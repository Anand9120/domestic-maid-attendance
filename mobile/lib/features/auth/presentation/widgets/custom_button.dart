import 'package:flutter/material.dart';
import '../../../../core/ux4g/ux4g.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Ux4gButton(
      width: double.infinity,
      size: Ux4gButtonSize.large,
      variant: Ux4gButtonVariant.primary,
      backgroundColor: backgroundColor,
      contentColor: textColor,
      leadingIcon: icon,
      text: text,
      isLoading: isLoading,
      onPressed: onPressed,
      borderRadius: 14,
    );
  }
}
