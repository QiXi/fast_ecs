import 'dart:typed_data';

import 'package:meta/meta.dart';

class Uint16Set {
  final int capacity;
  final Uint16List indexByValue;
  final Uint16List valueByIndex;
  int _nextIndex = 0;

  Uint16Set(this.capacity)
      : indexByValue = Uint16List(capacity),
        valueByIndex = Uint16List(capacity);

  int get size => _nextIndex;

  bool get isEmpty => _nextIndex == 0;

  /// Removes all elements from the set.
  void clear() {
    _nextIndex = 0;
  }

  /// The object at the given [index] in the set.
  operator [](int index) => valueByIndex[index];

  /// The object at the given [index] in the set.
  int get(int index) => valueByIndex[index];

  int indexOf(int value) => indexByValue[value];

  /// Adds [value] to the set.
  @internal
  void add(int value) {
    var newIndex = _nextIndex;
    indexByValue[value] = newIndex;
    valueByIndex[newIndex] = value;
    _nextIndex++;
  }

  /// Removes [value] from the set.
  @internal
  void remove(int value) {
    var indexOfRemovedElement = indexByValue[value];
    var indexOfLastElement = _nextIndex - 1;
    int entityOfLastElement = valueByIndex[indexOfLastElement];
    indexByValue[entityOfLastElement] = indexOfRemovedElement;
    valueByIndex[indexOfRemovedElement] = entityOfLastElement;
    _nextIndex--;
  }

  @override
  String toString() {
    return 'Set{ size:$size capacity:$capacity ${valueByIndex.sublist(0, size)}}';
  }
}
