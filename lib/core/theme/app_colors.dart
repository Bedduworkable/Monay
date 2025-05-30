import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB); // Professional Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySurface = Color(0xFFEBF4FF);

  // Neutral Colors (Monday.com inspired)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);

  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEF2F2);

  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // Status Colors for Leads
  static const Color statusNew = Color(0xFF8B5CF6); // Purple
  static const Color statusContacted = Color(0xFF06B6D4); // Cyan
  static const Color statusFollowUp = Color(0xFFF59E0B); // Amber
  static const Color statusConverted = Color(0xFF10B981); // Green
  static const Color statusLost = Color(0xFFEF4444); // Red

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFFAFAFA);
  static const Color backgroundTertiary = Color(0xFFF5F5F5);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFAFAFA);
  static const Color surfaceTertiary = Color(0xFFF5F5F5);

  // Border Colors
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color borderDark = Color(0xFFD4D4D4);

  // Text Colors
  static const Color textPrimary = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF525252);
  static const Color textTertiary = Color(0xFF737373);
  static const Color textDisabled = Color(0xFFA3A3A3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Sidebar Colors
  static const Color sidebarBackground = Color(0xFFFAFAFA);
  static const Color sidebarItemHover = Color(0xFFF5F5F5);
  static const Color sidebarItemActive = Color(0xFFEBF4FF);
  static const Color sidebarItemText = Color(0xFF525252);
  static const Color sidebarItemActiveText = Color(0xFF2563EB);

  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E5E5);
  static const Color cardShadow = Color(0x0F000000);

  // Dashboard Metric Colors
  static const List<Color> chartColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF84CC16), // Lime
  ];

  // Role-specific Colors
  static const Color adminColor = Color(0xFF7C3AED); // Purple
  static const Color leaderColor = Color(0xFF2563EB); // Blue
  static const Color classLeaderColor = Color(0xFF059669); // Green
  static const Color userColor = Color(0xFF0891B2); // Sky

  // Helper Methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return statusNew;
      case 'contacted':
        return statusContacted;
      case 'follow up':
      case 'follow-up':
      case 'callback':
        return statusFollowUp;
      case 'converted':
      case 'won':
        return statusConverted;
      case 'lost':
      case 'rejected':
        return statusLost;
      default:
        return neutral400;
    }
  }

  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return adminColor;
      case 'leader':
        return leaderColor;
      case 'classleader':
      case 'class leader':
        return classLeaderColor;
      case 'user':
      case 'telecaller':
        return userColor;
      default:
        return neutral400;
    }
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAFAFA),
    ],
  );
}