import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/lead_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/models/lead_model.dart';
import '../widgets/lead_card.dart';

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    final allLeads = ref.watch(leadsForCurrentUserProvider);
    final selectedLeads = ref.watch(selectedLeadsProvider);
    final isLoading = ref.watch(leadManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(selectedLeads, user),
          body: Column(
            children: [
              // Search and Filters Section
              _buildSearchAndFilters()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.3, duration: 300.ms),

              // Statistics Header
              _buildStatisticsHeader(allLeads)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms),

              // Tab Bar
              _buildTabBar(allLeads)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeadsList(allLeads, 'all', isLoading),
                    _buildLeadsList(allLeads, 'active', isLoading),
                    _buildLeadsList(allLeads, 'followup', isLoading),
                    _buildLeadsList(allLeads, 'converted', isLoading),
                    _buildLeadsList(allLeads, 'overdue', isLoading),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(),
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

  PreferredSizeWidget _buildAppBar(Set<String> selectedLeads, UserModel user) {
    final hasSelection = selectedLeads.isNotEmpty;

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      title: hasSelection
          ? Text('${selectedLeads.length} selected')
          : Row(
        children: [
          Icon(
            LucideIcons.target,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('My Leads'),
        ],
      ),
      leading: hasSelection
          ? IconButton(
        onPressed: () => ref.read(selectedLeadsProvider.notifier).clearSelection(),
        icon: const Icon(LucideIcons.x),
      )
          : null,
      actions: hasSelection
          ? _buildSelectionActions(user)
          : _buildDefaultActions(),
    );
  }

  List<Widget> _buildDefaultActions() {
    return [
      // View Toggle
      IconButton(
        onPressed: _toggleView,
        icon: Icon(_isGridView ? LucideIcons.list : LucideIcons.grid3x3),
        tooltip: _isGridView ? 'List View' : 'Grid View',
      ),

      // Sort
      PopupMenuButton<String>(
        icon: const Icon(LucideIcons.arrowUpDown),
        tooltip: 'Sort',
        onSelected: _handleSort,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'updated_desc',
            child: Row(
              children: [
                Icon(LucideIcons.clock, size: 16),
                SizedBox(width: 8),
                Text('Recently Updated'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'created_desc',
            child: Row(
              children: [
                Icon(LucideIcons.plus, size: 16),
                SizedBox(width: 8),
                Text('Recently Created'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'name_asc',
            child: Row(
              children: [
                Icon(LucideIcons.sortAsc, size: 16),
                SizedBox(width: 8),
                Text('Name A-Z'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'status_asc',
            child: Row(
              children: [
                Icon(LucideIcons.flag, size: 16),
                SizedBox(width: 8),
                Text('Status'),
              ],
            ),
          ),
        ],
      ),

      // More Options
      PopupMenuButton<String>(
        icon: const Icon(LucideIcons.moreVertical),
        onSelected: _handleMenuAction,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'refresh',
            child: Row(
              children: [
                Icon(LucideIcons.refreshCw, size: 16),
                SizedBox(width: 8),
                Text('Refresh'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                Icon(LucideIcons.download, size: 16),
                SizedBox(width: 8),
                Text('Export'),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }

  List<Widget> _buildSelectionActions(UserModel user) {
    return [
      // Update Status
      IconButton(
        onPressed: _bulkUpdateStatus,
        icon: const Icon(LucideIcons.edit),
        tooltip: 'Update Status',
      ),

      // Assign (if user can assign)
      if (user.canAssignLeads)
        IconButton(
          onPressed: _bulkAssign,
          icon: const Icon(LucideIcons.userPlus),
          tooltip: 'Assign',
        ),

      // Delete
      IconButton(
        onPressed: _bulkDelete,
        icon: const Icon(LucideIcons.trash2, color: AppColors.error),
        tooltip: 'Delete',
      ),
      const SizedBox(width: 8),
    ];
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
            hint: 'Search by name, project, phone...',
            prefixIcon: LucideIcons.search,
            onChanged: (value) {
              ref.read(leadSearchQueryProvider.notifier).state = value;
            },
          ),

          const SizedBox(height: 12),

          // Quick Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Today\'s Follow-ups', 'today'),
                _buildFilterChip('This Week', 'week'),
                _buildFilterChip('High Priority', 'priority'),
                _buildFilterChip('New', 'new'),
                _buildFilterChip('Hot Leads', 'hot'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
          _applyFilter(value);
        },
        backgroundColor: AppColors.backgroundSecondary,
        selectedColor: AppColors.primary.withOpacity(0.1),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatisticsHeader(AsyncValue<List<LeadModel>> allLeads) {
    return allLeads.when(
      data: (leads) {
        final total = leads.length;
        final active = leads.where((l) => l.isActive).length;
        final converted = leads.where((l) => l.isConverted).length;
        final followUps = leads.where((l) => l.hasFollowUpDue).length;
        final conversionRate = total > 0 ? (converted / total * 100) : 0.0;

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
              _buildStatItem('Total', total.toString(), LucideIcons.target),
              _buildStatItem('Active', active.toString(), LucideIcons.play),
              _buildStatItem('Converted', converted.toString(), LucideIcons.checkCircle,
                  color: AppColors.success),
              _buildStatItem('Follow-ups', followUps.toString(), LucideIcons.clock,
                  color: followUps > 0 ? AppColors.warning : null),
              _buildStatItem('Rate', '${conversionRate.toStringAsFixed(1)}%',
                  LucideIcons.trendingUp, color: AppColors.primary),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
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

  Widget _buildTabBar(AsyncValue<List<LeadModel>> allLeads) {
    return allLeads.when(
      data: (leads) {
        final total = leads.length;
        final active = leads.where((l) => l.isActive).length;
        final followUps = leads.where((l) => l.hasFollowUpDue).length;
        final converted = leads.where((l) => l.isConverted).length;
        final overdue = leads.where((l) => l.isFollowUpOverdue).length;

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
              _buildTab('All', total),
              _buildTab('Active', active),
              _buildTab('Follow-ups', followUps, color: followUps > 0 ? AppColors.warning : null),
              _buildTab('Converted', converted, color: converted > 0 ? AppColors.success : null),
              _buildTab('Overdue', overdue, color: overdue > 0 ? AppColors.error : null),
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

  Widget _buildLeadsList(AsyncValue<List<LeadModel>> allLeads, String filter, bool isLoading) {
    return allLeads.when(
      data: (leads) {
        final filteredLeads = _filterLeads(leads, filter);

        if (isLoading) {
          return const Center(child: MinimalLoader());
        }

        if (filteredLeads.isEmpty) {
          return _buildEmptyState(filter);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.read(dashboardRefreshProvider.notifier).refresh();
          },
          child: _isGridView
              ? _buildGridView(filteredLeads)
              : _buildListView(filteredLeads),
        );
      },
      loading: () => const Center(child: MinimalLoader()),
      error: (error, _) => Center(
        child: EmptyState(
          icon: LucideIcons.alertCircle,
          title: 'Error Loading Leads',
          subtitle: error.toString(),
          actionText: 'Retry',
          onAction: () => ref.refresh(leadsForCurrentUserProvider),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String title, subtitle, actionText;
    IconData icon;

    switch (filter) {
      case 'followup':
        icon = LucideIcons.clock;
        title = 'No Follow-ups Due';
        subtitle = 'Great! You\'re caught up with all your follow-ups';
        actionText = 'Add Lead';
        break;
      case 'converted':
        icon = LucideIcons.checkCircle;
        title = 'No Converted Leads Yet';
        subtitle = 'Keep working on your leads to see conversions here';
        actionText = 'View Active Leads';
        break;
      case 'overdue':
        icon = LucideIcons.alertTriangle;
        title = 'No Overdue Follow-ups';
        subtitle = 'Excellent! You\'re staying on top of your follow-ups';
        actionText = 'Add Lead';
        break;
      default:
        icon = LucideIcons.target;
        title = 'No Leads Found';
        subtitle = 'Start building your pipeline by adding your first lead';
        actionText = 'Add Lead';
    }

    return Center(
      child: EmptyState(
        icon: icon,
        title: title,
        subtitle: subtitle,
        actionText: actionText,
        onAction: () => context.push('/leads/add'),
      ),
    );
  }

  Widget _buildGridView(List<LeadModel> leads) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return LeadCard(
          lead: lead,
          onTap: () => _navigateToLeadDetail(lead.leadId),
          onLongPress: () => _toggleLeadSelection(lead.leadId),
          isSelected: ref.watch(selectedLeadsProvider).contains(lead.leadId),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideY(begin: 0.3, duration: 300.ms);
      },
    );
  }

  Widget _buildListView(List<LeadModel> leads) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LeadCard(
            lead: lead,
            isCompact: true,
            onTap: () => _navigateToLeadDetail(lead.leadId),
            onLongPress: () => _toggleLeadSelection(lead.leadId),
            isSelected: ref.watch(selectedLeadsProvider).contains(lead.leadId),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 30).ms)
              .slideX(begin: -0.3, duration: 300.ms),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/leads/add'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      icon: const Icon(LucideIcons.plus),
      label: const Text('Add Lead'),
    ).animate()
        .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, delay: 1000.ms)
        .fadeIn(duration: 300.ms, delay: 1000.ms);
  }

  List<LeadModel> _filterLeads(List<LeadModel> leads, String filter) {
    switch (filter) {
      case 'active':
        return leads.where((lead) => lead.isActive).toList();
      case 'followup':
        return leads.where((lead) => lead.hasFollowUpDue).toList();
      case 'converted':
        return leads.where((lead) => lead.isConverted).toList();
      case 'overdue':
        return leads.where((lead) => lead.isFollowUpOverdue).toList();
      default:
        return leads;
    }
  }

  void _applyFilter(String filter) {
    // This could update a provider for more complex filtering
    // For now, the tab system handles basic filtering
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _handleSort(String sortType) {
    // Update sort in provider
    final sortBy = sortType.split('_')[0];
    ref.read(leadSortProvider.notifier).updateSort(sortBy);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        ref.read(dashboardRefreshProvider.notifier).refresh();
        AppHelpers.showSuccessSnackbar(context, 'Leads refreshed');
        break;
      case 'export':
        _exportLeads();
        break;
    }
  }

  void _toggleLeadSelection(String leadId) {
    ref.read(selectedLeadsProvider.notifier).toggleLead(leadId);
  }

  void _navigateToLeadDetail(String leadId) {
    context.push('/leads/detail/$leadId');
  }

  Future<void> _bulkUpdateStatus() async {
    final selectedLeads = ref.read(selectedLeadsProvider);
    if (selectedLeads.isEmpty) return;

    final newStatus = await _showStatusSelector();
    if (newStatus != null) {
      await ref.read(leadAssignmentProvider.notifier)
          .bulkUpdateLeadStatus(selectedLeads.toList(), newStatus);

      if (mounted) {
        ref.read(selectedLeadsProvider.notifier).clearSelection();
        AppHelpers.showSuccessSnackbar(
          context,
          'Updated ${selectedLeads.length} lead(s) to $newStatus',
        );
      }
    }
  }

  Future<void> _bulkAssign() async {
    final selectedLeads = ref.read(selectedLeadsProvider);
    if (selectedLeads.isEmpty) return;

    // Show user selector dialog - simplified for now
    AppHelpers.showInfoSnackbar(context, 'Bulk assign feature coming soon');
  }

  Future<void> _bulkDelete() async {
    final selectedLeads = ref.read(selectedLeadsProvider);
    if (selectedLeads.isEmpty) return;

    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Leads',
      content: 'Are you sure you want to delete ${selectedLeads.length} lead(s)? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirm == true) {
      await ref.read(leadAssignmentProvider.notifier)
          .bulkDeleteLeads(selectedLeads.toList());

      if (mounted) {
        ref.read(selectedLeadsProvider.notifier).clearSelection();
        AppHelpers.showSuccessSnackbar(
          context,
          'Deleted ${selectedLeads.length} lead(s)',
        );
      }
    }
  }

  Future<String?> _showStatusSelector() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'New', 'Contacted', 'Follow Up', 'Site Visit Scheduled',
            'Visit Done', 'Negotiation', 'Converted', 'Lost'
          ].map((status) => ListTile(
            title: Text(status),
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppHelpers.getStatusColor(status),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onTap: () => Navigator.of(context).pop(status),
          )).toList(),
        ),
      ),
    );
  }

  void _exportLeads() {
    // Export functionality
    AppHelpers.showInfoSnackbar(context, 'Export feature coming soon');
  }
}