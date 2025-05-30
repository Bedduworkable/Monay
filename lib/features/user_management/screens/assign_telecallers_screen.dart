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
import '../../../core/models/user_model.dart';

class AssignTelecallersScreen extends ConsumerStatefulWidget {
  const AssignTelecallersScreen({super.key});

  @override
  ConsumerState<AssignTelecallersScreen> createState() => _AssignTelecallersScreenState();
}

class _AssignTelecallersScreenState extends ConsumerState<AssignTelecallersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final Set<String> _selectedTelecallers = {};
  UserModel? _selectedClassLeader;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final availableTelecallers = ref.watch(availableTelecallersForAssignmentProvider);
    final assignedTelecallers = ref.watch(assignedTelecallersProvider);
    final classLeaders = ref.watch(classLeaderUsersProvider);
    final isLoading = ref.watch(userManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null || !user.canManageUsers) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'You don\'t have permission to assign telecallers',
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
              _buildHeader(availableTelecallers, assignedTelecallers, classLeaders)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, duration: 600.ms),

              // Search and Class Leader Selection
              _buildControlsSection(classLeaders)
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms),

              // Tab Bar
              _buildTabBar(availableTelecallers, assignedTelecallers)
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 300.ms),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTelecallersList(availableTelecallers, 'available', isLoading),
                    _buildTelecallersList(assignedTelecallers, 'assigned', isLoading),
                  ],
                ),
              ),

              // Bottom Action Bar
              if (_selectedTelecallers.isNotEmpty || _selectedClassLeader != null)
                _buildBottomActionBar()
                    .animate()
                    .slideY(begin: 1.0, duration: 300.ms)
                    .fadeIn(duration: 300.ms),
            ],
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
            LucideIcons.userCheck,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Assign Telecallers'),
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
              value: 'bulk_assign',
              child: Row(
                children: [
                  Icon(LucideIcons.users, size: 16),
                  SizedBox(width: 8),
                  Text('Bulk Assignment'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'auto_balance',
              child: Row(
                children: [
                  Icon(LucideIcons.scale, size: 16),
                  SizedBox(width: 8),
                  Text('Auto Balance Teams'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(
      List<UserModel> available,
      List<UserModel> assigned,
      AsyncValue<List<UserModel>> classLeaders,
      ) {
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
            'Team Assignment',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assign telecallers to class leaders for better team management',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Row
          Row(
            children: [
              _buildStatCard(
                'Available',
                available.length.toString(),
                LucideIcons.userPlus,
                AppColors.warning,
              ),
              _buildStatCard(
                'Assigned',
                assigned.length.toString(),
                LucideIcons.userCheck,
                AppColors.success,
              ),
              _buildStatCard(
                'Class Leaders',
                classLeaders.when(
                  data: (leaders) => leaders.length.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
                LucideIcons.users,
                AppColors.primary,
              ),
              _buildStatCard(
                'Selected',
                _selectedTelecallers.length.toString(),
                LucideIcons.checkSquare,
                _selectedTelecallers.isNotEmpty ? AppColors.info : AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsSection(AsyncValue<List<UserModel>> classLeaders) {
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
            hint: 'Search telecallers...',
            prefixIcon: LucideIcons.search,
            onChanged: (value) {
              ref.read(userSearchQueryProvider.notifier).state = value;
            },
          ),

          const SizedBox(height: 16),

          // Class Leader Selection
          Row(
            children: [
              Icon(
                LucideIcons.target,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Assign to Class Leader:',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          classLeaders.when(
            data: (leaders) {
              if (leaders.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: AppColors.info,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No class leaders available for assignment',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: leaders.map((leader) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildClassLeaderChip(leader),
                  )).toList(),
                ),
              );
            },
            loading: () => const Center(child: MinimalLoader()),
            error: (_, __) => const Text('Error loading class leaders'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassLeaderChip(UserModel leader) {
    final isSelected = _selectedClassLeader?.uid == leader.uid;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedClassLeader = isSelected ? null : leader;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(
              name: leader.name,
              radius: 12,
              backgroundColor: AppHelpers.getRoleColor(leader.role),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leader.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${leader.assignedTelecallerUids.length} assigned',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                LucideIcons.check,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(List<UserModel> available, List<UserModel> assigned) {
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
          _buildTab('Available', available.length, color: AppColors.warning),
          _buildTab('Assigned', assigned.length, color: AppColors.success),
        ],
      ),
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

  Widget _buildTelecallersList(List<UserModel> telecallers, String type, bool isLoading) {
    if (isLoading) {
      return const Center(child: MinimalLoader());
    }

    if (telecallers.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: telecallers.length,
        itemBuilder: (context, index) {
          final telecaller = telecallers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTelecallerCard(telecaller, type)
                .animate()
                .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                .slideX(begin: -0.3, duration: 300.ms),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    final isAvailable = type == 'available';

    return Center(
      child: EmptyState(
        icon: isAvailable ? LucideIcons.userPlus : LucideIcons.userCheck,
        title: isAvailable ? 'No Available Telecallers' : 'No Assigned Telecallers',
        subtitle: isAvailable
            ? 'All telecallers are currently assigned to class leaders'
            : 'No telecallers have been assigned to class leaders yet',
      ),
    );
  }

  Widget _buildTelecallerCard(UserModel telecaller, String type) {
    final isSelected = _selectedTelecallers.contains(telecaller.uid);
    final isAvailable = type == 'available';

    return GestureDetector(
      onTap: () => _toggleTelecallerSelection(telecaller.uid),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Selection checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(
                LucideIcons.check,
                size: 14,
                color: AppColors.textOnPrimary,
              )
                  : null,
            ),

            const SizedBox(width: 12),

            // User info
            UserAvatar(
              name: telecaller.name,
              radius: 20,
              backgroundColor: AppHelpers.getRoleColor(telecaller.role),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    telecaller.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    telecaller.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Joined ${AppHelpers.formatRelativeTime(telecaller.createdAt)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAvailable ? 'Available' : 'Assigned',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isAvailable ? AppColors.warning : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selection summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.info,
                  size: 16,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedTelecallers.isNotEmpty
                        ? '${_selectedTelecallers.length} telecaller(s) selected'
                        : 'Select telecallers and a class leader to assign',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: MinimalButton(
                  text: 'Clear Selection',
                  onPressed: _clearSelection,
                  isOutlined: true,
                  icon: LucideIcons.x,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MinimalButton(
                  text: 'Assign Selected',
                  onPressed: (_selectedTelecallers.isNotEmpty && _selectedClassLeader != null)
                      ? _assignSelected
                      : null,
                  icon: LucideIcons.userCheck,
                  backgroundColor: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleTelecallerSelection(String telecallerUid) {
    setState(() {
      if (_selectedTelecallers.contains(telecallerUid)) {
        _selectedTelecallers.remove(telecallerUid);
      } else {
        _selectedTelecallers.add(telecallerUid);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedTelecallers.clear();
      _selectedClassLeader = null;
    });
  }

  Future<void> _assignSelected() async {
    if (_selectedTelecallers.isEmpty || _selectedClassLeader == null) return;

    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Assign Telecallers',
      content: 'Assign ${_selectedTelecallers.length} telecaller(s) to ${_selectedClassLeader!.name}?',
      confirmText: 'Assign',
    );

    if (confirm == true) {
      try {
        for (final telecallerUid in _selectedTelecallers) {
          await ref.read(userManagementProvider.notifier)
              .assignTelecallerToClassLeader(telecallerUid, _selectedClassLeader!.uid);
        }

        if (mounted) {
          AppHelpers.showSuccessSnackbar(
            context,
            'Successfully assigned ${_selectedTelecallers.length} telecaller(s) to ${_selectedClassLeader!.name}',
          );
          _clearSelection();
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to assign telecallers: $e');
        }
      }
    }
  }

  Future<void> _refreshData() async {
    ref.invalidate(availableTelecallersForAssignmentProvider);
    ref.invalidate(assignedTelecallersProvider);
    ref.invalidate(classLeaderUsersProvider);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'bulk_assign':
        _showBulkAssignDialog();
        break;
      case 'auto_balance':
        _autoBalanceTeams();
        break;
    }
  }

  void _showBulkAssignDialog() {
    AppHelpers.showInfoSnackbar(context, 'Bulk assignment feature coming soon');
  }

  void _autoBalanceTeams() {
    AppHelpers.showInfoSnackbar(context, 'Auto balance feature coming soon');
  }
}