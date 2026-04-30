import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../admin_dashboard/presentation/screens/admin_dashboard_screen.dart'
    show showBranchSelectorSheet;
import '../../data/models/payroll_models.dart';
import '../providers/payroll_providers.dart';
import '../widgets/payroll_branch_chip.dart';
import '../widgets/payroll_filters_bar.dart';

class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final filters = ref.watch(payrollFiltersProvider);
    final async = ref.watch(adminPayrollProvider);

    // Real values from `payroll_run_items.status` enum:
    // included | excluded | accrued | paid
    final statusOptions = <({String value, String label})>[
      (value: 'included', label: 'payroll_status.included'.tr(context)),
      (value: 'excluded', label: 'payroll_status.excluded'.tr(context)),
      (value: 'accrued', label: 'payroll_status.accrued'.tr(context)),
      (value: 'paid', label: 'payroll_status.paid'.tr(context)),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          AdminAppBar(
            title: 'Payroll'.tr(context),
            subtitle: 'Monthly salary records'.tr(context),
            onBack: () => context.pop(),
          ),
          // Branch / Company scope chip
          const PayrollBranchChip(),
          // Summary KPIs (count, gross, net, paid)
          async.maybeWhen(
            data: (d) => d.summary != null
                ? PayrollSummaryStrip(summary: d.summary!)
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          PayrollFiltersBar(
            month: filters.month,
            search: filters.search,
            amountMin: filters.amountMin,
            amountMax: filters.amountMax,
            status: filters.status,
            statusOptions: statusOptions,
            onMonthChanged: (v) => ref
                .read(payrollFiltersProvider.notifier)
                .update((s) => s.copyWith(month: v)),
            onSearchChanged: (v) => ref
                .read(payrollFiltersProvider.notifier)
                .update((s) => s.copyWith(search: v)),
            onAmountChanged: (mn, mx) => ref
                .read(payrollFiltersProvider.notifier)
                .update((s) => s.copyWith(amountMin: mn, amountMax: mx)),
            onStatusChanged: (v) => ref
                .read(payrollFiltersProvider.notifier)
                .update((s) => s.copyWith(status: v)),
            onClearAll: () => ref
                .read(payrollFiltersProvider.notifier)
                .state = const PayrollFilters(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(adminPayrollProvider.future),
              child: AsyncValueWidget<PayrollListData>(
                value: async,
                onRetry: () => ref.invalidate(adminPayrollProvider),
                data: (d) => _buildList(context, d.items),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<PayrollItem> items) {
    if (items.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: EmptyState(
            icon: '💼',
            title: 'No payroll records'.tr(context),
            subtitle: 'Try changing the filters'.tr(context),
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: items.length,
      itemBuilder: (_, i) => PayrollItemCard(item: items[i]),
    );
  }
}

class PayrollItemCard extends StatelessWidget {
  final PayrollItem item;
  const PayrollItemCard({super.key, required this.item});

  /// Color matches the real payroll_run_items.status enum:
  /// included → orange (default state)
  /// excluded → grey/error
  /// accrued  → teal (calculated)
  /// paid     → green
  Color _statusColor() {
    switch (item.status) {
      case 'paid':
        return AppColors.success;
      case 'accrued':
        return AppColors.teal;
      case 'excluded':
        return AppColors.error;
      case 'included':
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(BuildContext context) {
    final key = 'payroll_status.${item.status}';
    final translated = key.tr(context);
    return translated == key ? item.status : translated;
  }

  /// Display "2026-04-01 → 2026-04-30" if both dates exist; otherwise fall
  /// back to whichever single date is available.
  String _periodLabel() {
    final start = item.periodStart;
    final end = item.periodEnd;
    if (start != null && end != null) return '$start → $end';
    if (start != null) return start;
    if (end != null) return end;
    if (item.month != null) return item.month!;
    return '-';
  }

  /// Format an amount with thousand separators.
  String _money(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final dec = parts.length > 1 ? parts[1] : '00';
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '$buffer.$dec';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            AdminAvatar(
                initials: (item.employee?.name ?? '·').characters.first,
                size: 42,
                fontSize: 15),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.employee?.name ?? '-',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                  Text(
                    [
                      item.employee?.jobTitle,
                      item.employee?.departmentName,
                    ].where((e) => e?.isNotEmpty ?? false).join(' · '),
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        color: c.textMuted),
                  ),
                ],
              ),
            ),
            StatusBadge(
              text: _statusLabel(context),
              type: item.status == 'paid'
                  ? 'approved'
                  : item.status == 'excluded'
                      ? 'rejected'
                      : item.status == 'accrued'
                          ? 'leave'
                          : 'pending',
              dot: true,
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _row(context, 'Period'.tr(context), _periodLabel()),
                if (item.payDate != null)
                  _row(context, 'Pay date'.tr(context), item.payDate!),
                _row(context, 'Basic salary'.tr(context),
                    _money(item.basicSalary)),
                if (item.totalAllowances > 0)
                  _row(context, 'Allowances'.tr(context),
                      '+ ${_money(item.totalAllowances)}',
                      valueColor: AppColors.success),
                if (item.totalDeductions > 0)
                  _row(context, 'Deductions'.tr(context),
                      '− ${_money(item.totalDeductions)}',
                      valueColor: AppColors.error),
                const Divider(height: 16),
                _row(context, 'Net salary'.tr(context),
                    _money(item.totalNet),
                    valueColor: _statusColor(), bold: true),
                if (item.paidAmount > 0)
                  _row(context, 'Paid amount'.tr(context),
                      _money(item.paidAmount),
                      valueColor: AppColors.success),
              ],
            ),
          ),
          if (item.runNo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.receipt_long_rounded, size: 13, color: c.textMuted),
                const SizedBox(width: 4),
                Text(item.runNo!,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: c.textMuted,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          if (item.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            Text(item.notes!,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    color: c.textSecondary)),
          ],
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {Color? valueColor, bool bold = false}) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: c.textMuted)),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: bold ? 14 : 12.5,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                  color: valueColor ?? c.textPrimary)),
        ],
      ),
    );
  }
}
