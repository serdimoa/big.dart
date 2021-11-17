int unShift<T>(List<T> list, item) {
  list.insert(0, item);
  return list.length;
}

extension ListEx<T> on List<T> {
  void reverse() {
    for (var i = 0; i < length / 2; i++) {
      var tempValue = elementAt(i);
      this[i] = elementAt(length - 1 - i);
      this[length - 1 - i] = tempValue;
    }
  }

  List<T> slice(int begin, int end) {
    int nextEnd;

    if (end > length) {
      nextEnd = length;
    } else {
      nextEnd = end;
    }

    return getRange(begin, nextEnd < 0 ? length + nextEnd : nextEnd).toList();
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
