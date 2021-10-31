import 'package:equatable/equatable.dart';

enum BigErrorCode {
  type,
  nan,
  infinity,
  divByZero,
  pow, // if exp is invalid
  dp,
  rm,
  sqrt,
  sd,
}

class BigError implements Exception {
  final BigErrorCode code;
  BigError({required this.code});
}
