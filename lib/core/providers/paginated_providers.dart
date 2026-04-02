import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'paginated_notifier.dart';
import 'admin_providers.dart';
import 'core_providers.dart';

// Models
import '../../features/attendance_management/data/models/leave_models.dart';
import '../../features/requests_management/data/models/request_models.dart';
import '../../features/tasks/data/models/task_models.dart';
import '../../features/employees/data/models/employee_models.dart';
import '../../features/expenses/data/models/expense_models.dart';
import '../../features/announcements/data/models/announcement_models.dart';
import '../../features/documents/data/models/document_models.dart';
import '../../features/projects/data/models/project_models.dart';
import '../../features/follow_up/data/models/follow_up_models.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. MANAGER LEAVES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedManagerLeavesNotifier extends PaginatedNotifier<LeaveRequest> {
  @override
  Future<PaginatedState<LeaveRequest>> build() async {
    ref.watch(managerLeavesStatusFilter);
    return super.build();
  }

  @override
  FetchPage<LeaveRequest> get fetchPage => (page, perPage) async {
    final status = ref.read(managerLeavesStatusFilter);
    final response = await ref.read(leaveRepositoryProvider).getManagerLeaves(
      status: status, perPage: perPage, page: page,
    );
    final data = response.data!;
    return PaginatedResponse(items: data.leaves, pagination: data.pagination);
  };
}

