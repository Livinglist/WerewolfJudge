export 'god.dart';
export 'wolf.dart';
export 'villager.dart';
export 'lucky_son.dart';

abstract class Role {
  final String roleName;

  String get name => roleName;

  Role({this.roleName});
}