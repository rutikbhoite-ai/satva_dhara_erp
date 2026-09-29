import 'dart:async';

import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';

/// Temporary phase-2 application repository.
///
/// It keeps the UI and business layer independent from persistence while the
/// Farm scope + Isar collection registration is completed. No sample animals
/// are inserted automatically.
class InMemoryAnimalRepository implements AnimalRepository {
  final Map<String, Map<String, Animal>> _byFarm = {};
  final Map<String, StreamController<List<Animal>>> _controllers = {};

  StreamController<List<Animal>> _controllerFor(String farmId) {
    return _controllers.putIfAbsent(
      farmId,
      () => StreamController<List<Animal>>.broadcast(),
    );
  }

  List<Animal> _visible(String farmId) {
    final values = _byFarm[farmId]?.values ?? const <Animal>[];
    final animals = values.where((animal) => !animal.isDeleted).toList();
    animals.sort((a, b) => a.tagNumber.toLowerCase().compareTo(b.tagNumber.toLowerCase()));
    return animals;
  }

  void _emit(String farmId) {
    _controllerFor(farmId).add(List.unmodifiable(_visible(farmId)));
  }

  @override
  Stream<List<Animal>> watchByFarm(String farmId) async* {
    yield _visible(farmId);
    yield* _controllerFor(farmId).stream;
  }

  @override
  Future<List<Animal>> search({
    required String farmId,
    String query = '',
    bool activeOnly = true,
  }) async {
    final normalized = query.trim().toLowerCase();
    final source = _visible(farmId).where((animal) {
      if (activeOnly && !animal.lifeStatus.isOperational) return false;
      if (normalized.isEmpty) return true;
      return [
        animal.tagNumber,
        animal.rfid ?? '',
        animal.qrCode ?? '',
        animal.animalNumber ?? '',
        animal.name ?? '',
        animal.breedName ?? '',
        animal.species.label,
        animal.operationalStatus.label,
      ].any((value) => value.toLowerCase().contains(normalized));
    }).toList();
    return source;
  }

  @override
  Future<Animal?> getById({
    required String farmId,
    required String animalId,
  }) async {
    final animal = _byFarm[farmId]?[animalId];
    if (animal == null || animal.isDeleted) return null;
    return animal;
  }

  @override
  Future<Animal> create(Animal animal) async {
    final farmAnimals = _byFarm.putIfAbsent(animal.farmId, () => {});
    farmAnimals[animal.id] = animal;
    _emit(animal.farmId);
    return animal;
  }

  @override
  Future<Animal> update(Animal animal) async {
    final farmAnimals = _byFarm.putIfAbsent(animal.farmId, () => {});
    farmAnimals[animal.id] = animal;
    _emit(animal.farmId);
    return animal;
  }

  @override
  Future<void> softDelete({
    required String farmId,
    required String animalId,
  }) async {
    final animal = _byFarm[farmId]?[animalId];
    if (animal == null) return;
    _byFarm[farmId]![animalId] = animal.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
      version: animal.version + 1,
    );
    _emit(farmId);
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
  }
}
