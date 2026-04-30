// update 2026-04-30
import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
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
  // ── runZonedGuarded captures uncaught async errors and forwards them
  //    to Crashlytics — required for production crash visibility.
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ar', null);

    // ── System UI (mobile only) ──
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    }

    // ── Firebase ──
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ── Crashlytics ──────────────────────────────────────────────────
    // Disabled in debug to avoid polluting the dashboard during dev.
    // Captures Flutter framework errors AND platform errors automatically.
    if (!kIsWeb && !kDebugMode) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
    await _continueMain();
  }, (error, stack) {
    if (!kIsWeb && !kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}

Future<void> _continueMain() async {

  // ── Notifications ──
  await AwesomeNotificationService.init();
  final fcmService = NotificationFCMService();
  await fcmService.initFCM();

  // ── Connect navigator key for notification tap navigation ──
  AdminNavigator.navigatorKey = rootNavigatorKey;

  // ── Config (prod: [base_url] from Firebase Remote Config) ──
  final appConfig = AppConfig.fromEnvironment();
  appConfigInstance = appConfig;
  await appConfig.loadRemoteConfig();
  AppLogger.init(appConfig);
  ApiConstants.configure(appConfig);
  // ignore: avoid_print
  print(
    '[AppConfig] root: ${appConfig.baseUrl} | example: ${ApiConstants.baseUrl}${ApiConstants.login} (${appConfig.envName})',
  );
  developer.log(
    'root: ${appConfig.baseUrl} | example: ${ApiConstants.baseUrl}${ApiConstants.login} (${appConfig.envName})',
    name: 'AppConfig',
  );

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
