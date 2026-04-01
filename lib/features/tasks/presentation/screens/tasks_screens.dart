import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/paginated_providers.dart';
import '../../../../core/providers/paginated_notifier.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../data/models/task_models.dart';

// ── Tasks Dashboard ───────────────────────────────────────
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
        error: (e, _) => Center(child: Text('${'Error'.tr(context)}: $e',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14))),
        data: (paginated) {
          final tasks = paginated.items;
          final stats = ref.read(paginatedTasksProvider.notifier).stats;
          final overdue = stats?.overdue ?? 0;
          final inProgress = stats?.inProgress ?? 0;
          final pending = stats?.pending ?? 0;
          return Column(children: [
            Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 16, left: 18, right: 18),
              child: Column(children: [
                Row(children: [
                  // START: زر الرجوع (يظهر فقط إذا كان هناك شيء للرجوع إليه)
                  if (context.canPop()) ...[
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: EdgeInsetsDirectional.only(start: 6),
                        alignment: AlignmentDirectional.center,
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18))),
                    const SizedBox(width: 6),
                  ],
                  // CENTER: العنوان
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('Task Management'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('tasks_total'.tr(context, params: {'count': '${stats?.total ?? 0}'}), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
                  ])),
                  // END: تحديث + عرض الكل
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    GestureDetector(
                      onTap: _refreshing ? null : _refresh,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: _refreshing
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.refresh, color: Colors.white, size: 18)))),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.push('/all-tasks'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(9)),
                        child: Text('View all'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)))),
                  ]),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _topStat('${stats?.total ?? 0}', 'All'.tr(context),    AppColors.navySoft,    AppColors.goldLight),
                  const SizedBox(width: 8),
                  _topStat('$inProgress',  'In Progress'.tr(context),  AppColors.tealSoft,    AppColors.tealLight),
                  const SizedBox(width: 8),
                  _topStat('$overdue',     'Overdue'.tr(context), AppColors.errorSoft,   AppColors.error),
                  const SizedBox(width: 8),
                  _topStat('$pending',     'Pending'.tr(context),  AppColors.warningSoft, AppColors.warning),
                ]),
              ]),
            ),
            Expanded(child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedTasksProvider);
                await ref.read(paginatedTasksProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // Overdue alert
                  if (overdue > 0) AlertBanner(
                    message: 'overdue_tasks_review'.tr(context, params: {'count': '$overdue'}),
                    type: 'error'),
                  SectionHeader(title: 'Overdue Tasks'.tr(context),
                    actionLabel: 'View all'.tr(context), onAction: () => context.push('/all-tasks')),
                  ...tasks.where((t) => t.status == 'overdue').map((t) =>
                    TaskCard(id: t.id.toString(), title: t.title, assignedTo: t.assignedTo.name,
                      dept: t.department.name, dueDate: t.dueDate, status: t.status, priority: t.priority,
                      onTap: () => context.push('/task-detail/${t.id}'))),
                  const SizedBox(height: 10),
                  SectionHeader(title: 'In Progress Tasks'.tr(context)),
                  ...tasks.where((t) => t.status == 'in_progress').map((t) =>
                    TaskCard(id: t.id.toString(), title: t.title, assignedTo: t.assignedTo.name,
                      dept: t.department.name, dueDate: t.dueDate, status: t.status, priority: t.priority,
                      onTap: () => context.push('/task-detail/${t.id}'))),
                  const SizedBox(height: 10),
                  SectionHeader(title: 'Pending Tasks'.tr(context)),
                  ...tasks.where((t) => t.status == 'pending').map((t) =>
                    TaskCard(id: t.id.toString(), title: t.title, assignedTo: t.assignedTo.name,
                      dept: t.department.name, dueDate: t.dueDate, status: t.status, priority: t.priority,
                      onTap: () => context.push('/task-detail/${t.id}'))),
                ]),
              ),
            )),
            StickyBar(child: PrimaryBtn(text: 'Create New Task'.tr(context), icon: '✏️',
              onTap: () => context.push('/create-task'))),
          ]);
        },
      ),
    );
  }
  Widget _topStat(String v, String l, Color bg, Color fg) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: bg.withOpacity(0.2), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: fg.withOpacity(0.3))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: fg, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
    ])));
}

// ── All Tasks List ────────────────────────────────────────
class AllTasksScreen extends ConsumerStatefulWidget {
  const AllTasksScreen({super.key});
  @override ConsumerState<AllTasksScreen> createState() => _AllTasksState();
}
class _AllTasksState extends ConsumerState<AllTasksScreen> {
  int _tab = 0;

