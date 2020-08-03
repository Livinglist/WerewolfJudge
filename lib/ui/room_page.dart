import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:werewolfjudge/model/actionable_mixin.dart';
import 'package:werewolfjudge/model/player.dart';
import 'package:werewolfjudge/resource/firebase_auth_provider.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';
import 'package:werewolfjudge/resource/judge_audio_provider.dart';
import 'package:werewolfjudge/resource/role_image_provider.dart';

import 'components/black_trader_dialog.dart';

class RoomPage extends StatefulWidget {
  final String roomNumber;

  RoomPage({@required this.roomNumber}) : assert(roomNumber != null && roomNumber.length == 4);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final audioPlayer = AudioCache();
  final endingDuration = Duration(seconds: 0);

  ///Reserved for Magician.
  int anotherIndex;
  int mySeatNumber;
  RoomStatus lastRoomStatus;
  Role myRole;
  bool imHost = false,
      imActioner = false,
      showWolves = false,
      hasShown = false,
      firstNightEnded = false,
      imMagician = false,
      luckySonPlayed = false,
      hasShownLuckySonDialog = false,
      hasPlayedLuckSon = false;
  Room room;
  double gridHeight;

  @override
  void initState() {
    Wakelock.enable();

    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('房间${widget.roomNumber}')),
        body: FutureBuilder(
          future: FirebaseAuthProvider.instance.currentUser,
          builder: (_, AsyncSnapshot<FirebaseUser> userSnapshot) {
            var myUid = userSnapshot.data?.uid ?? '';

            return StreamBuilder(
              stream: FirestoreProvider.instance.fetchRoom(widget.roomNumber),
              builder: (_, AsyncSnapshot<Room> snapshot) {
                if (snapshot.hasData) {
                  room = snapshot.data;
                  gridHeight = gridHeight ?? ((MediaQuery.of(context).size.width / 4) + 12) * ((room.template.roles.length / 4).ceil());

                  var players = room.players;

                  //如果有魔术师
                  if (room.template.roles.map((e) => e.runtimeType).contains(Magician)) {}

                  Map<int, Player> seatToPlayerMap = Map.fromEntries(List.generate(room.template.roles.length, (index) {
                    return MapEntry<int, Player>(
                        index, players.values.singleWhere((element) => (element?.seatNumber ?? -1) == index, orElse: () => null));
                  }));

                  for (var i in Iterable.generate(players.length)) {
                    if (players[i] != null && players[i].uid == myUid) {
                      mySeatNumber = i;
                    }
                  }

                  if (myUid == room.hostUid) {
                    imHost = true;
                  } else {
                    imHost = false;
                  }

                  if (room.roomStatus != RoomStatus.seating) {
                    myRole = room.template.roles[mySeatNumber];

                    debugPrint("天黑");
                  }

                  if (room.roomStatus == RoomStatus.ongoing) {
                    if (room.currentActionRole == null) {
                      if (room.template.rolesType.contains(BlackTrader)) {
                        //firstNightEnded = false;
                        imActioner = false;
                        showWolves = false;

                        if (imHost && firstNightEnded == false) {
                          audioPlayer.play(JudgeAudioProvider.instance.night);

                          Timer(Duration(seconds: 6), () {
                            setState(() {
                              firstNightEnded = true;
                            });
                            audioPlayer.play(JudgeAudioProvider.instance.nightEnd);
                          });
                        }
                      } else {
                        firstNightEnded = true;
                        imActioner = false;
                        showWolves = false;

                        if (imHost) audioPlayer.play(JudgeAudioProvider.instance.nightEnd);
                      }
                    } else if (room.currentActionRole is LuckySon) {
                      imActioner = false;

                      if (hasShownLuckySonDialog == false) {
                        hasShownLuckySonDialog = true;

                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          showLuckySonVerificationDialog();
                        });
                      }
                    } else if (myRole.runtimeType == room.currentActionRole.runtimeType) {
                      //wolfking.runtimeType does not equal to wolf.runTimeType
                      imActioner = true;

                      if (hasShown == false) {
                        hasShown = true;

                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          if (room.currentActionerSkillStatus) {
                            if (myRole is Witch) {
                              showWitchActionDialog(room.killedIndex);
                            } else if (myRole is Hunter) {
                              showHunterStatusDialog(myRole as ActionableMixin);
                            } else if (myRole is WolfBrother) {
                              showWolfBrotherActionMessage(myRole as ActionableMixin);
                            } else {
                              showActionMessage(myRole as ActionableMixin);
                            }
                          } else {
                            showActionForbiddenDialog();
                          }
                        });
                      }

                      if (myRole is Wolf &&
                          myRole is Nightmare == false &&
                          myRole is Gargoyle == false &&
                          myRole is HiddenWolf == false &&
                          myRole is WolfRobot == false &&
                          myRole is WolfBrother == false) showWolves = true;
                    } else if (room.currentActionRole is Wolf &&
                        (myRole is WolfKing || myRole is WolfQueen || myRole is Nightmare || myRole is WolfBrother)) {
                      //showActionMessage((myRole as Wolf) as ActionableMixin);
                      imActioner = true;
                      showWolves = true;
                    } else {
                      imActioner = false;
                      showWolves = false;
                    }

                    if (imHost) {
                      String endAudioPath = JudgeAudioProvider.instance.getEndingAudio(room.lastActionRole);
                      String audioPath = JudgeAudioProvider.instance.getBeginningAudio(room.currentActionRole);

                      var timelapse = Duration(seconds: 5);

                      if (room.template.rolesType.contains(BlackTrader) == false ||
                          (room.template.rolesType.contains(BlackTrader) && hasPlayedLuckSon == false)) {
                        if (room.currentActionRole is LuckySon) hasPlayedLuckSon = true;

                        if (endAudioPath != null) {
                          audioPlayer.play(endAudioPath);
                        }

                        if (audioPath != null)
                          Timer(timelapse, () {
                            audioPlayer.play(audioPath);
                          });
                      }
                    }

//                    switch (room.currentActionRole.runtimeType) {
//                      case Guard:
//                        print("Guard to go");
//                        audioPlayer.play("guard.m4a");
//                        break;
//                      case Wolf:
//                        print("Wolf to go");
//                        audioPlayer.play("wolf.m4a");
//                        break;
//                      case WolfQueen:
//                        print("WolfQueen to go");
//                        audioPlayer.play("wolf_queen.m4a");
//                        break;
//                      case Witch:
//                        print("Witch to go");
//                        audioPlayer.play("witch.m4a");
//                        break;
//                      case Seer:
//                        print("Seer to go");
//                        audioPlayer.play("seer.m4a");
//                        break;
//                      case Hunter:
//                        audioPlayer.play("hunter.m4a");
//                        break;
//                    }
                  }

                  return Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(12),
                          child: Wrap(
                            children: <Widget>[
                              Text("房间信息：${room.roomInfo}"),
                            ],
                          )),
                      Container(
                        height: gridHeight,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              top: 20,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 4,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.0,
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  for (var i in Iterable.generate(room.template.roles.length))
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Material(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                          elevation: 0,
                                          child: InkWell(
                                            child: Stack(
                                              children: <Widget>[
                                                if (seatToPlayerMap[i] != null)
                                                  Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: FutureBuilder(
                                                        future: FirestoreProvider.instance.fetchPlayerDisplayName(seatToPlayerMap[i].uid),
                                                        builder: (_, AsyncSnapshot<String> userNameSnapshot) {
                                                          if (userNameSnapshot.hasData) {
                                                            return Text(
                                                              userNameSnapshot.data,
                                                              textAlign: TextAlign.center,
                                                            );
                                                          }
                                                          return Container();
                                                        },
                                                      ))
                                              ],
                                            ),
                                          )),
                                    )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 4,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.0,
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  for (var i in Iterable.generate(room.template.roles.length))
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Material(
                                          color: ((showWolves && room.players[i].role is Wolf) || ((anotherIndex ?? -1) == i))
                                              ? Colors.red
                                              : Colors.orangeAccent,
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                          elevation: 8,
                                          child: InkWell(
                                            onTap: () => onSeatTapped(i),
                                            borderRadius: BorderRadius.all(Radius.circular(16)),
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 12, top: 12),
                                                    child: Text((i + 1).toString()),
                                                  ),
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                                                ),
                                                if (mySeatNumber == i)
                                                  Align(
                                                    alignment: Alignment.bottomRight,
                                                    child: Container(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(right: 12, bottom: 12),
                                                        child: Icon(Icons.event_seat),
                                                      ),
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                                                    ),
                                                  )
