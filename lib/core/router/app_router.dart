import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Auth ───────────────────────────────────────────────────
import '../../features/auth/presentation/screens/auth_screens.dart';

// ── Shell + Dashboard ──────────────────────────────────────
import '../../features/admin_dashboard/presentation/screens/admin_shell.dart';
import '../../features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart';

// ── Departments ────────────────────────────────────────────
import '../../features/departments/presentation/screens/departments_screens.dart';

// ── Employees ──────────────────────────────────────────────
import '../../features/employees/presentation/screens/employees_screens.dart';

// ── Requests Management ────────────────────────────────────
import '../../features/requests_management/presentation/screens/requests_screens.dart';

// ── Tasks ──────────────────────────────────────────────────
import '../../features/tasks/presentation/screens/tasks_screens.dart';

// ── Follow-up ──────────────────────────────────────────────
import '../../features/follow_up/presentation/screens/follow_up_screen.dart';

// ── Attendance + Leave ─────────────────────────────────────
import '../../features/attendance_management/presentation/screens/attendance_leave_screens.dart';

// ── Announcements ──────────────────────────────────────────
import '../../features/announcements/presentation/screens/announcements_screens.dart';

// ── Documents + Notifications ──────────────────────────────
import '../../features/documents/presentation/screens/documents_notifications_screens.dart';

// ── Reports ────────────────────────────────────────────────
import '../../features/reports/presentation/screens/reports_screen.dart';

// ── Settings ───────────────────────────────────────────────
import '../../features/settings/presentation/screens/settings_screens.dart';

// ── Projects ───────────────────────────────────────────────
import '../../features/projects/presentation/screens/projects_screens.dart';

// ── Expenses ───────────────────────────────────────────────
import '../../features/expenses/presentation/screens/expenses_screens.dart';

// ── Payroll / Allowances / Deductions ──────────────────────
import '../../features/payroll/presentation/screens/allowances_screen.dart';
import '../../features/payroll/presentation/screens/deductions_screen.dart';
import '../../features/payroll/presentation/screens/payroll_screen.dart';

// ── Ticket Sales Reports ───────────────────────────────────
import '../../features/ticket_sales/presentation/screens/ticket_sales_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

