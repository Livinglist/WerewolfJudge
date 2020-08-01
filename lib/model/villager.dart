import 'role.dart';

export 'pervert.dart';

class Villager extends Role {
  Villager({String roleName}) : super(roleName: roleName ?? '普通村民');
}
