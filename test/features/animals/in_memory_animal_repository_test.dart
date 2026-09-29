import 'package:flutter_test/flutter_test.dart';

import 'package:satva_dhara_erp/features/animals/application/animal_providers.dart';
import 'package:satva_dhara_erp/features/animals/data/repositories/in_memory_animal_repository.dart';
import 'package:satva_dhara_erp/features/animals/domain/enums/animal_enums.dart';

void main() {
  late InMemoryAnimalRepository repository;

  setUp(() => repository = InMemoryAnimalRepository());
  tearDown(() => repository.dispose());

  test('create and search are farm-scoped', () async {
    final animal = buildAnimal(
      farmId: 'farm-a',
      tagNumber: 'SD-001',
      species: AnimalSpecies.cow,
      sex: AnimalSex.female,
      dateOfBirth: DateTime(2024, 1, 1),
      source: AnimalSource.birth,
    );

    await repository.create(animal);

    final farmA = await repository.search(farmId: 'farm-a');
    final farmB = await repository.search(farmId: 'farm-b');

    expect(farmA.map((item) => item.tagNumber), contains('SD-001'));
    expect(farmB, isEmpty);
  });

  test('soft delete keeps record out of active searches', () async {
    final animal = buildAnimal(
      farmId: 'farm-a',
      tagNumber: 'SD-002',
      species: AnimalSpecies.cow,
      sex: AnimalSex.female,
      dateOfBirth: DateTime(2024, 2, 1),
      source: AnimalSource.birth,
    );

    await repository.create(animal);
    await repository.softDelete(farmId: 'farm-a', animalId: animal.id);

    expect(await repository.search(farmId: 'farm-a'), isEmpty);
    expect(await repository.getById(farmId: 'farm-a', animalId: animal.id), isNull);
  });
}
