import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../utils/enums.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

// Leads Providers based on user role
final leadsForCurrentUserProvider = StreamProvider<List<LeadModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) {
        return Stream.value(<LeadModel>[]);
      }

      switch (user.role) {
        case UserRole.admin:
          return firestoreService.getAllLeads();
        case UserRole.leader:
          return firestoreService.getLeadsForLeader(user.uid);
        case UserRole.classLeader:
          return firestoreService.getLeadsForClassLeader(user.uid);
        case UserRole.user:
          return firestoreService.getLeadsForUser(user.uid);
      }
    },
    loading: () => Stream.value(<LeadModel>[]),
    error: (_, __) => Stream.value(<LeadModel>[]),
  );
});

// Follow-up leads for today (for current user)
final followUpLeadsForTodayProvider = StreamProvider<List<LeadModel>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return Stream.value(<LeadModel>[]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getFollowUpLeadsForToday(currentUserId);
});

// Individual Lead Provider
final leadProvider = FutureProvider.family<LeadModel?, String>((ref, leadId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getLeadById(leadId);
});

// Lead Management Notifier
class LeadManagementNotifier extends StateNotifier<AsyncValue<void>> {
  LeadManagementNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  final FirestoreService _firestoreService;

  // Create new lead
  Future<String?> createLead(LeadModel lead) async {
    state = const AsyncValue.loading();
    try {
      final leadId = await _firestoreService.createLead(lead);
      state = const AsyncValue.data(null);
      return leadId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  // Update lead
  Future<void> updateLead(String leadId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateLead(leadId, data);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update lead status
  Future<void> updateLeadStatus(String leadId, String status) async {
    await updateLead(leadId, {'status': status});
  }

  // Update follow-up date
  Future<void> updateFollowUpDate(String leadId, DateTime? date) async {
    await updateLead(leadId, {'followUpDate': date});
  }

  // Update custom fields
  Future<void> updateCustomFields(String leadId, Map<String, dynamic> customFields) async {
    await updateLead(leadId, {'customFields': customFields});
  }

  // Add remark to lead
  Future<void> addRemark(String leadId, String text, String byUid, String byName) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.addRemarkToLead(leadId, text, byUid, byName);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Delete lead (soft delete)
  Future<void> deleteLead(String leadId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteLead(leadId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Assign lead to user
  Future<void> assignLead(String leadId, String userId) async {
    await updateLead(leadId, {'assignedToUid': userId});
  }

  // Clear error state
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

// Lead Management Provider
final leadManagementProvider = StateNotifierProvider<LeadManagementNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return LeadManagementNotifier(firestoreService);
});

// Lead Statistics Providers
final leadStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return <String, int>{};
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getLeadCountByStatus(currentUserId);
});

final totalLeadsCountProvider = FutureProvider<int>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getTotalLeadsCount();
});

// Search and Filter Providers
final leadSearchQueryProvider = StateProvider<String>((ref) => '');
final leadStatusFilterProvider = StateProvider<String?>((ref) => null);
final leadDateFilterProvider = StateProvider<DateTimeRange?>((ref) => null);

