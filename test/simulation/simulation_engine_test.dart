import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulationEngine', () {
    test('advances one deterministic pure Dart tick', () {
      final start = DateTime.utc(2026, 6, 9);
      final state = SimulationState.newGame(nowUtc: start, randomSeed: 123);
      final result = const SimulationEngine().tick(
        state,
        resolvedAtUtc: start,
      );

      expect(result.state.currentTick, 1);
      expect(result.state.lastResolvedTickAtUtc, start);
      expect(result.state.resources.gold, greaterThan(0));
      expect(result.state.resources.reputation, greaterThan(0));
      expect(result.state.activeDemands, isEmpty);
      expect(
        result.state.eventFeed.any(
          (entry) => entry.eventType == EventType.demandServed,
        ),
        isTrue,
      );
    });

    test('produces identical output for identical seeds and timestamps', () {
      final start = DateTime.utc(2026, 6, 9);
      final stateA = SimulationState.newGame(nowUtc: start, randomSeed: 456);
      final stateB = SimulationState.newGame(nowUtc: start, randomSeed: 456);

      final resultA = const SimulationEngine().runTicks(
        stateA,
        count: 4,
        firstResolvedAtUtc: start,
      );
      final resultB = const SimulationEngine().runTicks(
        stateB,
        count: 4,
        firstResolvedAtUtc: start,
      );

      expect(resultA.state.toJson(), resultB.state.toJson());
    });

    test('misses excess demand immediately without leaving a queue', () {
      final start = DateTime.utc(2026, 6, 9);
      final state = SimulationState.newGame(nowUtc: start, randomSeed: 789);
      final result = const SimulationEngine().runTicks(
        state,
        count: 10,
        firstResolvedAtUtc: start,
      );
      final tavern = result.state.buildings[BuildingType.tavern]!;

      expect(tavern.lifetimeDemandReceived, greaterThan(0));
      expect(tavern.lifetimeDemandServed, greaterThan(0));
      expect(tavern.lifetimeDemandLost, greaterThan(0));
      expect(result.state.activeDemands, isEmpty);
      expect(
        result.state.eventFeed.any(
          (entry) => entry.eventType == EventType.demandMissed,
        ),
        isTrue,
      );
    });
  });
}