int _extractId(GoRouterState state, [String param = 'id']) {
  final fromPath = state.pathParameters[param];
  if (fromPath != null) return int.parse(fromPath);
  if (state.extra is int) return state.extra as int;
  return 0;
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ── Auth ──────────────────────────────────────────────
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/otp', builder: (_, _) => const OTPScreen()),
    GoRoute(path: '/forgot-password', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/guest-settings', builder: (_, _) => const AdminSettingsScreen()),

    // ── Main Shell with persistent bottom nav ─────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdminShell(navigationShell: navigationShell),
      branches: [
        // Tab 0: Dashboard
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, _) => const NotificationsCenterScreen(),
          ),
          GoRoute(
            path: '/admin-profile',
            builder: (_, _) => const AdminProfileScreen(),
          ),
        ]),
        // Tab 1: Requests
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/requests',
            builder: (_, _) => const RequestsManagementScreen(),
          ),
        ]),
        // Tab 2: Tasks
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/tasks',
            builder: (_, _) => const TasksDashboardScreen(),
          ),
        ]),
        // Tab 3: Follow-up
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/follow-up',
            builder: (_, _) => const FollowUpScreen(),
          ),
        ]),
        // Tab 4: Settings
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (_, _) => const AdminSettingsScreen(),
          ),
        ]),
      ],
    ),

    // ── Departments ───────────────────────────────────────
    GoRoute(path: '/departments', builder: (_, _) => const DepartmentsScreen()),
    GoRoute(path: '/department-detail/:id', builder: (_, state) =>
      DepartmentDetailScreen(departmentId: _extractId(state))),
    GoRoute(path: '/department-detail', builder: (_, state) =>
      DepartmentDetailScreen(departmentId: _extractId(state))),

    // ── Employees ─────────────────────────────────────────
    GoRoute(path: '/employees', builder: (_, _) => const EmployeesScreen()),
    GoRoute(path: '/employee-detail/:id', builder: (_, state) =>
      EmployeeDetailScreen(employeeId: _extractId(state))),
    GoRoute(path: '/employee-detail', builder: (_, state) =>
      EmployeeDetailScreen(employeeId: _extractId(state))),

    // ── Requests (sub-pages) ──────────────────────────────
    GoRoute(path: '/all-requests', builder: (_, _) => const AllRequestsScreen()),
    GoRoute(path: '/request-detail/:id', builder: (_, state) =>
      RequestDetailScreen(requestId: _extractId(state))),
    GoRoute(path: '/request-detail', builder: (_, state) =>
      RequestDetailScreen(requestId: _extractId(state))),
    GoRoute(path: '/approvals', builder: (_, _) => const ApprovalsScreen()),

    // ── Tasks (sub-pages) ─────────────────────────────────
    GoRoute(path: '/all-tasks', builder: (_, _) => const AllTasksScreen()),
    GoRoute(path: '/task-detail/:id', builder: (_, state) =>
      TaskDetailScreen(taskId: _extractId(state))),
    GoRoute(path: '/task-detail', builder: (_, state) =>
      TaskDetailScreen(taskId: _extractId(state))),

    // ── Follow-up (sub-pages) ─────────────────────────────
    GoRoute(path: '/follow-up-detail/:id', builder: (_, state) =>
      FollowUpDetailScreen(followUpId: _extractId(state))),
    GoRoute(path: '/follow-up-detail', builder: (_, state) =>
      FollowUpDetailScreen(followUpId: _extractId(state))),

    // ── Attendance ────────────────────────────────────────
    GoRoute(path: '/attendance', builder: (_, _) => const AttendanceManagementScreen()),
    GoRoute(path: '/attendance-detail', builder: (_, state) =>
      AttendanceDetailScreen(record: state.extra as dynamic)),

    // ── Leave ─────────────────────────────────────────────
    GoRoute(path: '/leave', builder: (_, _) => const LeaveManagementScreen()),
    GoRoute(path: '/leave-detail/:id', builder: (_, state) => LeaveDetailAdminScreen(
      leaveId: int.parse(state.pathParameters['id']!))),

    // ── Announcements ─────────────────────────────────────
    GoRoute(path: '/announcements', builder: (_, _) => const AnnouncementsManagementScreen()),
    GoRoute(path: '/announcement-detail/:id', builder: (_, state) =>
      AnnouncementDetailScreen(announcementId: _extractId(state))),
    GoRoute(path: '/announcement-detail', builder: (_, state) =>
      AnnouncementDetailScreen(announcementId: _extractId(state))),

    // ── Documents ─────────────────────────────────────────
    GoRoute(path: '/documents', builder: (_, _) => const DocumentsOverviewScreen()),

    // ── Reports ───────────────────────────────────────────
    GoRoute(path: '/reports', builder: (_, _) => const ReportsKpiScreen()),

    // ── Settings (sub-pages) ──────────────────────────────
    GoRoute(path: '/support', builder: (_, _) => const SupportScreen()),
    GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),

    // ── Projects ──────────────────────────────────────────
    GoRoute(path: '/projects', builder: (_, _) => const ProjectsOverviewScreen()),
    GoRoute(path: '/projects-list', builder: (_, _) => const ProjectsListScreen()),
    GoRoute(path: '/project-detail/:id', builder: (_, state) =>
      ProjectDetailScreen(projectId: _extractId(state))),
    GoRoute(path: '/project-detail', builder: (_, state) =>
      ProjectDetailScreen(projectId: _extractId(state))),
    GoRoute(path: '/project-tasks/:id', builder: (_, state) =>
      ProjectTasksScreen(projectId: _extractId(state))),
    GoRoute(path: '/project-tasks', builder: (_, state) =>
      ProjectTasksScreen(projectId: _extractId(state))),
    GoRoute(path: '/project-milestones/:id', builder: (_, state) =>
      ProjectMilestonesScreen(projectId: _extractId(state))),
    GoRoute(path: '/project-milestones', builder: (_, state) =>
      ProjectMilestonesScreen(projectId: _extractId(state))),
    GoRoute(path: '/project-follow-up', builder: (_, _) => const ProjectFollowUpScreen()),
    GoRoute(path: '/project-analytics/:id', builder: (_, state) =>
      ProjectAnalyticsScreen(projectId: _extractId(state))),
    GoRoute(path: '/project-analytics', builder: (_, state) =>
      ProjectAnalyticsScreen(projectId: _extractId(state))),

    // ── Expenses ──────────────────────────────────────────
    GoRoute(path: '/expenses', builder: (_, _) => const ExpensesOverviewScreen()),
    GoRoute(path: '/expense-requests', builder: (_, _) => const ExpenseRequestsListScreen()),
    GoRoute(path: '/expense-detail/:id', builder: (_, state) =>
      ExpenseRequestDetailScreen(expenseId: _extractId(state))),
    GoRoute(path: '/expense-detail', builder: (_, state) =>
      ExpenseRequestDetailScreen(expenseId: _extractId(state))),
    GoRoute(path: '/expense-categories', builder: (_, _) => const ExpenseCategoriesScreen()),
    GoRoute(path: '/expense-analytics', builder: (_, _) => const ExpenseAnalyticsScreen()),
    GoRoute(path: '/expense-follow-up', builder: (_, _) => const ExpenseFollowUpScreen()),

    // ── Payroll ───────────────────────────────────────────
    GoRoute(path: '/payroll', builder: (_, _) => const PayrollScreen()),
    GoRoute(path: '/allowances', builder: (_, _) => const AllowancesScreen()),
    GoRoute(path: '/deductions', builder: (_, _) => const DeductionsScreen()),

    // ── Ticket Sales Reports ──────────────────────────────
    GoRoute(path: '/ticket-sales', builder: (_, _) => const TicketSalesScreen()),
  ],
);
