import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Base Text Style with Inter Font
  static TextStyle get _baseTextStyle => GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.normal,
  );

  // Display Styles (Large Headlines)
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // Headline Styles
  static TextStyle get headlineLarge => _baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static TextStyle get headlineMedium => _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get headlineSmall => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // Title Styles
  static TextStyle get titleLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static TextStyle get titleSmall => _baseTextStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Body Styles
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Label Styles
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // Button Styles
  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get buttonMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get buttonSmall => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Specialized Styles
  static TextStyle get caption => _baseTextStyle.copyWith(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static TextStyle get overline => _baseTextStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Dashboard-specific Styles
  static TextStyle get metricValue => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get metricLabel => _baseTextStyle.copyWith(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle get sidebarItem => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.sidebarItemText,
    height: 1.4,
  );

  static TextStyle get sidebarItemActive => sidebarItem.copyWith(
    color: AppColors.sidebarItemActiveText,
    fontWeight: FontWeight.w600,
  );

  // Form Styles
  static TextStyle get inputLabel => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get inputText => _baseTextStyle.copyWith(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get inputHint => _baseTextStyle.copyWith(
    fontSize: 14,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  static TextStyle get inputError => _baseTextStyle.copyWith(
    fontSize: 12,
    color: AppColors.error,
    height: 1.3,
  );

  // Status Styles
  static TextStyle get statusText => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Role-based Styles
  static TextStyle get roleAdmin => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.adminColor,
    height: 1.2,
  );

  static TextStyle get roleLeader => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.leaderColor,
    height: 1.2,
  );

  static TextStyle get roleClassLeader => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.classLeaderColor,
    height: 1.2,
  );

  static TextStyle get roleUser => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.userColor,
    height: 1.2,
  );

  // Helper Methods
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}