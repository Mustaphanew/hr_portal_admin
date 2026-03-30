import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'package:go_router/go_router.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADMIN SETTINGS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final localeMode = ref.watch(localeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'الإعدادات', onBack: () => context.pop()),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          children: [

            // ── Theme Section ──────────────────────────────────
            _SectionHeader(icon: Icons.palette_outlined, title: 'المظهر'),
            _OptionCard(children: [
              _RadioOption<ThemeMode>(
                icon: Icons.settings_suggest_outlined,
                label: 'تلقائي (حسب النظام)',
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v)),
              const Divider(height: 0.5, color: AppColors.g200),
              _RadioOption<ThemeMode>(
                icon: Icons.light_mode_outlined,
                label: 'فاتح',
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v)),
              const Divider(height: 0.5, color: AppColors.g200),
              _RadioOption<ThemeMode>(
                icon: Icons.dark_mode_outlined,
                label: 'داكن',
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v)),
            ]),
            const SizedBox(height: 20),

            // ── Language Section ────────────────────────────────
            _SectionHeader(icon: Icons.language, title: 'اللغة'),
            _OptionCard(children: [
              _RadioOption<AppLocaleMode>(
                icon: Icons.settings_suggest_outlined,
                label: 'تلقائي (حسب الجهاز)',
                value: AppLocaleMode.system,
                groupValue: localeMode,
                onChanged: (v) => ref.read(localeModeProvider.notifier).setMode(v)),
              const Divider(height: 0.5, color: AppColors.g200),
              _RadioOption<AppLocaleMode>(
                flag: 'AR',
                label: 'العربية',
                value: AppLocaleMode.ar,
                groupValue: localeMode,
                onChanged: (v) => ref.read(localeModeProvider.notifier).setMode(v)),
              const Divider(height: 0.5, color: AppColors.g200),
              _RadioOption<AppLocaleMode>(
                flag: 'EN',
                label: 'English',
                value: AppLocaleMode.en,
                groupValue: localeMode,
                onChanged: (v) => ref.read(localeModeProvider.notifier).setMode(v)),
            ]),
            const SizedBox(height: 20),

            // ── Account Section ────────────────────────────────
            _SectionHeader(icon: Icons.person_outline, title: 'الحساب'),
            _OptionCard(children: [
              _SettingsTile(icon: '👤', label: 'الملف الشخصي',
                desc: 'عرض وتعديل بياناتك',
                onTap: () => context.push('/admin-profile')),
              _SettingsTile(icon: '🔒', label: 'تغيير كلمة المرور',
                onTap: () {}),
              _SettingsTile(icon: '🛡', label: 'الصلاحيات والأدوار',
                desc: 'إدارة كاملة للنظام', isLast: true, onTap: () {}),
            ]),
            const SizedBox(height: 20),

            // ── System Section ─────────────────────────────────
            _SectionHeader(icon: Icons.info_outline, title: 'النظام'),
            _OptionCard(children: [
              _SettingsTile(icon: '❓', label: 'مركز المساعدة',
                onTap: () => context.push('/support')),
              _SettingsTile(icon: 'ℹ️', label: 'حول التطبيق',
                onTap: () => context.push('/about'), isLast: true),
            ]),
            const SizedBox(height: 20),

            // ── Logout ─────────────────────────────────────────
            SizedBox(height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
                      content: Text('هل أنت متأكد؟', style: TextStyle(fontFamily: 'Cairo')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false),
                          child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.tx3))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('خروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.white))),
                      ]));
                  if (confirm == true && context.mounted) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                label: Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              )),
          ],
        )),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.navyMid),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontFamily: 'Cairo',
        fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.tx1)),
    ]));
}

class _OptionCard extends StatelessWidget {
  final List<Widget> children;
  const _OptionCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppShadows.sm),
    child: Column(children: children),
  );
}

