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
import 'core_providers.dart';

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
// Tasks
// ═══════════════════════════════════════════════════════════════════════════

final tasksStatusFilter = StateProvider.autoDispose<String?>((_) => null);
final tasksPriorityFilter = StateProvider.autoDispose<String?>((_) => null);

final tasksProvider = FutureProvider.autoDispose<AdminTasksData>((ref) {
  final status = ref.watch(tasksStatusFilter);
  final priority = ref.watch(tasksPriorityFilter);
  return ref.watch(taskRepositoryProvider).getTasks(
    status: status,
    priority: priority,
    perPage: 50,
  );
});

final taskDetailProvider =
    FutureProvider.autoDispose.family<AdminTaskItem, int>((ref, id) {
  return ref.watch(taskRepositoryProvider).getTaskDetail(id);
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
// Requests (Manager)
// ═══════════════════════════════════════════════════════════════════════════

final managerRequestsStatusFilter = StateProvider.autoDispose<String?>((_) => null);

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
