import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/app_logger.dart';
import 'core/constants/api_constants.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/awesome_notification_service.dart';
import 'core/services/notification_fcm/notification_fcm_service.dart';
import 'core/theme/theme_mode_provider.dart';
import 'firebase_options.dart';
import 'injection.dart';

// ── Background message handler (must be top-level) ──
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AwesomeNotificationService.initForBackground();

  final d = message.data;
  final titleEn = (d['title_en'] ?? d['title'] ?? 'Notification').toString();
  final bodyEn = (d['body_en'] ?? d['body'] ?? '').toString();
  final titleAr = (d['title_ar'] ?? titleEn).toString();
  final bodyAr = (d['body_ar'] ?? bodyEn).toString();

  if (titleEn.isNotEmpty || bodyEn.isNotEmpty) {
    await AwesomeNotificationService.showLocalizedNotification(
      titleAr: titleAr,
      bodyAr: bodyAr,
      titleEn: titleEn,
      bodyEn: bodyEn,
      imageUrl: d['image']?.toString(),
      payload: d.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── System UI (mobile only) ──
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  // ── Firebase ──
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ── Notifications ──
  await AwesomeNotificationService.init();
  final fcmService = NotificationFCMService();
  await fcmService.initFCM();

  // ── Connect navigator key for notification tap navigation ──
  AdminNavigator.navigatorKey = rootNavigatorKey;

  // ── Config ──
  final appConfig = AppConfig.fromEnvironment();
  AppLogger.init(appConfig);
  ApiConstants.configure(appConfig);

  // ── DI ──
  await initDependencies();

  // ── Load persisted preferences ──
  final savedLocaleMode = await loadStartupLocaleMode();
  final savedThemeMode = await loadStartupThemeMode();

  // ── Run ──
  runApp(
    ProviderScope(
      overrides: [
        initialLocaleModeProvider.overrideWithValue(savedLocaleMode),
        initialThemeModeProvider.overrideWithValue(savedThemeMode),
      ],
      child: const AdminPortalApp(),
    ),
  );

  // ── Handle notification tap that launched the app ──
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await AwesomeNotificationService.handleInitialActionIfAny();
    await fcmService.handleInitialMessageAfterAppReady();
  });
}
