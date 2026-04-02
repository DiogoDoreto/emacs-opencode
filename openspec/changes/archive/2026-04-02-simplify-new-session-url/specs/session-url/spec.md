## ADDED Requirements

### Requirement: Session URL construction
The `opencode--session-url` function SHALL accept a `directory` string and an optional `session-id` string and return a fully-formed browser URL.

When `session-id` is provided, the URL SHALL have the form `<base-url>/<b64-dir>/session/<session-id>`, opening the identified existing session.

When `session-id` is omitted or nil, the URL SHALL have the form `<base-url>/<b64-dir>/session`, causing the OpenCode web UI to create and open a new session automatically.

The base64 encoding of `directory` SHALL use URL-safe (no-padding) encoding, consistent with how OpenCode identifies projects in its web UI.

#### Scenario: URL for existing session
- **WHEN** `opencode--session-url` is called with a directory and a session ID
- **THEN** it returns `<base-url>/<b64-dir>/session/<session-id>`

#### Scenario: URL for new session
- **WHEN** `opencode--session-url` is called with a directory and no session ID
- **THEN** it returns `<base-url>/<b64-dir>/session`

### Requirement: New session action opens browser directly
The "new session" menu action in `opencode.el` SHALL open the new-session URL in the browser synchronously, without making any HTTP API call.

#### Scenario: New session from menu
- **WHEN** the user selects the "New session" action from the transient menu
- **THEN** the browser opens `<base-url>/<b64-dir>/session` immediately with no API request

### Requirement: Session create SDK function removed
`opencode-sdk-session-create` SHALL be removed from `opencode-sdk.el`, as session creation is now delegated entirely to the web UI via URL navigation.

#### Scenario: No create function in SDK
- **WHEN** `opencode-sdk.el` is loaded
- **THEN** `opencode-sdk-session-create` is not defined
