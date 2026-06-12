import 'dart:convert';

import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';

void main(List<String> args) {
  final tickCount = args.isEmpty ? 5 : int.tryParse(args.first) ?? 5;
  final start = DateTime.utc(2026, 6, 9);
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 692026);
  final result = const SimulationEngine().runTicks(
    initial,
    count: tickCount,
    firstResolvedAtUtc: start,
  );
  final state = result.state;

  final summary = {
    'currentTick': state.currentTick,
    'gold': state.resources.gold,
    'reputation': state.resources.reputation,
    'activeDemands': state.activeDemands.length,
    'adventurers': state.adventurers.length,
    'eventFeedEntries': state.eventFeed.length,
    'tavernLostDemand': state.buildings[BuildingType.tavern]?.lifetimeDemandLost,
  };

  print(const JsonEncoder.withIndent('  ').convert(summary));
}
