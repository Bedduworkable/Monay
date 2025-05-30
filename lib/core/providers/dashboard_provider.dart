import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/lead_model.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import 'auth_provider.dart';
import 'user_provider.dart';
import 'lead_provider.dart';

// Dashboard Metrics State
class DashboardMetrics {
  final int totalLeads;
  final int convertedLeads;
  final int activeLeads;
  final int followUpsDue;
  final int overdueFollowUps;
  final double conversionRate;
  final int totalUsers;
  final int newLeadsThisMonth;
  final int pendingJoinRequests;
  final Map<String, int> leadsByStatus;
  final List<LeadModel> recentActivity;

  const DashboardMetrics({
    this.totalLeads = 0,
    this.convertedLeads = 0,
    this.activeLeads = 0,
    this.followUpsDue = 0,
    this.overdueFollowUps = 0,
    this.conversionRate = 0.0,
    this.totalUsers = 0,
    this.newLeadsThisMonth = 0,
    this.pendingJoinRequests = 0,
    this.leadsByStatus = const {},
    this.recentActivity = const [],
  });

  DashboardMetrics copyWith({
    int? totalLeads,
    int? convertedLeads,
    int? activeLeads,
    int? followUpsDue,
    int? overdueFollowUps,
    double? conversionRate,
    int? totalUsers,
    int? newLeadsThisMonth,
    int? pendingJoinRequests,
    Map<String, int>? leadsByStatus,
    List<LeadModel>? recentActivity,
  }) {
    return DashboardMetrics(
      totalLeads: totalLeads ?? this.totalLeads,
      convertedLeads: convertedLeads ?? this.convertedLeads,
      activeLeads: activeLeads ?? this.activeLeads,
      followUpsDue: followUpsDue ?? this.followUpsDue,
      overdueFollowUps: overdueFollowUps ?? this.overdueFollowUps,
      conversionRate: conversionRate ?? this.conversionRate,
      totalUsers: totalUsers ?? this.totalUsers,
      newLeadsThisMonth: newLeadsThisMonth ?? this.newLeadsThisMonth,
      pendingJoinRequests: pendingJoinRequests ?? this.pendingJoinRequests,
      leadsByStatus: leadsByStatus ?? this.leadsByStatus,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }
}

// Dashboard Metrics Provider
final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final leads = ref.watch(leadsForCurrentUserProvider);
  final followUpLeads = ref.watch(followUpLeadsForTodayProvider);
  final overdueLeads = ref.watch(overdueFollowUpsProvider);
  final convertedLeads = ref.watch(convertedLeadsProvider);
  final activeLeads = ref.watch(activeLeadsProvider);
  final recentLeads = ref.watch(recentLeadsProvider);
  final pendingRequests = ref.watch(pendingJoinRequestsCountProvider);
  final teamSize = ref.watch(teamSizeProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) {
        return const DashboardMetrics();
      }

      final allLeads = leads.asData?.value ?? [];
      final todayFollowUps = followUpLeads.asData?.value ?? [];
      final overdue = overdueLeads.asData?.value ?? [];
      final converted = convertedLeads.asData?.value ?? [];
      final active = activeLeads.asData?.value ?? [];
      final recent = recentLeads.asData?.value ?? [];

      // Calculate this month's leads
      final thisMonth = DateTime.now();
      final startOfMonth = DateTime(thisMonth.year, thisMonth.month, 1);
      final newThisMonth = allLeads.where((lead) =>
          lead.createdAt.isAfter(startOfMonth)).length;

      // Calculate conversion rate
      final conversionRate = allLeads.isNotEmpty
          ? (converted.length / allLeads.length * 100)
          : 0.0;

      // Group leads by status
      final leadsByStatus = <String, int>{};
      for (final lead in allLeads) {
        leadsByStatus[lead.status] = (leadsByStatus[lead.status] ?? 0) + 1;
      }

      return DashboardMetrics(
        totalLeads: allLeads.length,
        convertedLeads: converted.length,
        activeLeads: active.length,
        followUpsDue: todayFollowUps.length,
        overdueFollowUps: overdue.length,
        conversionRate: conversionRate,
        totalUsers: teamSize,
        newLeadsThisMonth: newThisMonth,
        pendingJoinRequests: pendingRequests,
        leadsByStatus: leadsByStatus,
        recentActivity: recent.take(10).toList(),
      );
    },
    loading: () => const DashboardMetrics(),
    error: (_, __) => const DashboardMetrics(),
  );
});

