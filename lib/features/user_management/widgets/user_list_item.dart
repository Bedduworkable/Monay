import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onPromote;
  final VoidCallback? onRenew;
  final VoidCallback? onDeactivate;
  final bool isCompact;

  const UserListItem({
    super.key,
    required this.user,
    this.onTap,
    this.onPromote,
    this.onRenew,
    this.onDeactivate,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: user.isExpiringSoon
                ? AppColors.warning.withOpacity(0.3)
                : AppColors.cardBorder,
            width: user.isExpiringSoon ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
      ),
    );
  }

  Widget _buildFullLayout() {
    final roleColor = AppHelpers.getRoleColor(user.role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with avatar and status
        Row(
          children: [
            UserAvatar(
              name: user.name,
              radius: 24,
              backgroundColor: roleColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildStatusIndicator(),
          ],
        ),

        const SizedBox(height: 16),

        // Role Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: roleColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(),
                size: 14,
                color: roleColor,
              ),
              const SizedBox(width: 6),
              Text(
                user.displayRole,
                style: AppTextStyles.labelSmall.copyWith(
                  color: roleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Account Info
        _buildAccountInfo(),

        const SizedBox(height: 16),

        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildCompactLayout() {
    final roleColor = AppHelpers.getRoleColor(user.role);

    return Row(
      children: [
        // Avatar
        UserAvatar(
          name: user.name,
          radius: 20,
          backgroundColor: roleColor,
        ),

        const SizedBox(width: 12),

        // Main content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and role row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.displayRole,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: roleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Email and status row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusIndicator(),
                ],
              ),

              const SizedBox(height: 8),

              // Quick info row
              Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Joined ${AppHelpers.formatRelativeTime(user.createdAt)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (user.isExpiringSoon) ...[
                    const SizedBox(width: 12),
                    Icon(
                      LucideIcons.alertTriangle,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires in ${user.daysUntilExpiry} days',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Action menu
        PopupMenuButton<String>(
          onSelected: _handleAction,
          icon: const Icon(
            LucideIcons.moreVertical,
            size: 16,
            color: AppColors.textSecondary,
          ),
          itemBuilder: (context) => _buildMenuItems(),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    if (user.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 12,
              color: AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              'Expired',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else if (user.isExpiringSoon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.clock,
              size: 12,
              color: AppColors.warning,
            ),
            const SizedBox(width: 4),
            Text(
              'Expiring',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.checkCircle,
              size: 12,
              color: AppColors.success,
            ),
            const SizedBox(width: 4),
            Text(
              'Active',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAccountInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Created date
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Joined ${AppHelpers.formatDate(user.createdAt)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Expiry info
          if (user.expiresAt != null) ...[
            Row(
              children: [
                Icon(
                  user.isExpiringSoon
                      ? LucideIcons.alertTriangle
                      : LucideIcons.shield,
                  size: 16,
                  color: user.isExpiringSoon
                      ? AppColors.warning
                      : AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.isExpired
                        ? 'Expired on ${AppHelpers.formatDate(user.expiresAt!)}'
                        : user.isExpiringSoon
                        ? 'Expires in ${user.daysUntilExpiry} days'
                        : 'Valid until ${AppHelpers.formatDate(user.expiresAt!)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: user.isExpired
                          ? AppColors.error
                          : user.isExpiringSoon
                          ? AppColors.warning
                          : AppColors.textSecondary,
                      fontWeight: user.isExpiringSoon ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Primary action based on user state
        if (user.isUser && onPromote != null)
          Expanded(
            child: MinimalButton(
              text: 'Promote',
              onPressed: onPromote,
              icon: LucideIcons.arrowUp,
              backgroundColor: AppColors.primary,
            ),
          )
        else if (user.isExpiringSoon && onRenew != null)
          Expanded(
            child: MinimalButton(
              text: 'Renew',
              onPressed: onRenew,
              icon: LucideIcons.calendar,
              backgroundColor: AppColors.success,
            ),
          )
        else
          Expanded(
            child: MinimalButton(
              text: 'View Details',
              onPressed: onTap,
              icon: LucideIcons.eye,
              isOutlined: true,
            ),
          ),

        const SizedBox(width: 8),

        // Menu button
        PopupMenuButton<String>(
          onSelected: _handleAction,
          icon: Icon(
            LucideIcons.moreHorizontal,
            color: AppColors.textSecondary,
          ),
          itemBuilder: (context) => _buildMenuItems(),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    // View details
    items.add(const PopupMenuItem(
      value: 'view',
      child: Row(
        children: [
          Icon(LucideIcons.eye, size: 16),
          SizedBox(width: 8),
          Text('View Details'),
        ],
      ),
    ));

    // Role-specific actions
    if (user.isUser) {
      items.add(const PopupMenuItem(
        value: 'promote',
        child: Row(
          children: [
            Icon(LucideIcons.arrowUp, size: 16, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Promote to Class Leader'),
          ],
        ),
      ));
    }

    // Renewal action
    if (user.expiresAt != null) {
      items.add(const PopupMenuItem(
        value: 'renew',
        child: Row(
          children: [
            Icon(LucideIcons.calendar, size: 16, color: AppColors.success),
            SizedBox(width: 8),
            Text('Renew Account'),
          ],
        ),
      ));
    }

    // Separator
    items.add(const PopupMenuDivider());

    // Deactivate
    items.add(const PopupMenuItem(
      value: 'deactivate',
      child: Row(
        children: [
          Icon(LucideIcons.userX, size: 16, color: AppColors.error),
          SizedBox(width: 8),
          Text('Deactivate', style: TextStyle(color: AppColors.error)),
        ],
      ),
    ));

    return items;
  }

  void _handleAction(String action) {
    switch (action) {
      case 'view':
        onTap?.call();
        break;
      case 'promote':
        onPromote?.call();
        break;
      case 'renew':
        onRenew?.call();
        break;
      case 'deactivate':
        onDeactivate?.call();
        break;
    }
  }

  IconData _getRoleIcon() {
    switch (user.role) {
      case UserRole.admin:
        return LucideIcons.crown;
      case UserRole.leader:
        return LucideIcons.users;
      case UserRole.classLeader:
        return LucideIcons.userCheck;
      case UserRole.user:
        return LucideIcons.headphones;
    }
  }
}