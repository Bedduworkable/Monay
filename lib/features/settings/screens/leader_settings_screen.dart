import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/navigation/route_names.dart'; // Import RouteNames

class LeaderSettingsScreen extends ConsumerStatefulWidget {
  const LeaderSettingsScreen({super.key});

  @override
  ConsumerState<LeaderSettingsScreen> createState() => _LeaderSettingsScreenState();
}

class _LeaderSettingsScreenState extends ConsumerState<LeaderSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return currentUser.when(
      data: (user) {
        if (user == null || (!user.isLeader && !user.isClassLeader && !user.isAdmin)) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'Only leaders or administrators can access team settings',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
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

                // Team Configuration
                _buildTeamConfigSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // Lead Management Settings
                _buildLeadManagementSettingsSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // Notifications
                _buildNotificationSettingsSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // Account & Billing (for Leaders)
                if (user.isLeader || user.isAdmin)
                  _buildAccountAndBillingSection()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms)
                      .slideY(begin: 0.3, duration: 600.ms),
              ],
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
            LucideIcons.settings,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Team Settings'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          onPressed: () {}, // Implement refresh if needed
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
              LucideIcons.users,
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
                  '$roleDisplayName Settings',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your team\'s preferences and lead settings',
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

  Widget _buildTeamConfigSection() {
    return _buildSettingsSection(
      title: 'Team Configuration',
      subtitle: 'Manage team structure and member roles',
      icon: LucideIcons.users,
      children: [
        _buildSettingsItem(
          title: 'Manage Team Members',
          subtitle: 'View and manage members in your team',
          icon: LucideIcons.user,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Manage Team Members'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Join Requests',
          subtitle: 'Review and approve new member requests',
          icon: LucideIcons.userPlus,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Join Requests'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Assign Telecallers',
          subtitle: 'Assign telecallers to class leaders',
          icon: LucideIcons.userCheck,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Assign Telecallers'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildLeadManagementSettingsSection() {
    return _buildSettingsSection(
      title: 'Lead Management Settings',
      subtitle: 'Customize lead statuses and custom fields for your team',
      icon: LucideIcons.target,
      children: [
        _buildSettingsItem(
          title: 'Manage Lead Statuses',
          subtitle: 'Add, edit, or reorder lead statuses',
          icon: LucideIcons.flag,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.manageStatuses),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Manage Custom Fields',
          subtitle: 'Define custom fields for lead information',
          icon: LucideIcons.grid3x3,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.manageFields),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Lead Assignment Rules',
          subtitle: 'Set rules for automated lead distribution',
          icon: LucideIcons.share,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Configure Lead Assignment Rules'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildNotificationSettingsSection() {
    return _buildSettingsSection(
      title: 'Notification Settings',
      subtitle: 'Control team-wide notification preferences',
      icon: LucideIcons.bell,
      children: [
        _buildSettingsItem(
          title: 'Team Activity Alerts',
          subtitle: 'Receive alerts for team member activities',
          icon: LucideIcons.activity,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Configure Team Activity Alerts'),
          trailing: Switch(value: true, onChanged: (value) {}),
        ),
        _buildSettingsItem(
          title: 'Lead Update Notifications',
          subtitle: 'Get notified about changes to assigned leads',
          icon: LucideIcons.bellRing,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Configure Lead Update Notifications'),
          trailing: Switch(value: true, onChanged: (value) {}),
        ),
      ],
    );
  }

  Widget _buildAccountAndBillingSection() {
    return _buildSettingsSection(
      title: 'Account & Billing',
      subtitle: 'Manage your subscription and account details',
      icon: LucideIcons.dollarSign,
      children: [
        _buildSettingsItem(
          title: 'Subscription Status',
          subtitle: 'View your current plan and renewal date',
          icon: LucideIcons.creditCard,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'View Subscription Status'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Payment Methods',
          subtitle: 'Manage your payment information',
          icon: LucideIcons.wallet,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Manage Payment Methods'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Billing History',
          subtitle: 'View past invoices and transactions',
          icon: LucideIcons.receipt,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'View Billing History'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
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
            padding: const EdgeInsets.only(bottom: 16),
            child: child,
          )),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
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
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}