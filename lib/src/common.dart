typedef Comparison = int;

class ComparisonValue {
  static const Comparison gt = 1;
  static const Comparison eq = 0;
  static const Comparison lt = -1;
}

enum RoundingMode {
  /// 0
  /// Rounds towards zero.
  /// I.e. truncate, no rounding.
  roundDown,

  /// 1
  ///  Rounds towards nearest neighbour.
  ///  If equidistant, rounds away from zero.
  roundHalfUp,

  /// 2
  ///  Rounds towards nearest neighbour.
  ///   If equidistant, rounds towards even neighbour.
  roundHalfEven,

  /// 3
  ///Rounds away from zero
  roundUp,
}

class BigOption {
  final int dp;
  final RoundingMode rm;
  final int ne;
  final int pe;
  final bool strict;
  BigOption({
    this.dp = 20,
    this.rm = RoundingMode.roundHalfUp,
    this.ne = -7,
    this.pe = 21,
    this.strict = false,
  });

  @override
  String toString() {
    return 'BigOption(dp: $dp, rm: $rm, ne: $ne, pe: $pe, strict: $strict)';
  }
}
