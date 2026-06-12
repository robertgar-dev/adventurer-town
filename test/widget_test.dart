import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('town view launches', (tester) async {
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
    await tester.pump();

    expect(find.text('Adventurer Town'), findsOneWidget);
    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('Reputation'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
