import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../injection.dart';
import '../network/session_manager.dart';
import '../storage/secure_token_storage.dart';

// ── Repositories ──
import '../../features/admin_dashboard/data/repositories/dashboard_repository.dart';
import '../../features/announcements/data/repositories/announcement_repository.dart';
import '../../features/attendance_management/data/repositories/attendance_repository.dart';
import '../../features/attendance_management/data/repositories/leave_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/departments/data/repositories/department_repository.dart';
import '../../features/documents/data/repositories/document_repository.dart';
import '../../features/documents/data/repositories/notification_repository.dart';
import '../../features/employees/data/repositories/employee_repository.dart';
import '../../features/expenses/data/repositories/expense_repository.dart';
import '../../features/follow_up/data/repositories/follow_up_repository.dart';
import '../../features/projects/data/repositories/project_repository.dart';
import '../../features/reports/data/repositories/report_repository.dart';
import '../../features/requests_management/data/repositories/request_repository.dart';
import '../../features/settings/data/repositories/profile_repository.dart';
import '../../features/tasks/data/repositories/task_repository.dart';

// ── Core ──
final sessionManagerProvider = Provider<SessionManager>((_) => sl<SessionManager>());
final secureStorageProvider = Provider<SecureTokenStorage>((_) => sl<SecureTokenStorage>());

// ── Feature Repositories ──
final authRepositoryProvider = Provider<AuthRepository>((_) => sl<AuthRepository>());
final profileRepositoryProvider = Provider<ProfileRepository>((_) => sl<ProfileRepository>());
final dashboardRepositoryProvider = Provider<DashboardRepository>((_) => sl<DashboardRepository>());
final requestRepositoryProvider = Provider<RequestRepository>((_) => sl<RequestRepository>());
final leaveRepositoryProvider = Provider<LeaveRepository>((_) => sl<LeaveRepository>());
final attendanceRepositoryProvider = Provider<AttendanceRepository>((_) => sl<AttendanceRepository>());
final employeeRepositoryProvider = Provider<EmployeeRepository>((_) => sl<EmployeeRepository>());
final departmentRepositoryProvider = Provider<DepartmentRepository>((_) => sl<DepartmentRepository>());
final announcementRepositoryProvider = Provider<AnnouncementRepository>((_) => sl<AnnouncementRepository>());
final projectRepositoryProvider = Provider<ProjectRepository>((_) => sl<ProjectRepository>());
final expenseRepositoryProvider = Provider<ExpenseRepository>((_) => sl<ExpenseRepository>());
final reportRepositoryProvider = Provider<ReportRepository>((_) => sl<ReportRepository>());
final notificationRepositoryProvider = Provider<NotificationRepository>((_) => sl<NotificationRepository>());
final taskRepositoryProvider = Provider<TaskRepository>((_) => sl<TaskRepository>());
final followUpRepositoryProvider = Provider<FollowUpRepository>((_) => sl<FollowUpRepository>());
final documentRepositoryProvider = Provider<DocumentRepository>((_) => sl<DocumentRepository>());
