import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/base_response.dart';
import '../models/request_models.dart';

/// Repository for employee and admin request operations.
///
/// Endpoints covered:
/// - D1–D3 (Employee self-requests at `/api/v1/requests`)
/// - Postman 01 (Admin employee-requests at `/api/v1/admin/employee-requests`)
class RequestRepository {
  final ApiClient _apiClient;

  RequestRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════════════════════════
  // D. Employee Requests (self)
  // ═══════════════════════════════════════════════════════════════════════════

  /// D1 — List the authenticated employee's requests.
  Future<BaseResponse<RequestsListData>> getEmployeeRequests({
    String? status,
    String? type,
    int? perPage,
    int? page,
  }) async {
    final queryParameters = <String, dynamic>{
      'status': ?status,
      'type': ?type,
      'per_page': ?perPage,
      'page': ?page,
    };

    return _apiClient.get<RequestsListData>(
      ApiConstants.requests,
      queryParameters: queryParameters,
      fromJson: (json) =>
          RequestsListData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// D2 — Create a new employee request.
  Future<BaseResponse<EmployeeRequest>> createRequest({
    required String requestType,
    required String subject,
    String? description,
  }) async {
    return _apiClient.post<EmployeeRequest>(
      ApiConstants.requests,
      data: {
        'request_type': requestType,
        'subject': subject,
        'description': ?description,
      },
      fromJson: (json) =>
          EmployeeRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  /// D3 — Get a single employee request by ID.
  Future<BaseResponse<EmployeeRequest>> getRequestDetail(int id) async {
    return _apiClient.get<EmployeeRequest>(
      ApiConstants.requestDetail(id),
      fromJson: (json) =>
          EmployeeRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Admin Employee Requests (Postman 01)
  // ═══════════════════════════════════════════════════════════════════════════

  /// List employee requests in admin scope with rich filters.
  Future<BaseResponse<RequestsListData>> getAdminEmployeeRequests({
    int? companyId,
    int? branchId,
    int? departmentId,
    int? employeeId,
    String? requestType,
    int? requestTypeId,
    String? status,
    String? dateFrom,
    String? dateTo,
    double? amountMin,
    double? amountMax,
    String? search,
    int? perPage,
    int? page,
  }) async {
    final queryParameters = <String, dynamic>{
      'company_id': ?companyId,
      'branch_id': ?branchId,
      'department_id': ?departmentId,
      'employee_id': ?employeeId,
      'request_type': ?requestType,
      'request_type_id': ?requestTypeId,
      'status': ?status,
      'date_from': ?dateFrom,
      'date_to': ?dateTo,
      'amount_min': ?amountMin,
      'amount_max': ?amountMax,
      'search': ?search,
      'per_page': ?perPage,
      'page': ?page,
    };

    return _apiClient.get<RequestsListData>(
      ApiConstants.adminEmployeeRequests,
      queryParameters: queryParameters,
      fromJson: (json) =>
          RequestsListData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Summary KPIs for admin employee requests.
  Future<BaseResponse<EmployeeRequestsSummary>> getAdminEmployeeRequestsSummary({
    int? companyId,
    int? branchId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParameters = <String, dynamic>{
      'company_id': ?companyId,
      'branch_id': ?branchId,
      'date_from': ?dateFrom,
      'date_to': ?dateTo,
    };

    return _apiClient.get<EmployeeRequestsSummary>(
      ApiConstants.adminEmployeeRequestsSummary,
      queryParameters: queryParameters,
      fromJson: (json) =>
          EmployeeRequestsSummary.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Show a single admin employee-request by id.
  Future<BaseResponse<EmployeeRequest>> getAdminEmployeeRequestDetail(
    int id,
  ) async {
    return _apiClient.get<EmployeeRequest>(
      ApiConstants.adminEmployeeRequestDetail(id),
      fromJson: (json) =>
          EmployeeRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Generic decide endpoint that accepts `decision: approved|rejected`.
  Future<BaseResponse<EmployeeRequest>> decideAdminEmployeeRequest(
    int id, {
    required String decision,
    String? notes,
  }) async {
    return _apiClient.post<EmployeeRequest>(
      ApiConstants.adminEmployeeRequestDecide(id),
      data: {
        'decision': decision,
        'notes': ?notes,
      },
      fromJson: (json) =>
          EmployeeRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Approve an employee request.
  Future<BaseResponse<EmployeeRequest>> approveAdminEmployeeRequest(
    int id, {
    String? notes,
  }) async {
    return _apiClient.post<EmployeeRequest>(
      ApiConstants.adminEmployeeRequestApprove(id),
      data: {
        'notes': ?notes,
      },
      fromJson: (json) =>
          EmployeeRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Reject an employee request.
  Future<BaseResponse<EmployeeRequest>> rejectAdminEmployeeRequest(
    int id, {
    String? notes,
  }) async {
    return _apiClient.post<EmployeeRequest>(
      ApiConstants.adminEmployeeRequestReject(id),
      data: {
        'notes': ?notes,
      },
      fromJson: (json) =>
          EmployeeRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Backwards-compatible aliases (used by existing screens/providers).
  // These now point to the new admin endpoints.
  // ═══════════════════════════════════════════════════════════════════════════

  /// @deprecated Use [getAdminEmployeeRequests]. Kept so existing UI keeps working.
  Future<BaseResponse<RequestsListData>> getManagerRequests({
    String? status,
    String? requestType,
    int? employeeId,
    int? perPage,
    int? page,
  }) {
    return getAdminEmployeeRequests(
      status: status,
      requestType: requestType,
      employeeId: employeeId,
      perPage: perPage,
      page: page,
    );
  }

  /// @deprecated Use [getAdminEmployeeRequestDetail].
  Future<BaseResponse<EmployeeRequest>> getManagerRequestDetail(int id) {
    return getAdminEmployeeRequestDetail(id);
  }

  /// @deprecated Use [decideAdminEmployeeRequest] / [approveAdminEmployeeRequest] /
  /// [rejectAdminEmployeeRequest].
  ///
  /// Maps the legacy `status` parameter (`approved` | `rejected`) to the new
  /// `decision` body field expected by `/admin/employee-requests/{id}/decide`.
  Future<BaseResponse<EmployeeRequest>> decideRequest(
    int id, {
    required String status,
    String? responseNotes,
  }) {
    return decideAdminEmployeeRequest(
      id,
      decision: status,
      notes: responseNotes,
    );
  }
}
