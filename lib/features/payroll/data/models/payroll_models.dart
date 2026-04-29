import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════

String? _asString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared lightweight refs
// ═══════════════════════════════════════════════════════════════════════════

class PayrollEmployeeRef extends Equatable {
  final int id;
  final String? code;
  final String name;
  final String? jobTitle;
  final String? departmentName;

  const PayrollEmployeeRef({
    required this.id,
    this.code,
    required this.name,
    this.jobTitle,
    this.departmentName,
  });

  factory PayrollEmployeeRef.fromJson(Map<String, dynamic> json) {
    final dept = json['department'];
    return PayrollEmployeeRef(
      id: _asInt(json['id']) ?? 0,
      code: _asString(json['employee_number']) ?? _asString(json['code']),
      name: _asString(json['name']) ?? '',
      jobTitle: _asString(json['job_title']),
      departmentName: dept is Map<String, dynamic>
          ? _asString(dept['name'])
          : _asString(json['department_name']),
    );
  }

  @override
  List<Object?> get props => [id, code, name, jobTitle, departmentName];
}

class PayrollInputType extends Equatable {
  final int id;
  final String? code;
  final String name;
  final String? type; // allowance / deduction
  final bool? isPercentage;

  const PayrollInputType({
    required this.id,
    this.code,
    required this.name,
    this.type,
    this.isPercentage,
  });

  factory PayrollInputType.fromJson(Map<String, dynamic> json) {
    return PayrollInputType(
      id: _asInt(json['id']) ?? 0,
      code: _asString(json['code']),
      name: _asString(json['name']) ?? '',
      type: _asString(json['type']),
      isPercentage: json['is_percentage'] is bool
          ? json['is_percentage'] as bool
          : null,
    );
  }

  @override
  List<Object?> get props => [id, code, name, type, isPercentage];
}

// ═══════════════════════════════════════════════════════════════════════════
// PayrollItem (Postman 03 — /admin/payroll list & show)
// ═══════════════════════════════════════════════════════════════════════════

class PayrollItem extends Equatable {
  final int id;
  final PayrollEmployeeRef? employee;
  final String? month;
  final String? periodStart;
  final String? periodEnd;
  final String status;
  final double basicSalary;
  final double totalAllowances;
  final double totalDeductions;
  final double netSalary;
  final double? grossSalary;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const PayrollItem({
    required this.id,
    this.employee,
    this.month,
    this.periodStart,
    this.periodEnd,
    required this.status,
    required this.basicSalary,
    required this.totalAllowances,
    required this.totalDeductions,
    required this.netSalary,
    this.grossSalary,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory PayrollItem.fromJson(Map<String, dynamic> json) {
    final emp = json['employee'];
    return PayrollItem(
      id: _asInt(json['id']) ?? 0,
      employee: emp is Map<String, dynamic>
          ? PayrollEmployeeRef.fromJson(emp)
          : null,
      month: _asString(json['month']),
      periodStart: _asString(json['period_start']),
      periodEnd: _asString(json['period_end']),
      status: _asString(json['status']) ?? 'draft',
      basicSalary: _asDouble(json['basic_salary']) ?? 0,
      totalAllowances: _asDouble(json['total_allowances']) ?? 0,
      totalDeductions: _asDouble(json['total_deductions']) ?? 0,
      netSalary: _asDouble(json['net_salary']) ?? 0,
      grossSalary: _asDouble(json['gross_salary']),
      notes: _asString(json['notes']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        employee,
        month,
        periodStart,
        periodEnd,
        status,
        basicSalary,
        totalAllowances,
        totalDeductions,
        netSalary,
        grossSalary,
        notes,
        createdAt,
        updatedAt,
      ];
}

class PayrollListData extends Equatable {
  final List<PayrollItem> items;
  final Pagination? pagination;

  const PayrollListData({required this.items, this.pagination});

  factory PayrollListData.fromJson(Map<String, dynamic> json) {
    final raw = json['payroll'] ??
        json['items'] ??
        json['data'] ??
        const <dynamic>[];
    return PayrollListData(
      items: (raw as List<dynamic>)
          .map((e) => PayrollItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: (json['meta'] ?? json['pagination']) != null
          ? Pagination.fromParent(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [items, pagination];
}

// ═══════════════════════════════════════════════════════════════════════════
// PayrollLineItem — shared by Allowances & Deductions (Postman 04)
// ═══════════════════════════════════════════════════════════════════════════

/// Generic payroll line item used for both allowances and deductions.
/// They share the same shape on the API; only the endpoint differs.
class PayrollLineItem extends Equatable {
  final int id;
  final PayrollEmployeeRef? employee;
  final PayrollInputType? inputType;
  final String? periodStart;
  final String? periodEnd;
  final String? month;
  final double quantity;
  final double rate;
  final double amount;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const PayrollLineItem({
    required this.id,
    this.employee,
    this.inputType,
    this.periodStart,
    this.periodEnd,
    this.month,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory PayrollLineItem.fromJson(Map<String, dynamic> json) {
    final emp = json['employee'];
    final type = json['input_type'] ?? json['type'];
    return PayrollLineItem(
      id: _asInt(json['id']) ?? 0,
      employee: emp is Map<String, dynamic>
          ? PayrollEmployeeRef.fromJson(emp)
          : null,
      inputType: type is Map<String, dynamic>
          ? PayrollInputType.fromJson(type)
          : null,
      periodStart: _asString(json['period_start']),
      periodEnd: _asString(json['period_end']),
      month: _asString(json['month']),
      quantity: _asDouble(json['quantity']) ?? 1,
      rate: _asDouble(json['rate']) ?? 0,
      amount: _asDouble(json['amount']) ?? 0,
      notes: _asString(json['notes']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        employee,
        inputType,
        periodStart,
        periodEnd,
        month,
        quantity,
        rate,
        amount,
        notes,
        createdAt,
        updatedAt,
      ];
}

class PayrollLineItemsData extends Equatable {
  final List<PayrollLineItem> items;
  final Pagination? pagination;

  const PayrollLineItemsData({required this.items, this.pagination});

  factory PayrollLineItemsData.fromJson(Map<String, dynamic> json, {String? key}) {
    final candidates = <String>[
      ?key,
      'allowances',
      'deductions',
      'items',
      'data',
    ];
    List<dynamic> raw = const [];
    for (final k in candidates) {
      final v = json[k];
      if (v is List<dynamic>) {
        raw = v;
        break;
      }
    }
    return PayrollLineItemsData(
      items: raw
          .map((e) => PayrollLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: (json['meta'] ?? json['pagination']) != null
          ? Pagination.fromParent(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [items, pagination];
}
