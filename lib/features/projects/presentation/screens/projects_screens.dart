import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/paginated_providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../data/models/project_models.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROJECT-SPECIFIC WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectProgressCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  const ProjectProgressCard({super.key, required this.project, this.onTap});

  Color get _statusColor {
    switch (project.status) {
      case 'active':    return AppColors.navyMid;
      case 'on_hold':   return AppColors.warning;
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.g400;
      default:          return AppColors.g400;
    }
  }

  String statusLabel(BuildContext context) {
    switch (project.status) {
      case 'active':    return 'Active'.tr(context);
      case 'on_hold':   return 'On Hold'.tr(context);
      case 'completed': return 'Completed'.tr(context);
      case 'cancelled': return 'Cancelled'.tr(context);
      default:          return project.status;
    }
  }

  String get _badgeType {
    switch (project.status) {
      case 'active':    return 'navy';
      case 'on_hold':   return 'pending';
      case 'completed': return 'approved';
      case 'cancelled': return 'overdue';
      default:          return 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
        border: Border(
          right: BorderSide(color: _statusColor, width: 4))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          // Header row
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              StatusBadge(text: statusLabel(context), type: _badgeType, dot: true),
              const SizedBox(width: 6),
              PriorityBadge(priority: project.priority),
              if (project.isDelayed) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft, borderRadius: BorderRadius.circular(6)),
                  child: Text('⏰ ${'Delayed'.tr(context)}', style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error))),
              ],
            ]),
            Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(project.name, style: TextStyle(fontFamily: 'Cairo',
                fontSize: 13, fontWeight: FontWeight.w800),
                textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(project.code, style: TextStyle(fontFamily: 'Cairo',
                fontSize: 10, color: c.gray400, letterSpacing: 0.5)),
            ])),
          ]),
          const SizedBox(height: 10),
          // Progress bar
          Row(children: [
            Text('${(project.progress * 100).toInt()}%', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 12, fontWeight: FontWeight.w800, color: _statusColor)),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor: c.gray100,
                  valueColor: AlwaysStoppedAnimation(_statusColor),
                  minHeight: 6)))),
            Text('tasks_progress'.tr(context, params: {'completed': '${project.completedTasks}', 'total': '${project.taskCount}'}),
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c.textMuted)),
          ]),
          const SizedBox(height: 10),
          // Footer meta
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${project.startDate ?? '-'} → ${project.endDate ?? '-'}',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c.textMuted),
              ),
            Row(children: [
              if (project.manager != null) ...[
                AdminAvatar(
                  initials: project.manager!.initials ?? project.manager!.name.substring(0, 2),
                  size: 24, fontSize: 10),
                const SizedBox(width: 6),
              ],
              Text(project.department ?? '', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 11, color: c.textMuted)),
            ]),
          ]),
        ]),
      ),
    ),
  );
  }
}

