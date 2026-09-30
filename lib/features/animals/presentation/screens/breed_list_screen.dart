import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/animal_master_providers.dart';
import '../../application/animal_providers.dart';
import '../../domain/entities/breed.dart';
import '../../domain/enums/animal_enums.dart';

class BreedListScreen extends ConsumerWidget {
  const BreedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmId = ref.watch(currentFarmIdProvider);
    final breedsAsync = ref.watch(breedsProvider(farmId));
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 820;

    return AppPage(
      title: 'Breed Master',
      subtitle: 'Manage the controlled breed vocabulary used by animal records.',
      child: breedsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Unable to load breeds: $error'),
        ),
        data: (breeds) => ListView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${breeds.length} breed records',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddBreedDialog(context, ref, farmId),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Breed'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (breeds.isEmpty)
              const _EmptyBreedState()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: breeds.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: compact ? 1 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: compact ? 4.0 : 3.1,
                ),
                itemBuilder: (context, index) {
                  final breed = breeds[index];
                  return _BreedCard(breed: breed);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBreedDialog(
    BuildContext context,
    WidgetRef ref,
    String farmId,
  ) async {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    var species = AnimalSpecies.cow;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: const Text('Add Breed'),
                content: SizedBox(
                  width: 430,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Breed name *',
                          hintText: 'e.g. Holstein Friesian',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<AnimalSpecies>(
                        initialValue: species,
                        decoration: const InputDecoration(
                          labelText: 'Species *',
                        ),
                        items: AnimalSpecies.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => species = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: typeController,
                        decoration: const InputDecoration(
                          labelText: 'Breed type',
                          hintText: 'Optional, e.g. Crossbred',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Breed name is required.'),
                          ),
                        );
                        return;
                      }

                      final repository = ref.read(breedRepositoryProvider);
                      final existing = await repository.search(
                        farmId: farmId,
                        activeOnly: false,
                      );
                      final duplicate = existing.any(
                        (item) =>
                            item.species == species &&
                            item.name.trim().toLowerCase() ==
                                name.toLowerCase(),
                      );

                      if (duplicate) {
                        if (!dialogContext.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'This breed already exists for the selected species.',
                            ),
                          ),
                        );
                        return;
                      }

                      await repository.create(
                        buildBreed(
                          farmId: farmId,
                          name: name,
                          species: species,
                          breedType: typeController.text,
                        ),
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text('Save Breed'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      typeController.dispose();
    }
  }
}

class _BreedCard extends StatelessWidget {
  const _BreedCard({required this.breed});

  final Breed breed;

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.biotech_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breed.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  breed.species.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (breed.breedType?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    breed.breedType!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            breed.isActive
                ? Icons.check_circle_outline_rounded
                : Icons.pause_circle_outline_rounded,
            color:
                breed.isActive ? AppColors.success : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _EmptyBreedState extends StatelessWidget {
  const _EmptyBreedState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.biotech_outlined,
            size: 46,
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          Text(
            'No breeds created yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'Create your farm breed master before linking detailed animal records.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
