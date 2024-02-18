enum DotType {
  none,
  tree,
  fieldPartial,
  fieldFull,
  farm,
  city;

  bool get isGoodDotForField =>
      this == DotType.none || this == DotType.fieldPartial;

  bool get isField => this == DotType.fieldFull || this == DotType.fieldPartial;
}
