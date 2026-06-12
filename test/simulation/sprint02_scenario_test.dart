import 'dart:convert';

import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:adventurer_town/src/simulation/simulation_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sprint 02 Scenario 1', () {
    test('100 tick baseline run with seed 1001 passes Phase 1 expectations',
        () {
      final start = DateTime.utc(2026, 6, 9);
      final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
      final result = const SimulationEngine().runTicks(
        initial,
        count: 100,
        firstResolvedAtUtc: start,
      );
      final report = SimulationRunReport.fromState(result.state);

      expect(report.currentTick, 100);
      expect(report.demandGenerated, greaterThan(0));
      expect(report.demandServed, greaterThan(0));
      expect(report.demandLost, greaterThan(0));
      expect(report.goldEarned, greaterThan(0));
      expect(report.reputationEarned, greaterThan(0));
      expect(report.demandServedRate, inInclusiveRange(0.45, 0.85));
      expect(report.primaryBottleneck, BuildingType.tavern);
      expect(report.demandLostByType[DemandType.food], greaterThan(0));
      expect(report.canAffordFirstUpgrade, isTrue);
      expect(report.activeDemandBacklog, 0);
      expect(result.state.activeDemands, isEmpty);
    });
  });

  group('Sprint 02 Scenario 2', () {
    test('capacity upgrade comparison improves Tavern throughput', () {
      final start = DateTime.utc(2026, 6, 9);
      final baseline = _runScenarioState(
        start: start,
        tavernCapacityLevel: 1,
        tavernValueLevel: 1,
      );
      final upgraded = _runScenarioState(
        start: start,
        tavernCapacityLevel: 2,
        tavernValueLevel: 1,
      );
      final baselineReport = SimulationRunReport.fromState(baseline);
      final upgradedReport = SimulationRunReport.fromState(upgraded);

      expect(
        upgradedReport.demandGenerated,
        baselineReport.demandGenerated,
      );
      expect(
        upgradedReport.demandGeneratedByType[DemandType.food],
        baselineReport.demandGeneratedByType[DemandType.food],
      );
      expect(
        upgradedReport.demandServedRate,
        greaterThan(baselineReport.demandServedRate),
      );
      expect(
        _servedRateFor(upgradedReport, DemandType.food),
        greaterThan(_servedRateFor(baselineReport, DemandType.food)),
      );
      expect(
        upgradedReport.demandLostByType[DemandType.food],
        lessThan(baselineReport.demandLostByType[DemandType.food]!),
      );
      expect(
        upgradedReport.goldEarned,
        greaterThanOrEqualTo(baselineReport.goldEarned),
      );
      expect(
        upgradedReport.reputationEarned,
        greaterThanOrEqualTo(baselineReport.reputationEarned),
      );
      expect(baseline.activeDemands, isEmpty);
      expect(upgraded.activeDemands, isEmpty);
    });
  });

  group('Sprint 02 Scenario 3', () {
    test('value upgrade comparison improves Gold efficiency only', () {
      final start = DateTime.utc(2026, 6, 9);
      final baseline = _runScenarioState(
        start: start,
        tavernCapacityLevel: 2,
        tavernValueLevel: 1,
      );
      final upgraded = _runScenarioState(
        start: start,
        tavernCapacityLevel: 2,
        tavernValueLevel: 2,
      );
      final baselineReport = SimulationRunReport.fromState(baseline);
      final upgradedReport = SimulationRunReport.fromState(upgraded);

      expect(upgradedReport.demandGenerated, baselineReport.demandGenerated);
      expect(
          upgradedReport.demandServed, closeTo(baselineReport.demandServed, 1));
      expect(
        upgradedReport.demandServedRate,
        closeTo(baselineReport.demandServedRate, 0.01),
      );
      expect(upgradedReport.goldEarned, greaterThan(baselineReport.goldEarned));
      expect(
        upgradedReport.goldPerService,
        greaterThan(baselineReport.goldPerService),
      );
      expect(
        upgradedReport.reputationEarned,
        closeTo(baselineReport.reputationEarned, 1),
      );
      expect(baseline.activeDemands, isEmpty);
      expect(upgraded.activeDemands, isEmpty);
    });
  });

  group('Sprint 02 Scenario 4', () {
    test('500 tick progression run validates long-horizon MVP economy', () {
      final start = DateTime.utc(2026, 6, 9);
      final result = _runProgressionState(start: start, ticks: 500);
      final replay = _runProgressionState(start: start, ticks: 500);
      final report = SimulationRunReport.fromState(result);

      expect(report.currentTick, 500);
      expect(report.demandGenerated, greaterThan(100));
      expect(report.demandServed, greaterThan(0));
      expect(report.demandLost, greaterThan(0));
      expect(report.demandServedRate, inInclusiveRange(0.50, 0.90));
      expect(report.demandGeneratedByType[DemandType.rest], greaterThan(0));
      expect(report.demandGeneratedByType[DemandType.food], greaterThan(0));
      expect(report.demandGeneratedByType[DemandType.gear], greaterThan(0));
      expect(report.demandServedByType[DemandType.rest], greaterThan(0));
      expect(report.demandServedByType[DemandType.food], greaterThan(0));
      expect(report.demandServedByType[DemandType.gear], greaterThan(0));
      expect(report.demandLostByType.values.fold<int>(0, (a, b) => a + b),
          greaterThan(0));
      expect(report.demandGenerated, report.demandServed + report.demandLost);
      expect(report.activeDemandBacklog, 0);
      expect(result.activeDemands, isEmpty);
      expect(result.resources.gold, greaterThanOrEqualTo(0));
      expect(result.resources.reputation, greaterThanOrEqualTo(0));
      expect(
        report.goldEarned,
        greaterThanOrEqualTo(EconomyConstants.firstUpgradeGoldCost * 2),
      );
      expect(_affordableUpgradeCount(result), greaterThan(1));
      expect(_progressTowardVeteranUnlock(result), greaterThan(0));
      expect(
        report.reputationEarned,
        greaterThanOrEqualTo(
          EconomyConstants.tierReputationUnlock[AdventurerTier.veteran]!,
        ),
      );
      expect(
        _highestTierForReputation(result.resources.reputation).index,
        greaterThanOrEqualTo(AdventurerTier.veteran.index),
      );
      expect(
        result.buildings[BuildingType.tavern]!.lifetimeDemandLost,
        greaterThan(0),
      );
      expect(report.primaryBottleneck, isNotNull);
      expect(_buildingProducingMostLostDemand(result), isNotNull);
      expect(_buildingProducingMostGold(result), isNotNull);
      expect(jsonEncode(result.toJson()), jsonEncode(replay.toJson()));
      expect(
        result.resources.toJson().keys,
        unorderedEquals([
          'gold',
          'reputation',
          'lifetimeGoldEarned',
          'lifetimeReputationEarned',
        ]),
      );
    });
  });

  group('Sprint 02 Scenario 5', () {
    test('1000 tick stability run validates long-run simulation bounds', () {
      final run = _runAuditedStabilityState(ticks: 1000);
      final replay = _runAuditedStabilityState(ticks: 1000);
      final result = run.state;
      final report = run.report;

      expect(report.currentTick, 1000);
      expect(report.demandGenerated, greaterThan(0));
      expect(report.demandServed, greaterThan(0));
      expect(report.demandLost, greaterThan(0));
      expect(report.demandServedRate, inInclusiveRange(0, 1));
      expect(report.demandGeneratedByType[DemandType.rest], greaterThan(0));
      expect(report.demandGeneratedByType[DemandType.food], greaterThan(0));
      expect(report.demandGeneratedByType[DemandType.gear], greaterThan(0));
      expect(report.goldEarned, greaterThan(0));
      expect(report.reputationEarned, greaterThan(0));
      expect(report.demandGenerated, report.demandServed + report.demandLost);
      expect(report.activeDemandBacklog, 0);
      expect(result.activeDemands, isEmpty);
      expect(run.audit.maxActiveDemandBacklog, 0);
      expect(run.audit.minGold, greaterThanOrEqualTo(0));
      expect(run.audit.minReputation, greaterThanOrEqualTo(0));
      expect(result.resources.gold, greaterThanOrEqualTo(0));
      expect(result.resources.reputation, greaterThanOrEqualTo(0));
      expect(_affordableUpgradeCount(result), greaterThan(0));
      expect(_affordableUpgradeCountForAxis(result, UpgradeAxis.capacity),
          greaterThan(0));
      expect(_affordableUpgradeCountForAxis(result, UpgradeAxis.value),
          greaterThan(0));
      expect(_upgradeLevelsWithinBounds(result), isTrue);
      expect(_buildingProducingMostLostDemand(result), isNotNull);
      expect(_buildingProducingMostGold(result), isNotNull);
      expect(report.primaryBottleneck, isNotNull);
      expect(run.audit.invalidCountsObserved, isFalse);
      expect(run.audit.invalidFiniteValuesObserved, isFalse);
      expect(run.audit.invalidPercentagesObserved, isFalse);
      expect(jsonEncode(result.toJson()), jsonEncode(replay.state.toJson()));
      expect(
        result.resources.toJson().keys,
        unorderedEquals([
          'gold',
          'reputation',
          'lifetimeGoldEarned',
          'lifetimeReputationEarned',
        ]),
      );
    });
  });
}

