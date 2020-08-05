import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:werewolfjudge/model/room.dart';
import 'package:werewolfjudge/model/template.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';

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
const String currentActionerIndexKey = 'currentActionerIndex';
const String hasPosionKey = 'hasPoison';
const String hasAntidoteKey = 'hasAntidote';
const String luckySonVerificationsCountKey = 'luckySonVerificationsCount';

class FirestoreProvider {
  static final instance = FirestoreProvider._();

  String currentRoomNumber;

  FirestoreProvider._();

  Future<String> fetchPlayerDisplayName(String uid) async {
    DocumentReference docRef = Firestore.instance.collection(usersKey).document(uid);
    DocumentSnapshot docSnap = await docRef.get();

    if (docSnap.exists) return docSnap[userNameKey];

    return '无名氏';
  }

  ///Create a room using [uid] of host and [numOfSeats]
  Future<String> newRoom({String uid, Template template}) async {
    DocumentReference docRef;
    DocumentSnapshot docSnap;
    String roomNum;

    do {
      roomNum = generateRoomNumber();
      docRef = Firestore.instance.collection(rooms).document(roomNum);
      docSnap = await docRef.get();
    } while (docSnap.exists &&
        (DateTime.fromMillisecondsSinceEpoch(docSnap.data[timestamp]).toLocal().difference(DateTime.now()).inHours <= 2 ||
            RoomStatus.values.elementAt(docSnap.data[roomStatusKey]) != RoomStatus.terminated));

    docRef.delete().whenComplete(() => docRef.setData({
          actionsKey: {},
          hasPosionKey: true,
          hasAntidoteKey: true,
          timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
          hostUidKey: uid,
          roomStatus: RoomStatus.seating.index,
          rolesKey: template.roles.map((e) => Player.roleToIndex(e)).toList(),
          playersKey: Map.fromEntries(List.generate(template.roles.length, (index) => MapEntry(index.toString(), null))),
          currentActionerIndexKey: 0,
        }));

    currentRoomNumber = roomNum;

    SharedPreferencesProvider.instance.setLastRoom(roomNum);

    print("The room number in newRoom() is $roomNum");

    return roomNum;
  }

  ///Check whether or not the room number is valid.
  Future<bool> checkRoom(String roomNum) async {
    return Firestore.instance.collection(rooms).document(roomNum).get().then((value) {
      if (value.exists == false) return false;
      if (DateTime.fromMillisecondsSinceEpoch(value.data[timestamp]).toLocal().difference(DateTime.now()).inHours >= 2) return false;

      SharedPreferencesProvider.instance.setLastRoom(roomNum);

      return true;
    });
  }

  Future<void> terminateRoom(String roomNum) async {
    var docRef = Firestore.instance.collection(rooms).document(roomNum);

    return docRef.setData({roomStatusKey: RoomStatus.terminated.index}, merge: true);
  }

  Stream<Room> fetchRoom(String roomNum) {
    currentRoomNumber = roomNum;
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

    int roleIndex = docSnap.data[rolesKey][seatNumber];
    Role role = Player.indexToRole(roleIndex);

    if (currentSeatNumber != null) {
      return docRef.setData({
        playersKey: {
          seatNumber.toString(): Player(uid: playerUid, seatNumber: seatNumber, role: role).toMap(),
          currentSeatNumber.toString(): null,
        },
      }, merge: true).then((value) => 0);
    } else {
      return docRef.setData({
        playersKey: {
          seatNumber.toString(): Player(uid: playerUid, seatNumber: seatNumber, role: role).toMap(),
        },
      }, merge: true).then((value) => 0);
    }
  }

  Future<int> leaveSeat(String roomNumber, int seatNumber) async {
    DocumentReference docRef = Firestore.instance.collection(rooms).document(roomNumber);
    DocumentSnapshot docSnap = await docRef.get();

    if (docSnap.data[playersKey][seatNumber.toString()] == null) {
      return -1;
    }

    print("the seat number is $seatNumber");

    return docRef.setData({
      playersKey: {
        seatNumber.toString(): null,
      },
    }, merge: true).then((value) => 0);
  }

