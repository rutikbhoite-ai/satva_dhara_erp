import '../domain/entities/animal.dart';
import '../domain/entities/animal_event.dart';
import '../domain/entities/farm_location.dart';
import '../domain/repositories/animal_event_repository.dart';
import '../domain/repositories/animal_repository.dart';
import '../domain/repositories/breed_repository.dart';
import '../domain/repositories/farm_location_repository.dart';

class AnimalBusinessException implements Exception {
  AnimalBusinessException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AnimalCoreService {
  const AnimalCoreService({
    required this.animalRepository,
    required this.eventRepository,
    required this.breedRepository,
    required this.locationRepository,
  });

  final AnimalRepository animalRepository;
  final AnimalEventRepository eventRepository;
  final BreedRepository breedRepository;
  final FarmLocationRepository locationRepository;

  Future<Animal> createAnimal(Animal animal) async {
    final farmId = animal.farmId.trim();
    final tag = animal.tagNumber.trim().toLowerCase();

    if (farmId.isEmpty) {
      throw AnimalBusinessException('Farm scope is required.');
    }
    if (tag.isEmpty) {
      throw AnimalBusinessException('Animal tag number is required.');
    }
    if (animal.dateOfBirth.isAfter(DateTime.now())) {
      throw AnimalBusinessException('Date of birth cannot be in the future.');
    }
    if (animal.weightKg != null && animal.weightKg! <= 0) {
      throw AnimalBusinessException('Weight must be greater than zero.');
    }
    if (animal.purchasePrice != null && animal.purchasePrice! < 0) {
      throw AnimalBusinessException('Purchase price cannot be negative.');
    }
    if (animal.source.name == 'purchase' && animal.purchaseDate == null) {
      throw AnimalBusinessException(
        'Purchase date is required for purchased animals.',
      );
    }

    if (animal.purchaseDate != null &&
        animal.purchaseDate!.isAfter(DateTime.now())) {
      throw AnimalBusinessException(
        'Purchase date cannot be in the future.',
      );
    }

    final matches = await animalRepository.search(
      farmId: farmId,
      query: animal.tagNumber,
      activeOnly: false,
    );
    final duplicateTag = matches.any(
      (item) =>
          item.tagNumber.trim().toLowerCase() == tag &&
      item.id != animal.id,
    );
    if (duplicateTag) {
      throw AnimalBusinessException(
        'This tag number already exists in this farm.',
      );
    }

    if (animal.rfid != null && animal.rfid!.trim().isNotEmpty) {
      final rfid = animal.rfid!.trim().toLowerCase();
      final all = await animalRepository.search(
        farmId: farmId,
        activeOnly: false,
      );
      if (all.any(
        (item) =>
            item.id != animal.id &&
            (item.rfid ?? '').trim().toLowerCase() == rfid,
      )) {
        throw AnimalBusinessException(
          'This RFID tag already exists in this farm.',
        );
      }
    }

    if (animal.breedId != null) {
      final breed = await breedRepository.getById(
        farmId: farmId,
        breedId: animal.breedId!,
      );
      if (breed == null) {
        throw AnimalBusinessException('Selected breed does not exist.');
      }
      if (breed.species != animal.species) {
        throw AnimalBusinessException(
          'Selected breed does not match the animal species.',
        );
      }
    }

    if (animal.penId != null) {
      final pen = await locationRepository.getById(
        farmId: farmId,
        locationId: animal.penId!,
      );
      if (pen == null || pen.type != FarmLocationType.pen) {
        throw AnimalBusinessException('Selected pen is not valid.');
      }
      if (animal.shedId == null ||
          (pen.parentId != null && pen.parentId != animal.shedId)) {
        throw AnimalBusinessException(
          'Selected pen must belong to the selected shed.',
        );
      }
    }

    final created = await animalRepository.create(animal);

    final eventType = switch (created.source.name) {
      'birth' => AnimalEventType.birth,
      'purchase' => AnimalEventType.purchase,
      'transfer' => AnimalEventType.transfer,
      _ => AnimalEventType.recordCreated,
    };

    await eventRepository.create(
      buildInitialAnimalEvent(
        farmId: created.farmId,
        animalId: created.id,
        type: eventType,
        occurredAt: switch (eventType) {
          AnimalEventType.birth => created.dateOfBirth,
          AnimalEventType.purchase => created.purchaseDate ?? created.createdAt,
          _ => created.createdAt,
        },
        title: eventType.label,
        description: _eventDescription(created, eventType),
      ),
    );

    return created;
  }

  String _eventDescription(Animal animal, AnimalEventType type) {
    return switch (type) {
      AnimalEventType.purchase =>
        'Animal master created from purchase source.',
      AnimalEventType.birth => 'Animal master created from birth source.',
      AnimalEventType.transfer =>
        'Animal master created from transfer source.',
      _ => 'Animal master record created.',
    };
  }

  Future<List<AnimalEvent>> timelineFor({
    required String farmId,
    required String animalId,
  }) {
    return eventRepository.getByAnimal(
      farmId: farmId,
      animalId: animalId,
    );
  }
}
