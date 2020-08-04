import 'package:flutter/material.dart';

import 'package:werewolfjudge/bloc/history_bloc.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("历史记录"),
        ),
        body: StreamBuilder(
          stream: roomHistoryBloc.rooms,
          builder: (_, AsyncSnapshot<List<Room>> snapshot) {
            if (snapshot.hasData) {
              var rooms = snapshot.data;
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[...buildChildren(rooms)],
                ),
              );
            }

            return Container(
              child: Text("空"),
            );
          },
        ));
  }

  List<Widget> buildChildren(List<Room> rooms) {
    return rooms.map((room) {
      var gridHeight = ((MediaQuery.of(context).size.width / 4) + 12) * ((room.players.length / 4).ceil());

      return Container(
        height: 300,
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(12),
                child: Wrap(
                  children: <Widget>[
                    Text("房间信息：${room.roomNumber}"),
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
                        for (var i in Iterable.generate(room.players.length))
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                elevation: 0,
                                child: InkWell(
                                  child: Stack(
                                    children: <Widget>[
                                      if (room.players[i] != null)
                                        Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: FutureBuilder(
                                              future: FirestoreProvider.instance.fetchPlayerDisplayName(room.players[i].uid) ?? "",
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
                        for (var i in Iterable.generate(room.players.length))
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Material(
                                color: ((room.players[i].role is Wolf)) ? Colors.red : Colors.orangeAccent,
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                elevation: 8,
                                child: InkWell(
                                  onTap: () {},
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
          ],
        ),
      );
    }).toList();
  }
}
