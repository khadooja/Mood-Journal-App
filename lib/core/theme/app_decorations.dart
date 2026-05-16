import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Shadow tiers — all tinted with [AppColors.primary] for warmth.
abstract final class AppShadows {
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get strong => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Premium card shadow — layered for depth.
  static List<BoxShadow> get premium => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Floating nav bar shadow.
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, -4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, -2),
        ),
      ];
}

/// Shared [BoxDecoration] factories.
abstract final class AppDecorations {
  /// Standard white card.
  static BoxDecoration card({
    List<BoxShadow>? shadows,
    double? radius,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
        boxShadow: shadows ?? AppShadows.medium,
      );

  /// Premium glass card — white + subtle border.
  static BoxDecoration glassCard({
    double radius = AppRadius.lg,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.cardGlass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: AppShadows.premium,
      );

  /// Gradient-backed card for the Daily Prompt / featured sections.
  static BoxDecoration gradientCard({
    required List<Color> colors,
    double radius = AppRadius.xl,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.premium,
      );

  /// Gradient button decoration.
  static BoxDecoration gradientButton({
    double radius = AppRadius.xl,
  }) =>
      BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Idle text-input container.
  static BoxDecoration input() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.soft,
      );

  /// Focused text-input container.
  static BoxDecoration inputFocused() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: AppShadows.soft,
      );

  /// Premium pill search field.
  static BoxDecoration searchField({bool focused = false}) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.fullAll,
        border: Border.all(
          color: focused ? AppColors.primary : AppColors.borderLight,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: AppShadows.medium,
      );

  /// Pill / badge background.
  static BoxDecoration pill({required Color color}) => BoxDecoration(
        color: color,
        borderRadius: AppRadius.fullAll,
      );
}
