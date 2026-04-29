import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/admin_dashboard/data/models/dashboard_models.dart';
import '../../features/announcements/data/models/announcement_models.dart';
import '../../features/attendance_management/data/models/attendance_models.dart';
import '../../features/attendance_management/data/models/leave_models.dart';
import '../../features/departments/data/models/department_models.dart';
import '../../features/documents/data/models/document_models.dart';
import '../../features/employees/data/models/employee_models.dart';
import '../../features/expenses/data/models/expense_models.dart';
import '../../features/follow_up/data/models/follow_up_models.dart';
import '../../features/projects/data/models/project_models.dart';
import '../../features/reports/data/models/report_models.dart';
import '../../features/requests_management/data/models/request_models.dart';
import '../../features/tasks/data/models/task_models.dart';
import '../../features/auth/data/models/auth_models.dart';
import '../../features/admin_dashboard/data/models/branch_models.dart';
import 'core_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Profile (from server)
// ═══════════════════════════════════════════════════════════════════════════

final adminProfileProvider = FutureProvider.autoDispose<EmployeeProfile>((ref) {
  return ref.watch(authRepositoryProvider).getProfile();
});

// ═══════════════════════════════════════════════════════════════════════════
// Companies & Branches (Admin scope — Postman 00)
// ═══════════════════════════════════════════════════════════════════════════

/// Companies the current admin is allowed to operate on (`/admin/companies`).
final companiesProvider = FutureProvider.autoDispose<CompaniesData>((ref) {
  return ref.watch(dashboardRepositoryProvider).getCompanies();
});

/// All branches the current admin is allowed to operate on
/// (no filter applied). Most screens should prefer [branchesByCompanyProvider]
/// to scope by the currently selected company.
final branchesProvider = FutureProvider.autoDispose<BranchesData>((ref) {
  return ref.watch(dashboardRepositoryProvider).getBranches();
});

/// Branches scoped to a specific company id. Pass `null` to fetch every branch.
final branchesByCompanyProvider = FutureProvider.autoDispose
    .family<BranchesData, int?>((ref, companyId) {
  return ref
      .watch(dashboardRepositoryProvider)
      .getBranches(companyId: companyId);
});

/// Selected company/branch for this session. Default = all.
final selectedBranchProvider =
    StateProvider<BranchSelection>((ref) => const BranchSelection());

// ═══════════════════════════════════════════════════════════════════════════
// Dashboard
// ═══════════════════════════════════════════════════════════════════════════

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) {
  return ref.watch(dashboardRepositoryProvider).getDashboard();
});

// ═══════════════════════════════════════════════════════════════════════════
// Employees
// ═══════════════════════════════════════════════════════════════════════════

final employeesSearchProvider = StateProvider.autoDispose<String>((_) => '');
final employeesStatusProvider = StateProvider.autoDispose<String?>((_) => null);

final employeesProvider = FutureProvider.autoDispose<AdminEmployeesData>((ref) {
  final search = ref.watch(employeesSearchProvider);
  final status = ref.watch(employeesStatusProvider);
  return ref.watch(employeeRepositoryProvider).getEmployees(
    search: search.isEmpty ? null : search,
    attendanceStatus: status,
    perPage: 50,
  );
});

final employeeDetailProvider =
    FutureProvider.autoDispose.family<EmployeeDetail, int>((ref, id) {
  return ref.watch(employeeRepositoryProvider).getEmployeeDetail(id);
});

// ═══════════════════════════════════════════════════════════════════════════
// Departments
// ═══════════════════════════════════════════════════════════════════════════

final departmentsProvider = FutureProvider.autoDispose<DepartmentsData>((ref) {
  return ref.watch(departmentRepositoryProvider).getDepartments();
});

final departmentDetailProvider =
    FutureProvider.autoDispose.family<DepartmentDetail, int>((ref, id) {
  return ref.watch(departmentRepositoryProvider).getDepartmentDetail(id);
});

// ═══════════════════════════════════════════════════════════════════════════
// Attendance (Admin)
// ═══════════════════════════════════════════════════════════════════════════

final adminAttendanceDateProvider = StateProvider.autoDispose<String>((_) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
});

final adminAttendanceProvider =
    FutureProvider.autoDispose<AdminAttendanceData>((ref) {
  final date = ref.watch(adminAttendanceDateProvider);
  return ref.watch(attendanceRepositoryProvider).getAdminAttendance(date: date);
});

