import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralised typography scale (Inter, 8-pt baseline).
/// Override colour at call-site with `.copyWith(color: ...)`.
abstract final class AppTextStyles {
  // ── Display ───────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, height: 1.1,
      );

  // ── Headlines ────────────────────────────────────────────
  static TextStyle get headline => GoogleFonts.inter(
        fontSize: 26, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, height: 1.2,
      );

  static TextStyle get title => GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, height: 1.2,
      );

  // ── Section labels ───────────────────────────────────────
  static TextStyle get sectionLabel => GoogleFonts.inter(
        fontSize: 17, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.3,
      );

  // ── Body ─────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.6,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.5,
      );

  // ── Captions ─────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary, height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary, height: 1.3,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary, height: 1.3,
      );
}