class MilestoneTimelineCard extends StatelessWidget {
  final ProjectMilestone milestone;
  final bool isLast;
  const MilestoneTimelineCard({
    super.key, required this.milestone, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final Color color = milestone.isCompleted ? AppColors.success
      : milestone.isDelayed ? AppColors.error
      : milestone.status == 'pending' ? c.gray300 : AppColors.navyMid;

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: color,
            boxShadow: milestone.isCompleted ? AppShadows.teal
              : milestone.isDelayed ? AppShadows.gold : null),
          child: Center(child: Icon(
            milestone.isCompleted ? Icons.check
              : milestone.isDelayed ? Icons.warning_rounded
              : Icons.radio_button_unchecked,
            color: Colors.white, size: 14))),
        if (!isLast) Container(width: 2, height: 32, color: color.withOpacity(0.3)),
      ]),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6)),
              child: Text('📅 ${milestone.targetDate ?? '-'}', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 10, fontWeight: FontWeight.w600, color: color))),
          ]),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(milestone.title, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 12, fontWeight: FontWeight.w700,
              color: milestone.isCompleted ? c.textMuted : c.textPrimary),
              textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (milestone.isDelayed)
              Text('⚠️ ${'Deadline exceeded'.tr(context)}', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
          ])),
        ]),
      )),
    ]);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. PROJECTS OVERVIEW SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectsOverviewScreen extends ConsumerWidget {
  const ProjectsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final projectsAsync = ref.watch(paginatedProjectsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error loading projects'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, color: AppColors.error)),
            const SizedBox(height: 8),
            OutlineBtn(text: 'Retry'.tr(context),
              onTap: () => ref.invalidate(paginatedProjectsProvider)),
          ],
        )),
        data: (paginated) {
          final projects = paginated.items;
          final active    = projects.where((p) => p.status == 'active').length;
          final onHold    = projects.where((p) => p.status == 'on_hold').length;
          final completed = projects.where((p) => p.status == 'completed').length;
          final delayed   = projects.where((p) => p.isDelayed).length;

          return Column(children: [
            // ── Header ─────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 18, left: 18, right: 18),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => context.push('/projects-list'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text('View all'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)))),
                  Expanded(child: Column(children: [
                    Text('Project Management'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('projects_total'.tr(context, params: {'count': '${projects.length}'}), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, color: AppColors.goldLight)),
                  ])),
                  const SizedBox(width: 36),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _pill('$active',    'Active'.tr(context),     AppColors.navyBright),
                  const SizedBox(width: 8),
                  _pill('$onHold',    'On Hold'.tr(context),    AppColors.warning),
                  const SizedBox(width: 8),
                  _pill('$completed', 'Completed'.tr(context),   AppColors.success),
                  const SizedBox(width: 8),
                  _pill('${projects.length}', 'Total'.tr(context), Colors.white54),
                ]),
              ]),
            ),
            Expanded(child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedProjectsProvider);
                await ref.read(paginatedProjectsProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                child: Column(children: [

                  // Alerts
                  if (delayed > 0) AlertBanner(
                    message: 'delayed_projects_alert'.tr(context, params: {'count': '$delayed'}),
                    type: 'error'),

                  // KPI cards row
                  SectionHeader(title: 'Operational overview'.tr(context)),
                  Row(children: [
                    _kpiTile(context, projects.isNotEmpty
                      ? '${(projects.fold(0.0, (s, p) => s + p.progress) / projects.length * 100).toInt()}%'
                      : '0%',
                      'Average completion'.tr(context), AppColors.navyMid, '📊'),
                    const SizedBox(width: 10),
                    _kpiTile(context, '${projects.fold(0, (s, p) => s + p.taskCount)}',
                      'Total tasks'.tr(context), AppColors.teal, '✅'),
                    const SizedBox(width: 10),
                    _kpiTile(context, '$delayed',
                      'Delayed projects'.tr(context), AppColors.error, '⏰'),
                  ]),
                  const SizedBox(height: 16),

                  // Active projects
                  SectionHeader(title: 'Active projects'.tr(context),
                    actionLabel: 'View all'.tr(context),
                    onAction: () => context.push('/projects-list')),
                  ...projects.where((p) => p.status == 'active').map((p) =>
                    ProjectProgressCard(project: p,
                      onTap: () => context.push('/project-detail/${p.id}'))),

                  // Delayed projects
                  if (delayed > 0) ...[
                    SectionHeader(title: 'Delayed projects'.tr(context),
                      actionLabel: 'Follow-up'.tr(context),
                      onAction: () => context.push('/project-follow-up')),
                    ...projects.where((p) => p.isDelayed).map((p) =>
                      ProjectProgressCard(project: p,
                        onTap: () => context.push('/project-detail/${p.id}'))),
                  ],

                  const SizedBox(height: 10),

                  // Completed
                  if (completed > 0) ...[
                    SectionHeader(title: 'Completed projects'.tr(context)),
                    ...projects.where((p) => p.status == 'completed').map((p) =>
                      ProjectProgressCard(project: p,
                        onTap: () => context.push('/project-detail/${p.id}'))),
                  ],
                ]),
              ),
            )),
            StickyBar(child: Row(children: [
              Expanded(child: OutlineBtn(text: '📊 ${'Analytics'.tr(context)}',
                onTap: () => context.push('/project-analytics'))),
              const SizedBox(width: 10),
              Expanded(child: PrimaryBtn(text: '+ ${'New project'.tr(context)}', icon: '🏗',
                onTap: () {})),
            ])),
          ]);
        },
      ),
    );
  }

  Widget _pill(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
    ])));

  Widget _kpiTile(BuildContext context, String v, String l, Color col, String ico) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.appColors.bgCard, borderRadius: BorderRadius.circular(14),
      boxShadow: AppShadows.card,
      border: Border(bottom: BorderSide(color: col, width: 3))),
    child: Column(children: [
      Text(ico, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(v, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 20, fontWeight: FontWeight.w900, color: col, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: col.withOpacity(0.6)),
        textAlign: TextAlign.center),
    ])));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. PROJECTS LIST SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});
  @override ConsumerState<ProjectsListScreen> createState() => _ProjectsListState();
}
class _ProjectsListState extends ConsumerState<ProjectsListScreen> {
  int _tab = 0;
  String _search = '';

