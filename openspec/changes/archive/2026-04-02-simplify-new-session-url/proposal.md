## Why

Opening a new OpenCode session currently makes an unnecessary `POST /session` API call just to obtain a session ID for URL construction — but the OpenCode web UI creates a new session automatically when navigating to `<base-url>/<b64_dir>/session` without an ID. Eliminating the API call makes the "new session" action synchronous, instant, and resilient to transient server errors.

## What Changes

- `opencode--session-url` is updated to make `session-id` optional: omitting it produces the "new session" URL (`/<b64_dir>/session`), passing it produces the "open existing session" URL (`/<b64_dir>/session/<id>`)
- The "new session" action in `opencode.el` is simplified to directly call `browse-url` with no async callback
- `opencode-sdk-session-create` is removed from `opencode-sdk.el` (it had no callers beyond the now-simplified action)

## Capabilities

### New Capabilities

- `session-url`: Constructing OpenCode browser URLs for both new and existing sessions from a directory path and optional session ID

### Modified Capabilities

*(none — no existing spec files)*

## Impact

- `opencode.el`: `opencode--session-url` signature change; "new session" lambda simplified
- `opencode-sdk.el`: `opencode-sdk-session-create` function removed
