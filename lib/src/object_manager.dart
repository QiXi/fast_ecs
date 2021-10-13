class ObjectManager {
  final List<ObjectArray> data = [];
  final List<Type> registerTypes = [];
  int _nextIndex = 0;

  int get size => _nextIndex;

  int register<T>(T Function(int index) generator, int capacity) {
    assert(!registerTypes.contains(T), 'Registering $T more than once.');
    var objectId = _nextIndex;
    data.add(ObjectArray<T>(capacity, generator));
    registerTypes.add(T);
    _nextIndex++;
    return objectId;
  }

  int getObjectId<T>() {
    assert(registerTypes.contains(T), '$T not registered before use.');
    return registerTypes.indexOf(T);
  }

  T getObject<T>() {
    var id = getObjectId<T>();
    return data[id].data[0] as T;
  }

  List<T> getObjectList<T>() {
    var id = getObjectId<T>();
    return data[id].data as List<T>;
  }

  @override
  String toString() {
    return 'ObjectManager{ size:$size $registerTypes}';
  }
}

class ObjectArray<T> {
  final int capacity;
  final List<T> data;

  ObjectArray(this.capacity, T Function(int index) generator)
      : data = List.generate(capacity, generator, growable: false);
}
