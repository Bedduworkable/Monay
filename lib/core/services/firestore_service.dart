import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/lead_model.dart';
import '../models/settings_model.dart';
import '../models/join_request_model.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // USERS COLLECTION METHODS

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(UserRole role) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: role.value)
        .where('approvalStatus', isEqualTo: ApprovalStatus.approved.value)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }

  // Get users under a leader
  Stream<List<UserModel>> getUsersUnderLeader(String leaderUid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('parentUid', isEqualTo: leaderUid)
        .where('approvalStatus', isEqualTo: ApprovalStatus.approved.value)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }

  // Get telecallers assigned to class leader
  Stream<List<UserModel>> getTelecallersForClassLeader(String classLeaderUid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('assignedToClassLeaderUid', isEqualTo: classLeaderUid)
        .where('role', isEqualTo: UserRole.user.value)
        .where('approvalStatus', isEqualTo: ApprovalStatus.approved.value)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Promote user to class leader
  Future<void> promoteUserToClassLeader(String userId) async {
    try {
      await updateUser(userId, {
        'role': UserRole.classLeader.value,
        'isClassLeader': true,
      });
    } catch (e) {
      throw Exception('Failed to promote user: $e');
    }
  }

  // Assign telecaller to class leader
  Future<void> assignTelecallerToClassLeader(String telecallerUid, String classLeaderUid) async {
    try {
      final batch = _firestore.batch();

      // Update telecaller
      final telecallerRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(telecallerUid);
      batch.update(telecallerRef, {
        'assignedToClassLeaderUid': classLeaderUid,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update class leader's assigned list
      final classLeaderRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(classLeaderUid);
      batch.update(classLeaderRef, {
        'assignedTelecallerUids': FieldValue.arrayUnion([telecallerUid]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to assign telecaller: $e');
    }
  }

  // LEADS COLLECTION METHODS

  // Create lead
  Future<String> createLead(LeadModel lead) async {
    try {
      final docRef = _firestore.collection(AppConstants.leadsCollection).doc();
      final leadWithId = lead.copyWith(leadId: docRef.id);
      await docRef.set(leadWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create lead: $e');
    }
  }

  // Get lead by ID
  Future<LeadModel?> getLeadById(String leadId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.leadsCollection)
          .doc(leadId)
          .get();

      if (doc.exists) {
        return LeadModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get lead: $e');
    }
  }

  // Get leads for user (telecaller)
  Stream<List<LeadModel>> getLeadsForUser(String userId) {
    return _firestore
        .collection(AppConstants.leadsCollection)
        .where('assignedToUid', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => LeadModel.fromFirestore(doc))
        .toList());
  }

  // Get leads for class leader
  Stream<List<LeadModel>> getLeadsForClassLeader(String classLeaderUid) {
    return _firestore
        .collection(AppConstants.leadsCollection)
        .where('parentClassLeaderUid', isEqualTo: classLeaderUid)
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => LeadModel.fromFirestore(doc))
        .toList());
  }

  // Get leads for leader
  Stream<List<LeadModel>> getLeadsForLeader(String leaderUid) {
    return _firestore
        .collection(AppConstants.leadsCollection)
        .where('parentLeaderUid', isEqualTo: leaderUid)
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => LeadModel.fromFirestore(doc))
        .toList());
  }

  // Get all leads (admin)
  Stream<List<LeadModel>> getAllLeads() {
    return _firestore
        .collection(AppConstants.leadsCollection)
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => LeadModel.fromFirestore(doc))
        .toList());
  }

  // Update lead
  Future<void> updateLead(String leadId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore
          .collection(AppConstants.leadsCollection)
          .doc(leadId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update lead: $e');
    }
  }

  // Add remark to lead
  Future<void> addRemarkToLead(String leadId, String text, String byUid, String byName) async {
    try {
      final remark = RemarkModel(
        remarkId: _uuid.v4(),
        text: text,
        createdAt: DateTime.now(),
        byUid: byUid,
        byName: byName,
      );

      await _firestore
          .collection(AppConstants.leadsCollection)
          .doc(leadId)
          .update({
        'remarks': FieldValue.arrayUnion([remark.toMap()]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to add remark: $e');
    }
  }

  // Soft delete lead
  Future<void> deleteLead(String leadId) async {
    try {
      await updateLead(leadId, {'isDeleted': true});
    } catch (e) {
      throw Exception('Failed to delete lead: $e');
    }
  }

  // Get follow-up leads for today
  Stream<List<LeadModel>> getFollowUpLeadsForToday(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _firestore
        .collection(AppConstants.leadsCollection)
        .where('assignedToUid', isEqualTo: userId)
        .where('followUpDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('followUpDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => LeadModel.fromFirestore(doc))
        .toList());
  }

  // SETTINGS COLLECTION METHODS

  // Get settings for leader
  Future<SettingsModel?> getSettingsForLeader(String leaderUid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.settingsCollection)
          .doc(leaderUid)
          .get();

      if (doc.exists) {
        return SettingsModel.fromFirestore(doc);
      }

      // Return default settings if none exist
      return _createDefaultSettings(leaderUid);
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  // Update settings
  Future<void> updateSettings(SettingsModel settings) async {
    try {
      await _firestore
          .collection(AppConstants.settingsCollection)
          .doc(settings.settingsId)
          .set(settings.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // Create default settings
  Future<SettingsModel> _createDefaultSettings(String leaderUid) async {
    final settings = SettingsModel(
      settingsId: leaderUid,
      customStatuses: AppConstants.defaultLeadStatuses,
      customFields: AppConstants.defaultCustomFields
          .map((field) => CustomFieldModel.fromMap(field))
          .toList(),
      updatedAt: DateTime.now(),
    );

    await updateSettings(settings);
    return settings;
  }

  // JOIN REQUESTS COLLECTION METHODS

  // Get join requests for leader
  Stream<List<JoinRequestModel>> getJoinRequestsForLeader(String leaderUid) {
    return _firestore
        .collection(AppConstants.joinRequestsCollection)
        .where('targetLeaderUid', isEqualTo: leaderUid)
        .where('status', isEqualTo: JoinRequestStatus.pending.value)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => JoinRequestModel.fromFirestore(doc))
        .toList());
  }

  // Approve join request
  Future<void> approveJoinRequest(String requestId, String approverUid) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();

      // Update join request
      final requestRef = _firestore
          .collection(AppConstants.joinRequestsCollection)
          .doc(requestId);
      batch.update(requestRef, {
        'status': JoinRequestStatus.approved.value,
        'actionedAt': Timestamp.fromDate(now),
        'actionedByUid': approverUid,
      });

      // Get request data to update user
      final requestDoc = await requestRef.get();
      final requestData = JoinRequestModel.fromFirestore(requestDoc);

      // Update user status
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(requestData.requestingUserUid);
      batch.update(userRef, {
        'approvalStatus': ApprovalStatus.approved.value,
        'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 730))), // 2 years
        'updatedAt': Timestamp.fromDate(now),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to approve request: $e');
    }
  }

  // Reject join request
  Future<void> rejectJoinRequest(String requestId, String rejecterUid) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();

      // Update join request
      final requestRef = _firestore
          .collection(AppConstants.joinRequestsCollection)
          .doc(requestId);
      batch.update(requestRef, {
        'status': JoinRequestStatus.rejected.value,
        'actionedAt': Timestamp.fromDate(now),
        'actionedByUid': rejecterUid,
      });

      // Get request data to update user
      final requestDoc = await requestRef.get();
      final requestData = JoinRequestModel.fromFirestore(requestDoc);

      // Update user status
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(requestData.requestingUserUid);
      batch.update(userRef, {
        'approvalStatus': ApprovalStatus.rejected.value,
        'updatedAt': Timestamp.fromDate(now),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reject request: $e');
    }
  }

  // ANALYTICS & METRICS METHODS

  // Get lead count by status for user
  Future<Map<String, int>> getLeadCountByStatus(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.leadsCollection)
          .where('assignedToUid', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .get();

      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final lead = LeadModel.fromFirestore(doc);
        counts[lead.status] = (counts[lead.status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get lead counts: $e');
    }
  }

  // Get total leads count
  Future<int> getTotalLeadsCount() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.leadsCollection)
          .where('isDeleted', isEqualTo: false)
          .count()
          .get();

      return snapshot.count;
    } catch (e) {
      throw Exception('Failed to get total leads count: $e');
    }
  }

  // Get users count by role
  Future<Map<String, int>> getUsersCountByRole() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('approvalStatus', isEqualTo: ApprovalStatus.approved.value)
          .get();

      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final user = UserModel.fromFirestore(doc);
        counts[user.role.value] = (counts[user.role.value] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get user counts: $e');
    }
  }

  // Batch operations
  WriteBatch get batch => _firestore.batch();

  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to commit batch: $e');
    }
  }
}