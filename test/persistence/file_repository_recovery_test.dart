import 'dart:convert';
import 'dart:io';

import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileSimulationRepository recovery', () {
    late Directory directory;
    late File file;
    late FileSimulationRepository repository;

    setUp(() async {
      directory =
          await Directory.systemTemp.createTemp('adventurer_town_recovery_');
      file = File('${directory.path}${Platform.pathSeparator}state.json');
      repository = FileSimulationRepository(() async => file);
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test('full state save/load preserves all MVP fields', () async {
      final saved = SimulationState.newGame(nowUtc: DateTime.utc(2026, 6, 9))
          .copyWith(
        currentTick: 24,
        randomSeed: 4242,
        resources: const Resources(
          gold: 150,
          reputation: 40,
          lifetimeGoldEarned: 320,
          lifetimeReputationEarned: 95,
        ),
      );

      await repository.saveState(saved);
      final loaded = await repository.loadState();

      expect(loaded.currentTick, 24);
      expect(loaded.randomSeed, 4242);
      expect(loaded.resources.gold, 150);
      expect(loaded.resources.reputation, 40);
      expect(loaded.resources.lifetimeGoldEarned, 320);
      expect(loaded.resources.lifetimeReputationEarned, 95);
      expect(loaded.buildings.keys.toSet(), BuildingType.values.toSet());
      // Equality across the full payload except the save timestamp, which the
      // repository intentionally refreshes on every write.
      final expectedJson = saved.toJson()..remove('lastSavedAtUtc');
      final loadedJson = loaded.toJson()..remove('lastSavedAtUtc');
      expect(loadedJson, expectedJson);
    });

    test('missing save creates and persists a safe default state', () async {
      expect(await file.exists(), isFalse);

      final loaded = await repository.loadState();

      expect(loaded.currentTick, 0);
      expect(loaded.resources.gold, 0);
      expect(loaded.schemaVersion, SimulationState.currentSchemaVersion);
      // The default must be written back to disk, not just returned.
      expect(await file.exists(), isTrue);
      final persisted = SimulationStateCodec.decode(await file.readAsString());
      expect(persisted, isNotNull);
      expect(persisted!.currentTick, 0);
    });

    test('corrupt JSON recovers to a safe default and re-persists', () async {
      await file.writeAsString('{ definitely not valid json');

      final loaded = await repository.loadState();

      expect(loaded.currentTick, 0);
      expect(loaded.schemaVersion, SimulationState.currentSchemaVersion);
      final persisted = SimulationStateCodec.decode(await file.readAsString());
      expect(persisted, isNotNull);
    });

    test('non-map payload recovers to a safe default', () async {
      await file.writeAsString('[1, 2, 3]');

      final loaded = await repository.loadState();

      expect(loaded.currentTick, 0);
      expect(loaded.schemaVersion, SimulationState.currentSchemaVersion);
    });

    test('schema version round-trips correctly', () async {
      final saved =
          SimulationState.newGame(nowUtc: DateTime.utc(2026, 6, 9)).copyWith(
        currentTick: 5,
      );

      await repository.saveState(saved);
      final loaded = await repository.loadState();

      expect(loaded.schemaVersion, SimulationState.currentSchemaVersion);
      final raw = jsonDecode(await file.readAsString()) as Map<String, Object?>;
      expect(raw['schemaVersion'], SimulationState.currentSchemaVersion);
    });

    test('invalid (future) schema version falls back to a safe default',
        () async {
      final payload = SimulationState.newGame().copyWith(currentTick: 77).toJson()
        ..['schemaVersion'] = SimulationState.currentSchemaVersion + 1;
      await file.writeAsString(jsonEncode(payload));

      final loaded = await repository.loadState();

      // The currentTick:77 data must be discarded, not loaded under a schema we
      // do not understand.
      expect(loaded.currentTick, 0);
      expect(loaded.schemaVersion, SimulationState.currentSchemaVersion);
    });
  });

  group('FileSimulationRepository time semantics', () {
    late Directory directory;
    late File file;
    late FileSimulationRepository repository;

    setUp(() async {
      directory =
          await Directory.systemTemp.createTemp('adventurer_town_time_');
      file = File('${directory.path}${Platform.pathSeparator}state.json');
      repository = FileSimulationRepository(() async => file);
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test('lastSavedAtUtc is refreshed and stored as UTC on save', () async {
      final before = DateTime.now().toUtc();
      final stale =
          SimulationState.newGame(nowUtc: DateTime.utc(2020, 1, 1)).copyWith();
      expect(stale.lastSavedAtUtc, DateTime.utc(2020, 1, 1));

      await repository.saveState(stale);
      final loaded = await repository.loadState();

      expect(loaded.lastSavedAtUtc.isUtc, isTrue);
      expect(
        loaded.lastSavedAtUtc.isAfter(before) ||
            loaded.lastSavedAtUtc.isAtSameMomentAs(before),
        isTrue,
      );
      expect(loaded.lastSavedAtUtc.isAfter(DateTime.utc(2020, 1, 1)), isTrue);
    });

    test('lastResolvedTickAtUtc is preserved and restored as UTC', () async {
      final resolvedAt = DateTime.utc(2026, 3, 14, 9, 26, 53);
      final saved = SimulationState.newGame(nowUtc: DateTime.utc(2026, 6, 9))
          .copyWith(lastResolvedTickAtUtc: resolvedAt);

      await repository.saveState(saved);
      final loaded = await repository.loadState();

      expect(loaded.lastResolvedTickAtUtc.isUtc, isTrue);
      expect(loaded.lastResolvedTickAtUtc, resolvedAt);
    });

    test('a non-UTC lastResolvedTickAtUtc is normalized to UTC on load',
        () async {
      // Even if a payload smuggles in a non-UTC ISO string, the restored value
      // must be UTC so future elapsed-time math stays consistent.
      final json = SimulationState.newGame().toJson()
        ..['lastResolvedTickAtUtc'] = '2026-03-14T09:26:53+02:00';
      await file.writeAsString(jsonEncode(json));

      final loaded = await repository.loadState();

      expect(loaded.lastResolvedTickAtUtc.isUtc, isTrue);
      expect(loaded.lastResolvedTickAtUtc, DateTime.utc(2026, 3, 14, 7, 26, 53));
    });
  });
}
