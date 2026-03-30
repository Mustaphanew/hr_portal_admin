import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';

// ── Departments Overview ──────────────────────────────────
class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});
  @override State<DepartmentsScreen> createState() => _DepartmentsState();
}
class _DepartmentsState extends State<DepartmentsScreen> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final depts = AdminData.departments
      .where((d) => _search.isEmpty || d.name.contains(_search)).toList();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'الإدارات', subtitle: '${AdminData.departments.length} إدارات',
          onBack: () => context.pop()),
        // Stats strip
        Container(
          color: AppColors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            _orgStat('109', 'موظف', AppColors.navyMid, '👥'),
            const SizedBox(width: 10),
            _orgStat('6',   'إدارة', AppColors.teal,    '🏢'),
            const SizedBox(width: 10),
            _orgStat('31',  'طلب معلق', AppColors.warning, '📋'),
            const SizedBox(width: 10),
            _orgStat('14',  'استثناء', AppColors.error,  '⚠️'),
          ]),
        ),
        // Search
        Container(color: AppColors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: TextField(
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            onChanged: (v) => setState(() => _search = v),
            decoration: fieldDec('ابحث عن إدارة...').copyWith(
              prefixIcon: const Icon(Icons.search, color: AppColors.g400, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: depts.length,
          itemBuilder: (_, i) {
            final d = depts[i];
            return DepartmentCard(
              name: d.name, head: d.headName, headTitle: d.headTitle,
              employees: d.employeeCount, requests: d.pendingRequests,
              tasks: d.activeTasks, issues: d.attendanceIssues,
              performance: d.performanceScore,
              onTap: () => context.push('/department-detail'));
          },
        )),
      ]),
    );
  }
  Widget _orgStat(String v, String l, Color c, String ico) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
    decoration: BoxDecoration(color: c.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(ico, style: const TextStyle(fontSize: 14)),
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3), textAlign: TextAlign.center),
    ]),
  ));
}

// ── Department Detail ─────────────────────────────────────
class DepartmentDetailScreen extends StatelessWidget {
  const DepartmentDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final d = AdminData.departments.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 20, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
              Expanded(child: Column(children: [
                Text(d.name, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(d.headName, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _heroStat('${d.employeeCount}', 'موظف', '👥'),
              _heroStat('${d.activeTasks}',   'مهمة', '✅'),
              _heroStat('${d.pendingRequests}', 'طلب معلق', '📋'),
              _heroStat('${d.attendanceIssues}', 'استثناء', '⚠️'),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Performance
            AppCard(mb: 14, child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                StatusBadge(text: 'أداء ${d.performanceScore.toInt()}%',
                  type: d.performanceScore >= 90 ? 'approved' : d.performanceScore >= 75 ? 'warning' : 'error'),
                Text('مؤشر الأداء', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: d.performanceScore / 100,
                  backgroundColor: AppColors.g100,
                  valueColor: AlwaysStoppedAnimation(
                    d.performanceScore >= 90 ? AppColors.success
                      : d.performanceScore >= 75 ? AppColors.warning : AppColors.error),
                  minHeight: 8)),
            ])),
            // Manager Info
            AppCard(mb: 14, child: Column(children: [
              Align(alignment: Alignment.centerRight, child: Text('معلومات المدير',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),
              InfoRow(label: 'المدير المباشر', value: d.headName, icon: '👤'),
              InfoRow(label: 'المسمى الوظيفي', value: d.headTitle, icon: '💼'),
              const InfoRow(label: 'الفرع',          value: 'الرياض — المقر الرئيسي', icon: '📍', border: false),
            ])),
            // Operational summary
            AppCard(mb: 14, child: Column(children: [
              Align(alignment: Alignment.centerRight, child: Text('الوضع التشغيلي',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),
              SummaryStatRow(label: 'الموظفون النشطون', value: '${d.employeeCount}', icon: '👥', color: AppColors.navyMid),
              const SizedBox(height: 8),
              SummaryStatRow(label: 'الطلبات المعلقة',   value: '${d.pendingRequests}', icon: '📋', color: AppColors.warning),
              const SizedBox(height: 8),
              SummaryStatRow(label: 'المهام النشطة',      value: '${d.activeTasks}', icon: '✅', color: AppColors.teal),
              const SizedBox(height: 8),
              SummaryStatRow(label: 'استثناءات الحضور',  value: '${d.attendanceIssues}', icon: '⚠️', color: d.attendanceIssues > 0 ? AppColors.error : AppColors.success),
            ])),
            // Employees in dept
            SectionHeader(title: 'موظفو الإدارة',
              actionLabel: 'عرض الكل', onAction: () => context.push('/employees')),
            ...AdminData.employees.where((e) => e.deptId == d.id).take(3).map((emp) =>
              EmployeeListCard(
                initials: emp.initials, name: emp.name, title: emp.title,
                dept: emp.dept, id: emp.id, status: emp.status,
                attendanceStatus: emp.attendanceStatus,
                onTap: () => context.push('/employee-detail'))),
            // Pending requests
            const SizedBox(height: 8),
            SectionHeader(title: 'الطلبات المعلقة',
              actionLabel: 'عرض الكل', onAction: () => context.push('/requests')),
            ...AdminData.requests.where((r) => r.dept.contains(d.name.split('إدارة').last.trim()) && r.status == 'pending').take(2).map((r) =>
              RequestCard(id: r.id, empName: r.empName, dept: r.dept, type: r.type,
                date: r.submittedDate, status: r.status, priority: r.priority,
                onTap: () => context.push('/request-detail'))),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: OutlineBtn(text: '📊 تقرير الإدارة', onTap: () => context.push('/reports'))),
          const SizedBox(width: 10),
          Expanded(child: PrimaryBtn(text: '📋 الطلبات', onTap: () => context.push('/requests'))),
        ])),
      ]),
    );
  }
  Widget _heroStat(String v, String l, String ico) => Column(children: [
    Text(ico, style: const TextStyle(fontSize: 18)),
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white60)),
  ]);
}
