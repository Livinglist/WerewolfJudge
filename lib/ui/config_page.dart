import 'package:flutter/material.dart';

import 'package:werewolfjudge/model/template.dart';
import 'package:werewolfjudge/resource/firebase_auth_provider.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';
import 'room_page.dart';

///This page is for users to configure and start rooms.
class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

const String wolf = '普狼';
const String extraWolf1 = '普狼1';
const String extraWolf2 = '普狼2';
const String wolfQueen = '普美人';
const String wolfKing = '白狼王';
const String seer = '预言家';
const String witch = '女巫';
const String hunter = '猎人';
const String guard = '守卫';
const String villager = '普通村民';
const String extraVillager = '普通村民1';
const String slacker = '混子';

class _ConfigPageState extends State<ConfigPage> {
  Map<String, bool> selectedMap = {
    wolf: true,
    extraWolf1: true,
    extraWolf2: false,
    wolfQueen: false,
    wolfKing: false,
    seer: true,
    witch: true,
    hunter: true,
    guard: true,
    villager: true,
    extraVillager: false,
    slacker: false,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange,
        appBar: AppBar(
          title: Text('创建房间 ${selectedMap.values.toList().where((e) => e).length + 5}人'),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                FirebaseAuthProvider.instance.currentUser.then((user) {
                  FirestoreProvider.instance.newRoom(uid: user.uid, numOfSeats: 12, template: WolfQueenTemplate.newGame()).then((roomNumber) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage(roomNumber: roomNumber)));
                  });
                });
              },
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            buildSubTitle('狼人'),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  FilterChip(
                    label: Text('普狼'),
                    selected: selectedMap[wolf],
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('普狼'),
                    selected: selectedMap[wolf],
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('普狼'),
                    selected: selectedMap[wolf],
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('普狼'),
                    selected: selectedMap[extraWolf1],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[extraWolf1] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: Text('普狼'),
                    selected: selectedMap[extraWolf2],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[extraWolf2] = selected;
                      });
                    },
                  ),
                ],
              ),
            ),
            buildSubTitle('技能狼'),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  FilterChip(
                    label: Text('狼美人'),
                    selected: selectedMap[wolfQueen],
                    onSelected: (selected) {
                      selectWoldWithSkill(wolfQueen);
                    },
                  ),
                  FilterChip(
                    label: Text('白狼王'),
                    selected: selectedMap[wolfKing],
                    onSelected: (selected) {
                      selectWoldWithSkill(wolfKing);
                    },
                  ),
                ],
              ),
            ),
            buildSubTitle('民'),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  FilterChip(
                    label: Text('普通村民'),
                    selected: selectedMap[villager],
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('普通村民'),
                    selected: selectedMap[villager],
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('普通村民'),
                    selected: selectedMap[villager],
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('普通村民'),
                    selected: selectedMap[villager],
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('普通村民'),
                    selected: selectedMap[extraVillager],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[extraVillager] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: Text('混子'),
                    selected: selectedMap[slacker],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[slacker] = selected;
                      });
                    },
                  ),
                ],
              ),
            ),
            buildSubTitle('神'),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  FilterChip(
                    label: Text(seer),
                    selected: selectedMap[seer],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[seer] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: Text(witch),
                    selected: selectedMap[witch],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[witch] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: Text(hunter),
                    selected: selectedMap[hunter],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[hunter] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: Text(guard),
                    selected: selectedMap[guard],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[guard] = selected;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Widget buildSubTitle(String text) => Padding(
        padding: EdgeInsets.only(left: 12),
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      );

  void selectWoldWithSkill(String wolf) {
    var wolvesWithSkill = [wolfQueen, wolfKing]..remove(wolf);

    for (var i in wolvesWithSkill) {
      if (selectedMap[i]) {
        setState(() {
          selectedMap[i] = false;
          selectedMap[wolf] = true;
        });
        return;
      }
    }

    setState(() {
      selectedMap[wolf] = true;
    });
  }
}
