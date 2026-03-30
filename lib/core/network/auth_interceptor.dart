import 'package:dio/dio.dart';
import '../config/app_logger.dart';
import '../constants/api_constants.dart';
import '../errors/api_error_codes.dart';
import '../storage/secure_token_storage.dart';
import 'session_manager.dart';

class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _storage;
  final SessionManager _sessionManager;

  AuthInterceptor({
    required SecureTokenStorage storage,
    required SessionManager sessionManager,
  })  : _storage = storage,
        _sessionManager = sessionManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final apiVersion = response.headers.value(ApiConstants.versionHeader);
    final traceId = response.headers.value(ApiConstants.traceIdHeader);
    if (apiVersion != null && apiVersion != ApiConstants.contractVersion) {
      AppLogger.w(
        'API version mismatch! Expected ${ApiConstants.contractVersion}, got $apiVersion. Trace: $traceId',
        tag: 'Network',
      );
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    if (response != null && response.statusCode == 401) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final code = data['code'] as String?;
        if (code != null && ApiErrorCodes.requiresLogout(code)) {
          AppLogger.w('Token expired/invalid ($code). Triggering auto-logout.', tag: 'Auth');
          await _sessionManager.onTokenExpired();
        }
      }
    }
    handler.next(err);
  }
}
