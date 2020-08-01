import 'god.dart';

class Witcher extends God {
  Witcher() : super(roleName: '猎魔人') {
    super.actionMessage = "请选择狩猎对象";
    super.actionConfirmMessage = "狩猎";
  }
}
