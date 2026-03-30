import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';
import '../../../shared/models/admin_models.dart';

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
      case 'delayed':   return AppColors.error;
      case 'completed': return AppColors.success;
      default:          return AppColors.g400;
    }
  }

  String get _statusLabel {
    switch (project.status) {
      case 'active':    return 'نشط';
      case 'delayed':   return 'متأخر';
      case 'completed': return 'مكتمل';
      case 'pending':   return 'معلق';
      default:          return project.status;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
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
              StatusBadge(text: _statusLabel,
                type: project.status == 'active' ? 'navy'
                  : project.status == 'delayed' ? 'overdue'
                  : project.status == 'completed' ? 'approved' : 'pending',
                dot: true),
              const SizedBox(width: 6),
              PriorityBadge(priority: project.priority),
              if (project.isDelayed) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft, borderRadius: BorderRadius.circular(6)),
                  child: Text('⏰ متأخر', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error))),
              ],
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(project.name, style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 13, fontWeight: FontWeight.w800),
                textAlign: TextAlign.right, maxLines: 2),
              Text(project.code, style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 10, color: AppColors.g400, letterSpacing: 0.5)),
            ]),
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
                  backgroundColor: AppColors.g100,
                  valueColor: AlwaysStoppedAnimation(_statusColor),
                  minHeight: 6)))),
            Text('${project.completedTasks}/${project.taskCount} مهمة',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
          ]),
          const SizedBox(height: 10),
          // Footer meta
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${project.startDate} → ${project.endDate}',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3),
              textDirection: TextDirection.rtl),
            Row(children: [
              AdminAvatar(initials: project.managerInitials, size: 24, fontSize: 10),
              const SizedBox(width: 6),
              Text(project.dept, style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.tx3)),
            ]),
          ]),
        ]),
      ),
    ),
  );
}