SimulationState _runScenarioState({
  required DateTime start,
  required int tavernCapacityLevel,
  required int tavernValueLevel,
}) {
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    capacityLevel: tavernCapacityLevel,
    valueLevel: tavernValueLevel,
  );

  final result = const SimulationEngine().runTicks(
    initial.copyWith(
      buildings: buildings,
      unlockedTiers: const {AdventurerTier.novice},
    ),
    count: 100,
    firstResolvedAtUtc: start,
  );
  return result.state;
}

SimulationState _runProgressionState({
  required DateTime start,
  required int ticks,
}) {
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 5001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  buildings[BuildingType.inn] = buildings[BuildingType.inn]!.copyWith(
    isConstructed: true,
    capacityLevel: 1,
    valueLevel: 1,
    constructedTick: 0,
  );
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    isConstructed: true,
    capacityLevel: 1,
    valueLevel: 1,
    constructedTick: 0,
  );
  buildings[BuildingType.blacksmith] =
      buildings[BuildingType.blacksmith]!.copyWith(
    isConstructed: true,
    capacityLevel: 1,
    valueLevel: 1,
    constructedTick: 0,
  );

  final result = const SimulationEngine().runTicks(
    initial.copyWith(
      buildings: buildings,
      unlockedTiers: const {AdventurerTier.novice},
    ),
    count: ticks,
    firstResolvedAtUtc: start,
  );
  return result.state;
}

