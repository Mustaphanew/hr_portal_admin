import 'package:equatable/equatable.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Dashboard Models (API J1)
// ═══════════════════════════════════════════════════════════════════════════

/// Key performance indicators shown on the admin dashboard.
class DashboardKpis extends Equatable {
  final int totalEmployees;
  final int presentToday;
  final int absentToday;
  final int onLeaveToday;
  final int lateToday;
  final int pendingRequests;
  final int pendingLeaves;
  final int overdueTasks;
  final double attendanceRate;

  const DashboardKpis({
    required this.totalEmployees,
    required this.presentToday,
    required this.absentToday,
    required this.onLeaveToday,
    required this.lateToday,
    required this.pendingRequests,
    required this.pendingLeaves,
    required this.overdueTasks,
    required this.attendanceRate,
  });

  factory DashboardKpis.fromJson(Map<String, dynamic> json) {
    final total = (json['total_employees'] ?? 0) as int;
    final present = (json['present_today'] ?? 0) as int;
    return DashboardKpis(
      totalEmployees: total,
      presentToday: present,
      absentToday: (json['absent_today'] ?? 0) as int,
      onLeaveToday: (json['on_leave'] ?? json['on_leave_today'] ?? 0) as int,
      lateToday: (json['late_today'] ?? 0) as int,
      pendingRequests: (json['pending_requests'] ?? 0) as int,
      pendingLeaves: (json['pending_leaves'] ?? 0) as int,
      overdueTasks: (json['overdue_tasks'] ?? 0) as int,
      attendanceRate: json['attendance_rate'] != null
          ? (json['attendance_rate'] as num).toDouble()
          : (total > 0 ? (present / total * 100) : 0.0),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_employees': totalEmployees,
        'present_today': presentToday,
        'absent_today': absentToday,
        'on_leave_today': onLeaveToday,
        'late_today': lateToday,
        'pending_requests': pendingRequests,
        'pending_leaves': pendingLeaves,
        'overdue_tasks': overdueTasks,
        'attendance_rate': attendanceRate,
      };

  @override
  List<Object?> get props => [
        totalEmployees,
        presentToday,
        absentToday,
        onLeaveToday,
        lateToday,
        pendingRequests,
        pendingLeaves,
        overdueTasks,
        attendanceRate,
      ];
}

/// A pending approval item on the dashboard.
class PendingApproval extends Equatable {
  final int id;
  final String type;
  final String employeeName;
  final String employeeCode;
  final String subject;
  final String createdAt;

  const PendingApproval({
    required this.id,
    required this.type,
    required this.employeeName,
    required this.employeeCode,
    required this.subject,
    required this.createdAt,
  });

  factory PendingApproval.fromJson(Map<String, dynamic> json) {
    return PendingApproval(
      id: json['id'] as int,
      type: (json['request_type'] ?? json['type'] ?? '') as String,
      employeeName: json['employee_name'] as String,
      employeeCode: (json['employee_code'] ?? '') as String,
      subject: (json['subject'] ?? '') as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'employee_name': employeeName,
        'employee_code': employeeCode,
        'subject': subject,
        'created_at': createdAt,
      };

  @override
  List<Object?> get props => [id, type, employeeName, employeeCode, subject, createdAt];
}

/// A recent activity entry on the dashboard.
class RecentActivity extends Equatable {
  final String type;
  final String description;
  final String employee;
  final String time;

  const RecentActivity({
    required this.type,
    required this.description,
    required this.employee,
    required this.time,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] as String,
      description: json['description'] as String,
      employee: json['employee'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'description': description,
        'employee': employee,
        'time': time,
      };

  @override
  List<Object?> get props => [type, description, employee, time];
}

/// Department-level summary on the dashboard.
class DepartmentSummary extends Equatable {
  final int id;
  final String name;
  final int employeeCount;
  final int present;
  final int absent;
  final int onLeave;
  final int pendingRequests;

  const DepartmentSummary({
    required this.id,
    required this.name,
    required this.employeeCount,
    required this.present,
    required this.absent,
    required this.onLeave,
    required this.pendingRequests,
  });

  factory DepartmentSummary.fromJson(Map<String, dynamic> json) {
    return DepartmentSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      employeeCount: (json['employee_count'] ?? 0) as int,
      present: (json['present_count'] ?? json['present'] ?? 0) as int,
      absent: (json['absent'] ?? 0) as int,
      onLeave: (json['on_leave'] ?? 0) as int,
      pendingRequests: (json['pending_requests'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'employee_count': employeeCount,
        'present': present,
        'absent': absent,
        'on_leave': onLeave,
        'pending_requests': pendingRequests,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        employeeCount,
        present,
        absent,
        onLeave,
        pendingRequests,
      ];
}

/// Data payload returned by GET /admin/dashboard (API J1).
class DashboardData extends Equatable {
  final DashboardKpis kpis;
  final List<PendingApproval> pendingApprovals;
  final List<RecentActivity> recentActivity;
  final List<DepartmentSummary> departmentSummary;

  const DashboardData({
    required this.kpis,
    required this.pendingApprovals,
    required this.recentActivity,
    required this.departmentSummary,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      kpis: DashboardKpis.fromJson(json['kpis'] as Map<String, dynamic>),
      pendingApprovals: ((json['pending_requests'] ?? json['pending_approvals'] ?? []) as List<dynamic>)
          .map((e) => PendingApproval.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivity: ((json['recent_activity'] ?? []) as List<dynamic>)
          .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      departmentSummary: ((json['departments_summary'] ?? json['department_summary'] ?? []) as List<dynamic>)
          .map((e) => DepartmentSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'kpis': kpis.toJson(),
        'pending_approvals':
            pendingApprovals.map((e) => e.toJson()).toList(),
        'recent_activity':
            recentActivity.map((e) => e.toJson()).toList(),
        'department_summary':
            departmentSummary.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        kpis,
        pendingApprovals,
        recentActivity,
        departmentSummary,
      ];
}
