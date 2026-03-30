import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyMid,
        primary: AppColors.navyMid,
        secondary: AppColors.gold,
        tertiary: AppColors.teal,
        background: AppColors.bg,
        surface: AppColors.bgCard,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Cairo',
      textTheme: const TextTheme(
        displayLarge  : TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.tx1),
        displayMedium : TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.tx1),
        headlineLarge : TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.tx1),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.tx1),
        titleLarge    : TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.tx1),
        titleMedium   : TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tx2),
        bodyLarge     : TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.tx1, height: 1.6),
        bodyMedium    : TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.tx2, height: 1.6),
        bodySmall     : TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.tx3, height: 1.6),
        labelLarge    : TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tx1),
        labelSmall    : TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.tx4),
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColors.navyMid,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(fontFamily: 'Cairo', 
          fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: AppColors.g50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.g200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.g200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navyMid, width: 1.5)),
        hintStyle: TextStyle(fontFamily: 'Cairo', color: AppColors.g400, fontSize: 13),
      ),
    );
  }
}
