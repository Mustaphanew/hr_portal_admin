import 'dart:convert';

/// Local notification model stored in SQLite.
class LocalNotification {
  final String id;
  final String titleAr;
  final String bodyAr;
  final String titleEn;
  final String bodyEn;
  final String? img;
  final String? url;
  final String? route;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final int createdAt; // epoch ms

  const LocalNotification({
    required this.id,
    required this.titleAr,
    required this.bodyAr,
    required this.titleEn,
    required this.bodyEn,
    this.img,
    this.url,
    this.route,
    this.payload,
    this.isRead = false,
    required this.createdAt,
  });

  /// Localized title based on language code.
  String titleByLang(String lang) {
    if (lang == 'ar') return titleAr.isNotEmpty ? titleAr : titleEn;
    return titleEn.isNotEmpty ? titleEn : titleAr;
  }

  /// Localized body based on language code.
  String bodyByLang(String lang) {
    if (lang == 'ar') return bodyAr.isNotEmpty ? bodyAr : bodyEn;
    return bodyEn.isNotEmpty ? bodyEn : bodyAr;
  }

  DateTime get createdAtDate =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);

  String get timeAgo {
    final diff = DateTime.now().difference(createdAtDate);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${createdAtDate.day}/${createdAtDate.month}/${createdAtDate.year}';
  }

  factory LocalNotification.fromDbMap(Map<String, Object?> m) {
    Map<String, dynamic>? payloadMap;
    final raw = m['payload'];
    if (raw is String && raw.isNotEmpty) {
      try {
        payloadMap = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    return LocalNotification(
      id: m['id'] as String,
      titleAr: (m['title_ar'] as String?) ?? '',
      bodyAr: (m['body_ar'] as String?) ?? '',
      titleEn: (m['title_en'] as String?) ?? '',
      bodyEn: (m['body_en'] as String?) ?? '',
      img: m['img'] as String?,
      url: m['url'] as String?,
      route: m['route'] as String?,
      payload: payloadMap,
      isRead: (m['is_read'] as int?) == 1,
      createdAt: (m['created_at'] as int?) ?? 0,
    );
  }

  LocalNotification copyWith({bool? isRead}) => LocalNotification(
        id: id,
        titleAr: titleAr,
        bodyAr: bodyAr,
        titleEn: titleEn,
        bodyEn: bodyEn,
        img: img,
        url: url,
        route: route,
        payload: payload,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
