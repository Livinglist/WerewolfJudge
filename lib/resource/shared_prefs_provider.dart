import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:werewolfjudge/model/room.dart';

const roomHistoryKey = 'roomHistory';

class SharedPreferencesProvider {
  static final instance = SharedPreferencesProvider._();

  static SharedPreferences _sharedPreferences;

  SharedPreferencesProvider._() {
    if (_sharedPreferences == null) initSharedPrefs();
  }

  SharedPreferencesProvider() {
    initSharedPrefs();
  }

  Future initSharedPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (!_sharedPreferences.containsKey(roomHistoryKey)) {}
  }

  void update(List<Room> rooms) {
    _sharedPreferences.setStringList(roomHistoryKey, rooms.map((e) => jsonEncode(e.toMap())));
  }

  List<Room> getAllRoomHistory() {
    var roomsJsonStrings = _sharedPreferences.getStringList(roomHistoryKey);
    var rooms = roomsJsonStrings.map((e) => Room.fromMap(jsonDecode(e)));
    return rooms;
  }
}
