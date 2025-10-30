import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/aria2_android_channel.dart';
import 'package:kazumi/utils/aria2_ios_channel.dart';
import 'package:kazumi/utils/aria2_feature_manager.dart';
import 'package:logger/logger.dart';

/// Manages the aria2 process lifecycle for desktop, Android, and iOS platforms.
/// On Android and iOS: Uses bundled binary via platform channel
/// On Desktop: Launches system aria2c binary
class Aria2ProcessManager {
  static final Aria2ProcessManager _instance = Aria2ProcessManager._internal();
  factory Aria2ProcessManager() => _instance;
  Aria2ProcessManager._internal();

  Process? _aria2Process;
  bool _isRunning = false;
  final KazumiLogger _logger = KazumiLogger();

  bool get isRunning => _isRunning;

  /// Starts the aria2 process if it's not already running.
  /// On Android: Uses bundled binary via platform channel
  /// On iOS: Uses bundled binary via platform channel (self-signed builds only)
  /// On Desktop: Launches system aria2c binary
  Future<bool> start() async {
    // Check if aria2 is available on this platform
    final isAvailable = await Aria2FeatureManager().initialize();
    if (!isAvailable) {
      _logger.log(Level.warning, '[Aria2ProcessManager] aria2 is not available on this platform/build');
      return false;
    }

    // iOS: Use platform channel
    if (Platform.isIOS) {
      final isRunning = await Aria2IOSChannel.isAria2Running();
      if (isRunning) {
        _logger.log(Level.info, '[Aria2ProcessManager] aria2 is already running on iOS');
        _isRunning = true;
        return true;
      }
    }
    
    // Android: Use platform channel
    else if (Platform.isAndroid) {
      final isRunning = await Aria2AndroidChannel.isAria2Running();
      if (isRunning) {
        _logger.log(Level.info, '[Aria2ProcessManager] aria2 is already running on Android');
        _isRunning = true;
        return true;
      }
    } 
    
    // Desktop: Check process
    else if (_isRunning && _aria2Process != null) {
      _logger.log(Level.info, '[Aria2ProcessManager] aria2 is already running');
      return true;
    }

    try {
      final setting = GStorage.setting;
      final String secret = setting.get(SettingBoxKey.aria2Secret, defaultValue: '') as String;
      final int maxConcurrent = setting.get(SettingBoxKey.aria2MaxConcurrentDownloads, defaultValue: 2) as int;

      // Get the download directory
      final Directory downloadsDir = await _getDownloadsDirectory();
      
      // Build aria2 command arguments
      final List<String> args = [
        '--enable-rpc',
        '--rpc-listen-all=true',
        '--rpc-listen-port=6800',
        '--dir=${downloadsDir.path}',
        '--max-concurrent-downloads=$maxConcurrent',
        '--continue=true',
        '--max-connection-per-server=16',
        '--min-split-size=1M',
        '--split=16',
        '--disable-ipv6=true',
        '--http-accept-gzip=true',
        '--allow-overwrite=true',
        '--auto-file-renaming=true',
      ];

      if (secret.isNotEmpty) {
        args.add('--rpc-secret=$secret');
      }

      // iOS: Use platform channel with bundled binary (self-signed builds only)
      if (Platform.isIOS) {
        _logger.log(Level.info, '[Aria2ProcessManager] Starting aria2 on iOS via platform channel');
        _logger.log(Level.info, '[Aria2ProcessManager] Download directory: ${downloadsDir.path}');
        
        final success = await Aria2IOSChannel.startAria2(args);
        if (success) {
          _isRunning = true;
          _logger.log(Level.info, '[Aria2ProcessManager] aria2 started successfully on iOS');
        } else {
          _logger.log(Level.error, '[Aria2ProcessManager] Failed to start aria2 on iOS');
        }
        return success;
      }

      // Android: Use platform channel with bundled binary
      if (Platform.isAndroid) {
        // Add Android-specific DNS configuration
        args.add('--async-dns');
        // Note: DNS servers will be configured dynamically by the native code if needed
        
        _logger.log(Level.info, '[Aria2ProcessManager] Starting aria2 on Android via platform channel');
        _logger.log(Level.info, '[Aria2ProcessManager] Download directory: ${downloadsDir.path}');
        
        final success = await Aria2AndroidChannel.startAria2(args);
        if (success) {
          _isRunning = true;
          _logger.log(Level.info, '[Aria2ProcessManager] aria2 started successfully on Android');
        } else {
          _logger.log(Level.error, '[Aria2ProcessManager] Failed to start aria2 on Android');
        }
        return success;
      }

      // Desktop: Use system aria2c binary
      // Try to find aria2c in PATH or common locations
      String? aria2Path = await _findAria2Binary();
      
      if (aria2Path == null) {
        _logger.log(Level.error, '[Aria2ProcessManager] aria2c binary not found in PATH or common locations');
        return false;
      }

      _logger.log(Level.info, '[Aria2ProcessManager] Starting aria2c from: $aria2Path');
      _logger.log(Level.info, '[Aria2ProcessManager] Download directory: ${downloadsDir.path}');

      _aria2Process = await Process.start(aria2Path, args);
      _isRunning = true;

      // Listen to stdout and stderr for logging
      _aria2Process!.stdout.listen((data) {
        final output = String.fromCharCodes(data).trim();
        if (output.isNotEmpty) {
          _logger.log(Level.info, '[Aria2ProcessManager] stdout: $output');
        }
      });

      _aria2Process!.stderr.listen((data) {
        final output = String.fromCharCodes(data).trim();
        if (output.isNotEmpty) {
          _logger.log(Level.warning, '[Aria2ProcessManager] stderr: $output');
        }
      });

      // Listen for process exit
      _aria2Process!.exitCode.then((exitCode) {
        _logger.log(Level.info, '[Aria2ProcessManager] aria2 process exited with code: $exitCode');
        _isRunning = false;
        _aria2Process = null;
      });

      _logger.log(Level.info, '[Aria2ProcessManager] aria2 started successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.log(Level.error, '[Aria2ProcessManager] Failed to start aria2: $e', error: e, stackTrace: stackTrace);
      _isRunning = false;
      _aria2Process = null;
      return false;
    }
  }

  /// Stops the aria2 process if it's running.
  Future<void> stop() async {
    if (Platform.isIOS) {
      _logger.log(Level.info, '[Aria2ProcessManager] Stopping aria2 on iOS');
      await Aria2IOSChannel.stopAria2();
      _isRunning = false;
    } else if (Platform.isAndroid) {
      _logger.log(Level.info, '[Aria2ProcessManager] Stopping aria2 on Android');
      await Aria2AndroidChannel.stopAria2();
      _isRunning = false;
    } else if (_aria2Process != null) {
      _logger.log(Level.info, '[Aria2ProcessManager] Stopping aria2 process');
      _aria2Process!.kill();
      _aria2Process = null;
      _isRunning = false;
    }
  }

  /// Restarts the aria2 process.
  Future<bool> restart() async {
    await stop();
    await Future.delayed(const Duration(seconds: 1));
    return await start();
  }

  /// Finds the aria2c binary in PATH or common locations.
  Future<String?> _findAria2Binary() async {
    // Try to run aria2c directly (will work if it's in PATH)
    try {
      if (Platform.isWindows) {
        // On Windows, try aria2c.exe
        final result = await Process.run('where', ['aria2c.exe']);
        if (result.exitCode == 0) {
          final path = result.stdout.toString().trim().split('\n').first;
          if (path.isNotEmpty) {
            return path;
          }
        }
      } else {
        // On Unix-like systems, use 'which'
        final result = await Process.run('which', ['aria2c']);
        if (result.exitCode == 0) {
          final path = result.stdout.toString().trim();
          if (path.isNotEmpty) {
            return path;
          }
        }
      }
    } catch (e) {
      _logger.log(Level.warning, '[Aria2ProcessManager] Could not find aria2c in PATH: $e');
    }

    // Try common installation locations
    final commonPaths = _getCommonAria2Paths();
    for (final path in commonPaths) {
      final file = File(path);
      if (await file.exists()) {
        _logger.log(Level.info, '[Aria2ProcessManager] Found aria2c at: $path');
        return path;
      }
    }

    return null;
  }

  /// Returns a list of common aria2c installation paths for different platforms.
  List<String> _getCommonAria2Paths() {
    if (Platform.isWindows) {
      return [
        'C:\\Program Files\\aria2\\aria2c.exe',
        'C:\\Program Files (x86)\\aria2\\aria2c.exe',
        'C:\\aria2\\aria2c.exe',
      ];
    } else if (Platform.isMacOS) {
      return [
        '/usr/local/bin/aria2c',
        '/opt/homebrew/bin/aria2c',
        '/usr/bin/aria2c',
      ];
    } else if (Platform.isLinux) {
      return [
        '/usr/bin/aria2c',
        '/usr/local/bin/aria2c',
        '/opt/aria2/bin/aria2c',
      ];
    } else if (Platform.isAndroid) {
      // For Android, we might need to bundle aria2c with the app
      // or install it via Termux
      return [
        '/data/data/com.termux/files/usr/bin/aria2c',
      ];
    }
    return [];
  }

  /// Gets the appropriate downloads directory for the current platform.
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // On Android, use external storage downloads directory
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadsDir = Directory('${externalDir.path}/Downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return downloadsDir;
      }
    }
    
    // For desktop platforms, use the system downloads directory
    try {
      final Directory downloadsDir = await getDownloadsDirectory();
      return downloadsDir;
    } catch (e) {
      _logger.log(Level.warning, '[Aria2ProcessManager] Could not get downloads directory, using app directory');
      final Directory appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return downloadsDir;
    }
  }
}
