/*
     * Return a string representing the value of Big x in normal or exponential notation.
     * Handles P.toExponential, P.toFixed, P.toJSON, P.toPrecision, P.toString and P.valueOf.
     */
import 'package:big_dart/src/big_dart.dart';

String stringify(Big x, bool doExponential, bool isNonzero) {
  var e = x.e, s = x.c.join(''), n = s.length;

  // Exponential notation?
  if (doExponential) {
    s = s[0] +
        (n > 1 ? '.' + s.substring(1) : '') +
        (e < 0 ? 'e' : 'e+') +
        e.toString();

    // Normal notation.
  } else if (e < 0) {
    for (; ++e < 0;) {
      s = '0' + s;
    }
    s = '0.' + s;
  } else if (e > 0) {
    if (++e > n) {
      for (e -= n; e-- > 0;) {
        s += '0';
      }
    } else if (e < n) {
      s = s.substring(0, e) + '.' + s.substring(e);
    }
  } else if (n > 1) {
    s = s[0] + '.' + s.substring(1);
  }

  return x.s < 0 && isNonzero ? '-' + s : s;
}
