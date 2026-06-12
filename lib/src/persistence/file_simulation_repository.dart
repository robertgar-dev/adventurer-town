import 'dart:convert';
import 'dart:io';

import '../domain/domain.dart';
import 'simulation_repository.dart';
import 'simulation_state_codec.dart';

class FileSimulationRepository implements SimulationRepository {
  FileSimulationRepository(this._fileFactory);

  final Future<File> Function() _fileFactory;

  @override
  Future<SimulationState> loadState() async {
    final file = await _fileFactory();
    if (!await file.exists()) {
      final state = SimulationState.newGame();
      await saveState(state);
      return state;
    }

    try {
      final restored = SimulationStateCodec.decode(await file.readAsString());
      if (restored != null) {
        return restored;
      }
      // Unreadable payload (corrupt JSON, non-map, or unsupported schema
      // version): fall through to safe default recovery.
    } on IOException {
      // Fall through to safe default recovery.
    }

    final recovered = SimulationState.newGame();
    await saveState(recovered);
    return recovered;
  }

  @override
  Future<void> saveState(SimulationState state) async {
    final file = await _fileFactory();
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    final savedState = state.copyWith(lastSavedAtUtc: DateTime.now().toUtc());
    await file.writeAsString(jsonEncode(savedState.toJson()), flush: true);
  }
}
