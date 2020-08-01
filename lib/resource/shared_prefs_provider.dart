import 'package:shared_preferences/shared_preferences.dart';

import 'package:werewolfjudge/model/room.dart';

const roomHistoryKey = 'roomHistory';

class SharedPreferencesProvider {
  static SharedPreferences _sharedPreferences;

  SharedPreferencesProvider._() {
    if (_sharedPreferences == null) initSharedPrefs();
  }

  static final instance = SharedPreferencesProvider._();

  SharedPreferencesProvider() {
    initSharedPrefs();
  }

  Future initSharedPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (!_sharedPreferences.containsKey(roomHistoryKey)) {}
  }

  List<String> getAllFavKanjiStrs() => _sharedPreferences.getStringList(roomHistoryKey);

  List<String> uids = [];

  void addFav(String kanjiStr) {
    var favKanjiStrs = _sharedPreferences.getStringList(roomHistoryKey);
    favKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(roomHistoryKey, favKanjiStrs);
  }

  void removeFav(String kanjiStr) {
    var favKanjiStrs = _sharedPreferences.getStringList(roomHistoryKey);
    favKanjiStrs.remove(kanjiStr);
    _sharedPreferences.setStringList(roomHistoryKey, favKanjiStrs);
  }

  List<Room> getAllRoomHistory() {
    var roomsJsonStrings = _sharedPreferences.getStringList(roomHistoryKey);

  }
}
