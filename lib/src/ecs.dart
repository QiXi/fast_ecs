import '../fast_ecs.dart';
import 'component.dart';
import 'component_manager.dart';
import 'entity_manager.dart';
import 'object_manager.dart';
import 'system.dart';
import 'system_manager.dart';
import 'types.dart';

class Ecs {
  final int maxEntity;
  final int maxComponents;
  final int maxSystems;
  final ComponentManager componentManager;
  final EntityManager entityManager;
  final SystemManager systemManager;
  final ObjectManager objectManager;

  Ecs({this.maxEntity = 1024, this.maxComponents = 32, this.maxSystems = 16})
      : componentManager = ComponentManager(maxComponents),
        entityManager = EntityManager(maxEntity),
        systemManager = SystemManager(maxSystems, maxEntity),
        objectManager = ObjectManager();

  SystemId registerSystem<T extends EcsSystem>(T Function() creator,
      {Signature signature = 0, required SystemPhases phase}) {
    var system = creator();
    var systemId = systemManager.register<T>(system, phase);
    systemManager.setSignature(systemId, signature);
    system.register(this, signature);
    return systemId;
  }

  void init() {
    systemManager.init();
  }

  void enableSystem(SystemId systemId, SystemPhases phase) {
    systemManager.enable(systemId, phase.index);
  }

  void disableSystem(SystemId systemId) {
    systemManager.disable(systemId);
  }

  Entity createEntity() {
    return entityManager.createEntity();
  }

  void destroyEntity(Entity entity) {
    var signature = entityManager.getSignature(entity);
    var isAlive = (signature & 1 << aliveComponentId) == 1;
    if (isAlive) {
      entityManager.destroyEntity(entity);
      componentManager.entityDestroyed(entity, signature);
      systemManager.entityDestroyed(entity);
    }
  }

  ComponentId registerComponent<T extends Component>(T Function(int index) creator, int capacity) {
    return componentManager.register<T>(creator, capacity);
  }

  bool hasComponent(ComponentId id, Entity entity) {
    var signature = entityManager.getSignature(entity);
    return containsComponentId(signature, id);
  }

  bool containsComponentId(Signature signature, ComponentId id) {
    return (signature & 1 << id) > 0;
  }

  ComponentId findComponentId<T extends Component>() {
    return componentManager.getComponentId<T>();
  }

  ComponentArray<T> getComponentArray<T extends Component>() {
    return componentManager.getComponentArray<T>();
  }

  List<T> getComponentList<T extends Component>() {
    return componentManager.getComponentList<T>();
  }

  void addComponent(ComponentId id, Entity entity) {
    final signature = entityManager.getSignature(entity);
    if (!containsComponentId(signature, id)) {
      componentManager.addComponent(id, entity);
      var newSignature = signature | 1 << id; // enable
      entityManager.setSignature(entity, newSignature);
      systemManager.entitySignatureChanged(entity, signature, newSignature);
    } else {
      print('Component added to same entity more than once.');
    }
  }

  void addComponents(List<ComponentId> ids, Entity entity) {
    final signature = entityManager.getSignature(entity);
    var newSignature = signature;
    for (int i = 0, length = ids.length; i < length; i++) {
      var id = ids[i];
      if (!containsComponentId(signature, id)) {
        componentManager.addComponent(id, entity);
        newSignature |= 1 << id; // enable
      }
    }
    entityManager.setSignature(entity, newSignature);
    systemManager.entitySignatureChanged(entity, signature, newSignature);
  }

  void removeComponent(ComponentId id, Entity entity) {
    var signature = entityManager.getSignature(entity);
    if (containsComponentId(signature, id)) {
      componentManager.removeComponent(id, entity);
      var newSignature = signature ^ 1 << id; // disable
      entityManager.setSignature(entity, newSignature);
      systemManager.entitySignatureChanged(entity, signature, newSignature);
    } else {
      print('Removing non-existent component.');
    }
  }

  Signature createSignature(List<ComponentId> list) {
    Signature signature = 1 << aliveComponentId;
    for (int i = 0, length = list.length; i < length; i++) {
      signature |= 1 << list[i]; //enable
    }
    return signature;
  }

  void update(double deltaTime) {
    final systems = systemManager.systems;
    final activeSystems = systemManager.systemSet;
    for (int i = 0, size = activeSystems.size; i < size; i++) {
      var systemId = activeSystems[i];
      var system = systems[systemId];
      if (system is UpdateEcsSystem) {
        system.update(deltaTime, systemManager.systemEntities[systemId]);
      }
    }
  }

  void forEach(void Function(EcsSystem element, EntitySet entities) action) {
    final systems = systemManager.systems;
    final activeSystems = systemManager.systemSet;
    for (int i = 0, size = activeSystems.size; i < size; i++) {
      var systemId = activeSystems[i];
      action(systems[systemId], systemManager.systemEntities[systemId]);
    }
  }

  int registerObject<T>(T Function(int index) generator, int capacity) {
    return objectManager.register<T>(generator, capacity);
  }

  T getObject<T>() {
    return objectManager.getObject<T>();
  }

  List<T> getObjectList<T>() {
    return objectManager.getObjectList<T>();
  }

  @override
  String toString() {
    return 'Ecs{ maxEntity:$maxEntity maxComponents:$maxComponents'
        ' $componentManager $entityManager $systemManager}';
  }
}
