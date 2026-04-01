import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_portal_admin/core/providers/core_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/paginated_providers.dart';
import '../../../../core/providers/paginated_notifier.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../data/models/attendance_models.dart';
import '../../data/models/leave_models.dart';
import '../../../../core/localization/app_localizations.dart';

String _leaveStatusTr(BuildContext context, String s) => switch (s) {
  'draft'     => 'Draft'.tr(context),
  'pending'   => 'Pending'.tr(context),
  'approved'  => 'Approved'.tr(context),
  'rejected'  => 'Rejected'.tr(context),
  'cancelled' => 'Cancelled'.tr(context),
  _           => s,
};

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATTENDANCE MANAGEMENT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AttendanceManagementScreen extends ConsumerStatefulWidget {
  const AttendanceManagementScreen({super.key});
  @override
  ConsumerState<AttendanceManagementScreen> createState() => _AttMgmtState();
}

class _AttMgmtState extends ConsumerState<AttendanceManagementScreen> {
  int _tab = 0;
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    ref.invalidate(adminAttendanceProvider);
    try { await ref.read(adminAttendanceProvider.future); } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  List<AdminAttendanceRecord> _filterRecords(List<AdminAttendanceRecord> records) {
    switch (_tab) {
      case 1: return records.where((r) => r.status == 'present').toList();
      case 2: return records.where((r) => r.status == 'late').toList();
      case 3: return records.where((r) => r.status == 'absent').toList();
      case 4: return records.where((r) => r.status == 'leave').toList();
      default: return records;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final attendanceAsync = ref.watch(adminAttendanceProvider);
    return Scaffold(
      backgroundColor: c.bg,
      body: attendanceAsync.when(
        loading: () => Column(children: [
          _buildHeader(context, present: 0, late_: 0, absent: 0, onLeave: 0,
            total: 0, date: '...'),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          _buildHeader(context, present: 0, late_: 0, absent: 0, onLeave: 0,
            total: 0, date: '...'),
          Expanded(child: Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w700, color: c.textSecondary)),
              const SizedBox(height: 8),
              Text('$e', style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                color: c.textMuted), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              PrimaryBtn(text: 'Retry'.tr(context), small: true, fullWidth: false,
                onTap: () => ref.invalidate(adminAttendanceProvider)),
            ]),
          ))),
        ]),
        data: (data) {
          final summary = data.summary;
          final filtered = _filterRecords(data.records);
          final attendancePercent = summary.total > 0
            ? ((summary.present / summary.total) * 100).round()
            : 0;
          return Column(children: [
            _buildHeader(context,
              present: summary.present,
              late_: summary.late,
              absent: summary.absent,
              onLeave: summary.onLeave,
              total: summary.total,
              date: data.date),
            // Stats cards
            Container(color: c.bgCard,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(children: [
                _smallStat('${summary.total}', 'Total employees stat'.tr(context), AppColors.navyMid, c),
                const SizedBox(width: 10),
                _smallStat('${summary.late + summary.absent}', 'Exceptions today'.tr(context), AppColors.error, c),
                const SizedBox(width: 10),
                _smallStat('$attendancePercent%', 'Attendance rate'.tr(context), AppColors.success, c),
              ])),
            FilterBar(tabs: ['All'.tr(context),'Present'.tr(context),'Late'.tr(context),'Absent'.tr(context),'On Leave'.tr(context)],
              selected: _tab, onSelect: (i) => setState(() => _tab = i)),
            Expanded(child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminAttendanceProvider);
                // Wait for the provider to refetch
                await ref.read(adminAttendanceProvider.future);
              },
              child: filtered.isEmpty
                ? ListView(children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Center(child: Text('No records'.tr(context), style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 14, color: c.textMuted))),
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final r = filtered[i];
                      return GestureDetector(
                        onTap: () => context.push('/attendance-detail', extra: r),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: c.bgCard, borderRadius: BorderRadius.circular(14),
                            boxShadow: AppShadows.card),
                          child: Row(children: [
                            Column(children: [
                              StatusBadge(
                                text: r.status == 'present' ? 'Present'.tr(context) : r.status == 'late' ? 'Late'.tr(context)
                                  : r.status == 'leave' ? 'On Leave'.tr(context) : 'Absent'.tr(context),
                                type: r.status == 'present' ? 'approved'
                                  : r.status == 'late' ? 'warning'
                                  : r.status == 'leave' ? 'leave' : 'error', dot: true),
                            ]),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(r.employeeName, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
                              Text('${r.department} · ${r.employeeCode}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: c.textMuted)),
                            ])),
                            const SizedBox(width: 10),
                            if (r.status != 'absent' && r.status != 'leave')
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text('${r.checkIn ?? '--:--'} — ${r.checkOut ?? '--:--'}', style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 11, color: c.textSecondary, fontWeight: FontWeight.w600)),
                                if (r.lateMinutes > 0)
                                  Text('late_min'.tr(context, params: {'min': '${r.lateMinutes}'}), style: TextStyle(fontFamily: 'Cairo',
                                    fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w700)),
                                if (r.overtimeMinutes > 0)
                                  Text('overtime_min'.tr(context, params: {'min': '${r.overtimeMinutes}'}), style: TextStyle(fontFamily: 'Cairo',
                                    fontSize: 10, color: AppColors.teal, fontWeight: FontWeight.w700)),
                              ])
                            else Text('—', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: c.gray400)),
                          ]),
                        ),
                      );
                    },
                  ),
            )),
          ]);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {
    required int present, required int late_, required int absent,
    required int onLeave, required int total, required String date,
  }) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.navyGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16, left: 18, right: 18),
      child: Column(children: [
        Row(children: [
          // START: زر الرجوع
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
            const SizedBox(width: 8),
          ],
          // CENTER: العنوان
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('Attendance Management'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(date == '...' ? '...' : '${'Today'.tr(context)} — $date', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 11, color: AppColors.goldLight)),
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
              onTap: () => context.push('/all-attendance'),
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
          _attPill('$present', 'Present'.tr(context), AppColors.success),
          const SizedBox(width: 6),
          _attPill('$late_',   'Late'.tr(context), AppColors.warning),
          const SizedBox(width: 6),
          _attPill('$absent',  'Absent'.tr(context), AppColors.error),
          const SizedBox(width: 6),
          _attPill('$onLeave', 'On Leave'.tr(context), AppColors.teal),
        ]),
      ]),
    );
  }

  Widget _attPill(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
    ])));
  Widget _smallStat(String v, String l, Color c, AppColorsExtension colors) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: colors.textMuted, height: 1.2), textAlign: TextAlign.center),
    ])));
}

