import 'dart:io';
import 'package:flutter/services.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

/// Platform channel wrapper for Android aria2 binary execution
class Aria2AndroidChannel {
  static const MethodChannel _channel = MethodChannel('com.predidit.kazumi/aria2');
  static final KazumiLogger _logger = KazumiLogger();

  /// Start aria2 process on Android using the bundled binary
  static Future<bool> startAria2(List<String> args) async {
    if (!Platform.isAndroid) {
      _logger.log(Level.warning, '[Aria2AndroidChannel] Not on Android platform');
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod<bool>('startAria2', {
        'args': args,
      });
      
      if (result == true) {
        _logger.log(Level.info, '[Aria2AndroidChannel] aria2 started successfully via platform channel');
      } else {
        _logger.log(Level.error, '[Aria2AndroidChannel] Failed to start aria2 via platform channel');
      }
      
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.log(Level.error, '[Aria2AndroidChannel] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      _logger.log(Level.error, '[Aria2AndroidChannel] Error starting aria2: $e');
      return false;
    }
  }

  /// Stop aria2 process on Android
  static Future<bool> stopAria2() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod<bool>('stopAria2');
      
      if (result == true) {
        _logger.log(Level.info, '[Aria2AndroidChannel] aria2 stopped successfully');
      }
      
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.log(Level.error, '[Aria2AndroidChannel] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      _logger.log(Level.error, '[Aria2AndroidChannel] Error stopping aria2: $e');
      return false;
    }
  }

  /// Check if aria2 is running on Android
  static Future<bool> isAria2Running() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod<bool>('isAria2Running');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.log(Level.error, '[Aria2AndroidChannel] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      _logger.log(Level.error, '[Aria2AndroidChannel] Error checking aria2 status: $e');
      return false;
    }
  }
}
