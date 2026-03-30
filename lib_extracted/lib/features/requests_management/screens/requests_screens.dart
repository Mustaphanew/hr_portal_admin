import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';

// ── Requests Dashboard ────────────────────────────────────
class RequestsManagementScreen extends StatelessWidget {
  const RequestsManagementScreen({super.key});

  static const _cats = [
    {'icon': '🌴', 'label': 'طلبات إجازة',   'count': '7',  'color': AppColors.navyMid,   'status': 'معلقة'},
    {'icon': '🕐', 'label': 'تصحيح حضور',    'count': '4',  'color': AppColors.warning,   'status': 'معلقة'},
    {'icon': '🚪', 'label': 'أذونات مغادرة', 'count': '2',  'color': AppColors.teal,      'status': 'معلقة'},
    {'icon': '💳', 'label': 'مطالبات مصاريف', 'count': '5', 'color': AppColors.gold,      'status': 'معلقة'},
    {'icon': '💰', 'label': 'سلف الرواتب',   'count': '1',  'color': AppColors.success,   'status': 'معلقة'},
    {'icon': '📄', 'label': 'طلبات وثائق',   'count': '3',  'color': AppColors.info,      'status': 'معلقة'},
    {'icon': '🏦', 'label': 'طلبات قروض',    'count': '0',  'color': AppColors.navyDeep,  'status': 'لا يوجد'},
    {'icon': '🚶', 'label': 'طلبات استقالة', 'count': '1',  'color': AppColors.error,     'status': 'معلقة'},
    {'icon': '✈️', 'label': 'مهام رسمية',    'count': '4',  'color': AppColors.navyLight, 'status': 'معلقة'},
    {'icon': '💻', 'label': 'طلبات أصول',    'count': '2',  'color': AppColors.g600,      'status': 'معلقة'},
  ];

  @override
  Widget build(BuildContext context) {
    final pending = AdminData.requests.where((r) => r.status == 'pending').length;
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
              GestureDetector(
                onTap: () => context.push('/all-requests'),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)))),
              Expanded(child: Column(children: [
                Text('إدارة الطلبات', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('$pending طلب يحتاج مراجعة', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 12),
            // Summary strip
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _strip('31', 'معلق',  AppColors.warning),
                _strip('12', 'هذا الأسبوع', AppColors.goldLight),
                _strip('18', 'معتمد', AppColors.tealLight),
                _strip('5',  'مرفوض', AppColors.error),
              ])),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            SectionHeader(title: 'الطلبات العاجلة',
              actionLabel: 'عرض الكل', onAction: () => context.push('/approvals')),
            ...AdminData.requests.where((r) => r.priority == 'high' && r.status == 'pending').map((r) =>
              RequestCard(id: r.id, empName: r.empName, dept: r.dept, type: r.type,
                date: r.submittedDate, status: r.status, priority: r.priority,
                onTap: () => context.push('/request-detail'))),
            const SizedBox(height: 8),
            SectionHeader(title: 'حسب الفئة'),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6,
              children: _cats.map((c) => GestureDetector(
                onTap: () => context.push('/all-requests'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                    boxShadow: AppShadows.card),
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      StatusBadge(text: c['status'] as String,
                        type: c['status'] == 'لا يوجد' ? 'navy' : 'pending'),
                      const Spacer(),
                      Text(c['count'] as String, style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 22, fontWeight: FontWeight.w900,
                        color: c['color'] as Color, height: 1)),
                    ]),
                    const Spacer(),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Container(width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: (c['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(c['icon'] as String,
                          style: const TextStyle(fontSize: 20)))),
                      const SizedBox(height: 4),
                      Text(c['label'] as String, style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tx2),
                        textAlign: TextAlign.right, maxLines: 2),
                    ]),
                  ]),
                ),
              )).toList(),
            ),
          ]),
        )),
      ]),
    );
  }
  Widget _strip(String v, String l, Color c) => Column(children: [
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: c, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white60)),
  ]);
}

// ── All Requests List ─────────────────────────────────────
class AllRequestsScreen extends StatefulWidget {
  const AllRequestsScreen({super.key});
  @override State<AllRequestsScreen> createState() => _AllRequestsState();
}
class _AllRequestsState extends State<AllRequestsScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Column(children: [
      AdminAppBar(title: 'إدارة الطلبات', subtitle: 'جميع الطلبات',
        onBack: () => context.pop()),
      FilterBar(tabs: ['الكل','معلق','معتمد','مرفوض','مكتمل'],
        selected: _tab, onSelect: (i) => setState(() => _tab = i)),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: AdminData.requests.length,
        itemBuilder: (_, i) {
          final r = AdminData.requests[i];
          return RequestCard(
            id: r.id, empName: r.empName, dept: r.dept, type: r.type,
            date: r.submittedDate, status: r.status, priority: r.priority,
            onTap: () => context.push('/request-detail'));
        },
      )),
    ]),
  );
}

