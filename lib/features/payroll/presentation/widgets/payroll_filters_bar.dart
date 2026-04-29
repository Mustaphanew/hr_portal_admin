import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';

/// Compact filter bar with: month chip, search field, amount range, and an
/// "advanced" sheet for additional filters (status, employee, etc.).
class PayrollFiltersBar extends StatelessWidget {
  final String? month; // yyyy-MM
  final String? search;
  final double? amountMin;
  final double? amountMax;
  final String? status;

  /// Available status options. If empty, the status pill is hidden.
  final List<({String value, String label})> statusOptions;

  final ValueChanged<String?> onMonthChanged;
  final ValueChanged<String?> onSearchChanged;
  final void Function(double? min, double? max) onAmountChanged;
  final ValueChanged<String?>? onStatusChanged;
  final VoidCallback? onClearAll;

  const PayrollFiltersBar({
    super.key,
    required this.month,
    required this.search,
    required this.amountMin,
    required this.amountMax,
    this.status,
    this.statusOptions = const [],
    required this.onMonthChanged,
    required this.onSearchChanged,
    required this.onAmountChanged,
    this.onStatusChanged,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final hasAmount = amountMin != null || amountMax != null;
    final hasStatus = (status?.isNotEmpty ?? false);

    return Container(
      color: c.bgCard,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        children: [
          // ── Search row ───────────────────────────────────────
          Row(children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: search ?? '')
                  ..selection = TextSelection.collapsed(offset: (search ?? '').length),
                onSubmitted: onSearchChanged,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search'.tr(context),
                  hintStyle: TextStyle(
                      fontFamily: 'Cairo', fontSize: 12, color: c.textMuted),
                  prefixIcon:
                      const Icon(Icons.search_rounded, size: 18, color: AppColors.g500),
                  suffixIcon: (search?.isNotEmpty ?? false)
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: () => onSearchChanged(null),
                          splashRadius: 18,
                        )
                      : null,
                  filled: true,
                  fillColor: c.bg,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _IconChip(
              icon: Icons.tune_rounded,
              tooltip: 'More filters'.tr(context),
              onTap: () => _openAdvancedSheet(context),
              active: hasAmount,
            ),
          ]),
          const SizedBox(height: 8),
          // ── Active filter chips ──────────────────────────────
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _MonthChip(
                  month: month,
                  onChanged: onMonthChanged,
                ),
                if (statusOptions.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _StatusChip(
                    selected: status,
                    options: statusOptions,
                    onChanged: onStatusChanged,
                  ),
                ],
                if (hasAmount) ...[
                  const SizedBox(width: 6),
                  _ChipPill(
                    icon: Icons.payments_rounded,
                    label: _amountLabel(amountMin, amountMax),
                    onClear: () => onAmountChanged(null, null),
                  ),
                ],
                if (hasStatus && statusOptions.isEmpty) ...[
                  const SizedBox(width: 6),
                  _ChipPill(
                    icon: Icons.flag_rounded,
                    label: status!,
                    onClear: () => onStatusChanged?.call(null),
                  ),
                ],
                const SizedBox(width: 6),
                if (_anyActive())
                  GestureDetector(
                    onTap: onClearAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.clear_all_rounded,
                              size: 14, color: AppColors.errorDark),
                          const SizedBox(width: 4),
                          Text('Clear all'.tr(context),
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.errorDark)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _anyActive() {
    return (search?.isNotEmpty ?? false) ||
        (amountMin != null || amountMax != null) ||
        (status?.isNotEmpty ?? false);
  }

  String _amountLabel(double? min, double? max) {
    if (min != null && max != null) return '$min — $max';
    if (min != null) return '≥ $min';
    if (max != null) return '≤ $max';
    return '';
  }

  Future<void> _openAdvancedSheet(BuildContext context) async {
    final minCtrl = TextEditingController(
        text: amountMin == null ? '' : amountMin!.toStringAsFixed(0));
    final maxCtrl = TextEditingController(
        text: amountMax == null ? '' : amountMax!.toStringAsFixed(0));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.g300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Text('Amount range'.tr(sheetCtx),
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Min'.tr(sheetCtx),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Max'.tr(sheetCtx),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlineBtn(
                      text: 'Reset'.tr(sheetCtx),
                      onTap: () {
                        onAmountChanged(null, null);
                        Navigator.pop(sheetCtx);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TealBtn(
                      text: 'Apply'.tr(sheetCtx),
                      onTap: () {
                        final mn = double.tryParse(minCtrl.text.trim());
                        final mx = double.tryParse(maxCtrl.text.trim());
                        onAmountChanged(mn, mx);
                        Navigator.pop(sheetCtx);
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;
  const _IconChip({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: active ? AppColors.tealLight.withOpacity(0.2) : c.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppColors.teal : AppColors.g300,
            ),
          ),
          child: Icon(icon,
              size: 18, color: active ? AppColors.teal : AppColors.g500),
        ),
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  final String? month; // yyyy-MM
  final ValueChanged<String?> onChanged;
  const _MonthChip({required this.month, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label = month ?? 'All months'.tr(context);
    return GestureDetector(
      onTap: () => _pickMonth(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.navySoft,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_rounded,
                size: 14, color: AppColors.navyMid),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyMid)),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded,
                size: 14, color: AppColors.navyMid),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    DateTime initial;
    if (month != null && month!.length >= 7) {
      final y = int.tryParse(month!.substring(0, 4)) ?? DateTime.now().year;
      final m = int.tryParse(month!.substring(5, 7)) ?? DateTime.now().month;
      initial = DateTime(y, m);
    } else {
      initial = DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select month'.tr(context),
    );
    if (picked != null) {
      final s = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      onChanged(s);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String? selected;
  final List<({String value, String label})> options;
  final ValueChanged<String?>? onChanged;
  const _StatusChip(
      {required this.selected, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label = selected == null
        ? 'Status'.tr(context)
        : (options.firstWhere(
              (o) => o.value == selected,
              orElse: () => (value: selected!, label: selected!),
            ).label);
    return PopupMenuButton<String?>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text('All'.tr(context))),
        ...options.map((o) => PopupMenuItem(value: o.value, child: Text(o.label))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.tealLight.withOpacity(0.2),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_rounded, size: 14, color: AppColors.teal),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal)),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded,
                size: 14, color: AppColors.teal),
          ],
        ),
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onClear;
  const _ChipPill(
      {required this.icon, required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 12, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onClear,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.goldDark,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.close_rounded, size: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 14, color: AppColors.goldDark),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldDark)),
        ],
      ),
    );
  }
}
