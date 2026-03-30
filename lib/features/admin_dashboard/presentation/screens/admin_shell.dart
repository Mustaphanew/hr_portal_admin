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

  void _showMoreMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            top: 16, left: 20, right: 20),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.g200, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(99)),
                  child: Text('Close'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.tx3)))),
              Text('More Modules'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.tx1)),
            ]),
            const SizedBox(height: 16),
            _moreItem(context, '⚙️', 'Settings'.tr(context), 'Settings desc'.tr(context), AppColors.g600, '/settings'),
            const SizedBox(height: 12),
            _sectionHeader('Additional Modules'.tr(context)),
            _moreItem(context, '🏗', 'Project Management'.tr(context),    'Projects phases tracking'.tr(context),      AppColors.navyMid,   '/projects'),
            _moreItem(context, '💰', 'Expense Management'.tr(context),  'Expense requests categories'.tr(context),   AppColors.gold,      '/expenses'),
            _moreItem(context, '📊', 'Project Analytics'.tr(context), 'KPIs project performance'.tr(context),       AppColors.teal,      '/project-analytics'),
            _moreItem(context, '💳', 'Expense Approval'.tr(context), 'Pending high follow-up'.tr(context),  AppColors.error,     '/expense-follow-up'),
            const SizedBox(height: 12),
            _sectionHeader('Admin Modules'.tr(context)),
            _moreItem(context, '🏢', 'Departments'.tr(context),          'Depts overview desc'.tr(context),  AppColors.navyLight, '/departments'),
            _moreItem(context, '👥', 'Employees'.tr(context),          'Employee directory desc'.tr(context),           AppColors.navyMid,   '/employees'),
            _moreItem(context, '⏱', 'Attendance Management'.tr(context),      'Attendance desc'.tr(context),      AppColors.teal,      '/attendance'),
            _moreItem(context, '🌴', 'Leave Management'.tr(context),   'Leave desc'.tr(context),     AppColors.success,   '/leave'),
            _moreItem(context, '📢', 'Announcements'.tr(context),         'Announcements desc'.tr(context),             AppColors.gold,      '/announcements'),
            _moreItem(context, '📄', 'Documents'.tr(context),         'Documents desc'.tr(context),           AppColors.info,      '/documents'),
            _moreItem(context, '📋', 'Reports KPIs'.tr(context), 'Reports desc'.tr(context),  AppColors.navyDeep,  '/reports'),
            const SizedBox(height: 16),
            const Divider(color: AppColors.g200, height: 1),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context, ref);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.2))),
                child: Row(children: [
                  const Icon(Icons.chevron_left, color: AppColors.error, size: 18),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Logout'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
                    Text('Logout from account'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 11, color: AppColors.error.withValues(alpha: 0.6))),
                  ])),
                  const SizedBox(width: 10),
                  Container(width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Icon(Icons.logout, color: AppColors.error, size: 20))),
                ])),
            ),
            const SizedBox(height: 6),
          ])),
        ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('Logout'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            const Icon(Icons.logout, color: AppColors.error, size: 22),
          ]),
          content: Text('Logout confirm'.tr(context),
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.tx2, height: 1.6),
            textAlign: TextAlign.right),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.tx3))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              child: Text('Logout'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
          ],
        ),
    );
  }

  Widget _sectionHeader(String t) => Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tx3, letterSpacing: 0.5))));

  Widget _moreItem(BuildContext ctx, String ico, String label, String sub, Color c, String route) =>
    GestureDetector(
      onTap: () { Navigator.pop(ctx); ctx.push(route); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.chevron_left, color: AppColors.g300, size: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tx1)),
            Text(sub, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
          ])),
          const SizedBox(width: 10),
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(ico, style: const TextStyle(fontSize: 18)))),
        ])));

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: const Border(top: BorderSide(color: AppColors.g100)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0,-4))]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
                _NavItem(icon: '🏠', label: 'Dashboard'.tr(context),  active: navigationShell.currentIndex==0,
                  onTap: () => navigationShell.goBranch(0, initialLocation: true)),
                _NavItem(icon: '📋', label: 'Requests'.tr(context),  active: navigationShell.currentIndex==1,
                  onTap: () => navigationShell.goBranch(1, initialLocation: true)),
                _NavItem(icon: '✅', label: 'Tasks'.tr(context),   active: navigationShell.currentIndex==2,
                  onTap: () => navigationShell.goBranch(2, initialLocation: true)),
                _NavItem(icon: '🔄', label: 'Follow up'.tr(context), active: navigationShell.currentIndex==3,
                  onTap: () => navigationShell.goBranch(3, initialLocation: true)),
                _NavMoreBtn(label: 'More'.tr(context), onTap: () => _showMoreMenu(context, ref)),
              ]),
          ),
        ),
      ),
  );
}

class _NavItem extends StatelessWidget {
  final String icon, label; final bool active; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedScale(scale: active ? 1.2 : 1.0, duration: const Duration(milliseconds: 200),
          child: Text(icon, style: const TextStyle(fontSize: 22))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
          fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          color: active ? AppColors.navyMid : AppColors.g400)),
        if (active) Container(margin: const EdgeInsets.only(top: 2),
          width: 18, height: 3,
          decoration: BoxDecoration(color: AppColors.navyMid, borderRadius: BorderRadius.circular(99))),
      ]),
    ),
  );
}

class _NavMoreBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavMoreBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 26,
          decoration: BoxDecoration(
            gradient: AppColors.navyGradient, borderRadius: BorderRadius.circular(8),
            boxShadow: AppShadows.sm),
          child: Center(child: Text('⋯', style: TextStyle(fontFamily: 'Cairo',
            fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900, height: 1.1)))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontFamily: 'Cairo',
          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
      ]),
    ),
  );
}
