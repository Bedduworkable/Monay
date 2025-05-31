// This file is a placeholder for a RenewalCard widget.
// This widget would typically display information about a user's account renewal status,
// especially useful for leaders to see expiring team members.

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/user_model.dart'; //
import '../../core/theme/app_colors.dart'; //
import '../../core/theme/app_text_styles.dart'; //
import '../../core/theme/custom_widgets.dart'; // For UserAvatar, MinimalButton, StatusBadge
import '../../core/utils/helpers.dart'; // For AppHelpers

class RenewalCard extends StatelessWidget {
  final UserModel user; //
  final VoidCallback? onRenew;
  final VoidCallback? onViewDetails;

  const RenewalCard({
    super.key,
    required this.user, //
    this.onRenew,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpired = user.isExpired; //
    final bool isExpiringSoon = user.isExpiringSoon; //
    final Color statusColor = isExpired
        ? AppColors.error //
        : (isExpiringSoon ? AppColors.warning : AppColors.success); //
    final IconData statusIcon = isExpired
        ? LucideIcons.alertCircle //
        : (isExpiringSoon ? LucideIcons.clock : LucideIcons.checkCircle); //

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2, //
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1.5), //
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12), //
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                    name: user.name, //
                    radius: 24,
                    backgroundColor: AppHelpers.getRoleColor(user.role), //
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name, //
                          style: AppTextStyles.titleMedium.copyWith( //
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.email, //
                          style: AppTextStyles.bodySmall.copyWith( //
                            color: AppColors.textSecondary, //
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(statusIcon, color: statusColor, size: 28), //
                ],
              ),
              const Divider(height: 24), //
              _buildInfoRow(
                'Role',
                user.displayRole, //
                AppHelpers.getRoleIcon(user.role), //
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Joined',
                AppHelpers.formatDate(user.createdAt), //
                LucideIcons.calendar, //
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Expiry Date',
                user.expiresAt != null //
                    ? AppHelpers.formatDate(user.expiresAt!) //
                    : 'N/A',
                LucideIcons.calendarX, //
                valueColor: statusColor, //
                isBoldValue: true,
              ),
              if (isExpiringSoon || isExpired) ...[ //
                const SizedBox(height: 16),
                Center(
                  child: MinimalButton( //
                    text: isExpired ? 'Renew Now' : 'Renew Account',
                    onPressed: onRenew,
                    icon: LucideIcons.refreshCw, //
                    backgroundColor: statusColor, //
                    textColor: AppColors.textOnPrimary, //
                    width: double.infinity,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor, bool isBoldValue = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary), //
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary), //
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith( //
              color: valueColor ?? AppColors.textPrimary, //
              fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}