// ── Attendance Detail ─────────────────────────────────────
class AttendanceDetailScreen extends ConsumerWidget {
  final AdminAttendanceRecord? record;
  const AttendanceDetailScreen({super.key, this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    // Try to get the record from constructor or from GoRouter extra
    final r = record ?? (GoRouterState.of(context).extra as AdminAttendanceRecord?);
    if (r == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Column(children: [
          AdminAppBar(title: 'تفاصيل سجل الحضور', subtitle: '',
            onBack: () => context.pop()),
          const Expanded(child: Center(child: Text('لا توجد بيانات',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14)))),
        ]),
      );
    }

    final statusText = r.status == 'present' ? 'حاضر'
      : r.status == 'late' ? 'متأخر'
      : r.status == 'leave' ? 'إجازة' : 'غائب';
    final statusType = r.status == 'present' ? 'approved'
      : r.status == 'late' ? 'warning'
      : r.status == 'leave' ? 'leave' : 'error';
    final hoursStr = '${r.workedHours.toStringAsFixed(1)} ساعة';

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل سجل الحضور',
          subtitle: '${r.employeeName} — ${r.date}',
          onBack: () => context.pop()),
        Expanded(child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminAttendanceProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              AppCard(mb: 14, child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  StatusBadge(text: statusText, type: statusType, dot: true),
                  Text(r.date, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
                ]),
                Divider(height: 20, color: c.gray100),
                InfoRow(label: 'الموظف',         value: r.employeeName, icon: '👤'),
                InfoRow(label: 'الإدارة',         value: r.department,   icon: '🏢'),
                InfoRow(label: 'الرمز الوظيفي',   value: r.employeeCode, icon: '🔢'),
                InfoRow(label: 'وقت الدخول',      value: r.checkIn ?? '—', icon: '🟢'),
                InfoRow(label: 'وقت الخروج',     value: r.checkOut ?? '—', icon: '🔴'),
                InfoRow(label: 'إجمالي الساعات', value: hoursStr,        icon: '⏱'),
                InfoRow(label: 'وقت التأخر',      value: r.lateMinutes > 0 ? '${r.lateMinutes} دقيقة' : 'لا يوجد', icon: '⚠️'),
                InfoRow(label: 'الوقت الإضافي',  value: r.overtimeMinutes > 0 ? '${r.overtimeMinutes} دقيقة' : 'لا يوجد', icon: '✨', border: false),
              ])),
              AppCard(mb: 14, child: Column(children: [
                Align(alignment: Alignment.centerRight, child: Text('الموقع والجهاز',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
                const SizedBox(height: 10),
                const InfoRow(label: 'موقع الدخول',  value: 'المقر الرئيسي — الرياض', icon: '📍'),
                const InfoRow(label: 'جهاز التسجيل', value: 'بصمة المدخل الرئيسي',   icon: '🖐', border: false),
              ])),
            ]),
          ),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: OutlineBtn(text: '✏️ تصحيح السجل', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: PrimaryBtn(text: '📋 ملف الموظف', onTap: () => context.push('/employee-detail', extra: r.employeeId))),
        ])),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LEAVE MANAGEMENT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class LeaveManagementScreen extends ConsumerStatefulWidget {
  const LeaveManagementScreen({super.key});
  @override ConsumerState<LeaveManagementScreen> createState() => _LeaveMgmtState();
}
class _LeaveMgmtState extends ConsumerState<LeaveManagementScreen> {
  int _tab = 0;
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    ref.invalidate(paginatedManagerLeavesProvider);
    try { await ref.read(paginatedManagerLeavesProvider.future); } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  // pending, all, draft, approved, rejected, cancelled
  static const _statusMap = ['pending', null, 'draft', 'approved', 'rejected', 'cancelled'];
  static const _labels = ['Pending', 'All', 'Draft', 'Approved', 'Rejected', 'Cancelled'];
  static const _colors = [AppColors.warning, AppColors.goldLight, AppColors.g400, AppColors.tealLight, AppColors.error, AppColors.navyMid];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final leavesAsync = ref.watch(paginatedManagerLeavesProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 16, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              // START: زر الرجوع
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
                const SizedBox(width: 8),
              ],
              // CENTER: العنوان
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('Leave Management'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Leave overview'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: AppColors.goldLight)),
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
              ]),
            ]),
            const SizedBox(height: 14),
            leavesAsync.when(
              data: (paginated) {
                final all = paginated.items;
                int _c(String s) => all.where((l) => l.status == s).length;
                return _buildFilterRow(context, [
                  _c('pending'), all.length, _c('draft'), _c('approved'), _c('rejected'), _c('cancelled'),
                ]);
              },
              loading: () => _buildFilterRow(context, null),
              error: (_, __) => _buildFilterRow(context, null),
            ),
          ]),
        ),
        Expanded(child: leavesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navyMid)),
          error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.textSecondary)),
            const SizedBox(height: 4),
            Text('$e', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c.textMuted), textAlign: TextAlign.center, maxLines: 3),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(paginatedManagerLeavesProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('Retry'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
          ])),
          data: (paginated) {
            final filtered = _statusMap[_tab] == null
              ? paginated.items
              : paginated.items.where((l) => l.status == _statusMap[_tab]).toList();
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedManagerLeavesProvider);
                await ref.read(paginatedManagerLeavesProvider.future);
              },
              child: PaginatedListView<LeaveRequest>(
                items: filtered,
                isLoadingMore: paginated.isLoadingMore,
                hasMore: _tab == 1 ? paginated.hasMore : false,
                loadMoreError: paginated.loadMoreError,
                onFetchMore: () => ref.read(paginatedManagerLeavesProvider.notifier).fetchMore(),
                emptyWidget: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.event_available, size: 48, color: c.gray300),
                  const SizedBox(height: 12),
                  Text('No leaves'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.textMuted)),
                ])),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, l, i) {
                  final statusLabel = _leaveStatusTr(context, l.status);
                  final statusType = l.status == 'approved' ? 'approved'
                    : l.status == 'rejected' ? 'rejected'
                    : l.status == 'cancelled' ? 'error'
                    : l.status == 'draft' ? 'leave' : 'pending';
                  final borderColor = l.status == 'approved' ? AppColors.success
                    : l.status == 'rejected' ? AppColors.error
                    : l.status == 'cancelled' ? AppColors.g400
                    : l.status == 'draft' ? AppColors.g400 : AppColors.warning;
                  return GestureDetector(
                    onTap: () => context.push('/leave-detail/${l.id}'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.bgCard, borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.sm,
                        border: Border(right: BorderSide(color: borderColor, width: 3))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          StatusBadge(text: statusLabel, type: statusType),
                          Text(l.employee?.name ?? '—', style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 13, fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${l.totalDays.toStringAsFixed(0)} ${'days'.tr(context)}', style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 11, color: c.textMuted)),
                          Text(l.leaveType.name, style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 12, color: c.textSecondary)),
                        ]),
                        const SizedBox(height: 4),
                        Text('${l.startDate} ← ${l.endDate}', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 11, color: c.textMuted)),
                      ]),
                    ),
                  );
                },
              ),
            );
          },
        )),
      ]),
    );
  }

  Widget _buildFilterRow(BuildContext context, List<int>? counts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(children: List.generate(_labels.length, (i) {
        final v = counts != null ? '${counts[i]}' : '...';
        return Padding(
          padding: EdgeInsetsDirectional.only(end: i < _labels.length - 1 ? 6 : 0),
          child: _filterPill(v, _labels[i].tr(context), _colors[i], i),
        );
      })),
    );
  }

  Widget _filterPill(String v, String l, Color accentColor, int index) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.15),
            width: selected ? 1.5 : 1)),
        child: Column(children: [
          Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900,
            color: accentColor, height: 1.1)),
          Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
            color: selected ? Colors.white : Colors.white54)),
        ]),
      ),
    );
  }
}

