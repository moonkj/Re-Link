# Re-Link iOS Build Size Analysis

**Date**: 2026-03-20
**Build type**: Release (iphoneos)
**Flutter**: 3.41.2

---

## 1. Overall Build Size

| Component | Size |
|-----------|------|
| **Total Runner.app bundle** | **45 MB** |
| Runner binary (main executable) | 3.4 MB |
| App.framework (compiled Dart code) | 13 MB |
| Flutter.framework (engine) | 14 MB + 842 KB ICU data |
| Frameworks/ total (all native plugins) | ~40 MB |
| Assets.car (compiled asset catalog) | 522 KB |
| App icons (PNG) | ~33 KB |

> **Note**: The 45 MB uncompressed `.app` bundle typically compresses to ~15-20 MB as an IPA for App Store delivery. Apple's App Thinning further reduces the download size.

---

## 2. Top 10 Largest Files in Bundle

| Rank | File | Size | Notes |
|------|------|------|-------|
| 1 | `Frameworks/Flutter.framework/Flutter` | 14 MB | Flutter engine (irreducible) |
| 2 | `Frameworks/App.framework/App` | 13 MB | Compiled Dart code |
| 3 | `Runner` (main binary) | 3.4 MB | App + statically-linked Google Ads SDK (~8.7 MB pre-link) |
| 4 | `Frameworks/sqlite3.framework/sqlite3` | 1.2 MB | SQLite native library |
| 5 | `Frameworks/webview_flutter_wkwebview/...` | 1.0 MB | WebView (transitive dep of google_mobile_ads) |
| 6 | `Frameworks/DKImagePickerController/...` | 1.0 MB | Image picker native (dependency of file_picker) |
| 7 | `Frameworks/SDWebImage.framework/SDWebImage` | 831 KB | Image loading (dep of DKPhotoGallery) |
| 8 | `Frameworks/DKPhotoGallery.framework/...` | 801 KB | Photo gallery (dep of DKImagePickerController) |
| 9 | `Frameworks/in_app_purchase_storekit/...` | 698 KB | StoreKit IAP plugin |
| 10 | `Frameworks/libwebp.framework/libwebp` | 610 KB | WebP codec (for flutter_image_compress) |

---

## 3. Native Framework Size Breakdown (Frameworks/)

### Core (irreducible)
| Framework | Binary Size | Purpose |
|-----------|-------------|---------|
| Flutter.framework | 14 MB | Engine |
| App.framework | 13 MB | Compiled Dart |
| libswift_Concurrency.dylib | 540 KB | Swift runtime |
| objective_c.framework | 178 KB | Dart FFI bridge |

### Database
| Framework | Binary Size | Purpose |
|-----------|-------------|---------|
| sqlite3.framework | 1.2 MB | SQLite |
| sqlite3_flutter_libs.framework | 108 KB | SQLite bridge |

### Google Sign-In chain (for Google Drive backup)
| Framework | Binary Size | Purpose |
|-----------|-------------|---------|
| GoogleSignIn.framework | 278 KB | Sign-in UI |
| GTMSessionFetcher.framework | 424 KB | HTTP networking |
| GTMAppAuth.framework | 290 KB | OAuth |
| AppAuth.framework | 321 KB | OAuth core |
| AppCheckCore.framework | 316 KB | App attestation |
| FBLPromises.framework | 166 KB | Promise utility |
| GoogleUtilities.framework | 130 KB | Google shared utils |
| **Subtotal** | **~1.9 MB** | |

### Google Mobile Ads (statically linked into Runner binary)
- Native SDK: **~8.7 MB** (pre-link, contributes significantly to the 3.4 MB Runner binary after dead-code stripping)
- Also pulls in: `webview_flutter_wkwebview` (1.0 MB) as a transitive dependency

