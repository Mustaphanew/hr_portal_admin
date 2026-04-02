import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/session_manager.dart';
import '../models/auth_models.dart';

/// Repository handling all authentication operations.
///
/// Endpoints covered:
/// - A1: POST /auth/login
/// - A2: POST /auth/logout
/// - A3: POST /auth/logout-all
/// - A4: POST /change-password
class AuthRepository {
  final ApiClient _client;
  final SessionManager _sessionManager;

  AuthRepository({
    required ApiClient client,
    required SessionManager sessionManager,
  })  : _client = client,
        _sessionManager = sessionManager;

  /// Authenticate with username and password.
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

    final response = await _client.post<LoginData>(
      ApiConstants.login,
      fromJson: (json) => LoginData.fromJson(json as Map<String, dynamic>),
      data: data,
    );

    final loginData = response.data!;

    await _sessionManager.onLoginSuccess(
      token: loginData.token,
      adminId: loginData.employee.id,
      companyId: loginData.employee.company?.id ?? 0,
    );

    return loginData;
  }

  /// Revoke the current token and clear local session.
  Future<void> logout() async {
    try {
      await _client.post<void>(ApiConstants.logout);
    } finally {
      await _sessionManager.onLogout();
    }
  }

  /// Revoke all tokens for the authenticated user and clear local session.
  Future<LogoutAllData> logoutAll() async {
    final response = await _client.post<LogoutAllData>(
      ApiConstants.logoutAll,
      fromJson: (json) =>
          LogoutAllData.fromJson(json as Map<String, dynamic>),
    );

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
}
