import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';

// ── Tasks Dashboard ───────────────────────────────────────
class TasksDashboardScreen extends ConsumerWidget {
  const TasksDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${'Error'.tr(context)}: $e',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14))),
        data: (data) {
          final tasks = data.tasks;
          final stats = data.stats;
          final overdue = stats.overdue;
          final inProgress = stats.inProgress;
          final pending = stats.pending;
          return Column(children: [
            Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 16, left: 18, right: 18),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => context.push('/all-tasks'),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text('View all'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)))),
                  Expanded(child: Column(children: [
                    Text('Task Management'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('tasks_total'.tr(context, params: {'count': '${stats.total}'}), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
                  ])),
                  const SizedBox(width: 36),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _topStat('${stats.total}', 'All'.tr(context),    AppColors.navySoft,    AppColors.goldLight),
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
              onRefresh: () async => ref.invalidate(tasksProvider),
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
    final tasksAsync = ref.watch(tasksProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
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
          data: (data) {
            final tasks = data.tasks;
            if (tasks.isEmpty) {
              return Center(child: Text('No tasks'.tr(context),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.g400)));
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(tasksProvider),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: tasks.length,
                itemBuilder: (_, i) {
                  final t = tasks[i];
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
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                  const Divider(height: 20, color: AppColors.g100),
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
                    decoration: fieldDec('سجّل تعليق متابعة...')),
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
