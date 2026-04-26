import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/paginated_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../data/models/expense_models.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXPENSE-SPECIFIC WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseAmountCard extends StatelessWidget {
  final Expense expense;
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

  String statusLabel(BuildContext context) {
    switch (expense.status) {
      case 'approved':  return 'Approved'.tr(context);
      case 'rejected':  return 'Rejected'.tr(context);
      case 'returned':  return 'Returned'.tr(context);
      case 'pending':   return 'Under Review'.tr(context);
      default:          return expense.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.bgCard,
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
              StatusBadge(text: statusLabel(context),
                type: expense.status == 'approved' ? 'approved'
                  : expense.status == 'rejected' ? 'rejected'
                  : expense.status == 'returned' ? 'warning' : 'pending',
                dot: true),
              if (expense.isHighValue) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft, borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.payments_rounded, color: AppColors.goldDark, size: 12),
                    const SizedBox(width: 4),
                    Text('High amount'.tr(context), style: const TextStyle(fontFamily: 'Cairo',
                      fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldDark)),
                  ])),
              ],
            ]),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(expense.employee.name, style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 13, fontWeight: FontWeight.w700)),
                Text('${expense.employee.department} · ${expense.employee.code}', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: c.textMuted)),
              ]),
              const SizedBox(width: 8),
              AdminAvatar(initials: expense.employee.name.characters.first, size: 36, fontSize: 14),
            ]),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.bg, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  if (expense.categoryIcon != null)
                    Text(expense.categoryIcon!, style: const TextStyle(fontSize: 14)),
                  if (expense.categoryIcon != null) const SizedBox(width: 4),
                  Text(expense.category, style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 11, color: c.textMuted)),
                ]),
                Text('EXP-${expense.id}', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 10, color: c.gray400, letterSpacing: 0.5)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(expense.submittedDate, style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 10, color: c.textMuted)),
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
                Text('No invoice attached'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.warningDark)),
                const SizedBox(width: 4),
                const Icon(Icons.attach_file_rounded, color: AppColors.warningDark, size: 12),
              ])),
          ],
        ]),
      ),
    ),
  );
  }

  String _formatAmount(double a) {
    if (a >= 1000) {
      final s = a.toStringAsFixed(0);
      return s.length > 3 ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}' : s;
    }
    return a.toStringAsFixed(0);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

String _fmtBig(double a) {
  if (a >= 1000) {
    final s = a.toStringAsFixed(0);
    return s.length > 3 ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}' : s;
  }
  return a.toStringAsFixed(0);
}

