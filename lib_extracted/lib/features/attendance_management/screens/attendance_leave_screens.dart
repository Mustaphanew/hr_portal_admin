import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATTENDANCE MANAGEMENT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});
  @override State<AttendanceManagementScreen> createState() => _AttMgmtState();
}
class _AttMgmtState extends State<AttendanceManagementScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final records = AdminData.attendanceRecords;
    final present  = records.where((r) => r.status == 'present').length;
    final late     = records.where((r) => r.status == 'late').length;
    final absent   = records.where((r) => r.status == 'absent').length;
    final onLeave  = records.where((r) => r.status == 'leave').length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 16, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
              Expanded(child: Column(children: [
                Text('إدارة الحضور', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('اليوم — الأحد 9 مارس 2025', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _attPill('$present', 'حاضر', AppColors.success),
              const SizedBox(width: 6),
              _attPill('$late',    'متأخر', AppColors.warning),
              const SizedBox(width: 6),
              _attPill('$absent',  'غائب', AppColors.error),
              const SizedBox(width: 6),
              _attPill('$onLeave', 'إجازة', AppColors.teal),
            ]),
          ]),
        ),
        // Stats cards
        Container(color: AppColors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            _smallStat('109', 'إجمالي الموظفين', AppColors.navyMid),
            const SizedBox(width: 10),
            _smallStat('6',   'استثناءات اليوم', AppColors.error),
            const SizedBox(width: 10),
            _smallStat('86%', 'نسبة الحضور',     AppColors.success),
          ])),
        FilterBar(tabs: ['الكل','حاضر','متأخر','غائب','إجازة'],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: records.length,
          itemBuilder: (_, i) {
            final r = records[i];
            return GestureDetector(
              onTap: () => context.push('/attendance-detail'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.card),
                child: Row(children: [
                  Column(children: [
                    StatusBadge(
                      text: r.status == 'present' ? 'حاضر' : r.status == 'late' ? 'متأخر'
                        : r.status == 'leave' ? 'إجازة' : 'غائب',
                      type: r.status == 'present' ? 'approved'
                        : r.status == 'late' ? 'warning'
                        : r.status == 'leave' ? 'leave' : 'error', dot: true),
                  ]),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(r.empName, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('${r.dept} · ${r.empId}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                  ])),
                  const SizedBox(width: 10),
                  if (r.status != 'absent' && r.status != 'leave')
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${r.checkIn} — ${r.checkOut}', style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 11, color: AppColors.tx2, fontWeight: FontWeight.w600)),
                      if (r.lateMin > 0)
                        Text('تأخر ${r.lateMin}د', style: TextStyle(fontFamily: 'Cairo', 
                          fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w700)),
                      if (r.overtimeMin > 0)
                        Text('إضافي ${r.overtimeMin}د', style: TextStyle(fontFamily: 'Cairo', 
                          fontSize: 10, color: AppColors.teal, fontWeight: FontWeight.w700)),
                    ])
                  else Text('—', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.g400)),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }
  Widget _attPill(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
    ])));
  Widget _smallStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3, height: 1.2), textAlign: TextAlign.center),
    ])));
}

