import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});
  @override State<FollowUpScreen> createState() => _FollowUpState();
}
class _FollowUpState extends State<FollowUpScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final items = AdminData.followUpItems;
    final overdue    = items.where((f) => f.isOverdue).length;
    final escalated  = items.where((f) => f.isEscalated).length;
    final inProgress = items.where((f) => f.status == 'in_progress').length;
    final pending    = items.where((f) => f.status == 'pending').length;
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
              const SizedBox(width: 36),
              Expanded(child: Column(children: [
                Text('لوحة المتابعة', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('${items.length} بنود تحتاج متابعة', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _pill('متأخر', '$overdue',   AppColors.error,   AppColors.errorSoft.withOpacity(0.3)),
              const SizedBox(width: 8),
              _pill('مُصعَّد', '$escalated', AppColors.warningDark, AppColors.warningSoft.withOpacity(0.3)),
              const SizedBox(width: 8),
              _pill('جارٍ',   '$inProgress', AppColors.tealLight, AppColors.tealSoft.withOpacity(0.3)),
              const SizedBox(width: 8),
              _pill('معلق',   '$pending',    AppColors.goldLight, AppColors.goldSoft.withOpacity(0.3)),
            ]),
          ]),
        ),
        FilterBar(tabs: ['الكل','متأخر','مُصعَّد','جارٍ','معلق'],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (overdue > 0 || escalated > 0)
              AlertBanner(
                message: '$overdue بنود متأخرة · $escalated مُصعَّدة — يحتاج إجراء فوري',
                type: 'error'),
            ...items.map((f) => FollowUpCard(
              id: f.id, title: f.title, responsible: f.responsible,
              dept: f.dept, dueDate: f.dueDate, status: f.status,
              isOverdue: f.isOverdue, isEscalated: f.isEscalated,
              onTap: () => context.push('/follow-up-detail'))),
          ],
        )),
      ]),
    );
  }
  Widget _pill(String l, String v, Color fg, Color bg) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: fg.withOpacity(0.4))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: fg, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
    ])));
}

// ── Follow-Up Detail ──────────────────────────────────────
class FollowUpDetailScreen extends StatelessWidget {
  const FollowUpDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final f = AdminData.followUpItems.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل المتابعة', subtitle: f.id,
          onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            if (f.isOverdue) const AlertBanner(message: 'هذا البند تجاوز الموعد النهائي — يحتاج إجراء عاجل', type: 'error'),
            if (f.isEscalated) const AlertBanner(message: 'تم تصعيد هذا البند للإدارة العليا', type: 'warning'),
            AppCard(mb: 14, child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  if (f.isEscalated) ...[
                    Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(6)),
                      child: Text('🚨 مُصعَّد', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error))),
                    const SizedBox(width: 6),
                  ],
                  StatusBadge(text: f.isOverdue ? 'متأخر' : 'جارٍ', type: f.isOverdue ? 'overdue' : 'teal', dot: true),
                ]),
                Flexible(child: Text(f.title, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right)),
              ]),
              const Divider(height: 20, color: AppColors.g100),
              InfoRow(label: 'المسؤول',      value: f.responsible, icon: '👤'),
              InfoRow(label: 'الإدارة',      value: f.dept,        icon: '🏢'),
              InfoRow(label: 'الموعد النهائي', value: f.dueDate,   icon: '📅'),
              InfoRow(label: 'النوع',         value: f.type,       icon: '📋'),
              InfoRow(label: 'الحالة',        value: f.status == 'overdue' ? 'متأخر' : f.status == 'in_progress' ? 'جارٍ' : 'معلق',
                icon: '🔄', border: false),
            ])),
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('سجل المتابعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
              const SizedBox(height: 14),
              const TimelineWidget(steps: [
                TLStep(label: 'إنشاء بند المتابعة', sub: '1 مارس 2025', done: true),
                TLStep(label: 'تعيين المسؤول', sub: '3 مارس 2025', done: true),
                TLStep(label: 'الموعد النهائي تجاوز', sub: '12 مارس — لا استجابة', active: true),
                TLStep(label: 'التصعيد للإدارة العليا'),
                TLStep(label: 'الإغلاق'),
              ]),
            ])),
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('إجراء المتابعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              TextField(maxLines: 3, textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: fieldDec('سجّل الإجراء المتخذ...')),
            ])),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: DangerBtn(text: '🚨 تصعيد', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: OutlineBtn(text: '↩ إعادة تكليف', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: TealBtn(text: '✓ أُغلق', onTap: () {})),
        ])),
      ]),
    );
  }
}
