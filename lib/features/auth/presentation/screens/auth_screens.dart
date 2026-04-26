import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../providers/auth_providers.dart';

// ════════════════════════════════════════════════════════════════════
// Splash Screen
// ════════════════════════════════════════════════════════════════════
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashState();
}

class _SplashState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;
  bool _retryingConfig = false;

  bool get _blockStartup {
    final c = appConfigInstance;
    return c != null && c.isProduction && !c.hasValidBaseUrl;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    if (!_blockStartup) _checkSession();
  }

  Future<void> _retryRemoteConfig() async {
    final c = appConfigInstance;
    if (c == null) return;
    setState(() => _retryingConfig = true);
    try {
      await c.loadRemoteConfig();
      ApiConstants.configure(c);
      // ignore: avoid_print
      print('[AppConfig] root: ${c.baseUrl} | example: ${ApiConstants.baseUrl}${ApiConstants.login} (${c.envName})');
      developer.log(
        'root: ${c.baseUrl} | example: ${ApiConstants.baseUrl}${ApiConstants.login} (${c.envName})',
        name: 'AppConfig',
      );
      if (!mounted) return;
      if (!c.hasValidBaseUrl) {
        setState(() {});
        return;
      }
      setState(() {});
      _ctrl.forward(from: 0);
      _checkSession();
    } finally {
      if (mounted) setState(() => _retryingConfig = false);
    }
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.checkSession();
    if (!mounted) return;
    final isAuth = ref.read(authProvider).isAuthenticated;
    context.go(isAuth ? '/home' : '/login');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(children: [
            // Subtle geometric pattern overlay
            const Positioned.fill(
              child: IgnorePointer(child: _GeometricPattern(opacity: 0.06)),
            ),
            // Soft ambient glows
            Positioned(
              top: -80,
              right: -60,
              child: _glowCircle(260, AppColors.navyLight.withOpacity(0.18)),
            ),
            Positioned(
              bottom: -80,
              left: -50,
              child: _glowCircle(220, AppColors.gold.withOpacity(0.10)),
            ),
            // Top thin gold accent line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    AppColors.goldLight,
                    Colors.transparent,
                  ]),
                ),
              ),
            ),

            // Center content
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _CrestLogo(size: 110),
                      const SizedBox(height: 28),
                      const Text(
                        'بوابة إدارة المنظومة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppColors.gold.withOpacity(0.45)),
                        ),
                        child: const Text(
                          'مجموعة الراشد القابضة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldLight,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'AL-RASHED HOLDING GROUP',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.45),
                          letterSpacing: 3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_blockStartup) ...[
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'تعذر جلب عنوان الخادم. تحقق من الاتصال ثم أعد المحاولة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _retryingConfig ? null : _retryRemoteConfig,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navyDeep,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: _retryingConfig
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            if (!_blockStartup)
              Positioned(
                bottom: 64,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.gold.withOpacity(0.85),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'الإصدار 1.0.0',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.35),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ]),
        ),
      );

  static Widget _glowCircle(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c),
      );
}

