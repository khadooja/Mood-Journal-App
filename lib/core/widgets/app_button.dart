import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum _AppButtonVariant { primary, secondary, ghost }

/// Reusable button with press-scale micro-animation.
///
/// ```dart
/// // Primary — filled, full-width
/// AppButton.primary(label: 'Save Entry', onPressed: _save)
///
/// // Secondary — outlined
/// AppButton.secondary(label: 'Analyze with AI ✨', onPressed: _analyze)
///
/// // Ghost — text only
/// AppButton.ghost(label: 'Cancel', onPressed: () => pop())
/// ```
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final bool isLoading;
  final _AppButtonVariant _variant;

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.ghost;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!_enabled) return;
    _ctrl.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final double height = widget.height ??
        (widget._variant == _AppButtonVariant.primary
            ? AppSpacing.hLg
            : AppSpacing.h);

    switch (widget._variant) {
      case _AppButtonVariant.primary:
        return _PrimaryBody(
          label: widget.label,
          icon: widget.leadingIcon,
          height: height,
          isLoading: widget.isLoading,
          enabled: _enabled,
          bgColor: widget.backgroundColor ?? AppColors.primary,
          fgColor: widget.foregroundColor ?? AppColors.surface,
        );
      case _AppButtonVariant.secondary:
        return _SecondaryBody(
          label: widget.label,
          icon: widget.leadingIcon,
          height: height,
          isLoading: widget.isLoading,
          enabled: _enabled,
          fgColor: widget.foregroundColor ?? AppColors.primary,
        );
      case _AppButtonVariant.ghost:
        return _GhostBody(
          label: widget.label,
          icon: widget.leadingIcon,
          enabled: _enabled,
          fgColor: widget.foregroundColor ?? AppColors.textSecondary,
        );
    }
  }
}

// ── Private body widgets ────────────────────────────────────────────────────

class _PrimaryBody extends StatelessWidget {
  final String label;
  final Widget? icon;
  final double height;
  final bool isLoading;
  final bool enabled;
  final Color bgColor;
  final Color fgColor;

  const _PrimaryBody({
    required this.label,
    required this.height,
    required this.isLoading,
    required this.enabled,
    required this.bgColor,
    required this.fgColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: enabled ? bgColor : AppColors.borderLight,
        borderRadius: AppRadius.mdAll,
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? fgColor : AppColors.textHint,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SecondaryBody extends StatelessWidget {
  final String label;
  final Widget? icon;
  final double height;
  final bool isLoading;
  final bool enabled;
  final Color fgColor;

  const _SecondaryBody({
    required this.label,
    required this.height,
    required this.isLoading,
    required this.enabled,
    required this.fgColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: enabled ? fgColor : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? fgColor : AppColors.textHint,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GhostBody extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool enabled;
  final Color fgColor;

  const _GhostBody({
    required this.label,
    required this.enabled,
    required this.fgColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w500,
            color: enabled ? fgColor : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
