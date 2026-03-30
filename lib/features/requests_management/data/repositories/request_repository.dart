import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/base_response.dart';
import '../models/request_models.dart';

/// Repository for employee and manager request operations.
///
/// Endpoints covered:
/// - D1–D3 (Employee requests)
/// - E1–E3 (Manager requests)
class RequestRepository {
  final ApiClient _apiClient;

  RequestRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════════════════════════
  // D. Employee Requests
  // ═══════════════════════════════════════════════════════════════════════════

  /// D1 — List the authenticated employee's requests.
  Future<BaseResponse<RequestsListData>> getEmployeeRequests({
    String? status,
    String? type,
    int? perPage,
    int? page,
  }) async {
    final queryParameters = <String, dynamic>{
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (perPage != null) 'per_page': perPage,
      if (page != null) 'page': page,
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
        if (description != null) 'description': description,
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
  // E. Manager Requests
  // ═══════════════════════════════════════════════════════════════════════════

  /// E1 — List requests pending manager review.
  Future<BaseResponse<RequestsListData>> getManagerRequests({
    String? status,
    String? requestType,
    int? employeeId,
    int? perPage,
    int? page,
  }) async {
    final queryParameters = <String, dynamic>{
      if (status != null) 'status': status,
      if (requestType != null) 'request_type': requestType,
      if (employeeId != null) 'employee_id': employeeId,
      if (perPage != null) 'per_page': perPage,
      if (page != null) 'page': page,
    };

    return _apiClient.get<RequestsListData>(
      ApiConstants.managerRequests,
      queryParameters: queryParameters,
      fromJson: (json) =>
          RequestsListData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// E2 — Get a single request in manager view.
  Future<BaseResponse<EmployeeRequest>> getManagerRequestDetail(int id) async {
    return _apiClient.get<EmployeeRequest>(
      ApiConstants.managerRequestDetail(id),
      fromJson: (json) =>
          EmployeeRequest.fromJson(json as Map<String, dynamic>),
    );
  }

  /// E3 — Approve or reject a request.
  Future<BaseResponse<EmployeeRequest>> decideRequest(
    int id, {
    required String status,
    String? responseNotes,
  }) async {
    return _apiClient.post<EmployeeRequest>(
      ApiConstants.managerRequestDecide(id),
      data: {
        'status': status,
        if (responseNotes != null) 'response_notes': responseNotes,
      },
      fromJson: (json) =>
          EmployeeRequest.fromJson(json as Map<String, dynamic>),
    );
  }
}
