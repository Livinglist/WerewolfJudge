import 'actionable_mixin.dart';
import 'role.dart';

export 'seer.dart';
export 'hunter.dart';
export 'witch.dart';
export 'guard.dart';
export 'idiot.dart';
export 'graveyard_keeper.dart';
export 'slacker.dart';
export 'black_trader.dart';
export 'knight.dart';
export 'celebrity.dart';
export 'cupid.dart';
export 'moderator.dart';
export 'magician.dart';
export 'tree.dart';
export 'bride.dart';
export 'thief.dart';
export 'witcher.dart';
export 'psychic.dart';

export 'player.dart';

abstract class God extends Role with ActionableMixin {
  God({String roleName}) : super(roleName: roleName);
}
