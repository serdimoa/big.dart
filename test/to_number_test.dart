import 'package:big/big.dart';

import 'package:test/test.dart';

void main() {
  test('toNumber', () {
    Function t;

    Big.ne = -7;
    Big.pe = 21;
    Big.strict = false;

    // Positive zero
    t = (value) {
      expect(
        1 / Big(value).toNumber() == double.infinity,
        true,
      );
    };

    t(0);
    t('0');
    t('0.0');
    t('0.000000000000');
    t('0e+0');
    t('0e-0');

    // negative zero
    t = (value) {
      expect(1 / Big(value).toNumber() == -double.infinity, true);
    };

    t(Big.zero(isNegative: true));
    t('-0');
    t('-0.0');
    t('-0.000000000000');
    t('-0e+0');
    t('-0e-0');

    t = (value, expected) {
      expect(
        Big(value).toNumber(),
        expected,
        reason: '$value.toNumber() = $expected',
      );
    };

    t(0, 0);
    t(Big.zero(isNegative: true), -0);
    t('0', 0);
    t('-0', -0);

    t(1, 1);
    t('1', 1);
    t('1.0', 1);
    t('1e+0', 1);
    t('1e-0', 1);

    t(-1, -1);
    t('-1', -1);
    t('-1.0', -1);
    t('-1e+0', -1);
    t('-1e-0', -1);

    t('123.456789876543', 123.456789876543);
    t('-123.456789876543', -123.456789876543);

    t('1.1102230246251565e-16', 1.1102230246251565e-16);
    t('-1.1102230246251565e-16', -1.1102230246251565e-16);

    t('9007199254740991', 9007199254740991);
    t('-9007199254740991', -9007199254740991);

    t('5e-324', 5e-324);
    t('1.7976931348623157e+308', 1.7976931348623157e+308);

    t('0.00999', 0.00999);
    t('123.456789', 123.456789);
    t('1.23456789876543', 1.23456789876543);

    t(double.maxFinite, double.maxFinite);

    var n = '1.000000000000000000001';

    t(n, 1);

    Big.strict = true;

    // test.isException(function () {new Big(n).toNumber()}, "new Big(n).toNumber()");

    // test.isException(function () {new Big(0).toNumber()}, "new Big(0).toNumber()");
    // test.isException(function () {new Big(Big.zero(isNegative: true)).toNumber()}, "new Big(Big.zero(isNegative: true)).toNumber()");
    // test.isException(function () {new Big(1).toNumber()}, "new Big(1).toNumber()");
    // test.isException(function () {new Big(-1).toNumber()}, "new Big(-1).toNumber()");

    t('0', 0);
    t('-0', -0);
    t('1', 1);
    t('1.0', 1);
    t('1e+0', 1);
    t('1e-0', 1);
    t('-1', -1);
    t('-1.0', -1);
    t('-1e+0', -1);
    t('-1e-0', -1);

    t('123.456789876543', 123.456789876543);
    t('-123.456789876543', -123.456789876543);

    t('1.1102230246251565e-16', 1.1102230246251565e-16);
    t('-1.1102230246251565e-16', -1.1102230246251565e-16);

    t('9007199254740991', 9007199254740991);
    t('-9007199254740991', -9007199254740991);

    t('5e-324', 5e-324);
    t('1.7976931348623157e+308', 1.7976931348623157e+308);

    t('0.00999', 0.00999);
    t('123.456789', 123.456789);
    t('1.23456789876543', 1.23456789876543);

    Big.strict = false;
  });
}
