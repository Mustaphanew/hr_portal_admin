import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUTTONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PrimaryBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final String? icon;
  final bool loading, fullWidth, small;
  const PrimaryBtn({super.key, required this.text, this.onTap,
    this.icon, this.loading = false, this.fullWidth = true, this.small = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: loading ? 0.75 : 1.0,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: small ? 10 : 13, horizontal: small ? 14 : 20),
        decoration: BoxDecoration(
          gradient: AppColors.navyGradient,
          borderRadius: BorderRadius.circular(11),
          boxShadow: AppShadows.navy),
        child: loading
          ? const Center(child: SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          : Row(mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (icon != null) ...[Text(icon!, style: TextStyle(fontSize: small?14:16)), const SizedBox(width:6)],
                Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: small?12:14, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
      ),
    ),
  );
}

class TealBtn extends StatelessWidget {
  final String text; final VoidCallback? onTap; final String? icon; final bool small, fullWidth;
  const TealBtn({super.key, required this.text, this.onTap, this.icon, this.small=false, this.fullWidth=true});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(vertical: small?9:13, horizontal: small?14:20),
      decoration: BoxDecoration(gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(11), boxShadow: AppShadows.teal),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[Text(icon!, style: TextStyle(fontSize: small?14:16)), const SizedBox(width:6)],
          Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: small?12:14, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
    ),
  );
}

class GoldBtn extends StatelessWidget {
  final String text; final VoidCallback? onTap; final String? icon; final bool small, fullWidth;
  const GoldBtn({super.key, required this.text, this.onTap, this.icon, this.small=false, this.fullWidth=true});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(vertical: small?9:13, horizontal: small?14:20),
      decoration: BoxDecoration(gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(11), boxShadow: AppShadows.gold),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[Text(icon!, style: TextStyle(fontSize: small?14:16)), const SizedBox(width:6)],
          Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: small?12:14, fontWeight: FontWeight.w700, color: AppColors.navyDeep)),
        ]),
    ),
  );
}

class OutlineBtn extends StatelessWidget {
  final String text; final VoidCallback? onTap; final Color? color; final bool small, fullWidth;
  const OutlineBtn({super.key, required this.text, this.onTap, this.color, this.small=false, this.fullWidth=true});
  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.navyMid;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(vertical: small?8:12, horizontal: small?14:20),
        decoration: BoxDecoration(color: Colors.transparent,
          borderRadius: BorderRadius.circular(11), border: Border.all(color: c, width: 1.5)),
        child: Center(child: Text(text, style: TextStyle(fontFamily: 'Cairo', 
          fontSize: small?12:14, fontWeight: FontWeight.w600, color: c))),
      ),
    );
  }
}

class DangerBtn extends StatelessWidget {
  final String text; final VoidCallback? onTap; final bool small, fullWidth;
  const DangerBtn({super.key, required this.text, this.onTap, this.small=false, this.fullWidth=true});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(vertical: small?9:13, horizontal: small?14:20),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.error.withOpacity(0.5))),
      child: Center(child: Text(text, style: TextStyle(fontFamily: 'Cairo', 
        fontSize: small?12:14, fontWeight: FontWeight.w700, color: AppColors.error))),
    ),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS & PRIORITY BADGES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class StatusBadge extends StatelessWidget {
  final String text, type;
  final bool dot;
  const StatusBadge({super.key, required this.text, required this.type, this.dot=false});

  (Color bg, Color fg) get _c {
    switch (type) {
      case 'approved':  case 'success':   case 'present':   return (AppColors.successSoft, AppColors.successDark);
      case 'pending':   case 'warning':                     return (AppColors.warningSoft, AppColors.warningDark);
      case 'rejected':  case 'error':     case 'absent':    return (AppColors.errorSoft, AppColors.errorDark);
      case 'info':      case 'navy':      case 'completed': return (AppColors.navySoft, AppColors.navyMid);
      case 'gold':      case 'leave':                       return (AppColors.goldSoft, AppColors.goldDark);
      case 'teal':      case 'in_progress':                 return (AppColors.tealSoft, AppColors.teal);
      case 'late':                                          return (AppColors.warningSoft, AppColors.warningDark);
      case 'overdue':                                       return (AppColors.errorSoft, AppColors.error);
      default:                                              return (AppColors.g100, AppColors.g600);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (dot) ...[Container(width:5, height:5, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)), const SizedBox(width:4)],
        Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge({super.key, required this.priority});
  @override
  Widget build(BuildContext context) {
    final map = {'high': ('عالية', AppColors.error, AppColors.errorSoft),
                 'normal': ('متوسطة', AppColors.warning, AppColors.warningSoft),
                 'low': ('منخفضة', AppColors.g500, AppColors.g100)};
    final (label, fg, bg) = map[priority] ?? ('عادية', AppColors.g500, AppColors.g100);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADMIN APP BAR
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AdminAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  const AdminAppBar({super.key, required this.title, this.subtitle, this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.navyGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 14, left: 18, right: 18),
      child: Row(children: [
        // ── START: زر الرجوع ──────────────────────────────────
        if (onBack != null)
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(
                isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                color: Colors.white, size: 17)))
        else
          const SizedBox(width: 36),
        // ── CENTER: العنوان ───────────────────────────────────
        Expanded(child: Column(children: [
          Text(title, style: TextStyle(fontFamily: 'Cairo',
            fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          if (subtitle != null)
            Text(subtitle!, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 11, color: Colors.white54)),
        ])),
        // ── END: trailing ─────────────────────────────────────
        trailing ?? const SizedBox(width: 36),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KPI / STAT CARDS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class KpiCard extends StatelessWidget {
  final String label, value, change, icon;
  final bool isPositive;
  final Color color;
  final VoidCallback? onTap;
  const KpiCard({super.key, required this.label, required this.value,
    required this.change, required this.icon, required this.isPositive,
    required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border(bottom: BorderSide(color: color, width: 3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(icon, style: const TextStyle(fontSize: 18))),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.w900, color: color, height: 1)),
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3, height: 1.3)),
          ]),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(change, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: isPositive ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 11, color: isPositive ? AppColors.success : AppColors.error),
        ]),
      ]),
    ),
  );
}