double _progressTowardVeteranUnlock(SimulationState state) {
  final veteranRequirement =
      EconomyConstants.tierReputationUnlock[AdventurerTier.veteran]!;
  if (veteranRequirement <= 0) {
    return 1;
  }
  final progress = state.resources.reputation / veteranRequirement;
  return progress > 1 ? 1 : progress;
}

({SimulationState state, SimulationRunReport report, StabilityAudit audit})
    _runAuditedStabilityState({
  required int ticks,
}) {
  final start = DateTime.utc(2026, 6, 9);
  var state = _stabilityInitialState(start: start);
  var maxBacklog = state.activeDemands.length;
  var minGold = state.resources.gold;
  var minReputation = state.resources.reputation;
  var invalidCountsObserved = false;
  var invalidFiniteValuesObserved = false;

  for (var i = 0; i < ticks; i += 1) {
    final result = const SimulationEngine().tick(
      state,
      resolvedAtUtc: start.add(
        Duration(seconds: SimulationState.fixedTickIntervalSeconds * i),
      ),
    );
    state = result.state;
    maxBacklog = _max(maxBacklog, state.activeDemands.length);
    minGold = _min(minGold, state.resources.gold);
    minReputation = _min(minReputation, state.resources.reputation);
    invalidCountsObserved = invalidCountsObserved || _hasInvalidCounts(state);
    invalidFiniteValuesObserved =
        invalidFiniteValuesObserved || _hasInvalidFiniteValues(state);
  }

  final report = SimulationRunReport.fromState(state);
  return (
    state: state,
    report: report,
    audit: StabilityAudit(
      maxActiveDemandBacklog: maxBacklog,
      minGold: minGold,
      minReputation: minReputation,
      invalidCountsObserved: invalidCountsObserved,
      invalidFiniteValuesObserved: invalidFiniteValuesObserved,
      invalidPercentagesObserved: !_validRate(report.demandServedRate),
    ),
  );
}

