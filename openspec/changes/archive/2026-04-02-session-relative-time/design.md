## Context

The transient menu in `opencode.el` lists up to 5 sessions, each displayed with only its title. The session alist returned by the SDK already includes a `time.updated` field (millisecond epoch integer). No new data fetching is required — the information is available but unused in the UI.

## Goals / Non-Goals

**Goals:**
- Add a compact relative timestamp suffix to each session label (e.g. `"Implement Gen3 capture (3h ago)"`).
- Keep all display logic in `opencode.el`; `opencode-sdk.el` is unchanged.
- Handle missing or nil `time.updated` gracefully (show nothing).

**Non-Goals:**
- Absolute timestamp display.
- Locale-aware or configurable time formatting.
- Auto-refreshing the menu as time passes.

## Decisions

### 1. Relative time buckets

| Delta (seconds) | Display      |
|-----------------|--------------|
| < 60            | `"just now"` |
| < 3,600         | `"Xm ago"`   |
| < 86,400        | `"Xh ago"`   |
| < 604,800       | `"Xd ago"`   |
| ≥ 604,800       | `"Xw ago"`   |

Rationale: compact enough for a transient label, covers the full range a session might age through without becoming cryptic.

### 2. Label format: title first, time in parentheses

`"<title> (<relative-time>)"`

Rationale: matches common Emacs conventions (e.g. Magit status lines); the title is the primary identifier, the time is supplementary.

### 3. Millisecond → seconds conversion in Emacs Lisp

The `time.updated` value is a 13-digit millisecond epoch. Emacs time functions operate in seconds. Conversion: divide by 1000, pass to `seconds-to-time`, then compute `float-time` of `time-subtract` against `current-time`.

### 4. Graceful nil handling

If `(alist-get 'updated (alist-get 'time session))` returns nil, `opencode--relative-time` returns nil, and the label falls back to the bare title — no error, no visible change.

## Risks / Trade-offs

- **Clock skew**: If the machine clock differs from the server clock the relative time may appear off. → No mitigation; acceptable for a display hint.
- **Integer overflow**: Emacs Lisp integers are 62-bit on 64-bit systems; a 13-digit millisecond timestamp fits comfortably.
- **Label width**: Very long titles combined with the timestamp suffix could be wide. → Out of scope per the proposal; transient handles overflow natively.
