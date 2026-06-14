import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('M9 town onboarding hints', () {
    testWidgets('first launch shows the welcome card and dismiss persists',
        (tester) async {
      final repository = _repo(_fresh());
      await _pump(tester, repository);

      expect(find.byKey(const Key('onboarding-card-welcome')), findsOneWidget);
      expect(find.text('Welcome to your town'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-dismiss-welcome')));
      await tester.pumpAndSettle();

      // Welcome is gone and the next hint (resources) takes its place.
      expect(find.byKey(const Key('onboarding-card-welcome')), findsNothing);
      expect(find.byKey(const Key('onboarding-card-resources')), findsOneWidget);

      final saved = await repository.loadState();
      expect(saved.settings.welcomeSeen, isTrue);
      expect(saved.settings.resourcesHintSeen, isFalse);
    });

    testWidgets('resources hint surfaces once welcome is seen', (tester) async {
      await _pump(tester, _repo(_seen(welcome: true)));
      expect(find.byKey(const Key('onboarding-card-resources')), findsOneWidget);
      expect(find.textContaining('Reputation is the trust'), findsOneWidget);
    });

    testWidgets('event feed hint surfaces once resources is seen',
        (tester) async {
      await _pump(tester, _repo(_seen(welcome: true, resources: true)));
      expect(find.byKey(const Key('onboarding-card-eventFeed')), findsOneWidget);
    });

    testWidgets('no town hint once welcome/resources/feed are all seen',
        (tester) async {
      await _pump(
        tester,
        _repo(_seen(welcome: true, resources: true, eventFeed: true)),
      );
      expect(find.byKey(const Key('onboarding-card-welcome')), findsNothing);
      expect(find.byKey(const Key('onboarding-card-resources')), findsNothing);
      expect(find.byKey(const Key('onboarding-card-eventFeed')), findsNothing);
    });

    testWidgets('a seen welcome stays dismissed across a restart',
        (tester) async {
      final repository = _repo(_fresh());
      await _pump(tester, repository);

      await tester.tap(find.byKey(const Key('onboarding-dismiss-welcome')));
      await tester.pumpAndSettle();

      // Restart: fresh app + controller against the same persisted store.
      await tester.pumpWidget(const SizedBox.shrink());
      await _pump(tester, repository);

      expect(find.byKey(const Key('onboarding-card-welcome')), findsNothing);
    });
  });

  group('M9 building detail hint', () {
    testWidgets('Capacity vs Value hint shows on first open and persists',
        (tester) async {
      final repository = _repo(_seen(welcome: true, resources: true, eventFeed: true));
      await _pump(tester, repository);
      await _openTavern(tester);

      expect(
        find.byKey(const Key('onboarding-card-buildingDetail')),
        findsOneWidget,
      );
      expect(find.text('Capacity and Value'), findsOneWidget);

      await tester
          .tap(find.byKey(const Key('onboarding-dismiss-buildingDetail')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('onboarding-card-buildingDetail')),
        findsNothing,
      );

      final saved = await repository.loadState();
      expect(saved.settings.buildingDetailHintSeen, isTrue);
    });

    testWidgets('no detail hint once seen', (tester) async {
      await _pump(
        tester,
        _repo(_seen(
          welcome: true,
          resources: true,
          eventFeed: true,
          buildingDetail: true,
        )),
      );
      await _openTavern(tester);

      expect(
        find.byKey(const Key('onboarding-card-buildingDetail')),
        findsNothing,
      );
    });
  });

  group('M9 offline return note', () {
    testWidgets('first offline return shows the framing note', (tester) async {
      final last = DateTime.now().toUtc().subtract(const Duration(hours: 1));
      final seed = _seen(welcome: true, resources: true, eventFeed: true)
          .copyWith(lastResolvedTickAtUtc: last);
      final repository = _repo(seed);
      await _pump(tester, repository);

      expect(find.byKey(const Key('offline-summary-banner')), findsOneWidget);
      expect(find.textContaining("while you're watching"), findsOneWidget);

      await tester.tap(find.byKey(const Key('offline-summary-dismiss')));
      await tester.pumpAndSettle();

      final saved = await repository.loadState();
      expect(saved.settings.offlineHintSeen, isTrue);
    });
  });
}

InMemorySimulationRepository _repo(SimulationState state) {
  return InMemorySimulationRepository(seedState: state);
}

SimulationState _fresh() {
  // Fresh game with lastResolvedTickAtUtc == now (no offline resolution).
  return SimulationState.newGame(nowUtc: DateTime.now().toUtc(), randomSeed: 1001);
}

SimulationState _seen({
  bool welcome = false,
  bool resources = false,
  bool eventFeed = false,
  bool buildingDetail = false,
}) {
  final base = _fresh();
  return base.copyWith(
    settings: base.settings.copyWith(
      welcomeSeen: welcome,
      resourcesHintSeen: resources,
      eventFeedHintSeen: eventFeed,
      buildingDetailHintSeen: buildingDetail,
    ),
  );
}

Future<void> _pump(
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
  await tester.pump(const Duration(milliseconds: 20));
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _openTavern(WidgetTester tester) async {
  final finder = find.text('Tavern');
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
