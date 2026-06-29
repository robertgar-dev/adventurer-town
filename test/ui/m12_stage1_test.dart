import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/app/town_view_models.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/ui/town/notable_moments_panel.dart';
import 'package:adventurer_town/src/ui/town/offline_summary_banner.dart';
import 'package:adventurer_town/src/ui/town/resource_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// M12 Stage 1 widget tests for the presentation-only attachment surfaces.
void main() {
  // ---- WP1: Reputation as a Visible Destination ----------------------------
  group('WP1 ResourceHeader reputation destination', () {
    testWidgets('shows a trust trajectory caption next to Reputation',
        (tester) async {
      await _pumpHeader(tester, gold: 10, reputation: 50);

      expect(find.byKey(const Key('reputation-destination')), findsOneWidget);
      expect(find.textContaining('Reliable Stop'), findsOneWidget);
    });

    testWidgets('renders no fill/progress bar (not a spendable wallet)',
        (tester) async {
      await _pumpHeader(tester, gold: 10, reputation: 50);
      // A progress/fill bar would read as XP/wallet; the caption is text-only.
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('at highest standing shows a terminal trust line',
        (tester) async {
      await _pumpHeader(tester, gold: 0, reputation: 1500);
      expect(find.textContaining('Known and trusted'), findsOneWidget);
    });
  });

  // ---- WP2: Offline Return as a Story --------------------------------------
  group('WP2 OfflineSummaryBanner story layer', () {
    testWidgets('renders story lines AND keeps the honest scalars',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineSummaryBanner(
              elapsedSeconds: 3600,
              goldEarned: 40,
              demandServed: 12,
              demandMissed: 3,
              storyLines: const [
                'The Tavern kept the town fed while you were away.',
              ],
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Narrated beat present.
      expect(find.byKey(const Key('offline-summary-story-line-0')),
          findsOneWidget);
      expect(find.text('The Tavern kept the town fed while you were away.'),
          findsOneWidget);
      // Honest scalars retained.
      expect(find.text('+40 Gold'), findsOneWidget);
      expect(find.text('12 served, 3 missed'), findsOneWidget);
    });
  });

  // ---- WP3: Notable Town Moments -------------------------------------------
  group('WP3 NotableMomentsPanel', () {
    testWidgets('renders moments and respects the visible cap', (tester) async {
      final moments = [
        for (var i = 0; i < 4; i++)
          NotableMomentViewModel(id: 'm$i', description: 'Moment number $i.'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NotableMomentsPanel(moments: moments)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('notable-moments-panel')), findsOneWidget);
      expect(find.byKey(const Key('notable-moment-m0')), findsOneWidget);
      expect(find.byKey(const Key('notable-moment-m2')), findsOneWidget);
      // Cap of 3 — the fourth moment is not rendered.
      expect(find.byKey(const Key('notable-moment-m3')), findsNothing);
    });
  });

  // ---- WP4: First Upgrade Stakes and Affirmation ---------------------------
  group('WP4 first-upgrade stakes and affirmation', () {
    testWidgets('shows the stakes note before the first upgrade',
        (tester) async {
      await _pumpTownApp(tester, _state(gold: 125));
      await _openDetail(tester, 'Tavern');

      final note = find.byKey(const Key('first-upgrade-stakes-note'));
      await tester.scrollUntilVisible(
        note,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(note, findsOneWidget);
    });

    testWidgets(
        'shows an affirmation after purchase, with upgrade economics intact',
        (tester) async {
      final repository =
          InMemorySimulationRepository(seedState: _state(gold: 125));
      await _pumpTownApp(tester, _state(gold: 125), repository: repository);
      await _openDetail(tester, 'Tavern');

      final capacityButton = find.byKey(const Key('upgrade-button-capacity'));
      await tester.scrollUntilVisible(
        capacityButton,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(capacityButton);
      await tester.pumpAndSettle();

      // Affirmation surfaced (presentation only).
      expect(find.byKey(const Key('upgrade-affirmation')), findsOneWidget);
      expect(find.textContaining('more capable now'), findsOneWidget);

      // Upgrade economics unchanged: 50 Gold spent, level advanced, flag set.
      final state = await repository.loadState();
      expect(state.resources.gold, 75);
      expect(state.buildings[BuildingType.tavern]?.capacityLevel, 2);
      expect(state.settings.firstUpgradePurchased, isTrue);
    });
  });
}

Future<void> _pumpHeader(
  WidgetTester tester, {
  required int gold,
  required int reputation,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ResourceHeader(
          resources: TownResourcesViewModel(gold: gold, reputation: reputation),
        ),
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

Future<void> _openDetail(WidgetTester tester, String buildingName) async {
  for (var i = 0; i < 10 && find.byType(Scrollable).evaluate().isEmpty; i += 1) {
    await tester.pump(const Duration(milliseconds: 20));
  }
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

SimulationState _state({int gold = 0}) {
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
  );
}
