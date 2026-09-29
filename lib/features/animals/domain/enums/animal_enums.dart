enum AnimalSpecies {
  cow('Cow'),
  buffalo('Buffalo'),
  bull('Bull'),
  calf('Calf');

  const AnimalSpecies(this.label);
  final String label;
}

enum AnimalSex {
  female('Female'),
  male('Male');

  const AnimalSex(this.label);
  final String label;
}

enum AnimalHornStatus {
  horned('Horned'),
  dehorned('Dehorned'),
  polled('Polled'),
  unknown('Unknown');

  const AnimalHornStatus(this.label);
  final String label;
}

enum AnimalSource {
  birth('Birth'),
  purchase('Purchase'),
  transfer('Transfer'),
  other('Other');

  const AnimalSource(this.label);
  final String label;
}

/// Life-cycle status determines whether an animal remains in active
/// operational lists. Operational status is intentionally separate so
/// "Pregnant", "Sick" and "Milking" do not destroy the animal's life history.
enum AnimalLifeStatus {
  active('Active'),
  sold('Sold'),
  dead('Dead'),
  transferred('Transferred'),
  missing('Missing'),
  quarantine('Quarantine');

  const AnimalLifeStatus(this.label);
  final String label;

  bool get isOperational => this == AnimalLifeStatus.active || this == AnimalLifeStatus.quarantine;
}

enum AnimalOperationalStatus {
  active('Active'),
  milking('Milking'),
  dry('Dry'),
  pregnant('Pregnant'),
  heifer('Heifer'),
  calf('Calf'),
  bull('Bull'),
  sick('Sick'),
  quarantine('Quarantine'),
  retired('Retired');

  const AnimalOperationalStatus(this.label);
  final String label;
}
