import 'god.dart';

class Hunter extends God {
  Hunter() : super(roleName: '猎人') {
    actionMessage = '你可以发动技能。';
  }

  @override
  set actionMessage(String _actionMessage) {
    super.actionMessage = _actionMessage;
  }

  @override
  String get actionMessage => super.actionMessage;

  @override
  set actionResult(String _actionResult) {
    // TODO: implement actionResult
    super.actionResult = _actionResult;
  }

  @override
  String get actionResult => super.actionResult;

  @override
  String action(Map<int, Player> seatNumToPlayerMap,int target) {

  }
}
