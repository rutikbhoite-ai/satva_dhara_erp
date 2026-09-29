import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/in_memory_animal_repository.dart';
import '../domain/entities/animal.dart';
import '../domain/enums/animal_enums.dart';
import '../domain/repositories/animal_repository.dart';

/// Current farm scope is a foundation placeholder until the Farm module is
/// implemented. It is an internal scope identifier, not sample farm data.
final currentFarmIdProvider = Provider<String>((ref) => 'local-farm-scope');

final animalRepositoryProvider = Provider<AnimalRepository>((ref) {
  final repository = InMemoryAnimalRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final animalsProvider = StreamProvider.family<List<Animal>, String>((ref, farmId) {
  final repository = ref.watch(animalRepositoryProvider);
  return repository.watchByFarm(farmId);
});

final activeAnimalCountProvider = Provider.family<int, String>((ref, farmId) {
  final animals = ref.watch(animalsProvider(farmId)).valueOrNull ?? const <Animal>[];
  return animals.where((animal) => animal.lifeStatus.isOperational).length;
});

String createAnimalId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  return 'animal_${timestamp}_${DateTime.now().millisecond}';
}

Animal buildAnimal({
  required String farmId,
  required String tagNumber,
  required AnimalSpecies species,
  required AnimalSex sex,
  required DateTime dateOfBirth,
  required AnimalSource source,
  String? rfid,
  String? qrCode,
  String? animalNumber,
  String? name,
  String? breedName,
  String? color,
  AnimalHornStatus hornStatus = AnimalHornStatus.unknown,
  double? weightKg,
  DateTime? purchaseDate,
  double? purchasePrice,
  String? shedId,
  String? penId,
  String? notes,
}) {
  final now = DateTime.now();
  final operationalStatus = switch (species) {
    AnimalSpecies.bull => AnimalOperationalStatus.bull,
    AnimalSpecies.calf => AnimalOperationalStatus.calf,
    _ => AnimalOperationalStatus.active,
  };

  return Animal(
    id: createAnimalId(),
    farmId: farmId,
    tagNumber: tagNumber.trim(),
    rfid: _normalize(rfid),
    qrCode: _normalize(qrCode),
    animalNumber: _normalize(animalNumber),
    name: _normalize(name),
    species: species,
    breedName: _normalize(breedName),
    sex: sex,
    color: _normalize(color),
    hornStatus: hornStatus,
    dateOfBirth: dateOfBirth,
    weightKg: weightKg,
    source: source,
    purchaseDate: purchaseDate,
    purchasePrice: purchasePrice,
    shedId: _normalize(shedId),
    penId: _normalize(penId),
    lifeStatus: AnimalLifeStatus.active,
    operationalStatus: operationalStatus,
    notes: _normalize(notes),
    createdAt: now,
    updatedAt: now,
    version: 1,
  );
}

String? _normalize(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
