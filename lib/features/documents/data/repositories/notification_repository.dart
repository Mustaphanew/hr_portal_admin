import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_models.dart';

/// Repository handling push notification operations.
///
/// Endpoints covered:
/// - I1: POST /notifications/send
/// - I2: POST /notifications/send-to-user
class NotificationRepository {
  final ApiClient _client;

  NotificationRepository({required ApiClient client}) : _client = client;

  /// Send a notification to a topic or broadcast.
  Future<NotificationResponse> sendNotification({
    required bool isTopic,
    required String toWho,
    required String titleAr,
    required String bodyAr,
    required String titleEn,
    required String bodyEn,
    String? image,
    String? url,
    String? route,
  }) async {
    final response = await _client.post<NotificationResponse>(
      ApiConstants.notificationsSend,
      fromJson: (json) =>
          NotificationResponse.fromJson(json as Map<String, dynamic>),
      data: {
        'is_topic': isTopic,
        'to_who': toWho,
        'title_ar': titleAr,
        'body_ar': bodyAr,
        'title_en': titleEn,
        'body_en': bodyEn,
        if (image != null) 'image': image,
        if (url != null) 'url': url,
        if (route != null) 'route': route,
      },
    );
    return response.data!;
  }

  /// Send a notification to a specific user.
  Future<SendToUserResponse> sendToUser({
    required int userId,
    required String titleAr,
    required String bodyAr,
    required String titleEn,
    required String bodyEn,
    String? image,
    String? url,
    String? route,
  }) async {
    final response = await _client.post<SendToUserResponse>(
      ApiConstants.notificationsSendToUser,
      fromJson: (json) =>
          SendToUserResponse.fromJson(json as Map<String, dynamic>),
      data: {
        'user_id': userId,
        'title_ar': titleAr,
        'body_ar': bodyAr,
        'title_en': titleEn,
        'body_en': bodyEn,
        if (image != null) 'image': image,
        if (url != null) 'url': url,
        if (route != null) 'route': route,
      },
    );
    return response.data!;
  }
}
