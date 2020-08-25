import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wakelock/wakelock.dart';
import 'package:werewolfjudge/bloc/history_bloc.dart';
import 'package:werewolfjudge/model/actionable_mixin.dart';
import 'package:werewolfjudge/resource/firebase_auth_provider.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';
import 'package:werewolfjudge/resource/judge_audio_provider.dart';
import 'package:werewolfjudge/resource/role_image_provider.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';

import 'components/black_trader_dialog.dart';

class RoomPage extends StatefulWidget {
  final String roomNumber;

  RoomPage({@required this.roomNumber}) : assert(roomNumber != null && roomNumber.length == 4);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final audioPlayer = AudioPlayer();
  final endingDuration = Duration(seconds: 1);
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ///Reserved for Magician.
  int anotherIndex;
  int mySeatNumber;
  Role myRole;
  bool imHost = false,
      imActioner = false,
      showWolves = false,
      hasShown = false,
      firstNightEnded = false,
      imMagician = false,
      luckySonPlayed = false,
      hasShownLuckySonDialog = false,
      hasPlayedLuckSon = false,
      artworkEnabled = false,
      hasSkilledWolf = false,
      giftDialogShowed = false;
  Room room;
  double gridHeight;

  ///天亮后的发言顺序
  String orderMsg;

  @override
  void initState() {
    Wakelock.enable();

    artworkEnabled = SharedPreferencesProvider.instance.getArtworkEnabled();

    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    audioPlayer.dispose();
    super.dispose();
  }

