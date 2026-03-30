import 'package:get_it/get_it.dart';

import 'core/network/api_client.dart';
import 'core/network/session_manager.dart';
import 'core/storage/secure_token_storage.dart';

// ── Repositories ──
import 'features/admin_dashboard/data/repositories/dashboard_repository.dart';
import 'features/announcements/data/repositories/announcement_repository.dart';
import 'features/attendance_management/data/repositories/attendance_repository.dart';
import 'features/attendance_management/data/repositories/leave_repository.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/departments/data/repositories/department_repository.dart';
import 'features/documents/data/repositories/document_repository.dart';
import 'features/documents/data/repositories/notification_repository.dart';
import 'features/employees/data/repositories/employee_repository.dart';
import 'features/expenses/data/repositories/expense_repository.dart';
import 'features/follow_up/data/repositories/follow_up_repository.dart';
import 'features/projects/data/repositories/project_repository.dart';
import 'features/reports/data/repositories/report_repository.dart';
import 'features/requests_management/data/repositories/request_repository.dart';
import 'features/settings/data/repositories/profile_repository.dart';
import 'features/tasks/data/repositories/task_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ──
  sl.registerLazySingleton<SecureTokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(storage: sl<SecureTokenStorage>()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      storage: sl<SecureTokenStorage>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  // ── Feature Repositories ──
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      client: sl<ApiClient>(),
      sessionManager: sl<SessionManager>(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<RequestRepository>(
    () => RequestRepository(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<LeaveRepository>(
    () => LeaveRepository(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<DepartmentRepository>(
    () => DepartmentRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<FollowUpRepository>(
    () => FollowUpRepository(client: sl<ApiClient>()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepository(client: sl<ApiClient>()),
  );
}
