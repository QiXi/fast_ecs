import 'ecs.dart';
import 'set_entity.dart';
import 'types.dart';

abstract class EcsSystem {
  void init(Ecs ecs, Signature signature) {}
}

abstract class UpdateEcsSystem extends EcsSystem {
  void update(double deltaTime, SetEntity entities);
}