// ── Leave Detail ──────────────────────────────────────────
class LeaveDetailAdminScreen extends ConsumerStatefulWidget {
  final int leaveId;
  const LeaveDetailAdminScreen({super.key, required this.leaveId});
  @override ConsumerState<LeaveDetailAdminScreen> createState() => _LeaveDetailState();
}

class _LeaveDetailState extends ConsumerState<LeaveDetailAdminScreen> {
  String? _decision;
  bool _processing = false;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _decide(String status) async {
    if (status == 'rejected' && _notesCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Rejection reason required'.tr(context),
          style: const TextStyle(fontFamily: 'Cairo'))));
      return;
    }
    setState(() => _processing = true);
    try {
      await ref.read(leaveRepositoryProvider).decideLeave(
        widget.leaveId,
        status: status,
        responseNotes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );
      setState(() { _decision = status; _processing = false; });
      ref.invalidate(paginatedManagerLeavesProvider);
    } catch (e) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${'Error'.tr(context)}: $e',
            style: const TextStyle(fontFamily: 'Cairo'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final asyncLeave = ref.watch(managerLeaveDetailProvider(widget.leaveId));

    return Scaffold(
      backgroundColor: c.bg,
      body: asyncLeave.when(
        loading: () => Column(children: [
          AdminAppBar(title: 'Leave details'.tr(context), onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          AdminAppBar(title: 'Leave details'.tr(context), onBack: () => context.pop()),
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.textSecondary)),
            const SizedBox(height: 16),
            PrimaryBtn(text: 'Retry'.tr(context), small: true, fullWidth: false,
              onTap: () => ref.invalidate(managerLeaveDetailProvider(widget.leaveId))),
          ]))),
        ]),
        data: (leave) {
          if (_decision != null) return _buildDecisionResult(context);
          return _buildDetail(context, leave);
        },
      ),
    );
  }

  Widget _buildDecisionResult(BuildContext context) {
    final c = context.appColors;
    final isApproved = _decision == 'approved';
    return Column(children: [
      AdminAppBar(title: 'Leave details'.tr(context), onBack: () => context.pop()),
      Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(
            color: isApproved ? AppColors.successSoft : AppColors.errorSoft,
            shape: BoxShape.circle),
          child: Center(child: Icon(
            isApproved ? Icons.check : Icons.close,
            color: isApproved ? AppColors.success : AppColors.error, size: 40))),
        const SizedBox(height: 16),
        Text(isApproved
          ? '✅ ${'Leave approved'.tr(context)}'
          : '❌ ${'Leave rejected'.tr(context)}',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Employee notified'.tr(context), style: TextStyle(fontFamily: 'Cairo',
          fontSize: 13, color: c.textMuted)),
        const SizedBox(height: 24),
        OutlineBtn(text: 'Back to leaves'.tr(context), fullWidth: false,
          onTap: () => context.pop()),
      ]))),
    ]);
  }

  Widget _buildDetail(BuildContext context, LeaveRequest leave) {
    final c = context.appColors;
    final emp = leave.employee;

    return Column(children: [
      AdminAppBar(title: 'Leave details'.tr(context),
        subtitle: leave.requestNumber,
        onBack: () => context.pop()),
      Expanded(child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // ── Employee info + status ──
          AppCard(mb: 16, child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _leaveStatusBadge(context, leave.status),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(emp?.name ?? '—', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 15, fontWeight: FontWeight.w800)),
                Text('${emp?.code ?? ''} - ${emp?.jobTitle ?? ''}', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: c.textMuted)),
              ]),
              const SizedBox(width: 10),
              AdminAvatar(initials: (emp?.name ?? '?').characters.first, size: 44, fontSize: 18),
            ]),
          ])),

          // ── Details grid ──
          AppCard(mb: 16, child: Column(children: [
            _infoRow(context, c,
              'Request number'.tr(context), leave.requestNumber,
              'Leave type'.tr(context), leave.leaveType.name),
            const Divider(height: 24),
            _infoRow(context, c,
              'From date'.tr(context), leave.startDate,
              'To date'.tr(context), leave.endDate),
            const Divider(height: 24),
            _infoRow(context, c,
              'Number of days'.tr(context), leave.totalDays.toStringAsFixed(1),
              'Submission date'.tr(context), _fmtDate(leave.createdAt)),
            if (leave.reason != null && leave.reason!.isNotEmpty) ...[
              const Divider(height: 24),
              Align(alignment: AlignmentDirectional.centerEnd,
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Reason'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 11, color: c.textMuted)),
                  const SizedBox(height: 2),
                  Text(leave.reason!, style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 13, fontWeight: FontWeight.w600)),
                ])),
            ],
          ])),

          // ── Approval path ──
          AppCard(mb: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('Approval path'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              const Icon(Icons.account_tree_outlined, size: 20),
            ]),
            const Divider(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: leave.status == 'pending' ? AppColors.warningSoft
                  : leave.status == 'approved' ? AppColors.successSoft
                  : leave.status == 'rejected' ? AppColors.errorSoft : c.bg,
                borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Expanded(child: Text(
                  _leaveStatusTr(context, leave.status),
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: c.textMuted))),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Direct manager'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 13, fontWeight: FontWeight.w700)),
                  if (leave.approvedBy != null)
                    Text('ID: ${leave.approvedBy}', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 10, color: c.textMuted)),
                ])),
                const SizedBox(width: 8),
                Container(width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: leave.status == 'pending' ? AppColors.warning
                      : leave.status == 'approved' ? AppColors.success
                      : leave.status == 'rejected' ? AppColors.error : c.gray300,
                    shape: BoxShape.circle),
                  child: Icon(
                    leave.status == 'approved' ? Icons.check
                      : leave.status == 'rejected' ? Icons.close : Icons.access_time,
                    color: Colors.white, size: 18)),
              ]),
            ),
          ])),

          // ── Notes field (for pending) ──
          if (leave.status == 'pending' && leave.canDecide == true)
            AppCard(mb: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Notes'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: fieldDec(context, 'Add notes'.tr(context)),
              ),
            ])),

          // ── Rejection reason (if rejected) ──
          if (leave.status == 'rejected' && leave.rejectionReason != null)
            AppCard(mb: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Rejection reason'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
              const SizedBox(height: 4),
              Text(leave.rejectionReason!, style: TextStyle(fontFamily: 'Cairo',
                fontSize: 13, color: c.textSecondary)),
            ])),

          const SizedBox(height: 80),
        ]),
      )),

      // ── Action buttons ──
      if (leave.status == 'pending' && leave.canDecide == true)
        StickyBar(child: _processing
          ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator()))
          : Row(children: [
              OutlineBtn(text: 'Close'.tr(context),
                onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(child: DangerBtn(text: '✗ ${'Reject'.tr(context)}',
                onTap: () => _decide('rejected'))),
              const SizedBox(width: 8),
              Expanded(child: TealBtn(text: '✓ ${'Approve'.tr(context)}',
                onTap: () => _decide('approved'))),
            ])),
    ]);
  }

  Widget _leaveStatusBadge(BuildContext context, String status) {
    return StatusBadge(
      text: _leaveStatusTr(context, status),
      type: status == 'approved' ? 'approved'
        : status == 'rejected' ? 'rejected'
        : status == 'cancelled' ? 'error'
        : status == 'draft' ? 'leave' : 'pending',
      dot: true,
    );
  }

  Widget _infoRow(BuildContext context, AppColorsExtension c,
    String label1, String value1, String label2, String value2) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(label2, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: c.textMuted)),
        const SizedBox(height: 2),
        Text(value2, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
      ])),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(label1, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: c.textMuted)),
        const SizedBox(height: 2),
        Text(value1, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
      ])),
    ]);
  }

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    } catch (_) { return iso; }
  }
}
