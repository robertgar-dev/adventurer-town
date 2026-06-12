import 'dart:math';

import 'enums.dart';

class EconomyConstants {
  const EconomyConstants._();

  static const int tickIntervalSeconds = 5;
  static const int offlineCapSeconds = 28800;
  static const int dayLengthTicks = 288;
  static const int recentMetricsWindowTicks = 120;

  static const int minimumLevel = 1;
  static const int maximumUpgradeLevel = 10;
  static const int firstUpgradeGoldCost = 50;

  static const Map<int, int> upgradeGoldCostByLevel = {
    1: 0,
    2: 50,
    3: 100,
    4: 200,
    5: 400,
    6: 800,
    7: 1600,
    8: 3200,
    9: 6400,
    10: 12800,
  };

  static const Map<BuildingType, int> baseCapacity = {
    BuildingType.inn: 2,
    BuildingType.tavern: 1,
    BuildingType.blacksmith: 1,
    BuildingType.healer: 1,
    BuildingType.market: 1,
  };

  static const Map<BuildingType, double> buildingBaseValue = {
    BuildingType.inn: 1,
    BuildingType.tavern: 1,
    BuildingType.blacksmith: 1.15,
    BuildingType.healer: 1.25,
    BuildingType.market: 1.10,
  };

  static const Map<DemandType, int> demandGoldReward = {
    DemandType.rest: 5,
    DemandType.food: 7,
    DemandType.gear: 14,
    DemandType.healing: 18,
    DemandType.supplies: 10,
  };

  static const Map<DemandType, int> demandReputationReward = {
    DemandType.rest: 1,
    DemandType.food: 1,
    DemandType.gear: 2,
    DemandType.healing: 3,
    DemandType.supplies: 1,
  };

  static const Map<DemandType, int> demandGenerationWeight = {
    DemandType.rest: 30,
    DemandType.food: 30,
    DemandType.gear: 15,
    DemandType.healing: 10,
    DemandType.supplies: 15,
  };

  static const Map<AdventurerTier, double> adventurerRewardMultiplier = {
    AdventurerTier.novice: 1,
    AdventurerTier.veteran: 1.5,
    AdventurerTier.elite: 2.25,
    AdventurerTier.legendary: 4,
  };

  static const Map<AdventurerTier, int> tierDemandFrequencyTicks = {
    AdventurerTier.novice: 3,
    AdventurerTier.veteran: 2,
    AdventurerTier.elite: 1,
    AdventurerTier.legendary: 1,
  };

  static const Map<AdventurerTier, int> demandsPerGeneration = {
    AdventurerTier.novice: 1,
    AdventurerTier.veteran: 1,
    AdventurerTier.elite: 1,
    AdventurerTier.legendary: 2,
  };

  static const Map<AdventurerTier, int> tierReputationUnlock = {
    AdventurerTier.novice: 0,
    AdventurerTier.veteran: 100,
    AdventurerTier.elite: 400,
    AdventurerTier.legendary: 1200,
  };

  static const Map<int, double> valueMultiplierByLevel = {
    1: 1,
    2: 1.15,
    3: 1.30,
    4: 1.45,
    5: 1.60,
    6: 1.80,
    7: 2.00,
    8: 2.25,
    9: 2.50,
    10: 2.80,
  };

  static int effectiveCapacity(BuildingType type, int capacityLevel) {
    return baseCapacity[type]! + max(0, capacityLevel - 1);
  }

  static double buildingValueMultiplier(BuildingType type, int valueLevel) {
    return buildingBaseValue[type]! * valueMultiplierByLevel[valueLevel]!;
  }

  static int upgradeGoldCostToReachLevel(int targetLevel) {
    final clamped = min(
      maximumUpgradeLevel,
      max(minimumLevel, targetLevel),
    );
    return upgradeGoldCostByLevel[clamped]!;
  }

  static int reputationRequiredForUpgradeLevel(int targetLevel) {
    if (targetLevel <= 3) {
      return 0;
    }
    if (targetLevel <= 6) {
      return tierReputationUnlock[AdventurerTier.veteran]!;
    }
    if (targetLevel <= 9) {
      return tierReputationUnlock[AdventurerTier.elite]!;
    }
    return tierReputationUnlock[AdventurerTier.legendary]!;
  }

  static Map<AdventurerTier, int> spawnWeightsFor(
      Set<AdventurerTier> unlockedTiers) {
    if (unlockedTiers.contains(AdventurerTier.legendary)) {
      return const {
        AdventurerTier.novice: 50,
        AdventurerTier.veteran: 30,
        AdventurerTier.elite: 15,
        AdventurerTier.legendary: 5,
      };
    }
    if (unlockedTiers.contains(AdventurerTier.elite)) {
      return const {
        AdventurerTier.novice: 60,
        AdventurerTier.veteran: 30,
        AdventurerTier.elite: 10,
        AdventurerTier.legendary: 0,
      };
    }
    if (unlockedTiers.contains(AdventurerTier.veteran)) {
      return const {
        AdventurerTier.novice: 75,
        AdventurerTier.veteran: 25,
        AdventurerTier.elite: 0,
        AdventurerTier.legendary: 0,
      };
    }
    return const {
      AdventurerTier.novice: 100,
      AdventurerTier.veteran: 0,
      AdventurerTier.elite: 0,
      AdventurerTier.legendary: 0,
    };
  }

  static List<DemandType> eligibleDemandTypesForBuildings(
    Map<BuildingType, bool> constructedBuildings,
  ) {
    final demandTypes = <DemandType>[];
    for (final entry in constructedBuildings.entries) {
      if (entry.value) {
        demandTypes.add(demandServedByBuilding(entry.key));
      }
    }
    demandTypes.sort((a, b) => a.index.compareTo(b.index));
    return List.unmodifiable(demandTypes);
  }
}
