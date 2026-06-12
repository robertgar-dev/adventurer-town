import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter_test/flutter_test.dart';

EventFeedEntry _event(int tick) {
  return EventFeedEntry(
    id: 'event_$tick',
    eventType: EventType.demandServed,
    createdTick: tick,
    createdAtUtc: DateTime.utc(2026, 6, 9).add(Duration(minutes: tick)),
    templateId: 'demand_served',
    adventurerId: 'adventurer_1',
    adventurerTier: AdventurerTier.novice,
    buildingType: BuildingType.inn,
    demandType: DemandType.rest,
    upgradeAxis: null,
    goldDelta: 5,
    reputationDelta: 1,
    wasOffline: false,
    priority: 1,
    variables: const {},
  );
}

void main() {
  group('Demand persistence rules', () {
    test('pending demand restores as an active demand', () {
      final pending = Demand.create(
        id: 'demand_pending',
        adventurerId: 'adventurer_1',
        demandType: DemandType.rest,
        createdTick: 3,
        goldValue: 10,
        reputationValue: 2,
      );

      final json = SimulationState.newGame().toJson();
      json['activeDemands'] = [pending.toJson()];
      final restored = SimulationState.fromJson(json);

      expect(restored.activeDemands.keys, ['demand_pending']);
      expect(
        restored.activeDemands['demand_pending']!.status,
        DemandStatus.pending,
      );
    });

    test(
        'served and missed demands do not restore as active backlog',
        () {
      final pending = Demand.create(
        id: 'demand_pending',
        adventurerId: 'adventurer_1',
        demandType: DemandType.rest,
        createdTick: 3,
        goldValue: 10,
        reputationValue: 2,
      );
      final served = Demand.create(
        id: 'demand_served',
        adventurerId: 'adventurer_2',
        demandType: DemandType.food,
        createdTick: 4,
        goldValue: 12,
        reputationValue: 3,
      ).markServed(6);
      final missed = Demand.create(
        id: 'demand_missed',
        adventurerId: 'adventurer_3',
        demandType: DemandType.gear,
        createdTick: 5,
        goldValue: 8,
        reputationValue: 1,
      ).markMissed(7);

      final json = SimulationState.newGame().toJson();
      json['activeDemands'] = [
        pending.toJson(),
        served.toJson(),
        missed.toJson(),
      ];
      final restored = SimulationState.fromJson(json);

      // Only the pending demand survives — completed (served) and lost (missed)
      // demands must never become active backlog.
      expect(restored.activeDemands.length, 1);
      expect(restored.activeDemands.containsKey('demand_pending'), isTrue);
      expect(restored.activeDemands.containsKey('demand_served'), isFalse);
      expect(restored.activeDemands.containsKey('demand_missed'), isFalse);
    });

    test('an all-resolved demand list restores no backlog', () {
      final served = Demand.create(
        id: 'demand_served',
        adventurerId: 'adventurer_2',
        demandType: DemandType.food,
        createdTick: 4,
        goldValue: 12,
        reputationValue: 3,
      ).markServed(6);

      final json = SimulationState.newGame().toJson();
      json['activeDemands'] = [served.toJson()];
      final restored = SimulationState.fromJson(json);

      expect(restored.activeDemands, isEmpty);
    });
  });

  group('State integrity on restore', () {
    test('negative resource values clamp to zero', () {
      final json = SimulationState.newGame().toJson();
      json['resources'] = {
        'gold': -50,
        'reputation': -10,
        'lifetimeGoldEarned': -5,
        'lifetimeReputationEarned': -1,
      };
      final restored = SimulationState.fromJson(json);

      expect(restored.resources.gold, 0);
      expect(restored.resources.reputation, 0);
      expect(restored.resources.lifetimeGoldEarned, 0);
      expect(restored.resources.lifetimeReputationEarned, 0);
    });

    test('invalid building levels clamp to the approved 1..10 bounds', () {
      final inn = Building.forType(BuildingType.inn, isConstructed: true)
          .toJson()
        ..['capacityLevel'] = 99
        ..['valueLevel'] = -3;

      final json = SimulationState.newGame().toJson();
      json['buildings'] = [inn];
      final restored = SimulationState.fromJson(json);

      expect(restored.buildings[BuildingType.inn]!.capacityLevel, 10);
      expect(restored.buildings[BuildingType.inn]!.valueLevel, 1);
    });

    test('missing buildings restore approved MVP defaults', () {
      final json = SimulationState.newGame().toJson();
      json['buildings'] = <Object?>[];
      final restored = SimulationState.fromJson(json);

      expect(restored.buildings.keys.toSet(), BuildingType.values.toSet());
      expect(restored.buildings[BuildingType.inn]!.isConstructed, isTrue);
      expect(restored.buildings[BuildingType.tavern]!.isConstructed, isTrue);
      expect(restored.buildings[BuildingType.blacksmith]!.isConstructed, isFalse);
      expect(restored.buildings[BuildingType.inn]!.capacityLevel, 1);
    });
  });

  group('Event feed retention', () {
    test('event feed survives a save/load round trip in order', () async {
      final events = [for (var tick = 9; tick >= 0; tick--) _event(tick)];
      final state = SimulationState.newGame(nowUtc: DateTime.utc(2026, 6, 9))
          .copyWith(eventFeed: events);

      final repository = InMemorySimulationRepository(seedState: state);
      final loaded = await repository.loadState();

      expect(loaded.eventFeed.length, 10);
      expect(
        loaded.eventFeed.map((entry) => entry.createdTick).toList(),
        [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
      );
    });

    test('event feed retention stays bounded by the configured maximum', () {
      final json = SimulationState.newGame().toJson();
      json['settings'] = (json['settings']! as Map<String, Object?>)
        ..['eventFeedMaxEntries'] = 5;
      json['eventFeed'] = [for (var tick = 0; tick < 12; tick++) _event(tick).toJson()];

      final restored = SimulationState.fromJson(json);

      expect(restored.settings.eventFeedMaxEntries, 5);
      expect(restored.eventFeed.length, 5);
      // Trimming keeps the most recent entries (highest ticks), newest first.
      expect(
        restored.eventFeed.map((entry) => entry.createdTick).toList(),
        [11, 10, 9, 8, 7],
      );
    });
  });
}
