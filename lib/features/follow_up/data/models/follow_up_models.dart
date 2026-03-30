import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Follow-Up Models
// ═══════════════════════════════════════════════════════════════════════════

/// Responsible person info embedded in a follow-up.
class FollowUpResponsible extends Equatable {
  final int id;
  final String name;

  const FollowUpResponsible({
    required this.id,
    required this.name,
  });

  factory FollowUpResponsible.fromJson(Map<String, dynamic> json) {
    return FollowUpResponsible(
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

/// Department info embedded in a follow-up.
class FollowUpDepartment extends Equatable {
  final int id;
  final String name;

  const FollowUpDepartment({
    required this.id,
    required this.name,
  });

  factory FollowUpDepartment.fromJson(Map<String, dynamic> json) {
    return FollowUpDepartment(
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

/// A single follow-up record (list version).
class FollowUpItem extends Equatable {
  final int id;
  final String title;
  final FollowUpResponsible responsible;
  final FollowUpDepartment department;
  final String dueDate;
  final String status;
  final String type;
  final bool isOverdue;
  final bool isEscalated;
  final String createdAt;

  const FollowUpItem({
    required this.id,
    required this.title,
    required this.responsible,
    required this.department,
    required this.dueDate,
    required this.status,
    required this.type,
    required this.isOverdue,
    required this.isEscalated,
    required this.createdAt,
  });

  factory FollowUpItem.fromJson(Map<String, dynamic> json) {
    return FollowUpItem(
      id: json['id'] as int,
      title: json['title'] as String,
      responsible: FollowUpResponsible.fromJson(
          json['responsible'] as Map<String, dynamic>),
      department: FollowUpDepartment.fromJson(
          json['department'] as Map<String, dynamic>),
      dueDate: json['due_date'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      isOverdue: json['is_overdue'] as bool,
      isEscalated: json['is_escalated'] as bool,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'responsible': responsible.toJson(),
        'department': department.toJson(),
        'due_date': dueDate,
        'status': status,
        'type': type,
        'is_overdue': isOverdue,
        'is_escalated': isEscalated,
        'created_at': createdAt,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        responsible,
        department,
        dueDate,
        status,
        type,
        isOverdue,
        isEscalated,
        createdAt,
      ];
}

/// Related entity info for follow-up detail.
class FollowUpRelatedEntity extends Equatable {
  final String type;
  final int id;

  const FollowUpRelatedEntity({
    required this.type,
    required this.id,
  });

  factory FollowUpRelatedEntity.fromJson(Map<String, dynamic> json) {
    return FollowUpRelatedEntity(
      type: json['type'] as String,
      id: json['id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
      };

  @override
  List<Object?> get props => [type, id];
}

/// A single history entry for a follow-up.
class FollowUpHistoryEntry extends Equatable {
  final String action;
  final String by;
  final String at;
  final String? from;
  final String? to;

  const FollowUpHistoryEntry({
    required this.action,
    required this.by,
    required this.at,
    this.from,
    this.to,
  });

  factory FollowUpHistoryEntry.fromJson(Map<String, dynamic> json) {
    return FollowUpHistoryEntry(
      action: json['action'] as String,
      by: json['by'] as String,
      at: json['at'] as String,
      from: json['from'] as String?,
      to: json['to'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'action': action,
        'by': by,
        'at': at,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      };

  @override
  List<Object?> get props => [action, by, at, from, to];
}

/// Detailed follow-up record (detail version).
class FollowUpDetail extends Equatable {
  final int id;
  final String title;
  final String description;
  final FollowUpResponsible responsible;
  final FollowUpDepartment department;
  final String dueDate;
  final String status;
  final String type;
  final bool isOverdue;
  final bool isEscalated;
  final String createdAt;
  final FollowUpRelatedEntity relatedEntity;
  final List<FollowUpHistoryEntry> history;

  const FollowUpDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.responsible,
    required this.department,
    required this.dueDate,
    required this.status,
    required this.type,
    required this.isOverdue,
    required this.isEscalated,
    required this.createdAt,
    required this.relatedEntity,
    required this.history,
  });

  factory FollowUpDetail.fromJson(Map<String, dynamic> json) {
    return FollowUpDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      responsible: FollowUpResponsible.fromJson(
          json['responsible'] as Map<String, dynamic>),
      department: FollowUpDepartment.fromJson(
          json['department'] as Map<String, dynamic>),
      dueDate: json['due_date'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      isOverdue: json['is_overdue'] as bool,
      isEscalated: json['is_escalated'] as bool,
      createdAt: json['created_at'] as String,
      relatedEntity: FollowUpRelatedEntity.fromJson(
          json['related_entity'] as Map<String, dynamic>),
      history: (json['history'] as List<dynamic>)
          .map((e) => FollowUpHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'responsible': responsible.toJson(),
        'department': department.toJson(),
        'due_date': dueDate,
        'status': status,
        'type': type,
        'is_overdue': isOverdue,
        'is_escalated': isEscalated,
        'created_at': createdAt,
        'related_entity': relatedEntity.toJson(),
        'history': history.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        responsible,
        department,
        dueDate,
        status,
        type,
        isOverdue,
        isEscalated,
        createdAt,
        relatedEntity,
        history,
      ];
}

/// Follow-up statistics summary.
class FollowUpStats extends Equatable {
  final int total;
  final int pending;
  final int inProgress;
  final int overdue;
  final int escalated;
  final int completed;

  const FollowUpStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.overdue,
    required this.escalated,
    required this.completed,
  });

  factory FollowUpStats.fromJson(Map<String, dynamic> json) {
    return FollowUpStats(
      total: json['total'] as int,
      pending: json['pending'] as int,
      inProgress: json['in_progress'] as int,
      overdue: json['overdue'] as int,
      escalated: json['escalated'] as int,
      completed: json['completed'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'pending': pending,
        'in_progress': inProgress,
        'overdue': overdue,
        'escalated': escalated,
        'completed': completed,
      };

  @override
  List<Object?> get props =>
      [total, pending, inProgress, overdue, escalated, completed];
}

/// Data payload returned by GET /admin/follow-ups.
class FollowUpsData extends Equatable {
  final List<FollowUpItem> followUps;
  final FollowUpStats stats;
  final Pagination pagination;

  const FollowUpsData({
    required this.followUps,
    required this.stats,
    required this.pagination,
  });

  factory FollowUpsData.fromJson(Map<String, dynamic> json) {
    return FollowUpsData(
      followUps: (json['follow_ups'] as List<dynamic>)
          .map((e) => FollowUpItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: FollowUpStats.fromJson(json['stats'] as Map<String, dynamic>),
      pagination:
          Pagination.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'follow_ups': followUps.map((e) => e.toJson()).toList(),
        'stats': stats.toJson(),
        'meta': pagination.toJson(),
      };

  @override
  List<Object?> get props => [followUps, stats, pagination];
}
