import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';
import '../../../shared/models/admin_models.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXPENSE-SPECIFIC WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseAmountCard extends StatelessWidget {
  final ExpenseRequest expense;
  final VoidCallback? onTap;
  const ExpenseAmountCard({super.key, required this.expense, this.onTap});

  Color get _statusColor {
    switch (expense.status) {
      case 'approved':  return AppColors.success;
      case 'rejected':  return AppColors.error;
      case 'returned':  return AppColors.warning;
      case 'pending':   return AppColors.navyMid;
      default:          return AppColors.g400;
    }
  }

  String get _statusLabel {
    switch (expense.status) {
      case 'approved':  return 'معتمد';
      case 'rejected':  return 'مرفوض';
      case 'returned':  return 'معاد للتعديل';
      case 'pending':   return 'قيد المراجعة';
      default:          return expense.status;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: expense.isHighValue
          ? Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5)
          : null),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              StatusBadge(text: _statusLabel,
                type: expense.status == 'approved' ? 'approved'
                  : expense.status == 'rejected' ? 'rejected'
                  : expense.status == 'returned' ? 'warning' : 'pending',
                dot: true),
              if (expense.isHighValue) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft, borderRadius: BorderRadius.circular(6)),
                  child: Text('💰 مبلغ عالٍ', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldDark))),
              ],
            ]),
            // Employee + type
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(expense.empName, style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 13, fontWeight: FontWeight.w700)),
                Text('${expense.dept} · ${expense.empId}', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.tx3)),
              ]),
              const SizedBox(width: 8),
              AdminAvatar(initials: expense.empName.characters.first, size: 36, fontSize: 14),
            ]),
          ]),
          const SizedBox(height: 10),
          // Amount + meta row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Category + ID
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(expense.categoryIcon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(expense.category, style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 11, color: AppColors.tx3)),
                ]),
                Text(expense.id, style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 10, color: AppColors.g400, letterSpacing: 0.5)),
              ]),
              // Amount
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(expense.submittedDate, style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 10, color: AppColors.tx3)),
                RichText(text: TextSpan(children: [
                  TextSpan(text: '${expense.currency} ', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
                  TextSpan(text: _formatAmount(expense.amount), style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 18, fontWeight: FontWeight.w900, color: _statusColor)),
                ])),
              ]),
            ]),
          ),
          if (!expense.hasAttachment) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningSoft, borderRadius: BorderRadius.circular(6)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('تنبيه: لا توجد فاتورة مرفقة', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.warningDark)),
                const SizedBox(width: 4),
                const Text('📎', style: TextStyle(fontSize: 12)),
              ])),
          ],
        ]),
      ),
    ),
  );

  String _formatAmount(double a) {
    if (a >= 1000) {
      final s = a.toStringAsFixed(0);
      return s.length > 3 ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}' : s;
    }
    return a.toStringAsFixed(0);
  }
}