double _totalAmount(Iterable<Expense> list) =>
  list.fold(0.0, (s, e) => s + e.amount);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. EXPENSES OVERVIEW SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpensesOverviewScreen extends ConsumerWidget {
  const ExpensesOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final asyncExpenses = ref.watch(paginatedExpensesProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: asyncExpenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, color: AppColors.error)),
            const SizedBox(height: 8),
            OutlineBtn(text: 'Retry'.tr(context), fullWidth: false,
              onTap: () => ref.invalidate(paginatedExpensesProvider)),
          ],
        )),
        data: (paginated) {
          final expenses  = paginated.items;
          final pending   = expenses.where((e) => e.status == 'pending');
          final approved  = expenses.where((e) => e.status == 'approved');
          final rejected  = expenses.where((e) => e.status == 'rejected');
          final highValue = expenses.where((e) => e.isHighValue);
          final noAttach  = expenses.where((e) => !e.hasAttachment && e.status == 'pending');

          return Column(children: [
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
                      child: Text('View all'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)))),
                  Expanded(child: Column(children: [
                    Text('Expense Management'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('requests_this_month'.tr(context, params: {'count': '${expenses.length}'}), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, color: AppColors.goldLight)),
                  ])),
                  const SizedBox(width: 36),
                ]),
                const SizedBox(height: 14),
                Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white10, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Column(children: [
                      Text('Total expenses'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 11, color: Colors.white60)),
                      RichText(text: TextSpan(children: [
                        TextSpan(text: 'SAR ', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 13, color: AppColors.goldLight)),
                        TextSpan(text: _fmtBig(_totalAmount(expenses)),
                          style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                      ])),
                    ]),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.15)),
                    Column(children: [
                      Text('Approved'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                      Text('SAR ${_fmtBig(_totalAmount(approved))}', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.tealLight)),
                    ]),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.15)),
                    Column(children: [
                      Text('Under Review'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white60)),
                      Text('SAR ${_fmtBig(_totalAmount(pending))}', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.warning)),
                    ]),
                  ]),
                ),
              ]),
            ),
            Expanded(child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedExpensesProvider);
                await ref.read(paginatedExpensesProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                child: Column(children: [
                  if (noAttach.isNotEmpty) AlertBanner(
                    message: 'requests_no_attachments'.tr(context, params: {'count': '${noAttach.length}'}),
                    type: 'warning'),
                  if (highValue.any((e) => e.status == 'pending')) AlertBanner(
                    message: 'high_value_pending'.tr(context, params: {'count': '${highValue.where((e) => e.status == 'pending').length}'}),
                    type: 'error'),

                  SectionHeader(title: 'Overview'.tr(context)),
                  Row(children: [
                    _kpi('${pending.length}', 'Under Review'.tr(context),  AppColors.warning),
                    const SizedBox(width: 8),
                    _kpi('${approved.length}', 'Approved'.tr(context), AppColors.success),
                    const SizedBox(width: 8),
                    _kpi('${rejected.length}', 'Rejected'.tr(context), AppColors.error),
                    const SizedBox(width: 8),
                    _kpi('${expenses.where((e) => e.status == 'returned').length}', 'Returned'.tr(context), AppColors.gold),
                  ]),
                  const SizedBox(height: 16),

                  SectionHeader(title: 'Pending requests section'.tr(context),
                    actionLabel: 'View all'.tr(context),
                    onAction: () => context.push('/expense-requests')),
                  ...pending.take(3).map((e) => ExpenseAmountCard(expense: e,
                    onTap: () => context.push('/expense-detail/${e.id}'))),
                  const SizedBox(height: 6),

                  // Category breakdown derived from expenses
                  SectionHeader(title: 'Expense category distribution'.tr(context)),
                  _buildCategoryBreakdown(context, expenses),
                  const SizedBox(height: 16),

                  SectionHeader(title: 'Recent approved'.tr(context)),
                  ...approved.take(2).map((e) => ExpenseAmountCard(expense: e,
                    onTap: () => context.push('/expense-detail/${e.id}'))),
                ]),
              ),
            )),
            StickyBar(child: Row(children: [
              Expanded(child: OutlineBtn(text: '📊 ${'Analytics'.tr(context)}',
                onTap: () => context.push('/expense-analytics'))),
              const SizedBox(width: 10),
              Expanded(child: PrimaryBtn(text: '🔄 ${'Follow-up'.tr(context)}',
                onTap: () => context.push('/expense-follow-up'))),
            ])),
          ]);
        },
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, List<Expense> expenses) {
    final catMap = <String, double>{};
    final catIcons = <String, String?>{};
    for (final e in expenses) {
      catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
      catIcons[e.category] ??= e.categoryIcon;
    }
    final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();
    if (top.isEmpty) return const SizedBox.shrink();

    final maxAmt = top.first.value;
    return AppCard(mb: 16, child: Column(children: [
      SizedBox(height: 100, child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: top.map((entry) {
          return Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                height: maxAmt > 0 ? (entry.value / maxAmt) * 65 : 0,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.navyGradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))),
              const SizedBox(height: 4),
              AppIcon(catIcons[entry.key] ?? '📦', size: 14, color: AppColors.navyMid),
            ]));
        }).toList(),
      )),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Main categories'.tr(context), style: TextStyle(fontFamily: 'Cairo',
          fontSize: 11, color: context.appColors.textMuted)),
        Text('SAR ${_fmtBig(_totalAmount(expenses))} ${'Total'.tr(context)}', style: TextStyle(fontFamily: 'Cairo',
          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
      ]),
    ]));
  }

  Widget _kpi(String v, String l, Color col) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: col.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: col.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 22, fontWeight: FontWeight.w900, color: col, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: col.withOpacity(0.6))),
    ])));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. EXPENSE REQUESTS LIST SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseRequestsListScreen extends ConsumerStatefulWidget {
  const ExpenseRequestsListScreen({super.key});
  @override ConsumerState<ExpenseRequestsListScreen> createState() => _ExpRequestsState();
}

