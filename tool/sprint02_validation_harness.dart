import 'dart:convert';

import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:adventurer_town/src/simulation/simulation_report.dart';

void main(List<String> args) {
  final scenario = args.isEmpty ? 'scenario1' : args.first.toLowerCase();

  switch (scenario) {
    case 'scenario1':
    case 'baseline100':
      _runScenario1();
      return;
    case 'scenario2':
    case 'capacity100':
      _runScenario2();
      return;
    case 'scenario3':
    case 'value100':
      _runScenario3();
      return;
    case 'scenario4':
    case 'progression500':
      _runScenario4();
      return;
    case 'scenario5':
    case 'stability1000':
      _runScenario5();
      return;
    default:
      throw ArgumentError.value(
        scenario,
        'scenario',
        'Supported scenarios: scenario1, baseline100, scenario2, capacity100, '
            'scenario3, value100, scenario4, progression500, '
            'scenario5, stability1000.',
      );
  }
}

void _runScenario1() {
  final start = DateTime.utc(2026, 6, 9);
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
  final result = const SimulationEngine().runTicks(
    initial,
    count: 100,
    firstResolvedAtUtc: start,
  );
  final report = SimulationRunReport.fromState(result.state);
  final checks = _scenario1Checks(report);

  final output = {
    'scenario': 'Scenario 1 - 100 Tick Baseline Run',
    'seed': 1001,
    'ticks': 100,
    'report': report.toJson(),
    'checks': checks,
    'pass': checks.values.every((passed) => passed),
  };

  print(const JsonEncoder.withIndent('  ').convert(output));
}

void _runScenario2() {
  final baseline = _runScenario(
    tavernCapacityLevel: 1,
    tavernValueLevel: 1,
  );
  final upgraded = _runScenario(
    tavernCapacityLevel: 2,
    tavernValueLevel: 1,
  );
  final checks = _scenario2Checks(baseline.report, upgraded.report);

  final output = {
    'scenario': 'Scenario 2 - 100 Tick Capacity Upgrade Comparison',
    'seed': 1001,
    'ticks': 100,
    'baseline': {
      'tavernCapacityLevel': 1,
      'report': baseline.report.toJson(),
    },
    'capacityUpgrade': {
      'tavernCapacityLevel': 2,
      'report': upgraded.report.toJson(),
    },
    'comparison': {
      'baselineDemandServedPercent': _percent(baseline.report.demandServedRate),
      'capacityDemandServedPercent': _percent(upgraded.report.demandServedRate),
      'baselineFoodServedPercent': _percent(_servedRateFor(
        baseline.report,
        DemandType.food,
      )),
      'capacityFoodServedPercent': _percent(_servedRateFor(
        upgraded.report,
        DemandType.food,
      )),
      'baselineLostFoodDemand':
          baseline.report.demandLostByType[DemandType.food] ?? 0,
      'capacityLostFoodDemand':
          upgraded.report.demandLostByType[DemandType.food] ?? 0,
    },
    'checks': checks,
    'pass': checks.values.every((passed) => passed),
  };

  print(const JsonEncoder.withIndent('  ').convert(output));
}

void _runScenario3() {
  final baseline = _runScenario(
    tavernCapacityLevel: 2,
    tavernValueLevel: 1,
  );
  final upgraded = _runScenario(
    tavernCapacityLevel: 2,
    tavernValueLevel: 2,
  );
  final checks = _scenario3Checks(baseline.report, upgraded.report);

  final output = {
    'scenario': 'Scenario 3 - 100 Tick Value Upgrade Comparison',
    'seed': 1001,
    'ticks': 100,
    'baseline': {
      'tavernCapacityLevel': 2,
      'tavernValueLevel': 1,
      'report': baseline.report.toJson(),
    },
    'valueUpgrade': {
      'tavernCapacityLevel': 2,
      'tavernValueLevel': 2,
      'report': upgraded.report.toJson(),
    },
    'comparison': {
      'baselineDemandServedPercent': _percent(baseline.report.demandServedRate),
      'valueDemandServedPercent': _percent(upgraded.report.demandServedRate),
      'baselineGoldPerService': _fixed(baseline.report.goldPerService),
      'valueGoldPerService': _fixed(upgraded.report.goldPerService),
      'baselineReputationPerService':
          _fixed(baseline.report.reputationPerService),
      'valueReputationPerService': _fixed(upgraded.report.reputationPerService),
    },
    'checks': checks,
    'pass': checks.values.every((passed) => passed),
  };

  print(const JsonEncoder.withIndent('  ').convert(output));
}

