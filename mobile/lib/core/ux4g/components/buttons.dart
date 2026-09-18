import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/typography.dart';
import '../foundation/dimensions.dart';
import 'loader.dart';

enum Ux4gButtonVariant { primary, secondary, outline, ghost }

enum Ux4gButtonSize {
  xs(12.0, 4.0, 24.0),
  small(16.0, 7.0, 32.0),
  medium(20.0, 10.0, 40.0),
  large(24.0, 14.0, 48.0),
  xl(28.0, 16.0, 56.0);

  final double horizontalPadding;
  final double verticalPadding;
  final double defaultHeight;
  const Ux4gButtonSize(this.horizontalPadding, this.verticalPadding, this.defaultHeight);
}

class Ux4gButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;
  final Ux4gButtonVariant variant;
  final Ux4gButtonSize size;
  final bool enabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? contentColor;
  final Color? disabledBackgroundColor;
  final Color? disabledContentColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? iconSize;
  final double? width;
  final double? height;
  final double? elevation;
  final TextStyle? textStyle;

  const Ux4gButton({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.variant = Ux4gButtonVariant.primary,
    this.size = Ux4gButtonSize.medium,
    this.enabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.contentColor,
    this.disabledBackgroundColor,
    this.disabledContentColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.leadingIcon,
    this.trailingIcon,
    this.iconSize,
    this.width,
    this.height,
    this.elevation,
    this.textStyle,
  }) : assert(
         text != null ||
             child != null ||
             leadingIcon != null ||
             trailingIcon != null,
       );

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final style = _getStyle(ux4gColors, materialTheme);

    final effectiveBgColor = backgroundColor ?? style.backgroundColor;
    final effectiveContentColor = contentColor ?? style.contentColor;

    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;

    final isDark = materialTheme.brightness == Brightness.dark;

    final effectiveDisabledBgColor =
        disabledBackgroundColor ??
        (variant == Ux4gButtonVariant.primary ||
                variant == Ux4gButtonVariant.secondary
            ? (isDark ? Ux4gColors.neutral700 : Ux4gColors.neutral200)
            : Colors.transparent);
    final effectiveDisabledContentColor =
        disabledContentColor ?? (isDark ? Ux4gColors.neutral400 : Ux4gColors.neutral400);
    final effectiveBorderColor = borderColor ?? style.borderColor;
    final effectiveBorderWidth =
        borderWidth ?? (variant == Ux4gButtonVariant.outline ? 1.0 : 0.0);

    final defaultTextStyle =
        switch (size) {
          Ux4gButtonSize.xs => ux4gTypography?.lL_default.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          Ux4gButtonSize.small => ux4gTypography?.lL_default,
          Ux4gButtonSize.medium => ux4gTypography?.lXL_default,
          Ux4gButtonSize.large => ux4gTypography?.lXL_default,
          Ux4gButtonSize.xl => ux4gTypography?.lXL_default.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        } ??
        materialTheme.textTheme.labelLarge ??
        const TextStyle();

    final effectiveTextStyle = textStyle ?? defaultTextStyle;
    final effectiveHeight = height ?? size.defaultHeight;

    final currentContentColor = enabled ? effectiveContentColor : effectiveDisabledContentColor;

    return SizedBox(
      width: width,
      height: effectiveHeight,
      child: OutlinedButton(
        onPressed: enabled ? (isLoading ? () {} : onPressed) : null,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width ?? 0, effectiveHeight),
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveContentColor,
          disabledBackgroundColor: effectiveDisabledBgColor,
          disabledForegroundColor: effectiveDisabledContentColor,
          elevation: elevation ?? 0,
          padding:
              padding ??
                EdgeInsets.symmetric(
                  horizontal: size.horizontalPadding,
                  vertical: size.verticalPadding,
                ),
            side: !enabled && variant != Ux4gButtonVariant.ghost
                ? BorderSide(
                    color: isDark ? Colors.transparent : Ux4gColors.neutral300,
                    width: 1.0,
                  )
                : (effectiveBorderColor != Colors.transparent
                    ? BorderSide(
                        color: effectiveBorderColor,
                        width: effectiveBorderWidth,
                      )
                    : BorderSide.none),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? Ux4gRadius.radius8,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) ...[
                Ux4gSpinner(
                  size: 16,
                  color: currentContentColor,
                  strokeWidth: 2,
                ),
                const SizedBox(width: 8),
              ],
              if (leadingIcon != null && !isLoading) ...[
                Icon(
                  leadingIcon,
                  size: iconSize ?? 18,
                  color: currentContentColor,
                ),
                if (text != null || child != null) const SizedBox(width: 8),
              ],
              Flexible(
                child: DefaultTextStyle(
                  style: effectiveTextStyle.copyWith(
                    color: currentContentColor,
                  ),
                  child:
                      child ??
                      (text != null
                          ? Text(text!, overflow: TextOverflow.ellipsis)
                          : const SizedBox.shrink()),
                ),
              ),
              if (trailingIcon != null) ...[
                if (text != null || child != null || leadingIcon != null)
                  const SizedBox(width: 8),
                Icon(
                  trailingIcon,
                  size: iconSize ?? 18,
                  color: currentContentColor,
                ),
              ],
            ],
          ),
        ),
    );
  }

  _ButtonStyle _getStyle(Ux4gThemeColors? ux4gColors, ThemeData materialTheme) {
    final colorScheme = materialTheme.colorScheme;

    final primary = ux4gColors?.primary ?? colorScheme.primary;
    final onPrimary = ux4gColors?.onPrimary ?? colorScheme.onPrimary;
    final secondary = ux4gColors?.secondary ?? colorScheme.secondary;
    final onSecondary = ux4gColors?.onSecondary ?? colorScheme.onSecondary;

    return switch (variant) {
      Ux4gButtonVariant.primary => _ButtonStyle(
        backgroundColor: primary,
        contentColor: onPrimary,
        borderColor: Colors.transparent,
      ),
      Ux4gButtonVariant.secondary => _ButtonStyle(
        backgroundColor: secondary,
        contentColor: onSecondary,
        borderColor: Colors.transparent,
      ),
      Ux4gButtonVariant.outline => _ButtonStyle(
        backgroundColor: Colors.transparent,
        contentColor: primary,
        borderColor: primary,
      ),
      Ux4gButtonVariant.ghost => _ButtonStyle(
        backgroundColor: Colors.transparent,
        contentColor: primary,
        borderColor: Colors.transparent,
      ),
    };
  }
}

