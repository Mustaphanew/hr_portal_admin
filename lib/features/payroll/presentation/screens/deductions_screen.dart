import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/payroll_models.dart';
import '../providers/payroll_providers.dart';
import '../widgets/payroll_filters_bar.dart';
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
            subtitle: 'View employee deductions'.tr(context),
            onBack: () => context.pop(),
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
                data: (d) => _buildList(context, d.items),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<PayrollLineItem> items) {
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: items.length,
      itemBuilder: (_, i) => PayrollLineCard(
        item: items[i],
        kind: PayrollLineKind.deduction,
      ),
    );
  }
}
