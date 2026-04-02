## Why

`opencode-menu` crashes with a misleading "JSON parse error" when the transient menu is displayed. The root cause is twofold: the SDK's `condition-case` is too broad (swallowing callback errors as JSON errors), and `opencode--show-menu` builds the dynamic transient menu using private, unstable transient internals (`transient--parse-child`, direct `put` to `'transient--layout`) that produce a malformed layout vector at runtime.

## What Changes

- **`opencode-sdk.el`**: Narrow the `condition-case` in the `:then` callback so it only catches JSON parsing failures, not errors thrown by the caller-supplied callback.
- **`opencode.el`**: Replace the private-API layout mutation approach with the transient-supported `:setup-children` + `:hide` pattern. Session data is stored in module-level variables that the prefix's `:setup-children` function reads at display time. The `opencode--show-menu` function is simplified to set those variables and call `transient-setup`.

## Capabilities

### New Capabilities

_(none — this is a bug fix with no new user-facing capabilities)_

### Modified Capabilities

- `sdk-http`: The error-reporting contract for the async HTTP helper changes: errors thrown by the callback are no longer silently caught and re-labelled as "JSON parse error". The callback is now invoked outside the JSON `condition-case`.
- `opencode-menu`: The dynamic menu building mechanism changes from direct internal layout mutation to the `:setup-children` / `:hide` public API. Externally observable behaviour (keys, groups, labels) is preserved.

## Impact

- `opencode-sdk.el`: one function modified (`opencode-sdk--request`)
- `opencode.el`: `transient-define-prefix` form rewritten; `opencode--show-menu` simplified; two new `defvar`s added; `opencode--build-new-session-suffix` retained but its return value is no longer used for layout construction
- No public API surface changes; `opencode-menu` remains the sole entry point
- Depends on transient's documented `:setup-children` slot (available since transient 0.4.0) and `:hide` slot (available since transient 0.3.0)
