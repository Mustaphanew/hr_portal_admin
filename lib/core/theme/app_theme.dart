import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Cairo';

  static final ThemeData light = _buildLightTheme();
  static final ThemeData dark = _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    const c = AppColorsExtension.light;
    final textTheme = _textTheme(c);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [AppColorsExtension.light],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyMid,
        primary: AppColors.navyMid,
        secondary: AppColors.gold,
        tertiary: AppColors.teal,
        surface: c.bgCard,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: c.bg,
      textTheme: textTheme,
      fontFamily: _fontFamily,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColors.navyMid, elevation: 0, centerTitle: true,
        titleTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(color: c.bgCard, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      inputDecorationTheme: _inputDeco(c, AppColors.navyMid),
      elevatedButtonTheme: _elevatedBtn(),
      outlinedButtonTheme: _outlinedBtn(),
      textButtonTheme: _textBtn(),
      bottomNavigationBarTheme: _bottomNav(c, AppColors.navyMid),
      navigationBarTheme: NavigationBarThemeData(elevation: 0, height: 72, backgroundColor: c.bgCard,
        indicatorColor: AppColors.navySoft, indicatorShape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd)),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 0),
      dialogTheme: DialogThemeData(backgroundColor: c.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary)),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      popupMenuTheme: PopupMenuThemeData(color: c.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 3),
    );
  }

  static ThemeData _buildDarkTheme() {
    const c = AppColorsExtension.dark;
    final textTheme = _textTheme(c);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [AppColorsExtension.dark],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyMid, brightness: Brightness.dark,
        primary: AppColors.navyLight, secondary: AppColors.gold,
        tertiary: AppColors.tealLight, surface: c.bgCard, error: AppColors.error,
      ),
      scaffoldBackgroundColor: c.bg,
      textTheme: textTheme,
      fontFamily: _fontFamily,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColors.navyMid, elevation: 0, centerTitle: true,
        titleTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(color: c.bgCard, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: c.cardBorder))),
      inputDecorationTheme: _inputDeco(c, AppColors.navyLight),
      elevatedButtonTheme: _elevatedBtn(),
      outlinedButtonTheme: _outlinedBtn(borderColor: c.inputBorder),
      textButtonTheme: _textBtn(),
      bottomNavigationBarTheme: _bottomNav(c, AppColors.goldLight),
      navigationBarTheme: NavigationBarThemeData(elevation: 0, height: 72, backgroundColor: c.bgCard,
        indicatorColor: AppColors.navyMid.withValues(alpha: 0.3),
        indicatorShape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd)),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 0),
      dialogTheme: DialogThemeData(backgroundColor: c.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary)),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      popupMenuTheme: PopupMenuThemeData(color: c.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 3),
    );
  }

  // ── Shared helpers ──

  static TextTheme _textTheme(AppColorsExtension c) => TextTheme(
    displayLarge  : TextStyle(fontFamily: _fontFamily, fontSize: 32, fontWeight: FontWeight.w900, color: c.textPrimary, height: 1.3),
    displayMedium : TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w800, color: c.textPrimary, height: 1.3),
    displaySmall  : TextStyle(fontFamily: _fontFamily, fontSize: 24, fontWeight: FontWeight.w800, color: c.textPrimary, height: 1.3),
    headlineLarge : TextStyle(fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w800, color: c.textPrimary, height: 1.4),
    headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.4),
    headlineSmall : TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.4),
    titleLarge    : TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.5),
    titleMedium   : TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary, height: 1.5),
    titleSmall    : TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: c.textSecondary, height: 1.5),
    bodyLarge     : TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w400, color: c.textPrimary, height: 1.6),
    bodyMedium    : TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: c.textSecondary, height: 1.6),
    bodySmall     : TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w400, color: c.textMuted, height: 1.6),
    labelLarge    : TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.4),
    labelMedium   : TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: c.textMuted, height: 1.4),
    labelSmall    : TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w500, color: c.textDisabled, height: 1.4),
  );

  static InputDecorationTheme _inputDeco(AppColorsExtension c, Color focusColor) => InputDecorationTheme(
    filled: true, fillColor: c.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.inputBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.inputBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: focusColor, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
    hintStyle: TextStyle(fontFamily: _fontFamily, color: c.gray400, fontSize: 14),
    labelStyle: TextStyle(fontFamily: _fontFamily, color: c.textMuted, fontSize: 14),
  );

  static ElevatedButtonThemeData _elevatedBtn() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.navyMid, foregroundColor: Colors.white, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );

  static OutlinedButtonThemeData _outlinedBtn({Color? borderColor}) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: borderColor != null ? BorderSide(color: borderColor) : null,
      textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  static TextButtonThemeData _textBtn() => TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  static BottomNavigationBarThemeData _bottomNav(AppColorsExtension c, Color selectedColor) => BottomNavigationBarThemeData(
    backgroundColor: c.bgCard, selectedItemColor: selectedColor, unselectedItemColor: c.gray400,
    showSelectedLabels: true, showUnselectedLabels: true, type: BottomNavigationBarType.fixed,
    selectedLabelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w700),
    unselectedLabelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w400),
  );
}
