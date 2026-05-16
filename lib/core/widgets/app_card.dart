import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';

/// Standard card shell: white background, warm shadow, rounded corners.
/// Wraps [child] in an [InkWell] ripple when [onTap] is provided.
///
/// ```dart
/// AppCard(
///   onTap: () => ...,
///   child: Text('Hello'),
/// )
/// ```
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final List<BoxShadow>? shadows;
  final double? borderRadius;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.shadows,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? AppRadius.md);

    return Container(
      decoration: AppDecorations.card(
        shadows: shadows ?? AppShadows.medium,
        radius: borderRadius ?? AppRadius.md,
        color: color,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.primary.withValues(alpha: 0.06),
            highlightColor: AppColors.primary.withValues(alpha: 0.04),
            child: Padding(
              padding: padding ?? AppSpacing.cardPadding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