class SummaryStatRow extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const SummaryStatRow({super.key, required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ]),
      Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tx2)),
    ]),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION HEADER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.tx1)),
      if (onAction != null)
        GestureDetector(onTap: onAction,
          child: Text(actionLabel ?? 'عرض الكل', style: TextStyle(fontFamily: 'Cairo',
            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyLight)))
      else const SizedBox(),
    ]),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CARDS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppCard extends StatelessWidget {
  final Widget child; final double? mb; final VoidCallback? onTap; final EdgeInsets? padding;
  const AppCard({super.key, required this.child, this.mb, this.onTap, this.padding});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: mb ?? 0),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card),
      child: child,
    ),
  );
}

class InfoRow extends StatelessWidget {
  final String label, value; final String? icon; final bool border;
  const InfoRow({super.key, required this.label, required this.value, this.icon, this.border = true});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(border: border ? const Border(bottom: BorderSide(color: AppColors.g100)) : null),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(child: Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.tx2), textAlign: TextAlign.left, textDirection: TextDirection.ltr)),
      Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Text(icon!, style: const TextStyle(fontSize: 14)), const SizedBox(width: 6)],
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.tx3)),
      ]),
    ]),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DEPARTMENT CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DepartmentCard extends StatelessWidget {
  final String name, head, headTitle;
  final int employees, requests, tasks, issues;
  final double performance;
  final VoidCallback? onTap;
  const DepartmentCard({super.key, required this.name, required this.head,
    required this.headTitle, required this.employees, required this.requests,
    required this.tasks, required this.issues, required this.performance, this.onTap});

  @override
  Widget build(BuildContext context) {
    final perfColor = performance >= 90 ? AppColors.success : performance >= 75 ? AppColors.warning : AppColors.error;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: AppColors.navyGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(6)),
                    child: Text('أداء ${performance.toInt()}%', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
                ]),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(name, style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('$head — $headTitle', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: Colors.white60)),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: performance / 100,
                  backgroundColor: AppColors.g100,
                  valueColor: AlwaysStoppedAnimation(perfColor),
                  minHeight: 4)),
              const SizedBox(height: 12),
              Row(children: [
                _stat(employees.toString(), 'موظف', '👥', AppColors.navyMid),
                _div(),
                _stat(requests.toString(), 'طلب', '📋', AppColors.warning),
                _div(),
                _stat(tasks.toString(), 'مهمة', '✅', AppColors.teal),
                _div(),
                _stat(issues.toString(), 'استثناء', '⚠️', issues > 0 ? AppColors.error : AppColors.g400),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _stat(String v, String l, String ico, Color c) => Expanded(child: Column(children: [
    Text(ico, style: const TextStyle(fontSize: 14)),
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w900, color: c, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3)),
  ]));

  Widget _div() => Container(width: 1, height: 32, color: AppColors.g100);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMPLOYEE CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class EmployeeListCard extends StatelessWidget {
  final String initials, name, title, dept, id, status, attendanceStatus;
  final VoidCallback? onTap;
  const EmployeeListCard({super.key, required this.initials, required this.name,
    required this.title, required this.dept, required this.id,
    required this.status, required this.attendanceStatus, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card),
      child: Row(children: [
        Row(children: [
          StatusBadge(
            text: attendanceStatus == 'حاضر' ? 'حاضر'
              : attendanceStatus == 'متأخر' ? 'متأخر'
              : attendanceStatus == 'إجازة' ? 'إجازة' : 'غائب',
            type: attendanceStatus == 'حاضر' ? 'success'
              : attendanceStatus == 'متأخر' ? 'late'
              : attendanceStatus == 'إجازة' ? 'leave' : 'absent',
            dot: true),
        ]),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(name, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
          Text('$title · $dept', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
          Text(id, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.g400)),
        ])),
        const SizedBox(width: 10),
        AdminAvatar(initials: initials, size: 44),
      ]),
    ),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REQUEST CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class RequestCard extends StatelessWidget {
  final String id, empName, dept, type, date, status, priority;
  final VoidCallback? onTap;
  const RequestCard({super.key, required this.id, required this.empName,
    required this.dept, required this.type, required this.date,
    required this.status, required this.priority, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border(right: BorderSide(
          color: priority == 'high' ? AppColors.error
            : priority == 'normal' ? AppColors.warning : AppColors.g300,
          width: 3.5))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              StatusBadge(
                text: status == 'pending' ? 'معلق' : status == 'approved' ? 'معتمد'
                  : status == 'completed' ? 'مكتمل' : 'مرفوض',
                type: status, dot: true),
              const SizedBox(width: 8),
              PriorityBadge(priority: priority),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(type, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
              Text('$empName · $dept', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
            ]),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(id, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.g400)),
            Text(date, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
          ]),
        ]),
      ),
    ),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TASK CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class TaskCard extends StatelessWidget {
  final String id, title, assignedTo, dept, dueDate, status, priority;
  final VoidCallback? onTap;
  const TaskCard({super.key, required this.id, required this.title,
    required this.assignedTo, required this.dept, required this.dueDate,
    required this.status, required this.priority, this.onTap});

  @override
  Widget build(BuildContext context) {
    final priColor = priority == 'high' ? AppColors.error : priority == 'normal' ? AppColors.warning : AppColors.g300;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
          border: Border(right: BorderSide(color: priColor, width: 3.5))),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              StatusBadge(
                text: status == 'pending' ? 'معلقة' : status == 'in_progress' ? 'جارية'
                  : status == 'overdue' ? 'متأخرة' : 'مكتملة',
                type: status == 'overdue' ? 'overdue' : status == 'in_progress' ? 'teal'
                  : status == 'pending' ? 'pending' : 'approved', dot: true),
            ]),
            Flexible(child: Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right, maxLines: 2)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('📅 $dueDate', style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 11, color: status == 'overdue' ? AppColors.error : AppColors.tx3,
              fontWeight: status == 'overdue' ? FontWeight.w700 : FontWeight.w400)),
            Text('$assignedTo · $dept', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
          ]),
        ]),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FOLLOW-UP CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class FollowUpCard extends StatelessWidget {
  final String id, title, responsible, dept, dueDate, status;
  final bool isOverdue, isEscalated;
  final VoidCallback? onTap;
  const FollowUpCard({super.key, required this.id, required this.title,
    required this.responsible, required this.dept, required this.dueDate,
    required this.status, this.isOverdue = false, this.isEscalated = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: isOverdue ? AppColors.error.withOpacity(0.4)
            : isEscalated ? AppColors.warning.withOpacity(0.4) : Colors.transparent,
          width: isOverdue || isEscalated ? 1.5 : 0)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            if (isEscalated) ...[
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(6)),
                child: Text('🚨 مُصعَّد', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error))),
              const SizedBox(width: 6),
            ],
            StatusBadge(text: isOverdue ? 'متأخر' : status == 'in_progress' ? 'جارٍ' : 'معلق',
              type: isOverdue ? 'overdue' : status == 'in_progress' ? 'teal' : 'pending', dot: true),
          ]),
          Flexible(child: Text(title, style: TextStyle(fontFamily: 'Cairo', 
            fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.right, maxLines: 2)),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('📅 $dueDate', style: TextStyle(fontFamily: 'Cairo', 
            fontSize: 11, color: isOverdue ? AppColors.error : AppColors.tx3,
            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w400)),
          Text('$responsible · $dept', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
        ]),
      ]),
    ),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMELINE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class TLStep { final String label; final String? sub; final bool done, active;
  const TLStep({required this.label, this.sub, this.done=false, this.active=false}); }