  @Deprecated('Overwrite leading button is more customizable.')
  Future<bool> onWillPop() async {
    if (room.roomStatus == RoomStatus.terminated) return true;

    Widget cancelButton = FlatButton(
      child: Text("取消"),
      onPressed: () => Navigator.pop(context, false),
    );

    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("离开房间？"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myUid = FirebaseAuthProvider.instance.currentUser.uid;

    return WillPopScope(
        child: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    if (room.roomStatus == RoomStatus.terminated) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      return null;
                    }

                    Widget cancelButton = FlatButton(
                      child: Text("取消"),
                      onPressed: () => Navigator.pop(context),
                    );

                    Widget continueButton = FlatButton(
                      child: Text("确定"),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    );

                    AlertDialog alert = AlertDialog(
                      title: Text("离开房间？"),
                      actions: [
                        cancelButton,
                        continueButton,
                      ],
                    );

                    return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  },
                ),
                title: Text('房间${widget.roomNumber}')),
            body: StreamBuilder(
              stream: FirestoreProvider.instance.fetchRoom(widget.roomNumber),
              builder: (_, AsyncSnapshot<Room> snapshot) {
                if (snapshot.hasData) {
                  room = snapshot.data;
                  gridHeight ??= ((MediaQuery.of(context).size.width / 4) + 12) * ((room.template.roles.length / 4).ceil());
                  hasSkilledWolf ??= room.hasSkilledWolf;

                  var players = room.players;

                  var seatToPlayerMap = room.players;

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

                  if (room.roomStatus != RoomStatus.seating && mySeatNumber != null) {
                    myRole = room.template.roles[mySeatNumber];

                    debugPrint("天黑");
                  }

                  if (room.roomStatus == RoomStatus.ongoing) {
                    if (room.currentActionRole == null) {
                      firstNightEnded = true;
                      imActioner = false;
                      showWolves = false;
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
                          Timer(Duration(seconds: 3), () {
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
                        });
                      }

                      if (myRole is Wolf &&
                          myRole is Nightmare == false &&
                          myRole is Gargoyle == false &&
                          myRole is HiddenWolf == false &&
                          myRole is WolfRobot == false &&
                          myRole is WolfBrother == false) {
                        showWolves = true;
                      }

                      //如果有与普通狼人见面的技能狼，普狼不能开刀
                      if (room.currentActionRole.runtimeType == Wolf) {
                        if (room.hasSkilledWolf && myRole.runtimeType == Wolf) {
                          imActioner = false;
                        } else if (mySeatNumber == room.actionWolfIndex) {
                          imActioner = true;
                        } else {
                          imActioner = false;
                        }
                      }
                    } else if (room.currentActionRole is Wolf &&
                        (myRole is WolfKing || myRole is WolfQueen || myRole is Nightmare || myRole is WolfBrother || myRole is BloodMoon)) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        Timer(Duration(seconds: 3), () {
                          if (room.currentActionerSkillStatus)
                            showActionMessage(Wolf());
                          else
                            showActionForbiddenDialog();
                        });
                      });
                      imActioner = true;
                      showWolves = true;
                    } else {
                      imActioner = false;
                      showWolves = false;
                    }

                    print("firstNightEnded: $firstNightEnded");

                    if (imHost && room.roomStatus != RoomStatus.terminated) {
                      if (firstNightEnded) {
                        if (room.template.rolesType.contains(BlackTrader)) {
                          String endAudioPath = JudgeAudioProvider.instance.night;
                          String audioPath = JudgeAudioProvider.instance.nightEnd;

                          var timelapse = Duration(seconds: 5);

                          playAudio(endAudioPath);

                          Timer(timelapse, () {
                            playAudio(audioPath);
                            room.terminate();
                          });
                        } else {
                          String endAudioPath = JudgeAudioProvider.instance.getEndingAudio(room.lastActionRole);
                          var timelapse = Duration(seconds: 5);
                          playAudio(endAudioPath);
                          Timer(timelapse, () {
                            playAudio(JudgeAudioProvider.instance.nightEnd);
                            room.terminate();
                          });
                        }
                      } else {
                        String endAudioPath = JudgeAudioProvider.instance.getEndingAudio(room.lastActionRole);
                        String audioPath = JudgeAudioProvider.instance.getBeginningAudio(room.currentActionRole);

                        var timelapse = Duration(seconds: 5);

                        if (room.template.rolesType.contains(BlackTrader) == false ||
                            (room.template.rolesType.contains(BlackTrader) && hasPlayedLuckSon == false)) {
                          if (room.currentActionRole is LuckySon) hasPlayedLuckSon = true;

                          if (endAudioPath != null) {
                            playAudio(endAudioPath);
                          }

                          if (audioPath != null)
                            Timer(timelapse, () {
                              playAudio(audioPath);
                            });
                        }
                      }
                    }
                  } else if (room.roomStatus == RoomStatus.terminated) {
                    firstNightEnded = true;
                  }

                  String actionMessage;

                  if (imActioner) {
                    if (room.currentActionRole.runtimeType == Wolf) {
                      actionMessage = Wolf().actionMessage;
                    } else
                      actionMessage = (myRole as ActionableMixin).actionMessage;
                  }

                  print("currentRole is ${room.currentActionRole}");
                  print("currentRole.runtimeType is ${room.currentActionRole.runtimeType}");
                  print("${room.currentActionRole is Wolf}");
                  print("${room.currentActionRole.runtimeType is Wolf}");
                  print("myRole is $myRole");
                  print("myRole.runtimeType is ${myRole.runtimeType}");

                  bool scrollable = gridHeight > MediaQuery.of(context).size.height;

                  Widget child = Column(
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
                                                              maxLines: 1,
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
                                        color: ((showWolves &&
                                                    room.players[i].role is Wolf &&
                                                    room.players[i].role.runtimeType != WolfRobot &&
                                                    room.players[i].role.runtimeType != Gargoyle) ||
                                                ((anotherIndex ?? -1) == i))
                                            ? Colors.red
                                            : Colors.orange,
                                        borderRadius: BorderRadius.all(Radius.circular(16)),
                                        elevation: 8,
                                        child: Stack(
                                          children: <Widget>[
                                            if (seatToPlayerMap[i] != null)
                                              Positioned.fill(
                                                child: FutureBuilder(
                                                  future: FirestoreProvider.instance.getAvatar(seatToPlayerMap[i].uid),
                                                  builder: (_, AsyncSnapshot<String> urlSnapshot) {
                                                    if (urlSnapshot.hasData && urlSnapshot != null) {
                                                      var url = urlSnapshot.data;
                                                      return Stack(
                                                        children: <Widget>[
                                                          Positioned.fill(
                                                              child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(13),
                                                            child: FadeInImage.memoryNetwork(
                                                              placeholder: kTransparentImage,
                                                              image: url,
                                                              fit: BoxFit.cover,
                                                              width: 26,
                                                              height: 26,
                                                            ),
                                                          )),
                                                          Positioned.fill(
                                                              child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(13),
                                                            child: BackdropFilter(
                                                                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                                                child: Container(
                                                                    width: 26,
                                                                    height: 26,
                                                                    decoration: BoxDecoration(
                                                                        color: ((showWolves &&
                                                                                    room.players[i].role is Wolf &&
                                                                                    room.players[i].role.runtimeType != WolfRobot &&
                                                                                    room.players[i].role.runtimeType != Gargoyle) ||
                                                                                ((anotherIndex ?? -1) == i))
                                                                            ? Colors.red.shade400.withOpacity(0.8)
                                                                            : Colors.grey.shade200.withOpacity(0.5)),
                                                                    child: Container())),
                                                          )),
                                                        ],
                                                      );
                                                    }

                                                    return Container();
                                                  },
                                                ),
                                              ),
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
                                                    padding: EdgeInsets.only(right: 8, bottom: 8),
                                                    child: Icon(Icons.event_seat),
                                                  ),
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                                                ),
                                              ),
                                            Positioned.fill(
                                              child: InkWell(
                                                onTap: () => onSeatTapped(i),
                                                splashColor: Colors.orangeAccent,
                                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (scrollable == false) Spacer(),
                      if (imActioner) Padding(padding: EdgeInsets.only(bottom: 12), child: Text(actionMessage)),
                      if (room.currentActionRole is LuckySon) Padding(padding: EdgeInsets.only(bottom: 12), child: Text("请确认自己是否是幸运儿")),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: buildPadding(children: [
                          if (room.currentActionRole is LuckySon && giftDialogShowed == false)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                shape: StadiumBorder(),
                                child: Text('查看礼物'),
                                onPressed: () {
                                  if (giftDialogShowed == false) showGiftDialog();
                                },
                              ),
                            ),
                          if (imHost && room.roomStatus == RoomStatus.seating)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                shape: StadiumBorder(),
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
                                color: Theme.of(context).primaryColor,
                                shape: StadiumBorder(),
                                child: Text('开始游戏'),
                                onPressed: () {
                                  showStartGameDialog();
                                },
                              ),
                            ),
                          if (imActioner && myRole is! Hunter && myRole is! BlackTrader && myRole is! WolfRobot)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                shape: StadiumBorder(),
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
                                color: Theme.of(context).primaryColor,
                                shape: StadiumBorder(),
                                child: Text('查看昨晚信息'),
                                onPressed: () {
                                  showLastNightConfirmDialog();
                                },
                              ),
                            ),
                          if (room.roomStatus != RoomStatus.seating && mySeatNumber != null)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                shape: StadiumBorder(),
                                child: Text('查看身份'),
                                onPressed: () {
                                  showRoleCardDialog();
                                },
                              ),
                            ),
                          if (room.roomStatus == RoomStatus.seating && mySeatNumber != null)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: RaisedButton(
                                color: Colors.grey,
                                shape: StadiumBorder(),
                                child: Text('查看身份'),
                                onPressed: () {
                                  scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text('等待其他玩家入座'),
                                    action: SnackBarAction(label: '好', onPressed: () => scaffoldKey.currentState.hideCurrentSnackBar()),
                                  ));
                                },
                              ),
                            ),
                        ]),
                      ),
                      SizedBox(height: 12)
                    ],
                  );

                  return scrollable ? SingleChildScrollView(child: child) : child;
                }

                return Center(
                  child: Text('无'),
                );
              },
            )),
        onWillPop: () => Future.value(false));
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
          scaffoldKey.currentState.hideCurrentSnackBar();
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('女巫无法自救'),
            action: SnackBarAction(label: '惨', onPressed: () => scaffoldKey.currentState.hideCurrentSnackBar()),
          ));
        } else {
          Navigator.pop(context);
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

        //如果index为-1，则视为不发动技能
        if (index == -1) {
          Timer(endingDuration, () => room.proceed(null));
          return;
        }

        var msg = room.action(index);
        if (msg != null) {
          showActionResultDialog(index, msg);
        } else if (room.currentActionRole is Magician) {
          var target = anotherIndex + index * 100;

          anotherIndex = null;

          Timer(endingDuration, () => room.proceed(target));
        } else {
          Timer(endingDuration, () => room.proceed(index));
        }
      },
    );

    String msg;

    if (index == -1) {
      msg = "确定不发动技能吗？";
    } else if (room.currentActionRole.runtimeType == Wolf) {
      msg = "确定${Wolf().actionConfirmMessage}${index + 1}号玩家?";
    } else {
      msg = "确定${(myRole as ActionableMixin).actionConfirmMessage}${index + 1}号${anotherIndex == null ? "" : "和${anotherIndex + 1}号玩家"}?";
    }

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(index == -1 ? "不发动技能" : "使用技能"),
      content: Text(msg),
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
    Widget cancelButton = FlatButton(
      child: Text("取消"),
      onPressed: () => Navigator.pop(context),
    );

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

    bool showArtwork = this.artworkEnabled;

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black,
      title: Text(
        "你的底牌是：",
        style: TextStyle(color: Colors.white),
      ),
      content: showArtwork
          ? Container(
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
            )
          : Text(
              myRole.roleName,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
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

        playAudio(JudgeAudioProvider.instance.night);

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
      barrierDismissible: false,
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

        if (imActioner) Timer(endingDuration, () => room.proceed(null));
      },
    );

    String title = '你的技能已被封锁', msg = '点击"好"后请闭眼';
    if (myRole is Wolf) {
      title = '狼队的技能已被封锁';
      if (imActioner)
        msg = '请先讨论战术再点击"好"';
      else
        msg = '';
    }

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
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

        giftDialogShowed = true;
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(mySeatNumber == room.luckySonIndex ? "你收到了礼物" : "你没有收到礼物"),
      content: Text(mySeatNumber == room.luckySonIndex ? room.giftInfo : ''),
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

  List<Widget> buildPadding({List<Widget> children}) {
    for (int i = 1; i < children.length; i += 2) {
      children.insert(i, SizedBox(width: 12));
    }

    return children;
  }

  void playAudio(String audioPath) async {
    print("The audio path is $audioPath");

    var tempDir = await getTemporaryDirectory();
    var tempPath = tempDir.path + '/' + audioPath.replaceFirst('/', '_');
    File file = File(tempPath);
    var audioFile = await rootBundle.load('assets/' + audioPath);
    file.writeAsBytes(audioFile.buffer.asUint8List()).whenComplete(() => audioPlayer.play(tempPath));
  }
}
