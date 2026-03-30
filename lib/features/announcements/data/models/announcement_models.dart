import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Announcement Models (API N1-N5)
// ═══════════════════════════════════════════════════════════════════════════

/// Creator info embedded in an announcement.
class AnnouncementCreator extends Equatable {
  final int id;
  final String name;

  const AnnouncementCreator({
    required this.id,
    required this.name,
  });

  factory AnnouncementCreator.fromJson(Map<String, dynamic> json) {
    return AnnouncementCreator(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  List<Object?> get props => [id, name];
}

/// An announcement record.
class Announcement extends Equatable {
  final int id;
  final String title;
  final String body;
  final String category;
  final String audience;
  final String publishStatus;
  final bool isPinned;
  final AnnouncementCreator? createdBy;
  final String createdAt;
  final String? publishedAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.audience,
    required this.publishStatus,
    required this.isPinned,
    this.createdBy,
    required this.createdAt,
    this.publishedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String,
      audience: json['audience'] as String,
      publishStatus: json['publish_status'] as String,
      isPinned: json['is_pinned'] as bool,
      createdBy: json['created_by'] != null
          ? AnnouncementCreator.fromJson(
              json['created_by'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String,
      publishedAt: json['published_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
        'audience': audience,
        'publish_status': publishStatus,
        'is_pinned': isPinned,
        'created_by': createdBy?.toJson(),
        'created_at': createdAt,
        'published_at': publishedAt,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        category,
        audience,
        publishStatus,
        isPinned,
        createdBy,
        createdAt,
        publishedAt,
      ];
}

/// Data payload returned by GET /admin/announcements (API N1).
class AnnouncementsData extends Equatable {
  final List<Announcement> announcements;
  final Pagination pagination;

  const AnnouncementsData({
    required this.announcements,
    required this.pagination,
  });

  factory AnnouncementsData.fromJson(Map<String, dynamic> json) {
    return AnnouncementsData(
      announcements: (json['announcements'] as List<dynamic>)
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromParent(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'announcements': announcements.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };

  @override
  List<Object?> get props => [announcements, pagination];
}
