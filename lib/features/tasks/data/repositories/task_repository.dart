import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/task_models.dart';

/// Repository handling admin task operations.
///
/// Endpoints covered (Postman 06):
/// - GET    /admin/tasks
/// - POST   /admin/tasks
/// - GET    /admin/tasks/{id}
/// - PUT    /admin/tasks/{id}
/// - DELETE /admin/tasks/{id}
/// - GET/POST/PUT/DELETE /admin/tasks/{id}/time-logs[/{id}]
/// - GET/POST/PUT/DELETE /admin/tasks/{id}/comments[/{id}]
/// - GET/POST/PUT/DELETE /admin/tasks/{id}/attachments[/{id}]
class TaskRepository {
  final ApiClient _client;

  TaskRepository({required ApiClient client}) : _client = client;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tasks (CRUD)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch paginated list of tasks with optional filters.
  ///
  /// All filters are optional. The legacy params `assignedTo`, `departmentId`
  /// are kept for backwards compatibility with existing screens.
  Future<AdminTasksData> getTasks({
    int? companyId,
    int? branchId,
    int? projectId,
    int? employeeId,
    int? assigneeEmployeeId,
    String? status,
    String? priority,
    String? type,
    String? dueFrom,
    String? dueTo,
    String? search,
    int? perPage,
    int? page,
    // Legacy aliases (older screens)
    int? departmentId,
    int? assignedTo,
  }) async {
    final response = await _client.get<AdminTasksData>(
      ApiConstants.adminTasks,
      fromJson: (json) =>
          AdminTasksData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'company_id': ?companyId,
        'branch_id': ?branchId,
        'project_id': ?projectId,
        'employee_id': ?employeeId,
        'assignee_employee_id': ?(assigneeEmployeeId ?? assignedTo),
        'status': ?status,
        'priority': ?priority,
        'type': ?type,
        'due_from': ?dueFrom,
        'due_to': ?dueTo,
        'department_id': ?departmentId,
        'search': ?search,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
    return response.data!;
  }

  /// Fetch a single task by its ID.
  Future<AdminTaskItem> getTaskDetail(int id) async {
    final response = await _client.get<AdminTaskItem>(
      ApiConstants.adminTaskDetail(id),
      fromJson: (json) =>
          AdminTaskItem.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Create a new task using the new Postman 06 schema.
  Future<AdminTaskItem> createTask({
    required int projectId,
    required String title,
    required int assigneeEmployeeId,
    required int reporterEmployeeId,
    required String dueDate,
    String? startDate,
    String? description,
    String? type,
    String? status,
    String? priority,
    int? estimateMinutes,
    int? progressPercent,
    bool? isBillable,
    bool? isUrgent,
  }) async {
    final response = await _client.post<AdminTaskItem>(
      ApiConstants.adminTasks,
      fromJson: (json) =>
          AdminTaskItem.fromJson(json as Map<String, dynamic>),
      data: {
        'project_id': projectId,
        'title': title,
        'description': ?description,
        'type': type ?? 'task',
        'status': status ?? 'TODO',
        'priority': priority ?? 'MEDIUM',
        'assignee_employee_id': assigneeEmployeeId,
        'reporter_employee_id': reporterEmployeeId,
        'start_date': ?startDate,
        'due_date': dueDate,
        'estimate_minutes': ?estimateMinutes,
        'progress_percent': progressPercent ?? 0,
        'is_billable': isBillable ?? false,
        'is_urgent': isUrgent ?? false,
      },
    );
    return response.data!;
  }

  /// Update an existing task. Uses the new Postman 06 schema.
  ///
  /// Backwards-compatible aliases (`assignedTo`, `departmentId`, `notes`) are
  /// accepted for legacy callers; pass any subset of fields you want to
  /// update.
  Future<AdminTaskItem> updateTask(
    int id, {
    String? title,
    String? description,
    String? status,
    String? priority,
    String? type,
    int? assigneeEmployeeId,
    int? reporterEmployeeId,
    String? startDate,
    String? dueDate,
    int? estimateMinutes,
    int? actualMinutes,
    int? progressPercent,
    bool? isBillable,
    bool? isUrgent,
    // Legacy
    int? assignedTo,
    int? departmentId,
    String? notes,
  }) async {
    final response = await _client.put<AdminTaskItem>(
      ApiConstants.adminTaskDetail(id),
      fromJson: (json) =>
          AdminTaskItem.fromJson(json as Map<String, dynamic>),
      data: {
        'title': ?title,
        'description': ?(description ?? notes),
        'status': ?status,
        'priority': ?priority,
        'type': ?type,
        'assignee_employee_id': ?(assigneeEmployeeId ?? assignedTo),
        'reporter_employee_id': ?reporterEmployeeId,
        'start_date': ?startDate,
        'due_date': ?dueDate,
        'estimate_minutes': ?estimateMinutes,
        'actual_minutes': ?actualMinutes,
        'progress_percent': ?progressPercent,
        'is_billable': ?isBillable,
        'is_urgent': ?isUrgent,
        'department_id': ?departmentId,
      },
    );
    return response.data!;
  }

  /// Delete a task.
  Future<void> deleteTask(int id) async {
    await _client.delete<void>(
      ApiConstants.adminTaskDetail(id),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Time Logs
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<TaskTimeLog>> getTaskTimeLogs(int taskId) async {
    final response = await _client.get<List<TaskTimeLog>>(
      ApiConstants.adminTaskTimeLogs(taskId),
      fromJson: (json) {
        final list = (json is Map<String, dynamic>)
            ? (json['time_logs'] ?? json['items'] ?? json['data'] ?? const [])
            : json;
        return (list as List<dynamic>)
            .map((e) => TaskTimeLog.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data ?? const [];
  }

  Future<TaskTimeLog> createTaskTimeLog(
    int taskId, {
    required int employeeId,
    required String logDate,
    String? startTime,
    String? endTime,
    required double hoursSpent,
    String? description,
    bool isBillable = false,
  }) async {
    final response = await _client.post<TaskTimeLog>(
      ApiConstants.adminTaskTimeLogs(taskId),
      fromJson: (json) =>
          TaskTimeLog.fromJson(json as Map<String, dynamic>),
      data: {
        'employee_id': employeeId,
        'log_date': logDate,
        'start_time': ?startTime,
        'end_time': ?endTime,
        'hours_spent': hoursSpent,
        'description': ?description,
        'is_billable': isBillable,
      },
    );
    return response.data!;
  }

  Future<TaskTimeLog> updateTaskTimeLog(
    int taskId,
    int timeLogId, {
    double? hoursSpent,
    String? startTime,
    String? endTime,
    String? description,
    bool? isBillable,
  }) async {
    final response = await _client.put<TaskTimeLog>(
      ApiConstants.adminTaskTimeLogDetail(taskId, timeLogId),
      fromJson: (json) =>
          TaskTimeLog.fromJson(json as Map<String, dynamic>),
      data: {
        'hours_spent': ?hoursSpent,
        'start_time': ?startTime,
        'end_time': ?endTime,
        'description': ?description,
        'is_billable': ?isBillable,
      },
    );
    return response.data!;
  }

  Future<void> deleteTaskTimeLog(int taskId, int timeLogId) async {
    await _client.delete<void>(
      ApiConstants.adminTaskTimeLogDetail(taskId, timeLogId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Comments
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<TaskComment>> getTaskComments(int taskId) async {
    final response = await _client.get<List<TaskComment>>(
      ApiConstants.adminTaskComments(taskId),
      fromJson: (json) {
        final list = (json is Map<String, dynamic>)
            ? (json['comments'] ?? json['items'] ?? json['data'] ?? const [])
            : json;
        return (list as List<dynamic>)
            .map((e) => TaskComment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data ?? const [];
  }

  Future<TaskComment> createTaskComment(
    int taskId, {
    required String body,
    int? employeeId,
    int? parentCommentId,
  }) async {
    final response = await _client.post<TaskComment>(
      ApiConstants.adminTaskComments(taskId),
      fromJson: (json) =>
          TaskComment.fromJson(json as Map<String, dynamic>),
      data: {
        'body': body,
        'employee_id': ?employeeId,
        'parent_comment_id': ?parentCommentId,
      },
    );
    return response.data!;
  }

  Future<TaskComment> updateTaskComment(
    int taskId,
    int commentId, {
    required String body,
  }) async {
    final response = await _client.put<TaskComment>(
      ApiConstants.adminTaskCommentDetail(taskId, commentId),
      fromJson: (json) =>
          TaskComment.fromJson(json as Map<String, dynamic>),
      data: {'body': body},
    );
    return response.data!;
  }

  Future<void> deleteTaskComment(int taskId, int commentId) async {
    await _client.delete<void>(
      ApiConstants.adminTaskCommentDetail(taskId, commentId),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Attachments
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<TaskAttachment>> getTaskAttachments(int taskId) async {
    final response = await _client.get<List<TaskAttachment>>(
      ApiConstants.adminTaskAttachments(taskId),
      fromJson: (json) {
        final list = (json is Map<String, dynamic>)
            ? (json['attachments'] ?? json['items'] ?? json['data'] ?? const [])
            : json;
        return (list as List<dynamic>)
            .map((e) => TaskAttachment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data ?? const [];
  }

  Future<TaskAttachment> updateTaskAttachment(
    int taskId,
    int attachmentId, {
    String? notes,
  }) async {
    final response = await _client.put<TaskAttachment>(
      ApiConstants.adminTaskAttachmentDetail(taskId, attachmentId),
      fromJson: (json) =>
          TaskAttachment.fromJson(json as Map<String, dynamic>),
      data: {
        'notes': ?notes,
      },
    );
    return response.data!;
  }

  Future<void> deleteTaskAttachment(int taskId, int attachmentId) async {
    await _client.delete<void>(
      ApiConstants.adminTaskAttachmentDetail(taskId, attachmentId),
    );
  }

  // Note: Upload endpoint requires multipart/form-data. The existing ApiClient
  // does not yet expose a multipart helper, so we leave the upload to be
  // wired when an attachment-upload UI is introduced.
}