class TimelineWidget extends StatelessWidget {
  final List<TLStep> steps;
  const TimelineWidget({super.key, required this.steps});
  @override
  Widget build(BuildContext context) => Column(
    children: steps.asMap().entries.map((e) {
      final i = e.key; final s = e.value; final isLast = i == steps.length - 1;
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: s.done ? AppColors.navyMid : s.active ? AppColors.gold : AppColors.g200,
              boxShadow: s.active ? AppShadows.gold : null),
            child: Center(child: s.done
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text(s.active ? '◉' : '${i+1}', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: s.done || s.active ? Colors.white : AppColors.g400)))),
          if (!isLast) Container(width: 2, height: 26, color: s.done ? AppColors.navySoft : AppColors.g200),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(s.label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700,
              color: s.active ? AppColors.navyMid : s.done ? AppColors.tx2 : AppColors.g400)),
            if (s.sub != null) Text(s.sub!, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
          ]),
        )),
      ]);
    }).toList(),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MISC
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AdminAvatar extends StatelessWidget {
  final String initials; final double size; final Color? bg; final double? fontSize;
  const AdminAvatar({super.key, required this.initials, this.size=44, this.bg, this.fontSize});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [bg ?? AppColors.navyMid, AppColors.navyDeep]),
      shape: BoxShape.circle, boxShadow: AppShadows.sm),
    child: Center(child: Text(initials, style: TextStyle(fontFamily: 'Cairo', 
      fontSize: fontSize ?? size * 0.34, fontWeight: FontWeight.w800, color: Colors.white))),
  );
}

