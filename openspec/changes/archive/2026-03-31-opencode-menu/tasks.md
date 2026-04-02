## 1. Package Setup

- [x] 1.1 Add `Package-Requires` header declaring `emacs "28.1"` and `opencode-sdk` in `opencode.el`
- [x] 1.2 Add `(require 'transient)`, `(require 'project)`, and `(require 'opencode-sdk)` to `opencode.el`

## 2. Project Root Resolution

- [x] 2.1 Implement helper `opencode--project-root` that returns `(project-root (project-current))` when a project is found, falling back to `default-directory`

## 3. Transient Menu Builder

- [x] 3.1 Implement `opencode--build-session-suffix (key session)` that creates a transient suffix for a single session, binding `key` (e.g., `"1"`) and displaying `session` title as the label
- [x] 3.2 The suffix action SHALL call `browse-url` with `(concat opencode-sdk-base-url "/" projectID "/session/" sessionID)` using values from the session alist
- [x] 3.3 Implement `opencode--build-new-session-suffix (directory)` that creates a transient suffix for key `n` labelled "New session"
- [x] 3.4 The new-session suffix action SHALL call `opencode-sdk-session-create` with `directory`, then on success call `browse-url` with the new session's URL, or display an error message on failure
- [x] 3.5 Implement `opencode--show-menu (sessions directory)` that dynamically assembles and invokes the transient with a "Sessions" group (keys 1–N) and an "Actions" group (key `n`)

## 4. Main Command

- [x] 4.1 Implement interactive command `opencode-menu`
- [x] 4.2 On invoke, resolve project root via `opencode--project-root` and display echo-area message "Fetching OpenCode sessions..."
- [x] 4.3 Call `opencode-sdk-session-list` with the resolved directory, `limit=5`, `roots=t`
- [x] 4.4 In the callback, if error is non-nil display it in the echo area and return
- [x] 4.5 In the callback on success, call `opencode--show-menu` with the sessions and directory

## 5. Provide and Finalize

- [x] 5.1 Ensure `(provide 'opencode)` is at the end of the file
- [x] 5.2 Manual smoke test: invoke `M-x opencode-menu` from a buffer in a git repo, verify transient appears with correct session titles and browser opens on selection
