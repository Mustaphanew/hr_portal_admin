import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/payroll_models.dart';
import '../providers/payroll_providers.dart';
import '../widgets/payroll_branch_chip.dart';
import '../widgets/payroll_filters_bar.dart';
import '../widgets/payroll_line_form_sheet.dart';

class AllowancesScreen extends ConsumerWidget {
  const AllowancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final filters = ref.watch(allowancesFiltersProvider);
    final async = ref.watch(adminAllowancesProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          AdminAppBar(
            title: 'Allowances'.tr(context),
            subtitle: 'Manage employee allowances'.tr(context),
            onBack: () => context.pop(),
          ),
          const PayrollBranchChip(),
          // Summary KPIs (count + total)
          async.maybeWhen(
            data: (d) => d.summary != null
                ? PayrollLinesSummaryStrip(
                    summary: d.summary!,
                    kind: PayrollLineKind.allowance,
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
                .read(allowancesFiltersProvider.notifier)
                .update((s) => s.copyWith(month: v)),
            onSearchChanged: (v) => ref
                .read(allowancesFiltersProvider.notifier)
                .update((s) => s.copyWith(search: v)),
            onAmountChanged: (mn, mx) => ref
                .read(allowancesFiltersProvider.notifier)
                .update((s) => s.copyWith(amountMin: mn, amountMax: mx)),
            onClearAll: () => ref
                .read(allowancesFiltersProvider.notifier)
                .state = const PayrollFilters(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(adminAllowancesProvider.future),
              child: AsyncValueWidget<PayrollLineItemsData>(
                value: async,
                onRetry: () => ref.invalidate(adminAllowancesProvider),
                data: (d) => _buildList(context, ref, d.items),
              ),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            showPayrollLineFormSheet(context, ref, kind: PayrollLineKind.allowance),
        backgroundColor: AppColors.success,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add allowance'.tr(context),
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
            icon: '💰',
            title: 'No allowances found'.tr(context),
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
        kind: PayrollLineKind.allowance,
        onEdit: () => showPayrollLineFormSheet(
          context, ref,
          kind: PayrollLineKind.allowance,
          existing: items[i],
        ),
        onDelete: () =>
            _confirmDelete(context, ref, items[i], PayrollLineKind.allowance),
      ),
    );
  }
}

/// Shared confirm-and-delete helper for both allowances and deductions.
Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PayrollLineItem item,
  PayrollLineKind kind,
) async {
  final isAllow = kind == PayrollLineKind.allowance;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        isAllow ? 'Delete allowance?'.tr(context) : 'Delete deduction?'.tr(context),
        style: const TextStyle(fontFamily: 'Cairo'),
      ),
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
    if (isAllow) {
      await ref.read(payrollRepositoryProvider).deleteAllowance(item.id);
      ref.invalidate(adminAllowancesProvider);
    } else {
      await ref.read(payrollRepositoryProvider).deleteDeduction(item.id);
      ref.invalidate(adminDeductionsProvider);
    }
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

enum PayrollLineKind { allowance, deduction }

// ═══════════════════════════════════════════════════════════════════════════
// Reusable card for allowance/deduction line items
// ═══════════════════════════════════════════════════════════════════════════

class PayrollLineCard extends StatelessWidget {
  final PayrollLineItem item;
  final PayrollLineKind kind;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const PayrollLineCard({
    super.key,
    required this.item,
    required this.kind,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isAllowance = kind == PayrollLineKind.allowance;
    final accent = isAllowance ? AppColors.success : AppColors.error;

    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border(
            right: BorderSide(color: accent.withOpacity(0.6), width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(children: [
              AdminAvatar(
                  initials: (item.employee?.name ?? '·').characters.first,
                  size: 38,
                  fontSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.employee?.name ?? '-',
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800)),
                    Text(
                      [
                        item.inputType?.name ?? '-',
                        if (item.periodStart != null) '· ${item.periodStart}',
                      ].join(' '),
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.5,
                          color: c.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.amount.toStringAsFixed(2),
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: accent)),
                  Text(
                      '${item.quantity.toStringAsFixed(0)} × ${item.rate.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5,
                          color: c.textMuted)),
                ],
              ),
            ]),
            if (item.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: c.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(item.notes!,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        color: c.textSecondary)),
              ),
            ],
          ],
        ),
      ),
    );

    // Wrap in Slidable when edit/delete actions are provided.
    if (onEdit == null && onDelete == null) return card;
    return Slidable(
      key: ValueKey('payroll-line-${item.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Edit'.tr(context),
              borderRadius: BorderRadius.circular(12),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete'.tr(context),
              borderRadius: BorderRadius.circular(12),
            ),
        ],
      ),
      child: GestureDetector(onLongPress: onEdit, child: card),
    );
  }
}
