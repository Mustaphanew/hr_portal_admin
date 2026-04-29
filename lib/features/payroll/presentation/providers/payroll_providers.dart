import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/models/payroll_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Holds all payroll/allowance/deduction list filters in one immutable value.
class PayrollFilters {
  final int? employeeId;
  final int? inputTypeId;
  final String? month; // yyyy-MM
  final String? status;
  final double? amountMin;
  final double? amountMax;
  final String? search;

  const PayrollFilters({
    this.employeeId,
    this.inputTypeId,
    this.month,
    this.status,
    this.amountMin,
    this.amountMax,
    this.search,
  });

  PayrollFilters copyWith({
    Object? employeeId = _sentinel,
    Object? inputTypeId = _sentinel,
    Object? month = _sentinel,
    Object? status = _sentinel,
    Object? amountMin = _sentinel,
    Object? amountMax = _sentinel,
    Object? search = _sentinel,
  }) {
    return PayrollFilters(
      employeeId: identical(employeeId, _sentinel)
          ? this.employeeId
          : employeeId as int?,
      inputTypeId: identical(inputTypeId, _sentinel)
          ? this.inputTypeId
          : inputTypeId as int?,
      month: identical(month, _sentinel) ? this.month : month as String?,
      status: identical(status, _sentinel) ? this.status : status as String?,
      amountMin: identical(amountMin, _sentinel)
          ? this.amountMin
          : amountMin as double?,
      amountMax: identical(amountMax, _sentinel)
          ? this.amountMax
          : amountMax as double?,
      search: identical(search, _sentinel) ? this.search : search as String?,
    );
  }

  static const _sentinel = Object();
}

String _yyyyMm(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}';

PayrollFilters _defaultFilters() => PayrollFilters(month: _yyyyMm(DateTime.now()));

// ═══════════════════════════════════════════════════════════════════════════
// Filter providers (one set per module so screens don't collide)
// ═══════════════════════════════════════════════════════════════════════════

final payrollFiltersProvider =
    StateProvider<PayrollFilters>((_) => _defaultFilters());

final allowancesFiltersProvider =
    StateProvider<PayrollFilters>((_) => _defaultFilters());

final deductionsFiltersProvider =
    StateProvider<PayrollFilters>((_) => _defaultFilters());

// ═══════════════════════════════════════════════════════════════════════════
// Data providers (auto-rebuild on filter change & branch change)
// ═══════════════════════════════════════════════════════════════════════════

final adminPayrollProvider =
    FutureProvider.autoDispose<PayrollListData>((ref) async {
  final f = ref.watch(payrollFiltersProvider);
  final sel = ref.watch(selectedBranchProvider);
  final response = await ref.watch(payrollRepositoryProvider).getPayroll(
        companyId: sel.companyId,
        branchId: sel.branchId,
        employeeId: f.employeeId,
        month: f.month,
        status: f.status,
        amountMin: f.amountMin,
        amountMax: f.amountMax,
        search: (f.search?.isEmpty ?? true) ? null : f.search,
        perPage: 50,
      );
  return response.data!;
});

final adminPayrollItemProvider = FutureProvider.autoDispose
    .family<PayrollItem, int>((ref, id) async {
  final response =
      await ref.watch(payrollRepositoryProvider).getPayrollItem(id);
  return response.data!;
});

final adminAllowancesProvider =
    FutureProvider.autoDispose<PayrollLineItemsData>((ref) async {
  final f = ref.watch(allowancesFiltersProvider);
  final sel = ref.watch(selectedBranchProvider);
  final response = await ref.watch(payrollRepositoryProvider).getAllowances(
        companyId: sel.companyId,
        branchId: sel.branchId,
        employeeId: f.employeeId,
        inputTypeId: f.inputTypeId,
        month: f.month,
        amountMin: f.amountMin,
        amountMax: f.amountMax,
        search: (f.search?.isEmpty ?? true) ? null : f.search,
        perPage: 50,
      );
  return response.data!;
});

final adminDeductionsProvider =
    FutureProvider.autoDispose<PayrollLineItemsData>((ref) async {
  final f = ref.watch(deductionsFiltersProvider);
  final sel = ref.watch(selectedBranchProvider);
  final response = await ref.watch(payrollRepositoryProvider).getDeductions(
        companyId: sel.companyId,
        branchId: sel.branchId,
        employeeId: f.employeeId,
        inputTypeId: f.inputTypeId,
        month: f.month,
        amountMin: f.amountMin,
        amountMax: f.amountMax,
        search: (f.search?.isEmpty ?? true) ? null : f.search,
        perPage: 50,
      );
  return response.data!;
});
