import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/announcement_models.dart';

/// Repository handling admin announcement operations.
///
/// Endpoints covered:
/// - N1: GET /admin/announcements
/// - N2: POST /admin/announcements
/// - N3: PUT /admin/announcements/{id}
/// - N4: POST /admin/announcements/{id}/publish
/// - N5: DELETE /admin/announcements/{id}
class AnnouncementRepository {
  final ApiClient _client;

  AnnouncementRepository({required ApiClient client}) : _client = client;

  /// Fetch paginated list of announcements with optional status filter.
  Future<AnnouncementsData> getAnnouncements({
    String? status,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<AnnouncementsData>(
      ApiConstants.adminAnnouncements,
      fromJson: (json) =>
          AnnouncementsData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        if (status != null) 'status': status,
        if (perPage != null) 'per_page': perPage,
        if (page != null) 'page': page,
      },
    );
    return response.data!;
  }

  /// Create a new announcement.
  Future<Announcement> createAnnouncement({
    required String title,
    required String body,
    required String category,
    required String audience,
    bool? isPinned,
  }) async {
    final response = await _client.post<Announcement>(
      ApiConstants.adminAnnouncements,
      fromJson: (json) =>
          Announcement.fromJson(json as Map<String, dynamic>),
      data: {
        'title': title,
        'body': body,
        'category': category,
        'audience': audience,
        if (isPinned != null) 'is_pinned': isPinned,
      },
    );
    return response.data!;
  }

  /// Update an existing announcement.
  Future<Announcement> updateAnnouncement(
    int id, {
    String? title,
    String? body,
    String? category,
    String? audience,
    bool? isPinned,
  }) async {
    final response = await _client.put<Announcement>(
      ApiConstants.adminAnnouncementDetail(id),
      fromJson: (json) =>
          Announcement.fromJson(json as Map<String, dynamic>),
      data: {
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (category != null) 'category': category,
        if (audience != null) 'audience': audience,
        if (isPinned != null) 'is_pinned': isPinned,
      },
    );
    return response.data!;
  }

  /// Publish a draft announcement.
  Future<Announcement> publishAnnouncement(int id) async {
    final response = await _client.post<Announcement>(
      ApiConstants.adminAnnouncementPublish(id),
      fromJson: (json) =>
          Announcement.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Delete an announcement.
  Future<void> deleteAnnouncement(int id) async {
    await _client.delete<void>(
      ApiConstants.adminAnnouncementDetail(id),
    );
  }
}
