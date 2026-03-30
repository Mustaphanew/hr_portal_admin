import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';

class AdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AdminShell({super.key, required this.navigationShell});

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
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
                  child: Text('إغلاق', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.tx3)))),
              Text('المزيد من الوحدات', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.tx1)),
            ]),
            const SizedBox(height: 16),
            _sectionHeader('🆕 وحدات إضافية'),
            _moreItem(context, '🏗', 'إدارة المشاريع',    'المشاريع والمراحل والمتابعة',      AppColors.navyMid,   '/projects'),
            _moreItem(context, '💰', 'إدارة المصروفات',  'طلبات الصرف والفئات والتحليلات',   AppColors.gold,      '/expenses'),
            _moreItem(context, '📊', 'تحليلات المشاريع', 'KPIs ومؤشرات أداء المشاريع',       AppColors.teal,      '/project-analytics'),
            _moreItem(context, '💳', 'اعتماد المصروفات', 'المعلقة والعالية — متابعة فورية',  AppColors.error,     '/expense-follow-up'),
            const SizedBox(height: 12),
            _sectionHeader('🏛 وحدات إدارية'),
            _moreItem(context, '🏢', 'الإدارات',          'نظرة شاملة على الإدارات والأداء',  AppColors.navyLight, '/departments'),
            _moreItem(context, '👥', 'الموظفون',          'دليل الموظفين وسجلاتهم',           AppColors.navyMid,   '/employees'),
            _moreItem(context, '⏱', 'إدارة الحضور',      'الحضور والغياب والاستثناءات',      AppColors.teal,      '/attendance'),
            _moreItem(context, '🌴', 'إدارة الإجازات',   'طلبات الإجازة وإجازات اليوم',     AppColors.success,   '/leave'),
            _moreItem(context, '📢', 'الإعلانات',         'إدارة ونشر الإعلانات',             AppColors.gold,      '/announcements'),
            _moreItem(context, '📄', 'المستندات',         'وثائق ومرفقات الموظفين',           AppColors.info,      '/documents'),
            _moreItem(context, '📋', 'التقارير والـKPIs', 'تحليلات وتقارير الأداء الشاملة',  AppColors.navyDeep,  '/reports'),
            const SizedBox(height: 6),
          ])),
        ),
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
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
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
              _NavItem(icon: '🏠', label: 'الإدارة',  active: navigationShell.currentIndex==0,
                onTap: () => navigationShell.goBranch(0, initialLocation: true)),
              _NavItem(icon: '📋', label: 'الطلبات',  active: navigationShell.currentIndex==1,
                onTap: () => navigationShell.goBranch(1, initialLocation: true)),
              _NavItem(icon: '✅', label: 'المهام',   active: navigationShell.currentIndex==2,
                onTap: () => navigationShell.goBranch(2, initialLocation: true)),
              _NavItem(icon: '🔄', label: 'المتابعة', active: navigationShell.currentIndex==3,
                onTap: () => navigationShell.goBranch(3, initialLocation: true)),
              _NavMoreBtn(onTap: () => _showMoreMenu(context)),
            ]),
          ),
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
  final VoidCallback onTap;
  const _NavMoreBtn({required this.onTap});
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
        Text('المزيد', style: TextStyle(fontFamily: 'Cairo',
          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
      ]),
    ),
  );
}
