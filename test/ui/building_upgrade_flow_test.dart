import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'capacity upgrade displays cost, spends Gold, and refreshes level',
      (tester) async {
    final repository = InMemorySimulationRepository(
      seedState: _upgradeState(gold: 125),
    );
    await _pumpTownApp(tester, repository);
    await _openTavernDetail(tester);

    expect(_panelText(UpgradeAxis.capacity, 'Current Level 1'), findsOneWidget);
    expect(
        _panelText(UpgradeAxis.capacity, 'Next Cost 50 Gold'), findsOneWidget);
    expect(_panelText(UpgradeAxis.capacity, 'Available'), findsOneWidget);

    await tester.tap(find.byKey(const Key('upgrade-button-capacity')));
    await tester.pumpAndSettle();

    final state = await repository.loadState();
    expect(state.resources.gold, 75);
    expect(state.buildings[BuildingType.tavern]?.capacityLevel, 2);
    expect(_panelText(UpgradeAxis.capacity, 'Current Level 2'), findsOneWidget);
    expect(
        _panelText(UpgradeAxis.capacity, 'Next Cost 100 Gold'), findsOneWidget);
  });

  testWidgets('value upgrade displays cost, spends Gold, and refreshes level',
      (tester) async {
    final repository = InMemorySimulationRepository(
      seedState: _upgradeState(gold: 125),
    );
    await _pumpTownApp(tester, repository);
    await _openTavernDetail(tester);

    expect(_panelText(UpgradeAxis.value, 'Current Level 1'), findsOneWidget);
    expect(_panelText(UpgradeAxis.value, 'Next Cost 50 Gold'), findsOneWidget);

    await tester.tap(find.byKey(const Key('upgrade-button-value')));
    await tester.pumpAndSettle();

    final state = await repository.loadState();
    expect(state.resources.gold, 75);
    expect(state.buildings[BuildingType.tavern]?.valueLevel, 2);
    expect(_panelText(UpgradeAxis.value, 'Current Level 2'), findsOneWidget);
    expect(_panelText(UpgradeAxis.value, 'Next Cost 100 Gold'), findsOneWidget);
  });

  testWidgets('upgrade buttons disable when unaffordable', (tester) async {
    final repository = InMemorySimulationRepository(
      seedState: _upgradeState(gold: 0),
    );
    await _pumpTownApp(tester, repository);
    await _openTavernDetail(tester);

    expect(
        _panelText(UpgradeAxis.capacity, 'Next Cost 50 Gold'), findsOneWidget);
    expect(_panelText(UpgradeAxis.capacity, 'Need 50 Gold'), findsOneWidget);
    expect(_panelText(UpgradeAxis.value, 'Need 50 Gold'), findsOneWidget);
    expect(_button(UpgradeAxis.capacity).onPressed, isNull);
    expect(_button(UpgradeAxis.value).onPressed, isNull);
  });

  testWidgets('upgrade buttons disable at max level', (tester) async {
    final repository = InMemorySimulationRepository(
      seedState: _upgradeState(
        gold: 50000,
        reputation: 5000,
        capacityLevel: 10,
        valueLevel: 10,
      ),
    );
    await _pumpTownApp(tester, repository);
    await _openTavernDetail(tester);

    expect(
        _panelText(UpgradeAxis.capacity, 'Current Level 10'), findsOneWidget);
    expect(_panelText(UpgradeAxis.capacity, 'Max Level'), findsWidgets);
    expect(_panelText(UpgradeAxis.value, 'Current Level 10'), findsOneWidget);
    expect(_panelText(UpgradeAxis.value, 'Max Level'), findsWidgets);
    expect(_button(UpgradeAxis.capacity).onPressed, isNull);
    expect(_button(UpgradeAxis.value).onPressed, isNull);
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

Future<void> _openTavernDetail(WidgetTester tester) async {
  await tester.tap(find.text('Tavern'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Upgrade Section'),
    240,
    scrollable: find.byType(Scrollable),
  );
  await tester.pumpAndSettle();
}

Finder _panelText(UpgradeAxis axis, String text) {
  return find.descendant(
    of: find.byKey(Key('upgrade-panel-${axis.code}')),
    matching: find.text(text),
  );
}

FilledButton _button(UpgradeAxis axis) {
  return testerWidget<FilledButton>(
    find.byKey(Key('upgrade-button-${axis.code}')),
  );
}

T testerWidget<T extends Widget>(Finder finder) {
  final element = finder.evaluate().single;
  return element.widget as T;
}

SimulationState _upgradeState({
  required int gold,
  int reputation = 0,
  int capacityLevel = 1,
  int valueLevel = 1,
}) {
  final initial = SimulationState.newGame(
    nowUtc: DateTime.utc(2026, 6, 9),
    randomSeed: 1001,
  );
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    isConstructed: true,
    capacityLevel: capacityLevel,
    valueLevel: valueLevel,
  );

  return initial.copyWith(
    lastResolvedTickAtUtc: DateTime.now().toUtc(),
    resources: Resources(
      gold: gold,
      reputation: reputation,
      lifetimeGoldEarned: gold,
      lifetimeReputationEarned: reputation,
    ),
    buildings: buildings,
  );
}
