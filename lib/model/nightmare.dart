import 'wolf.dart';

class Nightmare extends Wolf{
  Nightmare() : super(roleName: '梦魇') {
    super.actionMessage = '请选择恐吓对象';
    super.actionConfirmMessage = '恐吓';
  }
}