SimulationState _stabilityInitialState({required DateTime start}) {
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 10001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  for (final type in const [
    BuildingType.inn,
    BuildingType.tavern,
    BuildingType.blacksmith,
  ]) {
    buildings[type] = buildings[type]!.copyWith(
      isConstructed: true,
      capacityLevel: 1,
      valueLevel: 1,
      constructedTick: 0,
    );
  }
  for (final type in const [BuildingType.healer, BuildingType.market]) {
    buildings[type] = buildings[type]!.copyWith(
      isConstructed: false,
      capacityLevel: 1,
      valueLevel: 1,
    );
  }

  return initial.copyWith(
    buildings: buildings,
    unlockedTiers: const {AdventurerTier.novice},
  );
}

class StabilityAudit {
  const StabilityAudit({
    required this.maxActiveDemandBacklog,
    required this.minGold,
    required this.minReputation,
    required this.invalidCountsObserved,
    required this.invalidFiniteValuesObserved,
    required this.invalidPercentagesObserved,
  });

  final int maxActiveDemandBacklog;
  final int minGold;
  final int minReputation;
  final bool invalidCountsObserved;
  final bool invalidFiniteValuesObserved;
  final bool invalidPercentagesObserved;
}

double _servedRateFor(SimulationRunReport report, DemandType demandType) {
  final generated = report.demandGeneratedByType[demandType] ?? 0;
  if (generated == 0) {
    return 0;
  }
  return (report.demandServedByType[demandType] ?? 0) / generated;
}

int _affordableUpgradeCount(SimulationState state) {
  return _affordableUpgradeCountForGold(state, state.resources.gold);
}

int _affordableUpgradeCountForGold(SimulationState state, int goldBudget) {
  var remainingGold = goldBudget;
  var purchased = 0;
  final upgradeLevels = <int>[
    for (final building in state.buildings.values)
      if (building.isConstructed) ...[
        building.capacityLevel,
        building.valueLevel,
      ],
  ];

  while (true) {
    var selectedIndex = -1;
    var selectedCost = 1 << 62;

    for (var i = 0; i < upgradeLevels.length; i += 1) {
      final nextLevel = upgradeLevels[i] + 1;
      if (nextLevel > EconomyConstants.maximumUpgradeLevel) {
        continue;
      }
      if (state.resources.reputation <
          EconomyConstants.reputationRequiredForUpgradeLevel(nextLevel)) {
        continue;
      }

      final cost = EconomyConstants.upgradeGoldCostToReachLevel(nextLevel);
      if (cost <= remainingGold && cost < selectedCost) {
        selectedIndex = i;
        selectedCost = cost;
      }
    }

    if (selectedIndex < 0) {
      return purchased;
    }

    remainingGold -= selectedCost;
    upgradeLevels[selectedIndex] += 1;
    purchased += 1;
  }
}

