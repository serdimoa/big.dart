import 'package:big/big.dart';

import 'package:big/src/common.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // To default
      Big.dp = 20;
      Big.rm = RoundingMode.values[1];
      Big.ne = -7;
      Big.pe = 21;
    });

    test('Value of', () {
      Big.strict = true;
      var y = Big('-0');
      expect(
        () {
          y.valueOf();
        },
        throwsA(const TypeMatcher<BigError>()),
      );

      Big.strict = false;
      expect(
        y.valueOf(),
        '-0',
      );
    });
    test('toExponential', () {
      var x = 45.6;
      var y = Big(x);

      expect(y.toExponential(dp: 1, rm: RoundingMode.roundDown), '4.5e+1');
      expect(y.toExponential(dp: 0), '5e+1');
      expect(y.toExponential(dp: 3), '4.560e+1');
    });
    test('times', () {
      var x = 0.6;
      var y = Big(x);
      expect(y.times(Big(3)), Big('1.8'));
    });
  });
}
