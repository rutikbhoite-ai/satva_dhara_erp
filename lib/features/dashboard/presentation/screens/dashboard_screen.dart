import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app.dart';
import '../../../../app/app_bootstrap.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 820;

    return AppPage(
      title: strings.get('welcomeTitle'),
      subtitle: strings.get('welcomeSubtitle'),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          isCompact ? 16 : 28,
          0,
          isCompact ? 16 : 28,
          36,
        ),
        children: [
          _OverviewHero(strings: strings),
          const SizedBox(height: 18),
          _KpiSection(strings: strings, compact: isCompact),
          const SizedBox(height: 18),
          _QuickActions(strings: strings, compact: isCompact),
          const SizedBox(height: 18),
          _MainGrid(strings: strings, compact: isCompact),
          const SizedBox(height: 18),
          _OperationalModules(strings: strings, compact: isCompact),
        ],
      ),
    );
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showLogo = width >= 700;

    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: EdgeInsets.all(width < 700 ? 22 : 28),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatusPill(strings: strings),
                const SizedBox(height: 16),
                Text(
                  strings.get('today'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Farm Command Center',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Text(
                    'A single operational view for production, animals, tasks, finance and farm intelligence.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.74),
                          height: 1.5,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroChip(
                      icon: Icons.visibility_outlined,
                      label: 'What is happening today?',
                    ),
                    _HeroChip(
                      icon: Icons.flag_outlined,
                      label: 'What needs attention?',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showLogo) ...[
            const SizedBox(width: 28),
            const _BrandCard(),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final ready = AppBootstrap.firebaseAvailable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: ready ? AppColors.accent : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ready ? strings.get('firebaseReady') : strings.get('firebaseSetup'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.accent),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/logo/satva_dhara_logo.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _KpiSection extends StatelessWidget {
  const _KpiSection({required this.strings, required this.compact});

  final AppStrings strings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiData(
        icon: Icons.water_drop_outlined,
        label: strings.get('production'),
        helper: 'Milk production',
      ),
      _KpiData(
        icon: Icons.payments_outlined,
        label: strings.get('revenue'),
        helper: 'Farm income',
      ),
      _KpiData(
        icon: Icons.account_balance_wallet_outlined,
        label: strings.get('expenses'),
        helper: 'Farm spending',
      ),
      _KpiData(
        icon: Icons.priority_high_rounded,
        label: strings.get('attention'),
        helper: 'Critical changes',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: compact ? 2 : 4,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: compact ? 1.48 : 1.62,
      ),
      itemBuilder: (context, index) => _KpiCard(data: cards[index]),
    );
  }
}

class _KpiData {
  const _KpiData({required this.icon, required this.label, required this.helper});

  final IconData icon;
  final String label;
  final String helper;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 21),
          ),
          const Spacer(),
          Text(
            '—',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            data.helper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.strings, required this.compact});

  final AppStrings strings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(Icons.pets_rounded, strings.get('animals'), '/animals'),
      _ActionData(Icons.water_drop_rounded, strings.get('milk'), '/milk'),
      _ActionData(Icons.task_alt_rounded, strings.get('tasks'), '/tasks'),
      _ActionData(Icons.medical_services_rounded, strings.get('health'), '/health'),
      _ActionData(Icons.inventory_2_rounded, strings.get('inventory'), '/inventory'),
      _ActionData(Icons.auto_awesome_rounded, strings.get('ai'), '/ai'),
    ];

    return _SectionCard(
      title: 'Quick actions',
      subtitle: 'Jump directly into an operational area.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: actions
            .map(
              (action) => _ActionButton(
                data: action,
                compact: compact,
                onPressed: () => context.go(action.route),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ActionData {
  const _ActionData(this.icon, this.label, this.route);

  final IconData icon;
  final String label;
  final String route;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.data,
    required this.compact,
    required this.onPressed,
  });

  final _ActionData data;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 148 : 160,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(data.icon, size: 18),
        label: Text(
          data.label,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _MainGrid extends StatelessWidget {
  const _MainGrid({required this.strings, required this.compact});

  final AppStrings strings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final operational = _SectionCard(
      title: 'Today at a glance',
      subtitle: 'The dashboard becomes data-driven as modules are activated.',
      child: Column(
        children: [
          _EmptyRow(
            icon: Icons.timeline_outlined,
            title: 'No operational events yet',
            message: strings.get('noDataText'),
          ),
          const SizedBox(height: 10),
          const _EmptyRow(
            icon: Icons.notifications_none_rounded,
            title: 'No active alerts',
            message: 'Smart alerts will appear here when real farm data is available.',
          ),
        ],
      ),
    );

    final intelligence = _SectionCard(
      title: 'AI Farm Brain',
      subtitle: 'Insights, anomalies and recommendations from authorized farm data.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI features remain evidence-based. No medical or financial decisions are automated.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.45,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _MiniStat(label: 'Insights', value: '—'),
          const _MiniStat(label: 'Predictions', value: '—'),
          const _MiniStat(label: 'Recommendations', value: '—'),
        ],
      ),
    );

    if (compact) {
      return Column(
        children: [
          operational,
          const SizedBox(height: 14),
          intelligence,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: operational),
        const SizedBox(width: 14),
        Expanded(child: intelligence),
      ],
    );
  }
}

class _OperationalModules extends StatelessWidget {
  const _OperationalModules({required this.strings, required this.compact});

  final AppStrings strings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final modules = [
      _ModuleData(Icons.pets_outlined, strings.get('animals'), '/animals', 'Animal master, profile and timeline'),
      _ModuleData(Icons.water_drop_outlined, strings.get('milk'), '/milk', 'Collection, sessions and analytics'),
      _ModuleData(Icons.medical_services_outlined, strings.get('health'), '/health', 'Health events and treatments'),
      _ModuleData(Icons.favorite_outline, strings.get('pregnancy'), '/pregnancy', 'Pregnancy checks and calving'),
      _ModuleData(Icons.grass_outlined, strings.get('feed'), '/feed', 'Feed planning and consumption'),
      _ModuleData(Icons.account_balance_wallet_outlined, strings.get('finance'), '/finance', 'Income, expense and profitability'),
      _ModuleData(Icons.groups_outlined, strings.get('staff'), '/staff', 'People, attendance and tasks'),
      _ModuleData(Icons.bar_chart_rounded, strings.get('reports'), '/reports', 'Reports, exports and KPIs'),
    ];

    return _SectionCard(
      title: 'Operational modules',
      subtitle: 'One consistent navigation model across the ERP.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: modules.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: compact ? 1 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: compact ? 4.2 : 2.75,
        ),
        itemBuilder: (context, index) {
          final module = modules[index];
          return _ModuleTile(
            data: module,
            onTap: () => context.go(module.route),
          );
        },
      ),
    );
  }
}

class _ModuleData {
  const _ModuleData(this.icon, this.title, this.route, this.description);

  final IconData icon;
  final String title;
  final String route;
  final String description;
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.data, required this.onTap});

  final _ModuleData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(data.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
