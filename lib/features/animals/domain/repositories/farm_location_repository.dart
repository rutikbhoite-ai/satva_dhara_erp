import '../entities/farm_location.dart';

abstract interface class FarmLocationRepository {
  Stream<List<FarmLocation>> watchByFarm(String farmId);

  Future<List<FarmLocation>> search({
    required String farmId,
    String query = '',
    FarmLocationType? type,
    bool activeOnly = true,
  });

  Future<FarmLocation?> getById({
    required String farmId,
    required String locationId,
  });

  Future<FarmLocation> create(FarmLocation location);
  Future<FarmLocation> update(FarmLocation location);

  Future<void> softDelete({
    required String farmId,
    required String locationId,
  });
}
