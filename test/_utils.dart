import 'package:big/src/big.dart';
import 'package:test/test.dart';

bool isBigZero(Big? n) {
  return n != null &&
      n.c.isNotEmpty &&
      n.c.length == 1 &&
      n.c[0] == 0 &&
      n.e == 0 &&
      (n.s == 1 || n.s == -1);
}

// test.isException = function (func, msg) {
//   var actual;
//   ++count;
//   try {
//     func();
//   } catch (e) {
//     actual = e;
//   }
//   if (actual instanceof Error && /\[big\.js\]/.test(actual.message)) {
//     ++passed;
//   } else {
//     fail(count, (msg + ' to raise an fail.'), (actual || 'no exception'));
//   }
// };

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
