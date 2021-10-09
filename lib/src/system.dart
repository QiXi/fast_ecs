import 'ecs.dart';
import 'set.dart';
import 'types.dart';

abstract class EcsSystem {
  SystemPhases phase = SystemPhases.begin;

  void register(Ecs ecs, Signature signature) {}

  void init() {}
}

abstract class UpdateEcsSystem extends EcsSystem {
  void update(double deltaTime, Uint16Set entities);
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
