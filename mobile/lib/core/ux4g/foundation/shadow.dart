import 'package:flutter/material.dart';

/// UX4G Design System Shadow Tokens.
///
/// Five reusable shadow styles (`shadow0` to `shadow4`).
/// Each combines a directional key shadow and an ambient shadow to express depth.
/// Always apply the matching effect token rather than hand-setting shadow values.
class Ux4gShadow {
  /// Shadow 0 — Flat Surfaces (No shadow)
  static const List<BoxShadow> shadow0 = [];
  static const List<BoxShadow> flat = shadow0;

  /// Shadow 1 — Subtle Lift
  /// Key: Offset(0, 1), blurRadius: 2 | Ambient: Offset(0, 1), blurRadius: 2
  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Color(0x0A000000), // ~4% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x0A000000), // ~4% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
  static const List<BoxShadow> subtle = shadow1;

  /// Shadow 2 — Floating Content
  /// Key: Offset(0, 1), blurRadius: 2 | Ambient: Offset(0, 4), blurRadius: 8
  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x0D000000), // ~5% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x14000000), // ~8% opacity
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];
  static const List<BoxShadow> floating = shadow2;

  /// Shadow 3 — Prominent overlay
  /// Key: Offset(0, 4), blurRadius: 8 | Ambient: Offset(0, 0), blurRadius: 16
  static const List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Color(0x14000000), // ~8% opacity
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Color(0x1A000000), // ~10% opacity
      offset: Offset(0, 0),
      blurRadius: 16,
    ),
  ];
  static const List<BoxShadow> prominent = shadow3;

  /// Shadow 4 — Highest emphasis
  /// Key: Offset(0, 8), blurRadius: 16 | Ambient: Offset(0, 16), blurRadius: 32
  static const List<BoxShadow> shadow4 = [
    BoxShadow(
      color: Color(0x1F000000), // ~12% opacity
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
    BoxShadow(
      color: Color(0x26000000), // ~15% opacity
      offset: Offset(0, 16),
      blurRadius: 32,
    ),
  ];
  static const List<BoxShadow> highest = shadow4;

  /// Returns theme-adapted shadows if needed.
  /// In dark mode, shadow opacity is slightly increased so depth remains visible.
  static List<BoxShadow> get(int level, {bool isDark = false}) {
    if (!isDark) {
      switch (level) {
        case 0:
          return shadow0;
        case 1:
          return shadow1;
        case 2:
          return shadow2;
        case 3:
          return shadow3;
        case 4:
          return shadow4;
        default:
          return shadow0;
      }
    } else {
      // Dark mode adapted shadows (slightly stronger alpha for contrast)
      switch (level) {
        case 0:
          return shadow0;
        case 1:
          return const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Color(0x26000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ];
        case 2:
          return const [
            BoxShadow(
              color: Color(0x3D000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ];
        case 3:
          return const [
            BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Color(0x66000000),
              offset: Offset(0, 0),
              blurRadius: 16,
            ),
          ];
        case 4:
          return const [
            BoxShadow(
              color: Color(0x66000000),
              offset: Offset(0, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Color(0x80000000),
              offset: Offset(0, 16),
              blurRadius: 32,
            ),
          ];
        default:
          return shadow0;
      }
    }
  }
}
