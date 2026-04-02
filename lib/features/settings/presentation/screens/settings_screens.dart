import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/admin_providers.dart';
import 'package:go_router/go_router.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADMIN SETTINGS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final themeMode = ref.watch(themeModeProvider);
    final localeMode = ref.watch(localeModeProvider);

    return Scaffold(
      backgroundColor: c.bg,
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
              Divider(height: 0.5, color: c.gray200),
              _RadioOption<ThemeMode>(
                icon: Icons.light_mode_outlined,
                label: 'Light'.tr(context),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v)),
              Divider(height: 0.5, color: c.gray200),
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
              Divider(height: 0.5, color: c.gray200),
              _RadioOption<AppLocaleMode>(
                flag: 'AR',
                label: 'Arabic'.tr(context),
                value: AppLocaleMode.ar,
                groupValue: localeMode,
                onChanged: (v) => ref.read(localeModeProvider.notifier).setMode(v)),
              Divider(height: 0.5, color: c.gray200),
              _RadioOption<AppLocaleMode>(
                flag: 'EN',
                label: 'English',
                value: AppLocaleMode.en,
                groupValue: localeMode,
                onChanged: (v) => ref.read(localeModeProvider.notifier).setMode(v)),
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
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.navyMid),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontFamily: 'Cairo',
          fontSize: 15, fontWeight: FontWeight.w800, color: c.textPrimary)),
      ]));
  }
}

class _OptionCard extends StatelessWidget {
  final List<Widget> children;
  const _OptionCard({required this.children});
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm),
      child: Column(children: children),
    );
  }
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
    final c = context.appColors;
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
              border: Border.all(color: selected ? AppColors.navyMid : c.gray300, width: 2)),
            child: selected ? Center(child: Container(width: 12, height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.navyMid))) : null),
          const SizedBox(width: 12),
          // Label
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Cairo',
            fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.navyMid : c.textSecondary))),
          // Icon or flag
          if (icon != null) Icon(icon, size: 20, color: selected ? AppColors.navyMid : c.gray400),
          if (flag != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: selected ? AppColors.navyMid.withOpacity(0.12) : c.gray100,
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
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(color: c.gray100))),
        child: Row(children: [
          // START: الأيقونة
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: danger ? AppColors.errorSoft : AppColors.navySoft,
              borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
          const SizedBox(width: 12),
          // CENTER: النص
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, fontWeight: FontWeight.w600,
              color: danger ? AppColors.error : c.textPrimary)),
            if (desc != null) Text(desc!, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 11, color: c.textMuted)),
          ])),
          // END: سهم التنقل
          trailing ?? Icon(
            Icons.arrow_forward_ios,
            color: danger ? AppColors.error : c.gray400, size: 16),
        ]),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADMIN PROFILE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});
  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileState();
}

