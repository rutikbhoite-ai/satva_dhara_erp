import '../entities/animal_event.dart';

abstract interface class AnimalEventRepository {
  Stream<List<AnimalEvent>> watchByAnimal({
    required String farmId,
    required String animalId,
  });

  Future<List<AnimalEvent>> getByAnimal({
    required String farmId,
    required String animalId,
  });

  Future<AnimalEvent> create(AnimalEvent event);
}
