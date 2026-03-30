import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Nested Models
// ═══════════════════════════════════════════════════════════════════════════

/// Department reference embedded in an employee record.
class EmployeeDepartment extends Equatable {
  final int id;
  final String name;

  const EmployeeDepartment({
    required this.id,
    required this.name,
  });

  factory EmployeeDepartment.fromJson(Map<String, dynamic> json) {
    return EmployeeDepartment(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  List<Object?> get props => [id, name];
}

/// Attendance summary for an employee detail view.
class AttendanceSummaryData extends Equatable {
  final String month;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int leaveDays;
  final double totalWorkedHours;
  final int totalOvertimeMinutes;

  const AttendanceSummaryData({
    required this.month,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.leaveDays,
    required this.totalWorkedHours,
    required this.totalOvertimeMinutes,
  });

  factory AttendanceSummaryData.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryData(
      month: json['month'] as String,
      presentDays: json['present_days'] as int,
      absentDays: json['absent_days'] as int,
      lateDays: json['late_days'] as int,
      leaveDays: json['leave_days'] as int,
      totalWorkedHours: (json['total_worked_hours'] as num).toDouble(),
      totalOvertimeMinutes: json['total_overtime_minutes'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'present_days': presentDays,
        'absent_days': absentDays,
        'late_days': lateDays,
        'leave_days': leaveDays,
        'total_worked_hours': totalWorkedHours,
        'total_overtime_minutes': totalOvertimeMinutes,
      };

  @override
  List<Object?> get props => [
        month,
        presentDays,
        absentDays,
        lateDays,
        leaveDays,
        totalWorkedHours,
        totalOvertimeMinutes,
      ];
}

/// Leave summary for an employee detail view.
class LeaveSummaryData extends Equatable {
  final int year;
  final int annualTotal;
  final int annualUsed;
  final int annualAvailable;
  final int sickTotal;
  final int sickUsed;
  final int sickAvailable;
  final int pendingRequests;

  const LeaveSummaryData({
    required this.year,
    required this.annualTotal,
    required this.annualUsed,
    required this.annualAvailable,
    required this.sickTotal,
    required this.sickUsed,
    required this.sickAvailable,
    required this.pendingRequests,
  });

  factory LeaveSummaryData.fromJson(Map<String, dynamic> json) {
    return LeaveSummaryData(
      year: json['year'] as int,
      annualTotal: json['annual_total'] as int,
      annualUsed: json['annual_used'] as int,
      annualAvailable: json['annual_available'] as int,
      sickTotal: json['sick_total'] as int,
      sickUsed: json['sick_used'] as int,
      sickAvailable: json['sick_available'] as int,
      pendingRequests: json['pending_requests'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'annual_total': annualTotal,
        'annual_used': annualUsed,
        'annual_available': annualAvailable,
        'sick_total': sickTotal,
        'sick_used': sickUsed,
        'sick_available': sickAvailable,
        'pending_requests': pendingRequests,
      };

  @override
  List<Object?> get props => [
        year,
        annualTotal,
        annualUsed,
        annualAvailable,
        sickTotal,
        sickUsed,
        sickAvailable,
        pendingRequests,
      ];
}

// ═══════════════════════════════════════════════════════════════════════════
// Core Models (API K1-K2)
// ═══════════════════════════════════════════════════════════════════════════

/// Employee record in the admin employees list (API K1).
class AdminEmployee extends Equatable {
  final int id;
  final String code;
  final String name;
  final String? nameEn;
  final String? jobTitle;
  final EmployeeDepartment? department;
  final String? mobile;
  final String? email;
  final String employmentStatus;
  final String? attendanceStatus;
  final String? initials;
  final String? hireDate;
  final int pendingRequests;
  final int activeTasks;

  const AdminEmployee({
    required this.id,
    required this.code,
    required this.name,
    this.nameEn,
    this.jobTitle,
    this.department,
    this.mobile,
    this.email,
    required this.employmentStatus,
    this.attendanceStatus,
    this.initials,
    this.hireDate,
    required this.pendingRequests,
    required this.activeTasks,
  });

  factory AdminEmployee.fromJson(Map<String, dynamic> json) {
    return AdminEmployee(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      jobTitle: json['job_title'] as String?,
      department: json['department'] != null
          ? EmployeeDepartment.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      employmentStatus: (json['employment_status'] ?? json['status'] ?? '') as String,
      attendanceStatus: json['attendance_status'] as String?,
      initials: json['initials'] as String?,
      hireDate: json['hire_date'] as String?,
      pendingRequests: (json['pending_requests'] ?? 0) as int,
      activeTasks: (json['active_tasks'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'name_en': nameEn,
        'job_title': jobTitle,
        'department': department?.toJson(),
        'mobile': mobile,
        'email': email,
        'employment_status': employmentStatus,
        'attendance_status': attendanceStatus,
        'initials': initials,
        'hire_date': hireDate,
        'pending_requests': pendingRequests,
        'active_tasks': activeTasks,
      };

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        nameEn,
        jobTitle,
        department,
        mobile,
        email,
        employmentStatus,
        attendanceStatus,
        initials,
        hireDate,
        pendingRequests,
        activeTasks,
      ];
}

/// Detailed employee record returned by GET /admin/employees/{id} (API K2).
class EmployeeDetail extends AdminEmployee {
  final String? phone;
  final String? address;
  final String? photoUrl;
  final String? gender;
  final String? nationality;
  final String? dateOfBirth;
  final String? idNumber;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? manager;
  final String? company;
  final AttendanceSummaryData? attendanceSummary;
  final LeaveSummaryData? leaveSummary;

  const EmployeeDetail({
    required super.id,
    required super.code,
    required super.name,
    super.nameEn,
    super.jobTitle,
    super.department,
    super.mobile,
    super.email,
    required super.employmentStatus,
    super.attendanceStatus,
    super.initials,
    super.hireDate,
    required super.pendingRequests,
    required super.activeTasks,
    this.phone,
    this.address,
    this.photoUrl,
    this.gender,
    this.nationality,
    this.dateOfBirth,
    this.idNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.manager,
    this.company,
    this.attendanceSummary,
    this.leaveSummary,
  });

  factory EmployeeDetail.fromJson(Map<String, dynamic> json) {
    return EmployeeDetail(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      jobTitle: json['job_title'] as String?,
      department: json['department'] != null
          ? EmployeeDepartment.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      employmentStatus: (json['employment_status'] ?? json['status'] ?? '') as String,
      attendanceStatus: json['attendance_status'] as String?,
      initials: json['initials'] as String?,
      hireDate: json['hire_date'] as String?,
      pendingRequests: (json['pending_requests'] ?? 0) as int,
      activeTasks: (json['active_tasks'] ?? 0) as int,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      photoUrl: json['photo_url'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      idNumber: json['id_number'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      manager: json['manager'] is Map
          ? (json['manager'] as Map<String, dynamic>)['name'] as String?
          : json['manager'] as String?,
      company: json['company'] as String?,
      attendanceSummary: json['attendance_summary'] != null
          ? AttendanceSummaryData.fromJson(
              json['attendance_summary'] as Map<String, dynamic>)
          : null,
      leaveSummary: json['leave_summary'] != null
          ? LeaveSummaryData.fromJson(
              json['leave_summary'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'phone': phone,
        'address': address,
        'photo_url': photoUrl,
        'gender': gender,
        'nationality': nationality,
        'date_of_birth': dateOfBirth,
        'id_number': idNumber,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'manager': manager,
        'company': company,
        'attendance_summary': attendanceSummary?.toJson(),
        'leave_summary': leaveSummary?.toJson(),
      };

  @override
  List<Object?> get props => [
        ...super.props,
        phone,
        address,
        photoUrl,
        gender,
        nationality,
        dateOfBirth,
        idNumber,
        emergencyContactName,
        emergencyContactPhone,
        manager,
        company,
        attendanceSummary,
        leaveSummary,
      ];
}

/// Data payload returned by GET /admin/employees (API K1).
class AdminEmployeesData extends Equatable {
  final List<AdminEmployee> employees;
  final Pagination pagination;

  const AdminEmployeesData({
    required this.employees,
    required this.pagination,
  });

  factory AdminEmployeesData.fromJson(Map<String, dynamic> json) {
    return AdminEmployeesData(
      employees: (json['employees'] as List<dynamic>)
          .map((e) => AdminEmployee.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromParent(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'employees': employees.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };

  @override
  List<Object?> get props => [employees, pagination];
}