class _AdminProfileState extends ConsumerState<AdminProfileScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    ref.invalidate(adminProfileProvider);
    try { await ref.read(adminProfileProvider.future); } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final profileAsync = ref.watch(adminProfileProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: profileAsync.when(
        loading: () => CustomScrollView(slivers: [
          _buildSliverAppBar(context, null, null, '—', ''),
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
        ]),
        error: (e, _) => CustomScrollView(slivers: [
          _buildSliverAppBar(context, null, null, '—', ''),
          SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error loading data'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c.textSecondary)),
            const SizedBox(height: 16),
            PrimaryBtn(text: 'Retry'.tr(context), small: true, fullWidth: false,
              onTap: _refresh),
          ]))),
        ]),
        data: (employee) => _buildBody(context, ref, employee),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, String? name, String? role, String initials, String code) {
    return SliverAppBar(
      expandedHeight: 150,
      collapsedHeight: kToolbarHeight,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        child: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 4,
              left: 18, right: 18, bottom: 16),
            child: Row(children: [
              Container(width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.goldLight,
                  border: Border.all(color: Colors.white24, width: 2)),
                child: Center(child: Text(initials, style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)))),
              const SizedBox(width: 14),
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name ?? '...', style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (role != null)
                    Text(role, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.goldLight),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (code.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                      child: Text(code, style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70))),
                  ],
                ])),
            ]),
          ),
        ),
      ),
      title: Row(children: [
        if (context.canPop())
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18))),
        if (context.canPop()) const SizedBox(width: 12),
        Expanded(child: Text('Profile'.tr(context), style: TextStyle(fontFamily: 'Cairo',
          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
        GestureDetector(
          onTap: _refreshing ? null : _refresh,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: _refreshing
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.refresh, color: Colors.white, size: 18)))),
      ]),
      titleSpacing: 18,
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, EmployeeProfile employee) {
    final c = context.appColors;
    final na = 'Not specified'.tr(context);
    return CustomScrollView(slivers: [
      _buildSliverAppBar(context, employee.name, employee.jobTitle,
        employee.initials ?? '—', employee.code),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        sliver: SliverList(delegate: SliverChildListDelegate([

          // ── Permissions & Roles ──
          _AdminExpansionSection(
            icon: Icons.shield_outlined, iconColor: AppColors.teal,
            title: 'Permissions Roles'.tr(context),
            child: Wrap(spacing: 8, runSpacing: 8,
              children: ['HR Management', 'Approve Requests', 'Review Reports',
                'Employee Management', 'Announcements', 'Task Management',
              ].map((p) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.tealSoft, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3))),
                child: Text(p.tr(context), style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal))
              )).toList()),
          ),
          const SizedBox(height: 12),

          // ── Change Password ──
          const _AdminChangePasswordSection(),
          const SizedBox(height: 12),

          // ── Personal Info ──
          _ProfileSectionCard(title: 'Personal information'.tr(context), icon: Icons.person_outline_rounded, children: [
            _ProfileInfoTile(icon: Icons.email_outlined, label: 'Email'.tr(context), value: employee.email ?? na),
            _ProfileInfoTile(icon: Icons.phone_android_rounded, label: 'Phone'.tr(context),
              value: employee.mobile ?? employee.phone ?? na),
            if (employee.gender != null)
              _ProfileInfoTile(icon: Icons.wc_rounded, label: 'Gender'.tr(context),
                value: employee.gender == 'male' ? 'Male'.tr(context) : 'Female'.tr(context)),
            if (employee.dateOfBirth != null)
              _ProfileInfoTile(icon: Icons.cake_outlined, label: 'Date of birth'.tr(context), value: employee.dateOfBirth!),
            if (employee.nationality != null)
              _ProfileInfoTile(icon: Icons.flag_outlined, label: 'Nationality'.tr(context), value: employee.nationality!),
            if (employee.idNumber != null)
              _ProfileInfoTile(icon: Icons.badge_outlined, label: 'ID number'.tr(context), value: employee.idNumber!),
            if (employee.address != null)
              _ProfileInfoTile(icon: Icons.location_on_outlined, label: 'Address'.tr(context), value: employee.address!),
            if (employee.emergencyContactName != null)
              _ProfileInfoTile(icon: Icons.emergency_outlined, label: 'Emergency contact'.tr(context), value: employee.emergencyContactName!),
            if (employee.emergencyContactPhone != null)
              _ProfileInfoTile(icon: Icons.phone_outlined, label: 'Emergency phone'.tr(context), value: employee.emergencyContactPhone!),
          ]),
          const SizedBox(height: 12),

          // ── Work Info ──
          _ProfileSectionCard(title: 'Work information'.tr(context), icon: Icons.work_outline_rounded, children: [
            _ProfileInfoTile(icon: Icons.badge_rounded, label: 'Employee Number'.tr(context), value: employee.code),
            _ProfileInfoTile(icon: Icons.work_rounded, label: 'Job Title'.tr(context), value: employee.jobTitle ?? na),
            _ProfileInfoTile(icon: Icons.business_rounded, label: 'Department'.tr(context), value: employee.department?.name ?? na),
            if (employee.company?.name != null)
              _ProfileInfoTile(icon: Icons.apartment_rounded, label: 'Company'.tr(context), value: employee.company!.name!),
            _ProfileInfoTile(icon: Icons.shield_rounded, label: 'Access Level'.tr(context),
              value: employee.isManager ? 'Senior admin full access'.tr(context) : 'Standard'.tr(context)),
            if (employee.hireDate != null)
              _ProfileInfoTile(icon: Icons.calendar_today_outlined, label: 'Hire date'.tr(context), value: employee.hireDate!),
          ]),
          const SizedBox(height: 12),

          // ── Manager Info ──
          if (employee.manager != null) ...[
            _ProfileSectionCard(title: 'Direct manager'.tr(context), icon: Icons.supervisor_account_outlined, children: [
              _ProfileInfoTile(icon: Icons.person_rounded, label: 'Name'.tr(context), value: employee.manager!.name),
              _ProfileInfoTile(icon: Icons.work_rounded, label: 'Job Title'.tr(context), value: employee.manager!.jobTitle),
            ]),
            const SizedBox(height: 12),
          ],

          // ── Activity Stats ──
          _ProfileSectionCard(title: 'Activity Stats'.tr(context), icon: Icons.analytics_outlined, children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                _actStat('42', 'Approvals this month'.tr(context), AppColors.success, c),
                const SizedBox(width: 8),
                _actStat('8', 'Rejected this month'.tr(context), AppColors.error, c),
                const SizedBox(width: 8),
                _actStat('15', 'Assigned tasks'.tr(context), AppColors.navyMid, c),
              ])),
          ]),
        ]))),
    ]);
  }

  Widget _actStat(String v, String l, Color col, AppColorsExtension c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: col.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: col.withOpacity(0.2))),
    child: Column(children: [
      Text(v, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: col, height: 1.1)),
      Text(l, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: c.textMuted, height: 1.3), textAlign: TextAlign.center),
    ])));
}

// ═══════════════════════════════════════════════════════════════════
// Profile Section Card (like employee app)
// ═══════════════════════════════════════════════════════════════════

