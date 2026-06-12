import 'dart:math';

import 'economy_constants.dart';
import 'enums.dart';

class Building {
  const Building({
    required this.id,
    required this.buildingType,
    required this.servedDemandType,
    required this.isConstructed,
    required this.capacityLevel,
    required this.valueLevel,
    required this.constructedTick,
    required this.lastUpgradeTick,
    required this.currentOccupancy,
    required this.recentDemandReceived,
    required this.recentDemandServed,
    required this.recentDemandLost,
    required this.recentGoldEarned,
    required this.lifetimeDemandReceived,
    required this.lifetimeDemandServed,
    required this.lifetimeDemandLost,
    required this.lifetimeGoldEarned,
    required this.recentActivityEventIds,
  });

  factory Building.forType(
    BuildingType type, {
    bool isConstructed = false,
    int constructedTick = 0,
  }) {
    return Building(
      id: 'building_${type.code}',
      buildingType: type,
      servedDemandType: demandServedByBuilding(type),
      isConstructed: isConstructed,
      capacityLevel: 1,
      valueLevel: 1,
      constructedTick: constructedTick,
      lastUpgradeTick: null,
      currentOccupancy: 0,
      recentDemandReceived: 0,
      recentDemandServed: 0,
      recentDemandLost: 0,
      recentGoldEarned: 0,
      lifetimeDemandReceived: 0,
      lifetimeDemandServed: 0,
      lifetimeDemandLost: 0,
      lifetimeGoldEarned: 0,
      recentActivityEventIds: const [],
    );
  }

  static Building? fromJson(Map<String, Object?> json) {
    final type = enumFromCodeOrNull(BuildingType.values, json['buildingType']);
    if (type == null) {
      return null;
    }

    return Building(
      id: _stringOr(json['id'], 'building_${type.code}'),
      buildingType: type,
      servedDemandType: demandServedByBuilding(type),
      isConstructed: json['isConstructed'] == true,
      capacityLevel: _level(json['capacityLevel']),
      valueLevel: _level(json['valueLevel']),
      constructedTick: _nonNegativeInt(json['constructedTick']),
      lastUpgradeTick: _nullableNonNegativeInt(json['lastUpgradeTick']),
      currentOccupancy: _nonNegativeInt(json['currentOccupancy']),
      recentDemandReceived: _nonNegativeInt(json['recentDemandReceived']),
      recentDemandServed: _nonNegativeInt(json['recentDemandServed']),
      recentDemandLost: _nonNegativeInt(json['recentDemandLost']),
      recentGoldEarned: _nonNegativeInt(json['recentGoldEarned']),
      lifetimeDemandReceived: _nonNegativeInt(json['lifetimeDemandReceived']),
      lifetimeDemandServed: _nonNegativeInt(json['lifetimeDemandServed']),
      lifetimeDemandLost: _nonNegativeInt(json['lifetimeDemandLost']),
      lifetimeGoldEarned: _nonNegativeInt(json['lifetimeGoldEarned']),
      recentActivityEventIds: _stringList(json['recentActivityEventIds']),
    );
  }

  final String id;
  final BuildingType buildingType;
  final DemandType servedDemandType;
  final bool isConstructed;
  final int capacityLevel;
  final int valueLevel;
  final int constructedTick;
  final int? lastUpgradeTick;
  final int currentOccupancy;
  final int recentDemandReceived;
  final int recentDemandServed;
  final int recentDemandLost;
  final int recentGoldEarned;
  final int lifetimeDemandReceived;
  final int lifetimeDemandServed;
  final int lifetimeDemandLost;
  final int lifetimeGoldEarned;
  final List<String> recentActivityEventIds;

  int get capacityPerTick {
    return EconomyConstants.effectiveCapacity(buildingType, capacityLevel);
  }

  double get utilizationRatio {
    if (capacityPerTick <= 0) {
      return 0;
    }
    return recentDemandReceived / capacityPerTick;
  }

  UtilizationState get utilizationState => utilizationStateForRatio(
        utilizationRatio,
        hasRecentLostDemand: recentDemandLost > 0,
      );

  Building recordDemandReceived() {
    return copyWith(
      recentDemandReceived: recentDemandReceived + 1,
      lifetimeDemandReceived: lifetimeDemandReceived + 1,
    );
  }

  Building recordDemandServed({
    required int goldEarned,
    required int occupancy,
    required String eventId,
  }) {
    return copyWith(
      currentOccupancy: occupancy,
      recentDemandServed: recentDemandServed + 1,
      recentGoldEarned: recentGoldEarned + goldEarned,
      lifetimeDemandServed: lifetimeDemandServed + 1,
      lifetimeGoldEarned: lifetimeGoldEarned + goldEarned,
      recentActivityEventIds: _appendEvent(eventId),
    );
  }