### Image/File handling chain
| Framework | Binary Size | Purpose |
|-----------|-------------|---------|
| DKImagePickerController.framework | 1.0 MB | Image picker (from file_picker) |
| DKPhotoGallery.framework | 801 KB | Photo preview (dep of above) |
| SDWebImage.framework | 831 KB | Image loading (dep of above) |
| SDWebImageWebPCoder.framework | 112 KB | WebP support |
| SwiftyGif.framework | 236 KB | GIF support (dep of DKPhotoGallery) |
| Mantle.framework | 172 KB | Model framework (dep of flutter_image_compress) |
| libwebp.framework | 610 KB | WebP codec |
| image_picker_ios.framework | 200 KB | Image picker |
| file_picker.framework | 156 KB | File picker |
| flutter_image_compress_common.framework | 369 KB | Image compression |
| **Subtotal** | **~4.5 MB** | |

### Media
| Framework | Binary Size | Purpose |
|-----------|-------------|---------|
| audio_waveforms.framework | 327 KB | Waveform display |
| record_ios.framework | 340 KB | Audio recording |

### Other
| Framework | Binary Size | Purpose |
|-----------|-------------|---------|
| in_app_purchase_storekit.framework | 698 KB | IAP |
| webview_flutter_wkwebview.framework | 1.0 MB | WebView (google_mobile_ads dep) |
| icloud_storage.framework | 230 KB | iCloud |
| share_plus.framework | 117 KB | Sharing |
| url_launcher_ios.framework | 202 KB | URL launch |
| package_info_plus.framework | 90 KB | Package info |
| integration_test.framework | 98 KB | **SHOULD NOT BE IN RELEASE** |

---

## 4. Asset Analysis

