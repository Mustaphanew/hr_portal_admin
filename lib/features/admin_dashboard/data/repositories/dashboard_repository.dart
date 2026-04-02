import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_models.dart';
import '../models/branch_models.dart';

/// Repository handling admin dashboard operations.
///
/// Endpoints covered:
/// - J1: GET /admin/dashboard
class DashboardRepository {
  final ApiClient _client;

  DashboardRepository({required ApiClient client}) : _client = client;

  /// Fetch the admin dashboard data including KPIs, pending approvals,
  /// recent activity, and department summaries.
  Future<DashboardData> getDashboard() async {
    final response = await _client.get<DashboardData>(
      ApiConstants.adminDashboard,
      fromJson: (json) =>
          DashboardData.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Fetch all branches for branch selector.
  Future<BranchesData> getBranches() async {
    final response = await _client.get<BranchesData>(
      ApiConstants.adminBranches,
      fromJson: (json) => BranchesData.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }
}
