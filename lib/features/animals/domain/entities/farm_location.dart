enum FarmLocationType {
  shed('Shed'),
  pen('Pen');

  const FarmLocationType(this.label);
  final String label;
}

class FarmLocation {
  const FarmLocation({
    required this.id,
    required this.farmId,
    required this.name,
    required this.type,
    this.parentId,
    this.capacity,
    this.notes,
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
  final FarmLocationType type;
  final String? parentId;
  final int? capacity;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final bool isDeleted;
  final int version;

  FarmLocation copyWith({
    String? id,
    String? farmId,
    String? name,
    FarmLocationType? type,
    String? parentId,
    int? capacity,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    int? version,
  }) {
    return FarmLocation(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      capacity: capacity ?? this.capacity,
      notes: notes ?? this.notes,
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

String createFarmLocationId() {
  final value = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  return 'loc_$value';
}

FarmLocation buildFarmLocation({
  required String farmId,
  required String name,
  required FarmLocationType type,
  String? parentId,
  int? capacity,
  String? notes,
}) {
  final now = DateTime.now();
  return FarmLocation(
    id: createFarmLocationId(),
    farmId: farmId.trim(),
    name: name.trim(),
    type: type,
    parentId: _normalize(parentId),
    capacity: capacity,
    notes: _normalize(notes),
    createdAt: now,
    updatedAt: now,
  );
}

String? _normalize(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
