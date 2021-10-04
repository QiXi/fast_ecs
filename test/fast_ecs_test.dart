import 'package:fast_ecs/fast_ecs.dart';
import 'package:test/test.dart';

void main() {
  int maxEntity;
  late Ecs world;
  ComponentId component1Id = -1;
  ComponentId component2Id = -1;
  group('register', () {
    setUp(() {
      maxEntity = 10;
      world = Ecs(maxEntity: maxEntity);
    });

    test('Components', () {
      expect(world.componentManager.size, 0);
      component1Id = world.registerComponent<Component1>((int index) => Component1(), 32);
      expect(component1Id, 0);
      expect(world.componentManager.size, 1);
      component2Id = world.registerComponent<Component2>((int index) => Component2(), 32);
      expect(component2Id, 1);
      expect(world.componentManager.size, 2);
    });

    test('Systems', () {
      world.registerComponent<Component1>((int index) => Component1(), 32);
      world.registerComponent<Component2>((int index) => Component2(), 32);
      //
      expect(world.systemManager.size, 0);
      var system1Id = world.registerSystem<System1>(() => System1());
      expect(world.systemManager.size, 1);
      expect(world.systemManager.getSignature(system1Id), 0); //0000

      var signature = world.createSignature([component1Id, component2Id]);
      var system2Id = world.registerSystem<System2>(() => System2(), signature: signature);
      expect(world.systemManager.size, 2);
      expect(world.systemManager.getSignature(system2Id), 3); //0011
    });
  });

  group('ECS', () {
    setUp(() {
      maxEntity = 10;
      world = Ecs(maxEntity: maxEntity);
      component1Id = world.registerComponent<Component1>((int index) => Component1(), 32);
      component2Id = world.registerComponent<Component2>((int index) => Component2(), 32);
    });

    test('createEntity', () {
      expect(world.entityManager.size, 0);
      Entity entity = world.createEntity();
      expect(entity, 0);
      expect(world.entityManager.size, 1);
    });

    test('destroyEntity', () {
      Entity entity = world.createEntity();
      expect(world.entityManager.size, 1);
      world.destroyEntity(entity);
      expect(world.entityManager.size, 0);
    });

    test('addComponent', () {
      Entity entity = world.createEntity();
      expect(world.hasComponent(component1Id, entity), false);
      expect(world.hasComponent(component2Id, entity), false);

      world.addComponent(component1Id, entity);
      expect(world.hasComponent(component1Id, entity), true);
      expect(
          world.componentManager
              .getArray(
                component1Id,
              )
              .size,
          1);

      world.addComponent(component2Id, entity);
      expect(world.hasComponent(component2Id, entity), true);
      expect(world.componentManager.getArray(component2Id).size, 1);
    });

    test('removeComponent', () {
      Entity entity = world.createEntity();
      world.addComponent(component1Id, entity);
      world.addComponent(component2Id, entity);
      expect(world.hasComponent(component1Id, entity), true);
      expect(world.hasComponent(component2Id, entity), true);

      world.removeComponent(component1Id, entity);
      expect(world.hasComponent(component1Id, entity), false);
      expect(world.componentManager.getArray(component1Id).size, 0);

      world.removeComponent(component2Id, entity);
      expect(world.hasComponent(component2Id, entity), false);
      expect(world.componentManager.getArray(component2Id).size, 0);
    });

    test('getSignature', () {
      Entity entity = world.createEntity();
      expect(world.entityManager.getSignature(entity), 0); //0000
      world.addComponent(component1Id, entity);
      expect(world.entityManager.getSignature(entity), 1); //0001
      world.addComponent(component2Id, entity);
      expect(world.entityManager.getSignature(entity), 3); //0011

      world.removeComponent(component1Id, entity);
      expect(world.entityManager.getSignature(entity), 2); //0010
      world.removeComponent(component2Id, entity);
      expect(world.entityManager.getSignature(entity), 0); //0000
    });
  });
}

class Component1 extends Component {
  @override
  void reset() {}
}

class Component2 extends Component {
  @override
  void reset() {}
}

class System1 extends UpdateEcsSystem {
  @override
  void init(Ecs ecs, Signature signature) {}

  @override
  void update(double deltaTime, SetEntity entities) {}
}

class System2 extends RenderEcsSystem {
  @override
  void init(Ecs ecs, Signature signature) {}

  @override
  void render(SetEntity entities) {}
}
