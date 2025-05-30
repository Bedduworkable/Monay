import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/models/user_model.dart';
import '../widgets/user_list_item.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    final filteredUsers = ref.watch(filteredUsersProvider);
    final isLoading = ref.watch(userManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null || !user.canManageUsers) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'You don\'t have permission to manage users',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(user),
          body: Column(
            children: [
              // Search and Filters
              _buildSearchAndFilters()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.3, duration: 300.ms),

              // Statistics Header
              _buildStatisticsHeader()
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms),

              // Tab Bar
              _buildTabBar()
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUsersList(filteredUsers, 'all', isLoading),
                    _buildUsersList(filteredUsers, 'leaders', isLoading),
                    _buildUsersList(filteredUsers, 'class_leaders', isLoading),
                    _buildUsersList(filteredUsers, 'telecallers', isLoading),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(user),
        );
      },
      loading: () => const Scaffold(body: Center(child: MinimalLoader())),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel user) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            LucideIcons.users,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Team Management'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        // View Toggle
        IconButton(
          onPressed: _toggleView,
          icon: Icon(_isGridView ? LucideIcons.list : LucideIcons.grid3x3),
          tooltip: _isGridView ? 'List View' : 'Grid View',
        ),

        // Refresh
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),

        // Menu
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(LucideIcons.download, size: 16),
                  SizedBox(width: 8),
                  Text('Export Users'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'bulk_renew',
              child: Row(
                children: [
                  Icon(LucideIcons.calendar, size: 16),
                  SizedBox(width: 8),
                  Text('Bulk Renewal'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          MinimalTextField(
            controller: _searchController,
            hint: 'Search by name, email, or role...',
            prefixIcon: LucideIcons.search,
            onChanged: (value) {
              ref.read(userSearchQueryProvider.notifier).state = value;
            },
          ),

          const SizedBox(height: 12),

          // Quick Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Users', 'all'),
                _buildFilterChip('Active', 'active'),
                _buildFilterChip('Expiring Soon', 'expiring'),
                _buildFilterChip('Unassigned', 'unassigned'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: false, // You can implement filter state here
        onSelected: (selected) {
          // Implement filter logic
        },
        backgroundColor: AppColors.backgroundSecondary,
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: AppTextStyles.bodySmall,
      ),
    );
  }

  Widget _buildStatisticsHeader() {
    final allLeaders = ref.watch(leaderUsersProvider);
    final allClassLeaders = ref.watch(classLeaderUsersProvider);
    final allTelecallers = ref.watch(telecallerUsersProvider);
    final expiringUsers = ref.watch(expiringUsersProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Leaders',
            allLeaders.when(
              data: (users) => users.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            LucideIcons.crown,
            color: AppColors.leaderColor,
          ),
          _buildStatItem(
            'Class Leaders',
            allClassLeaders.when(
              data: (users) => users.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            LucideIcons.userCheck,
            color: AppColors.classLeaderColor,
          ),
          _buildStatItem(
            'Telecallers',
            allTelecallers.when(
              data: (users) => users.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            LucideIcons.headphones,
            color: AppColors.userColor,
          ),
          _buildStatItem(
            'Expiring',
            expiringUsers.length.toString(),
            LucideIcons.alertTriangle,
            color: expiringUsers.isNotEmpty ? AppColors.warning : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
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
    );
  }

  Widget _buildTabBar() {
    final allLeaders = ref.watch(leaderUsersProvider);
    final allClassLeaders = ref.watch(classLeaderUsersProvider);
    final allTelecallers = ref.watch(telecallerUsersProvider);
    final filteredUsers = ref.watch(filteredUsersProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: [
          _buildTab('All', filteredUsers.length),
          _buildTab('Leaders', allLeaders.asData?.value.length ?? 0),
          _buildTab('Class Leaders', allClassLeaders.asData?.value.length ?? 0),
          _buildTab('Telecallers', allTelecallers.asData?.value.length ?? 0),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<UserModel> users, String filter, bool isLoading) {
    final filteredUsers = _filterUsers(users, filter);

    if (isLoading) {
      return const Center(child: MinimalLoader());
    }

    if (filteredUsers.isEmpty) {
      return _buildEmptyState(filter);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _isGridView
          ? _buildGridView(filteredUsers)
          : _buildListView(filteredUsers),
    );
  }

  Widget _buildEmptyState(String filter) {
    String title, subtitle;
    IconData icon;

    switch (filter) {
      case 'leaders':
        icon = LucideIcons.crown;
        title = 'No Leaders Found';
        subtitle = 'Create leader accounts to manage teams';
        break;
      case 'class_leaders':
        icon = LucideIcons.userCheck;
        title = 'No Class Leaders Found';
        subtitle = 'Promote telecallers to class leader role';
        break;
      case 'telecallers':
        icon = LucideIcons.headphones;
        title = 'No Telecallers Found';
        subtitle = 'Approve join requests to add telecallers';
        break;
      default:
        icon = LucideIcons.users;
        title = 'No Team Members';
        subtitle = 'Your team members will appear here';
    }

    return Center(
      child: EmptyState(
        icon: icon,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  Widget _buildGridView(List<UserModel> users) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListItem(
          user: user,
          onTap: () => _viewUserDetails(user),
          onPromote: () => _promoteUser(user),
          onRenew: () => _renewUser(user),
          onDeactivate: () => _deactivateUser(user),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideY(begin: 0.3, duration: 300.ms);
      },
    );
  }

  Widget _buildListView(List<UserModel> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UserListItem(
            user: user,
            isCompact: true,
            onTap: () => _viewUserDetails(user),
            onPromote: () => _promoteUser(user),
            onRenew: () => _renewUser(user),
            onDeactivate: () => _deactivateUser(user),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 30).ms)
              .slideX(begin: -0.3, duration: 300.ms),
        );
      },
    );
  }

  Widget? _buildFloatingActionButton(UserModel user) {
    if (!user.isAdmin) return null;

    return FloatingActionButton.extended(
      onPressed: () => _showCreateUserDialog(),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      icon: const Icon(LucideIcons.userPlus),
      label: const Text('Add User'),
    ).animate()
        .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, delay: 1000.ms)
        .fadeIn(duration: 300.ms, delay: 1000.ms);
  }

  List<UserModel> _filterUsers(List<UserModel> users, String filter) {
    switch (filter) {
      case 'leaders':
        return users.where((user) => user.isLeader).toList();
      case 'class_leaders':
        return users.where((user) => user.isClassLeader).toList();
      case 'telecallers':
        return users.where((user) => user.isUser).toList();
      default:
        return users;
    }
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  Future<void> _refreshData() async {
    ref.invalidate(filteredUsersProvider);
    ref.invalidate(leaderUsersProvider);
    ref.invalidate(classLeaderUsersProvider);
    ref.invalidate(telecallerUsersProvider);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportUsers();
        break;
      case 'bulk_renew':
        _bulkRenewUsers();
        break;
    }
  }

  void _viewUserDetails(UserModel user) {
    // Navigate to user detail screen
    AppHelpers.showInfoSnackbar(context, 'User details: ${user.name}');
  }

  Future<void> _promoteUser(UserModel user) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Promote User',
      content: 'Promote ${user.name} to Class Leader?',
      confirmText: 'Promote',
    );

    if (confirm == true) {
      try {
        await ref.read(userManagementProvider.notifier)
            .promoteUserToClassLeader(user.uid);

        if (mounted) {
          AppHelpers.showSuccessSnackbar(
            context,
            '${user.name} promoted to Class Leader!',
          );
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to promote user: $e');
        }
      }
    }
  }

  Future<void> _renewUser(UserModel user) async {
    final years = await _showRenewalDialog();
    if (years != null) {
      try {
        await ref.read(userManagementProvider.notifier)
            .renewUserAccount(user.uid, years);

        if (mounted) {
          AppHelpers.showSuccessSnackbar(
            context,
            '${user.name}\'s account renewed for $years year(s)!',
          );
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to renew account: $e');
        }
      }
    }
  }

  Future<void> _deactivateUser(UserModel user) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Deactivate User',
      content: 'Deactivate ${user.name}\'s account? They will lose access to the system.',
      confirmText: 'Deactivate',
    );

    if (confirm == true) {
      try {
        await ref.read(userManagementProvider.notifier)
            .deactivateUser(user.uid);

        if (mounted) {
          AppHelpers.showSuccessSnackbar(
            context,
            '${user.name}\'s account has been deactivated',
          );
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to deactivate user: $e');
        }
      }
    }
  }

  Future<int?> _showRenewalDialog() async {
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renew Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select renewal period:'),
            const SizedBox(height: 16),
            ...([1, 2, 3].map((years) => ListTile(
              title: Text('$years year${years > 1 ? 's' : ''}'),
              subtitle: Text('₹${(200 * years).toStringAsFixed(0)}'),
              onTap: () => Navigator.of(context).pop(years),
            ))),
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

  void _showCreateUserDialog() {
    AppHelpers.showInfoSnackbar(context, 'Create user feature coming soon');
  }

  void _exportUsers() {
    AppHelpers.showInfoSnackbar(context, 'Export feature coming soon');
  }

  void _bulkRenewUsers() {
    AppHelpers.showInfoSnackbar(context, 'Bulk renewal feature coming soon');
  }
}