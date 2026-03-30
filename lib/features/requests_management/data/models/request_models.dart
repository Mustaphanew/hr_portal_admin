import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ── RequestEmployee ──────────────────────────────────────────────────────────

/// Lightweight employee reference embedded in manager-view requests.
class RequestEmployee extends Equatable {
  final int id;
  final String name;
  final String code;

  const RequestEmployee({
    required this.id,
    required this.name,
    required this.code,
  });

  factory RequestEmployee.fromJson(Map<String, dynamic> json) {
    return RequestEmployee(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
      };

  @override
  List<Object?> get props => [id, name, code];
}

// ── EmployeeRequest ──────────────────────────────────────────────────────────

/// A single employee request (employee or manager view).
class EmployeeRequest extends Equatable {
  final int id;
  final String requestType;
  final String subject;
  final String? description;
  final String status;
  final int currentApprovalLevel;
  final String? responseNotes;
  final int? respondedBy;
  final String? respondedAt;
  final String createdAt;
  final String updatedAt;

  /// Only present in manager-view responses.
  final RequestEmployee? employee;

  final List<dynamic>? approvalChain;
  final List<dynamic>? attachments;

  /// Whether the current manager can approve/reject this request.
  final bool? canApprove;

  const EmployeeRequest({
    required this.id,
    required this.requestType,
    required this.subject,
    this.description,
    required this.status,
    required this.currentApprovalLevel,
    this.responseNotes,
    this.respondedBy,
    this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
    this.employee,
    this.approvalChain,
    this.attachments,
    this.canApprove,
  });

  factory EmployeeRequest.fromJson(Map<String, dynamic> json) {
    return EmployeeRequest(
      id: json['id'] as int,
      requestType: json['request_type'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      currentApprovalLevel: json['current_approval_level'] as int,
      responseNotes: json['response_notes'] as String?,
      respondedBy: json['responded_by'] as int?,
      respondedAt: json['responded_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      employee: json['employee'] != null
          ? RequestEmployee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      approvalChain: json['approval_chain'] as List<dynamic>?,
      attachments: json['attachments'] as List<dynamic>?,
      canApprove: json['can_approve'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'request_type': requestType,
        'subject': subject,
        'description': description,
        'status': status,
        'current_approval_level': currentApprovalLevel,
        'response_notes': responseNotes,
        'responded_by': respondedBy,
        'responded_at': respondedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        if (employee != null) 'employee': employee!.toJson(),
        if (approvalChain != null) 'approval_chain': approvalChain,
        if (attachments != null) 'attachments': attachments,
        if (canApprove != null) 'can_approve': canApprove,
      };

  @override
  List<Object?> get props => [
        id,
        requestType,
        subject,
        description,
        status,
        currentApprovalLevel,
        responseNotes,
        respondedBy,
        respondedAt,
        createdAt,
        updatedAt,
        employee,
        approvalChain,
        attachments,
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
    return RequestsListData(
      requests: (json['requests'] as List<dynamic>)
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