// Role-specific Dashboard Providers
final adminDashboardProvider = Provider<DashboardMetrics>((ref) {
  final userStats = ref.watch(userStatisticsProvider);
  final totalLeadsCount = ref.watch(totalLeadsCountProvider);
  final allLeaders = ref.watch(leaderUsersProvider);
  final allClassLeaders = ref.watch(classLeaderUsersProvider);
  final allTelecallers = ref.watch(telecallerUsersProvider);

  return userStats.when(
    data: (stats) {
      final totalUsers = stats.values.fold(0, (sum, count) => sum + count);
      final leadersCount = stats[UserRole.leader.value] ?? 0;
      final classLeadersCount = stats[UserRole.classLeader.value] ?? 0;
      final telecallersCount = stats[UserRole.user.value] ?? 0;

      return DashboardMetrics(
        totalUsers: totalUsers,
        totalLeads: totalLeadsCount.asData?.value ?? 0,
        // Add more admin-specific metrics here
      );
    },
    loading: () => const DashboardMetrics(),
    error: (_, __) => const DashboardMetrics(),
  );
});

// Performance Metrics Provider
final performanceMetricsProvider = Provider<Map<String, dynamic>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final metrics = ref.watch(dashboardMetricsProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) return {};

      final previousPeriodData = _getPreviousPeriodData(); // This would need implementation

      return {
        'leadsGrowth': _calculateGrowthRate(
          metrics.totalLeads.toDouble(),
          previousPeriodData['totalLeads']?.toDouble() ?? 0,
        ),
        'conversionGrowth': _calculateGrowthRate(
          metrics.conversionRate,
          previousPeriodData['conversionRate']?.toDouble() ?? 0,
        ),
        'activityTrend': _calculateActivityTrend(),
        'topPerformingStatus': _getTopPerformingStatus(metrics.leadsByStatus),
      };
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// Quick Actions Provider
final quickActionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final metrics = ref.watch(dashboardMetricsProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) return [];

      List<Map<String, dynamic>> actions = [];

      // Common actions for all users
      actions.add({
        'title': 'Add New Lead',
        'icon': 'plus',
        'action': 'add_lead',
        'badge': null,
      });

      // Role-specific actions
      switch (user.role) {
        case UserRole.admin:
          actions.addAll([
            {
              'title': 'Create Leader',
              'icon': 'user_plus',
              'action': 'create_leader',
              'badge': null,
            },
            {
              'title': 'System Settings',
              'icon': 'settings',
              'action': 'system_settings',
              'badge': null,
            },
            {
              'title': 'View Reports',
              'icon': 'bar_chart',
              'action': 'view_reports',
              'badge': null,
            },
          ]);
          break;

        case UserRole.leader:
          actions.addAll([
            {
              'title': 'Join Requests',
              'icon': 'user_check',
              'action': 'join_requests',
              'badge': metrics.pendingJoinRequests > 0 ? metrics.pendingJoinRequests : null,
            },
            {
              'title': 'Manage Team',
              'icon': 'users',
              'action': 'manage_team',
              'badge': null,
            },
            {
              'title': 'Team Settings',
              'icon': 'settings',
              'action': 'team_settings',
              'badge': null,
            },
          ]);
          break;

        case UserRole.classLeader:
          actions.addAll([
            {
              'title': 'Team Performance',
              'icon': 'trending_up',
              'action': 'team_performance',
              'badge': null,
            },
            {
              'title': 'Assign Leads',
              'icon': 'share',
              'action': 'assign_leads',
              'badge': null,
            },
          ]);
          break;

        case UserRole.user:
          actions.addAll([
            {
              'title': 'Follow-ups Due',
              'icon': 'clock',
              'action': 'follow_ups',
              'badge': metrics.followUpsDue > 0 ? metrics.followUpsDue : null,
            },
            {
              'title': 'My Performance',
              'icon': 'bar_chart_2',
              'action': 'my_performance',
              'badge': null,
            },
          ]);
          break;
      }

      return actions;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Notifications Provider for Dashboard
final dashboardNotificationsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final metrics = ref.watch(dashboardMetricsProvider);
  final expiringUsers = ref.watch(expiringUsersProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) return [];

      List<Map<String, dynamic>> notifications = [];

      // Overdue follow-ups
      if (metrics.overdueFollowUps > 0) {
        notifications.add({
          'type': 'warning',
          'title': 'Overdue Follow-ups',
          'message': 'You have ${metrics.overdueFollowUps} overdue follow-up${metrics.overdueFollowUps > 1 ? 's' : ''}',
          'action': 'view_overdue',
        });
      }

      // Today's follow-ups
      if (metrics.followUpsDue > 0) {
        notifications.add({
          'type': 'info',
          'title': 'Follow-ups Due Today',
          'message': '${metrics.followUpsDue} lead${metrics.followUpsDue > 1 ? 's' : ''} need${metrics.followUpsDue == 1 ? 's' : ''} follow-up today',
          'action': 'view_follow_ups',
        });
      }

      // Pending join requests (for leaders)
      if (user.canManageUsers && metrics.pendingJoinRequests > 0) {
        notifications.add({
          'type': 'info',
          'title': 'Pending Join Requests',
          'message': '${metrics.pendingJoinRequests} user${metrics.pendingJoinRequests > 1 ? 's' : ''} waiting for approval',
          'action': 'view_requests',
        });
      }

      // Expiring accounts (for leaders/admin)
      if (user.canManageUsers && expiringUsers.isNotEmpty) {
        notifications.add({
          'type': 'warning',
          'title': 'Accounts Expiring Soon',
          'message': '${expiringUsers.length} account${expiringUsers.length > 1 ? 's' : ''} expiring within 30 days',
          'action': 'view_renewals',
        });
      }

      // Account expiry warning for current user
      if (user.isExpiringSoon) {
        notifications.add({
          'type': 'error',
          'title': 'Account Expiring Soon',
          'message': 'Your account expires in ${user.daysUntilExpiry} days',
          'action': 'contact_leader',
        });
      }

      return notifications;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Chart Data Providers
final leadsTrendChartProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final leads = ref.watch(leadsForCurrentUserProvider);

  return leads.when(
    data: (leadsList) {
      // Group leads by month for the last 6 months
      final now = DateTime.now();
      final chartData = <Map<String, dynamic>>[];

      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(now.year, now.month - i + 1, 1);

        final monthLeads = leadsList.where((lead) =>
        lead.createdAt.isAfter(month.subtract(const Duration(days: 1))) &&
            lead.createdAt.isBefore(nextMonth)
        ).length;

        chartData.add({
          'month': AppHelpers.formatDate(month).substring(3), // MM/yyyy
          'leads': monthLeads,
        });
      }

      return chartData;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final conversionRateChartProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final leadsByStatus = ref.watch(leadsByStatusProvider);

  final chartData = leadsByStatus.entries.map((entry) {
    return {
      'status': entry.key,
      'count': entry.value.length,
      'color': AppHelpers.getStatusColor(entry.key).value,
    };
  }).toList();

  return chartData;
});

// Helper Functions
Map<String, dynamic> _getPreviousPeriodData() {
  // This would typically fetch data from a previous time period
  // For now, returning mock data
  return {
    'totalLeads': 0,
    'conversionRate': 0.0,
  };
}

double _calculateGrowthRate(double current, double previous) {
  if (previous == 0) return current > 0 ? 100.0 : 0.0;
  return ((current - previous) / previous) * 100;
}

String _calculateActivityTrend() {
  // This would analyze recent activity patterns
  return 'increasing'; // or 'decreasing', 'stable'
}

String _getTopPerformingStatus(Map<String, int> leadsByStatus) {
  if (leadsByStatus.isEmpty) return 'None';

  final sortedEntries = leadsByStatus.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sortedEntries.first.key;
}

// Dashboard Refresh Provider
final dashboardRefreshProvider = StateNotifierProvider<DashboardRefreshNotifier, DateTime>((ref) {
  return DashboardRefreshNotifier();
});

class DashboardRefreshNotifier extends StateNotifier<DateTime> {
  DashboardRefreshNotifier() : super(DateTime.now());

  void refresh() {
    state = DateTime.now();
  }
}

// Last Updated Provider
final lastUpdatedProvider = Provider<String>((ref) {
  final lastRefresh = ref.watch(dashboardRefreshProvider);
  return AppHelpers.formatRelativeTime(lastRefresh);
});