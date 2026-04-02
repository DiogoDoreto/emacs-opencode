## Context

`opencode.el` provides an Emacs transient menu for managing OpenCode sessions. The "new session" action currently calls `opencode-sdk-session-create` (a `POST /session` HTTP request) to create a session server-side, receives the new session ID in a callback, then constructs a URL and opens it in the browser.

This is unnecessary: the OpenCode web UI creates a new session automatically when navigated to `<base-url>/<b64-dir>/session` without an ID. The API call existed solely to obtain an ID for URL construction — a problem that dissolves once we know the URL pattern.

## Goals / Non-Goals

**Goals:**
- Make `opencode--session-url` handle both URL forms (with and without session ID) in a single, well-documented function
- Make the "new session" action synchronous and free of async plumbing
- Remove `opencode-sdk-session-create` as dead code

**Non-Goals:**
- Changing how existing sessions are listed or opened
- Adding any new UI affordances
- Modifying `opencode-sdk-base-url` configuration or the base64 encoding scheme

## Decisions

### Make `session-id` optional in `opencode--session-url`

**Decision**: Change the signature to `(directory &optional session-id)`. When `session-id` is nil, omit the final path segment; when provided, append `/session/<id>` as before.

**Rationale**: Both URL forms share the same base64-encoded directory prefix. A single function with clear docstring documenting both outputs is simpler than two separate functions that duplicate the encoding logic. The optional-arg pattern is idiomatic Emacs Lisp.

**Alternative considered**: Two separate functions (`opencode--session-url` and `opencode--new-session-url`). Rejected — more surface area, duplicated `base64-encode-string` call, and callers need to know which to use.

### Remove `opencode-sdk-session-create`

**Decision**: Delete the function outright.

**Rationale**: Its only purpose was to POST a new session and return the ID for URL construction. With URL-based session creation, there are zero callers. The SDK will gain write operations in the future, but those will be driven by concrete needs, not preserved as dead code.

## Risks / Trade-offs

- **No server-side confirmation before browser opens** → The browser will show a connection error if the OpenCode server is not running. This is acceptable — the browser error is more informative than the current Emacs minibuffer error, and the failure mode is visible immediately rather than after an async timeout.

- **Behaviour depends on web UI contract** → The assumption that `/<b64-dir>/session` always creates a new session is implicit. If OpenCode changes this URL behaviour, the feature silently breaks. → Mitigation: this is documented in the spec and the function docstring; it should be validated against OpenCode's own documentation or source if the contract ever becomes unclear.

## Open Questions

*(none — decisions made during exploration)*