final employeeAttendanceProvider =
    FutureProvider.autoDispose.family<EmployeeAttendanceData, int>((ref, id) {
  return ref.watch(attendanceRepositoryProvider).getEmployeeAttendance(id);
});

// ═══════════════════════════════════════════════════════════════════════════
// Tasks (Postman 06: /admin/tasks)
// ═══════════════════════════════════════════════════════════════════════════

/// All filters supported by `/admin/tasks` (Postman 06).
class TasksFilters {
  final String? status; // TODO / IN_PROGRESS / DONE / etc.
  final String? priority; // LOW / MEDIUM / HIGH / URGENT
  final String? type;
  final int? projectId;
  final int? assigneeEmployeeId;
  final String? dueFrom; // yyyy-MM-dd
  final String? dueTo; // yyyy-MM-dd
  final String? search;

  const TasksFilters({
    this.status,
    this.priority,
    this.type,
    this.projectId,
    this.assigneeEmployeeId,
    this.dueFrom,
    this.dueTo,
    this.search,
  });

  TasksFilters copyWith({
    Object? status = _sentinel,
    Object? priority = _sentinel,
    Object? type = _sentinel,
    Object? projectId = _sentinel,
    Object? assigneeEmployeeId = _sentinel,
    Object? dueFrom = _sentinel,
    Object? dueTo = _sentinel,
    Object? search = _sentinel,
  }) {
    return TasksFilters(
      status: identical(status, _sentinel) ? this.status : status as String?,
      priority: identical(priority, _sentinel)
          ? this.priority
          : priority as String?,
      type: identical(type, _sentinel) ? this.type : type as String?,
      projectId:
          identical(projectId, _sentinel) ? this.projectId : projectId as int?,
      assigneeEmployeeId: identical(assigneeEmployeeId, _sentinel)
          ? this.assigneeEmployeeId
          : assigneeEmployeeId as int?,
      dueFrom:
          identical(dueFrom, _sentinel) ? this.dueFrom : dueFrom as String?,
      dueTo: identical(dueTo, _sentinel) ? this.dueTo : dueTo as String?,
      search:
          identical(search, _sentinel) ? this.search : search as String?,
    );
  }

  bool get hasAnyAdvanced =>
      priority != null ||
      type != null ||
      projectId != null ||
      assigneeEmployeeId != null ||
      dueFrom != null ||
      dueTo != null ||
      (search?.isNotEmpty ?? false);

  static const _sentinel = Object();
}

/// Aggregated state for the tasks screen (status + advanced filters).
final tasksFiltersProvider =
    StateProvider.autoDispose<TasksFilters>((_) => const TasksFilters());

/// Backwards-compatible legacy filters. The paginated provider now reads from
/// [tasksFiltersProvider] first.
final tasksStatusFilter = StateProvider.autoDispose<String?>((_) => null);
final tasksPriorityFilter = StateProvider.autoDispose<String?>((_) => null);

final tasksProvider = FutureProvider.autoDispose<AdminTasksData>((ref) {
  final f = ref.watch(tasksFiltersProvider);
  final sel = ref.watch(selectedBranchProvider);
  return ref.watch(taskRepositoryProvider).getTasks(
        companyId: sel.companyId,
        branchId: sel.branchId,
        status: f.status,
        priority: f.priority,
        type: f.type,
        projectId: f.projectId,
        assigneeEmployeeId: f.assigneeEmployeeId,
        dueFrom: f.dueFrom,
        dueTo: f.dueTo,
        search: (f.search?.isEmpty ?? true) ? null : f.search,
        perPage: 50,
      );
});

final taskDetailProvider =
    FutureProvider.autoDispose.family<AdminTaskItem, int>((ref, id) {
  return ref.watch(taskRepositoryProvider).getTaskDetail(id);
});

// ── Task sub-resources (Postman 06: time-logs / comments / attachments) ──

final taskTimeLogsProvider = FutureProvider.autoDispose
    .family<List<TaskTimeLog>, int>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).getTaskTimeLogs(taskId);
});

final taskCommentsProvider = FutureProvider.autoDispose
    .family<List<TaskComment>, int>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).getTaskComments(taskId);
});

final taskAttachmentsProvider = FutureProvider.autoDispose
    .family<List<TaskAttachment>, int>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).getTaskAttachments(taskId);
});

// ═══════════════════════════════════════════════════════════════════════════
// Follow-ups
// ═══════════════════════════════════════════════════════════════════════════

final followUpsStatusFilter = StateProvider.autoDispose<String?>((_) => null);
final followUpsTypeFilter = StateProvider.autoDispose<String?>((_) => null);

