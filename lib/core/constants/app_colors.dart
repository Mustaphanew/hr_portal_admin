import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// Visual Identity — Navy + Royal Blue + Gold
// ───────────────────────────────────────────────────────────────────
// Premium Corporate / Governmental palette. Token names preserved for
// backward compatibility, but values now reflect the new identity:
//   • navyDeep / navy / navyMid / navyLight  →  Navy → Royal Blue
//   • gold*                                  →  Gold accent (D6A646)
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ── Primary (Navy → Royal Blue) ───────────────────────────
  static const Color navyDeep    = Color(0xFF071B33); // Navy Blue
  static const Color navy        = Color(0xFF0A2A5E); // Deep Gradient Blue
  static const Color navyMid     = Color(0xFF1F5FD6); // Royal Blue (Primary action)
  static const Color navyLight   = Color(0xFF3B82F6); // Royal lighter
  static const Color navyBright  = Color(0xFF60A5FA); // Royal brightest
  static const Color navySoft    = Color(0xFFE8EFFC); // Soft tint
  static const Color navyBorder  = Color(0xFFC2D5F5);
  static const Color navyGhost   = Color(0xFFF4F7FB);

  // ── Gold Accent ───────────────────────────────────────────
  static const Color gold      = Color(0xFFD6A646);
  static const Color goldLight = Color(0xFFE5BC6B);
  static const Color goldSoft  = Color(0xFFFBF1DD);
  static const Color goldDark  = Color(0xFFB58632);

  // ── Teal Accent (kept for compat) ─────────────────────────
  static const Color teal      = Color(0xFF0EA5A4);
  static const Color tealLight = Color(0xFF22D3CE);
  static const Color tealSoft  = Color(0xFFE6F8F8);

  // ── Indigo / Sky / Coral (additional palette tints) ──────
  static const Color indigo     = Color(0xFF6366F1);
  static const Color indigoSoft = Color(0xFFEEF0FF);
  static const Color sky        = Color(0xFF38BDF8);
  static const Color skySoft    = Color(0xFFE6F4FF);
  static const Color coral      = Color(0xFFF87171);
  static const Color coralSoft  = Color(0xFFFEEFEA);

  // ── Semantic ──────────────────────────────────────────────
  static const Color success     = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF065F46);

  static const Color warning     = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF6E0);
  static const Color warningDark = Color(0xFFB45309);

  static const Color error     = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEE4E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info     = Color(0xFF1F5FD6);
  static const Color infoSoft = Color(0xFFE8EFFC);
  static const Color infoDark = Color(0xFF0A2A5E);

  // ── Backgrounds ───────────────────────────────────────────
  static const Color bg        = Color(0xFFF4F7FB);
  static const Color bgCard    = Color(0xFFFFFFFF);
  static const Color bgSection = Color(0xFFEEF2F7);

  // ── Grays ────────────────────────────────────────────────
  static const Color g50  = Color(0xFFF8FAFC);
  static const Color g100 = Color(0xFFF1F5F9);
  static const Color g200 = Color(0xFFE2E8F0);
  static const Color g300 = Color(0xFFCBD5E1);
  static const Color g400 = Color(0xFF94A3B8);
  static const Color g500 = Color(0xFF64748B);
  static const Color g600 = Color(0xFF475569);
  static const Color g700 = Color(0xFF334155);
  static const Color g800 = Color(0xFF1E293B);
  static const Color g900 = Color(0xFF0F172A);

  // ── Text ─────────────────────────────────────────────────
  static const Color tx1 = Color(0xFF1E293B); // Text Dark
  static const Color tx2 = Color(0xFF334155);
  static const Color tx3 = Color(0xFF94A3B8); // Text Muted
  static const Color tx4 = Color(0xFFCBD5E1);

  // ── Gradients ────────────────────────────────────────────
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [navyMid, navy, navyDeep],
    stops: [0, 0.55, 1],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [navyDeep, navy, navyMid],
    stops: [0, 0.55, 1],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [goldLight, gold],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [tealLight, teal],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF065F46)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFF87171), Color(0xFF991B1B)],
  );

  // ── Convenience: resolve theme-aware colors from context ──
  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>()!;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Theme-aware colors
