import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/settings_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/enums.dart';

class CustomFieldWidget extends StatefulWidget {
  final CustomFieldModel field;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const CustomFieldWidget({
    super.key,
    required this.field,
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<CustomFieldWidget> createState() => _CustomFieldWidgetState();
}

class _CustomFieldWidgetState extends State<CustomFieldWidget> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    switch (widget.field.type) {
      case CustomFieldType.text:
        return _buildTextField();
      case CustomFieldType.number:
        return _buildNumberField();
      case CustomFieldType.date:
        return _buildDateField();
      case CustomFieldType.dropdown:
        return _buildDropdownField();
    }
  }

  Widget _buildTextField() {
    return MinimalTextField(
      label: _buildLabel(),
      hint: 'Enter ${widget.field.label.toLowerCase()}',
      controller: widget.controller,
      prefixIcon: LucideIcons.type,
      enabled: widget.enabled,
      validator: widget.field.isRequired
          ? (value) => AppValidators.validateRequired(value, widget.field.label)
          : null,
      onChanged: widget.onChanged,
      maxLines: _isLongTextField() ? 3 : 1,
    );
  }

  Widget _buildNumberField() {
    return MinimalTextField(
      label: _buildLabel(),
      hint: 'Enter ${widget.field.label.toLowerCase()}',
      controller: widget.controller,
      keyboardType: TextInputType.number,
      prefixIcon: _getBudgetIcon(),
      enabled: widget.enabled,
      validator: (value) {
        if (widget.field.isRequired && (value == null || value.trim().isEmpty)) {
          return '${widget.field.label} is required';
        }
        return AppValidators.validateNumber(value, isRequired: widget.field.isRequired);
      },
      onChanged: widget.onChanged,
    );
  }

  Widget _buildDateField() {
    return MinimalTextField(
      label: _buildLabel(),
      hint: 'Select ${widget.field.label.toLowerCase()}',
      controller: widget.controller,
      readOnly: true,
      prefixIcon: LucideIcons.calendar,
      suffixIcon: _selectedDate != null ? LucideIcons.x : null,
      enabled: widget.enabled,
      onTap: widget.enabled ? _selectDate : null,
      onSuffixTap: _selectedDate != null ? _clearDate : null,
      validator: widget.field.isRequired
          ? (value) => AppValidators.validateRequired(value, widget.field.label)
          : null,
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _buildLabel(),
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: widget.controller.text.isEmpty ? null : widget.controller.text,
          decoration: InputDecoration(
            hintText: 'Select ${widget.field.label.toLowerCase()}',
            prefixIcon: Icon(_getDropdownIcon()),
            filled: true,
            fillColor: widget.enabled ? AppColors.backgroundSecondary : AppColors.neutral100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: widget.field.options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: widget.enabled ? (value) {
            widget.controller.text = value ?? '';
            widget.onChanged?.call(value ?? '');
          } : null,
          validator: widget.field.isRequired
              ? (value) => AppValidators.validateRequired(value, widget.field.label)
              : null,
        ),
      ],
    );
  }

  String _buildLabel() {
    return widget.field.label + (widget.field.isRequired ? ' *' : '');
  }

  bool _isLongTextField() {
    final label = widget.field.label.toLowerCase();
    return label.contains('description') ||
        label.contains('notes') ||
        label.contains('remarks') ||
        label.contains('address') ||
        label.contains('comment');
  }

  IconData _getBudgetIcon() {
    final label = widget.field.label.toLowerCase();
    if (label.contains('budget') || label.contains('price') || label.contains('amount')) {
      return LucideIcons.indianRupee;
    } else if (label.contains('area') || label.contains('size')) {
      return LucideIcons.maximize;
    } else if (label.contains('phone') || label.contains('mobile')) {
      return LucideIcons.phone;
    }
    return LucideIcons.hash;
  }

  IconData _getDropdownIcon() {
    final label = widget.field.label.toLowerCase();
    if (label.contains('type')) {
      return LucideIcons.tag;
    } else if (label.contains('source')) {
      return LucideIcons.globe;
    } else if (label.contains('priority')) {
      return LucideIcons.flag;
    } else if (label.contains('project')) {
      return LucideIcons.building;
    }
    return LucideIcons.list;
  }

  Future<void> _selectDate() async {
    final initialDate = _selectedDate ?? DateTime.now();
    final firstDate = _isFollowUpDate()
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(days: 365 * 10));
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        widget.controller.text = AppHelpers.formatDate(date);
      });
      widget.onChanged?.call(widget.controller.text);
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      widget.controller.clear();
    });
    widget.onChanged?.call('');
  }

  bool _isFollowUpDate() {
    final label = widget.field.label.toLowerCase();
    return label.contains('follow') ||
        label.contains('next') ||
        label.contains('visit') ||
        label.contains('callback');
  }
}