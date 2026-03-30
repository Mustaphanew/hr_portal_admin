import 'package:equatable/equatable.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Report Models (API Q1-Q4)
// ═══════════════════════════════════════════════════════════════════════════

/// A single KPI item in the reports overview (API Q1).
class KpiItem extends Equatable {
  final String label;
  final String? labelEn;
  final double value;
  final double? change;
  final bool isPositive;

  const KpiItem({
    required this.label,
    this.labelEn,
    required this.value,
    this.change,
    required this.isPositive,
  });

  factory KpiItem.fromJson(Map<String, dynamic> json) {
    // value may come as String like "109" or "87.2%" or as num
    final rawValue = json['value'];
    double value;
    if (rawValue is num) {
      value = rawValue.toDouble();
    } else if (rawValue is String) {
      value = double.tryParse(rawValue.replaceAll('%', '').replaceAll(',', '')) ?? 0.0;
    } else {
      value = 0.0;
    }

    return KpiItem(
      label: (json['label'] ?? '') as String,
      labelEn: json['label_en'] as String?,
      value: value,
      change: json['change'] != null
          ? (json['change'] as num).toDouble()
          : null,
      isPositive: (json['is_positive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'label_en': labelEn,
        'value': value,
        'change': change,
        'is_positive': isPositive,
      };

  @override
  List<Object?> get props => [label, labelEn, value, change, isPositive];
}

/// A monthly attendance trend data point (API Q2).
class AttendanceTrendMonth extends Equatable {
  final String month;
  final double attendanceRate;
  final double lateRate;
  final double absentRate;

  const AttendanceTrendMonth({
    required this.month,
    required this.attendanceRate,
    required this.lateRate,
    required this.absentRate,
  });

  factory AttendanceTrendMonth.fromJson(Map<String, dynamic> json) {
    return AttendanceTrendMonth(
      month: (json['month'] ?? '') as String,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 0.0,
      lateRate: (json['late_rate'] as num?)?.toDouble() ?? 0.0,
      absentRate: (json['absent_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'attendance_rate': attendanceRate,
        'late_rate': lateRate,
        'absent_rate': absentRate,
      };

  @override
  List<Object?> get props => [month, attendanceRate, lateRate, absentRate];
}

/// Leave analysis grouped by leave type (API Q3).
class LeaveAnalysisType extends Equatable {
  final String type;
  final String? typeEn;
  final int count;
  final int totalDays;

  const LeaveAnalysisType({
    required this.type,
    this.typeEn,
    required this.count,
    required this.totalDays,
  });

  factory LeaveAnalysisType.fromJson(Map<String, dynamic> json) {
    return LeaveAnalysisType(
      type: (json['type'] ?? '') as String,
      typeEn: json['type_en'] as String?,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalDays: (json['total_days'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'type_en': typeEn,
        'count': count,
        'total_days': totalDays,
      };

  @override
  List<Object?> get props => [type, typeEn, count, totalDays];
}

/// Leave analysis grouped by month (API Q3).
class LeaveAnalysisMonth extends Equatable {
  final String month;
  final int count;
  final int totalDays;

  const LeaveAnalysisMonth({
    required this.month,
    required this.count,
    required this.totalDays,
  });

  factory LeaveAnalysisMonth.fromJson(Map<String, dynamic> json) {
    return LeaveAnalysisMonth(
      month: (json['month'] ?? '') as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalDays: (json['total_days'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'count': count,
        'total_days': totalDays,
      };

  @override
  List<Object?> get props => [month, count, totalDays];
}

/// Leave analysis grouped by department (API Q3).
class LeaveAnalysisDept extends Equatable {
  final String department;
  final int count;
  final int totalDays;

  const LeaveAnalysisDept({
    required this.department,
    required this.count,
    required this.totalDays,
  });

  factory LeaveAnalysisDept.fromJson(Map<String, dynamic> json) {
    return LeaveAnalysisDept(
      department: (json['department'] ?? '') as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalDays: (json['total_days'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'department': department,
        'count': count,
        'total_days': totalDays,
      };

  @override
  List<Object?> get props => [department, count, totalDays];
}

/// Combined leave analysis data (API Q3).
class LeaveAnalysisData extends Equatable {
  final List<LeaveAnalysisType> byType;
  final List<LeaveAnalysisMonth> byMonth;
  final List<LeaveAnalysisDept> byDepartment;

  const LeaveAnalysisData({
    required this.byType,
    required this.byMonth,
    required this.byDepartment,
  });

  factory LeaveAnalysisData.fromJson(Map<String, dynamic> json) {
    return LeaveAnalysisData(
      byType: ((json['by_type'] ?? []) as List<dynamic>)
          .map((e) =>
              LeaveAnalysisType.fromJson(e as Map<String, dynamic>))
          .toList(),
      byMonth: ((json['by_month'] ?? []) as List<dynamic>)
          .map((e) =>
              LeaveAnalysisMonth.fromJson(e as Map<String, dynamic>))
          .toList(),
      byDepartment: ((json['by_department'] ?? []) as List<dynamic>)
          .map((e) =>
              LeaveAnalysisDept.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'by_type': byType.map((e) => e.toJson()).toList(),
        'by_month': byMonth.map((e) => e.toJson()).toList(),
        'by_department': byDepartment.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [byType, byMonth, byDepartment];
}

/// Task completion data grouped by department (API Q4).
class TaskCompletionDept extends Equatable {
  final String department;
  final int total;
  final int completed;
  final int inProgress;
  final int overdue;
  final double completionRate;

  const TaskCompletionDept({
    required this.department,
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.overdue,
    required this.completionRate,
  });

  factory TaskCompletionDept.fromJson(Map<String, dynamic> json) {
    return TaskCompletionDept(
      department: (json['department'] ?? '') as String,
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
      overdue: (json['overdue'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'department': department,
        'total': total,
        'completed': completed,
        'in_progress': inProgress,
        'overdue': overdue,
        'completion_rate': completionRate,
      };

  @override
  List<Object?> get props => [
        department,
        total,
        completed,
        inProgress,
        overdue,
        completionRate,
      ];
}