  static const _statusValues = <String?>[null, 'in_progress', 'pending', 'overdue', 'completed'];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final tasksAsync = ref.watch(paginatedTasksProvider);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'All Tasks'.tr(context), onBack: () => context.pop()),
        FilterBar(tabs: ['All'.tr(context),'In Progress'.tr(context),'Pending'.tr(context),'Overdue'.tr(context),'Completed'.tr(context)],
          selected: _tab, onSelect: (i) {
            setState(() => _tab = i);
            ref.read(tasksStatusFilter.notifier).state = _statusValues[i];
          }),
        Expanded(child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${'Error'.tr(context)}: $e',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14))),
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
                onFetchMore: () => ref.read(paginatedTasksProvider.notifier).fetchMore(),
                emptyWidget: Center(child: Text('No tasks'.tr(context),
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.gray400))),
                itemBuilder: (context, t, index) {
                  return TaskCard(id: t.id.toString(), title: t.title, assignedTo: t.assignedTo.name,
                    dept: t.department.name, dueDate: t.dueDate, status: t.status, priority: t.priority,
                    onTap: () => context.push('/task-detail/${t.id}'));
                },
              ),
            );
          },
        )),
      ]),
    );
  }
}

// ── Task Detail ───────────────────────────────────────────
class TaskDetailScreen extends ConsumerWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    return Scaffold(
      backgroundColor: c.bg,
      body: taskAsync.when(
        loading: () => Column(children: [
          AdminAppBar(title: 'Task Details'.tr(context), onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          AdminAppBar(title: 'Task Details'.tr(context), onBack: () => context.pop()),
          Expanded(child: Center(child: Text('${'Error'.tr(context)}: $e',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14)))),
        ]),
        data: (t) => Column(children: [
          AdminAppBar(title: 'Task Details'.tr(context), subtitle: t.id.toString(),
            onBack: () => context.pop()),
          Expanded(child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(taskDetailProvider(taskId)),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                AppCard(mb: 14, child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    PriorityBadge(priority: t.priority),
                    StatusBadge(text: t.status == 'in_progress' ? 'In Progress'.tr(context) : t.status == 'overdue' ? 'Overdue'.tr(context) : t.status == 'completed' ? 'Completed'.tr(context) : 'Pending'.tr(context),
                      type: t.status == 'overdue' ? 'overdue' : t.status == 'in_progress' ? 'teal' : t.status == 'completed' ? 'teal' : 'pending', dot: true),
                  ]),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: Text(t.title,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800))),
                  Divider(height: 20, color: c.gray100),
                  InfoRow(label: 'Assigned To'.tr(context),  value: t.assignedTo.name, icon: '👤'),
                  InfoRow(label: 'Department'.tr(context),       value: t.department.name, icon: '🏢'),
                  InfoRow(label: 'Creation Date'.tr(context), value: t.createdDate,     icon: '📅'),
                  InfoRow(label: 'Deadline'.tr(context), value: t.dueDate,        icon: '⏰'),
                  if (t.notes != null) InfoRow(label: 'Notes'.tr(context), value: t.notes!, icon: '📝', border: false),
                ])),
                AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('متابعة التنفيذ', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
                  const SizedBox(height: 14),
                  const TimelineWidget(steps: [
                    TLStep(label: 'إنشاء المهمة', sub: 'إدارة الموارد البشرية — 1 مارس', done: true),
                    TLStep(label: 'التكليف والبدء', sub: 'تم التكليف — 3 مارس', done: true),
                    TLStep(label: 'جارٍ التنفيذ', sub: 'آخر تحديث — 9 مارس', active: true),
                    TLStep(label: 'مراجعة ومتابعة'),
                    TLStep(label: 'الإغلاق والإتمام'),
                  ]),
                ])),
                AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('إضافة تعليق للمتابعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  TextField(maxLines: 3, 
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    decoration: fieldDec(context, 'سجّل تعليق متابعة...')),
                ])),
              ]),
            ),
          )),
          StickyBar(child: Row(children: [
            Expanded(child: OutlineBtn(text: '↩ إعادة تكليف', onTap: () {})),
            const SizedBox(width: 10),
            Expanded(child: TealBtn(text: '✓ تم الإنجاز', onTap: () {})),
          ])),
        ]),
      ),
    );
  }
}
