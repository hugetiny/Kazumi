# Android aria2 Binary Setup Guide

This guide explains how to set up the aria2 binary for Android in Kazumi.

## Overview

Kazumi bundles the aria2 binary directly in the Android app and executes it via Platform Channel. This eliminates the need for users to manually install aria2 through Termux or other means.

## Setup Instructions

### 1. Download aria2 Binary

Download the official aria2 binary for Android:

**Direct link**: https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-aarch64-linux-android-build1.zip

Or visit the releases page: https://github.com/aria2/aria2/releases/tag/release-1.37.0

### 2. Extract and Place Binary

1. Extract the downloaded ZIP file
2. Inside, you'll find the `aria2c` binary file
3. Copy `aria2c` to `android/app/src/main/assets/aria2c`

**Important**: 
- The file should be named exactly `aria2c` (no extension)
- Place it directly in the `assets` folder, not in a subdirectory

### 3. Verify Setup

After placing the binary, your directory structure should look like:
```
android/app/src/main/
├── assets/
│   ├── aria2c          # ← The binary file
│   └── README.md       # Setup instructions
├── kotlin/
│   └── ...
└── ...
```

### 4. Build and Test

Build the Android app:
```bash
flutter build apk
# or
flutter run
```

The app will automatically:
1. Extract the `aria2c` binary from assets to internal storage
2. Set execute permissions
3. Start aria2 with the configured parameters
4. Manage the process lifecycle

## Binary Information

- **Version**: 1.37.0
- **Architecture**: aarch64 (ARM64)
- **Platform**: Android (linux-android)
- **Build**: Official GitHub release build1

### Statically Linked Libraries

The binary includes these statically linked libraries:
- OpenSSL 1.1.1k
- expat 2.4.1
- zlib 1.2.11
- c-ares 1.17.2 (async DNS)
- libssh2 1.9.0

## How It Works

### Architecture

```
Flutter App (Dart)
    ↓ Platform Channel
Native Android (Kotlin)
    ↓ Process.start()
aria2c binary (extracted from assets)
    ↓ RPC
aria2 JSON-RPC server (localhost:6800)
    ↑ HTTP requests
Flutter App (Dart)
```

### Implementation Details

1. **MainActivity.kt**: 
   - Implements Platform Channel methods: `startAria2`, `stopAria2`, `isAria2Running`
   - Extracts binary from assets to `app.filesDir/bin/aria2c`
   - Manages process lifecycle with proper cleanup

2. **aria2_android_channel.dart**:
   - Flutter-side Platform Channel wrapper
   - Provides async methods for process control

3. **aria2_process_manager.dart**:
   - Unified manager for all platforms
   - Uses Platform Channel on Android
   - Uses system binary on Desktop

### Process Management

- **Startup**: Binary is extracted once and reused on subsequent launches
- **Execution**: Process is started with user-configured parameters
- **Monitoring**: stdout/stderr are logged to Android Logcat
- **Cleanup**: Process is terminated when app is destroyed

## Configuration

Android-specific aria2 configurations are applied automatically:

- `--async-dns`: Enables asynchronous DNS resolution
- `--disable-ipv6=true`: Disables IPv6 (common issue on Android)
- Download directory: External storage Downloads folder

## Troubleshooting

### Binary not found error

**Symptoms**: App logs show "Failed to extract aria2 binary"

**Solutions**:
1. Verify `aria2c` file is in `android/app/src/main/assets/`
2. Rebuild the app completely: `flutter clean && flutter build apk`
3. Check file permissions in assets folder

### Process fails to start

**Symptoms**: App logs show "Failed to start aria2"

**Solutions**:
1. Check Android Logcat for detailed error messages
2. Verify the device architecture is ARM64 (aarch64)
3. Ensure app has necessary permissions (WRITE_EXTERNAL_STORAGE)

### Connection refused

**Symptoms**: Download controller shows "connection failed"

**Solutions**:
1. Check if aria2 process is actually running (Settings → Process Management → Check)
2. Verify no other app is using port 6800
3. Try restarting aria2 from settings

## Development Notes

### Building Custom Binary

If you need a custom aria2 build for Android:

1. Install Android NDK
2. Clone aria2 source: `git clone https://github.com/aria2/aria2.git`
3. Follow the Android build instructions in aria2's README
4. Replace the binary in assets folder

### Testing on Emulator

**Note**: The ARM64 binary won't run on x86 emulators.

Options:
- Use a physical ARM64 Android device
- Use an ARM64 emulator image
- Build an x86_64 version of aria2 for emulator testing

### Debugging

Enable detailed logging:
1. Check Flutter console for Dart-side logs
2. Check Android Logcat for native logs (tag: "Aria2")
3. Monitor aria2 RPC with browser: http://localhost:6800/jsonrpc

## Security Considerations

- Binary is extracted to app-private directory (not accessible by other apps)
- No elevated permissions required
- RPC server only listens on localhost
- Optional RPC secret for additional security

## License

The aria2 binary is subject to aria2's GPLv2+ license.
See: https://github.com/aria2/aria2/blob/master/COPYING

## References

- aria2 GitHub: https://github.com/aria2/aria2
- aria2 Documentation: https://aria2.github.io/
- Android NDK: https://developer.android.com/ndk
- Platform Channels: https://docs.flutter.dev/platform-integration/platform-channels
