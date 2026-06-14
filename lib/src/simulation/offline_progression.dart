import '../domain/domain.dart';
import 'simulation_engine.dart';

/// Result of resolving offline progression. Pure data; safe to surface to the
/// app/UI layer for a return summary without leaking simulation internals.
class OfflineResolution {
  const OfflineResolution({
    required this.state,
    required this.elapsedSeconds,
    required this.resolvedTicks,
    required this.goldEarned,
    required this.demandServed,
    required this.demandMissed,
    required this.didResolve,
  });

  /// The state after offline ticks have been applied (or the input state when
  /// nothing was resolved).
  final SimulationState state;

  /// Clamped, capped elapsed time that was considered for resolution.
  final int elapsedSeconds;

  /// Whole ticks actually executed (0 when below one tick or in the future).
  final int resolvedTicks;

  /// Gold earned during the offline window (delta of lifetime Gold earned).
  final int goldEarned;

  /// Demand served during the offline window (delta of lifetime served).
  final int demandServed;

  /// Demand missed/lost during the offline window (delta of lifetime lost).
  final int demandMissed;

  /// True only when at least one whole offline tick was executed.
  final bool didResolve;
}

/// Resolves elapsed real time into offline simulation progression by replaying
/// the approved [SimulationEngine] economy. There is no second economy, no
/// shortcut formula, and no direct Gold grant: offline ticks run the same
/// serving/reward logic as live ticks, only flagged offline so Reputation is
/// not awarded and events are marked offline.
class OfflineProgressionResolver {
  const OfflineProgressionResolver({
    SimulationEngine engine = const SimulationEngine(),
  }) : _engine = engine;

  final SimulationEngine _engine;

  /// Whole-tick cap (5,760) derived from the approved 8-hour / 28,800-second
  /// offline cap. Derived, not separately stored.
  static int get maxOfflineTicks =>
      EconomyConstants.offlineCapSeconds ~/ EconomyConstants.tickIntervalSeconds;

  /// Resolves offline progression for [state] as of [nowUtc].
  ///
  /// WP-M7-01: elapsed time is measured from `lastResolvedTickAtUtc`, negative
  /// (future) durations clamp to zero, only whole ticks are executed, and the
  /// sub-tick remainder is ignored. WP-M7-05: the window is capped at the
  /// approved 8-hour limit and the resolved timestamp jumps to [nowUtc] so the
  /// same window can never be processed twice (one-time, no duplicate rewards).
  OfflineResolution resolve(SimulationState state, {required DateTime nowUtc}) {
    final now = nowUtc.toUtc();
    final last = state.lastResolvedTickAtUtc.toUtc();

    var elapsedSeconds = now.difference(last).inSeconds;
    if (elapsedSeconds < 0) {
      elapsedSeconds = 0; // Clamp negative / future timestamps.
    }
    if (elapsedSeconds > EconomyConstants.offlineCapSeconds) {
      elapsedSeconds = EconomyConstants.offlineCapSeconds; // 8h / 28,800s cap.
    }

    final interval = state.tickIntervalSeconds <= 0
        ? SimulationState.fixedTickIntervalSeconds
        : state.tickIntervalSeconds;

    var ticks = elapsedSeconds ~/ interval; // Whole ticks; sub-tick ignored.
    if (ticks > maxOfflineTicks) {
      ticks = maxOfflineTicks; // Defensive 5,760-tick cap.
    }

    if (ticks <= 0) {
      return OfflineResolution(
        state: state,
        elapsedSeconds: elapsedSeconds,
        resolvedTicks: 0,
        goldEarned: 0,
        demandServed: 0,
        demandMissed: 0,
        didResolve: false,
      );
    }

    final goldBefore = state.resources.lifetimeGoldEarned;
    final servedBefore = _totalServed(state);
    final missedBefore = _totalMissed(state);

    final result = _engine.runTicks(
      state,
      count: ticks,
      firstResolvedAtUtc: last.add(Duration(seconds: interval)),
      offline: true,
    );

    // Advance the resolved timestamp to now so the processed window (including
    // any capped excess and the sub-tick remainder) can never be replayed.
    final resolved = result.state.copyWith(lastResolvedTickAtUtc: now);

    return OfflineResolution(
      state: resolved,
      elapsedSeconds: elapsedSeconds,
      resolvedTicks: ticks,
      goldEarned: resolved.resources.lifetimeGoldEarned - goldBefore,
      demandServed: _totalServed(resolved) - servedBefore,
      demandMissed: _totalMissed(resolved) - missedBefore,
      didResolve: true,
    );
  }

  static int _totalServed(SimulationState state) {
    var total = 0;
    for (final building in state.buildings.values) {
      total += building.lifetimeDemandServed;
    }
    return total;
  }

  static int _totalMissed(SimulationState state) {
    var total = 0;
    for (final building in state.buildings.values) {
      total += building.lifetimeDemandLost;
    }
    return total;
  }
}
