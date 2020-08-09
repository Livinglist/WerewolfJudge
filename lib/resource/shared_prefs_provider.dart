import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:werewolfjudge/model/room.dart';

const roomHistoryKey = 'roomHistory';
const artworkEnabledKey = 'artworkEnabled';

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
    if (_sharedPreferences == null) _sharedPreferences = await SharedPreferences.getInstance();
    if (!_sharedPreferences.containsKey(roomHistoryKey)) {}
  }

  void update(List<Room> rooms) {
    _sharedPreferences.setStringList(roomHistoryKey, rooms.map((e) => jsonEncode(e.toMap())).toList());
  }

  List<Room> getAllRoomHistory() {
    var roomsJsonStrings = _sharedPreferences.getStringList(roomHistoryKey);
    if (roomsJsonStrings == null) return [];
    var rooms = roomsJsonStrings.map((e) => Room.fromMap(jsonDecode(e))).toList();
    return rooms;
  }

  void setLastRoom(String roomNumber) {
    _sharedPreferences.setString(roomNumberKey, roomNumber);
  }

  String getLastRoom() {
    return _sharedPreferences.getString(roomNumberKey);
  }

  void setArtworkEnabled(bool val) {
    _sharedPreferences.setBool(artworkEnabledKey, val);
  }

  bool getArtworkEnabled() {
    return _sharedPreferences.getBool(artworkEnabledKey) ?? true;
  }
}
