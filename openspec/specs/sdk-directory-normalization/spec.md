# Spec: SDK Directory Normalization

## Purpose

Ensure directory path arguments are normalized before being sent to the OpenCode API,
preventing subtle bugs caused by trailing slashes that may differ between callers.

## Requirements

### Requirement: SDK normalizes directory paths before sending to the API
The SDK SHALL strip trailing slashes from directory path arguments before
including them in HTTP requests to the OpenCode API. This normalization SHALL
be performed by a private helper function `opencode-sdk--normalize-directory`
so the intent is explicit and the pattern is reusable by future SDK functions.

#### Scenario: Directory with trailing slash is normalized
- **WHEN** a caller passes a directory path ending in `/` (e.g. `/home/user/project/`)
- **THEN** the SDK sends the path without trailing slash (e.g. `/home/user/project`)

#### Scenario: Directory without trailing slash is unchanged
- **WHEN** a caller passes a directory path that does not end in `/`
- **THEN** the SDK sends the path as-is

#### Scenario: session-list normalizes directory argument
- **WHEN** `opencode-sdk-session-list` is called with a directory that has a trailing slash
- **THEN** the HTTP request is made with the normalized path in the `directory` query parameter

#### Scenario: session-create normalizes directory argument
- **WHEN** `opencode-sdk-session-create` is called with a directory that has a trailing slash
- **THEN** the HTTP request is made with the normalized path in the `directory` query parameter
