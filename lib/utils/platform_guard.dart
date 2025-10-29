import 'package:flutter/foundation.dart';

/// Captures platform information used to gate feature availability.
class PlatformDescriptor {
  const PlatformDescriptor._({
    required this.isWeb,
    required this.platform,
  });

  factory PlatformDescriptor.detect() {
    return PlatformDescriptor._(
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
  }

  factory PlatformDescriptor.forValues({
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    return PlatformDescriptor._(
      isWeb: isWeb,
      platform: platform,
    );
  }

  final bool isWeb;
  final TargetPlatform platform;

  bool get isAndroid => !isWeb && platform == TargetPlatform.android;
  bool get isIOS => !isWeb && platform == TargetPlatform.iOS;
  bool get isWindows => !isWeb && platform == TargetPlatform.windows;
  bool get isLinux => !isWeb && platform == TargetPlatform.linux;
  bool get isMacOS => !isWeb && platform == TargetPlatform.macOS;

  bool get isDesktop => isWindows || isLinux || isMacOS;
}

/// Describes support state for a guarded feature along with a fallback reason.
class FeatureSupport {
  const FeatureSupport._(this.isSupported, this.reason);

  final bool isSupported;
  final String? reason;

  static const FeatureSupport supported = FeatureSupport._(true, null);

  factory FeatureSupport.unsupported(String reason) {
    return FeatureSupport._(false, reason);
  }
}

/// Centralises runtime platform checks so torrent/download features can degrade
/// gracefully on unsupported targets.
class PlatformGuard {
  PlatformGuard({PlatformDescriptor? descriptor})
      : descriptor = descriptor ?? PlatformDescriptor.detect();

  final PlatformDescriptor descriptor;

  FeatureSupport get downloadQueueSupport {
    if (descriptor.isWeb) {
      return FeatureSupport.unsupported(
        'Downloads are unavailable on web builds.',
      );
    }
    if (descriptor.isAndroid || descriptor.isDesktop) {
      return FeatureSupport.supported;
    }
    return FeatureSupport.unsupported(
      'Downloads require Android, Windows, macOS, or Linux builds.',
    );
  }

  FeatureSupport get torrentSupport {
    if (descriptor.isWeb) {
      return FeatureSupport.unsupported(
        'Torrent handling is disabled on web builds.',
      );
    }
    if (descriptor.isDesktop || descriptor.isAndroid) {
      return FeatureSupport.supported;
    }
    return FeatureSupport.unsupported(
      'Torrent downloads are disabled on this platform.',
    );
  }

  FeatureSupport get anime4kSupport {
    if (descriptor.isWeb) {
      return FeatureSupport.unsupported(
        'Anime4K shaders are not supported on web builds.',
      );
    }
    if (descriptor.isWindows || descriptor.isLinux) {
      return FeatureSupport.supported;
    }
    return FeatureSupport.unsupported(
      'Anime4K requires Windows or Linux with compatible GPU drivers.',
    );
  }
}
