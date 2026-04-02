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
import '../../data/models/branch_models.dart';

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

  String _timeStr(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final hour = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final min = _now.minute.toString().padLeft(2, '0');
    final period = isAr ? (_now.hour < 12 ? 'ص' : 'م') : (_now.hour < 12 ? 'AM' : 'PM');
    return '$hour:$min $period';
  }

  String _dateStr(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) {
      const days = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
      const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
      return '${days[_now.weekday % 7]}، ${_now.day} ${months[_now.month - 1]} ${_now.year}';
    } else {
      const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${days[_now.weekday % 7]}, ${_now.day} ${months[_now.month - 1]} ${_now.year}';
    }
  }

  List<Map<String, dynamic>> _getQuickActions(BuildContext context) => [
    {'l': 'Request Management'.tr(context),  'i':'📋', 'r':'/requests',     'c': AppColors.navyMid},
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
    final c = context.appColors;
    final authState = ref.watch(authProvider);
    final employee = authState.employee;
    final adminName = employee?.name.split(' ').take(2).join(' ') ?? 'Admin'.tr(context);
    final adminRole = employee?.jobTitle ?? 'System Manager'.tr(context);
    final notifCount = ref.watch(notificationsProvider).unreadCount;
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        color: AppColors.navyMid,
        child: CustomScrollView(
        slivers: [
          // ── SliverAppBar — pinned: user info + icons ──
          SliverAppBar(
            expandedHeight: 170,
            collapsedHeight: 70,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              child: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                    left: 18, right: 18, bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white10, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12)),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(_timeStr(context), style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1, height: 1.2)),
                        const SizedBox(height: 8),
                        Text(_dateStr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60, height: 1.2)),
                      ])),
                      dashAsync.when(
                        data: (dash) => Column(crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center, children: [
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
                ),
              ),
            ),
            title: Row(children: [
              Expanded(child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                Text(adminName, style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
                const SizedBox(height: 8),
                Text(adminRole, style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: AppColors.goldLight, height: 1.2)),
              ])),
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Stack(children: [
                  Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11)),
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
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(11)),
                  child: const Center(child: Text('👤', style: TextStyle(fontSize: 18))))),
            ]),
            titleSpacing: 18,
          ),

          // ── Body ──────────────────────────────────────
          dashAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.navyMid))),
            error: (error, _) => SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.cloud_off, size: 48, color: c.gray300),
              const SizedBox(height: 12),
              Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.textSecondary)),
              const SizedBox(height: 4),
              Text('$error', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: c.textMuted), textAlign: TextAlign.center, maxLines: 3),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.invalidate(dashboardProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text('Retry'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
            ]))),
            data: (dash) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── Alerts ────────────────────────────────────────
                if (dash.kpis.overdueTasks > 0)
                  AlertBanner(message: 'overdue_tasks_alert'.tr(context, params: {'count': '${dash.kpis.overdueTasks}'}), type: 'error'),
                if (dash.kpis.pendingRequests > 0)
                  AlertBanner(message: 'pending_requests_alert'.tr(context, params: {'count': '${dash.kpis.pendingRequests}'}), type: 'warning'),

                // ── Branch Selector ───────────────────────────────
                Builder(builder: (ctx) {
                  final sel = ref.watch(selectedBranchProvider);
                  final companyLine = sel.companyLabel('All companies'.tr(context));
                  final branchLine = sel.isAll ? 'All branches'.tr(context)
                    : sel.isBranch ? sel.branchLabel('') : 'All branches'.tr(context);
                  return GestureDetector(
                    onTap: () => _showBranchSheet(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.card,
                        border: Border.all(color: AppColors.navyMid.withOpacity(0.12))),
                      child: Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.navyGradient,
                            borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Icon(Icons.store_rounded, color: Colors.white, size: 20))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(companyLine, style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.2),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(branchLine, style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 11, color: c.textMuted, height: 1.2),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.navyMid.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('Change'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyMid)),
                          ])),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // ── KPI Grid ──────────────────────────────────────
                SectionHeader(title: 'Operational KPIs'.tr(context)),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
                  padding: EdgeInsets.zero,
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
                  padding: EdgeInsets.zero,
                  children: _getQuickActions(context).map((a) => GestureDetector(
                    onTap: () => context.push(a['r'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: c.bgCard,
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
                          fontSize: 10, fontWeight: FontWeight.w700, color: c.textSecondary),
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
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
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
                                color: c.bgCard,
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
                                    backgroundColor: c.gray100,
                                    valueColor: AlwaysStoppedAnimation(perfColor), minHeight: 3)),
                                const SizedBox(height: 8),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  _deptChip('${d.employeeCount}', '👥', c),
                                  _deptChip('${d.present}', '✅', c),
                                  _deptChip('${d.pendingRequests}', '📋', c),
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

              ])),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _headerStat(String v, String l, Color c) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white60, height: 1.2)),
    const SizedBox(width: 4),
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800, color: c, height: 1.2)),
  ]);

  Widget _deptChip(String v, String ico, AppColorsExtension c) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(ico, style: const TextStyle(fontSize: 10)),
    const SizedBox(width: 2),
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800, color: c.textPrimary)),
  ]);

  Widget _taskStat(String v, String l, Color c, AppColorsExtension colors) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: c, height: 1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: colors.textMuted)),
    ]),
  ));

  void _showBranchSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BranchSelectorSheet(parentRef: ref),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Company/Branch Selector Bottom Sheet
