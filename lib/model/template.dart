import 'dart:math';

import 'hunter.dart';
import 'role.dart';
import 'villager.dart';
import 'wolf.dart';
import 'wolfQueen.dart';
import 'seer.dart';
import 'witch.dart';
import 'guard.dart';

export 'player.dart';

abstract class Template {
  final String name;
  final int numberOfPlayers;
  final List<Role> roles;
  final List<Role> actionOrder;

  Template({this.name, this.numberOfPlayers, this.roles, this.actionOrder});
}

//Order: guard -> wolf -> wolf queen -> witch -> seer -> hunter
class WolfQueenTemplate extends Template {
  WolfQueenTemplate.newGame()
      : super(name: '预女猎守狼美人12人局', numberOfPlayers: 12, roles: [
          Villager(),
          Villager(),
          Villager(),
          Villager(),
          Wolf(),
          Wolf(),
          Wolf(),
          WolfQueen(),
          Seer(),
          Hunter(),
          Witch(),
          Guard(),
        ], actionOrder: [
          Guard(),
          Wolf(),
          WolfQueen(),
          Witch(),
          Seer(),
          Hunter(),
        ]) {
    roles.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
  }

  WolfQueenTemplate.from({List<dynamic> roles})
      : super(name: '预女猎守狼美人12人局', numberOfPlayers: roles.length, roles: roles.map((e) => e as Role).toList(), actionOrder: [
          Guard(),
          Wolf(),
          WolfQueen(),
          Witch(),
          Seer(),
          Hunter(),
        ]) {
    print('constructing ${this.roles}');
  }
}

//Order: guard -> wolf -> wolf queen -> witch -> seer -> hunter
class WolfQueenSlackerTemplate extends Template {
  WolfQueenSlackerTemplate.newGame()
      : super(name: '预女猎守狼美人12人局', numberOfPlayers: 12, roles: [
    Villager(),
    Villager(),
    Villager(),
    Villager(),
    Wolf(),
    Wolf(),
    Wolf(),
    WolfQueen(),
    Seer(),
    Hunter(),
    Witch(),
    Guard(),
  ], actionOrder: [
    Guard(),
    Wolf(),
    WolfQueen(),
    Witch(),
    Seer(),
    Hunter(),
  ]) {
    roles.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
  }

  WolfQueenSlackerTemplate.from({List<dynamic> roles})
      : super(name: '预女猎守混狼美人13人局', numberOfPlayers: roles.length, roles: roles.map((e) => e as Role).toList(), actionOrder: [
    Guard(),
    Wolf(),
    WolfQueen(),
    Witch(),
    Seer(),
    Hunter(),
  ]) {
    print('constructing ${this.roles}');
  }
}

class WolfKingTemplate extends Template {}
