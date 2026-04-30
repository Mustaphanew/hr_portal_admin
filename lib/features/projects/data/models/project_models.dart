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
  final String? jobTitle;

  const ProjectManager({
    required this.id,
    required this.name,
    this.initials,
    this.jobTitle,
  });

  factory ProjectManager.fromJson(Map<String, dynamic> json) {
    return ProjectManager(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      initials: json['initials'] as String?,
      jobTitle: json['job_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initials': initials,
        if (jobTitle != null) 'job_title': jobTitle,
      };

  @override
  List<Object?> get props => [id, name, initials, jobTitle];
}

/// Lightweight `{id, name}` reference (company / branch / department).
class ProjectNamedRef extends Equatable {
  final int id;
  final String name;
  final String? nameEn;

  const ProjectNamedRef({
    required this.id,
    required this.name,
    this.nameEn,
  });

  factory ProjectNamedRef.fromJson(Map<String, dynamic> json) {
    return ProjectNamedRef(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      nameEn: json['name_en'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (nameEn != null) 'name_en': nameEn,
      };

  @override
  List<Object?> get props => [id, name, nameEn];
}

/// Tasks summary embedded in project detail.
class ProjectTasksSummary extends Equatable {
  final int total;
  final int completed;
  final int inProgress;
  final int pending;
  final int overdue;

  const ProjectTasksSummary({
    this.total = 0,
    this.completed = 0,
    this.inProgress = 0,
    this.pending = 0,
    this.overdue = 0,
  });

  factory ProjectTasksSummary.fromJson(Map<String, dynamic> json) {
    return ProjectTasksSummary(
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      overdue: (json['overdue'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [total, completed, inProgress, pending, overdue];
}

/// A project record matching real `/admin/projects` response (2026-04-29).
class Project extends Equatable {
  final int id;
  final String code;
  final String name;
  final String? nameEn;
  final ProjectNamedRef? company;
  final ProjectNamedRef? branch;
  final int? departmentId;
  final ProjectManager? manager;
  final String? startDate;
  final String? endDate;
  final String? actualStartDate;
  final String? actualEndDate;
  final String status; // ACTIVE / IN_PROGRESS / COMPLETED / CANCELLED ...
  final String priority; // LOW / MEDIUM / HIGH / URGENT
  final String? description;
  final double budgetAmount;
  final double spentAmount;
  /// 0-100 (real key is `progress_percent`).
  final double progressPercent;
  final bool isActive;
  /// Only present in detail responses.
  final ProjectTasksSummary? tasksSummary;
  final int? attachmentsCount;
  final String? createdAt;
  final String? updatedAt;

  const Project({
    required this.id,
    required this.code,
    required this.name,
    this.nameEn,
    this.company,
    this.branch,
    this.departmentId,
    this.manager,
    this.startDate,
    this.endDate,
    this.actualStartDate,
    this.actualEndDate,
    required this.status,
    required this.priority,
    this.description,
    this.budgetAmount = 0,
    this.spentAmount = 0,
    this.progressPercent = 0,
    this.isActive = false,
    this.tasksSummary,
    this.attachmentsCount,
    this.createdAt,
    this.updatedAt,
  });

  // ── Convenience aliases for old screen code ──
  /// Lower-case status (e.g. "active") for matching with old switch cases.
  String get statusLower => status.toLowerCase();
  double get progress => progressPercent;
  int get taskCount => tasksSummary?.total ?? 0;
  int get completedTasks => tasksSummary?.completed ?? 0;
  int get milestoneCount => 0; // milestones not part of summary
  bool get isDelayed => tasksSummary != null && tasksSummary!.overdue > 0;
  /// Legacy single-string department name (best-effort — we only have the id).
  String? get department =>
      departmentId == null ? null : 'Dept #$departmentId';

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: (json['code'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      nameEn: json['name_en'] as String?,
      company: json['company'] is Map<String, dynamic>
          ? ProjectNamedRef.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      branch: json['branch'] is Map<String, dynamic>
          ? ProjectNamedRef.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      departmentId: (json['department_id'] as num?)?.toInt(),
      manager: json['manager'] is Map<String, dynamic>
          ? ProjectManager.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      actualStartDate: json['actual_start_date'] as String?,
      actualEndDate: json['actual_end_date'] as String?,
      status: (json['status'] ?? 'ACTIVE').toString(),
      priority: (json['priority'] ?? 'MEDIUM').toString(),
      description: json['description'] as String?,
      budgetAmount: (json['budget_amount'] as num?)?.toDouble() ?? 0,
      spentAmount: (json['spent_amount'] as num?)?.toDouble() ?? 0,
      // Accept both `progress_percent` (real) and `progress` (legacy) keys.
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ??
          (json['progress'] as num?)?.toDouble() ??
          0,
      isActive: (json['is_active'] ?? false) as bool,
      tasksSummary: json['tasks_summary'] is Map<String, dynamic>
          ? ProjectTasksSummary.fromJson(
              json['tasks_summary'] as Map<String, dynamic>)
          : null,
      attachmentsCount: (json['attachments_count'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        if (nameEn != null) 'name_en': nameEn,
        if (company != null) 'company': company!.toJson(),
        if (branch != null) 'branch': branch!.toJson(),
        if (departmentId != null) 'department_id': departmentId,
        if (manager != null) 'manager': manager!.toJson(),
        'start_date': startDate,
        'end_date': endDate,
        if (actualStartDate != null) 'actual_start_date': actualStartDate,
        if (actualEndDate != null) 'actual_end_date': actualEndDate,
        'status': status,
        'priority': priority,
        'description': description,
        'budget_amount': budgetAmount,
        'spent_amount': spentAmount,
        'progress_percent': progressPercent,
        'is_active': isActive,
        if (attachmentsCount != null) 'attachments_count': attachmentsCount,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        nameEn,
        company,
        branch,
        departmentId,
        manager,
        startDate,
        endDate,
        actualStartDate,
        actualEndDate,
        status,
        priority,
        description,
        budgetAmount,
        spentAmount,
        progressPercent,
        isActive,
        tasksSummary,
        attachmentsCount,
        createdAt,
        updatedAt,
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

/// A task within a project. Maps the same shape as `/admin/tasks`.
///
/// Real fields (captured 2026-04-29):
/// `id, code, title, description, type, status, priority, assignee, reporter,
///  start_date, due_date, closed_at, estimate_minutes, actual_minutes,
///  progress_percent, is_billable, is_urgent, is_completed`.
class ProjectTask extends Equatable {
  final int id;
  final String? code;
  final String title;
  final String? description;
  final String? type;
  final TaskAssignee? assignedTo;
  final TaskAssignee? reporter;
  final String? startDate;
  final String? dueDate;
  final String? closedAt;
  /// Lowercase normalized status (`pending`, `in_progress`, `completed`,
  /// `cancelled`, `overdue`).
  final String status;
  final String rawStatus; // original (TODO / IN_PROGRESS / DONE / HOLD / ...)
  final String priority;
  final int? estimateMinutes;
  final int? actualMinutes;
  final int progressPercent;
  final bool isCompleted;
  final bool isUrgent;

  const ProjectTask({
    required this.id,
    this.code,
    required this.title,
    this.description,
    this.type,
    this.assignedTo,
    this.reporter,
    this.startDate,
    this.dueDate,
    this.closedAt,
    required this.status,
    required this.rawStatus,
    required this.priority,
    this.estimateMinutes,
    this.actualMinutes,
    this.progressPercent = 0,
    this.isCompleted = false,
    this.isUrgent = false,
  });

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    final raw = (json['status'] ?? 'pending').toString();
    final lc = raw.toLowerCase();
    final normalized = switch (lc) {
      'todo' => 'pending',
      'done' => 'completed',
      'hold' => 'pending',
      _ => lc,
    };
    // Assignee may come from `assignee` (real API) OR `assigned_to` (legacy).
    final rawAssignee = json['assignee'] ?? json['assigned_to'];
    return ProjectTask(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code'] as String?,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      type: json['type'] as String?,
      assignedTo: rawAssignee is Map<String, dynamic>
          ? TaskAssignee.fromJson(rawAssignee)
          : null,
      reporter: json['reporter'] is Map<String, dynamic>
          ? TaskAssignee.fromJson(json['reporter'] as Map<String, dynamic>)
          : null,
      startDate: json['start_date'] as String?,
      dueDate: json['due_date'] as String?,
      closedAt: json['closed_at'] as String?,
      status: normalized,
      rawStatus: raw,
      priority: (json['priority'] ?? 'MEDIUM').toString().toLowerCase(),
      estimateMinutes: (json['estimate_minutes'] as num?)?.toInt(),
      actualMinutes: (json['actual_minutes'] as num?)?.toInt(),
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
      isCompleted: (json['is_completed'] ?? false) as bool,
      isUrgent: (json['is_urgent'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (code != null) 'code': code,
        'title': title,
        if (description != null) 'description': description,
        if (type != null) 'type': type,
        if (assignedTo != null) 'assignee': assignedTo!.toJson(),
        if (reporter != null) 'reporter': reporter!.toJson(),
        if (startDate != null) 'start_date': startDate,
        if (dueDate != null) 'due_date': dueDate,
        if (closedAt != null) 'closed_at': closedAt,
        'status': rawStatus,
        'priority': priority,
        if (estimateMinutes != null) 'estimate_minutes': estimateMinutes,
        if (actualMinutes != null) 'actual_minutes': actualMinutes,
        'progress_percent': progressPercent,
        'is_completed': isCompleted,
        'is_urgent': isUrgent,
      };

  @override
  List<Object?> get props => [
        id,
        code,
        title,
        description,
        type,
        assignedTo,
        reporter,
        startDate,
        dueDate,
        closedAt,
        status,
        rawStatus,
        priority,
        estimateMinutes,
        actualMinutes,
        progressPercent,
        isCompleted,
        isUrgent,
      ];
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

/// Project analytics data — matches real `/admin/projects/{id}/analytics`
/// response shape: `{ project: {...}, tasks: {...} }`.
class ProjectAnalytics extends Equatable {
  final Project? project;
  final AnalyticsTaskStats tasks;
  final AnalyticsMilestoneStats milestones;
  final AnalyticsBudget budget;
  final AnalyticsTimeline timeline;

  const ProjectAnalytics({
    this.project,
    required this.tasks,
    required this.milestones,
    required this.budget,
    required this.timeline,
  });

  /// Convenience: derive overall progress from the embedded project.
  double get progress => project?.progressPercent ?? 0.0;

  factory ProjectAnalytics.fromJson(Map<String, dynamic> json) {
    final p = json['project'] is Map<String, dynamic>
        ? Project.fromJson(json['project'] as Map<String, dynamic>)
        : null;

    // Budget can be derived from the embedded project when the analytics
    // endpoint omits it (current backend behaviour).
    final budgetJson = json['budget'];
    final allocated = budgetJson is Map<String, dynamic>
        ? ((budgetJson['allocated'] as num?)?.toDouble() ?? 0)
        : (p?.budgetAmount ?? 0);
    final spent = budgetJson is Map<String, dynamic>
        ? ((budgetJson['spent'] as num?)?.toDouble() ?? 0)
        : (p?.spentAmount ?? 0);
    final remaining = budgetJson is Map<String, dynamic>
        ? ((budgetJson['remaining'] as num?)?.toDouble() ??
            (allocated - spent))
        : (allocated - spent);

    final timelineJson = json['timeline'];
    final timeline = timelineJson is Map<String, dynamic>
        ? AnalyticsTimeline.fromJson(timelineJson)
        : AnalyticsTimeline(
            startDate: p?.startDate,
            endDate: p?.endDate,
            daysRemaining: 0,
            isOnTrack: !(p?.isDelayed ?? false),
          );

    return ProjectAnalytics(
      project: p,
      tasks: AnalyticsTaskStats.fromJson(
          (json['tasks'] ?? <String, dynamic>{}) as Map<String, dynamic>),
      milestones: AnalyticsMilestoneStats.fromJson(
          (json['milestones'] ?? <String, dynamic>{}) as Map<String, dynamic>),
      budget: AnalyticsBudget(
        allocated: allocated,
        spent: spent,
        remaining: remaining,
      ),
      timeline: timeline,
    );
  }

  Map<String, dynamic> toJson() => {
        if (project != null) 'project': project!.toJson(),
        'tasks': tasks.toJson(),
        'milestones': milestones.toJson(),
        'budget': budget.toJson(),
        'timeline': timeline.toJson(),
      };

  @override
  List<Object?> get props =>
      [project, tasks, milestones, budget, timeline];
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
