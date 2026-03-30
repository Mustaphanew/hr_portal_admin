import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/department_models.dart';

/// Repository handling admin department operations.
///
/// Endpoints covered:
/// - L1: GET /admin/departments
/// - L2: GET /admin/departments/{id}
class DepartmentRepository {
  final ApiClient _client;

  DepartmentRepository({required ApiClient client}) : _client = client;

  /// Fetch the list of all departments.
  Future<DepartmentsData> getDepartments() async {
    final response = await _client.get<DepartmentsData>(
      ApiConstants.adminDepartments,
      fromJson: (json) =>
          DepartmentsData.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Fetch detailed information for a specific department.
  Future<DepartmentDetail> getDepartmentDetail(int id) async {
    final response = await _client.get<DepartmentDetail>(
      ApiConstants.adminDepartmentDetail(id),
      fromJson: (json) =>
          DepartmentDetail.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }
}
