import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF4F46E5);       // Indigo 600
  static const Color primaryDark = Color(0xFF4338CA);   // Indigo 700
  static const Color primaryLight = Color(0xFF818CF8);  // Indigo 400
  static const Color secondary = Color(0xFF0EA5E9);     // Sky 500

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);    // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);        // Slate 200

  // Attendance Status Colors (PRD US-E03)
  static const Color present = Color(0xFF10B981);       // Emerald 500
  static const Color presentBg = Color(0xFFECFDF5);     // Emerald 50
  static const Color late = Color(0xFFF59E0B);          // Amber 500
  static const Color lateBg = Color(0xFFFFFBEB);        // Amber 50
  static const Color halfDay = Color(0xFF8B5CF6);       // Purple 500
  static const Color halfDayBg = Color(0xFFF5F3FF);     // Purple 50
  static const Color absent = Color(0xFFEF4444);        // Rose 500
  static const Color absentBg = Color(0xFFFEF2F2);      // Rose 50

  // Geofence Radar
  static const Color geofenceActive = Color(0xFF10B981);
  static const Color geofenceInactive = Color(0xFF94A3B8);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8);     // Slate 400
}
