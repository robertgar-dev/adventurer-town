import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/domain.dart';
import '../simulation_repository.dart';
import 'simulation_save_record.dart';

class IsarSimulationRepository implements SimulationRepository {
  IsarSimulationRepository({Future<Isar> Function()? openIsar})
      : _openIsarOverride = openIsar;

  final Future<Isar> Function()? _openIsarOverride;
  Isar? _isar;

  @override
  Future<SimulationState> loadState() async {
    final isar = await _open();
    final record = await isar.collection<SimulationSaveRecord>().get(1);
    if (record == null) {
      final state = SimulationState.newGame();
      await saveState(state);
      return state;
    }

    try {
      final decoded = jsonDecode(record.stateJson);
      if (decoded is Map<String, Object?>) {
        return SimulationState.fromJson(decoded);
      }
      if (decoded is Map) {
        return SimulationState.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } on FormatException {
      // Fall through to safe default recovery.
    }

    final recovered = SimulationState.newGame();
    await saveState(recovered);
    return recovered;
  }

  @override
  Future<void> saveState(SimulationState state) async {
    final isar = await _open();
    final savedState = state.copyWith(lastSavedAtUtc: DateTime.now().toUtc());
    final record = SimulationSaveRecord()
      ..id = 1
      ..stateJson = jsonEncode(savedState.toJson())
      ..savedAtUtc = savedState.lastSavedAtUtc;

    await isar
        .writeTxn(() => isar.collection<SimulationSaveRecord>().put(record));
  }

  Future<Isar> _open() async {
    final existing = _isar;
    if (existing != null && existing.isOpen) {
      return existing;
    }

    final override = _openIsarOverride;
    if (override != null) {
      _isar = await override();
      return _isar!;
    }

    final directory = await getApplicationSupportDirectory();
    _isar = await Isar.open(
      const [SimulationSaveRecordSchema],
      directory: directory.path,
      name: 'adventurer_town',
    );
    return _isar!;
  }
}
