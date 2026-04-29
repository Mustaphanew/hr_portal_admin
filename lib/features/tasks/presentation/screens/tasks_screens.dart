import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/paginated_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../data/models/task_models.dart';
import '../widgets/tasks_filters_sheet.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Tasks Dashboard
// ═══════════════════════════════════════════════════════════════════════════

class TasksDashboardScreen extends ConsumerStatefulWidget {
  const TasksDashboardScreen({super.key});
  @override
  ConsumerState<TasksDashboardScreen> createState() => _TasksDashboardState();
}

class _TasksDashboardState extends ConsumerState<TasksDashboardScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    ref.invalidate(paginatedTasksProvider);
    await ref.read(paginatedTasksProvider.future);
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final tasksAsync = ref.watch(paginatedTasksProvider);
    return Scaffold(
      backgroundColor: c.bg,
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('${'Error'.tr(context)}: $e',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14))),
        data: (paginated) {
          final tasks = paginated.items;
          final stats = ref.read(paginatedTasksProvider.notifier).stats;
          final overdue = stats?.overdue ?? tasks.where((t) => t.status == 'overdue').length;
          final inProgress = stats?.inProgress ?? tasks.where((t) => t.status == 'in_progress').length;
          final pending = stats?.pending ?? tasks.where((t) => t.status == 'pending').length;
          final total = stats?.total ?? tasks.length;

          return Column(children: [
            Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  bottom: 16,
                  left: 18,
                  right: 18),
              child: Column(children: [
                Row(children: [
                  if (context.canPop()) ...[
                    GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                            padding:
                                const EdgeInsetsDirectional.only(start: 6),
                            alignment: AlignmentDirectional.center,
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 18))),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Task Management'.tr(context),
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        Text(
                            'tasks_total'.tr(context,
                                params: {'count': '$total'}),
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: AppColors.goldLight)),
                      ])),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    GestureDetector(
                        onTap: _refreshing ? null : _refresh,
                        child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: _refreshing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : const Icon(Icons.refresh,
                                        color: Colors.white, size: 18)))),
                    const SizedBox(width: 8),
                    GestureDetector(
                        onTap: () => context.push('/all-tasks'),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(9)),
                            child: Text('View all'.tr(context),
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70)))),
                  ]),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _topStat('$total', 'All'.tr(context), AppColors.navySoft,
                      AppColors.goldLight),
                  const SizedBox(width: 8),
                  _topStat('$inProgress', 'In Progress'.tr(context),
                      AppColors.tealSoft, AppColors.tealLight),
                  const SizedBox(width: 8),
                  _topStat('$overdue', 'Overdue'.tr(context),
                      AppColors.errorSoft, AppColors.error),
                  const SizedBox(width: 8),
                  _topStat('$pending', 'Pending'.tr(context),
                      AppColors.warningSoft, AppColors.warning),
                ]),
              ]),
            ),
            Expanded(
                child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(paginatedTasksProvider);
                      await ref.read(paginatedTasksProvider.future);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        if (overdue > 0)
                          AlertBanner(
                              message: 'overdue_tasks_review'.tr(context,
                                  params: {'count': '$overdue'}),
                              type: 'error'),
                        if (tasks.where((t) => t.status == 'overdue').isNotEmpty) ...[
                          SectionHeader(
                              title: 'Overdue Tasks'.tr(context),
                              actionLabel: 'View all'.tr(context),
                              onAction: () => context.push('/all-tasks')),
                          ...tasks.where((t) => t.status == 'overdue').map((t) =>
                              TaskCard(
                                  id: t.id.toString(),
                                  title: t.title,
                                  assignedTo: t.assignedTo.name,
                                  dept: t.department.name,
                                  dueDate: t.dueDate,
                                  status: t.status,
                                  priority: t.priority,
                                  onTap: () =>
                                      context.push('/task-detail/${t.id}'))),
                          const SizedBox(height: 10),
                        ],
                        if (tasks.where((t) => t.status == 'in_progress').isNotEmpty) ...[
                          SectionHeader(title: 'In Progress Tasks'.tr(context)),
                          ...tasks.where((t) => t.status == 'in_progress').map(
                              (t) => TaskCard(
                                  id: t.id.toString(),
                                  title: t.title,
                                  assignedTo: t.assignedTo.name,
                                  dept: t.department.name,
                                  dueDate: t.dueDate,
                                  status: t.status,
                                  priority: t.priority,
                                  onTap: () =>
                                      context.push('/task-detail/${t.id}'))),
                          const SizedBox(height: 10),
                        ],
                        if (tasks.where((t) => t.status == 'pending').isNotEmpty) ...[
                          SectionHeader(title: 'Pending Tasks'.tr(context)),
                          ...tasks.where((t) => t.status == 'pending').map(
                              (t) => TaskCard(
                                  id: t.id.toString(),
                                  title: t.title,
                                  assignedTo: t.assignedTo.name,
                                  dept: t.department.name,
                                  dueDate: t.dueDate,
                                  status: t.status,
                                  priority: t.priority,
                                  onTap: () =>
                                      context.push('/task-detail/${t.id}'))),
                        ],
                        if (tasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Center(
                                child: Text('No tasks'.tr(context),
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        color: c.gray400))),
                          ),
                      ]),
                    ))),
          ]);
        },
      ),
    );
  }

  Widget _topStat(String v, String l, Color bg, Color fg) =>
      Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: bg.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: fg.withOpacity(0.3))),
              child: Column(children: [
                Text(v,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: fg,
                        height: 1.1)),
                Text(l,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: Colors.white70)),
              ])));
}

