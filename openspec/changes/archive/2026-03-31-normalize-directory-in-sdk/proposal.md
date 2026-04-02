## Why

Emacs functions like `project-root` and `default-directory` return directory paths with a trailing slash by convention, but the OpenCode HTTP API expects paths without one. This mismatch causes incorrect requests when callers pass Emacs-sourced paths directly to the SDK, and any future caller faces the same silent pitfall.

## What Changes

- Add a private helper function `opencode-sdk--normalize-directory` in `opencode-sdk.el` that strips trailing slashes from a directory path.
- `opencode-sdk-session-list` normalizes its `directory` argument before use.
- `opencode-sdk-session-create` normalizes its `directory` argument before use.

## Capabilities

### New Capabilities

- `sdk-directory-normalization`: Internal normalization of directory paths within the SDK to ensure API compatibility. Callers may pass Emacs-convention paths (with trailing slash) and the SDK adapts them transparently.

### Modified Capabilities

<!-- No existing spec-level requirements are changing. -->

## Impact

- `opencode-sdk.el`: new private function, two call sites updated.
- `opencode.el`: no changes required — the fix is fully contained in the SDK layer.
- No breaking changes for callers; behavior only improves (previously broken paths now work correctly).
