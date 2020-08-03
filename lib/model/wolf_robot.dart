import 'wolf.dart';

class WolfRobot extends Wolf {
  WolfRobot() : super(roleName: '机械狼') {
    super.actionMessage = '请选择模仿对象';
    super.actionConfirmMessage = '模仿';
  }
}
