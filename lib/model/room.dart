import 'dart:convert';

import 'package:werewolfjudge/model/psychic.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';
import 'package:werewolfjudge/resource/constants.dart';

import 'template.dart';
import 'role.dart';

export 'role.dart';

enum RoomStatus { seating, seated, ongoing, terminated }

const String roomNumberKey = 'roomNumber';

class Room {
  int timestamp;
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

  bool get hasSkilledWolf {
    var rolesSet = template.rolesType.toSet();
    print(rolesSet);
    if (rolesSet.contains(WolfKing) ||
        rolesSet.contains(WolfQueen) ||
        rolesSet.contains(WolfBrother) ||
        rolesSet.contains(Nightmare) ||
        rolesSet.contains(BloodMoon) ||
        rolesSet.contains(WolfSeeder)) {
      return true;
    }
    return false;
  }

  int get actionWolfIndex {
    var temp = players.values.where((element) => element.role.runtimeType == Wolf).map((e) => e.seatNumber).toList()..sort();
    return temp.first;
  }

  Role get currentActionRole {
    if (currentActionerIndex == template.actionOrder.length) {
      if (template.rolesType.contains(BlackTrader))
        return LuckySon();
      else
        return null;
    } else {
      //如果有黑商，为了确认谁是幸运儿，夜间会多一个轮次
      if (currentActionerIndex == template.actionOrder.length + 1)
        return null;
      else
        return template.actionOrder[currentActionerIndex];
    }
  }

  Role get lastActionRole {
    if (currentActionerIndex == 0 || currentActionerIndex > template.actionOrder.length + 1) return null;

    if (currentActionerIndex == template.actionOrder.length + 1) return LuckySon();

    return template.actionOrder[currentActionerIndex - 1];
  }

  int get luckySonIndex {
    int index = actions[BlackTrader];
    if (index == null || index == -1) return -1;

    index = index % 100;

    return index;
  }

  String get giftInfo {
    int index = actions[BlackTrader];
    if (index == null || index == -1) return "";

    int roleIndex = (index - index % 100) ~/ 100;

    Type roleType = Player.indexToRoleType(roleIndex);

    var killedByWitch = (actions[Witch] ?? 1) < 0 ? -1 * actions[Witch] - 1 : null;
    String gunStatus = '你的发动状态为：可以发动';

    if (killedByWitch == index) {
      gunStatus = '你的发动状态为：不可发动';
    }

    switch (roleType) {
      case Witch:
        return "女巫的毒药";
      case Hunter:
        return "猎人的枪\n$gunStatus";
      case Seer:
        return "预言家的眼镜";
      default:
        throw Exception("Unmatched $roleType");
    }
  }

  bool get hunterStatus {
    var killedByWitch = (actions[Witch] ?? 1) < 0 ? -1 * actions[Witch] - 1 : null;
    var linkedByWolfQueen = actions[WolfQueen];
    var nightmared = actions[Nightmare];

    if (killedByWitch != null && players[killedByWitch].role is Hunter) return false;
    if (linkedByWolfQueen != null && players[linkedByWolfQueen].role is Hunter) return false;
    if (nightmared != null && players[nightmared].role is Hunter) return false;

    return true;
  }

  bool get wolfKingStatus {
    var killedByWitch = (actions[Witch] ?? 1) < 0 ? -1 * actions[Witch] - 1 : null;
    if (killedByWitch != null && players[killedByWitch].role is WolfKing) return false;
    return true;
  }

  ///Whether or not the skill of the current actioner has been effected by nightmare.
  bool get currentActionerSkillStatus {
    if (template.rolesType.contains(Nightmare)) {
      var nightmaredIndex = actions[Nightmare];

      print("The nightmared index is $nightmaredIndex");
      print(currentActionerIndex);

      if (nightmaredIndex != null && players[nightmaredIndex].role.runtimeType == template.actionOrder[currentActionerIndex].runtimeType)
        return false;
      else
        return true;
    }

    if (actions[Nightmare] == currentActionerIndex) {
      return false;
    }

    return true;
  }

  String get roomInfo {
    var roomInfo = '';
    var villagerCount = template.roles.whereType<Villager>().length;
    var wolfCount = template.roles.where((e) => e.runtimeType == Wolf).length;

    roomInfo += '村民x$villagerCount, ';
    roomInfo += '普狼x$wolfCount, ';
    for (var i in template.roles) {
      if (i.runtimeType != Wolf && i is Villager == false) roomInfo += i.roleName + ', ';
    }

    //remove the last comma.
    roomInfo = roomInfo.substring(0, roomInfo.length - 2);

    return roomInfo;
  }

