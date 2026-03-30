import 'package:flutter/material.dart';

// ── Admin User ────────────────────────────────────────────
class AdminUser {
  final String id, name, nameEn, role, email, phone, initials;
  final List<String> permissions;
  const AdminUser({
    required this.id, required this.name, required this.nameEn,
    required this.role, required this.email, required this.phone,
    required this.initials, required this.permissions,
  });
}

// ── Department ────────────────────────────────────────────
class Department {
  final String id, name, headName, headTitle;
  final int employeeCount, pendingRequests, activeTasks, attendanceIssues;
  final double performanceScore;
  const Department({
    required this.id, required this.name,
    required this.headName, required this.headTitle,
    required this.employeeCount, required this.pendingRequests,
    required this.activeTasks, required this.attendanceIssues,
    required this.performanceScore,
  });
}

// ── Employee (Admin View) ─────────────────────────────────
class EmployeeRecord {
  final String id, name, title, deptId, dept, status, attendanceStatus;
  final String email, phone, joined, manager;
  final int pendingRequests, activeTasks;
  final String initials;
  const EmployeeRecord({
    required this.id, required this.name, required this.title,
    required this.deptId, required this.dept, required this.status,
    required this.attendanceStatus, required this.email,
    required this.phone, required this.joined, required this.manager,
    required this.pendingRequests, required this.activeTasks,
    required this.initials,
  });
}

// ── Request ───────────────────────────────────────────────
class AdminRequest {
  final String id, empName, empId, dept, type, submittedDate,
      status, priority, details, notes;
  const AdminRequest({
    required this.id, required this.empName, required this.empId,
    required this.dept, required this.type, required this.submittedDate,
    required this.status, required this.priority, required this.details,
    this.notes = '',
  });
}

// ── Task ──────────────────────────────────────────────────
class AdminTask {
  final String id, title, assignedTo, dept, createdDate, dueDate,
      status, priority;
  final String? notes;
  const AdminTask({
    required this.id, required this.title, required this.assignedTo,
    required this.dept, required this.createdDate, required this.dueDate,
    required this.status, required this.priority, this.notes,
  });
}

// ── Attendance Record ─────────────────────────────────────
class AttendanceRecord {
  final String empName, empId, dept, date, checkIn, checkOut, hours, status;
  final int lateMin, overtimeMin;
  const AttendanceRecord({
    required this.empName, required this.empId, required this.dept,
    required this.date, required this.checkIn, required this.checkOut,
    required this.hours, required this.status,
    this.lateMin = 0, this.overtimeMin = 0,
  });
}

// ── Leave Record ──────────────────────────────────────────
class LeaveRecord {
  final String id, empName, empId, dept, type, fromDate, toDate,
      duration, reason, status;
  const LeaveRecord({
    required this.id, required this.empName, required this.empId,
    required this.dept, required this.type, required this.fromDate,
    required this.toDate, required this.duration, required this.reason,
    required this.status,
  });
}

// ── Announcement ──────────────────────────────────────────
class AdminAnnouncement {
  final int id;
  final String title, category, audience, date, body, publishStatus;
  final bool isPinned;
  const AdminAnnouncement({
    required this.id, required this.title, required this.category,
    required this.audience, required this.date, required this.body,
    required this.publishStatus, this.isPinned = false,
  });
}

// ── Notification ──────────────────────────────────────────
class AdminNotification {
  final int id;
  final String title, body, time, type;
  bool isRead;
  AdminNotification({
    required this.id, required this.title, required this.body,
    required this.time, required this.type, this.isRead = false,
  });
}

// ── KPI Stat ──────────────────────────────────────────────
class KpiStat {
  final String label, value, change, icon;
  final bool isPositive;
  final Color color;
  const KpiStat({
    required this.label, required this.value, required this.change,
    required this.icon, required this.isPositive, required this.color,
  });
}

// ── Follow-up Item ────────────────────────────────────────
class FollowUpItem {
  final String id, title, responsible, dept, dueDate, status, type;
  final bool isOverdue, isEscalated;
  const FollowUpItem({
    required this.id, required this.title, required this.responsible,
    required this.dept, required this.dueDate, required this.status,
    required this.type, this.isOverdue = false, this.isEscalated = false,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROJECT MANAGEMENT MODELS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Project {
  final String id, code, name, dept, manager, managerInitials;
  final String startDate, endDate, status, priority, description;
  final double progress;
  final int taskCount, completedTasks, milestoneCount;
  final bool isDelayed;
  const Project({
    required this.id, required this.code, required this.name,
    required this.dept, required this.manager, required this.managerInitials,
    required this.startDate, required this.endDate, required this.status,
    required this.priority, required this.description, required this.progress,
    required this.taskCount, required this.completedTasks,
    required this.milestoneCount, this.isDelayed = false,
  });
}

class ProjectMilestone {
  final String id, projectId, title, targetDate, status;
  final bool isCompleted, isDelayed;
  const ProjectMilestone({
    required this.id, required this.projectId, required this.title,
    required this.targetDate, required this.status,
    this.isCompleted = false, this.isDelayed = false,
  });
}

class ProjectRisk {
  final String id, projectId, title, impact, likelihood, owner, status;
  const ProjectRisk({
    required this.id, required this.projectId, required this.title,
    required this.impact, required this.likelihood, required this.owner,
    required this.status,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXPENSE MANAGEMENT MODELS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseRequest {
  final String id, empName, empId, dept, category, categoryIcon;
  final double amount;
  final String currency, submittedDate, expenseDate, status, priority;
  final String? notes, projectRef;
  final bool hasAttachment, isHighValue;
  const ExpenseRequest({
    required this.id, required this.empName, required this.empId,
    required this.dept, required this.category, required this.categoryIcon,
    required this.amount, required this.currency,
    required this.submittedDate, required this.expenseDate,
    required this.status, required this.priority,
    this.notes, this.projectRef,
    this.hasAttachment = false, this.isHighValue = false,
  });
}

class ExpenseCategory {
  final String id, name, icon;
  final int requestCount;
  final double totalAmount;
  final bool isActive;
  const ExpenseCategory({
    required this.id, required this.name, required this.icon,
    required this.requestCount, required this.totalAmount,
    this.isActive = true,
  });
}
