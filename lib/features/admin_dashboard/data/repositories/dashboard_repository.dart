import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_models.dart';
import '../models/branch_models.dart';

/// Repository handling admin dashboard, scope (companies/branches) operations.
///
/// Endpoints covered:
/// - J1: GET /admin/dashboard
/// - Postman 00: GET /admin/companies
/// - Postman 00: GET /admin/branches[?company_id={id}]
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

  /// Fetch branches the current admin is allowed to operate on.
  ///
  /// When [companyId] is provided, the result is scoped to that company.
  /// Otherwise all branches across the admin's allowed companies are returned.
  Future<BranchesData> getBranches({int? companyId}) async {
    final response = await _client.get<BranchesData>(
      ApiConstants.adminBranches,
      fromJson: (json) => BranchesData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'company_id': ?companyId,
      },
    );
    return response.data!;
  }

  /// Fetch the companies the current admin is allowed to operate on.
  ///
  /// Backed by GET /admin/companies (Postman 00).
  Future<CompaniesData> getCompanies() async {
    final response = await _client.get<CompaniesData>(
      ApiConstants.adminCompanies,
      fromJson: (json) =>
          CompaniesData.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }
}
