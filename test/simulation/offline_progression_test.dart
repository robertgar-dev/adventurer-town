import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/simulation/offline_progression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = OfflineProgressionResolver();

  group('OfflineProgressionResolver — elapsed time (WP-M7-01)', () {
    test('converts elapsed seconds to whole ticks', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final result = resolver.resolve(
        _seed(lastResolved: last),
        nowUtc: last.add(const Duration(seconds: 100)),
      );

      expect(result.didResolve, isTrue);
      expect(result.resolvedTicks, 20); // 100s / 5s.
      expect(result.elapsedSeconds, 100);
    });

    test('clamps future timestamps to zero (no resolution)', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final seed = _seed(lastResolved: last);
      final result = resolver.resolve(
        seed,
        nowUtc: last.subtract(const Duration(seconds: 100)),
      );

      expect(result.didResolve, isFalse);
      expect(result.resolvedTicks, 0);
      expect(result.elapsedSeconds, 0);
      expect(result.state.lastResolvedTickAtUtc, seed.lastResolvedTickAtUtc);
    });

    test('ignores a sub-tick absence', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final result = resolver.resolve(
        _seed(lastResolved: last),
        nowUtc: last.add(const Duration(seconds: 4)), // < one 5s tick.
      );

      expect(result.didResolve, isFalse);
      expect(result.resolvedTicks, 0);
    });

    test('resolved timestamp advances to now (one-time processing)', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final now = last.add(const Duration(seconds: 100));
      final result = resolver.resolve(_seed(lastResolved: last), nowUtc: now);

      expect(result.state.lastResolvedTickAtUtc, now);
    });
  });

  group('OfflineProgressionResolver — safety caps (WP-M7-05)', () {
    test('caps the offline window at 8 hours / 28,800s / 5,760 ticks', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final result = resolver.resolve(
        _seed(lastResolved: last),
        nowUtc: last.add(const Duration(seconds: 100000)), // ~27.8h away.
      );

      expect(result.elapsedSeconds, EconomyConstants.offlineCapSeconds);
      expect(result.elapsedSeconds, 28800);
      expect(result.resolvedTicks, 5760);
      expect(OfflineProgressionResolver.maxOfflineTicks, 5760);
    });

    test('long-duration offline processing stays bounded and valid', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final result = resolver.resolve(
        _seed(lastResolved: last),
        nowUtc: last.add(const Duration(seconds: 100000)),
      );

      expect(result.didResolve, isTrue);
      expect(result.goldEarned, greaterThan(0));
      expect(result.state.activeDemands, isEmpty); // no backlog.
      expect(result.state.resources.gold, greaterThanOrEqualTo(0));
      // Event feed remains bounded by retention despite thousands of ticks.
      expect(
        result.state.eventFeed.length,
        lessThanOrEqualTo(result.state.settings.eventFeedMaxEntries),
      );
    });
  });

  group('OfflineProgressionResolver — offline economy rules (WP-M7-02)', () {
    test('awards Gold but never Reputation while offline', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final seed = _seed(lastResolved: last);
      final result = resolver.resolve(
        seed,
        nowUtc: last.add(const Duration(seconds: 600)), // 120 ticks.
      );

      expect(result.goldEarned, greaterThan(0));
      // No Reputation is earned offline.
      expect(result.state.resources.reputation,
          seed.resources.reputation);
      expect(result.state.resources.lifetimeReputationEarned,
          seed.resources.lifetimeReputationEarned);
    });

    test('missed offline demand remains lost (counted, not queued)', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final result = resolver.resolve(
        _seed(lastResolved: last),
        nowUtc: last.add(const Duration(seconds: 600)),
      );

      expect(result.demandServed, greaterThan(0));
      // Tavern (capacity 1) loses food demand under load; nothing is queued.
      expect(result.demandMissed, greaterThan(0));
      expect(result.state.activeDemands, isEmpty);
    });
  });

  group('OfflineProgressionResolver — events (WP-M7-04)', () {
    test('generates offline-marked events', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final result = resolver.resolve(
        _seed(lastResolved: last),
        nowUtc: last.add(const Duration(seconds: 600)),
      );

      expect(result.state.eventFeed, isNotEmpty);
      expect(result.state.eventFeed.every((entry) => entry.wasOffline), isTrue);
    });
  });

  group('OfflineProgressionResolver — determinism & duplicates', () {
    test('deterministic replay produces identical results', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final now = last.add(const Duration(seconds: 600));
      final a = resolver.resolve(_seed(lastResolved: last), nowUtc: now);
      final b = resolver.resolve(_seed(lastResolved: last), nowUtc: now);

      expect(a.state.toJson(), b.state.toJson());
      expect(a.goldEarned, b.goldEarned);
      expect(a.resolvedTicks, b.resolvedTicks);
    });

    test('re-resolving the resolved state yields no further rewards', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final now = last.add(const Duration(seconds: 600));
      final first = resolver.resolve(_seed(lastResolved: last), nowUtc: now);
      final second = resolver.resolve(first.state, nowUtc: now);

      expect(first.didResolve, isTrue);
      expect(second.didResolve, isFalse);
      expect(second.goldEarned, 0);
    });

    test('re-resolving after a capped window also yields nothing', () {
      final last = DateTime.utc(2026, 6, 14, 10);
      final now = last.add(const Duration(seconds: 100000));
      final first = resolver.resolve(_seed(lastResolved: last), nowUtc: now);
      final second = resolver.resolve(first.state, nowUtc: now);

      expect(first.resolvedTicks, 5760);
      expect(second.didResolve, isFalse);
      expect(second.goldEarned, 0);
    });
  });
}

SimulationState _seed({required DateTime lastResolved}) {
  // newGame constructs Inn and Tavern, which is enough to earn Gold and to
  // lose some Tavern (food) demand under load. lastResolvedTickAtUtc == now.
  final initial = SimulationState.newGame(
    nowUtc: lastResolved,
    randomSeed: 1001,
  );
  return initial.copyWith(lastResolvedTickAtUtc: lastResolved);
}
