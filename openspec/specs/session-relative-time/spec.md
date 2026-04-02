# Capability: Session Relative Time

## Purpose

Display a compact, human-readable relative timestamp next to each session title in the transient menu, derived from the session's `time.updated` field.

## Requirements

### Requirement: Session label includes relative time
The transient menu label for each session SHALL include a compact relative timestamp suffix derived from `time.updated`, formatted as `"<title> (<relative-time>)"`. If `time.updated` is absent or nil, the label SHALL display only the title with no suffix.

#### Scenario: Recent session shows relative time
- **WHEN** a session has `time.updated` set to a millisecond epoch timestamp
- **THEN** the session label in the transient menu SHALL be `"<title> (<X> ago)"` or `"<title> (just now)"`

#### Scenario: Missing time field shows plain title
- **WHEN** a session has no `time.updated` value (nil or missing)
- **THEN** the session label SHALL display only the title, with no parenthetical suffix

### Requirement: Relative time bucketing
The `opencode--relative-time` function SHALL convert a millisecond epoch integer to a human-readable relative string using the following rules:

- Delta < 60 seconds → `"just now"`
- Delta < 3,600 seconds → `"Xm ago"` (X = whole minutes)
- Delta < 86,400 seconds → `"Xh ago"` (X = whole hours)
- Delta < 604,800 seconds → `"Xd ago"` (X = whole days)
- Delta ≥ 604,800 seconds → `"Xw ago"` (X = whole weeks)

#### Scenario: Delta under one minute
- **WHEN** `time.updated` is 30 seconds in the past
- **THEN** `opencode--relative-time` SHALL return `"just now"`

#### Scenario: Delta in hours
- **WHEN** `time.updated` is 3 hours in the past
- **THEN** `opencode--relative-time` SHALL return `"3h ago"`

#### Scenario: Delta in days
- **WHEN** `time.updated` is 2 days in the past
- **THEN** `opencode--relative-time` SHALL return `"2d ago"`

#### Scenario: Delta in weeks
- **WHEN** `time.updated` is 10 days in the past
- **THEN** `opencode--relative-time` SHALL return `"1w ago"`

#### Scenario: Nil input returns nil
- **WHEN** `opencode--relative-time` is called with nil
- **THEN** it SHALL return nil
