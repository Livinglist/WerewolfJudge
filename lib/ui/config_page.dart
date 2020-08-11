import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
const String wolfQueen = '狼美人';
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
const String witcher = '猎魔人';
const String bloodMoon = '血月使徒';
const String pervert = '老流氓';
const String wolfRobot = '机械狼';
const String psychic = '通灵师';
const String wolfBrother = '狼兄';

class _ConfigPageState extends State<ConfigPage> {
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
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
    witcher: false,
    bloodMoon: false,
    pervert: false,
    wolfRobot: false,
    psychic: false,
    wolfBrother: false,
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
        key: scaffoldKey,
        backgroundColor: Colors.orange,
        appBar: AppBar(
          title: Text('创建房间 ${selectedMap.values.toList().where((e) => e).length}人'),
          elevation: showShadow ? 8 : 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                CustomTemplate template;
                List<Role> roles = [];
                var selectedEntries = selectedMap.entries.where((element) => element.value).toList();

                if (selectedEntries.isEmpty) {
                  scaffoldKey.currentState.hideCurrentSnackBar();
                  scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('没有选择角色'), backgroundColor: Colors.red));
                  return;
                }

                for (var i in selectedEntries) {
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
                      roles.add(LuckySon());
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
                    case bride:
                      roles.add(Bride());
                      break;
                    case thief:
                      roles.add(Thief());
                      break;
                    case witcher:
                      roles.add(Witcher());
                      break;
                    case bloodMoon:
                      roles.add(BloodMoon());
                      break;
                    case pervert:
                      roles.add(Pervert());
                      break;
                    case wolfRobot:
                      roles.add(WolfRobot());
                      break;
                    case psychic:
                      roles.add(Psychic());
                      break;
                    case wolfBrother:
                      roles.add(WolfBrother());
                      break;
                    default:
                      throw Exception("Unmatched role: ${i.key}");
                  }
                }

                print(roles);

                template = CustomTemplate.newGame(roles: roles);

                FirebaseAuthProvider.instance.currentUser.then((user) {
                  FirestoreProvider.instance.newRoom(uid: user.uid, template: template).then((roomNumber) {
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
            buildSubTitle('常见模板'),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  ActionChip(
                      avatar: Icon(
                        FontAwesomeIcons.chessQueen,
                        size: 12,
                      ),
                      label: Text('狼美守卫12人'),
                      onPressed: () {
                        setState(() {
                          for (var i in selectedMap.keys) {
                            selectedMap[i] = false;
                          }

                          selectedMap[villager] = true;
                          selectedMap[villager1] = true;
                          selectedMap[villager2] = true;
                          selectedMap[villager3] = true;
                          selectedMap[wolf] = true;
                          selectedMap[wolf1] = true;
                          selectedMap[wolf2] = true;
                          selectedMap[wolfQueen] = true;
                          selectedMap[seer] = true;
                          selectedMap[witch] = true;
                          selectedMap[hunter] = true;
                          selectedMap[guard] = true;
                        });
                      }),
                  ActionChip(
                      avatar: Icon(
                        FontAwesomeIcons.dollarSign,
                        size: 12,
                      ),
                      label: Text('狼兄黑商12人'),
                      onPressed: () {
                        setState(() {
                          for (var i in selectedMap.keys) {
                            selectedMap[i] = false;
                          }

                          selectedMap[villager] = true;
                          selectedMap[villager1] = true;
                          selectedMap[villager2] = true;
                          selectedMap[villager3] = true;
                          selectedMap[wolf] = true;
                          selectedMap[wolf1] = true;
                          selectedMap[hiddenWolf] = true;
                          selectedMap[wolfBrother] = true;
                          selectedMap[seer] = true;
                          selectedMap[witch] = true;
                          selectedMap[hunter] = true;
                          selectedMap[blackTrader] = true;
                        });
                      }),
                  ActionChip(
                      avatar: Text(
                        'tombstone',
                        style: TextStyle(fontSize: 12, fontFamily: 'Solid'),
                        textAlign: TextAlign.center,
                      ),
                      label: Text('石像鬼守墓人12人'),
                      onPressed: () {
                        setState(() {
                          for (var i in selectedMap.keys) {
                            selectedMap[i] = false;
                          }

                          selectedMap[villager] = true;
                          selectedMap[villager1] = true;
                          selectedMap[villager2] = true;
                          selectedMap[villager3] = true;
                          selectedMap[wolf] = true;
                          selectedMap[wolf1] = true;
                          selectedMap[wolf2] = true;
                          selectedMap[gargoyle] = true;
                          selectedMap[seer] = true;
                          selectedMap[witch] = true;
                          selectedMap[hunter] = true;
                          selectedMap[graveyardKeeper] = true;
                        });
                      }),
                  ActionChip(
                      avatar: Icon(
                        FontAwesomeIcons.solidEye,
                        size: 12,
                      ),
                      label: Text('梦魇守卫12人'),
                      onPressed: () {
                        setState(() {
                          for (var i in selectedMap.keys) {
                            selectedMap[i] = false;
                          }

                          selectedMap[villager] = true;
                          selectedMap[villager1] = true;
                          selectedMap[villager2] = true;
                          selectedMap[villager3] = true;
                          selectedMap[wolf] = true;
                          selectedMap[wolf1] = true;
                          selectedMap[wolf2] = true;
                          selectedMap[nightmare] = true;
                          selectedMap[seer] = true;
                          selectedMap[witch] = true;
                          selectedMap[hunter] = true;
                          selectedMap[guard] = true;
                        });
                      }),
                  ActionChip(
                      avatar: Icon(
                        FontAwesomeIcons.solidMoon,
                        size: 12,
                      ),
                      label: Text('血月猎魔12人'),
                      onPressed: () {
                        setState(() {
                          for (var i in selectedMap.keys) {
                            selectedMap[i] = false;
                          }

                          selectedMap[villager] = true;
                          selectedMap[villager1] = true;
                          selectedMap[villager2] = true;
                          selectedMap[villager3] = true;
                          selectedMap[wolf] = true;
                          selectedMap[wolf1] = true;
                          selectedMap[wolf2] = true;
                          selectedMap[bloodMoon] = true;
                          selectedMap[seer] = true;
                          selectedMap[witch] = true;
                          selectedMap[idiot] = true;
                          selectedMap[witcher] = true;
                        });
                      }),
                  ActionChip(
                      avatar: Icon(
                        FontAwesomeIcons.hornbill,
                        size: 12,
                      ),
                      label: Text('狼王摄梦人12人'),
                      onPressed: () {
                        setState(() {
                          for (var i in selectedMap.keys) {
                            selectedMap[i] = false;
                          }

                          selectedMap[villager] = true;
                          selectedMap[villager1] = true;
                          selectedMap[villager2] = true;
                          selectedMap[villager3] = true;
                          selectedMap[wolf] = true;
                          selectedMap[wolf1] = true;
                          selectedMap[wolf2] = true;
                          selectedMap[wolfKing] = true;
                          selectedMap[seer] = true;
                          selectedMap[witch] = true;
                          selectedMap[hunter] = true;
                          selectedMap[celebrity] = true;
                        });
                      }),
                  ActionChip(
                      avatar: Icon(
                        FontAwesomeIcons.magic,
                        size: 12,
                      ),
                      label: Text('狼王魔术师12人'),
                      onPressed: () {
                        setState(() {
                          for (var i in selectedMap.keys) {
                            selectedMap[i] = false;
                          }

                          selectedMap[villager] = true;
                          selectedMap[villager1] = true;
                          selectedMap[villager2] = true;
                          selectedMap[villager3] = true;
                          selectedMap[wolf] = true;
                          selectedMap[wolf1] = true;
                          selectedMap[wolf2] = true;
                          selectedMap[wolfKing] = true;
                          selectedMap[seer] = true;
                          selectedMap[witch] = true;
                          selectedMap[hunter] = true;
                          selectedMap[magician] = true;
                        });
                      }),
                  ActionChip(
                      avatar: Icon(
                        FontAwesomeIcons.robot,
                        size: 12,
                      ),
                      label: Text('机械狼通灵师12人'),
                      onPressed: () {
                        setState(() {
                          for (var i in selectedMap.keys) {
                            selectedMap[i] = false;
                          }

                          selectedMap[villager] = true;
                          selectedMap[villager1] = true;
                          selectedMap[villager2] = true;
                          selectedMap[villager3] = true;
                          selectedMap[wolf] = true;
                          selectedMap[wolf1] = true;
                          selectedMap[wolf2] = true;
                          selectedMap[wolfRobot] = true;
                          selectedMap[psychic] = true;
                          selectedMap[witch] = true;
                          selectedMap[hunter] = true;
                          selectedMap[guard] = true;
                        });
                      }),
                ],
              ),
            ),
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
                  buildFilterChip(bloodMoon),
                  buildFilterChip(wolfRobot),
                  buildFilterChip(wolfBrother)
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
                  buildFilterChip(pervert),
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
                  buildFilterChip(celebrity),
                  buildFilterChip(moderator),
                  buildFilterChip(tree),
                  buildFilterChip(magician),
                  buildFilterChip(witcher),
                  buildFilterChip(psychic),
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
                  buildFilterChip(cupid),
                  buildFilterChip(thief),
                  buildFilterChip(bride),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "备注",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            Divider(),
            Padding(padding: EdgeInsets.only(left: 12), child: Text("该应用可以充当第一夜法官的板子有：狼美守卫, 狼兄黑商, 石像鬼守墓人, 梦魇守卫, 血月猎魔, 狼王摄梦人, 狼王魔术师, 机械狼通灵师。")),
            SizedBox(
              height: 36,
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
