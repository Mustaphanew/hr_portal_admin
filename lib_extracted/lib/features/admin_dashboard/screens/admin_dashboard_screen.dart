import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override State<AdminDashboardScreen> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboardScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  @override
  void initState() { super.initState(); _timer = Timer.periodic(const Duration(seconds:1), (_){ if(mounted) setState(()=>_now=DateTime.now()); }); }
  @override void dispose() { _timer.cancel(); super.dispose(); }

  String get _timeStr => '${_now.hour.toString().padLeft(2,'0')}:${_now.minute.toString().padLeft(2,'0')}';
  String get _dateStr {
    const days=['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
    const months=['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${days[_now.weekday % 7]}، ${_now.day} ${months[_now.month - 1]} ${_now.year}';
  }

  static const _quickActions = [
    {'l':'مراجعة الطلبات',  'i':'📋', 'r':'/requests',     'c': AppColors.navyMid},
    {'l':'متابعة المهام',   'i':'✅', 'r':'/tasks',         'c': AppColors.teal},
    {'l':'اعتماد الطلبات', 'i':'🖊', 'r':'/approvals',     'c': AppColors.gold},
    {'l':'إدارة الحضور',   'i':'⏱', 'r':'/attendance',    'c': AppColors.info},
    {'l':'إدارة الإجازات', 'i':'🌴', 'r':'/leave',         'c': AppColors.success},
    {'l':'الموظفون',        'i':'👥', 'r':'/employees',     'c': AppColors.navyLight},
    {'l':'الإدارات',        'i':'🏢', 'r':'/departments',   'c': AppColors.warningDark},
    {'l':'التقارير',        'i':'📊', 'r':'/reports',       'c': AppColors.navyDeep},
    {'l':'المشاريع',         'i':'🏗', 'r':'/projects',      'c': AppColors.navyLight},
    {'l':'المصروفات',        'i':'💰', 'r':'/expenses',      'c': AppColors.gold},
    {'l':'متابعة المشاريع', 'i':'🔄', 'r':'/project-follow-up','c': AppColors.teal},
    {'l':'اعتماد المصروفات','i':'💳', 'r':'/expense-follow-up','c': AppColors.success},
  ];

  @override
  Widget build(BuildContext context) {
    final admin = AdminData.currentAdmin;
    final kpis  = AdminData.kpis;
    final notifCount = AdminData.notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // ── Header ──────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 18, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              // Left actions
              Row(children: [
                GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Stack(children: [
                    Container(width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
                      child: const Center(child: Text('🔔', style: TextStyle(fontSize: 18)))),
                    if (notifCount > 0) Positioned(top: 5, right: 5,
                      child: Container(width: 14, height: 14,
                        decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle,
                          border: Border.all(color: AppColors.navyMid, width: 1.5)),
                        child: Center(child: Text('$notifCount', style: TextStyle(fontFamily: 'Cairo', 
                          fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white))))),
                  ])),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/admin-profile'),
                  child: Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
                    child: const Center(child: Text('👤', style: TextStyle(fontSize: 18))))),
              ]),
              // Greeting
              Expanded(child: Column(children: [
                Text('لوحة الإدارة', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white38, letterSpacing: 2)),
                Text(admin.name.split(' ').take(2).join(' '), style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(admin.role, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
              ])),
            ]),
            const SizedBox(height: 16),
            // Date/Time + Quick Status Strip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white10, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12)),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_timeStr, style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                  Text(_dateStr, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(children: [
                    Text('94', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                    const SizedBox(width: 4),
                    Text('حاضر', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                  ]),
                  Row(children: [
                    Text('11', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.tealLight)),
                    const SizedBox(width: 4),
                    Text('إجازة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                  ]),
                  Row(children: [
                    Text('4', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
                    const SizedBox(width: 4),
                    Text('غياب', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                  ]),
                ]),
              ]),
            ),
          ]),
        ),
        // ── Scroll Body ──────────────────────────────────────
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // ── Alerts ────────────────────────────────────────
            const AlertBanner(message: '8 مهام تجاوزت الموعد النهائي — يحتاج متابعة فورية', type: 'error'),
            const AlertBanner(message: '31 طلب معلق — 4 منها عاجلة وتنتظر اعتمادك', type: 'warning'),

            // ── KPI Grid ──────────────────────────────────────
            SectionHeader(title: 'المؤشرات التشغيلية'),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
              children: kpis.map((k) => KpiCard(
                label: k.label, value: k.value, change: k.change,
                icon: k.icon, isPositive: k.isPositive, color: k.color,
                onTap: () {})).toList(),
            ),
            const SizedBox(height: 18),

            // ── Quick Actions ──────────────────────────────────
            SectionHeader(title: 'الإجراءات السريعة'),
            GridView.count(
              crossAxisCount: 4, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82,
              children: _quickActions.map((a) => GestureDetector(
                onTap: () => context.push(a['r'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppShadows.sm),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: (a['c'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(13)),
                      child: Center(child: Text(a['i'] as String, style: const TextStyle(fontSize: 20)))),
                    const SizedBox(height: 6),
                    Text(a['l'] as String, style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.tx2),
                      textAlign: TextAlign.center, maxLines: 2),
                  ])),
              )).toList(),
            ),
            const SizedBox(height: 18),

            // ── Projects + Expenses Summary Row ───────────────
            SectionHeader(title: 'المشاريع والمصروفات'),
            Row(children: [
              // Projects mini card
              Expanded(child: GestureDetector(
                onTap: () => context.push('/projects'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.card,
                    border: const Border(bottom: BorderSide(color: AppColors.navyMid, width: 3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.navyMid.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8)),
                        child: const Text('🏗', style: TextStyle(fontSize: 18))),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('6', style: TextStyle(fontFamily: 'Cairo', 
                          fontSize: 26, fontWeight: FontWeight.w900,
                          color: AppColors.navyMid, height: 1)),
                        Text('مشاريع', style: TextStyle(fontFamily: 'Cairo', 
                          fontSize: 10, color: AppColors.tx3)),
                      ]),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('2 متأخرة', style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_downward, size: 11, color: AppColors.error),
                    ]),
                  ])),
              )),
              const SizedBox(width: 10),
              // Expenses mini card
              Expanded(child: GestureDetector(
                onTap: () => context.push('/expenses'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.card,
                    border: const Border(bottom: BorderSide(color: AppColors.gold, width: 3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8)),
                        child: const Text('💰', style: TextStyle(fontSize: 18))),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('3', style: TextStyle(fontFamily: 'Cairo', 
                          fontSize: 26, fontWeight: FontWeight.w900,
                          color: AppColors.gold, height: 1)),
                        Text('مصاريف معلقة', style: TextStyle(fontFamily: 'Cairo', 
                          fontSize: 10, color: AppColors.tx3)),
                      ]),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('SAR 34,300 إجمالي', style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 10, color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                    ]),
                  ])),
              )),
            ]),
            const SizedBox(height: 18),

            // ── Departments Summary ────────────────────────────
            SectionHeader(title: 'نظرة على الإدارات',
              actionLabel: 'عرض الكل', onAction: () => context.push('/departments')),
            SizedBox(height: 110,
              child: ListView(scrollDirection: Axis.horizontal, reverse: true,
                padding: const EdgeInsets.only(bottom: 6),
                children: AdminData.departments.map((d) {
                  final perfColor = d.performanceScore >= 90 ? AppColors.success
                    : d.performanceScore >= 75 ? AppColors.warning : AppColors.error;
                  return GestureDetector(
                    onTap: () => context.push('/department-detail'),
                    child: Container(
                      width: 155, margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.card,
                        border: Border(bottom: BorderSide(color: perfColor, width: 3))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${d.performanceScore.toInt()}%', style: TextStyle(fontFamily: 'Cairo', 
                            fontSize: 13, fontWeight: FontWeight.w800, color: perfColor)),
                          Flexible(child: Text(d.name.split('إدارة').last.trim(),
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                        const SizedBox(height: 4),
                        ClipRRect(borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: d.performanceScore / 100,
                            backgroundColor: AppColors.g100,
                            valueColor: AlwaysStoppedAnimation(perfColor), minHeight: 3)),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          _deptChip('${d.activeTasks}', '✅'),
                          _deptChip('${d.pendingRequests}', '📋'),
                          _deptChip('${d.employeeCount}', '👥'),
                        ]),
                      ]),
                    ),
                  );
                }).toList(),
              )),
            const SizedBox(height: 18),

            // ── Pending Approvals ──────────────────────────────
            SectionHeader(title: 'الموافقات المعلقة',
              actionLabel: 'عرض الكل', onAction: () => context.push('/approvals')),
            ...AdminData.requests.where((r) => r.status == 'pending').take(3).map((r) =>
              RequestCard(
                id: r.id, empName: r.empName, dept: r.dept, type: r.type,
                date: r.submittedDate, status: r.status, priority: r.priority,
                onTap: () => context.push('/request-detail'))),
            const SizedBox(height: 10),

            // ── Task Summary ───────────────────────────────────
            SectionHeader(title: 'حالة المهام',
              actionLabel: 'عرض الكل', onAction: () => context.push('/tasks')),
            Row(children: [
              _taskStat('8', 'إجمالي', AppColors.navyMid),
              const SizedBox(width: 8),
              _taskStat('3', 'جارية', AppColors.teal),
              const SizedBox(width: 8),
              _taskStat('2', 'متأخرة', AppColors.error),
              const SizedBox(width: 8),
              _taskStat('3', 'معلقة', AppColors.warning),
            ]),
            const SizedBox(height: 14),
            ...AdminData.tasks.where((t) => t.status == 'overdue').map((t) =>
              TaskCard(
                id: t.id, title: t.title, assignedTo: t.assignedTo,
                dept: t.dept, dueDate: t.dueDate, status: t.status, priority: t.priority,
                onTap: () => context.push('/task-detail'))),
            const SizedBox(height: 10),

            // ── Recent Activity ────────────────────────────────
            SectionHeader(title: 'النشاط الأخير'),
            AppCard(child: Column(children:
              AdminData.recentActivity.asMap().entries.map((e) {
                final i = e.key; final a = e.value;
                final typeColor = a['type'] == 'success' ? AppColors.success
                  : a['type'] == 'warning' ? AppColors.warning
                  : a['type'] == 'error' ? AppColors.error : AppColors.navyMid;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    border: i < AdminData.recentActivity.length - 1
                      ? const Border(bottom: BorderSide(color: AppColors.g100)) : null),
                  child: Row(children: [
                    Text(a['time']!, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.g400)),
                    const Spacer(),
                    Flexible(child: Text(a['text']!, style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, color: AppColors.tx2), textAlign: TextAlign.right)),
                    const SizedBox(width: 8),
                    Container(width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text(a['icon']!, style: const TextStyle(fontSize: 14)))),
                  ]),
                );
              }).toList(),
            )),
            const SizedBox(height: 10),

            // ── Announcements ──────────────────────────────────
            SectionHeader(title: 'الإعلانات',
              actionLabel: 'عرض الكل', onAction: () => context.push('/announcements')),
            ...AdminData.announcements.take(2).map((a) => GestureDetector(
              onTap: () => context.push('/announcement-detail'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.sm,
                  border: Border(top: BorderSide(
                    color: a.isPinned ? AppColors.gold : AppColors.navyBorder, width: 2.5))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      if (a.isPinned) ...[
                        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(6)),
                          child: Text('📌 مثبّت', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldDark))),
                        const SizedBox(width: 6),
                      ],
                      StatusBadge(text: a.publishStatus, type: a.publishStatus == 'منشور' ? 'approved' : 'pending'),
                    ]),
                    Text(a.date, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                  ]),
                  const SizedBox(height: 6),
                  Text(a.title, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(a.audience, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                ]),
              ),
            )),
          ]),
        )),
      ]),
    );
  }

  Widget _deptChip(String v, String ico) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.tx1)),
    const SizedBox(width: 2),
    Text(ico, style: const TextStyle(fontSize: 10)),
  ]);

  Widget _taskStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: c, height: 1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
    ]),
  ));
}
