extension ListExtension<T> on List<T> {
  /// Add the element [item] between each element of this list.
  ///
  /// This function returns nothing, the actual list will be modified. If you
  /// want to construct a new list without affecting this instance, please use
  /// [intersperseCopy] instead.
  ///
  /// Note that the current list needs to be modifiable and growable, or an
  /// [UnsupportedError] will be thrown.
  ///
  /// Source code inspired from https://stackoverflow.com/a/5921708 by senderle
  /// (consulted on April 9th, 2022).
  void intersperse(final T item) {
    if (length <= 1) {
      return;
    }

    for (int i = 1; i < length; i += 2) {
      insert(i, item);
    }
  }

  /// Add the element [item] between each element of this list.
  ///
  /// This function returns a new list. If you want to edit this instance,
  /// please use [intersperse] instead.
  ///
  /// Source code inspired from https://stackoverflow.com/a/5921708 by senderle
  /// (consulted on April 9th, 2022).
  List<T> intersperseCopy(
    final T item, {
    final bool growable = false,
  }) {
    // If empty or singleton, return a copy of this list
    if (length <= 1) {
      return List<T>.of(this, growable: growable);
    }

    final List<T> newList = <T>[];
    for (int i = 0; i < length; ++i) {
      newList.add(elementAt(i));
      // Add item in-between
      if (i + 1 < length) {
        newList.add(item);
      }
    }

    return List<T>.of(newList, growable: growable);
  }
}
