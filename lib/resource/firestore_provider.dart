import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:werewolfjudge/model/room.dart';
import 'package:werewolfjudge/model/template.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';

import 'firebase_auth_provider.dart';
import 'constants.dart';

export 'package:werewolfjudge/model/room.dart';

class FirestoreProvider {
  static final instance = FirestoreProvider._();
  static Map<String, String> avatarLinkCache = {};

  String currentRoomNumber;

  FirestoreProvider._();

  Future<String> fetchPlayerDisplayName(String uid) async {
    DocumentReference docRef = FirebaseFirestore.instance.collection(usersKey).doc(uid);
    DocumentSnapshot docSnap = await docRef.get();


    if (docSnap.exists) return docSnap.data()[userNameKey]??'无名氏';

    return '无名氏';
  }

  ///Create a room using [uid] of host and [numOfSeats]
  Future<String> newRoom({String uid, Template template}) async {
    DocumentReference docRef;
    DocumentSnapshot docSnap;
    String roomNum;

    do {
      roomNum = generateRoomNumber();
      docRef = FirebaseFirestore.instance.collection(rooms).doc(roomNum);
      docSnap = await docRef.get();
    } while (docSnap.exists &&
        (DateTime.fromMillisecondsSinceEpoch(docSnap.data()[timestampKey]).toLocal().difference(DateTime.now()).inHours <= 2 ||
            RoomStatus.values.elementAt(docSnap.data()[roomStatusKey]) != RoomStatus.terminated));

    docRef.delete().whenComplete(() => docRef.set({
          actionsKey: {},
          hasPoisonKey: true,
          hasAntidoteKey: true,
          timestampKey: DateTime.now().toUtc().millisecondsSinceEpoch,
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
    return FirebaseFirestore.instance.collection(rooms).doc(roomNum).get().then((value) {
      if (value.exists == false) return false;
      if (DateTime.fromMillisecondsSinceEpoch(value.data()[timestampKey]).toLocal().difference(DateTime.now()).inHours >= 2) return false;

      SharedPreferencesProvider.instance.setLastRoom(roomNum);

      return true;
    });
  }

  Future<void> terminateRoom(String roomNum) async {
    var docRef = FirebaseFirestore.instance.collection(rooms).doc(roomNum);

    return docRef.set({roomStatusKey: RoomStatus.terminated.index}, SetOptions(merge: true));
  }

  Stream<Room> fetchRoom(String roomNum) {
    currentRoomNumber = roomNum;
    return FirebaseFirestore.instance
        .collection(rooms)
        .doc(roomNum)
        .snapshots()
        .transform<Room>(StreamTransformer.fromHandlers(handleData: handleDate));
  }

  Future<int> takeSeat(String roomNumber, int seatNumber, [int currentSeatNumber]) async {
    DocumentReference docRef = FirebaseFirestore.instance.collection(rooms).doc(roomNumber);
    DocumentSnapshot docSnap = await docRef.get();
    String playerUid = FirebaseAuthProvider.instance.currentUser.uid;

    if (docSnap.data()[playersKey][seatNumber.toString()] != null) {
      return -1;
    }

    int roleIndex = docSnap.data()[rolesKey][seatNumber];
    Role role = Player.indexToRole(roleIndex);

    if (currentSeatNumber != null) {
      return docRef.set({
        playersKey: {
          seatNumber.toString(): Player(uid: playerUid, seatNumber: seatNumber, role: role).toMap(),
          currentSeatNumber.toString(): null,
        },
      }, SetOptions(merge: true)).then((value) => 0);
    } else {
      return docRef.set({
        playersKey: {
          seatNumber.toString(): Player(uid: playerUid, seatNumber: seatNumber, role: role).toMap(),
        },
      }, SetOptions(merge: true)).then((value) => 0);
    }
  }

  Future<int> leaveSeat(String roomNumber, int seatNumber) async {
    DocumentReference docRef = FirebaseFirestore.instance.collection(rooms).doc(roomNumber);
    DocumentSnapshot docSnap = await docRef.get();

    if (docSnap.data()[playersKey][seatNumber.toString()] == null) {
      return -1;
    }

    print("the seat number is $seatNumber");

    return docRef.set({
      playersKey: {
        seatNumber.toString(): null,
      },
    }, SetOptions(merge: true)).then((value) => 0);
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
    var data = docSnap.data();
    var actions =
        (data[actionsKey] as Map<String, dynamic>).map((key, value) => MapEntry(Player.indexToRole(int.parse(key)).runtimeType, value as int));
    print("asd2");
    var roomNumber = docSnap.id;
    var roomStatus = RoomStatus.values.elementAt(data[roomStatusKey] ?? 0);
    var hostUid = data[hostUidKey];
    var roles = (data[rolesKey]).map((e) => Player.indexToRole(e)).toList();
    var players = (data[playersKey] as Map).map((k, e) => MapEntry(int.parse(k), e == null ? null : Player.fromMap(e)));
    var template = CustomTemplate.from(roles: roles);
    var timestamp = data[timestampKey];
    var currentActionerIndex = data[currentActionerIndexKey] ?? 0;

    var hasPoison = data[hasPoisonKey] ?? true;
    var hasAntidote = data[hasAntidoteKey] ?? true;

    Room room = Room.from(
        timestamp: timestamp,
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
    DocumentReference docRef = FirebaseFirestore.instance.collection(rooms).doc(currentRoomNumber);

    docRef.set({roomStatusKey: RoomStatus.seated.index}, SetOptions(merge: true));
  }

  void startGame() {
    DocumentReference docRef = FirebaseFirestore.instance.collection(rooms).doc(currentRoomNumber);

    docRef.set({roomStatusKey: RoomStatus.ongoing.index, currentActionerIndexKey: 0}, SetOptions(merge: true));
  }

  void performAction(Role role, int targetSeat, int currentActionerIndex, {bool usePoison = false}) {
    DocumentReference docRef = FirebaseFirestore.instance.collection(rooms).doc(currentRoomNumber);

    if (targetSeat == null) {
      docRef.set({currentActionerIndexKey: currentActionerIndex}, SetOptions(merge: true));
    } else {
      docRef.set({
        actionsKey: {
          Player.roleToIndex(role).toString(): targetSeat,
        },
        currentActionerIndexKey: currentActionerIndex
      }, SetOptions(merge: true));
    }
  }

  Future<void> checkInForLuckySonVerifications({int myIndex, int totalPlayers, int currentActionerIndex}) async {
    DocumentReference docRef = FirebaseFirestore.instance.collection(rooms).doc(currentRoomNumber);
    DocumentSnapshot docSnap = await docRef.get();

    var count = docSnap.data()[luckySonVerificationsCountKey];

    if (count != null && count + 1 == totalPlayers)
      docRef.set({currentActionerIndexKey: currentActionerIndex}, SetOptions(merge: true));
    else
      docRef.set({luckySonVerificationsCountKey: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<String> getAvatar(String uid) async {
    if(avatarLinkCache.containsKey(uid)) return avatarLinkCache[uid];

    var ref = FirebaseStorage.instance.ref().child('profile_pics/$uid');

    return ref.getDownloadURL().then((value) {
      if(value != null) avatarLinkCache[uid] = value;
      return value;
    }, onError: (_) => null);
  }

  StorageUploadTask uploadAvatar(String uid, List<int> imageBytes) {
    final StorageReference storageReference = FirebaseStorage().ref().child('profile_pics/$uid');

    final StorageUploadTask uploadTask = storageReference.putData(imageBytes);

    uploadTask.onComplete.then((value){
      value.ref.getDownloadURL().then((url) => avatarLinkCache[uid] = url);
    });

    return uploadTask;
  }

  Future deleteAvatar(String uid){
    return FirebaseStorage().ref().child('profile_pics/$uid').delete().then((_) => avatarLinkCache.remove(uid));
  }
}
