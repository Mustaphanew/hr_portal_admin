import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../data/models/report_models.dart';

class ReportsKpiScreen extends ConsumerWidget {
  const ReportsKpiScreen({super.key});

  // Default icon/color mapping for KPIs by index
  static const _kpiIcons = ['👥', '✅', '📋', '⚠️', '🌴', '📈'];
  static const _kpiColors = [
    AppColors.navyMid,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
    AppColors.teal,
    AppColors.gold,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(reportsKpisProvider);
    final attendance = ref.watch(attendanceTrendProvider);
    final leave = ref.watch(leaveAnalysisProvider);
    final tasks = ref.watch(taskCompletionProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // ── Header ──────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 16, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 17))),
              Expanded(child: Column(children: [
                Text('التقارير ومؤشرات الأداء',
                  style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: Colors.white)),
                Text('تحديث يومي',
                  style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 11, color: AppColors.goldLight)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(9)),
                child: Text('📤 تصدير',
                  style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.navyDeep))),
            ]),
          ]),
        ),

        // ── Body ────────────────────────────────────────────────
        Expanded(child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(reportsKpisProvider);
            ref.invalidate(attendanceTrendProvider);
            ref.invalidate(leaveAnalysisProvider);
            ref.invalidate(taskCompletionProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
            child: Column(children: [

              // ── KPI Grid ────────────────────────────────────────
              SectionHeader(title: 'مؤشرات الأداء الرئيسية — الشهر'),
              kpis.when(
                data: (items) => GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: items.asMap().entries.map((e) {
                    final i = e.key;
                    final k = e.value;
                    return KpiCard(
                      label: k.label,
                      value: _formatKpiValue(k.value),
                      change: k.change != null
                          ? '${k.change! >= 0 ? "+" : ""}${k.change!.toStringAsFixed(1)}%'
                          : '',
                      icon: i < _kpiIcons.length ? _kpiIcons[i] : '📊',
                      isPositive: k.isPositive,
                      color: i < _kpiColors.length
                          ? _kpiColors[i]
                          : AppColors.navyMid,
                    );
                  }).toList(),
                ),
                loading: () => const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator())),
                error: (e, _) => _errorCard('تعذر تحميل مؤشرات الأداء', e),
              ),
              const SizedBox(height: 16),

              // ── Attendance Trend ────────────────────────────────
              SectionHeader(title: 'اتجاه الحضور — شهري'),
              attendance.when(
                data: (months) => AppCard(
                  mb: 16,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          _legend(AppColors.success, 'حاضر'),
                          const SizedBox(width: 12),
                          _legend(AppColors.warning, 'متأخر'),
                          const SizedBox(width: 12),
                          _legend(AppColors.error, 'غائب'),
                        ]),
                        Text('${months.length} شهر',
                          style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 11, color: AppColors.tx3)),
                      ]),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: months.map((m) {
                          return Expanded(child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Attendance bar
                                Container(
                                  height: m.attendanceRate * 0.9,
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withOpacity(0.25),
                                    borderRadius:
                                        const BorderRadius.vertical(
                                      top: Radius.circular(4)))),
                                // Late bar
                                Container(
                                  height: m.lateRate * 0.9,
                                  decoration: BoxDecoration(
                                    color: AppColors.warning
                                        .withOpacity(0.6),
                                    borderRadius:
                                        const BorderRadius.vertical(
                                      top: Radius.circular(3)))),
                                // Absent bar
                                Container(
                                  height: m.absentRate * 0.9,
                                  decoration: BoxDecoration(
                                    color: AppColors.error
                                        .withOpacity(0.6),
                                    borderRadius:
                                        const BorderRadius.vertical(
                                      top: Radius.circular(3)))),
                                const SizedBox(height: 4),
                                Text(m.month,
                                  style: TextStyle(fontFamily: 'Cairo',
                                    fontSize: 8, color: AppColors.tx3),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              ]),
                          ));
                        }).toList(),
                      ),
                    ),
                  ]),
                ),
                loading: () => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator())),
                error: (e, _) => _errorCard('تعذر تحميل بيانات الحضور', e),
              ),

              // ── Leave Analysis ──────────────────────────────────
              SectionHeader(title: 'تحليل الإجازات — حسب النوع'),
              leave.when(
                data: (data) {
                  final totalDays = data.byType.fold<int>(
                      0, (s, t) => s + t.totalDays);
                  final totalCount = data.byType.fold<int>(
                      0, (s, t) => s + t.count);
                  final leaveColors = [
                    AppColors.navyMid,
                    AppColors.teal,
                    AppColors.warning,
                    AppColors.error,
                    AppColors.gold,
                    AppColors.success,
                  ];
                  return Column(children: [
                    // Summary stats
                    AppCard(
                      mb: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _circStat('$totalDays', 'يوم إجازة',
                            AppColors.navyMid),
                          _circStat('$totalCount', 'طلب إجازة',
                            AppColors.teal),
                          _circStat(
                            '${data.byType.length}', 'نوع',
                            AppColors.warning),
                        ]),
                    ),
                    // By type bars
                    AppCard(
                      mb: 12,
                      child: Column(
                        children: data.byType.asMap().entries.map((e) {
                          final i = e.key;
                          final t = e.value;
                          final ratio = totalDays > 0
                              ? t.totalDays / totalDays
                              : 0.0;
                          final c = leaveColors[i % leaveColors.length];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${(ratio * 100).toInt()}% · ${t.totalDays} يوم',
                                    style: TextStyle(fontFamily: 'Cairo',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: c)),
                                  Text(t.type,
                                    style: TextStyle(fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: AppColors.tx2)),
                                ]),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  backgroundColor: AppColors.g100,
                                  valueColor:
                                      AlwaysStoppedAnimation(c),
                                  minHeight: 6)),
                            ]),
                          );
                        }).toList(),
                      ),
                    ),
                    // By month
                    if (data.byMonth.isNotEmpty) ...[
                      SectionHeader(
                        title: 'الإجازات — حسب الشهر'),
                      AppCard(
                        mb: 16,
                        child: Column(
                          children: data.byMonth.map((m) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                SizedBox(
                                  width: 48,
                                  child: Text('${m.totalDays} يوم',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navyMid))),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: totalDays > 0
                                          ? m.totalDays / totalDays
                                          : 0,
                                      backgroundColor: AppColors.g100,
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                              AppColors.teal),
                                      minHeight: 7))),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: Text(m.month,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      color: AppColors.tx2),
                                    textAlign: TextAlign.right)),
                              ]),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ]);
                },
                loading: () => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator())),
                error: (e, _) =>
                    _errorCard('تعذر تحميل بيانات الإجازات', e),
              ),

              // ── Task Completion ─────────────────────────────────
              SectionHeader(title: 'إنجاز المهام — حسب الإدارة'),
              tasks.when(
                data: (depts) => Column(
                  children: depts.map((d) {
                    final perfColor = d.completionRate >= 90
                        ? AppColors.success
                        : d.completionRate >= 75
                            ? AppColors.warning
                            : AppColors.error;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.card),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${d.completionRate.toInt()}%',
                                style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: perfColor)),
                              Text(d.department,
                                style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tx2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            ]),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: d.completionRate / 100,
                              backgroundColor: AppColors.g100,
                              valueColor:
                                  AlwaysStoppedAnimation(perfColor),
                              minHeight: 8)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              _taskStat('${d.completed}', 'مكتمل',
                                AppColors.success),
                              _taskStat('${d.inProgress}', 'قيد التنفيذ',
                                AppColors.warning),
                              _taskStat('${d.overdue}', 'متأخر',
                                AppColors.error),
                              _taskStat('${d.total}', 'إجمالي',
                                AppColors.navyMid),
                            ]),
                        ]),
                    );
                  }).toList(),
                ),
                loading: () => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator())),
                error: (e, _) =>
                    _errorCard('تعذر تحميل بيانات المهام', e),
              ),
              const SizedBox(height: 16),

              // ── Projects & Expenses ─────────────────────────────
              SectionHeader(title: 'مؤشرات المشاريع والمصروفات'),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => context.push('/project-analytics'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.card,
                      border: const Border(
                        bottom: BorderSide(
                          color: AppColors.navyMid, width: 3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('🏗', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 6),
                        Text('المشاريع',
                          style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: AppColors.navyMid)),
                        Text('عرض التفاصيل',
                          style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.navyLight)),
                      ])))),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(
                  onTap: () => context.push('/expense-analytics'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.card,
                      border: const Border(
                        bottom: BorderSide(
                          color: AppColors.gold, width: 3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 6),
                        Text('المصروفات',
                          style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: AppColors.gold)),
                        Text('عرض التفاصيل',
                          style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.goldDark)),
                      ])))),
              ]),
              const SizedBox(height: 16),

              // ── Export Buttons ──────────────────────────────────
              SectionHeader(title: 'تصدير التقارير'),
              ...['تقرير الحضور الشهري', 'تقرير الإجازات',
                   'تقرير المهام والأداء', 'ملخص الطلبات']
                  .map((label) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.sm),
                child: Row(children: [
                  Row(children: [
                    const Text('📤', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('PDF / Excel',
                      style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 11, color: AppColors.g400)),
                  ]),
                  Expanded(child: Text(label,
                    style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.navyMid),
                    textAlign: TextAlign.right)),
                ]),
              )),
            ]),
          ),
        )),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  static String _formatKpiValue(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  Widget _legend(Color c, String l) => Row(children: [
    Container(width: 10, height: 10,
      decoration: BoxDecoration(
        color: c, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(l, style: TextStyle(fontFamily: 'Cairo',
      fontSize: 10, color: AppColors.tx3)),
  ]);

  Widget _circStat(String v, String l, Color c) =>
      Column(children: [
        Text(v, style: TextStyle(fontFamily: 'Cairo',
          fontSize: 22, fontWeight: FontWeight.w900,
          color: c, height: 1.1)),
        Text(l, style: TextStyle(fontFamily: 'Cairo',
          fontSize: 10, color: AppColors.tx3, height: 1.3),
          textAlign: TextAlign.center),
      ]);

  Widget _taskStat(String v, String l, Color c) =>
      Column(children: [
        Text(v, style: TextStyle(fontFamily: 'Cairo',
          fontSize: 14, fontWeight: FontWeight.w800, color: c)),
        Text(l, style: TextStyle(fontFamily: 'Cairo',
          fontSize: 9, color: AppColors.tx3)),
      ]);

  Widget _errorCard(String msg, [Object? error]) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.error.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.error.withOpacity(0.3))),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text(msg, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 13, color: AppColors.error)),
          ]),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text('$error', style: TextStyle(fontFamily: 'Cairo',
            fontSize: 10, color: AppColors.error.withOpacity(0.7)),
            textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ]),
  );
}