// ── Request Detail ────────────────────────────────────────
class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key});
  @override State<RequestDetailScreen> createState() => _RequestDetailState();
}
class _RequestDetailState extends State<RequestDetailScreen> {
  String? _decision;
  final _noteCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final r = AdminData.requests.first;
    if (_decision != null) return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل الطلب', onBack: () => context.pop()),
        Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(
              color: _decision == 'approve' ? AppColors.successSoft : AppColors.errorSoft,
              shape: BoxShape.circle),
            child: Center(child: Icon(
              _decision == 'approve' ? Icons.check : Icons.close,
              color: _decision == 'approve' ? AppColors.success : AppColors.error, size: 40))),
          const SizedBox(height: 16),
          Text(_decision == 'approve' ? '✅ تمت الموافقة' : '❌ تم الرفض',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('تم إشعار الموظف بالقرار', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.tx3)),
          const SizedBox(height: 24),
          OutlineBtn(text: 'رجوع للطلبات', onTap: () => context.pop(), fullWidth: false),
        ]))),
      ]));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل الطلب', subtitle: r.id,
          onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Employee header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: AppColors.navyGradient,
                borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.navy),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  StatusBadge(text: r.status == 'pending' ? 'قيد المراجعة' : r.status,
                    type: r.status, dot: true),
                  const SizedBox(height: 4),
                  PriorityBadge(priority: r.priority),
                ]),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(r.empName, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('${r.dept} · ${r.empId}', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white60)),
                  const SizedBox(height: 6),
                  Text(r.type, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldLight)),
                ])),
                const SizedBox(width: 10),
                AdminAvatar(initials: r.empName.characters.first, size: 48, fontSize: 18),
              ]),
            ),
            const SizedBox(height: 14),
            AppCard(mb: 14, child: Column(children: [
              Align(alignment: Alignment.centerRight, child: Text('تفاصيل الطلب',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),
              InfoRow(label: 'رقم الطلب',       value: r.id,              icon: '🔖'),
              InfoRow(label: 'نوع الطلب',       value: r.type,            icon: '📋'),
              InfoRow(label: 'تاريخ التقديم',   value: r.submittedDate,   icon: '📅'),
              InfoRow(label: 'الإدارة',          value: r.dept,            icon: '🏢'),
              InfoRow(label: 'التفاصيل',         value: r.details,         icon: '📝', border: false),
            ])),
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('مسار الموافقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
              const SizedBox(height: 14),
              const TimelineWidget(steps: [
                TLStep(label: 'تقديم الطلب', sub: 'الموظف — منذ ساعتين', done: true),
                TLStep(label: 'مراجعة المدير المباشر', sub: 'جارٍ الآن...', active: true),
                TLStep(label: 'اعتماد إدارة الموارد البشرية'),
                TLStep(label: 'إغلاق الطلب'),
              ]),
            ])),
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('تعليق / ملاحظة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              TextField(controller: _noteCtrl, maxLines: 3,
                textDirection: TextDirection.rtl, style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: fieldDec('أضف تعليقك على الطلب...')),
            ])),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: DangerBtn(text: '✗ رفض', onTap: () => setState(() => _decision = 'reject'))),
          const SizedBox(width: 10),
          Expanded(child: OutlineBtn(text: '↩ إعادة', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: TealBtn(text: '✓ اعتماد', onTap: () => setState(() => _decision = 'approve'))),
        ])),
      ]),
    );
  }
}

// ── Approvals Inbox ───────────────────────────────────────
class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});
  @override State<ApprovalsScreen> createState() => _ApprovalsState();
}
class _ApprovalsState extends State<ApprovalsScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final pending = AdminData.requests.where((r) => r.status == 'pending').toList();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'صندوق الموافقات',
          subtitle: '${pending.length} طلبات معلقة',
          onBack: () => context.pop()),
        FilterBar(tabs: ['الكل','عاجل','عادي','منخفض'],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: pending.length,
          itemBuilder: (_, i) {
            final r = pending[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard, borderRadius: BorderRadius.circular(18),
                boxShadow: AppShadows.card,
                border: Border(right: BorderSide(
                  color: r.priority == 'high' ? AppColors.error
                    : r.priority == 'normal' ? AppColors.warning : AppColors.g300,
                  width: 4))),
              child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    PriorityBadge(priority: r.priority),
                    const SizedBox(width: 6),
                    Text(r.submittedDate, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                  ]),
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(r.empName, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('${r.dept} · ${r.empId}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                    ]),
                    const SizedBox(width: 10),
                    AdminAvatar(initials: r.empName.characters.first, size: 38, fontSize: 14),
                  ]),
                ]),
                const SizedBox(height: 10),
                Container(width: double.infinity, padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(r.type, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
                    Text(r.details, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                  ])),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () => context.push('/request-detail'),
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: AppColors.navySoft,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.navyBorder)),
                      child: Center(child: Text('التفاصيل', style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyMid)))))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColors.error.withOpacity(0.4))),
                    child: Center(child: Text('✗ رفض', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error))))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(gradient: AppColors.tealGradient,
                      borderRadius: BorderRadius.circular(9), boxShadow: AppShadows.teal),
                    child: Center(child: Text('✓ اعتماد', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))))),
                ]),
              ])),
            );
          },
        )),
      ]),
    );
  }
}
