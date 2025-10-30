import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/request/api.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

/// Manages aria2 binary updates for Android platform
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
    if (!Platform.isAndroid) {
      _logger.log(Level.info, '[Aria2Updater] Update check only supported on Android');
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
        
        // Find Android ARM64 asset
        final assets = data['assets'] as List;
        String? downloadUrl;
        
        for (var asset in assets) {
          final name = asset['name'] as String;
          if (name.contains('aarch64-linux-android') && name.endsWith('.zip')) {
            downloadUrl = asset['browser_download_url'] as String;
            break;
          }
        }

        if (downloadUrl == null) {
          _logger.log(Level.warning, '[Aria2Updater] No Android ARM64 asset found');
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
  Future<bool> downloadAndInstall(String downloadUrl, {
    Function(double progress)? onProgress,
  }) async {
    if (!Platform.isAndroid) {
      _logger.log(Level.warning, '[Aria2Updater] Update only supported on Android');
      return false;
    }

    try {
      _logger.log(Level.info, '[Aria2Updater] Downloading update from: $downloadUrl');

      // Download to temporary location
      final tempDir = await getTemporaryDirectory();
      final zipPath = '${tempDir.path}/aria2_update.zip';
      
      await _dio.download(
        downloadUrl,
        zipPath,
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

      // Extract zip
      final bytes = File(zipPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find aria2c binary in archive
      ArchiveFile? aria2cFile;
      for (final file in archive) {
        if (file.name.endsWith('aria2c') && !file.isDirectory) {
          aria2cFile = file;
          break;
        }
      }

      if (aria2cFile == null) {
        _logger.log(Level.error, '[Aria2Updater] aria2c binary not found in archive');
        return false;
      }

      // Write to assets location (this will be used on next app start)
      // For Android, we can't update the APK assets, so we store it in a location
      // that the app will check on startup
      final appDir = await getApplicationDocumentsDirectory();
      final updateDir = Directory('${appDir.path}/aria2_update');
      if (!await updateDir.exists()) {
        await updateDir.create(recursive: true);
      }

      final newBinaryPath = '${updateDir.path}/aria2c';
      final newBinaryFile = File(newBinaryPath);
      await newBinaryFile.writeAsBytes(aria2cFile.content as List<int>);
      
      // Set executable permission
      await Process.run('chmod', ['755', newBinaryPath]);

      // Save version info
      final versionFile = File('${updateDir.path}/version.txt');
      await versionFile.writeAsString((downloadUrl.contains('release-') 
          ? downloadUrl.split('release-')[1].split('/')[0]
          : 'updated'));

      _logger.log(Level.info, '[Aria2Updater] Update installed successfully');

      // Clean up
      await File(zipPath).delete();

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
      final appDir = await getApplicationDocumentsDirectory();
      final updateDir = Directory('${appDir.path}/aria2_update');
      final versionFile = File('${updateDir.path}/version.txt');
      
      return await versionFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get the updated binary path if available
  Future<String?> getUpdatedBinaryPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final binaryPath = '${appDir.path}/aria2_update/aria2c';
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
  final String? releaseNotes;

  Aria2UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.downloadUrl,
    this.releaseNotes,
  });
}
