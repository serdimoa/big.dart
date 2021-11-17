// ignore_for_file: non_constant_identifier_names

import 'package:big_dart/src/common.dart';
import 'package:big_dart/src/errors.dart';
import 'package:big_dart/src/round.dart';
import 'package:big_dart/src/stringify.dart';
import 'package:big_dart/src/utils.dart';
import 'dart:math' as math;

var _numeric = RegExp(
  r"^-?(\d+(\.\d*)?|\.\d+)(e[+-]?\d+)?$",
  caseSensitive: false,
  multiLine: false,
);

class Big extends Comparable<Big> {
  /// Returns an array of single digits
  late List<int> c;

  /// Returns the exponent, Integer, -1e+6 to 1e+6 inclusive
  late int e;

  /// Returns the sign, -1 or 1
  late int s;

  // The default values below must be integers within the stated ranges.

  /// The maximum number of decimal places (dp) of the results of operations involving division:
  /// div and sqrt, and pow with negative exponents.
  static var dp = 20; // 0 to maxDp

  /// The rounding mode (rm) used when rounding to the above decimal places.
  static RoundingMode rm = RoundingMode.roundHalfUp;

  RoundingMode get RM => rm;

  /// The maximum value of dp and [Big.dp].
  final maxDp = 1E6; // 0 to 1000000

  /// The maximum magnitude of the exponent argument to the pow method.
  final maxPower = 1E6; // 1 to 1000000

  ///  The negative exponent (ne) at and beneath which toString returns exponential notation.
  ///   (Dart numbers: -7)
  ///   -1000000 is the minimum recommended exponent value of a [Big].
  static var ne = -7; // 0 to -1000000

  /// The positive exponent (pe) at and above which toString returns exponential notation.
  /// (Dart numbers: 21)
  /// 1000000 is the maximum recommended exponent value of a [Big], but this limit is not enforced.
  static var pe = 21; // 0 to 1000000

  /// When true, an error will be thrown if a primitive number is passed to the Big constructor,
  /// or if valueOf is called, or if toNumber is called on a Big which cannot be converted to a
  /// primitive number without a loss of precision.
  static var strict = false; // true or false

  // Error messages.
  static const name = '[big.dart] ';
  static const invalid = name + 'Invalid ';
  static const invalidDp = invalid + 'decimal places';
  static const invalidRm = invalid + 'rounding mode';
  static const divByZero = name + 'Division by zero';

  Big.zero({bool isNegative = false}) {
    if (isNegative) {
      parse(this, '-0');
    } else {
      parse(this, '0');
    }
  }

  /// Return a new Big whose value is the value of this Big rounded to a maximum precision of sd
  /// significant digits using rounding mode rm, or Big.rm if rm is not specified.
  ///
  /// sd [int] Significant digits: integer, 1 to MAX_DP inclusive.
  /// rm? [RoundingMode] Rounding mode.
  Big prec(int sd, [RoundingMode? _rm]) {
    if (sd != ~~sd || sd < 1 || sd > maxDp) {
      throw BigError(code: BigErrorCode.dp);
    }
    return round(
      Big(this),
      sd,
      _rm,
    );
  }

  Big(dynamic n) {
    // Duplicate
    if (n is Big) {
      s = n.s;
      e = n.e;
      c = [...n.c];
    } else {
      if (n is! String) {
        if (Big.strict == true) {
          throw BigError(
            code: BigErrorCode.invalidNumber,
          );
        }
        // Minus zero?
        // if (n == 0 && 1 / n < 0) {

        // } else {
        n = n.toString();
        // }
      }
      Big b = parse(this, n);
      c = b.c;
      e = b.e;
      s = b.s;
    }
  }