  static const _statusFilters = [null, 'active', 'on_hold', 'completed', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final projectsAsync = ref.watch(paginatedProjectsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'Projects'.tr(context),
          subtitle: projectsAsync.whenOrNull(data: (d) => 'projects_total'.tr(context, params: {'count': '${d.items.length}'})) ?? '',
          onBack: () => context.pop()),
        Container(color: c.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: TextField(
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            onChanged: (v) => setState(() => _search = v),
            decoration: fieldDec(context, 'Search'.tr(context)).copyWith(
              prefixIcon: Icon(Icons.search, color: c.gray400, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
        FilterBar(tabs: ['All'.tr(context), 'Active'.tr(context), 'On Hold'.tr(context), 'Completed'.tr(context), 'Cancelled'.tr(context)],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: projectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading projects'.tr(context), style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context),
                onTap: () => ref.invalidate(paginatedProjectsProvider)),
            ],
          )),
          data: (paginated) {
            final filtered = paginated.items.where((p) {
              final matchSearch = _search.isEmpty ||
                p.name.contains(_search) || p.code.contains(_search);
              final statusFilter = _statusFilters[_tab];
              final matchTab = statusFilter == null || p.status == statusFilter;
              return matchSearch && matchTab;
            }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedProjectsProvider);
                await ref.read(paginatedProjectsProvider.future);
              },
              child: PaginatedListView<Project>(
                items: filtered,
                isLoadingMore: paginated.isLoadingMore,
                hasMore: _tab == 0 && _search.isEmpty ? paginated.hasMore : false,
                loadMoreError: paginated.loadMoreError,
                onFetchMore: () => ref.read(paginatedProjectsProvider.notifier).fetchMore(),
                emptyWidget: Center(child: EmptyState(icon: '🏗', title: 'No projects'.tr(context),
                  subtitle: 'No matching projects'.tr(context))),
                itemBuilder: (_, p, i) => ProjectProgressCard(
                  project: p,
                  onTap: () => context.push('/project-detail/${p.id}')),
              ),
            );
          },
        )),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. PROJECT DETAIL SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectDetailScreen extends ConsumerWidget {
  final int projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final projectAsync = ref.watch(projectDetailProvider(projectId));
    final milestonesAsync = ref.watch(projectMilestonesProvider(projectId));

    return Scaffold(
      backgroundColor: c.bg,
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error loading projects'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, color: AppColors.error)),
            const SizedBox(height: 8),
            OutlineBtn(text: 'Retry'.tr(context),
              onTap: () {
                ref.invalidate(projectDetailProvider(projectId));
                ref.invalidate(projectMilestonesProvider(projectId));
              }),
          ],
        )),
        data: (p) {
          final String statusLabel = _projectStatusLabel(context, p.status);

          return Column(children: [
            Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 20, left: 18, right: 18),
              child: Column(children: [
                Row(children: [
                  GestureDetector(onTap: () => context.pop(),
                    child: Container(width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
                  Expanded(child: Column(children: [
                    Text(p.name, style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      textAlign: TextAlign.center, maxLines: 2),
                    Text(p.code, style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, color: AppColors.goldLight, letterSpacing: 1)),
                  ])),
                  const SizedBox(width: 36),
                ]),
                const SizedBox(height: 14),
                // Progress display
                Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white10, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12)),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        StatusBadge(text: statusLabel, type: 'teal', dot: true),
                        const SizedBox(width: 8),
                        PriorityBadge(priority: p.priority),
                      ]),
                      Text('${(p.progress * 100).toInt()}% مكتمل', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: p.progress, backgroundColor: Colors.white.withValues(alpha: 0.20),
                        valueColor: const AlwaysStoppedAnimation(AppColors.goldLight),
                        minHeight: 10)),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _heroStat('${p.completedTasks}/${p.taskCount}', 'المهام', '✅'),
                      milestonesAsync.when(
                        loading: () => _heroStat('...', 'المراحل', '🏁'),
                        error: (_, _) => _heroStat('-', 'المراحل', '🏁'),
                        data: (ms) => _heroStat(
                          '${ms.where((m) => m.isCompleted).length}/${ms.length}',
                          'المراحل', '🏁'),
                      ),
                      _heroStat('${p.milestoneCount}', 'معالم', '📌'),
                    ]),
                  ]),
                ),
              ]),
            ),
            Expanded(child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(projectDetailProvider(projectId));
                ref.invalidate(projectMilestonesProvider(projectId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                child: Column(children: [

                  // Quick nav tabs
                  Row(children: [
                    _quickNav(context, '📋 المهام',    '/project-tasks/$projectId'),
                    const SizedBox(width: 8),
                    _quickNav(context, '🏁 المراحل',  '/project-milestones/$projectId'),
                    const SizedBox(width: 8),
                    _quickNav(context, '🔄 متابعة',   '/project-follow-up'),
                    const SizedBox(width: 8),
                    _quickNav(context, '📊 تحليل',    '/project-analytics/$projectId'),
                  ]),
                  const SizedBox(height: 14),

                  // Project info
                  AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('بيانات المشروع', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    InfoRow(label: 'المدير المسؤول', value: p.manager?.name ?? '-', icon: '👤'),
                    InfoRow(label: 'الإدارة',         value: p.department ?? '-',     icon: '🏢'),
                    InfoRow(label: 'تاريخ البداية',   value: p.startDate ?? '-',      icon: '🟢'),
                    InfoRow(label: 'تاريخ الانتهاء', value: p.endDate ?? '-',        icon: '🔴'),
                    InfoRow(label: 'الأولوية',
                      value: p.priority == 'high' ? 'عالية' : p.priority == 'low' ? 'منخفضة' : 'متوسطة',
                      icon: '📌', border: false),
                  ])),

                  // Description
                  if (p.description != null && p.description!.isNotEmpty)
                    AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('وصف المشروع', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(p.description!, style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 13, color: c.textSecondary, height: 1.8)),
                    ])),

                  // Milestones preview
                  SectionHeader(title: 'المراحل الرئيسية',
                    actionLabel: 'View all'.tr(context),
                    onAction: () => context.push('/project-milestones/$projectId')),
                  milestonesAsync.when(
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator())),
                    error: (_, _) => AppCard(mb: 14, child: const EmptyState(
                      icon: '🏁', title: 'خطأ في تحميل المراحل', subtitle: '')),
                    data: (milestones) => milestones.isEmpty
                      ? AppCard(mb: 14, child: EmptyState(
                          icon: '🏁', title: 'No milestones'.tr(context), subtitle: 'No milestones added yet'.tr(context)))
                      : AppCard(mb: 14, child: Column(children:
                          milestones.take(5).toList().asMap().entries.map((e) =>
                            MilestoneTimelineCard(
                              milestone: e.value,
                              isLast: e.key == milestones.take(5).length - 1)).toList())),
                  ),

                  // Tasks summary
                  SectionHeader(title: 'المهام المرتبطة',
                    actionLabel: 'View all'.tr(context),
                    onAction: () => context.push('/project-tasks/$projectId')),
                  Row(children: [
                    _taskStat('${p.completedTasks}', 'Completed'.tr(context), AppColors.success),
                    const SizedBox(width: 8),
                    _taskStat('${p.taskCount - p.completedTasks}', 'أخرى', AppColors.teal),
                    const SizedBox(width: 8),
                    _taskStat('${p.taskCount}', 'All'.tr(context), AppColors.navyMid),
                  ]),
                  const SizedBox(height: 14),

                  // Team & Files placeholders
                  AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('فريق المشروع', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    if (p.manager != null)
                      Row(children: [
                        const Spacer(),
                        AdminAvatar(
                          initials: p.manager!.initials ?? p.manager!.name.substring(0, 2),
                          size: 36, fontSize: 13),
                        const SizedBox(width: 8),
                        Text(p.manager!.name, style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 11, color: AppColors.navyMid, fontWeight: FontWeight.w600)),
                      ])
                    else
                      const EmptyState(icon: '👥', title: 'لا يوجد فريق', subtitle: ''),
                  ])),

                  AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('المرفقات والوثائق', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const EmptyState(icon: '📎', title: 'لا توجد مرفقات',
                      subtitle: 'لم يتم رفع وثائق بعد لهذا المشروع'),
                  ])),
                ]),
              ),
            )),
            StickyBar(child: Row(children: [
              Expanded(child: OutlineBtn(text: '🔄 متابعة',
                onTap: () => context.push('/project-follow-up'))),
              const SizedBox(width: 10),
              Expanded(child: TealBtn(text: '📋 المهام',
                onTap: () => context.push('/project-tasks/$projectId'))),
            ])),
          ]);
        },
      ),
    );
  }

  String _projectStatusLabel(BuildContext context, String status) {
    switch (status) {
      case 'active':    return 'Active'.tr(context);
      case 'on_hold':   return 'On Hold'.tr(context);
      case 'completed': return 'Completed'.tr(context);
      case 'cancelled': return 'Cancelled'.tr(context);
      default:          return status;
    }
  }

  Widget _heroStat(String v, String l, String ico) => Column(children: [
    Text(ico, style: const TextStyle(fontSize: 16)),
    Text(v, style: TextStyle(fontFamily: 'Cairo',
      fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white60)),
  ]);

  Widget _quickNav(BuildContext ctx, String label, String route) => Expanded(
    child: GestureDetector(
      onTap: () => ctx.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: ctx.appColors.bgCard, borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.sm),
        child: Center(child: Text(label, style: TextStyle(fontFamily: 'Cairo',
          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navyMid),
          textAlign: TextAlign.center)))));

  Widget _taskStat(String v, String l, Color col) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: col.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: col.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 20, fontWeight: FontWeight.w900, color: col, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: col.withOpacity(0.6))),
    ])));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. PROJECT TASKS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectTasksScreen extends ConsumerStatefulWidget {
  final int projectId;
  const ProjectTasksScreen({super.key, required this.projectId});
  @override ConsumerState<ProjectTasksScreen> createState() => _ProjectTasksState();
}
class _ProjectTasksState extends ConsumerState<ProjectTasksScreen> {
  int _tab = 0;

