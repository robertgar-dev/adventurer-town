import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WP-M7-06 offline summary banner shows on launch and dismisses',
      (tester) async {
    // A save last resolved an hour ago triggers offline progression on load.
    final last = DateTime.now().toUtc().subtract(const Duration(hours: 1));
    final seed = SimulationState.newGame(nowUtc: last, randomSeed: 1001)
        .copyWith(lastResolvedTickAtUtc: last);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          simulationRepositoryProvider.overrideWithValue(
            InMemorySimulationRepository(seedState: seed),
          ),
        ],
        child: const AdventurerTownApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });

    expect(find.byKey(const Key('offline-summary-banner')), findsOneWidget);
    expect(find.text('While you were away'), findsOneWidget);
    expect(find.textContaining('Gold'), findsWidgets);

    await tester.tap(find.byKey(const Key('offline-summary-dismiss')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offline-summary-banner')), findsNothing);
  });

  testWidgets('no banner appears for a fresh game with no elapsed time',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          simulationRepositoryProvider.overrideWithValue(
            InMemorySimulationRepository(),
          ),
        ],
        child: const AdventurerTownApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });

    expect(find.byKey(const Key('offline-summary-banner')), findsNothing);
  });
}
