import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';

// ── Tasks Dashboard ───────────────────────────────────────
class TasksDashboardScreen extends StatelessWidget {
  const TasksDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final tasks = AdminData.tasks;
    final overdue     = tasks.where((t) => t.status == 'overdue').length;
    final inProgress  = tasks.where((t) => t.status == 'in_progress').length;
    final pending     = tasks.where((t) => t.status == 'pending').length;
    // final completed   = tasks.where((t) => t.status == 'completed').length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
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
                  child: Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)))),
              Expanded(child: Column(children: [
                Text('إدارة المهام', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('${tasks.length} مهمة إجمالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _topStat('${tasks.length}', 'الكل',    AppColors.navySoft,    AppColors.goldLight),
              const SizedBox(width: 8),
              _topStat('$inProgress',  'جارية',  AppColors.tealSoft,    AppColors.tealLight),
              const SizedBox(width: 8),
              _topStat('$overdue',     'متأخرة', AppColors.errorSoft,   AppColors.error),
              const SizedBox(width: 8),
              _topStat('$pending',     'معلقة',  AppColors.warningSoft, AppColors.warning),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Overdue alert
            if (overdue > 0) AlertBanner(
              message: '$overdue مهام تجاوزت الموعد النهائي — مراجعة فورية مطلوبة',
              type: 'error'),
            SectionHeader(title: 'المهام المتأخرة',
              actionLabel: 'عرض الكل', onAction: () => context.push('/all-tasks')),
            ...tasks.where((t) => t.status == 'overdue').map((t) =>
              TaskCard(id: t.id, title: t.title, assignedTo: t.assignedTo,
                dept: t.dept, dueDate: t.dueDate, status: t.status, priority: t.priority,
                onTap: () => context.push('/task-detail'))),
            const SizedBox(height: 10),
            SectionHeader(title: 'المهام الجارية'),
            ...tasks.where((t) => t.status == 'in_progress').map((t) =>
              TaskCard(id: t.id, title: t.title, assignedTo: t.assignedTo,
                dept: t.dept, dueDate: t.dueDate, status: t.status, priority: t.priority,
                onTap: () => context.push('/task-detail'))),
            const SizedBox(height: 10),
            SectionHeader(title: 'المهام المعلقة'),
            ...tasks.where((t) => t.status == 'pending').map((t) =>
              TaskCard(id: t.id, title: t.title, assignedTo: t.assignedTo,
                dept: t.dept, dueDate: t.dueDate, status: t.status, priority: t.priority,
                onTap: () => context.push('/task-detail'))),
          ]),
        )),
        StickyBar(child: PrimaryBtn(text: '+ إنشاء مهمة جديدة', icon: '✏️',
          onTap: () => context.push('/create-task'))),
      ]),
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
class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});
  @override State<AllTasksScreen> createState() => _AllTasksState();
}
class _AllTasksState extends State<AllTasksScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Column(children: [
      AdminAppBar(title: 'جميع المهام', onBack: () => context.pop()),
      FilterBar(tabs: ['الكل','جارية','معلقة','متأخرة','مكتملة'],
        selected: _tab, onSelect: (i) => setState(() => _tab = i)),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: AdminData.tasks.length,
        itemBuilder: (_, i) {
          final t = AdminData.tasks[i];
          return TaskCard(id: t.id, title: t.title, assignedTo: t.assignedTo,
            dept: t.dept, dueDate: t.dueDate, status: t.status, priority: t.priority,
            onTap: () => context.push('/task-detail'));
        },
      )),
    ]),
  );
}

// ── Task Detail ───────────────────────────────────────────
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AdminData.tasks.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل المهمة', subtitle: t.id,
          onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            AppCard(mb: 14, child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                PriorityBadge(priority: t.priority),
                StatusBadge(text: t.status == 'in_progress' ? 'جارية' : t.status == 'overdue' ? 'متأخرة' : 'معلقة',
                  type: t.status == 'overdue' ? 'overdue' : t.status == 'in_progress' ? 'teal' : 'pending', dot: true),
              ]),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: Text(t.title,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800))),
              const Divider(height: 20, color: AppColors.g100),
              InfoRow(label: 'المكلَّف بها',  value: t.assignedTo, icon: '👤'),
              InfoRow(label: 'الإدارة',       value: t.dept,       icon: '🏢'),
              InfoRow(label: 'تاريخ الإنشاء', value: t.createdDate, icon: '📅'),
              InfoRow(label: 'الموعد النهائي', value: t.dueDate,   icon: '⏰'),
              if (t.notes != null) InfoRow(label: 'ملاحظات',       value: t.notes!, icon: '📝', border: false),
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
              TextField(maxLines: 3, textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: fieldDec('سجّل تعليق متابعة...')),
            ])),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: OutlineBtn(text: '↩ إعادة تكليف', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: TealBtn(text: '✓ تم الإنجاز', onTap: () {})),
        ])),
      ]),
    );
  }
}
