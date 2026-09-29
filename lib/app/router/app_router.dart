import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../core/widgets/module_placeholder_screen.dart';
import '../app_bootstrap.dart';
import '../localization/app_localizations.dart';
import '../../core/widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) {
    if (!AppBootstrap.firebaseAvailable) {
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;
    final onAuth = state.uri.path == '/auth';

    if (user == null && !onAuth) return '/auth';
    if (user != null && onAuth) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        ..._moduleRoutes,
      ],
    ),
  ],
  errorBuilder: (context, state) => ModulePlaceholderScreen(
    title: 'Page not found',
    subtitle: state.error?.toString() ?? 'Unknown route',
  ),
);

final _moduleRoutes = <GoRoute>[
  _route('/animals', 'animals', Icons.pets_outlined),
  _route('/milk', 'milk', Icons.water_drop_outlined),
  _route('/health', 'health', Icons.medical_services_outlined),
  _route('/breeding', 'breeding', Icons.sync_alt_outlined),
  _route('/pregnancy', 'pregnancy', Icons.favorite_outline),
  _route('/feed', 'feed', Icons.grass_outlined),
  _route('/inventory', 'inventory', Icons.inventory_2_outlined),
  _route('/finance', 'finance', Icons.account_balance_wallet_outlined),
  _route('/customers', 'customers', Icons.people_outline),
  _route('/suppliers', 'suppliers', Icons.local_shipping_outlined),
  _route('/staff', 'staff', Icons.badge_outlined),
  _route('/tasks', 'tasks', Icons.task_alt_outlined),
  _route('/assets', 'assets', Icons.precision_manufacturing_outlined),
  _route('/reports', 'reports', Icons.analytics_outlined),
  _route('/ai', 'ai', Icons.auto_awesome_outlined),
  _route('/settings', 'settings', Icons.settings_outlined),
];

GoRoute _route(String path, String key, IconData icon) {
  return GoRoute(
    path: path,
    builder: (context, state) => ModulePlaceholderScreen(
      title: AppStrings.of(context).get(key),
      subtitle: 'Foundation route ready. Business functionality will be implemented here.',
      icon: icon,
    ),
  );
}