final followUpsProvider = FutureProvider.autoDispose<FollowUpsData>((ref) {
  final status = ref.watch(followUpsStatusFilter);
  final type = ref.watch(followUpsTypeFilter);
  return ref.watch(followUpRepositoryProvider).getFollowUps(
    status: status,
    type: type,
    perPage: 50,
  );
});

final followUpDetailProvider =
    FutureProvider.autoDispose.family<FollowUpDetail, int>((ref, id) {
  return ref.watch(followUpRepositoryProvider).getFollowUpDetail(id);
});

// ═══════════════════════════════════════════════════════════════════════════
// Announcements
// ═══════════════════════════════════════════════════════════════════════════

final announcementsStatusFilter = StateProvider.autoDispose<String?>((_) => null);

final announcementsProvider =
    FutureProvider.autoDispose<AnnouncementsData>((ref) {
  final status = ref.watch(announcementsStatusFilter);
  return ref.watch(announcementRepositoryProvider).getAnnouncements(
    status: status,
    perPage: 50,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// Projects
// ═══════════════════════════════════════════════════════════════════════════

final projectsStatusFilter = StateProvider.autoDispose<String?>((_) => null);

final projectsProvider = FutureProvider.autoDispose<ProjectsData>((ref) {
  final status = ref.watch(projectsStatusFilter);
  return ref.watch(projectRepositoryProvider).getProjects(status: status);
});

final projectDetailProvider =
    FutureProvider.autoDispose.family<Project, int>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProjectDetail(id);
});

final projectTasksProvider =
    FutureProvider.autoDispose.family<List<ProjectTask>, int>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProjectTasks(id);
});

final projectMilestonesProvider =
    FutureProvider.autoDispose.family<List<ProjectMilestone>, int>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProjectMilestones(id);
});

final projectAnalyticsProvider =
    FutureProvider.autoDispose.family<ProjectAnalytics, int>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProjectAnalytics(id);
});

// ═══════════════════════════════════════════════════════════════════════════
// Expenses
// ═══════════════════════════════════════════════════════════════════════════

final expensesStatusFilter = StateProvider.autoDispose<String?>((_) => null);

final expensesProvider = FutureProvider.autoDispose<ExpensesData>((ref) {
  final status = ref.watch(expensesStatusFilter);
  return ref.watch(expenseRepositoryProvider).getExpenses(status: status);
});

final expenseDetailProvider =
    FutureProvider.autoDispose.family<Expense, int>((ref, id) {
  return ref.watch(expenseRepositoryProvider).getExpenseDetail(id);
});

// ═══════════════════════════════════════════════════════════════════════════
// Reports
// ═══════════════════════════════════════════════════════════════════════════

final reportsKpisProvider = FutureProvider.autoDispose<List<KpiItem>>((ref) {
  return ref.watch(reportRepositoryProvider).getKpis();
});

final attendanceTrendProvider =
    FutureProvider.autoDispose<List<AttendanceTrendMonth>>((ref) {
  return ref.watch(reportRepositoryProvider).getAttendanceTrend();
});

final leaveAnalysisProvider =
    FutureProvider.autoDispose<LeaveAnalysisData>((ref) {
  return ref.watch(reportRepositoryProvider).getLeaveAnalysis();
});

final taskCompletionProvider =
    FutureProvider.autoDispose<List<TaskCompletionDept>>((ref) {
  return ref.watch(reportRepositoryProvider).getTaskCompletion();
});

// ═══════════════════════════════════════════════════════════════════════════
// Documents
// ═══════════════════════════════════════════════════════════════════════════

final documentCategoriesProvider =
    FutureProvider.autoDispose<DocumentCategoriesData>((ref) {
  return ref.watch(documentRepositoryProvider).getCategories();
});

final documentsCategoryFilter = StateProvider.autoDispose<String?>((_) => null);