void _runScenario4() {
  final run = _runProgressionScenario(ticks: 500);
  final replay = _runProgressionScenario(ticks: 500);
  final progression = _progressionReport(run.state);
  final replayMatches =
      jsonEncode(run.state.toJson()) == jsonEncode(replay.state.toJson());
  final checks = _scenario4Checks(
    state: run.state,
    report: run.report,
    replayMatches: replayMatches,
  );

  final output = {
    'scenario': 'Scenario 4 - 500 Tick Progression Run',
    'seed': 5001,
    'ticks': 500,
    'startingBuildings': const ['inn', 'tavern', 'blacksmith'],
    'report': run.report.toJson(),
    'progression': progression,
    'checks': checks,
    'pass': checks.values.every((passed) => passed),
  };

  print(const JsonEncoder.withIndent('  ').convert(output));
}

void _runScenario5() {
  final run = _runAuditedStabilityScenario(ticks: 1000);
  final replay = _runAuditedStabilityScenario(ticks: 1000);
  final replayMatches =
      jsonEncode(run.state.toJson()) == jsonEncode(replay.state.toJson());
  final economicHealth = _economicHealthReport(run.state);
  final upgradeSummary = _upgradeSummary(run.state);
  final checks = _scenario5Checks(
    state: run.state,
    report: run.report,
    audit: run.audit,
    replayMatches: replayMatches,
  );

  final output = {
    'scenario': 'Scenario 5 - 1000 Tick Stability Run',
    'seed': 10001,
    'ticks': 1000,
    'startingBuildings': const ['inn', 'tavern', 'blacksmith'],
    'report': run.report.toJson(),
    'economicHealth': economicHealth,
    'demandBreakdown': {
      'demandGeneratedByType':
          _demandMetricMap(run.report.demandGeneratedByType),
      'demandServedByType': _demandMetricMap(run.report.demandServedByType),
      'demandLostByType': _demandMetricMap(run.report.demandLostByType),
    },
    'upgradeSummary': upgradeSummary,
    'stability': run.audit.toJson(replayMatches: replayMatches),
    'checks': checks,
    'pass': checks.values.every((passed) => passed),
  };

  print(const JsonEncoder.withIndent('  ').convert(output));
}

({SimulationState state, SimulationRunReport report}) _runScenario({
  required int tavernCapacityLevel,
  required int tavernValueLevel,
}) {
  final start = DateTime.utc(2026, 6, 9);
  final initial = _initialState(
    start: start,
    tavernCapacityLevel: tavernCapacityLevel,
    tavernValueLevel: tavernValueLevel,
  );
  final result = const SimulationEngine().runTicks(
    initial,
    count: 100,
    firstResolvedAtUtc: start,
  );
  return (
    state: result.state,
    report: SimulationRunReport.fromState(result.state),
  );
}

({SimulationState state, SimulationRunReport report}) _runProgressionScenario({
  required int ticks,
}) {
  final start = DateTime.utc(2026, 6, 9);
  final initial = _progressionInitialState(start: start);
  final result = const SimulationEngine().runTicks(
    initial,
    count: ticks,
    firstResolvedAtUtc: start,
  );
  return (
    state: result.state,
    report: SimulationRunReport.fromState(result.state),
  );
}

