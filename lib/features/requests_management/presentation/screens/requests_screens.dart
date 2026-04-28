import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/paginated_providers.dart';
import '../../../../core/providers/paginated_notifier.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../data/models/request_models.dart';

// ── helpers ──────────────────────────────────────────────────────────────────

String _statusTr(BuildContext context, String s) => switch (s) {
  'pending'    => 'Pending'.tr(context),
  'processing' => 'Processing'.tr(context),
  'approved'   => 'Approved'.tr(context),
  'rejected'   => 'Rejected'.tr(context),
  'completed'  => 'Completed'.tr(context),
  'cancelled'  => 'Cancelled'.tr(context),
  _            => s,
};

String _typeTr(BuildContext context, String t) {
  // Short alias map → translation key
  const aliases = {
    'leave'        : 'leave_request',
    'attendance'   : 'attendance_correction',
    'permission'   : 'leave_permission',
    'expense'      : 'expense_claim',
    'document'     : 'document_request',
    'loan'         : 'loan_request',
    'resignation'  : 'resignation_request',
    'asset'        : 'asset_request',
    'experience'   : 'experience_letter',
    'certificate'  : 'certificate_request',
    'training'     : 'training_request',
    'promotion'    : 'promotion_request',
    'transfer'     : 'transfer_request',
  };
  final key = aliases[t] ?? t;
  final translated = key.tr(context);
  // If translation was not found (returns the key itself), prettify the slug.
  if (translated == key && key.contains('_')) {
    return key.split('_').map((w) =>
      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
  return translated;
}

String _fmtDate(String iso) {
  try {
    final d = DateTime.parse(iso);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso;
  }
}

// ── Requests Dashboard ──────────────────────────────────────────────────────
class RequestsManagementScreen extends ConsumerStatefulWidget {
  const RequestsManagementScreen({super.key});
  @override ConsumerState<RequestsManagementScreen> createState() => _RequestsMgmtState();
}

class _RequestsMgmtState extends ConsumerState<RequestsManagementScreen> {
  int _tab = 0; // 0=pending (default)
  bool _refreshing = false;

  // pending, all, processing, approved, rejected, completed, cancelled
  static const _statusMap = ['pending', null, 'processing', 'approved', 'rejected', 'completed', 'cancelled'];

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    ref.invalidate(paginatedRequestsProvider);
    try { await ref.read(paginatedRequestsProvider.future); } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final asyncRequests = ref.watch(paginatedRequestsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [

        // ── HEADER ──────────────────────────────────────
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 14, left: 16, right: 16),
          child: Column(children: [
            Row(children: [
              if (context.canPop()) ...[
                _HeaderIconBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop()),
                const SizedBox(width: 10),
              ],
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Management'.tr(context), style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800,
                    color: Colors.white, height: 1.2, letterSpacing: -0.2)),
                  const SizedBox(height: 2),
                  Text('Request overview'.tr(context), style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 11.5,
                    color: AppColors.goldLight.withOpacity(0.95),
                    fontWeight: FontWeight.w500, height: 1.2)),
                ])),
              _HeaderIconBtn(
                icon: Icons.refresh_rounded,
                loading: _refreshing,
                onTap: _refreshing ? null : _refresh),
            ]),
            const SizedBox(height: 14),
            // ── Filter pills (scrollable, modern) ──
            asyncRequests.when(
              data: (paginated) {
                final all = paginated.items;
                int cnt(String s) => all.where((r) => r.status == s).length;
                return _buildFilterRow(context, [
                  cnt('pending'), all.length, cnt('processing'), cnt('approved'),
                  cnt('rejected'), cnt('completed'), cnt('cancelled'),
                ]);
              },
              loading: () => _buildFilterRow(context, null),
              error: (_, __) => _buildFilterRow(context, null),
            ),
          ]),
        ),

        // ── BODY ─────────────────────────────────────────────
        Expanded(child: asyncRequests.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navyMid)),
          error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(paginatedRequestsProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('Retry'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
          ])),
          data: (paginated) {
            final filtered = _statusMap[_tab] == null
              ? paginated.items
              : paginated.items.where((r) => r.status == _statusMap[_tab]).toList();
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedRequestsProvider);
                await ref.read(paginatedRequestsProvider.future);
              },
              child: PaginatedListView<EmployeeRequest>(
                items: filtered,
                isLoadingMore: paginated.isLoadingMore,
                hasMore: _tab == 1 ? paginated.hasMore : false,
                loadMoreError: paginated.loadMoreError,
                onFetchMore: () => ref.read(paginatedRequestsProvider.notifier).fetchMore(),
                emptyWidget: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.inbox_outlined, size: 48, color: c.gray300),
                  const SizedBox(height: 12),
                  Text('No requests'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.textMuted)),
                ])),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                itemBuilder: (context, r, i) => RequestCard(
                  id: '#${r.id}',
                  empName: r.employee?.name ?? '—',
                  dept: r.employee?.code ?? '',
                  type: _typeTr(context, r.requestType),
                  typeKey: r.requestType,
                  date: _fmtDate(r.createdAt),
                  status: r.status,
                  priority: 'normal',
                  onTap: () => context.push('/request-detail', extra: r.id)),
              ),
            );
          },
        )),
      ]),
    );
  }

  static const _labels = ['Pending', 'All', 'Processing', 'Approved', 'Rejected', 'Completed', 'Cancelled'];
  static const _colors = [AppColors.warning, AppColors.goldLight, AppColors.navyBright, AppColors.tealLight, AppColors.coral, AppColors.success, AppColors.g400];

  Widget _buildFilterRow(BuildContext context, List<int>? counts) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _labels.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final v = counts != null ? '${counts[i]}' : '…';
          return _filterPill(v, _labels[i].tr(context), _colors[i], i);
        },
      ),
    );
  }

  Widget _filterPill(String count, String label, Color accentColor, int index) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.18),
            width: 1),
          boxShadow: selected ? [BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          // Count chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: selected ? accentColor.withOpacity(0.16) : accentColor.withOpacity(0.22),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(count, style: TextStyle(
              fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800,
              color: selected ? accentColor : Colors.white,
              height: 1, letterSpacing: -0.2)),
          ),
          const SizedBox(width: 7),
          // Label
          Text(label, style: TextStyle(
            fontFamily: 'Cairo', fontSize: 12.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.navyDeep : Colors.white.withValues(alpha: 0.92),
            height: 1)),
        ]),
      ),
    );
  }
}

