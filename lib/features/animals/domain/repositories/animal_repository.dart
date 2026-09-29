import '../entities/animal.dart';

abstract interface class AnimalRepository {
  Stream<List<Animal>> watchByFarm(String farmId);

  Future<List<Animal>> search({
    required String farmId,
    String query = '',
    bool activeOnly = true,
  });

  Future<Animal?> getById({
    required String farmId,
    required String animalId,
  });

  Future<Animal> create(Animal animal);

  Future<Animal> update(Animal animal);

  Future<void> softDelete({
    required String farmId,
    required String animalId,
  });
}
