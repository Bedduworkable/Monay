import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart'; // Ensure you have uuid package
import '../../../core/models/settings_model.dart'; //
import '../../../core/theme/app_colors.dart'; //
import '../../../core/theme/app_text_styles.dart'; //
import '../../../core/theme/custom_widgets.dart'; //
import '../../../core/utils/enums.dart'; //
import '../../../core/utils/validators.dart'; //
import '../../../core/services/settings_service.dart'; //

class FieldFormWidget extends StatefulWidget {
  final SettingsModel settings; //
  final CustomFieldModel? initialField; //
  final bool isEditing;

  const FieldFormWidget({
    super.key,
    required this.settings, //
    this.initialField, //
    this.isEditing = false,
  });

  @override
  State<FieldFormWidget> createState() => _FieldFormWidgetState();
}

class _FieldFormWidgetState extends State<FieldFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _optionsController = TextEditingController(); // For dropdown options
  CustomFieldType _selectedType = CustomFieldType.text; //
  bool _isRequired = false;
  List<String> _options = []; // For dropdown options

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialField != null) { //
      _labelController.text = widget.initialField!.label; //
      _selectedType = widget.initialField!.type; //
      _isRequired = widget.initialField!.isRequired; //
      if (_selectedType == CustomFieldType.dropdown) { //
        _options = List.from(widget.initialField!.options); //
        _optionsController.text = _options.join(', ');
      }
    } else {
      // Set default options for new dropdown field
      _options = SettingsService().getDefaultDropdownOptions(''); //
      _optionsController.text = _options.join(', ');
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Custom Field' : 'Add New Custom Field'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MinimalTextField(
                label: 'Field Label *',
                hint: 'e.g., Project Name, Client Type',
                controller: _labelController,
                prefixIcon: LucideIcons.tag,
                validator: (value) {
                  final validation = AppValidators.validateCustomFieldLabel(value); //
                  if (validation != null) return validation;
                  // Check for duplicate labels only when adding or if label changed during editing
                  if (!widget.isEditing || (widget.isEditing && value != widget.initialField?.label)) { //
                    if (widget.settings.customFields.any((field) => //
                    field.label.toLowerCase() == value?.trim().toLowerCase() && //
                        field.fieldId != widget.initialField?.fieldId)) { //
                      return 'A field with this label already exists.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<CustomFieldType>( //
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Field Type *',
                  prefixIcon: Icon(LucideIcons.type),
                ),
                items: CustomFieldType.values.map((type) { //
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName), //
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!; //
                    if (_selectedType == CustomFieldType.dropdown) { //
                      // Provide default options or keep existing if type changed to dropdown
                      if (_options.isEmpty || (!widget.isEditing && !['Option 1'].contains(_options.first))) {
                        _options = SettingsService().getDefaultDropdownOptions(_labelController.text); //
                        _optionsController.text = _options.join(', ');
                      }
                    } else {
                      _options = [];
                      _optionsController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isRequired,
                    onChanged: (value) {
                      setState(() {
                        _isRequired = value ?? false;
                      });
                    },
                  ),
                  const Text('Required Field'),
                ],
              ),
              if (_selectedType == CustomFieldType.dropdown) ...[ //
                const SizedBox(height: 20),
                MinimalTextField(
                  label: 'Dropdown Options *',
                  hint: 'Enter options separated by commas (e.g., Option1, Option2)',
                  controller: _optionsController,
                  prefixIcon: LucideIcons.list,
                  maxLines: 3,
                  validator: (value) {
                    if (_selectedType == CustomFieldType.dropdown && (value == null || value.trim().isEmpty)) { //
                      return 'At least one option is required for dropdowns.';
                    }
                    _options = value?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [];
                    return AppValidators.validateDropdownOptions(_options); //
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Separate each option with a comma. Max ${AppConstants.maxCustomFieldOptions} options.', //
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary), //
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        MinimalButton(
          text: widget.isEditing ? 'Save Changes' : 'Add Field',
          onPressed: _submitForm,
          icon: widget.isEditing ? LucideIcons.save : LucideIcons.plus,
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() == true) {
      final newField = CustomFieldModel( //
        fieldId: widget.isEditing ? widget.initialField!.fieldId : const Uuid().v4(), //
        label: _labelController.text.trim(),
        type: _selectedType, //
        isRequired: _isRequired,
        order: widget.isEditing ? widget.initialField!.order : (widget.settings.customFields.isEmpty ? 1 : widget.settings.customFields.last.order + 1), //
        options: _selectedType == CustomFieldType.dropdown ? _options : [], //
      );
      Navigator.of(context).pop(newField);
    }
  }
}