// This file is a placeholder for a custom app bar widget.
// The core AppBar theming is handled in lib/core/theme/app_theme.dart,
// and specific app bar implementations can be found in individual screen files
// or within the DashboardLayout (lib/features/dashboard/widgets/dashboard_layout.dart).

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// Example of how a CustomAppBar might be structured if it were a standalone widget.
// For this project, AppBar functionality is largely integrated into screen appBars
// or the DashboardLayout's top bar.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
      leading: leading,
      actions: actions,
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: centerTitle,
      // You can add more styling here from AppTheme
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}