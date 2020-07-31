import 'role.dart';

enum Status { dead, alive }

enum SkillStatus { unavailable, available }

const String uidKey = 'uid';
const String seatNumberKey = 'seatNumber';
const String statusKey = 'status';
const String skillStatusKey = 'skillStatus';
const String roleKey = 'role';

class Player {
  final String uid;

  int _seatNumber;
  int get seatNumber => _seatNumber;
  set seatNumber(i) => _seatNumber;

  Role _role;
  Role get role => _role;
  set role(role) => _role;

  Status _status;
  Status get status => _status;
  set status(status) => _status;

  SkillStatus _skillStatus;
  SkillStatus get skillStatus => _skillStatus;
  set skillStatus(status) => _skillStatus;

  Player({this.uid, int seatNumber, Role role}) {
    _role = role;
    _seatNumber = seatNumber;
    _status = Status.alive;
    _skillStatus = SkillStatus.available;
  }

  Map<String, dynamic> toMap() => {
        uidKey: uid,
        roleKey: roleToIndex(role),
        seatNumberKey: seatNumber,
        statusKey: status.index,
        skillStatusKey: skillStatus.index,
      };

  Player.fromMap(Map map) : uid = map[uidKey] {
    this._role = indexToRole(map[roleKey]);
    this._seatNumber = map[seatNumberKey];
    this._status = Status.values.elementAt(map[statusKey]);
    this._skillStatus = SkillStatus.values.elementAt(map[skillStatusKey]);
  }

  static int roleToIndex(Role role) {
    if (role == null) return -1;
    switch (role.runtimeType) {
      case Villager:
        return 0;
      case Wolf:
        return 1;
      case WolfQueen:
        return 2;
      case Seer:
        return 3;
      case Witch:
        return 4;
      case Hunter:
        return 5;
      case Guard:
        return 6;
      case Slacker:
        return 7;
      case WolfKing:
        return 8;
      case Nightmare:
        return 9;
      case Gargoyle:
        return 10;
      case GraveyardKeeper:
        return 11;
      case Idiot:
        return 12;
      case BlackTrader:
        return 13;
      case HiddenWolf:
        return 14;
      case Knight:
        return 15;
      case Celebrity:
        return 16;
      case Cupid:
        return 17;
      case Moderator:
        return 18;
      default:
        throw Exception("No corresponding index found for ${role.runtimeType}");
    }
  }

  static Role indexToRole(int index) {
    switch (index) {
      case -1:
        return null;
      case 0:
        return Villager();
      case 1:
        return Wolf();
      case 2:
        return WolfQueen();
      case 3:
        return Seer();
      case 4:
        return Witch();
      case 5:
        return Hunter();
      case 6:
        return Guard();
      case 7:
        return Slacker();
      case 8:
        return WolfKing();
      case 9:
        return Nightmare();
      case 10:
        return Gargoyle();
      case 11:
        return GraveyardKeeper();
      case 12:
        return Idiot();
      case 13:
        return BlackTrader();
      case 14:
        return HiddenWolf();
      case 15:
        return Knight();
      case 16:
        return Celebrity();
      case 17:
        return Cupid();
      case 18:
        return Moderator();
      default:
        throw Exception("No corresponding role found for $index");
    }
  }
}
