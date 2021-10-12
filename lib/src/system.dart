import 'ecs.dart';
import 'types.dart';

abstract class EcsSystem {
  SystemPhases phase = SystemPhases.think;

  void register(Ecs ecs, Signature signature) {}

  void init() {}
}

abstract class UpdateEcsSystem extends EcsSystem {
  void update(double deltaTime, EntitySet entities);
}

enum SystemPhases {
  begin,
  think,
  physics,
  postPhysics,
  movement,
  collisionDetection,
  collisionResponse,
  postCollision,
  animation,
  postAnimation,
  preDraw,
  draw,
  end,
}