class _ExpRequestsState extends ConsumerState<ExpenseRequestsListScreen> {
  int _tab = 0;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final asyncExpenses = ref.watch(paginatedExpensesProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: asyncExpenses.when(
        loading: () => Column(children: [
          AdminAppBar(title: 'Expense requests'.tr(context), subtitle: 'Loading'.tr(context), onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (err, _) => Column(children: [
          AdminAppBar(title: 'Expense requests'.tr(context), onBack: () => context.pop()),
          Expanded(child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context), fullWidth: false,
                onTap: () => ref.invalidate(paginatedExpensesProvider)),
            ],
          ))),
        ]),
        data: (paginated) {
          final all = paginated.items;
          final filtered = all.where((e) {
            final matchSearch = _search.isEmpty ||
              e.employee.name.contains(_search) ||
              e.employee.code.contains(_search) ||
              e.category.contains(_search);
            final matchTab = _tab == 0 ||
              (_tab == 1 ? e.status == 'pending' :
               _tab == 2 ? e.status == 'approved' :
               _tab == 3 ? e.status == 'rejected' : e.status == 'returned');
            return matchSearch && matchTab;
          }).toList();

          return Column(children: [
            AdminAppBar(title: 'Expense requests'.tr(context),
              subtitle: 'requests_total'.tr(context, params: {'count': '${all.length}'}),
              onBack: () => context.pop()),
            Container(color: c.bgCard,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TextField(
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                onChanged: (v) => setState(() => _search = v),
                decoration: fieldDec(context, 'Search'.tr(context)).copyWith(
                  prefixIcon: Icon(Icons.search, color: c.gray400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
            FilterBar(tabs: ['All'.tr(context), 'Under Review'.tr(context), 'Approved'.tr(context), 'Rejected'.tr(context), 'Returned'.tr(context)],
              selected: _tab, onSelect: (i) => setState(() => _tab = i)),
            Expanded(child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedExpensesProvider);
                await ref.read(paginatedExpensesProvider.future);
              },
              child: PaginatedListView<Expense>(
                items: filtered,
                isLoadingMore: paginated.isLoadingMore,
                hasMore: _tab == 0 && _search.isEmpty ? paginated.hasMore : false,
                loadMoreError: paginated.loadMoreError,
                onFetchMore: () => ref.read(paginatedExpensesProvider.notifier).fetchMore(),
                emptyWidget: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 100),
                  EmptyState(icon: '💳', title: 'No requests'.tr(context),
                    subtitle: 'No matching expenses'.tr(context)),
                ])),
                itemBuilder: (_, e, i) => ExpenseAmountCard(
                  expense: e,
                  onTap: () => context.push('/expense-detail/${e.id}')),
              ),
            )),
          ]);
        },
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. EXPENSE REQUEST DETAIL SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseRequestDetailScreen extends ConsumerStatefulWidget {
  final int expenseId;
  const ExpenseRequestDetailScreen({super.key, required this.expenseId});
  @override ConsumerState<ExpenseRequestDetailScreen> createState() => _ExpDetailState();
}

