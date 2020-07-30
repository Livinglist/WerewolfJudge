import 'god.dart';

class Slacker extends God{
  Slacker() : super(roleName: '混子') {
    super.actionMessage = "请选择你的偶像。";
    super.actionConfirmMessage = "混";
  }

  @override
  void action(Map<int, Player> seatNumToPlayer, int target) {}
}