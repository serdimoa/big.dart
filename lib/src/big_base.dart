import 'package:big/src/common.dart';

abstract class BigBase {
  /// Returns a Big number whose value is the absolute value, i.e. the magnitude, of this Big number. */
  BigBase abs();

  /// Returns a Big number whose value is the value of this Big number plus n - alias for .plus().
  ///
  /// @throws `NaN` if n is invalid.
  BigBase add(BigBase n);

  /// Compare the values.
  ///
  /// @throws `NaN` if n is invalid.
  Comparison cmp(BigBase n);

  /// Returns a Big number whose value is the value of this Big number divided by n.
  ///
  /// If the result has more fraction digits than is specified by Big.DP, it will be rounded to Big.DP decimal places using rounding mode Big.RM.
  ///
  /// @throws `NaN` if n is invalid.
  /// @throws `±Infinity` on division by zero.
  /// @throws `NaN` on division of zero by zero.
  BigBase div(BigBase n);

  /// Returns true if the value of this Big equals the value of n, otherwise returns false.
  ///
  /// @throws `NaN` if n is invalid.
  bool eq(BigBase n);

  /// Returns true if the value of this Big is greater than the value of n, otherwise returns false.
  ///
  /// @throws `NaN` if n is invalid.
  bool gt(BigBase n);

  /// Returns true if the value of this Big is greater than or equal to the value of n, otherwise returns false.
  ///
  /// @throws `NaN` if n is invalid.
  bool gte(BigBase n);

  /// Returns true if the value of this Big is less than the value of n, otherwise returns false.
  ///
  /// @throws `NaN` if n is invalid.
  bool lt(BigBase n);

  /// Returns true if the value of this Big is less than or equal to the value of n, otherwise returns false.
  ///
  /// @throws `NaN` if n is invalid.
  bool lte(BigBase n);

  /// Returns a Big number whose value is the value of this Big number minus n.
  ///
  /// @throws `NaN` if n is invalid.
  BigBase minus(BigBase n);

  /// Returns a Big number whose value is the value of this Big number modulo n, i.e. the integer remainder of dividing this Big number by n.
  ///
  /// The result will have the same sign as this Big number, and it will match that of Javascript's % operator (within the limits of its precision) and BigDecimal's remainder method.
  ///
  /// @throws `NaN` if n is negative or otherwise invalid.
  BigBase mod(BigBase n);

  /// Returns a Big number whose value is the value of this Big number times n - alias for .times().
  ///
  /// @throws `NaN` if n is invalid.
  BigBase mul(BigBase n);

  /// Returns a Big number whose value is the value of this Big number plus n.
  ///
  /// @throws `NaN` if n is invalid.
  BigBase plus(BigBase n);

  /// Returns a Big number whose value is the value of this Big number raised to the power exp.
  ///
  /// If exp is negative and the result has more fraction digits than is specified by Big.DP, it will be rounded to Big.DP decimal places using rounding mode Big.RM.
  ///
  /// @param exp The power to raise the number to, -1e+6 to 1e+6 inclusive
  /// @throws `!pow!` if exp is invalid.
  ///
  /// Note: High value exponents may cause this method to be slow to return.
  BigBase pow(int exp);

  /// Return a new Big whose value is the value of this Big rounded to a maximum precision of sd
  /// significant digits using rounding mode rm, or Big.RM if rm is not specified.
  ///
  /// @param sd Significant digits: integer, 1 to MAX_DP inclusive.
  /// @param [rm] The rounding mode, one of the RoundingMode enumeration values
  /// @throws `!prec!` if sd is invalid.
  /// @throws `!Big.RM!` if rm is invalid.
  BigBase prec(int sd, RoundingMode? rm);

  /// Returns a Big number whose value is the value of this Big number rounded using rounding mode rm to a maximum of dp decimal places.
  ///
  /// @param dp Decimal places, 0 to 1e+6 inclusive
  /// @param rm The rounding mode, one of the RoundingMode enumeration values
  /// @throws `!round!` if dp is invalid.
  /// @throws `!Big.RM!` if rm is invalid.
  BigBase round(int? dp, RoundingMode? rm, {bool? more});

  /// Returns a Big number whose value is the square root of this Big number.
  ///
  /// If the result has more fraction digits than is specified by Big.DP, it will be rounded to Big.DP decimal places using rounding mode Big.RM.
  ///
  /// @throws `NaN` if this Big number is negative.
  BigBase sqrt();

  /// Returns a Big number whose value is the value of this Big number minus n - alias for .minus().
  ///
  /// @throws `NaN` if n is invalid.
  BigBase sub(BigBase n);

