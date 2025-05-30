import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/lead_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isCompact;

  const LeadCard({
    super.key,
    required this.lead,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
      ),
    );
  }

  Widget _buildFullLayout() {
    final statusColor = AppHelpers.getStatusColor(lead.status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and selection
          Row(
            children: [
              Expanded(
                child: StatusBadge(
                  status: lead.status,
                  backgroundColor: statusColor.withOpacity(0.1),
                  textColor: statusColor,
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    color: AppColors.textOnPrimary,
                    size: 16,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            lead.leadTitle,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Client Info
          Row(
            children: [
              Icon(
                LucideIcons.user,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lead.clientName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Budget (if available)
          if (lead.budget != null) ...[
            Row(
              children: [
                Icon(
                  LucideIcons.indianRupee,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  AppHelpers.formatNumber(lead.budget!),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Bottom row with time and indicators
          Row(
            children: [
              // Time ago
              Expanded(
                child: Text(
                  AppHelpers.formatRelativeTime(lead.updatedAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),

              // Follow-up indicator
              if (lead.hasFollowUpDue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: lead.isFollowUpOverdue
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: lead.isFollowUpOverdue
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lead.isFollowUpOverdue ? 'Overdue' : 'Due',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: lead.isFollowUpOverdue
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),

              // Remarks indicator
              if (lead.remarkCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.messageCircle,
                        size: 12,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lead.remarkCount}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout() {
    final statusColor = AppHelpers.getStatusColor(lead.status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Selection indicator
          if (isSelected)
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.check,
                color: AppColors.textOnPrimary,
                size: 16,
              ),
            ),

          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and status row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lead.leadTitle,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusBadge(
                      status: lead.status,
                      backgroundColor: statusColor.withOpacity(0.1),
                      textColor: statusColor,
                      fontSize: 10,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Client and budget row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.user,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lead.clientName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (lead.budget != null) ...[
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.indianRupee,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppHelpers.formatNumber(lead.budget!),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Bottom info row
                Row(
                  children: [
                    // Time
                    Expanded(
                      child: Text(
                        AppHelpers.formatRelativeTime(lead.updatedAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),

                    // Indicators
                    if (lead.hasFollowUpDue) ...[
                      Icon(
                        LucideIcons.clock,
                        size: 14,
                        color: lead.isFollowUpOverdue
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                    ],

                    if (lead.remarkCount > 0) ...[
                      Icon(
                        LucideIcons.messageCircle,
                        size: 14,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lead.remarkCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action indicator
          Icon(
            LucideIcons.chevronRight,
            size: 16,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}