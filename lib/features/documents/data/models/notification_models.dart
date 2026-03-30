import 'package:equatable/equatable.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Notification Models (API I1-I2)
// ═══════════════════════════════════════════════════════════════════════════

/// Response payload from POST /notifications/send (API I1).
class NotificationResponse extends Equatable {
  final int id;
  final String createdAt;
  final String? fcmResponse;

  const NotificationResponse({
    required this.id,
    required this.createdAt,
    this.fcmResponse,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      fcmResponse: json['fcm_response'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt,
        'fcm_response': fcmResponse,
      };

  @override
  List<Object?> get props => [id, createdAt, fcmResponse];
}

/// Response payload from POST /notifications/send-to-user (API I2).
class SendToUserResponse extends Equatable {
  final int id;
  final String createdAt;
  final int deviceCount;
  final int sent;
  final int failed;

  const SendToUserResponse({
    required this.id,
    required this.createdAt,
    required this.deviceCount,
    required this.sent,
    required this.failed,
  });

  factory SendToUserResponse.fromJson(Map<String, dynamic> json) {
    return SendToUserResponse(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      deviceCount: json['device_count'] as int,
      sent: json['sent'] as int,
      failed: json['failed'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt,
        'device_count': deviceCount,
        'sent': sent,
        'failed': failed,
      };

  @override
  List<Object?> get props => [id, createdAt, deviceCount, sent, failed];
}
