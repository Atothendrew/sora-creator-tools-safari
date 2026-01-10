# CURSOR_CHANGELOG

## 2025-01-10
- Created new `ios-features` branch from `origin/main` (base repo).
- Added Safari/iOS support by:
  - Adding Safari compatibility shim (`browser` → `chrome` polyfill) to `background.js`, `content.js`, and `dashboard.js`.
  - Copying `safari-extension/` Xcode wrapper (macOS + iOS host apps) from the `ios` branch.
  - Adding `xcuserdata/` to `.gitignore` to exclude Xcode user-specific files.
- Shortened `manifest.json` name (22 chars) and description (104 chars) to satisfy Safari's ≤40/≤112 character limits.
- All origin/main functionality preserved - this is an additive change only.
