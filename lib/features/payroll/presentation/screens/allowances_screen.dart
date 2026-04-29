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
            icon: '💰',
            title: 'No allowances found'.tr(context),
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
        kind: PayrollLineKind.allowance,
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
  const PayrollLineCard({
    super.key,
    required this.item,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isAllowance = kind == PayrollLineKind.allowance;
    final accent = isAllowance ? AppColors.success : AppColors.error;
    return Container(
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
                        if (item.month != null) '· ${item.month}',
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
  }
}
