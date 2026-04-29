import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/ticket_sales_models.dart';
import '../providers/ticket_sales_providers.dart';

class TicketSalesScreen extends ConsumerWidget {
  const TicketSalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final filters = ref.watch(ticketSalesFiltersProvider);
    final kpis = ref.watch(ticketSalesKpisProvider);
    final list = ref.watch(ticketSalesListProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          AdminAppBar(
            title: 'Ticket Sales'.tr(context),
            subtitle: 'Sales reports & KPIs'.tr(context),
            onBack: () => context.pop(),
          ),
          _TicketSalesFilters(filters: filters),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  ref.refresh(ticketSalesKpisProvider.future),
                  ref.refresh(ticketSalesListProvider.future),
                ]);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                children: [
                  AsyncValueWidget<TicketSalesKpis>(
                    value: kpis,
                    onRetry: () => ref.invalidate(ticketSalesKpisProvider),
                    data: (k) => _KpiSection(kpis: k),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Sales records'.tr(context),
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 8),
                  AsyncValueWidget<TicketSalesListData>(
                    value: list,
                    onRetry: () => ref.invalidate(ticketSalesListProvider),
                    data: (d) => d.tickets.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: EmptyState(
                              icon: '🎫',
                              title: 'No tickets found'.tr(context),
                              subtitle: 'Try changing the filters'.tr(context),
                            ),
                          )
                        : Column(
                            children: d.tickets
                                .map((t) => TicketSaleCard(item: t))
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TicketSalesFilters extends ConsumerWidget {
  final TicketSalesFilters filters;
  const _TicketSalesFilters({required this.filters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;

    void update(TicketSalesFilters Function(TicketSalesFilters) up) {
      ref.read(ticketSalesFiltersProvider.notifier).update(up);
    }

    return Container(
      color: c.bgCard,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: filters.search ?? '')
                ..selection = TextSelection.collapsed(
                    offset: (filters.search ?? '').length),
              onSubmitted: (v) => update((s) => s.copyWith(search: v)),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search ticket / PNR / passenger'.tr(context),
                hintStyle: TextStyle(
                    fontFamily: 'Cairo', fontSize: 12, color: c.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: AppColors.g500),
                filled: true,
                fillColor: c.bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _Pill(
                icon: Icons.event_rounded,
                label: filters.month ?? 'All months'.tr(context),
                onTap: () async {
                  final y = filters.month?.substring(0, 4);
                  final m = filters.month?.substring(5, 7);
                  final initial = (y != null && m != null)
                      ? DateTime(int.parse(y), int.parse(m))
                      : DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDatePickerMode: DatePickerMode.year,
                  );
                  if (picked != null) {
                    final s =
                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
                    update((f) => f.copyWith(month: s));
                  }
                },
              ),
              const SizedBox(width: 6),
              _MenuPill<String?>(
                icon: Icons.flag_rounded,
                label: filters.status ?? 'Status'.tr(context),
                value: filters.status,
                items: [
                  (value: null, label: 'All'.tr(context)),
                  (value: 'issued', label: 'Issued'.tr(context)),
                  (value: 'cancelled', label: 'Cancelled'.tr(context)),
                  (value: 'refunded', label: 'Refunded'.tr(context)),
                  (value: 'exchanged', label: 'Exchanged'.tr(context)),
                ],
                onChanged: (v) => update((s) => s.copyWith(status: v)),
              ),
              const SizedBox(width: 6),
              _Pill(
                icon: Icons.flight_rounded,
                label: filters.carrierCode ?? 'Carrier'.tr(context),
                onTap: () async {
                  final code = await _askText(context,
                      title: 'Carrier code'.tr(context),
                      initial: filters.carrierCode);
                  update((s) => s.copyWith(carrierCode: code));
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Future<String?> _askText(BuildContext context,
      {required String title, String? initial}) async {
    final ctrl = TextEditingController(text: initial ?? '');
    return showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title,
            style:
                const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            isDense: true,
            hintText: 'e.g. SV, MS, GF'.tr(context),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Clear'.tr(context),
                  style: const TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, ctrl.text.trim().isEmpty ? null : ctrl.text.trim()),
              child: Text('Apply'.tr(context),
                  style: const TextStyle(fontFamily: 'Cairo'))),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Pill(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.navySoft,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: AppColors.navyMid),
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
        ]),
      ),
    );
  }
}

