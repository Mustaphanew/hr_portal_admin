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
class AdminAttendanceRecord extends Equatable {
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String department;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final double workedHours;
  final String status;
  final int lateMinutes;
  final int overtimeMinutes;

  const AdminAttendanceRecord({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.department,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.workedHours,
    required this.status,
    required this.lateMinutes,
    required this.overtimeMinutes,
  });

  factory AdminAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceRecord(
      employeeId: (json['employee_id'] ?? 0) as int,
      employeeName: (json['employee_name'] ?? '') as String,
      employeeCode: (json['employee_code'] ?? '') as String,
      department: (json['department'] ?? '') as String,
      date: (json['date'] ?? '') as String,
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      workedHours: (json['worked_hours'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? 'absent') as String,
      lateMinutes: (json['late_minutes'] ?? 0) as int,
      overtimeMinutes: (json['overtime_minutes'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'employee_id': employeeId,
        'employee_name': employeeName,
        'employee_code': employeeCode,
        'department': department,
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
        employeeId,
        employeeName,
        employeeCode,
        department,
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
class AdminAttendanceData extends Equatable {
  final String date;
  final AdminAttendanceSummary summary;
  final List<AdminAttendanceRecord> records;
  final Pagination pagination;

  const AdminAttendanceData({
    required this.date,
    required this.summary,
    required this.records,
    required this.pagination,
  });

  factory AdminAttendanceData.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceData(
      date: json['date'] as String,
      summary: AdminAttendanceSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
      records: (json['records'] as List<dynamic>)
          .map((e) =>
              AdminAttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromParent(json),
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
