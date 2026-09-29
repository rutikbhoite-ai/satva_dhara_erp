import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/animal_providers.dart';
import '../../domain/entities/animal.dart';
import '../../domain/enums/animal_enums.dart';

class AnimalListScreen extends ConsumerStatefulWidget {
  const AnimalListScreen({super.key});

  @override
  ConsumerState<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends ConsumerState<AnimalListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  AnimalLifeStatus? _lifeStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmId = ref.watch(currentFarmIdProvider);
    final animalsAsync = ref.watch(animalsProvider(farmId));
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 820;

    return AppPageLayout(
      title: 'Animal Master',
      subtitle: 'Central animal identity, status and operational records.',
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan QR'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => context.push('/animals/add'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Animal'),
        ),
      ],
      child: animalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorState(message: error.toString()),
        data: (animals) {
          final filtered = animals.where((animal) {
            final query = _query.trim().toLowerCase();
            final queryMatch = query.isEmpty || [
              animal.tagNumber,
              animal.rfid ?? '',
              animal.name ?? '',
              animal.animalNumber ?? '',
              animal.breedName ?? '',
              animal.species.label,
            ].any((value) => value.toLowerCase().contains(query));
            final statusMatch = _lifeStatus == null || animal.lifeStatus == _lifeStatus;
            return queryMatch && statusMatch;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            children: [
              _SummaryStrip(animals: animals, compact: compact),
              const SizedBox(height: 16),
              _FilterBar(
                controller: _searchController,
                query: _query,
                status: _lifeStatus,
                onSearch: (value) => setState(() => _query = value),
                onStatus: (value) => setState(() => _lifeStatus = value),
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                    _lifeStatus = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const _EmptyState()
              else
                _AnimalGrid(animals: filtered, compact: compact),
            ],
          );
        },
      ),
    );
  }
}

class AppPageLayout extends StatelessWidget {
  const AppPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.child,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.animals, required this.compact});

  final List<Animal> animals;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final active = animals.where((item) => item.lifeStatus.isOperational).length;
    final milking = animals.where((item) => item.operationalStatus == AnimalOperationalStatus.milking).length;
    final pregnant = animals.where((item) => item.operationalStatus == AnimalOperationalStatus.pregnant).length;
    final attention = animals.where((item) => {
      AnimalOperationalStatus.sick,
      AnimalOperationalStatus.quarantine,
    }.contains(item.operationalStatus)).length;

    final cards = [
      _StatCard(label: 'Total records', value: animals.length.toString(), icon: Icons.pets_rounded),
      _StatCard(label: 'Operational', value: active.toString(), icon: Icons.check_circle_outline_rounded),
      _StatCard(label: 'Milking', value: milking.toString(), icon: Icons.water_drop_outlined),
      _StatCard(label: 'Pregnant', value: pregnant.toString(), icon: Icons.favorite_outline_rounded),
      _StatCard(label: 'Attention', value: attention.toString(), icon: Icons.warning_amber_rounded),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final card in cards)
          SizedBox(width: compact ? 160 : 190, child: card),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.controller,
    required this.query,
    required this.status,
    required this.onSearch,
    required this.onStatus,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final AnimalLifeStatus? status;
  final ValueChanged<String> onSearch;
  final ValueChanged<AnimalLifeStatus?> onStatus;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 360,
            child: TextField(
              controller: controller,
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Search tag, RFID, name, breed...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<AnimalLifeStatus?>(
              value: status,
              hint: const Text('Life status'),
              items: [
                const DropdownMenuItem<AnimalLifeStatus?>(value: null, child: Text('All statuses')),
                ...AnimalLifeStatus.values.map(
                  (item) => DropdownMenuItem<AnimalLifeStatus?>(value: item, child: Text(item.label)),
                ),
              ],
              onChanged: onStatus,
            ),
          ),
          if (query.isNotEmpty || status != null)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Clear'),
            ),
        ],
      ),
    );
  }
}

class _AnimalGrid extends StatelessWidget {
  const _AnimalGrid({required this.animals, required this.compact});

  final List<Animal> animals;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: animals.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: compact ? 1 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: compact ? 3.25 : 2.55,
      ),
      itemBuilder: (context, index) => _AnimalCard(animal: animals[index]),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.divider),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 23,
                    backgroundColor: AppColors.accentSoft,
                    child: Icon(Icons.pets_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name?.isNotEmpty == true ? animal.name! : animal.tagNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          animal.tagNumber,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(label: animal.lifeStatus.label),
                ],
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MetaChip(icon: Icons.category_outlined, label: animal.species.label),
                  _MetaChip(icon: Icons.pets_outlined, label: animal.sex.label),
                  if (animal.breedName?.isNotEmpty == true)
                    _MetaChip(icon: Icons.biotech_outlined, label: animal.breedName!),
                  if (animal.weightKg != null)
                    _MetaChip(icon: Icons.monitor_weight_outlined, label: '${animal.weightKg!.toStringAsFixed(1)} kg'),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(Icons.timeline_rounded, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    animal.operationalStatus.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Icon(Icons.pets_outlined, size: 48, color: AppColors.primary),
          SizedBox(height: 12),
          Text('No animal records yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          SizedBox(height: 5),
          Text(
            'No sample animals are inserted. Add your first real animal to this farm scope.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text('Unable to load animals: $message'),
      ),
    );
  }
}
