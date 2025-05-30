import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../core/providers/lead_provider.dart';
import '../../../core/providers/auth_provider.dart';
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
    final filteredLeads = ref.watch(filteredLeadsProvider);
    final leadsByStatus = ref.watch(leadsByStatusProvider);
    final selectedLeads = ref.watch(selectedLeadsProvider);
    final isLoading = ref.watch(leadManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(selectedLeads),
          body: Column(
            children: [
              // Search and Filters
              _buildSearchAndFilters()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.3, duration: 300.ms),

              // Tab Bar
              _buildTabBar(leadsByStatus)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All Leads
                    _buildLeadsList(filteredLeads, isLoading),
                    // Active Leads
                    _buildLeadsList(
                      filteredLeads.where((lead) => lead.isActive).toList(),
                      isLoading,
                    ),
                    // Follow-ups
                    _buildLeadsList(
                      filteredLeads.where((lead) => lead.hasFollowUpDue).toList(),
                      isLoading,
                    ),
                    // Converted
                    _buildLeadsList(
                      filteredLeads.where((lead) => lead.isConverted).toList(),
                      isLoading,
                    ),
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

  PreferredSizeWidget _buildAppBar(Set<String> selectedLeads) {
    final hasSelection = selectedLeads.isNotEmpty;

    return AppBar(
      title: hasSelection
          ? Text('${selectedLeads.length} selected')
          : const Text('Leads'),
      leading: hasSelection
          ? IconButton(
        onPressed: () => ref.read(selectedLeadsProvider.notifier).clearSelection(),
        icon: const Icon(LucideIcons.x),
      )
          : null,
      actions: hasSelection
          ? _buildSelectionActions()
          : _buildDefaultActions(),
    );
  }

  List<Widget> _buildDefaultActions() {
    return [
      IconButton(
        onPressed: _toggleView,
        icon: Icon(_isGridView ? LucideIcons.list : LucideIcons.grid3x3),
        tooltip: _isGridView ? 'List View' : 'Grid View',
      ),
      IconButton(
        onPressed: _showFilterDialog,
        icon: const Icon(LucideIcons.filter),
        tooltip: 'Filter',
      ),
      IconButton(
        onPressed: _showSortDialog,
        icon: const Icon(LucideIcons.arrowUpDown),
        tooltip: 'Sort',
      ),
      const SizedBox(width: 8),
    ];
  }

  List<Widget> _buildSelectionActions() {
    return [
      IconButton(
        onPressed: _bulkUpdateStatus,
        icon: const Icon(LucideIcons.edit),
        tooltip: 'Update Status',
      ),
      IconButton(
        onPressed: _bulkAssign,
        icon: const Icon(LucideIcons.userPlus),
        tooltip: 'Assign',
      ),
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
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: MinimalTextField(
              controller: _searchController,
              hint: 'Search leads...',
              prefixIcon: LucideIcons.search,
              onChanged: (value) {
                ref.read(leadSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          const SizedBox(width: 12),

          // Status Filter
          _buildStatusFilter(),

          const SizedBox(width: 12),

          // Date Filter
          _buildDateFilter(),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final selectedStatus = ref.watch(leadStatusFilterProvider);

    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String?>(
        value: selectedStatus,
        decoration: const InputDecoration(
          labelText: 'Status',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('All Statuses'),
          ),
          ...['New', 'Contacted', 'Follow Up', 'Converted', 'Lost']
              .map((status) => DropdownMenuItem(
            value: status,
            child: Text(status),
          )),
        ],
        onChanged: (value) {
          ref.read(leadStatusFilterProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildDateFilter() {
    return OutlinedButton.icon(
      onPressed: _selectDateRange,
      icon: const Icon(LucideIcons.calendar, size: 18),
      label: const Text('Date'),
    );
  }

  Widget _buildTabBar(Map<String, List<LeadModel>> leadsByStatus) {
    final totalLeads = leadsByStatus.values.fold(0, (sum, leads) => sum + leads.length);
    final activeLeads = leadsByStatus.values
        .expand((leads) => leads)
        .where((lead) => lead.isActive)
        .length;
    final followUpLeads = leadsByStatus.values
        .expand((leads) => leads)
        .where((lead) => lead.hasFollowUpDue)
        .length;
    final convertedLeads = leadsByStatus.values
        .expand((leads) => leads)
        .where((lead) => lead.isConverted)
        .length;

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
          _buildTab('All', totalLeads),
          _buildTab('Active', activeLeads),
          _buildTab('Follow-ups', followUpLeads,
              color: followUpLeads > 0 ? AppColors.warning : null),
          _buildTab('Converted', convertedLeads,
              color: convertedLeads > 0 ? AppColors.success : null),
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
          const SizedBox(width: 4),
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

  Widget _buildLeadsList(List<LeadModel> leads, bool isLoading) {
    if (isLoading) {
      return const Center(child: MinimalLoader());
    }

    if (leads.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: LucideIcons.target,
          title: 'No Leads Found',
          subtitle: 'Start by adding your first lead or adjust your filters',
          actionText: 'Add Lead',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(dashboardRefreshProvider.notifier).refresh();
      },
      child: _isGridView ? _buildGridView(leads) : _buildListView(leads),
    );
  }

  Widget _buildGridView(List<LeadModel> leads) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
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
      onPressed: _navigateToAddLead,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      icon: const Icon(LucideIcons.plus),
      label: const Text('Add Lead'),
    );
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  Future<void> _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: ref.read(leadDateFilterProvider),
    );

    if (dateRange != null) {
      ref.read(leadDateFilterProvider.notifier).state = dateRange;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Leads'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Advanced filtering options coming soon...'),
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Leads'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Updated Date'),
              onTap: () {
                ref.read(leadSortProvider.notifier).updateSort('updatedAt');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Created Date'),
              onTap: () {
                ref.read(leadSortProvider.notifier).updateSort('createdAt');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Status'),
              onTap: () {
                ref.read(leadSortProvider.notifier).updateSort('status');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Follow-up Date'),
              onTap: () {
                ref.read(leadSortProvider.notifier).updateSort('followUpDate');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLeadSelection(String leadId) {
    ref.read(selectedLeadsProvider.notifier).toggleLead(leadId);
  }

  void _navigateToLeadDetail(String leadId) {
    context.push('/leads/detail/$leadId');
  }

  void _navigateToAddLead() {
    context.push('/leads/add');
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
          'Updated ${selectedLeads.length} lead(s)',
        );
      }
    }
  }

  Future<void> _bulkAssign() async {
    final selectedLeads = ref.read(selectedLeadsProvider);
    if (selectedLeads.isEmpty) return;

    // Show user selector dialog
    AppHelpers.showInfoSnackbar(context, 'Assign feature coming soon');
  }

  Future<void> _bulkDelete() async {
    final selectedLeads = ref.read(selectedLeadsProvider);
    if (selectedLeads.isEmpty) return;

    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Leads',
      content: 'Are you sure you want to delete ${selectedLeads.length} lead(s)?',
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
        title: const Text('Select Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'New', 'Contacted', 'Follow Up', 'Site Visit Scheduled',
            'Visit Done', 'Negotiation', 'Converted', 'Lost'
          ].map((status) => ListTile(
            title: Text(status),
            onTap: () => Navigator.of(context).pop(status),
          )).toList(),
        ),
      ),
    );
  }
}