  static const _statusFilters = [null, 'in_progress', 'pending', 'overdue', 'completed'];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));

    final subtitleText = projectAsync.whenOrNull(
      data: (p) => '${p.code} · ${p.name}',
    ) ?? '';

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'Project tasks'.tr(context),
          subtitle: subtitleText,
          onBack: () => context.pop()),
        // Summary strip
        tasksAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (tasks) => Container(color: c.bgCard,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(children: [
              _statChip('${tasks.length}', 'All'.tr(context), AppColors.navyMid),
              const SizedBox(width: 8),
              _statChip('${tasks.where((t) => t.status == 'in_progress').length}', 'In Progress'.tr(context), AppColors.teal),
              const SizedBox(width: 8),
              _statChip('${tasks.where((t) => t.status == 'overdue').length}', 'Delayed'.tr(context), AppColors.error),
              const SizedBox(width: 8),
              _statChip('${tasks.where((t) => t.status == 'pending').length}', 'Pending'.tr(context), AppColors.warning),
            ])),
        ),
        FilterBar(tabs: ['All'.tr(context), 'In Progress'.tr(context), 'Pending'.tr(context), 'Delayed'.tr(context), 'Completed'.tr(context)],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading projects'.tr(context), style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context),
                onTap: () => ref.invalidate(projectTasksProvider(widget.projectId))),
            ],
          )),
          data: (tasks) {
            final statusFilter = _statusFilters[_tab];
            final filtered = statusFilter == null
              ? tasks
              : tasks.where((t) => t.status == statusFilter).toList();

            if (filtered.isEmpty) {
              return EmptyState(icon: '📋', title: 'No tasks'.tr(context),
                subtitle: 'No matching tasks'.tr(context));
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(projectTasksProvider(widget.projectId)),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final t = filtered[i];
                  return _ProjectTaskCard(task: t);
                },
              ),
            );
          },
        )),
      ]),
    );
  }

  Widget _statChip(String v, String l, Color col) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: col.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10), border: Border.all(color: col.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w900, color: col, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: col.withOpacity(0.6))),
    ])));
}

