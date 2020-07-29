import 'player.dart';

class ActionableMixin {
  String actionMessage;
  String actionResult;

  action(Map<int, Player> seatNumToPlayerMap, int targetSeatNumber) {}
}