class _RadioOption<T> extends StatelessWidget {
  final IconData? icon;
  final String? flag;
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  const _RadioOption({this.icon, this.flag, required this.label,
    required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.navyMid.withOpacity(0.06) : null,
          borderRadius: BorderRadius.circular(4)),
        child: Row(children: [
          // Radio indicator
          Container(width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? AppColors.navyMid : AppColors.g300, width: 2)),
            child: selected ? Center(child: Container(width: 12, height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.navyMid))) : null),
          const SizedBox(width: 12),
          // Label
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Cairo',
            fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.navyMid : AppColors.tx2))),
          // Icon or flag
          if (icon != null) Icon(icon, size: 20, color: selected ? AppColors.navyMid : AppColors.g400),
          if (flag != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: selected ? AppColors.navyMid.withOpacity(0.12) : AppColors.g100,
              borderRadius: BorderRadius.circular(6)),
            child: Text(flag!, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 11, fontWeight: FontWeight.w800,
              color: selected ? AppColors.navyMid : AppColors.g500))),
        ]),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon, label;
  final String? desc;
  final Widget? trailing;
  final bool danger, isLast;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.label,
    this.desc, this.trailing, this.danger = false, this.isLast = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap, behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(
          bottom: BorderSide(color: AppColors.g100))),
      child: Row(children: [
        trailing ?? Icon(Icons.chevron_left,
          color: danger ? AppColors.error : AppColors.g400, size: 20),
        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(label, style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 14, fontWeight: FontWeight.w600,
              color: danger ? AppColors.error : AppColors.tx1)),
            if (desc != null) Text(desc!, style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 11, color: AppColors.tx3)),
          ]),
          const SizedBox(width: 12),
          Container(width: 36, height: 36,
            decoration: BoxDecoration(
              color: danger ? AppColors.errorSoft : AppColors.navySoft,
              borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
        ])),
      ]),
    ),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADMIN PROFILE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(authProvider).employee;
    final adminName = employee?.name ?? 'المدير';
    final adminRole = employee?.jobTitle ?? 'مدير النظام';
    final adminInitials = employee?.initials ?? '—';
    final adminCode = employee?.code ?? '';
    final adminEmail = employee?.email ?? 'غير محدد';
    final adminPhone = employee?.mobile ?? employee?.phone ?? 'غير محدد';
    final adminDept = employee?.department?.name ?? 'غير محدد';
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 24, left: 18, right: 18),
          child: Column(children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
              Expanded(child: Column(children: [
                AdminAvatar(initials: adminInitials, size: 70, fontSize: 24),
                const SizedBox(height: 10),
                Text(adminName, style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(adminRole, style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 12, color: AppColors.goldLight)),
              ])),
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Text('✏️', style: TextStyle(fontSize: 16)))),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Permissions
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('الصلاحيات والأدوار', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8,
                children: [
                  'إدارة الموارد البشرية',
                  'اعتماد الطلبات',
                  'مراجعة التقارير',
                  'إدارة الموظفين',
                  'النشر والإعلانات',
                  'إدارة المهام',
                ].map((p) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.tealSoft, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.teal.withOpacity(0.3))),
                  child: Text(p, style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal))
                )).toList()),
            ])),
            // Account info
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('بيانات الحساب', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'رقم الموظف',           value: adminCode,    icon: '🔖'),
              InfoRow(label: 'الدور الوظيفي',        value: adminRole,   icon: '💼'),
              InfoRow(label: 'القسم',                  value: adminDept,   icon: '🏢'),
              InfoRow(label: 'البريد الإلكتروني',    value: adminEmail,  icon: '✉️'),
              InfoRow(label: 'الهاتف',                value: adminPhone,  icon: '📱'),
              const InfoRow(label: 'مستوى الوصول',   value: 'إدارة عليا — صلاحيات كاملة', icon: '🛡', border: false),
            ])),
            // Activity stats
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('إحصائيات النشاط', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(children: [
                _actStat('42', 'اعتماد هذا الشهر', AppColors.success),
                const SizedBox(width: 8),
                _actStat('8',  'مرفوض هذا الشهر', AppColors.error),
                const SizedBox(width: 8),
                _actStat('15', 'مهام مُسنَدة', AppColors.navyMid),
              ]),
            ])),
          ]),
        )),
      ]),
    );
  }

  Widget _actStat(String v, String l, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: c, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.tx3, height: 1.3), textAlign: TextAlign.center),
    ])));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPPORT SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _faqs = [
    ('كيف أعتمد طلباً عاجلاً؟',    'الطلبات → صندوق الموافقات → اختر الطلب → اعتماد'),
    ('كيف أنشئ مهمة جديدة؟',       'المهام → لوحة المهام → إنشاء مهمة جديدة'),
    ('كيف أتابع بنود المتابعة؟',   'التبويب السفلي → المتابعة → عرض البنود'),
    ('كيف أرى تقارير الإدارات؟',   'التقارير → مؤشرات الأداء → اختر الإدارة'),
    ('كيف أنشر إعلاناً للموظفين؟', 'الإعلانات → إضافة جديد → نشر'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Column(children: [
      AdminAppBar(title: 'مركز المساعدة والدعم', onBack: () => context.pop()),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Contact channels
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6,
            children: [
              _contactCard('💻', 'الدعم التقني', 'IT Support — ext. 1000', AppColors.navyMid),
              _contactCard('📞', 'خط مساعدة المدراء', '+966 11 XXX 5000', AppColors.teal),
              _contactCard('📧', 'البريد الإلكتروني', 'support@riyad.sa', AppColors.gold),
              _contactCard('💬', 'دردشة مباشرة', '8 ص — 5 م', AppColors.success),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'الأسئلة الشائعة للمدراء'),
          ..._faqs.map((faq) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.sm),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('❓ ${faq.$1}', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
              const SizedBox(height: 6),
              Text('↩ ${faq.$2}', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 12, color: AppColors.tx3, height: 1.6)),
            ])),
          ),
        ]),
      )),
    ]),
  );

  Widget _contactCard(String ico, String t, String s, Color c) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14), boxShadow: AppShadows.card),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 46, height: 46,
        decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
        child: Center(child: Text(ico, style: const TextStyle(fontSize: 22)))),
      const SizedBox(height: 6),
      Text(t, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700)),
      Text(s, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.tx3)),
    ]));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ABOUT SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Column(children: [
      AdminAppBar(title: 'حول التطبيق', onBack: () => context.pop()),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          AppCard(mb: 14, child: Column(children: [
            const Text('🏛', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text('بوابة إدارة المنظومة', style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navyMid),
              textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('مجموعة الرياض القابضة', style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 12, color: AppColors.tx3)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const StatusBadge(text: 'Admin Portal', type: 'navy'),
              const SizedBox(width: 8),
              const StatusBadge(text: 'v1.0.0 ✓',    type: 'approved'),
            ]),
          ])),
          AppCard(mb: 14, child: Column(children: [
            const InfoRow(label: 'الإصدار',           value: '1.0.0 (Build 100)'),
            const InfoRow(label: 'تاريخ الإصدار',     value: '1 مارس 2025'),
            const InfoRow(label: 'المنصة',             value: 'Android 8+'),
            const InfoRow(label: 'المطوّر',            value: 'مجموعة الرياض — التقنية'),
            const InfoRow(label: 'الخادم',              value: 'سحابي — منطقة الرياض', border: false),
          ])),
          ...['سياسة الخصوصية', 'شروط الاستخدام', 'ترخيص البرمجيات'].map((l) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.sm),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Icon(Icons.chevron_left, color: AppColors.g400, size: 20),
                Text(l, style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyMid)),
              ]))),
          const SizedBox(height: 16),
          Text('جميع الحقوق محفوظة © 2025 مجموعة الرياض', style: TextStyle(fontFamily: 'Cairo', 
            fontSize: 11, color: AppColors.g400), textAlign: TextAlign.center),
        ]),
      )),
    ]),
  );
}
