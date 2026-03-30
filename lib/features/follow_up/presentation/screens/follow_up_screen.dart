import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';

// ── Follow-Up List Screen ─────────────────────────────────
class FollowUpScreen extends ConsumerStatefulWidget {
  const FollowUpScreen({super.key});
  @override
  ConsumerState<FollowUpScreen> createState() => _FollowUpState();
}

class _FollowUpState extends ConsumerState<FollowUpScreen> {
  int _tab = 0;

  static const _tabFilters = <String?>[
    null,       // الكل
    'overdue',  // متأخر
    'escalated',// مُصعَّد
    'in_progress', // جارٍ
    'pending',  // معلق
  ];

  void _onTabSelect(int i) {
    setState(() => _tab = i);
    final value = _tabFilters[i];
    // 'escalated' is not a status value; clear status filter for it
    if (value == 'escalated') {
      ref.read(followUpsStatusFilter.notifier).state = null;
    } else {
      ref.read(followUpsStatusFilter.notifier).state = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(followUpsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Error'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(followUpsProvider),
              child: Text('Retry'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
            ),
          ]),
        ),
        data: (data) {
          final stats = data.stats;
          final items = data.followUps;

          // Local filtering for escalated tab (not a status value)
          final filtered = _tab == 2
              ? items.where((f) => f.isEscalated).toList()
              : items;

          return Column(children: [
            // ── Header ──
            Container(
              decoration: const BoxDecoration(gradient: AppColors.navyGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 16, left: 18, right: 18),
              child: Column(children: [
                Row(children: [
                  const SizedBox(width: 36),
                  Expanded(child: Column(children: [
                    Text('Follow-up Board'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('items_followup'.tr(context, params: {'count': '${stats.total}'}), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, color: AppColors.goldLight)),
                  ])),
                  const SizedBox(width: 36),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _pill('Overdue'.tr(context), '${stats.overdue}',     AppColors.error,       AppColors.errorSoft.withOpacity(0.3)),
                  const SizedBox(width: 8),
                  _pill('Escalated'.tr(context), '${stats.escalated}', AppColors.warningDark,  AppColors.warningSoft.withOpacity(0.3)),
                  const SizedBox(width: 8),
                  _pill('In Progress'.tr(context),   '${stats.inProgress}', AppColors.tealLight,   AppColors.tealSoft.withOpacity(0.3)),
                  const SizedBox(width: 8),
                  _pill('Pending'.tr(context),   '${stats.pending}',    AppColors.goldLight,   AppColors.goldSoft.withOpacity(0.3)),
                ]),
              ]),
            ),

            // ── Filter tabs ──
            FilterBar(
              tabs: ['All'.tr(context),'Overdue'.tr(context),'Escalated'.tr(context),'In Progress'.tr(context),'Pending'.tr(context)],
              selected: _tab,
              onSelect: _onTabSelect,
            ),

            // ── List ──
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(followUpsProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    if (stats.overdue > 0 || stats.escalated > 0)
                      AlertBanner(
                        message: 'overdue_escalated_alert'.tr(context, params: {'overdue': '${stats.overdue}', 'escalated': '${stats.escalated}'}),
                        type: 'error'),
                    ...filtered.map((f) => FollowUpCard(
                      id: '${f.id}',
                      title: f.title,
                      responsible: f.responsible.name,
                      dept: f.department.name,
                      dueDate: f.dueDate,
                      status: f.status,
                      isOverdue: f.isOverdue,
                      isEscalated: f.isEscalated,
                      onTap: () => context.push('/follow-up-detail/${f.id}'),
                    )),
                  ],
                ),
              ),
            ),
          ]);
        },
      ),
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
class FollowUpDetailScreen extends ConsumerWidget {
  final int followUpId;
  const FollowUpDetailScreen({super.key, required this.followUpId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(followUpDetailProvider(followUpId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: asyncDetail.when(
        loading: () => Column(children: [
          AdminAppBar(title: 'تفاصيل المتابعة', subtitle: '#$followUpId',
            onBack: () => context.pop()),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (err, _) => Column(children: [
          AdminAppBar(title: 'تفاصيل المتابعة', subtitle: '#$followUpId',
            onBack: () => context.pop()),
          Expanded(child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Error'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.error)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(followUpDetailProvider(followUpId)),
                child: Text('Retry'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
              ),
            ]),
          )),
        ]),
        data: (f) => Column(children: [
          AdminAppBar(title: 'تفاصيل المتابعة', subtitle: '#${f.id}',
            onBack: () => context.pop()),
          Expanded(child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(followUpDetailProvider(followUpId)),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                if (f.isOverdue) const AlertBanner(message: 'هذا البند تجاوز الموعد النهائي — يحتاج إجراء عاجل', type: 'error'),
                if (f.isEscalated) const AlertBanner(message: 'تم تصعيد هذا البند للإدارة العليا', type: 'warning'),

                // ── Info card ──
                AppCard(mb: 14, child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      if (f.isEscalated) ...[
                        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(6)),
                          child: Text('🚨 مُصعَّد', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error))),
                        const SizedBox(width: 6),
                      ],
                      StatusBadge(
                        text: f.isOverdue ? 'متأخر' : _statusLabel(f.status),
                        type: f.isOverdue ? 'overdue' : _statusBadgeType(f.status),
                        dot: true),
                    ]),
                    Flexible(child: Text(f.title, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right)),
                  ]),
                  const Divider(height: 20, color: AppColors.g100),
                  InfoRow(label: 'المسؤول',       value: f.responsible.name, icon: '👤'),
                  InfoRow(label: 'الإدارة',       value: f.department.name,  icon: '🏢'),
                  InfoRow(label: 'الموعد النهائي', value: f.dueDate,         icon: '📅'),
                  InfoRow(label: 'النوع',          value: _typeLabel(f.type), icon: '📋'),
                  InfoRow(label: 'الحالة',         value: _statusLabel(f.status), icon: '🔄', border: false),
                ])),

                // ── History / timeline card ──
                AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('سجل المتابعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
                  const SizedBox(height: 14),
                  TimelineWidget(steps: f.history.asMap().entries.map((e) {
                    final h = e.value;
                    final isLast = e.key == f.history.length - 1;
                    final sub = h.from != null && h.to != null
                        ? '${h.at} — ${h.from} → ${h.to}'
                        : '${h.at} — ${h.by}';
                    return TLStep(
                      label: h.action,
                      sub: sub,
                      done: !isLast,
                      active: isLast,
                    );
                  }).toList()),
                ])),

                // ── Action card ──
                AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('إجراء المتابعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  TextField(maxLines: 3, 
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    decoration: fieldDec('سجّل الإجراء المتخذ...')),
                ])),
              ]),
            ),
          )),
          StickyBar(child: Row(children: [
            Expanded(child: DangerBtn(text: '🚨 تصعيد', onTap: () {})),
            const SizedBox(width: 10),
            Expanded(child: OutlineBtn(text: '↩ إعادة تكليف', onTap: () {})),
            const SizedBox(width: 10),
            Expanded(child: TealBtn(text: '✓ أُغلق', onTap: () {})),
          ])),
        ]),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'overdue':     return 'متأخر';
      case 'in_progress': return 'جارٍ';
      case 'pending':     return 'معلق';
      case 'completed':   return 'مكتمل';
      default:            return status;
    }
  }

  String _statusBadgeType(String status) {
    switch (status) {
      case 'overdue':     return 'overdue';
      case 'in_progress': return 'teal';
      case 'pending':     return 'gold';
      case 'completed':   return 'success';
      default:            return 'teal';
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'task':     return 'مهمة';
      case 'approval': return 'موافقة';
      case 'hr':       return 'موارد بشرية';
      case 'finance':  return 'مالية';
      default:         return type;
    }
  }
}
