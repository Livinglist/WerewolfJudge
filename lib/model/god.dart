import 'actionable_mixin.dart';
import 'role.dart';

export 'seer.dart';
export 'hunter.dart';
export 'witch.dart';
export 'guard.dart';

export 'player.dart';

abstract class God extends Role with ActionableMixin{
  God({String roleName}) : super(roleName: roleName);
}
