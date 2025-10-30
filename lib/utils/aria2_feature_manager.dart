import 'dart:io';
import 'package:kazumi/utils/aria2_ios_channel.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

/// Manages aria2 feature availability across platforms
class Aria2FeatureManager {
  static final Aria2FeatureManager _instance = Aria2FeatureManager._internal();
  factory Aria2FeatureManager() => _instance;
  Aria2FeatureManager._internal();

  final KazumiLogger _logger = KazumiLogger();
  
  bool? _isAvailable;
  bool _isInitialized = false;

  /// Initialize and check if aria2 features are available
  Future<bool> initialize() async {
    if (_isInitialized) {
      return _isAvailable ?? false;
    }

    _isInitialized = true;

    // Desktop platforms - always available if aria2 is installed
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      _isAvailable = true;
      _logger.log(Level.info, '[Aria2FeatureManager] Desktop platform - aria2 available');
      return true;
    }

    // Android - always available (bundled binary)
    if (Platform.isAndroid) {
      _isAvailable = true;
      _logger.log(Level.info, '[Aria2FeatureManager] Android platform - aria2 available (bundled)');
      return true;
    }

    // iOS - conditional availability
    if (Platform.isIOS) {
      try {
        // Check if this is an App Store build
        final isAppStore = await Aria2IOSChannel.isAppStoreVersion();
        
        if (isAppStore) {
          _isAvailable = false;
          _logger.log(Level.info, '[Aria2FeatureManager] iOS App Store build - aria2 disabled');
          return false;
        }

        // Check if aria2 binary is available (self-signed build)
        final isAvailable = await Aria2IOSChannel.isAria2Available();
        _isAvailable = isAvailable;
        
        if (isAvailable) {
          _logger.log(Level.info, '[Aria2FeatureManager] iOS self-signed build - aria2 available');
        } else {
          _logger.log(Level.warning, '[Aria2FeatureManager] iOS self-signed build - aria2 binary not found');
        }
        
        return isAvailable;
      } catch (e) {
        _logger.log(Level.error, '[Aria2FeatureManager] Error checking iOS aria2 availability: $e');
        _isAvailable = false;
        return false;
      }
    }

    // Unknown platform
    _isAvailable = false;
    _logger.log(Level.warning, '[Aria2FeatureManager] Unknown platform - aria2 disabled');
    return false;
  }

  /// Check if aria2 features are available
  bool get isAvailable {
    if (!_isInitialized) {
      _logger.log(Level.warning, '[Aria2FeatureManager] Not initialized, call initialize() first');
      return false;
    }
    return _isAvailable ?? false;
  }

  /// Get user-friendly message about aria2 availability
  String getAvailabilityMessage() {
    if (!_isInitialized) {
      return '正在检查 aria2 可用性...';
    }

    if (_isAvailable == true) {
      return 'aria2 下载功能可用';
    }

    if (Platform.isIOS) {
      return 'App Store 版本不支持 aria2 下载功能\n请使用自签名 IPA 版本以启用此功能';
    }

    return 'aria2 下载功能不可用';
  }

  /// Reset the initialization state (for testing)
  void reset() {
    _isInitialized = false;
    _isAvailable = null;
  }
}
