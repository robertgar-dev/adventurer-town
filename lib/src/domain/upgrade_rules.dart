import 'building.dart';
import 'economy_constants.dart';
import 'enums.dart';
import 'resources.dart';

class UpgradeQuote {
  const UpgradeQuote({
    required this.axis,
    required this.currentLevel,
    required this.nextLevel,
    required this.cost,
    required this.requiredReputation,
    required this.isConstructed,
    required this.hasEnoughGold,
    required this.hasEnoughReputation,
  });

  final UpgradeAxis axis;
  final int currentLevel;
  final int? nextLevel;
  final int? cost;
  final int requiredReputation;
  final bool isConstructed;
  final bool hasEnoughGold;
  final bool hasEnoughReputation;

  bool get isMaxLevel => nextLevel == null;

  bool get canPurchase {
    return isConstructed && !isMaxLevel && hasEnoughGold && hasEnoughReputation;
  }
}

class UpgradeRules {
  const UpgradeRules._();

  static UpgradeQuote quote({
    required Building building,
    required Resources resources,
    required UpgradeAxis axis,
  }) {
    final currentLevel = _levelFor(building, axis);
    final nextLevel = currentLevel >= EconomyConstants.maximumUpgradeLevel
        ? null
        : currentLevel + 1;
    final cost = nextLevel == null
        ? null
        : EconomyConstants.upgradeGoldCostToReachLevel(nextLevel);
    final requiredReputation = nextLevel == null
        ? 0
        : EconomyConstants.reputationRequiredForUpgradeLevel(nextLevel);

    return UpgradeQuote(
      axis: axis,
      currentLevel: currentLevel,
      nextLevel: nextLevel,
      cost: cost,
      requiredReputation: requiredReputation,
      isConstructed: building.isConstructed,
      hasEnoughGold: cost != null && resources.gold >= cost,
      hasEnoughReputation: resources.reputation >= requiredReputation,
    );
  }

  static int _levelFor(Building building, UpgradeAxis axis) {
    switch (axis) {
      case UpgradeAxis.capacity:
        return building.capacityLevel;
      case UpgradeAxis.value:
        return building.valueLevel;
    }
  }
}
