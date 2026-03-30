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
        if (month != null) 'month': month,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
        if (perPage != null) 'per_page': perPage,
        if (page != null) 'page': page,
      },
    );
    return response.data!;
  }

  /// Fetch all employees' attendance for a given date (admin view).
  Future<AdminAttendanceData> getAdminAttendance({
    String? date,
    int? departmentId,
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
        if (date != null) 'date': date,
        if (departmentId != null) 'department_id': departmentId,
        if (status != null) 'status': status,
        if (search != null) 'search': search,
        if (perPage != null) 'per_page': perPage,
        if (page != null) 'page': page,
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
        if (month != null) 'month': month,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      },
    );
    return response.data!;
  }
}
