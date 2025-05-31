// This file is a placeholder for a loading indicator widget.
// The core loading indicator functionality is handled in lib/core/theme/custom_widgets.dart
// (e.g., MinimalLoader).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

// Example of how a LoadingIndicator might be structured if it were a standalone widget.
// For this project, loading indicator functionality is largely integrated into MinimalLoader.
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? AppColors.primary,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: 1000.ms);
  }
}