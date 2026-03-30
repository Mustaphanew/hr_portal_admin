import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Task Models
// ═══════════════════════════════════════════════════════════════════════════

/// Assignee info embedded in a task.
class TaskAssignee extends Equatable {
  final int id;
  final String name;

  const TaskAssignee({
    required this.id,
    required this.name,
  });

  factory TaskAssignee.fromJson(Map<String, dynamic> json) {
    return TaskAssignee(
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

/// A single admin task record.
class AdminTaskItem extends Equatable {
  final int id;
  final String title;
  final TaskAssignee assignedTo;
  final TaskDepartment department;
  final String createdDate;
  final String dueDate;
  final String status;
  final String priority;
  final String? notes;

  const AdminTaskItem({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.department,
    required this.createdDate,
    required this.dueDate,
    required this.status,
    required this.priority,
    this.notes,
  });

  factory AdminTaskItem.fromJson(Map<String, dynamic> json) {
    return AdminTaskItem(
      id: json['id'] as int,
      title: json['title'] as String,
      assignedTo: TaskAssignee.fromJson(
          json['assigned_to'] as Map<String, dynamic>),
      department: TaskDepartment.fromJson(
          json['department'] as Map<String, dynamic>),
      createdDate: json['created_date'] as String,
      dueDate: json['due_date'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'assigned_to': assignedTo.toJson(),
        'department': department.toJson(),
        'created_date': createdDate,
        'due_date': dueDate,
        'status': status,
        'priority': priority,
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        assignedTo,
        department,
        createdDate,
        dueDate,
        status,
        priority,
        notes,
      ];
}

/// Task statistics summary.
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
      total: json['total'] as int,
      pending: json['pending'] as int,
      inProgress: json['in_progress'] as int,
      overdue: json['overdue'] as int,
      completed: json['completed'] as int,
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
  final TaskStats stats;
  final Pagination pagination;

  const AdminTasksData({
    required this.tasks,
    required this.stats,
    required this.pagination,
  });

  factory AdminTasksData.fromJson(Map<String, dynamic> json) {
    return AdminTasksData(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => AdminTaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: TaskStats.fromJson(json['stats'] as Map<String, dynamic>),
      pagination:
          Pagination.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'stats': stats.toJson(),
        'meta': pagination.toJson(),
      };

  @override
  List<Object?> get props => [tasks, stats, pagination];
}
