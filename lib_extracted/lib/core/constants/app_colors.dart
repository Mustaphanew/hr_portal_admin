import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Navy ─────────────────────────────────────────
  static const Color navyDeep    = Color(0xFF071526);
  static const Color navy        = Color(0xFF0D2142);
  static const Color navyMid     = Color(0xFF163870);
  static const Color navyLight   = Color(0xFF1E4D9A);
  static const Color navyBright  = Color(0xFF2563EB);
  static const Color navySoft    = Color(0xFFE8F0FB);
  static const Color navyBorder  = Color(0xFFBDD0F0);
  static const Color navyGhost   = Color(0xFFF2F6FD);

  // ── Gold Accent ───────────────────────────────────────────
  static const Color gold      = Color(0xFFC69228);
  static const Color goldLight = Color(0xFFE3AC35);
  static const Color goldSoft  = Color(0xFFFAF3E0);
  static const Color goldDark  = Color(0xFF9A6F18);

  // ── Teal Accent ───────────────────────────────────────────
  static const Color teal      = Color(0xFF0B7A65);
  static const Color tealLight = Color(0xFF18A88C);
  static const Color tealSoft  = Color(0xFFE2F4F1);

  // ── Backgrounds ───────────────────────────────────────────
  static const Color bg        = Color(0xFFEFF2F9);
  static const Color bgCard    = Color(0xFFFFFFFF);
  static const Color bgSection = Color(0xFFF6F8FD);

  // ── Grays ─────────────────────────────────────────────────
  static const Color g50  = Color(0xFFF9FAFB);
  static const Color g100 = Color(0xFFF3F4F6);
  static const Color g200 = Color(0xFFE5E7EB);
  static const Color g300 = Color(0xFFD1D5DB);
  static const Color g400 = Color(0xFF9CA3AF);
  static const Color g500 = Color(0xFF6B7280);
  static const Color g600 = Color(0xFF4B5563);
  static const Color g700 = Color(0xFF374151);
  static const Color g800 = Color(0xFF1F2937);
  static const Color g900 = Color(0xFF111827);

  // ── Semantic ──────────────────────────────────────────────
  static const Color success     = Color(0xFF059669);
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  static const Color warning     = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error     = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info     = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);

  // ── Text ──────────────────────────────────────────────────
  static const Color tx1 = Color(0xFF111827);
  static const Color tx2 = Color(0xFF374151);
  static const Color tx3 = Color(0xFF6B7280);
  static const Color tx4 = Color(0xFF9CA3AF);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyLight, navyDeep],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyBright, navyDeep],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealLight, teal],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF065F46)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
  );
}
