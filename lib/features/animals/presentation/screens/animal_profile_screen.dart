import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../application/animal_master_providers.dart';
import '../../application/animal_providers.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_event.dart';
import '../../domain/entities/farm_location.dart';

class AnimalProfileScreen extends ConsumerWidget {
  const AnimalProfileScreen({
    super.key,
    required this.animalId,
  });

  final String animalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmId = ref.watch(currentFarmIdProvider);
    final animalAsync = ref.watch(
      animalByIdProvider(
        AnimalScope(farmId: farmId, animalId: animalId),
      ),
    );

    return animalAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Unable to load animal: $error')),
      ),
      data: (animal) {
        if (animal == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            body: const Center(
              child: Text('Animal record not found.'),
            ),
          );
        }

        final locations = ref.watch(locationsProvider(farmId)).valueOrNull ?? [];
        final events = ref.watch(
          animalEventsProvider(
            AnimalEventScope(farmId: farmId, animalId: animal.id),
          ),
        );

        return AppPage(
          title: animal.name?.isNotEmpty == true
              ? animal.name!
              : animal.tagNumber,
          subtitle:
              '${animal.species.label} • ${animal.tagNumber} • ${animal.lifeStatus.label}',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back'),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/animals'),
                    icon: const Icon(Icons.pets_outlined),
                    label: const Text('Animal Master'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileHero(animal: animal),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 980) {
                    return Column(
                      children: [
                        _IdentityCard(animal: animal),
                        const SizedBox(height: 12),
                        _OperationalCard(
                          animal: animal,
                          locations: locations,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _IdentityCard(animal: animal)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OperationalCard(
                          animal: animal,
                          locations: locations,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _PedigreeCard(animal: animal),
              const SizedBox(height: 16),
              _TimelineCard(
                events: events.valueOrNull ?? const [],
                loading: events.isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}

final animalByIdProvider =
    FutureProvider.family<Animal?, AnimalScope>((ref, scope) {
  final repository = ref.watch(animalRepositoryProvider);
  return repository.getById(
    farmId: scope.farmId,
    animalId: scope.animalId,
  );
});

class AnimalScope {
  const AnimalScope({
    required this.farmId,
    required this.animalId,
  });

  final String farmId;
  final String animalId;

  @override
  bool operator ==(Object other) {
    return other is AnimalScope &&
        other.farmId == farmId &&
        other.animalId == animalId;
  }

  @override
  int get hashCode => Object.hash(farmId, animalId);
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.accentSoft,
            child: Icon(
              Icons.pets_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name?.isNotEmpty == true
                      ? animal.name!
                      : animal.tagNumber,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tag ${animal.tagNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          _HeroStatus(label: animal.lifeStatus.label),
          const SizedBox(width: 8),
          _HeroStatus(label: animal.operationalStatus.label),
        ],
      ),
    );
  }
}

class _HeroStatus extends StatelessWidget {
  const _HeroStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Identity',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          _InfoRow('Internal ID', animal.id),
          _InfoRow('Official Ear Tag', animal.tagNumber),
          _InfoRow('RFID', animal.rfid ?? 'Not assigned'),
          _InfoRow('QR Code', animal.qrCode ?? 'Not assigned'),
          _InfoRow('Animal Number', animal.animalNumber ?? 'Not assigned'),
          _InfoRow('Name', animal.name ?? 'Not assigned'),
        ],
      ),
    );
  }
}

class _OperationalCard extends StatelessWidget {
  const _OperationalCard({
    required this.animal,
    required this.locations,
  });

  final Animal animal;
  final List<FarmLocation> locations;

  @override
  Widget build(BuildContext context) {
    final shed = locations
        .where((item) => item.id == animal.shedId)
        .map((item) => item.name)
        .firstOrNull;
    final pen = locations
        .where((item) => item.id == animal.penId)
        .map((item) => item.name)
        .firstOrNull;

    return _SectionCard(
      title: 'Classification & location',
      icon: Icons.tune_rounded,
      child: Column(
        children: [
          _InfoRow('Species', animal.species.label),
          _InfoRow('Sex', animal.sex.label),
          _InfoRow('Breed', animal.breedName ?? 'Not assigned'),
          _InfoRow('Color', animal.color ?? 'Not assigned'),
          _InfoRow('Horn status', animal.hornStatus.label),
          _InfoRow('Weight', animal.weightKg == null
              ? 'Not recorded'
              : '${animal.weightKg!.toStringAsFixed(1)} kg'),
          _InfoRow('Shed', shed ?? 'Not assigned'),
          _InfoRow('Pen', pen ?? 'Not assigned'),
          _InfoRow('Source', animal.source.label),
        ],
      ),
    );
  }
}

class _PedigreeCard extends StatelessWidget {
  const _PedigreeCard({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Pedigree',
      icon: Icons.account_tree_outlined,
      child: Row(
        children: [
          Expanded(
            child: _PedigreeNode(
              label: 'Mother',
              value: animal.motherId ?? 'Not linked',
              icon: Icons.female_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PedigreeNode(
              label: 'Father',
              value: animal.fatherId ?? 'Not linked',
              icon: Icons.male_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _PedigreeNode extends StatelessWidget {
  const _PedigreeNode({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
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

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.events,
    required this.loading,
  });

  final List<AnimalEvent> events;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Animal Timeline',
      icon: Icons.timeline_rounded,
      child: loading && events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? const Text(
                  'No lifecycle events are recorded yet. New business events will appear here.',
                )
              : Column(
                  children: [
                    for (var index = 0; index < events.length; index++)
                      _TimelineItem(
                        event: events[index],
                        last: index == events.length - 1,
                      ),
                  ],
                ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.event,
    required this.last,
  });

  final AnimalEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 7,
                backgroundColor: AppColors.primary,
              ),
              if (!last)
                Container(
                  width: 2,
                  height: 54,
                  color: AppColors.divider,
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDateTime(event.occurredAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (event.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$d/$m/${date.year}  $hh:$mm';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 9),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