// ═══════════════════════════════════════════════════════════════════════════
// All Tasks (with filters)
// ═══════════════════════════════════════════════════════════════════════════

class AllTasksScreen extends ConsumerStatefulWidget {
  const AllTasksScreen({super.key});
  @override
  ConsumerState<AllTasksScreen> createState() => _AllTasksState();
}

class _AllTasksState extends ConsumerState<AllTasksScreen> {
  int _tab = 0;

  /// Status values matching backend (Postman 06 uses TODO/IN_PROGRESS/DONE).
  /// We send those raw values; the model normalizes for display.
  static const _statusValues = <String?>[
    null,
    'IN_PROGRESS',
    'TODO',
    'OVERDUE',
    'DONE',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final tasksAsync = ref.watch(paginatedTasksProvider);
    final filters = ref.watch(tasksFiltersProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(
            title: 'All Tasks'.tr(context),
            onBack: () => context.pop()),
        FilterBar(
          tabs: [
            'All'.tr(context),
            'In Progress'.tr(context),
            'Pending'.tr(context),
            'Overdue'.tr(context),
            'Completed'.tr(context),
          ],
          selected: _tab,
          onSelect: (i) {
            setState(() => _tab = i);
            ref.read(tasksFiltersProvider.notifier).update(
                  (f) => f.copyWith(status: _statusValues[i]),
                );
          },
        ),
        // Search + Filter
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: c.gray200),
                ),
                child: TextField(
                  controller: TextEditingController(text: filters.search ?? '')
                    ..selection = TextSelection.collapsed(
                        offset: (filters.search ?? '').length),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) => ref
                      .read(tasksFiltersProvider.notifier)
                      .update((f) => f.copyWith(search: v.trim().isEmpty ? null : v.trim())),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search tasks'.tr(context),
                    hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5,
                        color: c.gray400),
                    prefixIcon: Icon(Icons.search,
                        size: 18, color: c.gray400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () async {
                final updated = await showTasksFiltersSheet(
                  context,
                  initial: ref.read(tasksFiltersProvider),
                );
                if (updated != null) {
                  ref.read(tasksFiltersProvider.notifier).state = updated;
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: filters.hasAnyAdvanced
                      ? AppColors.teal.withOpacity(0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                      color: filters.hasAnyAdvanced
                          ? AppColors.teal
                          : c.gray200),
                ),
                child: Icon(Icons.tune_rounded,
                    size: 20,
                    color: filters.hasAnyAdvanced
                        ? AppColors.teal
                        : c.textSecondary),
              ),
            ),
          ]),
        ),
        // Active filter chips
        if (filters.hasAnyAdvanced)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _activeFilterChips(filters, ref, context),
              ),
            ),
          ),
        Expanded(
            child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text('${'Error'.tr(context)}: $e',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14))),
          data: (paginated) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedTasksProvider);
                await ref.read(paginatedTasksProvider.future);
              },
              child: PaginatedListView<AdminTaskItem>(
                items: paginated.items,
                isLoadingMore: paginated.isLoadingMore,
                hasMore: paginated.hasMore,
                loadMoreError: paginated.loadMoreError,
                onFetchMore: () =>
                    ref.read(paginatedTasksProvider.notifier).fetchMore(),
                emptyWidget: Center(
                    child: Text('No tasks'.tr(context),
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: c.gray400))),
                itemBuilder: (context, t, index) {
                  return TaskCard(
                      id: t.id.toString(),
                      title: t.title,
                      assignedTo: t.assignedTo.name,
                      dept: t.department.name,
                      dueDate: t.dueDate,
                      status: t.status,
                      priority: t.priority,
                      onTap: () => context.push('/task-detail/${t.id}'));
                },
              ),
            );
          },
        )),
      ]),
    );
  }

  List<Widget> _activeFilterChips(
      TasksFilters f, WidgetRef ref, BuildContext context) {
    final chips = <Widget>[];
    void add(String label, VoidCallback onClear) => chips.add(Padding(
          padding: const EdgeInsetsDirectional.only(end: 6),
          child: _ChipPill(label: label, onClear: onClear),
        ));

    if (f.search != null && f.search!.isNotEmpty) {
      add('🔍 ${f.search}', () {
        ref
            .read(tasksFiltersProvider.notifier)
            .update((s) => s.copyWith(search: null));
      });
    }
    if (f.priority != null) {
      add('${'Priority'.tr(context)}: ${f.priority!.toLowerCase().tr(context)}',
          () {
        ref
            .read(tasksFiltersProvider.notifier)
            .update((s) => s.copyWith(priority: null));
      });
    }
    if (f.type != null) {
      add('${'Type'.tr(context)}: ${f.type!.tr(context)}', () {
        ref
            .read(tasksFiltersProvider.notifier)
            .update((s) => s.copyWith(type: null));
      });
    }
    if (f.dueFrom != null) {
      add('${'Due from'.tr(context)}: ${f.dueFrom}', () {
        ref
            .read(tasksFiltersProvider.notifier)
            .update((s) => s.copyWith(dueFrom: null));
      });
    }
    if (f.dueTo != null) {
      add('${'Due to'.tr(context)}: ${f.dueTo}', () {
        ref
            .read(tasksFiltersProvider.notifier)
            .update((s) => s.copyWith(dueTo: null));
      });
    }
    if (f.projectId != null) {
      add('${'Project ID'.tr(context)}: ${f.projectId}', () {
        ref
            .read(tasksFiltersProvider.notifier)
            .update((s) => s.copyWith(projectId: null));
      });
    }
    if (f.assigneeEmployeeId != null) {
      add('${'Assignee ID'.tr(context)}: ${f.assigneeEmployeeId}', () {
        ref
            .read(tasksFiltersProvider.notifier)
            .update((s) => s.copyWith(assigneeEmployeeId: null));
      });
    }
    return chips;
  }
}

