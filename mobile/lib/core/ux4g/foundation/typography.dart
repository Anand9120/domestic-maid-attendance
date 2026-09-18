// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, deprecated_member_use
import 'package:flutter/material.dart';

class Ux4gTypography extends ThemeExtension<Ux4gTypography> {
  // Header
  final TextStyle hXXS_default;
  final TextStyle hXXS_strong;
  final TextStyle hXS_default;
  final TextStyle hXS_strong;
  final TextStyle hS_default;
  final TextStyle hS_strong;
  final TextStyle hM_default;
  final TextStyle hM_strong;
  final TextStyle hL_default;
  final TextStyle hL_strong;
  final TextStyle hXL_default;
  final TextStyle hXL_strong;
  final TextStyle hXXL_default;
  final TextStyle hXXL_strong;

  // Display
  final TextStyle dXS_default;
  final TextStyle dXS_strong;
  final TextStyle dS_default;
  final TextStyle dS_strong;
  final TextStyle dM_default;
  final TextStyle dM_strong;
  final TextStyle dL_default;
  final TextStyle dL_strong;

  // Body
  final TextStyle bXS_default;
  final TextStyle bXS_strong;
  final TextStyle bS_default;
  final TextStyle bS_strong;
  final TextStyle bM_default;
  final TextStyle bM_strong;
  final TextStyle bL_default;
  final TextStyle bL_strong;

  // Label
  final TextStyle lS_default;
  final TextStyle lS_strong;
  final TextStyle lM_default;
  final TextStyle lM_strong;
  final TextStyle lL_default;
  final TextStyle lL_strong;
  final TextStyle lXL_default;
  final TextStyle lXL_strong;

  // Title
  final TextStyle tS_default;
  final TextStyle tS_strong;
  final TextStyle tM_default;
  final TextStyle tM_strong;
  final TextStyle tL_default;
  final TextStyle tL_strong;

  const Ux4gTypography({
    required this.hXXS_default,
    required this.hXXS_strong,
    required this.hXS_default,
    required this.hXS_strong,
    required this.hS_default,
    required this.hS_strong,
    required this.hM_default,
    required this.hM_strong,
    required this.hL_default,
    required this.hL_strong,
    required this.hXL_default,
    required this.hXL_strong,
    required this.hXXL_default,
    required this.hXXL_strong,
    required this.dXS_default,
    required this.dXS_strong,
    required this.dS_default,
    required this.dS_strong,
    required this.dM_default,
    required this.dM_strong,
    required this.dL_default,
    required this.dL_strong,
    required this.bXS_default,
    required this.bXS_strong,
    required this.bS_default,
    required this.bS_strong,
    required this.bM_default,
    required this.bM_strong,
    required this.bL_default,
    required this.bL_strong,
    required this.lS_default,
    required this.lS_strong,
    required this.lM_default,
    required this.lM_strong,
    required this.lL_default,
    required this.lL_strong,
    required this.lXL_default,
    required this.lXL_strong,
    required this.tS_default,
    required this.tS_strong,
    required this.tM_default,
    required this.tM_strong,
    required this.tL_default,
    required this.tL_strong,
  });

  @override
  ThemeExtension<Ux4gTypography> copyWith() => this; // Simplified for brevity, usually you'd implement this properly

  @override
  ThemeExtension<Ux4gTypography> lerp(
    ThemeExtension<Ux4gTypography>? other,
    double t,
  ) {
    if (other is! Ux4gTypography) return this;
    return other; // Simplified
  }
}

// Default Typography Implementation
final defaultUx4gTypography = Ux4gTypography(
  hXXS_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 16 / 14,
  ),
  hXXS_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 16 / 14,
  ),
  hXS_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 20 / 16,
  ),
  hXS_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 20 / 16,
  ),
  hS_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 24 / 20,
  ),
  hS_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 24 / 20,
  ),
  hM_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 28 / 24,
  ),
  hM_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 28 / 24,
  ),
  hL_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 32 / 28,
  ),
  hL_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 32 / 28,
  ),
  hXL_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 36 / 32,
  ),
  hXL_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 36 / 32,
  ),
  hXXL_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 40,
    height: 44 / 40,
  ),
  hXXL_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 40,
    height: 44 / 40,
  ),

  dXS_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 36,
    height: 44 / 36,
  ),
  dXS_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 36,
    height: 44 / 36,
  ),
  dS_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 40,
    height: 52 / 40,
  ),
  dS_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 40,
    height: 52 / 40,
  ),
  dM_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 52,
    height: 72 / 52,
  ),
  dM_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 52,
    height: 72 / 52,
  ),
  dL_default: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 60,
    height: 80 / 60,
  ),
  dL_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 60,
    height: 80 / 60,
  ),

  bXS_default: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 14 / 11,
  ),
  bXS_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 14 / 11,
  ),
  bS_default: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
  ),
  bS_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
  ),
  bM_default: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 18 / 14,
  ),
  bM_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 18 / 14,
  ),
  bL_default: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 20 / 16,
  ),
  bL_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 20 / 16,
  ),

  lS_default: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 14 / 11,
  ),
  lS_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 14 / 11,
  ),
  lM_default: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
  ),
  lM_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
  ),
  lL_default: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 18 / 14,
  ),
  lL_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 18 / 14,
  ),
  lXL_default: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 20 / 16,
  ),
  lXL_strong: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 20 / 16,
  ),

  tS_default: const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
  ),
  tS_strong: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
  ),
  tM_default: const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
  ),
  tM_strong: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 24 / 16,
  ),
  tL_default: const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 24 / 18,
  ),
  tL_strong: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 24 / 18,
  ),
);
