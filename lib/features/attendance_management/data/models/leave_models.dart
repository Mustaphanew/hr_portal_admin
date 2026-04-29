import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ── LeaveType ────────────────────────────────────────────────────────────────

/// Definition of a leave type (vacation, sick, etc.).
class LeaveType extends Equatable {
  final int id;
  final String code;
  final String name;
  final String? nameEn;
  final String? color;
  final bool isPaid;
  final bool? allowsHalfDay;
  final bool? allowsHourly;
  final bool? requiresAttachment;
  final int? minNoticeDays;
  final int? maxConsecutiveDays;

  const LeaveType({
    required this.id,
    required this.code,
    required this.name,
    this.nameEn,
    this.color,
    required this.isPaid,
    this.allowsHalfDay,
    this.allowsHourly,
    this.requiresAttachment,
    this.minNoticeDays,
    this.maxConsecutiveDays,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: (json['code'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      nameEn: json['name_en'] as String?,
      color: json['color'] as String?,
      isPaid: (json['is_paid'] ?? false) as bool,
      allowsHalfDay: json['allows_half_day'] as bool?,
      allowsHourly: json['allows_hourly'] as bool?,
      requiresAttachment: json['requires_attachment'] as bool?,
      minNoticeDays: json['min_notice_days'] as int?,
      maxConsecutiveDays: json['max_consecutive_days'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'name_en': nameEn,
        'color': color,
        'is_paid': isPaid,
        'allows_half_day': allowsHalfDay,
        'allows_hourly': allowsHourly,
        'requires_attachment': requiresAttachment,
        'min_notice_days': minNoticeDays,
        'max_consecutive_days': maxConsecutiveDays,
      };

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        nameEn,
        color,
        isPaid,
        allowsHalfDay,
        allowsHourly,
        requiresAttachment,
        minNoticeDays,
        maxConsecutiveDays,
      ];
}

// ── LeaveBalance ─────────────────────────────────────────────────────────────

/// Employee's leave balance for a specific leave type and year.
class LeaveBalance extends Equatable {
  final int id;
  final int year;
  final LeaveType leaveType;
  final double totalEntitlement;
  final double used;
  final double pending;
  final double available;
  final double carriedForward;

  const LeaveBalance({
    required this.id,
    required this.year,
    required this.leaveType,
    required this.totalEntitlement,
    required this.used,
    required this.pending,
    required this.available,
    required this.carriedForward,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'] as int,
      year: json['year'] as int,
      leaveType: LeaveType.fromJson(json['leave_type'] as Map<String, dynamic>),
      totalEntitlement: (json['total_entitlement'] as num).toDouble(),
      used: (json['used'] as num).toDouble(),
      pending: (json['pending'] as num).toDouble(),
      available: (json['available'] as num).toDouble(),
      carriedForward: (json['carried_forward'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'year': year,
        'leave_type': leaveType.toJson(),
        'total_entitlement': totalEntitlement,
        'used': used,
        'pending': pending,
        'available': available,
        'carried_forward': carriedForward,
      };

  @override
  List<Object?> get props => [
        id,
        year,
        leaveType,
        totalEntitlement,
        used,
        pending,
        available,
        carriedForward,
      ];
}

// ── LeaveDay ─────────────────────────────────────────────────────────────────

/// A single day within a leave request's breakdown.
class LeaveDay extends Equatable {
  final String date;
  final String dayPart;
  final double dayValue;
  final bool isHoliday;
  final bool isWeekend;

  const LeaveDay({
    required this.date,
    required this.dayPart,
    required this.dayValue,
    required this.isHoliday,
    required this.isWeekend,
  });

  factory LeaveDay.fromJson(Map<String, dynamic> json) {
    return LeaveDay(
      date: json['date'] as String,
      dayPart: json['day_part'] as String,
      dayValue: (json['day_value'] as num).toDouble(),
      isHoliday: json['is_holiday'] as bool,
      isWeekend: json['is_weekend'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'day_part': dayPart,
        'day_value': dayValue,
        'is_holiday': isHoliday,
        'is_weekend': isWeekend,
      };

  @override
  List<Object?> get props => [date, dayPart, dayValue, isHoliday, isWeekend];
}

// ── LeaveEmployee ────────────────────────────────────────────────────────────

/// Lightweight employee reference embedded in manager-view leave requests.
class LeaveEmployee extends Equatable {
  final int id;
  final String name;
  final String code;
  final String? jobTitle;

  const LeaveEmployee({
    required this.id,
    required this.name,
    required this.code,
    this.jobTitle,
  });

  factory LeaveEmployee.fromJson(Map<String, dynamic> json) {
    return LeaveEmployee(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      jobTitle: json['job_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'job_title': jobTitle,
      };

  @override
  List<Object?> get props => [id, name, code, jobTitle];
}

// ── LeaveCompany ────────────────────────────────────────────────────────────

class LeaveCompany extends Equatable {
  final int id;
  final String? name;
  final String? nameEn;

  const LeaveCompany({required this.id, this.name, this.nameEn});

  factory LeaveCompany.fromJson(Map<String, dynamic> json) => LeaveCompany(
    id: json['id'] as int,
    name: json['name'] as String?,
    nameEn: json['name_en'] as String?,
  );

  @override
  List<Object?> get props => [id, name, nameEn];
}

// ── LeaveBranch ─────────────────────────────────────────────────────────────

class LeaveBranch extends Equatable {
  final int id;
  final String? name;
  final String? nameEn;

  const LeaveBranch({required this.id, this.name, this.nameEn});

  factory LeaveBranch.fromJson(Map<String, dynamic> json) => LeaveBranch(
    id: json['id'] as int,
    name: json['name'] as String?,
    nameEn: json['name_en'] as String?,
  );

  @override
  List<Object?> get props => [id, name, nameEn];
}

// ── LeaveApprover ───────────────────────────────────────────────────────────

class LeaveApprover extends Equatable {
  final int id;
  final String name;
  final String? code;
  final String? jobTitle;
  final int? approvalLevel;
  final String? decision;
  final String? decidedAt;
  final String? notes;

  const LeaveApprover({
    required this.id,
    required this.name,
    this.code,
    this.jobTitle,
    this.approvalLevel,
    this.decision,
    this.decidedAt,
    this.notes,
  });

  factory LeaveApprover.fromJson(Map<String, dynamic> json) => LeaveApprover(
    id: json['id'] as int,
    name: (json['name'] as String?) ?? '',
    code: json['code'] as String?,
    jobTitle: json['job_title'] as String?,
    approvalLevel: (json['approval_level'] as num?)?.toInt(),
    decision: json['decision'] as String?,
    decidedAt: json['decided_at'] as String?,
    notes: json['notes'] as String?,
  );

  @override
  List<Object?> get props => [id, name, decision, decidedAt];
}

// ── LeaveApprovalHistory ────────────────────────────────────────────────────

class LeaveApprovalHistory extends Equatable {
  final int id;
  final LeaveApprover approver;
  final int approvalLevel;
  final String decision;
  final String? decidedAt;
  final String? notes;
  final bool isCurrent;

  const LeaveApprovalHistory({
    required this.id,
    required this.approver,
    required this.approvalLevel,
    required this.decision,
    this.decidedAt,
    this.notes,
    required this.isCurrent,
  });

  factory LeaveApprovalHistory.fromJson(Map<String, dynamic> json) {
    final approverJson = json['approver'];
    return LeaveApprovalHistory(
      id: json['id'] as int,
      approver: approverJson is Map<String, dynamic>
        ? LeaveApprover.fromJson(approverJson)
        : LeaveApprover(id: 0, name: ''),
      approvalLevel: (json['approval_level'] as num?)?.toInt() ?? 1,
      decision: json['decision'] as String? ?? 'pending',
      decidedAt: json['decided_at'] as String?,
      notes: json['notes'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, approvalLevel, decision, isCurrent];
}

// ── LeaveRequest ─────────────────────────────────────────────────────────────

/// A single leave request (employee or admin view).
class LeaveRequest extends Equatable {
  final int id;
  final String requestNumber;
  final LeaveType leaveType;
  final String startDate;
  final String endDate;
  final double totalDays;
  final String dayPart;
  final String? reason;
  final String status;
  final String? rejectionReason;
  final int? approvedBy;
  final String? approvedAt;
  final String createdAt;

  /// Employee info (admin view).
  final LeaveEmployee? employee;

  /// Company info (admin view).
  final LeaveCompany? company;

  /// Branch info (admin view).
  final LeaveBranch? branch;

  /// Current approver info (admin view).
  final LeaveApprover? approver;

  /// Approval history (detail view).
  final List<LeaveApprovalHistory>? approvalHistory;

  /// Day-by-day breakdown of the leave period.
  final List<LeaveDay>? days;

  /// Whether the current admin can approve/reject this leave.
  final bool? canDecide;

  const LeaveRequest({
    required this.id,
    required this.requestNumber,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.dayPart,
    this.reason,
    required this.status,
    this.rejectionReason,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    this.employee,
    this.company,
    this.branch,
    this.approver,
    this.approvalHistory,
    this.days,
    this.canDecide,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'];
    List<LeaveDay>? days;
    if (rawDays is List && rawDays.isNotEmpty) {
      days = rawDays.map((e) => LeaveDay.fromJson(e as Map<String, dynamic>)).toList();
    }

    final rawHistory = json['approval_history'];
    List<LeaveApprovalHistory>? history;
    if (rawHistory is List && rawHistory.isNotEmpty) {
      history = rawHistory.map((e) => LeaveApprovalHistory.fromJson(e as Map<String, dynamic>)).toList();
    }

    return LeaveRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      requestNumber: (json['request_number'] ?? '') as String,
      leaveType: LeaveType.fromJson(json['leave_type'] as Map<String, dynamic>),
      startDate: (json['start_date'] ?? '') as String,
      endDate: (json['end_date'] ?? '') as String,
      totalDays: (json['total_days'] as num?)?.toDouble() ?? 0.0,
      dayPart: (json['day_part'] ?? 'full') as String,
      reason: json['reason'] as String?,
      status: (json['status'] ?? 'pending') as String,
      rejectionReason: json['rejection_reason'] as String?,
      approvedBy: (json['approved_by'] as num?)?.toInt(),
      approvedAt: json['approved_at'] as String?,
      createdAt: (json['created_at'] ?? '') as String,
      employee: json['employee'] is Map
          ? LeaveEmployee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      company: json['company'] is Map
          ? LeaveCompany.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      branch: json['branch'] is Map
          ? LeaveBranch.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      approver: json['approver'] is Map
          ? LeaveApprover.fromJson(json['approver'] as Map<String, dynamic>)
          : null,
      approvalHistory: history,
      days: days,
      canDecide: json['can_decide'] as bool?,
    );
  }

  @override
  List<Object?> get props => [id, requestNumber, status, createdAt];
}

// ── LeavesListData ───────────────────────────────────────────────────────────

/// Wrapper for the employee leaves endpoint (C1) which returns
/// balances, requests, leave types, and pagination.
class LeavesListData extends Equatable {
  final List<LeaveBalance>? balances;
  final List<LeaveRequest> requests;
  final List<LeaveType>? leaveTypes;
  final Pagination? pagination;

  const LeavesListData({
    this.balances,
    required this.requests,
    this.leaveTypes,
    this.pagination,
  });

  factory LeavesListData.fromJson(Map<String, dynamic> json) {
    return LeavesListData(
      balances: json['balances'] != null
          ? (json['balances'] as List<dynamic>)
              .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      requests: (json['requests'] as List<dynamic>)
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      leaveTypes: json['leave_types'] != null
          ? (json['leave_types'] as List<dynamic>)
              .map((e) => LeaveType.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pagination: (json['meta'] ?? json['pagination']) != null
          ? Pagination.fromParent(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [balances, requests, leaveTypes, pagination];
}

// ── ManagerLeavesData ────────────────────────────────────────────────────────

/// Wrapper for the admin leave requests endpoint.
class ManagerLeavesData extends Equatable {
  final List<LeaveRequest> leaves;
  final Pagination? pagination;

  const ManagerLeavesData({
    required this.leaves,
    this.pagination,
  });

  factory ManagerLeavesData.fromJson(Map<String, dynamic> json) {
    // Support both 'leave_requests' (new API) and 'leaves' (old API)
    final list = json['leave_requests'] ?? json['leaves'];
    return ManagerLeavesData(
      leaves: (list as List<dynamic>)
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: (json['pagination'] ?? json['meta']) != null
          ? Pagination.fromParent(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [leaves, pagination];
}

// ── LeaveRequestsSummary ─────────────────────────────────────────────────────

/// Summary KPIs returned by GET /admin/leave-requests/summary (Postman 02).
class LeaveRequestsSummary extends Equatable {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int? cancelled;
  final int? totalDays;

  const LeaveRequestsSummary({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    this.cancelled,
    this.totalDays,
  });

  factory LeaveRequestsSummary.fromJson(Map<String, dynamic> json) {
    return LeaveRequestsSummary(
      total: (json['total'] ?? 0) as int,
      pending: (json['pending'] ?? 0) as int,
      approved: (json['approved'] ?? 0) as int,
      rejected: (json['rejected'] ?? 0) as int,
      cancelled: json['cancelled'] as int?,
      totalDays: (json['total_days'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [total, pending, approved, rejected, cancelled, totalDays];
}
