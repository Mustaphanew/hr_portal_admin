import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// يطبع في الكونسول (debug فقط) تفاصيل الإرسال والرد مع إخفاء التوكنات وكلمات المرور.
class DebugHttpLoggerInterceptor extends Interceptor {
  static const int _maxBodyLength = 12000;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final b = StringBuffer()
        ..writeln('┌── ➜ ${options.method} ${options.uri}');
      if (options.queryParameters.isNotEmpty) {
        b.writeln('│ query: ${options.queryParameters}');
      }
      b.writeln('│ headers: ${_sanitizeHeaders(Map<String, dynamic>.from(options.headers))}');
      if (options.data != null) {
        b.writeln('│ data: ${_formatData(options.data)}');
      }
      b.write('└──');
      debugPrint(b.toString());
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final uri = response.requestOptions.uri;
      final body = _truncate(_formatData(response.data));
      debugPrint(
        '┌── ◀ ${response.statusCode} $uri\n'
        '│ body: $body\n'
        '└──',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final b = StringBuffer()
        ..writeln('┌── ✖ ${err.type} ${err.requestOptions.uri}');
      if (err.message != null) b.writeln('│ message: ${err.message}');
      final res = err.response;
      if (res != null) {
        b.writeln('│ status: ${res.statusCode}');
        b.writeln('│ body: ${_truncate(_formatData(res.data))}');
      }
      b.write('└──');
      debugPrint(b.toString());
    }
    handler.next(err);
  }

  static Map<String, Object?> _sanitizeHeaders(Map<String, dynamic> h) {
    const redact = {'authorization', 'cookie', 'set-cookie'};
    final m = <String, Object?>{};
    h.forEach((k, v) {
      final lk = k.toLowerCase();
      if (redact.contains(lk) ||
          lk.contains('token') && lk != 'x-api-version') {
        m[k] = '[REDACTED]';
      } else {
        m[k] = v;
      }
    });
    return m;
  }

  static const Set<String> _sensitiveKeys = {
    'password',
    'token',
    'access_token',
    'refresh_token',
    'secret',
    'fcm_token',
    'fcmToken',
    'fcmtoken',
  };

  static String _formatData(Object? data) {
    if (data == null) return 'null';
    if (data is FormData) {
      return 'FormData(files: ${data.files.length}, fields: ${data.fields.length})';
    }
    if (data is Map) {
      return _sanitizeMap(Map<String, dynamic>.from(data)).toString();
    }
    if (data is List) {
      return data.map(_formatData).toList().toString();
    }
    if (data is String) {
      return _truncate(data);
    }
    return _truncate(data.toString());
  }

  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (_sensitiveKeys.contains(k) || _sensitiveKeys.contains(k.toLowerCase())) {
        out[k] = '[REDACTED]';
      } else if (v is Map) {
        out[k] = _sanitizeMap(Map<String, dynamic>.from(v));
      } else if (v is List) {
        out[k] = (v)
            .map(
              (e) {
                if (e is Map) {
                  return _sanitizeMap(Map<String, dynamic>.from(e));
                }
                return e;
              },
            )
            .toList();
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  static String _truncate(String s) {
    if (s.length <= _maxBodyLength) return s;
    return '${s.substring(0, _maxBodyLength)}… [truncated, total ${s.length} chars]';
  }
}
