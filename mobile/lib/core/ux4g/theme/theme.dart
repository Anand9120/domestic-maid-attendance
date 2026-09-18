import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/typography.dart';

class Ux4gTheme extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const Ux4gTheme({super.key, required this.child, this.isDark = false});

  static ThemeData themeData({bool isDark = false}) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      extensions: [
        isDark ? darkUx4gColors : lightUx4gColors,
        defaultUx4gTypography,
      ],
    );
  }

  static Ux4gThemeColors colors(BuildContext context) {
    return Theme.of(context).extension<Ux4gThemeColors>() ?? lightUx4gColors;
  }

  static Ux4gTypography typography(BuildContext context) {
    return Theme.of(context).extension<Ux4gTypography>() ??
        defaultUx4gTypography;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData(isDark: isDark),
      child: child,
    );
  }
}