  static String generateRoomNumber() {
    String roomNumber;

    do {
      roomNumber = (Random(DateTime.now().millisecondsSinceEpoch).nextDouble() * 10000).toInt().toString();
    } while (roomNumber.length != 4);

    return roomNumber;
  }

  static void handleDate(DocumentSnapshot docSnap, Sink sink) {
    print("asd1");
    var actions = (docSnap.data[actionsKey] as Map<String, dynamic>)
        .map((key, value) => MapEntry(Player.indexToRole(int.parse(key)).runtimeType, value as int));
    print("asd2");
    var roomNumber = docSnap.documentID;
    var roomStatus = RoomStatus.values.elementAt(docSnap.data[roomStatusKey] ?? 0);
    var hostUid = docSnap.data[hostUidKey];
    var roles = (docSnap.data[rolesKey]).map((e) => Player.indexToRole(e)).toList();
    var players = (docSnap.data[playersKey] as Map).map((k, e) => MapEntry(int.parse(k), e == null ? null : Player.fromMap(e)));
    var template = CustomTemplate.from(roles: roles);
    var timestamp = docSnap.data[timestampKey];
    var currentActionerIndex = docSnap.data[currentActionerIndexKey] ?? 0;

    var hasPoison = docSnap.data[hasPosionKey] ?? true;
    var hasAntidote = docSnap.data[hasAntidoteKey] ?? true;

    ///Todo: Currently for experiment, support only one template. Add support for other template.
    Room room = Room.from(
        actions: actions,
        hostUid: hostUid,
        roomNumber: roomNumber,
        template: template,
        roomStatus: roomStatus,
        currentActionerIndex: currentActionerIndex,
        hasPoison: hasPoison,
        hasAntidote: hasAntidote,
        players: players);
    print("asd9");

    print(players);

//    room.players.clear();
//    room.players.addAll(players);

    print(room.players);

    print("asd0");

    print("$room");

    print("asd00");

    sink.add(room);
  }

  void prepare() {
    DocumentReference docRef = Firestore.instance.collection(rooms).document(currentRoomNumber);

    docRef.setData({roomStatusKey: RoomStatus.seated.index}, merge: true);
  }

  void startGame() {
    DocumentReference docRef = Firestore.instance.collection(rooms).document(currentRoomNumber);

    docRef.setData({roomStatusKey: RoomStatus.ongoing.index, currentActionerIndexKey: 0}, merge: true);
  }

  void performAction(Role role, int targetSeat, int currentActionerIndex, {bool usePoison = false}) {
    DocumentReference docRef = Firestore.instance.collection(rooms).document(currentRoomNumber);

    if (targetSeat == null) {
      docRef.setData({currentActionerIndexKey: currentActionerIndex}, merge: true);
    } else {
      docRef.setData({
        actionsKey: {
          Player.roleToIndex(role).toString(): targetSeat,
        },
        currentActionerIndexKey: currentActionerIndex
      }, merge: true);
    }
  }

  Future<void> checkInForLuckySonVerifications({int myIndex, int totalPlayers, int currentActionerIndex}) async {
    DocumentReference docRef = Firestore.instance.collection(rooms).document(currentRoomNumber);
    DocumentSnapshot docSnap = await docRef.get();

    var count = docSnap.data[luckySonVerificationsCountKey];

    if (count != null && count + 1 == totalPlayers)
      docRef.setData({currentActionerIndexKey: currentActionerIndex}, merge: true);
    else
      docRef.setData({luckySonVerificationsCountKey: FieldValue.increment(1)}, merge: true);
  }

  Future<String> getAvatar(String uid) async {
    var ref = FirebaseStorage.instance.ref().child('profile_pics/$uid');

    return ref.getDownloadURL().then((value) => value, onError: (_) => null);
  }

  StorageUploadTask uploadAvatar(String uid, List<int> imageBytes) {
    final StorageReference storageReference = FirebaseStorage().ref().child('profile_pics/$uid');

    final StorageUploadTask uploadTask = storageReference.putData(imageBytes);

    return uploadTask;

//    final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
//      print('EVENT ${event.type}');
//    });
//
//    await uploadTask.onComplete;
//    streamSubscription.cancel();
  }
}
