import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'set.dart';
import 'system.dart';
import 'system_set.dart';
import 'types.dart';

class SystemManager {
  final int capacity;
  final int maxEntities;
  final List<EcsSystem> systems = [];
  final Uint64List signatures;
  final SystemSet systemSet;
  final List<Uint16Set> systemEntities = [];
  final List<Type> registerTypes = []; //helper
  SystemId _nextIndex = 0;

  SystemManager(this.capacity, this.maxEntities)
      : signatures = Uint64List(capacity),
        systemSet = SystemSet(capacity);

  int get size => systems.length;

  SystemId register<T extends EcsSystem>(EcsSystem system, SystemPhases phase) {
    assert(_nextIndex < capacity, 'Too many systems in existence.');
    assert(!registerTypes.contains(T), 'Registering system more than once.');
    systems.add(system);
    var systemId = _nextIndex;
    registerTypes.add(T);
    systemEntities.add(Uint16Set(maxEntities));
    systemSet.add(systemId, phase.index);
    _nextIndex++;
    return systemId;
  }

  void init() {
    for (int i = 0, size = systemSet.size; i < size; i++) {
      var systemId = systemSet[i];
      print('init: systemId:$systemId ${systems[systemId]}');
      systems[systemId].init();
    }
  }

  void enable(SystemId systemId, PhaseIndex phase) {
    systemSet.add(systemId, phase);
  }

  void disable(SystemId systemId) {
    systemSet.remove(systemId);
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
    for (var id = 0, length = systemEntities.length; id < length; id++) {
      systemEntities[id].remove(entity);
    }
  }

  @internal
  void entitySignatureChanged(Entity entity, Signature oldSignature, Signature newSignature) {
    for (var systemId = 0, length = size; systemId < length; systemId++) {
      var systemSignature = signatures[systemId];
      var prevAdded = (oldSignature & systemSignature) == systemSignature;
      var nextAdded = (newSignature & systemSignature) == systemSignature;
      if (!prevAdded && nextAdded) {
        systemEntities[systemId].add(entity);
      } else if (prevAdded && !nextAdded) {
        systemEntities[systemId].remove(entity);
      }
    }
  }

  @override
  String toString() {
    return 'SystemManager{ size:$size capacity:$capacity systems:$systems}';
  }
}