  /// Parse the number or string value passed to a Big constructor.
  ///  x [Big] A Big number instance.
  ///  n [String] A numeric value.
  Big parse(Big x, String n) {
    int e, i, nl;

    if (!_numeric.hasMatch(n)) {
      throw BigError(
        code: BigErrorCode.type,
      );
    }

    // Determine sign.
    if (n[0] == '-') {
      n = n.substring(1);
      x.s = -1;
    } else {
      x.s = 1;
    }

    // Decimal point?
    if ((e = n.indexOf('.')) > -1) {
      n = n.replaceFirst('.', '');
    }

    // Exponential form?
    if ((i = n.indexOf(RegExp(r'e', caseSensitive: false))) > 0) {
      // Determine exponent.
      if (e < 0) {
        e = i;
      }
      e += int.parse(n.substring(i + 1));
      n = n.substring(0, i);
    } else if (e < 0) {
      // Integer.
      e = n.length;
    }

    nl = n.length;

    // Determine leading zeros.
    for (i = 0; i < nl && n[i] == '0';) {
      ++i;
    }

    if (i == nl) {
      // Zero.
      x.c = [x.e = 0];
    } else {
      // Determine trailing zeros.
      for (; nl > 0 && n[--nl] == '0';) {}
      x.e = e - i - 1;
      x.c = [];

      // Convert string to array of digits without leading/trailing zeros.
      for (e = 0; i <= nl;) {
        x.c.add(int.parse(n[i++]));
      }
    }
    return x;
  }

  /// Return a new [Big] whose value is the square root of the value of this [Big], rounded, if
  /// necessary, to a maximum of [Big.dp] decimal places using rounding mode [Big.rm].
  Big sqrt() {
    Big r, t;
    String c;
    var x = this;
    double s = x.s.toDouble();
    var e = x.e, half = Big('0.5');

    // Zero?
    if (x.c[0] == 0) return Big(x);

    // Negative?
    if (s < 0) {
      throw BigError(code: BigErrorCode.sqrt);
    }

    // Estimate.
    s = math.sqrt(x.toNumber());
    // Math.sqrt underflow/overflow?
    // Re-estimate: pass x coefficient to Math.sqrt as integer, then adjust the result exponent.
    if (s == 0 || s == 1 / 0) {
      c = x.c.join('');
      if (((c.length + e) & 1) != 0) {
        c += '0';
      }
      s = math.sqrt(double.parse(c));
      e = ((e + 1) ~/ 2 | 0) - (e < 0 ? 1 : e.toInt() & 1);
      var sAsExp = s.toStringAsExponential();
      var predefined =
          s == 1 / 0 ? '5e' : sAsExp.substring(0, sAsExp.indexOf('e') + 1);
      r = Big('$predefined$e');
    } else {
      r = Big(s);
    }

    e = r.e + (dp += 4);

    // Newton-Raphson iteration.
    do {
      t = r;
      r = half.times(t.add(x.div(t)));
    } while (t.c.slice(0, e).join('') != r.c.slice(0, e).join(''));

    return round(
      r,
      ((dp -= 4) + r.e + 1).toInt(),
      rm,
    );
  }

  /// Return a new [Big] whose value is the absolute value of this [Big].
  Big abs() {
    var x = this;
    x.s = 1;
    return x;
  }

  /// Compare two [Big]
  ///
  /// * `1` if the value of this [Big] is greater than the value of [Big] [y],
  /// * `-1` if the value of this [Big] is less than the value of [Big] [y],
  /// * `0` if they have the same value.
  int cmp(dynamic y) {
    bool isNegative;
    var yBig = Big(y);
    var x = this,
        xc = x.c,
        yc = yBig.c,
        i = x.s,
        j = yBig.s,
        k = x.e,
        l = yBig.e;

    // Either zero?
    if (!xc.numberAtLikeJsTest(0) || !yc.numberAtLikeJsTest(0)) {
      return !xc.numberAtLikeJsTest(0)
          ? !yc.numberAtLikeJsTest(0)
              ? 0
              : -j
          : i;
    }

    // Signs differ?
    if (i != j) return i;

    isNegative = i < 0;

    // Compare exponents.
    if (k != l) {
      return (k > l) ^ isNegative ? 1 : -1;
    }

    j = (k = xc.length) < (l = yc.length) ? k : l;

    // Compare digit by digit.
    for (i = -1; ++i < j;) {
      if (xc[i] != yc[i]) return (xc[i] > yc[i]) ^ isNegative ? 1 : -1;
    }

    // Compare lengths.
    return k == l
        ? 0
        : (k > l) ^ isNegative
            ? 1
            : -1;
  }

