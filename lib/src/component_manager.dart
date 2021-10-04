import 'component.dart';
import 'component_array.dart';
import 'types.dart';

class ComponentManager {
  final int defaultCapacity;
  final List<ComponentArray> componentArrays = [];
  final List<Type> registerTypes = [];
  ComponentId _nextComponentIndex = 0;

  ComponentManager(this.defaultCapacity);

  int get size => registerTypes.length;

  ComponentId register<T extends Component>(T Function(int index) creator, [int? capacity]) {
    assert(!registerTypes.contains(T), 'Registering component type more than once.');
    var index = _nextComponentIndex;
    componentArrays.add(ComponentArray<T>(capacity ?? defaultCapacity, creator));
    registerTypes.add(T);
    _nextComponentIndex++;
    return index;
  }

  ComponentId getComponentId<T extends Component>() {
    assert(registerTypes.contains(T), '$T not registered before use.');
    return registerTypes.indexOf(T);
  }

  ComponentArray getArray(ComponentId id) {
    assert(id < size, 'Component not registered before use.');
    return componentArrays[id];
  }

  Component? getComponent(ComponentId id, Entity entity) {
    return getArray(id).getComponent(entity);
  }

  void addComponent(ComponentId id, Entity entity) {
    getArray(id).add(entity);
  }

  void removeComponent(ComponentId id, Entity entity) {
    getArray(id).remove(entity);
  }

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