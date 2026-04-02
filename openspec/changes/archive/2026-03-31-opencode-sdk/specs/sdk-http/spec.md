## ADDED Requirements

### Requirement: Configurable base URL
The package SHALL expose a `opencode-sdk-base-url` custom variable that specifies the base URL of the running OpenCode HTTP server. It SHALL default to `"http://localhost:4321"` and belong to the `opencode-sdk` customization group.

#### Scenario: User configures a custom URL
- **WHEN** the user sets `opencode-sdk-base-url` to `"http://localhost:9000"`
- **THEN** all subsequent SDK requests SHALL use `"http://localhost:9000"` as the base URL

#### Scenario: Default URL is used when not customized
- **WHEN** the user has not set `opencode-sdk-base-url`
- **THEN** all SDK requests SHALL use `"http://localhost:4321"` as the base URL

---

### Requirement: Async HTTP request infrastructure
The package SHALL provide an internal async HTTP helper that sends requests using `plz.el` and delivers results via a caller-supplied callback of the form `(lambda (result error))`. On success, `result` SHALL be the parsed JSON response as an Elisp alist and `error` SHALL be `nil`. On failure, `result` SHALL be `nil` and `error` SHALL be a non-nil string describing the failure.

#### Scenario: Successful JSON response
- **WHEN** a request is made and the server responds with a 2xx JSON body
- **THEN** the callback SHALL be called with the parsed alist as `result` and `nil` as `error`

#### Scenario: Server unreachable
- **WHEN** a request is made and `curl` cannot connect to the server
- **THEN** the callback SHALL be called with `nil` as `result` and a descriptive error string as `error`

#### Scenario: JSON parse failure
- **WHEN** the server returns a response body that is not valid JSON
- **THEN** the callback SHALL be called with `nil` as `result` and an error string as `error`

---

### Requirement: List sessions by directory
The package SHALL provide `opencode-sdk-session-list`, a function that asynchronously fetches sessions from `GET /session` filtered by a given directory path, with `limit` and `roots` query parameters, and delivers the result via callback.

#### Scenario: Sessions found for directory
- **WHEN** `opencode-sdk-session-list` is called with a directory that has existing sessions
- **THEN** the callback SHALL receive a list of session alists, each containing at minimum `id`, `projectID`, `title`, and `time`

#### Scenario: No sessions for directory
- **WHEN** `opencode-sdk-session-list` is called with a directory that has no sessions
- **THEN** the callback SHALL receive an empty list as `result` and `nil` as `error`

#### Scenario: Limit is respected
- **WHEN** `opencode-sdk-session-list` is called with `limit` set to 5
- **THEN** the request SHALL include `?limit=5` and the response SHALL contain at most 5 sessions

---

### Requirement: Create a session for a directory
The package SHALL provide `opencode-sdk-session-create`, a function that asynchronously creates a new session via `POST /session?directory=<path>` and delivers the created session via callback.

#### Scenario: Session created successfully
- **WHEN** `opencode-sdk-session-create` is called with a valid directory path
- **THEN** the callback SHALL receive a session alist containing at minimum `id` and `projectID`

#### Scenario: Server returns error on create
- **WHEN** `opencode-sdk-session-create` is called and the server returns a non-2xx response
- **THEN** the callback SHALL receive `nil` as `result` and a non-nil error string
