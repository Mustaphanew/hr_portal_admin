import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../data/models/request_models.dart';

// ── helpers ──────────────────────────────────────────────────────────────────

String _statusAr(String s) => switch (s) {
  'pending'  => 'معلق',
  'approved' => 'معتمد',
  'rejected' => 'مرفوض',
  _          => s,
};

String _typeAr(String t) => switch (t) {
  'leave'              => 'طلب إجازة',
  'attendance'         => 'تصحيح حضور',
  'permission'         => 'إذن مغادرة',
  'expense'            => 'مطالبة مصاريف',
  'salary_advance'     => 'سلفة راتب',
  'document'           => 'طلب وثيقة',
  'loan'               => 'طلب قرض',
  'resignation'        => 'طلب استقالة',
  'official_mission'   => 'مهمة رسمية',
  'asset'              => 'طلب أصول',
  _                    => t,
};

String _fmtDate(String iso) {
  try {
    final d = DateTime.parse(iso);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso;
  }
}

// ── Requests Dashboard ──────────────────────────────────────────────────────
class RequestsManagementScreen extends ConsumerWidget {
  const RequestsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRequests = ref.watch(managerRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: asyncRequests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('حدث خطأ: $e',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.error))),
        data: (data) {
          final all = data.requests;
          final pending  = all.where((r) => r.status == 'pending').toList();
          final approved = all.where((r) => r.status == 'approved').length;
          final rejected = all.where((r) => r.status == 'rejected').length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(managerRequestsProvider),
            child: Column(children: [
              // ── header ──
              Container(
                decoration: const BoxDecoration(gradient: AppColors.navyGradient),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  bottom: 16, left: 18, right: 18),
                child: Column(children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => context.push('/all-requests'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10)),
                        child: Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)))),
                    Expanded(child: Column(children: [
                      Text('إدارة الطلبات', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('${pending.length} طلب يحتاج مراجعة', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 11, color: AppColors.goldLight)),
                    ])),
                    const SizedBox(width: 36),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _strip('${pending.length}', 'معلق', AppColors.warning),
                      _strip('${all.length}', 'الكل', AppColors.goldLight),
                      _strip('$approved', 'معتمد', AppColors.tealLight),
                      _strip('$rejected', 'مرفوض', AppColors.error),
                    ])),
                ]),
              ),

              // ── body ──
              Expanded(child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  SectionHeader(title: 'الطلبات المعلقة',
                    actionLabel: 'عرض الكل', onAction: () => context.push('/approvals')),
                  if (pending.isEmpty)
                    Padding(padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('لا توجد طلبات معلقة', style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 13, color: AppColors.tx3)))
                  else
                    ...pending.take(5).map((r) => RequestCard(
                      id: '#${r.id}',
                      empName: r.employee?.name ?? '—',
                      dept: r.employee?.code ?? '',
                      type: _typeAr(r.requestType),
                      date: _fmtDate(r.createdAt),
                      status: r.status,
                      priority: 'normal',
                      onTap: () => context.push('/request-detail', extra: r.id))),
                  const SizedBox(height: 8),
                  SectionHeader(title: 'أحدث الطلبات'),
                  ...all.take(10).map((r) => RequestCard(
                    id: '#${r.id}',
                    empName: r.employee?.name ?? '—',
                    dept: r.employee?.code ?? '',
                    type: _typeAr(r.requestType),
                    date: _fmtDate(r.createdAt),
                    status: r.status,
                    priority: 'normal',
                    onTap: () => context.push('/request-detail', extra: r.id))),
                ]),
              )),
            ]),
          );
        },
      ),
    );
  }

  static Widget _strip(String v, String l, Color c) => Column(children: [
    Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: c, height: 1.1)),
    Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white60)),
  ]);
}

// ── All Requests List ───────────────────────────────────────────────────────
class AllRequestsScreen extends ConsumerWidget {
  const AllRequestsScreen({super.key});