int _affordableUpgradeCountForAxis(SimulationState state, UpgradeAxis axis) {
  var remainingGold = state.resources.gold;
  var purchased = 0;
  final upgradeLevels = <int>[
    for (final building in state.buildings.values)
      if (building.isConstructed)
        axis == UpgradeAxis.capacity
            ? building.capacityLevel
            : building.valueLevel,
  ];

  while (true) {
    var selectedIndex = -1;
    var selectedCost = 1 << 62;

    for (var i = 0; i < upgradeLevels.length; i += 1) {
      final nextLevel = upgradeLevels[i] + 1;
      if (nextLevel > EconomyConstants.maximumUpgradeLevel) {
        continue;
      }
      if (state.resources.reputation <
          EconomyConstants.reputationRequiredForUpgradeLevel(nextLevel)) {
        continue;
      }

      final cost = EconomyConstants.upgradeGoldCostToReachLevel(nextLevel);
      if (cost <= remainingGold && cost < selectedCost) {
        selectedIndex = i;
        selectedCost = cost;
      }
    }

    if (selectedIndex < 0) {
      return purchased;
    }

    remainingGold -= selectedCost;
    upgradeLevels[selectedIndex] += 1;
    purchased += 1;
  }
}

AdventurerTier _highestTierForReputation(int reputation) {
  var highest = AdventurerTier.novice;
  for (final tier in AdventurerTier.values) {
    if (reputation >= EconomyConstants.tierReputationUnlock[tier]!) {
      highest = tier;
    }
  }
  return highest;
}

BuildingType? _buildingProducingMostLostDemand(SimulationState state) {
  return _buildingWithHighestMetric(
    state,
    (building) => building.lifetimeDemandLost,
  );
}

BuildingType? _buildingProducingMostGold(SimulationState state) {
  return _buildingWithHighestMetric(
    state,
    (building) => building.lifetimeGoldEarned,
  );
}

BuildingType? _buildingWithHighestMetric(
  SimulationState state,
  int Function(Building building) metric,
) {
  Building? best;
  for (final building in state.buildings.values) {
    if (!building.isConstructed || metric(building) <= 0) {
      continue;
    }
    if (best == null || metric(building) > metric(best)) {
      best = building;
    }
  }
  return best?.buildingType;
}

bool _upgradeLevelsWithinBounds(SimulationState state) {
  return state.buildings.values.every(
    (building) =>
        building.capacityLevel >= EconomyConstants.minimumLevel &&
        building.capacityLevel <= EconomyConstants.maximumUpgradeLevel &&
        building.valueLevel >= EconomyConstants.minimumLevel &&
        building.valueLevel <= EconomyConstants.maximumUpgradeLevel,
  );
}

bool _hasInvalidCounts(SimulationState state) {
  if (state.currentTick < 0 ||
      state.resources.gold < 0 ||
      state.resources.reputation < 0 ||
      state.resources.lifetimeGoldEarned < 0 ||
      state.resources.lifetimeReputationEarned < 0) {
    return true;
  }

  return state.buildings.values.any(
    (building) =>
        building.lifetimeDemandReceived < 0 ||
        building.lifetimeDemandServed < 0 ||
        building.lifetimeDemandLost < 0 ||
        building.lifetimeGoldEarned < 0 ||
        building.recentDemandReceived < 0 ||
        building.recentDemandServed < 0 ||
        building.recentDemandLost < 0,
  );
}

bool _hasInvalidFiniteValues(SimulationState state) {
  return state.buildings.values.any(
    (building) =>
        !building.utilizationRatio.isFinite || building.utilizationRatio.isNaN,
  );
}

bool _validRate(double value) {
  return value.isFinite && !value.isNaN && value >= 0 && value <= 1;
}

int _max(int a, int b) {
  return a > b ? a : b;
}

int _min(int a, int b) {
  return a < b ? a : b;
}
