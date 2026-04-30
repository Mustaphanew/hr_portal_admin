import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ── RequestEmployee ──────────────────────────────────────────────────────────

/// Lightweight employee reference embedded in manager-view requests.
class RequestEmployee extends Equatable {
  final int id;
  final String name;
  final String code;
  final String? jobTitle;
  final int? departmentId;

  const RequestEmployee({
    required this.id,
    required this.name,
    required this.code,
    this.jobTitle,
    this.departmentId,
  });

  factory RequestEmployee.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String asStr(dynamic v) {
      if (v == null) return '';
      if (v is String) return v;
      return v.toString();
    }

    return RequestEmployee(
      id: asInt(json['id']),
      name: asStr(json['name']),
      code: asStr(json['employee_number']).isNotEmpty
          ? asStr(json['employee_number'])
          : asStr(json['code']),
      jobTitle: (json['job_title'] as String?)?.trim().isNotEmpty == true
          ? json['job_title'] as String
          : null,
      departmentId: json['department_id'] is num
          ? (json['department_id'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        if (jobTitle != null) 'job_title': jobTitle,
        if (departmentId != null) 'department_id': departmentId,
      };

  @override
  List<Object?> get props => [id, name, code, jobTitle, departmentId];
}

// ── RequestCurrency ──────────────────────────────────────────────────────────

/// Currency reference embedded in employee requests (real response includes
/// `currency: {id, code, name, symbol}`). Captured 2026-04-29.
class RequestCurrency extends Equatable {
  final int id;
  final String code;
  final String? name;
  final String? symbol;

  const RequestCurrency({
    required this.id,
    required this.code,
    this.name,
    this.symbol,
  });

  factory RequestCurrency.fromJson(Map<String, dynamic> json) {
    return RequestCurrency(
      id: (json['id'] as num).toInt(),
      code: (json['code'] as String?) ?? '',
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        if (name != null) 'name': name,
        if (symbol != null) 'symbol': symbol,
      };

  /// Display string preferring `symbol` (`ر.ي`) over `code` (`YER`).
  String get displaySymbol => (symbol?.isNotEmpty == true) ? symbol! : code;

  @override
  List<Object?> get props => [id, code, name, symbol];
}

// ── RequestCompany / RequestBranch ───────────────────────────────────────────

class RequestCompany extends Equatable {
  final int id;
  final String name;
  final String? nameEn;

  const RequestCompany({required this.id, required this.name, this.nameEn});

  factory RequestCompany.fromJson(Map<String, dynamic> json) {
    return RequestCompany(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      nameEn: json['name_en'] as String?,
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, if (nameEn != null) 'name_en': nameEn};

  @override
  List<Object?> get props => [id, name, nameEn];
}

class RequestBranch extends Equatable {
  final int id;
  final String name;

  const RequestBranch({required this.id, required this.name});

  factory RequestBranch.fromJson(Map<String, dynamic> json) {
    return RequestBranch(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

// ── EmployeeRequest ──────────────────────────────────────────────────────────

/// A single employee request (employee or admin view).
class EmployeeRequest extends Equatable {
  final int id;
  final String requestType;
  final int? requestTypeId;
  final String? requestTypeLabel;
  final String subject;
  final String? description;
  final String status;
  final int currentApprovalLevel;
  final String? responseNotes;
  final int? respondedBy;
  final String? respondedAt;
  final String createdAt;
  final String updatedAt;

  /// Amount associated with the request (advance, expense, etc.).
  final double? amount;

  /// Date associated with the request (e.g. requested date).
  final String? date;

  /// Only present in admin/manager-view responses.
  final RequestEmployee? employee;

  final List<dynamic>? approvalChain;
  final List<dynamic>? attachments;

  /// Whether the current admin/manager can approve/reject this request.
  final bool? canApprove;

  // ── Fields captured from real response 2026-04-29 ──

  /// Currency for [amount]. Use [currency.displaySymbol] in the UI.
  final RequestCurrency? currency;

  /// Company that owns this request.
  final RequestCompany? company;

  /// Branch that owns this request.
  final RequestBranch? branch;

  /// Total approval levels (e.g. 3 means "Step 1/3").
  final int? totalLevels;

  /// Snapshot of who must approve next (raw object for now).
  final Map<String, dynamic>? nextApprover;

  /// Detailed approval history entries (kept as raw maps until we need typed).
  final List<Map<String, dynamic>>? approvalHistory;

  /// Public URL of the attached file (already absolute on the backend).
  final String? attachmentUrl;

  /// Backend storage path (rarely shown to users; useful for support).
  final String? attachmentPath;

  const EmployeeRequest({
    required this.id,
    required this.requestType,
    this.requestTypeId,
    this.requestTypeLabel,
    required this.subject,
    this.description,
    required this.status,
    required this.currentApprovalLevel,
    this.responseNotes,
    this.respondedBy,
    this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
    this.amount,
    this.date,
    this.employee,
    this.approvalChain,
    this.attachments,
    this.canApprove,
    this.currency,
    this.company,
    this.branch,
    this.totalLevels,
    this.nextApprover,
    this.approvalHistory,
    this.attachmentUrl,
    this.attachmentPath,
  });

  factory EmployeeRequest.fromJson(Map<String, dynamic> json) {
    String? asStr(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      return v.toString();
    }

    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    final rt = json['request_type'];
    String requestType;
    String? requestTypeLabel;
    if (rt is Map) {
      requestType = asStr(rt['slug']) ??
          asStr(rt['code']) ??
          asStr(rt['key']) ??
          '';
      requestTypeLabel =
          asStr(rt['name']) ?? asStr(rt['label']) ?? asStr(rt['title']);
    } else {
      requestType = asStr(rt) ?? '';
      requestTypeLabel = asStr(json['request_type_name']);
    }

    // Approval history: keep as List<Map<String, dynamic>> so the UI can
    // render a timeline without needing a typed model right away.
    List<Map<String, dynamic>>? approvalHistory;
    if (json['approval_history'] is List) {
      approvalHistory = (json['approval_history'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return EmployeeRequest(
      id: asInt(json['id']) ?? 0,
      requestType: requestType,
      requestTypeId: asInt(json['request_type_id']),
      requestTypeLabel: requestTypeLabel,
      subject: asStr(json['subject']) ??
          asStr(json['title']) ??
          requestTypeLabel ??
          '',
      description: asStr(json['description']) ?? asStr(json['notes']),
      status: asStr(json['status']) ?? 'pending',
      currentApprovalLevel: asInt(json['current_approval_level']) ?? 0,
      responseNotes:
          asStr(json['response_notes']) ?? asStr(json['decision_notes']),
      respondedBy: asInt(json['responded_by']),
      respondedAt:
          asStr(json['responded_at']) ?? asStr(json['decided_at']),
      createdAt: asStr(json['created_at']) ?? '',
      updatedAt: asStr(json['updated_at']) ??
          asStr(json['created_at']) ??
          '',
      amount: asDouble(json['amount']) ?? asDouble(json['total_amount']),
      // Accept all three name variants (the real API uses `request_date`).
      date: asStr(json['request_date']) ??
          asStr(json['requested_date']) ??
          asStr(json['date']),
      employee: json['employee'] is Map<String, dynamic>
          ? RequestEmployee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      approvalChain: json['approval_chain'] is List
          ? json['approval_chain'] as List<dynamic>
          : null,
      attachments: json['attachments'] is List
          ? json['attachments'] as List<dynamic>
          : null,
      canApprove: json['can_approve'] is bool ? json['can_approve'] as bool : null,
      // ── New fields from real response ──
      currency: json['currency'] is Map<String, dynamic>
          ? RequestCurrency.fromJson(json['currency'] as Map<String, dynamic>)
          : null,
      company: json['company'] is Map<String, dynamic>
          ? RequestCompany.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      branch: json['branch'] is Map<String, dynamic>
          ? RequestBranch.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      totalLevels: asInt(json['total_levels']),
      nextApprover: json['next_approver'] is Map<String, dynamic>
          ? json['next_approver'] as Map<String, dynamic>
          : null,
      approvalHistory: approvalHistory,
      attachmentUrl: asStr(json['attachment_url']),
      attachmentPath: asStr(json['attachment_path']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'request_type': requestType,
        if (requestTypeId != null) 'request_type_id': requestTypeId,
        if (requestTypeLabel != null) 'request_type_label': requestTypeLabel,
        'subject': subject,
        'description': description,
        'status': status,
        'current_approval_level': currentApprovalLevel,
        if (totalLevels != null) 'total_levels': totalLevels,
        'response_notes': responseNotes,
        'responded_by': respondedBy,
        'responded_at': respondedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency!.toJson(),
        if (date != null) 'request_date': date,
        if (employee != null) 'employee': employee!.toJson(),
        if (company != null) 'company': company!.toJson(),
        if (branch != null) 'branch': branch!.toJson(),
        if (approvalChain != null) 'approval_chain': approvalChain,
        if (approvalHistory != null) 'approval_history': approvalHistory,
        if (nextApprover != null) 'next_approver': nextApprover,
        if (attachments != null) 'attachments': attachments,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
        if (attachmentPath != null) 'attachment_path': attachmentPath,
        if (canApprove != null) 'can_approve': canApprove,
      };

  @override
  List<Object?> get props => [
        id,
        requestType,
        requestTypeId,
        requestTypeLabel,
        subject,
        description,
        status,
        currentApprovalLevel,
        totalLevels,
        responseNotes,
        respondedBy,
        respondedAt,
        createdAt,
        updatedAt,
        amount,
        currency,
        date,
        employee,
        company,
        branch,
        approvalChain,
        approvalHistory,
        nextApprover,
        attachments,
        attachmentUrl,
        attachmentPath,
        canApprove,
      ];
}

// ── RequestsListData ─────────────────────────────────────────────────────────

/// Wrapper for paginated request lists (employee or manager view).
class RequestsListData extends Equatable {
  final List<EmployeeRequest> requests;
  final Pagination? pagination;

  const RequestsListData({
    required this.requests,
    this.pagination,
  });

  factory RequestsListData.fromJson(Map<String, dynamic> json) {
    // The API may use a variety of keys for the list itself; try each in turn.
    // Falls back to scanning the map for the first List<Map> value.
    List<dynamic>? raw;
    for (final key in const [
      'employee_requests',
      'requests',
      'items',
      'data',
      'records',
      'results',
    ]) {
      final v = json[key];
      if (v is List) {
        raw = v;
        break;
      }
    }
    raw ??= json.values
        .whereType<List>()
        .firstWhere((l) => l.isEmpty || l.first is Map, orElse: () => const []);

    return RequestsListData(
      requests: raw
          .map((e) => EmployeeRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: (json['meta'] ?? json['pagination']) != null
          ? Pagination.fromParent(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [requests, pagination];
}

// ── EmployeeRequestsSummary ──────────────────────────────────────────────────

/// Summary KPIs returned by GET /admin/employee-requests/summary.
class EmployeeRequestsSummary extends Equatable {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int? processing;
  final int? completed;
  final int? cancelled;
  final double? totalAmount;

  const EmployeeRequestsSummary({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    this.processing,
    this.completed,
    this.cancelled,
    this.totalAmount,
  });

  factory EmployeeRequestsSummary.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return EmployeeRequestsSummary(
      total: (json['total'] ?? 0) as int,
      pending: (json['pending'] ?? 0) as int,
      approved: (json['approved'] ?? 0) as int,
      rejected: (json['rejected'] ?? 0) as int,
      processing: json['processing'] as int?,
      completed: json['completed'] as int?,
      cancelled: json['cancelled'] as int?,
      totalAmount: toDouble(json['total_amount']),
    );
  }

  @override
  List<Object?> get props =>
      [total, pending, approved, rejected, processing, completed, cancelled, totalAmount];
}
