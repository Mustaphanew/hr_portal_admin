import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════

String? _asString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }
  return null;
}

/// Normalize backend status casing/aliases to lowercase tokens used by the UI.
///
/// Maps the new Postman uppercase values (`TODO`, `IN_PROGRESS`, `DONE`,
/// `CANCELLED`) to the lowercase tokens already used by the existing screens
/// (`pending`, `in_progress`, `completed`, `cancelled`). Returns the lowercased
/// value for any other status.
String _normalizeStatus(String raw) {
  final s = raw.toLowerCase();
  switch (s) {
    case 'todo':
      return 'pending';
    case 'done':
      return 'completed';
    default:
      return s;
  }
}

/// Inverse of [_normalizeStatus] — used when sending the status back to the
/// new admin API (e.g. when updating). Defaults to uppercase pass-through.
String denormalizeTaskStatus(String uiValue) {
  switch (uiValue.toLowerCase()) {
    case 'pending':
      return 'TODO';
    case 'completed':
      return 'DONE';
    case 'in_progress':
      return 'IN_PROGRESS';
    case 'cancelled':
      return 'CANCELLED';
    default:
      return uiValue.toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Task Models
// ═══════════════════════════════════════════════════════════════════════════

/// Assignee info embedded in a task. Also used as a generic employee ref.
class TaskAssignee extends Equatable {
  final int id;
  final String name;

  const TaskAssignee({
    required this.id,
    required this.name,
  });

  factory TaskAssignee.fromJson(Map<String, dynamic> json) {
    return TaskAssignee(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['name']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  List<Object?> get props => [id, name];
}

/// Department info embedded in a task.
class TaskDepartment extends Equatable {
  final int id;
  final String name;

  const TaskDepartment({
    required this.id,
    required this.name,
  });

  factory TaskDepartment.fromJson(Map<String, dynamic> json) {
    return TaskDepartment(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['name']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  List<Object?> get props => [id, name];
}

/// Project reference embedded in a task.
class TaskProjectRef extends Equatable {
  final int id;
  final String? name;

  const TaskProjectRef({required this.id, this.name});

  factory TaskProjectRef.fromJson(Map<String, dynamic> json) => TaskProjectRef(
        id: _asInt(json['id']) ?? 0,
        name: _asString(json['name']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
      };

  @override
  List<Object?> get props => [id, name];
}

/// A single admin task record. Lenient towards both the legacy schema (used
/// by older screens) and the new Postman 06 schema.
class AdminTaskItem extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? type;

  /// Lowercase normalized status (`pending`, `in_progress`, `completed`,
  /// `cancelled`, `overdue`).
  final String status;

  /// Status as returned by the backend (e.g. `TODO`, `IN_PROGRESS`, `DONE`).
  final String rawStatus;

  final String priority;

  /// Embedded assignee (may be empty if backend only returns the id).
  final TaskAssignee assignedTo;

  /// Numeric assignee id (always populated when known).
  final int? assigneeEmployeeId;

  /// Numeric reporter id from the new Postman schema.
  final int? reporterEmployeeId;

  /// Embedded department (may be empty if backend doesn't provide).
  final TaskDepartment department;

  /// Project reference (Postman 06).
  final TaskProjectRef? project;

  /// Project id shortcut.
  final int? projectId;

  /// Date strings (kept as raw API strings, may be ISO date or datetime).
  final String createdDate;
  final String? startDate;
  final String dueDate;

  final int? estimateMinutes;
  final int? actualMinutes;
  final int? progressPercent;
  final bool? isBillable;
  final bool? isUrgent;

  final String? notes;

  const AdminTaskItem({
    required this.id,
    required this.title,
    this.description,
    this.type,
    required this.status,
    required this.rawStatus,
    required this.priority,
    required this.assignedTo,
    this.assigneeEmployeeId,
    this.reporterEmployeeId,
    required this.department,
    this.project,
    this.projectId,
    required this.createdDate,
    this.startDate,
    required this.dueDate,
    this.estimateMinutes,
    this.actualMinutes,
    this.progressPercent,
    this.isBillable,
    this.isUrgent,
    this.notes,
  });

  factory AdminTaskItem.fromJson(Map<String, dynamic> json) {
    final rawStatus = _asString(json['status']) ?? 'pending';

    // Embedded assignee can come from `assigned_to`, `assignee`, or fall back
    // to a synthetic record built from `assignee_employee_id` + name fields.
    TaskAssignee assignee;
    final assigneeRaw = json['assignee'] ?? json['assigned_to'];
    if (assigneeRaw is Map<String, dynamic>) {
      assignee = TaskAssignee.fromJson(assigneeRaw);
    } else {
      assignee = TaskAssignee(
        id: _asInt(json['assignee_employee_id']) ?? 0,
        name: _asString(json['assignee_name']) ?? '',
      );
    }

    TaskDepartment department;
    final deptRaw = json['department'];
    if (deptRaw is Map<String, dynamic>) {
      department = TaskDepartment.fromJson(deptRaw);
    } else {
      department = TaskDepartment(
        id: _asInt(json['department_id']) ?? 0,
        name: _asString(json['department_name']) ?? '',
      );
    }

    TaskProjectRef? project;
    final projectRaw = json['project'];
    if (projectRaw is Map<String, dynamic>) {
      project = TaskProjectRef.fromJson(projectRaw);
    }

    return AdminTaskItem(
      id: _asInt(json['id']) ?? 0,
      title: _asString(json['title']) ?? '',
      description: _asString(json['description']),
      type: _asString(json['type']),
      status: _normalizeStatus(rawStatus),
      rawStatus: rawStatus,
      priority: (_asString(json['priority']) ?? 'MEDIUM').toLowerCase(),
      assignedTo: assignee,
      assigneeEmployeeId:
          _asInt(json['assignee_employee_id']) ?? (assignee.id == 0 ? null : assignee.id),
      reporterEmployeeId: _asInt(json['reporter_employee_id']),
      department: department,
      project: project,
      projectId: _asInt(json['project_id']) ?? project?.id,
      createdDate: _asString(json['created_date']) ??
          _asString(json['created_at']) ??
          '',
      startDate: _asString(json['start_date']),
      dueDate: _asString(json['due_date']) ?? '',
      estimateMinutes: _asInt(json['estimate_minutes']),
      actualMinutes: _asInt(json['actual_minutes']),
      progressPercent: _asInt(json['progress_percent']),
      isBillable: _asBool(json['is_billable']),
      isUrgent: _asBool(json['is_urgent']),
      notes: _asString(json['notes']) ?? _asString(json['description']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        if (type != null) 'type': type,
        'status': rawStatus,
        'priority': priority,
        'assigned_to': assignedTo.toJson(),
        if (assigneeEmployeeId != null)
          'assignee_employee_id': assigneeEmployeeId,
        if (reporterEmployeeId != null)
          'reporter_employee_id': reporterEmployeeId,
        'department': department.toJson(),
        if (project != null) 'project': project!.toJson(),
        if (projectId != null) 'project_id': projectId,
        'created_date': createdDate,
        if (startDate != null) 'start_date': startDate,
        'due_date': dueDate,
        if (estimateMinutes != null) 'estimate_minutes': estimateMinutes,
        if (actualMinutes != null) 'actual_minutes': actualMinutes,
        if (progressPercent != null) 'progress_percent': progressPercent,
        if (isBillable != null) 'is_billable': isBillable,
        if (isUrgent != null) 'is_urgent': isUrgent,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        status,
        rawStatus,
        priority,
        assignedTo,
        assigneeEmployeeId,
        reporterEmployeeId,
        department,
        project,
        projectId,
        createdDate,
        startDate,
        dueDate,
        estimateMinutes,
        actualMinutes,
        progressPercent,
        isBillable,
        isUrgent,
        notes,
      ];
}

/// Task statistics summary (optional in the new Postman list response).
class TaskStats extends Equatable {
  final int total;
  final int pending;
  final int inProgress;
  final int overdue;
  final int completed;

  const TaskStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.overdue,
    required this.completed,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    return TaskStats(
      total: _asInt(json['total']) ?? 0,
      pending: _asInt(json['pending']) ?? _asInt(json['todo']) ?? 0,
      inProgress: _asInt(json['in_progress']) ?? 0,
      overdue: _asInt(json['overdue']) ?? 0,
      completed: _asInt(json['completed']) ?? _asInt(json['done']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'pending': pending,
        'in_progress': inProgress,
        'overdue': overdue,
        'completed': completed,
      };

  @override
  List<Object?> get props => [total, pending, inProgress, overdue, completed];
}

/// Data payload returned by GET /admin/tasks.
class AdminTasksData extends Equatable {
  final List<AdminTaskItem> tasks;

  /// Optional — not always present in the new Postman list response.
  final TaskStats? stats;

  final Pagination pagination;

  const AdminTasksData({
    required this.tasks,
    required this.stats,
    required this.pagination,
  });

  factory AdminTasksData.fromJson(Map<String, dynamic> json) {
    List<dynamic>? raw;
    for (final key in const [
      'tasks',
      'items',
      'data',
      'records',
      'results',
    ]) {
      final v = json[key];
      if (v is List) {
        raw = v;
        break;
      }
    }
    raw ??= json.values
        .whereType<List>()
        .firstWhere((l) => l.isEmpty || l.first is Map, orElse: () => const []);

    return AdminTasksData(
      tasks: raw
          .map((e) => AdminTaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: json['stats'] is Map<String, dynamic>
          ? TaskStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      pagination: Pagination.fromParent(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'tasks': tasks.map((e) => e.toJson()).toList(),
        if (stats != null) 'stats': stats!.toJson(),
        'meta': pagination.toJson(),
      };

  @override
  List<Object?> get props => [tasks, stats, pagination];
}

// ═══════════════════════════════════════════════════════════════════════════
// Time Logs (Postman 06)
// ═══════════════════════════════════════════════════════════════════════════

class TaskTimeLog extends Equatable {
  final int id;
  final int? employeeId;
  final String? employeeName;
  final String? logDate;
  final String? startTime;
  final String? endTime;
  final double? hoursSpent;
  final String? description;
  final bool? isBillable;
  final String? createdAt;

  const TaskTimeLog({
    required this.id,
    this.employeeId,
    this.employeeName,
    this.logDate,
    this.startTime,
    this.endTime,
    this.hoursSpent,
    this.description,
    this.isBillable,
    this.createdAt,
  });

  factory TaskTimeLog.fromJson(Map<String, dynamic> json) {
    final emp = json['employee'];
    return TaskTimeLog(
      id: _asInt(json['id']) ?? 0,
      employeeId: _asInt(json['employee_id']) ??
          (emp is Map<String, dynamic> ? _asInt(emp['id']) : null),
      employeeName:
          emp is Map<String, dynamic> ? _asString(emp['name']) : _asString(json['employee_name']),
      logDate: _asString(json['log_date']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      hoursSpent: _asDouble(json['hours_spent']),
      description: _asString(json['description']),
      isBillable: _asBool(json['is_billable']),
      createdAt: _asString(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        logDate,
        startTime,
        endTime,
        hoursSpent,
        description,
        isBillable,
        createdAt,
      ];
}

// ═══════════════════════════════════════════════════════════════════════════
// Comments (Postman 06)
// ═══════════════════════════════════════════════════════════════════════════

class TaskComment extends Equatable {
  final int id;
  final String body;
  final int? employeeId;
  final String? employeeName;
  final int? parentCommentId;
  final String? createdAt;
  final String? updatedAt;

  const TaskComment({
    required this.id,
    required this.body,
    this.employeeId,
    this.employeeName,
    this.parentCommentId,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    final emp = json['employee'];
    return TaskComment(
      id: _asInt(json['id']) ?? 0,
      body: _asString(json['body']) ?? '',
      employeeId: _asInt(json['employee_id']) ??
          (emp is Map<String, dynamic> ? _asInt(emp['id']) : null),
      employeeName:
          emp is Map<String, dynamic> ? _asString(emp['name']) : _asString(json['employee_name']),
      parentCommentId: _asInt(json['parent_comment_id']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
    );
  }

  @override
  List<Object?> get props =>
      [id, body, employeeId, employeeName, parentCommentId, createdAt, updatedAt];
}

// ═══════════════════════════════════════════════════════════════════════════
// Attachments (Postman 06)
// ═══════════════════════════════════════════════════════════════════════════

class TaskAttachment extends Equatable {
  final int id;
  final String? fileName;
  final String? fileUrl;
  final String? mimeType;
  final int? sizeBytes;
  final String? notes;
  final String? createdAt;

  const TaskAttachment({
    required this.id,
    this.fileName,
    this.fileUrl,
    this.mimeType,
    this.sizeBytes,
    this.notes,
    this.createdAt,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: _asInt(json['id']) ?? 0,
      fileName: _asString(json['file_name']) ?? _asString(json['name']),
      fileUrl: _asString(json['file_url']) ?? _asString(json['url']),
      mimeType: _asString(json['mime_type']),
      sizeBytes: _asInt(json['size_bytes']) ?? _asInt(json['size']),
      notes: _asString(json['notes']),
      createdAt: _asString(json['created_at']),
    );
  }

  @override
  List<Object?> get props =>
      [id, fileName, fileUrl, mimeType, sizeBytes, notes, createdAt];
}
