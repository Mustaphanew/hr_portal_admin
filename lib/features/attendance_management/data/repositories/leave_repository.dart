import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/base_response.dart';
import '../models/leave_models.dart';

/// Repository for employee and manager leave operations.
///
/// Endpoints covered:
/// - C1–C4 (Employee leaves)
/// - F1–F3 (Manager leaves)
class LeaveRepository {
  final ApiClient _apiClient;

  LeaveRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════════════════════════
  // C. Employee Leaves
  // ═══════════════════════════════════════════════════════════════════════════

  /// C1 — List the authenticated employee's leaves (with balances & types).
  Future<BaseResponse<LeavesListData>> getEmployeeLeaves({
    int? year,
    String? status,
    int? perPage,
    int? page,
  }) async {
    final queryParameters = <String, dynamic>{
      'year': ?year,
      'status': ?status,
      'per_page': ?perPage,
      'page': ?page,
    };

    return _apiClient.get<LeavesListData>(
      ApiConstants.leaves,
      queryParameters: queryParameters,
      fromJson: (json) =>
          LeavesListData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// C2 — Create a new leave request.
  Future<BaseResponse<LeaveRequest>> createLeave({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    String? dayPart,
    String? reason,
  }) async {
    return _apiClient.post<LeaveRequest>(
      ApiConstants.leaves,
      data: {
        'leave_type_id': leaveTypeId,
        'start_date': startDate,
        'end_date': endDate,
        'day_part': ?dayPart,
        'reason': ?reason,
      },
      fromJson: (json) =>
          LeaveRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  /// C3 — Get a single leave request by ID.
  Future<BaseResponse<LeaveRequest>> getLeaveDetail(int id) async {
    return _apiClient.get<LeaveRequest>(
      ApiConstants.leaveDetail(id),
      fromJson: (json) =>
          LeaveRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  /// C4 — Delete (cancel) a pending leave request.
  Future<BaseResponse<void>> deleteLeave(int id) async {
    return _apiClient.delete<void>(
      ApiConstants.leaveDetail(id),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // F. Manager Leaves
  // ═══════════════════════════════════════════════════════════════════════════

  /// F1 — List admin leave requests.
  Future<BaseResponse<ManagerLeavesData>> getManagerLeaves({
    String? status,
    int? employeeId,
    int? companyId,
    int? departmentId,
    int? leaveTypeId,
    String? search,
    int? perPage,
    int? page,
  }) async {
    final queryParameters = <String, dynamic>{
      'status': ?status,
      'employee_id': ?employeeId,
      'company_id': ?companyId,
      'department_id': ?departmentId,
      'leave_type_id': ?leaveTypeId,
      'search': ?search,
      'per_page': ?perPage,
      'page': ?page,
    };

    return _apiClient.get<ManagerLeavesData>(
      ApiConstants.adminLeaveRequests,
      queryParameters: queryParameters,
      fromJson: (json) =>
          ManagerLeavesData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// F2 — Get a single leave request detail.
  Future<BaseResponse<LeaveRequest>> getManagerLeaveDetail(int id) async {
    return _apiClient.get<LeaveRequest>(
      ApiConstants.adminLeaveRequestDetail(id),
      fromJson: (json) =>
          LeaveRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  /// F3 — Approve or reject a leave request.
  Future<BaseResponse<LeaveRequest>> decideLeave(
    int id, {
    required String decision,
    String? notes,
  }) async {
    return _apiClient.post<LeaveRequest>(
      ApiConstants.adminLeaveRequestDecide(id),
      data: {
        'decision': decision,
        'notes': ?notes,
      },
      fromJson: (json) =>
          LeaveRequest.fromJson(json as Map<String, dynamic>),
    );
  }
}
