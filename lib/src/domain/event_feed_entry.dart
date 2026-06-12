import 'enums.dart';

class EventFeedEntry {
  const EventFeedEntry({
    required this.id,
    required this.eventType,
    required this.createdTick,
    required this.createdAtUtc,
    required this.templateId,
    required this.adventurerId,
    required this.adventurerTier,
    required this.buildingType,
    required this.demandType,
    required this.upgradeAxis,
    required this.goldDelta,
    required this.reputationDelta,
    required this.wasOffline,
    required this.priority,
    required this.variables,
  });

  static EventFeedEntry? fromJson(Map<String, Object?> json) {
    final eventType = enumFromCodeOrNull(EventType.values, json['eventType']);
    if (eventType == null) {
      return null;
    }

    return EventFeedEntry(
      id: _stringOr(json['id'], 'event_unknown'),
      eventType: eventType,
      createdTick: _nonNegativeInt(json['createdTick']),
      createdAtUtc: _dateTime(json['createdAtUtc']),
      templateId: _stringOr(json['templateId'], eventType.code),
      adventurerId: json['adventurerId'] as String?,
      adventurerTier: enumFromCodeOrNull(
        AdventurerTier.values,
        json['adventurerTier'],
      ),
      buildingType:
          enumFromCodeOrNull(BuildingType.values, json['buildingType']),
      demandType: enumFromCodeOrNull(DemandType.values, json['demandType']),
      upgradeAxis: enumFromCodeOrNull(UpgradeAxis.values, json['upgradeAxis']),
      goldDelta: _intValue(json['goldDelta']),
      reputationDelta: _intValue(json['reputationDelta']),
      wasOffline: json['wasOffline'] == true,
      priority: _nonNegativeInt(json['priority']),
      variables: _stringMap(json['variables']),
    );
  }

  final String id;
  final EventType eventType;
  final int createdTick;
  final DateTime createdAtUtc;
  final String templateId;
  final String? adventurerId;
  final AdventurerTier? adventurerTier;
  final BuildingType? buildingType;
  final DemandType? demandType;
  final UpgradeAxis? upgradeAxis;
  final int goldDelta;
  final int reputationDelta;
  final bool wasOffline;
  final int priority;
  final Map<String, String> variables;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'eventType': eventType.code,
      'createdTick': createdTick,
      'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
      'templateId': templateId,
      'adventurerId': adventurerId,
      'adventurerTier': adventurerTier?.code,
      'buildingType': buildingType?.code,
      'demandType': demandType?.code,
      'upgradeAxis': upgradeAxis?.code,
      'goldDelta': goldDelta,
      'reputationDelta': reputationDelta,
      'wasOffline': wasOffline,
      'priority': priority,
      'variables': variables,
    };
  }

  static int _nonNegativeInt(Object? value) {
    final parsed = _intValue(value);
    return parsed < 0 ? 0 : parsed;
  }

  static int _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.floor();
    }
    return 0;
  }

  static String _stringOr(Object? value, String fallback) {
    return value is String && value.isNotEmpty ? value : fallback;
  }

  static DateTime _dateTime(Object? value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toUtc();
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static Map<String, String> _stringMap(Object? value) {
    if (value is! Map) {
      return const {};
    }

    return Map.unmodifiable(
      value.map(
        (key, mapValue) => MapEntry(key.toString(), mapValue.toString()),
      ),
    );
  }
}
