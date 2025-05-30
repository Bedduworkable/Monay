class RouteNames {
  RouteNames._();

  // Root routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String pendingApproval = '/pending-approval';

  // Dashboard routes
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/dashboard/admin';
  static const String leaderDashboard = '/dashboard/leader';
  static const String userDashboard = '/dashboard/user';

  // Lead management routes
  static const String leads = '/leads';
  static const String leadsList = '/leads/list';
  static const String addLead = '/leads/add';
  static const String editLead = '/leads/edit';
  static const String leadDetail = '/leads/detail';

  // User management routes
  static const String users = '/users';
  static const String usersList = '/users/list';
  static const String joinRequests = '/users/join-requests';
  static const String assignTelecallers = '/users/assign-telecallers';
  static const String userProfile = '/users/profile';

  // Settings routes
  static const String settings = '/settings';
  static const String adminSettings = '/settings/admin';
  static const String leaderSettings = '/settings/leader';
  static const String manageStatuses = '/settings/statuses';
  static const String manageFields = '/settings/fields';

  // Reports routes
  static const String reports = '/reports';
  static const String performanceReport = '/reports/performance';
  static const String conversionReport = '/reports/conversion';
  static const String teamReport = '/reports/team';

  // Renewal routes
  static const String renewals = '/renewals';
  static const String renewalStatus = '/renewals/status';

  // Notification routes
  static const String notifications = '/notifications';

  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // Route parameters
  static const String leadIdParam = 'leadId';
  static const String userIdParam = 'userId';
  static const String requestIdParam = 'requestId';

  // Route paths with parameters
  static String leadDetailPath(String leadId) => '/leads/detail/$leadId';
  static String editLeadPath(String leadId) => '/leads/edit/$leadId';
  static String userProfilePath(String userId) => '/users/profile/$userId';

  // Helper methods for navigation
  static Map<String, String> getLeadParams(String leadId) {
    return {leadIdParam: leadId};
  }

  static Map<String, String> getUserParams(String userId) {
    return {userIdParam: userId};
  }

  static Map<String, String> getRequestParams(String requestId) {
    return {requestIdParam: requestId};
  }

  // Route groups for role-based access
  static const List<String> adminOnlyRoutes = [
    adminDashboard,
    adminSettings,
    manageStatuses,
    manageFields,
  ];

  static const List<String> leaderOnlyRoutes = [
    leaderDashboard,
    leaderSettings,
    joinRequests,
    assignTelecallers,
    teamReport,
  ];

  static const List<String> userOnlyRoutes = [
    userDashboard,
  ];

  static const List<String> publicRoutes = [
    splash,
    login,
    signup,
    pendingApproval,
  ];

  static const List<String> protectedRoutes = [
    dashboard,
    leads,
    users,
    settings,
    reports,
    renewals,
    notifications,
    profile,
  ];
}