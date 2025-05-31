import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import 'auth_provider.dart';

// Settings Service Provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// Settings Provider
final settingsProvider = FutureProvider<SettingsModel>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final settingsService = ref.watch(settingsServiceProvider);

  // Ensure current user is available and has a parentUid (for leaders)
  // or is admin (for global settings)
  final user = currentUser.asData?.value;
  if (user == null) {
    throw Exception('User not authenticated or profile not loaded.');
  }

  // Determine the settings ID based on the user's role
  // Admins might have a global settings ID or manage settings for leaders
  // Leaders and Class Leaders manage settings for their teams via parentUid
  String settingsId;
  if (user.isAdmin) {
    // For admin, use a fixed ID or their own UID if they manage global settings
    settingsId = 'admin_default_settings'; // This should align with how admin settings are stored
  } else if (user.isLeader || user.isClassLeader || user.isUser) {
    // For leaders, class leaders, and telecallers, settings are managed by their parent leader
    // If a user (telecaller) is directly under an admin and has no direct leader,
    // their parentUid might be the admin's UID.
    settingsId = user.parentUid ?? user.uid; // Fallback to their own UID if parentUid is null (e.g., top-level leader)
  } else {
    throw Exception('Unsupported user role for settings management.');
  }

  // Fetch settings for the determined ID
  return await settingsService.getSettings(settingsId);
});

// Settings Management Notifier
class SettingsManagementNotifier extends StateNotifier<AsyncValue<void>> {
  SettingsManagementNotifier(this._settingsService) : super(const AsyncValue.data(null));

  final SettingsService _settingsService;

  // Update custom statuses
  Future<void> updateCustomStatuses(String leaderUid, List<String> statuses) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.updateCustomStatuses(leaderUid, statuses);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Add custom status
  Future<void> addCustomStatus(String leaderUid, String status) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.addCustomStatus(leaderUid, status);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Remove custom status
  Future<void> removeCustomStatus(String leaderUid, String status) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.removeCustomStatus(leaderUid, status);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Reorder custom statuses
  Future<void> reorderCustomStatuses(String leaderUid, List<String> reorderedStatuses) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.reorderCustomStatuses(leaderUid, reorderedStatuses);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update custom fields
  Future<void> updateCustomFields(String leaderUid, List<CustomFieldModel> fields) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.updateCustomFields(leaderUid, fields);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Add custom field
  Future<void> addCustomField(String leaderUid, CustomFieldModel field) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.addCustomField(leaderUid, field);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update existing custom field
  Future<void> updateCustomField(String leaderUid, CustomFieldModel updatedField) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.updateCustomField(leaderUid, updatedField);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Remove custom field
  Future<void> removeCustomField(String leaderUid, String fieldId) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.removeCustomField(leaderUid, fieldId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Reorder custom fields
  Future<void> reorderCustomFields(String leaderUid, List<CustomFieldModel> reorderedFields) async {
    state = const AsyncValue.loading();
    try {
      await _settingsService.reorderCustomFields(leaderUid, reorderedFields);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Clear error state
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

// Settings Management Provider
final settingsManagementProvider = StateNotifierProvider<SettingsManagementNotifier, AsyncValue<void>>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return SettingsManagementNotifier(settingsService);
});

// Settings Management Loading Provider
final settingsManagementLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(settingsManagementProvider);
  return state.isLoading;
});

// Settings Management Error Provider
final settingsManagementErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(settingsManagementProvider);
  return state.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});