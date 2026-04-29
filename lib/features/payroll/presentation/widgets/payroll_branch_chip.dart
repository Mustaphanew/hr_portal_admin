import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../admin_dashboard/presentation/screens/admin_dashboard_screen.dart'
    show showBranchSelectorSheet;
import '../../data/models/payroll_models.dart';

/// Compact branch / company scope chip used at the top of the payroll,
/// allowances and deductions screens. Tapping opens the shared selector
/// bottom sheet — see [showBranchSelectorSheet].
class PayrollBranchChip extends ConsumerWidget {
  const PayrollBranchChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final sel = ref.watch(selectedBranchProvider);
    final companyLabel = sel.companyLabel('All companies'.tr(context));
    final branchLabel = sel.isBranch ? sel.branchLabel('') : '';
    final scopeText =
        branchLabel.isEmpty ? companyLabel : '$companyLabel • $branchLabel';

    return Container(
      color: c.bgCard,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
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
      ),
    );
  }
}

/// Horizontal strip showing the four payroll KPIs (count, gross, net, paid).
class PayrollSummaryStrip extends StatelessWidget {
  final PayrollSummary summary;
  const PayrollSummaryStrip({super.key, required this.summary});

  String _fmt(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      color: c.bgCard,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(children: [
        _kpi(context, '${summary.count}', 'Total'.tr(context),
            AppColors.navyMid),
        const SizedBox(width: 8),
        _kpi(context, _fmt(summary.totalGross), 'Gross'.tr(context),
            AppColors.success),
        const SizedBox(width: 8),
        _kpi(context, _fmt(summary.totalNet), 'Net'.tr(context),
            AppColors.teal),
        const SizedBox(width: 8),
        _kpi(context, _fmt(summary.totalPaid), 'Paid'.tr(context),
            AppColors.gold),
      ]),
    );
  }

  Widget _kpi(BuildContext context, String v, String label, Color color) {
    final c = context.appColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text(v,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.1)),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 9,
                  color: c.textMuted,
                  height: 1.2),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