// Filtered Leads Provider
final filteredLeadsProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(leadsForCurrentUserProvider);
  final searchQuery = ref.watch(leadSearchQueryProvider);
  final statusFilter = ref.watch(leadStatusFilterProvider);
  final dateFilter = ref.watch(leadDateFilterProvider);

  return leads.when(
    data: (leadsList) => leadsList.where((lead) =>
        lead.createdAt.isAfter(sevenDaysAgo)).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Overdue Follow-ups Provider
final overdueFollowUpsProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(leadsForCurrentUserProvider);

  return leads.when(
    data: (leadsList) => leadsList.where((lead) => lead.isFollowUpOverdue).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Converted Leads Provider
final convertedLeadsProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(leadsForCurrentUserProvider);

  return leads.when(
    data: (leadsList) => leadsList.where((lead) => lead.isConverted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Active Leads Provider (not converted or lost)
final activeLeadsProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(leadsForCurrentUserProvider);

  return leads.when(
    data: (leadsList) => leadsList.where((lead) => lead.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Lead Metrics Provider
final leadMetricsProvider = Provider<Map<String, dynamic>>((ref) {
  final leads = ref.watch(leadsForCurrentUserProvider);

  return leads.when(
    data: (leadsList) {
      final total = leadsList.length;
      final converted = leadsList.where((lead) => lead.isConverted).length;
      final lost = leadsList.where((lead) => lead.isLost).length;
      final active = leadsList.where((lead) => lead.isActive).length;
      final overdueFollowUps = leadsList.where((lead) => lead.isFollowUpOverdue).length;
      final todayFollowUps = leadsList.where((lead) => lead.hasFollowUpDue).length;

      final conversionRate = total > 0 ? (converted / total * 100) : 0.0;

      return {
        'total': total,
        'converted': converted,
        'lost': lost,
        'active': active,
        'overdueFollowUps': overdueFollowUps,
        'todayFollowUps': todayFollowUps,
        'conversionRate': conversionRate,
      };
    },
    loading: () => <String, dynamic>{},
    error: (_, __) => <String, dynamic>{},
  );
});

// Lead Form State Provider
final leadFormProvider = StateNotifierProvider<LeadFormNotifier, LeadFormState>((ref) {
  return LeadFormNotifier();
});

// Lead Form State
class LeadFormState {
  final Map<String, dynamic> formData;
  final List<String> errors;
  final bool isValid;

  const LeadFormState({
    this.formData = const {},
    this.errors = const [],
    this.isValid = false,
  });

  LeadFormState copyWith({
    Map<String, dynamic>? formData,
    List<String>? errors,
    bool? isValid,
  }) {
    return LeadFormState(
      formData: formData ?? this.formData,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
    );
  }
}

// Lead Form Notifier
class LeadFormNotifier extends StateNotifier<LeadFormState> {
  LeadFormNotifier() : super(const LeadFormState());

  // Update form field
  void updateField(String fieldName, dynamic value) {
    final updatedFormData = Map<String, dynamic>.from(state.formData);
    updatedFormData[fieldName] = value;

    state = state.copyWith(
      formData: updatedFormData,
      isValid: _validateForm(updatedFormData),
    );
  }

  // Update multiple fields
  void updateFields(Map<String, dynamic> fields) {
    final updatedFormData = Map<String, dynamic>.from(state.formData);
    updatedFormData.addAll(fields);

    state = state.copyWith(
      formData: updatedFormData,
      isValid: _validateForm(updatedFormData),
    );
  }

  // Clear form
  void clearForm() {
    state = const LeadFormState();
  }

  // Initialize form with lead data (for editing)
  void initializeWithLead(LeadModel lead) {
    final formData = <String, dynamic>{
      'status': lead.status,
      'followUpDate': lead.followUpDate,
      ...lead.customFields,
    };

    state = state.copyWith(
      formData: formData,
      isValid: _validateForm(formData),
    );
  }

  // Validate form
  bool _validateForm(Map<String, dynamic> formData) {
    // Basic validation - can be enhanced based on requirements
    return formData.containsKey('status') &&
        formData['status']?.toString().isNotEmpty == true;
  }

  // Get form data as LeadModel
  LeadModel toLeadModel({
    required String createdByUid,
    required String assignedToUid,
    required String parentLeaderUid,
    String? parentClassLeaderUid,
    String? leadId,
  }) {
    final now = DateTime.now();

    return LeadModel(
      leadId: leadId ?? '',
      createdByUid: createdByUid,
      assignedToUid: assignedToUid,
      parentLeaderUid: parentLeaderUid,
      parentClassLeaderUid: parentClassLeaderUid,
      status: state.formData['status'] ?? 'New',
      followUpDate: state.formData['followUpDate'],
      customFields: Map<String, dynamic>.from(state.formData)
        ..remove('status')
        ..remove('followUpDate'),
      createdAt: now,
      updatedAt: now,
    );
  }
}

// Lead Assignment Provider
final leadAssignmentProvider = StateNotifierProvider<LeadAssignmentNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return LeadAssignmentNotifier(firestoreService);
});

// Lead Assignment Notifier
class LeadAssignmentNotifier extends StateNotifier<AsyncValue<void>> {
  LeadAssignmentNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  final FirestoreService _firestoreService;

  // Assign multiple leads to a user
  Future<void> assignLeadsToUser(List<String> leadIds, String userId) async {
    state = const AsyncValue.loading();
    try {
      final batch = _firestoreService.batch;

      for (final leadId in leadIds) {
        // Update each lead's assignment
        await _firestoreService.updateLead(leadId, {'assignedToUid': userId});
      }

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Bulk update lead status
  Future<void> bulkUpdateLeadStatus(List<String> leadIds, String status) async {
    state = const AsyncValue.loading();
    try {
      for (final leadId in leadIds) {
        await _firestoreService.updateLead(leadId, {'status': status});
      }
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Bulk delete leads
  Future<void> bulkDeleteLeads(List<String> leadIds) async {
    state = const AsyncValue.loading();
    try {
      for (final leadId in leadIds) {
        await _firestoreService.deleteLead(leadId);
      }
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Selected Leads Provider (for bulk operations)
final selectedLeadsProvider = StateNotifierProvider<SelectedLeadsNotifier, Set<String>>((ref) {
  return SelectedLeadsNotifier();
});

class SelectedLeadsNotifier extends StateNotifier<Set<String>> {
  SelectedLeadsNotifier() : super(<String>{});

  void toggleLead(String leadId) {
    if (state.contains(leadId)) {
      state = Set.from(state)..remove(leadId);
    } else {
      state = Set.from(state)..add(leadId);
    }
  }

  void selectAll(List<String> leadIds) {
    state = Set.from(leadIds);
  }

  void clearSelection() {
    state = <String>{};
  }

  bool isSelected(String leadId) {
    return state.contains(leadId);
  }

  int get selectedCount => state.length;
}

// Lead Error Provider
final leadManagementErrorProvider = Provider<String?>((ref) {
  final leadManagementState = ref.watch(leadManagementProvider);
  return leadManagementState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// Lead Loading Provider
final leadManagementLoadingProvider = Provider<bool>((ref) {
  final leadManagementState = ref.watch(leadManagementProvider);
  return leadManagementState.when(
    data: (_) => false,
    loading: () => true,
    error: (_, __) => false,
  );
});

// Lead Sort Provider
final leadSortProvider = StateNotifierProvider<LeadSortNotifier, LeadSortState>((ref) {
  return LeadSortNotifier();
});

class LeadSortState {
  final String sortBy;
  final bool isAscending;

  const LeadSortState({
    this.sortBy = 'updatedAt',
    this.isAscending = false,
  });

  LeadSortState copyWith({
    String? sortBy,
    bool? isAscending,
  }) {
    return LeadSortState(
      sortBy: sortBy ?? this.sortBy,
      isAscending: isAscending ?? this.isAscending,
    );
  }
}

class LeadSortNotifier extends StateNotifier<LeadSortState> {
  LeadSortNotifier() : super(const LeadSortState());

  void updateSort(String sortBy) {
    if (state.sortBy == sortBy) {
      // Toggle direction if same field
      state = state.copyWith(isAscending: !state.isAscending);
    } else {
      // New field, default to descending
      state = state.copyWith(sortBy: sortBy, isAscending: false);
    }
  }
}

// Sorted Leads Provider
final sortedLeadsProvider = Provider<List<LeadModel>>((ref) {
  final filteredLeads = ref.watch(filteredLeadsProvider);
  final sortState = ref.watch(leadSortProvider);

  final sortedLeads = List<LeadModel>.from(filteredLeads);

  sortedLeads.sort((a, b) {
    int comparison = 0;

    switch (sortState.sortBy) {
      case 'createdAt':
        comparison = a.createdAt.compareTo(b.createdAt);
        break;
      case 'updatedAt':
        comparison = a.updatedAt.compareTo(b.updatedAt);
        break;
      case 'status':
        comparison = a.status.compareTo(b.status);
        break;
      case 'followUpDate':
        if (a.followUpDate == null && b.followUpDate == null) {
          comparison = 0;
        } else if (a.followUpDate == null) {
          comparison = 1;
        } else if (b.followUpDate == null) {
          comparison = -1;
        } else {
          comparison = a.followUpDate!.compareTo(b.followUpDate!);
        }
        break;
      case 'clientName':
        comparison = a.clientName.compareTo(b.clientName);
        break;
      default:
        comparison = a.updatedAt.compareTo(b.updatedAt);
    }

    return sortState.isAscending ? comparison : -comparison;
  });

  return sortedLeads;
});when(
data: (leadsList) {
var filteredLeads = leadsList;

// Apply search filter
if (searchQuery.isNotEmpty) {
filteredLeads = filteredLeads.where((lead) {
final query = searchQuery.toLowerCase();
return lead.leadTitle.toLowerCase().contains(query) ||
lead.clientName.toLowerCase().contains(query) ||
lead.status.toLowerCase().contains(query) ||
lead.customFields.values.any((value) =>
value.toString().toLowerCase().contains(query));
}).toList();
}

// Apply status filter
if (statusFilter != null && statusFilter.isNotEmpty) {
filteredLeads = filteredLeads.where((lead) =>
lead.status == statusFilter).toList();
}

// Apply date filter
if (dateFilter != null) {
filteredLeads = filteredLeads.where((lead) {
final leadDate = lead.createdAt;
return leadDate.isAfter(dateFilter.start.subtract(const Duration(days: 1))) &&
leadDate.isBefore(dateFilter.end.add(const Duration(days: 1)));
}).toList();
}

return filteredLeads;
},
loading: () => [],
error: (_, __) => [],
);
});

// Leads by Status Provider
final leadsByStatusProvider = Provider<Map<String, List<LeadModel>>>((ref) {
final leads = ref.watch(leadsForCurrentUserProvider);

return leads.when(
data: (leadsList) {
final Map<String, List<LeadModel>> leadsByStatus = {};

for (final lead in leadsList) {
if (!leadsByStatus.containsKey(lead.status)) {
leadsByStatus[lead.status] = [];
}
leadsByStatus[lead.status]!.add(lead);
}

return leadsByStatus;
},
loading: () => {},
error: (_, __) => {},
);
});

// Recent Leads Provider (last 7 days)
final recentLeadsProvider = Provider<List<LeadModel>>((ref) {
final leads = ref.watch(leadsForCurrentUserProvider);
final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

return leads.