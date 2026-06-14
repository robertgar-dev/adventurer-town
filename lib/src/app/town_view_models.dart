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
    required this.purposeDescription,
    required this.capacityLevel,
    required this.valueLevel,
    required this.capacityPerTick,
    required this.utilizationLabel,
    required this.utilizationPercent,
    required this.recentDemandReceived,
    required this.recentDemandServed,
    required this.recentLostDemand,
    required this.recentGoldEarned,
    required this.lifetimeDemandServed,
    required this.lifetimeDemandReceived,
    required this.lifetimeDemandLost,
    required this.lifetimeGoldEarned,
    required this.isUnderPressure,
    required this.isPrimaryBottleneck,
    required this.pressureSummary,
    required this.isConstructed,
    required this.capacityUpgrade,
    required this.valueUpgrade,
  });

  final String buildingId;
  final Building building;
  final BuildingType buildingType;
  final String name;
  final String demandName;

  /// WP-M6-01: a one-line, derived explanation of what the building does and
  /// what each upgrade axis affects.
  final String purposeDescription;
  final int capacityLevel;
  final int valueLevel;

  /// WP-M6-04: derived from [EconomyConstants.effectiveCapacity].
  final int capacityPerTick;
  final String utilizationLabel;
  final int utilizationPercent;
  final int recentDemandReceived;
  final int recentDemandServed;
  final int recentLostDemand;
  final int recentGoldEarned;
  final int lifetimeDemandServed;
  final int lifetimeDemandReceived;
  final int lifetimeDemandLost;
  final int lifetimeGoldEarned;

  /// WP-M6-03: derived pressure/bottleneck signals.
  final bool isUnderPressure;
  final bool isPrimaryBottleneck;
  final String pressureSummary;
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
    required this.effectLabel,
    required this.statusLabel,
    required this.canPurchase,
    required this.isMaxLevel,
  });

  final UpgradeAxis axis;
  final String title;
  final String buttonLabel;
  final String currentLevelLabel;
  final String costLabel;

  /// WP-M6-02: derived before -> after effect of buying the next level.
  final String effectLabel;
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
    isPrimaryBottleneck: _primaryBottleneckType(state) == building.buildingType,
  );
});

/// WP-M6-03: derives the town's primary bottleneck (the constructed building
/// losing the most demand) from existing building metrics. No new state.
BuildingType? _primaryBottleneckType(SimulationState state) {
  Building? worst;
  for (final building in state.buildings.values) {
    if (!building.isConstructed || building.lifetimeDemandLost <= 0) {
      continue;
    }
    if (worst == null ||
        building.lifetimeDemandLost > worst.lifetimeDemandLost) {
      worst = building;
    }
  }
  return worst?.buildingType;
}

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
  bool isPrimaryBottleneck = false,
}) {
  final isUnderPressure =
      building.utilizationState == UtilizationState.overloaded ||
          building.recentDemandLost > 0;

  return BuildingDetailViewModel(
    buildingId: building.id,
    building: building,
    buildingType: building.buildingType,
    name: buildingName(building.buildingType),
    demandName: demandName(building.servedDemandType),
    purposeDescription: _purposeDescription(building),
    capacityLevel: building.capacityLevel,
    valueLevel: building.valueLevel,
    capacityPerTick: building.capacityPerTick,
    utilizationLabel: utilizationLabel(building.utilizationState),
    utilizationPercent: (building.utilizationRatio * 100).round(),
    recentDemandReceived: building.recentDemandReceived,
    recentDemandServed: building.recentDemandServed,
    recentLostDemand: building.recentDemandLost,
    recentGoldEarned: building.recentGoldEarned,
    lifetimeDemandServed: building.lifetimeDemandServed,
    lifetimeDemandReceived: building.lifetimeDemandReceived,
    lifetimeDemandLost: building.lifetimeDemandLost,
    lifetimeGoldEarned: building.lifetimeGoldEarned,
    isUnderPressure: isUnderPressure,
    isPrimaryBottleneck: isPrimaryBottleneck,
    pressureSummary: _pressureSummary(
      building: building,
      isPrimaryBottleneck: isPrimaryBottleneck,
    ),
    isConstructed: building.isConstructed,
    capacityUpgrade: _upgradeActionViewModel(
      UpgradeRules.quote(
        building: building,
        resources: resources,
        axis: UpgradeAxis.capacity,
      ),
      building,
    ),
    valueUpgrade: _upgradeActionViewModel(
      UpgradeRules.quote(
        building: building,
        resources: resources,
        axis: UpgradeAxis.value,
      ),
      building,
    ),
  );
}

String _purposeDescription(Building building) {
  final name = buildingName(building.buildingType);
  final demand = demandName(building.servedDemandType);
  return '$name serves $demand demand. Capacity sets how many adventurers it '
      'can serve each tick; Value sets the Gold earned per service.';
}

String _pressureSummary({
  required Building building,
  required bool isPrimaryBottleneck,
}) {
  if (isPrimaryBottleneck) {
    return 'Top bottleneck in town: this building is losing the most demand. '
        'A Capacity upgrade recovers the most throughput.';
  }
  if (building.utilizationState == UtilizationState.overloaded ||
      building.recentDemandLost > 0) {
    return 'Under pressure: demand is being lost at the current capacity. '
        'Consider a Capacity upgrade.';
  }
  if (building.utilizationState == UtilizationState.busy) {
    return 'Busy: nearing capacity. Watch for lost demand.';
  }
  return 'Healthy: serving demand within the current capacity.';
}

