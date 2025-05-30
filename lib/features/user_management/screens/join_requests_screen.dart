import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/models/join_request_model.dart';
import '../widgets/join_request_card.dart';

class JoinRequestsScreen extends ConsumerStatefulWidget {
  const JoinRequestsScreen({super.key});

  @override
  ConsumerState<JoinRequestsScreen> createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends ConsumerState<JoinRequestsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final joinRequests = ref.watch(joinRequestsForCurrentLeaderProvider);
    final isLoading = ref.watch(userManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null || !user.canManageUsers) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'You don\'t have permission to manage join requests',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // Header with statistics
              _buildHeader(joinRequests)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, duration: 600.ms),

              // Search Bar
              _buildSearchBar()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms),

              // Tab Bar
              _buildTabBar(joinRequests)
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 300.ms),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsList(joinRequests, 'all', isLoading, user),
                    _buildRequestsList(joinRequests, 'pending', isLoading, user),
                    _buildRequestsList(joinRequests, 'processed', isLoading, user),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: MinimalLoader()),
      ),
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
            LucideIcons.userPlus,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Join Requests'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'approve_all',
              child: Row(
                children: [
                  Icon(LucideIcons.checkCircle, size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Approve All Pending'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(LucideIcons.download, size: 16),
                  SizedBox(width: 8),
                  Text('Export Requests'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(AsyncValue<List<JoinRequestModel>> joinRequests) {
    return joinRequests.when(
      data: (requests) {
        final pending = requests.where((r) => r.isPending).length;
        final approved = requests.where((r) => r.isApproved).length;
        final rejected = requests.where((r) => r.isRejected).length;
        final urgent = requests.where((r) => r.isUrgent).length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: const Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Join Requests',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Row
              Row(
                children: [
                  _buildStatCard('Pending', pending.toString(), LucideIcons.clock,
                      pending > 0 ? AppColors.warning : AppColors.textSecondary),
                  _buildStatCard('Approved', approved.toString(), LucideIcons.checkCircle,
                      AppColors.success),
                  _buildStatCard('Rejected', rejected.toString(), LucideIcons.xCircle,
                      AppColors.error),
                  _buildStatCard('Urgent', urgent.toString(), LucideIcons.alertTriangle,
                      urgent > 0 ? AppColors.error : AppColors.textSecondary),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(height: 140),
      error: (_, __) => Container(height: 140),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: MinimalTextField(
        controller: _searchController,
        hint: 'Search by name or email...',
        prefixIcon: LucideIcons.search,
        onChanged: (value) {
          // Update search filter
          ref.read(userSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildTabBar(AsyncValue<List<JoinRequestModel>> joinRequests) {
    return joinRequests.when(
      data: (requests) {
        final total = requests.length;
        final pending = requests.where((r) => r.isPending).length;
        final processed = requests.where((r) => r.isActioned).length;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              _buildTab('All', total),
              _buildTab('Pending', pending,
                  color: pending > 0 ? AppColors.warning : null),
              _buildTab('Processed', processed),
            ],
          ),
        );
      },
      loading: () => Container(height: 48),
      error: (_, __) => Container(height: 48),
    );
  }

  Widget _buildTab(String label, int count, {Color? color}) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color ?? AppColors.neutral200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.labelSmall.copyWith(
                color: color != null ? AppColors.textOnPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
      AsyncValue<List<JoinRequestModel>> joinRequests,
      String filter,
      bool isLoading,
      UserModel currentUser,
      ) {
    return joinRequests.when(
      data: (requests) {
        final filteredRequests = _filterRequests(requests, filter);

        if (isLoading) {
          return const Center(child: MinimalLoader());
        }

        if (filteredRequests.isEmpty) {
          return _buildEmptyState(filter);
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: JoinRequestCard(
                  request: request,
                  onApprove: () => _approveRequest(request, currentUser),
                  onReject: () => _rejectRequest(request, currentUser),
                  onViewDetails: () => _viewRequestDetails(request),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                    .slideX(begin: -0.3, duration: 300.ms),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: MinimalLoader()),
      error: (error, _) => Center(
        child: EmptyState(
          icon: LucideIcons.alertCircle,
          title: 'Error Loading Requests',
          subtitle: error.toString(),
          actionText: 'Retry',
          onAction: _refreshData,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String title, subtitle;
    IconData icon;

    switch (filter) {
      case 'pending':
        icon = LucideIcons.checkCircle;
        title = 'No Pending Requests';
        subtitle = 'All caught up! No new join requests awaiting your approval.';
        break;
      case 'processed':
        icon = LucideIcons.fileCheck;
        title = 'No Processed Requests';
        subtitle = 'Requests you\'ve approved or rejected will appear here.';
        break;
      default:
        icon = LucideIcons.userPlus;
        title = 'No Join Requests';
        subtitle = 'When people request to join your team, they\'ll appear here.';
    }

    return Center(
      child: EmptyState(
        icon: icon,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  List<JoinRequestModel> _filterRequests(List<JoinRequestModel> requests, String filter) {
    switch (filter) {
      case 'pending':
        return requests.where((r) => r.isPending).toList();
      case 'processed':
        return requests.where((r) => r.isActioned).toList();
      default:
        return requests;
    }
  }

  Future<void> _refreshData() async {
    ref.invalidate(joinRequestsForCurrentLeaderProvider);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'approve_all':
        _approveAllPending();
        break;
      case 'export':
        _exportRequests();
        break;
    }
  }

  Future<void> _approveRequest(JoinRequestModel request, UserModel currentUser) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Approve Request',
      content: 'Approve ${request.requestingUserName} to join your team?',
      confirmText: 'Approve',
    );

    if (confirm == true) {
      try {
        await ref.read(userManagementProvider.notifier)
            .approveJoinRequest(request.requestId, currentUser.uid);

        if (mounted) {
          AppHelpers.showSuccessSnackbar(
              context,
              '${request.requestingUserName} has been approved!'
          );
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to approve request: $e');
        }
      }
    }
  }

  Future<void> _rejectRequest(JoinRequestModel request, UserModel currentUser) async {
    final reason = await _showRejectReasonDialog();
    if (reason != null) {
      try {
        await ref.read(userManagementProvider.notifier)
            .rejectJoinRequest(request.requestId, currentUser.uid);

        if (mounted) {
          AppHelpers.showSuccessSnackbar(
              context,
              '${request.requestingUserName}\'s request has been rejected'
          );
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to reject request: $e');
        }
      }
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject this request?'),
            SizedBox(height: 16),
            Text(
              'This action will deny the user access to your team.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('rejected'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _viewRequestDetails(JoinRequestModel request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    UserAvatar(
                      name: request.requestingUserName,
                      radius: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.requestingUserName,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            request.requestingUserEmail,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      status: request.statusDisplayName,
                      backgroundColor: request.status.color.withOpacity(0.1),
                      textColor: request.status.color,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Details
                _buildDetailRow('Request ID', request.requestId.substring(0, 8)),
                _buildDetailRow('Requested', AppHelpers.formatDateTime(request.requestedAt)),
                _buildDetailRow('Duration', request.formattedPendingDuration),
                if (request.isActioned) ...[
                  _buildDetailRow('Status', request.statusDisplayName),
                  if (request.actionedAt != null)
                    _buildDetailRow('Processed', AppHelpers.formatDateTime(request.actionedAt!)),
                ],

                const SizedBox(height: 32),

                // Priority indicator
                if (request.isUrgent)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.alertTriangle,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Urgent Request',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'This request has been pending for more than 3 days',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (request.isPending) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: MinimalButton(
                          text: 'Reject',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _rejectRequest(request, ref.read(currentUserProvider).value!);
                          },
                          isOutlined: true,
                          backgroundColor: AppColors.error,
                          textColor: AppColors.error,
                          icon: LucideIcons.xCircle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MinimalButton(
                          text: 'Approve',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _approveRequest(request, ref.read(currentUserProvider).value!);
                          },
                          backgroundColor: AppColors.success,
                          icon: LucideIcons.checkCircle,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveAllPending() async {
    final pendingRequests = ref.read(joinRequestsForCurrentLeaderProvider).value
        ?.where((r) => r.isPending).toList() ?? [];

    if (pendingRequests.isEmpty) {
      AppHelpers.showInfoSnackbar(context, 'No pending requests to approve');
      return;
    }

    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Approve All Pending',
      content: 'Approve all ${pendingRequests.length} pending requests?',
      confirmText: 'Approve All',
    );

    if (confirm == true) {
      final currentUser = ref.read(currentUserProvider).value!;

      for (final request in pendingRequests) {
        try {
          await ref.read(userManagementProvider.notifier)
              .approveJoinRequest(request.requestId, currentUser.uid);
        } catch (e) {
          // Continue with other requests even if one fails
        }
      }

      if (mounted) {
        AppHelpers.showSuccessSnackbar(
            context,
            'Approved ${pendingRequests.length} requests!'
        );
      }
    }
  }

  void _exportRequests() {
    AppHelpers.showInfoSnackbar(context, 'Export feature coming soon');
  }
} 8),
Text(
'Manage new team member requests and approvals',
style: AppTextStyles.bodyMedium.copyWith(
color: AppColors.textSecondary,
),
),
const SizedBox(height: