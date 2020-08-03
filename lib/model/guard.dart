import 'god.dart';

class Guard extends God {
  Guard() : super(roleName: '守卫'){
    super.actionMessage = '请选择守护对象';
    super.actionConfirmMessage = '守护';
  }

  @override
  void action(Map<int, Player> seatNumToPlayer, int target) {

  }
}
