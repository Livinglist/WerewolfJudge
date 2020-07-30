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
  Map<Role, int> actions;

  List<Map<Role, int>> rounds;

  int currentActionerIndex;

  bool hasPoison = false, hasAntidote = false;

  Role get currentActionRole => template.actionOrder[currentActionerIndex];

  int get killedIndex => actions[Wolf] ?? -1;

  Room.create({this.hostUid, this.roomNumber, this.template}) : roomStatus = RoomStatus.seating;

  Room.from({this.hostUid, this.roomNumber, this.template, this.roomStatus, this.currentActionerIndex, this.hasAntidote, this.hasPoison});

  void startGame() {
    FirestoreProvider.instance.startGame();
  }

  ///Take the seat number of target and return message if needed.
  String action(int target, {bool usePoison = false}) {
    if (currentActionRole is Seer)
      return players[target].role.runtimeType == Wolf().runtimeType ? "狼人" : "好人";
    else
      return null;
  }

  //Order: guard -> wolf -> wolf queen -> witch -> seer -> hunter
  void proceed(int target, {bool usePoison = false}) {
    //var currentActionRole = template.actionOrder[currentActionerIndex];

//    Player currentActionPlayer;
//
//    if (currentActionRole is Wolf == false) {
//      currentActionPlayer = players.values.singleWhere((player) => player.role.runtimeType == currentActionRole.runtimeType);
//    }

    FirestoreProvider.instance.performAction(currentActionRole, target, currentActionerIndex + 1, usePoison: usePoison);
  }
}
