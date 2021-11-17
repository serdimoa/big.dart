enum RoundingMode {
  /// Rounds towards zero.
  /// I.e. truncate, no rounding.
  roundDown,

  ///  Rounds towards nearest neighbour.
  ///  If equidistant, rounds away from zero.
  roundHalfUp,

  ///  Rounds towards nearest neighbour.
  ///   If equidistant, rounds towards even neighbour.
  roundHalfEven,

  ///Rounds away from zero
  roundUp,
}
