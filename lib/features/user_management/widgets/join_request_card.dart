import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/join_request_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';

class JoinRequestCard extends StatelessWidget {
  final JoinRequestModel request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onViewDetails;

  const JoinRequestCard({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: request.isUrgent
                ? AppColors.error.withOpacity(0.3)
                : AppColors.cardBorder,
            width: request.isUrgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // User Avatar
                UserAvatar(
                  name: request.requestingUserName,
                  radius: 20,
                ),

                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requestingUserName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        request.requestingUserEmail,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                StatusBadge(
                  status: request.statusDisplayName,
                  backgroundColor: request.status.color.withOpacity(0.1),
                  textColor: request.status.color,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Request Info Row
            Row(
              children: [
                // Time Info
                Icon(
                  LucideIcons.clock,
                  size: 16,
                  color: request.isUrgent ? AppColors.error : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Requested ${AppHelpers.formatRelativeTime(request.requestedAt)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: request.isUrgent ? AppColors.error : AppColors.textSecondary,
                      fontWeight: request.isUrgent ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),

                // Duration Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.isUrgent
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.formattedPendingDuration,
                    style: AppTextStyles.caption.copyWith(
                      color: request.isUrgent ? AppColors.error : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Urgent Warning
            if (request.isUrgent) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.alertTriangle,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Urgent: Request pending for over 3 days',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Leader Email Info
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.mail,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wants to join team under:',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          request.leaderEmail,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons (only for pending requests)
            if (request.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MinimalButton(
                      text: 'Reject',
                      onPressed: onReject,
                      isOutlined: true,
                      backgroundColor: AppColors.error,
                      textColor: AppColors.error,
                      icon: LucideIcons.xCircle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MinimalButton(
                      text: 'Approve',
                      onPressed: onApprove,
                      backgroundColor: AppColors.success,
                      icon: LucideIcons.checkCircle,
                    ),
                  ),
                ],
              ),
            ],

            // Processed Info (for approved/rejected requests)
            if (request.isActioned) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: request.isApproved
                      ? AppColors.successSurface
                      : AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      request.isApproved ? LucideIcons.checkCircle : LucideIcons.xCircle,
                      size: 16,
                      color: request.isApproved ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.isApproved
                            ? 'Approved ${request.actionedAt != null ? AppHelpers.formatRelativeTime(request.actionedAt!) : ''}'
                            : 'Rejected ${request.actionedAt != null ? AppHelpers.formatRelativeTime(request.actionedAt!) : ''}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: request.isApproved ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Tap to view details hint
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap to view details',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  LucideIcons.chevronRight,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}