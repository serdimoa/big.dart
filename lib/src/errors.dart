enum BigErrorCode {
  type,
  nan,
  infinity,
  divByZero,
  pow, // if exp is invalid
  dp,
  rm,
  sd,
}

class BigError extends Error {
  final BigErrorCode code;
  final String? description;
  BigError({required this.code, this.description});
}
