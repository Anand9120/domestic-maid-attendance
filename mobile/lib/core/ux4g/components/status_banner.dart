import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/typography.dart';

enum Ux4gBannerVariant {
  warningLight,
  warningSolid,
  errorLight,
  successLight,
  savingLight,
  infoLight,
  neutralLight,
  primaryLight,
}

class Ux4gStatusBanner extends StatelessWidget {
  final Ux4gBannerVariant variant;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Widget? badge;
  final List<Widget>? actions;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final Color? borderColor;
  final WrapAlignment actionsAlignment;
  final double? width;
  final double? height;

  /// Outer margin around the banner. Defaults to
  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` to preserve
  /// existing layouts. Set to [EdgeInsets.zero] when the banner sits
  /// inside a parent that already provides its own padding.
  final EdgeInsetsGeometry margin;

  /// Inner padding inside the banner card.
  final EdgeInsetsGeometry padding;

  const Ux4gStatusBanner({
    super.key,
    required this.variant,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.titleStyle,
    this.subtitleStyle,
    this.badge,
    this.leadingIcon,
    this.trailingIcon,
    this.actions,
    this.onDismiss,
    this.backgroundColor,
    this.borderColor,
    this.actionsAlignment = WrapAlignment.start,
    this.width,
    this.height,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final surface = ux4gColors?.surface ?? materialTheme.colorScheme.surface;
    final warning = ux4gColors?.warning ?? materialTheme.colorScheme.tertiary;
    final onWarning =
        ux4gColors?.onWarning ?? materialTheme.colorScheme.onTertiary;
    final error = ux4gColors?.error ?? materialTheme.colorScheme.error;
    final success = ux4gColors?.success ?? materialTheme.colorScheme.primary;
    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final info = ux4gColors?.info ?? materialTheme.colorScheme.secondary;
    final onBackground =
        ux4gColors?.onBackground ?? materialTheme.colorScheme.onSurface;

    final bMStrong =
        ux4gTypography?.bM_strong ??
        materialTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle();
    final bMDefault =
        ux4gTypography?.bM_default ??
        materialTheme.textTheme.bodyMedium ??
        const TextStyle();

    // Determine colors based on variant
    Color resolvedBackgroundColor;
    Color resolvedBorderColor;
    Color textColor = onSurface;
    Color subtitleColor = onSurface.withValues(alpha: 0.6);

    switch (variant) {
      case Ux4gBannerVariant.warningLight:
        resolvedBackgroundColor = Color.lerp(surface, warning, 0.12)!;
        resolvedBorderColor = warning.withValues(alpha: 0.3);
        break;
      case Ux4gBannerVariant.warningSolid:
        resolvedBackgroundColor = warning;
        resolvedBorderColor = warning;
        textColor = onWarning;
        subtitleColor = onWarning.withValues(alpha: 0.7);
        break;
      case Ux4gBannerVariant.errorLight:
        resolvedBackgroundColor = Color.lerp(surface, error, 0.12)!;
        resolvedBorderColor = error.withValues(alpha: 0.3);
        break;
      case Ux4gBannerVariant.successLight:
        resolvedBackgroundColor = Color.lerp(surface, success, 0.12)!;
        resolvedBorderColor = success.withValues(alpha: 0.3);
        break;
      case Ux4gBannerVariant.savingLight:
      case Ux4gBannerVariant.primaryLight:
        resolvedBackgroundColor = Color.lerp(surface, primary, 0.12)!;
        resolvedBorderColor = primary.withValues(alpha: 0.3);
        break;
      case Ux4gBannerVariant.infoLight:
        resolvedBackgroundColor = Color.lerp(surface, info, 0.12)!;
        resolvedBorderColor = info.withValues(alpha: 0.3);
        break;
      case Ux4gBannerVariant.neutralLight:
        resolvedBackgroundColor = onSurface.withValues(alpha: 0.05);
        resolvedBorderColor = onSurface.withValues(alpha: 0.15);
        break;
    }

    // Apply overrides
    resolvedBackgroundColor = backgroundColor ?? resolvedBackgroundColor;
    resolvedBorderColor = borderColor ?? resolvedBorderColor;

    return Container(
      width: width ?? double.infinity,
      height: height,
      constraints: BoxConstraints(minHeight: height ?? 48),
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resolvedBorderColor),
        boxShadow: [
          BoxShadow(
            color: onBackground.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: (subtitle != null || subtitleWidget != null)
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        Text(
                          title,
                          style: (titleStyle ?? bMStrong).copyWith(
                            color: titleStyle?.color ?? textColor,
                          ),
                        ),
                        if (badge != null) badge!,
                      ],
                    ),
                    if (subtitleWidget != null) ...[
                      const SizedBox(height: 4),
                      subtitleWidget!,
                    ] else if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: (subtitleStyle ?? bMDefault).copyWith(
                          color: subtitleStyle?.color ?? subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 16),
                trailingIcon!,
              ],
            ],
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: actionsAlignment,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}

/// A service to show top snackbars (banners) overlaying the screen.
class Ux4gBannerManager {
  static OverlayEntry? _currentEntry;
  static AnimationController? _animationController;

  static void show(
    BuildContext context, {
    required Ux4gBannerVariant variant,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    Widget? badge,
    Widget? leadingIcon,
    Widget? trailingIcon,
    List<Widget>? actions,
    Duration duration = const Duration(seconds: 4),
    bool autoDismiss = true,
  }) {
    // Dismiss existing
    hide();

    final overlay = Overlay.of(context);

    // Setup animation controller manually using a TickerProvider from the context if possible,
    // but since this is static, we'll use an implicit animation widget like AnimatedPositioned or TweenAnimationBuilder.

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: -100.0, end: 0.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: (1 - (value / -100)).clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Ux4gStatusBanner(
                variant: variant,
                title: title,
                subtitle: subtitle,
                subtitleWidget: subtitleWidget,
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                badge: badge,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
                actions: actions,
                onDismiss: hide,
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    if (autoDismiss) {
      Future.delayed(duration, () {
        if (_currentEntry == entry) {
          hide();
        }
      });
    }
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
