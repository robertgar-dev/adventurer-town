import 'dart:io';

import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulationRepository', () {
    test('in-memory repository round-trips through JSON serialization',
        () async {
      final repository = InMemorySimulationRepository();
      final initial = await repository.loadState();
      final ticked = const SimulationEngine()
          .tick(initial, resolvedAtUtc: DateTime.utc(2026, 6, 9))
          .state;

      await repository.saveState(ticked);
      final loaded = await repository.loadState();

      expect(loaded.toJson(), ticked.toJson());
    });

    test('file repository saves and loads local state', () async {
      final directory =
          await Directory.systemTemp.createTemp('adventurer_town_test_');
      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });

      final file = File('${directory.path}${Platform.pathSeparator}state.json');
      final repository = FileSimulationRepository(() async => file);
      final state = SimulationState.newGame(nowUtc: DateTime.utc(2026, 6, 9))
          .copyWith(currentTick: 7);

      await repository.saveState(state);
      final loaded = await repository.loadState();

      expect(await file.exists(), isTrue);
      expect(loaded.currentTick, 7);
      expect(loaded.resources.gold, state.resources.gold);
    });
  });
}
