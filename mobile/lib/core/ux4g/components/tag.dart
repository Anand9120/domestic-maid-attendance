import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/typography.dart';
import '../foundation/dimensions.dart';

enum Ux4gTagSize { m, l }

enum Ux4gTagShape { circular, rectangular }

enum Ux4gTagStyle { tonal, filled, outline, text }

enum Ux4gTagColor { neutral, brand, success, warning, error, info }

class Ux4gTag extends StatelessWidget {
  final String text;
  final Ux4gTagSize size;
  final Ux4gTagShape shape;
  final Ux4gTagStyle style;
  final Ux4gTagColor colorScheme;
  final Widget? leadingContent;
  final VoidCallback? onDismiss;
  final Color? customBackgroundColor;
  final Color? customContentColor;
  final Color? customBorderColor;
  final BorderRadius? customBorderRadius;

  const Ux4gTag({
    super.key,
    required this.text,
    this.size = Ux4gTagSize.m,
    this.shape = Ux4gTagShape.circular,
    this.style = Ux4gTagStyle.tonal,
    this.colorScheme = Ux4gTagColor.neutral,
    this.leadingContent,
    this.onDismiss,
    this.customBackgroundColor,
    this.customContentColor,
    this.customBorderColor,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final defaultColors = _getTagColors(ux4gColors, materialTheme.colorScheme);
    final bgColor = customBackgroundColor ?? defaultColors.backgroundColor;
    final contentColor = customContentColor ?? defaultColors.contentColor;
    final borderColor = customBorderColor ?? defaultColors.borderColor;

    final height = size == Ux4gTagSize.m ? 20.0 : 24.0;
    final horizontalPadding = size == Ux4gTagSize.m ? 8.0 : 12.0;

    final lSDefault =
        ux4gTypography?.lS_default ??
        materialTheme.textTheme.labelSmall ??
        const TextStyle();
    final lMDefault =
        ux4gTypography?.lM_default ??
        materialTheme.textTheme.labelMedium ??
        const TextStyle();

    final textStyle = size == Ux4gTagSize.m ? lSDefault : lMDefault;

    final borderRadius =
        customBorderRadius ??
        (shape == Ux4gTagShape.circular
            ? BorderRadius.circular(999)
            : BorderRadius.circular(Ux4gRadius.radius4));

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        border: style == Ux4gTagStyle.outline
            ? Border.all(color: borderColor)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingContent != null) ...[
            leadingContent!,
            const SizedBox(width: 6),
          ],
          Text(text, style: textStyle.copyWith(color: contentColor, height: 1)),
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: size == Ux4gTagSize.m ? 12 : 14,
                color: contentColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _TagColors _getTagColors(Ux4gThemeColors? ux4gColors, ColorScheme colorScheme) {
    final onSurface = ux4gColors?.onSurface ?? colorScheme.onSurface;
    final primary = ux4gColors?.primary ?? colorScheme.primary;
    final success = ux4gColors?.success ?? colorScheme.primary;
    final warning = ux4gColors?.warning ?? colorScheme.tertiary;
    final error = ux4gColors?.error ?? colorScheme.error;
    final info = ux4gColors?.info ?? colorScheme.secondary;
    final surface = ux4gColors?.surface ?? colorScheme.surface;
    final onPrimary = ux4gColors?.onPrimary ?? colorScheme.onPrimary;

    final (baseLight, baseNormal, baseDark) = switch (this.colorScheme) {
      Ux4gTagColor.neutral => (
        onSurface.withValues(alpha: 0.1),
        onSurface.withValues(alpha: 0.5),
        onSurface.withValues(alpha: 0.8),
      ),
      Ux4gTagColor.brand => (primary.withValues(alpha: 0.12), primary, primary),
      Ux4gTagColor.success => (
        success.withValues(alpha: 0.12),
        success,
        success,
      ),
      Ux4gTagColor.warning => (
        warning.withValues(alpha: 0.12),
        warning,
        warning,
      ),
      Ux4gTagColor.error => (error.withValues(alpha: 0.12), error, error),
      Ux4gTagColor.info => (info.withValues(alpha: 0.12), info, info),
    };

    return switch (style) {
      Ux4gTagStyle.tonal => _TagColors(
        backgroundColor: baseLight,
        contentColor: baseDark,
        borderColor: Colors.transparent,
      ),
      Ux4gTagStyle.filled => _TagColors(
        backgroundColor: baseNormal,
        contentColor: (this.colorScheme == Ux4gTagColor.neutral)
            ? surface
            : onPrimary, // Usually onPrimary works for brand/error/success/warning
        borderColor: Colors.transparent,
      ),
      Ux4gTagStyle.outline => _TagColors(
        backgroundColor: Colors.transparent,
        contentColor: baseNormal,
        borderColor: baseNormal,
      ),
      Ux4gTagStyle.text => _TagColors(
        backgroundColor: Colors.transparent,
        contentColor: baseNormal,
        borderColor: Colors.transparent,
      ),
    };
  }
}

class _TagColors {
  final Color backgroundColor;
  final Color contentColor;
  final Color borderColor;

