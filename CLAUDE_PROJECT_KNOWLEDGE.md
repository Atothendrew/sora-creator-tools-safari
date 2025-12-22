# CLAUDE_PROJECT_KNOWLEDGE

## Repository Layout
- Browser extension assets (`manifest.json`, `background.js`, `inject.js`, dashboard files, icons, imagery) live at the repo root.
- The Safari wrapper generated via `safari-web-extension-converter` lives in `safari-extension/Sora Creator Tools/` with macOS/iOS host apps, shared Swift sources, and the `.xcodeproj`.
- `imagery/Sorastat-logo.png` powers the README's sponsor callout—keep it updated if sponsorship changes.

## Git Remotes & Branches
- `origin` points to `fancyson-ai/sora-creator-tools` (upstream mainline).
- `safari` points to the fork (`Atothendrew/sora-creator-tools-safari`). Local `ios` tracks `safari/ios`.
- To sync the fork: `git fetch origin`, update `main`, then rebase or merge `ios` atop `main` before pushing (`git push safari ios --force-with-lease` after a rebase).
- After cross-branch integrations, rebuild both Xcode schemes (macOS + iOS/iPhone 16) to honor the project rules.

## Notes
- Prefer `@Observable` over `ObservableObject`, run `SwiftTests` for host app coverage when needed, and avoid iPhone 15 simulators per the repo guidelines.
- When adding Swift files to the wrapper, use the `xcodeproj` gem so the project references stay consistent.

## Codebase Overview
- `manifest.json`, `background.js`, `content.js`, `inject.js`, `dashboard.*` implement the Chrome/Safari web extension that instruments `https://sora.chatgpt.com`.
- `content.js` injects `api.js` first (request/body rewrite + duration dropdown/remix helpers) and then `inject.js`; `inject.js` is intentionally skipped on draft detail routes (`/d/...`) while `api.js` still runs. Metrics persist via `chrome.storage.local`.
- `dashboard.js/html/css` render the standalone analytics dashboard that opens via the browser action.
- Public-facing branding is "Creator Tools for Sora." The repo directory and Xcode project names still contain the legacy "Sora Creator Tools" label, but all manifest strings, CFBundle display names, and in-app copy now use the new name.
- `inject.js` is very large (~4K LOC) and hooks `fetch`/XHR to collect stats, power Gather/Analyze modes, and render badges in-page. Gather controls expose toggles for auto refresh and "Unload off-screen videos"; the latter uses an `IntersectionObserver` to remove `<video>` sources once cards leave the viewport, dramatically lowering memory use during long gather runs.
- Dashboard exports prefer `navigator.share` with a CSV `File` (so iPad/iOS Safari/extension pages can surface the system share sheet without download errors) and fall back to Blob downloads elsewhere.
- Gather mode’s “Unload off-screen videos” now also unloads images and uses a wider IntersectionObserver margin (600px) so long profile scrolls drop media src/srcset when offscreen and reload them when re-entering view.
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

