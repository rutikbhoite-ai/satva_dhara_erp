import 'package:flutter_test/flutter_test.dart';

import 'package:satva_dhara_erp/features/animals/application/animal_core_service.dart';
import 'package:satva_dhara_erp/features/animals/application/animal_providers.dart';
import 'package:satva_dhara_erp/features/animals/data/repositories/in_memory_animal_event_repository.dart';
import 'package:satva_dhara_erp/features/animals/data/repositories/in_memory_animal_repository.dart';
import 'package:satva_dhara_erp/features/animals/data/repositories/in_memory_breed_repository.dart';
import 'package:satva_dhara_erp/features/animals/data/repositories/in_memory_farm_location_repository.dart';
import 'package:satva_dhara_erp/features/animals/domain/enums/animal_enums.dart';

void main() {
  late InMemoryAnimalRepository animalRepository;
  late InMemoryAnimalEventRepository eventRepository;
  late InMemoryBreedRepository breedRepository;
  late InMemoryFarmLocationRepository locationRepository;
  late AnimalCoreService service;

  setUp(() {
    animalRepository = InMemoryAnimalRepository();
    eventRepository = InMemoryAnimalEventRepository();
    breedRepository = InMemoryBreedRepository();
    locationRepository = InMemoryFarmLocationRepository();

    service = AnimalCoreService(
      animalRepository: animalRepository,
      eventRepository: eventRepository,
      breedRepository: breedRepository,
      locationRepository: locationRepository,
    );
  });

  tearDown(() async {
    await animalRepository.dispose();
    await eventRepository.dispose();
    await breedRepository.dispose();
    await locationRepository.dispose();
  });

  test('createAnimal creates a farm-scoped animal and initial timeline event', () async {
    final animal = buildAnimal(
      farmId: 'farm-1',
      tagNumber: 'SD-101',
      species: AnimalSpecies.cow,
      sex: AnimalSex.female,
      dateOfBirth: DateTime(2024, 1, 1),
      source: AnimalSource.birth,
    );

    final created = await service.createAnimal(animal);
    final events = await service.timelineFor(
      farmId: 'farm-1',
      animalId: created.id,
    );

    expect(created.tagNumber, 'SD-101');
    expect(events, hasLength(1));
    expect(events.single.type.name, 'birth');
    expect(events.single.animalId, created.id);
  });

  test('createAnimal rejects duplicate tags inside the same farm', () async {
    final first = buildAnimal(
      farmId: 'farm-1',
      tagNumber: 'SD-101',
      species: AnimalSpecies.cow,
      sex: AnimalSex.female,
      dateOfBirth: DateTime(2024, 1, 1),
      source: AnimalSource.birth,
    );
    final second = buildAnimal(
      farmId: 'farm-1',
      tagNumber: ' sd-101 ',
      species: AnimalSpecies.cow,
      sex: AnimalSex.female,
      dateOfBirth: DateTime(2024, 2, 1),
      source: AnimalSource.birth,
    );

    await service.createAnimal(first);

    expect(
      () => service.createAnimal(second),
      throwsA(isA<AnimalBusinessException>()),
    );
  });

  test('purchased animal requires a purchase date', () async {
    final animal = buildAnimal(
      farmId: 'farm-1',
      tagNumber: 'SD-201',
      species: AnimalSpecies.buffalo,
      sex: AnimalSex.female,
      dateOfBirth: DateTime(2023, 5, 1),
      source: AnimalSource.purchase,
    );

    expect(
      () => service.createAnimal(animal),
      throwsA(
        isA<AnimalBusinessException>().having(
          (error) => error.message,
          'message',
          contains('Purchase date'),
        ),
      ),
    );
  });
}
