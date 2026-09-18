import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../foundation/colors.dart';
import '../foundation/typography.dart';
import '../foundation/dimensions.dart';
import 'input_field.dart';

// --- Choice Chip ---

enum Ux4gChoiceChipSize { s, m }

class Ux4gChoiceChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onClick;
  final bool enabled;
  final Ux4gChoiceChipSize size;
  final Widget? leadingContent;
  final Widget? trailingContent;
  final double borderRadius;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double selectedBorderWidth;
  final double unselectedBorderWidth;

  const Ux4gChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onClick,
    this.enabled = true,
    this.size = Ux4gChoiceChipSize.m,
    this.leadingContent,
    this.trailingContent,
    this.borderRadius = Ux4gRadius.radius4,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorderWidth = 1,
    this.unselectedBorderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final paddingH = size == Ux4gChoiceChipSize.s ? 12.0 : 16.0;
    final paddingV = size == Ux4gChoiceChipSize.s ? 6.0 : 8.0;
    final textStyle = size == Ux4gChoiceChipSize.s
        ? (ux4gTypography?.lM_default ??
              materialTheme.textTheme.labelMedium ??
              const TextStyle())
        : (ux4gTypography?.lL_default ??
              materialTheme.textTheme.labelLarge ??
              const TextStyle());

    final bgColor = selected
        ? (selectedBackgroundColor ??
              (ux4gColors?.primary ?? materialTheme.colorScheme.primary))
        : (unselectedBackgroundColor ??
              (ux4gColors?.surface ?? materialTheme.colorScheme.surface));

    final borderColor = selected
        ? (selectedBorderColor ??
              (ux4gColors?.primary ?? materialTheme.colorScheme.primary))
        : (unselectedBorderColor ??
              (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface)
                  .withValues(alpha: 0.2));

    final borderWidth = selected ? selectedBorderWidth : unselectedBorderWidth;

    final textColor = selected
        ? (selectedTextColor ??
              (ux4gColors?.onPrimary ?? materialTheme.colorScheme.onPrimary))
        : (unselectedTextColor ??
              (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface));

    return InkWell(
      onTap: enabled ? onClick : null,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingContent != null) ...[
                leadingContent!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  style: textStyle.copyWith(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingContent != null) ...[
                const SizedBox(width: 8),
                trailingContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- Filter Chip ---

enum Ux4gFilterChipSize { s, m }

class Ux4gFilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onClick;
  final bool enabled;
  final Ux4gFilterChipSize size;
  final Widget? leadingContent;
  final double borderRadius;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double selectedBorderWidth;
  final double unselectedBorderWidth;

  const Ux4gFilterChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onClick,
    this.enabled = true,
    this.size = Ux4gFilterChipSize.m,
    this.leadingContent,
    this.borderRadius = Ux4gRadius.radius4,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorderWidth = 1,
    this.unselectedBorderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final height = size == Ux4gFilterChipSize.s ? 28.0 : 32.0;
    final paddingH = size == Ux4gFilterChipSize.s ? 12.0 : 16.0;
    final textStyle = size == Ux4gFilterChipSize.s
        ? (ux4gTypography?.lM_default ??
              materialTheme.textTheme.labelMedium ??
              const TextStyle())
        : (ux4gTypography?.lL_default ??
              materialTheme.textTheme.labelLarge ??
              const TextStyle());

    final bgColor = selected
        ? (selectedBackgroundColor ??
              (ux4gColors?.primary ?? materialTheme.colorScheme.primary)
                  .withValues(alpha: 0.08))
        : (unselectedBackgroundColor ??
              (ux4gColors?.surface ?? materialTheme.colorScheme.surface));

    final borderColor = selected
        ? (selectedBorderColor ??
              (ux4gColors?.primary ?? materialTheme.colorScheme.primary))
        : (unselectedBorderColor ??
              (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface)
                  .withValues(alpha: 0.2));

    final borderWidth = selected ? selectedBorderWidth : unselectedBorderWidth;

    final textColor = selected
        ? (selectedTextColor ??
              (ux4gColors?.primary ?? materialTheme.colorScheme.primary))
        : (unselectedTextColor ??
              (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface));

    return InkWell(
      onTap: enabled ? onClick : null,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: paddingH),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingContent != null) ...[
                leadingContent!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  style: textStyle.copyWith(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Input Chip ---

enum Ux4gInputChipSize { xs, s, m }

class Ux4gInputChip extends StatelessWidget {
  final String text;
  final VoidCallback onDismiss;
  final bool enabled;
  final Ux4gInputChipSize size;
  final Widget? leadingContent;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double borderWidth;

  const Ux4gInputChip({
    super.key,
    required this.text,
    required this.onDismiss,
    this.enabled = true,
    this.size = Ux4gInputChipSize.m,
    this.leadingContent,
    this.borderRadius = Ux4gRadius.radius4,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final height = switch (size) {
      Ux4gInputChipSize.xs => 20.0,
      Ux4gInputChipSize.s => 28.0,
      Ux4gInputChipSize.m => 32.0,
    };
    final paddingH = switch (size) {
      Ux4gInputChipSize.xs => 8.0,
      Ux4gInputChipSize.s => 12.0,
      Ux4gInputChipSize.m => 16.0,
    };
    final textStyle = switch (size) {
      Ux4gInputChipSize.xs =>
        ux4gTypography?.lS_default ??
            materialTheme.textTheme.labelSmall ??
            const TextStyle(),
      Ux4gInputChipSize.s =>
        ux4gTypography?.lM_default ??
            materialTheme.textTheme.labelMedium ??
            const TextStyle(),
      Ux4gInputChipSize.m =>
        ux4gTypography?.lL_default ??
            materialTheme.textTheme.labelLarge ??
            const TextStyle(),
    };
    final iconSize = size == Ux4gInputChipSize.xs ? 12.0 : 16.0;

    final finalBgColor =
        backgroundColor ??
        (ux4gColors?.surface ?? materialTheme.colorScheme.surface);
    final finalBorderColor =
        borderColor ??
        (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface)
            .withValues(alpha: 0.2);
    final finalTextColor =
        textColor ??
        (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface);

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: paddingH),
        decoration: BoxDecoration(
          color: finalBgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: finalBorderColor, width: borderWidth),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingContent != null) ...[
              leadingContent!,
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                style: textStyle.copyWith(color: finalTextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: enabled ? onDismiss : null,
              child: Icon(
                Icons.close,
                size: iconSize,
                color: finalTextColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Ux4gInputChipField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onValueChange;
  final ValueChanged<String> onAddChip;
  final String placeholder;
  final Widget? leadingIcon;
  final bool isDropdown;
  final List<String> dropdownOptions;
  final List<Widget> chips;
  final Ux4gChipGroupArrangement arrangement;

  const Ux4gInputChipField({
    super.key,
    required this.value,
    required this.onValueChange,
    required this.onAddChip,
    this.placeholder = "Please select..",
    this.leadingIcon,
    this.isDropdown = false,
    this.dropdownOptions = const [],
    this.chips = const [],
    this.arrangement = Ux4gChipGroupArrangement.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDropdown)
          _buildDropdownField(context)
        else
          Ux4gInputField(
            value: value,
            onValueChange: onValueChange,
            placeholder: placeholder,
            leadingIcon: leadingIcon is Icon
                ? (leadingIcon as Icon).icon
                : null,
            onTrailingIconPressed: () {
              if (value.isNotEmpty) {
                onAddChip(value);
                onValueChange("");
              }
            },
            trailingIcon: Icons.add,
          ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Ux4gChipGroup(
            chips: chips,
            arrangement: arrangement,
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        onAddChip(val);
        onValueChange("");
      },
      itemBuilder: (context) => dropdownOptions
          .map((opt) => PopupMenuItem(value: opt, child: Text(opt)))
          .toList(),
      child: Ux4gInputField(
        value: value,
        onValueChange: onValueChange,
        placeholder: placeholder,
        leadingIcon: leadingIcon is Icon ? (leadingIcon as Icon).icon : null,
        enabled: false, // Click handles by popup
        trailingIcon: Icons.arrow_drop_down,
      ),
    );
  }
}

// --- Chip Group ---

enum Ux4gChipGroupArrangement { horizontal, wrap }

class Ux4gChipGroup extends StatelessWidget {
  final List<Widget> chips;
  final Ux4gChipGroupArrangement arrangement;
  final double spacing;
  final double runSpacing;

  const Ux4gChipGroup({
    super.key,
    required this.chips,
    this.arrangement = Ux4gChipGroupArrangement.horizontal,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (arrangement) {
      case Ux4gChipGroupArrangement.horizontal:
        return LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  dragStartBehavior: DragStartBehavior.down,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: chips
                        .map(
                          (chip) => Padding(
                            padding: EdgeInsets.only(right: spacing),
                            child: chip,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
          },
        );
      case Ux4gChipGroupArrangement.wrap:
        return Wrap(spacing: spacing, runSpacing: runSpacing, children: chips);
    }
  }
}
