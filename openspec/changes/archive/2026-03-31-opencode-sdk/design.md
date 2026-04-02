## Context

`opencode-sdk.el` is currently a stub file. The OpenCode HTTP API is well-defined (OpenAPI 3.1 spec), runs locally on a configurable URL, and uses standard JSON over HTTP. Emacs has no built-in async HTTP client suitable for this — `url.el` is synchronous and awkward; `plz.el` is a clean, actively maintained async HTTP library built on `curl`.

## Goals / Non-Goals

**Goals:**
- Provide a `defcustom` for the base URL so users can point the SDK at any running OpenCode instance
- Wrap the two session endpoints needed for the first feature: list sessions and create a session
- All HTTP calls MUST be async (non-blocking) using `plz.el`
- Return parsed Elisp data structures (alists from JSON) to callers via callbacks

**Non-Goals:**
- Wrapping every endpoint in the OpenCode API spec (grow incrementally)
- Error UI — the SDK layer surfaces errors to callers, not to users directly
- Caching or retrying requests

## Decisions

### Use `plz.el` for HTTP

`plz.el` provides a clean async interface over `curl`, handles JSON content types, and is the de-facto standard for modern Emacs HTTP clients. Alternative (`url.el`) is synchronous and would block Emacs.

### Callback-based async pattern

Functions accept a `callback` argument called with `(result error)`. `result` is the parsed JSON alist on success; `error` is a string on failure. This is the simplest async contract in Elisp — no need for promises or futures at this stage.

```
(opencode-sdk-session-list dir 5 t
  (lambda (sessions err)
    (if err
        (message "Error: %s" err)
      (dolist (s sessions) ...))))
```

Alternative (returning a `plz` future) would require callers to handle the future object, adding complexity for no benefit at this stage.

### Query params via URL construction

Session list and session create both use query parameters (`?directory=...&limit=...`). These will be constructed with `url-build-query-string` / string formatting rather than a generic param map, keeping the SDK functions explicit and readable.

### `defcustom` for base URL in `opencode-sdk` group

```elisp
(defcustom opencode-sdk-base-url "http://localhost:4321"
  "Base URL of the running OpenCode HTTP server."
  :type 'string
  :group 'opencode-sdk)
```

No auto-detection of port — users configure it explicitly.

## Risks / Trade-offs

- [`plz.el` not installed] → Emacs will error at load time. Mitigation: declare it in `Package-Requires` so package managers install it automatically.
- [OpenCode server not running] → `plz` will call back with a curl error. Mitigation: pass a descriptive error string to the callback; callers decide how to surface it.
- [JSON parsing failure] → `json-parse-string` may throw. Mitigation: wrap parse in `condition-case` and pass error to callback.
