import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/report_models.dart';

/// Repository handling admin report operations.
class ReportRepository {
  final ApiClient _client;

  ReportRepository({required ApiClient client}) : _client = client;

  /// Fetch KPI items for the reports overview.
  Future<List<KpiItem>> getKpis() async {
    final response = await _client.get<List<KpiItem>>(
      ApiConstants.adminReportsKpis,
      fromJson: (json) {
        // API may return {"kpis": [...]} or [...] directly
        if (json is List) {
          return json.map((e) => KpiItem.fromJson(e as Map<String, dynamic>)).toList();
        }
        final map = json as Map<String, dynamic>;
        final list = (map['kpis'] ?? map.values.firstWhere((v) => v is List, orElse: () => [])) as List;
        return list.map((e) => KpiItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    return response.data!;
  }

  /// Fetch monthly attendance trend data.
  Future<List<AttendanceTrendMonth>> getAttendanceTrend({
    int months = 6,
  }) async {
    final response = await _client.get<List<AttendanceTrendMonth>>(
      ApiConstants.adminReportsAttendanceTrend,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => AttendanceTrendMonth.fromJson(e as Map<String, dynamic>)).toList();
        }
        final map = json as Map<String, dynamic>;
        final list = (map['months'] ?? map.values.firstWhere((v) => v is List, orElse: () => [])) as List;
        return list.map((e) => AttendanceTrendMonth.fromJson(e as Map<String, dynamic>)).toList();
      },
      queryParameters: {'months': months},
    );
    return response.data!;
  }

  /// Fetch leave analysis data, optionally filtered by year.
  Future<LeaveAnalysisData> getLeaveAnalysis({int? year}) async {
    final response = await _client.get<LeaveAnalysisData>(
      ApiConstants.adminReportsLeaveAnalysis,
      fromJson: (json) =>
          LeaveAnalysisData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        if (year != null) 'year': year,
      },
    );
    return response.data!;
  }

  /// Fetch task completion data grouped by department.
  Future<List<TaskCompletionDept>> getTaskCompletion() async {
    final response = await _client.get<List<TaskCompletionDept>>(
      ApiConstants.adminReportsTaskCompletion,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => TaskCompletionDept.fromJson(e as Map<String, dynamic>)).toList();
        }
        final map = json as Map<String, dynamic>;
        final list = (map['departments'] ?? map.values.firstWhere((v) => v is List, orElse: () => [])) as List;
        return list.map((e) => TaskCompletionDept.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    return response.data!;
  }
}
