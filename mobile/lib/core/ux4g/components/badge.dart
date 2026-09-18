import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../foundation/colors.dart';
import '../foundation/typography.dart';

enum Ux4gBadgeLimit {
  singleDigit, // 9+
  doubleDigit, // 99+
}

enum _Ux4gBadgeInternalType { dot, text, label, icon, readyToUse }

class Ux4gBadge extends StatelessWidget {
  final Widget? child;
  final _Ux4gBadgeInternalType _type;
  final String? label;
  final int? count;
  final Ux4gBadgeLimit limit;
  final IconData? icon;
  final String? assetPath;
  final Color? containerColor;
  final Color? contentColor;
  final AlignmentGeometry alignment;
  final bool showBorder;
  final Color? borderColor;

  const Ux4gBadge.dot({
    super.key,
    this.child,
    this.containerColor,
    this.alignment = Alignment.topRight,
    this.showBorder = false,
    this.borderColor,
  }) : _type = _Ux4gBadgeInternalType.dot,
       label = null,
       count = null,
       limit = Ux4gBadgeLimit.singleDigit,
       icon = null,
       assetPath = null,
       contentColor = null;

  const Ux4gBadge.count(
    this.count, {
    super.key,
    this.child,
    this.limit = Ux4gBadgeLimit.singleDigit,
    this.containerColor,
    this.contentColor,
    this.alignment = Alignment.topRight,
    this.showBorder = false,
    this.borderColor,
  }) : _type = _Ux4gBadgeInternalType.text,
       label = null,
       icon = null,
       assetPath = null;

  const Ux4gBadge.label(
    this.label, {
    super.key,
    this.child,
    this.containerColor,
    this.contentColor,
    this.alignment = Alignment.topRight,
    this.showBorder = false,
    this.borderColor,
  }) : _type = _Ux4gBadgeInternalType.label,
       count = null,
       limit = Ux4gBadgeLimit.singleDigit,
       icon = null,
       assetPath = null;

  const Ux4gBadge.icon(
    this.icon, {
    super.key,
    this.child,
    this.containerColor,
    this.contentColor,
    this.alignment = Alignment.topRight,
    this.showBorder = false,
    this.borderColor,
  }) : _type = _Ux4gBadgeInternalType.icon,
       label = null,
       count = null,
       limit = Ux4gBadgeLimit.singleDigit,
       assetPath = null;

  const Ux4gBadge.readyToUse(
    this.assetPath, {
    super.key,
    this.child,
    this.contentColor,
    this.alignment = Alignment.topRight,
    this.showBorder = false,
    this.borderColor,
  }) : _type = _Ux4gBadgeInternalType.readyToUse,
       label = null,
       count = null,
       limit = Ux4gBadgeLimit.singleDigit,
       icon = null,
       containerColor = null;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return _buildBadge(context);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(
          // Adjust position so it sits on the edge
          right: alignment == Alignment.topRight ? -4 : null,
          top: alignment == Alignment.topRight ? -4 : null,
          left: alignment == Alignment.topLeft ? -4 : null,
          bottom: alignment == Alignment.bottomRight ? -4 : null,
          child: _buildBadge(context),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final resolvedBg =
        containerColor ??
        (ux4gColors?.primary ?? materialTheme.colorScheme.primary);
        
    Color getDefaultContentColor() {
      if (ux4gColors != null) {
        // Specific overrides for exact match with design
        if (resolvedBg == Ux4gColors.neutral600) return Ux4gColors.white;
        if (resolvedBg == Ux4gColors.neutral300) return Ux4gColors.neutral900;
        if (resolvedBg == Ux4gColors.orange600) return Ux4gColors.white;

        if (resolvedBg == ux4gColors.primary) return ux4gColors.onPrimary;
        if (resolvedBg == ux4gColors.secondary) return ux4gColors.onSecondary;
        if (resolvedBg == ux4gColors.success) return ux4gColors.onSuccess;
        if (resolvedBg == ux4gColors.error) return ux4gColors.onError;
        if (resolvedBg == ux4gColors.warning) return ux4gColors.onWarning;
        if (resolvedBg == ux4gColors.info) return ux4gColors.onInfo;
      }
      return ThemeData.estimateBrightnessForColor(resolvedBg) == Brightness.dark
          ? Ux4gColors.white
          : Ux4gColors.neutral900;
    }
    
    final resolvedContent = contentColor ?? getDefaultContentColor();
    final resolvedBorderColor = borderColor ?? materialTheme.colorScheme.surface;
    final border = showBorder ? Border.all(color: resolvedBorderColor, width: 1.5) : null;

    switch (_type) {
      case _Ux4gBadgeInternalType.dot:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: resolvedBg, shape: BoxShape.circle, border: border),
        );
      case _Ux4gBadgeInternalType.text:
        if (count == null) return const SizedBox.shrink();
        final displayCount = limit == Ux4gBadgeLimit.singleDigit
            ? (count! > 9 ? "9+" : count.toString())
            : (count! > 99 ? "99+" : count.toString());

        final isSingleChar = displayCount.length == 1;

        return Container(
          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          padding: EdgeInsets.symmetric(horizontal: isSingleChar ? 0 : 6),
          decoration: BoxDecoration(
            color: resolvedBg,
            shape: isSingleChar ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isSingleChar ? null : BorderRadius.circular(100),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayCount,
                    textAlign: TextAlign.center,
                    style:
                        (ux4gTypography?.lS_strong ??
                                materialTheme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ) ??
                                const TextStyle())
                            .copyWith(color: resolvedContent, fontSize: 10, height: 1),
                  ),
                ],
              ),
            ],
          ),
        );
      case _Ux4gBadgeInternalType.label:
        if (label == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: resolvedBg,
            borderRadius: BorderRadius.circular(4),
            border: border,
          ),
          child: Text(
            label!,
            style:
                (ux4gTypography?.lS_strong ??
                        materialTheme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ??
                        const TextStyle())
                    .copyWith(color: resolvedContent, height: 1),
          ),
        );
      case _Ux4gBadgeInternalType.icon:
        if (icon == null) return const SizedBox.shrink();
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: resolvedBg, shape: BoxShape.circle, border: border),
          alignment: Alignment.center,
          child: Icon(icon, size: 12, color: resolvedContent),
        );
      case _Ux4gBadgeInternalType.readyToUse:
        if (assetPath == null) return const SizedBox.shrink();
        Widget imageWidget;
        if (assetPath!.toLowerCase().contains('.svg')) {
          imageWidget = SvgPicture.asset(assetPath!.trim(), width: 18, height: 18);
        } else {
          imageWidget = Image.asset(assetPath!.trim(), width: 18, height: 18);
        }
        if (showBorder) {
          return Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: border,
            ),
            alignment: Alignment.center,
            child: imageWidget,
          );
        }
        return imageWidget;
      default:
        return const SizedBox.shrink();
    }
  }
}
