import 'actionable_mixin.dart';
import 'role.dart';

export 'wolf_queen.dart';
export 'wolf_king.dart';
export 'nightmare.dart';
export 'gargoyle.dart';
export 'hidden_wolf.dart';
export 'wolf_seeder.dart';
export 'blood_moon.dart';
export 'wolf_robot.dart';

class Wolf extends Role with ActionableMixin {
  final String roleName;

  Wolf({String roleName})
      : roleName = roleName ?? '狼人',
        super(roleName: '狼人'){
    super.actionMessage = '请选择猎杀对象。';
    super.actionConfirmMessage = "猎杀";
    super.actionResult = '';
  }
}
