# aria2 Binary for Android

This directory should contain the aria2c binary for Android.

## How to add the binary:

1. Download the aria2 binary for Android:
   - URL: https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-aarch64-linux-android-build1.zip
   
2. Extract the zip file and copy `aria2c` to this directory

3. The binary will be automatically extracted and executed by the app at runtime

## Binary Information:
- Architecture: aarch64 (ARM64)
- Platform: Android
- Version: 1.37.0
- Statically linked libraries:
  - openssl 1.1.1k
  - expat 2.4.1
  - zlib 1.2.11
  - c-ares 1.17.2
  - libssh2 1.9.0

Note: The binary should be placed directly in this directory as `aria2c` (no extension).
