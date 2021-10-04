import 'dart:collection';
import 'dart:typed_data';

import 'types.dart';

class EntityManager {
  final int capacity;
  final Queue<Entity> availableEntities;
  final Uint64List signatures;
  Entity _nextIndex = 0;

  EntityManager(this.capacity)
      : availableEntities = Queue.from(List.generate(capacity, (index) => index, growable: false)),
        signatures = Uint64List(capacity);

  int get size => _nextIndex;

  Entity createEntity() {
    assert(_nextIndex < capacity, 'Too many entities in existence.');
    Entity id = availableEntities.removeFirst();
    _nextIndex++;
    return id;
  }

  void destroyEntity(Entity entity) {
    assert(entity < size, 'Entity out of range.');
    availableEntities.addLast(entity);
    signatures[entity] = 0; // disable
    _nextIndex--;
  }

  Signature getSignature(Entity entity) {
    assert(entity < size, 'Entity out of range.');
    return signatures[entity];
  }

  void setSignature(Entity entity, Signature signature) {
    assert(entity < size, 'Entity out of range.');
    signatures[entity] = signature;
  }

  @override
  String toString() {
    return 'EntityManager{capacity:$capacity size:$size}';
  }
}
