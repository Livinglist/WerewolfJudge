import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:werewolfjudge/model/player.dart';
import 'package:werewolfjudge/resource/firebase_auth_provider.dart';

import 'package:werewolfjudge/resource/firestore_provider.dart';

class RoomPage extends StatefulWidget {
  final String roomNumber;

  RoomPage({@required this.roomNumber}) : assert(roomNumber != null && roomNumber.length == 4);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int mySeatNumber;
  RoomStatus lastRoomStatus;

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
                if (snapshot.hasData && snapshot.data != null) {
                  var room = snapshot.data;

                  var players = room.players;

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
                    if (lastRoomStatus == RoomStatus.seating && room.roomStatus == RoomStatus.ongoing) {
                      lastRoomStatus = room.roomStatus;

                      switch (room.currentActionRole.runtimeType) {
                        case Guard:
                          print("Guard to go");
                          break;
                        case Wolf:
                          print("Wolf to go");
                          break;
                        case WolfQueen:
                          print("WolfQueen to go");
                          break;
                        case Witch:
                          print("Witch to go");
                          break;
                        case Seer:
                          print("Seer to go");
                          break;
                        case Hunter:
                          print("Hunter to go");
                          break;
                      }
                    }
                  }

                  return Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              Text("房间信息：\n"),
                            ],
                          )),
                      Stack(
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
                                        color: Colors.orangeAccent,
                                        borderRadius: BorderRadius.all(Radius.circular(16)),
                                        elevation: 8,
                                        child: InkWell(
                                          onTap: () => showEnterSeatDialog(i),
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
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: RaisedButton(
                          child: Text('开始游戏'),
                          onPressed: () {
                            if (players.values.where((element) => element != null).length != room.template.numberOfPlayers) {
                              showNotAllSeatedDialog();
                            } else {
                              showStartGameDialog();
                            }
                          },
                        ),
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

  void showStartGameDialog() {
    Widget continueButton = FlatButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context);

        FirestoreProvider.instance.startGame();
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
}
