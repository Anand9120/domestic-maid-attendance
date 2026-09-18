import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/typography.dart';
import '../foundation/dimensions.dart';
import 'badge.dart';
import 'buttons.dart';

enum Ux4gCardDirection { vertical, horizontal }

enum Ux4gCardFooterType {
  none,
  primaryOnly,
  secondaryOnly,
  primaryAndSecondary,
}

enum Ux4gCardFooterAlignment { left, centered, right }

class Ux4gCard extends StatelessWidget {
  final Widget? child;
  final double cornerRadius;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double elevation;
  final bool isClickable;
  final VoidCallback? onPressed;
  final Ux4gCardDirection direction;
  final String? mediaImageUrl;
  final double mediaHeight;
  final double mediaWidth;
  final String? mediaLabelText;
  final Widget? avatar;
  final String? title;
  final String? subtitle;
  final List<String> statusChips;
  final String? body;
  final List<String> bottomChips;
  final Ux4gCardFooterType footerType;
  final Ux4gCardFooterAlignment footerAlignment;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryClick;
  final VoidCallback? onSecondaryClick;

  const Ux4gCard({
    super.key,
    this.child,
    this.cornerRadius = Ux4gRadius.radius12,
    this.backgroundColor,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.elevation = 0,
    this.isClickable = false,
    this.onPressed,
    this.direction = Ux4gCardDirection.vertical,
    this.mediaImageUrl,
    this.mediaHeight = 180,
    this.mediaWidth = 120,
    this.mediaLabelText,
    this.avatar,
    this.title,
    this.subtitle,
    this.statusChips = const [],
    this.body,
    this.bottomChips = const [],
    this.footerType = Ux4gCardFooterType.none,
    this.footerAlignment = Ux4gCardFooterAlignment.left,
    this.primaryButtonText = 'Confirm',
    this.secondaryButtonText = 'Cancel',
    this.onPrimaryClick,
    this.onSecondaryClick,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final resolvedBg =
        backgroundColor ??
        (ux4gColors?.surface ?? materialTheme.colorScheme.surface);
    final hasBorder = borderWidth > 0 && borderColor != Colors.transparent;

    // Determine the best content color based on background brightness
    final bgBrightness = ThemeData.estimateBrightnessForColor(resolvedBg);
    final contentColor = bgBrightness == Brightness.dark
        ? Colors.white
        : (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface);

    final content = child ?? _buildRichCard(context, contentColor);

    return Card(
      color: resolvedBg,
      elevation: elevation,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        side: hasBorder
            ? BorderSide(color: borderColor, width: borderWidth)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isClickable ? onPressed : null,
        child: child != null
            ? SizedBox(width: double.infinity, child: content)
            : content,
      ),
    );
  }

  Widget _buildRichCard(BuildContext context, Color contentColor) {
    if (direction == Ux4gCardDirection.horizontal) {
      return _buildHorizontalLayout(context, contentColor);
    }

    return _buildVerticalLayout(context, contentColor);
  }

  Widget _buildVerticalLayout(BuildContext context, Color contentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mediaImageUrl != null) _buildMedia(context, isHorizontal: false),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Ux4gSpace.space20,
            Ux4gSpace.space20,
            Ux4gSpace.space20,
            Ux4gSpace.space24,
          ),
          child: _CardContentBlock(
            avatar: avatar,
            title: title,
            subtitle: subtitle,
            statusChips: statusChips,
            body: body,
            bottomChips: bottomChips,
            footerType: footerType,
            footerAlignment: footerAlignment,
            primaryButtonText: primaryButtonText,
            secondaryButtonText: secondaryButtonText,
            onPrimaryClick: onPrimaryClick,
            onSecondaryClick: onSecondaryClick,
            contentColor: contentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, Color contentColor) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mediaImageUrl != null)
            SizedBox(
              width: mediaWidth,
              child: _buildMedia(context, isHorizontal: true),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Ux4gSpace.space20,
                Ux4gSpace.space20,
                Ux4gSpace.space20,
                Ux4gSpace.space24,
              ),
              child: _CardContentBlock(
                avatar: avatar,
                title: title,
                subtitle: subtitle,
                statusChips: statusChips,
                body: body,
                bottomChips: bottomChips,
                footerType: footerType,
                footerAlignment: footerAlignment,
                primaryButtonText: primaryButtonText,
                secondaryButtonText: secondaryButtonText,
                onPrimaryClick: onPrimaryClick,
                onSecondaryClick: onSecondaryClick,
                contentColor: contentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context, {required bool isHorizontal}) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();

    final image = SizedBox.expand(
      child: Image.network(
        mediaImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color:
                (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface)
                    .withValues(alpha: 0.08),
            alignment: Alignment.center,
            child: Icon(
              Icons.image_outlined,
              color:
                  (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface)
                      .withValues(alpha: 0.4),
            ),
          );
        },
      ),
    );

    final mediaContent = Stack(
      fit: StackFit.expand,
      children: [
        image,
        if (mediaLabelText != null)
          Positioned(
            top: Ux4gSpace.space8,
            left: Ux4gSpace.space8,
            child: Ux4gBadge.label(
              mediaLabelText!,
              containerColor:
                  ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface,
              contentColor:
                  ux4gColors?.surface ?? materialTheme.colorScheme.surface,
            ),
          ),
      ],
    );

    if (isHorizontal) {
      return mediaContent;
    }

    return SizedBox(
      width: double.infinity,
      height: mediaHeight,
      child: mediaContent,
    );
  }
}