| Category | Size | File Count | Details |
|----------|------|------------|---------|
| **Total assets/** | **772 KB** | 8 files | |
| Fonts (JetBrainsMono) | 532 KB | 2 files | Bold + Regular |
| Fonts (Pretendard) | 0 KB | 4 files | **Empty placeholder files (0 bytes)** |
| Data (korean_clans.json) | 22 KB | 1 file | Clan lookup data |
| Images (app_icon.png) | 216 KB | 1 file | Source icon |
| Animations/ | 0 KB | 0 files | **Empty directory** |
| Icons/ | 0 KB | 0 files | **Empty directory** |

### Asset Issues Found
1. **Pretendard font files are 0 bytes** -- 4 OTF files declared in pubspec.yaml are empty placeholders. The app will fall back to system font at runtime, but the pubspec declarations still reference them.
2. **Empty `assets/animations/` and `assets/icons/` directories** are declared in pubspec.yaml but contain no files.
3. **`google_fonts` package** is used only for Noto Serif KR (Display style T1). This downloads the font at runtime on first use, which is good for avoiding bundling the 24 MB CJK font, but adds a dependency and potential first-launch delay.

---

## 5. Dependency Bloat Analysis

### HIGH IMPACT -- google_mobile_ads (~8.7 MB native + 1 MB webview_flutter)

The Google Mobile Ads SDK is the single largest contributor to build size. It:
- Adds ~8.7 MB of native code (statically linked into Runner)
- Pulls in `webview_flutter_wkwebview` (1.0 MB) as a transitive dependency
- The FREE/BASIC plans show banner + native ads, so this is functionally required
- **Estimated total impact: ~5-6 MB of the final binary** (after dead-code elimination)

### MEDIUM IMPACT -- file_picker dependency chain (~3.2 MB)

`file_picker` (used for .rlink file import) pulls in on iOS:
- DKImagePickerController (1.0 MB)
- DKPhotoGallery (801 KB)
- SDWebImage (831 KB)
- SwiftyGif (236 KB)
- Mantle (172 KB)

This is a heavy chain for a feature that only needs to pick `.rlink` files (not images). Consider using a lighter alternative.

### MEDIUM IMPACT -- google_fonts package

Only used for a single font family (Noto Serif KR for T1 display style). Runtime download works but:
- Adds the google_fonts Dart package to the binary
- Requires network on first use
- Could use system serif font as fallback instead

### LOW IMPACT -- integration_test.framework (98 KB)

`integration_test` framework is present in the release build. This should only be included in test builds, not production releases. This likely comes from having `integration_test` in `dev_dependencies` but the iOS build configuration is not properly excluding it.

### LOW IMPACT -- Unused JetBrainsMono font (532 KB)

JetBrainsMono (Bold + Regular) is bundled and declared in pubspec.yaml. It is only referenced in `AppTypography.code` style, which is used in the invite feature. For a family memory app, a monospace font for invite codes could use the system monospace font instead, saving 532 KB.

---

## 6. Recommendations

### Priority 1 -- Quick Wins (Effort: Low, Savings: ~630 KB)

| Action | Estimated Savings |
|--------|-------------------|
| Remove `integration_test.framework` from release builds (fix Podfile/build config) | 98 KB |
| Remove JetBrainsMono font files, use system monospace | 532 KB |
| Remove empty Pretendard 0-byte placeholders from pubspec.yaml | Cleanliness |
| Remove empty `assets/animations/` and `assets/icons/` from pubspec.yaml | Cleanliness |

### Priority 2 -- Medium Effort (Savings: ~3 MB)

| Action | Estimated Savings |
|--------|-------------------|
| Replace `file_picker` with a lightweight document-only picker (e.g., `document_picker` or direct UTI-based approach) to avoid the DKImagePickerController/SDWebImage/SwiftyGif chain | ~3.2 MB |
| Consider replacing `google_fonts` with a system serif fallback for T1 display text, or bundle only the specific Noto Serif KR weights needed | Package removal |

### Priority 3 -- Architectural (Savings: ~5-6 MB, but with revenue impact)

| Action | Estimated Savings |
|--------|-------------------|
| Defer google_mobile_ads to a separate on-demand module (if Flutter supports deferred loading for native plugins) -- or accept the size cost as the price of ad monetization | ~5-6 MB |
| Build with `--split-debug-info` and `--obfuscate` flags for release | Reduces App.framework size |

### Priority 4 -- Build Configuration

| Action | Impact |
|--------|--------|
| Ensure `flutter build ios --release --split-debug-info=build/debug-info --obfuscate` is used for production builds | Reduces App.framework by stripping debug symbols |
| Verify Xcode build settings strip debug symbols (`STRIP_INSTALLED_PRODUCT = YES`, `DEPLOYMENT_POSTPROCESSING = YES`) | Further binary size reduction |
| Enable Bitcode (if not already) for App Store Thinning | Apple-side optimization |
| Set `DEAD_CODE_STRIPPING = YES` in Xcode | Removes unused native code |

---

## 7. Estimated Size After Optimizations

| Scenario | Uncompressed .app | Est. IPA |
|----------|-------------------|----------|
| **Current** | 45 MB | ~18-20 MB |
| After Priority 1 (quick wins) | ~44.4 MB | ~17-19 MB |
| After Priority 1 + 2 | ~41 MB | ~15-17 MB |
| After Priority 1 + 2 + build flags | ~38 MB | ~13-15 MB |

---

## 8. Summary

The 45 MB uncompressed bundle is reasonable for a Flutter app with ads, IAP, image handling, audio recording, and cloud backup. The dominant size contributors are:

1. **Flutter engine** (14 MB) -- irreducible
2. **Compiled Dart code** (13 MB) -- reducible with obfuscation/split-debug-info
3. **Google Mobile Ads SDK** (~5-6 MB effective) -- required for monetization
4. **file_picker dependency chain** (~3.2 MB) -- replaceable with lighter alternative

The most impactful actionable optimization is replacing `file_picker` with a document-only picker, which would save approximately 3 MB by eliminating the DKImagePickerController/SDWebImage/SwiftyGif/Mantle chain. Combined with build flag optimizations, the app could be reduced to an estimated 13-15 MB IPA download size.
