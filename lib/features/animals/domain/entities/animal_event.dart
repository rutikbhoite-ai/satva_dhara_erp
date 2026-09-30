enum AnimalEventType {
  recordCreated('Record created'),
  birth('Birth'),
  purchase('Purchase'),
  transfer('Transfer'),
  moved('Location changed'),
  weight('Weight recorded'),
  profileUpdated('Profile updated'),
  sale('Sale'),
  death('Death');

  const AnimalEventType(this.label);
  final String label;
}

class AnimalEvent {
  const AnimalEvent({
    required this.id,
    required this.farmId,
    required this.animalId,
    required this.type,
    required this.title,
    required this.occurredAt,
    required this.createdAt,
    this.description,
    this.relatedRecordId,
    this.createdBy,
  });

  final String id;
  final String farmId;
  final String animalId;
  final AnimalEventType type;
  final String title;
  final DateTime occurredAt;
  final String? description;
  final String? relatedRecordId;
  final DateTime createdAt;
  final String? createdBy;
}

String createAnimalEventId() {
  final value = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  return 'animal_event_$value';
}

AnimalEvent buildInitialAnimalEvent({
  required String farmId,
  required String animalId,
  required AnimalEventType type,
  required DateTime occurredAt,
  required String title,
  String? description,
}) {
  return AnimalEvent(
    id: createAnimalEventId(),
    farmId: farmId,
    animalId: animalId,
    type: type,
    title: title,
    occurredAt: occurredAt,
    description: description,
    createdAt: DateTime.now(),
  );
}
