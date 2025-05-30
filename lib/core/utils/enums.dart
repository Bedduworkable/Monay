// User Roles in the CRM Hierarchy
enum UserRole {
  admin('Admin'),
  leader('Leader'),
  classLeader('ClassLeader'),
  user('User');

  const UserRole(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.leader:
        return 'Leader';
      case UserRole.classLeader:
        return 'Class Leader';
      case UserRole.user:
        return 'Telecaller';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isLeader => this == UserRole.leader;
  bool get isClassLeader => this == UserRole.classLeader;
  bool get isUser => this == UserRole.user;

  bool get canManageUsers => this == UserRole.admin || this == UserRole.leader;
  bool get canManageSettings => this == UserRole.admin || this == UserRole.leader;
  bool get canSeeAllLeads => this == UserRole.admin;
  bool get canAssignLeads => this == UserRole.admin || this == UserRole.leader || this == UserRole.classLeader;
}

// User Account Status
enum ApprovalStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const ApprovalStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Pending Approval';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ApprovalStatus.pending:
        return const Color(0xFFF59E0B); // Amber
      case ApprovalStatus.approved:
        return const Color(0xFF10B981); // Green
      case ApprovalStatus.rejected:
        return const Color(0xFFEF4444); // Red
    }
  }
}

// Join Request Status
enum JoinRequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const JoinRequestStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case JoinRequestStatus.pending:
        return 'Pending';
      case JoinRequestStatus.approved:
        return 'Approved';
      case JoinRequestStatus.rejected:
        return 'Rejected';
    }
  }
}

// Custom Field Types for Dynamic Forms
enum CustomFieldType {
  text('text'),
  number('number'),
  date('date'),
  dropdown('dropdown');

  const CustomFieldType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case CustomFieldType.text:
        return 'Text';
      case CustomFieldType.number:
        return 'Number';
      case CustomFieldType.date:
        return 'Date';
      case CustomFieldType.dropdown:
        return 'Dropdown';
    }
  }

  IconData get icon {
    switch (this) {
      case CustomFieldType.text:
        return Icons.text_fields;
      case CustomFieldType.number:
        return Icons.numbers;
      case CustomFieldType.date:
        return Icons.calendar_today;
      case CustomFieldType.dropdown:
        return Icons.arrow_drop_down;
    }
  }
}

// Dashboard Metrics Period
enum MetricsPeriod {
  today('today'),
  thisWeek('this_week'),
  thisMonth('this_month'),
  thisQuarter('this_quarter'),
  thisYear('this_year'),
  custom('custom');

  const MetricsPeriod(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case MetricsPeriod.today:
        return 'Today';
      case MetricsPeriod.thisWeek:
        return 'This Week';
      case MetricsPeriod.thisMonth:
        return 'This Month';
      case MetricsPeriod.thisQuarter:
        return 'This Quarter';
      case MetricsPeriod.thisYear:
        return 'This Year';
      case MetricsPeriod.custom:
        return 'Custom Range';
    }
  }
}

// Notification Types
enum NotificationType {
  leadAssigned('lead_assigned'),
  followupDue('followup_due'),
  joinRequest('join_request'),
  joinRequestApproved('join_request_approved'),
  joinRequestRejected('join_request_rejected'),
  renewalReminder('renewal_reminder'),
  accountExpiry('account_expiry');

  const NotificationType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case NotificationType.leadAssigned:
        return 'Lead Assigned';
      case NotificationType.followupDue:
        return 'Follow-up Due';
      case NotificationType.joinRequest:
        return 'Join Request';
      case NotificationType.joinRequestApproved:
        return 'Request Approved';
      case NotificationType.joinRequestRejected:
        return 'Request Rejected';
      case NotificationType.renewalReminder:
        return 'Renewal Reminder';
      case NotificationType.accountExpiry:
        return 'Account Expiry';
    }
  }
}