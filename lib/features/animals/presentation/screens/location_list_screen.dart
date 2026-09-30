import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/animal_master_providers.dart';
import '../../application/animal_providers.dart';
import '../../domain/entities/farm_location.dart';

class LocationListScreen extends ConsumerWidget {
  const LocationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmId = ref.watch(currentFarmIdProvider);
    final locationsAsync = ref.watch(locationsProvider(farmId));
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 820;

    return AppPage(
      title: 'Farm Locations',
      subtitle: 'Manage sheds and pens used as the operational location master.',
      child: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Unable to load locations: $error'),
        ),
        data: (locations) => ListView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${locations.length} location records',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddLocationDialog(
                    context,
                    ref,
                    farmId,
                    locations,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Location'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (locations.isEmpty)
              const _EmptyLocationState()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locations.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: compact ? 1 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: compact ? 4.2 : 3.0,
                ),
                itemBuilder: (context, index) {
                  final location = locations[index];
                  final parentName = location.parentId == null
                      ? null
                      : locations
                          .where((item) => item.id == location.parentId)
                          .map((item) => item.name)
                          .firstOrNull;

                  return _LocationCard(
                    location: location,
                    parentName: parentName,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddLocationDialog(
    BuildContext context,
    WidgetRef ref,
    String farmId,
    List<FarmLocation> locations,
  ) async {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    final notesController = TextEditingController();
    var type = FarmLocationType.shed;
    String? parentId;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final sheds = locations
                  .where((item) => item.type == FarmLocationType.shed)
                  .toList();

              return AlertDialog(
                title: const Text('Add Farm Location'),
                content: SizedBox(
                  width: 450,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Location name *',
                            hintText: 'e.g. Shed A / Pen 01',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<FarmLocationType>(
                          initialValue: type,
                          decoration: const InputDecoration(
                            labelText: 'Location type *',
                          ),
                          items: FarmLocationType.values
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              type = value;
                              if (type == FarmLocationType.shed) {
                                parentId = null;
                              }
                            });
                          },
                        ),
                        if (type == FarmLocationType.pen) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String?>(
                            initialValue: parentId,
                            decoration: const InputDecoration(
                              labelText: 'Parent shed *',
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Select shed'),
                              ),
                              ...sheds.map(
                                (shed) => DropdownMenuItem<String?>(
                                  value: shed.id,
                                  child: Text(shed.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() => parentId = value);
                            },
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Capacity',
                            hintText: 'Optional number of animals',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            hintText: 'Optional',
                          ),
                        ),
                      ],
                    ),
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
                            content: Text('Location name is required.'),
                          ),
                        );
                        return;
                      }

                      if (type == FarmLocationType.pen && parentId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Select the parent shed for a pen.'),
                          ),
                        );
                        return;
                      }

                      final capacityText = capacityController.text.trim();
                      final capacity = int.tryParse(capacityText);
                      if (capacityText.isNotEmpty &&
                          (capacity == null || capacity <= 0)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Capacity must be a positive number.'),
                          ),
                        );
                        return;
                      }

                      final duplicate = locations.any(
                        (item) =>
                            item.type == type &&
                            item.name.trim().toLowerCase() ==
                                name.toLowerCase(),
                      );
                      if (duplicate) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'This location name already exists for this type.',
                            ),
                          ),
                        );
                        return;
                      }

                      final repository =
                          ref.read(locationRepositoryProvider);
                      await repository.create(
                        buildFarmLocation(
                          farmId: farmId,
                          name: name,
                          type: type,
                          parentId: parentId,
                          capacity: capacity,
                          notes: notesController.text,
                        ),
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text('Save Location'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      capacityController.dispose();
      notesController.dispose();
    }
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.parentName,
  });

  final FarmLocation location;
  final String? parentName;

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
            child: Icon(
              location.type == FarmLocationType.shed
                  ? Icons.home_work_outlined
                  : Icons.grid_view_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  location.type.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (parentName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Parent: $parentName',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (location.capacity != null)
            Text(
              '${location.capacity}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
            ),
        ],
      ),
    );
  }
}

class _EmptyLocationState extends StatelessWidget {
  const _EmptyLocationState();

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
            Icons.home_work_outlined,
            size: 46,
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          Text(
            'No farm locations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'Create sheds first, then create pens under the correct shed.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