//                                              else
//                                                Align(
//                                                  alignment: Alignment.bottomRight,
//                                                  child: Container(
//                                                    child: Padding(
//                                                      padding: EdgeInsets.only(right: 12, bottom: 12),
//                                                      child: Text((i + 1).toString()),
//                                                    ),
//                                                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
//                                                  ),
//                                                ),
                                              ],
                                            ),
                                          )),
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      if (imActioner)
                        Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(myRole is Wolf ? Wolf().actionMessage : (myRole as ActionableMixin).actionMessage)),
                      if (room.currentActionRole is LuckySon) Padding(padding: EdgeInsets.only(bottom: 12), child: Text("请确认自己是否是幸运儿")),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: buildPadding(children: [
                          if (room.currentActionRole is LuckySon)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                child: Text('查看礼物'),
                                onPressed: () {
                                  showGiftDialog();
                                },
                              ),
                            ),
                          if (imHost && room.roomStatus == RoomStatus.seating)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                child: Text('准备看牌'),
                                onPressed: () {
                                  if (players.values.where((element) => element != null).length != room.template.numberOfPlayers) {
                                    showNotAllSeatedDialog();
                                  } else {
                                    showFlipRoleCardDialog();
                                  }
                                },
                              ),
                            ),
                          if (imHost && room.roomStatus == RoomStatus.seated)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                child: Text('开始游戏'),
                                onPressed: () {
                                  showStartGameDialog();
                                },
                              ),
                            ),
                          if (imActioner && myRole is Hunter == false && myRole is BlackTrader == false)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                child: Text('不使用技能'),
                                onPressed: () {
                                  showActionConfirmDialog(-1);
                                },
                              ),
                            ),
                          if (imHost && firstNightEnded)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                child: Text('查看昨晚信息'),
                                onPressed: () {
                                  showLastNightConfirmDialog();
                                },
                              ),
                            ),
                          if (room.roomStatus != RoomStatus.seating)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                child: Text('查看身份'),
                                onPressed: () {
                                  showRoleCardDialog();
                                },
                              ),
                            ),
                        ]),
                      )
                    ],
                  );
                }

                return Center(
                  child: Text('无'),
                );
              },
            );
          },
        ));
  }

  void playEndingAudio() {
    var audioPath = JudgeAudioProvider.instance.getEndingAudio(room.currentActionRole);
    if (audioPath != null) audioPlayer.play(audioPath);
  }

  void onSeatTapped(int index) {
    if (room.roomStatus == RoomStatus.seating) {
      if (imHost == false && index == mySeatNumber)
        showLeaveSeatDialog(index);
      else
        showEnterSeatDialog(index);
    } else if (imActioner) {
      if (room.currentActionRole is Magician && anotherIndex == null) {
        setState(() {
          anotherIndex = index;
        });
      } else if (room.currentActionRole is BlackTrader) {
        if (index != mySeatNumber) showBlackTraderActionDialog(index);
      } else {
        showActionConfirmDialog(index);
      }
    }
  }

  showActionResultDialog(int index, String msg) {
    Widget continueButton = FlatButton(
        child: Text("确定"),
        onPressed: () {
          Navigator.pop(context);

          playEndingAudio();
          Timer(endingDuration, () => room.proceed(index));
        });

    AlertDialog alert = AlertDialog(
      title: Text("${index + 1}号是$msg。"),
      actions: [
        continueButton,
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showBlackTraderActionDialog(int giftedIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlackTraderDialog(
            index: giftedIndex,
            onCancel: () => Navigator.pop(context),
            onContinue: (Type giftedType) {
              Navigator.pop(context);
              playEndingAudio();
              Timer(endingDuration, () => room.proceed(giftedIndex, giftedByBlackTrader: giftedType));
            });
      },
    );
  }

  showWitchActionDialog(int killedIndex) {
    Widget cancelButton = FlatButton(
      child: Text("不救助"),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "救助",
        style: TextStyle(color: killedIndex == mySeatNumber ? Colors.grey : Colors.orange),
      ),
      onPressed: () {
        if (killedIndex == mySeatNumber) {
          ///Todo: no saving self
        } else {
          Navigator.pop(context);
          playEndingAudio();
          Timer(endingDuration, () => room.proceed(killedIndex, usePoison: false));
        }
      },
    );

    ///狼队空刀，无人倒台
    if (killedIndex == -1) {
      continueButton = FlatButton(
        child: Text(
          "好",
          style: TextStyle(color: killedIndex == mySeatNumber ? Colors.grey : Colors.orange),
        ),
        onPressed: () => Navigator.pop(context),
      );
    }

    AlertDialog alert = AlertDialog(
      title: Text(killedIndex == -1 ? "昨夜无人倒台" : "昨夜倒台玩家为${killedIndex + 1}号。"),
      content: Text(killedIndex == -1 ? "" : "是否救助?"),
      actions: [
        if (killedIndex != -1) cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showActionConfirmDialog(int index) {
    // set up the buttons
    Widget cancelButton = FlatButton(
        child: Text("取消"),
        onPressed: () {
          anotherIndex = null;
          Navigator.pop(context);
        });
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context);
        var msg = room.action(index);
        if (msg != null) {
          showActionResultDialog(index, msg);
        } else if (room.currentActionRole is Magician) {
          var target = anotherIndex + index * 100;

          anotherIndex = null;

          playEndingAudio();
          Timer(endingDuration, () => room.proceed(target));
        } else {
          playEndingAudio();
          Timer(endingDuration, () => room.proceed(index));
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(index == -1 ? "不发动技能" : "使用技能"),
      content: Text(index == -1
          ? "确定不发动技能吗？"
          : "确定${(myRole as ActionableMixin).actionConfirmMessage}${index + 1}号${anotherIndex == null ? "" : "和${anotherIndex + 1}号玩家"}?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showEnterSeatDialog(int index) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("取消"),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        FirestoreProvider.instance.takeSeat(widget.roomNumber, index, mySeatNumber).then((result) {
          Navigator.pop(context);

          if (result == -1) showConflictDialog(index);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("入座"),
      content: Text("确定在${index + 1}号位入座?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showLeaveSeatDialog(int index) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("取消"),
      onPressed: () => Navigator.pop(context),
    );

    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        mySeatNumber = null;

        FirestoreProvider.instance.leaveSeat(widget.roomNumber, index).then((_) => Navigator.pop(context));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("离席"),
      content: Text("确定离开${index + 1}号?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showConflictDialog(int index) {
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () => Navigator.pop(context),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("${index + 1}号座已被占用"),
      content: Text("请选择其他位置。"),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ///Confirm to see the last night information.
  void showLastNightConfirmDialog() {
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context);
        showLastNightInfoDialog();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("确定查看昨夜信息？"),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ///Confirm to see the last night information.
  void showLastNightInfoDialog() {
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("昨夜信息"),
      content: Text(room.lastNightInfo),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ///Display the role card.
  void showRoleCardDialog() {
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black,
      title: Text(
        "你的底牌是：",
        style: TextStyle(color: Colors.white),
      ),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(RoleImageProvider.instance[myRole], fit: BoxFit.fitHeight),
            Text(
              myRole.roleName,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ///Allowing everybody to see their role.
  void showFlipRoleCardDialog() {
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context);

        FirestoreProvider.instance.prepare();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("允许看牌？"),
      content: Text("所有座位已被占用。"),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ///Start the game.
  void showStartGameDialog() {
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context);

        audioPlayer.play(JudgeAudioProvider.instance.night);

        Timer(Duration(seconds: 8), () => room.startGame());
        //FirestoreProvider.instance.startGame();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("开始游戏？"),
      content: Text("所有座位已被占用。"),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ///If not all seated, then game cannot be started.
  void showNotAllSeatedDialog() {
    Widget continueButton = FlatButton(
      child: Text("好"),
      onPressed: () => Navigator.pop(context),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("无法开始游戏"),
      content: Text("有座位尚未被占用。"),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showWolfBrotherActionMessage(ActionableMixin actionableMixin) {
    Widget continueButton = FlatButton(
        child: Text("结束互认"),
        onPressed: () {
          Navigator.pop(context);
          //playEndingAudio();
          room.proceed(null);
        });

    AlertDialog alert = AlertDialog(
      title: Text(actionableMixin.actionMessage),
      content: Text(""),
      actions: [
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showActionMessage(ActionableMixin actionableMixin) {
    Widget continueButton = FlatButton(
      child: Text("好"),
      onPressed: () => Navigator.pop(context),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(actionableMixin.actionMessage),
      content: Text(""),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showHunterStatusDialog(ActionableMixin actionableMixin) {
    Widget continueButton = FlatButton(
      child: Text("好"),
      onPressed: () {
        Navigator.pop(context);
        playEndingAudio();
        Timer(endingDuration, () => room.proceed(null));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(actionableMixin.actionMessage),
      content: Text(room.hunterStatus ? "可以发动" : "不可发动"),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showWolfKingStatusDialog(ActionableMixin actionableMixin) {
    Widget continueButton = FlatButton(
      child: Text("好"),
      onPressed: () {
        Navigator.pop(context);

        playEndingAudio();
        Timer(endingDuration, () => room.proceed(null));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(actionableMixin.actionMessage),
      content: Text(room.wolfKingStatus ? "可以发动" : "不可发动"),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showActionForbiddenDialog() {
    Widget continueButton = FlatButton(
      child: Text("好"),
      onPressed: () {
        Navigator.pop(context);

        playEndingAudio();
        Timer(endingDuration, () => room.proceed(null));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("你的技能已被封锁"),
      content: Text('如果你是狼，请先讨论战术再点击"好"'),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showLuckySonVerificationDialog() {
    Widget continueButton = FlatButton(
      child: Text("好"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("请确认自己是否是幸运儿"),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showGiftDialog() {
    Widget continueButton = FlatButton(
      child: Text("确认"),
      onPressed: () {
        Navigator.pop(context);

        room.checkInForLuckySonVerifications(mySeatNumber);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(mySeatNumber == room.luckySonIndex ? "你收到了礼物" : "你没有收到礼物"),
      content: Text(mySeatNumber == room.luckySonIndex ? room.giftInfo : ''),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  List<Widget> buildPadding({List<Widget> children}) {
    for (int i = 1; i < children.length; i += 2) {
      children.insert(i, SizedBox(width: 12));
    }

    return children;
  }
}
