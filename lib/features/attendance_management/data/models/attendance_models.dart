import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Employee Attendance Models (API G1)
// ═══════════════════════════════════════════════════════════════════════════

/// A single attendance record for the logged-in employee.
class AttendanceRecord extends Equatable {
  final int id;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;
  final double workedHours;
  final int overtimeMinutes;
  final int lateMinutes;
  final int earlyDepartureMinutes;
  final bool isComplete;

  const AttendanceRecord({
    required this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.workedHours,
    required this.overtimeMinutes,
    required this.lateMinutes,
    required this.earlyDepartureMinutes,
    required this.isComplete,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: (json['id'] ?? 0) as int,
      date: (json['date'] ?? '') as String,
      checkInTime: (json['check_in_time'] ?? json['check_in']) as String?,
      checkOutTime: (json['check_out_time'] ?? json['check_out']) as String?,
      status: (json['status'] ?? 'absent') as String,
      workedHours: (json['worked_hours'] as num?)?.toDouble() ?? 0.0,
      overtimeMinutes: (json['overtime_minutes'] ?? 0) as int,
      lateMinutes: (json['late_minutes'] ?? 0) as int,
      earlyDepartureMinutes: (json['early_departure_minutes'] ?? 0) as int,
      isComplete: (json['is_complete'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
        'status': status,
        'worked_hours': workedHours,
        'overtime_minutes': overtimeMinutes,
        'late_minutes': lateMinutes,
        'early_departure_minutes': earlyDepartureMinutes,
        'is_complete': isComplete,
      };

  @override
  List<Object?> get props => [
        id,
        date,
        checkInTime,
        checkOutTime,
        status,
        workedHours,
        overtimeMinutes,
        lateMinutes,
        earlyDepartureMinutes,
        isComplete,
      ];
}

/// Summary statistics for a date range of attendance records.
class AttendanceSummary extends Equatable {
  final double totalWorkedHours;
  final int totalLateDays;
  final int totalAbsentDays;
  final int totalPresentDays;
  final int totalOvertimeMinutes;

  const AttendanceSummary({
    required this.totalWorkedHours,
    required this.totalLateDays,
    required this.totalAbsentDays,
    required this.totalPresentDays,
    required this.totalOvertimeMinutes,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalWorkedHours: (json['total_worked_hours'] as num?)?.toDouble() ?? 0.0,
      totalLateDays: (json['total_late_days'] ?? json['late_days'] ?? 0) as int,
      totalAbsentDays: (json['total_absent_days'] ?? json['absent_days'] ?? 0) as int,
      totalPresentDays: (json['total_present_days'] ?? json['present_days'] ?? 0) as int,
      totalOvertimeMinutes: (json['total_overtime_minutes'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_worked_hours': totalWorkedHours,
        'total_late_days': totalLateDays,
        'total_absent_days': totalAbsentDays,
        'total_present_days': totalPresentDays,
        'total_overtime_minutes': totalOvertimeMinutes,
      };

  @override
  List<Object?> get props => [
        totalWorkedHours,
        totalLateDays,
        totalAbsentDays,
        totalPresentDays,
        totalOvertimeMinutes,
      ];
}

/// Data payload returned by GET /attendance/history (API G1).
class AttendanceHistoryData extends Equatable {
  final List<AttendanceRecord> records;
  final AttendanceSummary summary;
  final Pagination pagination;

  const AttendanceHistoryData({
    required this.records,
    required this.summary,
    required this.pagination,
  });

  factory AttendanceHistoryData.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryData(
      records: (json['records'] as List<dynamic>)
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: AttendanceSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
      pagination:
          Pagination.fromParent(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'records': records.map((e) => e.toJson()).toList(),
        'summary': summary.toJson(),
        'pagination': pagination.toJson(),
      };

  @override
  List<Object?> get props => [records, summary, pagination];
}

// ═══════════════════════════════════════════════════════════════════════════
// Admin Attendance Models (API M1-M2)
// ═══════════════════════════════════════════════════════════════════════════

/// A single attendance record in the admin attendance view.
///
/// Captured 2026-04-29 from real `/admin/attendance` response — the API now
/// returns nested `{employee, department, company, branch}` objects rather
/// than flat keys. Backwards-compatible with the old flat-key shape.
class AdminAttendanceRecord extends Equatable {
  final int? recordId;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final int? departmentId;
  final String department;
  final int? companyId;
  final String? companyName;
  final int? branchId;
  final String? branchName;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final double workedHours;
  final String status;
  final int lateMinutes;
  final int overtimeMinutes;

  const AdminAttendanceRecord({
    this.recordId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    this.departmentId,
    required this.department,
    this.companyId,
    this.companyName,
    this.branchId,
    this.branchName,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.workedHours,
    required this.status,
    required this.lateMinutes,
    required this.overtimeMinutes,
  });

  factory AdminAttendanceRecord.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? asStr(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      return v.toString();
    }

    // Employee may be nested OR flat.
    int empId = 0;
    String empName = '';
    String empCode = '';
    final empRaw = json['employee'];
    if (empRaw is Map<String, dynamic>) {
      empId = asInt(empRaw['id']) ?? 0;
      empName = asStr(empRaw['name']) ?? '';
      empCode = asStr(empRaw['employee_number']) ??
          asStr(empRaw['code']) ??
          '';
    } else {
      empId = asInt(json['employee_id']) ?? 0;
      empName = asStr(json['employee_name']) ?? '';
      empCode = asStr(json['employee_code']) ?? '';
    }

    // Department may be nested OR flat string.
    int? deptId;
    String deptName = '';
    final deptRaw = json['department'];
    if (deptRaw is Map<String, dynamic>) {
      deptId = asInt(deptRaw['id']);
      deptName = asStr(deptRaw['name']) ?? '';
    } else if (deptRaw is String) {
      deptName = deptRaw;
    }

    // Company nested.
    int? compId;
    String? compName;
    final compRaw = json['company'];
    if (compRaw is Map<String, dynamic>) {
      compId = asInt(compRaw['id']);
      compName = asStr(compRaw['name']);
    }

    // Branch nested.
    int? brId;
    String? brName;
    final brRaw = json['branch'];
    if (brRaw is Map<String, dynamic>) {
      brId = asInt(brRaw['id']);
      brName = asStr(brRaw['name']);
    }

    return AdminAttendanceRecord(
      recordId: asInt(json['id']),
      employeeId: empId,
      employeeName: empName,
      employeeCode: empCode,
      departmentId: deptId,
      department: deptName,
      companyId: compId,
      companyName: compName,
      branchId: brId,
      branchName: brName,
      date: asStr(json['date']) ?? '',
      checkIn: asStr(json['check_in']),
      checkOut: asStr(json['check_out']),
      workedHours: (json['worked_hours'] as num?)?.toDouble() ?? 0.0,
      status: asStr(json['status']) ?? 'absent',
      lateMinutes: asInt(json['late_minutes']) ?? 0,
      overtimeMinutes: asInt(json['overtime_minutes']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (recordId != null) 'id': recordId,
        'employee_id': employeeId,
        'employee_name': employeeName,
        'employee_code': employeeCode,
        if (departmentId != null) 'department_id': departmentId,
        'department': department,
        if (companyId != null) 'company_id': companyId,
        if (companyName != null) 'company_name': companyName,
        if (branchId != null) 'branch_id': branchId,
        if (branchName != null) 'branch_name': branchName,
        'date': date,
        'check_in': checkIn,
        'check_out': checkOut,
        'worked_hours': workedHours,
        'status': status,
        'late_minutes': lateMinutes,
        'overtime_minutes': overtimeMinutes,
      };

  @override
  List<Object?> get props => [
        recordId,
        employeeId,
        employeeName,
        employeeCode,
        departmentId,
        department,
        companyId,
        companyName,
        branchId,
        branchName,
        date,
        checkIn,
        checkOut,
        workedHours,
        status,
        lateMinutes,
        overtimeMinutes,
      ];
}

/// Summary counts for admin attendance overview.
class AdminAttendanceSummary extends Equatable {
  final int total;
  final int present;
  final int late;
  final int absent;
  final int onLeave;

  const AdminAttendanceSummary({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.onLeave,
  });

  factory AdminAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceSummary(
      total: (json['total'] ?? 0) as int,
      present: (json['present'] ?? 0) as int,
      late: (json['late'] ?? 0) as int,
      absent: (json['absent'] ?? 0) as int,
      onLeave: (json['on_leave'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'present': present,
        'late': late,
        'absent': absent,
        'on_leave': onLeave,
      };

  @override
  List<Object?> get props => [total, present, late, absent, onLeave];
}

/// Data payload returned by GET /admin/attendance (API M1).
///
/// Real response shape (captured 2026-04-29):
/// `{ summary: {total, present, late, absent}, records: [...], meta: {...} }`
class AdminAttendanceData extends Equatable {
  /// Optional date filter — populated when scoping to a single day.
  final String date;
  final AdminAttendanceSummary summary;
  final List<AdminAttendanceRecord> records;
  final Pagination pagination;

  const AdminAttendanceData({
    this.date = '',
    required this.summary,
    required this.records,
    required this.pagination,
  });

  factory AdminAttendanceData.fromJson(Map<String, dynamic> json) {
    final rawRecords = json['records'];
    final records = (rawRecords is List)
        ? rawRecords
            .whereType<Map<String, dynamic>>()
            .map(AdminAttendanceRecord.fromJson)
            .toList()
        : <AdminAttendanceRecord>[];

    final summaryJson = json['summary'];
    final summary = (summaryJson is Map<String, dynamic>)
        ? AdminAttendanceSummary.fromJson(summaryJson)
        : const AdminAttendanceSummary(
            total: 0, present: 0, late: 0, absent: 0, onLeave: 0);

    return AdminAttendanceData(
      date: (json['date'] as String?) ?? '',
      summary: summary,
      records: records,
      pagination: Pagination.fromParent(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'summary': summary.toJson(),
        'records': records.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };

  @override
  List<Object?> get props => [date, summary, records, pagination];
}

/// Data payload returned by GET /admin/attendance/{id} (API M2).
class EmployeeAttendanceData extends Equatable {
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String department;
  final List<AttendanceRecord> records;
  final AttendanceSummary summary;

  const EmployeeAttendanceData({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.department,
    required this.records,
    required this.summary,
  });

  factory EmployeeAttendanceData.fromJson(Map<String, dynamic> json) {
    final emp = json['employee'];
    return EmployeeAttendanceData(
      employeeId: emp is Map ? (emp['id'] ?? 0) as int : (json['employee_id'] ?? 0) as int,
      employeeName: emp is Map ? (emp['name'] ?? '') as String : (json['employee_name'] ?? '') as String,
      employeeCode: emp is Map ? (emp['code'] ?? '') as String : (json['employee_code'] ?? '') as String,
      department: emp is Map ? (emp['department'] ?? '') as String : (json['department'] ?? '') as String,
      records: (json['records'] as List<dynamic>)
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: AttendanceSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'employee_id': employeeId,
        'employee_name': employeeName,
        'employee_code': employeeCode,
        'department': department,
        'records': records.map((e) => e.toJson()).toList(),
        'summary': summary.toJson(),
      };

  @override
  List<Object?> get props => [
        employeeId,
        employeeName,
        employeeCode,
        department,
        records,
        summary,
      ];
}