// ─── Header circular icon button (used in HEADER bar) ────────────────────
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;
  const _HeaderIconBtn({required this.icon, this.onTap, this.loading = false});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Ink(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Center(child: loading
            ? const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Icon(icon, color: Colors.white, size: 18)),
        ),
      ),
    );
  }
}

// ── All Requests List ───────────────────────────────────────────────────────
class AllRequestsScreen extends ConsumerWidget {
  const AllRequestsScreen({super.key});

  static final _tabKeys = ['All', 'Pending', 'Approved', 'Rejected'];
  static const _statusMap = [null, 'pending', 'approved', 'rejected'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final currentFilter = ref.watch(managerRequestsStatusFilter);
    final selectedIdx = _statusMap.indexOf(currentFilter).clamp(0, _tabKeys.length - 1);
    final asyncRequests = ref.watch(paginatedRequestsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(title: 'Request Management'.tr(context), subtitle: 'All Requests'.tr(context),
          onBack: () => context.pop()),
        FilterBar(
          tabs: _tabKeys.map((k) => k.tr(context)).toList(),
          selected: selectedIdx,
          onSelect: (i) => ref.read(managerRequestsStatusFilter.notifier).state = _statusMap[i]),
        Expanded(child: asyncRequests.when(

          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${'Error'.tr(context)}: $e',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.error))),
          data: (paginated) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedRequestsProvider);
                await ref.read(paginatedRequestsProvider.future);
              },
              child: PaginatedListView<EmployeeRequest>(
                items: paginated.items,
                isLoadingMore: paginated.isLoadingMore,
                hasMore: paginated.hasMore,
                loadMoreError: paginated.loadMoreError,
                onFetchMore: () => ref.read(paginatedRequestsProvider.notifier).fetchMore(),
                emptyWidget: Center(child: Text('No requests'.tr(context), style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 14, color: c.textMuted))),
                itemBuilder: (context, r, index) {
                  return RequestCard(
                    id: '#${r.id}',
                    empName: r.employee?.name ?? '—',
                    dept: r.employee?.code ?? '',
                    type: _typeTr(context, r.requestType),
                    typeKey: r.requestType,
                    date: _fmtDate(r.createdAt),
                    status: r.status,
                    priority: 'normal',
                    onTap: () => context.push('/request-detail', extra: r.id));
                },
              ),
            );
          },
        )),
      ]),
    );
  }
}