  /// Return a new [Big] whose value is the value of this [Big] divided by the value of [Big] y, rounded,
  /// if necessary, to a maximum of [Big.dp] decimal places using rounding mode [Big.rm].
  Big div(dynamic y) {
    var yBig = Big(y);
    var x = this,
        a = x.c, // dividend
        b = yBig.c, // divisor
        k = x.s == yBig.s ? 1 : -1,
        dp = Big.dp;

    // Divisor is zero?
    if (!b.numberAtLikeJsTest(0)) {
      throw BigError(
        code: BigErrorCode.divByZero,
      );
    }

    // Dividend is 0? Return +-0.
    if (!a.numberAtLikeJsTest(0)) {
      yBig.s = k;
      yBig.c = [yBig.e = 0];
      return yBig;
    }
    int? cmp;
    int n, ri, bl;
    List<int> bt;
    var bz = [...b],
        ai = bl = b.length,
        al = a.length,
        q = yBig, // quotient
        qc = q.c = [],
        qi = 0;
    q.e = x.e - yBig.e;
    var p = dp + q.e + 1; // precision of the result

    var r = a.slice(0, bl); // remainder
    var rl = r.length;

    q.s = k;
    k = p < 0 ? 0 : p;

    // Create version of divisor with leading zero.
    unShift(bz, 0);

    // Add zeros to make remainder as long as divisor.
    for (; rl++ < bl;) {
      r.add(0);
    }

    do {
      // n is how many times the divisor goes into current remainder.
      for (n = 0; n < 10; n++) {
        // Compare divisor and remainder.
        if (bl != (rl = r.length)) {
          cmp = bl > rl ? 1 : -1;
        } else {
          cmp = 0;
          for (ri = -1; ++ri < bl;) {
            if (b[ri] != r[ri]) {
              cmp = b[ri] > r[ri] ? 1 : -1;
              break;
            }
          }
        }

        // If divisor < remainder, subtract divisor from remainder.
        if (cmp != null && cmp < 0) {
          // Remainder can't be more than 1 digit longer than divisor.
          // Equalise lengths using divisor with extra leading zero?
          for (bt = rl == bl ? b : bz; rl != 0;) {
            if (r[--rl] < (bt.elementAtOrNull(rl) ?? 0)) {
              ri = rl;
              for (; ri != 0 && !r.numberAtLikeJsTest(--ri);) {
                r[ri] = 9;
              }
              --r[ri];
              r[rl] += 10;
            }
            r[rl] -= bt.elementAtOrNull(rl) ?? 0;
          }

          for (; !r.numberAtLikeJsTest(0);) {
            r.removeAt(0);
          }
        } else {
          break;
        }
      }

      // Add the digit n to the result array.
      if (cmp != null && cmp != 0) {
        qi++;
        qc.add(n);
      } else {
        qi++;
        qc.add(++n);
      }
      // Update the remainder.
      if (r.numberAtLikeJsTest(0) && cmp != null && cmp != 0) {
        r.add(a.elementAtOrNull(ai) ?? 0);
      } else {
        r = a.elementAtOrNull(ai) != null ? [a.elementAt(ai)] : [];
      }
    } while ((ai++ < al || r.firstOrNull != null) && (k--).intToBool);

    // Leading zero? Do not remove if result is simply zero (qi == 1).
    if (!qc.numberAtLikeJsTest(0) && qi != 1) {
      // There can't be more than one zero.
      qc.removeAt(0);
      q.e--;
      p--;
    }

    // Round?
    if (qi > p) {
      round(q, p, rm, more: r.firstOrNull != null);
    }

    return q;
  }

  /// Return true if the value of this [Big] is equal to the value of [Big] y, otherwise return false.
  bool eq(dynamic y) {
    return cmp(y) == 0;
  }

  /// Return true if the value of this [Big] is greater than the value of [Big] y, otherwise return
  /// false.
  bool gt(dynamic y) {
    return cmp(y) > 0;
  }

  /// Return true if the value of this [Big] is greater than or equal to the value of [Big] y, otherwise
  /// return false.
  bool gte(dynamic y) {
    return cmp(y) > -1;
  }

  /// Return true if the value of this [Big] is less than the value of [Big] y, otherwise return false.
  bool lt(dynamic y) {
    return cmp(y) < 0;
  }

  ///  Return true if the value of this [Big] is less than or equal to the value of [Big] y, otherwise
  ///  return false.
  bool lte(dynamic y) {
    return cmp(y) < 1;
  }

