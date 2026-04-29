// API CONTRACT v1.0.0 — Envelope structure matches §1 exactly.
// Success: { ok, message, data, trace_id }
// Error:   { ok, code, message, details, trace_id }

/// Generic wrapper for all API responses.
///
/// The API always returns one of two envelopes:
/// - **Success:** `ok=true`, `data` contains the payload, `code` is null.
/// - **Error:** `ok=false`, `code` contains the error code, `data` is null.
///
/// Usage:
/// ```dart
/// final response = BaseResponse<AdminProfile>.fromJson(
///   json,
///   (data) => AdminProfile.fromJson(data as Map<String, dynamic>),
/// );
/// if (response.isSuccess) {
///   print(response.data!.name);
/// }
/// ```
class BaseResponse<T> {
  /// Whether the request succeeded.
  final bool ok;

  /// Human-readable message from the server.
  final String message;

  /// Parsed payload (null for errors or empty-body success).
  final T? data;

  /// UUID v4 request trace identifier.
  final String traceId;

  /// Machine-readable error code (null for success).
  final String? code;

  /// Extra error context (e.g. validation errors). Null for success.
  final Map<String, dynamic>? details;

  const BaseResponse({
    required this.ok,
    required this.message,
    this.data,
    required this.traceId,
    this.code,
    this.details,
  });

  /// Whether the response is a success.
  bool get isSuccess => ok;

  /// Whether the response is an error.
  bool get isError => !ok;

  /// Convenience: validation field errors map.
  ///
  /// Returns `{'field': ['error1', 'error2']}` or empty map.
  Map<String, List<String>> get fieldErrors {
    final errors = details?['errors'];
    if (errors is Map) {
      return errors.map((key, value) => MapEntry(
            key.toString(),
            (value as List).map((e) => e.toString()).toList(),
          ));
    }
    return {};
  }

  /// Parse from raw JSON map.
  ///
  /// [fromJsonT] converts the `data` field into type [T].
  /// Pass `null` if no data parsing is needed (e.g. logout returns null data).
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    // Accept both `ok` (legacy contract) and `status` (Backend API Requirements
    // doc). Some endpoints may also omit it entirely and rely on `code` ranges.
    bool ok;
    final rawOk = json['ok'];
    final rawStatus = json['status'];
    if (rawOk is bool) {
      ok = rawOk;
    } else if (rawStatus is bool) {
      ok = rawStatus;
    } else if (rawStatus is String) {
      ok = rawStatus.toLowerCase() == 'true' ||
          rawStatus.toLowerCase() == 'success';
    } else {
      // Fallback: treat HTTP-like 2xx code as success.
      final code = json['code'];
      if (code is int) {
        ok = code >= 200 && code < 300;
      } else {
        ok = !json.containsKey('error') && !json.containsKey('errors');
      }
    }

    final message = json['message'] as String? ?? '';
    final traceId = json['trace_id'] as String? ?? '';

    if (ok) {
      // ── Success envelope ──
      return BaseResponse<T>(
        ok: true,
        message: message,
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'])
            : null,
        traceId: traceId,
      );
    } else {
      // ── Error envelope ──
      // `code` may arrive as a string error code (e.g. "VALIDATION_FAILED")
      // OR as an int HTTP status (e.g. 422). Prefer the string form when
      // present (`error_code`), fall back to stringifying `code`.
      String? codeStr;
      final rawCode = json['code'];
      final rawErrCode = json['error_code'];
      if (rawErrCode is String && rawErrCode.isNotEmpty) {
        codeStr = rawErrCode;
      } else if (rawCode is String) {
        codeStr = rawCode;
      } else if (rawCode is int) {
        codeStr = rawCode.toString();
      }

      // `details` may live under `details` or `errors` (validation maps).
      Map<String, dynamic>? details;
      if (json['details'] is Map) {
        details = Map<String, dynamic>.from(json['details'] as Map);
      } else if (json['errors'] is Map) {
        details = {'errors': Map<String, dynamic>.from(json['errors'] as Map)};
      }

      return BaseResponse<T>(
        ok: false,
        message: message,
        traceId: traceId,
        code: codeStr,
        details: details,
      );
    }
  }
}
