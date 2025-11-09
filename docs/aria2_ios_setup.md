# iOS aria2 Setup Guide

This guide explains how to set up aria2 for iOS in Kazumi.

## Overview

Kazumi supports aria2 download functionality on iOS with the following restrictions:
- **App Store builds**: aria2 is **completely disabled** (no UI, no functionality)
- **Self-signed IPA builds**: aria2 is **fully enabled** with bundled binary

This approach complies with App Store guidelines while allowing advanced users who sideload the app to use the full download manager.

## Architecture

### Detection Mechanism

The app automatically detects the build type by checking for the `embedded.mobileprovision` file:

```swift
// App Store build: No provisioning profile
if embedded.mobileprovision is missing -> App Store build -> Disable aria2

// Self-signed build: Has provisioning profile with device list  
if embedded.mobileprovision exists and contains "ProvisionedDevices" -> Self-signed -> Enable aria2
```

### Platform Channel Implementation

```
Flutter (Dart)
    ↓ MethodChannel('com.predidit.kazumi/aria2_ios')
AppDelegate (Swift)
    ↓ Check isAppStoreVersion()
    ↓ Check isAria2Available()
    ↓ Process.run(aria2c, args)
aria2 process
    ↓ JSON-RPC (localhost:6800)
Flutter aria2_client.dart
```

## Setup Instructions (Developers)

### 1. Build aria2 for iOS

**Option A: Use precompiled binary (if available)**

Download from aria2 releases for iOS (ARM64):
```bash
# Check if iOS build is available
# https://github.com/aria2/aria2/releases
```

**Option B: Compile from source**

Requirements:
- Xcode with iOS SDK
- iOS toolchain

Steps:
```bash
# Clone aria2
git clone https://github.com/aria2/aria2.git
cd aria2

# Configure for iOS ARM64
./configure \
  --host=aarch64-apple-darwin \
  --prefix=/usr/local \
  --without-openssl \
  --without-libxml2 \
  --without-libexpat \
  --without-sqlite3 \
  --disable-nls \
  CFLAGS="-arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path)" \
  CXXFLAGS="-arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path)" \
  LDFLAGS="-arch arm64"

# Build
make

# The binary will be in src/aria2c
```

**Option C: Use a build script**

Create `build_ios_aria2.sh`:
```bash
#!/bin/bash
set -e

# iOS SDK paths
export IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export IOS_MIN_VERSION="12.0"

# Clone aria2
git clone https://github.com/aria2/aria2.git
cd aria2

# Autogen
autoreconf -i

# Configure for iOS
./configure \
  --host=aarch64-apple-darwin \
  --prefix="$PWD/ios-build" \
  --enable-static \
  --disable-shared \
  --without-openssl \
  --without-gnutls \
  --without-libssh2 \
  --without-libcares \
  --disable-websocket \
  CC="$(xcrun -find clang)" \
  CXX="$(xcrun -find clang++)" \
  CFLAGS="-arch arm64 -mios-version-min=$IOS_MIN_VERSION -isysroot $IOS_SDK" \
  CXXFLAGS="-arch arm64 -mios-version-min=$IOS_MIN_VERSION -isysroot $IOS_SDK -std=c++11" \
  LDFLAGS="-arch arm64 -mios-version-min=$IOS_MIN_VERSION -isysroot $IOS_SDK"

# Build
make -j$(sysctl -n hw.ncpu)
make install

echo "aria2c binary: $PWD/ios-build/bin/aria2c"
```

### 2. Add Binary to iOS Bundle

1. Copy the compiled `aria2c` binary
2. Place it in `ios/Runner/Resources/aria2c`
3. Add to Xcode project:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on `Runner` folder
   - Select "Add Files to Runner"
   - Choose `aria2c` binary
   - ✅ Check "Copy items if needed"
   - ✅ Check "Runner" target
   - Click "Add"

4. Set executable permissions:
```bash
chmod +x ios/Runner/Resources/aria2c
```

5. Update `Info.plist` to declare binary usage (if needed for App Store):
```xml
<key>UIFileSharingEnabled</key>
<false/>
```

### 3. Configure Build Settings

In Xcode, ensure:
- **Signing**: Use development or ad-hoc provisioning profile for self-signed builds
- **Capabilities**: No special entitlements needed for subprocess execution
- **Deployment Target**: iOS 12.0+ recommended

### 4. Build and Test