// ── Request Detail ──────────────────────────────────────────────────────────
class RequestDetailScreen extends ConsumerStatefulWidget {
  final int requestId;
  const RequestDetailScreen({super.key, required this.requestId});
  @override
  ConsumerState<RequestDetailScreen> createState() => _RequestDetailState();
}

class _RequestDetailState extends ConsumerState<RequestDetailScreen> {
  String? _decision;
  bool _processing = false;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _decide(String status) async {
    setState(() => _processing = true);
    try {
      await ref.read(requestRepositoryProvider).decideRequest(
        widget.requestId,
        status: status,
        responseNotes: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      ref.invalidate(paginatedRequestsProvider);
      ref.invalidate(managerRequestDetailProvider(widget.requestId));
      if (mounted) setState(() { _decision = status; _processing = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'Error'.tr(context)}: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final asyncDetail = ref.watch(managerRequestDetailProvider(widget.requestId));

    // ── success view after decision ──
    if (_decision != null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Column(children: [
          AdminAppBar(title: 'Request details'.tr(context), onBack: () => context.pop()),
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(
                color: _decision == 'approved' ? AppColors.successSoft : AppColors.errorSoft,
                shape: BoxShape.circle),
              child: Center(child: Icon(
                _decision == 'approved' ? Icons.check : Icons.close,
                color: _decision == 'approved' ? AppColors.success : AppColors.error, size: 40))),
            const SizedBox(height: 16),
            Text(_decision == 'approved' ? 'Approved'.tr(context) : 'Rejected'.tr(context),
              style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Employee notified'.tr(context),
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: c.textMuted)),
            const SizedBox(height: 24),
            OutlineBtn(text: 'Back to requests'.tr(context), onTap: () => context.pop(), fullWidth: false),
          ]))),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: asyncDetail.when(
        
        loading: () => Column(children: [
          AdminAppBar(title: 'Request details'.tr(context), onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          AdminAppBar(title: 'Request details'.tr(context), onBack: () => context.pop()),
          Expanded(child: Center(child: Text('${'Error'.tr(context)}: $e',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.error)))),
        ]),
        data: (r) {
          return Column(children: [
            AdminAppBar(title: 'Request details'.tr(context), subtitle: '#${r.id}',
              onBack: () => context.pop()),
            Expanded(child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(managerRequestDetailProvider(widget.requestId)),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // ── employee header ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(gradient: AppColors.navyGradient,
                      borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.navy),
                    child: Row(children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        StatusBadge(text: _statusTr(context,r.status), type: r.status, dot: true),
                      ]),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(r.employee?.name ?? '—', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text(r.employee?.code ?? '', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 12, color: Colors.white60)),
                        const SizedBox(height: 6),
                        Text(_typeTr(context,r.requestType), style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldLight)),
                      ])),
                      const SizedBox(width: 10),
                      AdminAvatar(
                        initials: (r.employee?.name ?? '?').characters.first,
                        size: 48, fontSize: 18),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ── details card ──
                  AppCard(mb: 14, child: Column(children: [
                    Align(alignment: Alignment.centerRight, child: Text('Request details'.tr(context),
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
                    const SizedBox(height: 10),
                    InfoRow(label: 'Request ID'.tr(context),       value: '#${r.id}',               icon: '🔖'),
                    InfoRow(label: 'Request type'.tr(context),       value: _typeTr(context,r.requestType),   icon: '📋'),
                    InfoRow(label: 'Subject'.tr(context),          value: r.subject,                icon: '📝'),
                    InfoRow(label: 'Submission date'.tr(context),   value: _fmtDate(r.createdAt),    icon: '📅'),
                    InfoRow(label: 'Employee'.tr(context),           value: r.employee?.name ?? '—',  icon: '🏢'),
                    if (r.description != null && r.description!.isNotEmpty)
                      InfoRow(label: 'Details'.tr(context), value: r.description!, icon: '📄', border: false),
                  ])),

                  // ── approval chain ──
                  AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('Approval path'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
                    const SizedBox(height: 14),
                    TimelineWidget(steps: [
                      TLStep(label: 'Submit request'.tr(context),
                        sub: '${r.employee?.name ?? ''} — ${_fmtDate(r.createdAt)}', done: true),
                      TLStep(label: 'Manager review'.tr(context),
                        sub: r.status == 'pending' ? 'In progress'.tr(context) : _statusTr(context,r.status),
                        done: r.status != 'pending', active: r.status == 'pending'),
                      TLStep(label: 'Close request'.tr(context),
                        done: r.status == 'approved' || r.status == 'rejected'),
                    ]),
                  ])),

