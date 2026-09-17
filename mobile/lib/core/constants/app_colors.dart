import 'package:flutter/material.dart';

class AppColors {
  // UX4G Government Primary Palette
  static const Color primary = Color(0xFF0B4D8C);       // UX4G Deep Civic Blue
  static const Color primaryDark = Color(0xFF083664);   // Navy 800
  static const Color primaryLight = Color(0xFF135BB4);  // Civic Blue 500
  static const Color secondary = Color(0xFFE05A1B);     // UX4G Saffron Accent
  static const Color secondaryLight = Color(0xFFFF9933);// National Saffron

  // Background & Surface
  static const Color background = Color(0xFFF4F6F9);    // UX4G Canvas Grey
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFDDE2E5);        // WCAG 3:1 Boundary Border

  // High Contrast Mode Colors (GIGW AAA)
  static const Color hcBackground = Color(0xFF121212);
  static const Color hcSurface = Color(0xFF1E1E1E);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcHighlight = Color(0xFFFFFF00);    // High-contrast Yellow
  static const Color hcBorder = Color(0xFFFFFF00);

  // Attendance Status Colors (PRD US-E03 & GIGW AA)
  static const Color present = Color(0xFF13795B);       // UX4G Success Green
  static const Color presentBg = Color(0xFFE8F5EE);
  static const Color late = Color(0xFFC47400);          // UX4G Warning Amber
  static const Color lateBg = Color(0xFFFFF8E7);
  static const Color halfDay = Color(0xFF63329D);       // UX4G Info Purple
  static const Color halfDayBg = Color(0xFFF4EBFD);
  static const Color absent = Color(0xFFC5221F);        // UX4G Danger Red
  static const Color absentBg = Color(0xFFFCE8E6);

  // Geofence Radar
  static const Color geofenceActive = Color(0xFF13795B);
  static const Color geofenceInactive = Color(0xFF64748B);

  // Text (WCAG 2.1 AA Compliant >= 4.5:1 on light backgrounds)
  static const Color textPrimary = Color(0xFF1E293B);   // Slate 800
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF64748B);     // Slate 500
}