class _ProfileSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _ProfileSectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.navyMid.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: AppColors.navyMid)),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
          ])),
        const SizedBox(height: 8),
        const Divider(height: 1),
        ...children,
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Profile Info Tile (like employee app)
// ═══════════════════════════════════════════════════════════════════

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileInfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: c.textMuted),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: c.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
            fontWeight: FontWeight.w600, color: c.textPrimary)),
        ])),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Admin Expansion Section (for permissions, password)
// ═══════════════════════════════════════════════════════════════════

class _AdminExpansionSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  const _AdminExpansionSection({required this.icon, required this.iconColor, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor)),
          title: Text(title, style: TextStyle(fontFamily: 'Cairo',
            fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
          children: [child],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Change Password Section (ExpansionTile like employee app)
// ═══════════════════════════════════════════════════════════════════

class _AdminChangePasswordSection extends ConsumerStatefulWidget {
  const _AdminChangePasswordSection();
  @override ConsumerState<_AdminChangePasswordSection> createState() => _AdminChangePasswordState();
}

class _AdminChangePasswordState extends ConsumerState<_AdminChangePasswordSection> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
        currentPassword: _currentCtrl.text.trim(),
        password: _newCtrl.text.trim(),
        passwordConfirmation: _confirmCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password changed successfully'.tr(context), style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.success));
      ref.read(authProvider.notifier).logout();
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.warning)),
          title: Text('Change password'.tr(context), style: TextStyle(fontFamily: 'Cairo',
            fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
          children: [
            Form(key: _formKey, child: Column(children: [
              const SizedBox(height: 8),
              _AdminPasswordField(controller: _currentCtrl, label: 'Current password'.tr(context),
                obscure: _obscureCurrent, onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'This field is required'.tr(context) : null),
              const SizedBox(height: 12),
              _AdminPasswordField(controller: _newCtrl, label: 'New password'.tr(context),
                obscure: _obscureNew, onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'This field is required'.tr(context);
                  if (v.trim().length < 8) return 'Password must be at least 8 characters'.tr(context);
                  return null;
                }),
              const SizedBox(height: 12),
              _AdminPasswordField(controller: _confirmCtrl, label: 'Confirm password'.tr(context),
                obscure: _obscureConfirm, onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'This field is required'.tr(context);
                  if (v.trim() != _newCtrl.text.trim()) return 'Passwords do not match'.tr(context);
                  return null;
                }),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 44,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyMid, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Change password'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 14, fontWeight: FontWeight.w700)))),
            ])),
          ],
        ),
      ),
    );
  }
}

class _AdminPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  const _AdminPasswordField({required this.controller, required this.label,
    required this.obscure, required this.onToggle, this.validator});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return TextFormField(
      controller: controller, obscureText: obscure, validator: validator,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: c.textMuted),
        filled: true, fillColor: c.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.gray200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navyMid, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20, color: c.textMuted),
          onPressed: onToggle),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPPORT SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final faqs = [
      ('faq1_q'.tr(context), 'faq1_a'.tr(context)),
      ('faq2_q'.tr(context), 'faq2_a'.tr(context)),
      ('faq3_q'.tr(context), 'faq3_a'.tr(context)),
      ('faq4_q'.tr(context), 'faq4_a'.tr(context)),
      ('faq5_q'.tr(context), 'faq5_a'.tr(context)),
    ];

    return Scaffold(
      backgroundColor: c.bg,
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
              padding: EdgeInsets.zero,
              children: [
                _contactCard('💻', 'Technical Support'.tr(context), 'IT Support — ext. 1000', AppColors.navyMid, c),
                _contactCard('📞', 'Manager Helpline'.tr(context), '+966 11 XXX 5000', AppColors.teal, c),
                _contactCard('📧', 'Email'.tr(context), 'support@riyad.sa', AppColors.gold, c),
                _contactCard('💬', 'Live Chat'.tr(context), '8am 5pm'.tr(context), AppColors.success, c),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeader(title: 'Manager FAQs'.tr(context)),
            ...faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.bgCard, borderRadius: BorderRadius.circular(14),
                boxShadow: AppShadows.sm),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('❓ ${faq.$1}', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
                const SizedBox(height: 6),
                Text('↩ ${faq.$2}', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 12, color: c.textMuted, height: 1.6)),
              ])),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _contactCard(String ico, String t, String s, Color col, AppColorsExtension c) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: c.bgCard,
      borderRadius: BorderRadius.circular(14), boxShadow: AppShadows.card),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 46, height: 46,
        decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
        child: Center(child: Text(ico, style: const TextStyle(fontSize: 22)))),
      const SizedBox(height: 6),
      Text(t, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700)),
      Text(s, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c.textMuted)),
    ]));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ABOUT SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
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
                fontSize: 12, color: c.textMuted)),
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
                  color: c.bgCard, borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.sm),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Icon(Icons.chevron_left, color: c.gray400, size: 20),
                  Text(l.tr(context), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyMid)),
                ]))),
            const SizedBox(height: 16),
            Text('All rights reserved'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 11, color: c.gray400), textAlign: TextAlign.center),
          ]),
        )),
      ]),
    );
  }
}
