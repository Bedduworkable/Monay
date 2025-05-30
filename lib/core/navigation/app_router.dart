import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/enums.dart';
import 'route_names.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/dashboard/screens/admin_dashboard.dart';
import '../../features/dashboard/screens/leader_dashboard.dart';
import '../../features/dashboard/screens/user_dashboard.dart';

// App Router Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: RouteNames.login,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Get auth state
      final authState = ref.read(authNotifierProvider);
      final isSignedIn = authState.hasValue && authState.value != null;
      final user = authState.value;

      final isOnAuthPage = [
        RouteNames.login,
        RouteNames.signup,
        RouteNames.pendingApproval,
      ].contains(state.location);

      // If not signed in and not on auth page, redirect to login
      if (!isSignedIn && !isOnAuthPage) {
        return RouteNames.login;
      }

      // If signed in but account pending approval
      if (isSignedIn && user?.approvalStatus == ApprovalStatus.pending) {
        if (state.location != RouteNames.pendingApproval) {
          return RouteNames.pendingApproval;
        }
        return null;
      }

      // If signed in and approved, redirect to appropriate dashboard
      if (isSignedIn && user?.isApproved == true && isOnAuthPage) {
        return _getDashboardRoute(user!.role);
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.pendingApproval,
        name: 'pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),

      // Dashboard Routes
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        redirect: (context, state) {
          final user = ref.read(authNotifierProvider).value;
          if (user == null) return RouteNames.login;
          return _getDashboardRoute(user.role);
        },
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: RouteNames.leaderDashboard,
        name: 'leader-dashboard',
        builder: (context, state) => const LeaderDashboard(),
      ),
      GoRoute(
        path: RouteNames.userDashboard,
        name: 'user-dashboard',
        builder: (context, state) => const UserDashboard(),
      ),

      // Lead Routes
      GoRoute(
        path: RouteNames.leads,
        name: 'leads',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Leads Screen - Coming Soon')),
        ),
        routes: [
          GoRoute(
            path: '/list',
            name: 'leads-list',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Leads List - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/add',
            name: 'add-lead',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Add Lead - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/edit/:${RouteNames.leadIdParam}',
            name: 'edit-lead',
            builder: (context, state) {
              final leadId = state.pathParameters[RouteNames.leadIdParam]!;
              return Scaffold(
                body: Center(child: Text('Edit Lead: $leadId - Coming Soon')),
              );
            },
          ),
          GoRoute(
            path: '/detail/:${RouteNames.leadIdParam}',
            name: 'lead-detail',
            builder: (context, state) {
              final leadId = state.pathParameters[RouteNames.leadIdParam]!;
              return Scaffold(
                body: Center(child: Text('Lead Detail: $leadId - Coming Soon')),
              );
            },
          ),
        ],
      ),

      // User Management Routes
      GoRoute(
        path: RouteNames.users,
        name: 'users',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Users Screen - Coming Soon')),
        ),
        routes: [
          GoRoute(
            path: '/list',
            name: 'users-list',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Users List - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/join-requests',
            name: 'join-requests',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Join Requests - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/assign-telecallers',
            name: 'assign-telecallers',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Assign Telecallers - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/profile/:${RouteNames.userIdParam}',
            name: 'user-profile',
            builder: (context, state) {
              final userId = state.pathParameters[RouteNames.userIdParam]!;
              return Scaffold(
                body: Center(child: Text('User Profile: $userId - Coming Soon')),
              );
            },
          ),
        ],
      ),

      // Settings Routes
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings Screen - Coming Soon')),
        ),
        routes: [
          GoRoute(
            path: '/admin',
            name: 'admin-settings',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Admin Settings - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/leader',
            name: 'leader-settings',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Leader Settings - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/statuses',
            name: 'manage-statuses',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Manage Statuses - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/fields',
            name: 'manage-fields',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Manage Fields - Coming Soon')),
            ),
          ),
        ],
      ),

      // Reports Routes
      GoRoute(
        path: RouteNames.reports,
        name: 'reports',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Reports Screen - Coming Soon')),
        ),
        routes: [
          GoRoute(
            path: '/performance',
            name: 'performance-report',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Performance Report - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/conversion',
            name: 'conversion-report',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Conversion Report - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/team',
            name: 'team-report',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Team Report - Coming Soon')),
            ),
          ),
        ],
      ),

      // Renewal Routes
      GoRoute(
        path: RouteNames.renewals,
        name: 'renewals',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Renewals Screen - Coming Soon')),
        ),
        routes: [
          GoRoute(
            path: '/status',
            name: 'renewal-status',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Renewal Status - Coming Soon')),
            ),
          ),
        ],
      ),

      // Notifications Route
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Notifications - Coming Soon')),
        ),
      ),

      // Profile Routes
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile Screen - Coming Soon')),
        ),
        routes: [
          GoRoute(
            path: '/edit',
            name: 'edit-profile',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Edit Profile - Coming Soon')),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.location}" could not be found.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Helper function to get dashboard route based on user role
String _getDashboardRoute(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return RouteNames.adminDashboard;
    case UserRole.leader:
      return RouteNames.leaderDashboard;
    case UserRole.classLeader:
    case UserRole.user:
      return RouteNames.userDashboard;
  }
}