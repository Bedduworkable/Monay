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

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
                subtitle: 'You must be logged in to view your profile',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.read(authNotifierProvider.notifier).refreshUserData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(user)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Personal Information
                  _buildPersonalInformationSection(user)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Account Settings
                  _buildAccountSettingsSection(user)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Security
                  _buildSecuritySection()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Other Options
                  _buildOtherOptionsSection(user)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms)
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
            LucideIcons.user,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('My Profile'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          onPressed: () => ref.read(authNotifierProvider.notifier).refreshUserData(),
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(UserModel user) {
    final roleColor = AppHelpers.getRoleColor(user.role);

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
          UserAvatar(
            name: user.name,
            radius: 40,
            backgroundColor: AppColors.textOnPrimary.withOpacity(0.2),
            imageUrl: user.uid.contains('placeholder') ? null : null, // Placeholder for actual image URL
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.displayRole,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
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

  Widget _buildPersonalInformationSection(UserModel user) {
    return _buildSectionContainer(
      title: 'Personal Information',
      subtitle: 'View and update your basic details',
      icon: LucideIcons.info,
      children: [
        _buildInfoRow('Full Name', user.name, LucideIcons.user),
        _buildInfoRow('Email Address', user.email, LucideIcons.mail),
        _buildInfoRow('Role', user.displayRole, AppHelpers.getRoleIcon(user.role)),
        if (user.parentUid != null)
          _buildInfoRow(
            user.isClassLeader ? 'Assigned to Leader' : 'Assigned to Class Leader',
            user.parentUid!, // This would ideally fetch the parent's name
            LucideIcons.gitFork,
          ),
        if (user.isClassLeader && user.assignedTelecallerUids.isNotEmpty)
          _buildInfoRow(
            'Assigned Telecallers',
            '${user.assignedTelecallerUids.length} telecaller${user.assignedTelecallerUids.length > 1 ? 's' : ''}',
            LucideIcons.users,
          ),
        _buildSettingsItem(
          title: 'Edit Profile',
          subtitle: 'Update your name, email, and other details',
          icon: LucideIcons.edit,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Edit Profile Screen'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                  label,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection(UserModel user) {
    return _buildSectionContainer(
      title: 'Account Settings',
      subtitle: 'Manage your account preferences and status',
      icon: LucideIcons.settings,
      children: [
        _buildSettingsItem(
          title: 'Account Status',
          subtitle: user.approvalStatus.displayName,
          icon: user.approvalStatus.value == 'approved' ? LucideIcons.checkCircle : LucideIcons.clock,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Account Status details'),
          trailing: StatusBadge(
            status: user.approvalStatus.displayName,
            backgroundColor: user.approvalStatus.color.withOpacity(0.1),
            textColor: user.approvalStatus.color,
          ),
        ),
        _buildSettingsItem(
          title: 'Account Expiry',
          subtitle: user.isExpired
              ? 'Expired on ${AppHelpers.formatDate(user.expiresAt!)}'
              : user.isExpiringSoon
              ? 'Expires in ${user.daysUntilExpiry} days'
              : 'Valid until ${AppHelpers.formatDate(user.expiresAt!)}',
          icon: LucideIcons.calendarX,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Renewal Status'),
          trailing: Icon(
            user.isExpired ? LucideIcons.alertCircle : (user.isExpiringSoon ? LucideIcons.clock : LucideIcons.shield),
            color: user.isExpired ? AppColors.error : (user.isExpiringSoon ? AppColors.warning : AppColors.success),
            size: 18,
          ),
        ),
        _buildSettingsItem(
          title: 'Notification Preferences',
          subtitle: 'Control how you receive alerts and updates',
          icon: LucideIcons.bell,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Notification Preferences'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSectionContainer(
      title: 'Security',
      subtitle: 'Manage your password and account security',
      icon: LucideIcons.lock,
      children: [
        _buildSettingsItem(
          title: 'Change Password',
          subtitle: 'Update your account password',
          icon: LucideIcons.key,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Change Password'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Two-Factor Authentication (2FA)',
          subtitle: 'Add an extra layer of security to your account',
          icon: LucideIcons.shieldCheck,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Configure 2FA'),
          trailing: Switch(value: false, onChanged: (value) {}), // Placeholder for 2FA toggle
        ),
        _buildSettingsItem(
          title: 'Delete Account',
          subtitle: 'Permanently delete your account from the system',
          icon: LucideIcons.trash2,
          onTap: () => _confirmAccountDeletion(),
          trailing: Icon(LucideIcons.alertTriangle, color: AppColors.error),
        ),
      ],
    );
  }

  Widget _buildOtherOptionsSection(UserModel user) {
    return _buildSectionContainer(
      title: 'Other Options',
      subtitle: 'Additional settings and actions',
      icon: LucideIcons.menu,
      children: [
        _buildSettingsItem(
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          icon: LucideIcons.fingerprint,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Open Privacy Policy'),
          trailing: const Icon(LucideIcons.externalLink),
        ),
        _buildSettingsItem(
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          icon: LucideIcons.fileText,
          onTap: () => AppHelpers.showInfoSnackbar(context, 'Open Terms of Service'),
          trailing: const Icon(LucideIcons.externalLink),
        ),
        _buildSettingsItem(
          title: 'Sign Out',
          subtitle: 'Log out of your account',
          icon: LucideIcons.logOut,
          onTap: () => _confirmSignOut(),
          trailing: Icon(LucideIcons.logOut, color: AppColors.error),
        ),
      ],
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
            padding: const EdgeInsets.only(bottom: 8),
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

  Future<void> _confirmAccountDeletion() async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Account',
      content: 'Are you sure you want to permanently delete your account? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirm == true) {
      // Implement account deletion logic here
      AppHelpers.showInfoSnackbar(context, 'Account deletion initiated (coming soon)');
    }
  }

  Future<void> _confirmSignOut() async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Sign Out',
      content: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
    );

    if (confirm == true) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.signOut();
      if (mounted) {
        // Assuming app_router will handle redirection to login
      }
    }
  }
}