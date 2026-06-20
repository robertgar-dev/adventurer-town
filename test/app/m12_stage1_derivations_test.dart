import 'package:adventurer_town/src/app/town_view_models.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// M12 Stage 1 — pure derivation + copy-guardrail tests for the presentation-only
/// attachment work packages (WP1 Reputation destination, WP2 offline story,
/// WP3 notable moments). No simulation, schema, or economy behavior is exercised
/// here; these are read-only derivations over existing state/view-model data.
void main() {
  // ---- WP1: Reputation as a Visible Destination ----------------------------
  group('WP1 reputationDestinationFor', () {
    test('points at the next standing with the remaining amount to earn', () {
      expect(reputationDestinationFor(0).nextStandingReputation, 100);
      expect(reputationDestinationFor(0).reputationToNextStanding, 100);

      expect(reputationDestinationFor(99).nextStandingReputation, 100);
      expect(reputationDestinationFor(99).reputationToNextStanding, 1);

      // At exactly a threshold, the destination advances to the next one.
      expect(reputationDestinationFor(100).nextStandingReputation, 400);
      expect(reputationDestinationFor(100).reputationToNextStanding, 300);

      expect(reputationDestinationFor(400).nextStandingReputation, 1200);
      expect(reputationDestinationFor(1199).reputationToNextStanding, 1);
    });

    test('reaches a highest-standing terminal state with no next threshold', () {
      final maxed = reputationDestinationFor(1200);
      expect(maxed.isAtHighestStanding, isTrue);
      expect(maxed.nextStandingReputation, isNull);
      expect(maxed.reputationToNextStanding, isNull);
      expect(reputationDestinationFor(5000).isAtHighestStanding, isTrue);
    });

    test('copy is trust-framed and never implies spending or offline gain', () {
      for (final reputation in [0, 50, 100, 399, 400, 1200, 5000]) {
        final text = reputationDestinationFor(reputation).trajectoryText
            .toLowerCase();
        for (final forbidden in const [
          'spend',
          'buy',
          'cost',
          'purchase',
          'pay',
          'wallet',
          'offline',
          r'$',
        ]) {
          expect(text.contains(forbidden), isFalse,
              reason: 'destination copy must not contain "$forbidden": $text');
        }
      }
    });
  });

  // ---- WP3: Notable Town Moments -------------------------------------------
  group('WP3 deriveNotableMoments', () {
    test('a fresh town (low trust, partial build, no service) has none', () {
      final moments = deriveNotableMoments(_newGame());
      expect(moments, isEmpty);
    });

    test('surfaces the standing reached once trust crosses a threshold', () {
      final moments = deriveNotableMoments(_newGame(reputation: 150));
      expect(moments.map((m) => m.id), contains('notable_standing_100'));
    });

    test('surfaces an all-services-open moment when every building stands', () {
      final moments = deriveNotableMoments(_newGame(allConstructed: true));
      expect(moments.map((m) => m.id), contains('notable_all_services_open'));
    });

    test('names the building that has served the most adventurers', () {
      final moments = deriveNotableMoments(
        _newGame(tavernLifetimeServed: 42),
      );
      final carrier = moments.firstWhere(
        (m) => m.id == 'notable_carrier_tavern',
        orElse: () => const NotableMomentViewModel(id: 'none', description: ''),
      );
      expect(carrier.id, 'notable_carrier_tavern');
      expect(carrier.description, contains('Tavern'));
    });

    test('is capped at three moments and never mentions quest/hero fiction', () {
      final moments = deriveNotableMoments(
        _newGame(
          reputation: 1500,
          allConstructed: true,
          tavernLifetimeServed: 99,
        ),
      );
      expect(moments.length, lessThanOrEqualTo(3));
      for (final moment in moments) {
        final text = moment.description.toLowerCase();
        for (final forbidden in const ['quest', 'hero', 'battle', 'boss']) {
          expect(text.contains(forbidden), isFalse,
              reason: 'notable copy must stay economic-with-flavor: $text');
        }
      }
    });
  });

  // ---- WP2: Offline Return as a Story --------------------------------------
  group('WP2 offlineStoryLines', () {
    test('narrates the busiest building and the most-missed demand', () {
      final feed = [
        _item(EventType.demandServed, BuildingType.tavern, offline: true),
        _item(EventType.demandServed, BuildingType.tavern, offline: true),
        _item(EventType.demandServed, BuildingType.inn, offline: true),
        _item(EventType.demandMissed, BuildingType.market, offline: true),
      ];
      final lines = offlineStoryLines(feed);
      expect(lines.length, 2);
      expect(lines.first, contains('Tavern'));
      expect(lines.any((l) => l.contains('Market')), isTrue);
    });

    test('ignores non-offline entries entirely', () {
      final feed = [
        _item(EventType.demandServed, BuildingType.tavern),
        _item(EventType.demandMissed, BuildingType.market),
      ];
      expect(offlineStoryLines(feed), isEmpty);
    });

    test('copy is Gold-only and never implies Reputation, backlog, or payment',
        () {
      final feed = [
        for (final type in BuildingType.values)
          _item(EventType.demandServed, type, offline: true),
        for (final type in BuildingType.values)
          _item(EventType.demandMissed, type, offline: true),
      ];
      final joined = offlineStoryLines(feed).join(' ').toLowerCase();
      for (final forbidden in const [
        'reputation',
        'queue',
        'backlog',
        'recover',
        'buy',
        'pay',
        'unlock',
        'restore',
        r'$',
      ]) {
        expect(joined.contains(forbidden), isFalse,
            reason: 'offline story copy must not contain "$forbidden"');
      }
    });
  });
}

SimulationState _newGame({
  int reputation = 0,
  bool allConstructed = false,
  int tavernLifetimeServed = 0,
}) {
  final base = SimulationState.newGame(
    nowUtc: DateTime.utc(2026, 6, 9),
    randomSeed: 1001,
  );
  final buildings = Map<BuildingType, Building>.from(base.buildings);
  if (allConstructed) {
    for (final type in BuildingType.values) {
      buildings[type] = buildings[type]!.copyWith(isConstructed: true);
    }
  }
  if (tavernLifetimeServed > 0) {
    buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
      isConstructed: true,
      lifetimeDemandServed: tavernLifetimeServed,
    );
  }
  return base.copyWith(
    resources: Resources(
      gold: 0,
      reputation: reputation,
      lifetimeGoldEarned: 0,
      lifetimeReputationEarned: reputation,
    ),
    buildings: buildings,
  );
}

EventFeedItemViewModel _item(
  EventType eventType,
  BuildingType buildingType, {
  bool offline = false,
}) {
  return EventFeedItemViewModel(
    id: 'evt_${buildingType.code}_${eventType.code}_$offline',
    eventType: eventType,
    createdTick: 1,
    description: 'derived test row',
    buildingType: buildingType,
    demandType: null,
    upgradeAxis: null,
    goldDelta: 0,
    reputationDelta: 0,
    isOffline: offline,
    priority: 1,
  );
}
