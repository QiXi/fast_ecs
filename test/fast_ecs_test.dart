import 'package:fast_ecs/fast_ecs.dart';
import 'package:test/test.dart';

void main() {
  int maxEntity = 10;
  late Ecs ecs;
  ComponentId component1Id = -1;
  ComponentId component2Id = -1;

  group('register', () {
    setUp(() {
      ecs = Ecs(maxEntity: 10);
    });

    test('Components', () {
      expect(ecs.componentManager.size, 1); // AliveComponent
      component1Id = ecs.registerComponent<Component1>((int index) => Component1(), 32);
      expect(component1Id, 1);
      expect(ecs.componentManager.size, 2);
      component2Id = ecs.registerComponent<Component2>((int index) => Component2(), 32);
      expect(component2Id, 2);
      expect(ecs.componentManager.size, 3);
    });

    test('Systems', () {
      ecs.registerComponent<Component1>((int index) => Component1(), 32);
      ecs.registerComponent<Component2>((int index) => Component2(), 32);
      //
      expect(ecs.systemManager.size, 0);
      var system1Id = ecs.registerSystem<System1>(() => System1());
      expect(ecs.systemManager.size, 1);
      expect(ecs.systemManager.getSignature(system1Id), 0); //0000
      //
      var signature = ecs.createSignature([component1Id, component2Id]);
      var system2Id = ecs.registerSystem<System2>(() => System2(), signature: signature);
      expect(ecs.systemManager.size, 2);
      expect(ecs.systemManager.getSignature(system2Id), 7); //0111
    });
  });

  group('ECS', () {
    setUp(() {
      ecs = Ecs(maxEntity: maxEntity);
      component1Id = ecs.registerComponent<Component1>((int index) => Component1(), 32);
      component2Id = ecs.registerComponent<Component2>((int index) => Component2(), 32);
    });

    test('createEntity', () {
      Entity entity = ecs.createEntity();
      expect(entity, 0);
      expect(ecs.entityManager.size, 1);
      //
      Entity entity2 = ecs.createEntity();
      expect(entity2, 1);
      expect(ecs.entityManager.size, 2);
    });

    test('destroyEntity', () {
      Entity entity1 = ecs.createEntity();
      Entity entity2 = ecs.createEntity();
      expect(ecs.entityManager.size, 2);
      expect(ecs.entityManager.availableEntities.contains(entity1), false);
      expect(ecs.entityManager.availableEntities.contains(entity2), false);
      expect(ecs.entityManager.availableEntities.length, maxEntity - 2);
      //
      ecs.destroyEntity(entity1);
      expect(ecs.entityManager.size, 1);
      expect(ecs.entityManager.availableEntities.contains(entity1), true);
      expect(ecs.entityManager.availableEntities.length, maxEntity - 1);
      ecs.destroyEntity(entity2);
      expect(ecs.entityManager.size, 0);
      expect(ecs.entityManager.availableEntities.contains(entity2), true);
      expect(ecs.entityManager.availableEntities.length, maxEntity);
      //
      ecs.destroyEntity(entity2);
      expect(ecs.entityManager.size, 0);
      expect(ecs.entityManager.availableEntities.contains(entity2), true);
      expect(ecs.entityManager.availableEntities.length, maxEntity);
    });

    test('addComponent', () {
      Entity entity = ecs.createEntity();
      expect(ecs.hasComponent(component1Id, entity), false);
      expect(ecs.hasComponent(component2Id, entity), false);

      ecs.addComponent(component1Id, entity);
      expect(ecs.hasComponent(component1Id, entity), true);
      expect(ecs.componentManager.getArray(component1Id).size, 1);
      //
      ecs.addComponent(component2Id, entity);
      expect(ecs.hasComponent(component2Id, entity), true);
      expect(ecs.componentManager.getArray(component2Id).size, 1);
    });

    test('addComponents', () {
      Entity entity = ecs.createEntity();
      ecs.addComponents([component1Id, component2Id], entity);
      expect(ecs.hasComponent(component1Id, entity), true);
      expect(ecs.hasComponent(component2Id, entity), true);
      expect(ecs.componentManager.getArray(component1Id).size, 1);
      expect(ecs.componentManager.getArray(component2Id).size, 1);
    });

    test('removeComponent', () {
      Entity entity = ecs.createEntity();
      ecs.addComponent(component1Id, entity);
      ecs.addComponent(component2Id, entity);
      expect(ecs.hasComponent(component1Id, entity), true);
      expect(ecs.hasComponent(component2Id, entity), true);

      ecs.removeComponent(component1Id, entity);
      expect(ecs.hasComponent(component1Id, entity), false);
      expect(ecs.componentManager.getArray(component1Id).size, 0);

      ecs.removeComponent(component2Id, entity);
      expect(ecs.hasComponent(component2Id, entity), false);
      expect(ecs.componentManager.getArray(component2Id).size, 0);
    });

    test('getSignature', () {
      Entity entity = ecs.createEntity();
      expect(ecs.entityManager.getSignature(entity), 1); //0001
      ecs.addComponent(component1Id, entity);
      expect(ecs.entityManager.getSignature(entity), 3); //0011
      ecs.addComponent(component2Id, entity);
      expect(ecs.entityManager.getSignature(entity), 7); //0111

      ecs.removeComponent(component1Id, entity);
      expect(ecs.entityManager.getSignature(entity), 5); //0101
      ecs.removeComponent(component2Id, entity);
      expect(ecs.entityManager.getSignature(entity), 1); //0001
    });
  });
}

class Component1 extends Component {}

class Component2 extends Component {}

class System1 extends UpdateEcsSystem {
  @override
  void init(Ecs ecs, Signature signature) {}

  @override
  void update(double deltaTime, SetEntity entities) {}
}

class System2 extends EcsSystem {
  @override
  void init(Ecs ecs, Signature signature) {}
}
