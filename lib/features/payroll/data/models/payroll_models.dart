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

/// Lightweight company / branch / department reference.
class PayrollNamedRef extends Equatable {
  final int id;
  final String name;
  final String? nameEn;

  const PayrollNamedRef({
    required this.id,
    required this.name,
    this.nameEn,
  });

  factory PayrollNamedRef.fromJson(Map<String, dynamic> json) {
    return PayrollNamedRef(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['name']) ?? '',
      nameEn: _asString(json['name_en']),
    );
  }

  @override
  List<Object?> get props => [id, name, nameEn];
}

class PayrollInputType extends Equatable {
  final int id;
  final String? code;
  final String name;
  /// `earning` (= allowance / bonus) or `deduction` — captured from real
  /// `/admin/allowances` response.
  final String? type;
  final bool? isPercentage;
  /// `days` / `hours` / `fixed` — describes how `quantity * rate = amount`.
  final String? calcMode;

  const PayrollInputType({
    required this.id,
    this.code,
    required this.name,
    this.type,
    this.isPercentage,
    this.calcMode,
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
      calcMode: _asString(json['calc_mode']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (code != null) 'code': code,
        'name': name,
        if (type != null) 'type': type,
        if (isPercentage != null) 'is_percentage': isPercentage,
        if (calcMode != null) 'calc_mode': calcMode,
      };

  @override
  List<Object?> get props => [id, code, name, type, isPercentage, calcMode];
}

// ═══════════════════════════════════════════════════════════════════════════
// PayrollItem (Postman 03 — /admin/payroll list & show)
// ═══════════════════════════════════════════════════════════════════════════

/// Real `/admin/payroll` item — captured 2026-04-29.
///
/// Field mapping vs old model:
/// - `basicSalary` ← was `basic_salary`, **really `base_salary`**
/// - `totalGross`  ← was `gross_salary`,  **really `total_gross`**
/// - `totalNet`    ← was `net_salary`,    **really `total_net`**
class PayrollItem extends Equatable {
  final int id;
  final int? payrollRunId;
  final String? runNo;
  final String? runType;
  final String? runStatus;
  final PayrollEmployeeRef? employee;
  final PayrollNamedRef? company;
  final PayrollNamedRef? branch;
  final PayrollNamedRef? department;
  final String? month;
  final String? periodStart;
  final String? periodEnd;
  final String? payDate;
  final String status;
  final double basicSalary;
  final double totalGross;
  final double totalAllowances;
  final double totalDeductions;
  final double totalNet;
  final double paidAmount;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const PayrollItem({
    required this.id,
    this.payrollRunId,
    this.runNo,
    this.runType,
    this.runStatus,
    this.employee,
    this.company,
    this.branch,
    this.department,
    this.month,
    this.periodStart,
    this.periodEnd,
    this.payDate,
    required this.status,
    required this.basicSalary,
    required this.totalGross,
    required this.totalAllowances,
    required this.totalDeductions,
    required this.totalNet,
    required this.paidAmount,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Convenience aliases for older UI code.
  double get netSalary => totalNet;
  double get grossSalary => totalGross;

  factory PayrollItem.fromJson(Map<String, dynamic> json) {
    final emp = json['employee'];
    final comp = json['company'];
    final br = json['branch'];
    final dep = json['department'];
    return PayrollItem(
      id: _asInt(json['id']) ?? 0,
      payrollRunId: _asInt(json['payroll_run_id']),
      runNo: _asString(json['run_no']),
      runType: _asString(json['run_type']),
      runStatus: _asString(json['run_status']),
      employee: emp is Map<String, dynamic>
          ? PayrollEmployeeRef.fromJson(emp)
          : null,
      company: comp is Map<String, dynamic>
          ? PayrollNamedRef.fromJson(comp)
          : null,
      branch: br is Map<String, dynamic>
          ? PayrollNamedRef.fromJson(br)
          : null,
      department: dep is Map<String, dynamic>
          ? PayrollNamedRef.fromJson(dep)
          : null,
      month: _asString(json['month']),
      periodStart: _asString(json['period_start']),
      periodEnd: _asString(json['period_end']),
      payDate: _asString(json['pay_date']),
      status: _asString(json['status']) ?? 'draft',
      // ── Core money fields — accept both old and new keys for safety ──
      basicSalary: _asDouble(json['base_salary']) ??
          _asDouble(json['basic_salary']) ??
          0,
      totalGross: _asDouble(json['total_gross']) ??
          _asDouble(json['gross_salary']) ??
          0,
      totalAllowances: _asDouble(json['total_allowances']) ?? 0,
      totalDeductions: _asDouble(json['total_deductions']) ?? 0,
      totalNet: _asDouble(json['total_net']) ??
          _asDouble(json['net_salary']) ??
          0,
      paidAmount: _asDouble(json['paid_amount']) ?? 0,
      notes: _asString(json['notes']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        payrollRunId,
        runNo,
        runType,
        runStatus,
        employee,
        company,
        branch,
        department,
        month,
        periodStart,
        periodEnd,
        payDate,
        status,
        basicSalary,
        totalGross,
        totalAllowances,
        totalDeductions,
        totalNet,
        paidAmount,
        notes,
        createdAt,
        updatedAt,
      ];
}

/// Aggregate KPIs included alongside `/admin/payroll` — captured 2026-04-29.
class PayrollSummary extends Equatable {
  final int count;
  final double totalGross;
  final double totalDeductions;
  final double totalNet;
  final double totalPaid;

  const PayrollSummary({
    required this.count,
    required this.totalGross,
    required this.totalDeductions,
    required this.totalNet,
    required this.totalPaid,
  });

  factory PayrollSummary.fromJson(Map<String, dynamic> json) {
    return PayrollSummary(
      count: _asInt(json['count']) ?? 0,
      totalGross: _asDouble(json['total_gross']) ?? 0,
      totalDeductions: _asDouble(json['total_deductions']) ?? 0,
      totalNet: _asDouble(json['total_net']) ?? 0,
      totalPaid: _asDouble(json['total_paid']) ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [count, totalGross, totalDeductions, totalNet, totalPaid];
}

class PayrollListData extends Equatable {
  final List<PayrollItem> items;
  final PayrollSummary? summary;
  final Pagination? pagination;

  const PayrollListData({
    required this.items,
    this.summary,
    this.pagination,
  });

  factory PayrollListData.fromJson(Map<String, dynamic> json) {
    final raw = json['payroll'] ??
        json['items'] ??
        json['data'] ??
        const <dynamic>[];
    return PayrollListData(
      items: (raw as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(PayrollItem.fromJson)
          .toList(),
      summary: json['summary'] is Map<String, dynamic>
          ? PayrollSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      pagination: (json['meta'] ?? json['pagination']) != null
          ? Pagination.fromParent(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [items, summary, pagination];
}

// ═══════════════════════════════════════════════════════════════════════════
// PayrollLineItem — shared by Allowances & Deductions (Postman 04)
// ═══════════════════════════════════════════════════════════════════════════

/// Generic payroll line item used for both allowances and deductions.
/// They share the same shape on the API; only the endpoint differs.
///
/// Real shape (captured 2026-04-29 from `/admin/allowances`):
/// `{id, payroll_run_id, period_start, period_end, quantity, rate, amount,
///   notes, input_type:{id,code,name,type,calc_mode}, employee:{...},
///   company:{...}, department:{...}, branch:{...}, created_at}`
class PayrollLineItem extends Equatable {
  final int id;
  final int? payrollRunId;
  final PayrollEmployeeRef? employee;
  final PayrollInputType? inputType;
  final PayrollNamedRef? company;
  final PayrollNamedRef? branch;
  final PayrollNamedRef? department;
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
    this.payrollRunId,
    this.employee,
    this.inputType,
    this.company,
    this.branch,
    this.department,
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
    final comp = json['company'];
    final br = json['branch'];
    final dep = json['department'];
    return PayrollLineItem(
      id: _asInt(json['id']) ?? 0,
      payrollRunId: _asInt(json['payroll_run_id']),
      employee: emp is Map<String, dynamic>
          ? PayrollEmployeeRef.fromJson(emp)
          : null,
      inputType: type is Map<String, dynamic>
          ? PayrollInputType.fromJson(type)
          : null,
      company: comp is Map<String, dynamic>
          ? PayrollNamedRef.fromJson(comp)
          : null,
      branch: br is Map<String, dynamic>
          ? PayrollNamedRef.fromJson(br)
          : null,
      department: dep is Map<String, dynamic>
          ? PayrollNamedRef.fromJson(dep)
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
        payrollRunId,
        employee,
        inputType,
        company,
        branch,
        department,
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

/// Aggregate summary returned alongside allowances/deductions lists.
class PayrollLinesSummary extends Equatable {
  final int count;
  final double totalAmount;

  const PayrollLinesSummary({required this.count, required this.totalAmount});

  factory PayrollLinesSummary.fromJson(Map<String, dynamic> json) {
    return PayrollLinesSummary(
      count: _asInt(json['count']) ?? 0,
      totalAmount: _asDouble(json['total_amount']) ?? 0,
    );
  }

  @override
  List<Object?> get props => [count, totalAmount];
}

class PayrollLineItemsData extends Equatable {
  final List<PayrollLineItem> items;
  final PayrollLinesSummary? summary;
  final Pagination? pagination;

  const PayrollLineItemsData({
    required this.items,
    this.summary,
    this.pagination,
  });

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
          .whereType<Map<String, dynamic>>()
          .map(PayrollLineItem.fromJson)
          .toList(),
      summary: json['summary'] is Map<String, dynamic>
          ? PayrollLinesSummary.fromJson(
              json['summary'] as Map<String, dynamic>)
          : null,
      pagination: (json['meta'] ?? json['pagination']) != null
          ? Pagination.fromParent(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [items, summary, pagination];
}
