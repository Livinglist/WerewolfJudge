import 'package:rxdart/rxdart.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';

import 'package:werewolfjudge/model/room.dart';

export 'package:werewolfjudge/model/room.dart';

class RoomHistoryBloc {
  static final instance = RoomHistoryBloc._();

  RoomHistoryBloc._() {
    if (_rooms == null) {
      _rooms = SharedPreferencesProvider.instance.getAllRoomHistory();
      if (!_roomsFetcher.isClosed) _roomsFetcher.sink.add(_rooms);
    }
  }

  final _roomsFetcher = BehaviorSubject<List<Room>>();

  Stream<List<Room>> get rooms => _roomsFetcher.stream;

  static List<Room> _rooms;

  void addRoom(Room room) {
    _rooms.add(room);

    _roomsFetcher.sink.add(_rooms);

    SharedPreferencesProvider.instance.update(_rooms);
  }

  void deleteRoom(Room room) {
    _rooms.remove(room);

    _roomsFetcher.sink.add(_rooms);

    SharedPreferencesProvider.instance.update(_rooms);
  }

  void clearAll() {
    _rooms.clear();

    _roomsFetcher.sink.add(_rooms);

    SharedPreferencesProvider.instance.update(_rooms);
  }

  void dispose() {
    _roomsFetcher.close();
  }
}
