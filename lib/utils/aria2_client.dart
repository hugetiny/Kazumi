import 'dart:async';

import 'package:dio/dio.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:logger/logger.dart';

int _parseMaxConcurrent(dynamic raw, {required int fallback}) {
  if (raw == null) {
    return fallback;
  }
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  if (raw is String) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    final int? parsed = int.tryParse(trimmed);
    if (parsed != null) {
      return parsed;
    }
  }
  return fallback;
}

int _normalizeMaxConcurrent(int value) {
  return value < 1 ? 1 : value;
}

class Aria2ConcurrencyConfig {
  const Aria2ConcurrencyConfig({required this.maxConcurrentDownloads});

  final int maxConcurrentDownloads;

  Aria2ConcurrencyConfig copyWith({int? maxConcurrentDownloads}) {
    return Aria2ConcurrencyConfig(
      maxConcurrentDownloads:
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
    );
  }

  Map<String, String> toOptionsPayload() {
    return <String, String>{
      'max-concurrent-downloads': maxConcurrentDownloads.toString(),
    };
  }

  static Aria2ConcurrencyConfig fromOptions(
    Map<String, dynamic> options, {
    required int fallback,
  }) {
    final dynamic raw = options['max-concurrent-downloads'];
    final int parsed = _normalizeMaxConcurrent(
      _parseMaxConcurrent(raw, fallback: fallback),
    );
    return Aria2ConcurrencyConfig(maxConcurrentDownloads: parsed);
  }
}

/// Exception thrown when aria2 RPC responds with an error or unexpected format.
class Aria2RpcException implements Exception {
  Aria2RpcException(this.message, {this.code});

  final String message;
  final dynamic code;

  @override
  String toString() => 'Aria2RpcException(code: $code, message: $message)';
}

/// Lightweight JSON-RPC client for talking to aria2.
///
/// The helper centralises token handling, basic logging, and exposes common
/// queue-management methods used throughout the download feature set.
class Aria2Client {
  Aria2Client({
    required Uri endpoint,
    String? secret,
    Duration timeout = const Duration(seconds: 15),
    Dio? httpClient,
    int maxConcurrentDownloads = _defaultMaxConcurrentDownloads,
  })  : _endpoint = endpoint,
        _secret =
            (secret == null || secret.trim().isEmpty) ? null : secret.trim(),
        _timeout = timeout,
        _maxConcurrentDownloads =
            _normalizeMaxConcurrent(maxConcurrentDownloads),
        _dio = httpClient ??
            Dio(
              BaseOptions(
                connectTimeout: timeout,
                receiveTimeout: timeout,
                sendTimeout: timeout,
                headers: const <String, String>{
                  'Content-Type': 'application/json',
                },
              ),
            );

  factory Aria2Client.fromSettings() {
    final setting = GStorage.setting;
    final String endpoint = (setting.get(SettingBoxKey.aria2Endpoint,
            defaultValue: _defaultEndpoint) as String)
        .trim();
    final String secret =
        (setting.get(SettingBoxKey.aria2Secret, defaultValue: '') as String)
            .trim();
    final int timeoutSeconds =
        setting.get(SettingBoxKey.aria2TimeoutSeconds, defaultValue: 15) as int;
    final dynamic concurrencyRaw = setting.get(
      SettingBoxKey.aria2MaxConcurrentDownloads,
      defaultValue: _defaultMaxConcurrentDownloads,
    );
    final int maxConcurrentDownloads = _normalizeMaxConcurrent(
      _parseMaxConcurrent(
        concurrencyRaw,
        fallback: _defaultMaxConcurrentDownloads,
      ),
    );
    if (!setting.containsKey(SettingBoxKey.aria2MaxConcurrentDownloads)) {
      unawaited(setting.put(
        SettingBoxKey.aria2MaxConcurrentDownloads,
        maxConcurrentDownloads,
      ));
    }

    return Aria2Client(
      endpoint: Uri.parse(endpoint.isEmpty ? _defaultEndpoint : endpoint),
      secret: secret.isEmpty ? null : secret,
      timeout: Duration(seconds: timeoutSeconds.clamp(5, 120)),
      maxConcurrentDownloads: maxConcurrentDownloads,
    );
  }

