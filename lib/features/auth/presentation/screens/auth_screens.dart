import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../providers/auth_providers.dart';

// ── Splash ────────────────────────────────────────────────
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override ConsumerState<SplashScreen> createState() => _SplashState();
}
class _SplashState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
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
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    if (_blockStartup) {
      _ctrl.forward();
      return;
    }
    _ctrl.forward();
    _checkSession();
  }

  Future<void> _retryRemoteConfig() async {
    final c = appConfigInstance;
    if (c == null) return;
    setState(() => _retryingConfig = true);
    try {
      await c.loadRemoteConfig();
      ApiConstants.configure(c);
      // ignore: avoid_print
      print(
        '[AppConfig] root: ${c.baseUrl} | example: ${ApiConstants.baseUrl}${ApiConstants.login} (${c.envName})',
      );
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
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.checkSession();
    if (!mounted) return;
    final isAuth = ref.read(authProvider).isAuthenticated;
    if (isAuth) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.navyLight, AppColors.navyDeep, Color(0xFF020C1A)], stops: [0,0.5,1])),
      child: Stack(children: [
        Positioned(top: -80, right: -60, child: Container(width: 250, height: 250,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
        Positioned(bottom: -60, left: -40, child: Container(width: 200, height: 200,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.gold.withOpacity(0.08)))),
        Positioned(top: 0, left: 0, right: 0, child: Container(height: 2,
          decoration: const BoxDecoration(gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.goldLight, Colors.transparent])))),
        Center(child: FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 96, height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 20))]),
              child: const Center(child: Text('🏛', style: TextStyle(fontSize: 46)))),
            const SizedBox(height: 24),
            Text('لوحة إدارة المنظومة', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 11, color: AppColors.goldLight, letterSpacing: 6, fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            Text('مجموعة الرياض', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
            const SizedBox(height: 4),
            Text('ADMIN MANAGEMENT PORTAL', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 11, color: Colors.white30, letterSpacing: 2)),
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
                ),
                child: _retryingConfig
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ])))),
        if (!_blockStartup)
          Positioned(bottom: 52, left: 0, right: 0, child: Center(
            child: SizedBox(width: 30, height: 30,
              child: CircularProgressIndicator(color: AppColors.gold.withOpacity(0.7), strokeWidth: 2)))),
        Positioned(bottom: 26, left: 0, right: 0, child: Center(
          child: Text('الإصدار 1.0.0', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white24, letterSpacing: 2)))),
      ]),
    ),
  );
}

// ── Login ─────────────────────────────────────────────────
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginState();
}
class _LoginState extends ConsumerState<LoginScreen> {
  bool _showPw = false, _loading = false, _remember = true;
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _pwCtrl   = TextEditingController();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _userCtrl.text.trim();
    final password = _pwCtrl.text.trim();

    setState(() => _loading = true);
    try {
      String? fcmToken;
      try { fcmToken = await FirebaseMessaging.instance.getToken(); } catch (_) {}

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.toString().contains('401')
              ? 'Invalid credentials'.tr(context)
              : 'Connection failed'.tr(context),
            style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SingleChildScrollView(child: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 44, left: 22, right: 22),
          child: Column(children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: GestureDetector(
                onTap: () => context.push('/guest-settings'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white10,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.settings_outlined, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text('Settings'.tr(context), style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
            Container(width: 72, height: 72,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                color: Colors.white12, border: Border.all(color: AppColors.gold.withOpacity(0.5))),
              child: const Center(child: Text('🏛', style: TextStyle(fontSize: 36)))),
            const SizedBox(height: 14),
            Text('Login Title'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Login Subtitle'.tr(context), style: TextStyle(fontFamily: 'Cairo',
              fontSize: 13, color: AppColors.goldLight)),
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(99)),
              child: Text('Admin access only'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 11, color: Colors.white70))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Admin email'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary), textAlign: TextAlign.right),
              const SizedBox(height: 6),
              TextFormField(
                controller: _userCtrl,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: fieldDec(context, 'Admin email'.tr(context)),
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
              const SizedBox(height: 14),
              Text('Enter password'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary), textAlign: TextAlign.right),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pwCtrl,
                obscureText: !_showPw,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: fieldDec(context, 'Enter password'.tr(context)).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility,
                      color: c.gray400, size: 20),
                    onPressed: () => setState(() => _showPw = !_showPw))),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'This field is required'.tr(context);
                  }
                  if (v.trim().length < 6) {
                    return 'Password must be at least 6 characters'.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text('Forgot password?'.tr(context), style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 12, color: AppColors.navyLight, fontWeight: FontWeight.w600))),
                Row(children: [
                  Text('Remember me'.tr(context), style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: c.textMuted)),
                  const SizedBox(width: 6),
                  Transform.scale(scale: 0.9, child: Checkbox(
                    value: _remember, activeColor: AppColors.navyMid,
                    onChanged: (v) => setState(() => _remember = v ?? true))),
                ]),
              ]),
              const SizedBox(height: 20),
              PrimaryBtn(text: 'Secure Login'.tr(context), onTap: _login, loading: _loading, icon: '🔐'),
              const SizedBox(height: 28),
              Center(child: Text('Portal for management only'.tr(context),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: c.gray400), textAlign: TextAlign.center)),
            ]),
          ),
        ),
      ])),
    );
  }
}

// ── OTP ───────────────────────────────────────────────────
class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});
  @override State<OTPScreen> createState() => _OTPState();
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
        AdminAppBar(title: 'التحقق الثنائي', subtitle: 'إجراء أمني إلزامي',
          onBack: () => context.pop()),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(children: [
            const SizedBox(height: 20),
            Container(width: 80, height: 80, decoration: BoxDecoration(
              color: AppColors.navySoft, shape: BoxShape.circle),
              child: const Center(child: Text('📱', style: TextStyle(fontSize: 36)))),
            const SizedBox(height: 16),
            Text('رمز التحقق', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            RichText(text: TextSpan(children: [
              TextSpan(text: 'تم إرسال رمز التحقق إلى ', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: c.textMuted)),
              TextSpan(text: '+966 50 *** 2200', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyMid)),
            ])),
            const SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => Container(
                width: 52, height: 60, margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(maxLength: 1, textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navyMid),
                  decoration: InputDecoration(counterText: '', filled: true, fillColor: AppColors.navySoft,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.navyBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.navyBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.navyMid, width: 2)))))),
            ),
            const SizedBox(height: 24),
            _timer > 0
              ? Text('إعادة الإرسال بعد ${_timer}s', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: c.textMuted))
              : TextButton(onPressed: () => setState(() { _timer = 60; _startTimer(); }),
                  child: Text('إعادة إرسال الرمز', style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyMid, decoration: TextDecoration.underline))),
            const SizedBox(height: 30),
            PrimaryBtn(text: 'تأكيد الدخول',
              onTap: () => context.go('/home')),
          ]),
        )),
      ]),
    );
  }
}
