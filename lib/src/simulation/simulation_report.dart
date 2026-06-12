import '../domain/domain.dart';

class SimulationRunReport {
  const SimulationRunReport({
    required this.currentTick,
    required this.demandGenerated,
    required this.demandServed,
    required this.demandLost,
    required this.goldEarned,
    required this.reputationEarned,
    required this.activeDemandBacklog,
    required this.primaryBottleneck,
    required this.demandGeneratedByType,
    required this.demandServedByType,
    required this.demandLostByType,
  });

  factory SimulationRunReport.fromState(SimulationState state) {
    final generatedByType = <DemandType, int>{};
    final servedByType = <DemandType, int>{};
    final lostByType = <DemandType, int>{};

    for (final building in state.buildings.values) {
      final demandType = building.servedDemandType;
      generatedByType[demandType] =
          (generatedByType[demandType] ?? 0) + building.lifetimeDemandReceived;
      servedByType[demandType] =
          (servedByType[demandType] ?? 0) + building.lifetimeDemandServed;
      lostByType[demandType] =
          (lostByType[demandType] ?? 0) + building.lifetimeDemandLost;
    }

    final demandGenerated =
        generatedByType.values.fold<int>(0, (a, b) => a + b);
    final demandServed = servedByType.values.fold<int>(0, (a, b) => a + b);
    final demandLost = lostByType.values.fold<int>(0, (a, b) => a + b);

    return SimulationRunReport(
      currentTick: state.currentTick,
      demandGenerated: demandGenerated,
      demandServed: demandServed,
      demandLost: demandLost,
      goldEarned: state.resources.lifetimeGoldEarned,
      reputationEarned: state.resources.lifetimeReputationEarned,
      activeDemandBacklog: state.activeDemands.length,
      primaryBottleneck: _primaryBottleneck(state),
      demandGeneratedByType: Map.unmodifiable(generatedByType),
      demandServedByType: Map.unmodifiable(servedByType),
      demandLostByType: Map.unmodifiable(lostByType),
    );
  }

  final int currentTick;
  final int demandGenerated;
  final int demandServed;
  final int demandLost;
  final int goldEarned;
  final int reputationEarned;
  final int activeDemandBacklog;
  final BuildingType? primaryBottleneck;
  final Map<DemandType, int> demandGeneratedByType;
  final Map<DemandType, int> demandServedByType;
  final Map<DemandType, int> demandLostByType;

  double get demandServedRate {
    if (demandGenerated == 0) {
      return 0;
    }
    return demandServed / demandGenerated;
  }

  double get goldPerService {
    if (demandServed == 0) {
      return 0;
    }
    return goldEarned / demandServed;
  }

  double get reputationPerService {
    if (demandServed == 0) {
      return 0;
    }
    return reputationEarned / demandServed;
  }

  bool get canAffordFirstUpgrade {
    return goldEarned >= EconomyConstants.firstUpgradeGoldCost;
  }

  Map<String, Object?> toJson() {
    return {
      'currentTick': currentTick,
      'demandGenerated': demandGenerated,
      'demandServed': demandServed,
      'demandLost': demandLost,
      'demandServedPercent': _percent(demandServedRate),
      'goldEarned': goldEarned,
      'reputationEarned': reputationEarned,
      'goldPerService': _fixed(goldPerService),
      'reputationPerService': _fixed(reputationPerService),
      'activeDemandBacklog': activeDemandBacklog,
      'primaryBottleneck': primaryBottleneck?.code,
      'demandGeneratedByType': _demandMap(demandGeneratedByType),
      'demandServedByType': _demandMap(demandServedByType),
      'demandLostByType': _demandMap(demandLostByType),
      'canAffordFirstUpgrade': canAffordFirstUpgrade,
    };
  }

  static BuildingType? _primaryBottleneck(SimulationState state) {
    Building? bottleneck;
    for (final building in state.buildings.values) {
      if (!building.isConstructed || building.lifetimeDemandLost <= 0) {
        continue;
      }
      if (bottleneck == null ||
          building.lifetimeDemandLost > bottleneck.lifetimeDemandLost) {
        bottleneck = building;
      }
    }
    return bottleneck?.buildingType;
  }

  static Map<String, int> _demandMap(Map<DemandType, int> values) {
    return {
      for (final type in DemandType.values) type.code: values[type] ?? 0,
    };
  }

  static double _percent(double value) {
    return _fixed(value * 100);
  }

  static double _fixed(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}
