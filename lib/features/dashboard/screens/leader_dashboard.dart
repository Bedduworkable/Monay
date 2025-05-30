import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/lead_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/enums.dart';
import '../widgets/dashboard_layout.dart';

class LeaderDashboard extends ConsumerStatefulWidget {
  const LeaderDashboard({super.key});

  @override
  ConsumerState<LeaderDashboard> createState() => _LeaderDashboardState();
}

class _LeaderDashboardState extends ConsumerState<LeaderDashboard> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final dashboardMetrics = ref.watch(dashboardMetricsProvider);
    final usersUnderLeader = ref.watch(usersUnderCurrentLeaderProvider);
    final joinRequests = ref.watch(joinRequestsForCurrentLeaderProvider);
    final leadsByStatus = ref.watch(leadsByStatusProvider);
    final quickActions = ref.watch(quickActionsProvider);

    return currentUser.when(
      data: (user) {
        if (user == null || (!user.isLeader && !user.isClassLeader)) {
          return const Scaffold(
            body: Center(
              child: Text('Access Denied'),
            ),
          );
        }

        return DashboardLayout(
          title: user.isLeader ? 'Leader Dashboard' : 'Class Leader Dashboard',
          subtitle: 'Team Performance & Management',
          user: user,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.read(dashboardRefreshProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(user, dashboardMetrics)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Team Metrics
                  _buildTeamMetrics(dashboardMetrics, usersUnderLeader, joinRequests)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Performance Charts
                  _buildPerformanceSection(leadsByStatus)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Quick Actions & Team Overview
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions
                      Expanded(
                        flex: 1,
                        child: _buildQuickActions(quickActions)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 600.ms)
                            .slideX(begin: -0.3, duration: 600.ms),
                      ),

                      const SizedBox(width: 24),

                      // Team Members
                      Expanded(
                        flex: 2,
                        child: _buildTeamMembers(usersUnderLeader)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 800.ms)
                            .slideX(begin: 0.3, duration: 600.ms),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const DashboardLayout(
        title: 'Loading...',
        body: Center(child: MinimalLoader()),
      ),
      error: (error, _) => DashboardLayout(
        title: 'Error',
        body: Center(
          child: Text('Error loading dashboard: $error'),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(UserModel user, DashboardMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: user.isLeader
            ? AppColors.primaryGradient
            : LinearGradient(
          colors: [AppColors.classLeaderColor, AppColors.classLeaderColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (user.isLeader ? AppColors.primary : AppColors.classLeaderColor).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user.name}!',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${user.displayRole} • ${AppHelpers.formatDate(DateTime.now())}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  user.isLeader ? LucideIcons.users : LucideIcons.userCheck,
                  color: AppColors.textOnPrimary,
                  size: 40,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Stats Row
          Row(
            children: [
              _buildQuickStat(
                'Team Size',
                '${metrics.totalUsers}',
                LucideIcons.users,
              ),
              const SizedBox(width: 24),
              _buildQuickStat(
                'Active Leads',
                '${metrics.activeLeads}',
                LucideIcons.target,
              ),
              const SizedBox(width: 24),
              _buildQuickStat(
                'Conversion',
                '${metrics.conversionRate.toStringAsFixed(1)}%',
                LucideIcons.trendingUp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.textOnPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.textOnPrimary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textOnPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMetrics(
      DashboardMetrics metrics,
      AsyncValue<List<UserModel>> teamMembers,
      AsyncValue<List<JoinRequestModel>> joinRequests,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Team Performance',
          subtitle: 'Overview of your team\'s activities and achievements',
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            MetricCard(
              title: 'Total Leads',
              value: AppHelpers.formatCompactNumber(metrics.totalLeads),
              icon: LucideIcons.target,
              iconColor: AppColors.primary,
              subtitle: 'All time',
            ),
            MetricCard(
              title: 'Converted',
              value: AppHelpers.formatCompactNumber(metrics.convertedLeads),
              icon: LucideIcons.checkCircle,
              iconColor: AppColors.success,
              subtitle: '${metrics.conversionRate.toStringAsFixed(1)}% rate',
            ),
            MetricCard(
              title: 'Follow-ups Due',
              value: AppHelpers.formatCompactNumber(metrics.followUpsDue),
              icon: LucideIcons.clock,
              iconColor: metrics.followUpsDue > 0 ? AppColors.warning : AppColors.success,
              subtitle: 'Today',
            ),
            MetricCard(
              title: 'Join Requests',
              value: joinRequests.when(
                data: (requests) => AppHelpers.formatCompactNumber(requests.length),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              icon: LucideIcons.userPlus,
              iconColor: joinRequests.asData?.value.isNotEmpty == true ? AppColors.info : AppColors.textSecondary,
              subtitle: 'Pending',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(Map<String, List<LeadModel>> leadsByStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Performance Analytics',
          subtitle: 'Track team progress and lead distribution',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Lead Status Distribution
            Expanded(
              child: _buildLeadStatusChart(leadsByStatus),
            ),
            const SizedBox(width: 24),
            // Performance Trends
            Expanded(
              child: _buildPerformanceTrendChart(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeadStatusChart(Map<String, List<LeadModel>> leadsByStatus) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lead Status Distribution',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: leadsByStatus.isNotEmpty
                ? SfCircularChart(
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              series: <CircularSeries>[
                PieSeries<MapEntry<String, List<LeadModel>>, String>(
                  dataSource: leadsByStatus.entries.toList(),
                  xValueMapper: (entry, _) => entry.key,
                  yValueMapper: (entry, _) => entry.value.length.toDouble(),
                  pointColorMapper: (entry, _) => AppHelpers.getStatusColor(entry.key),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                  radius: '80%',
                ),
              ],
            )
                : const Center(
              child: EmptyState(
                icon: LucideIcons.pieChart,
                title: 'No Data Available',
                subtitle: 'Start adding leads to see the distribution',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrendChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Performance Trend',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(),
              series: <CartesianSeries>[
                ColumnSeries<ChartData, String>(
                  dataSource: _getTeamPerformanceData(),
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(List<Map<String, dynamic>> actions) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...actions.map((action) => _buildActionItem(action)),
        ],
      ),
    );
  }

  Widget _buildActionItem(Map<String, dynamic> action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleActionTap(action['action']),
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
                  _getIconFromString(action['icon']),
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
                      action['title'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (action['badge'] != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${action['badge']}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMembers(AsyncValue<List<UserModel>> teamMembers) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Members',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () => _handleActionTap('manage_team'),
                icon: const Icon(LucideIcons.settings, size: 16),
                label: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          teamMembers.when(
            data: (members) {
              if (members.isEmpty) {
                return const EmptyState(
                  icon: LucideIcons.users,
                  title: 'No Team Members',
                  subtitle: 'Start by approving join requests',
                );
              }

              return Column(
                children: members.take(5).map((member) => _buildTeamMemberItem(member)).toList(),
              );
            },
            loading: () => const Center(child: MinimalLoader()),
            error: (_, __) => const Center(
              child: Text('Failed to load team members'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberItem(UserModel member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          UserAvatar(
            name: member.name,
            radius: 20,
            backgroundColor: AppHelpers.getRoleColor(member.role),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  member.displayRole,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: member.isExpiringSoon
                  ? AppColors.warning.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: member.isExpiringSoon
                    ? AppColors.warning.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Text(
              member.isExpiringSoon ? 'Expiring' : 'Active',
              style: AppTextStyles.labelSmall.copyWith(
                color: member.isExpiringSoon ? AppColors.warning : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleActionTap(String action) {
    // Handle action navigation
    AppHelpers.showInfoSnackbar(context, 'Action: $action');
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'plus':
        return LucideIcons.plus;
      case 'user_check':
        return LucideIcons.userCheck;
      case 'users':
        return LucideIcons.users;
      case 'settings':
        return LucideIcons.settings;
      case 'trending_up':
        return LucideIcons.trendingUp;
      case 'share':
        return LucideIcons.share;
      case 'clock':
        return LucideIcons.clock;
      case 'bar_chart_2':
        return LucideIcons.barChart2;
      default:
        return LucideIcons.plus;
    }
  }

  List<ChartData> _getTeamPerformanceData() {
    // Mock data - in real app, this would come from actual metrics
    return [
      ChartData('Week 1', 25, AppColors.primary),
      ChartData('Week 2', 35, AppColors.primary),
      ChartData('Week 3', 30, AppColors.primary),
      ChartData('Week 4', 45, AppColors.primary),
      ChartData('Week 5', 40, AppColors.primary),
    ];
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}