import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../data/models/local_notification_model.dart';
import '../providers/notifications_providers.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DOCUMENTS OVERVIEW
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DocumentsOverviewScreen extends ConsumerWidget {
  const DocumentsOverviewScreen({super.key});

  /// Map category key to a color for the card accent.
  static Color _colorForCategory(String key) {
    switch (key) {
      case 'contracts':
        return AppColors.navyMid;
      case 'insurance':
        return AppColors.warning;
      case 'certificates':
        return AppColors.success;
      case 'requests':
        return AppColors.error;
      case 'policies':
        return AppColors.teal;
      case 'travel':
        return AppColors.gold;
      default:
        return AppColors.navyMid;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(documentCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // ── Header ──
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
                Text('Document Management'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Documents overview'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: AppColors.goldLight)),
              ])),
              const SizedBox(width: 36),
            ]),
            const SizedBox(height: 14),
            // Alert - expiring docs
            categoriesAsync.when(
              data: (data) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4))),
                child: Row(children: [
                  Text('docs_in_system'.tr(context, params: {'count': '${data.totalDocuments}'}), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Text('📂', style: TextStyle(fontSize: 16)),
                ])),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ]),
        ),
        // ── Body ──
        Expanded(child: categoriesAsync.when(
          data: (data) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(documentCategoriesProvider);
              await ref.read(documentCategoriesProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Stats
                SectionHeader(title: 'Overview'.tr(context)),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5,
                  children: data.categories.map((cat) {
                    final color = _colorForCategory(cat.key);
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.card,
                          border: Border(bottom: BorderSide(color: color, width: 3))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6)),
                              child: Text('${cat.count}', style: TextStyle(fontFamily: 'Cairo',
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: color))),
                            Text(cat.icon, style: const TextStyle(fontSize: 22)),
                          ]),
                          const SizedBox(height: 6),
                          Text('${cat.count}', style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 26, fontWeight: FontWeight.w900,
                            color: color, height: 1)),
                          Text(cat.label, style: TextStyle(fontFamily: 'Cairo',
                            fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tx2),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Error loading documents'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.tx2)),
              const SizedBox(height: 8),
              Text('$err', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 11, color: AppColors.tx3), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(documentCategoriesProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text('Retry'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyMid,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ]),
          )),
        )),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NOTIFICATIONS CENTER (SQLite-backed)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class NotificationsCenterScreen extends ConsumerStatefulWidget {
  const NotificationsCenterScreen({super.key});
  @override ConsumerState<NotificationsCenterScreen> createState() => _NotifState();
}
class _NotifState extends ConsumerState<NotificationsCenterScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final notifs = state.visible;
    final unread = state.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // ── Header ──
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 14, left: 18, right: 18),
          child: Row(children: [
            // Mark all read
            GestureDetector(
              onTap: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9)),
                child: Text('Mark all read'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)))),
            Expanded(child: Column(children: [
              Text('Notifications Center'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              if (unread > 0) Text('unread_notifications'.tr(context, params: {'count': '$unread'}), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 11, color: AppColors.goldLight)),
            ])),
            // Back + Refresh
            Row(children: [
              GestureDetector(
                onTap: () => ref.read(notificationsProvider.notifier).fetchFirstPage(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 18))),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
            ]),
          ]),
        ),
        // ── Body ──
        Expanded(child: _buildBody(notifs, state)),
      ]),
    );
  }

  Widget _buildBody(List<LocalNotification> notifs, NotificationsState state) {
    if (notifs.isEmpty && !state.isLoading) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔔', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text('No notifications'.tr(context), style: TextStyle(fontFamily: 'Cairo',
          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.tx3)),
        const SizedBox(height: 6),
        Text('Notifications will appear here'.tr(context), style: TextStyle(fontFamily: 'Cairo',
          fontSize: 12, color: AppColors.g400)),
      ]));
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: notifs.length + (state.isLoading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= notifs.length) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator()));
        }

        final n = notifs[i];
        return Dismissible(
          key: ValueKey(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.error, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.delete, color: Colors.white)),
          onDismissed: (_) => ref.read(notificationsProvider.notifier).deleteById(n.id),
          child: GestureDetector(
            onTap: () {
              if (!n.isRead) ref.read(notificationsProvider.notifier).markAsRead(n.id);
              if (n.route != null && n.route!.isNotEmpty) context.push(n.route!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: n.isRead ? AppColors.bgCard : AppColors.navyGhost,
                borderRadius: BorderRadius.circular(16),
                boxShadow: n.isRead ? AppShadows.sm : AppShadows.card,
                border: n.isRead
                  ? null
                  : Border.all(color: AppColors.navyBorder, width: 1.5)),
              child: Row(children: [
                // Unread indicator
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  if (!n.isRead)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.navyMid, shape: BoxShape.circle)),
                ]),
                const SizedBox(width: 8),
                // Content
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(n.timeAgo, style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 10, color: AppColors.g400)),
                    Flexible(child: Text(n.titleByLang('ar'), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                      color: AppColors.tx1),
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                  ]),
                  const SizedBox(height: 4),
                  Text(n.bodyByLang('ar'), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 12, color: AppColors.tx3, height: 1.6),
                    textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(width: 10),
                // Icon
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.navyMid.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('🔔', style: TextStyle(fontSize: 18)))),
              ]),
            ),
          ),
        );
      },
    );
  }
}