class _ChipPill extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _ChipPill({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.teal.withOpacity(0.30)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.teal)),
        const SizedBox(width: 6),
        InkWell(
          onTap: onClear,
          child: const Icon(Icons.close_rounded,
              size: 14, color: AppColors.teal),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Task Detail (read-only with tabs: info / comments / time-logs / attachments)
// ═══════════════════════════════════════════════════════════════════════════

class TaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailState();
}

class _TaskDetailState extends ConsumerState<TaskDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      backgroundColor: c.bg,
      body: taskAsync.when(
        loading: () => Column(children: [
          AdminAppBar(
              title: 'Task Details'.tr(context),
              onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          AdminAppBar(
              title: 'Task Details'.tr(context),
              onBack: () => context.pop()),
          Expanded(
              child: Center(
                  child: Text('${'Error'.tr(context)}: $e',
                      style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 14)))),
        ]),
        data: (t) => Column(children: [
          AdminAppBar(
              title: 'Task Details'.tr(context),
              subtitle: '#${t.id}',
              onBack: () => context.pop()),
          // Header card
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: AppCard(
                mb: 12,
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PriorityBadge(priority: t.priority),
                        StatusBadge(
                          text: _statusLabel(context, t.status),
                          type: _statusType(t.status),
                          dot: true,
                        ),
                      ]),
                  const SizedBox(height: 10),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text(t.title,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w800))),
                  if (t.progressPercent != null) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: (t.progressPercent! / 100)
                                    .clamp(0.0, 1.0),
                                minHeight: 7,
                                backgroundColor: c.gray100,
                                color: AppColors.teal,
                              ))),
                      const SizedBox(width: 10),
                      Text('${t.progressPercent}%',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.teal)),
                    ]),
                  ],
                ])),
          ),
          // Tabs
          _DetailTabs(
            tabs: [
              'Info'.tr(context),
              'Comments'.tr(context),
              'Time logs'.tr(context),
              'Attachments'.tr(context),
            ],
            selected: _tab,
            onSelect: (i) => setState(() => _tab = i),
          ),
          Expanded(
              child: IndexedStack(index: _tab, children: [
            _InfoTab(task: t),
            _CommentsTab(taskId: t.id),
            _TimeLogsTab(taskId: t.id),
            _AttachmentsTab(taskId: t.id),
          ])),
        ]),
      ),
    );
  }

  String _statusLabel(BuildContext context, String s) {
    switch (s) {
      case 'in_progress':
        return 'In Progress'.tr(context);
      case 'overdue':
        return 'Overdue'.tr(context);
      case 'completed':
        return 'Completed'.tr(context);
      case 'cancelled':
        return 'Cancelled'.tr(context);
      default:
        return 'Pending'.tr(context);
    }
  }

  String _statusType(String s) {
    switch (s) {
      case 'overdue':
        return 'overdue';
      case 'in_progress':
      case 'completed':
        return 'teal';
      default:
        return 'pending';
    }
  }
}

