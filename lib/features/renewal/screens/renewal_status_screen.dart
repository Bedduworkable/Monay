import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart'; // To get expiring users
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/constants.dart'; // For renewal constants

class RenewalStatusScreen extends ConsumerStatefulWidget {
  const RenewalStatusScreen({super.key});

  @override
  ConsumerState<RenewalStatusScreen> createState() => _RenewalStatusScreenState();
}

class _RenewalStatusScreenState extends ConsumerState<RenewalStatusScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final expiringUsers = ref.watch(expiringUsersProvider);
    final isLoading = ref.watch(userManagementLoadingProvider); // For renewal actions

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'You must be logged in to view renewal status',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(expiringUsersProvider); // Refresh expiring users
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(user.displayRole)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Current User Account Status
                  _buildCurrentUserAccountStatus(user, isLoading)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  if (user.canManageUsers) ...[
                    const SizedBox(height: 24),
                    // Expiring Team Members (for Leaders/Admins)
                    _buildExpiringTeamMembersSection(expiringUsers, isLoading)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.3, duration: 600.ms),
                  ],

                  const SizedBox(height: 24),

                  // Renewal Policy
                  _buildRenewalPolicySection()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms),
                ],
              ),
            ),
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
            LucideIcons.calendarCheck,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Account Renewals'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(expiringUsersProvider),
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(String roleDisplayName) {
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
            child: const Icon(
              LucideIcons.calendarCheck,
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
                  'Account Renewal Status',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage account validity and renewals for your team.',
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

  Widget _buildCurrentUserAccountStatus(UserModel user, bool isLoading) {
    Color statusColor = AppColors.success;
    String statusMessage = 'Your account is active.';
    IconData statusIcon = LucideIcons.checkCircle;

    if (user.isExpired) {
      statusColor = AppColors.error;
      statusMessage = 'Your account has expired on ${AppHelpers.formatDate(user.expiresAt!)}. Please renew to regain access.';
      statusIcon = LucideIcons.alertCircle;
    } else if (user.isExpiringSoon) {
      statusColor = AppColors.warning;
      statusMessage = 'Your account expires in ${user.daysUntilExpiry} days. Please renew soon.';
      statusIcon = LucideIcons.clock;
    }

    return _buildSectionContainer(
      title: 'My Account Status',
      subtitle: 'Your personal account validity information.',
      icon: LucideIcons.user,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current plan valid until: ${user.expiresAt != null ? AppHelpers.formatDate(user.expiresAt!) : 'N/A'}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (user.isExpired || user.isExpiringSoon) ...[
          const SizedBox(height: 16),
          MinimalButton(
            text: 'Contact Leader to Renew',
            onPressed: isLoading ? null : () => _contactLeaderForRenewal(user),
            isLoading: isLoading,
            icon: LucideIcons.mail,
            backgroundColor: AppColors.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildExpiringTeamMembersSection(AsyncValue<List<UserModel>> expiringUsers, bool isLoading) {
    return _buildSectionContainer(
      title: 'Expiring Team Members',
      subtitle: 'Accounts of your team members that are expiring soon.',
      icon: LucideIcons.alertTriangle,
      children: [
        expiringUsers.when(
          data: (users) {
            if (users.isEmpty) {
              return const EmptyState(
                icon: LucideIcons.checkCircle,
                title: 'No Expiring Accounts',
                subtitle: 'All team member accounts are currently valid.',
              );
            }
            return Column(
              children: users.map((user) => _buildExpiringUserItem(user, isLoading)).toList(),
            );
          },
          loading: () => const Center(child: MinimalLoader()),
          error: (error, stack) => EmptyState(
            icon: LucideIcons.alertCircle,
            title: 'Error Loading Expiring Users',
            subtitle: error.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiringUserItem(UserModel user, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            UserAvatar(name: user.name, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${user.displayRole} - Expires in ${user.daysUntilExpiry} days',
                    style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                  ),
                ],
              ),
            ),
            MinimalButton(
              text: 'Renew',
              onPressed: isLoading ? null : () => _renewUserAccount(user),
              isLoading: isLoading,
              icon: LucideIcons.calendarPlus,
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRenewalPolicySection() {
    return _buildSectionContainer(
      title: 'Renewal Policy',
      subtitle: 'Understand how account renewals work for your team.',
      icon: LucideIcons.info,
      children: [
        _buildPolicyDetail(
          'Validity Period',
          'Accounts are typically valid for ${AppConstants.renewalValidityYears} years from approval.',
          LucideIcons.calendar,
        ),
        _buildPolicyDetail(
          'Renewal Reminders',
          'Reminders are sent ${AppConstants.renewalReminderDays.join(', ')} days before expiry.',
          LucideIcons.bell,
        ),
        _buildPolicyDetail(
          'Renewal Cost',
          'The standard renewal cost is ${AppHelpers.formatCurrency(AppConstants.renewalCostINR)} per user per year.',
          LucideIcons.indianRupee,
        ),
        _buildPolicyDetail(
          'Expired Accounts',
          'Expired accounts lose access to the system until renewed by a leader.',
          LucideIcons.lock,
        ),
      ],
    );
  }

  Widget _buildPolicyDetail(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children.map((child) => Padding(
            padding: const EdgeInsets.only(bottom: 8), // Smaller padding for list items
            child: child,
          )),
        ],
      ),
    );
  }

  Future<void> _contactLeaderForRenewal(UserModel user) async {
    // This would typically involve sending an email or notification to the leader
    AppHelpers.showInfoSnackbar(context, 'Request sent to your leader for renewal!');
  }

  Future<void> _renewUserAccount(UserModel user) async {
    final years = await _showRenewalPeriodDialog();
    if (years != null) {
      try {
        await ref.read(userManagementProvider.notifier).renewUserAccount(user.uid, years);
        if (mounted) {
          AppHelpers.showSuccessSnackbar(context, '${user.name}\'s account renewed for $years year(s)!');
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to renew account: $e');
        }
      }
    }
  }

  Future<int?> _showRenewalPeriodDialog() async {
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Renewal Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose how many years to extend the account by:'),
            const SizedBox(height: 16),
            ...[1, 2, 3, 5].map((years) => ListTile(
              title: Text('$years Year${years > 1 ? 's' : ''}'),
              subtitle: Text(
                'Cost: ${AppHelpers.formatCurrency(AppConstants.renewalCostINR * years)}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              onTap: () => Navigator.of(context).pop(years),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}