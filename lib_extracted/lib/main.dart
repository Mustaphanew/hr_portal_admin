import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const AdminPortalApp());
}

class AdminPortalApp extends StatelessWidget {
  const AdminPortalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'لوحة إدارة مجموعة الرياض',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    locale: const Locale('ar', 'SA'),
    supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => Directionality(
      textDirection: TextDirection.rtl, child: child!),
    routerConfig: appRouter,
  );
}