  static const _tabs = ['الكل', 'معلق', 'معتمد', 'مرفوض'];
  static const _statusMap = [null, 'pending', 'approved', 'rejected'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(managerRequestsStatusFilter);
    final selectedIdx = _statusMap.indexOf(currentFilter).clamp(0, _tabs.length - 1);
    final asyncRequests = ref.watch(managerRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'إدارة الطلبات', subtitle: 'جميع الطلبات',
          onBack: () => context.pop()),
        FilterBar(
          tabs: _tabs,
          selected: selectedIdx,
          onSelect: (i) => ref.read(managerRequestsStatusFilter.notifier).state = _statusMap[i]),
        Expanded(child: asyncRequests.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('حدث خطأ: $e',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.error))),
          data: (data) {
            final requests = data.requests;
            if (requests.isEmpty) {
              return Center(child: Text('لا توجد طلبات', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx3)));
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(managerRequestsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: requests.length,
                itemBuilder: (_, i) {
                  final r = requests[i];
                  return RequestCard(
                    id: '#${r.id}',
                    empName: r.employee?.name ?? '—',
                    dept: r.employee?.code ?? '',
                    type: _typeAr(r.requestType),
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
      ref.invalidate(managerRequestsProvider);
      ref.invalidate(managerRequestDetailProvider(widget.requestId));
      if (mounted) setState(() { _decision = status; _processing = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(managerRequestDetailProvider(widget.requestId));

    // ── success view after decision ──
    if (_decision != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(children: [
          AdminAppBar(title: 'تفاصيل الطلب', onBack: () => context.pop()),
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(
                color: _decision == 'approved' ? AppColors.successSoft : AppColors.errorSoft,
                shape: BoxShape.circle),
              child: Center(child: Icon(
                _decision == 'approved' ? Icons.check : Icons.close,
                color: _decision == 'approved' ? AppColors.success : AppColors.error, size: 40))),
            const SizedBox(height: 16),
            Text(_decision == 'approved' ? 'تمت الموافقة' : 'تم الرفض',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('تم إشعار الموظف بالقرار',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.tx3)),
            const SizedBox(height: 24),
            OutlineBtn(text: 'رجوع للطلبات', onTap: () => context.pop(), fullWidth: false),
          ]))),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: asyncDetail.when(
        loading: () => Column(children: [
          AdminAppBar(title: 'تفاصيل الطلب', onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          AdminAppBar(title: 'تفاصيل الطلب', onBack: () => context.pop()),
          Expanded(child: Center(child: Text('حدث خطأ: $e',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.error)))),
        ]),
        data: (r) {
          return Column(children: [
            AdminAppBar(title: 'تفاصيل الطلب', subtitle: '#${r.id}',
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
                        StatusBadge(text: _statusAr(r.status), type: r.status, dot: true),
                      ]),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(r.employee?.name ?? '—', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text(r.employee?.code ?? '', style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 12, color: Colors.white60)),
                        const SizedBox(height: 6),
                        Text(_typeAr(r.requestType), style: TextStyle(fontFamily: 'Cairo',
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
                    Align(alignment: Alignment.centerRight, child: Text('تفاصيل الطلب',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
                    const SizedBox(height: 10),
                    InfoRow(label: 'رقم الطلب',       value: '#${r.id}',               icon: '🔖'),
                    InfoRow(label: 'نوع الطلب',       value: _typeAr(r.requestType),   icon: '📋'),
                    InfoRow(label: 'الموضوع',          value: r.subject,                icon: '📝'),
                    InfoRow(label: 'تاريخ التقديم',   value: _fmtDate(r.createdAt),    icon: '📅'),
                    InfoRow(label: 'الموظف',           value: r.employee?.name ?? '—',  icon: '🏢'),
                    if (r.description != null && r.description!.isNotEmpty)
                      InfoRow(label: 'التفاصيل', value: r.description!, icon: '📄', border: false),
                  ])),

                  // ── approval chain ──
                  AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('مسار الموافقة', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
                    const SizedBox(height: 14),
                    TimelineWidget(steps: [
                      TLStep(label: 'تقديم الطلب',
                        sub: '${r.employee?.name ?? ''} — ${_fmtDate(r.createdAt)}', done: true),
                      TLStep(label: 'مراجعة المدير',
                        sub: r.status == 'pending' ? 'جارٍ الآن...' : _statusAr(r.status),
                        done: r.status != 'pending', active: r.status == 'pending'),
                      TLStep(label: 'إغلاق الطلب',
                        done: r.status == 'approved' || r.status == 'rejected'),
                    ]),
                  ])),

                  // ── response notes (if already decided) ──
                  if (r.responseNotes != null && r.responseNotes!.isNotEmpty)
                    AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('ملاحظات الرد', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight,
                        child: Text(r.responseNotes!, style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 13, color: AppColors.tx3))),
                    ])),

                  // ── note input (only for pending) ──
                  if (r.status == 'pending')
                    AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('تعليق / ملاحظة', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      TextField(controller: _noteCtrl, maxLines: 3,
                        
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: fieldDec('أضف تعليقك على الطلب...')),
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
                    Expanded(child: DangerBtn(text: 'رفض',
                      onTap: () => _decide('rejected'))),
                    const SizedBox(width: 10),
                    Expanded(child: TealBtn(text: 'اعتماد',
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
    // Force pending filter for this screen
    final asyncRequests = ref.watch(managerRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: asyncRequests.when(
        loading: () => Column(children: [
          AdminAppBar(title: 'صندوق الموافقات', onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => Column(children: [
          AdminAppBar(title: 'صندوق الموافقات', onBack: () => context.pop()),
          Expanded(child: Center(child: Text('حدث خطأ: $e',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.error)))),
        ]),
        data: (data) {
          final pending = data.requests.where((r) => r.status == 'pending').toList();
          return Column(children: [
            AdminAppBar(title: 'صندوق الموافقات',
              subtitle: '${pending.length} طلبات معلقة',
              onBack: () => context.pop()),
            Expanded(child: pending.isEmpty
              ? Center(child: Text('لا توجد طلبات معلقة', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 14, color: AppColors.tx3)))
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(managerRequestsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: pending.length,
                    itemBuilder: (_, i) {
                      final r = pending[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppShadows.card,
                          border: Border(right: BorderSide(
                            color: AppColors.warning, width: 4))),
                        child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(_fmtDate(r.createdAt), style: TextStyle(fontFamily: 'Cairo',
                              fontSize: 11, color: AppColors.tx3)),
                            Row(children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(r.employee?.name ?? '—', style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                                Text(r.employee?.code ?? '', style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 11, color: AppColors.tx3)),
                              ]),
                              const SizedBox(width: 10),
                              AdminAvatar(
                                initials: (r.employee?.name ?? '?').characters.first,
                                size: 38, fontSize: 14),
                            ]),
                          ]),
                          const SizedBox(height: 10),
                          Container(width: double.infinity, padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColors.bg,
                              borderRadius: BorderRadius.circular(10)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(_typeAr(r.requestType), style: TextStyle(fontFamily: 'Cairo',
                                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
                              Text(r.subject, style: TextStyle(fontFamily: 'Cairo',
                                fontSize: 11, color: AppColors.tx3)),
                            ])),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: GestureDetector(
                              onTap: () => context.push('/request-detail', extra: r.id),
                              child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(color: AppColors.navySoft,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: AppColors.navyBorder)),
                                child: Center(child: Text('التفاصيل', style: TextStyle(fontFamily: 'Cairo',
                                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyMid)))))),
                            const SizedBox(width: 8),
                            Expanded(child: GestureDetector(
                              onTap: () => context.push('/request-detail', extra: r.id),
                              child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(gradient: AppColors.tealGradient,
                                  borderRadius: BorderRadius.circular(9), boxShadow: AppShadows.teal),
                                child: Center(child: Text('مراجعة', style: TextStyle(fontFamily: 'Cairo',
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