  const _TagColors({
    required this.backgroundColor,
    required this.contentColor,
    required this.borderColor,
  });
}

// ─── Unified Pill Segment ───────────────────────────────────────────────────

/// A single segment inside a [Ux4gUnifiedPillTag].
class Ux4gPillSegment {
  /// Text displayed in this segment.
  final String text;

  /// Optional widget shown before the text (e.g., a dot indicator).
  final Widget? leading;

  /// Text color override for this segment.
  final Color? textColor;

  /// Text style override: `true` for bold, `false` (default) for regular.
  final bool bold;

  const Ux4gPillSegment({
    required this.text,
    this.leading,
    this.textColor,
    this.bold = false,
  });
}

// ─── Unified Pill Tag ───────────────────────────────────────────────────────

/// A pill-shaped tag that renders multiple [Ux4gPillSegment]s separated by a
/// thin vertical divider — all inside one unified container.
///
/// Example:
/// ```dart
/// Ux4gUnifiedPillTag(
///   segments: [
///     Ux4gPillSegment(
///       text: '2 days remaining',
///       leading: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
///     ),
///     Ux4gPillSegment(text: 'Pending', bold: true, textColor: Colors.orange),
///   ],
/// )
/// ```
class Ux4gUnifiedPillTag extends StatelessWidget {
  /// Segments to render inside the pill.
  final List<Ux4gPillSegment> segments;

  /// Size of the pill.
  final Ux4gTagSize size;

  /// Background color (defaults to white).
  final Color? backgroundColor;

  /// Border color (defaults to subtle onSurface).
  final Color? borderColor;

  /// Border width (defaults to 1.0).
  final double borderWidth;

  /// Divider color between segments.
  final Color? dividerColor;

  /// Custom border radius override.
  final BorderRadius? customBorderRadius;

  const Ux4gUnifiedPillTag({
    super.key,
    required this.segments,
    this.size = Ux4gTagSize.l,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.dividerColor,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final lSDefault =
        ux4gTypography?.lS_default ??
        materialTheme.textTheme.labelSmall ??
        const TextStyle();
    final lMDefault =
        ux4gTypography?.lM_default ??
        materialTheme.textTheme.labelMedium ??
        const TextStyle();
    final lSStrong =
        ux4gTypography?.lS_strong ??
        materialTheme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle();
    final lMStrong =
        ux4gTypography?.lM_strong ??
        materialTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle();

    final height = size == Ux4gTagSize.m ? 20.0 : 24.0;
    final horizontalPadding = size == Ux4gTagSize.m ? 8.0 : 12.0;
    final textStyleDefault = size == Ux4gTagSize.m ? lSDefault : lMDefault;
    final textStyleBold = size == Ux4gTagSize.m ? lSStrong : lMStrong;

    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final surface = ux4gColors?.surface ?? materialTheme.colorScheme.surface;

    final bgColor = backgroundColor ?? surface;
    final border = borderColor ?? onSurface.withValues(alpha: 0.12);
    final divider = dividerColor ?? onSurface.withValues(alpha: 0.15);
    final defaultTextColor = onSurface;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: size == Ux4gTagSize.m ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: customBorderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: border, width: borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < segments.length; i++) ...[
            if (i > 0) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 14,
                color: divider,
              ),
            ],
            if (segments[i].leading != null) ...[
              segments[i].leading!,
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                segments[i].text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (segments[i].bold ? textStyleBold : textStyleDefault)
                    .copyWith(
                      color: segments[i].textColor ?? defaultTextColor,
                      height: 1,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
