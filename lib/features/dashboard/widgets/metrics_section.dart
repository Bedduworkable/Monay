import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; //
import 'package:flutter_animate/flutter_animate.dart'; //

import '../../../core/providers/dashboard_provider.dart'; //
import '../../../core/providers/user_provider.dart'; // For user specific metrics, if any
import '../../../core/providers/lead_provider.dart'; // For lead specific metrics, if any
import '../../../core/theme/app_colors.dart'; //
import '../../../core/theme/app_text_styles.dart'; //
import '../../../core/theme/custom_widgets.dart'; // For MetricCard, SectionHeader, MinimalLoader
import '../../../core/utils/helpers.dart'; // For AppHelpers
import '../../../core/models/user_model.dart'; //
import '../../../core/models/lead_model.dart'; //

enum MetricSectionType {
  personal,
  team,
  admin,
}

class MetricsSection extends ConsumerWidget {
  final String title;
  final String subtitle;
  final MetricSectionType type;

  const MetricsSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardMetrics = ref.watch(dashboardMetricsProvider); //

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader( //
          title: title,
          subtitle: subtitle,
        ),
        const SizedBox(height: 16),
        dashboardMetrics.when(
          data: (metrics) {
            return GridView.count(
              crossAxisCount: 4, // Adjust based on screen size, currently fixed for wide view
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: _buildMetricCards(metrics, ref),
            );
          },
          loading: () => const Center(child: MinimalLoader()), //
          error: (error, stack) => EmptyState( //
            icon: LucideIcons.alertCircle, //
            title: 'Error Loading Metrics',
            subtitle: error.toString(),
            actionText: 'Retry',
            onAction: () => ref.invalidate(dashboardMetricsProvider), //
          ),
        ).animate().fadeIn(duration: 600.ms), //
      ],
    );
  }

  List<Widget> _buildMetricCards(DashboardMetrics metrics, WidgetRef ref) {
    switch (type) {
      case MetricSectionType.personal:
        final followUpLeads = ref.watch(followUpLeadsForTodayProvider); //
        final overdueLeads = ref.watch(overdueFollowUpsProvider); //
        return [
          MetricCard( //
            title: 'Total Leads',
            value: AppHelpers.formatCompactNumber(metrics.totalLeads), //
            icon: LucideIcons.target, //
            iconColor: AppColors.primary, //
            subtitle: 'All time',
          ),
          MetricCard( //
            title: 'Converted',
            value: AppHelpers.formatCompactNumber(metrics.convertedLeads), //
            icon: LucideIcons.checkCircle, //
            iconColor: AppColors.success, //
            subtitle: '${metrics.conversionRate.toStringAsFixed(1)}% rate',
          ),
          MetricCard( //
            title: 'Due Today',
            value: followUpLeads.when(
              data: (leads) => AppHelpers.formatCompactNumber(leads.length), //
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: LucideIcons.clock, //
            iconColor: AppColors.warning, //
            subtitle: 'Follow-ups',
          ),
          MetricCard( //
            title: 'Overdue',
            value: overdueLeads.when(
              data: (leads) => AppHelpers.formatCompactNumber(leads.length), //
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: LucideIcons.alertCircle, //
            iconColor: AppColors.error, //
            subtitle: 'Past due',
          ),
        ];
      case MetricSectionType.team:
        final joinRequests = ref.watch(joinRequestsForCurrentLeaderProvider); //
        final usersUnderLeader = ref.watch(usersUnderCurrentLeaderProvider); //

        return [
          MetricCard( //
            title: 'Total Leads',
            value: AppHelpers.formatCompactNumber(metrics.totalLeads), //
            icon: LucideIcons.target, //
            iconColor: AppColors.primary, //
            subtitle: 'All time',
          ),
          MetricCard( //
            title: 'Converted',
            value: AppHelpers.formatCompactNumber(metrics.convertedLeads), //
            icon: LucideIcons.checkCircle, //
            iconColor: AppColors.success, //
            subtitle: '${metrics.conversionRate.toStringAsFixed(1)}% rate',
          ),
          MetricCard( //
            title: 'Team Size',
            value: usersUnderLeader.when(
              data: (users) => AppHelpers.formatCompactNumber(users.length), //
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: LucideIcons.users, //
            iconColor: AppColors.info, //
            subtitle: 'Active members',
          ),
          MetricCard( //
            title: 'Join Requests',
            value: joinRequests.when(
              data: (requests) => AppHelpers.formatCompactNumber(requests.length), //
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: LucideIcons.userPlus, //
            iconColor: AppColors.warning, //
            subtitle: 'Pending approvals',
          ),
        ];
      case MetricSectionType.admin:
        final userStats = ref.watch(userStatisticsProvider); //
        final totalLeadsCount = ref.watch(totalLeadsCountProvider); //
        return [
          MetricCard( //
            title: 'Total Users',
            value: userStats.when(
              data: (stats) => AppHelpers.formatCompactNumber(
                stats.values.fold(0, (sum, count) => sum + count),
              ),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: LucideIcons.users, //
            iconColor: AppColors.primary, //
            subtitle: 'Active accounts',
          ),
          MetricCard( //
            title: 'Leaders',
            value: userStats.when(
              data: (stats) => AppHelpers.formatCompactNumber(
                stats[UserRole.leader.value] ?? 0, //
              ),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: LucideIcons.userCheck, //
            iconColor: AppColors.leaderColor, //
            subtitle: 'Team leaders',
          ),
          MetricCard( //
            title: 'Total Leads',
            value: totalLeadsCount.when(
              data: (count) => AppHelpers.formatCompactNumber(count), //
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: LucideIcons.target, //
            iconColor: AppColors.success, //
            subtitle: 'All time',
          ),
          MetricCard( //
            title: 'System Health',
            value: '99.9%',
            icon: LucideIcons.activity, //
            iconColor: AppColors.success, //
            subtitle: 'Uptime',
          ),
        ];
    }
  }
}