  String get lastNightInfo {
    var killedByWolf = actions[Wolf];
    var killedByWitch = (actions[Witch] ?? 1) < 0 ? -1 * actions[Witch] - 1 : null;
    var savedByWitch = (actions[Witch] ?? -1) >= 0 ? actions[Witch] : null;
    var queenIndex =
        actions.containsKey(WolfQueen) ? players.values.singleWhere((element) => element.role is WolfQueen, orElse: () => null).seatNumber : null;
    var sleptWith = actions[WolfQueen];
    var guardedByGuard = actions[Guard];
    var moderatedByModerator = actions[Moderator];
    var nightWalker = actions[Celebrity];
    var blackTraderTarget = actions[BlackTrader];
    var blackTraderIndex =
        actions.containsKey(BlackTrader) ? players.values.singleWhere((element) => element.role is BlackTrader, orElse: () => null).seatNumber : null;
    var blackTraderKilledByHiddenWolf = false;
    var witcherIndex = this.template.rolesType.contains(Witcher)
        ? players.values.singleWhere((element) => element.role is Witcher, orElse: () => null).seatNumber
        : null;

    //var killedByWitcher = actions[Witcher];
    int firstExchanged, secondExchanged;
    if (actions.keys.contains(Magician) && actions[Magician] != -1) {
      firstExchanged = actions[Magician] % 100;
      secondExchanged = (actions[Magician] - firstExchanged) ~/ 100;
    }

    //尝试获取摄梦人号码
    var celebrityIndex =
        actions.containsKey(Celebrity) ? players.values.singleWhere((element) => element.role is Celebrity, orElse: () => null).seatNumber : null;

    Set<int> deaths = {};

    print('==========================');
    print("killedByWolf: $killedByWolf");
    print("killedByWitch: $killedByWitch");
    print("savedByWitch: $savedByWitch");
    print("queenIndex: $queenIndex");
    print("sleptWith: $sleptWith");
    print("firstExchanged: $firstExchanged");
    print("secondExchanged: $secondExchanged");
    print("blackTraderTarget: $blackTraderTarget");
    print("blackTraderIndex: $blackTraderIndex");
    print('==========================');

    //奶死
    if (savedByWitch != null && savedByWitch == guardedByGuard) {
      deaths.add(savedByWitch);
    }

    //没有被救或守
    if (killedByWolf != null && killedByWolf != -1 && killedByWolf != guardedByGuard && (savedByWitch == null || savedByWitch != killedByWolf)) {
      deaths.add(killedByWolf);
    }

    //毒死
    if (killedByWitch != null) {
      //猎魔人不吃毒
      if (witcherIndex != killedByWitch) {
        deaths.add(killedByWitch);
      }
    }

    //如果狼美人死亡，被连的人殉情
    if (deaths.contains(queenIndex)) {
      deaths.add(sleptWith);
    }

    //摄梦人使死亡失效
    deaths.remove(nightWalker);

    //如果摄梦人死亡，则梦游者也死亡
    if (deaths.contains(celebrityIndex)) {
      deaths.add(nightWalker);
    }

//    if(killedByWitcher != null){
//      if(players[killedByWitcher].role is Wolf == false){
//        deaths.add()
//      }
//    }

    if (deaths.contains(firstExchanged) && deaths.contains(secondExchanged) == false) {
      deaths.remove(firstExchanged);
      deaths.add(secondExchanged);
    } else if (deaths.contains(firstExchanged) == false && deaths.contains(secondExchanged)) {
      deaths.remove(secondExchanged);
      deaths.add(firstExchanged);
    }

    if (blackTraderTarget != null && blackTraderTarget == -1) {
      deaths.add(blackTraderIndex);
      blackTraderKilledByHiddenWolf = true;
    }

    String info;
    if (deaths.isEmpty) {
      info = "昨天晚上是平安夜。";
    } else {
      info = "昨天晚上";

      for (var i in deaths.toList()..sort()) {
        info += "${i + 1}号, ";
      }

      info = info.substring(0, info.length - 2);
      info += "玩家死亡。";
    }

    if (moderatedByModerator == nightWalker) moderatedByModerator = null;

    if (this.template.rolesType.contains(Moderator)) {
      if (moderatedByModerator == null)
        info += "\n无人被禁票。";
      else
        info += "\n${moderatedByModerator + 1}号被禁票。";
    }

    if (blackTraderKilledByHiddenWolf) {
      info += "\n黑查杀，隐狼变普狼。";
    }

    return info;
  }

