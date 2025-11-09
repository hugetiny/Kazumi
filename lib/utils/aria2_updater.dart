import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/request/api.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

/// Manages aria2 binary updates for all platforms (except iOS)
/// Supports: Android (ZIP), Windows (ZIP), macOS (TAR.BZ2/TAR.GZ), Linux (TAR.BZ2/TAR.GZ)
class Aria2Updater {
  static final Aria2Updater _instance = Aria2Updater._internal();
  factory Aria2Updater() => _instance;
  Aria2Updater._internal();

  final KazumiLogger _logger = KazumiLogger();
  final Dio _dio = Dio();

  /// GitHub API endpoint for aria2 releases
  static const String _githubApiUrl = 'https://api.github.com/repos/aria2/aria2/releases/latest';
  
  /// Current bundled aria2 version
  static const String _currentVersion = '1.37.0';

  /// Check for aria2 updates
  Future<Aria2UpdateInfo?> checkForUpdates() async {
    // iOS not supported (subprocess restrictions)
    if (Platform.isIOS) {
      _logger.log(Level.info, '[Aria2Updater] Update check not supported on iOS');
      return null;
    }

    try {
      // Use GitHub mirror if configured
      final useGithubProxy = GStorage.setting.get(SettingBoxKey.useGithubProxy, defaultValue: false) as bool;
      final apiUrl = useGithubProxy 
          ? _getProxiedUrl(_githubApiUrl)
          : _githubApiUrl;

      _logger.log(Level.info, '[Aria2Updater] Checking for updates from: $apiUrl');

      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Accept': 'application/vnd.github.v3+json',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final latestVersion = (data['tag_name'] as String).replaceAll('release-', '');
        
        // Find platform-specific asset
        final assets = data['assets'] as List;
        String? downloadUrl;
        String archiveType = 'zip';
        
        for (var asset in assets) {
          final name = asset['name'] as String;
          
          if (Platform.isAndroid) {
            // Android: aarch64-linux-android.zip
            if (name.contains('aarch64-linux-android') && name.endsWith('.zip')) {
              downloadUrl = asset['browser_download_url'] as String;
              archiveType = 'zip';
              break;
            }
          } else if (Platform.isWindows) {
            // Windows: win-64bit-build.zip
            if (name.contains('win-64bit') && name.endsWith('.zip')) {
              downloadUrl = asset['browser_download_url'] as String;
              archiveType = 'zip';
              break;
            }
          } else if (Platform.isMacOS) {
            // macOS: osx-darwin.tar.bz2
            if (name.contains('osx-darwin') && (name.endsWith('.tar.bz2') || name.endsWith('.tar.gz'))) {
              downloadUrl = asset['browser_download_url'] as String;
              archiveType = name.endsWith('.tar.bz2') ? 'tar.bz2' : 'tar.gz';
              break;
            }
          } else if (Platform.isLinux) {
            // Linux: linux-gnu-64bit.tar.bz2
            if (name.contains('linux-gnu-64bit') && (name.endsWith('.tar.bz2') || name.endsWith('.tar.gz'))) {
              downloadUrl = asset['browser_download_url'] as String;
              archiveType = name.endsWith('.tar.bz2') ? 'tar.bz2' : 'tar.gz';
              break;
            }
          }
        }

        if (downloadUrl == null) {
          _logger.log(Level.warning, '[Aria2Updater] No compatible asset found for current platform');
          return null;
        }

        // Apply mirror to download URL if needed
        if (useGithubProxy) {
          downloadUrl = _getProxiedUrl(downloadUrl);
        }

        final hasUpdate = _compareVersions(latestVersion, _currentVersion) > 0;
        
        _logger.log(Level.info, '[Aria2Updater] Current: $_currentVersion, Latest: $latestVersion, Has update: $hasUpdate');

        return Aria2UpdateInfo(
          currentVersion: _currentVersion,
          latestVersion: latestVersion,
          hasUpdate: hasUpdate,
          downloadUrl: downloadUrl,
          archiveType: archiveType,
          releaseNotes: data['body'] as String?,
        );
      }
    } catch (e, stackTrace) {
      _logger.log(Level.error, '[Aria2Updater] Failed to check for updates: $e', 
          error: e, stackTrace: stackTrace);
    }
    
