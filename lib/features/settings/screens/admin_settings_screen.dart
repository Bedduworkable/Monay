import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return currentUser.when(
      data: (user) {
        if (user == null || !user.isAdmin) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'Only administrators can access system settings',
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
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, duration: 600.ms),

                const SizedBox(height: 32),

                // System Configuration
                _buildSystemConfigSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // User Management
                _buildUserManagementSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // Data Management
                _buildDataManagementSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // Security Settings
                _buildSecuritySection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 800.ms)
                    .slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // System Maintenance
                _buildMaintenanceSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1000.ms)
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
          const Text('System Settings'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          onPressed: _showSystemInfo,
          icon: const Icon(LucideIcons.info),
          tooltip: 'System Information',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
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
              LucideIcons.shield,
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
                  'Administrator Settings',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage system-wide configurations and policies',
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

  Widget _buildSystemConfigSection() {
    return _buildSettingsSection(
      title: 'System Configuration',
      subtitle: 'Core system settings and configurations',
      icon: LucideIcons.cog,
      children: [
        _buildSettingsItem(
          title: 'Global Lead Statuses',
          subtitle: 'Manage default lead statuses for all teams',
          icon: LucideIcons.flag,
          onTap: () => _navigateToScreen('manage_statuses'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Default Custom Fields',
          subtitle: 'Configure default fields for new teams',
          icon: LucideIcons.grid3x3,
          onTap: () => _navigateToScreen('manage_fields'),
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'System Notifications',
          subtitle: 'Configure system-wide notification settings',
          icon: LucideIcons.bell,
          onTap: _configureNotifications,
          trailing: Switch(
            value: true,
            onChanged: (value) {},
          ),
        ),
        _buildSettingsItem(
          title: 'Renewal Settings',
          subtitle: 'Configure account renewal policies',
          icon: LucideIcons.calendar,
          onTap: _configureRenewalSettings,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildUserManagementSection() {
    return _buildSettingsSection(
      title: 'User Management',
      subtitle: 'User roles, permissions, and account policies',
      icon: LucideIcons.users,
      children: [
        _buildSettingsItem(
          title: 'Role Permissions',
          subtitle: 'Configure permissions for each user role',
          icon: LucideIcons.shield,
          onTap: _configureRolePermissions,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Auto-Approval Rules',
          subtitle: 'Set rules for automatic join request approval',
          icon: LucideIcons.userCheck,
          onTap: _configureAutoApproval,
          trailing: Switch(
            value: false,
            onChanged: (value) {},
          ),
        ),
        _buildSettingsItem(
          title: 'Account Expiry Policy',
          subtitle: 'Configure default account validity periods',
          icon: LucideIcons.clock,
          onTap: _configureExpiryPolicy,
          trailing: const Text(
            '2 Years',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildSettingsItem(
          title: 'Bulk User Operations',
          subtitle: 'Import/export users and bulk management',
          icon: LucideIcons.users,
          onTap: _manageBulkOperations,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return _buildSettingsSection(
      title: 'Data Management',
      subtitle: 'Backup, export, and data integrity settings',
      icon: LucideIcons.database,
      children: [
        _buildSettingsItem(
          title: 'Data Backup',
          subtitle: 'Configure automated backup schedules',
          icon: LucideIcons.hardDrive,
          onTap: _configureBackup,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Data Export',
          subtitle: 'Export system data for analysis',
          icon: LucideIcons.download,
          onTap: _exportSystemData,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Data Retention',
          subtitle: 'Configure data retention policies',
          icon: LucideIcons.archive,
          onTap: _configureDataRetention,
          trailing: const Text(
            '7 Years',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildSettingsItem(
          title: 'Data Cleanup',
          subtitle: 'Remove old or unnecessary data',
          icon: LucideIcons.trash2,
          onTap: _performDataCleanup,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSettingsSection(
      title: 'Security & Compliance',
      subtitle: 'Security policies and compliance settings',
      icon: LucideIcons.lock,
      children: [
        _buildSettingsItem(
          title: 'Password Policy',
          subtitle: 'Configure password requirements',
          icon: LucideIcons.key,
          onTap: _configurePasswordPolicy,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Session Management',
          subtitle: 'Configure session timeouts and policies',
          icon: LucideIcons.timer,
          onTap: _configureSessionPolicy,
          trailing: const Text(
            '60 min',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildSettingsItem(
          title: 'Audit Logs',
          subtitle: 'View and configure system audit logs',
          icon: LucideIcons.fileText,
          onTap: _viewAuditLogs,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'API Access Control',
          subtitle: 'Manage API keys and access permissions',
          icon: LucideIcons.key,
          onTap: _manageApiAccess,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection() {
    return _buildSettingsSection(
      title: 'System Maintenance',
      subtitle: 'System health, updates, and maintenance tools',
      icon: LucideIcons.wrench,
      children: [
        _buildSettingsItem(
          title: 'System Health',
          subtitle: 'View system performance and health metrics',
          icon: LucideIcons.activity,
          onTap: _viewSystemHealth,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Healthy',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        _buildSettingsItem(
          title: 'System Updates',
          subtitle: 'Check for and manage system updates',
          icon: LucideIcons.download,
          onTap: _checkSystemUpdates,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Cache Management',
          subtitle: 'Clear system caches and temporary data',
          icon: LucideIcons.refreshCw,
          onTap: _manageCaches,
          trailing: const Icon(LucideIcons.chevronRight),
        ),
        _buildSettingsItem(
          title: 'Maintenance Mode',
          subtitle: 'Enable maintenance mode for system updates',
          icon: LucideIcons.construction,
          onTap: _toggleMaintenanceMode,
          trailing: Switch(
            value: false,
            onChanged: (value) => _confirmMaintenanceMode(value),
          ),
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

  // Navigation and Action Methods
  void _navigateToScreen(String screenName) {
    AppHelpers.showInfoSnackbar(context, 'Navigate to: $screenName');
  }

  void _showSystemInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version: 1.0.0'),
            Text('Database Version: 2.1.3'),
            Text('Last Updated: May 30, 2025'),
            Text('Environment: Production'),
            Text('Region: Asia-Pacific'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _configureNotifications() {
    AppHelpers.showInfoSnackbar(context, 'Configure notifications');
  }

  void _configureRenewalSettings() {
    AppHelpers.showInfoSnackbar(context, 'Configure renewal settings');
  }

  void _configureRolePermissions() {
    AppHelpers.showInfoSnackbar(context, 'Configure role permissions');
  }

  void _configureAutoApproval() {
    AppHelpers.showInfoSnackbar(context, 'Configure auto-approval rules');
  }

  void _configureExpiryPolicy() {
    AppHelpers.showInfoSnackbar(context, 'Configure expiry policy');
  }

  void _manageBulkOperations() {
    AppHelpers.showInfoSnackbar(context, 'Manage bulk operations');
  }

  void _configureBackup() {
    AppHelpers.showInfoSnackbar(context, 'Configure backup settings');
  }

  void _exportSystemData() {
    AppHelpers.showInfoSnackbar(context, 'Export system data');
  }

  void _configureDataRetention() {
    AppHelpers.showInfoSnackbar(context, 'Configure data retention');
  }

  void _performDataCleanup() {
    AppHelpers.showInfoSnackbar(context, 'Perform data cleanup');
  }

  void _configurePasswordPolicy() {
    AppHelpers.showInfoSnackbar(context, 'Configure password policy');
  }

  void _configureSessionPolicy() {
    AppHelpers.showInfoSnackbar(context, 'Configure session policy');
  }

  void _viewAuditLogs() {
    AppHelpers.showInfoSnackbar(context, 'View audit logs');
  }

  void _manageApiAccess() {
    AppHelpers.showInfoSnackbar(context, 'Manage API access');
  }

  void _viewSystemHealth() {
    AppHelpers.showInfoSnackbar(context, 'View system health');
  }

  void _checkSystemUpdates() {
    AppHelpers.showInfoSnackbar(context, 'Check system updates');
  }

  void _manageCaches() {
    AppHelpers.showInfoSnackbar(context, 'Manage caches');
  }

  void _toggleMaintenanceMode() {
    AppHelpers.showInfoSnackbar(context, 'Toggle maintenance mode');
  }

  Future<void> _confirmMaintenanceMode(bool enabled) async {
    if (enabled) {
      final confirm = await AppHelpers.showConfirmDialog(
        context,
        title: 'Enable Maintenance Mode',
        content: 'This will prevent all users from accessing the system. Continue?',
        confirmText: 'Enable',
      );

      if (confirm == true) {
        AppHelpers.showInfoSnackbar(context, 'Maintenance mode enabled');
      }
    }
  }
}