import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/paginated_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../admin_dashboard/presentation/screens/admin_dashboard_screen.dart'
    show showBranchSelectorSheet;
import '../../data/models/employee_models.dart';
import '../widgets/employees_advanced_filter_sheet.dart';

// ── Employees Directory ───────────────────────────────────
class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});
  @override ConsumerState<EmployeesScreen> createState() => _EmployeesState();
}
class _EmployeesState extends ConsumerState<EmployeesScreen> {
  int _tab = 0;

  // Top FilterBar now maps to employment_status (the API doesn't include
  // attendance_status in /admin/employees, so the old حاضر/متأخر tabs were
  // a no-op). The advanced sheet still offers more granular filters.
  static const _statusValues = <int, String?>{
    0: null,             // الكل
    1: 'core_employee',  // دائمين
    2: 'trainee',        // متدربون
    3: 'contractor',     // متعاقدون
    4: 'terminated',     // منتهية خدمتهم
  };

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final employeesAsync = ref.watch(paginatedEmployeesProvider);
    final hasAdvanced =
        ref.watch(employeesDepartmentFilterProvider) != null ||
            ref.watch(employeesEmploymentStatusFilterProvider) != null;
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'Employees'.tr(context),
          subtitle: employeesAsync.whenOrNull(
            data: (d) => 'active_employees'.tr(context, params: {'count': '${d.items.length}'}),
          ),
          onBack: () => context.pop()),

        // ── Branch / Company scope chip ─────────────────────
        Container(
          color: c.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: _BranchScopeChip(),
        ),

        // ── Search + Advanced filter button ────────────────
        Container(
          color: c.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(children: [
            Expanded(
              child: TextField(
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                onChanged: (v) {
                  ref.read(employeesSearchProvider.notifier).state = v;
                },
                decoration: fieldDec(context, 'Search employee'.tr(context)).copyWith(
                  prefixIcon: Icon(Icons.search, color: c.gray400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'More filters'.tr(context),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => showEmployeesAdvancedFilterSheet(context, ref),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasAdvanced
                        ? AppColors.tealLight.withOpacity(0.2)
                        : c.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: hasAdvanced ? AppColors.teal : AppColors.g300),
                  ),
                  child: Icon(Icons.tune_rounded,
                      size: 18,
                      color: hasAdvanced ? AppColors.teal : AppColors.g500),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),

        // ── Active filter chips ─────────────────────────────
        if (hasAdvanced) _ActiveFilterChips(),

        FilterBar(
          tabs: [
            'All'.tr(context),
            'employment_status.core_employee'.tr(context),
            'employment_status.trainee'.tr(context),
            'employment_status.contractor'.tr(context),
            'employment_status.terminated'.tr(context),
          ],
          selected: _tab,
          onSelect: (i) {
            setState(() => _tab = i);
            // Reset legacy attendance filter (it was always a no-op anyway)
            ref.read(employeesStatusProvider.notifier).state = null;
            // Wire the tab to employment_status so the API actually filters.
            ref
                .read(employeesEmploymentStatusFilterProvider.notifier)
                .state = _statusValues[i];
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

// ── Branch / Company scope chip (compact, in-screen) ────────
class _BranchScopeChip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final sel = ref.watch(selectedBranchProvider);
    final companyLabel = sel.companyLabel('All companies'.tr(context));
    final branchLabel = sel.isBranch ? sel.branchLabel('') : '';
    final scopeText =
        branchLabel.isEmpty ? companyLabel : '$companyLabel • $branchLabel';

    return InkWell(
      onTap: () => showBranchSelectorSheet(context, ref),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.navyMid.withOpacity(0.12)),
        ),
        child: Row(children: [
          const Icon(Icons.store_rounded, size: 16, color: AppColors.navyMid),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              scopeText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          ),
          Text('Change'.tr(context),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(width: 4),
          const Icon(Icons.unfold_more_rounded,
              color: AppColors.teal, size: 16),
        ]),
      ),
    );
  }
}

// ── Active advanced-filter chips ────────────────────────────
class _ActiveFilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptId = ref.watch(employeesDepartmentFilterProvider);
    final empStatus = ref.watch(employeesEmploymentStatusFilterProvider);
    final deptsAsync = ref.watch(departmentsProvider);

    String? deptName;
    deptsAsync.whenData((d) {
      if (deptId != null) {
        final found = d.departments.where((x) => x.id == deptId);
        if (found.isNotEmpty) deptName = found.first.name;
      }
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(spacing: 6, runSpacing: 6, children: [
        if (deptId != null)
          _Chip(
            label: 'Department'.tr(context) + ': ${deptName ?? '#$deptId'}',
            onClear: () => ref
                .read(employeesDepartmentFilterProvider.notifier)
                .state = null,
          ),
        if (empStatus != null)
          _Chip(
            label: 'Status'.tr(context) +
                ': ${'employment_status.$empStatus'.tr(context)}',
            onClear: () => ref
                .read(employeesEmploymentStatusFilterProvider.notifier)
                .state = null,
          ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _Chip({required this.label, required this.onClear});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tealLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.teal.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(width: 4),
        InkWell(
          onTap: onClear,
          child: const Icon(Icons.close_rounded,
              size: 13, color: AppColors.teal),
        ),
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
        Expanded(
          child: OutlineBtn(
            text: '🔄 ${'Change Status'.tr(context)}',
            onTap: () =>
                _showChangeStatusSheet(context, ref, employeeId, e.employmentStatus),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: TealBtn(text: '📋 الطلبات', onTap: () => context.push('/requests'))),
      ])),
    ]);
  }

  /// Show a bottom sheet to change the employee's employment status.
  /// Backed by `PATCH /admin/employees/{id}/status`.
  void _showChangeStatusSheet(
    BuildContext context,
    WidgetRef ref,
    int employeeId,
    String currentStatus,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangeStatusSheet(
        employeeId: employeeId,
        currentStatus: currentStatus,
      ),
    );
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

// ── Change Status Sheet ──────────────────────────────────────────
//
// Bottom sheet that lets the admin update an employee's employment_status
// via PATCH /admin/employees/{id}/status. Refreshes the detail provider on
// success so the new status is reflected immediately.
class _ChangeStatusSheet extends ConsumerStatefulWidget {
  final int employeeId;
  final String currentStatus;
  const _ChangeStatusSheet({
    required this.employeeId,
    required this.currentStatus,
  });
  @override
  ConsumerState<_ChangeStatusSheet> createState() =>
      _ChangeStatusSheetState();
}

class _ChangeStatusSheetState extends ConsumerState<_ChangeStatusSheet> {
  late String _selected;
  bool _saving = false;

  static const _options = <String>[
    'core_employee',
    'trainee',
    'contractor',
    'terminated',
    'resigned',
    'suspended',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentStatus;
  }

  Future<void> _save() async {
    if (_selected == widget.currentStatus) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(employeeRepositoryProvider).updateEmployeeStatus(
            widget.employeeId,
            employmentStatus: _selected,
          );
      // Refresh the detail + list
      ref.invalidate(employeeDetailProvider(widget.employeeId));
      ref.invalidate(paginatedEmployeesProvider);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated'.tr(context),
              style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${'Failed'.tr(context)}: $e',
            style: const TextStyle(fontFamily: 'Cairo'),
            maxLines: 3,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.g300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Text(
              'Change Status'.tr(context),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            // Options as RadioListTile-style rows
            ..._options.map((opt) {
              final selected = _selected == opt;
              return InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: _saving ? null : () => setState(() => _selected = opt),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.tealLight.withOpacity(0.15)
                        : c.bg,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: selected ? AppColors.teal : AppColors.g300,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: selected ? AppColors.teal : AppColors.g400,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'employment_status.$opt'.tr(context),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.teal
                              : c.textPrimary,
                        ),
                      ),
                    ),
                    if (opt == widget.currentStatus)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Current'.tr(context),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            color: AppColors.goldLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlineBtn(
                  text: 'Cancel'.tr(context),
                  onTap: _saving ? null : () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TealBtn(
                  text: _saving
                      ? '${'Saving'.tr(context)}...'
                      : 'Save'.tr(context),
                  onTap: _saving ? null : _save,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