final documentsProvider =
    FutureProvider.autoDispose<AdminDocumentsData>((ref) {
  final category = ref.watch(documentsCategoryFilter);
  return ref.watch(documentRepositoryProvider).getDocuments(
    category: category,
    perPage: 50,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// Manager Leaves
// ═══════════════════════════════════════════════════════════════════════════

final managerLeavesStatusFilter = StateProvider.autoDispose<String?>((_) => null);

final managerLeavesProvider = FutureProvider.autoDispose<ManagerLeavesData>((ref) async {
  final status = ref.watch(managerLeavesStatusFilter);
  final response = await ref.watch(leaveRepositoryProvider).getManagerLeaves(
    status: status,
    perPage: 50,
  );
  return response.data!;
});

final managerLeaveDetailProvider = FutureProvider.autoDispose.family<LeaveRequest, int>((ref, id) async {
  final response = await ref.watch(leaveRepositoryProvider).getManagerLeaveDetail(id);
  return response.data!;
});

// ═══════════════════════════════════════════════════════════════════════════
// Requests (Admin / Manager) — Postman 01: /admin/employee-requests
// ═══════════════════════════════════════════════════════════════════════════

/// All filters supported by `/admin/employee-requests` (Postman 01).
class EmployeeRequestsFilters {
  final String? status;
  final String? requestType;
  final int? requestTypeId;
  final int? departmentId;
  final int? employeeId;
  final String? dateFrom; // yyyy-MM-dd
  final String? dateTo; // yyyy-MM-dd
  final double? amountMin;
  final double? amountMax;
  final String? search;

  const EmployeeRequestsFilters({
    this.status,
    this.requestType,
    this.requestTypeId,
    this.departmentId,
    this.employeeId,
    this.dateFrom,
    this.dateTo,
    this.amountMin,
    this.amountMax,
    this.search,
  });

  EmployeeRequestsFilters copyWith({
    Object? status = _sentinel,
    Object? requestType = _sentinel,
    Object? requestTypeId = _sentinel,
    Object? departmentId = _sentinel,
    Object? employeeId = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    Object? amountMin = _sentinel,
    Object? amountMax = _sentinel,
    Object? search = _sentinel,
  }) {
    return EmployeeRequestsFilters(
      status: identical(status, _sentinel) ? this.status : status as String?,
      requestType: identical(requestType, _sentinel)
          ? this.requestType
          : requestType as String?,
      requestTypeId: identical(requestTypeId, _sentinel)
          ? this.requestTypeId
          : requestTypeId as int?,
      departmentId: identical(departmentId, _sentinel)
          ? this.departmentId
          : departmentId as int?,
      employeeId: identical(employeeId, _sentinel)
          ? this.employeeId
          : employeeId as int?,
      dateFrom: identical(dateFrom, _sentinel)
          ? this.dateFrom
          : dateFrom as String?,
      dateTo:
          identical(dateTo, _sentinel) ? this.dateTo : dateTo as String?,
      amountMin: identical(amountMin, _sentinel)
          ? this.amountMin
          : amountMin as double?,
      amountMax: identical(amountMax, _sentinel)
          ? this.amountMax
          : amountMax as double?,
      search:
          identical(search, _sentinel) ? this.search : search as String?,
    );
  }

  bool get hasAnyAdvanced =>
      requestType != null ||
      requestTypeId != null ||
      departmentId != null ||
      employeeId != null ||
      dateFrom != null ||
      dateTo != null ||
      amountMin != null ||
      amountMax != null ||
      (search?.isNotEmpty ?? false);

  static const _sentinel = Object();
}

/// Backwards-compatible: kept so existing UI keeps compiling. Mirrors the
/// `status` field from [employeeRequestsFiltersProvider].
final managerRequestsStatusFilter =
    StateProvider.autoDispose<String?>((_) => null);

/// Aggregated state for the employee-requests screen.
final employeeRequestsFiltersProvider = StateProvider.autoDispose<
    EmployeeRequestsFilters>((_) => const EmployeeRequestsFilters());

/// Summary KPIs (`/admin/employee-requests/summary`).
final employeeRequestsSummaryProvider =
    FutureProvider.autoDispose<EmployeeRequestsSummary>((ref) async {
  final f = ref.watch(employeeRequestsFiltersProvider);
  final sel = ref.watch(selectedBranchProvider);
  final response = await ref
      .watch(requestRepositoryProvider)
      .getAdminEmployeeRequestsSummary(
        companyId: sel.companyId,
        branchId: sel.branchId,
        dateFrom: f.dateFrom,
        dateTo: f.dateTo,
      );
  return response.data!;
});

final managerRequestsProvider =
    FutureProvider.autoDispose<RequestsListData>((ref) async {
  final status = ref.watch(managerRequestsStatusFilter);
  final response = await ref.watch(requestRepositoryProvider).getManagerRequests(
    status: status,
    perPage: 50,
  );
  return response.data!;
});

final managerRequestDetailProvider =
    FutureProvider.autoDispose.family<EmployeeRequest, int>((ref, id) async {
  final response = await ref.watch(requestRepositoryProvider).getManagerRequestDetail(id);
  return response.data!;
});
