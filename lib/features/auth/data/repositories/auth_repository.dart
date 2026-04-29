import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/base_response.dart';
import '../../../../core/network/session_manager.dart';
import '../models/auth_models.dart';

/// Repository handling all authentication operations.
///
/// Endpoints covered (Admin Portal — Postman 00):
/// - POST /admin/auth/login
/// - POST /admin/auth/logout
/// - POST /admin/auth/logout-all
/// - GET  /admin/auth/me
/// - GET  /admin/companies
/// - GET  /admin/branches
/// - POST /change-password
class AuthRepository {
  final ApiClient _client;
  final SessionManager _sessionManager;

  AuthRepository({
    required ApiClient client,
    required SessionManager sessionManager,
  })  : _client = client,
        _sessionManager = sessionManager;

  /// Authenticate with username and password against the admin portal.
  ///
  /// Tries `/admin/auth/login` first (returns an admin-scoped token required
  /// by all `/admin/*` endpoints). Falls back to the legacy `/auth/login`
  /// route only if the admin endpoint isn't deployed (404 / endpoint not
  /// found), so the same client keeps working against older backends.
  ///
  /// On success, persists the token and session info via [SessionManager].
  Future<LoginData> login({
    required String username,
    required String password,
    String? deviceName,
    String? fcmToken,
  }) async {
    final data = {
      'username': username,
      'password': password,
      'device_name': ?deviceName,
      'fcm_token': ?fcmToken,
    };

    BaseResponse<LoginData> response;
    try {
      response = await _client.post<LoginData>(
        ApiConstants.adminLogin,
        fromJson: (json) => LoginData.fromJson(json as Map<String, dynamic>),
        data: data,
      );
    } on ApiException catch (e) {
      // If the admin route isn't available on this backend, fall back to the
      // generic `/auth/login`. Any other error (invalid credentials, etc.)
      // bubbles up unchanged.
      if (e is ResourceNotFoundException) {
        response = await _client.post<LoginData>(
          ApiConstants.login,
          fromJson: (json) => LoginData.fromJson(json as Map<String, dynamic>),
          data: data,
        );
      } else {
        rethrow;
      }
    }

    final loginData = response.data!;

    await _sessionManager.onLoginSuccess(
      token: loginData.token,
      adminId: loginData.employee.id,
      companyId: loginData.employee.company?.id ?? 0,
    );

    return loginData;
  }

  /// Revoke the current token and clear local session.
  ///
  /// Tries the admin logout endpoint first, falling back to the legacy one.
  Future<void> logout() async {
    try {
      try {
        await _client.post<void>(ApiConstants.adminLogout);
      } on ResourceNotFoundException {
        await _client.post<void>(ApiConstants.logout);
      } catch (_) {
        // Even if the server-side revocation fails, we still clear local state.
      }
    } finally {
      await _sessionManager.onLogout();
    }
  }

  /// Revoke all tokens for the authenticated user and clear local session.
  Future<LogoutAllData> logoutAll() async {
    BaseResponse<LogoutAllData> response;
    try {
      response = await _client.post<LogoutAllData>(
        ApiConstants.adminLogoutAll,
        fromJson: (json) =>
            LogoutAllData.fromJson(json as Map<String, dynamic>),
      );
    } on ResourceNotFoundException {
      response = await _client.post<LogoutAllData>(
        ApiConstants.logoutAll,
        fromJson: (json) =>
            LogoutAllData.fromJson(json as Map<String, dynamic>),
      );
    }

    await _sessionManager.onLogout();
    return response.data!;
  }

  /// Fetch the authenticated user's profile from the server.
  Future<EmployeeProfile> getProfile() async {
    final response = await _client.get<EmployeeProfile>(
      ApiConstants.profile,
      fromJson: (json) => EmployeeProfile.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Change the authenticated user's password.
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _client.post<void>(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Admin Auth Scope (Postman 00)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch the currently authenticated admin's profile via `/admin/auth/me`.
  ///
  /// Returns the raw JSON map (the admin endpoint may include scope info such
  /// as roles/permissions on top of the standard employee profile).
  Future<Map<String, dynamic>> getAdminMe() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.adminMe,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }

  /// List companies the current admin is allowed to operate on
  /// via `/admin/companies`.
  Future<List<Map<String, dynamic>>> getAllowedCompanies() async {
    final response = await _client.get<List<Map<String, dynamic>>>(
      ApiConstants.adminCompanies,
      fromJson: (json) {
        final list = (json is Map<String, dynamic>)
            ? (json['companies'] ?? json['items'] ?? json['data'] ?? const [])
            : json;
        return (list as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .toList();
      },
    );
    return response.data ?? const [];
  }

  /// List branches the current admin is allowed to operate on, optionally
  /// scoped by `companyId`. Backed by `/admin/branches`.
  Future<List<Map<String, dynamic>>> getAllowedBranches({int? companyId}) async {
    final response = await _client.get<List<Map<String, dynamic>>>(
      ApiConstants.adminBranches,
      queryParameters: {
        'company_id': ?companyId,
      },
      fromJson: (json) {
        final list = (json is Map<String, dynamic>)
            ? (json['branches'] ?? json['items'] ?? json['data'] ?? const [])
            : json;
        return (list as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .toList();
      },
    );
    return response.data ?? const [];
  }
}
