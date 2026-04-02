## Why

The `opencode-sdk.el` package provides a thin, reusable Emacs Lisp wrapper around the OpenCode HTTP API, so that higher-level packages (like `opencode.el`) can interact with a running OpenCode server without duplicating HTTP plumbing or hardcoding connection details.

## What Changes

- Introduce `opencode-sdk.el` as a new file in the project (currently a stub)
- Add `opencode-sdk-base-url` custom variable to configure the OpenCode server URL
- Add async HTTP helper using `plz.el` for issuing requests and decoding JSON responses
- Add `opencode-sdk-session-list` to fetch sessions filtered by directory
- Add `opencode-sdk-session-create` to create a new session for a directory

## Capabilities

### New Capabilities

- `sdk-http`: Base async HTTP request infrastructure using `plz.el`, with JSON encoding/decoding and configurable base URL
- `sdk-session`: Session API operations — list sessions by directory and create a new session

### Modified Capabilities

_None — this is a new file with no prior implementation._

## Impact

- `opencode-sdk.el`: all new implementation
- Depends on `plz.el` (external package) and Emacs built-in `json.el`
- `opencode.el` will depend on `opencode-sdk.el` for all HTTP calls