// ═══════════════════════════════════════════════════════════════════

class _BranchSelectorSheet extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _BranchSelectorSheet({required this.parentRef});
  @override
  ConsumerState<_BranchSelectorSheet> createState() => _BranchSelectorSheetState();
}

class _BranchSelectorSheetState extends ConsumerState<_BranchSelectorSheet> {
  late BranchSelection _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.parentRef.read(selectedBranchProvider);
  }

  void _selectAll() => setState(() => _temp = const BranchSelection());

  void _selectCompany(BranchCompany company) => setState(() =>
    _temp = BranchSelection(company: company));

  void _selectBranch(BranchCompany company, Branch branch) => setState(() =>
    _temp = BranchSelection(company: company, branch: branch));

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final branchesAsync = ref.watch(branchesProvider);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── Handle ──
        Center(child: Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: c.gray300, borderRadius: BorderRadius.circular(2)))),

        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            const SizedBox(width: 36),
            Expanded(child: Text('Select company or branch'.tr(context),
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16,
                fontWeight: FontWeight.w800, color: c.textPrimary),
              textAlign: TextAlign.center)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: c.bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.close_rounded, size: 20, color: c.textMuted))),
          ])),
        const SizedBox(height: 12),
        const Divider(height: 1),

        // ── Body ──
        Flexible(child: branchesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline, size: 40, color: AppColors.error),
              const SizedBox(height: 8),
              Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 13, color: c.textMuted)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(branchesProvider),
                child: Text('Retry'.tr(context))),
            ])),
          data: (data) {
            // Group by company
            final grouped = <int, _CompanyGroup>{};
            for (final b in data.branches) {
              final cid = b.companyId;
              grouped.putIfAbsent(cid, () => _CompanyGroup(
                company: b.company ?? BranchCompany(id: cid, nameAr: 'Other'.tr(context)),
                branches: [],
              )).branches.add(b);
            }

            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // ── "All" option ──
                _selectionTile(
                  icon: Icons.language_rounded,
                  title: 'All companies'.tr(context),
                  subtitle: 'Show all data'.tr(context),
                  isSelected: _temp.isAll,
                  onTap: _selectAll,
                ),
                // ── Companies + their branches ──
                ...grouped.values.expand((group) => [
                  // Company header (selectable)
                  _selectionTile(
                    icon: Icons.business_rounded,
                    title: group.company.displayName,
                    subtitle: 'branches_count'.tr(context, params: {'count': '${group.branches.length}'}),
                    isSelected: _temp.isCompany && _temp.companyId == group.company.id,
                    onTap: () => _selectCompany(group.company),
                    isCompany: true,
                  ),
                  // Branches under this company (indented)
                  ...group.branches.map((branch) => Padding(
                    padding: const EdgeInsetsDirectional.only(start: 24),
                    child: _selectionTile(
                      icon: Icons.store_rounded,
                      title: branch.name ?? branch.branchName,
                      subtitle: branch.location.isNotEmpty ? branch.location : branch.code,
                      isSelected: _temp.isBranch && _temp.branchId == branch.id,
                      onTap: () => _selectBranch(group.company, branch),
                    ),
                  )),
                ]),
              ],
            );
          },
        )),

        // ── Footer ──
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          child: SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.parentRef.read(selectedBranchProvider.notifier).state = _temp;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyMid, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text('Save'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _selectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCompany = false,
  }) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navyMid.withOpacity(0.06) : c.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.navyMid.withOpacity(0.4) : c.gray200,
            width: isSelected ? 1.5 : 1)),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navyMid.withOpacity(0.12)
                : isCompany ? AppColors.gold.withOpacity(0.1) : c.bg,
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18,
              color: isSelected ? AppColors.navyMid
                : isCompany ? AppColors.gold : c.textMuted)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
              fontWeight: isCompany ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.navyMid : c.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
              color: c.textMuted),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          if (isSelected)
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(
                color: AppColors.navyMid, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 14))
          else
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.gray300, width: 1.5))),
        ]),
      ),
    );
  }
}

class _CompanyGroup {
  final BranchCompany company;
  final List<Branch> branches;
  _CompanyGroup({required this.company, required this.branches});
}
