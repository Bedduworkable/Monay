import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart'; // Add this import for UUID generation

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart'; // This needs to be created
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/models/settings_model.dart'; // Ensure SettingsModel is imported

class ManageStatusesScreen extends ConsumerStatefulWidget {
  const ManageStatusesScreen({super.key});

  @override
  ConsumerState<ManageStatusesScreen> createState() => _ManageStatusesScreenState();
}

class _ManageStatusesScreenState extends ConsumerState<ManageStatusesScreen> {
  final _addStatusController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _newStatusError;

  @override
  void dispose() {
    _addStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final settingsAsync = ref.watch(settingsProvider); // Assuming a settingsProvider exists
    final settingsLoading = ref.watch(settingsManagementLoadingProvider); // This needs to be created

    return currentUser.when(
      data: (user) {
        if (user == null || !user.canManageSettings) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'You don\'t have permission to manage statuses',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: settingsAsync.when(
            data: (settings) => _buildBody(user, settings, settingsLoading),
            loading: () => const Center(child: MinimalLoader()),
            error: (error, stack) => Center(
              child: EmptyState(
                icon: LucideIcons.alertCircle,
                title: 'Error Loading Settings',
                subtitle: error.toString(),
                actionText: 'Retry',
                onAction: () => ref.invalidate(settingsProvider),
              ),
            ),
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
            LucideIcons.flag,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Manage Lead Statuses'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(settingsProvider),
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(UserModel user, SettingsModel settings, bool isLoading) {
    return Column(
      children: [
        _buildHeader()
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, duration: 600.ms),

        const SizedBox(height: 24),

        _buildAddStatusSection(settings, isLoading)
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, duration: 600.ms),

        const SizedBox(height: 24),

        _buildCurrentStatusesSection(settings, isLoading)
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.3, duration: 600.ms),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.surface],
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
            'Customize Lead Statuses',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define and reorder the lead statuses relevant to your team\'s workflow.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(LucideIcons.info, size: 16, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Changes here affect all leads and users under your management.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddStatusSection(SettingsModel settings, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: MinimalTextField(
                  controller: _addStatusController,
                  hint: 'Enter new status name (e.g., "Site Visit")',
                  prefixIcon: LucideIcons.plusCircle,
                  enabled: !isLoading,
                  validator: (value) {
                    final validationResult = AppValidators.validateCustomStatus(value ?? '', settings.customStatuses);
                    setState(() {
                      _newStatusError = validationResult;
                    });
                    return validationResult;
                  },
                ),
              ),
              const SizedBox(width: 12),
              MinimalButton(
                text: 'Add Status',
                onPressed: isLoading ? null : () => _addStatus(settings),
                isLoading: isLoading,
                icon: LucideIcons.plus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatusesSection(SettingsModel settings, bool isLoading) {
    if (settings.customStatuses.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.flagOff,
        title: 'No Custom Statuses',
        subtitle: 'Add your first lead status using the field above.',
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
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
                'Current Statuses (${settings.customStatuses.length})',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: settings.customStatuses.length,
                  onReorder: isLoading ? (oldIndex, newIndex) {} : (oldIndex, newIndex) {
                    _reorderStatuses(settings, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final status = settings.customStatuses[index];
                    return _buildStatusListItem(status, settings, isLoading).key!,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusListItem(String status, SettingsModel settings, bool isLoading) {
    final statusColor = AppHelpers.getStatusColor(status);
    final isDefault = AppConstants.defaultLeadStatuses.contains(status);

    return Dismissible(
      key: ValueKey(status),
      direction: isDefault ? DismissDirection.none : DismissDirection.endToStart,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _removeStatus(status, settings);
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppColors.error,
        child: const Icon(LucideIcons.trash2, color: AppColors.textOnPrimary),
      ),
      confirmDismiss: (direction) => _confirmRemoveStatus(status),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Icon(LucideIcons.flag, size: 18, color: statusColor),
          ),
          title: Text(
            status,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: isDefault
              ? Text(
            'Default status',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          )
              : null,
          trailing: isDefault
              ? Tooltip(
            message: 'Default statuses cannot be removed',
            child: Icon(LucideIcons.lock, size: 16, color: AppColors.neutral400),
          )
              : Icon(LucideIcons.gripVertical, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Future<void> _addStatus(SettingsModel settings) async {
    if (_formKey.currentState?.validate() == true) {
      final statusName = _addStatusController.text.trim();
      final currentUser = ref.read(currentUserProvider).value;

      if (currentUser == null || currentUser.parentUid == null) {
        AppHelpers.showErrorSnackbar(context, 'Could not determine leader ID.');
        return;
      }

      try {
        await ref.read(settingsManagementProvider.notifier).addCustomStatus(
          currentUser.parentUid!,
          statusName,
        );
        if (mounted) {
          AppHelpers.showSuccessSnackbar(context, 'Status "$statusName" added successfully!');
          _addStatusController.clear();
          setState(() {
            _newStatusError = null; // Clear error after successful addition
          });
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to add status: ${e.toString().split(':').last}');
        }
      }
    }
  }

  Future<bool?> _confirmRemoveStatus(String status) async {
    return await AppHelpers.showConfirmDialog(
      context,
      title: 'Remove Status',
      content: 'Are you sure you want to remove "$status"? Leads currently with this status will be unaffected, but it won\'t be available for new assignments.',
      confirmText: 'Remove',
    );
  }

  Future<void> _removeStatus(String status, SettingsModel settings) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.parentUid == null) {
      AppHelpers.showErrorSnackbar(context, 'Could not determine leader ID.');
      return;
    }

    try {
      await ref.read(settingsManagementProvider.notifier).removeCustomStatus(
        currentUser.parentUid!,
        status,
      );
      if (mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Status "$status" removed successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to remove status: ${e.toString().split(':').last}');
      }
    }
  }

  Future<void> _reorderStatuses(SettingsModel settings, int oldIndex, int newIndex) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.parentUid == null) {
      AppHelpers.showErrorSnackbar(context, 'Could not determine leader ID.');
      return;
    }

    // Adjust newIndex when moving item down
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<String> updatedList = List.from(settings.customStatuses);
    final String item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    try {
      await ref.read(settingsManagementProvider.notifier).reorderCustomStatuses(
        currentUser.parentUid!,
        updatedList,
      );
      if (mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Statuses reordered successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to reorder statuses: ${e.toString().split(':').last}');
      }
    }
  }
}