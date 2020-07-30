extension ListExtension on List {
  bool hasType<T>(T t) {
    for (var i in this) {
      if (i.runtimeType == t.runtimeType) {
        return true;
      }
    }
    return false;
  }
}
