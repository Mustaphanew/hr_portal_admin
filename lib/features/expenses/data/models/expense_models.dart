import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Expense Models (API P1-P4)
// ═══════════════════════════════════════════════════════════════════════════

/// Employee reference embedded in an expense record.
class ExpenseEmployee extends Equatable {
  final int id;
  final String name;
  final String code;
  final String department;

  const ExpenseEmployee({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
  });

  factory ExpenseEmployee.fromJson(Map<String, dynamic> json) {
    return ExpenseEmployee(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      code: (json['code'] ?? '') as String,
      department: (json['department'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'department': department,
      };

  @override
  List<Object?> get props => [id, name, code, department];
}

/// An expense record in the admin expenses list.
class Expense extends Equatable {
  final int id;
  final ExpenseEmployee employee;
  final String category;
  final String? categoryIcon;
  final double amount;
  final String currency;
  final String submittedDate;
  final String expenseDate;
  final String status;
  final String? priority;
  final String? notes;
  final String? projectRef;
  final bool hasAttachment;
  final bool isHighValue;

  const Expense({
    required this.id,
    required this.employee,
    required this.category,
    this.categoryIcon,
    required this.amount,
    required this.currency,
    required this.submittedDate,
    required this.expenseDate,
    required this.status,
    this.priority,
    this.notes,
    this.projectRef,
    required this.hasAttachment,
    required this.isHighValue,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: (json['id'] as num?)?.toInt() ?? 0,
      employee: json['employee'] is Map
          ? ExpenseEmployee.fromJson(json['employee'] as Map<String, dynamic>)
          : const ExpenseEmployee(id: 0, name: '—', code: '', department: ''),
      category: (json['category'] ?? '') as String,
      categoryIcon: json['category_icon'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? 'YER') as String,
      submittedDate: (json['submitted_date'] ?? '') as String,
      expenseDate: (json['expense_date'] ?? '') as String,
      status: (json['status'] ?? 'pending') as String,
      priority: json['priority'] as String?,
      notes: json['notes'] as String?,
      projectRef: json['project_ref'] as String?,
      hasAttachment: (json['has_attachment'] ?? json['has_receipt'] ?? false) as bool,
      isHighValue: (json['is_high_value'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee': employee.toJson(),
        'category': category,
        'category_icon': categoryIcon,
        'amount': amount,
        'currency': currency,
        'submitted_date': submittedDate,
        'expense_date': expenseDate,
        'status': status,
        'priority': priority,
        'notes': notes,
        'project_ref': projectRef,
        'has_attachment': hasAttachment,
        'is_high_value': isHighValue,
      };

  @override
  List<Object?> get props => [
        id,
        employee,
        category,
        categoryIcon,
        amount,
        currency,
        submittedDate,
        expenseDate,
        status,
        priority,
        notes,
        projectRef,
        hasAttachment,
        isHighValue,
      ];
}

/// Data payload returned by GET /admin/expenses (API P1).
class ExpensesData extends Equatable {
  final List<Expense> expenses;
  final Pagination pagination;

  const ExpensesData({
    required this.expenses,
    required this.pagination,
  });

  factory ExpensesData.fromJson(Map<String, dynamic> json) {
    return ExpensesData(
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromParent(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };

  @override
  List<Object?> get props => [expenses, pagination];
}
