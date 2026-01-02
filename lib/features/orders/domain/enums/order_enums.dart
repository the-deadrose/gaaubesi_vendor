enum PackageAccess {
  canOpen('Can Open'),
  cantOpen('Can\'t Open');

  final String displayName;
  const PackageAccess(this.displayName);
}

enum PickupType {
  pickup('Pickup'),
  dropOff('Drop Off');

  final String displayName;
  const PickupType(this.displayName);
}

enum PackageType {
  documents('Documents'),
  electronics('Electronics'),
  clothing('Clothing'),
  food('Food'),
  fragile('Fragile'),
  liquid('Liquid'),
  other('Other');

  final String displayName;
  const PackageType(this.displayName);
}