  /// Return a new [Big] whose value is the value of this [Big] minus the value of [Big] y.
  Big sub(dynamic y) {
    var yBig = Big(y);
    int i, j;
    List<int> t;
    var x = this, a = x.s, b = yBig.s;
    bool isXLtY;
    // Signs differ?
    if (a != b) {
      yBig.s = -b;
      return x.add(yBig);
    }

    var xc = [...x.c], xe = x.e, yc = yBig.c, ye = yBig.e;

    // Either zero?
    if (!xc.numberAtLikeJsTest(0) || !yc.numberAtLikeJsTest(0)) {
      if (yc.numberAtLikeJsTest(0)) {
        yBig.s = -b;
      } else if (xc.numberAtLikeJsTest(0)) {
        yBig = Big(x);
      } else {
        yBig.s = 1;
      }
      return yBig;
    }

    a = xe - ye;
    // Determine which is the bigger number. Prepend zeros to equalise exponents.
    if (a != 0) {
      if (isXLtY = a < 0) {
        a = -a;
        t = xc;
      } else {
        ye = xe;
        t = yc;
      }

      t.reverse();
      for (b = a; b > 0;) {
        b--;
        t.add(0);
      }
      t.reverse();
    } else {
      // Exponents equal. Check digit by digit.
      j = ((isXLtY = xc.length < yc.length) ? xc : yc).length;

      for (a = b = 0; b < j; b++) {
        if (xc[b] != yc[b]) {
          isXLtY = xc[b] < yc[b];
          break;
        }
      }
    }

    // x < y? Point xc to the array of the bigger number.
    if (isXLtY) {
      t = xc;
      xc = yc;
      yc = t;
      yBig.s = -yBig.s;
    }

    /// Append zeros to xc if shorter. No need to add zeros to yc if shorter as subtraction only
    /// needs to start at yc.length.

    if ((b = (j = yc.length) - (i = xc.length)) > 0) {
      for (; b > 0;) {
        b--;
        i++;
        xc.add(0);
      }
    }

    // Subtract yc from xc.
    for (b = i; j > a;) {
      if (xc[--j] < yc[j]) {
        for (i = j; i > 0 && !xc.numberAtLikeJsTest(--i);) {
          xc[i] = 9;
        }
        --xc[i];
        xc[j] += 10;
      }

      xc[j] -= yc[j];
    }

    // Remove trailing zeros.
    for (; xc[--b] == 0;) {
      xc.removeLast();
      if (b == 0) {
        break;
      }
    }
    // Remove leading zeros and adjust exponent accordingly.
    for (; xc.isNotEmpty && xc[0] == 0;) {
      xc.removeAt(0);
      --ye;
    }

    if (!xc.numberAtLikeJsTest(0)) {
      // n - n = +0
      yBig.s = 1;

      // Result must be zero.
      xc = [ye = 0];
    }

    yBig.c = xc;
    yBig.e = ye;

    return yBig;
  }

  /// Return a new [Big] whose value is the value of this [Big] modulo the value of [Big] y.
  Big mod(dynamic y) {
    bool isYgtX;
    var yBig = Big(y);
    var x = this, a = x.s, b = yBig.s;

    if (!yBig.c.numberAtLikeJsTest(0)) {
      throw BigError(
        code: BigErrorCode.divByZero,
      );
    }

    x.s = yBig.s = 1;
    isYgtX = yBig.cmp(x) == 1;
    x.s = a;
    yBig.s = b;
    if (isYgtX) return Big(x);

    var tempRm = rm;
    a = dp;
    rm = RoundingMode.roundDown;
    dp = 0;
    x = x.div(yBig);
    dp = a;
    rm = tempRm;
    return sub(x.times(yBig));
  }

  /// Return a new Big whose value is the value of this [Big] plus the value of [Big] y.
  Big add(dynamic y) {
    var yBig = Big(y);
    int e, k;
    List<int> t;
    Big x = this;

    // Signs differ?
    if (x.s != yBig.s) {
      yBig.s = -yBig.s;
      return x.sub(yBig);
    }

    var xe = x.e, xc = x.c, ye = yBig.e, yc = yBig.c;
    // Either zero?
    if (!xc.numberAtLikeJsTest(0) || !yc.numberAtLikeJsTest(0)) {
      if (!yc.numberAtLikeJsTest(0)) {
        if (xc.numberAtLikeJsTest(0)) {
          yBig = Big(x);
        } else {
          yBig.s = x.s;
        }
      }
      return yBig;
    }
    xc = [...xc];

    // Prepend zeros to equalise exponents.
    e = xe - ye;
    if (e != 0) {
      if (e > 0) {
        ye = xe;
        t = yc;
      } else {
        e = -e;
        t = xc;
      }

      t.reverse();

      for (; e-- > 0;) {
        t.add(0);
      }
      t.reverse();
    }

    // Point xc to the longer array.
    if (xc.length - yc.length < 0) {
      t = yc;
      yc = xc;
      xc = t;
    }

    e = yc.length;

    // Only start adding at yc.length - 1 as the further digits of xc can be left as they are.
    for (k = 0; e > 0; xc[e] %= 10) {
      k = (xc[--e] = xc[e] + yc[e] + k) ~/ 10 | 0;
    }

    // No need to check for zero, as +x + +y != 0 && -x + -y != 0

    if (k != 0) {
      unShift(xc, k);
      ++ye;
    }

    // Remove trailing zeros.
    for (e = xc.length; xc[--e] == 0;) {
      xc.removeLast();
    }

    yBig.c = xc;
    yBig.e = ye;

    return yBig;
  }

