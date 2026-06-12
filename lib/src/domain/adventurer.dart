import 'enums.dart';

class Adventurer {
  const Adventurer({
    required this.id,
    required this.displayName,
    required this.tier,
    required this.state,
    required this.currentDemandId,
    required this.preferredDemandTypes,
    required this.arrivalTick,
    required this.departureTick,
    required this.expectedReturnTick,
    required this.lastServiceBuildingType,
    required this.lastOutcomeEventId,
    required this.wealthBand,
  });

  factory Adventurer.create({
    required String id,
    required String displayName,
    required AdventurerTier tier,
    required List<DemandType> preferredDemandTypes,
    required int arrivalTick,
    int wealthBand = 0,
  }) {
    return Adventurer(
      id: id,
      displayName: displayName,
      tier: tier,
      state: AdventurerState.seekingService,
      currentDemandId: null,
      preferredDemandTypes: List.unmodifiable(preferredDemandTypes),
      arrivalTick: arrivalTick,
      departureTick: null,
      expectedReturnTick: null,
      lastServiceBuildingType: null,
      lastOutcomeEventId: null,
      wealthBand: wealthBand < 0 ? 0 : wealthBand,
    );
  }

  static Adventurer? fromJson(Map<String, Object?> json) {
    final tier = enumFromCodeOrNull(AdventurerTier.values, json['tier']);
    final state = enumFromCodeOrNull(AdventurerState.values, json['state']);
    if (tier == null || state == null) {
      return null;
    }

    return Adventurer(
      id: _stringOr(json['id'], 'adventurer_unknown'),
      displayName: _stringOr(json['displayName'], 'Adventurer'),
      tier: tier,
      state: state,
      currentDemandId: json['currentDemandId'] as String?,
      preferredDemandTypes: _demandTypeList(json['preferredDemandTypes']),
      arrivalTick: _nonNegativeInt(json['arrivalTick']),
      departureTick: _nullableNonNegativeInt(json['departureTick']),
      expectedReturnTick: _nullableNonNegativeInt(json['expectedReturnTick']),
      lastServiceBuildingType: enumFromCodeOrNull(
        BuildingType.values,
        json['lastServiceBuildingType'],
      ),
      lastOutcomeEventId: json['lastOutcomeEventId'] as String?,
      wealthBand: _nonNegativeInt(json['wealthBand']),
    );
  }

  final String id;
  final String displayName;
  final AdventurerTier tier;
  final AdventurerState state;
  final String? currentDemandId;
  final List<DemandType> preferredDemandTypes;
  final int arrivalTick;
  final int? departureTick;
  final int? expectedReturnTick;
  final BuildingType? lastServiceBuildingType;
  final String? lastOutcomeEventId;
  final int wealthBand;

  Adventurer copyWith({
    String? id,
    String? displayName,
    AdventurerTier? tier,
    AdventurerState? state,
    String? currentDemandId,
    List<DemandType>? preferredDemandTypes,
    int? arrivalTick,
    int? departureTick,
    int? expectedReturnTick,
    BuildingType? lastServiceBuildingType,
    String? lastOutcomeEventId,
    int? wealthBand,
  }) {
    return Adventurer(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      tier: tier ?? this.tier,
      state: state ?? this.state,
      currentDemandId: currentDemandId,
      preferredDemandTypes:
          List.unmodifiable(preferredDemandTypes ?? this.preferredDemandTypes),
      arrivalTick: _clamp(arrivalTick ?? this.arrivalTick),
      departureTick: departureTick ?? this.departureTick,
      expectedReturnTick: expectedReturnTick ?? this.expectedReturnTick,
      lastServiceBuildingType:
          lastServiceBuildingType ?? this.lastServiceBuildingType,
      lastOutcomeEventId: lastOutcomeEventId ?? this.lastOutcomeEventId,
      wealthBand: _clamp(wealthBand ?? this.wealthBand),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'tier': tier.code,
      'state': state.code,
      'currentDemandId': currentDemandId,
      'preferredDemandTypes':
          preferredDemandTypes.map((type) => type.code).toList(),
      'arrivalTick': arrivalTick,
      'departureTick': departureTick,
      'expectedReturnTick': expectedReturnTick,
      'lastServiceBuildingType': lastServiceBuildingType?.code,
      'lastOutcomeEventId': lastOutcomeEventId,
      'wealthBand': wealthBand,
    };
  }

  static List<DemandType> _demandTypeList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return List.unmodifiable(
      value
          .map((entry) => enumFromCodeOrNull(DemandType.values, entry))
          .whereType<DemandType>(),
    );
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
}