class Ux4gOutlineButton extends Ux4gButton {
  const Ux4gOutlineButton({
    super.key,
    required super.onPressed,
    super.text,
    super.child,
    super.size,
    super.enabled,
    super.isLoading,
    super.backgroundColor,
    Color? color,
    super.borderRadius,
    super.padding,
    super.width,
    super.height,
    super.textStyle,
  }) : super(
         variant: Ux4gButtonVariant.outline,
         contentColor: color,
         borderColor: color,
       );
}

class Ux4gTextButton extends Ux4gButton {
  const Ux4gTextButton({
    super.key,
    required super.onPressed,
    super.text,
    super.child,
    super.size,
    super.enabled,
    super.isLoading,
    Color? color,
    super.borderRadius,
    super.padding,
    super.width,
    super.height,
    super.textStyle,
  }) : super(variant: Ux4gButtonVariant.ghost, contentColor: color);
}

class Ux4gIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Ux4gButtonVariant variant;
  final double size;
  final bool enabled;

  const Ux4gIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = Ux4gButtonVariant.primary,
    this.size = 40,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onPrimary =
        ux4gColors?.onPrimary ?? materialTheme.colorScheme.onPrimary;
    final secondary =
        ux4gColors?.secondary ?? materialTheme.colorScheme.secondary;
    final onSecondary =
        ux4gColors?.onSecondary ?? materialTheme.colorScheme.onSecondary;

    final bgColor = switch (variant) {
      Ux4gButtonVariant.primary => primary,
      Ux4gButtonVariant.secondary => secondary,
      Ux4gButtonVariant.outline => Colors.transparent,
      Ux4gButtonVariant.ghost => Colors.transparent,
    };

    final contentColor = switch (variant) {
      Ux4gButtonVariant.primary => onPrimary,
      Ux4gButtonVariant.secondary => onSecondary,
      Ux4gButtonVariant.outline => primary,
      Ux4gButtonVariant.ghost => primary,
    };
    
    final isDark = materialTheme.brightness == Brightness.dark;
    
    final disabledBgColor = variant == Ux4gButtonVariant.primary || variant == Ux4gButtonVariant.secondary
        ? (isDark ? Ux4gColors.neutral700 : Ux4gColors.neutral200)
        : Colors.transparent;
    final disabledFgColor = isDark ? Ux4gColors.neutral400 : Ux4gColors.neutral400;

    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: size * 0.6),
      style: IconButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: contentColor,
        disabledBackgroundColor: disabledBgColor,
        disabledForegroundColor: disabledFgColor,
        fixedSize: Size(size, size),
        side: !enabled && variant != Ux4gButtonVariant.ghost
            ? BorderSide(
                color: isDark ? Colors.transparent : Ux4gColors.neutral300,
                width: 1.0,
              )
            : (variant == Ux4gButtonVariant.outline
                ? BorderSide(
                    color: primary,
                    width: 1.0,
                  )
                : null),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ux4gRadius.radius8),
        ),
      ),
    );
  }
}

class _ButtonStyle {
  final Color backgroundColor;
  final Color contentColor;
  final Color borderColor;

  const _ButtonStyle({
    required this.backgroundColor,
    required this.contentColor,
    required this.borderColor,
  });
}
