import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/domain.dart';
import 'app_providers.dart';

class TownResourcesViewModel {
  const TownResourcesViewModel({
    required this.gold,
    required this.reputation,
  });

  final int gold;
  final int reputation;
}

class BuildingCardViewModel {
  const BuildingCardViewModel({
    required this.buildingId,
    required this.building,
    required this.buildingType,
    required this.name,
    required this.demandName,
    required this.capacityLevel,
    required this.valueLevel,
    required this.utilizationState,
    required this.utilizationLabel,
    required this.recentLostDemand,
    required this.isConstructed,
  });

  final String buildingId;
  final Building building;
  final BuildingType buildingType;
  final String name;
  final String demandName;
  final int capacityLevel;
  final int valueLevel;
  final UtilizationState utilizationState;
  final String utilizationLabel;
  final int recentLostDemand;
  final bool isConstructed;

  bool get hasRecentLostDemand => recentLostDemand > 0;
}

class BuildingDetailViewModel {
  const BuildingDetailViewModel({
    required this.buildingId,
    required this.building,
    required this.buildingType,
    required this.name,
    required this.demandName,
    required this.capacityLevel,
    required this.valueLevel,
    required this.utilizationLabel,
    required this.utilizationPercent,
    required this.recentLostDemand,
    required this.isConstructed,
    required this.capacityUpgrade,
    required this.valueUpgrade,
  });

  final String buildingId;
  final Building building;
  final BuildingType buildingType;
  final String name;
  final String demandName;
  final int capacityLevel;
  final int valueLevel;
  final String utilizationLabel;
  final int utilizationPercent;
  final int recentLostDemand;
  final bool isConstructed;
  final UpgradeActionViewModel capacityUpgrade;
  final UpgradeActionViewModel valueUpgrade;
}

class UpgradeActionViewModel {
  const UpgradeActionViewModel({
    required this.axis,
    required this.title,
    required this.buttonLabel,
    required this.currentLevelLabel,
    required this.costLabel,
    required this.statusLabel,
    required this.canPurchase,
    required this.isMaxLevel,
  });

  final UpgradeAxis axis;
  final String title;
  final String buttonLabel;
  final String currentLevelLabel;
  final String costLabel;
  final String statusLabel;
  final bool canPurchase;
  final bool isMaxLevel;
}

class EventFeedItemViewModel {
  const EventFeedItemViewModel({
    required this.id,
    required this.eventType,
    required this.createdTick,
    required this.description,
    required this.buildingType,
    required this.demandType,
    required this.upgradeAxis,
    required this.goldDelta,
    required this.reputationDelta,
    required this.isOffline,
    required this.priority,
  });

  final String id;
  final EventType eventType;
  final int createdTick;
  final String description;
  final BuildingType? buildingType;
  final DemandType? demandType;
  final UpgradeAxis? upgradeAxis;
  final int goldDelta;
  final int reputationDelta;
  final bool isOffline;
  final int priority;
}

final townResourcesProvider = Provider<TownResourcesViewModel?>((ref) {
  final state = ref.watch(
    simulationControllerProvider.select((value) => value.simulationState),
  );
  if (state == null) {
    return null;
  }

  return TownResourcesViewModel(
    gold: state.resources.gold,
    reputation: state.resources.reputation,
  );
});

final townBuildingCardsProvider = Provider<List<BuildingCardViewModel>>((ref) {
  final state = ref.watch(
    simulationControllerProvider.select((value) => value.simulationState),
  );
  if (state == null) {
    return const [];
  }

  return [
    for (final type in BuildingType.values)
      _buildingCardViewModel(
        state.buildings[type] ?? Building.forType(type),
      ),
  ];
});

final townEventFeedProvider = Provider<List<EventFeedItemViewModel>>((ref) {
  final state = ref.watch(
    simulationControllerProvider.select((value) => value.simulationState),
  );
  if (state == null) {
    return const [];
  }

  return [
    for (final entry in state.eventFeed)
      if (_eventFeedItemViewModelFor(entry) case final item?) item,
  ];
});

final buildingDetailProvider =
    Provider.family<BuildingDetailViewModel?, BuildingType>((ref, type) {
  final state = ref.watch(
    simulationControllerProvider.select((value) => value.simulationState),
  );
  if (state == null) {
    return null;
  }

  final building = state.buildings[type] ?? Building.forType(type);
  return buildingDetailViewModelFor(
    building: building,
    resources: state.resources,
  );
});

final buildingRecentActivityProvider =
    Provider.family<List<EventFeedItemViewModel>, BuildingType>((ref, type) {
  final feed = ref.watch(townEventFeedProvider);
  return [
    for (final entry in feed)
      if (entry.buildingType == type) entry,
  ];
});

