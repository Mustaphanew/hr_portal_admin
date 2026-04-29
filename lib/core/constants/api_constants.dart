import 'package:hr_portal_admin/core/config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  /// جذر الخادم فقط، مثال: `http://172.16.0.66:8000` — المسارات تتضمّن `/api/v1/...` أدناه.
  static late String baseUrl;

  static void configure(AppConfig config) {
    baseUrl = config.baseUrl;
  }

  /// بادئة الـ API (مثال كامل: `[baseUrl]/api/v1/auth/login`).
  static const String _v1 = '/api/v1';

  static const String contractVersion = '1.0.0';
  static const String versionHeader = 'X-API-Version';
  static const String traceIdHeader = 'X-Trace-Id';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 10000;

  // ── A. Auth ──────────────────────────────────────────────────
  static const String login = '$_v1/auth/login';
  static const String logout = '$_v1/auth/logout';
  static const String logoutAll = '$_v1/auth/logout-all';
  static const String changePassword = '$_v1/change-password';

  // ── A2. Admin Auth (Postman canonical) ──────────────────────
  static const String adminLogin = '$_v1/admin/auth/login';
  static const String adminLogout = '$_v1/admin/auth/logout';
  static const String adminLogoutAll = '$_v1/admin/auth/logout-all';
  static const String adminMe = '$_v1/admin/auth/me';
  static const String adminCompanies = '$_v1/admin/companies';

  // ── B. Profile ───────────────────────────────────────────────
  static const String profile = '$_v1/profile';

  // ── C. Leaves (Employee) ─────────────────────────────────────
  static const String leaves = '$_v1/leaves';
  static String leaveDetail(int id) => '$_v1/leaves/$id';

  // ── D. Requests (Employee) ───────────────────────────────────
  static const String requests = '$_v1/requests';
  static String requestDetail(int id) => '$_v1/requests/$id';

  // ── E. Manager Requests ──────────────────────────────────────
  static const String managerRequests = '$_v1/manager/requests';
  static String managerRequestDetail(int id) => '$_v1/manager/requests/$id';
  static String managerRequestDecide(int id) => '$_v1/manager/requests/$id/decide';

  // ── F. Manager Leaves ────────────────────────────────────────
  static const String managerLeaves = '$_v1/manager/leaves';
  static String managerLeaveDetail(int id) => '$_v1/manager/leaves/$id';
  static String managerLeaveDecide(int id) => '$_v1/manager/leaves/$id/decide';

  // ── F2. Admin Leave Requests (new) ──────────────────────────
  static const String adminLeaveRequests = '$_v1/admin/leave-requests';
  static const String adminLeaveRequestsSummary = '$_v1/admin/leave-requests/summary';
  static String adminLeaveRequestDetail(int id) => '$_v1/admin/leave-requests/$id';
  static String adminLeaveRequestDecide(int id) => '$_v1/admin/leave-requests/$id/decide';
  static String adminLeaveRequestApprove(int id) => '$_v1/admin/leave-requests/$id/approve';
  static String adminLeaveRequestReject(int id) => '$_v1/admin/leave-requests/$id/reject';

  // ── F3. Admin Employee Requests (Postman 01) ────────────────
  static const String adminEmployeeRequests = '$_v1/admin/employee-requests';
  static const String adminEmployeeRequestsSummary = '$_v1/admin/employee-requests/summary';
  static String adminEmployeeRequestDetail(int id) => '$_v1/admin/employee-requests/$id';
  static String adminEmployeeRequestDecide(int id) => '$_v1/admin/employee-requests/$id/decide';
  static String adminEmployeeRequestApprove(int id) => '$_v1/admin/employee-requests/$id/approve';
  static String adminEmployeeRequestReject(int id) => '$_v1/admin/employee-requests/$id/reject';

  // ── G. Attendance (Employee) ─────────────────────────────────
  static const String attendanceHistory = '$_v1/attendance/history';

  // ── H. Payroll ───────────────────────────────────────────────
  static const String payroll = '$_v1/payroll';
  static String payslipDetail(String month) => '$_v1/payroll/$month';

  // ── I. Notifications ─────────────────────────────────────────
  static const String notificationsSend = '$_v1/notifications/send';
  static const String notificationsSendToUser = '$_v1/notifications/send-to-user';

  // ── J0. Branches (Admin) ─────────────────────────────────────
  static const String adminBranches = '$_v1/admin/branches';

  // ── J. Dashboard (Admin) ─────────────────────────────────────
  static const String adminDashboard = '$_v1/admin/dashboard';

  // ── K. Employees (Admin) ─────────────────────────────────────
  static const String adminEmployees = '$_v1/admin/employees';
  static String adminEmployeeDetail(int id) => '$_v1/admin/employees/$id';
  static String adminEmployeeStatus(int id) => '$_v1/admin/employees/$id/status';

  // ── L. Departments (Admin) ───────────────────────────────────
  static const String adminDepartments = '$_v1/admin/departments';
  static String adminDepartmentDetail(int id) => '$_v1/admin/departments/$id';

  // ── M. Attendance (Admin) ────────────────────────────────────
  static const String adminAttendance = '$_v1/admin/attendance';
  static String adminAttendanceEmployee(int id) => '$_v1/admin/attendance/$id';

  // ── N. Announcements (Admin) ─────────────────────────────────
  static const String adminAnnouncements = '$_v1/admin/announcements';
  static String adminAnnouncementDetail(int id) => '$_v1/admin/announcements/$id';
  static String adminAnnouncementPublish(int id) => '$_v1/admin/announcements/$id/publish';

  // ── O. Projects (Admin) ──────────────────────────────────────
  static const String adminProjects = '$_v1/admin/projects';
  static String adminProjectDetail(int id) => '$_v1/admin/projects/$id';
  static String adminProjectTasks(int id) => '$_v1/admin/projects/$id/tasks';
  static String adminProjectMilestones(int id) => '$_v1/admin/projects/$id/milestones';
  static String adminProjectAnalytics(int id) => '$_v1/admin/projects/$id/analytics';

  // ── P. Expenses (Admin) ──────────────────────────────────────
  static const String adminExpenses = '$_v1/admin/expenses';
  static String adminExpenseDetail(int id) => '$_v1/admin/expenses/$id';
  static String adminExpenseApprove(int id) => '$_v1/admin/expenses/$id/approve';
  static String adminExpenseReject(int id) => '$_v1/admin/expenses/$id/reject';

  // ── Q. Reports (Admin) ───────────────────────────────────────
  static const String adminReportsKpis = '$_v1/admin/reports/kpis';
  static const String adminReportsAttendanceTrend = '$_v1/admin/reports/attendance-trend';
  static const String adminReportsLeaveAnalysis = '$_v1/admin/reports/leave-analysis';
  static const String adminReportsTaskCompletion = '$_v1/admin/reports/task-completion';

  // ── R. Tasks (Admin) ───────────────────────────────────────
  static const String adminTasks = '$_v1/admin/tasks';
  static String adminTaskDetail(int id) => '$_v1/admin/tasks/$id';
  static String adminTaskTimeLogs(int taskId) => '$_v1/admin/tasks/$taskId/time-logs';
  static String adminTaskTimeLogDetail(int taskId, int timeLogId) =>
      '$_v1/admin/tasks/$taskId/time-logs/$timeLogId';
  static String adminTaskComments(int taskId) => '$_v1/admin/tasks/$taskId/comments';
  static String adminTaskCommentDetail(int taskId, int commentId) =>
      '$_v1/admin/tasks/$taskId/comments/$commentId';
  static String adminTaskAttachments(int taskId) => '$_v1/admin/tasks/$taskId/attachments';
  static String adminTaskAttachmentDetail(int taskId, int attachmentId) =>
      '$_v1/admin/tasks/$taskId/attachments/$attachmentId';

  // ── S. Follow-ups (Admin) ──────────────────────────────────
  static const String adminFollowUps = '$_v1/admin/follow-ups';
  static String adminFollowUpDetail(int id) => '$_v1/admin/follow-ups/$id';
  static String adminFollowUpEscalate(int id) => '$_v1/admin/follow-ups/$id/escalate';

  // ── T. Documents (Admin) ───────────────────────────────────
  static const String adminDocuments = '$_v1/admin/documents';
  static const String adminDocumentCategories = '$_v1/admin/documents/categories';
  static String adminDocumentDetail(int id) => '$_v1/admin/documents/$id';

  // ── U. Payroll (Admin — Postman 03) ────────────────────────
  static const String adminPayroll = '$_v1/admin/payroll';
  static String adminPayrollItem(int id) => '$_v1/admin/payroll/$id';

  // ── V. Allowances (Admin — Postman 04) ─────────────────────
  static const String adminAllowances = '$_v1/admin/allowances';
  static String adminAllowanceDetail(int id) => '$_v1/admin/allowances/$id';

  // ── W. Deductions (Admin — Postman 04) ─────────────────────
  static const String adminDeductions = '$_v1/admin/deductions';
  static String adminDeductionDetail(int id) => '$_v1/admin/deductions/$id';

  // ── X. Ticket Sales Reports (Admin — Postman 07) ───────────
  static const String adminTicketSalesReports = '$_v1/admin/ticket-sales-reports';
  static const String adminTicketSalesReportsKpis =
      '$_v1/admin/ticket-sales-reports/kpis';
}
