import 'package:werewolfjudge/model/role.dart';

class JudgeAudioProvider {
  static final instance = JudgeAudioProvider._();

  JudgeAudioProvider._();

  String get night => 'assets/audio/night.m4a';
  String get nightEnd => 'assets/audio/night_end.m4a';

  final Map<Type, String> _rolesToAudio = {
    Celebrity: 'assets/audio/celebrity.m4a',
    Gargoyle: 'assets/audio/gargoyle.m4a',
    Guard: 'assets/audio/guard.m4a',
    Hunter: 'assets/audio/hunter.m4a',
    Magician: 'assets/audio/magician.m4a',
    Moderator: 'assets/audio/moderator.m4a',
    //:'assets/audio/night.m4a',
    //:'assets/audio/night_end.m4a',
    Nightmare: 'assets/audio/nightmare.m4a',
    Psychic: 'assets/audio/psychic.m4a',
    Seer: 'assets/audio/seer.m4a',
    Witch: 'assets/audio/witch.m4a',
    Wolf: 'assets/audio/wolf.m4a',
    WolfKing: 'assets/audio/wolf_king.m4a',
    WolfQueen: 'assets/audio/wolf_queen.m4a',
    WolfRobot: 'assets/audio/wolf_robot.m4a',
  };

  operator [](Role role) => _rolesToAudio[role.runtimeType];
}
