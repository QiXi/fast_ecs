import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'types.dart';

class SetEntity {
  final int capacity;
  final Uint16List indexByEntity;
  final Uint16List entityByIndex;
  int _nextIndex = 0;

  SetEntity(this.capacity)
      : indexByEntity = Uint16List(capacity),
        entityByIndex = Uint16List(capacity);

  int get size => _nextIndex;

  void clear() {
    _nextIndex = 0;
  }

  operator [](int index) => entityByIndex[index];

  Entity get(int index) => entityByIndex[index];

  @internal
  void add(Entity entity) {
    var newIndex = _nextIndex;
    indexByEntity[entity] = newIndex;
    entityByIndex[newIndex] = entity;
    _nextIndex++;
  }

  @internal
  void remove(Entity entity) {
    var indexOfRemovedEntity = indexByEntity[entity];
    var indexOfLastElement = _nextIndex - 1;
    Entity entityOfLastElement = entityByIndex[indexOfLastElement];
    indexByEntity[entityOfLastElement] = indexOfRemovedEntity;
    entityByIndex[indexOfRemovedEntity] = entityOfLastElement;
    _nextIndex--;
  }

  @override
  String toString() {
    return 'SetEntity{ size:$size capacity:$capacity ${entityByIndex.sublist(0, size)}}';
  }
}
