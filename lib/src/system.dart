import 'ecs.dart';
import 'set_entity.dart';
import 'types.dart';

abstract class EcsSystem {
  void register(Ecs ecs, Signature signature) {}

  void init() {}
}

abstract class UpdateEcsSystem extends EcsSystem {
  void update(double deltaTime, SetEntity entities);
}
