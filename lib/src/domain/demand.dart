import 'enums.dart';

class Demand {
  const Demand({
    required this.id,
    required this.adventurerId,
    required this.demandType,
    required this.targetBuildingType,
    required this.createdTick,
    required this.resolutionTick,
    required this.status,
    required this.serviceCompletionTick,
    required this.goldValue,
    required this.reputationValue,
    required this.wasOfflineResolved,
  });

  factory Demand.create({
    required String id,
    required String adventurerId,
    required DemandType demandType,
    required int createdTick,
    required int goldValue,
    required int reputationValue,
    bool wasOfflineResolved = false,
  }) {
    return Demand(
      id: id,
      adventurerId: adventurerId,
      demandType: demandType,
      targetBuildingType: buildingForDemand(demandType),
      createdTick: createdTick < 0 ? 0 : createdTick,
      resolutionTick: null,
      status: DemandStatus.pending,
      serviceCompletionTick: null,
      goldValue: goldValue < 0 ? 0 : goldValue,
      reputationValue: reputationValue < 0 ? 0 : reputationValue,
      wasOfflineResolved: wasOfflineResolved,
    );
  }

  static Demand? fromJson(Map<String, Object?> json) {
    final demandType =
        enumFromCodeOrNull(DemandType.values, json['demandType']);
    final targetBuildingType = enumFromCodeOrNull(
      BuildingType.values,
      json['targetBuildingType'],
    );
    final status = enumFromCodeOrNull(DemandStatus.values, json['status']);

    if (demandType == null ||
        targetBuildingType == null ||
        status == null ||
        targetBuildingType != buildingForDemand(demandType)) {
      return null;
    }

    return Demand(
      id: _stringOr(json['id'], 'demand_unknown'),
      adventurerId: _stringOr(json['adventurerId'], 'adventurer_unknown'),
      demandType: demandType,
      targetBuildingType: targetBuildingType,
      createdTick: _nonNegativeInt(json['createdTick']),
      resolutionTick: _nullableNonNegativeInt(json['resolutionTick']),
      status: status,
      serviceCompletionTick:
          _nullableNonNegativeInt(json['serviceCompletionTick']),
      goldValue: _nonNegativeInt(json['goldValue']),
      reputationValue: _nonNegativeInt(json['reputationValue']),
      wasOfflineResolved: json['wasOfflineResolved'] == true,
    );
  }

  final String id;
  final String adventurerId;
  final DemandType demandType;
  final BuildingType targetBuildingType;
  final int createdTick;
  final int? resolutionTick;
  final DemandStatus status;
  final int? serviceCompletionTick;
  final int goldValue;
  final int reputationValue;
  final bool wasOfflineResolved;

  Demand markServed(int tick) {
    return copyWith(
      resolutionTick: tick,
      status: DemandStatus.served,
      serviceCompletionTick: tick,
    );
  }

  Demand markMissed(int tick) {
    return copyWith(
      resolutionTick: tick,
      status: DemandStatus.missed,
      serviceCompletionTick: null,
    );
  }

  Demand copyWith({
    String? id,
    String? adventurerId,
    DemandType? demandType,
    BuildingType? targetBuildingType,
    int? createdTick,
    int? resolutionTick,
    DemandStatus? status,
    int? serviceCompletionTick,
    int? goldValue,
    int? reputationValue,
    bool? wasOfflineResolved,
  }) {
    final nextDemandType = demandType ?? this.demandType;
    return Demand(
      id: id ?? this.id,
      adventurerId: adventurerId ?? this.adventurerId,
      demandType: nextDemandType,
      targetBuildingType:
          targetBuildingType ?? buildingForDemand(nextDemandType),
      createdTick: _clamp(createdTick ?? this.createdTick),
      resolutionTick: resolutionTick ?? this.resolutionTick,
      status: status ?? this.status,
      serviceCompletionTick:
          serviceCompletionTick ?? this.serviceCompletionTick,
      goldValue: _clamp(goldValue ?? this.goldValue),
      reputationValue: _clamp(reputationValue ?? this.reputationValue),
      wasOfflineResolved: wasOfflineResolved ?? this.wasOfflineResolved,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'adventurerId': adventurerId,
      'demandType': demandType.code,
      'targetBuildingType': targetBuildingType.code,
      'createdTick': createdTick,
      'resolutionTick': resolutionTick,
      'status': status.code,
      'serviceCompletionTick': serviceCompletionTick,
      'goldValue': goldValue,
      'reputationValue': reputationValue,
      'wasOfflineResolved': wasOfflineResolved,
    };
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
