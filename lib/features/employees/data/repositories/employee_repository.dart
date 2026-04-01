import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/employee_models.dart';

/// Repository handling admin employee operations.
///
/// Endpoints covered:
/// - K1: GET /admin/employees
/// - K2: GET /admin/employees/{id}
class EmployeeRepository {
  final ApiClient _client;

  EmployeeRepository({required ApiClient client}) : _client = client;

  /// Fetch the paginated list of employees with optional filters.
  Future<AdminEmployeesData> getEmployees({
    int? departmentId,
    String? status,
    String? attendanceStatus,
    String? search,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<AdminEmployeesData>(
      ApiConstants.adminEmployees,
      fromJson: (json) =>
          AdminEmployeesData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'department_id': ?departmentId,
        'employment_status': ?status,
        'attendance_status': ?attendanceStatus,
        'search': ?search,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
    return response.data!;
  }

  /// Fetch detailed information for a specific employee.
  Future<EmployeeDetail> getEmployeeDetail(int id) async {
    final response = await _client.get<EmployeeDetail>(
      ApiConstants.adminEmployeeDetail(id),
      fromJson: (json) =>
          EmployeeDetail.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }
}
