import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Auth ───────────────────────────────────────────────────
import '../../features/auth/screens/auth_screens.dart';

// ── Shell + Dashboard ──────────────────────────────────────
import '../../features/admin_dashboard/screens/admin_shell.dart';
import '../../features/admin_dashboard/screens/admin_dashboard_screen.dart';

// ── Departments ────────────────────────────────────────────
import '../../features/departments/screens/departments_screens.dart';

// ── Employees ──────────────────────────────────────────────
import '../../features/employees/screens/employees_screens.dart';

// ── Requests Management ────────────────────────────────────
import '../../features/requests_management/screens/requests_screens.dart';

// ── Tasks ──────────────────────────────────────────────────
import '../../features/tasks/screens/tasks_screens.dart';

// ── Follow-up ──────────────────────────────────────────────
import '../../features/follow_up/screens/follow_up_screen.dart';

// ── Attendance + Leave ─────────────────────────────────────
import '../../features/attendance_management/screens/attendance_leave_screens.dart';

// ── Announcements ──────────────────────────────────────────
import '../../features/announcements/screens/announcements_screens.dart';

// ── Documents + Notifications ──────────────────────────────
import '../../features/documents/screens/documents_notifications_screens.dart';

// ── Reports ────────────────────────────────────────────────
import '../../features/reports/screens/reports_screen.dart';

// ── Settings ───────────────────────────────────────────────
import '../../features/settings/screens/settings_screens.dart';

// ── Projects ───────────────────────────────────────────────
import '../../features/projects/screens/projects_screens.dart';

// ── Expenses ───────────────────────────────────────────────
import '../../features/expenses/screens/expenses_screens.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ── Auth ──────────────────────────────────────────────
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/otp', builder: (_, __) => const OTPScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const LoginScreen()),

    // ── Main Shell with persistent bottom nav ─────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdminShell(navigationShell: navigationShell),
      branches: [
        // Tab 0: Dashboard
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
        ]),
        // Tab 1: Requests
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/requests',
            builder: (_, __) => const RequestsManagementScreen(),
          ),
        ]),
        // Tab 2: Tasks
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/tasks',
            builder: (_, __) => const TasksDashboardScreen(),
          ),
        ]),
        // Tab 3: Follow-up
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/follow-up',
            builder: (_, __) => const FollowUpScreen(),
          ),
        ]),
        // Tab 4: Settings
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (_, __) => const AdminSettingsScreen(),
          ),
        ]),
      ],
    ),

    // ── Departments ───────────────────────────────────────
    GoRoute(path: '/departments', builder: (_, __) => const DepartmentsScreen()),
    GoRoute(path: '/department-detail', builder: (_, __) => const DepartmentDetailScreen()),

    // ── Employees ─────────────────────────────────────────
    GoRoute(path: '/employees', builder: (_, __) => const EmployeesScreen()),
    GoRoute(path: '/employee-detail', builder: (_, __) => const EmployeeDetailScreen()),

    // ── Requests (sub-pages) ──────────────────────────────
    GoRoute(path: '/all-requests', builder: (_, __) => const AllRequestsScreen()),
    GoRoute(path: '/request-detail', builder: (_, __) => const RequestDetailScreen()),
    GoRoute(path: '/approvals', builder: (_, __) => const ApprovalsScreen()),

    // ── Tasks (sub-pages) ─────────────────────────────────
    GoRoute(path: '/all-tasks', builder: (_, __) => const AllTasksScreen()),
    GoRoute(path: '/task-detail', builder: (_, __) => const TaskDetailScreen()),
    GoRoute(path: '/create-task', builder: (_, __) => const TaskDetailScreen()),

    // ── Follow-up (sub-pages) ─────────────────────────────
    GoRoute(path: '/follow-up-detail', builder: (_, __) => const FollowUpDetailScreen()),

    // ── Attendance ────────────────────────────────────────
    GoRoute(path: '/attendance', builder: (_, __) => const AttendanceManagementScreen()),
    GoRoute(path: '/attendance-detail', builder: (_, __) => const AttendanceDetailScreen()),

    // ── Leave ─────────────────────────────────────────────
    GoRoute(path: '/leave', builder: (_, __) => const LeaveManagementScreen()),
    GoRoute(path: '/leave-detail', builder: (_, __) => const LeaveDetailAdminScreen()),

    // ── Announcements ─────────────────────────────────────
    GoRoute(path: '/announcements', builder: (_, __) => const AnnouncementsManagementScreen()),
    GoRoute(path: '/announcement-detail', builder: (_, __) => const AnnouncementDetailScreen()),
    GoRoute(path: '/create-announcement', builder: (_, __) => const AnnouncementDetailScreen()),

    // ── Documents + Notifications ─────────────────────────
    GoRoute(path: '/documents', builder: (_, __) => const DocumentsOverviewScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsCenterScreen()),

    // ── Reports ───────────────────────────────────────────
    GoRoute(path: '/reports', builder: (_, __) => const ReportsKpiScreen()),

    // ── Settings (sub-pages) ──────────────────────────────
    GoRoute(path: '/admin-profile', builder: (_, __) => const AdminProfileScreen()),
    GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
    GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),

    // ── Projects ──────────────────────────────────────────
    GoRoute(path: '/projects', builder: (_, __) => const ProjectsOverviewScreen()),
    GoRoute(path: '/projects-list', builder: (_, __) => const ProjectsListScreen()),
    GoRoute(path: '/project-detail', builder: (_, __) => const ProjectDetailScreen()),
    GoRoute(path: '/project-tasks', builder: (_, __) => const ProjectTasksScreen()),
    GoRoute(path: '/project-milestones', builder: (_, __) => const ProjectMilestonesScreen()),
    GoRoute(path: '/project-follow-up', builder: (_, __) => const ProjectFollowUpScreen()),
    GoRoute(path: '/project-analytics', builder: (_, __) => const ProjectAnalyticsScreen()),

    // ── Expenses ──────────────────────────────────────────
    GoRoute(path: '/expenses', builder: (_, __) => const ExpensesOverviewScreen()),
    GoRoute(path: '/expense-requests', builder: (_, __) => const ExpenseRequestsListScreen()),
    GoRoute(path: '/expense-detail', builder: (_, __) => const ExpenseRequestDetailScreen()),
    GoRoute(path: '/expense-categories', builder: (_, __) => const ExpenseCategoriesScreen()),
    GoRoute(path: '/expense-analytics', builder: (_, __) => const ExpenseAnalyticsScreen()),
    GoRoute(path: '/expense-follow-up', builder: (_, __) => const ExpenseFollowUpScreen()),
  ],
);
