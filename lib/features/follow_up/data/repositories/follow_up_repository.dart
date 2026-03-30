import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/follow_up_models.dart';

/// Repository handling admin follow-up operations.
///
/// Endpoints covered:
/// - GET /admin/follow-ups
/// - GET /admin/follow-ups/{id}
/// - PUT /admin/follow-ups/{id}
/// - POST /admin/follow-ups/{id}/escalate
class FollowUpRepository {
  final ApiClient _client;

  FollowUpRepository({required ApiClient client}) : _client = client;

  /// Fetch paginated list of follow-ups with optional filters.
  Future<FollowUpsData> getFollowUps({
    String? status,
    String? type,
    bool? isOverdue,
    bool? isEscalated,
    int? departmentId,
    String? search,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<FollowUpsData>(
      ApiConstants.adminFollowUps,
      fromJson: (json) =>
          FollowUpsData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        if (status != null) 'status': status,
        if (type != null) 'type': type,
        if (isOverdue == true) 'is_overdue': 'true',
        if (isEscalated == true) 'is_escalated': 'true',
        if (departmentId != null) 'department_id': departmentId,
        if (search != null) 'search': search,
        if (perPage != null) 'per_page': perPage,
        if (page != null) 'page': page,
      },
    );
    return response.data!;
  }

  /// Fetch a single follow-up by its ID.
  Future<FollowUpDetail> getFollowUpDetail(int id) async {
    final response = await _client.get<FollowUpDetail>(
      ApiConstants.adminFollowUpDetail(id),
      fromJson: (json) =>
          FollowUpDetail.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Update an existing follow-up's status.
  Future<FollowUpDetail> updateFollowUp(
    int id, {
    required String status,
    String? notes,
  }) async {
    final response = await _client.put<FollowUpDetail>(
      ApiConstants.adminFollowUpDetail(id),
      fromJson: (json) =>
          FollowUpDetail.fromJson(json as Map<String, dynamic>),
      data: {
        'status': status,
        if (notes != null) 'notes': notes,
      },
    );
    return response.data!;
  }

  /// Escalate a follow-up.
  Future<FollowUpItem> escalateFollowUp(
    int id, {
    required String reason,
    int? escalateTo,
  }) async {
    final response = await _client.post<FollowUpItem>(
      ApiConstants.adminFollowUpEscalate(id),
      fromJson: (json) =>
          FollowUpItem.fromJson(json as Map<String, dynamic>),
      data: {
        'reason': reason,
        if (escalateTo != null) 'escalate_to': escalateTo,
      },
    );
    return response.data!;
  }
}
