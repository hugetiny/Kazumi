# Quickstart: Kazumi Media Experience Suite

## Prerequisites
- Flutter 3.x (stable channel) with desktop support enabled for Windows and Android SDK/NDK installed.
- aria2 daemon running locally or remotely; launch with `aria2c --enable-rpc --rpc-listen-all=true --rpc-allow-origin-all=true --rpc-secret=<token>` (default endpoint: `http://127.0.0.1:6800/jsonrpc`).
- Bangumi and TMDb API credentials (TMDb API key optional; defaults to built-in key if not provided).
- slang CLI installed for generating translations: `dart pub global activate slang`.
- Hive boxes and code generation updated: `flutter pub run build_runner build --delete-conflicting-outputs`.
- Test devices available: Windows desktop (hardware acceleration on/off) and Android mid/high tier handsets per playback smoke matrix.

## Setup
1. Run `flutter pub get` to install dependencies.
2. Generate translations with slang: `slang` (or `dart run slang` from project root). This creates `lib/l10n/generated/translations.g.dart` from `app_zh-CN.i18n.json` (base) and `app_en-US.i18n.json`.
3. Run code generation for Hive adapters and freezed models: `flutter pub run build_runner build --delete-conflicting-outputs`.
4. Start the aria2 daemon if testing download features: `aria2c --enable-rpc --rpc-listen-all=true --rpc-allow-origin-all=true --rpc-secret=YOUR_SECRET`.
5. Launch the app on Windows and Android emulators/devices: `flutter run -d windows` or `flutter run -d <android-device>`.
6. In settings, configure aria2 endpoint and secret, opt in to metadata sync, and enable subtitle auto-matching.

## Verification Steps
1. **Localization**
   - Change device language to English; confirm UI displays English strings.
   - Switch back to Chinese; verify Chinese strings display correctly.
2. **Metadata Sync**
   - Navigate to catalog page, trigger manual refresh.
   - Confirm entries show localized data based on device language.
   - Verify Bangumi is used for Chinese/Japanese locales, TMDb for others.
3. **Playback Stack**
   - Play an episode on Windows (hardware acceleration on & off) and Android mid/high tier devices.
   - Toggle Anime4K presets; verify visual enhancement without stutter.
   - Enable danmaku; confirm synchronized comments display.
   - Test subtitle auto-matching: verify best match loads automatically based on language preference.
4. **Download Queue**
   - Configure aria2 endpoint and secret in settings.
   - Queue two episodes for download; observe progress and storage footprint updates.
   - Adjust maximum concurrent downloads in settings and add additional tasks to confirm queueing behaviour.
5. **Torrent Integration**
   - Accept torrent consent dialog when prompted.
   - Select torrent source from plugin; verify magnet link passes to aria2.
   - Monitor download progress within Kazumi UI.
6. **Cross-Device Consistency**
   - Sync playback history via WebDAV (if configured) and verify watch state matches across Windows and Android.