  static const String _jsonRpcVersion = '2.0';
  static const String _defaultEndpoint = 'http://127.0.0.1:6800/jsonrpc';
  static const List<String> _defaultStatusKeys = <String>[
    'gid',
    'status',
    'totalLength',
    'completedLength',
    'downloadSpeed',
    'connections',
    'numSeeders',
    'errorCode',
    'errorMessage',
    'files',
    'bittorrent',
  ];
  static const int _defaultMaxConcurrentDownloads = 2;

  final Dio _dio;
  final Uri _endpoint;
  final String? _secret;
  final Duration _timeout;
  int _maxConcurrentDownloads;
  final KazumiLogger _logger = KazumiLogger();

  Uri get endpoint => _endpoint;

  bool get hasSecret => _secret?.isNotEmpty ?? false;

  int get maxConcurrentDownloads => _maxConcurrentDownloads;

  Future<String?> addUri(
    List<String> uris, {
    Map<String, dynamic>? options,
    int? position,
  }) async {
    final List<dynamic> params = <dynamic>[uris];
    if (options != null) {
      params.add(options);
    }
    if (position != null) {
      params.add(position);
    }
    final dynamic result = await _call('aria2.addUri', params: params);
    return result as String?;
  }

  Future<Map<String, dynamic>?> tellStatus(
    String gid, {
    List<String>? keys,
  }) async {
    final dynamic result = await _call('aria2.tellStatus',
        params: <dynamic>[gid, keys ?? _defaultStatusKeys]);
    if (result is Map<String, dynamic>) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }

  Future<List<dynamic>> tellActive({List<String>? keys}) async {
    final dynamic result = await _call('aria2.tellActive',
        params: <dynamic>[keys ?? _defaultStatusKeys]);
    if (result is List<dynamic>) {
      return result;
    }
    return <dynamic>[];
  }

  Future<List<dynamic>> tellWaiting(
    int offset,
    int num, {
    List<String>? keys,
  }) async {
    final dynamic result = await _call(
      'aria2.tellWaiting',
      params: <dynamic>[offset, num, keys ?? _defaultStatusKeys],
    );
    if (result is List<dynamic>) {
      return result;
    }
    return <dynamic>[];
  }

  Future<List<dynamic>> tellStopped(
    int offset,
    int num, {
    List<String>? keys,
  }) async {
    final dynamic result = await _call(
      'aria2.tellStopped',
      params: <dynamic>[offset, num, keys ?? _defaultStatusKeys],
    );
    if (result is List<dynamic>) {
      return result;
    }
    return <dynamic>[];
  }

  Future<bool> pause(String gid, {bool force = false}) async {
    final String method = force ? 'aria2.forcePause' : 'aria2.pause';
    final dynamic result = await _call(method, params: <dynamic>[gid]);
    return result is String;
  }

  Future<bool> resume(String gid) async {
    final dynamic result = await _call('aria2.unpause', params: <dynamic>[gid]);
    return result is String;
  }

  Future<bool> remove(String gid, {bool force = false}) async {
    final String method = force ? 'aria2.forceRemove' : 'aria2.remove';
    final dynamic result = await _call(method, params: <dynamic>[gid]);
    return result is String;
  }

  Future<bool> purgeCompleted() async {
    final dynamic result = await _call('aria2.purgeDownloadResult');
    return result == 'OK';
  }

  Future<Aria2ConcurrencyConfig> getConcurrencyConfig() async {
    final dynamic result = await _call('aria2.getGlobalOption');
    if (result is Map) {
      return Aria2ConcurrencyConfig.fromOptions(
        Map<String, dynamic>.from(result),
        fallback: _maxConcurrentDownloads,
      );
    }
    return Aria2ConcurrencyConfig(
      maxConcurrentDownloads: _maxConcurrentDownloads,
    );
  }

