import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/attendance_models.dart';

/// Repository handling all attendance operations.
///
/// Endpoints covered:
/// - G1: GET /attendance/history
/// - M1: GET /admin/attendance
/// - M2: GET /admin/attendance/{id}
class AttendanceRepository {
  final ApiClient _client;

  AttendanceRepository({required ApiClient client}) : _client = client;

  /// Fetch the authenticated employee's attendance history.
  Future<AttendanceHistoryData> getHistory({
    String? month,
    String? dateFrom,
    String? dateTo,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<AttendanceHistoryData>(
      ApiConstants.attendanceHistory,
      fromJson: (json) =>
          AttendanceHistoryData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'month': ?month,
        'date_from': ?dateFrom,
        'date_to': ?dateTo,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
    return response.data!;
  }

  /// Fetch all employees' attendance with optional filters (admin view).
  ///
  /// All filters are server-side query parameters. Pass `null` to skip a filter.
  /// Aligned with Postman 03 contract:
  /// `?company_id=&branch_id=&department_id=&employee_id=&month=&status=&search=&per_page=`
  Future<AdminAttendanceData> getAdminAttendance({
    String? date,
    String? month, // YYYY-MM
    int? companyId,
    int? branchId,
    int? departmentId,
    int? employeeId,
    String? status,
    String? search,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<AdminAttendanceData>(
      ApiConstants.adminAttendance,
      fromJson: (json) =>
          AdminAttendanceData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'date': ?date,
        'month': ?month,
        'company_id': ?companyId,
        'branch_id': ?branchId,
        'department_id': ?departmentId,
        'employee_id': ?employeeId,
        'status': ?status,
        'search': ?search,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
    return response.data!;
  }

  /// Fetch a specific employee's attendance records (admin view).
  Future<EmployeeAttendanceData> getEmployeeAttendance(
    int employeeId, {
    String? month,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _client.get<EmployeeAttendanceData>(
      ApiConstants.adminAttendanceEmployee(employeeId),
      fromJson: (json) =>
          EmployeeAttendanceData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'month': ?month,
        'date_from': ?dateFrom,
        'date_to': ?dateTo,
      },
    );
    return response.data!;
  }
}
