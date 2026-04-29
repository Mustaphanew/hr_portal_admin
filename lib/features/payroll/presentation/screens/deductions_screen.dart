import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/payroll_models.dart';
import '../providers/payroll_providers.dart';
import '../widgets/payroll_branch_chip.dart';
import '../widgets/payroll_filters_bar.dart';
import '../widgets/payroll_line_form_sheet.dart';
import 'allowances_screen.dart' show PayrollLineCard, PayrollLineKind;

class DeductionsScreen extends ConsumerWidget {
  const DeductionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final filters = ref.watch(deductionsFiltersProvider);
    final async = ref.watch(adminDeductionsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          AdminAppBar(
            title: 'Deductions'.tr(context),
            subtitle: 'Manage employee deductions'.tr(context),
            onBack: () => context.pop(),
          ),
          const PayrollBranchChip(),
          // Summary strip (count + total)
          async.maybeWhen(
            data: (d) => d.summary != null
                ? PayrollLinesSummaryStrip(
                    summary: d.summary!,
                    kind: PayrollLineKind.deduction,
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          PayrollFiltersBar(
            month: filters.month,
            search: filters.search,
            amountMin: filters.amountMin,
            amountMax: filters.amountMax,
            onMonthChanged: (v) => ref
                .read(deductionsFiltersProvider.notifier)
                .update((s) => s.copyWith(month: v)),
            onSearchChanged: (v) => ref
                .read(deductionsFiltersProvider.notifier)
                .update((s) => s.copyWith(search: v)),
            onAmountChanged: (mn, mx) => ref
                .read(deductionsFiltersProvider.notifier)
                .update((s) => s.copyWith(amountMin: mn, amountMax: mx)),
            onClearAll: () => ref
                .read(deductionsFiltersProvider.notifier)
                .state = const PayrollFilters(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(adminDeductionsProvider.future),
              child: AsyncValueWidget<PayrollLineItemsData>(
                value: async,
                onRetry: () => ref.invalidate(adminDeductionsProvider),
                data: (d) => _buildList(context, ref, d.items),
              ),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPayrollLineFormSheet(
          context, ref,
          kind: PayrollLineKind.deduction,
        ),
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add deduction'.tr(context),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, WidgetRef ref, List<PayrollLineItem> items) {
    if (items.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: EmptyState(
            icon: '📉',
            title: 'No deductions found'.tr(context),
            subtitle: 'Try changing the filters'.tr(context),
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 84),
      itemCount: items.length,
      itemBuilder: (_, i) => PayrollLineCard(
        item: items[i],
        kind: PayrollLineKind.deduction,
        onEdit: () => showPayrollLineFormSheet(
          context, ref,
          kind: PayrollLineKind.deduction,
          existing: items[i],
        ),
        onDelete: () => _confirmDeleteDeduction(context, ref, items[i]),
      ),
    );
  }
}

Future<void> _confirmDeleteDeduction(
  BuildContext context,
  WidgetRef ref,
  PayrollLineItem item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Delete deduction?'.tr(context),
          style: const TextStyle(fontFamily: 'Cairo')),
      content: Text(
        '${item.employee?.name ?? ''} — ${item.inputType?.name ?? ''} — ${item.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'.tr(context),
              style: const TextStyle(fontFamily: 'Cairo')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Delete'.tr(context),
              style: const TextStyle(
                  fontFamily: 'Cairo', color: AppColors.error)),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(payrollRepositoryProvider).deleteDeduction(item.id);
    ref.invalidate(adminDeductionsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted'.tr(context),
            style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'Failed'.tr(context)}: $e',
            style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
