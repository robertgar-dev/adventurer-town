import 'adventurer.dart';
import 'building.dart';
import 'demand.dart';
import 'economy_constants.dart';
import 'enums.dart';
import 'event_feed_entry.dart';
import 'game_settings.dart';
import 'resources.dart';

class SimulationState {
  const SimulationState({
    required this.schemaVersion,
    required this.tickIntervalSeconds,
    required this.currentTick,
    required this.randomSeed,
    required this.lastResolvedTickAtUtc,
    required this.lastSavedAtUtc,
    required this.resources,
    required this.buildings,
    required this.adventurers,
    required this.activeDemands,
    required this.eventFeed,
    required this.settings,
    required this.unlockedTiers,
    required this.currentTimeOfDay,
    required this.recentWindowTicks,
  });

  factory SimulationState.newGame({
    DateTime? nowUtc,
    int randomSeed = 692026,
  }) {
    final now = (nowUtc ?? DateTime.now()).toUtc();

    return SimulationState(
      schemaVersion: currentSchemaVersion,
      tickIntervalSeconds: fixedTickIntervalSeconds,
      currentTick: 0,
      randomSeed: randomSeed < 0 ? 0 : randomSeed,
      lastResolvedTickAtUtc: now,
      lastSavedAtUtc: now,
      resources: Resources.initial(),
      buildings: Map.unmodifiable({
        for (final type in BuildingType.values)
          type: Building.forType(
            type,
            isConstructed:
                type == BuildingType.inn || type == BuildingType.tavern,
          ),
      }),
      adventurers: const {},
      activeDemands: const {},
      eventFeed: const [],
      settings: GameSettings.defaults(),
      unlockedTiers: const {AdventurerTier.novice},
      currentTimeOfDay: TimeOfDayBand.morning,
      recentWindowTicks: defaultRecentWindowTicks,
    );
  }

  factory SimulationState.fromJson(Map<String, Object?> json) {
    final now = DateTime.now().toUtc();
    final settings = json['settings'] is Map<String, Object?>
        ? GameSettings.fromJson(json['settings']! as Map<String, Object?>)
        : GameSettings.defaults();

    return SimulationState(
      schemaVersion: _positiveInt(json['schemaVersion'], currentSchemaVersion),
      tickIntervalSeconds: fixedTickIntervalSeconds,
      currentTick: _nonNegativeInt(json['currentTick']),
      randomSeed: _nonNegativeInt(json['randomSeed']),
      lastResolvedTickAtUtc: _dateTime(json['lastResolvedTickAtUtc'], now),
      lastSavedAtUtc: _dateTime(json['lastSavedAtUtc'], now),
      resources: json['resources'] is Map<String, Object?>
          ? Resources.fromJson(json['resources']! as Map<String, Object?>)
          : Resources.initial(),
      buildings: _buildingsFromJson(json['buildings']),
      adventurers: _adventurersFromJson(json['adventurers']),
      activeDemands: _activeDemandsFromJson(json['activeDemands']),
      eventFeed: _trimEventFeed(
        _eventFeedFromJson(json['eventFeed']),
        settings.eventFeedMaxEntries,
      ),
      settings: settings,
      unlockedTiers: _tiersFromJson(json['unlockedTiers']),
      currentTimeOfDay: enumFromCode(
        TimeOfDayBand.values,
        json['currentTimeOfDay'],
        TimeOfDayBand.morning,
      ),
      recentWindowTicks: _positiveInt(
        json['recentWindowTicks'],
        defaultRecentWindowTicks,
      ),
    );
  }

  static const int currentSchemaVersion = 1;
  static const int fixedTickIntervalSeconds =
      EconomyConstants.tickIntervalSeconds;
  static const int defaultRecentWindowTicks =
      EconomyConstants.recentMetricsWindowTicks;

  final int schemaVersion;
  final int tickIntervalSeconds;
  final int currentTick;
  final int randomSeed;
  final DateTime lastResolvedTickAtUtc;
  final DateTime lastSavedAtUtc;
  final Resources resources;
  final Map<BuildingType, Building> buildings;
  final Map<String, Adventurer> adventurers;
  final Map<String, Demand> activeDemands;
  final List<EventFeedEntry> eventFeed;
  final GameSettings settings;
  final Set<AdventurerTier> unlockedTiers;
  final TimeOfDayBand currentTimeOfDay;
  final int recentWindowTicks;

  SimulationState copyWith({
    int? schemaVersion,
    int? tickIntervalSeconds,
    int? currentTick,
    int? randomSeed,
    DateTime? lastResolvedTickAtUtc,
    DateTime? lastSavedAtUtc,
    Resources? resources,
    Map<BuildingType, Building>? buildings,
    Map<String, Adventurer>? adventurers,
    Map<String, Demand>? activeDemands,
    List<EventFeedEntry>? eventFeed,
    GameSettings? settings,
    Set<AdventurerTier>? unlockedTiers,
    TimeOfDayBand? currentTimeOfDay,
    int? recentWindowTicks,
  }) {
    final nextSettings = settings ?? this.settings;
    return SimulationState(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      tickIntervalSeconds: fixedTickIntervalSeconds,
      currentTick: _nonNegativeInt(currentTick ?? this.currentTick),
      randomSeed: _nonNegativeInt(randomSeed ?? this.randomSeed),
      lastResolvedTickAtUtc:
          (lastResolvedTickAtUtc ?? this.lastResolvedTickAtUtc).toUtc(),
      lastSavedAtUtc: (lastSavedAtUtc ?? this.lastSavedAtUtc).toUtc(),
      resources: resources ?? this.resources,
      buildings: Map.unmodifiable(buildings ?? this.buildings),
      adventurers: Map.unmodifiable(adventurers ?? this.adventurers),
      activeDemands: Map.unmodifiable(activeDemands ?? this.activeDemands),
      eventFeed: List.unmodifiable(
        _trimEventFeed(
          eventFeed ?? this.eventFeed,
          nextSettings.eventFeedMaxEntries,
        ),
      ),
      settings: nextSettings,
      unlockedTiers: Set.unmodifiable(
        (unlockedTiers == null || unlockedTiers.isEmpty)
            ? const {AdventurerTier.novice}
            : unlockedTiers,
      ),
      currentTimeOfDay: currentTimeOfDay ?? this.currentTimeOfDay,
      recentWindowTicks: _positiveInt(
        recentWindowTicks ?? this.recentWindowTicks,
        defaultRecentWindowTicks,
      ),
    );
  }

