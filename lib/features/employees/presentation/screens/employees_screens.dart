import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';

// ── Employees Directory ───────────────────────────────────
class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});
  @override ConsumerState<EmployeesScreen> createState() => _EmployeesState();
}
class _EmployeesState extends ConsumerState<EmployeesScreen> {
  int _tab = 0;

  static const _statusMap = <int, String?>{
    0: null,
    1: 'حاضر',
    2: 'متأخر',
    3: 'إجازة',
    4: 'غائب',
  };

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'الموظفون',
          subtitle: employeesAsync.whenOrNull(
            data: (d) => '${d.employees.length} موظف نشط',
          ),
          onBack: () => context.pop()),
        Container(
          color: AppColors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(children: [
            TextField(
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
              onChanged: (v) {
                ref.read(employeesSearchProvider.notifier).state = v;
              },
              decoration: fieldDec('ابحث عن موظف أو رقم...').copyWith(
                prefixIcon: const Icon(Icons.search, color: AppColors.g400, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
            const SizedBox(height: 8),
          ]),
        ),
        FilterBar(
          tabs: const ['الكل','حاضر','متأخر','إجازة','غائب'],
          selected: _tab,
          onSelect: (i) {
            setState(() => _tab = i);
            ref.read(employeesStatusProvider.notifier).state = _statusMap[i];
          }),
        Expanded(child: employeesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('حدث خطأ', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'إعادة المحاولة', small: true, fullWidth: false,
                onTap: () => ref.invalidate(employeesProvider)),
            ],
          )),
          data: (data) {
            final employees = data.employees;
            if (employees.isEmpty) {
              return Center(child: Text('لا يوجد موظفون',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx3)));
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(employeesProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: employees.length,
                itemBuilder: (_, i) {
                  final e = employees[i];
                  return EmployeeListCard(
                    initials: e.initials ?? '',
                    name: e.name,
                    title: e.jobTitle ?? '',
                    dept: e.department?.name ?? '',
                    id: e.code,
                    status: e.employmentStatus,
                    attendanceStatus: e.attendanceStatus ?? '',
                    onTap: () => context.push('/employee-detail/${e.id}'));
                },
              ),
            );
          },
        )),
      ]),
    );
  }
}

// ── Employee Detail ───────────────────────────────────────
class EmployeeDetailScreen extends ConsumerWidget {
  final int employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(employeeDetailProvider(employeeId));
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('حدث خطأ', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
            const SizedBox(height: 8),
            OutlineBtn(text: 'إعادة المحاولة', small: true, fullWidth: false,
              onTap: () => ref.invalidate(employeeDetailProvider(employeeId))),
          ],
        )),
        data: (e) => _buildDetail(context, ref, e),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, dynamic e) {
    final att = e.attendanceSummary;
    final leave = e.leaveSummary;
    return Column(children: [
      Container(
        decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          bottom: 24, left: 18, right: 18),
        child: Column(children: [
          Row(children: [
            GestureDetector(onTap: () => context.pop(),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
            Expanded(child: Column(children: [
              AdminAvatar(initials: e.initials ?? '', size: 64, fontSize: 22),
              const SizedBox(height: 10),
              Text(e.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(e.jobTitle ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                StatusBadge(text: e.code, type: 'navy'),
                const SizedBox(width: 8),
                if (e.attendanceStatus != null)
                  StatusBadge(
                    text: e.attendanceStatus!,
                    type: e.attendanceStatus == 'حاضر' ? 'approved'
                      : e.attendanceStatus == 'متأخر' ? 'warning'
                      : e.attendanceStatus == 'إجازة' ? 'leave' : 'error',
                    dot: true),
              ]),
            ])),
            const SizedBox(width: 36),
          ]),
        ]),
      ),
      Expanded(child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(employeeDetailProvider(employeeId)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(children: [
            // Quick stats
            Row(children: [
              _stat(e.hireDate ?? '-', 'تاريخ التحاق', '🏅'),
              const SizedBox(width: 10),
              _stat('${e.pendingRequests}', 'طلبات', '📋'),
              const SizedBox(width: 10),
              _stat('${e.activeTasks}', 'مهام', '✅'),
            ]),
            const SizedBox(height: 14),
            // Work info
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('بيانات التوظيف', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'القسم',           value: e.department?.name ?? '-', icon: '🏢'),
              InfoRow(label: 'المسمى الوظيفي', value: e.jobTitle ?? '-',         icon: '💼'),
              InfoRow(label: 'المدير المباشر',  value: e.manager ?? '-',         icon: '👤'),
              InfoRow(label: 'تاريخ الالتحاق', value: e.hireDate ?? '-',        icon: '📅'),
              InfoRow(label: 'الحالة',           value: e.employmentStatus,       icon: '✅', border: false),
            ])),
            // Contact
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('بيانات الاتصال', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'البريد الإلكتروني', value: e.email ?? '-',  icon: '✉️'),
              InfoRow(label: 'الجوال',             value: e.mobile ?? '-', icon: '📱', border: false),
            ])),
            // Attendance summary
            if (att != null)
              AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(onTap: () => context.push('/attendance'),
                    child: const Text('عرض السجل', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.navyLight, fontWeight: FontWeight.w700))),
                  Text('ملخص الحضور — ${att.month}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _attStat('${att.presentDays}', 'حاضر', AppColors.success),
                  const SizedBox(width: 8),
                  _attStat('${att.lateDays}', 'متأخر', AppColors.warning),
                  const SizedBox(width: 8),
                  _attStat('${att.leaveDays}', 'إجازة', AppColors.teal),
                  const SizedBox(width: 8),
                  _attStat('${att.absentDays}', 'غياب', AppColors.error),
                ]),
              ])),
            // Leave summary
            if (leave != null)
              AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(onTap: () => context.push('/leave'),
                    child: const Text('طلبات الإجازة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.navyLight, fontWeight: FontWeight.w700))),
                  const Text('رصيد الإجازات', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                _leaveRow('سنوية', '${leave.annualTotal}', '${leave.annualUsed}', '${leave.annualAvailable}'),
                _leaveRow('مرضية', '${leave.sickTotal}', '${leave.sickUsed}', '${leave.sickAvailable}'),
              ])),
          ]),
        ),
      )),
      StickyBar(child: Row(children: [
        Expanded(child: OutlineBtn(text: '📩 مراسلة', onTap: () {})),
        const SizedBox(width: 10),
        Expanded(child: TealBtn(text: '📋 الطلبات', onTap: () => context.push('/requests'))),
      ])),
    ]);
  }

  Widget _stat(String v, String l, String ico) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.sm),
    child: Column(children: [
      Text(ico, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(v, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
      Text(l, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
    ])));
  Widget _attStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: c.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: const TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3)),
    ])));
  Widget _leaveRow(String type, String total, String used, String rem) =>
    Container(padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.g100))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Text(rem, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navyMid)),
          const Text(' متبقي', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
        ]),
        Text('$type — من $total', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.tx2)),
      ]));
}
