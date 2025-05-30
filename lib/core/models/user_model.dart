import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/enums.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? parentUid;
  final ApprovalStatus approvalStatus;
  final bool isClassLeader;
  final String? assignedToClassLeaderUid;
  final List<String> assignedTelecallerUids;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.parentUid,
    required this.approvalStatus,
    this.isClassLeader = false,
    this.assignedToClassLeaderUid,
    this.assignedTelecallerUids = const [],
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.fcmToken,
  });

  // Factory constructor from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
            (role) => role.value == data['role'],
        orElse: () => UserRole.user,
      ),
      parentUid: data['parentUid'],
      approvalStatus: ApprovalStatus.values.firstWhere(
            (status) => status.value == data['approvalStatus'],
        orElse: () => ApprovalStatus.pending,
      ),
      isClassLeader: data['isClassLeader'] ?? false,
      assignedToClassLeaderUid: data['assignedToClassLeaderUid'],
      assignedTelecallerUids: List<String>.from(data['assignedTelecallerUids'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      fcmToken: data['fcmToken'],
    );
  }

  // Factory constructor from Map
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
            (role) => role.value == data['role'],
        orElse: () => UserRole.user,
      ),
      parentUid: data['parentUid'],
      approvalStatus: ApprovalStatus.values.firstWhere(
            (status) => status.value == data['approvalStatus'],
        orElse: () => ApprovalStatus.pending,
      ),
      isClassLeader: data['isClassLeader'] ?? false,
      assignedToClassLeaderUid: data['assignedToClassLeaderUid'],
      assignedTelecallerUids: List<String>.from(data['assignedTelecallerUids'] ?? []),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data['updatedAt']),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] is Timestamp
          ? (data['expiresAt'] as Timestamp).toDate()
          : DateTime.parse(data['expiresAt']))
          : null,
      fcmToken: data['fcmToken'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.value,
      'parentUid': parentUid,
      'approvalStatus': approvalStatus.value,
      'isClassLeader': isClassLeader,
      'assignedToClassLeaderUid': assignedToClassLeaderUid,
      'assignedTelecallerUids': assignedTelecallerUids,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'fcmToken': fcmToken,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? parentUid,
    ApprovalStatus? approvalStatus,
    bool? isClassLeader,
    String? assignedToClassLeaderUid,
    List<String>? assignedTelecallerUids,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      parentUid: parentUid ?? this.parentUid,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isClassLeader: isClassLeader ?? this.isClassLeader,
      assignedToClassLeaderUid: assignedToClassLeaderUid ?? this.assignedToClassLeaderUid,
      assignedTelecallerUids: assignedTelecallerUids ?? this.assignedTelecallerUids,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  // Helper methods
  bool get isAdmin => role == UserRole.admin;
  bool get isLeader => role == UserRole.leader;
  bool get isUser => role == UserRole.user;

  bool get canManageUsers => role == UserRole.admin || role == UserRole.leader;
  bool get canManageSettings => role == UserRole.admin || role == UserRole.leader;
  bool get canSeeAllLeads => role == UserRole.admin;
  bool get canAssignLeads => role == UserRole.admin || role == UserRole.leader || role == UserRole.classLeader;

  bool get isApproved => approvalStatus == ApprovalStatus.approved;
  bool get isPending => approvalStatus == ApprovalStatus.pending;
  bool get isRejected => approvalStatus == ApprovalStatus.rejected;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final daysUntilExpiry = expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  int get daysUntilExpiry {
    if (expiresAt == null) return -1;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  String get displayRole => role.displayName;

  String get hierarchyLevel {
    switch (role) {
      case UserRole.admin:
        return 'Level 1 - Administrator';
      case UserRole.leader:
        return 'Level 2 - Leader';
      case UserRole.classLeader:
        return 'Level 3 - Class Leader';
      case UserRole.user:
        return 'Level 4 - Telecaller';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: ${role.value}, approvalStatus: ${approvalStatus.value})';
  }
}