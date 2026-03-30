import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../data/models/attendance_models.dart';

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
    final attendanceAsync = ref.watch(adminAttendanceProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
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
              Text('حدث خطأ في تحميل البيانات', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.tx2)),
              const SizedBox(height: 8),
              Text('$e', style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                color: AppColors.tx3), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              PrimaryBtn(text: 'إعادة المحاولة', small: true, fullWidth: false,
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
            Container(color: AppColors.bgCard,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(children: [
                _smallStat('${summary.total}', 'إجمالي الموظفين', AppColors.navyMid),
                const SizedBox(width: 10),
                _smallStat('${summary.late + summary.absent}', 'استثناءات اليوم', AppColors.error),
                const SizedBox(width: 10),
                _smallStat('$attendancePercent%', 'نسبة الحضور', AppColors.success),
              ])),
            FilterBar(tabs: const ['الكل','حاضر','متأخر','غائب','إجازة'],
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
                    Center(child: Text('لا توجد سجلات', style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx3))),
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
                            color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                            boxShadow: AppShadows.card),
                          child: Row(children: [
                            Column(children: [
                              StatusBadge(
                                text: r.status == 'present' ? 'حاضر' : r.status == 'late' ? 'متأخر'
                                  : r.status == 'leave' ? 'إجازة' : 'غائب',
                                type: r.status == 'present' ? 'approved'
                                  : r.status == 'late' ? 'warning'
                                  : r.status == 'leave' ? 'leave' : 'error', dot: true),
                            ]),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(r.employeeName, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
                              Text('${r.department} · ${r.employeeCode}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                            ])),
                            const SizedBox(width: 10),
                            if (r.status != 'absent' && r.status != 'leave')
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text('${r.checkIn ?? '--:--'} — ${r.checkOut ?? '--:--'}', style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 11, color: AppColors.tx2, fontWeight: FontWeight.w600)),
                                if (r.lateMinutes > 0)
                                  Text('تأخر ${r.lateMinutes}د', style: TextStyle(fontFamily: 'Cairo',
                                    fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w700)),
                                if (r.overtimeMinutes > 0)
                                  Text('إضافي ${r.overtimeMinutes}د', style: TextStyle(fontFamily: 'Cairo',
                                    fontSize: 10, color: AppColors.teal, fontWeight: FontWeight.w700)),
                              ])
                            else Text('—', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.g400)),
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
          GestureDetector(onTap: () => context.pop(),
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
          Expanded(child: Column(children: [
            Text('إدارة الحضور', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(date == '...' ? '...' : 'اليوم — $date', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 11, color: AppColors.goldLight)),
          ])),
          const SizedBox(width: 36),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _attPill('$present', 'حاضر', AppColors.success),
          const SizedBox(width: 6),
          _attPill('$late_',   'متأخر', AppColors.warning),
          const SizedBox(width: 6),
          _attPill('$absent',  'غائب', AppColors.error),
          const SizedBox(width: 6),
          _attPill('$onLeave', 'إجازة', AppColors.teal),
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
  Widget _smallStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3, height: 1.2), textAlign: TextAlign.center),
    ])));
}

// ── Attendance Detail ─────────────────────────────────────
class AttendanceDetailScreen extends ConsumerWidget {
  final AdminAttendanceRecord? record;
  const AttendanceDetailScreen({super.key, this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try to get the record from constructor or from GoRouter extra
    final r = record ?? (GoRouterState.of(context).extra as AdminAttendanceRecord?);
    if (r == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
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
      backgroundColor: AppColors.bg,
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
                const Divider(height: 20, color: AppColors.g100),
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

  static const _statusMap = [null, 'pending', 'approved', 'rejected'];

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(managerLeavesProvider);

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
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
              Expanded(child: Column(children: [
                Text('إدارة الإجازات', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('نظرة شاملة على الإجازات', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            leavesAsync.when(
              data: (data) {
                final all = data.leaves;
                final pending = all.where((l) => l.status == 'pending').length;
                final approved = all.where((l) => l.status == 'approved').length;
                return Row(children: [
                  _leavePill('${all.length}', 'إجمالي', AppColors.tealLight),
                  const SizedBox(width: 8),
                  _leavePill('$pending', 'معلق', AppColors.warning),
                  const SizedBox(width: 8),
                  _leavePill('$approved', 'معتمد', AppColors.goldLight),
                ]);
              },
              loading: () => Row(children: [
                _leavePill('...', 'إجمالي', AppColors.tealLight),
                const SizedBox(width: 8),
                _leavePill('...', 'معلق', AppColors.warning),
                const SizedBox(width: 8),
                _leavePill('...', 'معتمد', AppColors.goldLight),
              ]),
              error: (_, __) => Row(children: [
                _leavePill('—', 'إجمالي', AppColors.tealLight),
                const SizedBox(width: 8),
                _leavePill('—', 'معلق', AppColors.warning),
                const SizedBox(width: 8),
                _leavePill('—', 'معتمد', AppColors.goldLight),
              ]),
            ),
          ]),
        ),
        FilterBar(tabs: const ['الكل','معلق','معتمد','مرفوض'],
          selected: _tab, onSelect: (i) {
            setState(() => _tab = i);
            ref.read(managerLeavesStatusFilter.notifier).state = _statusMap[i];
          }),
        Expanded(child: leavesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navyMid)),
          error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('حدث خطأ في تحميل البيانات', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx2)),
            const SizedBox(height: 4),
            Text('$e', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3), textAlign: TextAlign.center, maxLines: 3),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(managerLeavesProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
          ])),
          data: (data) {
            if (data.leaves.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.event_available, size: 48, color: AppColors.g300),
                const SizedBox(height: 12),
                Text('لا توجد إجازات', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx3)),
              ]));
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(managerLeavesProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.leaves.length,
                itemBuilder: (context, i) {
                  final l = data.leaves[i];
                  final statusAr = l.status == 'approved' ? 'معتمد' : l.status == 'rejected' ? 'مرفوض' : 'معلق';
                  final statusType = l.status == 'approved' ? 'approved' : l.status == 'rejected' ? 'rejected' : 'pending';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.sm,
                      border: Border(right: BorderSide(
                        color: l.status == 'approved' ? AppColors.success : l.status == 'rejected' ? AppColors.error : AppColors.warning, width: 3))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        StatusBadge(text: statusAr, type: statusType),
                        Text(l.employee?.name ?? '—', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 13, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${l.totalDays.toStringAsFixed(0)} يوم', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 11, color: AppColors.tx3)),
                        Text(l.leaveType.name, style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 12, color: AppColors.tx2)),
                      ]),
                      const SizedBox(height: 4),
                      Text('${l.startDate} ← ${l.endDate}', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 11, color: AppColors.tx3)),
                    ]),
                  );
                },
              ),
            );
          },
        )),
      ]),
    );
  }
  Widget _leavePill(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
    ])));
}

// ── Leave Detail ──────────────────────────────────────────
class LeaveDetailAdminScreen extends StatelessWidget {
  const LeaveDetailAdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final leave = GoRouterState.of(context).extra;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل طلب الإجازة', subtitle: '',
          onBack: () => context.pop()),
        Expanded(child: Center(
          child: Text('تفاصيل الإجازة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx3)),
        )),
      ]),
    );
  }
}
