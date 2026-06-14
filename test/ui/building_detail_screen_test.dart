import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping Inn opens Inn detail', (tester) async {
    final repository = InMemorySimulationRepository(seedState: _detailState());
    await _pumpTownApp(tester, repository);

    await _openBuildingDetail(tester, 'Inn');

    expect(find.text('Inn'), findsWidgets);
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('Underused (50%)'), findsOneWidget);
  });

  testWidgets('tapping Tavern opens Tavern detail with read-only metrics',
      (tester) async {
    final repository = InMemorySimulationRepository(seedState: _detailState());
    final before = await repository.loadState();
    await _pumpTownApp(tester, repository);

    await _openBuildingDetail(tester, 'Tavern');

    expect(find.text('Tavern'), findsWidgets);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Capacity Level'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Value Level'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Overloaded (150%)'), findsOneWidget);
    expect(find.text('Recent Lost Demand'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Constructed State'), findsOneWidget);
    expect(find.text('Constructed'), findsOneWidget);
    await _expectVisibleText(tester, 'Recent Activity');
    expect(find.text('No recent activity.'), findsOneWidget);
    await _expectVisibleText(tester, 'Upgrade Section');
    await _expectVisibleText(tester, 'Upgrade Capacity');
    await _expectVisibleText(tester, 'Upgrade Value');

    final after = await repository.loadState();
    expect(after.toJson(), before.toJson());
  });

  testWidgets('tapping Blacksmith opens Blacksmith detail', (tester) async {
    final repository = InMemorySimulationRepository(seedState: _detailState());
    await _pumpTownApp(tester, repository);

    await _openBuildingDetail(tester, 'Blacksmith');

    expect(find.text('Blacksmith'), findsWidgets);
    expect(find.text('Gear'), findsOneWidget);
    expect(find.text('Underused (0%)'), findsOneWidget);
    expect(find.text('Recent Lost Demand'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Not constructed'), findsWidgets);
  });

  testWidgets('Building Detail filters recent activity by building',
      (tester) async {
    final repository = InMemorySimulationRepository(
      seedState: _detailState(
        eventFeed: [
          _event(
            id: 'tavern_served',
            eventType: EventType.demandServed,
            buildingType: BuildingType.tavern,
            demandType: DemandType.food,
          ),
          _event(
            id: 'inn_served',
            eventType: EventType.demandServed,
            buildingType: BuildingType.inn,
            demandType: DemandType.rest,
          ),
        ],
      ),
    );
    await _pumpTownApp(tester, repository);

    await _openBuildingDetail(tester, 'Tavern');
    await _expectVisibleText(tester, 'Recent Activity');

    expect(find.text('Tavern served Food demand.'), findsOneWidget);
    expect(find.text('Inn served Rest demand.'), findsNothing);
  });

  testWidgets('Building Detail renders recent activity empty state',
      (tester) async {
    final repository = InMemorySimulationRepository(
      seedState: _detailState(
        eventFeed: [
          _event(
            id: 'inn_served',
            eventType: EventType.demandServed,
            buildingType: BuildingType.inn,
            demandType: DemandType.rest,
          ),
        ],
      ),
    );
    await _pumpTownApp(tester, repository);

    await _openBuildingDetail(tester, 'Tavern');
    await _expectVisibleText(tester, 'Recent Activity');

    expect(find.text('No recent activity.'), findsOneWidget);
  });

  testWidgets('Building Detail does not use deprecated utilization terminology',
      (tester) async {
    final repository = InMemorySimulationRepository(seedState: _detailState());
    await _pumpTownApp(tester, repository);

    await _openBuildingDetail(tester, 'Tavern');

    final deprecatedLabels = [
      String.fromCharCodes(
        [67, 111, 109, 102, 111, 114, 116, 97, 98, 108, 101],
      ),
      String.fromCharCodes([83, 116, 114, 97, 105, 110, 101, 100]),
    ];
    for (final label in deprecatedLabels) {
      expect(find.textContaining(label), findsNothing);
    }
  });
}

Future<void> _pumpTownApp(
  WidgetTester tester,
  InMemorySimulationRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        simulationRepositoryProvider.overrideWithValue(repository),
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

Future<void> _openBuildingDetail(
  WidgetTester tester,
  String buildingName,
) async {
  final finder = find.text(buildingName);
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable),
  );
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
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

SimulationState _detailState({
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
    createdTick: 12,
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