                  // ── response notes (if already decided) ──
                  if (r.responseNotes != null && r.responseNotes!.isNotEmpty)
                    AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Response notes'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight,
                        child: Text(r.responseNotes!, style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 13, color: c.textMuted))),
                    ])),

                  // ── note input (only for pending) ──
                  if (r.status == 'pending')
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

            // ── action bar (only for pending) ──
            if (r.status == 'pending')
              StickyBar(child: _processing
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator()))
                : Row(children: [
                    Expanded(child: DangerBtn(text: 'Rejected'.tr(context),
                      onTap: () => _decide('rejected'))),
                    const SizedBox(width: 10),
                    Expanded(child: TealBtn(text: 'Approved'.tr(context),
                      onTap: () => _decide('approved'))),
                  ])),
          ]);
        },
      ),
    );
  }
}

// ── Approvals Inbox ─────────────────────────────────────────────────────────
class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    // Force pending filter for this screen
    final asyncRequests = ref.watch(paginatedRequestsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: asyncRequests.when(

        loading: () => Column(children: [
          AdminAppBar(title: 'Approvals inbox'.tr(context), onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          AdminAppBar(title: 'Approvals inbox'.tr(context), onBack: () => context.pop()),
          Expanded(child: Center(child: Text('${'Error'.tr(context)}: $e',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.error)))),
        ]),
        data: (paginated) {
          final pending = paginated.items.where((r) => r.status == 'pending').toList();
          return Column(children: [
            AdminAppBar(title: 'Approvals inbox'.tr(context),
              subtitle: 'requests_review'.tr(context, params: {'count': '${pending.length}'}),
              onBack: () => context.pop()),
            Expanded(child: pending.isEmpty
              ? Center(child: Text('No pending requests'.tr(context), style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 14, color: c.textMuted)))
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(paginatedRequestsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: pending.length,
                    itemBuilder: (_, i) {
                      final r = pending[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: c.bgCard,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppShadows.card,
                          border: Border(right: BorderSide(
                            color: AppColors.warning, width: 4))),
                        child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(_fmtDate(r.createdAt), style: TextStyle(fontFamily: 'Cairo',
                              fontSize: 11, color: c.textMuted)),
                            Row(children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(r.employee?.name ?? '—', style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                                Text(r.employee?.code ?? '', style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 11, color: c.textMuted)),
                              ]),
                              const SizedBox(width: 10),
                              AdminAvatar(
                                initials: (r.employee?.name ?? '?').characters.first,
                                size: 38, fontSize: 14),
                            ]),
                          ]),
                          const SizedBox(height: 10),
                          Container(width: double.infinity, padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: c.bg,
                              borderRadius: BorderRadius.circular(10)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(_typeTr(context,r.requestType), style: TextStyle(fontFamily: 'Cairo',
                                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
                              Text(r.subject, style: TextStyle(fontFamily: 'Cairo',
                                fontSize: 11, color: c.textMuted)),
                            ])),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: GestureDetector(
                              onTap: () => context.push('/request-detail', extra: r.id),
                              child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(color: AppColors.navySoft,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: AppColors.navyBorder)),
                                child: Center(child: Text('Details'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyMid)))))),
                            const SizedBox(width: 8),
                            Expanded(child: GestureDetector(
                              onTap: () => context.push('/request-detail', extra: r.id),
                              child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(gradient: AppColors.tealGradient,
                                  borderRadius: BorderRadius.circular(9), boxShadow: AppShadows.teal),
                                child: Center(child: Text('Review'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)))))),
                          ]),
                        ])),
                      );
                    },
                  ),
                )),
          ]);
        },
      ),
    );
  }
}
