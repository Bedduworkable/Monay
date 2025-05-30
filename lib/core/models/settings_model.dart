import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/enums.dart';

class SettingsModel {
  final String settingsId;
  final List<String> customStatuses;
  final List<CustomFieldModel> customFields;
  final DateTime updatedAt;

  const SettingsModel({
    required this.settingsId,
    required this.customStatuses,
    required this.customFields,
    required this.updatedAt,
  });

  // Factory constructor from Firestore document
  factory SettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SettingsModel(
      settingsId: doc.id,
      customStatuses: List<String>.from(data['customStatuses'] ?? []),
      customFields: (data['customFields'] as List<dynamic>? ?? [])
          .map((fieldData) => CustomFieldModel.fromMap(fieldData))
          .toList(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Factory constructor from Map
  factory SettingsModel.fromMap(Map<String, dynamic> data, String settingsId) {
    return SettingsModel(
      settingsId: settingsId,
      customStatuses: List<String>.from(data['customStatuses'] ?? []),
      customFields: (data['customFields'] as List<dynamic>? ?? [])
          .map((fieldData) => CustomFieldModel.fromMap(fieldData))
          .toList(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data['updatedAt']),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'settingsId': settingsId,
      'customStatuses': customStatuses,
      'customFields': customFields.map((field) => field.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  SettingsModel copyWith({
    String? settingsId,
    List<String>? customStatuses,
    List<CustomFieldModel>? customFields,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      settingsId: settingsId ?? this.settingsId,
      customStatuses: customStatuses ?? this.customStatuses,
      customFields: customFields ?? this.customFields,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool hasStatus(String status) {
    return customStatuses.contains(status);
  }

  CustomFieldModel? getFieldById(String fieldId) {
    try {
      return customFields.firstWhere((field) => field.fieldId == fieldId);
    } catch (e) {
      return null;
    }
  }

  CustomFieldModel? getFieldByLabel(String label) {
    try {
      return customFields.firstWhere((field) => field.label == label);
    } catch (e) {
      return null;
    }
  }

  List<CustomFieldModel> get requiredFields {
    return customFields.where((field) => field.isRequired).toList();
  }

  List<CustomFieldModel> get optionalFields {
    return customFields.where((field) => !field.isRequired).toList();
  }

  List<CustomFieldModel> get sortedFields {
    final fields = List<CustomFieldModel>.from(customFields);
    fields.sort((a, b) => a.order.compareTo(b.order));
    return fields;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel && other.settingsId == settingsId;
  }

  @override
  int get hashCode => settingsId.hashCode;

  @override
  String toString() {
    return 'SettingsModel(settingsId: $settingsId, statusCount: ${customStatuses.length}, fieldCount: ${customFields.length})';
  }
}

class CustomFieldModel {
  final String fieldId;
  final String label;
  final CustomFieldType type;
  final bool isRequired;
  final int order;
  final List<String> options;

  const CustomFieldModel({
    required this.fieldId,
    required this.label,
    required this.type,
    required this.isRequired,
    required this.order,
    this.options = const [],
  });

  // Factory constructor from Map
  factory CustomFieldModel.fromMap(Map<String, dynamic> data) {
    return CustomFieldModel(
      fieldId: data['fieldId'] ?? '',
      label: data['label'] ?? '',
      type: CustomFieldType.values.firstWhere(
            (type) => type.value == data['type'],
        orElse: () => CustomFieldType.text,
      ),
      isRequired: data['isRequired'] ?? false,
      order: data['order'] ?? 0,
      options: List<String>.from(data['options'] ?? []),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'fieldId': fieldId,
      'label': label,
      'type': type.value,
      'isRequired': isRequired,
      'order': order,
      'options': options,
    };
  }

  // Create a copy with updated fields
  CustomFieldModel copyWith({
    String? fieldId,
    String? label,
    CustomFieldType? type,
    bool? isRequired,
    int? order,
    List<String>? options,
  }) {
    return CustomFieldModel(
      fieldId: fieldId ?? this.fieldId,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      order: order ?? this.order,
      options: options ?? this.options,
    );
  }

  // Helper methods
  bool get isDropdown => type == CustomFieldType.dropdown;
  bool get isText => type == CustomFieldType.text;
  bool get isNumber => type == CustomFieldType.number;
  bool get isDate => type == CustomFieldType.date;

  bool hasOption(String option) {
    return options.contains(option);
  }

  String? validateValue(dynamic value) {
    // Basic validation based on field type and requirements
    if (isRequired && (value == null || value.toString().trim().isEmpty)) {
      return '$label is required';
    }

    if (value == null || value.toString().trim().isEmpty) {
      return null; // Optional field with no value is valid
    }

    switch (type) {
      case CustomFieldType.text:
        if (value.toString().length > 255) {
          return '$label is too long';
        }
        break;

      case CustomFieldType.number:
        final numValue = double.tryParse(value.toString());
        if (numValue == null) {
          return '$label must be a valid number';
        }
        if (numValue < 0) {
          return '$label cannot be negative';
        }
        break;

      case CustomFieldType.date:
        try {
          DateTime.parse(value.toString());
        } catch (e) {
          return '$label must be a valid date';
        }
        break;

      case CustomFieldType.dropdown:
        if (!options.contains(value.toString())) {
          return 'Invalid option selected for $label';
        }
        break;
    }

    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomFieldModel && other.fieldId == fieldId;
  }

  @override
  int get hashCode => fieldId.hashCode;

  @override
  String toString() {
    return 'CustomFieldModel(fieldId: $fieldId, label: $label, type: ${type.value}, required: $isRequired)';
  }
}