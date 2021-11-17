A small library for arbitrary-precision decimal arithmetic inspired by [big.js](https://github.com/MikeMcl/big.js/)

[![Coverage Status](https://coveralls.io/repos/github/serdimoa/big.dart/badge.svg)](https://coveralls.io/github/serdimoa/big.dart)
![build](https://github.com/serdimoa/big.dart/workflows/big.dart/badge.svg)
[![style: dart lint recommended](https://img.shields.io/badge/style-lints_recommended-40c4ff.svg)](https://pub.dev/packages/lints)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)


## Features

- Simple API
- Easier-to-use
- Replicates the `toStringAsExponential`, `toStringAsFixed` and `toStringAsPrecision` methods of Dart Numbers
- Stores values in an accessible decimal floating point format
- Comprehensive [documentation](https://mikemcl.github.io/big.js/) and test set
- Uses only Dart, so works in well where Dart work


## Use

*In the code examples below, semicolons and `toString` calls are not shown.*

The library exports a some Extensions for `String`, `double`, `int`, `Big`.

A Big number is created from a primitive `number`, `String`, or other `Big` number.

```dart
var x = Big(123.4567)
var y = Big('123456.7e-3')
var z = Big(x)
x.eq(y) && x.eq(z) && y.eq(z)          // true
```

In Big strict mode, creating a Big number from a primitive number is disallowed.

```dart
Big.strict = true
x = Big(1)                         // BigError(code: BigErrorCode.invalidNumber)
y = Big('1.0000000000000001')
y.toNumber()                       // BigError(code: BigErrorCode.impreciseConversion)
```

A Big number is immutable in the sense that it is not changed by its methods.

```dart
0.3 - 0.1                              // 0.19999999999999998
x = Big(0.3)
x.sub(0.1)                             // "0.2"
x-0.1                                  // Big(0.2)
x                                      // "0.3"
```

The methods that return a Big number can be chained.

```dart
x.div(y).add(z).times(9).sub('1.234567801234567e+8').add(976.54321).div('2598.11772')
x.sqrt().div(y).pow(3).gt(y.mod(z))    // true
```

Like JavaScript's Number type, there are `toStringAsExponential`, `toStringAsFixed` and `toStringAsPrecision` methods.

```dart
x = Big(255.5)
x.toStringAsExponential(5)                     // "2.55500e+2"
x.toStringAsFixed(5)                           // "255.50000"
x.toStringAsPrecision(5)                       // "255.50"
```

The arithmetic methods always return the exact result except `div`, `sqrt` and `pow`
(with negative exponent), as these methods involve division.

The maximum number of decimal places and the rounding mode used to round the results of these methods is determined by the value of the `dp` and `rm` properties of the `Big` number constructor.

```dart
Big.dp = 10
Big.rm = RoundingMode.roundHalfUp
x = Big(2);
y = Big(3);
z = x.div(y)                           // "0.6666666667"
z.sqrt()                               // "0.8164965809"
z.pow(-3)                              // "3.3749999995"
z.times(z)                             // "0.44444444448888888889"
z.times(z).round(10)                   // "0.4444444445"
```

The value of a Big number is stored in a decimal floating point format in terms of a coefficient, exponent and sign.

```dart
x = Big(-123.456);
x.c                                    // [1,2,3,4,5,6]    coefficient (i.e. significand)
x.e                                    // 2                exponent
x.s                                    // -1               sign
```




