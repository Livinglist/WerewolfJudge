import 'package:werewolfjudge/model/role.dart';

class JudgeAudioProvider {
  static final instance = JudgeAudioProvider._();

  JudgeAudioProvider._();

  String get night => 'audio/night.m4a';
  String get nightEnd => 'audio/night_end.m4a';

  final Map<Type, String> _rolesToAudio = {
    Celebrity: 'audio/celebrity.m4a',
    Gargoyle: 'audio/gargoyle.m4a',
    Guard: 'audio/guard.m4a',
    Hunter: 'audio/hunter.m4a',
    Magician: 'audio/magician.m4a',
    Moderator: 'audio/moderator.m4a',
    //:'audio/night.m4a',
    //:'audio/night_end.m4a',
    Nightmare: 'audio/nightmare.m4a',
    Psychic: 'audio/psychic.m4a',
    Seer: 'audio/seer.m4a',
    Witch: 'audio/witch.m4a',
    Wolf: 'audio/wolf.m4a',
    WolfKing: 'audio/wolf_king.m4a',
    WolfQueen: 'audio/wolf_queen.m4a',
    WolfRobot: 'audio/wolf_robot.m4a',
    BlackTrader: 'audio/black_trader.m4a',
    WolfBrother: 'audio/wolf_brother.m4a',
    LuckySon: 'audio/lucky_son.m4a',
    Slacker: 'audio/slacker.m4a',
  };

  final Map<Type, String> _rolesToEndAudio = {
    Celebrity: 'audio_end/celebrity.m4a',
    Gargoyle: 'audio_end/gargoyle.m4a',
    Guard: 'audio_end/guard.m4a',
    Hunter: 'audio_end/hunter.m4a',
    Magician: 'audio_end/magician.m4a',
    Moderator: 'audio_end/moderator.m4a',
    //:'audio/night.m4a',
    //:'audio/night_end.m4a',
    Nightmare: 'audio_end/nightmare.m4a',
    Psychic: 'audio_end/psychic.m4a',
    Seer: 'audio_end/seer.m4a',
    Witch: 'audio_end/witch.m4a',
    Wolf: 'audio_end/wolf.m4a',
    WolfKing: 'audio_end/wolf_king.m4a',
    WolfQueen: 'audio_end/wolf_queen.m4a',
    WolfRobot: 'audio_end/wolf_robot.m4a',
    BlackTrader: 'audio_end/black_trader.m4a',
    WolfBrother: 'audio_end/wolf_brother.m4a',
    LuckySon: 'audio/night.m4a',
    Slacker: 'audio_end/slacker.m4a',
  };

  String getBeginningAudio(Role role) => _rolesToAudio[role.runtimeType];

  String getEndingAudio(Role role) => _rolesToEndAudio[role.runtimeType];
}
