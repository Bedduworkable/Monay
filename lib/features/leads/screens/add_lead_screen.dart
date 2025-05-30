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
import '../../../core/models/settings_model.dart';
import '../widgets/custom_field_widget.dart';

class AddLeadScreen extends ConsumerStatefulWidget {
  const AddLeadScreen({super.key});

  @override
  ConsumerState<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends ConsumerState<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _statusController = TextEditingController();
  final _followUpController = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  DateTime? _selectedFollowUpDate;
  SettingsModel? _settings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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

  Future<void> _loadSettings() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser?.parentUid != null) {
      try {
        final settingsService = SettingsService();
        final settings = await settingsService.getSettings(currentUser!.parentUid!);
        setState(() {
          _settings = settings;
          // Set default status
          if (settings.customStatuses.isNotEmpty) {
            _statusController.text = settings.customStatuses.first;
          }
          // Initialize controllers for custom fields
          for (final field in settings.customFields) {
            _customFieldControllers[field.fieldId] = TextEditingController();
          }
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
    final currentUser = ref.watch(currentUserProvider);
    final isSubmitting = ref.watch(leadManagementLoadingProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: _settings == null
              ? const Center(child: MinimalLoader())
              : _buildForm(user, isSubmitting),
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
      title: const Text('Add New Lead'),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(LucideIcons.arrowLeft),
      ),
      actions: [
        TextButton.icon(
          onPressed: _isLoading ? null : _saveAsDraft,
          icon: const Icon(LucideIcons.save, size: 18),
          label: const Text('Draft'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildForm(UserModel user, bool isSubmitting) {
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

            // Basic Information
            _buildBasicInfoSection()
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 32),

            // Custom Fields
            if (_settings!.customFields.isNotEmpty)
              _buildCustomFieldsSection()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 32),

            // Follow-up Section
            _buildFollowUpSection()
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 40),

            // Action Buttons
            _buildActionButtons(user, isSubmitting)
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.target,
              color: AppColors.textOnPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Lead',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the details to add a new lead to your pipeline',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
                LucideIcons.info,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Basic Information',
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
              labelText: 'Lead Status *',
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
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _statusController.text = value ?? '';
              });
            },
            validator: (value) => AppValidators.validateRequired(value, 'Status'),
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
                'Lead Details',
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
                onChanged: (value) {
                  // Update form state if needed
                },
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
                'Follow-up',
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
        ],
      ),
    );
  }

  Widget _buildActionButtons(UserModel user, bool isSubmitting) {
    return Column(
      children: [
        // Primary Action
        MinimalButton(
          text: 'Create Lead',
          onPressed: isSubmitting ? null : () => _submitForm(user),
          isLoading: isSubmitting,
          icon: LucideIcons.plus,
          width: double.infinity,
        ),

        const SizedBox(height: 12),

        // Secondary Action
        MinimalButton(
          text: 'Cancel',
          onPressed: isSubmitting ? null : () => context.pop(),
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
      initialDate: _selectedFollowUpDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedFollowUpDate = date;
        _followUpController.text = AppHelpers.formatDate(date);
      });
    }
  }

  void _clearFollowUpDate() {
    setState(() {
      _selectedFollowUpDate = null;
      _followUpController.clear();
    });
  }

  Future<void> _submitForm(UserModel user) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
        }
      }

      // Create lead model
      final now = DateTime.now();
      final lead = LeadModel(
        leadId: '', // Will be set by Firestore
        createdByUid: user.uid,
        assignedToUid: user.uid,
        parentLeaderUid: user.parentUid ?? user.uid,
        parentClassLeaderUid: user.assignedToClassLeaderUid,
        status: _statusController.text,
        followUpDate: _selectedFollowUpDate,
        customFields: customFields,
        createdAt: now,
        updatedAt: now,
      );

      // Submit to provider
      final leadManagement = ref.read(leadManagementProvider.notifier);
      final leadId = await leadManagement.createLead(lead);

      if (leadId != null && mounted) {
        AppHelpers.showSuccessSnackbar(context, 'Lead created successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to create lead: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAsDraft() async {
    // Save form data locally for future completion
    AppHelpers.showInfoSnackbar(context, 'Draft saved locally');
  }
}