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
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  List<Object?> get props => [id, name];
}

/// Company reference embedded in an employee record.
/// Captured from real /admin/employees response 2026-04-29.
class EmployeeCompany extends Equatable {
  final int id;
  final String name;
  final String? nameEn;

  const EmployeeCompany({
    required this.id,
    required this.name,
    this.nameEn,
  });

  factory EmployeeCompany.fromJson(Map<String, dynamic> json) {
    return EmployeeCompany(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      nameEn: json['name_en'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
      };

  @override
  List<Object?> get props => [id, name, nameEn];
}

/// Branch reference embedded in an employee record.
class EmployeeBranch extends Equatable {
  final int id;
  final String name;

  const EmployeeBranch({required this.id, required this.name});

  factory EmployeeBranch.fromJson(Map<String, dynamic> json) {
    return EmployeeBranch(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
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
  final EmployeeCompany? company;
  final EmployeeBranch? branch;
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
    this.company,
    this.branch,
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
      id: (json['id'] as num).toInt(),
      code: (json['employee_number'] ?? json['code'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      nameEn: json['name_en'] as String?,
      jobTitle: json['job_title'] as String?,
      department: json['department'] is Map<String, dynamic>
          ? EmployeeDepartment.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      company: json['company'] is Map<String, dynamic>
          ? EmployeeCompany.fromJson(
              json['company'] as Map<String, dynamic>)
          : null,
      branch: json['branch'] is Map<String, dynamic>
          ? EmployeeBranch.fromJson(
              json['branch'] as Map<String, dynamic>)
          : null,
      mobile: json['mobile']?.toString(),
      email: json['email'] as String?,
      employmentStatus: (json['employment_status'] ?? json['status'] ?? '').toString(),
      attendanceStatus: json['attendance_status'] as String?,
      initials: json['initials'] as String?,
      hireDate: json['hire_date'] as String?,
      pendingRequests: (json['pending_requests'] as num?)?.toInt() ?? 0,
      activeTasks: (json['active_tasks'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'name_en': nameEn,
        'job_title': jobTitle,
        'department': department?.toJson(),
        'company': company?.toJson(),
        'branch': branch?.toJson(),
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
        company,
        branch,
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
  /// Legacy string form of the company name (when API returns a plain string
  /// rather than the structured `EmployeeCompany`). Use [company] (from the
  /// parent class) for the structured form.
  final String? companyLabel;
  final AttendanceSummaryData? attendanceSummary;
  final LeaveSummaryData? leaveSummary;

  const EmployeeDetail({
    required super.id,
    required super.code,
    required super.name,
    super.nameEn,
    super.jobTitle,
    super.department,
    super.company,
    super.branch,
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
    this.companyLabel,
    this.attendanceSummary,
    this.leaveSummary,
  });

  factory EmployeeDetail.fromJson(Map<String, dynamic> json) {
    // The detail endpoint may return `company` as a string OR an object —
    // accept both for backwards compatibility.
    String? companyLabel;
    EmployeeCompany? companyObj;
    final rawCompany = json['company'];
    if (rawCompany is Map<String, dynamic>) {
      companyObj = EmployeeCompany.fromJson(rawCompany);
      companyLabel = companyObj.name;
    } else if (rawCompany is String) {
      companyLabel = rawCompany;
    }

    return EmployeeDetail(
      id: (json['id'] as num).toInt(),
      code: (json['employee_number'] ?? json['code'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      nameEn: json['name_en'] as String?,
      jobTitle: json['job_title'] as String?,
      department: json['department'] is Map<String, dynamic>
          ? EmployeeDepartment.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      company: companyObj,
      branch: json['branch'] is Map<String, dynamic>
          ? EmployeeBranch.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      mobile: json['mobile']?.toString(),
      email: json['email'] as String?,
      employmentStatus:
          (json['employment_status'] ?? json['status'] ?? '').toString(),
      attendanceStatus: json['attendance_status'] as String?,
      initials: json['initials'] as String?,
      hireDate: json['hire_date'] as String?,
      pendingRequests: (json['pending_requests'] as num?)?.toInt() ?? 0,
      activeTasks: (json['active_tasks'] as num?)?.toInt() ?? 0,
      phone: json['phone']?.toString(),
      address: json['address'] as String?,
      photoUrl: json['photo_url'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      idNumber: json['id_number']?.toString(),
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone']?.toString(),
      manager: json['manager'] is Map
          ? (json['manager'] as Map<String, dynamic>)['name'] as String?
          : json['manager'] as String?,
      companyLabel: companyLabel,
      attendanceSummary: json['attendance_summary'] is Map<String, dynamic>
          ? AttendanceSummaryData.fromJson(
              json['attendance_summary'] as Map<String, dynamic>)
          : null,
      leaveSummary: json['leave_summary'] is Map<String, dynamic>
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
        // 'company' (structured) is already serialised by super.toJson().
        // companyLabel is the legacy plain-string form.
        if (companyLabel != null) 'company_label': companyLabel,
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
        companyLabel,
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
