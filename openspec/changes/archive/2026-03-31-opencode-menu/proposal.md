## Why

Emacs users working with OpenCode need a quick, keyboard-driven way to access their sessions for the current project without leaving the editor. A `transient` menu triggered by a single command gives them that — list recent sessions, open one in the browser, or start a new one.

## What Changes

- Introduce `opencode-menu` as the main entry point in `opencode.el` (currently a stub)
- The command resolves the current project root via `project-current`, falling back to `default-directory`
- Fetches up to 5 recent root sessions for that directory from the OpenCode API (async)
- Builds and displays a `transient` menu dynamically once the response arrives
- Sessions are bound to keys `1`–`5`; `n` creates a new session
- Selecting a session or creating a new one opens a browser tab at `<base-url>/<projectID>/session/<sessionID>`

## Capabilities

### New Capabilities

- `opencode-menu`: Transient menu for browsing and launching OpenCode sessions from within Emacs

### Modified Capabilities

_None — this is a new feature on top of the existing stubs._

## Impact

- `opencode.el`: all new implementation
- Depends on `opencode-sdk.el` for HTTP calls (`opencode-sdk-session-list`, `opencode-sdk-session-create`)
- Depends on `transient.el` (built into Emacs 28+) for the menu UI
- Uses `browse-url` (Emacs built-in) to open sessions in the browser
- `opencode-sdk` change must be implemented first (or in parallel)