// ════════════════════════════════════════════════════════════════════
// Login Screen — Premium Corporate Governmental UI
// ════════════════════════════════════════════════════════════════════
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  bool _showPw = false, _loading = false, _remember = true;
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _userFocus = FocusNode();
  final _pwFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _userFocus.addListener(() => setState(() {}));
    _pwFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _pwCtrl.dispose();
    _userFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _userCtrl.text.trim();
    final password = _pwCtrl.text.trim();

    setState(() => _loading = true);
    try {
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {}
      await ref.read(authProvider.notifier).login(
            username: username,
            password: password,
            deviceName: 'admin_portal',
            fcmToken: fcmToken,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('401')
                  ? 'Invalid credentials'.tr(context)
                  : 'Connection failed'.tr(context),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    // Hero height that scales nicely on different devices.
    final heroH = math.max(280.0, math.min(size.height * 0.42, 360.0));

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: Column(
              children: [
                _LoginHero(height: heroH, topPad: topPad),
                Transform.translate(
                  offset: const Offset(0, -42),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _LoginCard(
                        formKey: _formKey,
                        userCtrl: _userCtrl,
                        pwCtrl: _pwCtrl,
                        userFocus: _userFocus,
                        pwFocus: _pwFocus,
                        showPw: _showPw,
                        remember: _remember,
                        loading: _loading,
                        onTogglePw: () => setState(() => _showPw = !_showPw),
                        onToggleRemember: (v) => setState(() => _remember = v),
                        onSubmit: _login,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 22),
                  child: Text(
                    'هذه البوابة مخصصة للإدارة العليا ومسؤولي الموارد البشرية فقط',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      height: 1.6,
                      color: c.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Login Hero
// ════════════════════════════════════════════════════════════════════
class _LoginHero extends StatelessWidget {
  final double height;
  final double topPad;
  const _LoginHero({required this.height, required this.topPad});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(children: [
          // Soft geometric pattern
          const Positioned.fill(
            child: IgnorePointer(child: _GeometricPattern(opacity: 0.07)),
          ),
          // Ambient glows
          Positioned(
            top: -70,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyLight.withOpacity(0.20),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withOpacity(0.10),
              ),
            ),
          ),
          // Top gold thin accent line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AppColors.goldLight,
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Settings chip (top start in RTL → top-left visually)
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: topPad + 12,
            end: 16,
            child: _SettingsChip(),
          ),
          // Centered crest + titles
          Padding(
            padding: EdgeInsets.fromLTRB(22, topPad + 10, 22, 26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const _CrestLogo(size: 84),
                const SizedBox(height: 16),
                const Text(
                  'بوابة إدارة المنظومة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'مجموعة الراشد القابضة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldLight.withOpacity(0.95),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.goldLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'بوابة دخول آمن لإدارة الموظفين',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Login Card (form)
// ════════════════════════════════════════════════════════════════════
class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl, pwCtrl;
  final FocusNode userFocus, pwFocus;
  final bool showPw, remember, loading;
  final VoidCallback onTogglePw;
  final ValueChanged<bool> onToggleRemember;
  final VoidCallback onSubmit;
  const _LoginCard({
    required this.formKey,
    required this.userCtrl,
    required this.pwCtrl,
    required this.userFocus,
    required this.pwFocus,
    required this.showPw,
    required this.remember,
    required this.loading,
    required this.onTogglePw,
    required this.onToggleRemember,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.inputBorder.withOpacity(0.6)),
        boxShadow: AppShadows.elevated,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.navySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.navyMid, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تسجيل الدخول الآمن',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الرجاء إدخال بيانات الاعتماد للمتابعة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.5,
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            _FieldLabel(text: 'Admin email'.tr(context)),
            const SizedBox(height: 8),
            TextFormField(
              controller: userCtrl,
              focusNode: userFocus,
              enabled: !loading,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.5, color: c.textPrimary),
              decoration: _decor(
                context,
                hint: 'admin@alrashed.com',
                icon: Icons.alternate_email_rounded,
                focused: userFocus.hasFocus,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'This field is required'.tr(context);
                }
                if (v.trim().length < 3) {
                  return 'Username must be at least 3 characters'.tr(context);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _FieldLabel(text: 'Enter password'.tr(context)),
            const SizedBox(height: 8),
            TextFormField(
              controller: pwCtrl,
              focusNode: pwFocus,
              enabled: !loading,
              obscureText: !showPw,
              autofillHints: const [AutofillHints.password],
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.5, color: c.textPrimary),
              decoration: _decor(
                context,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                focused: pwFocus.hasFocus,
                suffix: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: c.textMuted,
                    size: 20,
                  ),
                  onPressed: loading ? null : onTogglePw,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'This field is required'.tr(context);
                }
                if (v.trim().length < 6) {
                  return 'Password must be at least 6 characters'.tr(context);
                }
                return null;
              },
              onFieldSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: loading ? null : () => onToggleRemember(!remember),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: remember ? AppColors.navyMid : Colors.transparent,
                            border: Border.all(
                              color: remember ? AppColors.navyMid : c.inputBorder,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: remember
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember me'.tr(context),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.5,
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: loading ? null : () => context.push('/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.navyMid,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  child: Text(
                    'Forgot password?'.tr(context),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.5,
                      color: AppColors.navyMid,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _PrimaryGradientButton(
              loading: loading,
              onTap: onSubmit,
              label: 'Secure Login'.tr(context),
            ),

            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: Divider(color: c.divider, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'اتصال مشفّر · TLS 1.3',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5,
                    color: c.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(child: Divider(color: c.divider, thickness: 1)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Helper widgets
// ────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: c.textSecondary,
      ),
    );
  }
}

InputDecoration _decor(
  BuildContext context, {
  required String hint,
  required IconData icon,
  required bool focused,
  Widget? suffix,
}) {
  final c = context.appColors;
  Color border() => focused ? AppColors.navyMid : c.inputBorder;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: 'Cairo',
      color: c.textMuted,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: focused ? Colors.white : c.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    prefixIcon: Padding(
      padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
      child: Icon(icon, color: focused ? AppColors.navyMid : AppColors.gold, size: 20),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    suffixIcon: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: border()),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c.inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.navyMid, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 1.6),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c.inputBorder.withOpacity(0.5)),
    ),
    errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11, height: 1.2),
  );
}

class _PrimaryGradientButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _PrimaryGradientButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  @override
  State<_PrimaryGradientButton> createState() => _PrimaryGradientButtonState();
}

class _PrimaryGradientButtonState extends State<_PrimaryGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.loading;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navyMid, AppColors.navy, AppColors.navyDeep],
            stops: [0, 0.55, 1],
          ),
          boxShadow: _pressed || disabled
              ? [
                  BoxShadow(
                    color: AppColors.navyDeep.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppShadows.navy,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle inner gold sheen on top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    AppColors.goldLight.withOpacity(0.55),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            if (widget.loading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColors.gold.withOpacity(0.55)),
                    ),
                    child: const Icon(Icons.lock_rounded, color: AppColors.goldLight, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: () => context.push('/guest-settings'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.settings_outlined, color: Colors.white.withOpacity(0.85), size: 15),
            const SizedBox(width: 6),
            Text(
              'Settings'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.5,
                color: Colors.white.withOpacity(0.92),
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Crest Logo — institutional shield with monogram + gold accents
// ════════════════════════════════════════════════════════════════════
class _CrestLogo extends StatelessWidget {
  final double size;
  const _CrestLogo({required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.16),
            Colors.white.withOpacity(0.06),
          ],
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.55), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDeep.withOpacity(0.45),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.gold.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner shield outline
          Container(
            width: size * 0.66,
            height: size * 0.66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.18),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
          ),
          // Monogram letters (Arabic + Latin) stacked
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الراشد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: size * 0.20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              SizedBox(height: size * 0.04),
              Container(
                width: size * 0.30,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: size * 0.04),
              Text(
                'AR',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: size * 0.13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldLight,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Subtle geometric line pattern (used inside hero / splash)
// ════════════════════════════════════════════════════════════════════
class _GeometricPattern extends StatelessWidget {
  final double opacity;
  const _GeometricPattern({required this.opacity});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GeometricPainter(opacity: opacity),
    );
  }
}

class _GeometricPainter extends CustomPainter {
  final double opacity;
  _GeometricPainter({required this.opacity});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Diagonal hairlines
    const step = 36.0;
    for (double x = -size.height; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
    }
    // Two soft rings as accents
    final p2 = Paint()
      ..color = AppColors.goldLight.withOpacity(opacity * 1.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.18), 60, p2);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.78), 90, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════
// OTP Screen (light tweaks)
// ════════════════════════════════════════════════════════════════════
class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});
  @override
  State<OTPScreen> createState() => _OTPState();
}

class _OTPState extends State<OTPScreen> {
  int _timer = 60;
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    while (_timer > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _timer--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        AdminAppBar(
          title: 'التحقق الثنائي',
          subtitle: 'إجراء أمني إلزامي',
          onBack: () => context.pop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(children: [
              const SizedBox(height: 20),
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppColors.navySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android_rounded, color: AppColors.navyMid, size: 38),
              ),
              const SizedBox(height: 16),
              Text(
                'رمز التحقق',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'تم إرسال رمز التحقق إلى ',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: c.textMuted),
                  ),
                  const TextSpan(
                    text: '+966 50 *** 2200',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyMid,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Container(
                    width: 52,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyMid,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.navySoft,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.navyBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.navyBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.navyMid, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _timer > 0
                  ? Text(
                      'إعادة الإرسال بعد ${_timer}s',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: c.textMuted),
                    )
                  : TextButton(
                      onPressed: () => setState(() {
                        _timer = 60;
                        _startTimer();
                      }),
                      child: const Text(
                        'إعادة إرسال الرمز',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyMid,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
              const SizedBox(height: 30),
              PrimaryBtn(text: 'تأكيد الدخول', onTap: () => context.go('/home')),
            ]),
          ),
        ),
      ]),
    );
  }
}
