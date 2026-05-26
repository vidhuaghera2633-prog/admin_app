import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/register_screen.dart';
import 'screens/layout/adaptive_scaffold.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/complaints/complaints_list_screen.dart';
import 'screens/complaints/complaint_detail_screen.dart';
import 'screens/technicians/technician_management_screen.dart';
import 'screens/customers/customer_management_screen.dart';
import 'screens/customers/customer_detail_screen.dart';
import 'screens/scheduling/scheduling_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      if (!auth.isInitialized) return '/splash';

      final isLoggedIn = auth.isLoggedIn;
      final isLoginRoute = state.matchedLocation == '/';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isSplashRoute = state.matchedLocation == '/splash';
      
      if (!isLoggedIn) {
        if (isLoginRoute || isRegisterRoute) return null;
        return '/';
      }
      
      if (isLoggedIn && (isLoginRoute || isRegisterRoute || isSplashRoute)) {
        return '/app/dashboard';
      }
      
      return null;
    },
    refreshListenable: auth,
    routes: [
      GoRoute(path: '/splash', builder: (ctx, state) => const SplashScreen()),
      GoRoute(path: '/', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (ctx, state) => const RegisterScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (ctx, state, child) => AdaptiveScaffold(child: child),
        routes: [
          GoRoute(path: '/app/dashboard', builder: (ctx, state) => const DashboardScreen()),
          GoRoute(path: '/app/complaints', builder: (ctx, state) => const ComplaintsListScreen()),
          GoRoute(path: '/app/complaints/:id', builder: (ctx, state) => ComplaintDetailScreen(id: state.pathParameters['id']!)),
          GoRoute(path: '/app/technicians', builder: (ctx, state) => const TechnicianManagementScreen()),
          GoRoute(path: '/app/customers', builder: (ctx, state) => const CustomerManagementScreen()),
          GoRoute(path: '/app/customers/:id', builder: (ctx, state) => CustomerDetailScreen(userId: state.pathParameters['id']!)),
          GoRoute(path: '/app/scheduling', builder: (ctx, state) => const SchedulingScreen()),
          GoRoute(path: '/app/map', builder: (ctx, state) => const MapScreen()),
          GoRoute(path: '/app/reports', builder: (ctx, state) => const ReportsScreen()),
          GoRoute(path: '/app/settings', builder: (ctx, state) => const SettingsScreen()),
        ],
      ),
    ],
  );
}