// ═══════════════════════════════════════════════════════════════════

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color bg;
  final Color bgCard;
  final Color bgSection;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color inputFill;
  final Color inputBorder;
  final Color divider;
  final Color cardBorder;
  final Color gray50;
  final Color gray100;
  final Color gray200;
  final Color gray300;
  final Color gray400;

  const AppColorsExtension({
    required this.bg,
    required this.bgCard,
    required this.bgSection,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.inputFill,
    required this.inputBorder,
    required this.divider,
    required this.cardBorder,
    required this.gray50,
    required this.gray100,
    required this.gray200,
    required this.gray300,
    required this.gray400,
  });

  // ── Light ──
  static const light = AppColorsExtension(
    bg: Color(0xFFF4F7FB),
    bgCard: Color(0xFFFFFFFF),
    bgSection: Color(0xFFEEF2F7),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF334155),
    textMuted: Color(0xFF94A3B8),
    textDisabled: Color(0xFFCBD5E1),
    inputFill: Color(0xFFF8FAFC),
    inputBorder: Color(0xFFE2E8F0),
    divider: Color(0xFFEEF2F6),
    cardBorder: Colors.transparent,
    gray50: Color(0xFFF8FAFC),
    gray100: Color(0xFFF1F5F9),
    gray200: Color(0xFFE2E8F0),
    gray300: Color(0xFFCBD5E1),
    gray400: Color(0xFF94A3B8),
  );

  // ── Dark ──
  static const dark = AppColorsExtension(
    bg: Color(0xFF050E1F),
    bgCard: Color(0xFF0F1B33),
    bgSection: Color(0xFF0A1428),
    textPrimary: Color(0xFFE8ECF4),
    textSecondary: Color(0xFFB0B8C8),
    textMuted: Color(0xFF7B8AA1),
    textDisabled: Color(0xFF55617A),
    inputFill: Color(0xFF13203B),
    inputBorder: Color(0xFF233356),
    divider: Color(0xFF1B274A),
    cardBorder: Color(0xFF233356),
    gray50: Color(0xFF0F1B33),
    gray100: Color(0xFF13203B),
    gray200: Color(0xFF233356),
    gray300: Color(0xFF3D4B6E),
    gray400: Color(0xFF5A6A8A),
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? bg, Color? bgCard, Color? bgSection,
    Color? textPrimary, Color? textSecondary, Color? textMuted, Color? textDisabled,
    Color? inputFill, Color? inputBorder, Color? divider, Color? cardBorder,
    Color? gray50, Color? gray100, Color? gray200, Color? gray300, Color? gray400,
  }) {
    return AppColorsExtension(
      bg: bg ?? this.bg,
      bgCard: bgCard ?? this.bgCard,
      bgSection: bgSection ?? this.bgSection,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      divider: divider ?? this.divider,
      cardBorder: cardBorder ?? this.cardBorder,
      gray50: gray50 ?? this.gray50,
      gray100: gray100 ?? this.gray100,
      gray200: gray200 ?? this.gray200,
      gray300: gray300 ?? this.gray300,
      gray400: gray400 ?? this.gray400,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      bg: Color.lerp(bg, other.bg, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgSection: Color.lerp(bgSection, other.bgSection, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      gray50: Color.lerp(gray50, other.gray50, t)!,
      gray100: Color.lerp(gray100, other.gray100, t)!,
      gray200: Color.lerp(gray200, other.gray200, t)!,
      gray300: Color.lerp(gray300, other.gray300, t)!,
      gray400: Color.lerp(gray400, other.gray400, t)!,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Extension on BuildContext for quick access
// ═══════════════════════════════════════════════════════════════════

extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
