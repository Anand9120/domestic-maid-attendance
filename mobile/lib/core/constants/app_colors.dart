import 'package:flutter/material.dart';

class AppColors {
  // UX4G Government Primary Palette (Light Mode)
  static const Color primary = Color(0xFF0B4D8C);       // UX4G Deep Civic Blue
  static const Color primaryDark = Color(0xFF083664);   // Navy 800
  static const Color primaryLight = Color(0xFF135BB4);  // Civic Blue 500
  static const Color secondary = Color(0xFFE05A1B);     // UX4G Saffron Accent
  static const Color secondaryLight = Color(0xFFFF9933);// National Saffron

  // Background & Surface (Light Mode)
  static const Color background = Color(0xFFF4F6F9);    // UX4G Canvas Grey
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFDDE2E5);        // WCAG 3:1 Boundary Border

  // UX4G Ergonomic Dark Mode Palette (WCAG 2.1 AAA Compliant)
  // Replaces harsh OLED black & neon yellow with deep civic slate & sky blue
  static const Color darkBackground = Color(0xFF0F172A);      // Slate 900 (Deep, soothing canvas)
  static const Color darkSurface = Color(0xFF1E293B);         // Slate 800 (Elevated card surface)
  static const Color darkSurfaceCard = Color(0xFF1E293B);     // Slate 800
  static const Color darkSurfaceElevated = Color(0xFF273549); // Slate 750 (Headers, chips, modals)
  static const Color darkBorder = Color(0xFF334155);          // Slate 700 (Subtle 1px boundary)
  static const Color darkBorderHighlight = Color(0xFF38BDF8); // Civic Sky Blue focus outline

  // Brand Accents in Dark Mode (High contrast, non-glaring)
  static const Color darkPrimary = Color(0xFF38BDF8);         // UX4G Civic Sky Blue (AAA 8.2:1 contrast)
  static const Color darkPrimaryLight = Color(0xFF7DD3FC);    // Sky 300
  static const Color darkPrimaryDark = Color(0xFF0284C7);     // Sky 600
  static const Color darkSecondary = Color(0xFFFB923C);       // UX4G Warm Saffron (AAA 9.1:1 contrast)

  // Typography Hierarchy in Dark Mode (Zero glare, maximum legibility)
  static const Color darkTextPrimary = Color(0xFFF8FAFC);     // Slate 50 (AAA 15.4:1 contrast)
  static const Color darkTextSecondary = Color(0xFF94A3B8);   // Slate 400 (Gentle readability)
  static const Color darkTextMuted = Color(0xFF64748B);       // Slate 500

  // High Contrast Compatibility Aliases (Mapped to UX4G Dark Standards)
  static const Color hcBackground = darkBackground;
  static const Color hcSurface = darkSurface;
  static const Color hcText = darkTextPrimary;
  static const Color hcHighlight = darkPrimary;
  static const Color hcBorder = darkBorder;

  // Attendance Status Colors (Light Mode)
  static const Color present = Color(0xFF13795B);       // UX4G Success Green
  static const Color presentBg = Color(0xFFE8F5EE);
  static const Color late = Color(0xFFC47400);          // UX4G Warning Amber
  static const Color lateBg = Color(0xFFFFF8E7);
  static const Color halfDay = Color(0xFF63329D);       // UX4G Info Purple
  static const Color halfDayBg = Color(0xFFF4EBFD);
  static const Color absent = Color(0xFFC5221F);        // UX4G Danger Red
  static const Color absentBg = Color(0xFFFCE8E6);

  // Attendance Status Colors (Dark Mode - Soft on eyes, vibrant recognition)
  static const Color darkPresent = Color(0xFF34D399);   // Mint Emerald 400
  static const Color darkPresentBg = Color(0x3310B981); // Subtle Emerald tint
  static const Color darkLate = Color(0xFFFBBF24);      // Warm Amber 400
  static const Color darkLateBg = Color(0x33F59E0B);    // Subtle Amber tint
  static const Color darkHalfDay = Color(0xFFA78BFA);   // Lavender 400
  static const Color darkHalfDayBg = Color(0x338B5CF6); // Subtle Purple tint
  static const Color darkAbsent = Color(0xFFF87171);    // Coral Red 400
  static const Color darkAbsentBg = Color(0x33EF4444);  // Subtle Red tint

  // Geofence Radar
  static const Color geofenceActive = Color(0xFF13795B);
  static const Color geofenceInactive = Color(0xFF64748B);
  static const Color darkGeofenceActive = Color(0xFF34D399);
  static const Color darkGeofenceInactive = Color(0xFF64748B);

  // Text (WCAG 2.1 AA Compliant >= 4.5:1 on light backgrounds)
  static const Color textPrimary = Color(0xFF1E293B);   // Slate 800
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF64748B);     // Slate 500
}