  /// Return a [Big] whose value is the value of this [Big] raised to the power [n].
  /// If [n] is negative, round to a maximum of [Big.dp] decimal places using rounding
  /// mode [Big.rm].
  /// n [int] Integer, -[maxPower] to [maxPower] inclusive.
  Big pow(int n) {
    if (n != ~~n || n < -maxPower || n > maxPower) {
      throw BigError(
        code: BigErrorCode.pow,
      );
    }
    var x = this, one = Big('1'), y = one, isNegative = n < 0;

    if (isNegative) n = -n;

    for (;;) {
      if ((n & 1) != 0) y = y.times(x);
      n >>= 1;
      if (n == 0) break;
      x = x.times(x);
    }

    return isNegative ? one.div(y) : y;
  }

  /// Return a new [Big] whose value is the value of this [Big] times the value of Big y.
  Big times(dynamic y) {
    List<int> c;
    var yBig = Big(y);
    var x = this,
        xc = x.c,
        yc = yBig.c,
        a = xc.length,
        b = yc.length,
        i = x.e,
        j = yBig.e;

    // Determine sign of result.
    yBig.s = x.s == yBig.s ? 1 : -1;

    // Return signed 0 if either 0.
    if (!xc.numberAtLikeJsTest(0) || !yc.numberAtLikeJsTest(0)) {
      yBig.c = [yBig.e = 0];
      return yBig;
    }

    // Initialize exponent of result as x.e + y.e.
    yBig.e = i + j;

    // If array xc has fewer digits than yc, swap xc and yc, and lengths.
    if (a < b) {
      c = xc;
      xc = yc;
      yc = c;
      j = a;
      a = b;
      b = j;
    }

    // Initialize coefficient array of result with zeros.
    c = List.filled(a + b, 0, growable: true);
    // Multiply.

    // i is initially xc.length.
    for (i = b; (i--) > 0;) {
      b = 0;

      // a is yc.length.
      for (j = a + i; j > i;) {
        // Current sum of products at this digit position, plus carry.
        b = c[j] + yc[i] * xc[j - i - 1] + b;
        c[j--] = b % 10;

        // carry
        b = b ~/ 10 | 0;
      }

      c[j] = b;
    }

    // Increment result exponent if there is a final carry, otherwise remove leading zero.
    if (b != 0) {
      ++yBig.e;
    } else {
      c.removeAt(0);
    }

    // Remove trailing zeros.
    for (i = c.length; !c.numberAtLikeJsTest(--i);) {
      c.removeLast();
    }

    yBig.c = c;
    return yBig;
  }

  /// Return a string representing the value of this [Big] in exponential notation rounded to [dp] fixed
  /// decimal places using rounding mode [rm], or [Big.rm] if [rm] is not specified.
  /// dp? [int] Decimal places: integer, 0 to maxDp inclusive.
  /// rm? [RoundingMode] Rounding mode
  String toStringAsExponential({int? dp, RoundingMode? rm}) {
    var x = this, n = x.c[0];

    if (dp != null) {
      if (dp != ~~dp || dp < 0 || dp > maxDp) {
        throw BigError(
          code: BigErrorCode.dp,
        );
      }
      x = round(Big(x), ++dp, rm);
      for (; x.c.length < dp;) {
        x.c.add(0);
      }
    }

    return stringify(x, true, n != 0);
  }