class ExpenseCategoryCard extends StatelessWidget {
  final ExpenseCategory cat;
  final VoidCallback? onTap;
  const ExpenseCategoryCard({super.key, required this.cat, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          StatusBadge(text: cat.isActive ? 'نشط' : 'غير نشط',
            type: cat.isActive ? 'approved' : 'navy'),
          Text(cat.icon, style: const TextStyle(fontSize: 28)),
        ]),
        const SizedBox(height: 6),
        Text(cat.name, style: TextStyle(fontFamily: 'Cairo', 
          fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navyMid)),
        const SizedBox(height: 4),
        Text('${cat.requestCount} طلب', style: TextStyle(fontFamily: 'Cairo', 
          fontSize: 11, color: AppColors.tx3)),
        const SizedBox(height: 2),
        Text('SAR ${_fmt(cat.totalAmount)}', style: TextStyle(fontFamily: 'Cairo', 
          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tx2)),
      ]),
    ),
  );

  String _fmt(double a) {
    if (a >= 1000) {
      final s = a.toStringAsFixed(0);
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return a.toStringAsFixed(0);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. EXPENSES OVERVIEW SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpensesOverviewScreen extends StatelessWidget {
  const ExpensesOverviewScreen({super.key});

  static double _total(Iterable<ExpenseRequest> list) =>
    list.fold(0, (s, e) => s + e.amount);

  @override
  Widget build(BuildContext context) {
    final expenses  = AdminData.expenses;
    final pending   = expenses.where((e) => e.status == 'pending');
    final approved  = expenses.where((e) => e.status == 'approved');
    final rejected  = expenses.where((e) => e.status == 'rejected');
    final highValue = expenses.where((e) => e.isHighValue);
    final noAttach  = expenses.where((e) => !e.hasAttachment && e.status == 'pending');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 18, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => context.push('/expense-requests'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)))),
              Expanded(child: Column(children: [
                Text('إدارة المصروفات', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('${expenses.length} طلب هذا الشهر', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            // Total amount summary
            Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white10, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(children: [
                  Text('إجمالي المصروفات', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 11, color: Colors.white60)),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: 'SAR ', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 13, color: AppColors.goldLight)),
                    TextSpan(text: _fmtBig(_total(expenses)),
                      style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  ])),
                ]),
                Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.15)),
                Column(children: [
                  Text('معتمد', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                  Text('SAR ${_fmtBig(_total(approved))}', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.tealLight)),
                ]),
                Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.15)),
                Column(children: [
                  Text('معلق', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                  Text('SAR ${_fmtBig(_total(pending))}', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.warning)),
                ]),
              ]),
            ),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(children: [

            // Alerts
            if (noAttach.isNotEmpty) AlertBanner(
              message: '${noAttach.length} طلبات بدون مرفقات — تحتاج مراجعة',
              type: 'warning'),
            if (highValue.any((e) => e.status == 'pending')) AlertBanner(
              message: '${highValue.where((e) => e.status == 'pending').length} طلبات بمبالغ عالية معلقة',
              type: 'error'),

            // Quick KPI row
            SectionHeader(title: 'نظرة إجمالية'),
            Row(children: [
              _kpi('${pending.length}', 'معلق',  AppColors.warning),
              const SizedBox(width: 8),
              _kpi('${approved.length}', 'معتمد', AppColors.success),
              const SizedBox(width: 8),
              _kpi('${rejected.length}', 'مرفوض', AppColors.error),
              const SizedBox(width: 8),
              _kpi('${expenses.where((e) => e.status == 'returned').length}', 'معاد', AppColors.gold),
            ]),
            const SizedBox(height: 16),

            // Pending approvals
            SectionHeader(title: 'الطلبات المعلقة',
              actionLabel: 'عرض الكل',
              onAction: () => context.push('/expense-requests')),
            ...pending.take(3).map((e) => ExpenseAmountCard(expense: e,
              onTap: () => context.push('/expense-detail'))),
            const SizedBox(height: 6),

            // Categories summary
            SectionHeader(title: 'فئات المصروفات',
              actionLabel: 'إدارة الفئات',
              onAction: () => context.push('/expense-categories')),
            GridView.count(
              crossAxisCount: 4, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85,
              children: AdminData.expenseCategories.map((cat) => GestureDetector(
                onTap: () => context.push('/expense-requests'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.sm),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(cat.name, style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.tx2)),
                    Text('${cat.requestCount}', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
                  ]),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // Top spending chart placeholder
            SectionHeader(title: 'أكبر المصروفات — الشهر الحالي'),
            AppCard(mb: 16, child: Column(children: [
              // Bar chart
              SizedBox(height: 90, child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: AdminData.expenseCategories.take(6).map((cat) {
                  final maxAmt = AdminData.expenseCategories.fold(0.0,
                    (m, c) => c.totalAmount > m ? c.totalAmount : m);
                  return Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        height: (cat.totalAmount / maxAmt) * 70,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.navyGradient,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))),
                      const SizedBox(height: 4),
                      Text(cat.icon, style: const TextStyle(fontSize: 12)),
                    ]));
                }).toList(),
              )),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('الفئات الرئيسية', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.tx3)),
                Text('SAR ${_fmtBig(_total(AdminData.expenses))} إجمالي', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
              ]),
            ])),

            // Recent approved
            SectionHeader(title: 'آخر المعتمدة'),
            ...approved.take(2).map((e) => ExpenseAmountCard(expense: e,
              onTap: () => context.push('/expense-detail'))),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: OutlineBtn(text: '📊 التحليلات',
            onTap: () => context.push('/expense-analytics'))),
          const SizedBox(width: 10),
          Expanded(child: PrimaryBtn(text: '🔄 المتابعة',
            onTap: () => context.push('/expense-follow-up'))),
        ])),
      ]),
    );
  }

  Widget _kpi(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', 
        fontSize: 22, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
    ])));

  String _fmtBig(double a) {
    if (a >= 1000) {
      final s = a.toStringAsFixed(0);
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return a.toStringAsFixed(0);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. EXPENSE REQUESTS LIST SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseRequestsListScreen extends StatefulWidget {
  const ExpenseRequestsListScreen({super.key});
  @override State<ExpenseRequestsListScreen> createState() => _ExpRequestsState();
}
class _ExpRequestsState extends State<ExpenseRequestsListScreen> {
  int _tab = 0;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final all = AdminData.expenses;
    final filtered = all.where((e) {
      final matchSearch = _search.isEmpty ||
        e.empName.contains(_search) || e.id.contains(_search) ||
        e.category.contains(_search);
      final matchTab = _tab == 0 ||
        (_tab == 1 ? e.status == 'pending' :
         _tab == 2 ? e.status == 'approved' :
         _tab == 3 ? e.status == 'rejected' : e.status == 'returned');
      return matchSearch && matchTab;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'طلبات المصروفات',
          subtitle: '${all.length} طلب إجمالي',
          onBack: () => context.pop()),
        Container(color: AppColors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: TextField(textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            onChanged: (v) => setState(() => _search = v),
            decoration: fieldDec('ابحث: موظف، رقم، فئة...').copyWith(
              prefixIcon: const Icon(Icons.search, color: AppColors.g400, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
        FilterBar(tabs: ['الكل', 'معلق', 'معتمد', 'مرفوض', 'معاد'],
          selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        Expanded(child: filtered.isEmpty
          ? const EmptyState(icon: '💳', title: 'لا توجد طلبات',
              subtitle: 'لا توجد مصروفات تطابق معايير البحث')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: filtered.length,
              itemBuilder: (_, i) => ExpenseAmountCard(
                expense: filtered[i],
                onTap: () => context.push('/expense-detail')))),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. EXPENSE REQUEST DETAIL SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseRequestDetailScreen extends StatefulWidget {
  const ExpenseRequestDetailScreen({super.key});
  @override State<ExpenseRequestDetailScreen> createState() => _ExpDetailState();
}
class _ExpDetailState extends State<ExpenseRequestDetailScreen> {
  String? _decision;
  final _noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final e = AdminData.expenses.first;

    if (_decision != null) return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل المصروف', onBack: () => context.pop()),
        Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(
              color: _decision == 'approve' ? AppColors.successSoft : AppColors.errorSoft,
              shape: BoxShape.circle),
            child: Center(child: Icon(
              _decision == 'approve' ? Icons.check : Icons.close,
              color: _decision == 'approve' ? AppColors.success : AppColors.error, size: 40))),
          const SizedBox(height: 16),
          Text(_decision == 'approve' ? '✅ تم اعتماد المصروف' : '❌ تم رفض المصروف',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('تم إشعار الموظف بالقرار', style: TextStyle(fontFamily: 'Cairo', 
            fontSize: 13, color: AppColors.tx3)),
          const SizedBox(height: 24),
          OutlineBtn(text: 'رجوع للطلبات', fullWidth: false,
            onTap: () => context.pop()),
        ]))),
      ]));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل المصروف', subtitle: e.id,
          onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [

            // Hero amount card
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: e.isHighValue
                  ? const LinearGradient(begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.goldLight, AppColors.gold])
                  : AppColors.navyGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: e.isHighValue ? AppShadows.gold : AppShadows.navy),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  StatusBadge(text: 'قيد المراجعة', type: 'pending', dot: true),
                  if (e.isHighValue) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24, borderRadius: BorderRadius.circular(99)),
                    child: Text('💰 مبلغ عالٍ — يحتاج اعتماد مزدوج', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(e.categoryIcon, style: const TextStyle(fontSize: 36)),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(e.category, style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, color: Colors.white70)),
                    RichText(text: TextSpan(children: [
                      TextSpan(text: '${e.currency} ', style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 14, color: Colors.white70)),
                      TextSpan(text: '${e.amount.toStringAsFixed(0)}',
                        style: TextStyle(fontFamily: 'Cairo', 
                          fontSize: 36, fontWeight: FontWeight.w900,
                          color: Colors.white)),
                    ])),
                  ]),
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // Employee info
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('بيانات الموظف', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'اسم الموظف',   value: e.empName, icon: '👤'),
              InfoRow(label: 'رقم الموظف',   value: e.empId,   icon: '🔖'),
              InfoRow(label: 'الإدارة',       value: e.dept,    icon: '🏢', border: false),
            ])),

            // Expense details
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('تفاصيل المصروف', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'رقم الطلب',      value: e.id,           icon: '📋'),
              InfoRow(label: 'الفئة',           value: e.category,     icon: e.categoryIcon),
              InfoRow(label: 'المبلغ',          value: '${e.currency} ${e.amount.toStringAsFixed(0)}', icon: '💰'),
              InfoRow(label: 'تاريخ الصرف',    value: e.expenseDate,  icon: '📅'),
              InfoRow(label: 'تاريخ التقديم',  value: e.submittedDate, icon: '🕐'),
              if (e.projectRef != null)
                InfoRow(label: 'مشروع مرتبط', value: e.projectRef!,  icon: '🏗'),
              if (e.notes != null)
                InfoRow(label: 'الملاحظات',   value: e.notes!,       icon: '📝', border: false),
            ])),

            // Attachments
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (!e.hasAttachment) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft, borderRadius: BorderRadius.circular(6)),
                  child: Text('⚠️ لا توجد مرفقات', style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warningDark))),
                Text('الفواتير والمرفقات', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              if (!e.hasAttachment)
                const EmptyState(icon: '📎',
                  title: 'لا توجد فاتورة مرفقة',
                  subtitle: 'يجب طلب الفاتورة من الموظف قبل الاعتماد')
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.navySoft, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.navyBorder)),
                  child: Row(children: [
                    const Text('📄', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text('invoice_${e.id}.pdf', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, color: AppColors.navyMid, fontWeight: FontWeight.w600)),
                  ])),
            ])),

            // Approval timeline
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('مسار الاعتماد', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
              const SizedBox(height: 14),
              const TimelineWidget(steps: [
                TLStep(label: 'تقديم الطلب',         sub: 'الموظف — منذ 4 ساعات', done: true),
                TLStep(label: 'مراجعة المدير المباشر', sub: 'قيد المراجعة...',      active: true),
                TLStep(label: 'اعتماد إدارة المالية'),
                TLStep(label: 'إغلاق وسداد'),
              ]),
            ])),

            // Comment
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('تعليق / ملاحظة على القرار', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              TextField(controller: _noteCtrl, maxLines: 3,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: fieldDec('أضف ملاحظتك...')),
            ])),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: DangerBtn(text: '✗ رفض',
            onTap: () => setState(() => _decision = 'reject'))),
          const SizedBox(width: 8),
          Expanded(child: OutlineBtn(text: '↩ إعادة',
            onTap: () => setState(() => _decision = 'return'))),
          const SizedBox(width: 8),
          Expanded(child: TealBtn(text: '✓ اعتماد',
            onTap: () => setState(() => _decision = 'approve'))),
        ])),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. EXPENSE CATEGORIES SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseCategoriesScreen extends StatelessWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = AdminData.expenseCategories;
    final total = cats.fold(0.0, (s, c) => s + c.totalAmount);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'فئات المصروفات', subtitle: '${cats.length} فئات',
          onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Summary
            AppCard(mb: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('الإجمالي الشهري', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 12, color: AppColors.tx3)),
              RichText(text: TextSpan(children: [
                TextSpan(text: 'SAR ', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 14, color: AppColors.navyMid, fontWeight: FontWeight.w600)),
                TextSpan(text: _fmt(total), style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
              ])),
              const SizedBox(height: 12),
              // Distribution bars
              ...cats.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  SizedBox(width: 42, child: Text('${(c.totalAmount / total * 100).toInt()}%',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3))),
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.totalAmount / total,
                      backgroundColor: AppColors.g100,
                      valueColor: const AlwaysStoppedAnimation(AppColors.navyMid),
                      minHeight: 8))),
                  const SizedBox(width: 8),
                  SizedBox(width: 28, child: Text(c.icon,
                    style: const TextStyle(fontSize: 14))),
                ])),
              ),
            ])),

            // Category grid
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
              children: cats.map((cat) => ExpenseCategoryCard(
                cat: cat,
                onTap: () => context.push('/expense-requests'))).toList(),
            ),
          ]),
        )),
      ]),
    );
  }

  String _fmt(double a) {
    final s = a.toStringAsFixed(0);
    if (s.length > 3) return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    return s;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. EXPENSE ANALYTICS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseAnalyticsScreen extends StatelessWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = AdminData.expenses;
    final cats = AdminData.expenseCategories;
    final total = cats.fold(0.0, (s, c) => s + c.totalAmount);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 14, left: 18, right: 18),
          child: Row(children: [
            GestureDetector(onTap: () => context.pop(),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
            Expanded(child: Column(children: [
              Text('تحليلات المصروفات', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('مارس 2025', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.goldLight)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(9)),
              child: Text('📤 تصدير', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyDeep))),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(children: [

            // KPI Grid
            SectionHeader(title: 'مؤشرات المصروفات'),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
              children: [
                KpiCard(label: 'إجمالي الشهر',    value: _fmtK(total),
                  change: '+12% عن الشهر',  icon: '💰', isPositive: false, color: AppColors.navyMid),
                KpiCard(label: 'طلبات معلقة',     value: '${expenses.where((e) => e.status == 'pending').length}',
                  change: 'يحتاج مراجعة',   icon: '⏳', isPositive: false, color: AppColors.warning),
                KpiCard(label: 'معدل الاعتماد',   value: '75%',
                  change: '+5% عن الشهر',   icon: '✅', isPositive: true,  color: AppColors.success),
                KpiCard(label: 'مبالغ عالية',      value: '${expenses.where((e) => e.isHighValue).length}',
                  change: 'تحتاج اعتماد مزدوج', icon: '⚠️', isPositive: false, color: AppColors.error),
              ],
            ),
            const SizedBox(height: 16),

            // Monthly trend placeholder
            SectionHeader(title: 'الاتجاه الشهري للمصروفات'),
            AppCard(mb: 16, child: Column(children: [
              SizedBox(height: 90, child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [65, 80, 55, 90, 70, 85, 100].asMap().entries.map((e) {
                  final isLast = e.key == 6;
                  return Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        height: e.value * 0.7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          gradient: isLast ? AppColors.goldGradient : null,
                          color: isLast ? null : AppColors.navySoft,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))),
                      const SizedBox(height: 4),
                      Text(['سب','أغ','سب','أك','نف','ديس','مار'][e.key],
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 8, color: AppColors.tx3)),
                    ]));
                }).toList(),
              )),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('مارس الحالي أعلى شهر', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, color: AppColors.tx3)),
                Text('SAR ${_fmtK(total)}', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
              ]),
            ])),

            // By category distribution
            SectionHeader(title: 'التوزيع حسب الفئة'),
            AppCard(mb: 16, child: Column(children: [
              ...cats.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('SAR ${_fmtK(c.totalAmount)}', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
                    Row(children: [
                      Text(c.name, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.tx2)),
                      const SizedBox(width: 6),
                      Text(c.icon, style: const TextStyle(fontSize: 14)),
                    ]),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.totalAmount / total,
                      backgroundColor: AppColors.g100,
                      valueColor: const AlwaysStoppedAnimation(AppColors.navyMid),
                      minHeight: 6)),
                ]),
              )),
            ])),

            // Top spending depts
            SectionHeader(title: 'أعلى الإدارات إنفاقاً'),
            AppCard(mb: 16, child: Column(children: [
              ...['تقنية المعلومات', 'الموارد البشرية', 'التطوير والابتكار', 'المالية', 'المبيعات']
                .asMap().entries.map((e) {
                  final amounts = [16300.0, 11200.0, 6750.0, 9100.0, 1200.0];
                  final maxAmt = amounts.reduce((a, b) => a > b ? a : b);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      SizedBox(width: 60, child: Text('SAR ${_fmtK(amounts[e.key])}',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3))),
                      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: amounts[e.key] / maxAmt,
                          backgroundColor: AppColors.g100,
                          valueColor: AlwaysStoppedAnimation(
                            [AppColors.navyMid, AppColors.teal, AppColors.gold,
                             AppColors.success, AppColors.warning][e.key]),
                          minHeight: 8))),
                      const SizedBox(width: 8),
                      SizedBox(width: 80, child: Text(e.value, style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 10, color: AppColors.tx2), textAlign: TextAlign.right)),
                    ]));
              }),
            ])),

            // Rejected summary
            SectionHeader(title: 'المرفوضة والمعادة'),
            ...expenses.where((e) => e.status == 'rejected' || e.status == 'returned')
              .take(3).map((e) => ExpenseAmountCard(expense: e,
                onTap: () => context.push('/expense-detail'))),
          ]),
        )),
      ]),
    );
  }

  String _fmtK(double a) {
    if (a >= 1000) {
      final s = a.toStringAsFixed(0);
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return a.toStringAsFixed(0);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. EXPENSE FOLLOW-UP SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseFollowUpScreen extends StatelessWidget {
  const ExpenseFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pending   = AdminData.expenses.where((e) => e.status == 'pending').toList();
    final noAttach  = AdminData.expenses.where((e) => !e.hasAttachment && e.status == 'pending').toList();
    final returned  = AdminData.expenses.where((e) => e.status == 'returned').toList();
    final highVal   = AdminData.expenses.where((e) => e.isHighValue && e.status == 'pending').toList();

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
                Text('متابعة المصروفات', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('${pending.length} معلق · ${noAttach.length} بدون مرفقات',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _pill('${pending.length}',  'معلق',         AppColors.warning),
              const SizedBox(width: 8),
              _pill('${highVal.length}',  'مبالغ عالية',  AppColors.error),
              const SizedBox(width: 8),
              _pill('${noAttach.length}', 'بدون مرفقات', AppColors.gold),
              const SizedBox(width: 8),
              _pill('${returned.length}', 'معاد',         AppColors.navyBright),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(children: [
            // High value pending
            if (highVal.isNotEmpty) ...[
              AlertBanner(
                message: '${highVal.length} طلبات بمبالغ عالية تنتظر اعتماد مزدوج',
                type: 'error'),
              SectionHeader(title: '💰 مبالغ عالية — أولوية'),
              ...highVal.map((e) => ExpenseAmountCard(expense: e,
                onTap: () => context.push('/expense-detail'))),
              const SizedBox(height: 10),
            ],

            // No attachment alert
            if (noAttach.isNotEmpty) ...[
              SectionHeader(title: '📎 بدون مرفقات — يحتاج متابعة'),
              ...noAttach.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.sm,
                  border: Border.all(color: AppColors.warning.withOpacity(0.4))),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('📎', style: TextStyle(fontSize: 18)),
                    Text('لا توجد فاتورة', style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w700)),
                  ]),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(e.empName, style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('${e.category} · ${e.currency} ${e.amount.toStringAsFixed(0)}',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                  ])),
                  const SizedBox(width: 8),
                  AdminAvatar(initials: e.empName.characters.first, size: 36, fontSize: 14),
                ])),
              ),
              const SizedBox(height: 10),
            ],

            // Returned items
            if (returned.isNotEmpty) ...[
              SectionHeader(title: '↩ معادة للتعديل'),
              ...returned.map((e) => ExpenseAmountCard(expense: e,
                onTap: () => context.push('/expense-detail'))),
              const SizedBox(height: 10),
            ],

            // All pending
            SectionHeader(title: '⏳ جميع المعلقة'),
            ...pending.map((e) => ExpenseAmountCard(expense: e,
              onTap: () => context.push('/expense-detail'))),
          ]),
        )),
      ]),
    );
  }

  Widget _pill(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 7),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', 
        fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', 
        fontSize: 9, color: Colors.white70), textAlign: TextAlign.center),
    ])));
}
