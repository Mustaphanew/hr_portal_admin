import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';

// ── Employees Directory ───────────────────────────────────
class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});
  @override State<EmployeesScreen> createState() => _EmployeesState();
}
class _EmployeesState extends State<EmployeesScreen> {
  String _search = '';
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final all = AdminData.employees;
    final filtered = all.where((e) =>
      (_search.isEmpty || e.name.contains(_search) || e.id.contains(_search)) &&
      (_tab == 0 || (
        _tab == 1 ? e.attendanceStatus == 'حاضر' :
        _tab == 2 ? e.attendanceStatus == 'متأخر' :
        _tab == 3 ? e.attendanceStatus == 'إجازة' :
        e.attendanceStatus == 'غائب'))).toList();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'الموظفون', subtitle: '${all.length} موظف نشط',
          onBack: () => context.pop()),
        Container(
          color: AppColors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(children: [
            TextField(textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
              onChanged: (v) => setState(() => _search = v),
              decoration: fieldDec('ابحث عن موظف أو رقم...').copyWith(
                prefixIcon: const Icon(Icons.search, color: AppColors.g400, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
            const SizedBox(height: 8),
          ]),
        ),
        FilterBar(
          tabs: ['الكل','حاضر','متأخر','إجازة','غائب'],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final e = filtered[i];
            return EmployeeListCard(
              initials: e.initials, name: e.name, title: e.title,
              dept: e.dept, id: e.id, status: e.status,
              attendanceStatus: e.attendanceStatus,
              onTap: () => context.push('/employee-detail'));
          },
        )),
      ]),
    );
  }
}

// ── Employee Detail ───────────────────────────────────────
class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final e = AdminData.employees.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 24, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
              Expanded(child: Column(children: [
                AdminAvatar(initials: e.initials, size: 64, fontSize: 22),
                const SizedBox(height: 10),
                Text(e.name, style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(e.title, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  StatusBadge(text: e.id, type: 'navy'),
                  const SizedBox(width: 8),
                  StatusBadge(
                    text: e.attendanceStatus,
                    type: e.attendanceStatus == 'حاضر' ? 'approved'
                      : e.attendanceStatus == 'متأخر' ? 'warning'
                      : e.attendanceStatus == 'إجازة' ? 'leave' : 'error',
                    dot: true),
                ]),
              ])),
              const SizedBox(width: 36),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(children: [
            // Quick stats
            Row(children: [
              _stat('6 سنوات', 'خدمة', '🏅'),
              const SizedBox(width: 10),
              _stat('${e.pendingRequests}', 'طلبات', '📋'),
              const SizedBox(width: 10),
              _stat('${e.activeTasks}', 'مهام', '✅'),
            ]),
            const SizedBox(height: 14),
            // Work info
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('بيانات التوظيف', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'القسم',           value: e.dept,    icon: '🏢'),
              InfoRow(label: 'المسمى الوظيفي', value: e.title,   icon: '💼'),
              InfoRow(label: 'المدير المباشر',  value: e.manager, icon: '👤'),
              InfoRow(label: 'تاريخ الالتحاق', value: e.joined,  icon: '📅'),
              InfoRow(label: 'الحالة',           value: e.status,  icon: '✅', border: false),
            ])),
            // Contact
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('بيانات الاتصال', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'البريد الإلكتروني', value: e.email, icon: '✉️'),
              InfoRow(label: 'الجوال',             value: e.phone, icon: '📱', border: false),
            ])),
            // Attendance summary
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(onTap: () => context.push('/attendance'),
                  child: Text('عرض السجل', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.navyLight, fontWeight: FontWeight.w700))),
                Text('ملخص الحضور — مارس', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _attStat('17', 'حاضر', AppColors.success),
                const SizedBox(width: 8),
                _attStat('1', 'متأخر', AppColors.warning),
                const SizedBox(width: 8),
                _attStat('2', 'إجازة', AppColors.teal),
                const SizedBox(width: 8),
                _attStat('0', 'غياب', AppColors.error),
              ]),
            ])),
            // Leave summary
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(onTap: () => context.push('/leave'),
                  child: Text('طلبات الإجازة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.navyLight, fontWeight: FontWeight.w700))),
                Text('رصيد الإجازات', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 12),
              _leaveRow('سنوية', '21', '7', '11'),
              _leaveRow('مرضية', '14', '3', '11'),
              _leaveRow('طارئة', '5', '1', '4'),
            ])),
            // Recent requests
            SectionHeader(title: 'آخر الطلبات',
              actionLabel: 'عرض الكل', onAction: () => context.push('/requests')),
            ...AdminData.requests.where((r) => r.empId == e.id).take(3).map((r) =>
              RequestCard(id: r.id, empName: r.empName, dept: r.dept, type: r.type,
                date: r.submittedDate, status: r.status, priority: r.priority,
                onTap: () => context.push('/request-detail'))),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: OutlineBtn(text: '📩 مراسلة', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: TealBtn(text: '📋 الطلبات', onTap: () => context.push('/requests'))),
        ])),
      ]),
    );
  }
  Widget _stat(String v, String l, String ico) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.sm),
    child: Column(children: [
      Text(ico, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
    ])));
  Widget _attStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: c.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3)),
    ])));
  Widget _leaveRow(String type, String total, String used, String rem) =>
    Container(padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.g100))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Text(rem, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navyMid)),
          Text(' متبقي', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
        ]),
        Text('$type — من $total', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.tx2)),
      ]));
}