**For development/testing:**
```bash
# Build IPA with development profile (self-signed)
flutter build ipa --release

# Install on device via Xcode or other tools
```

**Test aria2 availability:**
- App will automatically detect if it's self-signed
- Check "Settings → Download Settings → Process Management"
- Should show "aria2 available" for self-signed builds

## How It Works

### Automatic Feature Detection

```dart
// On app startup
await Aria2FeatureManager().initialize();

// Returns true for:
// - Desktop platforms (Windows, macOS, Linux)
// - Android (bundled binary)
// - iOS self-signed builds with binary

// Returns false for:
// - iOS App Store builds
// - iOS self-signed builds without binary
```

### UI Conditional Rendering

All download-related UI checks the feature flag:

```dart
// Example: Hide download button in App Store builds
if (Aria2FeatureManager().isAvailable) {
  IconButton(
    icon: Icon(Icons.download),
    onPressed: () => downloadVideo(),
  )
}
```

### Process Lifecycle

**Self-signed build:**
1. App starts → Check provisioning profile
2. Detect self-signed → Initialize aria2 binary
3. User opens download manager → Start aria2 process
4. User downloads video → aria2 handles download
5. App exits → aria2 process terminates

**App Store build:**
1. App starts → Check provisioning profile
2. Detect App Store → Disable all aria2 features
3. Download UI is hidden
4. No aria2 process ever starts

## Testing

### Test Self-Signed Build

1. Build with development profile
2. Install on device
3. Open app
4. Go to "Settings → Download Settings"
5. Should see: "aria2 available" status
6. Try downloading a video

### Test App Store Simulation

To simulate App Store behavior:
1. Remove `embedded.mobileprovision` from built app
2. Or set a flag to force App Store mode
3. All download features should be hidden
4. No aria2 UI visible

## Troubleshooting

### Binary Not Found

**Symptoms**: "aria2 not available" on self-signed build

**Solutions**:
1. Verify binary is in `ios/Runner/Resources/aria2c`
2. Check it's added to Xcode project
3. Verify executable permissions: `chmod +x`
4. Rebuild the app

### Process Won't Start

**Symptoms**: "Failed to start aria2"

**Solutions**:
1. Check iOS logs: `xcrun deviceconsole` or Xcode console
2. Verify binary architecture matches device (ARM64)
3. Check code signing doesn't strip execute permission
4. Try simpler aria2 arguments first

### App Store Detection Wrong

**Symptoms**: App thinks it's App Store when self-signed

**Solutions**:
1. Verify provisioning profile is included in build
2. Check `embedded.mobileprovision` exists in app bundle
3. Review detection logic in `AppDelegate.swift`

## Binary Information

### Required Binary Specs

- **Architecture**: arm64 (64-bit ARM)
- **iOS Version**: 12.0+ compatible
- **Size**: ~3-5 MB (varies with features)
- **Dependencies**: Static linking preferred

### Minimal Build Configuration

For smallest binary size:
```
--without-openssl      (use system SSL if needed)
--without-gnutls       (reduce crypto dependencies)
--without-libssh2      (no SFTP support needed)
--without-libcares     (use system DNS)
--disable-websocket    (not needed for basic downloads)
--disable-bittorrent   (if not supporting torrents)
```

### Full-Featured Build

For maximum compatibility:
```
--with-openssl         (HTTPS support)
--with-libssh2         (SFTP support)
--with-libcares        (better DNS handling)
--enable-bittorrent    (torrent support)
--enable-metalink      (metalink support)
```

## Security Considerations

- ✅ Binary runs in app sandbox
- ✅ No elevated privileges required
- ✅ RPC server only listens on localhost
- ✅ Optional RPC secret for additional security
- ✅ App Store builds have no aria2 code/binary

## Distribution

### Self-Signed IPA Distribution

Recommended methods:
1. **AltStore**: Sideload with free Apple ID
2. **TrollStore**: For jailbroken/exploit devices
3. **Enterprise**: Via enterprise provisioning
4. **TestFlight**: For beta testing (with binary included)

### App Store Distribution

- Binary should NOT be included
- All aria2 code remains but is automatically disabled
- UI elements are conditionally hidden
- Complies with App Store guidelines (no subprocess execution)

## References

- aria2 GitHub: https://github.com/aria2/aria2
- aria2 Documentation: https://aria2.github.io/
- iOS App Extensions: https://developer.apple.com/app-extensions/
- iOS Provisioning: https://developer.apple.com/documentation/security/code_signing
