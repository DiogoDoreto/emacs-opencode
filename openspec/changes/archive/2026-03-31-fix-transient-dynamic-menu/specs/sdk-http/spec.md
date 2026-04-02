## MODIFIED Requirements

### Requirement: Async HTTP request infrastructure
The package SHALL provide an internal async HTTP helper that sends requests using `plz.el` and delivers results via a caller-supplied callback of the form `(lambda (result error))`. On success, `result` SHALL be the parsed JSON response as an Elisp alist and `error` SHALL be `nil`. On failure, `result` SHALL be `nil` and `error` SHALL be a non-nil string describing the failure.

The `condition-case` that catches JSON parse errors SHALL only wrap the `json-parse-string` call itself. The caller-supplied callback SHALL be invoked outside of any `condition-case` so that errors thrown by the callback propagate naturally to the caller.

#### Scenario: Successful JSON response
- **WHEN** a request is made and the server responds with a 2xx JSON body
- **THEN** the callback SHALL be called with the parsed alist as `result` and `nil` as `error`

#### Scenario: Server unreachable
- **WHEN** a request is made and `curl` cannot connect to the server
- **THEN** the callback SHALL be called with `nil` as `result` and a descriptive error string as `error`

#### Scenario: JSON parse failure
- **WHEN** the server returns a response body that is not valid JSON
- **THEN** the callback SHALL be called with `nil` as `result` and an error string prefixed `"JSON parse error:"` as `error`

#### Scenario: Callback throws an error
- **WHEN** the server returns valid JSON and the callback throws a Lisp error
- **THEN** the error SHALL propagate to the caller unchanged, NOT wrapped with a `"JSON parse error:"` prefix
