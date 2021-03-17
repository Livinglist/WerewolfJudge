import 'god.dart';

class Witch extends God {
  Witch() : super(roleName: '女巫'){
    super.actionMessage = "请选择是否使用毒药";
    super.actionConfirmMessage = "毒杀";
  }

  @override
  void action(Map<int, Player> seatNumToPlayer, int target) {

  }
}
