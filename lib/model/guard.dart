import 'god.dart';

class Guard extends God {
  Guard() : super(roleName: '守卫'){
    actionMessage = '请选择守护对象。';
    super.actionConfirmMessage = '守护';
  }

  @override
  void set actionConfirmMessage(String _actionConfirmMessage) {
    // TODO: implement actionConfirmMessage
    super.actionConfirmMessage = _actionConfirmMessage;
  }

  @override
  // TODO: implement actionConfirmMessage
  String get actionConfirmMessage => super.actionConfirmMessage;

  @override
  void set actionMessage(String _actionMessage) {
    // TODO: implement actionMessage
    super.actionMessage = _actionMessage;
  }

  @override
  // TODO: implement actionMessage
  String get actionMessage => super.actionMessage;

  @override
  void set actionResult(String _actionResult) {
    // TODO: implement actionResult
    super.actionResult = _actionResult;
  }

  @override
  // TODO: implement actionResult
  String get actionResult => super.actionResult;

  @override
  void action(Map<int, Player> seatNumToPlayer, int target) {

  }
}
