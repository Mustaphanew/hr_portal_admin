import 'package:equatable/equatable.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Department Models (API L1-L2)
// ═══════════════════════════════════════════════════════════════════════════

/// Head of a department.
class DepartmentHead extends Equatable {
  final int id;
  final String name;
  final String jobTitle;

  const DepartmentHead({
    required this.id,
    required this.name,
    required this.jobTitle,
  });

  factory DepartmentHead.fromJson(Map<String, dynamic> json) {
    return DepartmentHead(
      id: json['id'] as int,
      name: json['name'] as String,
      jobTitle: json['job_title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'job_title': jobTitle,
      };

  @override
  List<Object?> get props => [id, name, jobTitle];
}

/// Department record in the admin departments list (API L1).
class AdminDepartment extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final DepartmentHead? head;
  final int employeeCount;
  final int pendingRequests;
  final int activeTasks;
  final int attendanceIssues;
  final double? performanceScore;

  const AdminDepartment({
    required this.id,
    required this.name,
    this.nameEn,
    this.head,
    required this.employeeCount,
    required this.pendingRequests,
    required this.activeTasks,
    required this.attendanceIssues,
    this.performanceScore,
  });

  factory AdminDepartment.fromJson(Map<String, dynamic> json) {
    return AdminDepartment(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      head: json['head'] != null
          ? DepartmentHead.fromJson(json['head'] as Map<String, dynamic>)
          : null,
      employeeCount: (json['employee_count'] as num?)?.toInt() ?? 0,
      pendingRequests: (json['pending_requests'] as num?)?.toInt() ?? 0,
      activeTasks: (json['active_tasks'] as num?)?.toInt() ?? 0,
      attendanceIssues: (json['attendance_issues'] as num?)?.toInt() ?? 0,
      performanceScore: json['performance_score'] != null
          ? (json['performance_score'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
        'head': head?.toJson(),
        'employee_count': employeeCount,
        'pending_requests': pendingRequests,
        'active_tasks': activeTasks,
        'attendance_issues': attendanceIssues,
        'performance_score': performanceScore,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        nameEn,
        head,
        employeeCount,
        pendingRequests,
        activeTasks,
        attendanceIssues,
        performanceScore,
      ];
}

/// Employee entry within a department detail view.
class DepartmentEmployee extends Equatable {
  final int id;
  final String code;
  final String name;
  final String? jobTitle;
  final String? attendanceStatus;

  const DepartmentEmployee({
    required this.id,
    required this.code,
    required this.name,
    this.jobTitle,
    this.attendanceStatus,
  });

  factory DepartmentEmployee.fromJson(Map<String, dynamic> json) {
    return DepartmentEmployee(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: (json['code'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      jobTitle: json['job_title'] as String?,
      attendanceStatus: json['attendance_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'job_title': jobTitle,
        'attendance_status': attendanceStatus,
      };

  @override
  List<Object?> get props => [id, code, name, jobTitle, attendanceStatus];
}

/// Department-level stats for the detail view.
class DepartmentStats extends Equatable {
  final int presentToday;
  final int absentToday;
  final int onLeaveToday;
  final int pendingRequests;
  final int activeTasks;

  const DepartmentStats({
    required this.presentToday,
    required this.absentToday,
    required this.onLeaveToday,
    required this.pendingRequests,
    required this.activeTasks,
  });

  factory DepartmentStats.fromJson(Map<String, dynamic> json) {
    return DepartmentStats(
      presentToday: (json['present_today'] as num?)?.toInt() ?? 0,
      absentToday: (json['absent_today'] as num?)?.toInt() ?? 0,
      onLeaveToday: (json['on_leave_today'] as num?)?.toInt() ?? 0,
      pendingRequests: (json['pending_requests'] as num?)?.toInt() ?? 0,
      activeTasks: (json['active_tasks'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'present_today': presentToday,
        'absent_today': absentToday,
        'on_leave_today': onLeaveToday,
        'pending_requests': pendingRequests,
        'active_tasks': activeTasks,
      };

  @override
  List<Object?> get props => [
        presentToday,
        absentToday,
        onLeaveToday,
        pendingRequests,
        activeTasks,
      ];
}

/// Detailed department record returned by GET /admin/departments/{id} (API L2).
class DepartmentDetail extends AdminDepartment {
  final List<DepartmentEmployee> employees;
  final DepartmentStats stats;

  const DepartmentDetail({
    required super.id,
    required super.name,
    super.nameEn,
    super.head,
    required super.employeeCount,
    required super.pendingRequests,
    required super.activeTasks,
    required super.attendanceIssues,
    super.performanceScore,
    required this.employees,
    required this.stats,
  });

  factory DepartmentDetail.fromJson(Map<String, dynamic> json) {
    return DepartmentDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      head: json['head'] != null
          ? DepartmentHead.fromJson(json['head'] as Map<String, dynamic>)
          : null,
      employeeCount: (json['employee_count'] as num?)?.toInt() ?? 0,
      pendingRequests: (json['pending_requests'] as num?)?.toInt() ?? 0,
      activeTasks: (json['active_tasks'] as num?)?.toInt() ?? 0,
      attendanceIssues: (json['attendance_issues'] as num?)?.toInt() ?? 0,
      performanceScore: json['performance_score'] != null
          ? (json['performance_score'] as num).toDouble()
          : null,
      employees: ((json['employees'] ?? []) as List<dynamic>)
          .map((e) =>
              DepartmentEmployee.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: json['stats'] != null
          ? DepartmentStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const DepartmentStats(presentToday: 0, absentToday: 0, onLeaveToday: 0, pendingRequests: 0, activeTasks: 0),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'employees': employees.map((e) => e.toJson()).toList(),
        'stats': stats.toJson(),
      };

  @override
  List<Object?> get props => [
        ...super.props,
        employees,
        stats,
      ];
}

/// Data payload returned by GET /admin/departments (API L1).
class DepartmentsData extends Equatable {
  final List<AdminDepartment> departments;

  const DepartmentsData({required this.departments});

  factory DepartmentsData.fromJson(Map<String, dynamic> json) {
    return DepartmentsData(
      departments: (json['departments'] as List<dynamic>)
          .map((e) => AdminDepartment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'departments': departments.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [departments];
}