  /// Return a string representing the value of this Big in normal notation rounded to dp fixed
  /// decimal places using rounding mode [rm], or [Big.rm] if rm is not specified.
  ///
  /// dp? [int] Decimal places: integer, 0 to maxDp inclusive.
  /// rm? [RoundingMode] Rounding mode.
  ///
  /// (-0).toFixed(dp:0) is '0', but (-0.1).toFixed(dp:0) is '-0'.
  /// (-0).toFixed(dp:1) is '0.0', but (-0.01).toFixed(dp:1) is '-0.0'.
  ///
  String toStringAsFixed({int? dp, RoundingMode? rm}) {
    var x = this, n = x.c[0];

    if (dp != null) {
      if (dp != ~~dp || dp < 0 || dp > maxDp) {
        throw BigError(
          code: BigErrorCode.dp,
        );
      }
      x = round(Big(x), dp + x.e + 1, rm);

      // x.e may have changed if the value is rounded up.
      for (dp = dp + x.e + 1; x.c.length < dp;) {
        x.c.add(0);
      }
    }

    return stringify(x, false, n != 0);
  }

  /// Return a string representing the value of this Big.
  /// Return exponential notation if this Big has a positive exponent equal to or greater than
  /// Big.PE, or a negative exponent equal to or less than Big.NE.
  /// Omit the sign for negative zero.

  @override
  toString() {
    var x = this;
    return stringify(x, x.e <= ne || x.e >= pe, x.c.numberAtLikeJsTest(0));
  }

  /// Return the value of this Big as a primitive number.
  double toNumber() {
    var n = double.parse(stringify(this, true, true));
    if (strict == true && !eq(Big(n.toString()))) {
      throw BigError(
        code: BigErrorCode.impreciseConversion,
      );
    }
    return n;
  }

  /// Return a string representing the value of this Big rounded to sd significant digits using
  /// rounding mode rm, or Big.rm if rm is not specified.
  /// Use exponential notation if sd is less than the number of digits necessary to represent
  /// the integer part of the value in normal notation.
  /// sd {number} Significant digits: integer, 1 to maxDp inclusive.
  /// rm? {number} Rounding mode: 0 (down), 1 (half-up), 2 (half-even) or 3 (up).

  String toStringAsPrecision([int? sd, RoundingMode? rm]) {
    var x = this, n = x.c[0];
    if (sd != null) {
      if (sd != ~~sd || sd < 1 || sd > maxDp) {
        throw BigError(
          code: BigErrorCode.sd,
        );
      }
      x = round(Big(x), sd, rm);
      for (; x.c.length < sd;) {
        x.c.add(0);
      }
    }

    return stringify(
      x,
      (sd != null && sd <= x.e) || x.e <= ne || x.e >= pe,
      n != 0,
    );
  }

  /// Return a string representing the value of this Big.
  /// Return exponential notation if this Big has a positive exponent equal to or greater than
  /// [Big.pe], or a negative exponent equal to or less than [Big.ne].
  /// Include the sign for negative zero.
  String valueOf() {
    var x = this;

    if (Big.strict == true) {
      throw BigError(
        code: BigErrorCode.invalidNumber,
      );
    }
    return stringify(x, x.e <= ne || x.e >= pe, true);
  }

  Big selfRound([int? dp, RoundingMode? roundingMode]) {
    if (dp == null) {
      dp = 0;
    } else if (dp != ~~dp || dp < -maxDp || dp > maxDp) {
      throw BigError(
        code: BigErrorCode.dp,
      );
    }
    return round(
      Big(this),
      dp + e + 1,
      roundingMode,
    );
  }

  @override
  int compareTo(other) {
    return cmp(other);
  }

  Big operator +(dynamic other) => add(other);
  Big operator -(dynamic other) => sub(other);
  Big operator /(dynamic other) => div(other);
  Big operator *(dynamic other) => times(other);
  Big operator %(dynamic other) => mod(other);
  bool operator <(dynamic other) => lt(other);
  bool operator >(dynamic other) => gt(other);
  bool operator >=(dynamic other) => gte(other);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;

    return eq(other);
  }

  bool operator <=(dynamic other) => lte(other);
  Big operator -() {
    s = -s;
    return this;
  }

  // coverage:ignore-start
  @override
  int get hashCode => c.hashCode + e.hashCode + s.hashCode;
  // coverage:ignore-end
}

extension BigInt on int {
  Big get toBig => Big(this);
  bool get intToBool => this == 0 ? false : true;
}

extension BigDouble on double {
  Big get toBig => Big(this);
}

extension BigString on String {
  Big get toBig => Big(this);
}