BuildingDetailViewModel buildingDetailViewModelFor({
  required Building building,
  required Resources resources,
}) {
  return BuildingDetailViewModel(
    buildingId: building.id,
    building: building,
    buildingType: building.buildingType,
    name: buildingName(building.buildingType),
    demandName: demandName(building.servedDemandType),
    capacityLevel: building.capacityLevel,
    valueLevel: building.valueLevel,
    utilizationLabel: utilizationLabel(building.utilizationState),
    utilizationPercent: (building.utilizationRatio * 100).round(),
    recentLostDemand: building.recentDemandLost,
    isConstructed: building.isConstructed,
    capacityUpgrade: _upgradeActionViewModel(
      UpgradeRules.quote(
        building: building,
        resources: resources,
        axis: UpgradeAxis.capacity,
      ),
    ),
    valueUpgrade: _upgradeActionViewModel(
      UpgradeRules.quote(
        building: building,
        resources: resources,
        axis: UpgradeAxis.value,
      ),
    ),
  );
}

EventFeedItemViewModel? _eventFeedItemViewModelFor(EventFeedEntry entry) {
  final description = _eventDescription(entry);
  if (description == null) {
    return null;
  }

  return EventFeedItemViewModel(
    id: entry.id,
    eventType: entry.eventType,
    createdTick: entry.createdTick,
    description: description,
    buildingType: entry.buildingType,
    demandType: entry.demandType,
    upgradeAxis: entry.upgradeAxis,
    goldDelta: entry.goldDelta,
    reputationDelta: entry.reputationDelta,
    isOffline: entry.wasOffline,
    priority: entry.priority,
  );
}

String? _eventDescription(EventFeedEntry entry) {
  final building = entry.buildingType;
  final demand = entry.demandType;

  switch (entry.eventType) {
    case EventType.demandServed:
      if (building == null || demand == null) {
        return null;
      }
      return '${buildingName(building)} served ${demandName(demand)} demand.';
    case EventType.demandMissed:
      if (building == null || demand == null) {
        return null;
      }
      return '${buildingName(building)} missed ${demandName(demand)} demand.';
    case EventType.buildingUpgraded:
      if (building == null || entry.upgradeAxis == null) {
        return null;
      }
      final level = entry.variables['level'];
      final levelLabel = level == null ? '' : ' to Level $level';
      return '${buildingName(building)} ${_upgradeAxisLabel(entry.upgradeAxis!)} upgraded$levelLabel.';
    case EventType.adventurerArrived:
    case EventType.demandGenerated:
    case EventType.buildingBottleneck:
    case EventType.simulationTick:
      return null;
  }
}

BuildingCardViewModel _buildingCardViewModel(Building building) {
  return BuildingCardViewModel(
    buildingId: building.id,
    building: building,
    buildingType: building.buildingType,
    name: buildingName(building.buildingType),
    demandName: demandName(building.servedDemandType),
    capacityLevel: building.capacityLevel,
    valueLevel: building.valueLevel,
    utilizationState: building.utilizationState,
    utilizationLabel: utilizationLabel(building.utilizationState),
    recentLostDemand: building.recentDemandLost,
    isConstructed: building.isConstructed,
  );
}

String utilizationLabel(UtilizationState state) {
  switch (state) {
    case UtilizationState.underused:
      return 'Underused';
    case UtilizationState.healthy:
      return 'Healthy';
    case UtilizationState.busy:
      return 'Busy';
    case UtilizationState.overloaded:
      return 'Overloaded';
  }
}

UpgradeActionViewModel _upgradeActionViewModel(UpgradeQuote quote) {
  final title = _upgradeTitle(quote.axis);
  return UpgradeActionViewModel(
    axis: quote.axis,
    title: title,
    buttonLabel: 'Upgrade ${_upgradeAxisLabel(quote.axis)}',
    currentLevelLabel: 'Current Level ${quote.currentLevel}',
    costLabel: quote.isMaxLevel ? 'Max Level' : 'Next Cost ${quote.cost} Gold',
    statusLabel: _upgradeStatusLabel(quote),
    canPurchase: quote.canPurchase,
    isMaxLevel: quote.isMaxLevel,
  );
}

String _upgradeStatusLabel(UpgradeQuote quote) {
  if (quote.isMaxLevel) {
    return 'Max Level';
  }
  if (!quote.isConstructed) {
    return 'Not constructed';
  }
  if (!quote.hasEnoughReputation) {
    return 'Requires ${quote.requiredReputation} Reputation';
  }
  if (!quote.hasEnoughGold && quote.cost != null) {
    return 'Need ${quote.cost} Gold';
  }
  return 'Available';
}

String _upgradeTitle(UpgradeAxis axis) {
  return '${_upgradeAxisLabel(axis)} Upgrade';
}

String _upgradeAxisLabel(UpgradeAxis axis) {
  switch (axis) {
    case UpgradeAxis.capacity:
      return 'Capacity';
    case UpgradeAxis.value:
      return 'Value';
  }
}

String buildingName(BuildingType type) {
  switch (type) {
    case BuildingType.inn:
      return 'Inn';
    case BuildingType.tavern:
      return 'Tavern';
    case BuildingType.blacksmith:
      return 'Blacksmith';
    case BuildingType.healer:
      return 'Healer';
    case BuildingType.market:
      return 'Market';
  }
}

String demandName(DemandType type) {
  switch (type) {
    case DemandType.rest:
      return 'Rest';
    case DemandType.food:
      return 'Food';
    case DemandType.gear:
      return 'Gear';
    case DemandType.healing:
      return 'Healing';
    case DemandType.supplies:
      return 'Supplies';
  }
}
