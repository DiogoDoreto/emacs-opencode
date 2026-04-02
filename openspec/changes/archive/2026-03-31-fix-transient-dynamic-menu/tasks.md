## 1. Fix SDK condition-case scope (opencode-sdk.el)

- [x] 1.1 Restructure the `:then` lambda in `opencode-sdk--request` so that `json-parse-string` is the only form inside the `condition-case`, returning `nil` on parse failure after calling the callback with the error string
- [x] 1.2 Move `(when (and callback result) (funcall callback result nil))` outside the `condition-case` so callback errors propagate naturally
- [x] 1.3 Verify: a JSON parse failure still calls the callback with `"JSON parse error: ..."` and `nil` result
- [x] 1.4 Verify: an error thrown inside the callback propagates without a `"JSON parse error:"` prefix

## 2. Add module-level state variables (opencode.el)

- [x] 2.1 Add `(defvar opencode--menu-sessions nil ...)` with docstring
- [x] 2.2 Add `(defvar opencode--menu-directory nil ...)` with docstring

## 3. Rewrite transient prefix definition (opencode.el)

- [x] 3.1 Replace the existing `transient-define-prefix opencode--menu-prefix` body with two static groups: `"Sessions"` and `"Actions"`
- [x] 3.2 Add `:hide (lambda () (null opencode--menu-sessions))` to the Sessions group
- [x] 3.3 Add `:setup-children` to the Sessions group using `transient-parse-suffixes` over `opencode--menu-sessions` with keys `'("1" "2" "3" "4" "5")`
- [x] 3.4 Keep the Actions group static with `("n" "New session" opencode--new-session)`
- [x] 3.5 Ensure `transient-define-prefix` appears after `opencode--build-new-session-suffix` in the file so `opencode--new-session` symbol is resolvable at load time

## 4. Simplify opencode--show-menu (opencode.el)

- [x] 4.1 Remove the `human-layout`, `raw-layout`, `session-specs`, and `keys` local bindings from `opencode--show-menu`
- [x] 4.2 Remove the `(put 'opencode--menu-prefix 'transient--layout ...)` call
- [x] 4.3 Remove the `(cl-mapcan ...)` / `transient--parse-child` / `eval` block
- [x] 4.4 Replace the body with: set `opencode--menu-sessions`, set `opencode--menu-directory`, call `opencode--build-new-session-suffix`, call `(transient-setup 'opencode--menu-prefix)`
- [x] 4.5 Update the docstring of `opencode--show-menu` to reflect the new implementation

## 5. Cleanup

- [x] 5.1 Remove `opencode--build-new-session-suffix`'s return value usage (it still defines the command via `defalias`, but callers no longer use the returned list for layout construction) — confirm the function body is still correct
- [x] 5.2 Byte-compile both files and confirm zero warnings
