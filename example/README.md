Fast ECS Examples
==========================
Simple and fast Entity-Component-System (ECS) library written in Dart.


Components
---
Creating a `VelocityComponent` class

```dart
class VelocityComponent extends Component {
  double velocity = 2;
}
```

Creating a `TransformComponent` class

```dart
class TransformComponent extends Component {
  double rotation = 0.0;
  double scale = 0.5;
}
```

Systems
---
Creating a `RotationSystem` class

```dart
class RotationSystem extends UpdateEcsSystem {
  late ComponentArray<TransformComponent> transformComponents; // quick link
  late ComponentArray<VelocityComponent> velocityComponents; // quick link

  @override
  void init(ecs, Signature signature) {
    transformComponents = ecs.getComponentArray<TransformComponent>();
    velocityComponents = ecs.getComponentArray<VelocityComponent>();
  }

  @override
  void update(double deltaTime, SetEntity entities) {
    for (var i = 0; i < entities.size; i++) {
      Entity entity = entities.get(i);
      TransformComponent transform = transformComponents.getComponent(entity);
      VelocityComponent velocity = velocityComponents.getComponent(entity);
      transform.rotation += velocity.velocity * deltaTime;
    }
  }
}
```

Entity Component System
---
Creating a `Ecs` class

```dart
Ecs ecs = Ecs(maxEntity: maxEntity, maxComponents: 8);
// register components
ComponentId transformId = ecs.registerComponent<TransformComponent>((index) => TransformComponent(), maxEntity);
ComponentId velocityId = ecs.registerComponent<VelocityComponent>((index) => VelocityComponent(), maxEntity);
var rotationSystemSignature = ecs.createSignature([transformId, velocityId]);
// register RotationSystem with signature
ecs.registerSystem<RotationSystem>(() => RotationSystem(), signature: rotationSystemSignature);
```

Entity
---
Creating a `Entity`

```dart
Entity entity = ecs.createEntity();
ecs.addComponent(transformId, entity);
ecs.addComponent(velocityId, entity);
```

Usage
---
update `ECS`

```dart
ecs.update(deltaTime);
```

render `ECS`

```dart
void _render(EcsSystem system, Uint16Set entities) {
  if (system is DrawSystem) {
    system.draw(batch, entities);
  }
}

void render() {
  ecs.forEach(_render);
}
```