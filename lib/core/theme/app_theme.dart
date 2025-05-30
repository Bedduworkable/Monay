import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      dialogTheme: _dialogTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      drawerTheme: _drawerTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
      listTileTheme: _listTileTheme,
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      tabBarTheme: _tabBarTheme,
      tooltipTheme: _tooltipTheme,
      snackBarTheme: _snackBarTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      scaffoldBackgroundColor: AppColors.background,
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColors.neutral900,
    );
  }

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primarySurface,
    secondary: AppColors.neutral600,
    secondaryContainer: AppColors.neutral100,
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
    errorContainer: AppColors.errorSurface,
    onPrimary: AppColors.textOnPrimary,
    onPrimaryContainer: AppColors.primary,
    onSecondary: AppColors.textOnPrimary,
    onSecondaryContainer: AppColors.neutral600,
    onSurface: AppColors.textPrimary,
    onBackground: AppColors.textPrimary,
    onError: AppColors.textOnPrimary,
    onErrorContainer: AppColors.error,
    outline: AppColors.border,
    shadow: AppColors.cardShadow,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.neutral400,
    secondaryContainer: AppColors.neutral800,
    surface: AppColors.neutral800,
    background: AppColors.neutral900,
    error: AppColors.errorLight,
    errorContainer: AppColors.errorDark,
    onPrimary: AppColors.neutral900,
    onPrimaryContainer: AppColors.primaryLight,
    onSecondary: AppColors.neutral900,
    onSecondaryContainer: AppColors.neutral400,
    onSurface: AppColors.neutral100,
    onBackground: AppColors.neutral100,
    onError: AppColors.neutral900,
    onErrorContainer: AppColors.errorLight,
    outline: AppColors.neutral600,
    shadow: Colors.black26,
  );

  static TextTheme get _textTheme => TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    displaySmall: AppTextStyles.displaySmall,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );

  static AppBarTheme get _appBarTheme => AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.surface,
    surfaceTintColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    titleTextStyle: AppTextStyles.headlineSmall,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.buttonMedium,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: AppTextStyles.buttonMedium,
      foregroundColor: AppColors.primary,
    ),
  );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppColors.border),
          textStyle: AppTextStyles.buttonMedium,
          foregroundColor: AppColors.textPrimary,
        ),
      );

  static InputDecorationTheme get _inputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.inputHint,
        errorStyle: AppTextStyles.inputError,
      );

  static CardTheme get _cardTheme => CardTheme(
    elevation: 0,
    color: AppColors.cardBackground,
    shadowColor: AppColors.cardShadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.cardBorder, width: 1),
    ),
    margin: const EdgeInsets.all(8),
  );

  static DialogTheme get _dialogTheme => DialogTheme(
    elevation: 8,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    titleTextStyle: AppTextStyles.headlineSmall,
    contentTextStyle: AppTextStyles.bodyMedium,
  );

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
      );

  static DrawerThemeData get _drawerTheme => DrawerThemeData(
    backgroundColor: AppColors.sidebarBackground,
    elevation: 0,
    shape: const RoundedRectangleBorder(),
    width: 280,
  );

  static ChipThemeData get _chipTheme => ChipThemeData(
    backgroundColor: AppColors.neutral100,
    selectedColor: AppColors.primarySurface,
    labelStyle: AppTextStyles.labelMedium,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );

  static DividerThemeData get _dividerTheme => const DividerThemeData(
    color: AppColors.border,
    thickness: 1,
    space: 1,
  );

  static ListTileThemeData get _listTileTheme => ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    titleTextStyle: AppTextStyles.bodyMedium,
    subtitleTextStyle: AppTextStyles.caption,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static SwitchThemeData get _switchTheme => SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.textOnPrimary;
      }
      return AppColors.neutral400;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.neutral200;
    }),
  );

  static CheckboxThemeData get _checkboxTheme => CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(AppColors.textOnPrimary),
    side: const BorderSide(color: AppColors.border, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );

  static RadioThemeData get _radioTheme => RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.neutral400;
    }),
  );

  static TabBarTheme get _tabBarTheme => TabBarTheme(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    labelStyle: AppTextStyles.labelLarge,
    unselectedLabelStyle: AppTextStyles.labelLarge,
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  static TooltipThemeData get _tooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.neutral800,
      borderRadius: BorderRadius.circular(6),
    ),
    textStyle: AppTextStyles.caption.copyWith(
      color: AppColors.textOnPrimary,
    ),
  );

  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
    backgroundColor: AppColors.neutral800,
    contentTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textOnPrimary,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
  );

  static ProgressIndicatorThemeData get _progressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: AppColors.neutral200,
      );
}