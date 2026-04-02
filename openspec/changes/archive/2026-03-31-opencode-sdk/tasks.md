## 1. Package Setup

- [x] 1.1 Add `Package-Requires` header declaring `plz` and `emacs "27.1"` in `opencode-sdk.el`
- [x] 1.2 Add `(require 'plz)` and `(require 'json)` to `opencode-sdk.el`
- [x] 1.3 Define `opencode-sdk` customization group

## 2. Base URL Configuration

- [x] 2.1 Define `opencode-sdk-base-url` defcustom with default `"http://localhost:4321"` in the `opencode-sdk` group

## 3. Async HTTP Infrastructure

- [x] 3.1 Implement internal helper `opencode-sdk--request` that takes `method`, `path`, optional `params` alist, optional request body, and `callback`
- [x] 3.2 Build the full URL by concatenating `opencode-sdk-base-url`, `path`, and query string from params using `url-build-query-string`
- [x] 3.3 Use `plz` to issue the async request with `Content-Type: application/json`
- [x] 3.4 On success, parse the response body with `json-parse-string` (returning alists) and call `callback` with `(result nil)`
- [x] 3.5 Wrap parse and plz error handling in `condition-case`; call `callback` with `(nil error-string)` on any failure

## 4. Session List

- [x] 4.1 Implement `opencode-sdk-session-list (directory limit roots callback)` that calls `opencode-sdk--request` with `GET /session` and params `directory`, `limit`, `roots`
- [x] 4.2 Pass the raw sessions array (or empty list) through to `callback`

## 5. Session Create

- [x] 5.1 Implement `opencode-sdk-session-create (directory callback)` that calls `opencode-sdk--request` with `POST /session` and query param `directory`
- [x] 5.2 Pass the created session alist through to `callback`

## 6. Provide and Finalize

- [x] 6.1 Ensure `(provide 'opencode-sdk)` is at the end of the file
- [x] 6.2 Manual smoke test: evaluate the file, call `opencode-sdk-session-list` against a running OpenCode instance, verify callback receives data