class _ProjectTaskCard extends StatelessWidget {
  final ProjectTask task;
  const _ProjectTaskCard({required this.task});

  Color get _statusColor {
    switch (task.status) {
      case 'completed':   return AppColors.success;
      case 'in_progress': return AppColors.teal;
      case 'overdue':     return AppColors.error;
      case 'pending':     return AppColors.warning;
      default:            return AppColors.g400;
    }
  }

  String statusLabel(BuildContext context) {
    switch (task.status) {
      case 'completed':   return 'Completed'.tr(context);
      case 'in_progress': return 'In Progress'.tr(context);
      case 'overdue':     return 'Delayed'.tr(context);
      case 'pending':     return 'Pending'.tr(context);
      default:            return task.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
        border: Border(right: BorderSide(color: _statusColor, width: 3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            StatusBadge(text: statusLabel(context),
              type: task.status == 'completed' ? 'approved'
                : task.status == 'overdue' ? 'overdue'
                : task.status == 'in_progress' ? 'teal' : 'pending',
              dot: true),
            const SizedBox(width: 6),
            PriorityBadge(priority: task.priority),
          ]),
          Flexible(child: Text(task.title, style: TextStyle(fontFamily: 'Cairo',
            fontSize: 13, fontWeight: FontWeight.w700),
            textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (task.dueDate != null)
            Text('📅 ${task.dueDate}', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 10, color: c.textMuted)),
          if (task.assignedTo != null)
            Row(children: [
              Text(task.assignedTo!.name, style: TextStyle(fontFamily: 'Cairo',
                fontSize: 11, color: c.textMuted)),
              const SizedBox(width: 4),
              AdminAvatar(
                initials: task.assignedTo!.name.length >= 2
                  ? task.assignedTo!.name.substring(0, 2) : task.assignedTo!.name,
                size: 22, fontSize: 9),
            ]),
        ]),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. PROJECT MILESTONES SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectMilestonesScreen extends ConsumerWidget {
  final int projectId;
  const ProjectMilestonesScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final milestonesAsync = ref.watch(projectMilestonesProvider(projectId));

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'Project milestones'.tr(context),
          subtitle: milestonesAsync.whenOrNull(
            data: (ms) => '${ms.length} مراحل',
          ) ?? '',
          onBack: () => context.pop()),
        milestonesAsync.when(
          loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Expanded(child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading projects'.tr(context), style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context),
                onTap: () => ref.invalidate(projectMilestonesProvider(projectId))),
            ],
          ))),
          data: (milestones) {
            if (milestones.isEmpty) {
              return Expanded(child: EmptyState(
                icon: '🏁', title: 'No milestones'.tr(context),
                subtitle: 'No milestones added yet'.tr(context)));
            }

            final completed = milestones.where((m) => m.isCompleted).length;
            final delayed   = milestones.where((m) => m.isDelayed).length;

            return Expanded(child: Column(children: [
              // Progress strip
              Container(color: c.bgCard,
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${(completed / milestones.length * 100).toInt()}%', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
                    Text('$completed/${milestones.length} مراحل مكتملة', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 13, fontWeight: FontWeight.w700, color: c.textSecondary)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: completed / milestones.length,
                      backgroundColor: c.gray100,
                      valueColor: const AlwaysStoppedAnimation(AppColors.navyMid),
                      minHeight: 10)),
                  if (delayed > 0) ...[
                    const SizedBox(height: 8),
                    AlertBanner(message: '$delayed مرحلة متأخرة — يحتاج متابعة', type: 'error'),
                  ],
                ])),
              Expanded(child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(projectMilestonesProvider(projectId)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: AppCard(child: Column(children:
                    milestones.asMap().entries.map((e) => MilestoneTimelineCard(
                      milestone: e.value,
                      isLast: e.key == milestones.length - 1)).toList())),
                ),
              )),
            ]));
          },
        ),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. PROJECT FOLLOW-UP SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectFollowUpScreen extends ConsumerWidget {
  const ProjectFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final projectsAsync = ref.watch(paginatedProjectsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error loading projects'.tr(context), style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
            const SizedBox(height: 8),
            OutlineBtn(text: 'Retry'.tr(context),
              onTap: () => ref.invalidate(paginatedProjectsProvider)),
          ],
        )),
        data: (paginated) {
          final delayedProjects = paginated.items.where((p) => p.isDelayed).toList();
          final activeProjects = paginated.items.where((p) => p.status == 'active').toList();
          final followUpProjects = [...delayedProjects, ...activeProjects.where((p) => !p.isDelayed)];

          return Column(children: [
            Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 14, left: 18, right: 18),
              child: Row(children: [
                GestureDetector(onTap: () => context.pop(),
                  child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
                Expanded(child: Column(children: [
                  Text('Project follow-up'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('${delayedProjects.length} متأخرة · ${followUpProjects.length} للمتابعة',
                    style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, color: AppColors.goldLight)),
                ])),
                const SizedBox(width: 36),
              ]),
            ),
            Expanded(child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(paginatedProjectsProvider),
              child: followUpProjects.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: EmptyState(icon: '✅', title: 'No projects to follow up'.tr(context),
                        subtitle: 'All projects on track'.tr(context))))
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      if (delayedProjects.isNotEmpty)
                        AlertBanner(
                          message: '${delayedProjects.length} مشاريع متأخرة تحتاج متابعة فورية',
                          type: 'error'),
                      ...followUpProjects.map((p) => _FollowUpProjectCard(
                        project: p,
                        onTap: () => context.push('/project-detail/${p.id}'))),
                    ],
                  ),
            )),
          ]);
        },
      ),
    );
  }
}