class _ExpDetailState extends ConsumerState<ExpenseRequestDetailScreen> {
  String? _decision;
  bool _processing = false;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleApprove(int id) async {
    setState(() => _processing = true);
    try {
      await ref.read(expenseRepositoryProvider).approveExpense(id, notes: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null);
      setState(() { _decision = 'approve'; _processing = false; });
      ref.invalidate(paginatedExpensesProvider);
    } catch (_) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving request'.tr(context))));
      }
    }
  }

  Future<void> _handleReject(int id) async {
    setState(() => _processing = true);
    try {
      await ref.read(expenseRepositoryProvider).rejectExpense(id, notes: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null);
      setState(() { _decision = 'reject'; _processing = false; });
      ref.invalidate(paginatedExpensesProvider);
    } catch (_) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request'.tr(context))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final asyncExpense = ref.watch(expenseDetailProvider(widget.expenseId));

    return Scaffold(
      backgroundColor: c.bg,
      body: asyncExpense.when(
        loading: () => Column(children: [
          AdminAppBar(title: 'Expense details'.tr(context), onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (err, _) => Column(children: [
          AdminAppBar(title: 'Expense details'.tr(context), onBack: () => context.pop()),
          Expanded(child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context), fullWidth: false,
                onTap: () => ref.invalidate(expenseDetailProvider(widget.expenseId))),
            ],
          ))),
        ]),
        data: (e) {
          if (_decision != null) return _buildDecisionResult(context);
          return _buildDetail(context, e);
        },
      ),
    );
  }

  Widget _buildDecisionResult(BuildContext context) {
    final c = context.appColors;
    return Column(children: [
      AdminAppBar(title: 'Expense details'.tr(context), onBack: () => context.pop()),
      Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(
            color: _decision == 'approve' ? AppColors.successSoft : AppColors.errorSoft,
            shape: BoxShape.circle),
          child: Center(child: Icon(
            _decision == 'approve' ? Icons.check : Icons.close,
            color: _decision == 'approve' ? AppColors.success : AppColors.error, size: 40))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_decision == 'approve' ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: _decision == 'approve' ? AppColors.success : AppColors.error, size: 22),
          const SizedBox(width: 8),
          Text(_decision == 'approve' ? 'Expense approved'.tr(context) : 'Expense rejected'.tr(context),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        Text('Employee notified'.tr(context), style: TextStyle(fontFamily: 'Cairo',
          fontSize: 13, color: c.textMuted)),
        const SizedBox(height: 24),
        OutlineBtn(text: 'Back to requests'.tr(context), fullWidth: false,
          onTap: () => context.pop()),
      ]))),
    ]);
  }

  Widget _buildDetail(BuildContext context, Expense e) {
    final statusLabel = e.status == 'approved' ? 'Approved'.tr(context)
      : e.status == 'rejected' ? 'Rejected'.tr(context)
      : e.status == 'returned' ? 'Returned'.tr(context) : 'Under Review'.tr(context);
    final statusType = e.status == 'approved' ? 'approved'
      : e.status == 'rejected' ? 'rejected'
      : e.status == 'returned' ? 'warning' : 'pending';

    return Column(children: [
      AdminAppBar(title: 'Expense details'.tr(context), subtitle: 'EXP-${e.id}',
        onBack: () => context.pop()),
      Expanded(child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(expenseDetailProvider(widget.expenseId)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  StatusBadge(text: statusLabel, type: statusType, dot: true),
                  if (e.isHighValue) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white24, borderRadius: BorderRadius.circular(99)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.payments_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 6),
                      Text('${'High amount'.tr(context)} — ${'Needs dual approval'.tr(context)}',
                        style: const TextStyle(fontFamily: 'Cairo',
                          fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                    ])),
                ]),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withOpacity(0.45)),
                    ),
                    child: Center(child: AppIcon(e.categoryIcon ?? '📦', size: 28, color: AppColors.goldLight)),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(e.category, style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 12, color: Colors.white70)),
                    RichText(text: TextSpan(children: [
                      TextSpan(text: '${e.currency} ', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, color: Colors.white70)),
                      TextSpan(text: e.amount.toStringAsFixed(0),
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
              Text('Employee info'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'Employee name'.tr(context),   value: e.employee.name,       icon: '👤'),
              InfoRow(label: 'Employee ID'.tr(context),   value: e.employee.code,       icon: '🔖'),
              InfoRow(label: 'Department'.tr(context),       value: e.employee.department, icon: '🏢', border: false),
            ])),

            // Expense details
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Expense details'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'Request ID'.tr(context),      value: 'EXP-${e.id}',       icon: '📋'),
              InfoRow(label: 'Category'.tr(context),           value: e.category,          icon: e.categoryIcon ?? '📦'),
              InfoRow(label: 'Amount'.tr(context),          value: '${e.currency} ${e.amount.toStringAsFixed(0)}', icon: '💰'),
              InfoRow(label: 'Expense date'.tr(context),    value: e.expenseDate,        icon: '📅'),
              InfoRow(label: 'Submission date'.tr(context),  value: e.submittedDate,      icon: '🕐'),
              if (e.projectRef != null)
                InfoRow(label: 'Linked project'.tr(context), value: e.projectRef!,        icon: '🏗'),
              if (e.notes != null)
                InfoRow(label: 'Notes'.tr(context),   value: e.notes!,             icon: '📝', border: false),
            ])),

            // Attachments
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (!e.hasAttachment) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft, borderRadius: BorderRadius.circular(6)),
                  child: Text('⚠️ ${'No attachments'.tr(context)}', style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warningDark))),
                Text('Invoices and attachments'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              if (!e.hasAttachment)
                EmptyState(icon: '📎',
                  title: 'No invoice attached'.tr(context),
                  subtitle: 'Request invoice before approval'.tr(context))
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.navySoft, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.navyBorder)),
                  child: Row(children: [
                    const Icon(Icons.description_rounded, color: AppColors.navyMid, size: 20),
                    const SizedBox(width: 10),
                    Text('invoice_EXP-${e.id}.pdf', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 12, color: AppColors.navyMid, fontWeight: FontWeight.w600)),
                  ])),
            ])),

            // Approval timeline
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Approval path'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
              const SizedBox(height: 14),
              TimelineWidget(steps: [
                TLStep(label: 'Submit request'.tr(context), sub: 'Employee'.tr(context), done: true),
                TLStep(label: 'Manager review'.tr(context),
                  sub: e.status == 'pending' ? 'Under Review'.tr(context) : 'Done'.tr(context),
                  done: e.status != 'pending',
                  active: e.status == 'pending'),
                TLStep(label: 'Finance approval'.tr(context),
                  done: e.status == 'approved'),
                TLStep(label: 'Close and pay'.tr(context),
                  done: e.status == 'approved'),
              ]),
            ])),

            // Comment
            if (e.status == 'pending')
              AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Comment note'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                TextField(controller: _noteCtrl, maxLines: 3,
                  
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  decoration: fieldDec(context, 'Add your comment'.tr(context))),
              ])),
          ]),
        ),
      )),
      if (e.status == 'pending')
        StickyBar(child: _processing
          ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator()))
          : Row(children: [
              Expanded(child: DangerBtn(text: '✗ ${'Rejected'.tr(context)}',
                onTap: () => _handleReject(e.id))),
              const SizedBox(width: 8),
              Expanded(child: TealBtn(text: '✓ ${'Approved'.tr(context)}',
                onTap: () => _handleApprove(e.id))),
            ])),
    ]);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. EXPENSE CATEGORIES SCREEN (Placeholder — no categories API)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseCategoriesScreen extends ConsumerWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final asyncExpenses = ref.watch(paginatedExpensesProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'Expense categories'.tr(context), subtitle: 'Extracted from requests'.tr(context),
          onBack: () => context.pop()),
        Expanded(child: asyncExpenses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context), fullWidth: false,
                onTap: () => ref.invalidate(paginatedExpensesProvider)),
            ],
          )),
          data: (paginated) {
            final catMap = <String, _CatSummary>{};
            for (final e in paginated.items) {
              catMap.putIfAbsent(e.category, () => _CatSummary(e.categoryIcon));
              catMap[e.category]!.count++;
              catMap[e.category]!.total += e.amount;
            }
            final cats = catMap.entries.toList()..sort((a, b) => b.value.total.compareTo(a.value.total));
            final grandTotal = cats.fold(0.0, (s, entry) => s + entry.value.total);

            if (cats.isEmpty) {
              return Center(child: EmptyState(
                icon: '📁',
                title: 'No categories'.tr(context),
                subtitle: 'No expenses found yet'.tr(context)));
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(paginatedExpensesProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  AppCard(mb: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Monthly total'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 12, color: c.textMuted)),
                    RichText(text: TextSpan(children: [
                      TextSpan(text: 'SAR ', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, color: AppColors.navyMid, fontWeight: FontWeight.w600)),
                      TextSpan(text: _fmtBig(grandTotal), style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navyMid)),
                    ])),
                    const SizedBox(height: 12),
                    ...cats.map((cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        SizedBox(width: 42, child: Text(
                          grandTotal > 0 ? '${(cat.value.total / grandTotal * 100).toInt()}%' : '0%',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c.textMuted))),
                        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: grandTotal > 0 ? cat.value.total / grandTotal : 0,
                            backgroundColor: c.gray100,
                            valueColor: const AlwaysStoppedAnimation(AppColors.navyMid),
                            minHeight: 8))),
                        const SizedBox(width: 8),
                        SizedBox(width: 28, child: AppIcon(cat.value.icon ?? '📦', size: 16, color: AppColors.navyMid)),
                      ])),
                    ),
                  ])),

                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
                    padding: EdgeInsets.zero,
                    children: cats.map((cat) => GestureDetector(
                      onTap: () => context.push('/expense-requests'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppShadows.card),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gold.withOpacity(0.18)),
                            ),
                            child: Center(child: AppIcon(cat.value.icon ?? '📦', size: 22, color: AppColors.gold)),
                          ),
                          const SizedBox(height: 8),
                          Text(cat.key, style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navyMid)),
                          const SizedBox(height: 4),
                          Text('requests_count'.tr(context, params: {'count': '${cat.value.count}'}), style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 11, color: c.textMuted)),
                          const SizedBox(height: 2),
                          Text('SAR ${_fmtBig(cat.value.total)}', style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 12, fontWeight: FontWeight.w700, color: c.textSecondary)),
                        ]),
                      ),
                    )).toList(),
                  ),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }
}

