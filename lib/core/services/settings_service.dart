import '../models/settings_model.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';
import 'firestore_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  // Get settings for a leader or admin
  Future<SettingsModel> getSettings(String leaderUid) async {
    try {
      final settings = await _firestoreService.getSettingsForLeader(leaderUid);
      return settings ?? await _createDefaultSettings(leaderUid);
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  // Update custom statuses
  Future<void> updateCustomStatuses(String leaderUid, List<String> statuses) async {
    try {
      final currentSettings = await getSettings(leaderUid);
      final updatedSettings = currentSettings.copyWith(
        customStatuses: statuses,
        updatedAt: DateTime.now(),
      );
      await _firestoreService.updateSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update custom statuses: $e');
    }
  }

  // Add custom status
  Future<void> addCustomStatus(String leaderUid, String status) async {
    try {
      final currentSettings = await getSettings(leaderUid);
      if (!currentSettings.customStatuses.contains(status)) {
        final updatedStatuses = [...currentSettings.customStatuses, status];
        await updateCustomStatuses(leaderUid, updatedStatuses);
      }
    } catch (e) {
      throw Exception('Failed to add custom status: $e');
    }
  }

  // Remove custom status
  Future<void> removeCustomStatus(String leaderUid, String status) async {
    try {
      final currentSettings = await getSettings(leaderUid);
      final updatedStatuses = currentSettings.customStatuses
          .where((s) => s != status)
          .toList();
      await updateCustomStatuses(leaderUid, updatedStatuses);
    } catch (e) {
      throw Exception('Failed to remove custom status: $e');
    }
  }

  // Reorder custom statuses
  Future<void> reorderCustomStatuses(String leaderUid, List<String> reorderedStatuses) async {
    try {
      await updateCustomStatuses(leaderUid, reorderedStatuses);
    } catch (e) {
      throw Exception('Failed to reorder custom statuses: $e');
    }
  }

  // Update custom fields
  Future<void> updateCustomFields(String leaderUid, List<CustomFieldModel> fields) async {
    try {
      final currentSettings = await getSettings(leaderUid);
      final updatedSettings = currentSettings.copyWith(
        customFields: fields,
        updatedAt: DateTime.now(),
      );
      await _firestoreService.updateSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update custom fields: $e');
    }
  }

  // Add custom field
  Future<void> addCustomField(String leaderUid, CustomFieldModel field) async {
    try {
      final currentSettings = await getSettings(leaderUid);

      // Check if field with same label already exists
      final existingField = currentSettings.getFieldByLabel(field.label);
      if (existingField != null) {
        throw Exception('A field with this label already exists');
      }

      // Assign order if not provided
      final maxOrder = currentSettings.customFields.isEmpty
          ? 0
          : currentSettings.customFields
          .map((f) => f.order)
          .reduce((a, b) => a > b ? a : b);

      final fieldWithOrder = field.copyWith(order: field.order == 0 ? maxOrder + 1 : field.order);
      final updatedFields = [...currentSettings.customFields, fieldWithOrder];

      await updateCustomFields(leaderUid, updatedFields);
    } catch (e) {
      throw Exception('Failed to add custom field: $e');
    }
  }

  // Update existing custom field
  Future<void> updateCustomField(String leaderUid, CustomFieldModel updatedField) async {
    try {
      final currentSettings = await getSettings(leaderUid);
      final fieldIndex = currentSettings.customFields
          .indexWhere((f) => f.fieldId == updatedField.fieldId);

      if (fieldIndex == -1) {
        throw Exception('Field not found');
      }

      final updatedFields = [...currentSettings.customFields];
      updatedFields[fieldIndex] = updatedField;

      await updateCustomFields(leaderUid, updatedFields);
    } catch (e) {
      throw Exception('Failed to update custom field: $e');
    }
  }

  // Remove custom field
  Future<void> removeCustomField(String leaderUid, String fieldId) async {
    try {
      final currentSettings = await getSettings(leaderUid);
      final updatedFields = currentSettings.customFields
          .where((f) => f.fieldId != fieldId)
          .toList();

      await updateCustomFields(leaderUid, updatedFields);
    } catch (e) {
      throw Exception('Failed to remove custom field: $e');
    }
  }

  // Reorder custom fields
  Future<void> reorderCustomFields(String leaderUid, List<CustomFieldModel> reorderedFields) async {
    try {
      // Update order values
      final fieldsWithUpdatedOrder = reorderedFields.asMap().entries.map((entry) {
        return entry.value.copyWith(order: entry.key + 1);
      }).toList();

      await updateCustomFields(leaderUid, fieldsWithUpdatedOrder);
    } catch (e) {
      throw Exception('Failed to reorder custom fields: $e');
    }
  }

  // Validate field configuration
  String? validateCustomField(CustomFieldModel field) {
    if (field.label.trim().isEmpty) {
      return 'Field label is required';
    }

    if (field.label.length > 50) {
      return 'Field label is too long (max 50 characters)';
    }

    if (field.type == CustomFieldType.dropdown) {
      if (field.options.isEmpty) {
        return 'Dropdown fields must have at least one option';
      }

      if (field.options.length > AppConstants.maxCustomFieldOptions) {
        return 'Too many dropdown options (max ${AppConstants.maxCustomFieldOptions})';
      }

      // Check for empty options
      for (final option in field.options) {
        if (option.trim().isEmpty) {
          return 'Dropdown options cannot be empty';
        }
      }

      // Check for duplicate options
      final uniqueOptions = field.options.map((o) => o.trim().toLowerCase()).toSet();
      if (uniqueOptions.length != field.options.length) {
        return 'Duplicate dropdown options are not allowed';
      }
    }

    return null;
  }

  // Validate status configuration
  String? validateCustomStatus(String status, List<String> existingStatuses) {
    if (status.trim().isEmpty) {
      return 'Status name is required';
    }

    if (status.length > 30) {
      return 'Status name is too long (max 30 characters)';
    }

    if (existingStatuses.contains(status)) {
      return 'This status already exists';
    }

    return null;
  }

  // Get available field types
  List<CustomFieldType> getAvailableFieldTypes() {
    return CustomFieldType.values;
  }

  // Get default field options for dropdown
  List<String> getDefaultDropdownOptions(String fieldLabel) {
    switch (fieldLabel.toLowerCase()) {
      case 'client type':
        return ['Investor', 'End-User', 'Broker'];
      case 'property type':
        return ['Apartment', 'Villa', 'Plot', 'Commercial'];
      case 'budget range':
        return ['Below 50L', '50L-1Cr', '1Cr-2Cr', 'Above 2Cr'];
      case 'source':
        return ['Website', 'Referral', 'Advertisement', 'Walk-in'];
      case 'priority':
        return ['High', 'Medium', 'Low'];
      default:
        return ['Option 1', 'Option 2', 'Option 3'];
    }
  }

  // Import settings from another leader (admin only)
  Future<void> importSettingsFromLeader(String targetLeaderUid, String sourceLeaderUid) async {
    try {
      final sourceSettings = await getSettings(sourceLeaderUid);
      final importedSettings = sourceSettings.copyWith(
        settingsId: targetLeaderUid,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateSettings(importedSettings);
    } catch (e) {
      throw Exception('Failed to import settings: $e');
    }
  }

  // Reset to default settings
  Future<void> resetToDefaultSettings(String leaderUid) async {
    try {
      final defaultSettings = await _createDefaultSettings(leaderUid);
      await _firestoreService.updateSettings(defaultSettings);
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }

  // Export settings (returns JSON-like structure for backup)
  Future<Map<String, dynamic>> exportSettings(String leaderUid) async {
    try {
      final settings = await getSettings(leaderUid);
      return {
        'customStatuses': settings.customStatuses,
        'customFields': settings.customFields.map((f) => f.toMap()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': AppConstants.appVersion,
      };
    } catch (e) {
      throw Exception('Failed to export settings: $e');
    }
  }

  // Import settings from exported data
  Future<void> importSettings(String leaderUid, Map<String, dynamic> exportedData) async {
    try {
      final customStatuses = List<String>.from(exportedData['customStatuses'] ?? []);
      final customFieldsData = List<Map<String, dynamic>>.from(exportedData['customFields'] ?? []);
      final customFields = customFieldsData
          .map((data) => CustomFieldModel.fromMap(data))
          .toList();

      // Validate imported data
      for (final field in customFields) {
        final validation = validateCustomField(field);
        if (validation != null) {
          throw Exception('Invalid field configuration: $validation');
        }
      }

      final settings = SettingsModel(
        settingsId: leaderUid,
        customStatuses: customStatuses.isNotEmpty ? customStatuses : AppConstants.defaultLeadStatuses,
        customFields: customFields.isNotEmpty ? customFields : _getDefaultCustomFields(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateSettings(settings);
    } catch (e) {
      throw Exception('Failed to import settings: $e');
    }
  }

  // Create default settings
  Future<SettingsModel> _createDefaultSettings(String leaderUid) async {
    return SettingsModel(
      settingsId: leaderUid,
      customStatuses: AppConstants.defaultLeadStatuses,
      customFields: _getDefaultCustomFields(),
      updatedAt: DateTime.now(),
    );
  }

  // Get default custom fields
  List<CustomFieldModel> _getDefaultCustomFields() {
    return AppConstants.defaultCustomFields
        .map((field) => CustomFieldModel.fromMap(field))
        .toList();
  }

  // Check if user can modify settings
  bool canModifySettings(UserRole userRole) {
    return userRole == UserRole.admin || userRole == UserRole.leader;
  }

  // Get settings applicable to a user (considering hierarchy)
  Future<SettingsModel> getApplicableSettings(String userId, String? parentLeaderUid) async {
    try {
      if (parentLeaderUid != null) {
        return await getSettings(parentLeaderUid);
      } else {
        // Fallback to default admin settings
        return await getSettings('admin_default_settings');
      }
    } catch (e) {
      // Return default settings if none found
      return await _createDefaultSettings('admin_default_settings');
    }
  }
}