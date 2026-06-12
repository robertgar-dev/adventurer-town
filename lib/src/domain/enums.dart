enum ResourceType {
  gold,
  reputation,
}

enum BuildingType {
  inn,
  tavern,
  blacksmith,
  healer,
  market,
}

enum DemandType {
  rest,
  food,
  gear,
  healing,
  supplies,
}

enum AdventurerTier {
  novice,
  veteran,
  elite,
  legendary,
}

enum AdventurerState {
  arriving,
  seekingService,
  receivingService,
  departing,
  returned,
  removed,
}

enum EventType {
  adventurerArrived,
  demandGenerated,
  demandServed,
  demandMissed,
  buildingUpgraded,
  buildingBottleneck,
  simulationTick,
}

enum UtilizationState {
  underused,
  healthy,
  busy,
  overloaded,
}

enum UpgradeAxis {
  capacity,
  value,
}

enum TimeOfDayBand {
  morning,
  day,
  evening,
  night,
}

enum DemandStatus {
  pending,
  served,
  missed,
}

extension EnumPersistenceName on Enum {
  String get code => name;
}

T? enumFromCodeOrNull<T extends Enum>(List<T> values, Object? code) {
  if (code is! String) {
    return null;
  }

  for (final value in values) {
    if (value.name == code) {
      return value;
    }
  }

  return null;
}

T enumFromCode<T extends Enum>(List<T> values, Object? code, T fallback) {
  return enumFromCodeOrNull(values, code) ?? fallback;
}

DemandType demandServedByBuilding(BuildingType type) {
  switch (type) {
    case BuildingType.inn:
      return DemandType.rest;
    case BuildingType.tavern:
      return DemandType.food;
    case BuildingType.blacksmith:
      return DemandType.gear;
    case BuildingType.healer:
      return DemandType.healing;
    case BuildingType.market:
      return DemandType.supplies;
  }
}

BuildingType buildingForDemand(DemandType type) {
  switch (type) {
    case DemandType.rest:
      return BuildingType.inn;
    case DemandType.food:
      return BuildingType.tavern;
    case DemandType.gear:
      return BuildingType.blacksmith;
    case DemandType.healing:
      return BuildingType.healer;
    case DemandType.supplies:
      return BuildingType.market;
  }
}

UtilizationState utilizationStateForRatio(
  double ratio, {
  bool hasRecentLostDemand = false,
}) {
  if (hasRecentLostDemand || ratio >= 1) {
    return UtilizationState.overloaded;
  }
  if (ratio >= 0.85) {
    return UtilizationState.busy;
  }
  if (ratio >= 0.6) {
    return UtilizationState.healthy;
  }
  return UtilizationState.underused;
}

TimeOfDayBand timeOfDayForTick(int tick) {
  final normalizedTick = tick < 0 ? 0 : tick;
  final bandIndex = (normalizedTick ~/ 180) % TimeOfDayBand.values.length;
  return TimeOfDayBand.values[bandIndex];
}
