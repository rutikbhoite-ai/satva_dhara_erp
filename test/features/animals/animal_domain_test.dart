import 'package:flutter_test/flutter_test.dart';

import 'package:satva_dhara_erp/features/animals/application/animal_providers.dart';
import 'package:satva_dhara_erp/features/animals/domain/enums/animal_enums.dart';

void main() {
  group('Animal domain', () {
    test('buildAnimal preserves farm scope and required identity', () {
      final animal = buildAnimal(
        farmId: 'farm-1',
        tagNumber: ' SD-001 ',
        species: AnimalSpecies.cow,
        sex: AnimalSex.female,
        dateOfBirth: DateTime(2024, 1, 15),
        source: AnimalSource.birth,
      );

      expect(animal.farmId, 'farm-1');
      expect(animal.tagNumber, 'SD-001');
      expect(animal.species, AnimalSpecies.cow);
      expect(animal.sex, AnimalSex.female);
      expect(animal.lifeStatus, AnimalLifeStatus.active);
      expect(animal.isDeleted, isFalse);
      expect(animal.version, 1);
    });

    test('buildAnimal assigns calf and bull operational defaults', () {
      final calf = buildAnimal(
        farmId: 'farm-1',
        tagNumber: 'CALF-1',
        species: AnimalSpecies.calf,
        sex: AnimalSex.female,
        dateOfBirth: DateTime(2026, 1, 1),
        source: AnimalSource.birth,
      );
      final bull = buildAnimal(
        farmId: 'farm-1',
        tagNumber: 'BULL-1',
        species: AnimalSpecies.bull,
        sex: AnimalSex.male,
        dateOfBirth: DateTime(2023, 1, 1),
        source: AnimalSource.purchase,
      );

      expect(calf.operationalStatus, AnimalOperationalStatus.calf);
      expect(bull.operationalStatus, AnimalOperationalStatus.bull);
    });
  });
}