class _CatSummary {
  final String? icon;
  int count = 0;
  double total = 0;
  _CatSummary(this.icon);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. EXPENSE ANALYTICS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseAnalyticsScreen extends ConsumerWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final asyncExpenses = ref.watch(paginatedExpensesProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: asyncExpenses.when(
        loading: () => Column(children: [
          _buildHeader(context),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (err, _) => Column(children: [
          _buildHeader(context),
          Expanded(child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context), fullWidth: false,
                onTap: () => ref.invalidate(paginatedExpensesProvider)),
            ],
          ))),
        ]),
        data: (paginated) {
          final expenses = paginated.items;
          final total = _totalAmount(expenses);
          final pending = expenses.where((e) => e.status == 'pending');
          final approved = expenses.where((e) => e.status == 'approved');
          final highValue = expenses.where((e) => e.isHighValue);
          final approvalRate = expenses.isNotEmpty
            ? (approved.length / expenses.length * 100).toInt()
            : 0;

          // Category breakdown
          final catMap = <String, double>{};
          final catIcons = <String, String?>{};
          for (final e in expenses) {
            catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
            catIcons[e.category] ??= e.categoryIcon;
          }
          final catSorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

          // Department breakdown
          final deptMap = <String, double>{};
          for (final e in expenses) {
            deptMap[e.employee.department] = (deptMap[e.employee.department] ?? 0) + e.amount;
          }
          final deptSorted = deptMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final deptColors = [AppColors.navyMid, AppColors.teal, AppColors.gold,
            AppColors.success, AppColors.warning, AppColors.error];

          return Column(children: [
            _buildHeader(context),
            Expanded(child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(paginatedExpensesProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                child: Column(children: [

                  SectionHeader(title: 'Expense indicators'.tr(context)),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
                    padding: EdgeInsets.zero,
                    children: [
                      KpiCard(label: 'Monthly total'.tr(context), value: _fmtBig(total),
                        change: 'requests_count'.tr(context, params: {'count': '${expenses.length}'}), icon: '💰', isPositive: false, color: AppColors.navyMid),
                      KpiCard(label: 'Pending requests'.tr(context), value: '${pending.length}',
                        change: 'Needs review'.tr(context), icon: '⏳', isPositive: false, color: AppColors.warning),
                      KpiCard(label: 'Approval rate'.tr(context), value: '$approvalRate%',
                        change: '${approved.length} / ${expenses.length}', icon: '✅', isPositive: true, color: AppColors.success),
                      KpiCard(label: 'High amount'.tr(context), value: '${highValue.length}',
                        change: 'Needs dual approval'.tr(context), icon: '⚠️', isPositive: false, color: AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // By category distribution
                  if (catSorted.isNotEmpty) ...[
                    SectionHeader(title: 'Distribution by category'.tr(context)),
                    AppCard(mb: 16, child: Column(children: [
                      ...catSorted.map((cat) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('SAR ${_fmtBig(cat.value)}', style: TextStyle(fontFamily: 'Cairo',
                              fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
                            Row(children: [
                              Text(cat.key, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: c.textSecondary)),
                              const SizedBox(width: 6),
                              AppIcon(catIcons[cat.key] ?? '📦', size: 16, color: AppColors.navyMid),
                            ]),
                          ]),
                          const SizedBox(height: 4),
                          ClipRRect(borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total > 0 ? cat.value / total : 0,
                              backgroundColor: c.gray100,
                              valueColor: const AlwaysStoppedAnimation(AppColors.navyMid),
                              minHeight: 6)),
                        ]),
                      )),
                    ])),
                  ],

                  // Top spending depts
                  if (deptSorted.isNotEmpty) ...[
                    SectionHeader(title: 'Top spending departments'.tr(context)),
                    AppCard(mb: 16, child: Column(children: [
                      ...deptSorted.take(6).toList().asMap().entries.map((entry) {
                        final maxAmt = deptSorted.first.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [
                            SizedBox(width: 60, child: Text('SAR ${_fmtBig(entry.value.value)}',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c.textMuted))),
                            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: maxAmt > 0 ? entry.value.value / maxAmt : 0,
                                backgroundColor: c.gray100,
                                valueColor: AlwaysStoppedAnimation(
                                  deptColors[entry.key % deptColors.length]),
                                minHeight: 8))),
                            const SizedBox(width: 8),
                            SizedBox(width: 80, child: Text(entry.value.key, style: TextStyle(fontFamily: 'Cairo',
                              fontSize: 10, color: c.textSecondary), textAlign: TextAlign.right)),
                          ]));
                      }),
                    ])),
                  ],

                  // Rejected summary
                  SectionHeader(title: 'Rejected and returned'.tr(context)),
                  ...expenses.where((e) => e.status == 'rejected' || e.status == 'returned')
                    .take(3).map((e) => ExpenseAmountCard(expense: e,
                      onTap: () => context.push('/expense-detail/${e.id}'))),
                  if (expenses.where((e) => e.status == 'rejected' || e.status == 'returned').isEmpty)
                    EmptyState(icon: '✅', title: 'No rejected'.tr(context),
                      subtitle: 'All requests approved or under review'.tr(context)),
                ]),
              ),
            )),
          ]);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
          Text('Expense analytics'.tr(context), style: TextStyle(fontFamily: 'Cairo',
            fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('Requests Summary'.tr(context), style: TextStyle(fontFamily: 'Cairo',
            fontSize: 11, color: AppColors.goldLight)),
        ])),
        const SizedBox(width: 36),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. EXPENSE FOLLOW-UP SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ExpenseFollowUpScreen extends ConsumerWidget {
  const ExpenseFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final asyncExpenses = ref.watch(paginatedExpensesProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: asyncExpenses.when(
        loading: () => Column(children: [
          _buildHeader(context, 0, 0),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (err, _) => Column(children: [
          _buildHeader(context, 0, 0),
          Expanded(child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
              const SizedBox(height: 8),
              OutlineBtn(text: 'Retry'.tr(context), fullWidth: false,
                onTap: () => ref.invalidate(paginatedExpensesProvider)),
            ],
          ))),
        ]),
        data: (paginated) {
          final expenses = paginated.items;
          final pending   = expenses.where((e) => e.status == 'pending').toList();
          final noAttach  = expenses.where((e) => !e.hasAttachment && e.status == 'pending').toList();
          final returned  = expenses.where((e) => e.status == 'returned').toList();
          final highVal   = expenses.where((e) => e.isHighValue && e.status == 'pending').toList();

          return Column(children: [
            _buildHeader(context, pending.length, noAttach.length),
            Container(
              color: AppColors.navyDeep,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Row(children: [
                _pill('${pending.length}',  'Under Review'.tr(context),         AppColors.warning),
                const SizedBox(width: 8),
                _pill('${highVal.length}',  'High amount'.tr(context),  AppColors.error),
                const SizedBox(width: 8),
                _pill('${noAttach.length}', 'No attachments'.tr(context), AppColors.gold),
                const SizedBox(width: 8),
                _pill('${returned.length}', 'Returned'.tr(context),         AppColors.navyBright),
              ]),
            ),
            Expanded(child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(paginatedExpensesProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(children: [
                  if (highVal.isNotEmpty) ...[
                    AlertBanner(
                      message: 'high_value_pending'.tr(context, params: {'count': '${highVal.length}'}),
                      type: 'error'),
                    SectionHeader(title: '💰 ${'High amount priority'.tr(context)}'),
                    ...highVal.map((e) => ExpenseAmountCard(expense: e,
                      onTap: () => context.push('/expense-detail/${e.id}'))),
                    const SizedBox(height: 10),
                  ],

                  if (noAttach.isNotEmpty) ...[
                    SectionHeader(title: '📎 ${'No attachments follow-up'.tr(context)}'),
                    ...noAttach.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: c.bgCard, borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.sm,
                        border: Border.all(color: AppColors.warning.withOpacity(0.4))),
                      child: Row(children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.attach_file_rounded, color: AppColors.warning, size: 18),
                          Text('No invoice'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w700)),
                        ]),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(e.employee.name, style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('${e.category} · ${e.currency} ${e.amount.toStringAsFixed(0)}',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: c.textMuted)),
                        ])),
                        const SizedBox(width: 8),
                        AdminAvatar(initials: e.employee.name.characters.first, size: 36, fontSize: 14),
                      ])),
                    ),
                    const SizedBox(height: 10),
                  ],

                  if (returned.isNotEmpty) ...[
                    SectionHeader(title: '↩ ${'Returned'.tr(context)}'),
                    ...returned.map((e) => ExpenseAmountCard(expense: e,
                      onTap: () => context.push('/expense-detail/${e.id}'))),
                    const SizedBox(height: 10),
                  ],

                  SectionHeader(title: '⏳ ${'All pending'.tr(context)}'),
                  if (pending.isEmpty)
                    EmptyState(icon: '✅', title: 'No pending requests'.tr(context),
                      subtitle: 'All requests reviewed'.tr(context))
                  else
                    ...pending.map((e) => ExpenseAmountCard(expense: e,
                      onTap: () => context.push('/expense-detail/${e.id}'))),
                ]),
              ),
            )),
          ]);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int pendingCount, int noAttachCount) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.navyGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 12, left: 18, right: 18),
      child: Row(children: [
        GestureDetector(onTap: () => context.pop(),
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
        Expanded(child: Column(children: [
          Text('Expense follow-up'.tr(context), style: TextStyle(fontFamily: 'Cairo',
            fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('$pendingCount ${'Pending'.tr(context)} · $noAttachCount ${'No attachments'.tr(context)}',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.goldLight)),
        ])),
        const SizedBox(width: 36),
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
