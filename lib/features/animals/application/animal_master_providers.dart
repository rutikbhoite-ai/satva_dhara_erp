import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/in_memory_animal_event_repository.dart';
import '../data/repositories/in_memory_breed_repository.dart';
import '../data/repositories/in_memory_farm_location_repository.dart';
import '../domain/entities/animal_event.dart';
import '../domain/entities/breed.dart';
import '../domain/entities/farm_location.dart';
import '../domain/repositories/animal_event_repository.dart';
import '../domain/repositories/breed_repository.dart';
import '../domain/repositories/farm_location_repository.dart';
import 'animal_core_service.dart';
import 'animal_providers.dart';

final breedRepositoryProvider = Provider<BreedRepository>((ref) {
  final repository = InMemoryBreedRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final breedsProvider =
    StreamProvider.family<List<Breed>, String>((ref, farmId) {
  final repository = ref.watch(breedRepositoryProvider);
  return repository.watchByFarm(farmId);
});

final locationRepositoryProvider =
    Provider<FarmLocationRepository>((ref) {
  final repository = InMemoryFarmLocationRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final locationsProvider =
    StreamProvider.family<List<FarmLocation>, String>((ref, farmId) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.watchByFarm(farmId);
});

final animalEventRepositoryProvider =
    Provider<AnimalEventRepository>((ref) {
  final repository = InMemoryAnimalEventRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final animalEventsProvider =
    StreamProvider.family<List<AnimalEvent>, AnimalEventScope>((ref, scope) {
  final repository = ref.watch(animalEventRepositoryProvider);
  return repository.watchByAnimal(
    farmId: scope.farmId,
    animalId: scope.animalId,
  );
});

final animalCoreServiceProvider = Provider<AnimalCoreService>((ref) {
  return AnimalCoreService(
    animalRepository: ref.watch(animalRepositoryProvider),
    eventRepository: ref.watch(animalEventRepositoryProvider),
    breedRepository: ref.watch(breedRepositoryProvider),
    locationRepository: ref.watch(locationRepositoryProvider),
  );
});

class AnimalEventScope {
  const AnimalEventScope({
    required this.farmId,
    required this.animalId,
  });

  final String farmId;
  final String animalId;

  @override
  bool operator ==(Object other) {
    return other is AnimalEventScope &&
        other.farmId == farmId &&
        other.animalId == animalId;
  }

  @override
  int get hashCode => Object.hash(farmId, animalId);
}
