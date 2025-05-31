// This file is a placeholder for a navigation service.
// In this project, navigation is primarily handled directly by GoRouter's context extensions
// (e.g., context.go, context.push) within widgets.
// A NavigationService could be used to centralize navigation logic,
// especially for scenarios where navigation needs to be triggered from
// outside of a widget tree (e.g., from a Riverpod provider or a service).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/route_names.dart'; // Import RouteNames

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Private constructor
  NavigationService._internal();

  // Singleton instance
  static final NavigationService _instance = NavigationService._internal();

  // Factory constructor to return the singleton instance
  factory NavigationService() {
    return _instance;
  }

  // Get the current context
  BuildContext? get currentContext => navigatorKey.currentContext;

  // Navigate to a specific named route
  void go(String routeName) {
    if (currentContext != null) {
      currentContext!.goNamed(routeName);
    }
  }

  // Navigate to a specific path
  void goPath(String path) {
    if (currentContext != null) {
      currentContext!.go(path);
    }
  }

  // Push a new route onto the stack
  void push(String routeName, {Object? extra}) {
    if (currentContext != null) {
      currentContext!.pushNamed(routeName, extra: extra);
    }
  }

  // Push a new path onto the stack
  void pushPath(String path, {Object? extra}) {
    if (currentContext != null) {
      currentContext!.push(path, extra: extra);
    }
  }

  // Pop the current route from the stack
  bool pop<T extends Object?>([T? result]) {
    if (currentContext != null && currentContext!.canPop()) {
      currentContext!.pop(result);
      return true;
    }
    return false;
  }

  // Replace the current route with a new one
  void replace(String routeName, {Object? extra}) {
    if (currentContext != null) {
      currentContext!.replaceNamed(routeName, extra: extra);
    }
  }

  // Go to dashboard based on user role (example of centralized logic)
  void goToDashboardForRole(UserRole role) {
    String dashboardRoute;
    switch (role) {
      case UserRole.admin:
        dashboardRoute = RouteNames.adminDashboard;
        break;
      case UserRole.leader:
        dashboardRoute = RouteNames.leaderDashboard;
        break;
      case UserRole.classLeader:
      case UserRole.user:
        dashboardRoute = RouteNames.userDashboard;
        break;
      default:
        dashboardRoute = RouteNames.login; // Fallback
    }
    goPath(dashboardRoute);
  }
}