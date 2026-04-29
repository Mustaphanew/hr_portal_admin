import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/project_models.dart';

/// Repository handling admin project operations.
///
/// Endpoints covered:
/// - O1: GET /admin/projects
/// - O2: GET /admin/projects/{id}
/// - O3: GET /admin/projects/{id}/tasks
/// - O4: GET /admin/projects/{id}/milestones
/// - O5: GET /admin/projects/{id}/analytics
class ProjectRepository {
  final ApiClient _client;

  ProjectRepository({required ApiClient client}) : _client = client;

  /// Fetch paginated list of projects with optional filters.
  Future<ProjectsData> getProjects({
    String? status,
    int? departmentId,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<ProjectsData>(
      ApiConstants.adminProjects,
      fromJson: (json) =>
          ProjectsData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'status': ?status,
        'department_id': ?departmentId,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
    return response.data!;
  }

  /// Fetch detailed information for a specific project.
  Future<Project> getProjectDetail(int id) async {
    final response = await _client.get<Project>(
      ApiConstants.adminProjectDetail(id),
      fromJson: (json) =>
          Project.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Fetch all tasks for a specific project.
  ///
  /// The real API wraps the list: `{ tasks: [...], summary: {...},
  /// pagination: {...} }`. We unwrap and return only the list here.
  Future<List<ProjectTask>> getProjectTasks(int id) async {
    final response = await _client.get<List<ProjectTask>>(
      ApiConstants.adminProjectTasks(id),
      fromJson: (json) {
        // Accept either a bare list (legacy) or the wrapped object.
        final raw = json is List
            ? json
            : (json is Map<String, dynamic>
                ? (json['tasks'] ?? json['items'] ?? json['data'] ?? const [])
                : const []);
        return (raw as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(ProjectTask.fromJson)
            .toList();
      },
    );
    return response.data!;
  }

  /// Fetch all milestones for a specific project.
  ///
  /// Real API: `{ milestones: [] }` (also returns `message: "Milestones
  /// module is not configured."` when the feature is disabled).
  Future<List<ProjectMilestone>> getProjectMilestones(int id) async {
    final response = await _client.get<List<ProjectMilestone>>(
      ApiConstants.adminProjectMilestones(id),
      fromJson: (json) {
        final raw = json is List
            ? json
            : (json is Map<String, dynamic>
                ? (json['milestones'] ?? json['items'] ?? json['data'] ?? const [])
                : const []);
        return (raw as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(ProjectMilestone.fromJson)
            .toList();
      },
    );
    return response.data ?? const <ProjectMilestone>[];
  }

  /// Fetch attachments for a project. Wraps `{ attachments: [...] }`.
  Future<List<Map<String, dynamic>>> getProjectAttachments(int id) async {
    final response = await _client.get<List<Map<String, dynamic>>>(
      ApiConstants.adminProjectAttachments(id),
      fromJson: (json) {
        final raw = json is List
            ? json
            : (json is Map<String, dynamic>
                ? (json['attachments'] ?? json['items'] ?? const [])
                : const []);
        return (raw as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .toList();
      },
    );
    return response.data ?? const [];
  }

  /// Fetch analytics data for a specific project.
  Future<ProjectAnalytics> getProjectAnalytics(int id) async {
    final response = await _client.get<ProjectAnalytics>(
      ApiConstants.adminProjectAnalytics(id),
      fromJson: (json) =>
          ProjectAnalytics.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }
}
