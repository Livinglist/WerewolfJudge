export 'god.dart';
export 'wolf.dart';
export 'villager.dart';

abstract class Role {
  final String roleName;

  String get name => roleName;

  Role({this.roleName});
}