class _CardContentBlock extends StatelessWidget {
  final Widget? avatar;
  final String? title;
  final String? subtitle;
  final List<String> statusChips;
  final String? body;
  final List<String> bottomChips;
  final Ux4gCardFooterType footerType;
  final Ux4gCardFooterAlignment footerAlignment;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryClick;
  final VoidCallback? onSecondaryClick;
  final Color contentColor;

  const _CardContentBlock({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.statusChips,
    required this.body,
    required this.bottomChips,
    required this.footerType,
    required this.footerAlignment,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryClick,
    required this.onSecondaryClick,
    required this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();
    final hasHeader = avatar != null || title != null || subtitle != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (avatar != null) ...[
                avatar!,
                const SizedBox(width: Ux4gSpace.space12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style:
                            (ux4gTypography?.tS_strong ??
                                    materialTheme.textTheme.titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ) ??
                                    const TextStyle())
                                .copyWith(color: contentColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style:
                            (ux4gTypography?.bS_default ??
                                    materialTheme.textTheme.bodySmall ??
                                    const TextStyle())
                                .copyWith(
                                  color: contentColor.withValues(alpha: 0.5),
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        if (statusChips.isNotEmpty) ...[
          const SizedBox(height: Ux4gSpace.space8),
          _CardChipRow(
            chips: statusChips,
            pillStyle: false,
            contentColor: contentColor,
          ),
        ],
        if (body != null) ...[
          const SizedBox(height: Ux4gSpace.space12),
          Text(
            body!,
            style:
                (ux4gTypography?.bM_default ??
                        materialTheme.textTheme.bodyMedium ??
                        const TextStyle())
                    .copyWith(color: contentColor.withValues(alpha: 0.7)),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (bottomChips.isNotEmpty) ...[
          const SizedBox(height: Ux4gSpace.space12),
          _CardChipRow(
            chips: bottomChips,
            pillStyle: true,
            contentColor: contentColor,
          ),
        ],
        if (footerType != Ux4gCardFooterType.none) ...[
          const SizedBox(height: Ux4gSpace.space20),
          _CardFooterRow(
            footerType: footerType,
            footerAlignment: footerAlignment,
            primaryButtonText: primaryButtonText,
            secondaryButtonText: secondaryButtonText,
            onPrimaryClick: onPrimaryClick,
            onSecondaryClick: onSecondaryClick,
          ),
        ],
      ],
    );
  }
}

class _CardChipRow extends StatelessWidget {
  final List<String> chips;
  final bool pillStyle;
  final Color contentColor;

  const _CardChipRow({
    required this.chips,
    required this.pillStyle,
    required this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.asMap().entries.expand((entry) {
          final index = entry.key;
          final chip = entry.value;

          if (pillStyle) {
            return [
              Container(
                margin: EdgeInsets.only(
                  right: index == chips.length - 1 ? 0 : Ux4gSpace.space6,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Ux4gSpace.space12,
                  vertical: Ux4gSpace.space4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Ux4gRadius.radius999),
                  border: Border.all(
                    color: contentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  chip,
                  style:
                      (ux4gTypography?.lS_default ??
                              materialTheme.textTheme.labelSmall ??
                              const TextStyle())
                          .copyWith(color: contentColor.withValues(alpha: 0.7)),
                ),
              ),
            ];
          }

          return [
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Ux4gSpace.space6,
                ),
                child: Text(
                  '│',
                  style:
                      (ux4gTypography?.bS_default ??
                              materialTheme.textTheme.bodySmall ??
                              const TextStyle())
                          .copyWith(color: contentColor.withValues(alpha: 0.3)),
                ),
              ),
            Text(
              chip,
              style:
                  (ux4gTypography?.lS_default ??
                          materialTheme.textTheme.labelSmall ??
                          const TextStyle())
                      .copyWith(color: contentColor.withValues(alpha: 0.6)),
            ),
          ];
        }).toList(),
      ),
    );
  }
}

class _CardFooterRow extends StatelessWidget {
  final Ux4gCardFooterType footerType;
  final Ux4gCardFooterAlignment footerAlignment;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryClick;
  final VoidCallback? onSecondaryClick;

  const _CardFooterRow({
    required this.footerType,
    required this.footerAlignment,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryClick,
    required this.onSecondaryClick,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = switch (footerAlignment) {
      Ux4gCardFooterAlignment.left => MainAxisAlignment.start,
      Ux4gCardFooterAlignment.centered => MainAxisAlignment.center,
      Ux4gCardFooterAlignment.right => MainAxisAlignment.end,
    };

    final fillWidth =
        footerAlignment == Ux4gCardFooterAlignment.centered &&
        footerType != Ux4gCardFooterType.primaryAndSecondary;

    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (footerType == Ux4gCardFooterType.primaryAndSecondary ||
            footerType == Ux4gCardFooterType.primaryOnly)
          Flexible(
            child: Ux4gButton(
              onPressed: onPrimaryClick ?? () {},
              padding: const EdgeInsets.symmetric(
                horizontal: Ux4gSpace.space20,
                vertical: Ux4gSpace.space12,
              ),
              width: fillWidth ? double.infinity : null,
              child: Text(primaryButtonText),
            ),
          ),
        if (footerType == Ux4gCardFooterType.primaryAndSecondary)
          const SizedBox(width: Ux4gSpace.space12),
        if (footerType == Ux4gCardFooterType.primaryAndSecondary ||
            footerType == Ux4gCardFooterType.secondaryOnly)
          Flexible(
            child: Ux4gOutlineButton(
              onPressed: onSecondaryClick ?? () {},
              padding: const EdgeInsets.symmetric(
                horizontal: Ux4gSpace.space20,
                vertical: Ux4gSpace.space12,
              ),
              width: fillWidth ? double.infinity : null,
              child: Text(secondaryButtonText),
            ),
          ),
      ],
    );
  }
}
