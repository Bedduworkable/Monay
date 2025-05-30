import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String leaderEmail,
  }) async {
    try {
      // Check if leader exists
      final leaderQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: leaderEmail)
          .where('role', whereIn: [UserRole.admin.value, UserRole.leader.value])
          .where('approvalStatus', isEqualTo: ApprovalStatus.approved.value)
          .limit(1)
          .get();

      if (leaderQuery.docs.isEmpty) {
        return AuthResult.failure('Leader not found with this email address');
      }

      final leaderData = leaderQuery.docs.first;
      final targetLeaderUid = leaderData.id;

      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Failed to create user account');
      }

      // Update display name
      await user.updateDisplayName(name);

      final now = DateTime.now();

      // Create user document in Firestore with pending status
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        role: UserRole.user,
        parentUid: targetLeaderUid,
        approvalStatus: ApprovalStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());

      // Create join request
      final joinRequest = {
        'requestingUserUid': user.uid,
        'requestingUserEmail': email,
        'requestingUserName': name,
        'leaderEmail': leaderEmail,
        'targetLeaderUid': targetLeaderUid,
        'status': JoinRequestStatus.pending.value,
        'requestedAt': Timestamp.fromDate(now),
      };

      await _firestore
          .collection(AppConstants.joinRequestsCollection)
          .add(joinRequest);

      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await signOut();
        return AuthResult.failure('User profile not found');
      }

      final userModel = UserModel.fromFirestore(userDoc);

      // Check if user is approved
      if (userModel.approvalStatus != ApprovalStatus.approved) {
        await signOut();
        return AuthResult.failure('Your account is pending approval');
      }

      // Check if account is expired
      if (userModel.isExpired) {
        await signOut();
        return AuthResult.failure('Your account has expired. Please contact your leader for renewal.');
      }

      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }

  // Update FCM token
  Future<void> updateFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'fcmToken': token,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // Silently fail for FCM token update
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to send password reset email');
    }
  }

  // Update password
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      await user.updatePassword(newPassword);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to update password');
    }
  }

  // Update email
  Future<AuthResult> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      await user.updateEmail(newEmail);

      // Update email in Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'email': newEmail,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to update email');
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      // Soft delete in Firestore first
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'isDeleted': true,
        'deletedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Delete Firebase Auth account
      await user.delete();

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to delete account');
    }
  }

  // Reauthenticate user (required for sensitive operations)
  Future<AuthResult> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to verify password');
    }
  }

  // Private helper method to get user-friendly error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again to perform this action.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

// Auth Result Class
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel? user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(isSuccess: false, errorMessage: errorMessage);
  }
}