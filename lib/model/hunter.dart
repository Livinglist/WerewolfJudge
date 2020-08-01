import 'god.dart';

class Hunter extends God {
  Hunter() : super(roleName: '猎人') {
    super.actionMessage = '你的技能发动状态是';
  }
}
