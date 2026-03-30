import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../documents/presentation/providers/notifications_providers.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboardScreen> {
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

  List<Map<String, dynamic>> _getQuickActions(BuildContext context) => [
    {'l': 'Review Requests'.tr(context),  'i':'📋', 'r':'/requests',     'c': AppColors.navyMid},
    {'l': 'Track Tasks'.tr(context),   'i':'✅', 'r':'/tasks',         'c': AppColors.teal},
    {'l': 'Approve Requests'.tr(context), 'i':'🖊', 'r':'/approvals',     'c': AppColors.gold},
    {'l': 'Attendance Management'.tr(context),   'i':'⏱', 'r':'/attendance',    'c': AppColors.info},
    {'l': 'Leave Management'.tr(context), 'i':'🌴', 'r':'/leave',         'c': AppColors.success},
    {'l': 'Employees'.tr(context),        'i':'👥', 'r':'/employees',     'c': AppColors.navyLight},
    {'l': 'Departments'.tr(context),        'i':'🏢', 'r':'/departments',   'c': AppColors.warningDark},
    {'l': 'Reports'.tr(context),        'i':'📊', 'r':'/reports',       'c': AppColors.navyDeep},
    {'l': 'Projects'.tr(context),         'i':'🏗', 'r':'/projects',      'c': AppColors.navyLight},
    {'l': 'Expenses'.tr(context),        'i':'💰', 'r':'/expenses',      'c': AppColors.gold},
    {'l': 'Track Projects'.tr(context), 'i':'🔄', 'r':'/project-follow-up','c': AppColors.teal},
    {'l': 'Expense Approval'.tr(context),'i':'💳', 'r':'/expense-follow-up','c': AppColors.success},
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final employee = authState.employee;
    final adminName = employee?.name.split(' ').take(2).join(' ') ?? 'Admin'.tr(context);
    final adminRole = employee?.jobTitle ?? 'System Manager'.tr(context);
    final notifCount = ref.watch(notificationsProvider).unreadCount;
    final dashAsync = ref.watch(dashboardProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

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
              // Icons (notification + profile) — leading side
              Row(children: [
                GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Stack(children: [
                    Container(width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
                      child: const Center(child: Text('🔔', style: TextStyle(fontSize: 18)))),
                    if (notifCount > 0) Positioned(top: 5, left: isRtl ? 5 : null, right: isRtl ? null : 5,
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
              // Greeting — center
              Expanded(child: Column(children: [
                Text('Admin Panel'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white38, letterSpacing: 2)),
                Text(adminName, style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(adminRole, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
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
                // Time & Date — start side
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_timeStr, style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                  Text(_dateStr, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                ])),
                // Stats — end side
                dashAsync.when(
                  data: (dash) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    _headerStat('${dash.kpis.presentToday}', 'Present'.tr(context), AppColors.goldLight),
                    _headerStat('${dash.kpis.onLeaveToday}', 'On Leave'.tr(context), AppColors.tealLight),
                    _headerStat('${dash.kpis.absentToday}', 'Absent'.tr(context), AppColors.error),
                  ]),
                  loading: () => const SizedBox(width: 60, child: Center(
                    child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 2))),
                  error: (_, __) => Text('—', style: TextStyle(color: Colors.white54)),
                ),
              ]),
            ),
          ]),
        ),
        // ── Scroll Body ──────────────────────────────────────
        Expanded(child: dashAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navyMid)),
          error: (error, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.g300),
            const SizedBox(height: 12),
            Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx2)),
            const SizedBox(height: 4),
            Text('$error', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3), textAlign: TextAlign.center, maxLines: 3),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.invalidate(dashboardProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('Retry'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
          ])),
          data: (dash) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                // ── Alerts ────────────────────────────────────────
                if (dash.kpis.overdueTasks > 0)
                  AlertBanner(message: 'overdue_tasks_alert'.tr(context, params: {'count': '${dash.kpis.overdueTasks}'}), type: 'error'),
                if (dash.kpis.pendingRequests > 0)
                  AlertBanner(message: 'pending_requests_alert'.tr(context, params: {'count': '${dash.kpis.pendingRequests}'}), type: 'warning'),

                // ── KPI Grid ──────────────────────────────────────
                SectionHeader(title: 'Operational KPIs'.tr(context)),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
                  children: [
                    KpiCard(label: 'Total Employees'.tr(context), value: '${dash.kpis.totalEmployees}', change: '', icon: '👥', isPositive: true, color: AppColors.navyMid, onTap: () => context.push('/employees')),
                    KpiCard(label: 'Present Today'.tr(context), value: '${dash.kpis.presentToday}', change: '${dash.kpis.attendanceRate.toStringAsFixed(0)}%', icon: '✅', isPositive: true, color: AppColors.success, onTap: () => context.push('/attendance')),
                    KpiCard(label: 'Absent'.tr(context), value: '${dash.kpis.absentToday}', change: '', icon: '🚫', isPositive: false, color: AppColors.error, onTap: () => context.push('/attendance')),
                    KpiCard(label: 'Late'.tr(context), value: '${dash.kpis.lateToday}', change: '', icon: '⏰', isPositive: false, color: AppColors.warning, onTap: () => context.push('/attendance')),
                    KpiCard(label: 'Pending Requests'.tr(context), value: '${dash.kpis.pendingRequests}', change: '', icon: '📋', isPositive: false, color: AppColors.gold, onTap: () => context.push('/requests')),
                    KpiCard(label: 'Pending Leaves'.tr(context), value: '${dash.kpis.pendingLeaves}', change: '', icon: '🌴', isPositive: false, color: AppColors.teal, onTap: () => context.push('/leave')),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Quick Actions ──────────────────────────────────
                SectionHeader(title: 'Quick Actions'.tr(context)),
                GridView.count(
                  crossAxisCount: 4, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82,
                  children: _getQuickActions(context).map((a) => GestureDetector(
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

                // ── Departments Summary ────────────────────────────
                if (dash.departmentSummary.isNotEmpty) ...[
                  SectionHeader(title: 'Departments Overview'.tr(context),
                    actionLabel: 'View all'.tr(context), onAction: () => context.push('/departments')),
                  SizedBox(height: 100,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: 6),
                        itemCount: dash.departmentSummary.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final d = dash.departmentSummary[i];
                          final rate = d.employeeCount > 0 ? (d.present / d.employeeCount * 100) : 0.0;
                          final perfColor = rate >= 90 ? AppColors.success
                            : rate >= 75 ? AppColors.warning : AppColors.error;
                          return GestureDetector(
                            onTap: () => context.push('/department-detail'),
                            child: Container(
                              width: 155,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppShadows.card,
                                border: Border(bottom: BorderSide(color: perfColor, width: 3))),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Flexible(child: Text(d.name,
                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700),
                                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  Text('${rate.toInt()}%', style: TextStyle(fontFamily: 'Cairo',
                                    fontSize: 13, fontWeight: FontWeight.w800, color: perfColor)),
                                ]),
                                const SizedBox(height: 4),
                                ClipRRect(borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: rate / 100,
                                    backgroundColor: AppColors.g100,
                                    valueColor: AlwaysStoppedAnimation(perfColor), minHeight: 3)),
                                const SizedBox(height: 8),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  _deptChip('${d.employeeCount}', '👥'),
                                  _deptChip('${d.present}', '✅'),
                                  _deptChip('${d.pendingRequests}', '📋'),
                                ]),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 18),
                ],

                // ── Pending Approvals ──────────────────────────────
                if (dash.pendingApprovals.isNotEmpty) ...[
                  SectionHeader(title: 'Pending Approvals'.tr(context),
                    actionLabel: 'View all'.tr(context), onAction: () => context.push('/approvals')),
                  ...dash.pendingApprovals.take(3).map((r) =>
                    RequestCard(
                      id: '${r.id}', empName: r.employeeName, dept: r.employeeCode, type: r.type,
                      date: r.createdAt, status: 'pending', priority: 'normal',
                      onTap: () => context.push('/request-detail', extra: r.id))),
                  const SizedBox(height: 10),
                ],

              ]),
            ),
          ),
        )),
      ]),
    );
  }

  Widget _headerStat(String v, String l, Color c) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
    const SizedBox(width: 4),
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: c)),
  ]);

  Widget _deptChip(String v, String ico) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(ico, style: const TextStyle(fontSize: 10)),
    const SizedBox(width: 2),
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.tx1)),
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
