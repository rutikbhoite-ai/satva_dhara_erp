import 'dart:async';

import '../../domain/entities/animal_event.dart';
import '../../domain/repositories/animal_event_repository.dart';

class InMemoryAnimalEventRepository implements AnimalEventRepository {
  final Map<String, List<AnimalEvent>> _byAnimal = {};
  final Map<String, StreamController<List<AnimalEvent>>> _controllers = {};

  String _key(String farmId, String animalId) => '$farmId::$animalId';

  StreamController<List<AnimalEvent>> _controllerFor(
    String farmId,
    String animalId,
  ) {
    final key = _key(farmId, animalId);
    return _controllers.putIfAbsent(
      key,
      () => StreamController<List<AnimalEvent>>.broadcast(),
    );
  }

  List<AnimalEvent> _events(String farmId, String animalId) {
    final result = List<AnimalEvent>.from(_byAnimal[_key(farmId, animalId)] ?? const []);
    result.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return result;
  }

  @override
  Stream<List<AnimalEvent>> watchByAnimal({
    required String farmId,
    required String animalId,
  }) async* {
    yield _events(farmId, animalId);
    yield* _controllerFor(farmId, animalId).stream;
  }

  @override
  Future<List<AnimalEvent>> getByAnimal({
    required String farmId,
    required String animalId,
  }) async {
    return _events(farmId, animalId);
  }

  @override
  Future<AnimalEvent> create(AnimalEvent event) async {
    final key = _key(event.farmId, event.animalId);
    final events = _byAnimal.putIfAbsent(key, () => []);
    events.add(event);
    _controllerFor(event.farmId, event.animalId).add(
      List.unmodifiable(_events(event.farmId, event.animalId)),
    );
    return event;
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
  }
}
