import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
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
        AdminAppBar(title: 'Settings'.tr(context), onBack: () => context.pop()),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          children: [

            // ── Theme Section ──────────────────────────────────
            _SectionHeader(icon: Icons.palette_outlined, title: 'Appearance'.tr(context)),
            _OptionCard(children: [
              _RadioOption<ThemeMode>(
                icon: Icons.settings_suggest_outlined,
                label: 'Auto system'.tr(context),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v)),
              const Divider(height: 0.5, color: AppColors.g200),
              _RadioOption<ThemeMode>(
                icon: Icons.light_mode_outlined,
                label: 'Light'.tr(context),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v)),
              const Divider(height: 0.5, color: AppColors.g200),
              _RadioOption<ThemeMode>(
                icon: Icons.dark_mode_outlined,
                label: 'Dark'.tr(context),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v)),
            ]),
            const SizedBox(height: 20),

            // ── Language Section ────────────────────────────────
            _SectionHeader(icon: Icons.language, title: 'Language'.tr(context)),
            _OptionCard(children: [
              _RadioOption<AppLocaleMode>(
                icon: Icons.settings_suggest_outlined,
                label: 'Auto device'.tr(context),
                value: AppLocaleMode.system,
                groupValue: localeMode,
                onChanged: (v) => ref.read(localeModeProvider.notifier).setMode(v)),
              const Divider(height: 0.5, color: AppColors.g200),
              _RadioOption<AppLocaleMode>(
                flag: 'AR',
                label: 'Arabic'.tr(context),
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
            _SectionHeader(icon: Icons.person_outline, title: 'Account'.tr(context)),
            _OptionCard(children: [
              _SettingsTile(icon: '👤', label: 'Profile'.tr(context),
                desc: 'View edit profile'.tr(context),
                onTap: () => context.push('/admin-profile')),
              _SettingsTile(icon: '🔒', label: 'Change Password'.tr(context),
                onTap: () {}),
              _SettingsTile(icon: '🛡', label: 'Permissions Roles'.tr(context),
                desc: 'Full system admin'.tr(context), isLast: true, onTap: () {}),
            ]),
            const SizedBox(height: 20),

            // ── System Section ─────────────────────────────────
            _SectionHeader(icon: Icons.info_outline, title: 'System section'.tr(context)),
            _OptionCard(children: [
              _SettingsTile(icon: '❓', label: 'Help Center'.tr(context),
                onTap: () => context.push('/support')),
              _SettingsTile(icon: 'ℹ️', label: 'About App'.tr(context),
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
                      title: Text('Logout'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
                      content: Text('Are you sure?'.tr(context), style: TextStyle(fontFamily: 'Cairo')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancel'.tr(context), style: TextStyle(fontFamily: 'Cairo', color: AppColors.tx3))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Sign out'.tr(context), style: TextStyle(fontFamily: 'Cairo', color: Colors.white))),
                      ]));
                  if (confirm == true && context.mounted) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                label: Text('Logout'.tr(context), style: TextStyle(fontFamily: 'Cairo',
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
    final adminName = employee?.name ?? 'Admin'.tr(context);
    final adminRole = employee?.jobTitle ?? 'System Manager'.tr(context);
    final adminInitials = employee?.initials ?? '—';
    final adminCode = employee?.code ?? '';
    final adminEmail = employee?.email ?? 'Not specified'.tr(context);
    final adminPhone = employee?.mobile ?? employee?.phone ?? 'Not specified'.tr(context);
    final adminDept = employee?.department?.name ?? 'Not specified'.tr(context);
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
              Text('Permissions Roles'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8,
                children: [
                  'HR Management',
                  'Approve Requests',
                  'Review Reports',
                  'Employee Management',
                  'Announcements',
                  'Task Management',
                ].map((p) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.tealSoft, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.teal.withOpacity(0.3))),
                  child: Text(p.tr(context), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal))
                )).toList()),
            ])),
            // Account info
            AppCard(mb: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Account Info'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              InfoRow(label: 'Employee Number'.tr(context),   value: adminCode,    icon: '🔖'),
              InfoRow(label: 'Job Title'.tr(context),          value: adminRole,   icon: '💼'),
              InfoRow(label: 'Department'.tr(context),         value: adminDept,   icon: '🏢'),
              InfoRow(label: 'Email'.tr(context),              value: adminEmail,  icon: '✉️'),
              InfoRow(label: 'Phone'.tr(context),              value: adminPhone,  icon: '📱'),
              InfoRow(label: 'Access Level'.tr(context),       value: 'Senior admin full access'.tr(context), icon: '🛡', border: false),
            ])),
            // Activity stats
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Activity Stats'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(children: [
                _actStat('42', 'Approvals this month'.tr(context), AppColors.success),
                const SizedBox(width: 8),
                _actStat('8',  'Rejected this month'.tr(context), AppColors.error),
                const SizedBox(width: 8),
                _actStat('15', 'Assigned tasks'.tr(context), AppColors.navyMid),
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

  @override
  Widget build(BuildContext context) {
    final faqs = [
      ('faq1_q'.tr(context), 'faq1_a'.tr(context)),
      ('faq2_q'.tr(context), 'faq2_a'.tr(context)),
      ('faq3_q'.tr(context), 'faq3_a'.tr(context)),
      ('faq4_q'.tr(context), 'faq4_a'.tr(context)),
      ('faq5_q'.tr(context), 'faq5_a'.tr(context)),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        AdminAppBar(title: 'Help Support Center'.tr(context), onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Contact channels
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6,
              children: [
                _contactCard('💻', 'Technical Support'.tr(context), 'IT Support — ext. 1000', AppColors.navyMid),
                _contactCard('📞', 'Manager Helpline'.tr(context), '+966 11 XXX 5000', AppColors.teal),
                _contactCard('📧', 'Email'.tr(context), 'support@riyad.sa', AppColors.gold),
                _contactCard('💬', 'Live Chat'.tr(context), '8am 5pm'.tr(context), AppColors.success),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeader(title: 'Manager FAQs'.tr(context)),
            ...faqs.map((faq) => Container(
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
  }

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
      AdminAppBar(title: 'About App'.tr(context), onBack: () => context.pop()),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          AppCard(mb: 14, child: Column(children: [
            const Text('🏛', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text('Portal title'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navyMid),
              textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Riyadh Group Holding'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 12, color: AppColors.tx3)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const StatusBadge(text: 'Admin Portal', type: 'navy'),
              const SizedBox(width: 8),
              const StatusBadge(text: 'v1.0.0 ✓',    type: 'approved'),
            ]),
          ])),
          AppCard(mb: 14, child: Column(children: [
            InfoRow(label: 'Version'.tr(context),        value: '1.0.0 (Build 100)'),
            InfoRow(label: 'Release Date'.tr(context),   value: 'March 2025'.tr(context)),
            InfoRow(label: 'Platform'.tr(context),       value: 'Android 8+'),
            InfoRow(label: 'Developer'.tr(context),      value: 'Riyadh Group Tech'.tr(context)),
            InfoRow(label: 'Server'.tr(context),         value: 'Cloud Riyadh'.tr(context), border: false),
          ])),
          ...['Privacy Policy', 'Terms of Use', 'Software License'].map((l) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.sm),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Icon(Icons.chevron_left, color: AppColors.g400, size: 20),
                Text(l.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyMid)),
              ]))),
          const SizedBox(height: 16),
          Text('All rights reserved'.tr(context), style: TextStyle(fontFamily: 'Cairo',
            fontSize: 11, color: AppColors.g400), textAlign: TextAlign.center),
        ]),
      )),
    ]),
  );
}
