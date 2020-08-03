import 'package:werewolfjudge/model/role.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';

class RoleImageProvider {
  static final instance = RoleImageProvider._();

  RoleImageProvider._();

  final Map<Type, String> _roleToImagePath = {
    BlackTrader: 'black_trader.png',
    BloodMoon: 'blood_moon.png',
    Bride: 'wolf_queen.png',
    Celebrity: 'celebrity.png',
    Cupid: 'cupid.png',
    Gargoyle: 'gargoyle.png',
    GraveyardKeeper: 'graveyard_keeper.png',
    Guard: 'guard.png',
    HiddenWolf: 'hidden_wolf.png',
    Hunter: 'hunter.png',
    Idiot: 'idiot.png',
    Knight: 'knight.png',
    Magician: 'magician.png',
    Moderator: 'moderator.png',
    Nightmare: 'nightmare.png',
    Pervert: 'pervert.png',
    Psychic: 'seer.png',
    Seer: 'seer.png',
    Slacker: 'slacker.png',
    Thief: 'thief.png',
    Tree: 'pervert.png',
    Villager: 'villager.png',
    Witch: 'witch.png',
    Witcher: 'witcher.png',
    Wolf: 'wolf.png',
    WolfKing: 'wolf_king.png',
    WolfQueen: 'wolf_queen.png',
    WolfRobot: 'wolf_seeder.png',
    WolfSeeder: 'wolf_seeder.png',
    WolfBrother: 'wolf_king.png'
  };

  operator [](Role role) => 'assets/images/' + _roleToImagePath[role.runtimeType];
}
