import 'package:big/src/big.dart';
import 'package:big/src/common.dart';
import 'package:big/src/utils.dart';

/*
     * Round Big x to a maximum of sd significant digits using rounding mode rm.
     *
     * x {Big} The Big to round.
     * sd {number} Significant digits: integer, 0 to MAX_DP inclusive.
     * rm {number} Rounding mode: 0 (down), 1 (half-up), 2 (half-even) or 3 (up).
     * [more] {boolean} Whether the result of division was truncated.
     */
Big round(Big x, int sd, RoundingMode? rm, {bool more = false}) {
  var xc = x.c;
  rm ??= x.RM;

  if (sd < 1) {
    more = rm == RoundingMode.roundUp && (more || xc.numberAtLikeJsTest(0)) ||
        sd == 0 &&
            (rm == RoundingMode.roundHalfUp && (xc.firstOrNull ?? 0) >= 5 ||
                rm == RoundingMode.roundHalfEven &&
                    ((xc.firstOrNull ?? 0) > 5 ||
                        xc.firstOrNull == 5 &&
                            (more || xc.numberAtLikeJsTest(2))));

    xc.length = 1;

    if (more) {
      // 1, 0.1, 0.01, 0.001, 0.0001 etc.
      x.e = x.e - sd + 1;
      xc[0] = 1;
    } else {
      // Zero.
      xc[0] = x.e = 0;
    }
  } else if (sd < xc.length) {
    // xc[sd] is the digit after the digit that may be rounded up.
    switch (rm) {
      case RoundingMode.roundDown:
        more = false;
        break;
      case RoundingMode.roundHalfUp:
        more = xc.elementAt(sd) >= 5;
        break;
      case RoundingMode.roundHalfEven:
        if (xc.elementAt(sd) > 5) {
          more = true;
        } else {
          if (xc.elementAt(sd) == 5) {
            if (more == false) {
              more = xc.elementAtOrNull(sd + 1) != null ||
                  (xc.elementAt(sd - 1) & 1) != 0;
            }
          } else {
            more = false;
          }
        }
        break;
      case RoundingMode.roundUp:
        more = (more || xc.numberAtLikeJsTest(0));
        break;
    }

    // Remove any digits after the required precision.
    xc.length = sd--;
    // Round up?
    if (more) {
      // Rounding up may mean the previous digit has to be rounded up.
      for (; (++xc[sd]) > 9;) {
        xc[sd] = 0;
        if (sd-- == 0) {
          ++x.e;
          unShift(xc, 1);

          if (sd == -1) {
            break;
          }
        }
      }
    }

    // Remove trailing zeros.
    for (sd = xc.length; !xc.numberAtLikeJsTest(--sd);) {
      xc.removeLast();
    }
  }

  return x;
}
