import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; //
import 'package:flutter_animate/flutter_animate.dart'; //

import '../../../core/theme/app_colors.dart'; //
import '../../../core/theme/app_text_styles.dart'; //
import '../../../core/theme/custom_widgets.dart'; // For SectionHeader, MinimalLoader
import '../../../core/utils/helpers.dart'; // For AppHelpers

class QuickActionsSection extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> actions; // Expects [{ 'title': 'Add Lead', 'icon': 'plus', 'action': 'add_lead', 'badge': null }]
  final bool isLoading;
  final Function(String)? onActionTap;

  const QuickActionsSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
    this.isLoading = false,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildContainer(
        const Center(child: MinimalLoader()), //
      );
    }

    if (actions.isEmpty) {
      return _buildContainer(
        const EmptyState( //
          icon: LucideIcons.mousePointerClick, //
          title: 'No Quick Actions Available',
          subtitle: 'Actions relevant to your role will appear here.',
        ),
      );
    }

    return _buildContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader( //
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => _buildActionItem(action)).toList(),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms); //
  }

  Widget _buildContainer(Widget content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, //
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder), //
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow, //
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildActionItem(Map<String, dynamic> action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onActionTap?.call(action['action'] as String),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary, //
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border), //
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1), //
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconFromString(action['icon'] as String),
                  color: AppColors.primary, //
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action['title'] as String,
                      style: AppTextStyles.bodyMedium.copyWith( //
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (action['badge'] != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error, //
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${action['badge']}',
                          style: AppTextStyles.labelSmall.copyWith( //
                            color: AppColors.textOnPrimary, //
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight, //
                color: AppColors.textSecondary, //
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'plus':
        return LucideIcons.plus;
      case 'clock':
        return LucideIcons.clock;
      case 'bar_chart_2':
        return LucideIcons.barChart2;
      case 'trending_up':
        return LucideIcons.trendingUp;
      case 'share':
        return LucideIcons.share;
      case 'user_plus':
        return LucideIcons.userPlus;
      case 'user_check':
        return LucideIcons.userCheck;
      case 'users':
        return LucideIcons.users;
      case 'settings':
        return LucideIcons.settings;
      case 'bar_chart':
        return LucideIcons.barChart;
      case 'edit':
        return LucideIcons.edit;
      default:
        return LucideIcons.zap; // A default icon in case of unknown string
    }
  }
}