import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';
import 'package:go_router/go_router.dart';

class ReportsKpiScreen extends StatelessWidget {
  const ReportsKpiScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
              Text('التقارير ومؤشرات الأداء', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('مارس 2025 — تحديث يومي', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.goldLight)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(9)),
              child: Text('📤 تصدير', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyDeep))),
          ]),
        ]),
      ),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
        child: Column(children: [

          // ── KPI Grid ──────────────────────────────────────
          SectionHeader(title: 'مؤشرات الأداء الرئيسية — الشهر'),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
            children: AdminData.kpis.map((k) => KpiCard(
              label: k.label, value: k.value, change: k.change,
              icon: k.icon, isPositive: k.isPositive, color: k.color)).toList(),
          ),
          const SizedBox(height: 16),

          // ── Attendance Trend Chart Placeholder ─────────────
          SectionHeader(title: 'اتجاه الحضور — أسبوعي'),
          AppCard(mb: 16, child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                _legend(AppColors.success, 'حاضر'),
                const SizedBox(width: 12),
                _legend(AppColors.warning, 'متأخر'),
                const SizedBox(width: 12),
                _legend(AppColors.error, 'غائب'),
              ]),
              Text('مارس 2025', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.tx3)),
            ]),
            const SizedBox(height: 16),
            // Attendance bar chart
            SizedBox(height: 100, child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...[
                  [88, 8, 4], [91, 6, 3], [86, 9, 5], [94, 4, 2],
                  [89, 7, 4], [92, 5, 3], [87, 8, 5],
                ].asMap().entries.map((e) {
                  final i = e.key;
                  final bars = e.value;
                  final labels = ['أ1', 'إ1', 'ث1', 'أر1', 'خ1', 'أ2', 'إ2'];
                  return Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(alignment: Alignment.bottomCenter, children: [
                        Container(height: bars[0] * 0.8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
                        Container(height: bars[1] * 0.8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.5),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
                      ]),
                      const SizedBox(height: 4),
                      Text(labels[i], style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 8, color: AppColors.tx3)),
                    ]));
                }),
              ],
            )),
          ])),

          // ── Leave Analysis ────────────────────────────────
          SectionHeader(title: 'تحليل الإجازات — الشهر'),
          AppCard(mb: 16, child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _circStat('42', 'يوم إجازة', AppColors.navyMid),
              _circStat('11', 'موظف الآن', AppColors.teal),
              _circStat('8', 'طلب معلق', AppColors.warning),
              _circStat('3', 'مرفوض', AppColors.error),
            ]),
            const Divider(height: 20, color: AppColors.g100),
            ...['سنوية', 'مرضية', 'طارئة'].asMap().entries.map((e) {
              final labels = ['سنوية', 'مرضية', 'طارئة'];
              final values = [0.65, 0.25, 0.10];
              final colors = [AppColors.navyMid, AppColors.teal, AppColors.warning];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${(values[e.key] * 100).toInt()}%', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 11, fontWeight: FontWeight.w700, color: colors[e.key])),
                    Text(labels[e.key], style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, color: AppColors.tx2)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: values[e.key],
                      backgroundColor: AppColors.g100,
                      valueColor: AlwaysStoppedAnimation(colors[e.key]),
                      minHeight: 6)),
                ]),
              );
            }),
          ])),

          // ── Tasks Completion ──────────────────────────────
          SectionHeader(title: 'إنجاز المهام — حسب الإدارة'),
          AppCard(mb: 16, child: Column(children: [
            ...AdminData.departments.map((d) {
              final perfColor = d.performanceScore >= 90 ? AppColors.success
                : d.performanceScore >= 75 ? AppColors.warning : AppColors.error;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${d.performanceScore.toInt()}%', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, fontWeight: FontWeight.w800, color: perfColor)),
                    Text(d.name.replaceFirst('إدارة ', ''), style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, color: AppColors.tx2), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: d.performanceScore / 100,
                      backgroundColor: AppColors.g100,
                      valueColor: AlwaysStoppedAnimation(perfColor),
                      minHeight: 8)),
                ]));
            }),
          ])),

          // ── Requests Analysis ─────────────────────────────
          SectionHeader(title: 'تحليل الطلبات'),
          AppCard(mb: 16, child: Column(children: [
            Row(children: [
              _reqStat('31', 'معلق',   AppColors.warning),
              _divider(),
              _reqStat('18', 'معتمد',  AppColors.success),
              _divider(),
              _reqStat('5',  'مرفوض', AppColors.error),
              _divider(),
              _reqStat('54', 'إجمالي', AppColors.navyMid),
            ]),
            const SizedBox(height: 14),
            // Requests by type
            ...['طلبات إجازة', 'تصحيح حضور', 'مطالبات مصاريف', 'مهام رسمية', 'أخرى'].asMap().entries.map((e) {
              final bars = [0.45, 0.20, 0.15, 0.12, 0.08];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  SizedBox(width: 32, child: Text(
                    '${(bars[e.key] * 100).toInt()}%',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3))),
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: bars[e.key],
                      backgroundColor: AppColors.g100,
                      valueColor: const AlwaysStoppedAnimation(AppColors.navyMid),
                      minHeight: 8))),
                  const SizedBox(width: 8),
                  SizedBox(width: 100, child: Text(
                    ['طلبات إجازة', 'تصحيح حضور', 'مطالبات مصاريف', 'مهام رسمية', 'أخرى'][e.key],
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx2),
                    textAlign: TextAlign.right)),
                ]));
            }),
          ])),

          // ── Projects & Expenses in Reports ───────────────
          SectionHeader(title: 'مؤشرات المشاريع والمصروفات'),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => context.push('/project-analytics'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.card,
                  border: const Border(bottom: BorderSide(color: AppColors.navyMid, width: 3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('🏗', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text('6', style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
                  Text('مشاريع إجمالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
                  const SizedBox(height: 4),
                  Text('2 متأخرة → تفاصيل', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navyLight)),
                ])))),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => context.push('/expense-analytics'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.card,
                  border: const Border(bottom: BorderSide(color: AppColors.gold, width: 3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('💰', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text('SAR 220K', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.gold)),
                  Text('إجمالي المصروفات', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
                  const SizedBox(height: 4),
                  Text('3 معلقة → مراجعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldDark)),
                ])))),
          ]),
          const SizedBox(height: 16),

          // ── Export Buttons ────────────────────────────────
          SectionHeader(title: 'تصدير التقارير'),
          ...['تقرير الحضور الشهري', 'تقرير الإجازات', 'تقرير المهام والأداء', 'ملخص الطلبات'].map((label) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.sm),
              child: Row(children: [
                Row(children: [
                  const Text('📤', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text('PDF / Excel', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 11, color: AppColors.g400)),
                ]),
                Expanded(child: Text(label, style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyMid),
                  textAlign: TextAlign.right)),
              ]),
            )),
        ]),
      )),
    ]),
  );

  Widget _legend(Color c, String l) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
  ]);

  Widget _circStat(String v, String l, Color c) => Column(children: [
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: c, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3, height: 1.3), textAlign: TextAlign.center),
  ]);

  Widget _reqStat(String v, String l, Color c) => Expanded(child: Column(children: [
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: c, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
  ]));

  Widget _divider() => Container(width: 1, height: 36, color: AppColors.g100);
}
