import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/payroll_models.dart';
import '../providers/payroll_providers.dart';
import '../widgets/payroll_filters_bar.dart';

class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final filters = ref.watch(payrollFiltersProvider);
    final async = ref.watch(adminPayrollProvider);

    final statusOptions = <({String value, String label})>[
      (value: 'draft', label: 'Draft'.tr(context)),
      (value: 'approved', label: 'Approved'.tr(context)),
      (value: 'paid', label: 'Paid'.tr(context)),
      (value: 'cancelled', label: 'Cancelled'.tr(context)),
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

  Color _statusColor() {
    switch (item.status) {
      case 'paid':
        return AppColors.success;
      case 'approved':
        return AppColors.teal;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(BuildContext context) {
    switch (item.status) {
      case 'paid':
        return 'Paid'.tr(context);
      case 'approved':
        return 'Approved'.tr(context);
      case 'cancelled':
        return 'Cancelled'.tr(context);
      case 'draft':
        return 'Draft'.tr(context);
      default:
        return item.status;
    }
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
                  : item.status == 'cancelled'
                      ? 'rejected'
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
                _row(context, 'Period'.tr(context),
                    item.month ?? item.periodStart ?? '-'),
                _row(context, 'Basic salary'.tr(context),
                    item.basicSalary.toStringAsFixed(2)),
                _row(context, 'Allowances'.tr(context),
                    '+ ${item.totalAllowances.toStringAsFixed(2)}',
                    valueColor: AppColors.success),
                _row(context, 'Deductions'.tr(context),
                    '− ${item.totalDeductions.toStringAsFixed(2)}',
                    valueColor: AppColors.error),
                const Divider(height: 16),
                _row(context, 'Net salary'.tr(context),
                    item.netSalary.toStringAsFixed(2),
                    valueColor: _statusColor(), bold: true),
              ],
            ),
          ),
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