final paginatedManagerLeavesProvider = AsyncNotifierProvider.autoDispose<
    PaginatedManagerLeavesNotifier, PaginatedState<LeaveRequest>>(
  PaginatedManagerLeavesNotifier.new,
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. MANAGER REQUESTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedRequestsNotifier extends PaginatedNotifier<EmployeeRequest> {
  @override
  Future<PaginatedState<EmployeeRequest>> build() async {
    ref.watch(managerRequestsStatusFilter);
    return super.build();
  }

  @override
  FetchPage<EmployeeRequest> get fetchPage => (page, perPage) async {
    final status = ref.read(managerRequestsStatusFilter);
    final response = await ref.read(requestRepositoryProvider).getManagerRequests(
      status: status, perPage: perPage, page: page,
    );
    final data = response.data!;
    return PaginatedResponse(items: data.requests, pagination: data.pagination);
  };
}

final paginatedRequestsProvider = AsyncNotifierProvider.autoDispose<
    PaginatedRequestsNotifier, PaginatedState<EmployeeRequest>>(
  PaginatedRequestsNotifier.new,
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. TASKS (with stats)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedTasksNotifier extends PaginatedNotifier<AdminTaskItem> {
  TaskStats? _stats;
  TaskStats? get stats => _stats;

  @override
  Future<PaginatedState<AdminTaskItem>> build() async {
    ref.watch(tasksStatusFilter);
    ref.watch(tasksPriorityFilter);
    return super.build();
  }

  @override
  FetchPage<AdminTaskItem> get fetchPage => (page, perPage) async {
    final status = ref.read(tasksStatusFilter);
    final priority = ref.read(tasksPriorityFilter);
    final data = await ref.read(taskRepositoryProvider).getTasks(
      status: status, priority: priority, perPage: perPage, page: page,
    );
    if (page == 1) _stats = data.stats;
    return PaginatedResponse(items: data.tasks, pagination: data.pagination);
  };
}

final paginatedTasksProvider = AsyncNotifierProvider.autoDispose<
    PaginatedTasksNotifier, PaginatedState<AdminTaskItem>>(
  PaginatedTasksNotifier.new,
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. EMPLOYEES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedEmployeesNotifier extends PaginatedNotifier<AdminEmployee> {
  @override
  Future<PaginatedState<AdminEmployee>> build() async {
    ref.watch(employeesSearchProvider);
    ref.watch(employeesStatusProvider);
    ref.watch(selectedBranchProvider);
    return super.build();
  }

  @override
  FetchPage<AdminEmployee> get fetchPage => (page, perPage) async {
    final search = ref.read(employeesSearchProvider);
    final status = ref.read(employeesStatusProvider);
    final sel = ref.read(selectedBranchProvider);
    final data = await ref.read(employeeRepositoryProvider).getEmployees(
      search: search.isNotEmpty ? search : null,
      status: status,
      companyId: sel.isBranch ? null : sel.companyId,
      branchId: sel.branchId,
      perPage: perPage,
      page: page,
    );
    return PaginatedResponse(items: data.employees, pagination: data.pagination);
  };
}

final paginatedEmployeesProvider = AsyncNotifierProvider.autoDispose<
    PaginatedEmployeesNotifier, PaginatedState<AdminEmployee>>(
  PaginatedEmployeesNotifier.new,
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. EXPENSES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedExpensesNotifier extends PaginatedNotifier<Expense> {
  @override
  Future<PaginatedState<Expense>> build() async {
    ref.watch(expensesStatusFilter);
    return super.build();
  }

  @override
  FetchPage<Expense> get fetchPage => (page, perPage) async {
    final status = ref.read(expensesStatusFilter);
    final data = await ref.read(expenseRepositoryProvider).getExpenses(
      status: status, perPage: perPage, page: page,
    );
    return PaginatedResponse(items: data.expenses, pagination: data.pagination);
  };
}

final paginatedExpensesProvider = AsyncNotifierProvider.autoDispose<
    PaginatedExpensesNotifier, PaginatedState<Expense>>(
  PaginatedExpensesNotifier.new,
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. ANNOUNCEMENTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedAnnouncementsNotifier extends PaginatedNotifier<Announcement> {
  @override
  Future<PaginatedState<Announcement>> build() async {
    ref.watch(announcementsStatusFilter);
    return super.build();
  }

  @override
  FetchPage<Announcement> get fetchPage => (page, perPage) async {
    final status = ref.read(announcementsStatusFilter);
    final data = await ref.read(announcementRepositoryProvider).getAnnouncements(
      status: status, perPage: perPage, page: page,
    );
    return PaginatedResponse(items: data.announcements, pagination: data.pagination);
  };
}

final paginatedAnnouncementsProvider = AsyncNotifierProvider.autoDispose<
    PaginatedAnnouncementsNotifier, PaginatedState<Announcement>>(
  PaginatedAnnouncementsNotifier.new,
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. DOCUMENTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedDocumentsNotifier extends PaginatedNotifier<AdminDocument> {
  @override
  Future<PaginatedState<AdminDocument>> build() async {
    ref.watch(documentsCategoryFilter);
    return super.build();
  }

  @override
  FetchPage<AdminDocument> get fetchPage => (page, perPage) async {
    final category = ref.read(documentsCategoryFilter);
    final data = await ref.read(documentRepositoryProvider).getDocuments(
      category: category, perPage: perPage, page: page,
    );
    return PaginatedResponse(items: data.documents, pagination: data.pagination);
  };
}

final paginatedDocumentsProvider = AsyncNotifierProvider.autoDispose<
    PaginatedDocumentsNotifier, PaginatedState<AdminDocument>>(
  PaginatedDocumentsNotifier.new,
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8. PROJECTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedProjectsNotifier extends PaginatedNotifier<Project> {
  @override
  Future<PaginatedState<Project>> build() async {
    ref.watch(projectsStatusFilter);
    return super.build();
  }

  @override
  FetchPage<Project> get fetchPage => (page, perPage) async {
    final status = ref.read(projectsStatusFilter);
    final data = await ref.read(projectRepositoryProvider).getProjects(
      status: status, perPage: perPage, page: page,
    );
    return PaginatedResponse(items: data.projects, pagination: data.pagination);
  };
}

final paginatedProjectsProvider = AsyncNotifierProvider.autoDispose<
    PaginatedProjectsNotifier, PaginatedState<Project>>(
  PaginatedProjectsNotifier.new,
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9. FOLLOW-UPS (with stats)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedFollowUpsNotifier extends PaginatedNotifier<FollowUpItem> {
  FollowUpStats? _stats;
  FollowUpStats? get stats => _stats;

  @override
  Future<PaginatedState<FollowUpItem>> build() async {
    ref.watch(followUpsStatusFilter);
    ref.watch(followUpsTypeFilter);
    return super.build();
  }

  @override
  FetchPage<FollowUpItem> get fetchPage => (page, perPage) async {
    final status = ref.read(followUpsStatusFilter);
    final type = ref.read(followUpsTypeFilter);
    final data = await ref.read(followUpRepositoryProvider).getFollowUps(
      status: status, type: type, perPage: perPage, page: page,
    );
    if (page == 1) _stats = data.stats;
    return PaginatedResponse(items: data.followUps, pagination: data.pagination);
  };
}

final paginatedFollowUpsProvider = AsyncNotifierProvider.autoDispose<
    PaginatedFollowUpsNotifier, PaginatedState<FollowUpItem>>(
  PaginatedFollowUpsNotifier.new,
);
