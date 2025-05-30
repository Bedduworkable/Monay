class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'IGPL Monday';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Real Estate CRM System';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String leadsCollection = 'leads';
  static const String settingsCollection = 'settings';
  static const String joinRequestsCollection = 'joinRequests';
  static const String notificationsCollection = 'notifications';

  // User Roles
  static const String adminRole = 'Admin';
  static const String leaderRole = 'Leader';
  static const String classLeaderRole = 'ClassLeader';
  static const String userRole = 'User';

  // Approval Status
  static const String pendingStatus = 'pending';
  static const String approvedStatus = 'approved';
  static const String rejectedStatus = 'rejected';

  // Default Lead Statuses
  static const List<String> defaultLeadStatuses = [
    'New',
    'Contacted',
    'Follow Up',
    'Site Visit Scheduled',
    'Visit Done',
    'Negotiation',
    'Converted',
    'Lost',
  ];

  // Default Custom Fields
  static const List<Map<String, dynamic>> defaultCustomFields = [
    {
      'fieldId': 'project_name',
      'label': 'Project Name',
      'type': 'text',
      'isRequired': true,
      'order': 1,
    },
    {
      'fieldId': 'client_type',
      'label': 'Client Type',
      'type': 'dropdown',
      'options': ['Investor', 'End-User', 'Broker'],
      'isRequired': false,
      'order': 2,
    },
    {
      'fieldId': 'budget',
      'label': 'Budget',
      'type': 'number',
      'isRequired': false,
      'order': 3,
    },
    {
      'fieldId': 'next_visit_date',
      'label': 'Next Visit Date',
      'type': 'date',
      'isRequired': false,
      'order': 4,
    },
  ];

  // Renewal Constants
  static const int renewalValidityYears = 2;
  static const double renewalCostINR = 200.0;
  static const List<int> renewalReminderDays = [30, 15, 7];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Sidebar Constants
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const Duration sidebarAnimationDuration = Duration(milliseconds: 300);

  // Notification Constants
  static const String fcmServerKey = 'your_fcm_server_key_here';
  static const String fcmSenderId = 'your_fcm_sender_id_here';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 254;
  static const int maxRemarkLength = 500;
  static const int maxCustomFieldOptions = 20;

  // File Upload Constants
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String unauthorizedErrorMessage = 'You are not authorized to perform this action.';
  static const String sessionExpiredMessage = 'Your session has expired. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String signupSuccessMessage = 'Account created successfully. Waiting for approval.';
  static const String leadCreatedMessage = 'Lead created successfully.';
  static const String leadUpdatedMessage = 'Lead updated successfully.';
  static const String settingsUpdatedMessage = 'Settings updated successfully.';
  static const String userPromotedMessage = 'User promoted successfully.';
  static const String userAssignedMessage = 'User assigned successfully.';

  // Chart Colors (Hex values for compatibility)
  static const List<String> chartColorHex = [
    '#2563EB', // Blue
    '#10B981', // Green
    '#F59E0B', // Amber
    '#EF4444', // Red
    '#8B5CF6', // Purple
    '#06B6D4', // Cyan
    '#EC4899', // Pink
    '#84CC16', // Lime
  ];

  // Dashboard Metrics
  static const List<String> userDashboardMetrics = [
    'Total Leads',
    'This Month Leads',
    'Follow-ups Due',
    'Converted Leads',
  ];

  static const List<String> leaderDashboardMetrics = [
    'Team Total Leads',
    'Team Conversions',
    'Active Telecallers',
    'Pending Requests',
  ];

  static const List<String> adminDashboardMetrics = [
    'Total Users',
    'Total Leads',
    'Active Leaders',
    'System Conversions',
  ];

  // Navigation Labels
  static const Map<String, String> navigationLabels = {
    'dashboard': 'Dashboard',
    'leads': 'Leads',
    'users': 'Users',
    'settings': 'Settings',
    'reports': 'Reports',
    'renewals': 'Renewals',
    'profile': 'Profile',
    'notifications': 'Notifications',
  };

  // Custom Field Types
  static const Map<String, String> customFieldTypes = {
    'text': 'Text',
    'number': 'Number',
    'date': 'Date',
    'dropdown': 'Dropdown',
  };

  // Lead Status Colors (for UI consistency)
  static const Map<String, String> leadStatusColors = {
    'new': '#8B5CF6',
    'contacted': '#06B6D4',
    'follow up': '#F59E0B',
    'site visit scheduled': '#3B82F6',
    'visit done': '#84CC16',
    'negotiation': '#F97316',
    'converted': '#10B981',
    'lost': '#EF4444',
  };

  // Shared Preferences Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String lastSyncKey = 'last_sync';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String nameRegex = r'^[a-zA-Z\s]{2,50}$';

  // API Endpoints (if using custom backend in future)
  static const String baseUrl = 'https://api.igplmonday.com';
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String leadsEndpoint = '/leads';
  static const String usersEndpoint = '/users';
  static const String settingsEndpoint = '/settings';

  // Feature Flags
  static const bool enableNotifications = true;
  static const bool enableCharts = true;
  static const bool enableExport = true;
  static const bool enableDarkMode = false;

  // Cache Keys
  static const String leadsCache = 'leads_cache';
  static const String usersCache = 'users_cache';
  static const String settingsCache = 'settings_cache';
  static const String dashboardCache = 'dashboard_cache';

  // Time Constants
  static const int sessionTimeoutMinutes = 60;
  static const int cacheExpiryHours = 24;
  static const int notificationRetryAttempts = 3;
}