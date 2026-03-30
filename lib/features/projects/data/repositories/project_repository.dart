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
        if (status != null) 'status': status,
        if (departmentId != null) 'department_id': departmentId,
        if (perPage != null) 'per_page': perPage,
        if (page != null) 'page': page,
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
  Future<List<ProjectTask>> getProjectTasks(int id) async {
    final response = await _client.get<List<ProjectTask>>(
      ApiConstants.adminProjectTasks(id),
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => ProjectTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data!;
  }

  /// Fetch all milestones for a specific project.
  Future<List<ProjectMilestone>> getProjectMilestones(int id) async {
    final response = await _client.get<List<ProjectMilestone>>(
      ApiConstants.adminProjectMilestones(id),
      fromJson: (json) => (json as List<dynamic>)
          .map((e) =>
              ProjectMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data!;
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
