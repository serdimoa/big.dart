// ignore_for_file: non_constant_identifier_names

import 'package:big/src/common.dart';
import 'package:big/src/errors.dart';
import 'package:big/src/round.dart';
import 'package:big/src/stringify.dart';
import 'package:big/src/utils.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';
// import 'package:collection/collection.dart';

extension BigList<T> on List<T> {
  List<T> slice(int begin, [int? end]) {
    var nextEnd = end;
    if (end != null) {
      if (end > length) {
        nextEnd = length;
      }
    }
    return getRange(
            begin,
            nextEnd == null
                ? length
                : nextEnd < 0
                    ? length + nextEnd
                    : nextEnd)
        .toList();
  }
}

extension BigListExtension<T> on Iterable<T> {
  T? elementAtOrNull(int index) {
    if (index < 0) return null;
    var count = 0;
    for (final element in this) {
      if (index == count++) return element;
    }
    return null;
  }

  T? get firstOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }

  bool numberAtLikeJsTest(int index) {
    var element = elementAtOrNull(index);
    if (element == null) {
      return false;
    }
    if (element is int || element is double) {
      if (element == 0) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }
}

extension ListEx<T> on List<T> {
  void reverse() {
    for (var i = 0; i < length / 2; i++) {
      var tempValue = elementAt(i);
      this[i] = elementAt(length - 1 - i);
      this[length - 1 - i] = tempValue;
    }
  }
}

var numeric = RegExp(
  r"^-?(\d+(\.\d*)?|\.\d+)(e[+-]?\d+)?$",
  caseSensitive: false,
  multiLine: false,
);

class Big with EquatableMixin {
  /// Returns an array of single digits
  late List<int> c;

  /// Returns the exponent, Integer, -1e+6 to 1e+6 inclusive
  late int e;

  /// Returns the sign, -1 or 1
  late int s;

  String get debug => "Big {\n s:$s,\ne:$e,\nc:$c\n}";

  /// ************************************ EDITABLE DEFAULTS *****************************************/

  // The default values below must be integers within the stated ranges.

  /// The maximum number of decimal places (DP) of the results of operations involving division:
  /// div and sqrt, and pow with negative exponents.
  static var dp = 20; // 0 to MAX_DP

  /// The rounding mode (RM) used when rounding to the above decimal places.
  ///  0  Towards zero (i.e. truncate, no rounding).       (ROUND_DOWN)
  ///  1  To nearest neighbour. If equidistant, round up.  (ROUND_HALF_UP)
  ///  2  To nearest neighbour. If equidistant, to even.   (ROUND_HALF_EVEN)
  ///  3  Away from zero.                                  (ROUND_UP)
  static int rm = 1; // 0, 1, 2 or 3
  get RM => rm;

  /// The maximum value of DP and Big.DP.
  final maxDp = 1E6; // 0 to 1000000

  /// The maximum magnitude of the exponent argument to the pow method.
  final maxPower = 1E6; // 1 to 1000000

  ///  The negative exponent (NE) at and beneath which toString returns exponential notation.
  ///   (JavaScript numbers: -7)
  ///   -1000000 is the minimum recommended exponent value of a Big.
  static var ne = -7; // 0 to -1000000

  /// The positive exponent (PE) at and above which toString returns exponential notation.
  /// (JavaScript numbers: 21)
  /// 1000000 is the maximum recommended exponent value of a Big, but this limit is not enforced.
  var pe = 21; // 0 to 1000000

  /// When true, an error will be thrown if a primitive number is passed to the Big constructor,
  /// or if valueOf is called, or if toNumber is called on a Big which cannot be converted to a
  /// primitive number without a loss of precision.
  static var strict = false; // true or false

  /// ************************************************************************************************/

  // Error messages.
  static const name = '[big.js] ';
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

  Big.fromParams(this.s, this.e, this.c);

  Big(dynamic n, {BigOption? options}) {
    // Duplicate
    if (n is Big) {
      s = n.s;
      e = n.e;
      c = [...n.c];
    } else {
      if (n is! String) {
        if (Big.strict == true) {
          throw BigError(
            description: invalid + 'number',
            code: BigErrorCode.type,
          );
        }
        // Minus zero?
        if (n == 0 && 1 / n < 0) {
          n = '-0';
        } else {
          n = n.toString();
        }
      }
      Big b = parse(this, n);
      c = b.c;
      e = b.e;
      s = b.s;
    }
    if (options != null) {
      dp = options.dp;
      rm = options.rm.index;
      ne = options.ne;
      pe = options.pe;
    }
  }

