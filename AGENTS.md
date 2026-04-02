## What's this projec about?
Emacs users working with OpenCode need a quick, keyboard-driven way to access their sessions for the current project without leaving the editor. A `transient` menu triggered by a single command gives them that — list recent sessions, open one in the browser, or start a new one.

## Notable files in this project

### `opencode-sdk.el`

The `opencode-sdk.el` package provides a thin, reusable Emacs Lisp wrapper around the OpenCode HTTP API, so that higher-level packages (like `opencode.el`) can interact with a running OpenCode server without duplicating HTTP plumbing or hardcoding connection details.

The reference specs for opencode HTTP API can be found at `./assets/opencode-http-spec.json`

### `opencode.el`

The `opencode.el` package includes the UI logic of the package, made using emacs' transient package.
