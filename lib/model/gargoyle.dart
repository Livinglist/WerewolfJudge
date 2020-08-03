import 'wolf.dart';

class Gargoyle extends Wolf {
  Gargoyle() : super(roleName: '石像鬼') {
    super.actionMessage = '请选择查验对象';
    super.actionConfirmMessage = '查验';
  }
}
