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
import '../../../core/utils/enums.dart';
import '../../../core/models/lead_model.dart';
import '../../../core/models/settings_model.dart';
import '../widgets/custom_field_widget.dart';

class EditLeadScreen extends ConsumerStatefulWidget {
  final String leadId;

  const EditLeadScreen({
    super.key,
    required this.leadId,
  });

  @override
  ConsumerState<EditLeadScreen> createState() => _EditLeadScreenState();
}

class _EditLeadScreenState extends ConsumerState<EditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _statusController = TextEditingController();
  final _followUpController = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  DateTime? _selectedFollowUpDate;
  SettingsModel? _settings;
  LeadModel? _originalLead;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _statusController.dispose();
    _followUpController.dispose();
    for (final controller in _customFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser?.parentUid != null) {
      try {
        // Load settings
        final settingsService = SettingsService();
        final settings = await settingsService.getSettings(currentUser!.parentUid!);

        // Load lead data
        final lead = await ref.read(leadProvider(widget.leadId).future);

        if (lead != null && mounted) {
          setState(() {
            _settings = settings;
            _originalLead = lead;
            _initializeFormWithLead(lead);
          });
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to load data: $e');
        }
      }
    }
  }

  void _initializeFormWithLead(LeadModel lead) {
    _statusController.text = lead.status;
    _selectedFollowUpDate = lead.followUpDate;
    _followUpController.text = lead.followUpDate != null
        ? AppHelpers.formatDate(lead.followUpDate!)
        : '';

    // Initialize custom field controllers
    for (final field in _settings?.customFields ?? []) {
      final value = lead.customFields[field.label]?.toString() ?? '';
      _customFieldControllers[field.fieldId] = TextEditingController(text: value);
    }

    // Add change listeners
    _statusController.addListener(_onFieldChanged);
    _followUpController.addListener(_onFieldChanged);
    for (final controller in _customFieldControllers.values) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isUpdating = ref.watch(leadManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }

        if (_originalLead == null || _settings == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: MinimalLoader()),
          );
        }

        return _buildEditScreen(user, isUpdating);
      },
      loading: () => const Scaffold(body: Center(child: MinimalLoader())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEditScreen(UserModel user, bool isUpdating) {
    return WillPopScope(
      onWillPop: () => _handleBackPress(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(isUpdating),
        body: _buildForm(user, isUpdating),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isUpdating) {
    return AppBar(
      title: const Text('Edit Lead'),
      elevation: 0,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        onPressed: isUpdating ? null : () => _handleBackPress(),
        icon: const Icon(LucideIcons.arrowLeft),
      ),
      actions: [
        if (_hasChanges) ...[
          TextButton(
            onPressed: isUpdating ? null : _resetForm,
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: isUpdating ? null : _saveChanges,
            child: Text(isUpdating ? 'Saving...' : 'Save'),
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildForm(UserModel user, bool isUpdating) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildFormHeader()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.3, duration: 600.ms),

            const SizedBox(height: 32),

            // Lead Status Section
            _buildStatusSection()
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 24),

            // Custom Fields Section
            if (_settings!.customFields.isNotEmpty)
              _buildCustomFieldsSection()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 24),

            // Follow-up Section
            _buildFollowUpSection()
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 40),

            // Action Buttons
            _buildActionButtons(isUpdating)
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    final statusColor = AppHelpers.getStatusColor(_originalLead!.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  LucideIcons.edit,
                  color: statusColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Lead',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _originalLead!.leadTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lead Info Row
          Row(
            children: [
              Icon(LucideIcons.user, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                _originalLead!.clientName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(LucideIcons.calendar, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Created ${AppHelpers.formatRelativeTime(_originalLead!.createdAt)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if (_hasChanges) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.edit,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Unsaved changes',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
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
          Row(
            children: [
              Icon(
                LucideIcons.flag,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lead Status',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Status Dropdown
          DropdownButtonFormField<String>(
            value: _statusController.text.isEmpty ? null : _statusController.text,
            decoration: const InputDecoration(
              labelText: 'Current Status *',
              prefixIcon: Icon(LucideIcons.flag),
            ),
            items: _settings!.customStatuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppHelpers.getStatusColor(status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(status),
                    if (status == _originalLead!.status) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Current',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _statusController.text = value ?? '';
              });
              _onFieldChanged();
            },
            validator: (value) => AppValidators.validateRequired(value, 'Status'),
          ),

          const SizedBox(height: 12),

          // Status Change Info
          if (_statusController.text != _originalLead!.status && _statusController.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.arrowRight,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status will change from "${_originalLead!.status}" to "${_statusController.text}"',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomFieldsSection() {
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
          Row(
            children: [
              Icon(
                LucideIcons.grid3x3,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lead Information',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dynamic Custom Fields
          ..._settings!.sortedFields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;

            return Padding(
              padding: EdgeInsets.only(bottom: index < _settings!.sortedFields.length - 1 ? 20 : 0),
              child: CustomFieldWidget(
                field: field,
                controller: _customFieldControllers[field.fieldId]!,
                onChanged: (value) => _onFieldChanged(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFollowUpSection() {
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
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Follow-up Schedule',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Follow-up Date
          MinimalTextField(
            label: 'Follow-up Date',
            hint: 'Select follow-up date',
            controller: _followUpController,
            readOnly: true,
            prefixIcon: LucideIcons.calendar,
            suffixIcon: _selectedFollowUpDate != null ? LucideIcons.x : null,
            onSuffixTap: _selectedFollowUpDate != null ? _clearFollowUpDate : null,
            onTap: _selectFollowUpDate,
            validator: (value) => AppValidators.validateFutureDate(value),
          ),

          const SizedBox(height: 12),

          // Follow-up Status Info
          if (_originalLead!.followUpDate != null || _selectedFollowUpDate != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_originalLead!.followUpDate != null) ...[
                    Row(
                      children: [
                        Icon(
                          LucideIcons.info,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Current: ${AppHelpers.formatDate(_originalLead!.followUpDate!)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedFollowUpDate != _originalLead!.followUpDate)
                      const SizedBox(height: 4),
                  ],
                  if (_selectedFollowUpDate != _originalLead!.followUpDate) ...[
                    Row(
                      children: [
                        Icon(
                          LucideIcons.arrowRight,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedFollowUpDate != null
                              ? 'New: ${AppHelpers.formatDate(_selectedFollowUpDate!)}'
                              : 'Removing follow-up',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isUpdating) {
    return Column(
      children: [
        // Save Button
        MinimalButton(
          text: 'Save Changes',
          onPressed: (_hasChanges && !isUpdating) ? _saveChanges : null,
          isLoading: isUpdating,
          icon: LucideIcons.save,
          width: double.infinity,
        ),

        const SizedBox(height: 12),

        // Cancel Button
        MinimalButton(
          text: 'Cancel',
          onPressed: isUpdating ? null : () => _handleBackPress(),
          isOutlined: true,
          icon: LucideIcons.x,
          width: double.infinity,
        ),
      ],
    );
  }

  Future<void> _selectFollowUpDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedFollowUpDate ??
          (_originalLead!.followUpDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedFollowUpDate = date;
        _followUpController.text = AppHelpers.formatDate(date);
      });
      _onFieldChanged();
    }
  }

  void _clearFollowUpDate() {
    setState(() {
      _selectedFollowUpDate = null;
      _followUpController.clear();
    });
    _onFieldChanged();
  }

  void _resetForm() {
    if (_originalLead != null) {
      setState(() {
        _initializeFormWithLead(_originalLead!);
        _hasChanges = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Collect custom field data
      final customFields = <String, dynamic>{};
      for (final field in _settings!.customFields) {
        final controller = _customFieldControllers[field.fieldId]!;
        final value = controller.text.trim();

        if (value.isNotEmpty) {
          // Convert value based on field type
          switch (field.type) {
            case CustomFieldType.number:
              customFields[field.label] = double.tryParse(value) ?? value;
              break;
            case CustomFieldType.date:
              customFields[field.label] = value;
              break;
            default:
              customFields[field.label] = value;
          }
        } else if (_originalLead!.customFields.containsKey(field.label)) {
          // Keep existing value if field is now empty but had a value before
          customFields[field.label] = _originalLead!.customFields[field.label];
        }
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'status': _statusController.text,
        'followUpDate': _selectedFollowUpDate,
        'customFields': customFields,
      };

      // Update the lead
      await ref.read(leadManagementProvider.notifier)
          .updateLead(_originalLead!.leadId, updateData);

      if (mounted) {
        setState(() {
          _hasChanges = false;
        });
        AppHelpers.showSuccessSnackbar(context, 'Lead updated successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to update lead: $e');
      }
    }
  }

  Future<bool> _handleBackPress() async {
    if (_hasChanges) {
      final shouldDiscard = await AppHelpers.showConfirmDialog(
        context,
        title: 'Discard Changes',
        content: 'You have unsaved changes. Are you sure you want to go back?',
        confirmText: 'Discard',
      );

      if (shouldDiscard == true) {
        context.pop();
        return true;
      }
      return false;
    } else {
      context.pop();
      return true;
    }
  }
}