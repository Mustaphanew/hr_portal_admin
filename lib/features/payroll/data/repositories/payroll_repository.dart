import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/base_response.dart';
import '../models/payroll_models.dart';

/// Repository covering admin payroll, allowances and deductions.
///
/// Postman sections:
/// - 03 — Payroll: list & show
/// - 04 — Allowances: CRUD
/// - 04 — Deductions: CRUD
class PayrollRepository {
  final ApiClient _client;

  PayrollRepository({required ApiClient client}) : _client = client;

  // ═══════════════════════════════════════════════════════════════════════════
  // Payroll (Postman 03)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<BaseResponse<PayrollListData>> getPayroll({
    int? companyId,
    int? branchId,
    int? employeeId,
    String? month,
    String? status,
    double? amountMin,
    double? amountMax,
    String? search,
    int? perPage,
    int? page,
  }) async {
    return _client.get<PayrollListData>(
      ApiConstants.adminPayroll,
      fromJson: (json) =>
          PayrollListData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'company_id': ?companyId,
        'branch_id': ?branchId,
        'employee_id': ?employeeId,
        'month': ?month,
        'status': ?status,
        'amount_min': ?amountMin,
        'amount_max': ?amountMax,
        'search': ?search,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
  }

  Future<BaseResponse<PayrollItem>> getPayrollItem(int id) async {
    return _client.get<PayrollItem>(
      ApiConstants.adminPayrollItem(id),
      fromJson: (json) => PayrollItem.fromJson(json as Map<String, dynamic>),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Allowances (Postman 04)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<BaseResponse<PayrollLineItemsData>> getAllowances({
    int? companyId,
    int? branchId,
    int? employeeId,
    int? inputTypeId,
    String? month,
    double? amountMin,
    double? amountMax,
    String? search,
    int? perPage,
    int? page,
  }) async {
    return _client.get<PayrollLineItemsData>(
      ApiConstants.adminAllowances,
      fromJson: (json) => PayrollLineItemsData.fromJson(
          json as Map<String, dynamic>,
          key: 'allowances'),
      queryParameters: {
        'company_id': ?companyId,
        'branch_id': ?branchId,
        'employee_id': ?employeeId,
        'input_type_id': ?inputTypeId,
        'month': ?month,
        'amount_min': ?amountMin,
        'amount_max': ?amountMax,
        'search': ?search,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
  }

  Future<BaseResponse<PayrollLineItem>> createAllowance({
    required int employeeId,
    required int inputTypeId,
    required String periodStart,
    required String periodEnd,
    double quantity = 1,
    required double rate,
    required double amount,
    String? notes,
  }) async {
    return _client.post<PayrollLineItem>(
      ApiConstants.adminAllowances,
      fromJson: (json) =>
          PayrollLineItem.fromJson(json as Map<String, dynamic>),
      data: {
        'employee_id': employeeId,
        'input_type_id': inputTypeId,
        'period_start': periodStart,
        'period_end': periodEnd,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
        'notes': ?notes,
      },
    );
  }

  Future<BaseResponse<PayrollLineItem>> updateAllowance(
    int id, {
    double? quantity,
    double? rate,
    double? amount,
    String? notes,
    String? periodStart,
    String? periodEnd,
  }) async {
    return _client.put<PayrollLineItem>(
      ApiConstants.adminAllowanceDetail(id),
      fromJson: (json) =>
          PayrollLineItem.fromJson(json as Map<String, dynamic>),
      data: {
        'quantity': ?quantity,
        'rate': ?rate,
        'amount': ?amount,
        'notes': ?notes,
        'period_start': ?periodStart,
        'period_end': ?periodEnd,
      },
    );
  }

  Future<BaseResponse<void>> deleteAllowance(int id) async {
    return _client.delete<void>(ApiConstants.adminAllowanceDetail(id));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Deductions (Postman 04)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<BaseResponse<PayrollLineItemsData>> getDeductions({
    int? companyId,
    int? branchId,
    int? employeeId,
    int? inputTypeId,
    String? month,
    double? amountMin,
    double? amountMax,
    String? search,
    int? perPage,
    int? page,
  }) async {
    return _client.get<PayrollLineItemsData>(
      ApiConstants.adminDeductions,
      fromJson: (json) => PayrollLineItemsData.fromJson(
          json as Map<String, dynamic>,
          key: 'deductions'),
      queryParameters: {
        'company_id': ?companyId,
        'branch_id': ?branchId,
        'employee_id': ?employeeId,
        'input_type_id': ?inputTypeId,
        'month': ?month,
        'amount_min': ?amountMin,
        'amount_max': ?amountMax,
        'search': ?search,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
  }

  Future<BaseResponse<PayrollLineItem>> createDeduction({
    required int employeeId,
    required int inputTypeId,
    required String periodStart,
    required String periodEnd,
    double quantity = 1,
    required double rate,
    required double amount,
    String? notes,
  }) async {
    return _client.post<PayrollLineItem>(
      ApiConstants.adminDeductions,
      fromJson: (json) =>
          PayrollLineItem.fromJson(json as Map<String, dynamic>),
      data: {
        'employee_id': employeeId,
        'input_type_id': inputTypeId,
        'period_start': periodStart,
        'period_end': periodEnd,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
        'notes': ?notes,
      },
    );
  }

  Future<BaseResponse<PayrollLineItem>> updateDeduction(
    int id, {
    double? quantity,
    double? rate,
    double? amount,
    String? notes,
    String? periodStart,
    String? periodEnd,
  }) async {
    return _client.put<PayrollLineItem>(
      ApiConstants.adminDeductionDetail(id),
      fromJson: (json) =>
          PayrollLineItem.fromJson(json as Map<String, dynamic>),
      data: {
        'quantity': ?quantity,
        'rate': ?rate,
        'amount': ?amount,
        'notes': ?notes,
        'period_start': ?periodStart,
        'period_end': ?periodEnd,
      },
    );
  }

  Future<BaseResponse<void>> deleteDeduction(int id) async {
    return _client.delete<void>(ApiConstants.adminDeductionDetail(id));
  }
}