    return null;
  }

  /// Download and install aria2 update
  Future<bool> downloadAndInstall(String downloadUrl, String archiveType, {
    Function(double progress)? onProgress,
  }) async {
    if (Platform.isIOS) {
      _logger.log(Level.warning, '[Aria2Updater] Update not supported on iOS');
      return false;
    }

    try {
      _logger.log(Level.info, '[Aria2Updater] Downloading update from: $downloadUrl');

      // Download to temporary location
      final tempDir = await getTemporaryDirectory();
      final extension = archiveType == 'tar.bz2' ? '.tar.bz2' : 
                       archiveType == 'tar.gz' ? '.tar.gz' : '.zip';
      final archivePath = '${tempDir.path}/aria2_update$extension';
      
      await _dio.download(
        downloadUrl,
        archivePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 10),
        ),
      );

      _logger.log(Level.info, '[Aria2Updater] Download complete, extracting...');

      // Extract archive based on type
      List<int>? binaryData;
      
      if (archiveType == 'zip') {
        // Extract ZIP (Android, Windows)
        final bytes = File(archivePath).readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(bytes);

        // Find aria2c binary in archive
        for (final file in archive) {
          final fileName = file.name.toLowerCase();
          if ((fileName.endsWith('aria2c') || fileName.endsWith('aria2c.exe')) && !file.isDirectory) {
            binaryData = file.content as List<int>;
            break;
          }
        }
      } else if (archiveType == 'tar.bz2' || archiveType == 'tar.gz') {
        // Extract TAR (macOS, Linux)
        final bytes = File(archivePath).readAsBytesSync();
        
        // First decompress
        List<int> decompressed;
        if (archiveType == 'tar.bz2') {
          decompressed = BZip2Decoder().decodeBytes(bytes);
        } else {
          decompressed = GZipDecoder().decodeBytes(bytes);
        }
        
        // Then extract tar
        final archive = TarDecoder().decodeBytes(decompressed);
        
        // Find aria2c binary in archive
        for (final file in archive) {
          final fileName = file.name.toLowerCase();
          if (fileName.endsWith('aria2c') && !file.isDirectory) {
            binaryData = file.content as List<int>;
            break;
          }
        }
      }

      if (binaryData == null) {
        _logger.log(Level.error, '[Aria2Updater] aria2c binary not found in archive');
        return false;
      }

      // Determine storage location based on platform
      String updateDirPath;
      if (Platform.isAndroid) {
        // Android: app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        updateDirPath = '${appDir.path}/aria2_update';
      } else if (Platform.isWindows) {
        // Windows: app data directory
        final appDir = await getApplicationSupportDirectory();
        updateDirPath = '${appDir.path}\\aria2_update';
      } else {
        // macOS/Linux: app support directory
        final appDir = await getApplicationSupportDirectory();
        updateDirPath = '${appDir.path}/aria2_update';
      }

      final updateDir = Directory(updateDirPath);
      if (!await updateDir.exists()) {
        await updateDir.create(recursive: true);
      }

      // Determine binary name based on platform
      final binaryName = Platform.isWindows ? 'aria2c.exe' : 'aria2c';
      final newBinaryPath = Platform.isWindows 
          ? '$updateDirPath\\$binaryName'
          : '$updateDirPath/$binaryName';
      
      final newBinaryFile = File(newBinaryPath);
      await newBinaryFile.writeAsBytes(binaryData);
      
      // Set executable permission (Unix-like systems)
      if (!Platform.isWindows) {
        await Process.run('chmod', ['755', newBinaryPath]);
      }

      // Save version info
      final versionFilePath = Platform.isWindows
          ? '$updateDirPath\\version.txt'
          : '$updateDirPath/version.txt';
      final versionFile = File(versionFilePath);
      await versionFile.writeAsString((downloadUrl.contains('release-') 
          ? downloadUrl.split('release-')[1].split('/')[0]
          : 'updated'));

      _logger.log(Level.info, '[Aria2Updater] Update installed successfully to: $newBinaryPath');

      // Clean up
      await File(archivePath).delete();

      return true;
    } catch (e, stackTrace) {
      _logger.log(Level.error, '[Aria2Updater] Failed to download and install update: $e',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Get proxied URL using GitHub mirror
  String _getProxiedUrl(String originalUrl) {
    // Use the mirror URL from settings or default
    final mirrorUrl = GStorage.setting.get(SettingBoxKey.githubMirrorUrl, 
        defaultValue: Api.githubMirrorUrl) as String;
    
    if (mirrorUrl.isEmpty) {
      return originalUrl;
    }

    // Replace github.com with mirror
    return originalUrl
        .replaceAll('https://github.com', mirrorUrl)
        .replaceAll('https://api.github.com', mirrorUrl.replaceAll('github.com', 'api.github.com'));
  }

  /// Compare two version strings (e.g., "1.37.0" vs "1.36.0")
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      
      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    
    return 0;
  }

  /// Check if there's a pending update that needs app restart
  Future<bool> hasPendingUpdate() async {
    try {
      String updateDirPath;
      if (Platform.isAndroid) {
        final appDir = await getApplicationDocumentsDirectory();
        updateDirPath = '${appDir.path}/aria2_update';
      } else if (Platform.isWindows) {
        final appDir = await getApplicationSupportDirectory();
        updateDirPath = '${appDir.path}\\aria2_update';
      } else {
        final appDir = await getApplicationSupportDirectory();
        updateDirPath = '${appDir.path}/aria2_update';
      }
      
      final versionFilePath = Platform.isWindows
          ? '$updateDirPath\\version.txt'
          : '$updateDirPath/version.txt';
      final versionFile = File(versionFilePath);
      
      return await versionFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get the updated binary path if available
  Future<String?> getUpdatedBinaryPath() async {
    try {
      String updateDirPath;
      if (Platform.isAndroid) {
        final appDir = await getApplicationDocumentsDirectory();
        updateDirPath = '${appDir.path}/aria2_update';
      } else if (Platform.isWindows) {
        final appDir = await getApplicationSupportDirectory();
        updateDirPath = '${appDir.path}\\aria2_update';
      } else {
        final appDir = await getApplicationSupportDirectory();
        updateDirPath = '${appDir.path}/aria2_update';
      }
      
      final binaryName = Platform.isWindows ? 'aria2c.exe' : 'aria2c';
      final binaryPath = Platform.isWindows
          ? '$updateDirPath\\$binaryName'
          : '$updateDirPath/$binaryName';
      final binaryFile = File(binaryPath);
      
      if (await binaryFile.exists()) {
        return binaryPath;
      }
    } catch (e) {
      _logger.log(Level.error, '[Aria2Updater] Failed to get updated binary path: $e');
    }
    
    return null;
  }
}

/// Information about available aria2 update
class Aria2UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String downloadUrl;
  final String archiveType; // 'zip', 'tar.gz', or 'tar.bz2'
  final String? releaseNotes;

  Aria2UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.downloadUrl,
    required this.archiveType,
    this.releaseNotes,
  });
}