class MilestoneTimelineCard extends StatelessWidget {
  final ProjectMilestone milestone;
  final bool isLast;
  const MilestoneTimelineCard({
    super.key, required this.milestone, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final Color color = milestone.isCompleted ? AppColors.success
      : milestone.isDelayed ? AppColors.error
      : milestone.status == 'active' ? AppColors.navyMid : AppColors.g300;

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
              child: Text('📅 ${milestone.targetDate}', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 10, fontWeight: FontWeight.w600, color: color))),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(milestone.title, style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 12, fontWeight: FontWeight.w700,
              color: milestone.isCompleted ? AppColors.tx3 : AppColors.tx1)),
            if (milestone.isDelayed)
              Text('⚠️ تجاوز الموعد', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
          ]),
        ]),
      )),
    ]);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. PROJECTS OVERVIEW SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectsOverviewScreen extends StatelessWidget {
  const ProjectsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = AdminData.projects;
    final active    = projects.where((p) => p.status == 'active').length;
    final delayed   = projects.where((p) => p.status == 'delayed').length;
    final completed = projects.where((p) => p.status == 'completed').length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
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
                  child: Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)))),
              Expanded(child: Column(children: [
                Text('إدارة المشاريع', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('${projects.length} مشاريع إجمالية', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _pill('$active',    'نشط',     AppColors.navyBright),
              const SizedBox(width: 8),
              _pill('$delayed',   'متأخر',   AppColors.error),
              const SizedBox(width: 8),
              _pill('$completed', 'مكتمل',   AppColors.success),
              const SizedBox(width: 8),
              _pill('${projects.length}', 'إجمالي', Colors.white54),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(children: [

            // Alerts
            if (delayed > 0) AlertBanner(
              message: '$delayed مشاريع متأخرة — يحتاج إجراء فوري',
              type: 'error'),

            // KPI cards row
            SectionHeader(title: 'نظرة تشغيلية'),
            Row(children: [
              _kpiTile('${(projects.fold(0.0, (s, p) => s + p.progress) / projects.length * 100).toInt()}%',
                'متوسط الإنجاز', AppColors.navyMid, '📊'),
              const SizedBox(width: 10),
              _kpiTile('${projects.fold(0, (s, p) => s + p.taskCount)}',
                'إجمالي المهام', AppColors.teal, '✅'),
              const SizedBox(width: 10),
              _kpiTile('${AdminData.milestones.where((m) => m.isDelayed).length}',
                'مراحل متأخرة', AppColors.error, '⏰'),
            ]),
            const SizedBox(height: 16),

            // Active projects
            SectionHeader(title: 'المشاريع النشطة',
              actionLabel: 'عرض الكل',
              onAction: () => context.push('/projects-list')),
            ...projects.where((p) => p.status == 'active').map((p) =>
              ProjectProgressCard(project: p,
                onTap: () => context.push('/project-detail'))),

            // Delayed projects
            SectionHeader(title: 'المشاريع المتأخرة',
              actionLabel: 'متابعة',
              onAction: () => context.push('/project-follow-up')),
            ...projects.where((p) => p.status == 'delayed').map((p) =>
              ProjectProgressCard(project: p,
                onTap: () => context.push('/project-detail'))),

            // Recent activity
            SectionHeader(title: 'النشاط الأخير'),
            AppCard(child: Column(children: [
              _actRow('🚀', 'تم رفع نسبة إنجاز ERP إلى 62%',         'منذ ساعتين',  AppColors.success),
              _actRow('⚠️', 'مشروع HR متأخر — المرحلة 2 لم تُكتمل', 'أمس',          AppColors.error),
              _actRow('📋', 'تمت إضافة مخاطرة جديدة — مشروع المالية', 'أمس',         AppColors.warning),
              _actRow('✅', 'أُغلق مشروع المنصة الرقمية بنجاح',       'قبل 3 أيام',  AppColors.teal),
            ])),
            const SizedBox(height: 10),

            // Completed
            SectionHeader(title: 'المشاريع المكتملة'),
            ...projects.where((p) => p.status == 'completed').map((p) =>
              ProjectProgressCard(project: p,
                onTap: () => context.push('/project-detail'))),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: OutlineBtn(text: '📊 التحليلات',
            onTap: () => context.push('/project-analytics'))),
          const SizedBox(width: 10),
          Expanded(child: PrimaryBtn(text: '+ مشروع جديد', icon: '🏗',
            onTap: () {})),
        ])),
      ]),
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

  Widget _kpiTile(String v, String l, Color c, String ico) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
      boxShadow: AppShadows.card,
      border: Border(bottom: BorderSide(color: c, width: 3))),
    child: Column(children: [
      Text(ico, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(v, style: TextStyle(fontFamily: 'Cairo', 
        fontSize: 20, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3),
        textAlign: TextAlign.center),
    ])));

  Widget _actRow(String ico, String text, String time, Color c) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.g100))),
    child: Row(children: [
      Text(time, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.g400)),
      const Spacer(),
      Flexible(child: Text(text, style: TextStyle(fontFamily: 'Cairo', 
        fontSize: 12, color: AppColors.tx2), textAlign: TextAlign.right)),
      const SizedBox(width: 8),
      Container(width: 32, height: 32,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(ico, style: const TextStyle(fontSize: 14)))),
    ]));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. PROJECTS LIST SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});
  @override State<ProjectsListScreen> createState() => _ProjectsListState();
}
class _ProjectsListState extends State<ProjectsListScreen> {
  int _tab = 0;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final all = AdminData.projects;
    final filtered = all.where((p) {
      final matchSearch = _search.isEmpty ||
        p.name.contains(_search) || p.code.contains(_search);
      final matchTab = _tab == 0 || (
        _tab == 1 ? p.status == 'active' :
        _tab == 2 ? p.status == 'delayed' :
        _tab == 3 ? p.status == 'completed' : true);
      return matchSearch && matchTab;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'المشاريع', subtitle: '${all.length} مشاريع',
          onBack: () => context.pop()),
        Container(color: AppColors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: TextField(textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            onChanged: (v) => setState(() => _search = v),
            decoration: fieldDec('ابحث عن مشروع أو كود...').copyWith(
              prefixIcon: const Icon(Icons.search, color: AppColors.g400, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
        FilterBar(tabs: ['الكل', 'نشط', 'متأخر', 'مكتمل'],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: filtered.isEmpty
          ? const EmptyState(icon: '🏗', title: 'لا توجد مشاريع',
              subtitle: 'لا توجد مشاريع تطابق معايير البحث')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: filtered.length,
              itemBuilder: (_, i) => ProjectProgressCard(
                project: filtered[i],
                onTap: () => context.push('/project-detail')))),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. PROJECT DETAIL SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AdminData.projects.first;
    final milestones = AdminData.milestones
      .where((m) => m.projectId == p.id).toList();
    final risks = AdminData.risks
      .where((r) => r.projectId == p.id).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
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
                    StatusBadge(text: 'نشط', type: 'teal', dot: true),
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
                  _heroStat('${milestones.where((m) => m.isCompleted).length}/${milestones.length}', 'المراحل', '🏁'),
                  _heroStat('${risks.length}', 'المخاطر', '⚠️'),
                ]),
              ]),
            ),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(children: [

            // Quick nav tabs
            Row(children: [
              _quickNav(context, '📋 المهام',    '/project-tasks'),
              const SizedBox(width: 8),
              _quickNav(context, '🏁 المراحل',  '/project-milestones'),
              const SizedBox(width: 8),
              _quickNav(context, '🔄 متابعة',   '/project-follow-up'),
              const SizedBox(width: 8),
              _quickNav(context, '📊 تحليل',    '/project-analytics'),
            ]),
            const SizedBox(height: 14),

            // Project info
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('بيانات المشروع', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'المدير المسؤول', value: p.manager,   icon: '👤'),
              InfoRow(label: 'الإدارة',         value: p.dept,      icon: '🏢'),
              InfoRow(label: 'تاريخ البداية',   value: p.startDate, icon: '🟢'),
              InfoRow(label: 'تاريخ الانتهاء', value: p.endDate,   icon: '🔴'),
              InfoRow(label: 'الأولوية',         value: p.priority == 'high' ? 'عالية' : 'متوسطة', icon: '📌', border: false),
            ])),

            // Description
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('وصف المشروع', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(p.description, style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 13, color: AppColors.tx2, height: 1.8)),
            ])),

            // Milestones preview
            SectionHeader(title: 'المراحل الرئيسية',
              actionLabel: 'عرض الكل',
              onAction: () => context.push('/project-milestones')),
            AppCard(mb: 14, child: Column(children:
              milestones.asMap().entries.map((e) => MilestoneTimelineCard(
                milestone: e.value,
                isLast: e.key == milestones.length - 1)).toList())),

            // Tasks summary
            SectionHeader(title: 'المهام المرتبطة',
              actionLabel: 'عرض الكل',
              onAction: () => context.push('/project-tasks')),
            Row(children: [
              _taskStat('${p.completedTasks}', 'مكتملة', AppColors.success),
              const SizedBox(width: 8),
              _taskStat('${p.taskCount - p.completedTasks - 2}', 'جارية', AppColors.teal),
              const SizedBox(width: 8),
              _taskStat('2', 'متأخرة', AppColors.error),
              const SizedBox(width: 8),
              _taskStat('${p.taskCount}', 'الكل', AppColors.navyMid),
            ]),
            const SizedBox(height: 14),

            // Risks
            if (risks.isNotEmpty) ...[
              SectionHeader(title: 'المخاطر والمعوقات'),
              ...risks.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.sm,
                  border: Border.all(color: AppColors.warning.withOpacity(0.3))),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft, borderRadius: BorderRadius.circular(6)),
                      child: Text('تأثير: ${r.impact}', style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warningDark))),
                    const SizedBox(height: 4),
                    Text(r.owner, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                  ]),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(r.title, style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('احتمالية: ${r.likelihood}', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 10, color: AppColors.tx3)),
                  ])),
                  const SizedBox(width: 8),
                  const Text('⚠️', style: TextStyle(fontSize: 20)),
                ])),
              ),
            ],

            // Team & Files placeholders
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('فريق المشروع', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(children: [
                const Spacer(),
                ...['فع', 'سم', 'مد', 'نز'].map((i) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: AdminAvatar(initials: i, size: 36, fontSize: 13))),
                const SizedBox(width: 8),
                Text('+ 5 أعضاء آخرين', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.navyMid, fontWeight: FontWeight.w600)),
              ]),
            ])),

            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('المرفقات والوثائق', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const EmptyState(icon: '📎', title: 'لا توجد مرفقات',
                subtitle: 'لم يتم رفع وثائق بعد لهذا المشروع'),
            ])),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: OutlineBtn(text: '🔄 متابعة',
            onTap: () => context.push('/project-follow-up'))),
          const SizedBox(width: 10),
          Expanded(child: TealBtn(text: '📋 المهام',
            onTap: () => context.push('/project-tasks'))),
        ])),
      ]),
    );
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
          color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.sm),
        child: Center(child: Text(label, style: TextStyle(fontFamily: 'Cairo', 
          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navyMid),
          textAlign: TextAlign.center)))));

  Widget _taskStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', 
        fontSize: 20, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3)),
    ])));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. PROJECT TASKS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectTasksScreen extends StatefulWidget {
  const ProjectTasksScreen({super.key});
  @override State<ProjectTasksScreen> createState() => _ProjectTasksState();
}
class _ProjectTasksState extends State<ProjectTasksScreen> {
  int _tab = 0;
  // Reuse existing AdminTask data filtered for this project
  @override
  Widget build(BuildContext context) {
    final tasks = AdminData.tasks;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'مهام المشروع',
          subtitle: 'PRJ-2025-001 · ERP',
          onBack: () => context.pop()),
        // Summary strip
        Container(color: AppColors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(children: [
            _statChip('${tasks.length}', 'الكل', AppColors.navyMid),
            const SizedBox(width: 8),
            _statChip('${tasks.where((t) => t.status == 'in_progress').length}', 'جارية', AppColors.teal),
            const SizedBox(width: 8),
            _statChip('${tasks.where((t) => t.status == 'overdue').length}', 'متأخرة', AppColors.error),
            const SizedBox(width: 8),
            _statChip('${tasks.where((t) => t.status == 'pending').length}', 'معلقة', AppColors.warning),
          ])),
        FilterBar(tabs: ['الكل', 'جارية', 'معلقة', 'متأخرة', 'مكتملة'],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: tasks.length,
          itemBuilder: (_, i) {
            final t = tasks[i];
            return TaskCard(id: t.id, title: t.title, assignedTo: t.assignedTo,
              dept: t.dept, dueDate: t.dueDate, status: t.status, priority: t.priority,
              onTap: () => context.push('/task-detail'));
          },
        )),
      ]),
    );
  }

  Widget _statChip(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: c.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3)),
    ])));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. PROJECT MILESTONES SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectMilestonesScreen extends StatelessWidget {
  const ProjectMilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final milestones = AdminData.milestones
      .where((m) => m.projectId == 'P01').toList();
    final completed = milestones.where((m) => m.isCompleted).length;
    final delayed   = milestones.where((m) => m.isDelayed).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'مراحل المشروع',
          subtitle: 'PRJ-2025-001',
          onBack: () => context.pop()),
        // Progress strip
        Container(color: AppColors.bgCard,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(completed / milestones.length * 100).toInt()}%', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
              Text('$completed/${milestones.length} مراحل مكتملة', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tx2)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: completed / milestones.length,
                backgroundColor: AppColors.g100,
                valueColor: const AlwaysStoppedAnimation(AppColors.navyMid),
                minHeight: 10)),
            if (delayed > 0) ...[
              const SizedBox(height: 8),
              AlertBanner(message: '$delayed مرحلة متأخرة — يحتاج متابعة', type: 'error'),
            ],
          ])),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AppCard(child: Column(children:
            milestones.asMap().entries.map((e) => MilestoneTimelineCard(
              milestone: e.value,
              isLast: e.key == milestones.length - 1)).toList())),
        )),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. PROJECT FOLLOW-UP SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectFollowUpScreen extends StatelessWidget {
  const ProjectFollowUpScreen({super.key});

  static const _items = [
    {'title': 'استكمال تكامل وحدة الحضور مع ERP',     'responsible': 'فهد العتيبي',   'dept': 'التقنية',    'due': '15 مارس', 'type': 'task',    'overdue': true,  'escalated': false},
    {'title': 'مراجعة متطلبات المرحلة 3',              'responsible': 'فهد العتيبي',   'dept': 'التقنية',    'due': '20 مارس', 'type': 'review',  'overdue': false, 'escalated': false},
    {'title': 'تحديث سياسة الإجازات — اعتراض الإدارة', 'responsible': 'سارة المطيري', 'dept': 'HR',         'due': '12 مارس', 'type': 'approval','overdue': true,  'escalated': true},
    {'title': 'رفع تقرير المخاطرة الأسبوعية',           'responsible': 'عمر الدوسري',  'dept': 'التطوير',    'due': '14 مارس', 'type': 'report',  'overdue': false, 'escalated': false},
    {'title': 'مراجعة ميزانية المشروع مع المالية',      'responsible': 'نورة الزهراني','dept': 'المالية',    'due': '18 مارس', 'type': 'finance', 'overdue': false, 'escalated': false},
  ];

  @override
  Widget build(BuildContext context) {
    final overdueCount  = _items.where((i) => i['overdue'] as bool).length;
    final escalatedCount = _items.where((i) => i['escalated'] as bool).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
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
              Text('متابعة المشاريع', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('$overdueCount متأخرة · $escalatedCount مُصعَّدة', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.goldLight)),
            ])),
            const SizedBox(width: 36),
          ]),
        ),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (overdueCount > 0)
              AlertBanner(
                message: '$overdueCount بنود متأخرة في متابعة المشاريع',
                type: 'error'),
            ..._items.map((item) => FollowUpCard(
              id: 'PFU-${_items.indexOf(item)+1}',
              title: item['title'] as String,
              responsible: item['responsible'] as String,
              dept: item['dept'] as String,
              dueDate: item['due'] as String,
              status: (item['overdue'] as bool) ? 'overdue' : 'pending',
              isOverdue: item['overdue'] as bool,
              isEscalated: item['escalated'] as bool,
              onTap: () => context.push('/follow-up-detail'))),
          ],
        )),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. PROJECT ANALYTICS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProjectAnalyticsScreen extends StatelessWidget {
  const ProjectAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = AdminData.projects;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
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
              Text('تحليل المشاريع', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('مارس 2025', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.goldLight)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(9)),
              child: Text('📤 تصدير', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyDeep))),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(children: [

            // KPI cards
            SectionHeader(title: 'مؤشرات المشاريع'),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
              children: [
                KpiCard(label: 'إجمالي المشاريع',  value: '${projects.length}',
                  change: '+2 هذا الربع',  icon: '🏗',  isPositive: true,  color: AppColors.navyMid),
                KpiCard(label: 'مشاريع نشطة',      value: '${projects.where((p) => p.status == 'active').length}',
                  change: 'تسير بشكل جيد',  icon: '🚀',  isPositive: true,  color: AppColors.teal),
                KpiCard(label: 'متأخرة',             value: '${projects.where((p) => p.status == 'delayed').length}',
                  change: 'يحتاج متابعة',   icon: '⏰',  isPositive: false, color: AppColors.error),
                KpiCard(label: 'متوسط الإنجاز',     value: '${(projects.fold(0.0, (s, p) => s + p.progress) / projects.length * 100).toInt()}%',
                  change: '+8% عن الشهر',   icon: '📈',  isPositive: true,  color: AppColors.gold),
              ],
            ),
            const SizedBox(height: 16),

            // Progress by project
            SectionHeader(title: 'نسبة الإنجاز حسب المشروع'),
            AppCard(mb: 16, child: Column(children:
              projects.map((p) {
                final color = p.status == 'completed' ? AppColors.success
                  : p.status == 'delayed' ? AppColors.error : AppColors.navyMid;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${(p.progress * 100).toInt()}%', style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 12, fontWeight: FontWeight.w800, color: color)),
                      Flexible(child: Text(p.name, style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 11, color: AppColors.tx2), textAlign: TextAlign.right,
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 4),
                    ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: p.progress, backgroundColor: AppColors.g100,
                        valueColor: AlwaysStoppedAnimation(color), minHeight: 8)),
                  ]));
              }).toList(),
            )),

            // Milestone completion
            SectionHeader(title: 'حالة المراحل الرئيسية'),
            AppCard(mb: 16, child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _circStat('${AdminData.milestones.where((m) => m.isCompleted).length}', 'مكتملة',  AppColors.success),
                _circStat('${AdminData.milestones.where((m) => m.isDelayed).length}',   'متأخرة',  AppColors.error),
                _circStat('${AdminData.milestones.where((m) => !m.isCompleted && !m.isDelayed).length}', 'معلقة', AppColors.warning),
                _circStat('${AdminData.milestones.length}', 'إجمالية', AppColors.navyMid),
              ]),
            ])),

            // By department
            SectionHeader(title: 'توزيع المشاريع حسب الإدارة'),
            AppCard(child: Column(children:
              projects.map((p) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.g100))),
                child: Row(children: [
                  Text(p.dept, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: p.progress, backgroundColor: AppColors.g100,
                        valueColor: AlwaysStoppedAnimation(
                          p.status == 'delayed' ? AppColors.error : AppColors.navyMid),
                        minHeight: 6)))),
                  Text(p.code, style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 9, color: AppColors.g400, letterSpacing: 0.5)),
                ]),
              )).toList(),
            )),
          ]),
        )),
      ]),
    );
  }

  Widget _circStat(String v, String l, Color c) => Column(children: [
    Text(v, style: TextStyle(fontFamily: 'Cairo', 
      fontSize: 22, fontWeight: FontWeight.w900, color: c, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3, height: 1.3)),
  ]);
}
