import '../enums/animal_enums.dart';

class Breed {
  const Breed({
    required this.id,
    required this.farmId,
    required this.name,
    required this.species,
    this.breedType,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isDeleted = false,
    this.version = 1,
  });

  final String id;
  final String farmId;
  final String name;
  final AnimalSpecies species;
  final String? breedType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final bool isDeleted;
  final int version;

  Breed copyWith({
    String? id,
    String? farmId,
    String? name,
    AnimalSpecies? species,
    String? breedType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    int? version,
  }) {
    return Breed(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      species: species ?? this.species,
      breedType: breedType ?? this.breedType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }
}

String createBreedId() {
  final value = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  return 'breed_$value';
}

Breed buildBreed({
  required String farmId,
  required String name,
  required AnimalSpecies species,
  String? breedType,
}) {
  final now = DateTime.now();
  final normalizedName = name.trim();
  return Breed(
    id: createBreedId(),
    farmId: farmId.trim(),
    name: normalizedName,
    species: species,
    breedType: _normalize(breedType),
    createdAt: now,
    updatedAt: now,
  );
}

String? _normalize(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
