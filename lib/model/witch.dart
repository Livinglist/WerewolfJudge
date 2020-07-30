import 'god.dart';

class Witch extends God {
  Witch() : super(roleName: '女巫'){
    super.actionMessage = "请选择使用毒药或者解药";
    super.actionConfirmMessage = "毒杀";
  }

  @override
  void action(Map<int, Player> seatNumToPlayer, int target) {

  }
}
