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
import '../widgets/dashboard_layout.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final dashboardMetrics = ref.watch(dashboardMetricsProvider);
    final userStats = ref.watch(userStatisticsProvider);
    final totalLeads = ref.watch(totalLeadsCountProvider);
    final quickActions = ref.watch(quickActionsProvider);

    return currentUser.when(
      data: (user) {
        if (user == null || !user.isAdmin) {
          return const Scaffold(
            body: Center(
              child: Text('Access Denied'),
            ),
          );
        }

        return DashboardLayout(
          title: 'Admin Dashboard',
          subtitle: 'System Overview & Management',
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
                  _buildWelcomeSection(user)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // System Overview Metrics
                  _buildSystemMetrics(userStats, totalLeads)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Charts Row
                  _buildChartsSection()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Quick Actions & Recent Activity
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

                      // Recent System Activity
                      Expanded(
                        flex: 2,
                        child: _buildRecentActivity()
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

  Widget _buildWelcomeSection(UserModel user) {
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
                  'System Administrator • ${AppHelpers.formatDate(DateTime.now())}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      LucideIcons.shield,
                      color: AppColors.textOnPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Full system access',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
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
              LucideIcons.crown,
              color: AppColors.textOnPrimary,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMetrics(AsyncValue<Map<String, int>> userStats, AsyncValue<int> totalLeads) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'System Overview',
          subtitle: 'Key performance indicators across the platform',
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
              title: 'Total Users',
              value: userStats.when(
                data: (stats) => AppHelpers.formatCompactNumber(
                  stats.values.fold(0, (sum, count) => sum + count),
                ),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              icon: LucideIcons.users,
              iconColor: AppColors.primary,
              subtitle: 'Active accounts',
            ),
            MetricCard(
              title: 'Leaders',
              value: userStats.when(
                data: (stats) => AppHelpers.formatCompactNumber(
                  stats['Leader'] ?? 0,
                ),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              icon: LucideIcons.userCheck,
              iconColor: AppColors.leaderColor,
              subtitle: 'Team leaders',
            ),
            MetricCard(
              title: 'Total Leads',
              value: totalLeads.when(
                data: (count) => AppHelpers.formatCompactNumber(count),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              icon: LucideIcons.target,
              iconColor: AppColors.success,
              subtitle: 'All time',
            ),
            MetricCard(
              title: 'System Health',
              value: '99.9%',
              icon: LucideIcons.activity,
              iconColor: AppColors.success,
              subtitle: 'Uptime',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Analytics',
          subtitle: 'Performance trends and insights',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // User Distribution Chart
            Expanded(
              child: _buildUserDistributionChart(),
            ),
            const SizedBox(width: 24),
            // Growth Trends Chart
            Expanded(
              child: _buildGrowthTrendsChart(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserDistributionChart() {
    final userStats = ref.watch(userStatisticsProvider);

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
            'User Distribution',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: userStats.when(
              data: (stats) {
                final chartData = stats.entries.map((entry) {
                  return ChartData(
                    entry.key,
                    entry.value.toDouble(),
                    AppHelpers.getRoleColor(_getRoleFromString(entry.key)),
                  );
                }).toList();

                return SfCircularChart(
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                  ),
                  series: <CircularSeries>[
                    DoughnutSeries<ChartData, String>(
                      dataSource: chartData,
                      xValueMapper: (ChartData data, _) => data.label,
                      yValueMapper: (ChartData data, _) => data.value,
                      pointColorMapper: (ChartData data, _) => data.color,
                      innerRadius: '60%',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: MinimalLoader()),
              error: (_, __) => const Center(
                child: Text('Failed to load chart data'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTrendsChart() {
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
            'Growth Trends',
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
                LineSeries<ChartData, String>(
                  dataSource: _getGrowthData(),
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  color: AppColors.primary,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    borderWidth: 2,
                  ),
                ),
              ],
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

  Widget _buildRecentActivity() {
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
            'Recent System Activity',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          // Mock activity items
          ...List.generate(5, (index) => _buildActivityItem(index)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {
        'icon': LucideIcons.userPlus,
        'title': 'New leader created',
        'subtitle': 'John Smith joined as team leader',
        'time': '2 hours ago',
        'color': AppColors.success,
      },
      {
        'icon': LucideIcons.target,
        'title': 'Lead converted',
        'subtitle': 'Premium project lead closed successfully',
        'time': '4 hours ago',
        'color': AppColors.primary,
      },
      {
        'icon': LucideIcons.settings,
        'title': 'System update',
        'subtitle': 'New features deployed',
        'time': '1 day ago',
        'color': AppColors.info,
      },
      {
        'icon': LucideIcons.shield,
        'title': 'Security scan',
        'subtitle': 'All systems secure',
        'time': '2 days ago',
        'color': AppColors.success,
      },
      {
        'icon': LucideIcons.database,
        'title': 'Data backup',
        'subtitle': 'Weekly backup completed',
        'time': '3 days ago',
        'color': AppColors.warning,
      },
    ];

    final activity = activities[index % activities.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  activity['subtitle'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
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

  UserRole _getRoleFromString(String roleString) {
    return UserRole.values.firstWhere(
          (role) => role.value == roleString,
      orElse: () => UserRole.user,
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'user_plus':
        return LucideIcons.userPlus;
      case 'settings':
        return LucideIcons.settings;
      case 'bar_chart':
        return LucideIcons.barChart;
      default:
        return LucideIcons.plus;
    }
  }

  List<ChartData> _getGrowthData() {
    return [
      ChartData('Jan', 120, AppColors.primary),
      ChartData('Feb', 145, AppColors.primary),
      ChartData('Mar', 160, AppColors.primary),
      ChartData('Apr', 180, AppColors.primary),
      ChartData('May', 200, AppColors.primary),
      ChartData('Jun', 225, AppColors.primary),
    ];
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}