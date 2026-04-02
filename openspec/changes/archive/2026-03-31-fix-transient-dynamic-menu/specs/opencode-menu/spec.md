## MODIFIED Requirements

### Requirement: Session list display
The transient menu SHALL display up to 5 sessions returned by `opencode-sdk-session-list`, called with `limit=5` and `roots=true`. Each session SHALL be bound to a numeric key (`1` through `5`) in the order provided by the API. The session title SHALL be shown as the key's label. If fewer than 5 sessions exist, only those keys SHALL appear.

The Sessions group SHALL be built using transient's `:setup-children` public API, reading session data from the module-level variable `opencode--menu-sessions`. The Sessions group SHALL be hidden (via `:hide`) when `opencode--menu-sessions` is nil or empty.

#### Scenario: Sessions exist for the project
- **WHEN** the API returns 3 sessions
- **THEN** the menu SHALL show keys `1`, `2`, `3` with the corresponding session titles

#### Scenario: No sessions exist
- **WHEN** the API returns an empty list
- **THEN** the menu SHALL show no session keys, only the "New session" action

---

### Requirement: Create new session
The transient menu SHALL expose a key `n` labelled "New session" in a static "Actions" group. When pressed, it SHALL call `opencode-sdk-session-create` with the resolved project directory stored in `opencode--menu-directory`. Once the response is received, it SHALL open a browser tab at the new session's URL.

The `opencode--new-session` command SHALL be defined (via `defalias`) each time `opencode--show-menu` is called, closing over the current `directory` argument. The Actions group SHALL reference this symbol statically in the prefix definition.

#### Scenario: New session created successfully
- **WHEN** the user presses `n` in the transient menu
- **THEN** `opencode-sdk-session-create` SHALL be called with the resolved project directory
- **THEN** upon a successful response, `browse-url` SHALL be called with the new session's URL

#### Scenario: Session creation fails
- **WHEN** `opencode-sdk-session-create` calls back with a non-nil error
- **THEN** an error message SHALL be displayed in the echo area and no browser tab SHALL be opened
