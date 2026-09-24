import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/colors.dart';
import '../foundation/typography.dart';
import '../foundation/dimensions.dart';

enum Ux4gInputFieldSize {
  small(32),
  medium(40),
  large(48),
  xl(56);

  final double height;
  const Ux4gInputFieldSize(this.height);
}

enum Ux4gInputFieldType { text, password, number, email }

enum Ux4gInputFieldStatus { defaultStatus, error, warning, success }

class Ux4gInputField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onValueChange;
  final Ux4gInputFieldSize size;
  final Ux4gInputFieldType type;
  final Ux4gInputFieldStatus status;
  final String? label;
  final bool required;
  final String? placeholder;
  final String? caption;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingIconPressed;
  final String? prefixText;
  final String? postfixText;
  final IconData? trailingIconLabel;
  final bool enabled;
  final bool readOnly;
  final bool singleLine;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final TextStyle? labelStyle;
  final TextStyle? captionStyle;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? disabledBorderColor;
  final double borderWidth;
  final double disabledBorderWidth;

  const Ux4gInputField({
    super.key,
    required this.value,
    required this.onValueChange,
    this.size = Ux4gInputFieldSize.medium,
    this.type = Ux4gInputFieldType.text,
    this.status = Ux4gInputFieldStatus.defaultStatus,
    this.label,
    this.required = false,
    this.placeholder,
    this.caption,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingIconPressed,
    this.prefixText,
    this.postfixText,
    this.trailingIconLabel,
    this.enabled = true,
    this.readOnly = false,
    this.singleLine = true,
    this.maxLines,
    this.maxLength,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.style,
    this.placeholderStyle,
    this.labelStyle,
    this.captionStyle,
    this.backgroundColor,
    this.borderColor,
    this.disabledBorderColor,
    this.borderWidth = 1.0,
    this.disabledBorderWidth = 0.0,
  });

  @override
  State<Ux4gInputField> createState() => _Ux4gInputFieldState();
}

class _Ux4gInputFieldState extends State<Ux4gInputField> {
  bool _obscureText = true;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _obscureText = widget.type == Ux4gInputFieldType.password;
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(Ux4gInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final error = ux4gColors?.error ?? materialTheme.colorScheme.error;

    final bsStrong =
        ux4gTypography?.bS_strong ??
        materialTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(fontWeight: FontWeight.w700, fontSize: 14);
    final bmDefault =
        ux4gTypography?.bM_default ??
        materialTheme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 16);
    final bsDefault =
        ux4gTypography?.bS_default ??
        materialTheme.textTheme.bodySmall ??
        const TextStyle(fontSize: 14);
    final bxsDefault =
        ux4gTypography?.bXS_default ??
        materialTheme.textTheme.bodySmall ??
        const TextStyle(fontSize: 12);
    final llDefault =
        ux4gTypography?.lL_default ??
        materialTheme.textTheme.labelLarge ??
        const TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

    final borderColor = _getBorderColor(materialTheme, ux4gColors);

    final isDark = materialTheme.brightness == Brightness.dark;
    final defaultBgColor = isDark
        ? Ux4gColors.neutral950
        : Ux4gColors.neutral0;

