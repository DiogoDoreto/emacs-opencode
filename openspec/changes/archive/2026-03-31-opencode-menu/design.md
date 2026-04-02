## Context

`opencode.el` is a stub. The user wants a keyboard-driven way to access OpenCode sessions for their current Emacs project. Emacs's `transient` library (built into Emacs 28+) is the established way to build these kinds of command menus. The flow is: resolve project root → fetch sessions async → display transient → open browser.

## Goals / Non-Goals

**Goals:**
- Single entry point: `M-x opencode-menu`
- Resolve project root via `project-current`, fall back to `default-directory`
- Fetch up to 5 recent root-level sessions for the resolved directory asynchronously
- Build and display a `transient` menu dynamically after the fetch completes
- Bind sessions to keys `1`–`5`, new session to `n`
- Open a browser tab at `<base-url>/<projectID>/session/<sessionID>` for session selection and new session creation

**Non-Goals:**
- Displaying session content inside Emacs (no buffer rendering of AI output)
- Polling or auto-refreshing the menu
- Handling more than 5 sessions in the menu

## Decisions

### Async-then-show pattern for the transient

The transient is built and opened only after the session list response arrives. This avoids a half-rendered menu with a "loading" state, which `transient` doesn't support cleanly.

```
invoke → plz GET /session → callback → build transient suffix list → transient-setup
```

Alternative (show immediately with placeholder rows) would require refreshing a live transient, which is complex and fragile.

### Dynamic transient using `transient-define-prefix` with runtime suffixes

`transient` supports defining suffix groups programmatically at call time by passing a `children` argument to `transient-setup`. Session keys `1`–`5` are generated from the session list at callback time — no static `transient-define-prefix` with hardcoded slots.

### URL construction

The browser URL is assembled as:
```
(concat opencode-sdk-base-url "/" projectID "/session/" sessionID)
```

Both `projectID` and `sessionID` are available on the session alist returned by the SDK — no additional API call needed.

### New session: wait for POST response, then open browser

After `POST /session`, the response contains the new session's `id` and `projectID`. Open the browser only after the response, not before — there's nothing to show at that URL until the session exists. The wait should be brief; show an echo-area message while pending.

### Project root resolution order

1. `(project-root (project-current))` — respects `.project` files, `git` roots, etc.
2. Fall back to `default-directory` if `project-current` returns nil.

This ensures the directory sent to the API matches what OpenCode considers the project root.

## Risks / Trade-offs

- [transient not available] → Emacs < 28 won't have `transient` built in. Mitigation: declare `(emacs "28.1")` in `Package-Requires`.
- [slow network response] → user invokes menu and nothing happens for a second. Mitigation: show an echo-area message "Fetching OpenCode sessions..." immediately on invoke.
- [more than 5 sessions exist] → older sessions not reachable from the menu. Acceptable for v1; full session browser is a future feature.
