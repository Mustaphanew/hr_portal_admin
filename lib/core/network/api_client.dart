import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/exception_mapper.dart';
import '../errors/exceptions.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';
import 'base_response.dart';
import 'session_manager.dart';

/// Configured HTTP client for the HR Admin API.
///
/// All feature repositories use this client. It:
/// - Points to `ApiConstants.baseUrl`
/// - Attaches Bearer token via [AuthInterceptor]
/// - Parses every response into [BaseResponse<T>]
/// - Converts API error codes into typed Dart exceptions
///
/// Usage:
/// ```dart
/// final client = ApiClient(storage: storage, sessionManager: manager);
/// final response = await client.get<AdminProfile>(
///   ApiConstants.me,
///   fromJson: (json) => AdminProfile.fromJson(json),
/// );
/// ```
class ApiClient {
  late final Dio _dio;
  final SessionManager sessionManager;

  ApiClient({
    required SecureTokenStorage storage,
    required this.sessionManager,
    Dio? dio,
  }) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout:
                const Duration(milliseconds: ApiConstants.connectTimeout),
            receiveTimeout:
                const Duration(milliseconds: ApiConstants.receiveTimeout),
            sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            validateStatus: (_) {
              return true;
            }, // Let us handle all status codes.
          ),
        );

    _dio.interceptors.add(
      AuthInterceptor(storage: storage, sessionManager: sessionManager),
    );
  }

  /// Expose Dio for testing or advanced usage.
  Dio get dio => _dio;

  // ═══════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════

  /// HTTP GET that returns parsed [BaseResponse<T>].
  Future<BaseResponse<T>> get<T>(
    String path, {
    T Function(Object? json)? fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _execute<T>(
      () => _dio.get(path, queryParameters: queryParameters),
      fromJson: fromJson,
    );
    return response;
  }

  /// HTTP POST that returns parsed [BaseResponse<T>].
  Future<BaseResponse<T>> post<T>(
    String path, {
    T Function(Object? json)? fromJson,
    Map<String, dynamic>? data,
  }) async {
    final response = await _execute<T>(
      () => _dio.post(path, data: data),
      fromJson: fromJson,
    );
    return response;
  }

  /// HTTP PUT that returns parsed [BaseResponse<T>].
  Future<BaseResponse<T>> put<T>(
    String path, {
    T Function(Object? json)? fromJson,
    Map<String, dynamic>? data,
  }) async {
    final response = await _execute<T>(
      () => _dio.put(path, data: data),
      fromJson: fromJson,
    );
    return response;
  }

  /// HTTP DELETE that returns parsed [BaseResponse<T>].
  Future<BaseResponse<T>> delete<T>(
    String path, {
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _execute<T>(
      () => _dio.delete(path),
      fromJson: fromJson,
    );
    return response;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Core Execution
  // ═══════════════════════════════════════════════════════════════════

  Future<BaseResponse<T>> _execute<T>(
    Future<Response> Function() request, {
    T Function(Object? json)? fromJson,
  }) async {
    try {
      final response = await request();
      final path = response.requestOptions.path;
      final json = response.data;

      // ── Debug log ──
      final fullUrl = response.requestOptions.uri.toString();
      print('┌── API ${response.requestOptions.method} $fullUrl [${response.statusCode}]');

      if (json is! Map<String, dynamic>) {
        print('└── ❌ Response is not JSON: ${json.runtimeType}');
        throw const ServerException(
          message: 'Unexpected response format from server.',
        );
      }

      final baseResponse = BaseResponse<T>.fromJson(json, fromJson);

      if (baseResponse.isError) {
        print('├── ❌ API Error: ${baseResponse.code} — ${baseResponse.message}');
        if (baseResponse.details != null) {
          print('├── Details: ${baseResponse.details}');
        }
        print('└── TraceId: ${baseResponse.traceId}');

        final code = baseResponse.code;

        if (code != null && _requiresReauth(code)) {
          try {
            await sessionManager.onTokenExpired();
          } catch (_) {}
        }

        if (code != null) {
          throw ExceptionMapper.fromResponse(
            code: code,
            message: baseResponse.message,
            traceId: baseResponse.traceId,
            details: baseResponse.details,
            statusCode: response.statusCode,
          );
        }

        throw ServerException(
          message: baseResponse.message ?? 'Unknown server error.',
        );
      }

      print('└── ✅ OK');
      return baseResponse;
    } on ApiException catch (e) {
      print('└── ❌ ApiException: $e');
      rethrow;
    } on DioException catch (e) {
      print('└── ❌ DioException: ${e.type} ${e.requestOptions.path} — ${e.message}');
      if (_isTimeout(e.type)) {
        try {
          await sessionManager.onTokenExpired();
        } catch (_) {}
      }
      throw _mapDioException(e);
    } catch (e, stack) {
      print('└── ❌ Unexpected: $e');
      print('    Stack: ${stack.toString().split('\n').take(5).join('\n    ')}');
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Map Dio-level errors to our exception hierarchy.
  ApiException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        // Try to parse the error body.
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('code')) {
          return ExceptionMapper.fromResponse(
            code: data['code'] as String,
            message: data['message'] as String? ?? 'Unknown error',
            traceId: data['trace_id'] as String?,
            details: data['details'] is Map
                ? Map<String, dynamic>.from(data['details'] as Map)
                : null,
            statusCode: e.response?.statusCode,
          );
        }
        return ServerException(
          message: 'Server error: ${e.response?.statusCode}',
        );
      default:
        return const ServerException(
          message: 'An unexpected network error occurred.',
        );
    }
  }

  /// Whether the Dio error is a timeout.
  bool _isTimeout(DioExceptionType type) {
    return type == DioExceptionType.connectionTimeout ||
           type == DioExceptionType.sendTimeout ||
           type == DioExceptionType.receiveTimeout;
  }

  /// API error codes that must force logout / re-auth.
  bool _requiresReauth(String code) {
    switch (code) {
      case 'TOKEN_EXPIRED':
      case 'TOKEN_INVALID':
      case 'UNAUTHENTICATED':
        return true;
      default:
        return false;
    }
  }
}
