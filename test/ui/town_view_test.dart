import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Town View displays resources and all MVP buildings',
      (tester) async {
    await _pumpTownApp(tester, _townState());

    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('Reputation'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);

    await _expectVisibleText(tester, 'Inn');
    await _expectVisibleText(tester, 'Tavern');
    await _expectVisibleText(tester, 'Blacksmith');
    await _expectVisibleText(tester, 'Healer');
    await _expectVisibleText(tester, 'Market');
  });

  testWidgets('Town View renders Event Feed empty state', (tester) async {
    await _pumpTownApp(tester, _townState());

    expect(find.text('Event Feed'), findsOneWidget);
    expect(find.text('No recent events.'), findsOneWidget);
  });

  testWidgets('Town View renders recent Event Feed entries', (tester) async {
    await _pumpTownApp(
      tester,
      _townState(
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

    expect(
      find.text('The Tavern served hot meals to hungry adventurers.'),
      findsOneWidget,
    );
    expect(
      find.text("The Inn's beds filled up, and a tired traveler moved on."),
      findsOneWidget,
    );
  });

  testWidgets('Building Cards display demand mapping, levels, and utilization',
      (tester) async {
    await _pumpTownApp(tester, _townState());

    await _expectVisibleText(tester, 'Serves Rest');
    await _expectVisibleText(tester, 'Serves Food');
    expect(find.text('Capacity Lv 2'), findsOneWidget);
    expect(find.text('Value Lv 3'), findsOneWidget);
    expect(find.text('Overloaded'), findsOneWidget);
    expect(find.text('Lost demand 1'), findsOneWidget);
    expect(find.text('Constructed'), findsWidgets);

    await _expectVisibleText(tester, 'Serves Gear');
    await _expectVisibleText(tester, 'Serves Healing');
    await _expectVisibleText(tester, 'Serves Supplies');
    await _expectVisibleText(tester, 'Not constructed');
  });

  testWidgets('Building Cards open read-only detail screens', (tester) async {
    await _pumpTownApp(tester, _townState());

    await tester.tap(find.text('Tavern'));
    await tester.pumpAndSettle();

    expect(find.text('Building Summary'), findsOneWidget);
    expect(find.text('Demand Type'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });
}

Future<void> _pumpTownApp(
  WidgetTester tester,
  SimulationState state,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        simulationRepositoryProvider.overrideWithValue(
          InMemorySimulationRepository(seedState: state),
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

Future<void> _expectVisibleText(
  WidgetTester tester,
  String text,
) async {
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
  }
  expect(finder, findsAtLeastNWidgets(1));
}

SimulationState _townState({
  List<EventFeedEntry> eventFeed = const [],
}) {
  final start = DateTime.utc(2026, 6, 9);
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  buildings[BuildingType.inn] = buildings[BuildingType.inn]!.copyWith(
    recentDemandReceived: 1,
    recentDemandServed: 1,
    lifetimeDemandReceived: 1,
    lifetimeDemandServed: 1,
  );
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    capacityLevel: 2,
    valueLevel: 3,
    recentDemandReceived: 3,
    recentDemandServed: 2,
    recentDemandLost: 1,
    lifetimeDemandReceived: 3,
    lifetimeDemandServed: 2,
    lifetimeDemandLost: 1,
  );

  return initial.copyWith(
    lastResolvedTickAtUtc: DateTime.now().toUtc(),
    resources: const Resources(
      gold: 123,
      reputation: 45,
      lifetimeGoldEarned: 123,
      lifetimeReputationEarned: 45,
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
