## 1. Relative Time Helper

- [x] 1.1 Add `opencode--relative-time` function to `opencode.el` that accepts a millisecond epoch integer (or nil) and returns a compact relative string per the bucketing spec, or nil if input is nil

## 2. Session Label Update

- [x] 2.1 Update `opencode--build-session-suffix` to extract `time.updated` from the session alist
- [x] 2.2 Append the relative time suffix to the session label in the format `"<title> (<relative-time>)"`, falling back to the plain title when relative time is nil