  /// Parse the number or string value passed to a Big constructor.
  ///  x {Big} A Big number instance.
  ///  n {number|string} A numeric value.
  Big parse(Big x, dynamic n) {
    int e, i, nl;

    if (!numeric.hasMatch(n)) {
      throw BigError(
        description: invalid + 'number',
        code: BigErrorCode.type,
      );
    }
    if (n is! String) {
      n = n.toString();
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
        try {
          x.c.add(int.parse(n[i++]));
        } catch (e) {
          print(e);
        }
      }
    }
    return x;
  }

  /// Return a new Big whose value is the absolute value of this Big.
  Big abs() {
    var x = this;
    x.s = 1;
    return x;
  }

  /// Return 1 if the value of this Big is greater than the value of Big y,
  ///       -1 if the value of this Big is less than the value of Big y, or
  ///        0 if they have the same value.
  int cmp(Big y) {
    bool isneg;
    var x = this, xc = x.c, yc = y.c, i = x.s, j = y.s, k = x.e, l = y.e;

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

    isneg = i < 0;

    // Compare exponents.
    if (k != l) {
      return (k > l) ^ isneg ? 1 : -1;
    }

    j = (k = xc.length) < (l = yc.length) ? k : l;

    // Compare digit by digit.
    for (i = -1; ++i < j;) {
      if (xc[i] != yc[i]) return (xc[i] > yc[i]) ^ isneg ? 1 : -1;
    }

    // Compare lengths.
    return k == l
        ? 0
        : (k > l) ^ isneg
            ? 1
            : -1;
  }

  /// Return a new Big whose value is the value of this Big divided by the value of Big y, rounded,
  /// if necessary, to a maximum of Big.DP decimal places using rounding mode Big.RM.
  Big div(Big y) {
    y = Big(y);
    var x = this,
        a = x.c, // dividend
        b = y.c, // divisor
        k = x.s == y.s ? 1 : -1,
        dp = Big.dp;

    if (dp != ~~dp || dp < 0 || dp > maxDp) {
      throw BigError(code: BigErrorCode.dp, description: invalidDp);
    }

    // Divisor is zero?
    if (!b.numberAtLikeJsTest(0)) {
      throw BigError(code: BigErrorCode.divByZero, description: divByZero);
    }

    // Dividend is 0? Return +-0.
    if (!a.numberAtLikeJsTest(0)) {
      y.s = k;
      y.c = [y.e = 0];
      return y;
    }
    int? bl, cmp;
    int n, ri;
    List<int> bt;
    var bz = [...b],
        ai = bl = b.length,
        al = a.length,
        q = y, // quotient
        qc = q.c = [],
        qi = 0;
    q.e = x.e - y.e;
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
        if (qc.elementAtOrNull(qi) == null) {
          qc.add(n);
        } else {
          qc[qi] = n;
        }
      } else {
        qi++;

        if (qc.elementAtOrNull(qi) == null) {
          qc.add(++n);
        } else {
          qc[qi] = ++n;
        }
      }
      // Update the remainder.
      if (r.numberAtLikeJsTest(0) && cmp != null && cmp != 0) {
        if (r.elementAtOrNull(rl) == null) {
          r.add(a.elementAtOrNull(ai) ?? 0);
        } else {
          r[rl] = a.elementAtOrNull(ai) ?? 0;
        }
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
      round(q, p, RoundingMode.values[rm], more: r.firstOrNull != null);
    }

    return q;
  }

  /// Return true if the value of this Big is equal to the value of Big y, otherwise return false.
  bool eq(Big y) {
    return cmp(y) == 0;
  }

  /// Return true if the value of this Big is greater than the value of Big y, otherwise return
  /// false.
  bool gt(Big y) {
    return cmp(y) > 0;
  }

  /// Return true if the value of this Big is greater than or equal to the value of Big y, otherwise
  /// return false.
  bool gte(Big y) {
    return cmp(y) > -1;
  }

  /// Return true if the value of this Big is less than the value of Big y, otherwise return false.
  bool lt(Big y) {
    return cmp(y) < 0;
  }

  ///  Return true if the value of this Big is less than or equal to the value of Big y, otherwise
  ///  return false.
  bool lte(Big y) {
    return cmp(y) < 1;
  }

  /// Return a new Big whose value is the value of this Big minus the value of Big y.
  Big sub(Big y) {
    y = Big(y);
    int i, j;
    List<int> t;
    var xlty, x = this, a = x.s, b = y.s;
    // Signs differ?
    if (a != b) {
      y.s = -b;
      return x.add(y);
    }

    var xc = [...x.c], xe = x.e, yc = y.c, ye = y.e;

    // Either zero?
    if (!xc.numberAtLikeJsTest(0) || !yc.numberAtLikeJsTest(0)) {
      if (yc.numberAtLikeJsTest(0)) {
        y.s = -b;
      } else if (xc.numberAtLikeJsTest(0)) {
        y = Big(x);
      } else {
        y.s = 1;
      }
      return y;
    }

    a = xe - ye;
    // Determine which is the bigger number. Prepend zeros to equalise exponents.
    if (a != 0) {
      if (xlty = a < 0) {
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
      j = ((xlty = xc.length < yc.length) ? xc : yc).length;

      for (a = b = 0; b < j; b++) {
        if (xc[b] != yc[b]) {
          xlty = xc[b] < yc[b];
          break;
        }
      }
    }

    // x < y? Point xc to the array of the bigger number.
    if (xlty) {
      t = xc;
      xc = yc;
      yc = t;
      y.s = -y.s;
    }

    /*
       * Append zeros to xc if shorter. No need to add zeros to yc if shorter as subtraction only
       * needs to start at yc.length.
       */
    if ((b = (j = yc.length) - (i = xc.length)) > 0) {
      for (; b > 0;) {
        b--;
        i++;
        if (xc.elementAtOrNull(i) != null) {
          xc[i] = 0;
        } else {
          xc.add(0);
        }
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
      y.s = 1;

      // Result must be zero.
      xc = [ye = 0];
    }

    y.c = xc;
    y.e = ye;

    return y;
  }

  /*
     * Return a new Big whose value is the value of this Big modulo the value of Big y.
     */
  Big mod(Big y) {
    bool ygtx;
    y = Big(y);
    var x = this, a = x.s, b = y.s;

    if (!y.c.numberAtLikeJsTest(0)) {
      throw BigError(code: BigErrorCode.divByZero, description: divByZero);
    }

    x.s = y.s = 1;
    ygtx = y.cmp(x) == 1;
    x.s = a;
    y.s = b;
    if (ygtx) return Big(x);

    a = dp;
    b = rm;
    dp = rm = 0;
    x = x.div(y);
    dp = a;
    rm = b;
    return sub(x.times(y));
  }

  /// Return a new Big whose value is the value of this Big plus the value of Big y.
  Big add(Big y) {
    int e, k;
    List<int> t;
    Big x = this;
    y = Big(y);

    // Signs differ?
    if (x.s != y.s) {
      y.s = -y.s;
      return x.sub(y);
    }

    var xe = x.e, xc = x.c, ye = y.e, yc = y.c;
    // Either zero?
    if (!xc.numberAtLikeJsTest(0) || !yc.numberAtLikeJsTest(0)) {
      if (!yc.numberAtLikeJsTest(0)) {
        if (xc.numberAtLikeJsTest(0)) {
          y = Big(x);
        } else {
          y.s = x.s;
        }
      }
      return y;
    }
    xc = [...xc];

    // Prepend zeros to equalise exponents.
    // Note: reverse faster than unshifts.
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

    y.c = xc;
    y.e = ye;

    return y;
  }

  /// Return a Big whose value is the value of this Big raised to the power n.
  /// If n is negative, round to a maximum of Big.DP decimal places using rounding
  /// mode Big.RM.
  /// n {number} Integer, -MAX_POWER to MAX_POWER inclusive.
  Big pow(int n) {
    var x = this, one = Big('1'), y = one, isneg = n < 0;

    if (n != ~~n || n < -maxPower || n > maxPower) {
      throw BigError(code: BigErrorCode.pow, description: invalid + 'exponent');
    }

    if (isneg) n = -n;

    for (;;) {
      if ((n & 1) != 0) y = y.times(x);
      n >>= 1;
      if (n == 0) break;
      x = x.times(x);
    }

    return isneg ? one.div(y) : y;
  }

  /// Return a new Big whose value is the value of this Big times the value of Big y.
  Big times(Big y) {
    List<int> c;
    y = Big(y);
    var x = this,
        xc = x.c,
        yc = y.c,
        a = xc.length,
        b = yc.length,
        i = x.e,
        j = y.e;

    // Determine sign of result.
    y.s = x.s == y.s ? 1 : -1;

    // Return signed 0 if either 0.
    if (!xc.numberAtLikeJsTest(0) || !yc.numberAtLikeJsTest(0)) {
      y.c = [y.e = 0];
      return y;
    }

    // Initialize exponent of result as x.e + y.e.
    y.e = i + j;

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
      ++y.e;
    } else {
      c.removeAt(0);
    }

    // Remove trailing zeros.
    for (i = c.length; !c.numberAtLikeJsTest(--i);) {
      c.removeLast();
    }

    y.c = c;
    return y;
  }

  /// Return a string representing the value of this Big in exponential notation rounded to dp fixed
  /// decimal places using rounding mode rm, or Big.RM if rm is not specified.

  /// dp? {number} Decimal places: integer, 0 to MAX_DP inclusive.
  /// rm? {number} Rounding mode: 0 (down), 1 (half-up), 2 (half-even) or 3 (up).
  String toExponential({int? dp, RoundingMode? rm}) {
    var x = this, n = x.c[0];

    if (dp != null) {
      if (dp != ~~dp || dp < 0 || dp > maxDp) {
        throw BigError(code: BigErrorCode.dp, description: invalidDp);
      }
      x = round(Big(x), ++dp, rm);
      for (; x.c.length < dp;) {
        x.c.add(0);
      }
    }

    return stringify(x, true, n != 0);
  }

  /*
     * Return a string representing the value of this Big in normal notation rounded to dp fixed
     * decimal places using rounding mode rm, or Big.RM if rm is not specified.
     *
     * dp? {number} Decimal places: integer, 0 to MAX_DP inclusive.
     * rm? {number} Rounding mode: 0 (down), 1 (half-up), 2 (half-even) or 3 (up).
     *
     * (-0).toFixed(0) is '0', but (-0.1).toFixed(0) is '-0'.
     * (-0).toFixed(1) is '0.0', but (-0.01).toFixed(1) is '-0.0'.
     */
  String toFixed({int? dp, RoundingMode? rm}) {
    var x = this, n = x.c[0];

    if (dp != null) {
      if (dp != ~~dp || dp < 0 || dp > maxDp) {
        throw BigError(code: BigErrorCode.dp, description: invalidDp);
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
        description: name + 'Imprecise conversion',
        code: BigErrorCode.type,
      );
    }
    return n;
  }

  /// Return a string representing the value of this Big rounded to sd significant digits using
  /// rounding mode rm, or Big.RM if rm is not specified.
  /// Use exponential notation if sd is less than the number of digits necessary to represent
  /// the integer part of the value in normal notation.
  /// sd {number} Significant digits: integer, 1 to MAX_DP inclusive.
  /// rm? {number} Rounding mode: 0 (down), 1 (half-up), 2 (half-even) or 3 (up).

  String toPrecision(int sd, RoundingMode? rm) {
    var x = this, n = x.c[0];

    if (sd != ~~sd || sd < 1 || sd > maxDp) {
      throw BigError(
        description: invalid + 'precision',
        code: BigErrorCode.sd,
      );
    }
    x = round(Big(x), sd, rm);
    for (; x.c.length < sd;) {
      x.c.add(0);
    }

    return stringify(x, sd <= x.e || x.e <= ne || x.e >= pe, n != 0);
  }

  /// Return a string representing the value of this Big.
  /// Return exponential notation if this Big has a positive exponent equal to or greater than
  /// Big.PE, or a negative exponent equal to or less than Big.NE.
  /// Include the sign for negative zero.
  valueOf() {
    var x = this;

    /// TODO:
    // if (Big.strict == true) {
    //   throw Error(NAME + 'valueOf disallowed');
    // }
    return stringify(x, x.e <= ne || x.e >= pe, true);
  }

  @override
  List<Object?> get props => [c, e, s];
}

extension BigDynamic on dynamic {
  Big get toBig => Big(this);
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
