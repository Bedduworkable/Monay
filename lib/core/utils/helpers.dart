import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'constants.dart';
import 'enums.dart';

class AppHelpers {
  AppHelpers._();

  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormat).format(time);
  }

  static String formatApiDate(DateTime date) {
    return DateFormat(AppConstants.apiDateFormat).format(date);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  static String formatTimeUntil(DateTime futureDate) {
    final now = DateTime.now();
    final difference = futureDate.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else if (difference.inSeconds > 0) {
      return 'in a few moments';
    } else {
      return 'overdue';
    }
  }

  // Number Formatting
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: symbol,
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static String formatNumber(double number) {
    if (number >= 10000000) {
      // Crores
      return '₹${(number / 10000000).toStringAsFixed(1)}Cr';
    } else if (number >= 100000) {
      // Lakhs
      return '₹${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      // Thousands
      return '₹${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return formatCurrency(number);
    }
  }

  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  static String formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  // String Utilities
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ')
        .map((word) => word.isEmpty ? word : capitalize(word))
        .join(' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  // Color Utilities
  static Color getStatusColor(String status) {
    return AppColors.getStatusColor(status);
  }

  static Color getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.adminColor;
      case UserRole.leader:
        return AppColors.leaderColor;
      case UserRole.classLeader:
        return AppColors.classLeaderColor;
      case UserRole.user:
        return AppColors.userColor;
    }
  }

  static Color getRandomChartColor(int index) {
    return AppColors.chartColors[index % AppColors.chartColors.length];
  }

  // Snackbar Utilities
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Dialog Utilities
  static Future<bool?> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String content,
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
      }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Validation Utilities
  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailRegex).hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(AppConstants.phoneRegex).hasMatch(phone);
  }

  // Date Utilities
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTimeRange getWeekRange(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return DateTimeRange(
      start: getStartOfDay(startOfWeek),
      end: getEndOfDay(endOfWeek),
    );
  }

  static DateTimeRange getMonthRange(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    return DateTimeRange(
      start: getStartOfDay(startOfMonth),
      end: getEndOfDay(endOfMonth),
    );
  }

  // File Utilities
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static String formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }

  // Search Utilities
  static bool matchesSearch(String text, String query) {
    return text.toLowerCase().contains(query.toLowerCase());
  }

  static List<T> filterList<T>(
      List<T> items,
      String query,
      String Function(T) getText,
      ) {
    if (query.isEmpty) return items;
    return items.where((item) => matchesSearch(getText(item), query)).toList();
  }

  // Metrics Utilities
  static double calculateConversionRate(int converted, int total) {
    if (total == 0) return 0.0;
    return (converted / total) * 100;
  }

  static double calculateGrowthRate(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  // Theme Utilities
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Network Utilities
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return AppConstants.networkErrorMessage;
    } else if (error.toString().contains('unauthorized')) {
      return AppConstants.unauthorizedErrorMessage;
    } else {
      return AppConstants.genericErrorMessage;
    }
  }

  // Debug Utilities
  static void debugLog(String message, [String? tag]) {
    if (tag != null) {
      debugPrint('[$tag] $message');
    } else {
      debugPrint(message);
    }
  }
}