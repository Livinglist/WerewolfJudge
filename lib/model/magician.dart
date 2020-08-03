import 'god.dart';

class Magician extends God {
  Magician() : super(roleName: '魔术师') {
    super.actionMessage = "请选择两个交换对象";
    super.actionConfirmMessage = "交换";
  }
}
