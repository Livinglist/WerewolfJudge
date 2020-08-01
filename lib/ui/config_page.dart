import 'package:flutter/material.dart';

import 'package:werewolfjudge/model/template.dart';
import 'package:werewolfjudge/model/wolf_seeder.dart';
import 'package:werewolfjudge/resource/firebase_auth_provider.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';
import 'room_page.dart';

///This page is for users to configure and start rooms.
class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

const String wolf = '普狼';
const String wolf1 = '普狼1';
const String wolf2 = '普狼2';
const String wolf3 = '普狼3';
const String wolf4 = '普狼4';
const String wolfQueen = '普美人';
const String wolfKing = '白狼王';
const String seer = '预言家';
const String witch = '女巫';
const String hunter = '猎人';
const String guard = '守卫';
const String villager = '普通村民';
const String villager1 = '普通村民1';
const String villager2 = '普通村民2';
const String villager3 = '普通村民3';
const String villager4 = '普通村民4';
const String slacker = '混子';
const String gargoyle = '石像鬼';
const String nightmare = '梦魇';
const String graveyardKeeper = '守墓人';
const String idiot = '白痴';
const String blackTrader = '黑商';
const String celebrity = '摄梦人';
const String knight = '骑士';
const String cupid = '丘比特';
const String moderator = '禁票长老';
const String hiddenWolf = '隐狼';
const String tree = '大树';
const String magician = '魔术师';
const String wolfSeeder = '种狼';
const String bride = '鬼魂新娘';
const String thief = '盗贼';

