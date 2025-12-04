# CURSOR_CHANGELOG

## 2025-12-04
- Generated Safari Web Extension Xcode wrapper via `safari-web-extension-converter`.
- Added Safari browser-namespace polyfill to `background.js`, `content.js`, and `dashboard.js`.
- Set consistent bundle identifiers (`com.soracreator.tools*`) and updated the shared controller to use the new extension ID.
- Built the macOS and iOS targets (`xcodebuild` against macOS and iPhone 16 simulator) to verify the wrapper compiles.
- Updated the iOS host UI to show Settings buttons (with open-settings handler) when the extension isn’t enabled, and wired the controller to deep-link into Settings via `UIApplication`.
- Added `LSApplicationQueriesSchemes` for `App-Prefs` so the host app can open Safari’s Settings page.
- Rebuilt both macOS and iOS schemes to confirm the new flow compiles.
- Shortened `manifest.json` `name`/`description` to satisfy Safari’s ≤40/≤112 character validation limits.
- Added `LSApplicationCategoryType` (`public.app-category.utilities`) to the macOS host’s `Info.plist` to satisfy App Store category requirements.
- Declared `ITSAppUsesNonExemptEncryption = NO` in all host/extension Info.plists so App Store submissions automatically state that no custom encryption is used.
- Enhanced Gather controls in `inject.js` with toggles for auto refresh and “Unload off-screen videos,” plus an IntersectionObserver that pauses/removes video sources when cards leave the viewport to cut memory usage.

