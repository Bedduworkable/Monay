import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Firebase Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Profile Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final authState = ref.watch(authStateProvider);

  await for (final user in authState.when(
    data: (user) => Stream.value(user),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  )) {
    if (user == null) {
      yield null;
    } else {
      try {
        final authService = ref.read(authServiceProvider);
        final userProfile = await authService.getCurrentUserProfile();
        yield userProfile;
      } catch (e) {
        yield null;
      }
    }
  }
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier(this._authService, this._notificationService)
      : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthService _authService;
  final NotificationService _notificationService;

  Future<void> _init() async {
    try {
      // Initialize notification service
      await _notificationService.initialize();

      // Get current user if signed in
      if (_authService.isSignedIn) {
        final userProfile = await _authService.getCurrentUserProfile();
        state = AsyncValue.data(userProfile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String leaderEmail,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
        leaderEmail: leaderEmail,
      );

      if (result.isSuccess) {
        state = AsyncValue.data(result.user);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        state = AsyncValue.data(result.user);

        // Subscribe to relevant notification topics based on user role
        if (result.user != null) {
          await _subscribeToNotificationTopics(result.user!);
        }
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Unsubscribe from notification topics
      final currentUser = state.value;
      if (currentUser != null) {
        await _unsubscribeFromNotificationTopics(currentUser);
      }

      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      final result = await _authService.resetPassword(email);
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      final result = await _authService.updatePassword(newPassword);
      if (result.isSuccess) {
        // Refresh user data
        await _refreshUserData();
      }
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  // Update email
  Future<bool> updateEmail(String newEmail) async {
    try {
      final result = await _authService.updateEmail(newEmail);
      if (result.isSuccess) {
        // Refresh user data
        await _refreshUserData();
      }
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    await _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    try {
      if (_authService.isSignedIn) {
        final userProfile = await _authService.getCurrentUserProfile();
        state = AsyncValue.data(userProfile);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Subscribe to notification topics based on user role
  Future<void> _subscribeToNotificationTopics(UserModel user) async {
    try {
      // Subscribe to general topics
      await _notificationService.subscribeToTopic('all_users');

      // Subscribe to role-specific topics
      switch (user.role) {
        case UserRole.admin:
          await _notificationService.subscribeToTopic('admins');
          await _notificationService.subscribeToTopic('leaders');
          break;
        case UserRole.leader:
          await _notificationService.subscribeToTopic('leaders');
          await _notificationService.subscribeToTopic('team_${user.uid}');
          break;
        case UserRole.classLeader:
          await _notificationService.subscribeToTopic('class_leaders');
          if (user.parentUid != null) {
            await _notificationService.subscribeToTopic('team_${user.parentUid}');
          }
          break;
        case UserRole.user:
          await _notificationService.subscribeToTopic('telecallers');
          if (user.parentUid != null) {
            await _notificationService.subscribeToTopic('team_${user.parentUid}');
          }
          break;
      }
    } catch (e) {
      // Silently fail for notification subscriptions
    }
  }

  // Unsubscribe from notification topics
  Future<void> _unsubscribeFromNotificationTopics(UserModel user) async {
    try {
      // Unsubscribe from general topics
      await _notificationService.unsubscribeFromTopic('all_users');

      // Unsubscribe from role-specific topics
      switch (user.role) {
        case UserRole.admin:
          await _notificationService.unsubscribeFromTopic('admins');
          await _notificationService.unsubscribeFromTopic('leaders');
          break;
        case UserRole.leader:
          await _notificationService.unsubscribeFromTopic('leaders');
          await _notificationService.unsubscribeFromTopic('team_${user.uid}');
          break;
        case UserRole.classLeader:
          await _notificationService.unsubscribeFromTopic('class_leaders');
          if (user.parentUid != null) {
            await _notificationService.unsubscribeFromTopic('team_${user.parentUid}');
          }
          break;
        case UserRole.user:
          await _notificationService.unsubscribeFromTopic('telecallers');
          if (user.parentUid != null) {
            await _notificationService.unsubscribeFromTopic('team_${user.parentUid}');
          }
          break;
      }
    } catch (e) {
      // Silently fail for notification unsubscriptions
    }
  }

  // Check if user account is expired
  bool get isAccountExpired {
    final user = state.value;
    return user?.isExpired ?? false;
  }

  // Check if account is expiring soon
  bool get isAccountExpiringSoon {
    final user = state.value;
    return user?.isExpiringSoon ?? false;
  }

  // Get days until expiry
  int get daysUntilExpiry {
    final user = state.value;
    return user?.daysUntilExpiry ?? -1;
  }
}

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return AuthNotifier(authService, notificationService);
});

// Convenience providers for common auth checks
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user?.role,
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
});

final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.admin;
});

final isLeaderProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.leader;
});

final isClassLeaderProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.classLeader;
});

final isUserProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.user;
});

final canManageUsersProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user?.canManageUsers ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

final canManageSettingsProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user?.canManageSettings ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

final canAssignLeadsProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user?.canAssignLeads ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Auth error provider for handling authentication errors
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// Loading state provider
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (_) => false,
    loading: () => true,
    error: (_, __) => false,
  );
});