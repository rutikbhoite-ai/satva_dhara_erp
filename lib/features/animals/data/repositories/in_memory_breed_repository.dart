import 'dart:async';

import '../../domain/entities/breed.dart';
import '../../domain/repositories/breed_repository.dart';

class InMemoryBreedRepository implements BreedRepository {
  final Map<String, Map<String, Breed>> _byFarm = {};
  final Map<String, StreamController<List<Breed>>> _controllers = {};

  StreamController<List<Breed>> _controllerFor(String farmId) {
    return _controllers.putIfAbsent(
      farmId,
      () => StreamController<List<Breed>>.broadcast(),
    );
  }

  List<Breed> _visible(String farmId) {
    final values = _byFarm[farmId]?.values ?? const <Breed>[];
    final result = values.where((item) => !item.isDeleted).toList();
    result.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return result;
  }

  void _emit(String farmId) {
    _controllerFor(farmId).add(List.unmodifiable(_visible(farmId)));
  }

  @override
  Stream<List<Breed>> watchByFarm(String farmId) async* {
    yield _visible(farmId);
    yield* _controllerFor(farmId).stream;
  }

  @override
  Future<List<Breed>> search({
    required String farmId,
    String query = '',
    bool activeOnly = true,
  }) async {
    final normalized = query.trim().toLowerCase();
    return _visible(farmId).where((item) {
      if (activeOnly && !item.isActive) return false;
      return normalized.isEmpty ||
          item.name.toLowerCase().contains(normalized) ||
          (item.breedType ?? '').toLowerCase().contains(normalized) ||
          item.species.label.toLowerCase().contains(normalized);
    }).toList();
  }

  @override
  Future<Breed?> getById({
    required String farmId,
    required String breedId,
  }) async {
    final breed = _byFarm[farmId]?[breedId];
    if (breed == null || breed.isDeleted) return null;
    return breed;
  }

  @override
  Future<Breed> create(Breed breed) async {
    final farmBreeds = _byFarm.putIfAbsent(breed.farmId, () => {});
    farmBreeds[breed.id] = breed;
    _emit(breed.farmId);
    return breed;
  }

  @override
  Future<Breed> update(Breed breed) async {
    final farmBreeds = _byFarm.putIfAbsent(breed.farmId, () => {});
    farmBreeds[breed.id] = breed;
    _emit(breed.farmId);
    return breed;
  }

  @override
  Future<void> softDelete({
    required String farmId,
    required String breedId,
  }) async {
    final breed = _byFarm[farmId]?[breedId];
    if (breed == null) return;
    _byFarm[farmId]![breedId] = breed.copyWith(
      isDeleted: true,
      isActive: false,
      updatedAt: DateTime.now(),
      version: breed.version + 1,
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
