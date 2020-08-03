import 'god.dart';

class Celebrity extends God {
  Celebrity() : super(roleName: '摄梦人') {
    super.actionMessage = "请选择摄梦对象";
    super.actionConfirmMessage = "摄梦";
  }
}