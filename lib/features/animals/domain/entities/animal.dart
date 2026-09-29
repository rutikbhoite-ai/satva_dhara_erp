import '../enums/animal_enums.dart';

class Animal {
  const Animal({
    required this.id,
    required this.farmId,
    required this.tagNumber,
    required this.species,
    required this.sex,
    required this.dateOfBirth,
    required this.source,
    required this.lifeStatus,
    required this.operationalStatus,
    required this.createdAt,
    required this.updatedAt,
    this.rfid,
    this.qrCode,
    this.animalNumber,
    this.name,
    this.breedId,
    this.breedName,
    this.color,
    this.hornStatus = AnimalHornStatus.unknown,
    this.weightKg,
    this.photoPath,
    this.purchaseDate,
    this.purchasePrice,
    this.shedId,
    this.penId,
    this.motherId,
    this.fatherId,
    this.notes,
    this.createdBy,
    this.updatedBy,
    this.isDeleted = false,
    this.version = 1,
  });

  final String id;
  final String farmId;
  final String tagNumber;
  final String? rfid;
  final String? qrCode;
  final String? animalNumber;
  final String? name;
  final AnimalSpecies species;
  final String? breedId;
  final String? breedName;
  final AnimalSex sex;
  final String? color;
  final AnimalHornStatus hornStatus;
  final DateTime dateOfBirth;
  final double? weightKg;
  final String? photoPath;
  final AnimalSource source;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? shedId;
  final String? penId;
  final String? motherId;
  final String? fatherId;
  final AnimalLifeStatus lifeStatus;
  final AnimalOperationalStatus operationalStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final bool isDeleted;
  final int version;

  Animal copyWith({
    String? id,
    String? farmId,
    String? tagNumber,
    String? rfid,
    String? qrCode,
    String? animalNumber,
    String? name,
    AnimalSpecies? species,
    String? breedId,
    String? breedName,
    AnimalSex? sex,
    String? color,
    AnimalHornStatus? hornStatus,
    DateTime? dateOfBirth,
    double? weightKg,
    String? photoPath,
    AnimalSource? source,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? shedId,
    String? penId,
    String? motherId,
    String? fatherId,
    AnimalLifeStatus? lifeStatus,
    AnimalOperationalStatus? operationalStatus,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    int? version,
  }) {
    return Animal(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      tagNumber: tagNumber ?? this.tagNumber,
      rfid: rfid ?? this.rfid,
      qrCode: qrCode ?? this.qrCode,
      animalNumber: animalNumber ?? this.animalNumber,
      name: name ?? this.name,
      species: species ?? this.species,
      breedId: breedId ?? this.breedId,
      breedName: breedName ?? this.breedName,
      sex: sex ?? this.sex,
      color: color ?? this.color,
      hornStatus: hornStatus ?? this.hornStatus,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
      photoPath: photoPath ?? this.photoPath,
      source: source ?? this.source,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      shedId: shedId ?? this.shedId,
      penId: penId ?? this.penId,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
      lifeStatus: lifeStatus ?? this.lifeStatus,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }
}
