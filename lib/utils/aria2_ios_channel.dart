import 'dart:io';
import 'package:flutter/services.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

/// Platform channel wrapper for iOS aria2 binary execution (self-signed IPA only)
class Aria2IOSChannel {
  static const MethodChannel _channel = MethodChannel('com.predidit.kazumi/aria2_ios');
  static final KazumiLogger _logger = KazumiLogger();

  /// Check if aria2 is available on iOS (only for self-signed builds)
  static Future<bool> isAria2Available() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final bool? available = await _channel.invokeMethod<bool>('isAria2Available');
      return available ?? false;
    } catch (e) {
      _logger.log(Level.warning, '[Aria2IOSChannel] Failed to check availability: $e');
      return false;
    }
  }

  /// Check if app is from App Store (aria2 should be disabled)
  static Future<bool> isAppStoreVersion() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final bool? isAppStore = await _channel.invokeMethod<bool>('isAppStoreVersion');
      return isAppStore ?? false;
    } on PlatformException catch (e) {
      _logger.log(Level.info, '[Aria2IOSChannel] Platform exception checking App Store: ${e.message}');
      // If we can't determine, assume it's App Store for safety
      return true;
    } catch (e) {
      _logger.log(Level.warning, '[Aria2IOSChannel] Error checking App Store version: $e');
      // If we can't determine, assume it's App Store for safety
      return true;
    }
  }

  /// Start aria2 process on iOS using the bundled binary (self-signed only)
  static Future<bool> startAria2(List<String> args) async {
    if (!Platform.isIOS) {
      _logger.log(Level.warning, '[Aria2IOSChannel] Not on iOS platform');
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod<bool>('startAria2', {
        'args': args,
      });
      
      if (result == true) {
        _logger.log(Level.info, '[Aria2IOSChannel] aria2 started successfully via platform channel');
      } else {
        _logger.log(Level.error, '[Aria2IOSChannel] Failed to start aria2 via platform channel');
      }
      
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.log(Level.error, '[Aria2IOSChannel] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      _logger.log(Level.error, '[Aria2IOSChannel] Error starting aria2: $e');
      return false;
    }
  }

  /// Stop aria2 process on iOS
  static Future<bool> stopAria2() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod<bool>('stopAria2');
      
      if (result == true) {
        _logger.log(Level.info, '[Aria2IOSChannel] aria2 stopped successfully');
      }
      
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.log(Level.error, '[Aria2IOSChannel] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      _logger.log(Level.error, '[Aria2IOSChannel] Error stopping aria2: $e');
      return false;
    }
  }

  /// Check if aria2 is running on iOS
  static Future<bool> isAria2Running() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod<bool>('isAria2Running');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.log(Level.error, '[Aria2IOSChannel] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      _logger.log(Level.error, '[Aria2IOSChannel] Error checking aria2 status: $e');
      return false;
    }
  }
}
