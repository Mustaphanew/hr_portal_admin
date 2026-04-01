import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/task_models.dart';

/// Repository handling admin task operations.
///
/// Endpoints covered:
/// - GET /admin/tasks
/// - GET /admin/tasks/{id}
/// - POST /admin/tasks
/// - PUT /admin/tasks/{id}
/// - DELETE /admin/tasks/{id}
class TaskRepository {
  final ApiClient _client;

  TaskRepository({required ApiClient client}) : _client = client;

  /// Fetch paginated list of tasks with optional filters.
  Future<AdminTasksData> getTasks({
    String? status,
    String? priority,
    int? departmentId,
    int? assignedTo,
    String? search,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<AdminTasksData>(
      ApiConstants.adminTasks,
      fromJson: (json) =>
          AdminTasksData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'status': ?status,
        'priority': ?priority,
        'department_id': ?departmentId,
        'assigned_to': ?assignedTo,
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

  /// Create a new task.
  Future<AdminTaskItem> createTask({
    required String title,
    required int assignedTo,
    required int departmentId,
    required String dueDate,
    required String priority,
    String? notes,
  }) async {
    final response = await _client.post<AdminTaskItem>(
      ApiConstants.adminTasks,
      fromJson: (json) =>
          AdminTaskItem.fromJson(json as Map<String, dynamic>),
      data: {
        'title': title,
        'assigned_to': assignedTo,
        'department_id': departmentId,
        'due_date': dueDate,
        'priority': priority,
        'notes': ?notes,
      },
    );
    return response.data!;
  }

  /// Update an existing task.
  Future<AdminTaskItem> updateTask(
    int id, {
    String? title,
    String? status,
    String? priority,
    String? notes,
    int? assignedTo,
    int? departmentId,
    String? dueDate,
  }) async {
    final response = await _client.put<AdminTaskItem>(
      ApiConstants.adminTaskDetail(id),
      fromJson: (json) =>
          AdminTaskItem.fromJson(json as Map<String, dynamic>),
      data: {
        'title': ?title,
        'status': ?status,
        'priority': ?priority,
        'notes': ?notes,
        'assigned_to': ?assignedTo,
        'department_id': ?departmentId,
        'due_date': ?dueDate,
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
}
