import 'god.dart';

class Psychic extends God {
  Psychic() : super(roleName: '通灵师') {
    super.actionMessage = "请选择查验对象";
    super.actionConfirmMessage = "查验";
  }
}
