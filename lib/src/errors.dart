enum BigErrorCode {
  type,
  nan,
  infinity,
  divByZero,
  pow, // if exp is invalid
  impreciseConversion,
  invalidNumber,
  dp,
  rm,
  sqrt,
  sd,
}

class BigError implements Exception {
  final BigErrorCode code;
  BigError({required this.code});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BigError && other.code == code;
  }

  // coverage:ignore-start
  @override
  String toString() {
    return 'BigError(code:$code)';
  }

  @override
  int get hashCode => code.hashCode;
  // coverage:ignore-end

}
