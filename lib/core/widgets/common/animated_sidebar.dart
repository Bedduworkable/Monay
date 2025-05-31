// This file is a placeholder for an animated sidebar widget.
// The core sidebar functionality is largely integrated into DashboardLayout
// (lib/features/dashboard/widgets/dashboard_layout.dart).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// Example of how an AnimatedSidebar might be structured if it were a standalone widget.
// For this project, the sidebar's animation and state are managed within DashboardLayout.
class AnimatedSidebar extends StatelessWidget {
  final bool isExpanded;
  final Widget child;

  const AnimatedSidebar({
    super.key,
    required this.isExpanded,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 280 : 72,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: child,
    );
  }
}