import 'package:adventurer_town/src/analytics/analytics_service.dart';
import 'package:adventurer_town/src/app/simulation_controller.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulationController offline resolution (WP-M7-03)', () {
    test('resolves offline progression on load and persists it', () async {
      final last = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
      final repository = InMemorySimulationRepository(seedState: _seed(last));
      final controller = _controller(repository);

      await controller.loadOrCreate();

      final summary = controller.state.offlineSummary;
      expect(summary, isNotNull);
      expect(summary!.didResolve, isTrue);
      expect(summary.resolvedTicks, greaterThan(0));
      expect(summary.goldEarned, greaterThan(0));

      // The resolved state was saved immediately (gold + advanced timestamp).
      final persisted = await repository.loadState();
      expect(persisted.resources.lifetimeGoldEarned, greaterThan(0));
      expect(persisted.lastResolvedTickAtUtc.isAfter(last), isTrue);
      // No Reputation was earned offline.
      expect(persisted.resources.reputation, 0);

      controller.dispose();
    });

    test('summary can be dismissed', () async {
      final last = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
      final repository = InMemorySimulationRepository(seedState: _seed(last));
      final controller = _controller(repository);

      await controller.loadOrCreate();
      expect(controller.state.offlineSummary, isNotNull);

      controller.dismissOfflineSummary();
      expect(controller.state.offlineSummary, isNull);

      controller.dispose();
    });

    test('a second load does not reprocess the same window', () async {
      final last = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
      final repository = InMemorySimulationRepository(seedState: _seed(last));

      final first = _controller(repository);
      await first.loadOrCreate();
      final goldAfterFirst =
          (await repository.loadState()).resources.lifetimeGoldEarned;
      first.dispose();

      // A fresh controller (app restart) reading the persisted state.
      final second = _controller(repository);
      await second.loadOrCreate();

      expect(second.state.offlineSummary, isNull); // no new window to resolve.
      final goldAfterSecond =
          (await repository.loadState()).resources.lifetimeGoldEarned;
      expect(goldAfterSecond, goldAfterFirst); // no duplicate rewards.

      second.dispose();
    });
  });
}

SimulationController _controller(InMemorySimulationRepository repository) {
  return SimulationController(
    repository: repository,
    engine: const SimulationEngine(),
    analyticsService: const NoopAnalyticsService(),
  );
}

SimulationState _seed(DateTime lastResolved) {
  final initial = SimulationState.newGame(
    nowUtc: lastResolved,
    randomSeed: 1001,
  );
  return initial.copyWith(lastResolvedTickAtUtc: lastResolved);
}
