import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class AdminShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AdminShell({super.key, required this.navigationShell});

  // ════════════════════════════════════════════════════════════════
  // More menu (modal sheet)
  // ════════════════════════════════════════════════════════════════
  void _showMoreMenu(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.78),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: AppShadows.elevated,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 14,
          left: 18,
          right: 18,
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Drag handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: c.gray200, borderRadius: BorderRadius.circular(99)),
            ),
            const SizedBox(height: 16),

            // Header row
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: c.gray100,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.close_rounded, size: 14, color: c.textMuted),
                    const SizedBox(width: 4),
                    Text('Close'.tr(context),
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              Row(children: [
                Container(
                  width: 4, height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [AppColors.gold, AppColors.goldDark],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text('More Modules'.tr(context),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: c.textPrimary,
                    )),
              ]),
            ]),

            const SizedBox(height: 18),

            _MoreItem(icon: Icons.settings_rounded, label: 'Settings'.tr(context),
                sub: 'Settings desc'.tr(context), color: AppColors.g600, route: '/settings'),

            const SizedBox(height: 14),
            _SectionHeader(text: 'Additional Modules'.tr(context)),
            _MoreItem(icon: Icons.architecture_rounded, label: 'Project Management'.tr(context),
                sub: 'Projects phases tracking'.tr(context), color: AppColors.navyMid,    route: '/projects'),
            _MoreItem(icon: Icons.payments_rounded,     label: 'Expense Management'.tr(context),
                sub: 'Expense requests categories'.tr(context), color: AppColors.gold,    route: '/expenses'),
            _MoreItem(icon: Icons.analytics_rounded,    label: 'Project Analytics'.tr(context),
                sub: 'KPIs project performance'.tr(context),   color: AppColors.teal,     route: '/project-analytics'),
            _MoreItem(icon: Icons.credit_card_rounded,  label: 'Expense Approval'.tr(context),
                sub: 'Pending high follow-up'.tr(context),     color: AppColors.error,    route: '/expense-follow-up'),

            const SizedBox(height: 14),
            _SectionHeader(text: 'Admin Modules'.tr(context)),
            _MoreItem(icon: Icons.apartment_rounded,    label: 'Departments'.tr(context),
                sub: 'Depts overview desc'.tr(context),        color: AppColors.navyLight, route: '/departments'),
            _MoreItem(icon: Icons.groups_rounded,       label: 'Employees'.tr(context),
                sub: 'Employee directory desc'.tr(context),    color: AppColors.navyMid,   route: '/employees'),
            _MoreItem(icon: Icons.timer_outlined,       label: 'Attendance Management'.tr(context),
                sub: 'Attendance desc'.tr(context),            color: AppColors.teal,      route: '/attendance'),
            _MoreItem(icon: Icons.beach_access_rounded, label: 'Leave Management'.tr(context),
                sub: 'Leave desc'.tr(context),                 color: AppColors.success,   route: '/leave'),
            _MoreItem(icon: Icons.campaign_rounded,     label: 'Announcements'.tr(context),
                sub: 'Announcements desc'.tr(context),         color: AppColors.gold,      route: '/announcements'),
            _MoreItem(icon: Icons.description_rounded,  label: 'Documents'.tr(context),
                sub: 'Documents desc'.tr(context),             color: AppColors.info,      route: '/documents'),
            _MoreItem(icon: Icons.bar_chart_rounded,    label: 'Reports KPIs'.tr(context),
                sub: 'Reports desc'.tr(context),               color: AppColors.navyDeep,  route: '/reports'),

            const SizedBox(height: 16),
            Divider(color: c.gray100, height: 1),
            const SizedBox(height: 12),

            // Logout
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context, ref);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
                ),
                child: Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Logout'.tr(context),
                          style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 13.5,
                            fontWeight: FontWeight.w800, color: AppColors.error,
                          )),
                      Text('Logout from account'.tr(context),
                          style: TextStyle(
                            fontFamily: 'Cairo', fontSize: 11,
                            color: AppColors.error.withValues(alpha: 0.65),
                          )),
                    ]),
                  ),
                  Icon(Icons.chevron_left_rounded, color: AppColors.error.withValues(alpha: 0.6), size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 6),
          ]),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Logout dialog
  // ════════════════════════════════════════════════════════════════
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('Logout'.tr(context),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
          ),
        ]),
        content: Text('Logout confirm'.tr(context),
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: c.textSecondary, height: 1.6),
            textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.tr(context),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: c.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: Text('Logout'.tr(context),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Build
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(i, initialLocation: true),
        onMore: () => _showMoreMenu(context, ref),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Premium Bottom Navigation Bar
// ════════════════════════════════════════════════════════════════════
class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onMore;
  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.onMore,
  });

  static const _items = <_NavItemData>[
    _NavItemData(icon: Icons.dashboard_rounded,   activeIcon: Icons.dashboard_rounded,        labelKey: 'Dashboard'),
    _NavItemData(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded,       labelKey: 'Requests'),
    _NavItemData(icon: Icons.task_alt_outlined,   activeIcon: Icons.task_alt_rounded,         labelKey: 'Tasks'),
    _NavItemData(icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check_rounded,       labelKey: 'Follow up'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        border: Border(top: BorderSide(color: c.gray100)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDeep.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                for (int i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavTile(
                      data: _items[i],
                      active: currentIndex == i,
                      onTap: () => onTap(i),
                    ),
                  ),
                Expanded(child: _MoreNavTile(onTap: onMore)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon, activeIcon;
  final String labelKey;
  const _NavItemData({required this.icon, required this.activeIcon, required this.labelKey});
}

class _NavTile extends StatelessWidget {
  final _NavItemData data;
  final bool active;
  final VoidCallback onTap;
  const _NavTile({required this.data, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.navyMid.withValues(alpha: 0.08),
        highlightColor: AppColors.navyMid.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: active ? AppColors.navySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: active ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      active ? data.activeIcon : data.icon,
                      size: 22,
                      color: active ? AppColors.navyMid : c.gray400,
                    ),
                  ),
                  if (active)
                    Positioned(
                      top: -3, right: -6,
                      child: Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  data.labelKey.tr(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5,
                    height: 1.1,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active ? AppColors.navyMid : c.gray400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreNavTile extends StatelessWidget {
  final VoidCallback onTap;
  const _MoreNavTile({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38, height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.navyMid, AppColors.navy],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navyMid.withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.grid_view_rounded, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  'More'.tr(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyMid,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// More-menu helpers
// ════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: c.textMuted,
                  letterSpacing: 0.6,
                )),
            const SizedBox(width: 8),
            Container(
              width: 14, height: 2,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label, sub, route;
  final Color color;
  const _MoreItem({
    required this.icon, required this.label, required this.sub,
    required this.color, required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: c.bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () { Navigator.pop(context); context.push(route); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.gray100),
            ),
            child: Row(children: [
              Icon(Icons.chevron_left_rounded, color: c.gray300, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(label,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: c.textMuted,
                      )),
                ]),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Center(child: Icon(icon, color: color, size: 20)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
