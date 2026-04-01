import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/paginated_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/employee_models.dart';

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
    final c = context.appColors;
    final employeesAsync = ref.watch(paginatedEmployeesProvider);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'Employees'.tr(context),
          subtitle: employeesAsync.whenOrNull(
            data: (d) => 'active_employees'.tr(context, params: {'count': '${d.items.length}'}),
          ),
          onBack: () => context.pop()),
        Container(
          color: c.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(children: [
            TextField(
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
              onChanged: (v) {
                ref.read(employeesSearchProvider.notifier).state = v;
              },
              decoration: fieldDec(context, 'Search employee'.tr(context)).copyWith(
                prefixIcon: Icon(Icons.search, color: c.gray400, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
            const SizedBox(height: 8),
          ]),
        ),
        FilterBar(
          tabs: ['All'.tr(context),'Present'.tr(context),'Late'.tr(context),'On Leave'.tr(context),'Absent'.tr(context)],
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
              Text('Error'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context), small: true, fullWidth: false,
                onTap: () => ref.invalidate(paginatedEmployeesProvider)),
            ],
          )),
          data: (paginated) {
            final employees = paginated.items;
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedEmployeesProvider);
                await ref.read(paginatedEmployeesProvider.future);
              },
              child: PaginatedListView<AdminEmployee>(
                items: employees,
                isLoadingMore: paginated.isLoadingMore,
                hasMore: paginated.hasMore,
                loadMoreError: paginated.loadMoreError,
                onFetchMore: () => ref.read(paginatedEmployeesProvider.notifier).fetchMore(),
                emptyWidget: Center(child: Text('No employees'.tr(context),
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.textMuted))),
                itemBuilder: (_, e, i) {
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
    final c = context.appColors;
    final detailAsync = ref.watch(employeeDetailProvider(employeeId));
    return Scaffold(
      backgroundColor: c.bg,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
            const SizedBox(height: 8),
            OutlineBtn(text: 'Retry'.tr(context), small: true, fullWidth: false,
              onTap: () => ref.invalidate(employeeDetailProvider(employeeId))),
          ],
        )),
        data: (e) => _buildDetail(context, ref, e, c),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, dynamic e, AppColorsExtension c) {
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
              _stat(e.hireDate ?? '-', 'تاريخ التحاق', '🏅', c),
              const SizedBox(width: 10),
              _stat('${e.pendingRequests}', 'طلبات', '📋', c),
              const SizedBox(width: 10),
              _stat('${e.activeTasks}', 'مهام', '✅', c),
            ]),
            const SizedBox(height: 14),
            // Work info
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Employment Info'.tr(context), style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'القسم',           value: e.department?.name ?? '-', icon: '🏢'),
              InfoRow(label: 'المسمى الوظيفي', value: e.jobTitle ?? '-',         icon: '💼'),
              InfoRow(label: 'المدير المباشر',  value: e.manager ?? '-',         icon: '👤'),
              InfoRow(label: 'تاريخ الالتحاق', value: e.hireDate ?? '-',        icon: '📅'),
              InfoRow(label: 'الحالة',           value: e.employmentStatus,       icon: '✅', border: false),
            ])),
            // Contact
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Contact Info'.tr(context), style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'البريد الإلكتروني', value: e.email ?? '-',  icon: '✉️'),
              InfoRow(label: 'الجوال',             value: e.mobile ?? '-', icon: '📱', border: false),
            ])),
            // Attendance summary
            if (att != null)
              AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(onTap: () => context.push('/attendance'),
                    child: Text('View Record'.tr(context), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.navyLight, fontWeight: FontWeight.w700))),
                  Text('ملخص الحضور — ${att.month}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _attStat('${att.presentDays}', 'حاضر', AppColors.success, c),
                  const SizedBox(width: 8),
                  _attStat('${att.lateDays}', 'متأخر', AppColors.warning, c),
                  const SizedBox(width: 8),
                  _attStat('${att.leaveDays}', 'إجازة', AppColors.teal, c),
                  const SizedBox(width: 8),
                  _attStat('${att.absentDays}', 'غياب', AppColors.error, c),
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
                _leaveRow('سنوية', '${leave.annualTotal}', '${leave.annualUsed}', '${leave.annualAvailable}', c),
                _leaveRow('مرضية', '${leave.sickTotal}', '${leave.sickUsed}', '${leave.sickAvailable}', c),
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

  Widget _stat(String v, String l, String ico, AppColorsExtension c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: c.bgCard,
      borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.sm),
    child: Column(children: [
      Text(ico, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(v, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c.textMuted)),
    ])));
  Widget _attStat(String v, String l, Color col, AppColorsExtension c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: col.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10), border: Border.all(color: col.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: col, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: c.textMuted)),
    ])));
  Widget _leaveRow(String type, String total, String used, String rem, AppColorsExtension c) =>
    Container(padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.gray100))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Text(rem, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navyMid)),
          Text(' متبقي', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c.textMuted)),
        ]),
        Text('$type — من $total', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: c.textSecondary)),
      ]));
}
