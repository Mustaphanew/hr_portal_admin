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
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/otp', builder: (_, _) => const OTPScreen()),
    GoRoute(path: '/forgot-password', builder: (_, _) => const LoginScreen()),

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
    GoRoute(path: '/department-detail', builder: (_, _) => const DepartmentDetailScreen()),

    // ── Employees ─────────────────────────────────────────
    GoRoute(path: '/employees', builder: (_, _) => const EmployeesScreen()),
    GoRoute(path: '/employee-detail', builder: (_, _) => const EmployeeDetailScreen()),

    // ── Requests (sub-pages) ──────────────────────────────
    GoRoute(path: '/all-requests', builder: (_, _) => const AllRequestsScreen()),
    GoRoute(path: '/request-detail', builder: (_, _) => const RequestDetailScreen()),
    GoRoute(path: '/approvals', builder: (_, _) => const ApprovalsScreen()),

    // ── Tasks (sub-pages) ─────────────────────────────────
    GoRoute(path: '/all-tasks', builder: (_, _) => const AllTasksScreen()),
    GoRoute(path: '/task-detail', builder: (_, _) => const TaskDetailScreen()),
    GoRoute(path: '/create-task', builder: (_, _) => const TaskDetailScreen()),

    // ── Follow-up (sub-pages) ─────────────────────────────
    GoRoute(path: '/follow-up-detail', builder: (_, _) => const FollowUpDetailScreen()),

    // ── Attendance ────────────────────────────────────────
    GoRoute(path: '/attendance', builder: (_, _) => const AttendanceManagementScreen()),
    GoRoute(path: '/attendance-detail', builder: (_, _) => const AttendanceDetailScreen()),

    // ── Leave ─────────────────────────────────────────────
    GoRoute(path: '/leave', builder: (_, _) => const LeaveManagementScreen()),
    GoRoute(path: '/leave-detail', builder: (_, _) => const LeaveDetailAdminScreen()),

    // ── Announcements ─────────────────────────────────────
    GoRoute(path: '/announcements', builder: (_, _) => const AnnouncementsManagementScreen()),
    GoRoute(path: '/announcement-detail', builder: (_, _) => const AnnouncementDetailScreen()),
    GoRoute(path: '/create-announcement', builder: (_, _) => const AnnouncementDetailScreen()),

    // ── Documents + Notifications ─────────────────────────
    GoRoute(path: '/documents', builder: (_, _) => const DocumentsOverviewScreen()),
    GoRoute(path: '/notifications', builder: (_, _) => const NotificationsCenterScreen()),

    // ── Reports ───────────────────────────────────────────
    GoRoute(path: '/reports', builder: (_, _) => const ReportsKpiScreen()),

    // ── Settings (sub-pages) ──────────────────────────────
    GoRoute(path: '/admin-profile', builder: (_, _) => const AdminProfileScreen()),
    GoRoute(path: '/support', builder: (_, _) => const SupportScreen()),
    GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),

    // ── Projects ──────────────────────────────────────────
    GoRoute(path: '/projects', builder: (_, _) => const ProjectsOverviewScreen()),
    GoRoute(path: '/projects-list', builder: (_, _) => const ProjectsListScreen()),
    GoRoute(path: '/project-detail', builder: (_, _) => const ProjectDetailScreen()),
    GoRoute(path: '/project-tasks', builder: (_, _) => const ProjectTasksScreen()),
    GoRoute(path: '/project-milestones', builder: (_, _) => const ProjectMilestonesScreen()),
    GoRoute(path: '/project-follow-up', builder: (_, _) => const ProjectFollowUpScreen()),
    GoRoute(path: '/project-analytics', builder: (_, _) => const ProjectAnalyticsScreen()),

    // ── Expenses ──────────────────────────────────────────
    GoRoute(path: '/expenses', builder: (_, _) => const ExpensesOverviewScreen()),
    GoRoute(path: '/expense-requests', builder: (_, _) => const ExpenseRequestsListScreen()),
    GoRoute(path: '/expense-detail', builder: (_, _) => const ExpenseRequestDetailScreen()),
    GoRoute(path: '/expense-categories', builder: (_, _) => const ExpenseCategoriesScreen()),
    GoRoute(path: '/expense-analytics', builder: (_, _) => const ExpenseAnalyticsScreen()),
    GoRoute(path: '/expense-follow-up', builder: (_, _) => const ExpenseFollowUpScreen()),
  ],
);
