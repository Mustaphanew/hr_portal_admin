import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/constants/api_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

class AdminPortalApp extends ConsumerStatefulWidget {
  const AdminPortalApp({super.key});

  @override
  ConsumerState<AdminPortalApp> createState() => _AdminPortalAppState();
}

class _AdminPortalAppState extends ConsumerState<AdminPortalApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final materialLocale = ref.watch(materialLocaleProvider);
    final resolvedLocale = ref.watch(resolvedLocaleProvider);

    final isRtl = resolvedLocale.languageCode == 'ar';

    return MaterialApp.router(
      title: isRtl ? 'الادمن موظفين نيوهورايزون' : 'Admin Employees NH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: materialLocale,
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: _DevEnvOverlay(child: child!),
      ),
      routerConfig: appRouter,
    );
  }
}

/// Floating banner shown only in non-prod flavors so the running base URL is
/// always visible during testing. Tap to copy the URL to the system clipboard.
class _DevEnvOverlay extends StatelessWidget {
  final Widget child;
  const _DevEnvOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    final cfg = appConfigInstance;
    if (cfg == null || !cfg.showEnvBanner) return child;
    return Stack(
      textDirection: Directionality.of(context),
      children: [
        child,
        Positioned(
          right: 0,
          left: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${cfg.envName} • ${ApiConstants.baseUrl}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
