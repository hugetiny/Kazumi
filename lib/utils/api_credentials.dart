/// Centralized API credential definitions.
///
/// This module consolidates every upstream API key or client credential so the
/// values can be audited and rotated from a single location. Do not scatter
/// API tokens across feature files—reference these constants instead.
class ApiCredentials {
  const ApiCredentials._();

  /// DanDanPlay public API credentials.
  static const String danDanAppId = 'kvpx7qkqjh';
  static const String danDanApiKey = 'rABUaBLqdz7aCSi3fe88ZDj2gwga9Vax';

  /// Optional Bangumi client credentials (leave empty if not required).
  static const String bangumiClientId = '';
  static const String bangumiClientSecret = '';

  /// Optional TMDb API key shipped with the app (user overrides still stored in settings).
  static const String tmdbApiKey = '';

  /// Convenience accessor returning a map compatible with previous dandan usage.
  static const Map<String, String> danDanPair = <String, String>{
    'id': danDanAppId,
    'value': danDanApiKey,
  };
}
