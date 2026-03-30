import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Project Models (API O1-O5)
// ═══════════════════════════════════════════════════════════════════════════

/// Manager reference embedded in a project.
class ProjectManager extends Equatable {
  final int id;
  final String name;
  final String? initials;

  const ProjectManager({
    required this.id,
    required this.name,
    this.initials,
  });

  factory ProjectManager.fromJson(Map<String, dynamic> json) {
    return ProjectManager(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      initials: json['initials'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initials': initials,
      };

  @override
  List<Object?> get props => [id, name, initials];
}

/// A project record in the admin projects list (API O1).
class Project extends Equatable {
  final int id;
  final String code;
  final String name;
  final String? department;
  final ProjectManager? manager;
  final String? startDate;
  final String? endDate;
  final String status;
  final String priority;
  final String? description;
  final double progress;
  final int taskCount;
  final int completedTasks;
  final int milestoneCount;
  final bool isDelayed;

  const Project({
    required this.id,
    required this.code,
    required this.name,
    this.department,
    this.manager,
    this.startDate,
    this.endDate,
    required this.status,
    required this.priority,
    this.description,
    required this.progress,
    required this.taskCount,
    required this.completedTasks,
    required this.milestoneCount,
    required this.isDelayed,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: (json['code'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      department: json['department'] as String?,
      manager: json['manager'] is Map
          ? ProjectManager.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: (json['status'] ?? 'active') as String,
      priority: (json['priority'] ?? 'normal') as String,
      description: json['description'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      taskCount: (json['task_count'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completed_tasks'] as num?)?.toInt() ?? 0,
      milestoneCount: (json['milestone_count'] as num?)?.toInt() ?? 0,
      isDelayed: (json['is_delayed'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'department': department,
        'manager': manager?.toJson(),
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
        'priority': priority,
        'description': description,
        'progress': progress,
        'task_count': taskCount,
        'completed_tasks': completedTasks,
        'milestone_count': milestoneCount,
        'is_delayed': isDelayed,
      };

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        department,
        manager,
        startDate,
        endDate,
        status,
        priority,
        description,
        progress,
        taskCount,
        completedTasks,
        milestoneCount,
        isDelayed,
      ];
}

/// Assignee reference embedded in a project task.
class TaskAssignee extends Equatable {
  final int id;
  final String name;

  const TaskAssignee({
    required this.id,
    required this.name,
  });

  factory TaskAssignee.fromJson(Map<String, dynamic> json) {
    return TaskAssignee(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  List<Object?> get props => [id, name];
}

/// A task within a project (API O3).
class ProjectTask extends Equatable {
  final int id;
  final String title;
  final TaskAssignee? assignedTo;
  final String? dueDate;
  final String status;
  final String priority;

  const ProjectTask({
    required this.id,
    required this.title,
    this.assignedTo,
    this.dueDate,
    required this.status,
    required this.priority,
  });

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      assignedTo: json['assigned_to'] != null
          ? TaskAssignee.fromJson(
              json['assigned_to'] as Map<String, dynamic>)
          : null,
      dueDate: json['due_date'] as String?,
      status: (json['status'] ?? 'pending') as String,
      priority: (json['priority'] ?? 'normal') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'assigned_to': assignedTo?.toJson(),
        'due_date': dueDate,
        'status': status,
        'priority': priority,
      };

  @override
  List<Object?> get props => [id, title, assignedTo, dueDate, status, priority];
}

/// A milestone within a project (API O4).
class ProjectMilestone extends Equatable {
  final int id;
  final String title;
  final String? targetDate;
  final String status;
  final bool isCompleted;
  final bool isDelayed;

  const ProjectMilestone({
    required this.id,
    required this.title,
    this.targetDate,
    required this.status,
    required this.isCompleted,
    required this.isDelayed,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    return ProjectMilestone(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      targetDate: json['target_date'] as String?,
      status: (json['status'] ?? 'pending') as String,
      isCompleted: (json['is_completed'] ?? false) as bool,
      isDelayed: (json['is_delayed'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'target_date': targetDate,
        'status': status,
        'is_completed': isCompleted,
        'is_delayed': isDelayed,
      };

  @override
  List<Object?> get props => [id, title, targetDate, status, isCompleted, isDelayed];
}

/// Task statistics within project analytics.
class AnalyticsTaskStats extends Equatable {
  final int total;
  final int completed;
  final int inProgress;
  final int pending;
  final int overdue;

  const AnalyticsTaskStats({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.overdue,
  });

  factory AnalyticsTaskStats.fromJson(Map<String, dynamic> json) {
    return AnalyticsTaskStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      overdue: (json['overdue'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'completed': completed,
        'in_progress': inProgress,
        'pending': pending,
        'overdue': overdue,
      };

  @override
  List<Object?> get props => [total, completed, inProgress, pending, overdue];
}

/// Milestone statistics within project analytics.
class AnalyticsMilestoneStats extends Equatable {
  final int total;
  final int completed;
  final int inProgress;
  final int pending;
  final int overdue;

  const AnalyticsMilestoneStats({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.overdue,
  });

  factory AnalyticsMilestoneStats.fromJson(Map<String, dynamic> json) {
    return AnalyticsMilestoneStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      overdue: (json['overdue'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'completed': completed,
        'in_progress': inProgress,
        'pending': pending,
        'overdue': overdue,
      };

  @override
  List<Object?> get props => [total, completed, inProgress, pending, overdue];
}

/// Budget info within project analytics.
class AnalyticsBudget extends Equatable {
  final double allocated;
  final double spent;
  final double remaining;

  const AnalyticsBudget({
    required this.allocated,
    required this.spent,
    required this.remaining,
  });

  factory AnalyticsBudget.fromJson(Map<String, dynamic> json) {
    return AnalyticsBudget(
      allocated: (json['allocated'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'allocated': allocated,
        'spent': spent,
        'remaining': remaining,
      };

  @override
  List<Object?> get props => [allocated, spent, remaining];
}

/// Timeline info within project analytics.
class AnalyticsTimeline extends Equatable {
  final String? startDate;
  final String? endDate;
  final int daysRemaining;
  final bool isOnTrack;

  const AnalyticsTimeline({
    this.startDate,
    this.endDate,
    required this.daysRemaining,
    required this.isOnTrack,
  });

  factory AnalyticsTimeline.fromJson(Map<String, dynamic> json) {
    return AnalyticsTimeline(
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? 0,
      isOnTrack: (json['is_on_track'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'start_date': startDate,
        'end_date': endDate,
        'days_remaining': daysRemaining,
        'is_on_track': isOnTrack,
      };

  @override
  List<Object?> get props => [startDate, endDate, daysRemaining, isOnTrack];
}

/// Project analytics data (API O5).
class ProjectAnalytics extends Equatable {
  final double progress;
  final AnalyticsTaskStats tasks;
  final AnalyticsMilestoneStats milestones;
  final AnalyticsBudget budget;
  final AnalyticsTimeline timeline;

  const ProjectAnalytics({
    required this.progress,
    required this.tasks,
    required this.milestones,
    required this.budget,
    required this.timeline,
  });

  factory ProjectAnalytics.fromJson(Map<String, dynamic> json) {
    return ProjectAnalytics(
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      tasks: AnalyticsTaskStats.fromJson(
          (json['tasks'] ?? <String, dynamic>{}) as Map<String, dynamic>),
      milestones: AnalyticsMilestoneStats.fromJson(
          (json['milestones'] ?? <String, dynamic>{}) as Map<String, dynamic>),
      budget: AnalyticsBudget.fromJson(
          (json['budget'] ?? <String, dynamic>{}) as Map<String, dynamic>),
      timeline: AnalyticsTimeline.fromJson(
          (json['timeline'] ?? <String, dynamic>{}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'progress': progress,
        'tasks': tasks.toJson(),
        'milestones': milestones.toJson(),
        'budget': budget.toJson(),
        'timeline': timeline.toJson(),
      };

  @override
  List<Object?> get props => [progress, tasks, milestones, budget, timeline];
}

/// Data payload returned by GET /admin/projects (API O1).
class ProjectsData extends Equatable {
  final List<Project> projects;
  final Pagination pagination;

  const ProjectsData({
    required this.projects,
    required this.pagination,
  });

  factory ProjectsData.fromJson(Map<String, dynamic> json) {
    return ProjectsData(
      projects: ((json['projects'] ?? <dynamic>[]) as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromParent(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'projects': projects.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };

  @override
  List<Object?> get props => [projects, pagination];
}
