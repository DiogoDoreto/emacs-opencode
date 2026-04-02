## Context

`opencode-sdk.el` is a thin HTTP wrapper around the OpenCode API. Two public functions — `opencode-sdk-session-list` and `opencode-sdk-session-create` — accept a `directory` argument that is passed as a query parameter to the API. Emacs functions (`project-root`, `default-directory`) return directory paths with a trailing slash by convention (e.g. `/home/user/project/`), while the OpenCode API expects no trailing slash. This mismatch causes incorrect requests silently.

## Goals / Non-Goals

**Goals:**
- Introduce `opencode-sdk--normalize-directory` as the single, named normalization point inside the SDK.
- Apply normalization in all current SDK functions that accept a `directory` parameter.
- Document the Emacs-convention → API-convention mapping clearly in the helper's docstring so future contributors understand and follow the pattern.

**Non-Goals:**
- Changing any behavior in `opencode.el` — the fix is fully contained in the SDK layer.
- Normalizing other kinds of path arguments (e.g. file paths, URL segments).
- Validating that the directory exists on disk.

## Decisions

### Use a named `defun`, not `defalias` or inline calls

**Decision:** Implement `opencode-sdk--normalize-directory` as a `defun` with a full docstring, rather than a `defalias` to `directory-file-name` or an inline `directory-file-name` call at each site.

**Rationale:** A `defun` carries intent. The docstring states *why* normalization is needed (API contract), not just *what* it does. Future contributors adding new SDK functions will see this as the established pattern to follow. An inline call or alias conveys mechanics but not purpose.

**Alternatives considered:**
- `defalias`: Creates the named abstraction but offers no docstring slot for explaining the API contract.
- Inline `directory-file-name` at each call site: Scatters the adaptation logic and forces future contributors to rediscover the reason.
- Normalize in `opencode-sdk--request`: Too generic — the request function doesn't know which params are directory paths.

### Delegate to `directory-file-name`

**Decision:** Implement the helper by calling Emacs's built-in `directory-file-name`, which removes a trailing slash from a directory name string.

**Rationale:** `directory-file-name` is the idiomatic Emacs Lisp function for this transformation. It handles edge cases (e.g. root `/`, already-clean paths) correctly and is well-tested. There is no reason to reimplement string stripping manually.

## Risks / Trade-offs

- [Minimal risk] The change is additive (new private function) and the two updated call sites are straightforward. No caller API surface changes.
- [Trade-off] Wrapping `directory-file-name` adds one thin indirection. This is intentional and the cost is negligible.

## Open Questions

None. The approach is fully determined.
