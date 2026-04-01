import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/auth_models.dart';

/// Repository for the authenticated user's profile.
///
/// Endpoints covered:
/// - B1: GET  /profile
/// - B2: PUT  /profile
class ProfileRepository {
  final ApiClient _client;

  ProfileRepository({required ApiClient client}) : _client = client;

  /// Fetch the current employee's profile.
  Future<EmployeeProfile> getProfile() async {
    final response = await _client.get<EmployeeProfile>(
      ApiConstants.profile,
      fromJson: (json) =>
          EmployeeProfile.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Update editable profile fields.
  ///
  /// Only non-null parameters are sent to the API.
  Future<EmployeeProfile> updateProfile({
    String? phone,
    String? mobile,
    String? email,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    final data = <String, dynamic>{
      'phone': ?phone,
      'mobile': ?mobile,
      'email': ?email,
      'address': ?address,
      'emergency_contact_name': ?emergencyContactName,
      'emergency_contact_phone': ?emergencyContactPhone,
    };

    final response = await _client.put<EmployeeProfile>(
      ApiConstants.profile,
      fromJson: (json) =>
          EmployeeProfile.fromJson(json as Map<String, dynamic>),
      data: data,
    );
    return response.data!;
  }
}
