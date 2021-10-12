import 'package:meta/meta.dart';

import 'component.dart';
import 'component_array.dart';
import 'types.dart';

class ComponentManager {
  final int defaultCapacity;
  final List<ComponentArray> componentArrays = [];
  final List<Type> registerTypes = [];
  ComponentId _nextIndex = 0;

  ComponentManager(this.defaultCapacity) {
    register((index) => AliveComponent(), 0);
  }

  int get size => registerTypes.length;

  ComponentId register<T extends Component>(T Function(int index) creator, [int? capacity]) {
    assert(!registerTypes.contains(T), 'Registering component type more than once.');
    var index = _nextIndex;
    componentArrays.add(ComponentArray<T>(capacity ?? defaultCapacity, creator));
    registerTypes.add(T);
    _nextIndex++;
    return index;
  }

  ComponentId getComponentId<T extends Component>() {
    assert(registerTypes.contains(T), '$T not registered before use.');
    return registerTypes.indexOf(T);
  }

  ComponentArray<T> getComponentArray<T extends Component>() {
    var id = getComponentId<T>();
    return componentArrays[id] as ComponentArray<T>;
  }

  ComponentId getComponentIdFrom(Type type) {
    assert(registerTypes.contains(type), '$type not registered before use.');
    return registerTypes.indexOf(type);
  }

  List<ComponentId> getComponentIdList(List<Type> components) {
    List<ComponentId> result = [];
    for (var i = 0, length = components.length; i < length; i++) {
      Type type = components[i];
      result.add(registerTypes.indexOf(type));
    }
    return result;
  }

  ComponentArray getArray(ComponentId id) {
    assert(id < size, 'Component not registered before use.');
    return componentArrays[id];
  }

  Component? getComponent(ComponentId id, Entity entity) {
    return getArray(id).get(entity);
  }

  void addComponent(ComponentId id, Entity entity) {
    getArray(id).add(entity);
  }

  void removeComponent(ComponentId id, Entity entity) {
    getArray(id).remove(entity);
  }

  @internal
  void entityDestroyed(Entity entity, Signature signature) {
    for (var id = 0; id < size; id++) {
      if (signature & 1 << id == 1) {
        getArray(id).entityDestroyed(entity);
      }
    }
  }

  @override
  String toString() {
    return 'ComponentManager{size:$size $registerTypes}';
  }
}

class AliveComponent extends Component {}
