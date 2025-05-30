import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/join_request_model.dart';
import '../services/firestore_service.dart';
import '../utils/enums.dart';
import 'auth_provider.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Users by Role Providers
final adminUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUsersByRole(UserRole.admin);
});

final leaderUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUsersByRole(UserRole.leader);
});

final classLeaderUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUsersByRole(UserRole.classLeader);
});

final telecallerUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUsersByRole(UserRole.user);
});

// Users under current leader
final usersUnderCurrentLeaderProvider = StreamProvider<List<UserModel>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return Stream.value(<UserModel>[]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUsersUnderLeader(currentUserId);
});

// Telecallers for current class leader
final telecallersForCurrentClassLeaderProvider = StreamProvider<List<UserModel>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return Stream.value(<UserModel>[]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTelecallersForClassLeader(currentUserId);
});

// Join requests for current leader
final joinRequestsForCurrentLeaderProvider = StreamProvider<List<JoinRequestModel>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return Stream.value(<JoinRequestModel>[]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getJoinRequestsForLeader(currentUserId);
});

// User Management Notifier
class UserManagementNotifier extends StateNotifier<AsyncValue<void>> {
  UserManagementNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  final FirestoreService _firestoreService;

  // Promote user to class leader
  Future<void> promoteUserToClassLeader(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.promoteUserToClassLeader(userId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Assign telecaller to class leader
  Future<void> assignTelecallerToClassLeader(String telecallerUid, String classLeaderUid) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.assignTelecallerToClassLeader(telecallerUid, classLeaderUid);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update user information
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateUser(userId, data);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Approve join request
  Future<void> approveJoinRequest(String requestId, String approverUid) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.approveJoinRequest(requestId, approverUid);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Reject join request
  Future<void> rejectJoinRequest(String requestId, String rejecterUid) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.rejectJoinRequest(requestId, rejecterUid);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Extend user account expiry (renewal)
  Future<void> renewUserAccount(String userId, int years) async {
    state = const AsyncValue.loading();
    try {
      final extensionDays = years * 365;
      final newExpiryDate = DateTime.now().add(Duration(days: extensionDays));

      await _firestoreService.updateUser(userId, {
        'expiresAt': newExpiryDate,
      });

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Deactivate user account
  Future<void> deactivateUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateUser(userId, {
        'approvalStatus': ApprovalStatus.rejected.value,
        'deactivatedAt': DateTime.now(),
      });
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Reactivate user account
  Future<void> reactivateUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateUser(userId, {
        'approvalStatus': ApprovalStatus.approved.value,
        'reactivatedAt': DateTime.now(),
      });
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    state = const AsyncValue.loading();
    try {
      final updateData = <String, dynamic>{
        'role': newRole.value,
      };

      // Update class leader flag if promoting to/from class leader
      if (newRole == UserRole.classLeader) {
        updateData['isClassLeader'] = true;
      } else {
        updateData['isClassLeader'] = false;
      }

      await _firestoreService.updateUser(userId, updateData);
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

// User Management Provider
final userManagementProvider = StateNotifierProvider<UserManagementNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return UserManagementNotifier(firestoreService);
});

// Individual User Provider (for user details)
final userProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUserById(userId);
});

// User Statistics Providers
final userStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUsersCountByRole();
});

// Filtered Users Providers
final availableTelecallersForAssignmentProvider = Provider<List<UserModel>>((ref) {
  final telecallers = ref.watch(telecallerUsersProvider);
  return telecallers.when(
    data: (users) => users.where((user) => user.assignedToClassLeaderUid == null).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final assignedTelecallersProvider = Provider<List<UserModel>>((ref) {
  final telecallers = ref.watch(telecallerUsersProvider);
  return telecallers.when(
    data: (users) => users.where((user) => user.assignedToClassLeaderUid != null).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Expiring Users Provider
final expiringUsersProvider = Provider<List<UserModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider);

  return currentUser.when(
    data: (user) {
      if (user == null || !user.canManageUsers) {
        return [];
      }

      final usersUnderLeader = ref.watch(usersUnderCurrentLeaderProvider);
      return usersUnderLeader.when(
        data: (users) => users.where((u) => u.isExpiringSoon).toList(),
        loading: () => [],
        error: (_, __) => [],
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Pending Join Requests Count
final pendingJoinRequestsCountProvider = Provider<int>((ref) {
  final joinRequests = ref.watch(joinRequestsForCurrentLeaderProvider);
  return joinRequests.when(
    data: (requests) => requests.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Team Size Provider (for leaders)
final teamSizeProvider = Provider<int>((ref) {
  final usersUnderLeader = ref.watch(usersUnderCurrentLeaderProvider);
  return usersUnderLeader.when(
    data: (users) => users.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Search and Filter Providers
final userSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredUsersProvider = Provider<List<UserModel>>((ref) {
  final searchQuery = ref.watch(userSearchQueryProvider);
  final currentUserRole = ref.watch(currentUserRoleProvider);

  if (currentUserRole == null) {
    return [];
  }

  List<UserModel> users = [];

  // Get appropriate users based on current user role
  if (currentUserRole == UserRole.admin) {
    // Admin can see all users
    final allLeaders = ref.watch(leaderUsersProvider);
    final allClassLeaders = ref.watch(classLeaderUsersProvider);
    final allTelecallers = ref.watch(telecallerUsersProvider);

    users = [
      ...allLeaders.asData?.value ?? [],
      ...allClassLeaders.asData?.value ?? [],
      ...allTelecallers.asData?.value ?? [],
    ];
  } else if (currentUserRole == UserRole.leader) {
    // Leader can see their team
    final teamUsers = ref.watch(usersUnderCurrentLeaderProvider);
    users = teamUsers.asData?.value ?? [];
  } else if (currentUserRole == UserRole.classLeader) {
    // Class Leader can see their assigned telecallers
    final assignedTelecallers = ref.watch(telecallersForCurrentClassLeaderProvider);
    users = assignedTelecallers.asData?.value ?? [];
  }

  // Apply search filter
  if (searchQuery.isEmpty) {
    return users;
  }

  return users.where((user) {
    final query = searchQuery.toLowerCase();
    return user.name.toLowerCase().contains(query) ||
        user.email.toLowerCase().contains(query) ||
        user.role.displayName.toLowerCase().contains(query);
  }).toList();
});

// User Management Error Provider
final userManagementErrorProvider = Provider<String?>((ref) {
  final userManagementState = ref.watch(userManagementProvider);
  return userManagementState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// User Management Loading Provider
final userManagementLoadingProvider = Provider<bool>((ref) {
  final userManagementState = ref.watch(userManagementProvider);
  return userManagementState.when(
    data: (_) => false,
    loading: () => true,
    error: (_, __) => false,
  );
});