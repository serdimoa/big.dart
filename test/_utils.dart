import 'package:big_dart/big_dart.dart';

import 'package:test/test.dart';

bool isBigZero(Big? n) {
  return n != null &&
      n.c.isNotEmpty &&
      n.c.length == 1 &&
      n.c[0] == 0 &&
      n.e == 0 &&
      (n.s == 1 || n.s == -1);
}

checkException(func, ex) {
  expect(func, throwsA(ex));
}

void isNegativeZero(Big actual) {
  expect(isBigZero(actual) && actual.s == -1, true,
      reason: 'isNegativeZero $actual');
}

void isPositiveZero(Big actual) {
  expect(
    isBigZero(actual) && actual.s == 1,
    true,
    reason: 'isPositiveZero $actual',
  );
}