  Future<int> ensureMaxConcurrentDownloads({
    int? limit,
    bool persistSetting = false,
    bool force = false,
  }) async {
    final int desired =
        _normalizeMaxConcurrent(limit ?? _maxConcurrentDownloads);
    if (limit != null) {
      _maxConcurrentDownloads = desired;
    }
    final Aria2ConcurrencyConfig remote = await getConcurrencyConfig();
    if (!force && remote.maxConcurrentDownloads == desired) {
      if (persistSetting && limit != null) {
        await GStorage.setting
            .put(SettingBoxKey.aria2MaxConcurrentDownloads, desired);
      }
      return remote.maxConcurrentDownloads;
    }
    await _applyConcurrencyLimit(desired);
    if (persistSetting) {
      await GStorage.setting
          .put(SettingBoxKey.aria2MaxConcurrentDownloads, desired);
    }
    return desired;
  }

  Future<void> setMaxConcurrentDownloads(
    int limit, {
    bool persistSetting = true,
    bool applyToDaemon = true,
  }) async {
    final int normalized = _normalizeMaxConcurrent(limit);
    _maxConcurrentDownloads = normalized;
    if (persistSetting) {
      await GStorage.setting
          .put(SettingBoxKey.aria2MaxConcurrentDownloads, normalized);
    }
    if (applyToDaemon) {
      await _applyConcurrencyLimit(normalized);
    }
  }

  Future<int> refreshMaxConcurrentDownloads(
      {bool persistSetting = false}) async {
    final Aria2ConcurrencyConfig remote = await getConcurrencyConfig();
    _maxConcurrentDownloads = remote.maxConcurrentDownloads;
    if (persistSetting) {
      await GStorage.setting.put(
          SettingBoxKey.aria2MaxConcurrentDownloads, _maxConcurrentDownloads);
    }
    return _maxConcurrentDownloads;
  }

  Future<dynamic> _call(
    String method, {
    List<dynamic>? params,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'jsonrpc': _jsonRpcVersion,
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'method': method,
      'params': _buildParams(params),
    };

    try {
      final Response<dynamic> response = await _dio.postUri(
        _endpoint,
        data: payload,
        options: Options(
          contentType: 'application/json',
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
        ),
      );

      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> body =
            Map<String, dynamic>.from(response.data as Map<String, dynamic>);
        if (body.containsKey('error') && body['error'] != null) {
          final Map<String, dynamic> error =
              Map<String, dynamic>.from(body['error'] as Map<String, dynamic>);
          final String message =
              error['message']?.toString() ?? 'aria2 RPC error';
          final dynamic code = error['code'];
          _logger.log(
            Level.error,
            '[Aria2Client] $method failed: $message (code: $code)',
          );
          throw Aria2RpcException(message, code: code);
        }
        return body['result'];
      }

      throw Aria2RpcException('Unexpected aria2 RPC response format');
    } catch (error, stackTrace) {
      if (error is Aria2RpcException) {
        rethrow;
      }
      _logger.log(
        Level.error,
        '[Aria2Client] $method RPC request failed: $error',
        error: error,
        stackTrace: stackTrace,
      );
      throw Aria2RpcException(error.toString());
    }
  }

  List<dynamic> _buildParams(List<dynamic>? params) {
    final List<dynamic> values = <dynamic>[];
    if (hasSecret) {
      values.add('token:$_secret');
    }
    if (params != null) {
      values.addAll(params);
    }
    return values;
  }

  Future<void> _applyConcurrencyLimit(int limit) async {
    final Aria2ConcurrencyConfig config =
        Aria2ConcurrencyConfig(maxConcurrentDownloads: limit);
    await _call(
      'aria2.changeGlobalOption',
      params: <dynamic>[config.toOptionsPayload()],
    );
    _logger.log(
      Level.info,
      '[Aria2Client] Set max concurrent downloads to $limit',
    );
  }
}