({SimulationState state, SimulationRunReport report, StabilityAudit audit})
    _runAuditedStabilityScenario({
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
  final audit = StabilityAudit(
    maxActiveDemandBacklog: maxBacklog,
    minGold: minGold,
    minReputation: minReputation,
    invalidCountsObserved: invalidCountsObserved,
    invalidFiniteValuesObserved: invalidFiniteValuesObserved,
    invalidPercentagesObserved: !_validRate(report.demandServedRate),
  );

  return (
    state: state,
    report: report,
    audit: audit,
  );
}

SimulationState _initialState({
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

  return initial.copyWith(
    buildings: buildings,
    unlockedTiers: const {AdventurerTier.novice},
  );
}

SimulationState _progressionInitialState({required DateTime start}) {
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

  return initial.copyWith(
    buildings: buildings,
    unlockedTiers: const {AdventurerTier.novice},
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

Map<String, bool> _scenario1Checks(SimulationRunReport report) {
  return {
    'demandGeneratedGreaterThanZero': report.demandGenerated > 0,
    'demandServedGreaterThanZero': report.demandServed > 0,
    'demandLostGreaterThanZero': report.demandLost > 0,
    'goldEarnedGreaterThanZero': report.goldEarned > 0,
    'reputationEarnedGreaterThanZero': report.reputationEarned > 0,
    'servedPercentWithinExpectedRange':
        report.demandServedRate >= 0.45 && report.demandServedRate <= 0.85,
    'primaryBottleneckIsTavern':
        report.primaryBottleneck == BuildingType.tavern,
    'firstUpgradeAffordableOrNear': report.goldEarned >= 40,
    'noDemandBacklog': report.activeDemandBacklog == 0,
  };
}

Map<String, bool> _scenario2Checks(
  SimulationRunReport baseline,
  SimulationRunReport upgraded,
) {
  return {
    'demandGeneratedEqual':
        baseline.demandGenerated == upgraded.demandGenerated,
    'foodDemandGeneratedEqual':
        baseline.demandGeneratedByType[DemandType.food] ==
            upgraded.demandGeneratedByType[DemandType.food],
    'demandServedPercentImproved':
        upgraded.demandServedRate > baseline.demandServedRate,
    'foodServedPercentImproved': _servedRateFor(upgraded, DemandType.food) >
        _servedRateFor(baseline, DemandType.food),
    'lostFoodDemandDecreased':
        (upgraded.demandLostByType[DemandType.food] ?? 0) <
            (baseline.demandLostByType[DemandType.food] ?? 0),
    'goldEarnedEqualOrHigher': upgraded.goldEarned >= baseline.goldEarned,
    'reputationEarnedEqualOrHigher':
        upgraded.reputationEarned >= baseline.reputationEarned,
    'baselineNoDemandBacklog': baseline.activeDemandBacklog == 0,
    'capacityNoDemandBacklog': upgraded.activeDemandBacklog == 0,
  };
}

Map<String, bool> _scenario3Checks(
  SimulationRunReport baseline,
  SimulationRunReport upgraded,
) {
  return {
    'demandGeneratedEqual':
        baseline.demandGenerated == upgraded.demandGenerated,
    'demandServedEqualOrNear': _nearEqual(
      baseline.demandServed,
      upgraded.demandServed,
    ),
    'demandServedPercentEqualOrNear': _nearEqualDouble(
      baseline.demandServedRate,
      upgraded.demandServedRate,
    ),
    'goldEarnedIncreased': upgraded.goldEarned > baseline.goldEarned,
    'goldPerServiceIncreased':
        upgraded.goldPerService > baseline.goldPerService,
    'reputationEarnedEqualOrNear': _nearEqual(
      baseline.reputationEarned,
      upgraded.reputationEarned,
    ),
    'baselineNoDemandBacklog': baseline.activeDemandBacklog == 0,
    'valueNoDemandBacklog': upgraded.activeDemandBacklog == 0,
  };
}

Map<String, bool> _scenario4Checks({
  required SimulationState state,
  required SimulationRunReport report,
  required bool replayMatches,
}) {
  return {
    'demandGeneratedGreaterThan100': report.demandGenerated > 100,
    'servedPercentWithinExpectedRange':
        report.demandServedRate >= 0.50 && report.demandServedRate <= 0.90,
    'goldEarnedSupportsMultipleEarlyUpgrades':
        report.goldEarned >= EconomyConstants.firstUpgradeGoldCost * 2 &&
            _affordableUpgradeCount(state) > 1,
    'reputationProgressesTowardVeteranUnlock':
        report.reputationEarned > 0 && _progressTowardVeteranUnlock(state) > 0,
    'lostDemandPresentAndAttributable': report.demandLost > 0 &&
        _buildingProducingMostLostDemand(state) != null,
    'bottleneckVisible': report.primaryBottleneck != null,
    'noDemandBacklog':
        report.activeDemandBacklog == 0 && state.activeDemands.isEmpty,
    'goldNeverNegative':
        state.resources.gold >= 0 && state.resources.lifetimeGoldEarned >= 0,
    'reputationNeverNegative': state.resources.reputation >= 0 &&
        state.resources.lifetimeReputationEarned >= 0,
    'stateContainsOnlyApprovedMvpEconomySystems':
        _stateContainsOnlyApprovedMvpEconomySystems(state),
    'deterministicReplayMatches': replayMatches,
  };
}

Map<String, bool> _scenario5Checks({
  required SimulationState state,
  required SimulationRunReport report,
  required StabilityAudit audit,
  required bool replayMatches,
}) {
  return {
    'simulationCompletes': report.currentTick == 1000,
    'demandContinuesToGenerate': report.demandGenerated > 0,
    'demandContinuesToResolve':
        report.demandGenerated == report.demandServed + report.demandLost,
    'demandServedGreaterThanZero': report.demandServed > 0,
    'goldEarnedGreaterThanZero': report.goldEarned > 0,
    'reputationEarnedGreaterThanZero': report.reputationEarned > 0,
    'noDemandBacklog': report.activeDemandBacklog == 0 &&
        state.activeDemands.isEmpty &&
        audit.maxActiveDemandBacklog == 0,
    'goldNeverNegative': audit.minGold >= 0,
    'reputationNeverNegative': audit.minReputation >= 0,
    'upgradeLevelsWithinBounds': _upgradeLevelsWithinBounds(state),
    'noInvalidUpgradeState': _noInvalidUpgradeState(state),
    'meaningfulBottleneckVisible': report.primaryBottleneck != null,
    'noInvalidCounts': !audit.invalidCountsObserved,
    'noNaNOrInfinityValues': !audit.invalidFiniteValuesObserved,
    'validPercentages': !audit.invalidPercentagesObserved,
    'deterministicReplayMatches': replayMatches,
    'stateContainsOnlyApprovedMvpEconomySystems':
        _stateContainsOnlyApprovedMvpEconomySystems(state),
  };
}

Map<String, Object?> _economicHealthReport(SimulationState state) {
  return {
    'affordableUpgradeCount': _affordableUpgradeCount(state),
    'highestUnlockedTier': _highestUnlockedTier(state).code,
    'highestEligibleTierByReputation':
        _highestTierForReputation(state.resources.reputation).code,
    'progressTowardNextTier': _fixed(_progressTowardNextTier(state)),
    'strongestGoldBuilding': _buildingProducingMostGold(state)?.code,
    'highestLostDemandBuilding': _buildingProducingMostLostDemand(state)?.code,
  };
}

Map<String, Object?> _upgradeSummary(SimulationState state) {
  return {
    'capacityUpgradesAffordable':
        _affordableUpgradeCountForAxis(state, UpgradeAxis.capacity),
    'valueUpgradesAffordable':
        _affordableUpgradeCountForAxis(state, UpgradeAxis.value),
  };
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

  Map<String, Object?> toJson({required bool replayMatches}) {
    return {
      'maxActiveDemandBacklog': maxActiveDemandBacklog,
      'minGold': minGold,
      'minReputation': minReputation,
      'invalidCountsObserved': invalidCountsObserved,
      'invalidFiniteValuesObserved': invalidFiniteValuesObserved,
      'invalidPercentagesObserved': invalidPercentagesObserved,
      'deterministicReplayMatches': replayMatches,
    };
  }
}

Map<String, Object?> _progressionReport(SimulationState state) {
  final thresholdsReached = _reputationThresholdsReached(
    state.resources.reputation,
  );
  return {
    'canAffordFirstCapacityUpgrade': _canAffordFirstUpgrade(
      state,
      UpgradeAxis.capacity,
    ),
    'canAffordFirstValueUpgrade': _canAffordFirstUpgrade(
      state,
      UpgradeAxis.value,
    ),
    'affordableUpgradeCount': _affordableUpgradeCount(state),
    'progressTowardVeteranUnlock': _fixed(
      _progressTowardVeteranUnlock(state),
    ),
    'reputationThresholdsReached': [
      for (final tier in thresholdsReached) tier.code,
    ],
    'highestEligibleAdventurerTierByReputation':
        _highestTierForReputation(state.resources.reputation).code,
    'highestLostDemandBuilding': _buildingProducingMostLostDemand(state)?.code,
    'strongestGoldBuilding': _buildingProducingMostGold(state)?.code,
    'lostDemandByBuilding': _buildingMetricMap(
      state,
      (building) => building.lifetimeDemandLost,
    ),
    'goldEarnedByBuilding': _buildingMetricMap(
      state,
      (building) => building.lifetimeGoldEarned,
    ),
  };
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

double _servedRateFor(SimulationRunReport report, DemandType demandType) {
  final generated = report.demandGeneratedByType[demandType] ?? 0;
  if (generated == 0) {
    return 0;
  }
  return (report.demandServedByType[demandType] ?? 0) / generated;
}

bool _canAffordFirstUpgrade(SimulationState state, UpgradeAxis axis) {
  return state.buildings.values.where((building) => building.isConstructed).any(
    (building) {
      final level = axis == UpgradeAxis.capacity
          ? building.capacityLevel
          : building.valueLevel;
      return level == EconomyConstants.minimumLevel &&
          _canAffordNextLevel(
            gold: state.resources.gold,
            reputation: state.resources.reputation,
            currentLevel: level,
          );
    },
  );
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
      final currentLevel = upgradeLevels[i];
      final nextLevel = currentLevel + 1;
      if (nextLevel > EconomyConstants.maximumUpgradeLevel) {
        continue;
      }
      if (!_reputationAllowsUpgrade(
        reputation: state.resources.reputation,
        targetLevel: nextLevel,
      )) {
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
      if (!_reputationAllowsUpgrade(
        reputation: state.resources.reputation,
        targetLevel: nextLevel,
      )) {
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

bool _canAffordNextLevel({
  required int gold,
  required int reputation,
  required int currentLevel,
}) {
  final nextLevel = currentLevel + 1;
  if (nextLevel > EconomyConstants.maximumUpgradeLevel) {
    return false;
  }

  return gold >= EconomyConstants.upgradeGoldCostToReachLevel(nextLevel) &&
      _reputationAllowsUpgrade(
        reputation: reputation,
        targetLevel: nextLevel,
      );
}

bool _reputationAllowsUpgrade({
  required int reputation,
  required int targetLevel,
}) {
  return reputation >=
      EconomyConstants.reputationRequiredForUpgradeLevel(targetLevel);
}

List<AdventurerTier> _reputationThresholdsReached(int reputation) {
  return [
    for (final tier in AdventurerTier.values)
      if (reputation >= EconomyConstants.tierReputationUnlock[tier]!) tier,
  ];
}

AdventurerTier _highestTierForReputation(int reputation) {
  return _reputationThresholdsReached(reputation).last;
}

AdventurerTier _highestUnlockedTier(SimulationState state) {
  return state.unlockedTiers.reduce(
    (highest, tier) => tier.index > highest.index ? tier : highest,
  );
}

double _progressTowardNextTier(SimulationState state) {
  final highestUnlockedTier = _highestUnlockedTier(state);
  final nextTierIndex = highestUnlockedTier.index + 1;
  if (nextTierIndex >= AdventurerTier.values.length) {
    return 1;
  }
  final nextTier = AdventurerTier.values[nextTierIndex];
  final required = EconomyConstants.tierReputationUnlock[nextTier]!;
  if (required <= 0) {
    return 1;
  }
  final progress = state.resources.reputation / required;
  return progress > 1 ? 1 : progress;
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

bool _noInvalidUpgradeState(SimulationState state) {
  return state.buildings.values.every(
    (building) =>
        building.capacityLevel <= EconomyConstants.maximumUpgradeLevel &&
        building.valueLevel <= EconomyConstants.maximumUpgradeLevel &&
        building.capacityLevel >= EconomyConstants.minimumLevel &&
        building.valueLevel >= EconomyConstants.minimumLevel,
  );
}

Map<String, int> _buildingMetricMap(
  SimulationState state,
  int Function(Building building) metric,
) {
  return {
    for (final building in state.buildings.values)
      if (building.isConstructed) building.buildingType.code: metric(building),
  };
}

Map<String, int> _demandMetricMap(Map<DemandType, int> metric) {
  return {
    for (final type in DemandType.values) type.code: metric[type] ?? 0,
  };
}

bool _stateContainsOnlyApprovedMvpEconomySystems(SimulationState state) {
  final resourceKeys = state.resources.toJson().keys.toSet();
  const approvedResourceKeys = {
    'gold',
    'reputation',
    'lifetimeGoldEarned',
    'lifetimeReputationEarned',
  };
  return resourceKeys.difference(approvedResourceKeys).isEmpty &&
      BuildingType.values.length == 5 &&
      DemandType.values.length == 5 &&
      UpgradeAxis.values.length == 2;
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

double _percent(double value) {
  return double.parse((value * 100).toStringAsFixed(2));
}

double _fixed(double value) {
  return double.parse(value.toStringAsFixed(2));
}

bool _nearEqual(int baseline, int comparison) {
  return (baseline - comparison).abs() <= 1;
}

bool _nearEqualDouble(double baseline, double comparison) {
  return (baseline - comparison).abs() <= 0.01;
}
