import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:werewolfjudge/model/room.dart';
import 'package:werewolfjudge/model/template.dart';

import 'firebase_auth_provider.dart';

export 'package:werewolfjudge/model/room.dart';

const String rooms = 'rooms';
const String roomStatusKey = 'roomStatus';
const String timestamp = 'timestamp';
const String totalSeats = 'totalSeats';
const String hostUidKey = 'hostUid';
const String roomStatus = 'roomStatus';
const String playersKey = 'players';
const String rolesKey = 'roles';
const String actionsKey = 'actions';

class FirestoreProvider {
  static final instance = FirestoreProvider._();

  String currentRoomNumber;

  FirestoreProvider._();

  Future<String> fetchPlayerDisplayName(String uid) async {
    DocumentReference docRef = Firestore.instance.collection(usersKey).document(uid);
    DocumentSnapshot docSnap = await docRef.get();

    return docSnap[userNameKey];
  }

  ///Create a room using [uid] of host and [numOfSeats]
  Future<String> newRoom({String uid, int numOfSeats, Template template}) async {
    DocumentReference docRef;
    DocumentSnapshot docSnap;
    String roomNum;

    do {
      roomNum = generateRoomNumber().toString();
      docRef = Firestore.instance.collection(rooms).document(roomNum);
      docSnap = await docRef.get();
    } while (docSnap.exists && DateTime.fromMillisecondsSinceEpoch(docSnap.data[timestamp]).toLocal().difference(DateTime.now()).inHours <= 2);

    docRef.delete().whenComplete(() => docRef.setData({
          timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
          totalSeats: numOfSeats,
          hostUidKey: uid,
          roomStatus: RoomStatus.seating.index,
          rolesKey: template.roles.map((e) => Player.roleToIndex(e)).toList(),
          playersKey: Map.fromEntries(List.generate(template.roles.length, (index) => MapEntry(index.toString(), null))),
        }));

    currentRoomNumber = roomNum;

    return roomNum;
  }

  ///Check whether or not the room number is valid.
  Future<bool> checkRoom(String roomNum) async {
    return Firestore.instance.collection(rooms).document(roomNum).get().then((value) {
      if (value.exists == false) return false;
      if (DateTime.fromMillisecondsSinceEpoch(value.data[timestamp]).toLocal().difference(DateTime.now()).inHours >= 2) return false;

      currentRoomNumber = roomNum;

      return true;
    });
  }

  Stream<Room> fetchRoom(String roomNum) {
    return Firestore.instance.collection(rooms).document(roomNum).snapshots().transform<Room>(StreamTransformer.fromHandlers(handleData: handleDate));
  }

  Future<int> takeSeat(String roomNumber, int seatNumber, [int currentSeatNumber]) async {
    DocumentReference docRef = Firestore.instance.collection(rooms).document(roomNumber);
    DocumentSnapshot docSnap = await docRef.get();
    String playerUid = await FirebaseAuthProvider.instance.currentUser.then((value) => value.uid);

    List<Player> playersSeated = [];

    if (docSnap.data[playersKey][seatNumber.toString()] != null) {
      return -1;
    }

    if (currentSeatNumber != null) {
      return docRef.setData({
        playersKey: {
          seatNumber.toString(): Player(uid: playerUid, seatNumber: seatNumber).toMap(),
          currentSeatNumber.toString(): null,
        },
      }, merge: true).then((value) => 0);
    } else {
      return docRef.setData({
        playersKey: {
          seatNumber.toString(): Player(uid: playerUid, seatNumber: seatNumber).toMap(),
        },
      }, merge: true).then((value) => 0);
    }
  }

  static int generateRoomNumber() {
    int roomNumber = (Random(DateTime.now().millisecondsSinceEpoch).nextDouble() * 10000).toInt();
    return roomNumber;
  }

  static void handleDate(DocumentSnapshot docSnap, Sink sink) {
    var roomNumber = docSnap.documentID;

    var roomStatus = RoomStatus.values.elementAt(docSnap.data[roomStatusKey] ?? 0);

    var hostUid = docSnap.data[hostUidKey];

    var roles = (docSnap.data[rolesKey]).map((e) => Player.indexToRole(e)).toList();

    var players = (docSnap.data[playersKey] as Map).map((k, e) => MapEntry(int.parse(k), e == null ? null : Player.fromMap(e)));

    var template = WolfQueenTemplate.from(roles: roles);

    ///Todo: Currently for experiment, support only one template. Add support for other template.
    Room room = Room.from(hostUid: hostUid, roomNumber: roomNumber, template: template, roomStatus: roomStatus);

    room.players.clear();
    room.players.addAll(players);

    sink.add(room);
  }

  void startGame() {
    DocumentReference docRef = Firestore.instance.collection(rooms).document(currentRoomNumber);

    docRef.setData({roomStatusKey: RoomStatus.ongoing.index}, merge: true);
  }

  void performAction(Role role, int targetSeat) {
    DocumentReference docRef = Firestore.instance.collection(rooms).document(currentRoomNumber);

    docRef.setData({
      actionsKey: {
        Player.roleToIndex(role).toString(): targetSeat,
      }
    }, merge: true);
  }
}
