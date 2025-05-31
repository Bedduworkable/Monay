import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart'; // For AppHelpers
import '../../../core/utils/enums.dart'; // For NotificationType enum

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Mock data for notifications
  final List<Map<String, dynamic>> _mockNotifications = [
    {
      'id': '1',
      'type': NotificationType.leadAssigned,
      'title': 'New Lead Assigned!',
      'message': 'Lead "Client Name - Project X" has been assigned to you.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
      'actionData': {'leadId': 'lead123'},
    },
    {
      'id': '2',
      'type': NotificationType.followupDue,
      'title': 'Follow-up Due Today',
      'message': 'Lead "Property Type - Client" requires a follow-up today.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'actionData': {'leadId': 'lead456'},
    },
    {
      'id': '3',
      'type': NotificationType.joinRequest,
      'title': 'New Join Request',
      'message': 'John Doe (john.doe@example.com) has requested to join your team.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'actionData': {'requestId': 'req789'},
    },
    {
      'id': '4',
      'type': NotificationType.accountExpiry,
      'title': 'Account Expiring Soon',
      'message': 'Your account expires in 7 days. Please contact your leader for renewal.',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': false,
      'actionData': {'screen': 'renewal'},
    },
    {
      'id': '5',
      'type': NotificationType.leadAssigned,
      'title': 'New Lead Assigned!',
      'message': 'Lead "Commercial Property - Investor" has been assigned to you.',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      'isRead': true,
      'actionData': {'leadId': 'lead999'},
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'You must be logged in to view notifications',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, duration: 600.ms),

              const SizedBox(height: 24),

              Expanded(
                child: _mockNotifications.isEmpty
                    ? const EmptyState(
                  icon: LucideIcons.bellOff,
                  title: 'No Notifications',
                  subtitle: 'All caught up! Your notifications will appear here.',
                )
                    : _buildNotificationsList(),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: MinimalLoader())),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(
            LucideIcons.bell,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Notifications'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          onPressed: () {
            // Implement mark all as read
            AppHelpers.showInfoSnackbar(context, 'Mark all as read (coming soon)');
          },
          icon: const Icon(LucideIcons.mailCheck),
          tooltip: 'Mark All as Read',
        ),
        IconButton(
          onPressed: () {
            // Implement refresh
            AppHelpers.showInfoSnackbar(context, 'Refreshing notifications (coming soon)');
          },
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    final unreadCount = _mockNotifications.where((n) => !n['isRead']).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              unreadCount > 0 ? LucideIcons.bellRing : LucideIcons.bell,
              color: AppColors.textOnPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Notifications',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount > 0
                      ? 'You have $unreadCount unread notification${unreadCount > 1 ? 's' : ''}.'
                      : 'You are all caught up! No new notifications.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      itemCount: _mockNotifications.length,
      itemBuilder: (context, index) {
        final notification = _mockNotifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildNotificationItem(notification)
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 50).ms)
              .slideX(begin: -0.3, duration: 300.ms),
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final NotificationType type = notification['type'];
    final bool isRead = notification['isRead'];
    final IconData icon = _getNotificationIcon(type);
    final Color iconColor = _getNotificationColor(type);

    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? AppColors.cardBackground : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? AppColors.cardBorder : AppColors.primary.withOpacity(0.3),
            width: isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                      color: isRead ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isRead ? AppColors.textTertiary : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppHelpers.formatRelativeTime(notification['timestamp']),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            // Unread indicator (if unread)
            if (!isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.leadAssigned:
        return LucideIcons.target;
      case NotificationType.followupDue:
        return LucideIcons.clock;
      case NotificationType.joinRequest:
        return LucideIcons.userPlus;
      case NotificationType.joinRequestApproved:
        return LucideIcons.checkCircle;
      case NotificationType.joinRequestRejected:
        return LucideIcons.xCircle;
      case NotificationType.renewalReminder:
      case NotificationType.accountExpiry:
        return LucideIcons.calendarX;
      default:
        return LucideIcons.bell;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.leadAssigned:
      case NotificationType.joinRequestApproved:
        return AppColors.success;
      case NotificationType.followupDue:
      case NotificationType.renewalReminder:
        return AppColors.warning;
      case NotificationType.joinRequest:
        return AppColors.info;
      case NotificationType.joinRequestRejected:
      case NotificationType.accountExpiry:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Implement navigation based on notification type and actionData
    // For example:
    // if (notification['type'] == NotificationType.leadAssigned) {
    //   context.go('/leads/detail/${notification['actionData']['leadId']}');
    // }
    AppHelpers.showInfoSnackbar(context, 'Notification tapped: ${notification['title']}');
  }
}