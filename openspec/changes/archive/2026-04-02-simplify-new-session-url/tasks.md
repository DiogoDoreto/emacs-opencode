## 1. Update `opencode--session-url` in `opencode.el`

- [x] 1.1 Change the function signature to `(directory &optional session-id)`
- [x] 1.2 Update the function body to conditionally append `/session/<id>` when `session-id` is non-nil, or just `/session` when nil
- [x] 1.3 Update the docstring to document both URL output forms

## 2. Simplify the "new session" action in `opencode.el`

- [x] 2.1 Replace the async `opencode-sdk-session-create` callback lambda with a direct `browse-url` call using `opencode--session-url` with no session ID

## 3. Remove `opencode-sdk-session-create` from `opencode-sdk.el`

- [x] 3.1 Delete the `opencode-sdk-session-create` function definition