// ── Attendance Detail ─────────────────────────────────────
class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final r = AdminData.attendanceRecords.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل سجل الحضور',
          subtitle: '${r.empName} — ${r.date}',
          onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            AppCard(mb: 14, child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                StatusBadge(text: 'حاضر', type: 'approved', dot: true),
                Text(r.date, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
              const Divider(height: 20, color: AppColors.g100),
              InfoRow(label: 'الموظف',         value: r.empName, icon: '👤'),
              InfoRow(label: 'الإدارة',         value: r.dept,    icon: '🏢'),
              InfoRow(label: 'وقت الدخول',      value: r.checkIn, icon: '🟢'),
              InfoRow(label: 'وقت الخروج',     value: r.checkOut, icon: '🔴'),
              InfoRow(label: 'إجمالي الساعات', value: r.hours,   icon: '⏱'),
              InfoRow(label: 'وقت التأخر',      value: r.lateMin > 0 ? '${r.lateMin} دقيقة' : 'لا يوجد', icon: '⚠️'),
              InfoRow(label: 'الوقت الإضافي',  value: r.overtimeMin > 0 ? '${r.overtimeMin} دقيقة' : 'لا يوجد', icon: '✨', border: false),
            ])),
            AppCard(mb: 14, child: Column(children: [
              Align(alignment: Alignment.centerRight, child: Text('الموقع والجهاز',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),
              const InfoRow(label: 'موقع الدخول',  value: 'المقر الرئيسي — الرياض', icon: '📍'),
              const InfoRow(label: 'جهاز التسجيل', value: 'بصمة المدخل الرئيسي',   icon: '🖐', border: false),
            ])),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: OutlineBtn(text: '✏️ تصحيح السجل', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: PrimaryBtn(text: '📋 ملف الموظف', onTap: () => context.push('/employee-detail'))),
        ])),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LEAVE MANAGEMENT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});
  @override State<LeaveManagementScreen> createState() => _LeaveMgmtState();
}
class _LeaveMgmtState extends State<LeaveManagementScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final records = AdminData.leaveRecords;
    final pending   = records.where((r) => r.status == 'pending').length;
    final approved  = records.where((r) => r.status == 'approved').length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 16, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
              Expanded(child: Column(children: [
                Text('إدارة الإجازات', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('نظرة شاملة على الإجازات', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _leavePill('11',       'في إجازة اليوم', AppColors.tealLight),
              const SizedBox(width: 8),
              _leavePill('$pending', 'معلق',           AppColors.warning),
              const SizedBox(width: 8),
              _leavePill('$approved','معتمد الشهر',    AppColors.goldLight),
            ]),
          ]),
        ),
        FilterBar(tabs: ['الكل','معلق','معتمد','مرفوض','مكتمل'],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: records.length,
          itemBuilder: (_, i) {
            final r = records[i];
            return GestureDetector(
              onTap: () => context.push('/leave-detail'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.card),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      StatusBadge(
                        text: r.status == 'pending' ? 'معلق' : r.status == 'approved' ? 'معتمد'
                          : r.status == 'completed' ? 'مكتمل' : 'مرفوض',
                        type: r.status, dot: true),
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.navySoft, borderRadius: BorderRadius.circular(6)),
                        child: Text(r.type, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navyMid))),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(r.empName, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('${r.dept} · ${r.empId}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                    ]),
                  ]),
                  const SizedBox(height: 10),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      Column(children: [
                        Text('من', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
                        Text(r.fromDate, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                      Container(width: 1, height: 28, color: AppColors.g200),
                      Column(children: [
                        Text('المدة', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
                        Text(r.duration, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
                      ]),
                      Container(width: 1, height: 28, color: AppColors.g200),
                      Column(children: [
                        Text('إلى', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
                        Text(r.toDate, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ])),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }
  Widget _leavePill(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
    ])));
}

// ── Leave Detail ──────────────────────────────────────────
class LeaveDetailAdminScreen extends StatelessWidget {
  const LeaveDetailAdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AdminData.leaveRecords.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل طلب الإجازة', subtitle: l.id,
          onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: AppColors.navyGradient,
                borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.navy),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  StatusBadge(text: 'قيد المراجعة', type: 'pending', dot: true),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(l.empName, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('${l.dept} · ${l.empId}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                  ]),
                ]),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _dItem('من', l.fromDate),
                  Column(children: [
                    Text(l.duration, style: TextStyle(fontFamily: 'Cairo', fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                    Text('إجازة ${l.type}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                  ]),
                  _dItem('إلى', l.toDate),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            AppCard(mb: 14, child: Column(children: [
              Align(alignment: Alignment.centerRight, child: Text('تفاصيل الطلب',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),
              InfoRow(label: 'نوع الإجازة', value: l.type,   icon: '🌴'),
              InfoRow(label: 'السبب',        value: l.reason, icon: '📋'),
              InfoRow(label: 'رقم الطلب',   value: l.id,     icon: '🔖', border: false),
            ])),
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('مسار الموافقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
              const SizedBox(height: 14),
              const TimelineWidget(steps: [
                TLStep(label: 'تقديم الطلب',          sub: 'الموظف — منذ ساعتين', done: true),
                TLStep(label: 'مراجعة المدير المباشر', sub: 'جارٍ...',              active: true),
                TLStep(label: 'اعتماد إدارة HR'),
                TLStep(label: 'إغلاق الطلب'),
              ]),
            ])),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: DangerBtn(text: '✗ رفض', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: OutlineBtn(text: '↩ إعادة', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: TealBtn(text: '✓ اعتماد', onTap: () {})),
        ])),
      ]),
    );
  }
  Widget _dItem(String l, String v) => Column(children: [
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white60)),
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
  ]);
}
