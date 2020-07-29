import 'package:werewolfjudge/resource/firestore_provider.dart';

import 'template.dart';
import 'role.dart';

export 'role.dart';

enum RoomStatus { seating, ongoing, terminated }

class Room {
  String hostUid;
  Template template;
  String roomNumber;
  RoomStatus roomStatus;

  ///seatNumber to Player
  Map<int, Player> players;

  ///Role to target
  Map<Role, int> actions;

  List<Map<Role, int>> rounds;

  int currentActionerIndex = 0;

  Role get currentActionRole => template.actionOrder[currentActionerIndex];

  Room.create({this.hostUid, this.roomNumber, this.template}) : roomStatus = RoomStatus.seating;

  Room.from({this.hostUid, this.roomNumber, this.template, this.roomStatus});

  void startGame() {
    FirestoreProvider.instance.startGame();
  }

  //Order: guard -> wolf -> wolf queen -> witch -> seer -> hunter
  void proceed(int target) {
    var currentActionRole = template.actionOrder[currentActionerIndex];

    Player currentActionPlayer;

    if (currentActionRole is Wolf == false) {
      currentActionPlayer = players.values.singleWhere((player) => player.role.runtimeType == currentActionRole.runtimeType);
    }

    FirestoreProvider.instance.performAction(currentActionRole, target);

    currentActionerIndex++;
  }
}