class StickyBar extends StatelessWidget {
  final Widget child;
  const StickyBar({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.bgCard,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, -4))]),
    padding: EdgeInsets.only(left: 16, right: 16, top: 12,
      bottom: MediaQuery.of(context).padding.bottom + 14),
    child: child,
  );
}

class FilterBar extends StatelessWidget {
  final List<String> tabs; final int selected; final ValueChanged<int> onSelect;
  const FilterBar({super.key, required this.tabs, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.bgCard,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal, reverse: true,
      child: Row(children: tabs.asMap().entries.map((e) {
        final active = e.key == selected;
        return GestureDetector(
          onTap: () => onSelect(e.key),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active ? AppColors.navyMid : Colors.transparent,
              borderRadius: BorderRadius.circular(99)),
            child: Text(e.value, style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.white : AppColors.g500))),
        );
      }).toList()),
    ),
  );
}

class AlertBanner extends StatelessWidget {
  final String message, type;
  const AlertBanner({super.key, required this.message, required this.type});
  @override
  Widget build(BuildContext context) {
    final (bg, fg, ico) = type == 'error' ? (AppColors.errorSoft, AppColors.errorDark, '🚨')
      : type == 'warning' ? (AppColors.warningSoft, AppColors.warningDark, '⚠️')
      : (AppColors.navySoft, AppColors.navyMid, 'ℹ️');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.3))),
      child: Row(children: [
        Text(message, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: fg, fontWeight: FontWeight.w600),
          textAlign: TextAlign.right),
        const Spacer(),
        Text(ico, style: const TextStyle(fontSize: 16)),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String icon, title; final String? subtitle;
  const EmptyState({super.key, this.icon='📂', required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 48)),
      const SizedBox(height: 14),
      Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.tx2), textAlign: TextAlign.center),
      if (subtitle != null) ...[const SizedBox(height: 8),
        Text(subtitle!, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.tx3, height: 1.7), textAlign: TextAlign.center)],
    ]),
  ));
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 90, margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.sm),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(height: 12, width: 160, decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(6))),
      const SizedBox(height: 8),
      Container(height: 10, width: 100, decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(6))),
      const Spacer(),
      Container(height: 8, width: 60, decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(4))),
    ]),
  );
}

class AppToggle extends StatelessWidget {
  final bool value; final ValueChanged<bool> onChanged;
  const AppToggle({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44, height: 26, padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? AppColors.navyMid : AppColors.g300,
        borderRadius: BorderRadius.circular(13)),
      child: AnimatedAlign(duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(width: 20, height: 20,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 3)]))),
    ),
  );
}

InputDecoration fieldDec([String? hint, String? label]) => InputDecoration(
  hintText: hint, labelText: label,
  filled: true, fillColor: AppColors.g50,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.g200)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.g200)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.navyMid, width: 1.5)),
  hintStyle: TextStyle(fontFamily: 'Cairo', color: AppColors.g400, fontSize: 13),
  labelStyle: TextStyle(fontFamily: 'Cairo', color: AppColors.tx3, fontSize: 12),
);
