import '../entities/breed.dart';

abstract interface class BreedRepository {
  Stream<List<Breed>> watchByFarm(String farmId);

  Future<List<Breed>> search({
    required String farmId,
    String query = '',
    bool activeOnly = true,
  });

  Future<Breed?> getById({
    required String farmId,
    required String breedId,
  });

  Future<Breed> create(Breed breed);
  Future<Breed> update(Breed breed);

  Future<void> softDelete({
    required String farmId,
    required String breedId,
  });
}