// ── Tab bar ──
class _DetailTabs extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelect;
  const _DetailTabs(
      {required this.tabs, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.gray100,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1)),
                        ]
                      : null,
                ),
                child: Text(tabs[i],
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: active ? AppColors.teal : c.textSecondary)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Info Tab ──
class _InfoTab extends StatelessWidget {
  final AdminTaskItem task;
  const _InfoTab({required this.task});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
      child: Column(children: [
        AppCard(
            mb: 12,
            child: Column(children: [
              InfoRow(
                  label: 'Assigned To'.tr(context),
                  value: task.assignedTo.name.isEmpty
                      ? '—'
                      : task.assignedTo.name,
                  icon: '👤'),
              InfoRow(
                  label: 'Department'.tr(context),
                  value: task.department.name.isEmpty
                      ? '—'
                      : task.department.name,
                  icon: '🏢'),
              if (task.project != null)
                InfoRow(
                    label: 'Project'.tr(context),
                    value: task.project!.name ?? '#${task.project!.id}',
                    icon: '📁'),
              if (task.type != null)
                InfoRow(
                    label: 'Type'.tr(context),
                    value: task.type!.tr(context),
                    icon: '🏷️'),
              InfoRow(
                  label: 'Creation Date'.tr(context),
                  value: task.createdDate.isEmpty ? '—' : task.createdDate,
                  icon: '📅'),
              if (task.startDate != null)
                InfoRow(
                    label: 'Start Date'.tr(context),
                    value: task.startDate!,
                    icon: '🟢'),
              InfoRow(
                  label: 'Deadline'.tr(context),
                  value: task.dueDate.isEmpty ? '—' : task.dueDate,
                  icon: '⏰'),
              if (task.estimateMinutes != null)
                InfoRow(
                    label: 'Estimate'.tr(context),
                    value: '${task.estimateMinutes} min',
                    icon: '⏱️'),
              if (task.actualMinutes != null)
                InfoRow(
                    label: 'Actual'.tr(context),
                    value: '${task.actualMinutes} min',
                    icon: '⌛'),
              if (task.isBillable == true)
                InfoRow(
                    label: 'Billable'.tr(context),
                    value: 'Yes'.tr(context),
                    icon: '💰'),
              if (task.isUrgent == true)
                InfoRow(
                    label: 'Urgent'.tr(context),
                    value: 'Yes'.tr(context),
                    icon: '🔥',
                    border: false),
            ])),
        if ((task.description?.isNotEmpty ?? false))
          AppCard(
              mb: 0,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('Description'.tr(context),
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                    ),
                    Text(task.description!,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.5,
                            height: 1.5,
                            color: c.textSecondary)),
                  ])),
      ]),
    );
  }
}

