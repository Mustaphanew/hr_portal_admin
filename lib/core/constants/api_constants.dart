import 'package:hr_portal_admin/core/config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static late String baseUrl;

  static void configure(AppConfig config) {
    baseUrl = config.baseUrl;
  }

  static const String contractVersion = '1.0.0';
  static const String versionHeader = 'X-API-Version';
  static const String traceIdHeader = 'X-Trace-Id';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 10000;

  // ── A. Auth ──────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String changePassword = '/change-password';

  // ── B. Profile ───────────────────────────────────────────────
  static const String profile = '/profile';

  // ── C. Leaves (Employee) ─────────────────────────────────────
  static const String leaves = '/leaves';
  static String leaveDetail(int id) => '/leaves/$id';

  // ── D. Requests (Employee) ───────────────────────────────────
  static const String requests = '/requests';
  static String requestDetail(int id) => '/requests/$id';

  // ── E. Manager Requests ──────────────────────────────────────
  static const String managerRequests = '/manager/requests';
  static String managerRequestDetail(int id) => '/manager/requests/$id';
  static String managerRequestDecide(int id) => '/manager/requests/$id/decide';

  // ── F. Manager Leaves ────────────────────────────────────────
  static const String managerLeaves = '/manager/leaves';
  static String managerLeaveDetail(int id) => '/manager/leaves/$id';
  static String managerLeaveDecide(int id) => '/manager/leaves/$id/decide';

  // ── G. Attendance (Employee) ─────────────────────────────────
  static const String attendanceHistory = '/attendance/history';

  // ── H. Payroll ───────────────────────────────────────────────
  static const String payroll = '/payroll';
  static String payslipDetail(String month) => '/payroll/$month';

  // ── I. Notifications ─────────────────────────────────────────
  static const String notificationsSend = '/notifications/send';
  static const String notificationsSendToUser = '/notifications/send-to-user';

  // ── J0. Branches (Admin) ─────────────────────────────────────
  static const String adminBranches = '/admin/branches';

  // ── J. Dashboard (Admin) ─────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';

  // ── K. Employees (Admin) ─────────────────────────────────────
  static const String adminEmployees = '/admin/employees';
  static String adminEmployeeDetail(int id) => '/admin/employees/$id';

  // ── L. Departments (Admin) ───────────────────────────────────
  static const String adminDepartments = '/admin/departments';
  static String adminDepartmentDetail(int id) => '/admin/departments/$id';

  // ── M. Attendance (Admin) ────────────────────────────────────
  static const String adminAttendance = '/admin/attendance';
  static String adminAttendanceEmployee(int id) => '/admin/attendance/$id';

  // ── N. Announcements (Admin) ─────────────────────────────────
  static const String adminAnnouncements = '/admin/announcements';
  static String adminAnnouncementDetail(int id) => '/admin/announcements/$id';
  static String adminAnnouncementPublish(int id) => '/admin/announcements/$id/publish';

  // ── O. Projects (Admin) ──────────────────────────────────────
  static const String adminProjects = '/admin/projects';
  static String adminProjectDetail(int id) => '/admin/projects/$id';
  static String adminProjectTasks(int id) => '/admin/projects/$id/tasks';
  static String adminProjectMilestones(int id) => '/admin/projects/$id/milestones';
  static String adminProjectAnalytics(int id) => '/admin/projects/$id/analytics';

  // ── P. Expenses (Admin) ──────────────────────────────────────
  static const String adminExpenses = '/admin/expenses';
  static String adminExpenseDetail(int id) => '/admin/expenses/$id';
  static String adminExpenseApprove(int id) => '/admin/expenses/$id/approve';
  static String adminExpenseReject(int id) => '/admin/expenses/$id/reject';

  // ── Q. Reports (Admin) ───────────────────────────────────────
  static const String adminReportsKpis = '/admin/reports/kpis';
  static const String adminReportsAttendanceTrend = '/admin/reports/attendance-trend';
  static const String adminReportsLeaveAnalysis = '/admin/reports/leave-analysis';
  static const String adminReportsTaskCompletion = '/admin/reports/task-completion';

  // ── R. Tasks (Admin) ───────────────────────────────────────
  static const String adminTasks = '/admin/tasks';
  static String adminTaskDetail(int id) => '/admin/tasks/$id';

  // ── S. Follow-ups (Admin) ──────────────────────────────────
  static const String adminFollowUps = '/admin/follow-ups';
  static String adminFollowUpDetail(int id) => '/admin/follow-ups/$id';
  static String adminFollowUpEscalate(int id) => '/admin/follow-ups/$id/escalate';

  // ── T. Documents (Admin) ───────────────────────────────────
  static const String adminDocuments = '/admin/documents';
  static const String adminDocumentCategories = '/admin/documents/categories';
  static String adminDocumentDetail(int id) => '/admin/documents/$id';
}
