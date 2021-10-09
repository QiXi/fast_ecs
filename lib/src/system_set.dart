import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'types.dart';

class SystemSet {
  final int capacity;
  final Uint16List systemIds;
  final Uint8List systemPhases;
  SystemId _nextIndex = 0;
  PhaseIndex lastInsertPhase = -1;

  SystemSet(this.capacity)
      : systemIds = Uint16List(capacity),
        systemPhases = Uint8List(capacity);

  int get size => _nextIndex;

  bool get isEmpty => size == 0;

  void clear() {
    _nextIndex = 0;
  }

  operator [](int index) => systemIds[index];

  PhaseIndex getPhaseIndex(int index) => systemPhases[index];

  int indexOf(SystemId systemId) => systemIds.indexOf(systemId);

  bool _indexWherePhase(PhaseIndex element) => element >= lastInsertPhase;

  @internal
  void add(SystemId systemId, PhaseIndex phase) {
    lastInsertPhase = phase;
    var insertIndex = systemPhases.indexWhere(_indexWherePhase);
    if (insertIndex == -1) {
      systemIds[_nextIndex] = systemId;
      systemPhases[_nextIndex] = phase;
    } else {
      var start = insertIndex + 1;
      var end = size + 1;
      systemIds.setRange(start, end, systemIds, insertIndex);
      systemPhases.setRange(start, end, systemPhases, insertIndex);
      systemIds[insertIndex] = systemId;
      systemPhases[insertIndex] = phase;
    }
    _nextIndex++;
  }

  @internal
  void remove(SystemId systemId) {
    if (_nextIndex <= 1) {
      clear();
    } else {
      var removeIndex = systemIds.indexOf(systemId);
      var skip = removeIndex + 1;
      systemIds.setRange(removeIndex, size, systemIds, skip);
      systemPhases.setRange(removeIndex, size, systemPhases, skip);
      _nextIndex--;
    }
  }

  @override
  String toString() {
    return 'Set{ size:$size capacity:$capacity'
        ' ids:${systemIds.sublist(0, size)} phases:${systemPhases.sublist(0, size)}}';
  }
}
