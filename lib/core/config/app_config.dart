import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

enum AppFlavor { dev, staging, prod }

/// Set in [main] after construction and [loadRemoteConfig] as needed.
AppConfig? appConfigInstance;

class AppConfig {
  static const String devBaseUrl = 'http://172.16.0.66:8000';
  static const String prodFallbackBaseUrl = 'https://account.alzajeltravel.com';
  final AppFlavor flavor;
  final String envName;
  final bool enableDebugLogs;
  final bool showEnvBanner;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;

  /// For [AppFlavor.prod], [loadRemoteConfig] replaces this with Remote Config
  /// when available; otherwise it stays on the production fallback URL.
  String baseUrl;

  AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.envName,
    required this.enableDebugLogs,
    required this.showEnvBanner,
    this.connectTimeoutMs = 15000,
    this.receiveTimeoutMs = 15000,
  });

  factory AppConfig.fromEnvironment() {
    const flavorStr = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    switch (flavorStr) {
      case 'prod':
        return AppConfig(
          flavor: AppFlavor.prod,
          baseUrl: prodFallbackBaseUrl,
          envName: 'Production',
          enableDebugLogs: false,
          showEnvBanner: false,
          connectTimeoutMs: 15000,
          receiveTimeoutMs: 15000,
        );
      case 'staging':
        return AppConfig(
          flavor: AppFlavor.staging,
          baseUrl: prodFallbackBaseUrl,
          envName: 'Staging',
          enableDebugLogs: true,
          showEnvBanner: true,
          connectTimeoutMs: 20000,
          receiveTimeoutMs: 20000,
        );
      case 'dev':
      default:
        /// افتراضي: خادم API على هذا الجهاز (المحاكي Android ← `localhost` الجهاز = `10.0.2.2`).
        /// لتجربة staging/الاستضافة: `flutter run --dart-define=API_BASE_URL=https://account.alzajeltravel.com`
        /// لتشغّل الويب على نفس الجهاز: `--dart-define=API_BASE_URL=http://localhost:8000`
        const devRoot = String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://10.0.2.2:8000',
        );
        const devFallback = 'http://10.0.2.2:8000';
        return AppConfig(
          flavor: AppFlavor.dev,
          baseUrl: devBaseUrl,
          envName: 'Development',
          enableDebugLogs: true,
          showEnvBanner: true,
          connectTimeoutMs: 30000,
          receiveTimeoutMs: 30000,
        );
    }
  }

  /// [AppFlavor.prod]: fetch [base_url] from Firebase Remote Config (project-level).
  /// Other flavors: no-op (fixed [baseUrl] from [fromEnvironment]).
  Future<void> loadRemoteConfig() async {
    if (flavor != AppFlavor.prod) return;

    final remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      // Matches Console default; also used if fetch fails before activate.
      await remoteConfig.setDefaults({_remoteKeyBaseUrl: prodFallbackBaseUrl});
      try {
        await remoteConfig.fetchAndActivate();
      } catch (_) {
        // Still read in-app / last activated values via getString.
      }
      final raw = remoteConfig.getString(_remoteKeyBaseUrl);
      baseUrl = _normalizeRootBaseUrl(raw, fallback: prodFallbackBaseUrl);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppConfig] loadRemoteConfig error: $e');
      }
      try {
        final raw = FirebaseRemoteConfig.instance.getString(_remoteKeyBaseUrl);
        baseUrl = _normalizeRootBaseUrl(raw, fallback: prodFallbackBaseUrl);
      } catch (_) {
        baseUrl = prodFallbackBaseUrl;
      }
    }
  }

  static const String _remoteKeyBaseUrl = 'base_url';

  /// جذر الخادم فقط (بدون `/api/v1`). مسارات [ApiConstants] تتضمّن `/api/v1/...`.
  static String _normalizeRootBaseUrl(String raw, {required String fallback}) {
    var s = raw.trim();
    if (s.isEmpty) return fallback;
    s = s.replaceAll(RegExp(r'/+$'), '');
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'https://$s';
    }
    if (s.endsWith('/api/v1')) {
      s = s.substring(0, s.length - '/api/v1'.length);
      s = s.replaceAll(RegExp(r'/+$'), '');
    }
    return s.isEmpty ? fallback : s;
  }

  bool get isProduction => flavor == AppFlavor.prod;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isDev => flavor == AppFlavor.dev;

  /// Whether API calls may proceed (prod must have a non-empty [baseUrl] from Remote Config).
  bool get hasValidBaseUrl => baseUrl.trim().isNotEmpty;

  @override
  String toString() => 'AppConfig($envName, $baseUrl)';
}
