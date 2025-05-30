import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/enums.dart';

class JoinRequestModel {
  final String requestId;
  final String requestingUserUid;
  final String requestingUserEmail;
  final String requestingUserName;
  final String leaderEmail;
  final String? targetLeaderUid;
  final JoinRequestStatus status;
  final DateTime requestedAt;
  final DateTime? actionedAt;
  final String? actionedByUid;

  const JoinRequestModel({
    required this.requestId,
    required this.requestingUserUid,
    required this.requestingUserEmail,
    required this.requestingUserName,
    required this.leaderEmail,
    this.targetLeaderUid,
    required this.status,
    required this.requestedAt,
    this.actionedAt,
    this.actionedByUid,
  });

  // Factory constructor from Firestore document
  factory JoinRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JoinRequestModel(
      requestId: doc.id,
      requestingUserUid: data['requestingUserUid'] ?? '',
      requestingUserEmail: data['requestingUserEmail'] ?? '',
      requestingUserName: data['requestingUserName'] ?? '',
      leaderEmail: data['leaderEmail'] ?? '',
      targetLeaderUid: data['targetLeaderUid'],
      status: JoinRequestStatus.values.firstWhere(
            (status) => status.value == data['status'],
        orElse: () => JoinRequestStatus.pending,
      ),
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      actionedAt: data['actionedAt'] != null
          ? (data['actionedAt'] as Timestamp).toDate()
          : null,
      actionedByUid: data['actionedByUid'],
    );
  }

  // Factory constructor from Map
  factory JoinRequestModel.fromMap(Map<String, dynamic> data, String requestId) {
    return JoinRequestModel(
      requestId: requestId,
      requestingUserUid: data['requestingUserUid'] ?? '',
      requestingUserEmail: data['requestingUserEmail'] ?? '',
      requestingUserName: data['requestingUserName'] ?? '',
      leaderEmail: data['leaderEmail'] ?? '',
      targetLeaderUid: data['targetLeaderUid'],
      status: JoinRequestStatus.values.firstWhere(
            (status) => status.value == data['status'],
        orElse: () => JoinRequestStatus.pending,
      ),
      requestedAt: data['requestedAt'] is Timestamp
          ? (data['requestedAt'] as Timestamp).toDate()
          : DateTime.parse(data['requestedAt']),
      actionedAt: data['actionedAt'] != null
          ? (data['actionedAt'] is Timestamp
          ? (data['actionedAt'] as Timestamp).toDate()
          : DateTime.parse(data['actionedAt']))
          : null,
      actionedByUid: data['actionedByUid'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'requestingUserUid': requestingUserUid,
      'requestingUserEmail': requestingUserEmail,
      'requestingUserName': requestingUserName,
      'leaderEmail': leaderEmail,
      'targetLeaderUid': targetLeaderUid,
      'status': status.value,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'actionedAt': actionedAt != null ? Timestamp.fromDate(actionedAt!) : null,
      'actionedByUid': actionedByUid,
    };
  }

  // Create a copy with updated fields
  JoinRequestModel copyWith({
    String? requestId,
    String? requestingUserUid,
    String? requestingUserEmail,
    String? requestingUserName,
    String? leaderEmail,
    String? targetLeaderUid,
    JoinRequestStatus? status,
    DateTime? requestedAt,
    DateTime? actionedAt,
    String? actionedByUid,
  }) {
    return JoinRequestModel(
      requestId: requestId ?? this.requestId,
      requestingUserUid: requestingUserUid ?? this.requestingUserUid,
      requestingUserEmail: requestingUserEmail ?? this.requestingUserEmail,
      requestingUserName: requestingUserName ?? this.requestingUserName,
      leaderEmail: leaderEmail ?? this.leaderEmail,
      targetLeaderUid: targetLeaderUid ?? this.targetLeaderUid,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      actionedAt: actionedAt ?? this.actionedAt,
      actionedByUid: actionedByUid ?? this.actionedByUid,
    );
  }

  // Helper methods
  bool get isPending => status == JoinRequestStatus.pending;
  bool get isApproved => status == JoinRequestStatus.approved;
  bool get isRejected => status == JoinRequestStatus.rejected;
  bool get isActioned => isApproved || isRejected;

  String get statusDisplayName => status.displayName;

  Duration get pendingDuration {
    if (isActioned && actionedAt != null) {
      return actionedAt!.difference(requestedAt);
    }
    return DateTime.now().difference(requestedAt);
  }

  String get formattedPendingDuration {
    final duration = pendingDuration;
    if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'}';
    } else {
      return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'}';
    }
  }

  bool get isOld {
    return pendingDuration.inDays > 7;
  }

  bool get isUrgent {
    return isPending && pendingDuration.inDays > 3;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JoinRequestModel && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;

  @override
  String toString() {
    return 'JoinRequestModel(requestId: $requestId, requestingUserName: $requestingUserName, status: ${status.value}, leaderEmail: $leaderEmail)';
  }
}