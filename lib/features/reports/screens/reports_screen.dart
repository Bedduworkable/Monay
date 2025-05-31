import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart'; // For AppHelpers
import '../../../core/navigation/route_names.dart'; // For RouteNames

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
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
                subtitle: 'You must be logged in to view reports',
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

                // Performance Reports
                _buildReportsSection(
                  title: 'Performance Reports',
                  subtitle: 'Analyze individual and team performance over time',
                  icon: LucideIcons.barChart2,
                  children: [
                    _buildReportItem(
                      title: 'My Performance',
                      subtitle: 'Detailed report of your personal lead metrics',
                      icon: LucideIcons.user,
                      onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to My Performance Report'),
                      trailing: const Icon(LucideIcons.chevronRight),
                    ),
                    if (user.canManageUsers) // Leaders and Admins can see team reports
                      _buildReportItem(
                        title: 'Team Performance',
                        subtitle: 'Overview of your team\'s lead and activity performance',
                        icon: LucideIcons.users,
                        onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Team Performance Report'),
                        trailing: const Icon(LucideIcons.chevronRight),
                      ),
                    if (user.isAdmin) // Admins can see overall system performance
                      _buildReportItem(
                        title: 'System Performance',
                        subtitle: 'Comprehensive analytics across all users and teams',
                        icon: LucideIcons.shield,
                        onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to System Performance Report'),
                        trailing: const Icon(LucideIcons.chevronRight),
                      ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // Lead Analytics Reports
                _buildReportsSection(
                  title: 'Lead Analytics Reports',
                  subtitle: 'Insights into lead pipeline, conversion rates, and sources',
                  icon: LucideIcons.target,
                  children: [
                    _buildReportItem(
                      title: 'Lead Conversion Funnel',
                      subtitle: 'Visualize lead progression through different stages',
                      icon: LucideIcons.funnel,
                      onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Lead Conversion Funnel'),
                      trailing: const Icon(LucideIcons.chevronRight),
                    ),
                    _buildReportItem(
                      title: 'Lead Source Analysis',
                      subtitle: 'Breakdown of leads by their origination source',
                      icon: LucideIcons.globe,
                      onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Lead Source Analysis'),
                      trailing: const Icon(LucideIcons.chevronRight),
                    ),
                    _buildReportItem(
                      title: 'Follow-up Effectiveness',
                      subtitle: 'Analyze the impact of follow-ups on lead conversion',
                      icon: LucideIcons.clock,
                      onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Follow-up Effectiveness Report'),
                      trailing: const Icon(LucideIcons.chevronRight),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, duration: 600.ms),

                const SizedBox(height: 24),

                // User & Team Reports
                if (user.canManageUsers)
                  _buildReportsSection(
                    title: 'User & Team Reports',
                    subtitle: 'Detailed reports on user activity and team structure',
                    icon: LucideIcons.users,
                    children: [
                      _buildReportItem(
                        title: 'User Activity Log',
                        subtitle: 'Track actions performed by individual users',
                        icon: LucideIcons.history,
                        onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to User Activity Log'),
                        trailing: const Icon(LucideIcons.chevronRight),
                      ),
                      _buildReportItem(
                        title: 'Team Hierarchy Overview',
                        subtitle: 'Visualize the organizational structure of teams',
                        icon: LucideIcons.network,
                        onTap: () => AppHelpers.showInfoSnackbar(context, 'Navigate to Team Hierarchy Overview'),
                        trailing: const Icon(LucideIcons.chevronRight),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3, duration: 600.ms),
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
            LucideIcons.barChart,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Reports'),
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
              LucideIcons.barChart,
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
                  'Analytics & Reports',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Access detailed insights into leads, users, and team performance.',
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

  Widget _buildReportsSection({
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

  Widget _buildReportItem({
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