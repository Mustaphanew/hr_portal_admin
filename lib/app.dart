import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      title: 'لوحة إدارة مجموعة الرياض',
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
        child: child!,
      ),
      routerConfig: appRouter,
    );
  }
}