class _MenuPill<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T value;
  final List<({T value, String label})> items;
  final ValueChanged<T> onChanged;
  const _MenuPill(
      {required this.icon,
      required this.label,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onChanged,
      itemBuilder: (_) => items
          .map((e) => PopupMenuItem<T>(value: e.value, child: Text(e.label)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.tealSoft,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: AppColors.teal),
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
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// KPI section
// ═══════════════════════════════════════════════════════════════════════════

class _KpiSection extends StatelessWidget {
  final TicketSalesKpis kpis;
  const _KpiSection({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final currency = kpis.currency ?? '';
    String fmt(double v) =>
        '${v.toStringAsFixed(0)}${currency.isEmpty ? '' : ' $currency'}';
    return Column(children: [
      Row(children: [
        Expanded(
            child: _KpiTile(
                icon: Icons.confirmation_number_rounded,
                label: 'Total tickets'.tr(context),
                value: '${kpis.totalTickets}',
                color: AppColors.navyMid)),
        const SizedBox(width: 8),
        Expanded(
            child: _KpiTile(
                icon: Icons.payments_rounded,
                label: 'Total sales'.tr(context),
                value: fmt(kpis.totalSales),
                color: AppColors.success)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
            child: _KpiTile(
                icon: Icons.flight_takeoff_rounded,
                label: 'Issued'.tr(context),
                value: '${kpis.issued}',
                color: AppColors.teal)),
        const SizedBox(width: 8),
        Expanded(
            child: _KpiTile(
                icon: Icons.cancel_rounded,
                label: 'Cancelled'.tr(context),
                value: '${kpis.cancelled ?? 0}',
                color: AppColors.error)),
        const SizedBox(width: 8),
        Expanded(
            child: _KpiTile(
                icon: Icons.swap_horiz_rounded,
                label: 'Refunded'.tr(context),
                value: '${kpis.refunded ?? 0}',
                color: AppColors.warning)),
      ]),
      if (kpis.totalCommission != null) ...[
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _KpiTile(
                  icon: Icons.percent_rounded,
                  label: 'Commission'.tr(context),
                  value: fmt(kpis.totalCommission!),
                  color: AppColors.gold)),
          const SizedBox(width: 8),
          Expanded(
              child: _KpiTile(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Net'.tr(context),
                  value: fmt(kpis.totalNet ?? 0),
                  color: AppColors.navyDeep)),
        ]),
      ],
    ]);
  }
}

class _KpiTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _KpiTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5,
                color: c.textMuted,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sale card
// ═══════════════════════════════════════════════════════════════════════════

class TicketSaleCard extends StatelessWidget {
  final TicketSaleRecord item;
  const TicketSaleCard({super.key, required this.item});

  Color _statusColor() {
    switch (item.status) {
      case 'cancelled':
        return AppColors.error;
      case 'refunded':
        return AppColors.warning;
      case 'exchanged':
        return AppColors.navyMid;
      default:
        return AppColors.success;
    }
  }

  String _statusLabel(BuildContext context) {
    switch (item.status) {
      case 'cancelled':
        return 'Cancelled'.tr(context);
      case 'refunded':
        return 'Refunded'.tr(context);
      case 'exchanged':
        return 'Exchanged'.tr(context);
      default:
        return 'Issued'.tr(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final amount = item.totalAmount ?? item.fareAmount ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tealLight, AppColors.teal],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flight_takeoff_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(
                          item.passengerName ?? '-',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.carrierCode != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.navySoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.carrierCode!,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navyMid)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (item.ticketNumber != null) '#${item.ticketNumber}',
                        if (item.pnr != null) '· PNR: ${item.pnr}',
                      ].join(' '),
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: c.textMuted),
                    ),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${amount.toStringAsFixed(0)} ${item.currency ?? ''}',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _statusColor())),
              const SizedBox(height: 4),
              StatusBadge(
                text: _statusLabel(context),
                type: item.status == 'cancelled'
                    ? 'rejected'
                    : item.status == 'issued'
                        ? 'approved'
                        : 'pending',
                dot: true,
              ),
            ]),
          ]),
          if ((item.routeFrom?.isNotEmpty ?? false) ||
              (item.routeTo?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Text(item.routeFrom ?? '-',
                    style: const TextStyle(
                        fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 14, color: AppColors.g500),
                ),
                Text(item.routeTo ?? '-',
                    style: const TextStyle(
                        fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                const Spacer(),
                if (item.travelDate?.isNotEmpty ?? false) ...[
                  const Icon(Icons.event_rounded,
                      size: 14, color: AppColors.g500),
                  const SizedBox(width: 4),
                  Text(item.travelDate!,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: c.textMuted)),
                ]
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
