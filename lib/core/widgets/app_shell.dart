import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const _desktopBreakpoint = 1000.0;

  int get _selectedIndex {
    const paths = [
      '/dashboard',
      '/animals',
      '/milk',
      '/health',
      '/breeding',
      '/pregnancy',
      '/feed',
      '/inventory',
      '/finance',
      '/customers',
      '/suppliers',
      '/staff',
      '/tasks',
      '/assets',
      '/reports',
      '/ai',
      '/settings',
    ];
    final index = paths.indexOf(location);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final strings = AppStrings.of(context);

    if (width < _desktopBreakpoint) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
          onDestinationSelected: (index) => _onMobileDestination(context, index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard_rounded),
              label: strings.get('dashboard'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.pets_outlined),
              selectedIcon: const Icon(Icons.pets_rounded),
              label: strings.get('animals'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.water_drop_outlined),
              selectedIcon: const Icon(Icons.water_drop_rounded),
              label: strings.get('milk'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.task_alt_outlined),
              selectedIcon: const Icon(Icons.task_alt_rounded),
              label: strings.get('tasks'),
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'More',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _DesktopSidebar(selectedIndex: _selectedIndex),
          Expanded(
            child: Column(
              children: [
                _TopBar(location: location),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMobileDestination(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        return;
      case 1:
        context.go('/animals');
        return;
      case 2:
        context.go('/milk');
        return;
      case 3:
        context.go('/tasks');
        return;
      case 4:
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (context) => const _MoreMenuSheet(),
        );
    }
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
      width: 268,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.card,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.asset(
                      'assets/logo/satva_dhara_logo.jpg',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SATVA DHARA',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'DAIRY FARM ERP',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                letterSpacing: 1.2,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _section(strings.get('main')),
                  _item(context, 0, Icons.dashboard_outlined, strings.get('dashboard'), '/dashboard'),
                  _section(strings.get('operations')),
                  _item(context, 1, Icons.pets_outlined, strings.get('animals'), '/animals'),
                  _item(context, 2, Icons.water_drop_outlined, strings.get('milk'), '/milk'),
                  _item(context, 3, Icons.medical_services_outlined, strings.get('health'), '/health'),
                  _item(context, 4, Icons.sync_alt_outlined, strings.get('breeding'), '/breeding'),
                  _item(context, 5, Icons.favorite_outline, strings.get('pregnancy'), '/pregnancy'),
                  _item(context, 6, Icons.grass_outlined, strings.get('feed'), '/feed'),
                  _item(context, 7, Icons.inventory_2_outlined, strings.get('inventory'), '/inventory'),
                  _section(strings.get('business')),
                  _item(context, 8, Icons.account_balance_wallet_outlined, strings.get('finance'), '/finance'),
                  _item(context, 9, Icons.people_outline, strings.get('customers'), '/customers'),
                  _item(context, 10, Icons.local_shipping_outlined, strings.get('suppliers'), '/suppliers'),
                  _item(context, 11, Icons.badge_outlined, strings.get('staff'), '/staff'),
                  _item(context, 12, Icons.task_alt_outlined, strings.get('tasks'), '/tasks'),
                  _item(context, 13, Icons.precision_manufacturing_outlined, strings.get('assets'), '/assets'),
                  _section(strings.get('intelligence')),
                  _item(context, 14, Icons.analytics_outlined, strings.get('reports'), '/reports'),
                  _item(context, 15, Icons.auto_awesome_outlined, strings.get('ai'), '/ai'),
                  _section(strings.get('system')),
                  _item(context, 16, Icons.settings_outlined, strings.get('settings'), '/settings'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'AI Farm Brain\ncoming in the intelligence phase',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String label, String path) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.go(path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.location});

  final String location;

  String _title(BuildContext context) {
    final strings = AppStrings.of(context);
    const map = {
      '/dashboard': 'dashboard',
      '/animals': 'animals',
      '/milk': 'milk',
      '/health': 'health',
      '/breeding': 'breeding',
      '/pregnancy': 'pregnancy',
      '/feed': 'feed',
      '/inventory': 'inventory',
      '/finance': 'finance',
      '/customers': 'customers',
      '/suppliers': 'suppliers',
      '/staff': 'staff',
      '/tasks': 'tasks',
      '/assets': 'assets',
      '/reports': 'reports',
      '/ai': 'ai',
      '/settings': 'settings',
    };
    final key = map[location] ?? 'dashboard';
    return strings.get(key);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Text(
            _title(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          SizedBox(
            width: 340,
            child: TextField(
              decoration: InputDecoration(
                hintText: strings.get('searchHint'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Chip(label: Text('Ctrl K')),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Satva Dhara Farm'),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_outline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MoreMenuSheet extends StatelessWidget {
  const _MoreMenuSheet();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final items = [
      ('Health', '/health', Icons.medical_services_outlined),
      ('Pregnancy', '/pregnancy', Icons.favorite_outline),
      ('Inventory', '/inventory', Icons.inventory_2_outlined),
      ('Finance', '/finance', Icons.account_balance_wallet_outlined),
      ('Reports', '/reports', Icons.analytics_outlined),
      (strings.get('settings'), '/settings', Icons.settings_outlined),
    ];

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(item.$3),
          title: Text(item.$1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          onTap: () {
            Navigator.pop(context);
            context.go(item.$2);
          },
        );
      },
    );
  }
}
