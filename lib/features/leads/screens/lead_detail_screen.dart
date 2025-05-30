import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/lead_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/models/lead_model.dart';
import '../../../core/models/settings_model.dart';
import '../widgets/remarks_section.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final String leadId;

  const LeadDetailScreen({
    super.key,
    required this.leadId,
  });

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _remarkController = TextEditingController();
  final _followUpController = TextEditingController();

  bool _isEditing = false;
  DateTime? _selectedFollowUpDate;
  SettingsModel? _settings;
  String? _selectedStatus;

  // Edit form controllers
  final Map<String, TextEditingController> _editControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _remarkController.dispose();
    _followUpController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser?.parentUid != null) {
      try {
        final settingsService = SettingsService();
        final settings = await settingsService.getSettings(currentUser!.parentUid!);
        setState(() {
          _settings = settings;
        });
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to load settings: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadAsync = ref.watch(leadProvider(widget.leadId));
    final currentUser = ref.watch(currentUserProvider);
    final isUpdating = ref.watch(leadManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }

        return leadAsync.when(
          data: (lead) {
            if (lead == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Lead Not Found')),
                body: const Center(
                  child: EmptyState(
                    icon: LucideIcons.searchX,
                    title: 'Lead Not Found',
                    subtitle: 'This lead may have been deleted or you don\'t have access to it',
                  ),
                ),
              );
            }

            return _buildLeadDetail(lead, user, isUpdating);
          },
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: MinimalLoader()),
          ),
          error: (error, _) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: EmptyState(
                icon: LucideIcons.alertCircle,
                title: 'Error Loading Lead',
                subtitle: error.toString(),
                actionText: 'Retry',
                onAction: () => ref.refresh(leadProvider(widget.leadId)),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: MinimalLoader())),
      error: (_, __) => const Scaffold(body: Center(child: Text('Authentication Error'))),
    );
  }

  Widget _buildLeadDetail(LeadModel lead, UserModel user, bool isUpdating) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(lead, user, isUpdating),
      body: Column(
        children: [
          // Lead Header
          _buildLeadHeader(lead)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, duration: 600.ms),

          // Tab Bar
          _buildTabBar()
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(lead, user),
                _buildDetailsTab(lead, user),
                _buildActivityTab(lead, user),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(lead, user),
    );
  }

  PreferredSizeWidget _buildAppBar(LeadModel lead, UserModel user, bool isUpdating) {
    return AppBar(
      title: Text(_isEditing ? 'Edit Lead' : 'Lead Details'),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        if (_isEditing) ...[
          TextButton(
            onPressed: isUpdating ? null : _cancelEdit,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: isUpdating ? null : () => _saveChanges(lead),
            child: Text(isUpdating ? 'Saving...' : 'Save'),
          ),
        ] else ...[
          IconButton(
            onPressed: () => _toggleEdit(lead),
            icon: const Icon(LucideIcons.edit),
            tooltip: 'Edit Lead',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, lead, user),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'call',
                child: Row(
                  children: [
                    Icon(LucideIcons.phone, size: 16),
                    SizedBox(width: 8),
                    Text('Call Client'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(LucideIcons.messageCircle, size: 16),
                    SizedBox(width: 8),
                    Text('WhatsApp'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(LucideIcons.copy, size: 16),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLeadHeader(LeadModel lead) {
    final statusColor = AppHelpers.getStatusColor(lead.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), AppColors.surface],
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
          // Title and Status
          Row(
            children: [
              Expanded(
                child: Text(
                  lead.leadTitle,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusBadge(
                status: lead.status,
                backgroundColor: statusColor.withOpacity(0.1),
                textColor: statusColor,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Key Information Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: LucideIcons.user,
                  label: 'Client',
                  value: lead.clientName,
                ),
              ),
              const SizedBox(width: 12),
              if (lead.clientPhone != null)
                Expanded(
                  child: _buildInfoCard(
                    icon: LucideIcons.phone,
                    label: 'Phone',
                    value: lead.clientPhone!,
                    onTap: () => _callClient(lead.clientPhone!),
                  ),
                ),
              const SizedBox(width: 12),
              if (lead.budget != null)
                Expanded(
                  child: _buildInfoCard(
                    icon: LucideIcons.indianRupee,
                    label: 'Budget',
                    value: AppHelpers.formatNumber(lead.budget!),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Timeline Info
          Row(
            children: [
              Icon(LucideIcons.clock, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Created ${AppHelpers.formatRelativeTime(lead.createdAt)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(LucideIcons.edit, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Updated ${AppHelpers.formatRelativeTime(lead.updatedAt)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (lead.followUpDate != null) ...[
                const SizedBox(width: 16),
                Icon(
                  lead.isFollowUpOverdue ? LucideIcons.alertCircle : LucideIcons.calendar,
                  size: 16,
                  color: lead.isFollowUpOverdue ? AppColors.error : AppColors.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  'Follow-up ${AppHelpers.formatTimeUntil(lead.followUpDate!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: lead.isFollowUpOverdue ? AppColors.error : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(LucideIcons.externalLink, size: 12, color: AppColors.primary),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Details'),
          Tab(text: 'Activity'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(LeadModel lead, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          _buildQuickActionsSection(lead, user)
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.3, duration: 600.ms),

          const SizedBox(height: 24),

          // Lead Progress
          _buildProgressSection(lead)
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.3, duration: 600.ms),

          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivitySection(lead)
              .animate()
              .fadeIn(duration: 600.ms, delay: 500.ms)
              .slideY(begin: 0.3, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(LeadModel lead, UserModel user) {
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
          Text(
            'Quick Actions',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: LucideIcons.phone,
                  label: 'Call',
                  onPressed: lead.clientPhone != null
                      ? () => _callClient(lead.clientPhone!)
                      : null,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: LucideIcons.messageCircle,
                  label: 'WhatsApp',
                  onPressed: lead.clientPhone != null
                      ? () => _openWhatsApp(lead.clientPhone!)
                      : null,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: LucideIcons.calendar,
                  label: 'Schedule',
                  onPressed: () => _scheduleFollowUp(lead),
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: LucideIcons.edit,
                  label: 'Update',
                  onPressed: () => _showQuickUpdateDialog(lead),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return MinimalButton(
      text: label,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: onPressed != null ? color : AppColors.neutral300,
      textColor: AppColors.textOnPrimary,
    );
  }

  Widget _buildProgressSection(LeadModel lead) {
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
          Text(
            'Lead Progress',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressIndicator(lead),
          const SizedBox(height: 16),
          Text(
            'Status: ${lead.status}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (lead.followUpDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Next Follow-up: ${AppHelpers.formatDate(lead.followUpDate!)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: lead.isFollowUpOverdue ? AppColors.error : AppColors.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(LeadModel lead) {
    final statuses = ['New', 'Contacted', 'Follow Up', 'Site Visit Scheduled', 'Visit Done', 'Negotiation', 'Converted'];
    final currentIndex = statuses.indexOf(lead.status);
    final progress = currentIndex >= 0 ? (currentIndex + 1) / statuses.length : 0.0;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.neutral200,
          valueColor: AlwaysStoppedAnimation<Color>(
            lead.isConverted ? AppColors.success : AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(LeadModel lead) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _tabController.animateTo(2),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (lead.remarks.isEmpty)
            const EmptyState(
              icon: LucideIcons.messageSquare,
              title: 'No Activity Yet',
              subtitle: 'Add remarks to track interactions with this lead',
            )
          else
            ...lead.remarks.take(3).map((remark) => _buildRemarkItem(remark)),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(LeadModel lead, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Fields
          if (lead.customFields.isNotEmpty)
            _buildCustomFieldsSection(lead)
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideY(begin: 0.3, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildCustomFieldsSection(LeadModel lead) {
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
          Text(
            'Lead Information',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...lead.customFields.entries.map((entry) =>
              _buildCustomFieldItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildCustomFieldItem(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              key,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value.toString(),
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(LeadModel lead, UserModel user) {
    return Column(
      children: [
        // Add Remark Section
        _buildAddRemarkSection(lead, user),

        // Remarks List
        Expanded(
          child: RemarksSection(
            remarks: lead.remarks,
            onAddRemark: (text) => _addRemark(lead, text, user),
          ),
        ),
      ],
    );
  }

  Widget _buildAddRemarkSection(LeadModel lead, UserModel user) {
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
          UserAvatar(
            name: user.name,
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MinimalTextField(
              controller: _remarkController,
              hint: 'Add a remark...',
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 12),
          MinimalButton(
            text: 'Add',
            onPressed: () => _addRemarkFromField(lead, user),
            icon: LucideIcons.send,
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkItem(RemarkModel remark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            name: remark.byName,
            radius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      remark.byName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppHelpers.formatRelativeTime(remark.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  remark.text,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(LeadModel lead, UserModel user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lead.hasFollowUpDue)
          FloatingActionButton(
            heroTag: 'followup',
            onPressed: () => _markFollowUpComplete(lead),
            backgroundColor: AppColors.warning,
            child: const Icon(LucideIcons.checkCircle, color: AppColors.textOnPrimary),
          ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'remark',
          onPressed: () => _showQuickRemarkDialog(lead, user),
          backgroundColor: AppColors.primary,
          child: const Icon(LucideIcons.plus, color: AppColors.textOnPrimary),
        ),
      ],
    ).animate()
        .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, delay: 1000.ms)
        .fadeIn(duration: 300.ms, delay: 1000.ms);
  }

  // Action Methods
  void _toggleEdit(LeadModel lead) {
    setState(() {
      _isEditing = true;
      _selectedStatus = lead.status;
      _selectedFollowUpDate = lead.followUpDate;
      _followUpController.text = lead.followUpDate != null
          ? AppHelpers.formatDate(lead.followUpDate!)
          : '';

      // Initialize edit controllers
      for (final entry in lead.customFields.entries) {
        _editControllers[entry.key] = TextEditingController(text: entry.value.toString());
      }
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _selectedStatus = null;
      _selectedFollowUpDate = null;
      _followUpController.clear();

      // Clear edit controllers
      for (final controller in _editControllers.values) {
        controller.dispose();
      }
      _editControllers.clear();
    });
  }

  Future<void> _saveChanges(LeadModel lead) async {
    try {
      final updateData = <String, dynamic>{
        'status': _selectedStatus ?? lead.status,
        'followUpDate': _selectedFollowUpDate,
      };

      // Add custom fields
      final customFields = <String, dynamic>{};
      for (final entry in _editControllers.entries) {
        customFields[entry.key] = entry.value.text;
      }
      updateData['customFields'] = customFields;

      await ref.read(leadManagementProvider.notifier).updateLead(lead.leadId, updateData);

      _cancelEdit();
      if (mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Lead updated successfully');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to update lead: $e');
      }
    }
  }

  void _handleMenuAction(String action, LeadModel lead, UserModel user) {
    switch (action) {
      case 'call':
        if (lead.clientPhone != null) _callClient(lead.clientPhone!);
        break;
      case 'whatsapp':
        if (lead.clientPhone != null) _openWhatsApp(lead.clientPhone!);
        break;
      case 'duplicate':
        _duplicateLead(lead);
        break;
      case 'delete':
        _deleteLead(lead);
        break;
    }
  }

  void _callClient(String phone) {
    AppHelpers.showInfoSnackbar(context, 'Calling $phone...');
    // Implement actual phone call functionality
  }

  void _openWhatsApp(String phone) {
    AppHelpers.showInfoSnackbar(context, 'Opening WhatsApp for $phone...');
    // Implement WhatsApp functionality
  }

  Future<void> _scheduleFollowUp(LeadModel lead) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      await ref.read(leadManagementProvider.notifier)
          .updateFollowUpDate(lead.leadId, date);

      if (mounted) {
        AppHelpers.showSuccessSnackbar(
            context,
            'Follow-up scheduled for ${AppHelpers.formatDate(date)}'
        );
      }
    }
  }

  Future<void> _showQuickUpdateDialog(LeadModel lead) async {
    if (_settings == null) return;

    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _settings!.customStatuses.map((status) => ListTile(
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

    if (newStatus != null && newStatus != lead.status) {
      await ref.read(leadManagementProvider.notifier)
          .updateLeadStatus(lead.leadId, newStatus);

      if (mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Status updated to $newStatus');
      }
    }
  }

  Future<void> _showQuickRemarkDialog(LeadModel lead, UserModel user) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Remark'),
        content: MinimalTextField(
          controller: controller,
          hint: 'Enter your remark...',
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await _addRemark(lead, result.trim(), user);
    }
  }

  Future<void> _addRemarkFromField(LeadModel lead, UserModel user) async {
    final text = _remarkController.text.trim();
    if (text.isNotEmpty) {
      await _addRemark(lead, text, user);
      _remarkController.clear();
    }
  }

  Future<void> _addRemark(LeadModel lead, String text, UserModel user) async {
    try {
      await ref.read(leadManagementProvider.notifier)
          .addRemark(lead.leadId, text, user.uid, user.name);

      if (mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Remark added successfully');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to add remark: $e');
      }
    }
  }

  Future<void> _markFollowUpComplete(LeadModel lead) async {
    await ref.read(leadManagementProvider.notifier)
        .updateFollowUpDate(lead.leadId, null);

    if (mounted) {
      AppHelpers.showSuccessSnackbar(context, 'Follow-up marked as complete');
    }
  }

  Future<void> _duplicateLead(LeadModel lead) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Duplicate Lead',
      content: 'This will create a copy of this lead with the same information.',
      confirmText: 'Duplicate',
    );

    if (confirm == true) {
      final duplicatedLead = lead.copyWith(
        leadId: '', // Will be assigned by Firestore
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'New',
        followUpDate: null,
        remarks: [], // Start with empty remarks
      );

      final leadId = await ref.read(leadManagementProvider.notifier)
          .createLead(duplicatedLead);

      if (leadId != null && mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Lead duplicated successfully');
        context.push('/leads/detail/$leadId');
      }
    }
  }

  Future<void> _deleteLead(LeadModel lead) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Lead',
      content: 'Are you sure you want to delete this lead? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirm == true) {
      await ref.read(leadManagementProvider.notifier).deleteLead(lead.leadId);

      if (mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Lead deleted successfully');
        context.pop();
      }
    }
  }
}