    final bgColor =
        widget.backgroundColor ??
        (widget.enabled ? defaultBgColor : onSurface.withValues(alpha: 0.05));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Section
        if (widget.label != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  widget.label!,
                  style: (widget.labelStyle ?? llDefault).copyWith(
                    color:
                        widget.labelStyle?.color ??
                        (widget.enabled
                            ? _getLabelColor(materialTheme, ux4gColors)
                            : onSurface.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              if (widget.required) ...[
                const SizedBox(width: 4),
                Text("*", style: bsStrong.copyWith(color: error)),
              ],
              if (widget.trailingIconLabel != null) ...[
                const SizedBox(width: 4),
                Icon(
                  widget.trailingIconLabel,
                  size: 16,
                  color: onSurface.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Input Container
        Container(
          height: widget.singleLine ? widget.size.height : null,
          constraints: widget.singleLine
              ? null
              : const BoxConstraints(minHeight: 100),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(Ux4gRadius.radius8),
            border: widget.enabled
                ? Border.all(
                    color: borderColor,
                    width: _isFocused ? 2.0 : widget.borderWidth,
                  )
                : (widget.disabledBorderWidth == 0.0
                      ? Border.all(color: Colors.transparent, width: 0.0)
                      : Border.all(
                          color: borderColor,
                          width: widget.disabledBorderWidth,
                        )),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Leading Icon
              if (widget.leadingIcon != null) ...[
                Icon(
                  widget.leadingIcon,
                  size: 20,
                  color: onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
              ],

              // Prefix Text
              if (widget.prefixText != null) ...[
                Text(
                  widget.prefixText!,
                  style: bsDefault.copyWith(
                    color: isDark
                        ? Ux4gColors.neutral200
                        : Ux4gColors.neutral700,
                  ),
                ),
                const SizedBox(width: 4),
              ],

              // Input Field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onValueChange,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  obscureText:
                      widget.type == Ux4gInputFieldType.password &&
                      _obscureText,
                  maxLines: widget.singleLine ? 1 : widget.maxLines,
                  keyboardType: _getKeyboardType(),
                  cursorColor: primary,
                  maxLength: widget.maxLength,
                  inputFormatters: _getEffectiveInputFormatters(),
                  textAlign: widget.textAlign,
                  style: (widget.style ?? bmDefault).copyWith(
                    color:
                        widget.style?.color ??
                        (widget.enabled
                            ? onSurface
                            : onSurface.withValues(alpha: 0.4)),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: (widget.placeholderStyle ?? bmDefault).copyWith(
                      color:
                          widget.placeholderStyle?.color ??
                          (Theme.of(context).brightness == Brightness.dark
                              ? Ux4gColors.neutral300
                              : Ux4gColors.neutral500),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: "",
                  ),
                ),
              ),

              // Postfix Text
              if (widget.postfixText != null) ...[
                const SizedBox(width: 4),
                Text(
                  widget.postfixText!,
                  style: bmDefault.copyWith(
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],

              // Trailing Icon or Eye Toggle
              if (widget.type == Ux4gInputFieldType.password) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _obscureText = !_obscureText),
                  child: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ] else if (widget.trailingIcon != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onTrailingIconPressed,
                  child: Icon(
                    widget.trailingIcon,
                    size: 20,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Caption Section
        if (widget.caption != null && widget.caption!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.status == Ux4gInputFieldStatus.error ||
                  widget.status == Ux4gInputFieldStatus.warning ||
                  widget.status == Ux4gInputFieldStatus.success) ...[
                Icon(
                  _getStatusIcon(),
                  size: 14,
                  color: _getStatusIconColor(materialTheme, ux4gColors),
                ),
                const SizedBox(width: 6),
              ] else if (widget.status ==
                  Ux4gInputFieldStatus.defaultStatus) ...[
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: _getStatusIconColor(materialTheme, ux4gColors),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  widget.caption ?? "",
                  style: (widget.captionStyle ?? bxsDefault).copyWith(
                    color:
                        widget.captionStyle?.color ??
                        _getStatusTextColor(materialTheme, ux4gColors),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getBorderColor(ThemeData materialTheme, Ux4gThemeColors? ux4gColors) {
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final error = materialTheme.brightness == Brightness.dark
        ? Ux4gColors.red300
        : Ux4gColors.red600;
    final warning = ux4gColors?.warning ?? Colors.orange;
    final success = ux4gColors?.success ?? Colors.green;
    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;

    final isDark = materialTheme.brightness == Brightness.dark;
    final defaultBorderColor = isDark
        ? Ux4gColors.neutral700
        : Ux4gColors.neutral200;

    if (!widget.enabled) {
      return widget.disabledBorderColor ?? onSurface.withValues(alpha: 0.3);
    }
    return switch (widget.status) {
      Ux4gInputFieldStatus.error => error,
      Ux4gInputFieldStatus.warning => warning,
      Ux4gInputFieldStatus.success => success,
      Ux4gInputFieldStatus.defaultStatus =>
        _isFocused ? primary : (widget.borderColor ?? defaultBorderColor),
    };
  }

  Color _getLabelColor(ThemeData materialTheme, Ux4gThemeColors? ux4gColors) {
    final isDark = materialTheme.brightness == Brightness.dark;
    return isDark ? Ux4gColors.neutral200 : Ux4gColors.neutral700;
  }

  Color _getStatusIconColor(ThemeData materialTheme, Ux4gThemeColors? ux4gColors) {
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final error = materialTheme.brightness == Brightness.dark
        ? Ux4gColors.red500
        : Ux4gColors.red600;
    final warning = ux4gColors?.warning ?? Colors.orange;
    final success = ux4gColors?.success ?? Colors.green;

    if (!widget.enabled) return onSurface.withValues(alpha: 0.4);
    return switch (widget.status) {
      Ux4gInputFieldStatus.error => error,
      Ux4gInputFieldStatus.warning => warning,
      Ux4gInputFieldStatus.success => success,
      Ux4gInputFieldStatus.defaultStatus => onSurface.withValues(alpha: 0.6),
    };
  }

  Color _getStatusTextColor(ThemeData materialTheme, Ux4gThemeColors? ux4gColors) {
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final error = materialTheme.brightness == Brightness.dark
        ? Ux4gColors.red300
        : Ux4gColors.red800;
    final warning = ux4gColors?.warning ?? Colors.orange;
    final success = ux4gColors?.success ?? Colors.green;

    if (!widget.enabled) return onSurface.withValues(alpha: 0.4);
    return switch (widget.status) {
      Ux4gInputFieldStatus.error => error,
      Ux4gInputFieldStatus.warning => warning,
      Ux4gInputFieldStatus.success => success,
      Ux4gInputFieldStatus.defaultStatus => onSurface.withValues(alpha: 0.6),
    };
  }

  IconData? _getStatusIcon() {
    return switch (widget.status) {
      Ux4gInputFieldStatus.error => Icons.error,
      Ux4gInputFieldStatus.warning => Icons.warning,
      Ux4gInputFieldStatus.success => Icons.check_circle,
      Ux4gInputFieldStatus.defaultStatus => null,
    };
  }

  TextInputType _getKeyboardType() {
    return switch (widget.type) {
      Ux4gInputFieldType.password => TextInputType.visiblePassword,
      Ux4gInputFieldType.number => TextInputType.number,
      Ux4gInputFieldType.email => TextInputType.emailAddress,
      Ux4gInputFieldType.text => TextInputType.text,
    };
  }

  List<TextInputFormatter> _getEffectiveInputFormatters() {
    if (widget.inputFormatters != null) {
      return widget.inputFormatters!;
    }
    final formatters = <TextInputFormatter>[];
    if (widget.type == Ux4gInputFieldType.number) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    return formatters;
  }
}
