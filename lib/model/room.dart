import 'package:werewolfjudge/resource/firestore_provider.dart';

import 'template.dart';
import 'role.dart';

export 'role.dart';

enum RoomStatus { seating, seated, ongoing, terminated }

class Room {
  String hostUid;
  Template template;
  String roomNumber;
  RoomStatus roomStatus;

  ///seatNumber to Player
  Map<int, Player> players = {};

  ///Role to target
  Map<Type, int> actions;

  List<Map<Role, int>> rounds;

  int currentActionerIndex;

  bool hasPoison = false, hasAntidote = false;

  Role get currentActionRole => currentActionerIndex == template.actionOrder.length ? null : template.actionOrder[currentActionerIndex];

  bool get hunterStatus {
    var killedByWitch = actions[Witch];
    if (killedByWitch != null && killedByWitch < 0 && players[(killedByWitch + 1).abs()].role is Hunter) return false;
    return true;
  }

  ///Whether or not the skill of the current actioner has been effected by nightmare.
  bool get currentActionerSkillStatus {
    if (template.rolesType.contains(Nightmare)) {
      return true;
    }

    if (actions[Nightmare] == currentActionerIndex) {
      return false;
    }

    return true;
  }

  String get lastNightInfo {
    var killedByWolf = actions[Wolf];
    var killedByWitch = (actions[Witch] ?? 1) < 0 ? -1 * actions[Witch] - 1 : null;
    var savedByWitch = (actions[Witch] ?? -1) > 0 ? actions[Witch] : null;
    var queenIndex =
        actions.containsKey(WolfQueen) ? players.values.singleWhere((element) => element.role is WolfQueen, orElse: () => null).seatNumber : null;
    var selptWith = actions[WolfQueen];
    var guardedByGuard = actions[Guard];

    Set<int> deaths = {};

    print("killedByWolf: $killedByWolf");
    print("killedByWitch: $killedByWitch");
    print("savedByWitch: $savedByWitch");
    print("queenIndex: $queenIndex");
    print("selptWith: $selptWith");

    //奶死
    if (savedByWitch != null && savedByWitch == guardedByGuard) {
      deaths.add(savedByWitch);
    }

    //没有被救或守
    if (killedByWolf != guardedByGuard && (savedByWitch == null || savedByWitch != killedByWolf)) {
      deaths.add(killedByWolf);
    }

    //毒死
    if (killedByWitch != null) {
      deaths.add(killedByWitch);
    }

    //如果狼美人死亡，被连的人殉情
    if (deaths.contains(queenIndex)) {
      deaths.add(selptWith);
    }

    if (deaths.isEmpty) {
      return "昨天晚上是平安夜。";
    }

    String info = "昨天晚上";
    for (var i in deaths) {
      info += "${i + 1}号, ";
    }
    info = info.substring(0, info.length - 2);
    info += "玩家死亡。";

    return info;
  }

  int get killedIndex => actions[Wolf] ?? -1;

  Room.create({this.hostUid, this.roomNumber, this.template}) : roomStatus = RoomStatus.seating;

  Room.from(
      {this.actions, this.hostUid, this.roomNumber, this.template, this.roomStatus, this.currentActionerIndex, this.hasAntidote, this.hasPoison});

  void startGame() {
    FirestoreProvider.instance.startGame();
  }

  ///Take the seat number of target and return message if needed.
  String action(int target, {bool usePoison = false}) {
    if (currentActionRole is Seer) return players[target].role is Wolf ? "狼人" : "好人";
    if (currentActionRole is Gargoyle)
      return players[target].role.roleName;
    else
      return null;
  }

  //Order: guard -> wolf -> wolf queen -> witch -> seer -> hunter
  void proceed(int target, {bool usePoison = true}) {
    //var currentActionRole = template.actionOrder[currentActionerIndex];

//    Player currentActionPlayer;
//
//    if (currentActionRole is Wolf == false) {
//      currentActionPlayer = players.values.singleWhere((player) => player.role.runtimeType == currentActionRole.runtimeType);
//    }

    FirestoreProvider.instance.performAction(currentActionRole, target, currentActionerIndex + 1, usePoison: usePoison);
  }
}
