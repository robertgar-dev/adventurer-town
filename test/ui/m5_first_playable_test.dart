import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/app/town_view_models.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/ui/town/building_card.dart';
import 'package:adventurer_town/src/ui/town/resource_header.dart';
import 'package:adventurer_town/src/ui/town/town_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// M5 First Playable — focused acceptance coverage for the three in-scope work
/// packages:
///
/// * WP-M5-01 Main Town View Shell — the app launches to the player-facing
///   Town View as the default screen.
/// * WP-M5-02 Resource Header — Gold and Reputation are visible.
/// * WP-M5-03 Building List/Grid — the five approved MVP buildings render with
///   Capacity and Value levels, and no other buildings are surfaced.
///
/// These reuse the existing TownView, ResourceHeader, BuildingCard widgets and
/// the existing town providers/view models (townResourcesProvider,
/// townBuildingCardsProvider). No new gameplay or systems are introduced.
void main() {
  group('WP-M5-01 Main Town View Shell', () {
    testWidgets('app launches to the Town View as the default screen',
        (tester) async {
      await _pumpTownApp(tester, _townState());

      expect(find.byType(TownView), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Adventurer Town'), findsOneWidget);
      // The Resource Header and at least one building card are present on land.
      expect(find.byType(ResourceHeader), findsOneWidget);
      expect(find.byType(BuildingCard), findsWidgets);
    });
  });

  group('WP-M5-02 Resource Header', () {
    testWidgets('renders Gold and Reputation labels and values in isolation',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResourceHeader(
              resources: TownResourcesViewModel(gold: 250, reputation: 60),
            ),
          ),
        ),
      );

      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('Reputation'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('reflects the resource values from simulation state on launch',
        (tester) async {
      await _pumpTownApp(tester, _townState());

      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.text('Reputation'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
    });
  });

  group('WP-M5-03 Building List/Grid', () {
    testWidgets('renders only the five approved MVP buildings', (tester) async {
      await _pumpTownApp(tester, _townState());

      for (final name in const [
        'Inn',
        'Tavern',
        'Blacksmith',
        'Healer',
        'Market',
      ]) {
        await _expectVisibleText(tester, name);
      }

      // No buildings outside the approved MVP set are surfaced.
      final cardNames = tester
          .widgetList<BuildingCard>(find.byType(BuildingCard))
          .map((card) => card.building.name)
          .toSet();
      expect(
        cardNames.difference(
          const {'Inn', 'Tavern', 'Blacksmith', 'Healer', 'Market'},
        ),
        isEmpty,
      );
    });

    testWidgets('building cards show Capacity and Value levels', (tester) async {
      await _pumpTownApp(tester, _townState());

      // Tavern is seeded at Capacity Lv 2 / Value Lv 3.
      await _expectVisibleText(tester, 'Tavern');
      await _expectVisibleText(tester, 'Capacity Lv 2');
      await _expectVisibleText(tester, 'Value Lv 3');

      // Inn (default) shows Level 1 on both axes.
      await _expectVisibleText(tester, 'Capacity Lv 1');
      await _expectVisibleText(tester, 'Value Lv 1');
    });
  });
}

Future<void> _pumpTownApp(WidgetTester tester, SimulationState state) async {
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

Future<void> _expectVisibleText(WidgetTester tester, String text) async {
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

SimulationState _townState() {
  final start = DateTime.utc(2026, 6, 9);
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    capacityLevel: 2,
    valueLevel: 3,
  );

  return initial.copyWith(
    resources: const Resources(
      gold: 123,
      reputation: 45,
      lifetimeGoldEarned: 123,
      lifetimeReputationEarned: 45,
    ),
    buildings: buildings,
  );
}
