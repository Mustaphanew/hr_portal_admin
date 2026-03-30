import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';
import 'package:go_router/go_router.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADMIN SETTINGS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});
  @override State<AdminSettingsScreen> createState() => _AdminSettingsState();
}
class _AdminSettingsState extends State<AdminSettingsScreen> {
  bool _bio = true;
  bool _notif = true;
  bool _dark = false;
  bool _emailAlerts = true;

  @override
  Widget build(BuildContext context) {
    final admin = AdminData.currentAdmin;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 26, left: 18, right: 18),
          child: Column(children: [
            AdminAvatar(initials: admin.initials, size: 72, fontSize: 26),
            const SizedBox(height: 12),
            Text(admin.name, style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(admin.role, style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 12, color: AppColors.goldLight)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              StatusBadge(text: admin.id, type: 'navy'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tealSoft.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColors.tealLight.withOpacity(0.4))),
                child: Text('🔐 صلاحيات كاملة', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tealLight))),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(children: [

            // ── Account ──────────────────────────────────────
            _group('الحساب والملف الشخصي', [
              _SettingsTile(icon: '👤', label: 'الملف الشخصي للمدير',
                desc: 'عرض وتعديل بياناتك',
                onTap: () => context.push('/admin-profile')),
              _SettingsTile(icon: '🔒', label: 'تغيير كلمة المرور',
                onTap: () {}),
              _SettingsTile(icon: '🛡', label: 'الصلاحيات والأدوار',
                desc: 'إدارة كاملة للنظام', isLast: true, onTap: () {}),
            ]),
            const SizedBox(height: 12),

            // ── Notifications ─────────────────────────────────
            _group('الإشعارات والتنبيهات', [
              _SettingsTile(icon: '🔔', label: 'الإشعارات الفورية',
                trailing: AppToggle(value: _notif, onChanged: (v) => setState(() => _notif = v))),
              _SettingsTile(icon: '📧', label: 'تنبيهات البريد الإلكتروني',
                trailing: AppToggle(value: _emailAlerts, onChanged: (v) => setState(() => _emailAlerts = v))),
              _SettingsTile(icon: '🔐', label: 'الدخول بالبصمة',
                trailing: AppToggle(value: _bio, onChanged: (v) => setState(() => _bio = v)), isLast: true),
            ]),
            const SizedBox(height: 12),

            // ── App settings ──────────────────────────────────
            _group('إعدادات التطبيق', [
              _SettingsTile(icon: '🌍', label: 'اللغة', desc: 'العربية (RTL)'),
              _SettingsTile(icon: '🌙', label: 'الوضع الداكن', desc: 'قريباً',
                trailing: AppToggle(value: _dark, onChanged: (v) => setState(() => _dark = v))),
              _SettingsTile(icon: '📊', label: 'عدد العناصر لكل صفحة', desc: '20 عنصراً', isLast: true),
            ]),
            const SizedBox(height: 12),

            // ── System ────────────────────────────────────────
            _group('النظام والمساعدة', [
              _SettingsTile(icon: '❓', label: 'مركز المساعدة',
                onTap: () => context.push('/support')),
              _SettingsTile(icon: '📞', label: 'الدعم التقني',
                desc: 'ext. 5000 · دعم مباشر', onTap: () {}),
              _SettingsTile(icon: 'ℹ️', label: 'حول التطبيق',
                onTap: () => context.push('/about'), isLast: true),
            ]),
            const SizedBox(height: 12),

            // ── Danger zone ───────────────────────────────────
            _group('', [
              _SettingsTile(icon: '🚪', label: 'تسجيل الخروج الآمن',
                danger: true, isLast: true,
                onTap: () => context.go('/login')),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _group(String title, List<Widget> tiles) => AppCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.end, children: [
      if (title.isNotEmpty) ...[
        Text(title, style: TextStyle(fontFamily: 'Cairo', 
          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tx3, letterSpacing: 0.5)),
        const SizedBox(height: 8),
      ],
      ...tiles,
    ]));
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

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final admin = AdminData.currentAdmin;
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
                AdminAvatar(initials: admin.initials, size: 70, fontSize: 24),
                const SizedBox(height: 10),
                Text(admin.name, style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(admin.role, style: TextStyle(fontFamily: 'Cairo', 
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
              InfoRow(label: 'رقم الموظف',           value: admin.id,    icon: '🔖'),
              InfoRow(label: 'الدور الوظيفي',        value: admin.role,  icon: '💼'),
              InfoRow(label: 'البريد الإلكتروني',    value: admin.email, icon: '✉️'),
              InfoRow(label: 'الهاتف',                value: admin.phone, icon: '📱'),
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