  SimulationState withEvent(EventFeedEntry entry) {
    return copyWith(eventFeed: [entry, ...eventFeed]);
  }

  Map<String, Object?> toJson() {
    final sortedBuildingTypes = [...buildings.keys]
      ..sort((a, b) => a.index - b.index);
    final sortedAdventurerIds = [...adventurers.keys]..sort();
    final sortedDemandIds = [...activeDemands.keys]..sort();

    return {
      'schemaVersion': schemaVersion,
      'tickIntervalSeconds': fixedTickIntervalSeconds,
      'currentTick': currentTick,
      'randomSeed': randomSeed,
      'lastResolvedTickAtUtc': lastResolvedTickAtUtc.toUtc().toIso8601String(),
      'lastSavedAtUtc': lastSavedAtUtc.toUtc().toIso8601String(),
      'resources': resources.toJson(),
      'buildings': [
        for (final type in sortedBuildingTypes) buildings[type]!.toJson(),
      ],
      'adventurers': [
        for (final id in sortedAdventurerIds) adventurers[id]!.toJson(),
      ],
      'activeDemands': [
        for (final id in sortedDemandIds) activeDemands[id]!.toJson(),
      ],
      'eventFeed': eventFeed.map((entry) => entry.toJson()).toList(),
      'settings': settings.toJson(),
      'unlockedTiers': unlockedTiers.map((tier) => tier.code).toList()..sort(),
      'currentTimeOfDay': currentTimeOfDay.code,
      'recentWindowTicks': recentWindowTicks,
    };
  }

  static Map<BuildingType, Building> _buildingsFromJson(Object? value) {
    final restored = <BuildingType, Building>{};
    if (value is List) {
      for (final entry in value) {
        if (entry is Map<String, Object?>) {
          final building = Building.fromJson(entry);
          if (building != null) {
            restored[building.buildingType] = building;
          }
        }
      }
    }

    for (final type in BuildingType.values) {
      restored.putIfAbsent(
        type,
        () => Building.forType(
          type,
          isConstructed:
              type == BuildingType.inn || type == BuildingType.tavern,
        ),
      );
    }

    return Map.unmodifiable(restored);
  }

  static Map<String, Adventurer> _adventurersFromJson(Object? value) {
    final restored = <String, Adventurer>{};
    if (value is List) {
      for (final entry in value) {
        if (entry is Map<String, Object?>) {
          final adventurer = Adventurer.fromJson(entry);
          if (adventurer != null) {
            restored[adventurer.id] = adventurer;
          }
        }
      }
    }
    return Map.unmodifiable(restored);
  }

  static Map<String, Demand> _activeDemandsFromJson(Object? value) {
    final restored = <String, Demand>{};
    if (value is List) {
      for (final entry in value) {
        if (entry is Map<String, Object?>) {
          final demand = Demand.fromJson(entry);
          if (demand != null && demand.status == DemandStatus.pending) {
            restored[demand.id] = demand;
          }
        }
      }
    }
    return Map.unmodifiable(restored);
  }

  static List<EventFeedEntry> _eventFeedFromJson(Object? value) {
    final restored = <EventFeedEntry>[];
    if (value is List) {
      for (final entry in value) {
        if (entry is Map<String, Object?>) {
          final event = EventFeedEntry.fromJson(entry);
          if (event != null) {
            restored.add(event);
          }
        }
      }
    }

    restored.sort((a, b) => b.createdTick.compareTo(a.createdTick));
    return restored;
  }

  static List<EventFeedEntry> _trimEventFeed(
    List<EventFeedEntry> entries,
    int maxEntries,
  ) {
    if (entries.length <= maxEntries) {
      return List.unmodifiable(entries);
    }
    return List.unmodifiable(entries.take(maxEntries));
  }

  static Set<AdventurerTier> _tiersFromJson(Object? value) {
    final restored = <AdventurerTier>{};
    if (value is List) {
      for (final entry in value) {
        final tier = enumFromCodeOrNull(AdventurerTier.values, entry);
        if (tier != null) {
          restored.add(tier);
        }
      }
    }

    if (restored.isEmpty) {
      restored.add(AdventurerTier.novice);
    }

    return Set.unmodifiable(restored);
  }

  static DateTime _dateTime(Object? value, DateTime fallback) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toUtc();
      }
    }
    return fallback.toUtc();
  }

  static int _positiveInt(Object? value, int fallback) {
    final parsed = _nonNegativeInt(value);
    return parsed == 0 ? fallback : parsed;
  }

  static int _nonNegativeInt(Object? value) {
    if (value is int) {
      return value < 0 ? 0 : value;
    }
    if (value is num) {
      final parsed = value.floor();
      return parsed < 0 ? 0 : parsed;
    }
    return 0;
  }
}
