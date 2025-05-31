import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/enums.dart';
import '../../../core/models/settings_model.dart';
import '../widgets/field_form_widget.dart'; // This widget needs to be created

class ManageFieldsScreen extends ConsumerStatefulWidget {
  const ManageFieldsScreen({super.key});

  @override
  ConsumerState<ManageFieldsScreen> createState() => _ManageFieldsScreenState();
}

class _ManageFieldsScreenState extends ConsumerState<ManageFieldsScreen> {
  final Uuid _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final settingsLoading = ref.watch(settingsManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null || !user.canManageSettings) {
          return const Scaffold(
            body: Center(
              child: EmptyState(
                icon: LucideIcons.lock,
                title: 'Access Denied',
                subtitle: 'You don\'t have permission to manage custom fields',
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
            LucideIcons.grid3x3,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Manage Custom Fields'),
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

        _buildAddFieldSection(settings, isLoading)
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, duration: 600.ms),

        const SizedBox(height: 24),

        _buildCurrentFieldsSection(settings, isLoading)
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
            'Customize Lead Fields',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add, edit, or reorder custom fields to capture specific lead information.',
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
                  'These fields will appear on all lead forms for your team.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddFieldSection(SettingsModel settings, bool isLoading) {
    return Padding(
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
              'Add New Custom Field',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            MinimalButton(
              text: 'Create New Field',
              onPressed: isLoading ? null : () => _showAddFieldDialog(settings),
              icon: LucideIcons.plus,
              backgroundColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentFieldsSection(SettingsModel settings, bool isLoading) {
    if (settings.customFields.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.box,
        title: 'No Custom Fields',
        subtitle: 'Add your first custom field to track more lead details.',
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
                'Current Fields (${settings.customFields.length})',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: settings.customFields.length,
                  onReorder: isLoading ? (oldIndex, newIndex) {} : (oldIndex, newIndex) {
                    _reorderFields(settings, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final field = settings.customFields[index];
                    return _buildFieldListItem(field, settings, isLoading).key!,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldListItem(CustomFieldModel field, SettingsModel settings, bool isLoading) {
    return Dismissible(
      key: ValueKey(field.fieldId),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _removeField(field.fieldId, settings);
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppColors.error,
        child: const Icon(LucideIcons.trash2, color: AppColors.textOnPrimary),
      ),
      confirmDismiss: (direction) => _confirmRemoveField(field.label),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Icon(field.type.icon, size: 18, color: AppColors.primary),
          ),
          title: Text(
            field.label,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${field.type.displayName} ${field.isRequired ? '• Required' : ''}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.edit, size: 18),
                onPressed: isLoading ? null : () => _showEditFieldDialog(field, settings),
                tooltip: 'Edit Field',
              ),
              Icon(LucideIcons.gripVertical, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddFieldDialog(SettingsModel settings) async {
    final newField = await showDialog<CustomFieldModel>(
      context: context,
      builder: (context) => FieldFormWidget(
        settings: settings,
        isEditing: false,
      ),
    );

    if (newField != null) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null || currentUser.parentUid == null) {
        AppHelpers.showErrorSnackbar(context, 'Could not determine leader ID.');
        return;
      }
      try {
        await ref.read(settingsManagementProvider.notifier).addCustomField(
          currentUser.parentUid!,
          newField.copyWith(fieldId: _uuid.v4()), // Assign a new UUID
        );
        if (mounted) {
          AppHelpers.showSuccessSnackbar(context, 'Custom field "${newField.label}" added successfully!');
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to add field: ${e.toString().split(':').last}');
        }
      }
    }
  }

  Future<void> _showEditFieldDialog(CustomFieldModel field, SettingsModel settings) async {
    final updatedField = await showDialog<CustomFieldModel>(
      context: context,
      builder: (context) => FieldFormWidget(
        settings: settings,
        initialField: field,
        isEditing: true,
      ),
    );

    if (updatedField != null) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null || currentUser.parentUid == null) {
        AppHelpers.showErrorSnackbar(context, 'Could not determine leader ID.');
        return;
      }
      try {
        await ref.read(settingsManagementProvider.notifier).updateCustomField(
          currentUser.parentUid!,
          updatedField,
        );
        if (mounted) {
          AppHelpers.showSuccessSnackbar(context, 'Custom field "${updatedField.label}" updated successfully!');
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to update field: ${e.toString().split(':').last}');
        }
      }
    }
  }

  Future<bool?> _confirmRemoveField(String fieldLabel) async {
    return await AppHelpers.showConfirmDialog(
      context,
      title: 'Remove Custom Field',
      content: 'Are you sure you want to remove "$fieldLabel"? This will remove all data for this field from all existing leads. This action cannot be undone.',
      confirmText: 'Remove',
    );
  }

  Future<void> _removeField(String fieldId, SettingsModel settings) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.parentUid == null) {
      AppHelpers.showErrorSnackbar(context, 'Could not determine leader ID.');
      return;
    }

    try {
      await ref.read(settingsManagementProvider.notifier).removeCustomField(
        currentUser.parentUid!,
        fieldId,
      );
      if (mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Custom field removed successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to remove field: ${e.toString().split(':').last}');
      }
    }
  }

  Future<void> _reorderFields(SettingsModel settings, int oldIndex, int newIndex) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.parentUid == null) {
      AppHelpers.showErrorSnackbar(context, 'Could not determine leader ID.');
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<CustomFieldModel> updatedList = List.from(settings.customFields);
    final CustomFieldModel item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    try {
      await ref.read(settingsManagementProvider.notifier).reorderCustomFields(
        currentUser.parentUid!,
        updatedList,
      );
      if (mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Fields reordered successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to reorder fields: ${e.toString().split(':').last}');
      }
    }
  }
}