EventFeedItemViewModel? _eventFeedItemViewModelFor(EventFeedEntry entry) {
  final description = eventFeedNarrative(entry);
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

/// M8 Event Feed narrative resolver.
///
/// A small, bounded "economic-with-flavor" template library. Every line is
/// derived from real event fields (building, demand, axis, level) — no authored
/// story, no recurring names, no unsupported mechanics. Returns `null` for
/// categories the feed does not surface, so the resolver is fallback-safe for
/// incomplete or non-display events.
String? eventFeedNarrative(EventFeedEntry entry) {
  final building = entry.buildingType;
  final demand = entry.demandType;

  switch (entry.eventType) {
    case EventType.demandServed:
      // Capability/pride: the town met an adventurer's need.
      if (building == null) {
        return null;
      }
      return _servedNarrative[building] ??
          '${buildingName(building)} served '
              '${demand == null ? 'an' : demandName(demand)} adventurer.';
    case EventType.demandMissed:
      // Missed opportunity (never punishment, queue, refund, or blame): the
      // service was not ready for the pressure placed on it.
      if (building == null) {
        return null;
      }
      return _missedNarrative[building] ??
          'The ${buildingName(building)} could not reach everyone in time.';
    case EventType.buildingUpgraded:
      // Stewardship: Capacity reads as more service coverage; Value reads as
      // better Gold return from demand already served.
      final axis = entry.upgradeAxis;
      if (building == null || axis == null) {
        return null;
      }
      return _upgradeNarrative(building, demand, axis, entry.variables['level']);
    case EventType.adventurerArrived:
    case EventType.demandGenerated:
    case EventType.buildingBottleneck:
    case EventType.simulationTick:
      return null;
  }
}

const Map<BuildingType, String> _servedNarrative = {
  BuildingType.inn: 'The Inn welcomed weary adventurers in to rest.',
  BuildingType.tavern: 'The Tavern served hot meals to hungry adventurers.',
  BuildingType.blacksmith: 'The Blacksmith mended gear for the road ahead.',
  BuildingType.healer: 'The Healer tended wounds and eased the journey.',
  BuildingType.market: 'The Market stocked adventurers for the road.',
};

const Map<BuildingType, String> _missedNarrative = {
  BuildingType.inn: "The Inn's beds filled up, and a tired traveler moved on.",
  BuildingType.tavern:
      'Every table was taken, and hungry adventurers passed the Tavern by.',
  BuildingType.blacksmith:
      "The Blacksmith couldn't reach every blade before the rush passed.",
  BuildingType.healer:
      "The Healer couldn't see everyone who needed care this time.",
  BuildingType.market: 'The Market ran short, and some left without supplies.',
};

String _upgradeNarrative(
  BuildingType building,
  DemandType? demand,
  UpgradeAxis axis,
  String? level,
) {
  final name = buildingName(building);
  final demandLabel = demand == null ? 'demand' : '${demandName(demand)} demand';
  final levelLabel =
      level == null ? '' : ' (${_upgradeAxisLabel(axis)} Lv $level)';
  switch (axis) {
    case UpgradeAxis.capacity:
      return 'The $name can serve more $demandLabel now — '
          'more adventurers helped.$levelLabel';
    case UpgradeAxis.value:
      return 'The $name now earns more Gold from every '
          '$demandLabel served.$levelLabel';
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

UpgradeActionViewModel _upgradeActionViewModel(
  UpgradeQuote quote,
  Building building,
) {
  final title = _upgradeTitle(quote.axis);
  return UpgradeActionViewModel(
    axis: quote.axis,
    title: title,
    buttonLabel: 'Upgrade ${_upgradeAxisLabel(quote.axis)}',
    currentLevelLabel: 'Current Level ${quote.currentLevel}',
    costLabel: quote.isMaxLevel ? 'Max Level' : 'Next Cost ${quote.cost} Gold',
    effectLabel: _upgradeEffectLabel(quote, building),
    statusLabel: _upgradeStatusLabel(quote),
    canPurchase: quote.canPurchase,
    isMaxLevel: quote.isMaxLevel,
  );
}

/// WP-M6-02: derives the before -> after effect of the next level purely from
/// approved economy constants. No simulation is run and no state is stored.
String _upgradeEffectLabel(UpgradeQuote quote, Building building) {
  final nextLevel = quote.nextLevel;
  if (quote.isMaxLevel || nextLevel == null) {
    return 'At maximum level';
  }

  switch (quote.axis) {
    case UpgradeAxis.capacity:
      final current = EconomyConstants.effectiveCapacity(
        building.buildingType,
        quote.currentLevel,
      );
      final next = EconomyConstants.effectiveCapacity(
        building.buildingType,
        nextLevel,
      );
      return 'Serves $current -> $next per tick';
    case UpgradeAxis.value:
      final reward =
          EconomyConstants.demandGoldReward[building.servedDemandType] ?? 0;
      final current = (reward *
              EconomyConstants.buildingValueMultiplier(
                building.buildingType,
                quote.currentLevel,
              ))
          .floor();
      final next = (reward *
              EconomyConstants.buildingValueMultiplier(
                building.buildingType,
                nextLevel,
              ))
          .floor();
      return 'Gold per service $current -> $next';
  }
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
