import 'dart:convert';
import 'dart:io';

import '../domain/domain.dart';
import 'simulation_repository.dart';

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
      final decoded = jsonDecode(await file.readAsString());
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
