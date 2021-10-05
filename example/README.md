Fast ECS Examples
==========================


Components
---
Creating a `VelocityComponent` class

```dart
class VelocityComponent extends Component {
  double velocity = 2;
}

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
  late List<TransformComponent> transformComponents; // quick link
  late List<VelocityComponent> velocityComponents; // quick link

  @override
  void init(ecs, Signature signature) {
    transformComponents = ecs.getComponentList<TransformComponent>();
    velocityComponents = ecs.getComponentList<VelocityComponent>();
  }

  @override
  void update(double deltaTime, SetEntity entities) {
    for (var i = 0; i < entities.size; i++) {
      Entity entity = entities.get(i);
      TransformComponent transform = transformComponents[entity];
      VelocityComponent velocity = velocityComponents[entity];
      transform.rotation += velocity.velocity * deltaTime;
    }
  }
}
```

Ecs
---
Creating a `Ecs` class

```dart
Ecs ecs = Ecs(maxEntity: maxEntity, maxComponents: 8);
// register components
ComponentId transformId = ecs.registerComponent<TransformComponent>((index) => TransformComponent(), maxEntity);
ComponentId velocityId = ecs.registerComponent<VelocityComponent>((index) => VelocityComponent(), maxEntity);
var rotationSystemSignature = ecs.createSignature([transformId, velocityId]);
// register [RotationSystem] with signature
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
//
ecs.update(deltaTime);
```