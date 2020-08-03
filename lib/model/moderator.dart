import 'god.dart';

class Moderator extends God {
  Moderator() : super(roleName: '禁票长老') {
    super.actionMessage = "请选择封禁对象";
    super.actionConfirmMessage = "封禁";
  }
}