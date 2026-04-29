import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/models/ticket_sales_models.dart';

class TicketSalesFilters {
  final String? month;
  final String? dateFrom;
  final String? dateTo;
  final String? status;
  final String? carrierCode;
  final String? search;

  const TicketSalesFilters({
    this.month,
    this.dateFrom,
    this.dateTo,
    this.status,
    this.carrierCode,
    this.search,
  });

  TicketSalesFilters copyWith({
    Object? month = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    Object? status = _sentinel,
    Object? carrierCode = _sentinel,
    Object? search = _sentinel,
  }) {
    return TicketSalesFilters(
      month: identical(month, _sentinel) ? this.month : month as String?,
      dateFrom:
          identical(dateFrom, _sentinel) ? this.dateFrom : dateFrom as String?,
      dateTo: identical(dateTo, _sentinel) ? this.dateTo : dateTo as String?,
      status: identical(status, _sentinel) ? this.status : status as String?,
      carrierCode: identical(carrierCode, _sentinel)
          ? this.carrierCode
          : carrierCode as String?,
      search: identical(search, _sentinel) ? this.search : search as String?,
    );
  }

  static const _sentinel = Object();
}

String _yyyyMm(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}';

final ticketSalesFiltersProvider = StateProvider<TicketSalesFilters>(
  (_) => TicketSalesFilters(month: _yyyyMm(DateTime.now())),
);

final ticketSalesListProvider =
    FutureProvider.autoDispose<TicketSalesListData>((ref) async {
  final f = ref.watch(ticketSalesFiltersProvider);
  final sel = ref.watch(selectedBranchProvider);
  final response =
      await ref.watch(ticketSalesRepositoryProvider).getTicketSales(
            companyId: sel.companyId,
            branchId: sel.branchId,
            month: f.month,
            dateFrom: f.dateFrom,
            dateTo: f.dateTo,
            status: f.status,
            carrierCode: f.carrierCode,
            search: (f.search?.isEmpty ?? true) ? null : f.search,
            perPage: 50,
          );
  return response.data!;
});

final ticketSalesKpisProvider =
    FutureProvider.autoDispose<TicketSalesKpis>((ref) async {
  final f = ref.watch(ticketSalesFiltersProvider);
  final sel = ref.watch(selectedBranchProvider);
  final response =
      await ref.watch(ticketSalesRepositoryProvider).getTicketSalesKpis(
            companyId: sel.companyId,
            branchId: sel.branchId,
            month: f.month,
            dateFrom: f.dateFrom,
            dateTo: f.dateTo,
            status: f.status,
          );
  return response.data!;
});
