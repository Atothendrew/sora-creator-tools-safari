# CLAUDE_PROJECT_KNOWLEDGE

## Codebase Overview
- `manifest.json`, `background.js`, `content.js`, `inject.js`, `dashboard.*` implement the Chrome/Safari web extension that instruments `https://sora.chatgpt.com`.
- `content.js` injects `inject.js` into the page context and persists metrics via `chrome.storage.local`.
- `dashboard.js/html/css` render the standalone analytics dashboard that opens via the browser action.
- Public-facing branding is "Creator Tools for Sora." The repo directory and Xcode project names still contain the legacy "Sora Creator Tools" label, but all manifest strings, CFBundle display names, and in-app copy now use the new name.
- `inject.js` is very large (~4K LOC) and hooks `fetch`/XHR to collect stats, power Gather/Analyze modes, and render badges in-page. Gather controls expose toggles for auto refresh and "Unload off-screen videos"; the latter uses an `IntersectionObserver` to remove `<video>` sources once cards leave the viewport, dramatically lowering memory use during long gather runs.
- Dashboard exports first try `navigator.share` with a CSV `File` (so iPad/iOS Safari can surface the system share sheet) and fall back to Blob downloads elsewhere.
- The dashboard sidebar provides a persisted date filter (All, Today, Yesterday, quick Last 3/7/30 days, or any custom "last N days"). State lives in `chrome.storage.local` as `dashboardDateFilter` and constrains the posts list, quick-select buttons, and every chart that depends on `visibleSet`.

## Safari Wrapper
- Generated via `xcrun safari-web-extension-converter`; lives in `safari-extension/Sora Creator Tools/`.
- Schemes: `Sora Creator Tools (macOS)` and `Sora Creator Tools (iOS)`.
- Bundle identifiers were normalized to `com.soracreator.tools` (app) and `com.soracreator.tools.extension` (extension). These are defined in the Xcode project and mirrored inside `Shared (App)/ViewController.swift`.
- Build commands used:  
  - `xcodebuild -project "Sora Creator Tools.xcodeproj" -scheme "Sora Creator Tools (macOS)" -configuration Debug build`  
  - `xcodebuild -project "Sora Creator Tools.xcodeproj" -scheme "Sora Creator Tools (iOS)" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build`
- The iOS host’s `Main.html` + `Script.js` now show a Settings button (states: unknown/off) that posts `open-settings` back to `ViewController`.
- `ViewController` relays `open-settings` commands on iOS by opening `App-Prefs:root=SAFARI&path=WEB_EXTENSIONS`, falling back to `UIApplication.openSettingsURLString`. Remember to keep `LSApplicationQueriesSchemes` (`App-Prefs`, `app-prefs`) in `iOS (App)/Info.plist`.
- App Store validation enforces Safari’s manifest limits (name ≤ 40 chars, description ≤ 112). `manifest.json` now uses `name: "Creator Tools for Sora"` and a concise description to satisfy both Chrome and Safari packaging.
- macOS submissions require `LSApplicationCategoryType`; the host app plist sets it to `public.app-category.utilities`. Update this if the app’s category ever changes.
- All four bundles (macOS app/extension, iOS app/extension) set `ITSAppUsesNonExemptEncryption` to `false` so App Store uploads automatically declare there’s no non-exempt encryption.

## Cross-Browser Compatibility
- Added a lightweight polyfill (`if (typeof browser !== 'undefined' && typeof chrome === 'undefined') globalThis.chrome = browser;`) to `background.js`, `content.js`, and `dashboard.js` so the code works when Safari exposes only the `browser.*` namespace.
- All data storage relies on `chrome.storage.local`, which maps to Safari's extension storage without extra work.

