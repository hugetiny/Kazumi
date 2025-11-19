import 'dart:io';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

/// Manages aria2 binary updates for all platforms
/// Windows: Uses WinGet for automatic updates
/// macOS/Linux: Uses system package managers (brew/apt/yum)
/// Android/iOS: Uses bundled binary (no updates needed)
class Aria2Updater {
  static final Aria2Updater _instance = Aria2Updater._internal();
  factory Aria2Updater() => _instance;
  Aria2Updater._internal();

  final KazumiLogger _logger = KazumiLogger();

  /// Check for aria2 updates
  /// Windows: Uses WinGet upgrade command
  /// macOS/Linux: Returns platform-specific update instructions
  /// Android/iOS: Not supported (uses bundled binary)
  Future<Aria2UpdateInfo?> checkForUpdates() async {
    // Mobile platforms not supported (bundled binary)
    if (Platform.isIOS || Platform.isAndroid) {
      _logger.log(Level.info, '[Aria2Updater] Updates not supported on mobile platforms (bundled binary)');
      return null;
    }

    try {
      if (Platform.isWindows) {
        // Check if WinGet is available
        final wingetCheck = await Process.run('winget', ['--version']);
        if (wingetCheck.exitCode != 0) {
          _logger.log(Level.warning, '[Aria2Updater] WinGet is not available');
          return null;
        }

        // Check for aria2 updates using WinGet
        _logger.log(Level.info, '[Aria2Updater] Checking for aria2 updates via WinGet...');
        final result = await Process.run(
          'winget',
          ['list', '--id', 'aria2.aria2', '--exact'],
          runInShell: true,
        );

        if (result.exitCode == 0) {
          final output = result.stdout.toString();

          // Parse WinGet output to detect if update is available
          // Output format: Name Id Version Available Source
          final hasUpdate = output.contains('aria2.aria2') &&
                           (output.toLowerCase().contains('available') ||
                            output.toLowerCase().contains('upgrade'));

          _logger.log(Level.info, '[Aria2Updater] Update check result: hasUpdate=$hasUpdate');

          return Aria2UpdateInfo(
            currentVersion: 'Installed via WinGet',
            latestVersion: hasUpdate ? 'Update available' : 'Latest',
            hasUpdate: hasUpdate,
            updateMethod: 'winget',
          );
        }
      } else if (Platform.isMacOS) {
        // macOS: Suggest using Homebrew
        _logger.log(Level.info, '[Aria2Updater] macOS: Use "brew upgrade aria2" to update');
        return Aria2UpdateInfo(
          currentVersion: 'System package',
          latestVersion: 'Unknown',
          hasUpdate: false,
          updateMethod: 'brew',
          updateCommand: 'brew upgrade aria2',
        );
      } else if (Platform.isLinux) {
        // Linux: Suggest using system package manager
        _logger.log(Level.info, '[Aria2Updater] Linux: Use system package manager to update');
        return Aria2UpdateInfo(
          currentVersion: 'System package',
          latestVersion: 'Unknown',
          hasUpdate: false,
          updateMethod: 'apt/yum',
          updateCommand: 'sudo apt update && sudo apt upgrade aria2c',
        );
      }
    } catch (e, stackTrace) {
      _logger.log(Level.error, '[Aria2Updater] Failed to check for updates: $e',
          error: e, stackTrace: stackTrace);
    }

    return null;
  }

  /// Update aria2 binary
  /// Windows: Uses WinGet upgrade command
  /// macOS/Linux: Returns false (manual update required)
  Future<bool> updateAria2() async {
    if (Platform.isIOS || Platform.isAndroid) {
      _logger.log(Level.warning, '[Aria2Updater] Updates not supported on mobile platforms');
      return false;
    }

    try {
      if (Platform.isWindows) {
        _logger.log(Level.info, '[Aria2Updater] Updating aria2 via WinGet...');

        final result = await Process.run(
          'winget',
          ['upgrade', 'aria2.aria2', '--accept-source-agreements', '--accept-package-agreements', '--silent'],
          runInShell: true,
        );

        if (result.exitCode == 0) {
          _logger.log(Level.info, '[Aria2Updater] aria2 updated successfully via WinGet');
          return true;
        } else {
          _logger.log(Level.error, '[Aria2Updater] WinGet update failed: ${result.stderr}');
          return false;
        }
      } else {
        // macOS/Linux: Manual update required
        _logger.log(Level.info, '[Aria2Updater] Please update aria2 manually using your system package manager');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.log(Level.error, '[Aria2Updater] Failed to update aria2: $e',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }
}

/// Information about available aria2 update
class Aria2UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String updateMethod; // 'winget', 'brew', 'apt/yum'
  final String? updateCommand; // Optional manual update command

  Aria2UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.updateMethod,
    this.updateCommand,
  });
}
