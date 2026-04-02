# Spec: opencode-menu

## Purpose

Provides an interactive transient menu (`opencode-menu`) for managing OpenCode sessions within Emacs. Users can list recent sessions for the current project, open them in a browser, or create a new session — all from a single keyboard-driven menu.

## Requirements

### Requirement: Entry point command
The package SHALL provide an interactive command `opencode-menu` that can be invoked via `M-x opencode-menu`. Upon invocation it SHALL immediately display a message in the echo area indicating it is fetching sessions, then asynchronously fetch sessions and open a transient menu.

#### Scenario: Command is invoked
- **WHEN** the user calls `M-x opencode-menu`
- **THEN** a message SHALL appear in the echo area (e.g., "Fetching OpenCode sessions...")
- **THEN** the transient menu SHALL open once the session list response is received

---

### Requirement: Project root resolution
The command SHALL resolve the current project root by first calling `project-current`. If a project is found, it SHALL use `project-root` to obtain the root path. If `project-current` returns nil, it SHALL fall back to `default-directory`.

#### Scenario: Emacs project is active
- **WHEN** the current buffer belongs to a recognized Emacs project (e.g., a git repo)
- **THEN** the resolved directory SHALL be the project root, not the buffer's subdirectory

#### Scenario: No recognized project
- **WHEN** `project-current` returns nil
- **THEN** the resolved directory SHALL be `default-directory`

---

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

### Requirement: Open existing session in browser
Selecting a session key in the transient menu SHALL open a browser tab at the URL `<base-url>/<projectID>/session/<sessionID>` using `browse-url`.

#### Scenario: User selects session key 1
- **WHEN** the user presses `1` in the transient menu
- **THEN** `browse-url` SHALL be called with `<opencode-sdk-base-url>/<projectID>/session/<sessionID>` for the first session

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
