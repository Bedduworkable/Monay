import 'package:cloud_firestore/cloud_firestore.dart';

class LeadModel {
  final String leadId;
  final String createdByUid;
  final String assignedToUid;
  final String parentLeaderUid;
  final String? parentClassLeaderUid;
  final String status;
  final DateTime? followUpDate;
  final Map<String, dynamic> customFields;
  final List<RemarkModel> remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const LeadModel({
    required this.leadId,
    required this.createdByUid,
    required this.assignedToUid,
    required this.parentLeaderUid,
    this.parentClassLeaderUid,
    required this.status,
    this.followUpDate,
    this.customFields = const {},
    this.remarks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  // Factory constructor from Firestore document
  factory LeadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LeadModel(
      leadId: doc.id,
      createdByUid: data['createdByUid'] ?? '',
      assignedToUid: data['assignedToUid'] ?? '',
      parentLeaderUid: data['parentLeaderUid'] ?? '',
      parentClassLeaderUid: data['parentClassLeaderUid'],
      status: data['status'] ?? 'New',
      followUpDate: data['followUpDate'] != null
          ? (data['followUpDate'] as Timestamp).toDate()
          : null,
      customFields: Map<String, dynamic>.from(data['customFields'] ?? {}),
      remarks: (data['remarks'] as List<dynamic>? ?? [])
          .map((remarkData) => RemarkModel.fromMap(remarkData))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // Factory constructor from Map
  factory LeadModel.fromMap(Map<String, dynamic> data, String leadId) {
    return LeadModel(
      leadId: leadId,
      createdByUid: data['createdByUid'] ?? '',
      assignedToUid: data['assignedToUid'] ?? '',
      parentLeaderUid: data['parentLeaderUid'] ?? '',
      parentClassLeaderUid: data['parentClassLeaderUid'],
      status: data['status'] ?? 'New',
      followUpDate: data['followUpDate'] != null
          ? (data['followUpDate'] is Timestamp
          ? (data['followUpDate'] as Timestamp).toDate()
          : DateTime.parse(data['followUpDate']))
          : null,
      customFields: Map<String, dynamic>.from(data['customFields'] ?? {}),
      remarks: (data['remarks'] as List<dynamic>? ?? [])
          .map((remarkData) => RemarkModel.fromMap(remarkData))
          .toList(),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data['updatedAt']),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'leadId': leadId,
      'createdByUid': createdByUid,
      'assignedToUid': assignedToUid,
      'parentLeaderUid': parentLeaderUid,
      'parentClassLeaderUid': parentClassLeaderUid,
      'status': status,
      'followUpDate': followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'customFields': customFields,
      'remarks': remarks.map((remark) => remark.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
    };
  }

  // Create a copy with updated fields
  LeadModel copyWith({
    String? leadId,
    String? createdByUid,
    String? assignedToUid,
    String? parentLeaderUid,
    String? parentClassLeaderUid,
    String? status,
    DateTime? followUpDate,
    Map<String, dynamic>? customFields,
    List<RemarkModel>? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return LeadModel(
      leadId: leadId ?? this.leadId,
      createdByUid: createdByUid ?? this.createdByUid,
      assignedToUid: assignedToUid ?? this.assignedToUid,
      parentLeaderUid: parentLeaderUid ?? this.parentLeaderUid,
      parentClassLeaderUid: parentClassLeaderUid ?? this.parentClassLeaderUid,
      status: status ?? this.status,
      followUpDate: followUpDate ?? this.followUpDate,
      customFields: customFields ?? this.customFields,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // Helper methods
  String get leadTitle {
    // Try to get a meaningful title from custom fields
    if (customFields.containsKey('Project Name')) {
      return customFields['Project Name'].toString();
    }
    if (customFields.containsKey('Client Name')) {
      return customFields['Client Name'].toString();
    }
    if (customFields.containsKey('Property Type')) {
      return customFields['Property Type'].toString();
    }
    return 'Lead #${leadId.substring(0, 8)}';
  }

  String get clientName {
    if (customFields.containsKey('Client Name')) {
      return customFields['Client Name'].toString();
    }
    if (customFields.containsKey('Name')) {
      return customFields['Name'].toString();
    }
    return 'Client';
  }

  String? get clientPhone {
    if (customFields.containsKey('Phone')) {
      return customFields['Phone'].toString();
    }
    if (customFields.containsKey('Mobile')) {
      return customFields['Mobile'].toString();
    }
    return null;
  }

  String? get clientEmail {
    if (customFields.containsKey('Email')) {
      return customFields['Email'].toString();
    }
    return null;
  }

  double? get budget {
    if (customFields.containsKey('Budget')) {
      final budgetValue = customFields['Budget'];
      if (budgetValue is num) {
        return budgetValue.toDouble();
      }
      if (budgetValue is String) {
        return double.tryParse(budgetValue);
      }
    }
    return null;
  }

  bool get hasFollowUpDue {
    if (followUpDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final followUp = DateTime(followUpDate!.year, followUpDate!.month, followUpDate!.day);
    return followUp.isBefore(today) || followUp.isAtSameMomentAs(today);
  }

  bool get isFollowUpOverdue {
    if (followUpDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final followUp = DateTime(followUpDate!.year, followUpDate!.month, followUpDate!.day);
    return followUp.isBefore(today);
  }

  bool get isConverted {
    return status.toLowerCase().contains('converted') ||
        status.toLowerCase().contains('won') ||
        status.toLowerCase().contains('closed won');
  }

  bool get isLost {
    return status.toLowerCase().contains('lost') ||
        status.toLowerCase().contains('rejected') ||
        status.toLowerCase().contains('closed lost');
  }

  bool get isActive {
    return !isConverted && !isLost && !isDeleted;
  }

  RemarkModel? get latestRemark {
    if (remarks.isEmpty) return null;
    return remarks.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  int get remarkCount => remarks.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeadModel && other.leadId == leadId;
  }

  @override
  int get hashCode => leadId.hashCode;

  @override
  String toString() {
    return 'LeadModel(leadId: $leadId, status: $status, assignedToUid: $assignedToUid)';
  }
}

class RemarkModel {
  final String remarkId;
  final String text;
  final DateTime createdAt;
  final String byUid;
  final String byName;

  const RemarkModel({
    required this.remarkId,
    required this.text,
    required this.createdAt,
    required this.byUid,
    required this.byName,
  });

  // Factory constructor from Map
  factory RemarkModel.fromMap(Map<String, dynamic> data) {
    return RemarkModel(
      remarkId: data['remarkId'] ?? '',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      byUid: data['byUid'] ?? '',
      byName: data['byName'] ?? '',
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'remarkId': remarkId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'byUid': byUid,
      'byName': byName,
    };
  }

  // Create a copy with updated fields
  RemarkModel copyWith({
    String? remarkId,
    String? text,
    DateTime? createdAt,
    String? byUid,
    String? byName,
  }) {
    return RemarkModel(
      remarkId: remarkId ?? this.remarkId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      byUid: byUid ?? this.byUid,
      byName: byName ?? this.byName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RemarkModel && other.remarkId == remarkId;
  }

  @override
  int get hashCode => remarkId.hashCode;

  @override
  String toString() {
    return 'RemarkModel(remarkId: $remarkId, byName: $byName, text: ${text.substring(0, text.length.clamp(0, 50))}...)';
  }
}