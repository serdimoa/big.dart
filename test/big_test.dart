import 'package:big_dart/big_dart.dart';

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

    test('use number to calculate', () {
      var a = Big(3);
      expect(a.div(3).toString(), '1');
      expect((-a).toString(), '-3');
    });

    test('strict mode', () {
      Big.strict = true;
      try {
        var y = Big('1.0000000000000001');
        y.toNumber();
        throw Error();
      } catch (e) {
        expect(e, BigError(code: BigErrorCode.impreciseConversion));
      }
      try {
        var _ = Big(1);
      } catch (e) {
        expect(e, BigError(code: BigErrorCode.invalidNumber));
      }
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

      expect(
          y.toStringAsExponential(dp: 1, rm: RoundingMode.roundDown), '4.5e+1');
      expect(y.toStringAsExponential(dp: 0), '5e+1');
      expect(y.toStringAsExponential(dp: 3), '4.560e+1');
    });
    test('times', () {
      var x = 0.6;
      var y = Big(x);
      expect(y.times(Big(3)), Big('1.8'));
    });
  });
}
