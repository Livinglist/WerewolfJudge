import 'player.dart';

import 'god.dart';

class Seer extends God {
  Seer() : super(roleName: '预言家') {
    actionMessage = "请选择查验对象。";
  }

  @override
  set actionMessage(String _actionMessage) {
    super.actionMessage = _actionMessage;
  }

  @override
  String get actionMessage => super.actionMessage;

  @override
  set actionResult(String _actionResult) {
    super.actionResult = _actionResult;
  }

  @override
  String get actionResult => super.actionResult;

  @override
  void action(Map<int, Player> seatNumToPlayer, int target) {

  }
}
