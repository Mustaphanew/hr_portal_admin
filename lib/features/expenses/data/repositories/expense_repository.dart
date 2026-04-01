import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/expense_models.dart';

/// Repository handling admin expense operations.
///
/// Endpoints covered:
/// - P1: GET /admin/expenses
/// - P2: GET /admin/expenses/{id}
/// - P3: POST /admin/expenses/{id}/approve
/// - P4: POST /admin/expenses/{id}/reject
class ExpenseRepository {
  final ApiClient _client;

  ExpenseRepository({required ApiClient client}) : _client = client;

  /// Fetch paginated list of expenses with optional filters.
  Future<ExpensesData> getExpenses({
    String? status,
    String? category,
    int? employeeId,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<ExpensesData>(
      ApiConstants.adminExpenses,
      fromJson: (json) =>
          ExpensesData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'status': ?status,
        'category': ?category,
        'employee_id': ?employeeId,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
    return response.data!;
  }

  /// Fetch detailed information for a specific expense.
  Future<Expense> getExpenseDetail(int id) async {
    final response = await _client.get<Expense>(
      ApiConstants.adminExpenseDetail(id),
      fromJson: (json) =>
          Expense.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Approve an expense with optional notes.
  Future<Expense> approveExpense(int id, {String? notes}) async {
    final response = await _client.post<Expense>(
      ApiConstants.adminExpenseApprove(id),
      fromJson: (json) =>
          Expense.fromJson(json as Map<String, dynamic>),
      data: {
        'notes': ?notes,
      },
    );
    return response.data!;
  }

  /// Reject an expense with optional notes.
  Future<Expense> rejectExpense(int id, {String? notes}) async {
    final response = await _client.post<Expense>(
      ApiConstants.adminExpenseReject(id),
      fromJson: (json) =>
          Expense.fromJson(json as Map<String, dynamic>),
      data: {
        'notes': ?notes,
      },
    );
    return response.data!;
  }
}
