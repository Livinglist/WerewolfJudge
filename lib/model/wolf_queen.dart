import 'wolf.dart';

class WolfQueen extends Wolf {
  WolfQueen() : super(roleName: '狼美人') {
    super.actionMessage = '请选择魅惑对象';
    super.actionConfirmMessage = '魅惑';
  }
}
