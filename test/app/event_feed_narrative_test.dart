import 'package:adventurer_town/src/app/town_view_models.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// M8 Event Feed — bounded narrative template resolver coverage.
///
/// Verifies the economic-with-flavor copy stays mechanically accurate,
/// non-punitive, fallback-safe, and scope-clean (no unsupported mechanics, no
/// spendable Reputation, no command voice).
void main() {
  // Language patterns that would imply systems M8 must never suggest.
  const banned = <String>[
    'queue',
    'queued',
    'refund',
    'recover',
    'reservation',
    'reserved',
    'waiting',
    'quest',
    'combat',
    'inventory',
    'craft',
    'staff',
    'faction',
    'upgrade now',
    'spend reputation',
    'buy reputation',
  ];

  String require(EventFeedEntry entry) {
    final copy = eventFeedNarrative(entry);
    expect(copy, isNotNull, reason: 'expected copy for ${entry.eventType}');
    return copy!;
  }

  void expectClean(String copy) {
    final lower = copy.toLowerCase();
    for (final word in banned) {
      expect(lower.contains(word), isFalse,
          reason: 'copy must not contain "$word": "$copy"');
    }
    // Mobile readability: one compact row, not a prose block.
    expect(copy.length, lessThanOrEqualTo(100), reason: 'too long: "$copy"');
  }

  group('WP-M8-03/04 served templates', () {
    test('each building maps to building-aware served copy', () {
      final expectations = <BuildingType, String>{
        BuildingType.inn: 'Inn',
        BuildingType.tavern: 'Tavern',
        BuildingType.blacksmith: 'Blacksmith',
        BuildingType.healer: 'Healer',
        BuildingType.market: 'Market',
      };
      for (final entry in expectations.entries) {
        final copy = require(_served(entry.key));
        expect(copy, contains(entry.value));
        expectClean(copy);
      }
    });

    test('served copy reads as capability (WP-M8-13)', () {
      expect(require(_served(BuildingType.tavern)), contains('served'));
      expect(require(_served(BuildingType.inn)), contains('rest'));
      expect(require(_served(BuildingType.healer)), contains('tended'));
    });
  });

  group('WP-M8-05 missed templates', () {
    test('missed copy is missed-opportunity, never punitive', () {
      for (final building in BuildingType.values) {
        final copy = require(_missed(building));
        expect(copy, contains(buildingName(building)));
        expectClean(copy);
        final lower = copy.toLowerCase();
        for (final blame in const ['fail', 'blame', 'wasted', 'lost demand']) {
          expect(lower.contains(blame), isFalse,
              reason: 'missed copy must not blame: "$copy"');
        }
      }
    });

    test('missed copy conveys an opportunity that passed (WP-M8-13)', () {
      expect(require(_missed(BuildingType.tavern)), contains('passed'));
      expect(require(_missed(BuildingType.inn)), contains('moved on'));
      expect(require(_missed(BuildingType.market)), contains('without'));
    });
  });

  group('WP-M8-06 upgrade-axis templates', () {
    test('Capacity reads as more coverage / more helped', () {
      final copy = require(
        _upgrade(BuildingType.tavern, UpgradeAxis.capacity, level: '2'),
      );
      expect(copy, contains('Capacity'));
      expect(copy, contains('more'));
      expect(copy.toLowerCase(), contains('helped'));
      expect(copy, contains('Food'));
      expectClean(copy);
    });

    test('Value reads as better Gold return', () {
      final copy = require(
        _upgrade(BuildingType.tavern, UpgradeAxis.value, level: '2'),
      );
      expect(copy, contains('Value'));
      expect(copy, contains('Gold'));
      expect(copy.toLowerCase(), contains('earns'));
      expectClean(copy);
    });
  });

  group('WP-M8-04 fallback safety', () {
    test('non-display categories return null', () {
      expect(eventFeedNarrative(_bare(EventType.demandGenerated)), isNull);
      expect(eventFeedNarrative(_bare(EventType.simulationTick)), isNull);
      expect(eventFeedNarrative(_bare(EventType.adventurerArrived)), isNull);
      expect(eventFeedNarrative(_bare(EventType.buildingBottleneck)), isNull);
    });

    test('served/missed without a building return null', () {
      expect(eventFeedNarrative(_bare(EventType.demandServed)), isNull);
      expect(eventFeedNarrative(_bare(EventType.demandMissed)), isNull);
    });

    test('upgrade without an axis returns null', () {
      expect(
        eventFeedNarrative(
          _entry(EventType.buildingUpgraded, building: BuildingType.inn),
        ),
        isNull,
      );
    });

    test('served still resolves when demand is missing', () {
      final copy = eventFeedNarrative(
        _entry(EventType.demandServed, building: BuildingType.inn),
      );
      expect(copy, isNotNull);
      expect(copy, contains('Inn'));
    });
  });
}

EventFeedEntry _served(BuildingType building) {
  return _entry(
    EventType.demandServed,
    building: building,
    demand: demandServedByBuilding(building),
    gold: 5,
    rep: 1,
  );
}

EventFeedEntry _missed(BuildingType building) {
  return _entry(
    EventType.demandMissed,
    building: building,
    demand: demandServedByBuilding(building),
  );
}

EventFeedEntry _upgrade(
  BuildingType building,
  UpgradeAxis axis, {
  required String level,
}) {
  return _entry(
    EventType.buildingUpgraded,
    building: building,
    demand: demandServedByBuilding(building),
    axis: axis,
    level: level,
  );
}

EventFeedEntry _bare(EventType type) => _entry(type);

EventFeedEntry _entry(
  EventType type, {
  BuildingType? building,
  DemandType? demand,
  UpgradeAxis? axis,
  String? level,
  int gold = 0,
  int rep = 0,
  bool offline = false,
}) {
  return EventFeedEntry(
    id: 'event_${type.code}',
    eventType: type,
    createdTick: 7,
    createdAtUtc: DateTime.utc(2026, 6, 14),
    templateId: type.code,
    adventurerId: null,
    adventurerTier: null,
    buildingType: building,
    demandType: demand,
    upgradeAxis: axis,
    goldDelta: gold,
    reputationDelta: rep,
    wasOffline: offline,
    priority: 1,
    variables: level == null ? const {} : {'level': level},
  );
}