// ── Comments Tab ──
class _CommentsTab extends ConsumerWidget {
  final int taskId;
  const _CommentsTab({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final async = ref.watch(taskCommentsProvider(taskId));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(taskCommentsProvider(taskId)),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: Text('${'Error'.tr(context)}: $e',
                      style:
                          const TextStyle(fontFamily: 'Cairo', fontSize: 13)))),
        ]),
        data: (items) {
          if (items.isEmpty) {
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                    child: Text('No comments'.tr(context),
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: c.gray400))),
              ),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final cm = items[i];
              return AppCard(
                  mb: 0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                AppColors.teal.withOpacity(0.12),
                            child: Text(
                                _initials(cm.employeeName ?? '#'),
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.teal)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                Text(cm.employeeName ?? '—',
                                    style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800)),
                                if (cm.createdAt != null)
                                  Text(cm.createdAt!,
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 10.5,
                                          color: c.gray400)),
                              ])),
                        ]),
                        const SizedBox(height: 10),
                        Text(cm.body,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.5,
                                height: 1.55,
                                color: c.textSecondary)),
                      ]));
            },
          );
        },
      ),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '#';
    if (parts.length == 1) return parts.first.characters.first;
    return parts.first.characters.first + parts.last.characters.first;
  }
}

// ── Time Logs Tab ──
class _TimeLogsTab extends ConsumerWidget {
  final int taskId;
  const _TimeLogsTab({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final async = ref.watch(taskTimeLogsProvider(taskId));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(taskTimeLogsProvider(taskId)),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: Text('${'Error'.tr(context)}: $e',
                      style:
                          const TextStyle(fontFamily: 'Cairo', fontSize: 13)))),
        ]),
        data: (logs) {
          if (logs.isEmpty) {
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                    child: Text('No time logs'.tr(context),
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: c.gray400))),
              ),
            ]);
          }
          final totalHours = logs.fold<double>(
              0, (sum, l) => sum + (l.hoursSpent ?? 0));

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
            children: [
              AppCard(
                  mb: 12,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total hours'.tr(context),
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w800)),
                        Text(totalHours.toStringAsFixed(2),
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.teal)),
                      ])),
              ...logs.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                        mb: 0,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(l.employeeName ?? '—',
                                            style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800))),
                                    Text(
                                        '${(l.hoursSpent ?? 0).toStringAsFixed(2)} h',
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.teal)),
                                  ]),
                              const SizedBox(height: 6),
                              if (l.logDate != null)
                                Text(
                                    '${l.logDate}'
                                    '${l.startTime != null ? '  ${l.startTime}' : ''}'
                                    '${l.endTime != null ? ' → ${l.endTime}' : ''}',
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11.5,
                                        color: c.textSecondary)),
                              if ((l.description ?? '').isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(l.description!,
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        height: 1.5,
                                        color: c.textSecondary)),
                              ],
                            ])),
                  )),
            ],
          );
        },
      ),
    );
  }
}

// ── Attachments Tab ──
class _AttachmentsTab extends ConsumerWidget {
  final int taskId;
  const _AttachmentsTab({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final async = ref.watch(taskAttachmentsProvider(taskId));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(taskAttachmentsProvider(taskId)),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: Text('${'Error'.tr(context)}: $e',
                      style:
                          const TextStyle(fontFamily: 'Cairo', fontSize: 13)))),
        ]),
        data: (items) {
          if (items.isEmpty) {
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                    child: Text('No attachments'.tr(context),
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: c.gray400))),
              ),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final att = items[i];
              return AppCard(
                  mb: 0,
                  child: Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.attach_file_rounded,
                          color: AppColors.teal, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(att.fileName ?? 'file',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800)),
                          if (att.sizeBytes != null)
                            Text(_fmtSize(att.sizeBytes!),
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: c.textSecondary)),
                          if (att.createdAt != null)
                            Text(att.createdAt!,
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10.5,
                                    color: c.gray400)),
                        ])),
                    if (att.fileUrl != null)
                      const Icon(Icons.open_in_new_rounded,
                          size: 18, color: AppColors.teal),
                  ]));
            },
          );
        },
      ),
    );
  }

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
