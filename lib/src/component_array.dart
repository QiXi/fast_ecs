import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'component.dart';
import 'types.dart';

class ComponentArray<T extends Component> {
  final int capacity;
  final List<T> data;
  final Uint16List entityToIndexList;
  final Uint16List indexToEntityList;
  int _nextIndex = 0;

  ComponentArray(this.capacity, T Function(int index) creator)
      : data = List.generate(capacity, (index) => creator(index), growable: false),
        entityToIndexList = Uint16List(capacity),
        indexToEntityList = Uint16List(capacity);

  int get size => _nextIndex;

  T? getComponent(Entity entity) {
    assert(entity < size, 'Entity out of range.');
    return data[entityToIndexList[entity]];
  }

  void add(Entity entity) {
    assert(_nextIndex < capacity, 'Too many entities in existence.');
    var newIndex = _nextIndex;
    entityToIndexList[entity] = newIndex;
    indexToEntityList[newIndex] = entity;
    _nextIndex++;
  }

  void remove(Entity entity) {
    assert(entity < size, 'Entity out of range.');
    var indexOfRemovedEntity = entityToIndexList[entity];
    var indexOfLastElement = _nextIndex - 1;
    var removedComponent = data[indexOfRemovedEntity];
    data[indexOfRemovedEntity] = data[indexOfLastElement];
    data[indexOfLastElement] = removedComponent;
    Entity entityOfLastElement = indexToEntityList[indexOfLastElement];
    entityToIndexList[entityOfLastElement] = indexOfRemovedEntity;
    indexToEntityList[indexOfRemovedEntity] = entityOfLastElement;
    _nextIndex--;
  }

  @internal
  void entityDestroyed(Entity entity) {
    if (entity < _nextIndex) {
      remove(entity);
    }
  }

  @override
  String toString() {
    return 'ComponentArray{capacity:$capacity size:$size}';
  }
}
