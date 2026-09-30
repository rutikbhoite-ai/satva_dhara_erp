import 'dart:async';

import '../../domain/entities/farm_location.dart';
import '../../domain/repositories/farm_location_repository.dart';

class InMemoryFarmLocationRepository implements FarmLocationRepository {
  final Map<String, Map<String, FarmLocation>> _byFarm = {};
  final Map<String, StreamController<List<FarmLocation>>> _controllers = {};

  StreamController<List<FarmLocation>> _controllerFor(String farmId) {
    return _controllers.putIfAbsent(
      farmId,
      () => StreamController<List<FarmLocation>>.broadcast(),
    );
  }

  List<FarmLocation> _visible(String farmId) {
    final values = _byFarm[farmId]?.values ?? const <FarmLocation>[];
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
  Stream<List<FarmLocation>> watchByFarm(String farmId) async* {
    yield _visible(farmId);
    yield* _controllerFor(farmId).stream;
  }

  @override
  Future<List<FarmLocation>> search({
    required String farmId,
    String query = '',
    FarmLocationType? type,
    bool activeOnly = true,
  }) async {
    final normalized = query.trim().toLowerCase();
    return _visible(farmId).where((item) {
      if (activeOnly && !item.isActive) return false;
      if (type != null && item.type != type) return false;
      return normalized.isEmpty ||
          item.name.toLowerCase().contains(normalized);
    }).toList();
  }

  @override
  Future<FarmLocation?> getById({
    required String farmId,
    required String locationId,
  }) async {
    final location = _byFarm[farmId]?[locationId];
    if (location == null || location.isDeleted) return null;
    return location;
  }

  @override
  Future<FarmLocation> create(FarmLocation location) async {
    final farmLocations = _byFarm.putIfAbsent(location.farmId, () => {});
    farmLocations[location.id] = location;
    _emit(location.farmId);
    return location;
  }

  @override
  Future<FarmLocation> update(FarmLocation location) async {
    final farmLocations = _byFarm.putIfAbsent(location.farmId, () => {});
    farmLocations[location.id] = location;
    _emit(location.farmId);
    return location;
  }

  @override
  Future<void> softDelete({
    required String farmId,
    required String locationId,
  }) async {
    final location = _byFarm[farmId]?[locationId];
    if (location == null) return;
    _byFarm[farmId]![locationId] = location.copyWith(
      isDeleted: true,
      isActive: false,
      updatedAt: DateTime.now(),
      version: location.version + 1,
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
