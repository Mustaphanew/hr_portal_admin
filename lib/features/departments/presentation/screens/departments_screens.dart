import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/localization/app_localizations.dart';

// ── Departments Overview ──────────────────────────────────
class DepartmentsScreen extends ConsumerStatefulWidget {
  const DepartmentsScreen({super.key});
  @override ConsumerState<DepartmentsScreen> createState() => _DepartmentsState();
}
class _DepartmentsState extends ConsumerState<DepartmentsScreen> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final deptsAsync = ref.watch(departmentsProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: deptsAsync.when(
        loading: () => Column(children: [
          AdminAppBar(title: 'Departments'.tr(context), subtitle: '...', onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          AdminAppBar(title: 'Departments'.tr(context), subtitle: '', onBack: () => context.pop()),
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx3)),
            const SizedBox(height: 12),
            OutlineBtn(text: 'Retry'.tr(context), onTap: () => ref.invalidate(departmentsProvider)),
          ]))),
        ]),
        data: (data) {
          final allDepts = data.departments;
          final depts = allDepts
            .where((d) => _search.isEmpty || d.name.contains(_search)).toList();
          final totalEmployees = allDepts.fold<int>(0, (s, d) => s + d.employeeCount);
          final totalPending = allDepts.fold<int>(0, (s, d) => s + d.pendingRequests);
          final totalIssues = allDepts.fold<int>(0, (s, d) => s + d.attendanceIssues);
          return Column(children: [
            AdminAppBar(title: 'Departments'.tr(context), subtitle: 'depts_count'.tr(context, params: {'count': '${allDepts.length}'}),
              onBack: () => context.pop()),
            // Stats strip
            Container(
              color: AppColors.bgCard,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [
                _orgStat('$totalEmployees', 'employee_word'.tr(context), AppColors.navyMid, '👥'),
                const SizedBox(width: 10),
                _orgStat('${allDepts.length}', 'department_word'.tr(context), AppColors.teal, '🏢'),
                const SizedBox(width: 10),
                _orgStat('$totalPending', 'pending_request_word'.tr(context), AppColors.warning, '📋'),
                const SizedBox(width: 10),
                _orgStat('$totalIssues', 'exception_word'.tr(context), AppColors.error, '⚠️'),
              ]),
            ),
            // Search
            Container(color: AppColors.bgCard,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                onChanged: (v) => setState(() => _search = v),
                decoration: fieldDec('Search department'.tr(context)).copyWith(
                  prefixIcon: const Icon(Icons.search, color: AppColors.g400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
            Expanded(child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(departmentsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: depts.length,
                itemBuilder: (_, i) {
                  final d = depts[i];
                  return DepartmentCard(
                    name: d.name,
                    head: d.head?.name ?? '—',
                    headTitle: d.head?.jobTitle ?? '—',
                    employees: d.employeeCount,
                    requests: d.pendingRequests,
                    tasks: d.activeTasks,
                    issues: d.attendanceIssues,
                    performance: d.performanceScore ?? 0,
                    onTap: () => context.push('/department-detail', extra: d.id));
                },
              ),
            )),
          ]);
        },
      ),
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
class DepartmentDetailScreen extends ConsumerWidget {
  final int departmentId;
  const DepartmentDetailScreen({super.key, required this.departmentId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(departmentDetailProvider(departmentId));
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: detailAsync.when(
        loading: () => Column(children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.navyGradient),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 20, left: 18, right: 18),
            child: Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
              Expanded(child: Center(child: Text('Loading'.tr(context), style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)))),
              const SizedBox(width: 36),
            ]),
          ),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.navyGradient),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 20, left: 18, right: 18),
            child: Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
              Expanded(child: Center(child: Text('Error'.tr(context), style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)))),
              const SizedBox(width: 36),
            ]),
          ),
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx3)),
            const SizedBox(height: 12),
            OutlineBtn(text: 'Retry'.tr(context), onTap: () => ref.invalidate(departmentDetailProvider(departmentId))),
          ]))),
        ]),
        data: (d) => Column(children: [
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
                  Text(d.head?.name ?? '—', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
                ])),
                const SizedBox(width: 36),
              ]),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _heroStat('${d.employeeCount}', 'موظف', '👥'),
                _heroStat('${d.activeTasks}', 'مهمة', '✅'),
                _heroStat('${d.pendingRequests}', 'طلب معلق', '📋'),
                _heroStat('${d.attendanceIssues}', 'استثناء', '⚠️'),
              ]),
            ]),
          ),
          Expanded(child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(departmentDetailProvider(departmentId)),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Performance
                if (d.performanceScore != null)
                  AppCard(mb: 14, child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      StatusBadge(text: 'أداء ${d.performanceScore!.toInt()}%',
                        type: d.performanceScore! >= 90 ? 'approved' : d.performanceScore! >= 75 ? 'warning' : 'error'),
                      Text('مؤشر الأداء', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: d.performanceScore! / 100,
                        backgroundColor: AppColors.g100,
                        valueColor: AlwaysStoppedAnimation(
                          d.performanceScore! >= 90 ? AppColors.success
                            : d.performanceScore! >= 75 ? AppColors.warning : AppColors.error),
                        minHeight: 8)),
                  ])),
                // Manager Info
                AppCard(mb: 14, child: Column(children: [
                  Align(alignment: Alignment.centerRight, child: Text('معلومات المدير',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 10),
                  InfoRow(label: 'المدير المباشر', value: d.head?.name ?? '—', icon: '👤'),
                  InfoRow(label: 'المسمى الوظيفي', value: d.head?.jobTitle ?? '—', icon: '💼', border: false),
                ])),
                // Operational summary
                AppCard(mb: 14, child: Column(children: [
                  Align(alignment: Alignment.centerRight, child: Text('الوضع التشغيلي',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 10),
                  SummaryStatRow(label: 'الحاضرون اليوم', value: '${d.stats.presentToday}', icon: '👥', color: AppColors.navyMid),
                  const SizedBox(height: 8),
                  SummaryStatRow(label: 'الغائبون اليوم', value: '${d.stats.absentToday}', icon: '🚫', color: AppColors.error),
                  const SizedBox(height: 8),
                  SummaryStatRow(label: 'في إجازة اليوم', value: '${d.stats.onLeaveToday}', icon: '🏖️', color: AppColors.warning),
                  const SizedBox(height: 8),
                  SummaryStatRow(label: 'الطلبات المعلقة', value: '${d.stats.pendingRequests}', icon: '📋', color: AppColors.warning),
                  const SizedBox(height: 8),
                  SummaryStatRow(label: 'المهام النشطة', value: '${d.stats.activeTasks}', icon: '✅', color: AppColors.teal),
                ])),
                // Employees in dept
                SectionHeader(title: 'موظفو الإدارة',
                  actionLabel: 'عرض الكل', onAction: () => context.push('/employees')),
                ...d.employees.take(3).map((emp) {
                  final initials = emp.name.isNotEmpty
                    ? emp.name.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0]).join()
                    : '?';
                  return EmployeeListCard(
                    initials: initials,
                    name: emp.name,
                    title: emp.jobTitle ?? '—',
                    dept: d.name,
                    id: emp.code,
                    status: 'active',
                    attendanceStatus: emp.attendanceStatus ?? 'غائب',
                    onTap: () => context.push('/employee-detail', extra: emp.id));
                }),
                const SizedBox(height: 8),
              ]),
            ),
          )),
          StickyBar(child: Row(children: [
            Expanded(child: OutlineBtn(text: '📊 تقرير الإدارة', onTap: () => context.push('/reports'))),
            const SizedBox(width: 10),
            Expanded(child: PrimaryBtn(text: '📋 الطلبات', onTap: () => context.push('/requests'))),
          ])),
        ]),
      ),
    );
  }
  Widget _heroStat(String v, String l, String ico) => Column(children: [
    Text(ico, style: const TextStyle(fontSize: 18)),
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white60)),
  ]);
}
