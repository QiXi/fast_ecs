import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'set_entity.dart';
import 'system.dart';
import 'types.dart';

class SystemManager {
  final int capacity;
  final int maxEntities;
  final List<EcsSystem> systems = [];
  final Uint64List signatures;
  final List<SetEntity> systemEntities = [];
  final List<Type> registerTypes = []; //helper
  SystemId _nextIndex = 0;

  SystemManager(this.capacity, this.maxEntities) : signatures = Uint64List(capacity);

  int get size => systems.length;

  SystemId register<T extends EcsSystem>(EcsSystem system) {
    assert(!registerTypes.contains(T), 'Registering system more than once.');
    systems.add(system);
    var index = _nextIndex;
    registerTypes.add(T);
    systemEntities.add(SetEntity(maxEntities));
    _nextIndex++;
    return index;
  }

  Signature getSignature(SystemId systemId) {
    assert(systemId < size, 'System out of range.');
    return signatures[systemId];
  }

  void setSignature(SystemId systemId, Signature signature) {
    assert(systemId < size, 'System out of range.');
    signatures[systemId] = signature;
  }

  @internal
  void entityDestroyed(Entity entity) {
    final length = systemEntities.length;
    for (var id = 0; id < length; id++) {
      systemEntities[id].remove(entity);
    }
  }

  @internal
  void entitySignatureChanged(
      Entity entity, Signature entityOldSignature, Signature entityNewSignature) {
    final length = systemEntities.length;
    for (var id = 0; id < length; id++) {
      var systemSignature = signatures[id];
      var prevAdded = (entityOldSignature & systemSignature) == systemSignature;
      var nextAdded = (entityNewSignature & systemSignature) == systemSignature;
      if (!prevAdded && nextAdded) {
        systemEntities[id].add(entity);
      } else if (prevAdded && !nextAdded) {
        systemEntities[id].remove(entity);
      }
    }
  }

  @override
  String toString() {
    return 'SystemManager{capacity:$capacity size:$size systems:$systems}';
  }
}
