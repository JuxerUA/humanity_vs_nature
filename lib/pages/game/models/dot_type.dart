enum DotType {
  none,
  tree,
  fieldPartial,
  fieldFull,
  farm,
  city;

  bool get isGoodDotForField => this == DotType.none || this == DotType.fieldPartial;
}
