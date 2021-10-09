<p align="center">
<a title="Pub" href="https://pub.dartlang.org/packages/fast_ecs"><img alt="Pub Version" src="https://img.shields.io/pub/v/fast_ecs?color=blue&style=for-the-badge"></a>
</p>

## Fast ECS

Simple and fast Entity-Component-System (ECS) library written in Dart.

## CPU Flame Chart

Demonstration of performance for rotation of 1024 entities

* device Nexus 5 (2014) android 6.0.1
* fast_ecs version 0.0.1
* all time 10500(ms)
* 1024 entities

![all](https://user-images.githubusercontent.com/1622824/135919089-c04aa86c-58b7-47fe-8c36-18db64fd977a.png)
RotationSystem

```dart
void update(double deltaTime, SetEntity entities) {
  for (var i = 0; i < entities.size; i++) {
    Entity entity = entities[i];
    TransformComponent transform = transformComponents[entity];
    VelocityComponent rotation = velocityComponents[entity];
    transform.rotation += rotation.velocity * deltaTime;
    transform.dirty = true;
  }
}
```

![update RotationSystem](https://user-images.githubusercontent.com/1622824/135920601-8fe2d132-ac46-40a7-8bdd-d41813bfefcd.png)

SpriteSystem

```dart
void updateSprite(TransformComponent transform, SpriteComponent sprite) {
  var textureRegion = sprite.textureRegion;
  if (transform.dirty && textureRegion != null) {
    var scos = cos(transform.rotation) * transform.scale;
    var ssin = sin(transform.rotation) * transform.scale;
    var tx = -scos * textureRegion.anchorX + ssin * textureRegion.anchorY;
    var ty = -ssin * textureRegion.anchorX - scos * textureRegion.anchorY;
    sprite.transformData.set(scos, ssin, tx, ty);
    transform.dirty = false;
  }
}
```

![updateSprite](https://user-images.githubusercontent.com/1622824/135920653-d3b6faf9-6f4b-4a04-a1b0-81ccd1b8e676.png)

---
Demonstration of performance for rotation of 10K entities

* device Nexus 5 (2014) android 6.0.1
* fast_ecs version 0.1.0
* all time 10.5 sec.
* 10000 entities
* update rotation - 0.85 sec.
* update sprite - 3.6 sec.

![update 10K sprites](https://user-images.githubusercontent.com/1622824/136676126-28d9d0ee-08a4-42b9-a6aa-a9b8473edaa3.png)


## History of creation

The source of inspiration was the
resource [A SIMPLE ENTITY COMPONENT SYSTEM (ECS) [C++]](https://austinmorlan.com/posts/entity_component_system/)
