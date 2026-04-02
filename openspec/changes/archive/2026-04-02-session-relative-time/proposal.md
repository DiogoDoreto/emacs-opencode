## Why

The session list in the transient menu shows only a title, giving no indication of recency. Users need a quick way to distinguish an active session from an old one without leaving Emacs.

## What Changes

- The session label in the transient menu will include a relative timestamp suffix, e.g. `"Implement Gen3 capture (3h ago)"`.
- A new helper function `opencode--relative-time` will be added to `opencode.el` to convert a millisecond epoch to a compact relative string.
- `opencode--build-session-suffix` will be updated to append the relative time to the session title when available.

## Capabilities

### New Capabilities

- `session-relative-time`: Displays a human-readable relative time ("just now", "3h ago", "2d ago") next to each session title in the transient menu, derived from the session's `time.updated` field.

### Modified Capabilities

<!-- none -->

## Impact

- `opencode.el`: new helper function, modified label builder.
- No changes to `opencode-sdk.el` — the raw session alist already carries the `time` field.
- No new dependencies.