class _ConfigPageState extends State<ConfigPage> {
  final scrollController = ScrollController();
  final Map<String, bool> selectedMap = {
    wolf: true,
    wolf1: true,
    wolf2: true,
    wolf3: false,
    wolf4: false,
    wolfQueen: true,
    wolfKing: false,
    seer: true,
    witch: true,
    hunter: true,
    guard: true,
    villager: true,
    villager1: true,
    villager2: true,
    villager3: true,
    villager4: false,
    slacker: false,
    gargoyle: false,
    nightmare: false,
    graveyardKeeper: false,
    idiot: false,
    blackTrader: false,
    celebrity: false,
    knight: false,
    cupid: false,
    moderator: false,
    hiddenWolf: false,
    tree: false,
    magician: false,
    wolfSeeder: false,
    bride: false,
    thief: false,
  };
  bool showShadow = false;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange,
        appBar: AppBar(
          title: Text('创建房间 ${selectedMap.values.toList().where((e) => e).length}人'),
          elevation: showShadow?8:0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                CustomTemplate template;
                List<Role> roles = [];

                for (var i in selectedMap.entries.where((element) => element.value)) {
                  switch (i.key) {
                    case wolf:
                    case wolf1:
                    case wolf2:
                    case wolf3:
                    case wolf4:
                      roles.add(Wolf());
                      break;
                    case wolfQueen:
                      roles.add(WolfQueen());
                      break;
                    case wolfKing:
                      roles.add(WolfKing());
                      break;
                    case nightmare:
                      roles.add(Nightmare());
                      break;
                    case gargoyle:
                      roles.add(Gargoyle());
                      break;
                    case hiddenWolf:
                      roles.add(HiddenWolf());
                      break;
                    case villager:
                    case villager1:
                    case villager2:
                    case villager3:
                    case villager4:
                      roles.add(Villager());
                      break;
                    case seer:
                      roles.add(Seer());
                      break;
                    case witch:
                      roles.add(Witch());
                      break;
                    case hunter:
                      roles.add(Hunter());
                      break;
                    case guard:
                      roles.add(Guard());
                      break;
                    case slacker:
                      roles.add(Slacker());
                      break;
                    case blackTrader:
                      roles.add(BlackTrader());
                      break;
                    case knight:
                      roles.add(Knight());
                      break;
                    case idiot:
                      roles.add(Idiot());
                      break;
                    case moderator:
                      roles.add(Moderator());
                      break;
                    case cupid:
                      roles.add(Cupid());
                      break;
                    case celebrity:
                      roles.add(Celebrity());
                      break;
                    case graveyardKeeper:
                      roles.add(GraveyardKeeper());
                      break;
                    case tree:
                      roles.add(Tree());
                      break;
                    case magician:
                      roles.add(Magician());
                      break;
                    case wolfSeeder:
                      roles.add(WolfSeeder());
                      break;
                    default:
                      throw Exception("Unmatched role: ${i.key}");
                  }
                }

                template = CustomTemplate.newGame(roles: roles);

                FirebaseAuthProvider.instance.currentUser.then((user) {
                  FirestoreProvider.instance.newRoom(uid: user.uid, numOfSeats: 12, template: template).then((roomNumber) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage(roomNumber: roomNumber)));
                  });
                });
              },
            )
          ],
        ),
        body: ListView(
          controller: scrollController,
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
                    elevation: selectedMap[wolf] ? 4 : 0,
                    selected: selectedMap[wolf],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[wolf] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    elevation: selectedMap[wolf1] ? 4 : 0,
                    label: Text('普狼'),
                    selected: selectedMap[wolf1],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[wolf1] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    elevation: selectedMap[wolf2] ? 4 : 0,
                    label: Text('普狼'),
                    selected: selectedMap[wolf2],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[wolf2] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    elevation: selectedMap[wolf3] ? 4 : 0,
                    label: Text('普狼'),
                    selected: selectedMap[wolf3],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[wolf3] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    elevation: selectedMap[wolf4] ? 4 : 0,
                    label: Text('普狼'),
                    selected: selectedMap[wolf4],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[wolf4] = selected;
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
                  buildFilterChip(wolfQueen),
                  buildFilterChip(wolfKing),
                  buildFilterChip(gargoyle),
                  buildFilterChip(nightmare),
                  buildFilterChip(hiddenWolf),
                  buildFilterChip(wolfSeeder),
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
                    elevation: selectedMap[villager] ? 4 : 0,
                    label: Text('普通村民'),
                    selected: selectedMap[villager],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[villager] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    elevation: selectedMap[villager1] ? 4 : 0,
                    label: Text('普通村民'),
                    selected: selectedMap[villager1],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[villager1] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    elevation: selectedMap[villager2] ? 4 : 0,
                    label: Text('普通村民'),
                    selected: selectedMap[villager2],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[villager2] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    elevation: selectedMap[villager3] ? 4 : 0,
                    label: Text('普通村民'),
                    selected: selectedMap[villager3],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[villager3] = selected;
                      });
                    },
                  ),
                  FilterChip(
                    elevation: selectedMap[villager4] ? 4 : 0,
                    label: Text('普通村民'),
                    selected: selectedMap[villager4],
                    onSelected: (selected) {
                      setState(() {
                        selectedMap[villager4] = selected;
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
                  buildFilterChip(seer),
                  buildFilterChip(witch),
                  buildFilterChip(hunter),
                  buildFilterChip(guard),
                  buildFilterChip(idiot),
                  buildFilterChip(blackTrader),
                  buildFilterChip(graveyardKeeper),
                  buildFilterChip(knight),
                  buildFilterChip(cupid),
                  buildFilterChip(celebrity),
                  buildFilterChip(moderator),
                  buildFilterChip(tree),
                  buildFilterChip(magician),
                ],
              ),
            ),
            buildSubTitle('特殊'),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  buildFilterChip(slacker),
                  buildFilterChip(thief),
                  buildFilterChip(bride),
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildFilterChip(String roleName) {
    return FilterChip(
      elevation: selectedMap[roleName] ? 4 : 0,
      label: Text(roleName),
      selected: selectedMap[roleName],
      onSelected: (selected) {
        setState(() {
          selectedMap[roleName] = selected;
        });
      },
    );
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
