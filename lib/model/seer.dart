import 'god.dart';

class Seer extends God {
  Seer() : super(roleName: '预言家') {
    super.actionMessage = "请选择查验对象。";
    super.actionConfirmMessage = "查验";
  }

  @override
  void action(Map<int, Player> seatNumToPlayer, int target) {}
}