  Building recordDemandLost({required String eventId}) {
    return copyWith(
      recentDemandLost: recentDemandLost + 1,
      lifetimeDemandLost: lifetimeDemandLost + 1,
      recentActivityEventIds: _appendEvent(eventId),
    );
  }

  Building resetTickOccupancy() {
    return copyWith(currentOccupancy: 0);
  }

  Building copyWith({
    String? id,
    BuildingType? buildingType,
    DemandType? servedDemandType,
    bool? isConstructed,
    int? capacityLevel,
    int? valueLevel,
    int? constructedTick,
    int? lastUpgradeTick,
    int? currentOccupancy,
    int? recentDemandReceived,
    int? recentDemandServed,
    int? recentDemandLost,
    int? recentGoldEarned,
    int? lifetimeDemandReceived,
    int? lifetimeDemandServed,
    int? lifetimeDemandLost,
    int? lifetimeGoldEarned,
    List<String>? recentActivityEventIds,
  }) {
    final nextType = buildingType ?? this.buildingType;
    return Building(
      id: id ?? this.id,
      buildingType: nextType,
      servedDemandType: servedDemandType ?? demandServedByBuilding(nextType),
      isConstructed: isConstructed ?? this.isConstructed,
      capacityLevel: _clampLevel(capacityLevel ?? this.capacityLevel),
      valueLevel: _clampLevel(valueLevel ?? this.valueLevel),
      constructedTick: _clamp(constructedTick ?? this.constructedTick),
      lastUpgradeTick: lastUpgradeTick ?? this.lastUpgradeTick,
      currentOccupancy: _clamp(currentOccupancy ?? this.currentOccupancy),
      recentDemandReceived: _clamp(
        recentDemandReceived ?? this.recentDemandReceived,
      ),
      recentDemandServed: _clamp(recentDemandServed ?? this.recentDemandServed),
      recentDemandLost: _clamp(recentDemandLost ?? this.recentDemandLost),
      recentGoldEarned: _clamp(recentGoldEarned ?? this.recentGoldEarned),
      lifetimeDemandReceived: _clamp(
        lifetimeDemandReceived ?? this.lifetimeDemandReceived,
      ),
      lifetimeDemandServed: _clamp(
        lifetimeDemandServed ?? this.lifetimeDemandServed,
      ),
      lifetimeDemandLost: _clamp(lifetimeDemandLost ?? this.lifetimeDemandLost),
      lifetimeGoldEarned: _clamp(lifetimeGoldEarned ?? this.lifetimeGoldEarned),
      recentActivityEventIds: List.unmodifiable(
          recentActivityEventIds ?? this.recentActivityEventIds),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'buildingType': buildingType.code,
      'servedDemandType': servedDemandType.code,
      'isConstructed': isConstructed,
      'capacityLevel': capacityLevel,
      'valueLevel': valueLevel,
      'constructedTick': constructedTick,
      'lastUpgradeTick': lastUpgradeTick,
      'currentOccupancy': currentOccupancy,
      'recentDemandReceived': recentDemandReceived,
      'recentDemandServed': recentDemandServed,
      'recentDemandLost': recentDemandLost,
      'recentGoldEarned': recentGoldEarned,
      'lifetimeDemandReceived': lifetimeDemandReceived,
      'lifetimeDemandServed': lifetimeDemandServed,
      'lifetimeDemandLost': lifetimeDemandLost,
      'lifetimeGoldEarned': lifetimeGoldEarned,
      'recentActivityEventIds': recentActivityEventIds,
    };
  }

  List<String> _appendEvent(String eventId) {
    return List.unmodifiable([
      eventId,
      ...recentActivityEventIds,
    ].take(10));
  }

  static int _level(Object? value) {
    if (value is int) {
      return _clampLevel(value);
    }
    if (value is num) {
      return _clampLevel(value.floor());
    }
    return 1;
  }

  static int _clampLevel(int value) {
    return min(10, max(1, value));
  }

  static int _nonNegativeInt(Object? value) {
    if (value is int) {
      return _clamp(value);
    }
    if (value is num) {
      return _clamp(value.floor());
    }
    return 0;
  }

  static int? _nullableNonNegativeInt(Object? value) {
    if (value == null) {
      return null;
    }
    return _nonNegativeInt(value);
  }

  static int _clamp(int value) {
    return value < 0 ? 0 : value;
  }

  static String _stringOr(Object? value, String fallback) {
    return value is String && value.isNotEmpty ? value : fallback;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return List.unmodifiable(value.whereType<String>());
  }
}
