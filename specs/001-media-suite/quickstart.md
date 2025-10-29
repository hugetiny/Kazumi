# Quickstart: Kazumi Media Experience Suite

## Prerequisites
- Flutter 3.x (stable channel) with desktop support enabled for Windows and Android SDK/NDK installed.
- aria2 release archives downloaded into `tools/aria2/<platform>/` and unpacked so `aria2c` is callable for each target; launch with `--enable-rpc --rpc-secret=<token>`.
- Bangumi and TMDb API credentials configured in Kazumi settings.
- Hive boxes migrated (`flutter pub run build_runner build --delete-conflicting-outputs`).
- Test devices available: Windows desktop (hardware acceleration on/off) and Android mid/high tier handsets per playback smoke matrix.

## Setup
1. Run `flutter pub get` to install dependencies.
2. Launch the platform-specific `aria2c` binary from `tools/aria2/<platform>/` (or ensure remote daemon reachable) before exercising download scenarios.
3. Start the app on Windows and Android emulators/devices.
4. In settings, opt in to metadata sync preview and confirm consent dialogs.

## Verification Steps
1. **Metadata Sync**
   - Navigate to catalog page, trigger manual refresh.
   - Confirm entries show localized data based on device language.
2. **Playback Stack**
   - Play an episode on Windows (hardware acceleration on & off) and Android mid/high tier devices, toggle Anime4K presets, enable danmaku, verify subtitles auto-select.
3. **Download Queue**
   - Queue two episodes for download; observe progress and storage footprint updates.
   - Adjust maximum concurrent downloads in settings and add additional tasks to confirm queueing behaviour.
4. **Cross-Device Consistency**
   - Sync playback history via WebDAV (if configured) and verify watch state matches across Windows and Android.
