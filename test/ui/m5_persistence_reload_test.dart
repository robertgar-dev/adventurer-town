import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// M5 WP-M5-08 — Save/Reload player-facing validation.
///
/// Controller/repository-level persistence and on-disk app-restart retention
/// are already proven in `test/app/m4_core_economy_loop_test.dart`. This adds
/// the missing player-facing evidence: a purchase made through the UI survives
/// an app relaunch and is visible again in the Town View, with no developer
/// tooling. A single shared repository instance models the persisted store
/// across the unmount/remount (app restart).
void main() {
  group('WP-M5-08 player-facing save/reload', () {
    testWidgets('a UI upgrade purchase persists and is visible after restart',
        (tester) async {
      final store = InMemorySimulationRepository(seedState: _seed(gold: 125));

      // Session 1: launch, inspect Tavern, purchase a Capacity upgrade.
      await _pumpApp(tester, store);
      await _openDetail(tester, 'Tavern');

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
      expect(find.text('Current Level 2'), findsWidgets);

      // Restart: fully unmount, then relaunch a fresh app against the same
      // persisted store (a new controller re-loads from it).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await _pumpApp(tester, store);

      // The relaunched Town View reflects the persisted progression.
      expect(find.text('75'), findsOneWidget); // Gold 125 - 50 spent.
      await _expectVisible(tester, 'Capacity Lv 2');
    });

    testWidgets('a fresh launch with no prior save shows safe defaults',
        (tester) async {
      // No seed: the store is empty, modelling a first ever launch.
      final store = InMemorySimulationRepository();

      await _pumpApp(tester, store);

      // Default new game: 0 Gold / 0 Reputation, five MVP buildings present.
      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('Reputation'), findsOneWidget);
      for (final name in const [
        'Inn',
        'Tavern',
        'Blacksmith',
        'Healer',
        'Market',
      ]) {
        await _expectVisible(tester, name);
      }
    });
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  InMemorySimulationRepository store,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        simulationRepositoryProvider.overrideWithValue(store),
      ],
      child: const AdventurerTownApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _openDetail(WidgetTester tester, String buildingName) async {
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

SimulationState _seed({required int gold}) {
  final start = DateTime.utc(2026, 6, 9);
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    isConstructed: true,
    capacityLevel: 1,
    valueLevel: 1,
  );

  return initial.copyWith(
    resources: Resources(
      gold: gold,
      reputation: 0,
      lifetimeGoldEarned: gold,
      lifetimeReputationEarned: 0,
    ),
    buildings: buildings,
  );
}