  int get killedIndex => actions[Wolf] ?? -1;

  Room.create({this.hostUid, this.roomNumber, this.template}) : roomStatus = RoomStatus.seating;

  Room.from(
      {this.actions,
      this.hostUid,
      this.roomNumber,
      this.template,
      this.timestamp,
      this.roomStatus,
      this.currentActionerIndex,
      this.hasAntidote,
      this.hasPoison,
      this.players});

  Room.fromMap(Map<String, dynamic> map) {
    this.timestamp = map[timestampKey];
    this.roomNumber = map[roomNumberKey];
    this.actions = (jsonDecode(map[actionsKey]) as Map).map((k, v) => MapEntry<Type, int>(Player.indexToRoleType(int.parse(k)), v));
    this.players = (jsonDecode(map[actionsKey]) as Map).map((k, v) => MapEntry<int, Player>(int.parse(k), Player.fromMap(jsonDecode(v))));
  }

  Map toMap() => {
        timestampKey: this.timestamp,
        roomNumberKey: this.roomNumber,
        actionsKey: jsonEncode(this.actions.map((key, value) => MapEntry<int, int>(Player.roleTypeToIndex(key), value))),
        playersKey: jsonEncode(this.players.map((key, value) => MapEntry<int, String>(key, jsonEncode(value.toMap())))),
      };

  void startGame() {
    FirestoreProvider.instance.startGame();
  }

  ///Take the seat number of target and return message if needed.
  String action(int target, {bool usePoison = false}) {
    print("${players[target]} is ${players[target]?.role ?? null} ${players[target] is HiddenWolf}");
    if (currentActionRole is Seer) {
      if (actions.values.contains(Magician) && actions[Magician] != -1) {
        int first = actions[Magician] % 100;
        int second = (actions[Magician] - first) ~/ 100;

        if (target == first) {
          return players[second].role is Wolf ? "狼人" : "好人";
        } else if (target == second) {
          return players[first].role is Wolf ? "狼人" : "好人";
        }
      } else if (players[target].role is HiddenWolf) {
        return "好人";
      }

      return players[target].role is Wolf ? "狼人" : "好人";
    } else if (currentActionRole is Psychic) {
      var learntByWolfRobot = actions[WolfRobot];

      return players[learntByWolfRobot].role.roleName;
    } else if (currentActionRole is WolfRobot)
      return players[target].role.roleName;
    else if (currentActionRole is Gargoyle)
      return players[target].role.roleName;
    else
      return null;
  }

  //Order: guard -> wolf -> wolf queen -> witch -> seer -> hunter
  void proceed(int target, {bool usePoison = true, Type giftedByBlackTrader = Witch}) {
    print("proceed() target is $target");
    if (target == null) {
      FirestoreProvider.instance.performAction(currentActionRole, target, currentActionerIndex + 1, usePoison: usePoison);
    } else {
      if (currentActionRole is Witch) {
        target = usePoison ? -1 * (target + 1) : target;
      } else if (currentActionRole is Hunter || currentActionRole is WolfBrother) {
        target = null;
      } else if (currentActionRole is BlackTrader) {
        //如果黑商选择的玩家是狼人，那么target变为-1，意为黑商倒台
        if (players[target].role is Wolf) {
          target = -1;
        } else {
          var indexOfRole = Player.roleTypeToIndex(giftedByBlackTrader);
          target = target + indexOfRole * 100;
        }
      }

      FirestoreProvider.instance.performAction(currentActionRole, target, currentActionerIndex + 1, usePoison: usePoison);
    }
  }

  void checkInForLuckySonVerifications(int myIndex) {
    FirestoreProvider.instance
        .checkInForLuckySonVerifications(myIndex: myIndex, totalPlayers: players.length, currentActionerIndex: currentActionerIndex + 1);
  }

  void terminate() {
    FirestoreProvider.instance.terminateRoom(this.roomNumber);
  }
}
