import 'component.dart';
import 'component_manager.dart';
import 'entity_manager.dart';
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

  Ecs({this.maxEntity = 1024, this.maxComponents = 32, this.maxSystems = 16})
      : componentManager = ComponentManager(maxComponents),
        entityManager = EntityManager(maxEntity),
        systemManager = SystemManager(maxSystems, maxEntity);

  SystemId registerSystem<T extends EcsSystem>(T Function() creator, {Signature signature = 0}) {
    var system = creator();
    var systemId = systemManager.register<T>(system);
    systemManager.setSystemSignature(systemId, signature);
    system.init(this, signature);
    return systemId;
  }

  Entity createEntity() {
    return entityManager.createEntity();
  }

  void destroyEntity(Entity entity) {
    var signature = entityManager.getSignature(entity);
    entityManager.destroyEntity(entity);
    componentManager.entityDestroyed(entity, signature);
    systemManager.entityDestroyed(entity);
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

  List<Component> getComponentList<T extends Component>() {
    var id = findComponentId<T>();
    return componentManager.getArray(id).data;
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

  void addComponents(List<ComponentId> list, Entity entity) {
    final signature = entityManager.getSignature(entity);
    var newSignature = signature;
    for (int i = 0; i < list.length; i++) {
      var id = list[i];
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
    Signature signature = 0;
    for (int i = 0; i < list.length; i++) {
      signature |= 1 << list[i]; //enable
    }
    return signature;
  }

  void update(double deltaTime) {
    var systems = systemManager.systems;
    for (int id = 0; id < systems.length; id++) {
      var system = systems[id];
      if (system is UpdateEcsSystem) {
        system.update(deltaTime, systemManager.systemEntities[id]);
      }
    }
  }

  void render() {
    var systems = systemManager.systems;
    for (int id = 0; id < systems.length; id++) {
      var system = systems[id];
      if (system is RenderEcsSystem) {
        system.render(systemManager.systemEntities[id]);
      }
    }
  }

  @override
  String toString() {
    return 'Ecs{$componentManager $entityManager $systemManager}';
  }
}
