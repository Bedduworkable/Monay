import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/lead_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';

class RemarksSection extends StatelessWidget {
  final List<RemarkModel> remarks;
  final Function(String) onAddRemark;

  const RemarksSection({
    super.key,
    required this.remarks,
    required this.onAddRemark,
  });

  @override
  Widget build(BuildContext context) {
    if (remarks.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: LucideIcons.messageSquare,
          title: 'No Remarks Yet',
          subtitle: 'Add remarks to track interactions and notes about this lead',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: remarks.length,
      itemBuilder: (context, index) {
        final remark = remarks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRemarkCard(remark)
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 50).ms)
              .slideX(begin: -0.3, duration: 300.ms),
        );
      },
    );
  }

  Widget _buildRemarkCard(RemarkModel remark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and timestamp
          Row(
            children: [
              UserAvatar(
                name: remark.byName,
                radius: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remark.byName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppHelpers.formatRelativeTime(remark.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.messageCircle,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Remark content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              remark.text,
              style: AppTextStyles.bodyMedium,
            ),
          ),

          const SizedBox(height: 8),

          // Footer with exact timestamp
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 12,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                AppHelpers.formatDateTime(remark.createdAt),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}