class _FollowUpProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  const _FollowUpProjectCard({required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDelayed = project.isDelayed;
    final borderColor = isDelayed ? AppColors.error : AppColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
          border: Border.all(color: borderColor.withOpacity(0.3))),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isDelayed ? AppColors.errorSoft : AppColors.warningSoft,
                borderRadius: BorderRadius.circular(6)),
              child: Text(
                isDelayed ? '⏰ ${'Delayed'.tr(context)}' : '🔄 نشط',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDelayed ? AppColors.error : AppColors.warningDark))),
            const SizedBox(height: 4),
            Text('${(project.progress * 100).toInt()}%',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                fontWeight: FontWeight.w900, color: borderColor)),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(project.name, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 13, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(project.code, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 10, color: c.gray400)),
            if (project.manager != null)
              Text(project.manager!.name, style: TextStyle(fontFamily: 'Cairo',
                fontSize: 11, color: c.textMuted)),
          ])),
          const SizedBox(width: 8),
          Text(isDelayed ? '⚠️' : '📋', style: const TextStyle(fontSize: 22)),
        ]),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. PROJECT ANALYTICS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectAnalyticsScreen extends ConsumerWidget {
  final int projectId;
  const ProjectAnalyticsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final analyticsAsync = ref.watch(projectAnalyticsProvider(projectId));
    final projectAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      backgroundColor: c.bg,
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error loading projects'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, color: AppColors.error)),
            const SizedBox(height: 8),
            OutlineBtn(text: 'Retry'.tr(context),
              onTap: () => ref.invalidate(projectAnalyticsProvider(projectId))),
          ],
        )),
        data: (analytics) {
          final projectName = projectAsync.whenOrNull(data: (p) => p.name) ?? '';

          return Column(children: [
            Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 14, left: 18, right: 18),
              child: Row(children: [
                GestureDetector(onTap: () => context.pop(),
                  child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
                Expanded(child: Column(children: [
                  Text('Project analysis'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  if (projectName.isNotEmpty)
                    Text(projectName, style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, color: AppColors.goldLight)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(9)),
                  child: Text('📤 ${'Export'.tr(context)}', style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyDeep))),
              ]),
            ),
            Expanded(child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(projectAnalyticsProvider(projectId)),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                child: Column(children: [

                  // Overall progress
                  SectionHeader(title: 'Completion rate'.tr(context)),
                  AppCard(mb: 16, child: Column(children: [
                    Text('${(analytics.progress * 100).toInt()}%', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: analytics.progress,
                        backgroundColor: c.gray100,
                        valueColor: const AlwaysStoppedAnimation(AppColors.navyMid),
                        minHeight: 10)),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _timelineStat(
                        analytics.timeline.isOnTrack ? '✅' : '⚠️',
                        analytics.timeline.isOnTrack ? 'في الموعد' : 'متأخر',
                        analytics.timeline.isOnTrack ? AppColors.success : AppColors.error),
                      _timelineStat('📅', '${analytics.timeline.daysRemaining} يوم متبقي', AppColors.navyMid),
                    ]),
                  ])),

                  // KPI cards
                  SectionHeader(title: 'Performance indicators'.tr(context)),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
                    padding: EdgeInsets.zero,
                    children: [
                      KpiCard(label: 'Total tasks'.tr(context),  value: '${analytics.tasks.total}',
                        change: '${analytics.tasks.completed} مكتملة', icon: '📋',
                        isPositive: true,  color: AppColors.navyMid),
                      KpiCard(label: 'مهام جارية',     value: '${analytics.tasks.inProgress}',
                        change: 'قيد التنفيذ', icon: '🚀',
                        isPositive: true,  color: AppColors.teal),
                      KpiCard(label: 'مهام متأخرة',    value: '${analytics.tasks.overdue}',
                        change: 'يحتاج متابعة', icon: '⏰',
                        isPositive: false, color: AppColors.error),
                      KpiCard(label: 'مهام معلقة',      value: '${analytics.tasks.pending}',
                        change: 'في الانتظار', icon: '⏳',
                        isPositive: true,  color: AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Milestone completion
                  SectionHeader(title: 'Key milestones status'.tr(context)),
                  AppCard(mb: 16, child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _circStat('${analytics.milestones.completed}', 'Completed'.tr(context),  AppColors.success),
                      _circStat('${analytics.milestones.overdue}',   'Delayed'.tr(context),  AppColors.error),
                      _circStat('${analytics.milestones.pending}',   'Pending'.tr(context),    AppColors.warning),
                      _circStat('${analytics.milestones.total}',     'إجمالية', AppColors.navyMid),
                    ]),
                  ])),

                  // Budget
                  SectionHeader(title: 'Budget'.tr(context)),
                  AppCard(mb: 16, child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${analytics.budget.spent.toStringAsFixed(0)} / ${analytics.budget.allocated.toStringAsFixed(0)}',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                          fontWeight: FontWeight.w800, color: AppColors.navyMid)),
                      Text('Budget'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 13, fontWeight: FontWeight.w700, color: c.textSecondary)),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: analytics.budget.allocated > 0
                          ? analytics.budget.spent / analytics.budget.allocated : 0,
                        backgroundColor: c.gray100,
                        valueColor: AlwaysStoppedAnimation(
                          analytics.budget.remaining < 0 ? AppColors.error : AppColors.teal),
                        minHeight: 8)),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('المتبقي: ${analytics.budget.remaining.toStringAsFixed(0)}',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                          color: analytics.budget.remaining < 0 ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600)),
                      Text('المصروف: ${analytics.budget.spent.toStringAsFixed(0)}',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: c.textMuted)),
                    ]),
                  ])),

                  // Timeline
                  SectionHeader(title: 'Timeline'.tr(context)),
                  AppCard(child: Column(children: [
                    InfoRow(label: 'تاريخ البداية', value: analytics.timeline.startDate ?? '-', icon: '🟢'),
                    InfoRow(label: 'تاريخ الانتهاء', value: analytics.timeline.endDate ?? '-', icon: '🔴'),
                    InfoRow(label: 'الأيام المتبقية', value: '${analytics.timeline.daysRemaining} يوم', icon: '📅'),
                    InfoRow(label: 'الحالة',
                      value: analytics.timeline.isOnTrack ? 'في الموعد' : 'متأخر عن الجدول',
                      icon: analytics.timeline.isOnTrack ? '✅' : '⚠️', border: false),
                  ])),
                ]),
              ),
            )),
          ]);
        },
      ),
    );
  }

  Widget _circStat(String v, String l, Color col) => Column(children: [
    Text(v, style: TextStyle(fontFamily: 'Cairo',
      fontSize: 22, fontWeight: FontWeight.w900, color: col, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: col.withOpacity(0.6), height: 1.3)),
  ]);

  Widget _timelineStat(String ico, String label, Color c) => Row(children: [
    Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
      fontWeight: FontWeight.w600, color: c)),
    const SizedBox(width: 4),
    Text(ico, style: const TextStyle(fontSize: 16)),
  ]);
}
