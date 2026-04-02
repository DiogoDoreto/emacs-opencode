## Context

`opencode-menu` fetches sessions asynchronously via `plz.el` and then displays a transient menu. The current implementation has two defects:

1. **`opencode-sdk.el` — over-broad `condition-case`**: The `:then` callback wraps both `json-parse-string` and `(funcall callback result nil)` in the same `condition-case`. Any error thrown inside the callback — including transient crashes — is caught and re-reported as `"JSON parse error: <original error>"`, masking the real failure.

2. **`opencode.el` — private transient internals**: `opencode--show-menu` uses `transient--parse-child` (a private function, `--` prefix) and directly `put`s to `'opencode--menu-prefix 'transient--layout`. This bypasses transient's initialization machinery. At runtime an `Args out of range` error occurs, caused by a layout vector with 3 elements where 4 are expected. This only manifests in interactive Emacs (not batch), because `transient-setup` only exercises display and keymap paths when a live display is present.

The supported transient mechanism for dynamic menus is `:setup-children` (a group slot that provides a function to build children at display time) combined with `:hide` (a group slot that hides the group when a predicate returns non-nil). Both are part of transient's public API and have been stable since transient ≥ 0.3.

## Goals / Non-Goals

**Goals:**
- Fix the misleading "JSON parse error" prefix on callback errors in `opencode-sdk.el`
- Replace private transient layout mutation with the `:setup-children` / `:hide` public API
- Preserve identical user-visible behaviour: two groups (Sessions, Actions), keys 1–5 for sessions, key `n` for new session

**Non-Goals:**
- Adding new features to the menu
- Changing the HTTP transport or error handling beyond scope of Bug 1
- Supporting more than 5 session slots

## Decisions

### Decision 1: Narrow `condition-case` in `opencode-sdk--request`

**Choice**: Restructure the `:then` lambda so `json-parse-string` is the only form inside `condition-case`. The `(funcall callback ...)` call moves outside.

```elisp
;; Before (callback errors swallowed):
(condition-case parse-err
    (let ((result (json-parse-string response ...)))
      (when callback (funcall callback result nil)))   ;; inside catch
  (error (funcall callback nil "JSON parse error: ...")))

;; After (only JSON parsing inside the catch):
(let ((result (condition-case parse-err
                  (json-parse-string response ...)
                (error
                 (when callback
                   (funcall callback nil (format "JSON parse error: %s" ...)))
                 nil))))
  (when (and callback result)
    (funcall callback result nil)))                    ;; outside catch
```

**Rationale**: `condition-case` should catch the specific error it's designed to handle. Catching everything leaks implementation details (error messages mention JSON when the problem is in the caller) and makes debugging harder.

**Alternative considered**: Wrap callback in its own `condition-case`. Rejected — it would still swallow genuine bugs in the callback; caller errors should propagate.

---

### Decision 2: Use module-level `defvar`s as the data bridge

**Choice**: Introduce two `defvar`s — `opencode--menu-sessions` and `opencode--menu-directory` — to carry session data and directory into the prefix's `:setup-children` function. `opencode--show-menu` sets them before calling `transient-setup`.

```elisp
(defvar opencode--menu-sessions nil)
(defvar opencode--menu-directory nil)

(defun opencode--show-menu (sessions directory)
  (setq opencode--menu-sessions sessions)
  (setq opencode--menu-directory directory)
  (opencode--build-new-session-suffix directory)   ;; sets up the command
  (transient-setup 'opencode--menu-prefix))
```

**Rationale**: `:setup-children` is a lambda stored in the prefix definition at load time. It cannot close over `sessions`/`directory` because those values only exist when the HTTP response arrives. Module-level vars are the standard Emacs pattern for this.

**Alternative considered**: Pass data via the transient `:scope` slot. Rejected — `:scope` is for prefix-level state; it would require a custom prefix class and adds unnecessary complexity for two plain values.

---

### Decision 3: Two static groups with `:hide` and `:setup-children`

**Choice**: Define `opencode--menu-prefix` with two groups declared statically in `transient-define-prefix`. The Sessions group uses `:hide` to disappear when the session list is empty, and `:setup-children` to build its suffix objects dynamically. The Actions group is fully static.

```elisp
(transient-define-prefix opencode--menu-prefix ()
  "OpenCode session menu (populated dynamically)."
  ["Sessions"
   :hide (lambda () (null opencode--menu-sessions))
   :setup-children
   (lambda (_children)
     (transient-parse-suffixes
      'opencode--menu-prefix
      (cl-loop for session in opencode--menu-sessions
               for key in '("1" "2" "3" "4" "5")
               collect (opencode--build-session-suffix key session))))]
  ["Actions"
   ("n" "New session" opencode--new-session)])
```

**Rationale**: 
- `:setup-children` is the documented, public API for dynamic suffix building. `transient-parse-suffixes` is also public (no `--` prefix), providing a stable conversion from human-readable specs to internal suffix objects.
- `:hide` keeps the Sessions group absent when empty, matching current behaviour.
- The Actions group stays static — there is no dynamic content needed there, so no reason to add complexity.
- `opencode--build-session-suffix` still uses `defalias` to create per-session commands; this pattern is unchanged.

**Alternative considered**: Single group with all suffixes. Rejected — loses the visual separation between session entries and the "New session" action, which is an intentional UX distinction.

**Alternative considered**: Dynamic prefix redefinition via `eval` on each call. Rejected — using `eval` for runtime code generation is an anti-pattern in Emacs Lisp; `transient-define-prefix` is a macro intended for load time.

## Risks / Trade-offs

- **`:setup-children` calling `transient-parse-suffixes` on every display** — Transient already calls `:setup-children` on each invocation; this is expected. The `cl-loop` over at most 5 sessions and `defalias` calls are cheap. No meaningful performance risk.

- **`opencode--new-session` is redefined on every `opencode--show-menu` call** — The `defalias` in `opencode--build-new-session-suffix` overwrites the previous command each time. Because the Actions group is static, the symbol must already be defined when `opencode--menu-prefix` is first loaded. If `opencode-menu` is called before the file is fully loaded this could fail. Mitigation: keep the `transient-define-prefix` at the bottom of the definitions, after `opencode--build-new-session-suffix`, ensuring the symbol exists when needed.

- **Module-level vars are not buffer-local** — If two concurrent async calls race (unlikely given the sequential UX flow), the second call's `setq` could overwrite the first's vars before the first menu displays. Mitigation: this race is extremely unlikely in normal use; no mitigation implemented.

## Open Questions

_(none — scope is well-defined and implementation approach is clear)_
