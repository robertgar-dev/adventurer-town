import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/app/town_view_models.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/ui/town/building_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// M5 First Playable — focused validation for WP-M5-04..07 over the existing
/// (already implemented) Town View, Building Card, and Building Detail surfaces.
/// No production code is added; these tests reuse the shipped widgets,
/// providers, and view models.
void main() {
  // WP-M5-04 Demand Outcome and Utilization Feedback.
  group('WP-M5-04 demand outcome and utilization feedback', () {
    testWidgets('overloaded building shows pressure and highlighted lost demand',
        (tester) async {
      await _pumpCard(
        tester,
        _card(
          utilizationState: UtilizationState.overloaded,
          utilizationLabel: 'Overloaded',
          recentLostDemand: 2,
        ),
      );

      expect(find.text('Overloaded'), findsOneWidget);
      expect(find.text('Lost demand 2'), findsOneWidget);
      // A pressured building surfaces a warning marker, not a queue.
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('healthy building shows no lost demand and a served marker',
        (tester) async {
      await _pumpCard(
        tester,
        _card(
          utilizationState: UtilizationState.healthy,
          utilizationLabel: 'Healthy',
          recentLostDemand: 0,
        ),
      );

      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('Lost demand 0'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('Event Feed distinguishes served from missed demand',
        (tester) async {
      await _pumpTownApp(
        tester,
        _state(
          eventFeed: [
            _event(
              id: 'served_food',
              eventType: EventType.demandServed,
              buildingType: BuildingType.tavern,
              demandType: DemandType.food,
            ),
            _event(
              id: 'missed_rest',
              eventType: EventType.demandMissed,
              buildingType: BuildingType.inn,
              demandType: DemandType.rest,
            ),
          ],
        ),
      );

      expect(find.text('Tavern served Food demand.'), findsOneWidget);
      expect(find.text('Inn missed Rest demand.'), findsOneWidget);
    });
  });

  // WP-M5-05 Minimum Building Inspect / Upgrade Surface.
  group('WP-M5-05 building inspect surface', () {
    testWidgets('every approved MVP building can be inspected', (tester) async {
      await _pumpTownApp(tester, _state());

      for (final entry in const {
        'Inn': 'Rest',
        'Tavern': 'Food',
        'Blacksmith': 'Gear',
        'Healer': 'Healing',
        'Market': 'Supplies',
      }.entries) {
        await _openDetail(tester, entry.key);

        expect(find.text(entry.key), findsWidgets);
        expect(find.text(entry.value), findsOneWidget);
        expect(find.text('Capacity Level'), findsOneWidget);
        expect(find.text('Value Level'), findsOneWidget);
        await _expectVisible(tester, 'Upgrade Section');

        // Return to the Town View before inspecting the next building.
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    });
  });

  // WP-M5-06 Capacity and Value Upgrade Controls.
  group('WP-M5-06 upgrade controls', () {
    testWidgets('controls expose level, cost, and affordability', (tester) async {
      await _pumpTownApp(tester, _state(gold: 125));
      await _openDetail(tester, 'Tavern');

      await _expectVisible(tester, 'Upgrade Capacity');
      await _expectVisible(tester, 'Upgrade Value');
      expect(find.text('Current Level 1'), findsWidgets);
      expect(find.text('Next Cost 50 Gold'), findsWidgets);
      expect(find.text('Available'), findsWidgets);
    });

    testWidgets('controls disable when Gold is insufficient', (tester) async {
      await _pumpTownApp(tester, _state(gold: 0));
      await _openDetail(tester, 'Tavern');

      await _expectVisible(tester, 'Upgrade Section');
      expect(find.text('Need 50 Gold'), findsWidgets);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('upgrade-button-capacity')))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('upgrade-button-value')))
            .onPressed,
        isNull,
      );
    });
  });

  // WP-M5-07 Upgrade Result Feedback.
  group('WP-M5-07 upgrade result feedback', () {
    testWidgets(
        'purchasing Capacity updates level, cost, and recent activity feedback',
        (tester) async {
      final repository =
          InMemorySimulationRepository(seedState: _state(gold: 125));
      await _pumpTownApp(tester, _state(gold: 125), repository: repository);
      await _openDetail(tester, 'Tavern');

      // Bring the capacity control into view, then purchase.
      final capacityButton = find.byKey(const Key('upgrade-button-capacity'));
      await tester.scrollUntilVisible(
        capacityButton,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Current Level 1'), findsWidgets);

      await tester.tap(capacityButton);
      await tester.pumpAndSettle();

      // Level and next-cost refresh in place (before/after visible).
      expect(find.text('Current Level 2'), findsWidgets);
      expect(find.text('Next Cost 100 Gold'), findsWidgets);

      // Player-facing "what changed" feedback appears in Recent Activity above.
      await _scrollUpTo(tester, 'Tavern Capacity upgraded to Level 2.');

      // Gold was spent (persisted), proving the purchase took effect.
      final state = await repository.loadState();
      expect(state.resources.gold, 75);
      expect(state.buildings[BuildingType.tavern]?.capacityLevel, 2);
    });
  });
}

Future<void> _pumpCard(WidgetTester tester, BuildingCardViewModel card) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BuildingCard(building: card, onTap: () {}),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpTownApp(
  WidgetTester tester,
  SimulationState state, {
  InMemorySimulationRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        simulationRepositoryProvider.overrideWithValue(
          repository ?? InMemorySimulationRepository(seedState: state),
        ),
      ],
      child: const AdventurerTownApp(),
    ),
  );
  await tester.pump();
  await tester.pump();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _waitForScrollable(WidgetTester tester) async {
  for (var i = 0; i < 10 && find.byType(Scrollable).evaluate().isEmpty; i += 1) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> _openDetail(WidgetTester tester, String buildingName) async {
  await _waitForScrollable(tester);
  final finder = find.text(buildingName);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Future<void> _expectVisible(WidgetTester tester, String text) async {
  await _waitForScrollable(tester);
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }
  expect(finder, findsAtLeastNWidgets(1));
}

Future<void> _scrollUpTo(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      -240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }
  expect(finder, findsAtLeastNWidgets(1));
}

BuildingCardViewModel _card({
  required UtilizationState utilizationState,
  required String utilizationLabel,
  required int recentLostDemand,
}) {
  final building = Building.forType(BuildingType.tavern, isConstructed: true);
  return BuildingCardViewModel(
    buildingId: building.id,
    building: building,
    buildingType: BuildingType.tavern,
    name: 'Tavern',
    demandName: 'Food',
    capacityLevel: building.capacityLevel,
    valueLevel: building.valueLevel,
    utilizationState: utilizationState,
    utilizationLabel: utilizationLabel,
    recentLostDemand: recentLostDemand,
    isConstructed: true,
  );
}

SimulationState _state({
  int gold = 0,
  List<EventFeedEntry> eventFeed = const [],
}) {
  final start = DateTime.utc(2026, 6, 9);
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    isConstructed: true,
    capacityLevel: 1,
    valueLevel: 1,
  );

  return initial.copyWith(
    lastResolvedTickAtUtc: DateTime.now().toUtc(),
    resources: Resources(
      gold: gold,
      reputation: 0,
      lifetimeGoldEarned: gold,
      lifetimeReputationEarned: 0,
    ),
    buildings: buildings,
    eventFeed: eventFeed,
  );
}

EventFeedEntry _event({
  required String id,
  required EventType eventType,
  required BuildingType buildingType,
  required DemandType demandType,
}) {
  return EventFeedEntry(
    id: id,
    eventType: eventType,
    createdTick: 7,
    createdAtUtc: DateTime.utc(2026, 6, 9),
    templateId: eventType.code,
    adventurerId: null,
    adventurerTier: null,
    buildingType: buildingType,
    demandType: demandType,
    upgradeAxis: null,
    goldDelta: eventType == EventType.demandServed ? 5 : 0,
    reputationDelta: eventType == EventType.demandServed ? 1 : 0,
    wasOffline: false,
    priority: eventType == EventType.demandMissed ? 2 : 1,
    variables: const {},
  );
}
