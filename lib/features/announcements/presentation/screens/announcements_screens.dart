import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../data/models/announcement_models.dart';

// ── Announcements Management ──────────────────────────────
class AnnouncementsManagementScreen extends ConsumerStatefulWidget {
  const AnnouncementsManagementScreen({super.key});
  @override
  ConsumerState<AnnouncementsManagementScreen> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends ConsumerState<AnnouncementsManagementScreen> {
  int _tab = 0;

  void _onTabChanged(int i) {
    setState(() => _tab = i);
    final status = switch (i) {
      1 => 'published',
      2 => 'draft',
      _ => null,
    };
    ref.read(announcementsStatusFilter.notifier).state = status;
  }

  @override
  Widget build(BuildContext context) {
    final asyncAnnouncements = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: asyncAnnouncements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('حدث خطأ', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error)),
            const SizedBox(height: 8),
            Text('$e', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 12, color: AppColors.tx3), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => ref.invalidate(announcementsProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.navyGradient,
                  borderRadius: BorderRadius.circular(10)),
                child: Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)))),
          ])),
        data: (data) {
          final all = data.announcements;
          final published = all.where((a) => a.publishStatus == 'published').length;
          final drafts = all.where((a) => a.publishStatus == 'draft').length;
          final pinned = all.where((a) => a.isPinned).length;

          return Column(children: [
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
                    Text('إدارة الإعلانات', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('${all.length} إعلانات', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, color: AppColors.goldLight)),
                  ])),
                  GestureDetector(
                    onTap: () => context.push('/create-announcement'),
                    child: Container(width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Icon(Icons.add, color: Colors.white, size: 20)))),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _pill('$published', 'منشور', AppColors.tealLight),
                  const SizedBox(width: 8),
                  _pill('$drafts', 'مسودة', AppColors.warning),
                  const SizedBox(width: 8),
                  _pill('$pinned', 'مثبّت', AppColors.goldLight),
                  const SizedBox(width: 8),
                  _pill('${all.length}', 'إجمالي', Colors.white70),
                ]),
              ]),
            ),
            FilterBar(
              tabs: ['الكل', 'منشور', 'مسودة', 'مثبّت'],
              selected: _tab, onSelect: _onTabChanged),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(announcementsProvider),
                child: _buildList(all),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _buildList(List<Announcement> all) {
    // Client-side filter for pinned tab (tab index 3) since the API
    // only supports published/draft status filtering.
    final filtered = _tab == 3 ? all.where((a) => a.isPinned).toList() : all;

    if (filtered.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          EmptyState(icon: '📢', title: 'لا توجد إعلانات', subtitle: 'لم يتم العثور على إعلانات'),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final a = filtered[i];
        final statusLabel = a.publishStatus == 'published' ? 'منشور' : 'مسودة';
        final displayDate = a.publishedAt ?? a.createdAt;
        return GestureDetector(
          onTap: () => context.push('/announcement-detail', extra: a),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
              border: Border(
                right: BorderSide(
                  color: a.isPinned ? AppColors.gold
                    : a.publishStatus == 'published' ? AppColors.navyMid
                    : AppColors.g300,
                  width: 3.5))),
            child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  StatusBadge(
                    text: statusLabel,
                    type: a.publishStatus == 'published' ? 'approved' : 'pending'),
                  if (a.isPinned) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldSoft, borderRadius: BorderRadius.circular(6)),
                      child: Text('📌 مثبّت', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldDark))),
                  ],
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(a.title, style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 13, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(a.category, style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 11, color: AppColors.tx3)),
                ]),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(displayDate, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
                Row(children: [
                  const Text('👥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(a.audience, style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 11, color: AppColors.tx3)),
                ]),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('🗑 حذف', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)))))),
                const SizedBox(width: 8),
                Expanded(child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.navySoft,
                      border: Border.all(color: AppColors.navyBorder),
                      borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('✏️ تعديل', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navyMid)))))),
                const SizedBox(width: 8),
                Expanded(child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      gradient: a.publishStatus == 'published' ? null : AppColors.tealGradient,
                      color: a.publishStatus == 'published' ? AppColors.g100 : null,
                      borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(
                      a.publishStatus == 'published' ? '📤 أُرسل' : '📢 نشر',
                      style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: a.publishStatus == 'published' ? AppColors.g400 : Colors.white)))))),
              ]),
            ])),
          ),
        );
      },
    );
  }

  Widget _pill(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
    ])));
}

// ── Announcement Detail ───────────────────────────────────
class AnnouncementDetailScreen extends ConsumerWidget {
  final int announcementId;
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = GoRouterState.of(context).extra as Announcement;
    final statusLabel = a.publishStatus == 'published' ? 'منشور' : 'مسودة';
    final displayDate = a.publishedAt ?? a.createdAt;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'تفاصيل الإعلان', onBack: () => context.pop(),
          trailing: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text('✏️ تعديل', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70))))),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            // Status bar
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                StatusBadge(text: statusLabel,
                  type: a.publishStatus == 'published' ? 'approved' : 'pending'),
                if (a.isPinned) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldSoft, borderRadius: BorderRadius.circular(6)),
                    child: Text('📌 مثبّت', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldDark))),
                ],
              ]),
              StatusBadge(text: a.category, type: 'navy'),
            ]),
            const SizedBox(height: 12),
            Text(a.title, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 20, fontWeight: FontWeight.w900, height: 1.3)),
            const SizedBox(height: 8),
            // Meta info
            AppCard(mb: 14, child: Column(children: [
              InfoRow(label: 'تاريخ النشر', value: displayDate, icon: '📅'),
              InfoRow(label: 'الجمهور المستهدف', value: a.audience, icon: '👥'),
              InfoRow(label: 'الفئة', value: a.category, icon: '🏷'),
              InfoRow(label: 'حالة النشر', value: statusLabel, icon: '📢', border: false),
            ])),
            // Body
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('محتوى الإعلان', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(a.body, style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, color: AppColors.tx2, height: 2.0)),
            ])),
            // Attachments placeholder
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('المرفقات', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const EmptyState(icon: '📎', title: 'لا توجد مرفقات',
                subtitle: 'لم يتم إرفاق ملفات بهذا الإعلان'),
            ])),
            // Reach stats
            AppCard(child: Column(children: [
              Align(alignment: Alignment.centerRight, child: Text('إحصاء الوصول',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800))),
              const SizedBox(height: 12),
              Row(children: [
                _reachStat('89', 'قرأ', AppColors.navyMid),
                const SizedBox(width: 8),
                _reachStat('12', 'لم يقرأ', AppColors.warning),
                const SizedBox(width: 8),
                _reachStat('101', 'المستهدفون', AppColors.g500),
              ]),
            ])),
          ]),
        )),
        StickyBar(child: Row(children: [
          Expanded(child: DangerBtn(text: '🗑 حذف', onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: a.publishStatus == 'draft'
            ? TealBtn(text: '📢 نشر الآن', onTap: () {})
            : OutlineBtn(text: '↩ إلغاء النشر', onTap: () {})),
        ])),
      ]),
    );
  }

  Widget _reachStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 22, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
    ])));
}
