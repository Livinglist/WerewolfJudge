import 'player.dart';

class ActionableMixin {
  String actionMessage;
  String actionConfirmMessage;
  String actionResult;

  action(Map<int, Player> seatNumToPlayerMap, int targetSeatNumber) {}
}
