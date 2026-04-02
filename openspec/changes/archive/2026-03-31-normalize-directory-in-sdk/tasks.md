## 1. Add normalization helper

- [x] 1.1 Add `opencode-sdk--normalize-directory` as a `defun` in `opencode-sdk.el`, implemented via `directory-file-name`, with a docstring explaining the Emacs trailing-slash convention and the API's expectation

## 2. Apply normalization at call sites

- [x] 2.1 Update `opencode-sdk-session-list` to normalize `directory` via `opencode-sdk--normalize-directory` before building the params alist
- [x] 2.2 Update `opencode-sdk-session-create` to normalize `directory` via `opencode-sdk--normalize-directory` before building the params alist