  /// Returns a Big number whose value is the value of this Big number times n.
  ///
  /// @throws `NaN` if n is invalid.
  BigBase times(BigBase n);

  /// Returns a string representing the value of this Big number in exponential notation to a fixed number of decimal places dp.
  ///
  /// If the value of this Big number in exponential notation has more digits to the right of the decimal point than is specified by dp,
  /// the return value will be rounded to dp decimal places using rounding mode Big.RM.
  ///
  /// If the value of this Big number in exponential notation has fewer digits to the right of the decimal point than is specified by dp, the return value will be appended with zeros accordingly.
  ///
  /// If dp is omitted, or is null or undefined, the number of digits after the decimal point defaults to the minimum number of digits necessary to represent the value exactly.
  ///
  /// @param dp Decimal places, 0 to 1e+6 inclusive
  /// @param rm Rounding mode: 0 (down), 1 (half-up), 2 (half-even) or 3 (up).
  /// @throws `!toFix!` if dp is invalid.
  String toExponential(int? dp, RoundingMode? rm);

  /// Returns a string representing the value of this Big number in normal notation to a fixed number of decimal places dp.
  ///
  /// If the value of this Big number in normal notation has more digits to the right of the decimal point than is specified by dp,
  /// the return value will be rounded to dp decimal places using rounding mode Big.RM.
  ///
  /// If the value of this Big number in normal notation has fewer fraction digits then is specified by dp, the return value will be appended with zeros accordingly.
  ///
  /// Unlike Number.prototype.toFixed, which returns exponential notation if a number is greater or equal to 1021, this method will always return normal notation.
  ///
  /// If dp is omitted, or is null or undefined, then the return value is simply the value in normal notation.
  /// This is also unlike Number.prototype.toFixed, which returns the value to zero decimal places.
  ///
  /// @param dp Decimal places, 0 to 1e+6 inclusive
  /// @param rm Rounding mode: 0 (down), 1 (half-up), 2 (half-even) or 3 (up).
  /// @throws `!toFix!` if dp is invalid.
  String toFixed(int? dp, RoundingMode? rm);

  /// Returns a string representing the value of this Big number to the specified number of significant digits sd.
  ///
  /// If the value of this Big number has more digits than is specified by sd, the return value will be rounded to sd significant digits using rounding mode Big.RM.
  ///
  /// If the value of this Big number has fewer digits than is specified by sd, the return value will be appended with zeros accordingly.
  ///
  /// If sd is less than the number of digits necessary to represent the integer part of the value in normal notation, then exponential notation is used.
  ///
  /// If sd is omitted, or is null or undefined, then the return value is the same as .toString().
  ///
  /// @param sd Significant digits, 1 to 1e+6 inclusive
  /// @param rm Rounding mode: 0 (down), 1 (half-up), 2 (half-even) or 3 (up).
  /// @throws `!toPre!` if sd is invalid.
  String toPrecision(int? sd, RoundingMode? rm);

  /// Returns a string representing the value of this Big number.
  ///
  /// If this Big number has a positive exponent that is equal to or greater than 21, or a negative exponent equal to or less than -7, then exponential notation is returned.
  ///
  /// The point at which toString returns exponential rather than normal notation can be adjusted by changing
  /// the value of Big.E_POS and Big.E_NEG. By default, Big numbers correspond to Javascript's number type in this regard.
  @override
  String toString();

  /// Returns a primitive number representing the value of this Big number.
  ///
  /// If Big.strict is true an error will be thrown if toNumber is called on a Big number which cannot be converted to a primitive number without a loss of precision.
  ///
  /// @since 6.0
  double toNumber();

  /// Returns a string representing the value of this Big number.
  ///
  /// If this Big number has a positive exponent that is equal to or greater than 21, or a negative exponent equal to or less than -7, then exponential notation is returned.
  ///
  /// The point at which toString returns exponential rather than normal notation can be adjusted by changing
  /// the value of Big.E_POS and Big.E_NEG. By default, Big numbers correspond to Javascript's number type in this regard.
  String valueOf();

  /// Returns a string representing the value of this Big number.
  ///
  /// If this Big number has a positive exponent that is equal to or greater than 21, or a negative exponent equal to or less than -7, then exponential notation is returned.
  ///
  /// The point at which toString returns exponential rather than normal notation can be adjusted by changing
  /// the value of Big.E_POS and Big.E_NEG. By default, Big numbers correspond to Javascript's number type in this regard.
  String toJSON();

  /// Returns an array of single digits
  late List<int> c;

  /// Returns the exponent, Integer, -1e+6 to 1e+6 inclusive
  late int e;

  /// Returns the sign, -1 or 1
  late int s;
}
