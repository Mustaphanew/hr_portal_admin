import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(color: AppColors.navyDeep.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(color: AppColors.navyDeep.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
    BoxShadow(color: AppColors.navyMid.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(color: AppColors.navyDeep.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
    BoxShadow(color: AppColors.navy.withOpacity(0.10), blurRadius: 48, offset: const Offset(0, 20)),
  ];

  static List<BoxShadow> get navy => [
    BoxShadow(color: AppColors.navyMid.withOpacity(0.28), blurRadius: 22, offset: const Offset(0, 10)),
    BoxShadow(color: AppColors.navy.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get gold => [
    BoxShadow(color: AppColors.gold.withOpacity(0.32), blurRadius: 16, offset: const Offset(0, 6)),
  ];

  static List<BoxShadow> get teal => [
    BoxShadow(color: AppColors.teal.withOpacity(0.24), blurRadius: 14, offset: const Offset(0, 4)),
  ];

  /// Soft inner-glow style shadow used around focused inputs.
  static List<BoxShadow> get focusGlow => [
    BoxShadow(color: AppColors.navyMid.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 4)),
  ];
}
