extension ListExtension<T> on List<T> {
  bool hasType<K>(K k) {
    for (var i in this) {
      if (i.runtimeType == k.runtimeType) {
        return true;
      }
    }
    return false;
  }
}
