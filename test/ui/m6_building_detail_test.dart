import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/app/town_view_models.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// M6 Building Detail UX — WP-M6-06 validation.
///
/// All assertions exercise derived presentation only. No simulation is run by
/// these helpers beyond seeding state, and no persistence schema is touched.
void main() {
  group('WP-M6-01 building purpose clarity (view model)', () {
    test('purpose names the building and the demand it serves', () {
      final vm = buildingDetailViewModelFor(
        building: _tavern(),
        resources: _res(0),
      );
      expect(vm.purposeDescription, contains('Tavern serves Food demand'));
      expect(vm.purposeDescription, contains('Capacity'));
      expect(vm.purposeDescription, contains('Value'));
    });
  });

  group('WP-M6-02 upgrade decision support (view model)', () {
    test('capacity effect shows before -> after throughput', () {
      final vm = buildingDetailViewModelFor(
        building: _tavern(capacityLevel: 1),
        resources: _res(0),
      );
      expect(vm.capacityUpgrade.effectLabel, 'Serves 1 -> 2 per tick');
    });

    test('value effect shows before -> after Gold per service', () {
      final vm = buildingDetailViewModelFor(
        building: _tavern(valueLevel: 1),
        resources: _res(0),
      );
      // Food base reward 7; value multiplier x1.00 -> x1.15 => 7 -> 8.
      expect(vm.valueUpgrade.effectLabel, 'Gold per service 7 -> 8');
    });

    test('derived effects match the approved economy constants', () {
      final vm = buildingDetailViewModelFor(
        building: _tavern(capacityLevel: 3, valueLevel: 2),
        resources: _res(0),
      );
      final capCurrent =
          EconomyConstants.effectiveCapacity(BuildingType.tavern, 3);
      final capNext = EconomyConstants.effectiveCapacity(BuildingType.tavern, 4);
      expect(vm.capacityUpgrade.effectLabel,
          'Serves $capCurrent -> $capNext per tick');
    });

    test('max level reports no further effect', () {
      final vm = buildingDetailViewModelFor(
        building: _tavern(capacityLevel: 10),
        resources: _res(0),
      );
      expect(vm.capacityUpgrade.isMaxLevel, isTrue);
      expect(vm.capacityUpgrade.effectLabel, 'At maximum level');
    });
  });

  group('WP-M6-03 bottleneck visibility (view model)', () {
    test('a building losing demand is flagged under pressure', () {
      final overloaded = _tavern(capacityLevel: 1).copyWith(
        recentDemandReceived: 5,
        recentDemandLost: 3,
      );
      final vm = buildingDetailViewModelFor(
        building: overloaded,
        resources: _res(0),
      );
      expect(vm.isUnderPressure, isTrue);
      expect(vm.pressureSummary, contains('Under pressure'));
    });

    test('the primary bottleneck flag yields a distinct summary', () {
      final overloaded = _tavern(capacityLevel: 1).copyWith(
        recentDemandReceived: 5,
        recentDemandLost: 3,
      );
      final vm = buildingDetailViewModelFor(
        building: overloaded,
        resources: _res(0),
        isPrimaryBottleneck: true,
      );
      expect(vm.isPrimaryBottleneck, isTrue);
      expect(vm.pressureSummary, contains('Top bottleneck'));
    });

    test('a healthy building is not under pressure', () {
      final vm = buildingDetailViewModelFor(
        building: _tavern(capacityLevel: 5),
        resources: _res(0),
      );
      expect(vm.isUnderPressure, isFalse);
      expect(vm.pressureSummary, contains('Healthy'));
    });
  });

  group('WP-M6-04 recent building performance (view model)', () {
    test('performance fields mirror existing building metrics', () {
      final building = _tavern(capacityLevel: 2).copyWith(
        recentDemandReceived: 3,
        recentDemandServed: 2,
        recentDemandLost: 1,
        recentGoldEarned: 14,
        lifetimeDemandServed: 5,
        lifetimeDemandReceived: 7,
        lifetimeDemandLost: 2,
        lifetimeGoldEarned: 40,
      );
      final vm = buildingDetailViewModelFor(
        building: building,
        resources: _res(0),
      );

      expect(vm.capacityPerTick,
          EconomyConstants.effectiveCapacity(BuildingType.tavern, 2));
      expect(vm.recentDemandReceived, 3);
      expect(vm.recentDemandServed, 2);
      expect(vm.recentLostDemand, 1);
      expect(vm.recentGoldEarned, 14);
      expect(vm.lifetimeDemandServed, 5);
      expect(vm.lifetimeDemandLost, 2);
      expect(vm.lifetimeGoldEarned, 40);
    });
  });

  group('WP-M6 detail screen (widget)', () {
    testWidgets('renders purpose, performance, decision support, bottleneck',
        (tester) async {
      await _pumpApp(tester, _bottleneckState());
      await _openDetail(tester, 'Tavern');

      // Top of the detail screen (no scroll needed).
      expect(
        find.textContaining('Tavern serves Food demand'),
        findsOneWidget,
      ); // WP-M6-01
      expect(find.text('Primary Bottleneck'), findsOneWidget); // WP-M6-03

      // Recent Performance section (WP-M6-04).
      await _scrollTo(tester, 'Recent Performance');
      expect(find.text('Capacity per tick'), findsOneWidget);

      // Upgrade decision support in the Upgrade Section (WP-M6-02).
      await _scrollTo(tester, 'Upgrade Section');
      expect(find.text('Serves 2 -> 3 per tick'), findsOneWidget);
      expect(find.text('Gold per service 9 -> 10'), findsOneWidget);
    });

    testWidgets('WP-M6-05 recent activity shows resource deltas',
        (tester) async {
      await _pumpApp(
        tester,
        _bottleneckState(
          eventFeed: [
            EventFeedEntry(
              id: 'tavern_served',
              eventType: EventType.demandServed,
              createdTick: 9,
              createdAtUtc: DateTime.utc(2026, 6, 9),
              templateId: 'demand_served',
              adventurerId: null,
              adventurerTier: null,
              buildingType: BuildingType.tavern,
              demandType: DemandType.food,
              upgradeAxis: null,
              goldDelta: 5,
              reputationDelta: 1,
              wasOffline: false,
              priority: 1,
              variables: const {},
            ),
          ],
        ),
      );
      await _openDetail(tester, 'Tavern');

      await _expectVisible(
          tester, 'The Tavern served hot meals to hungry adventurers.');
      await _expectVisible(tester, '+5 Gold · word spread');
    });
  });
}

Building _tavern({int capacityLevel = 1, int valueLevel = 1}) {
  return Building.forType(BuildingType.tavern, isConstructed: true).copyWith(
    capacityLevel: capacityLevel,
    valueLevel: valueLevel,
  );
}

Resources _res(int gold) {
  return Resources(
    gold: gold,
    reputation: 0,
    lifetimeGoldEarned: gold,
    lifetimeReputationEarned: 0,
  );
}

SimulationState _bottleneckState({List<EventFeedEntry> eventFeed = const []}) {
  final start = DateTime.utc(2026, 6, 9);
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  // Tavern is the only building losing demand => the town's primary bottleneck.
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    isConstructed: true,
    capacityLevel: 2,
    valueLevel: 3,
    recentDemandReceived: 4,
    recentDemandServed: 2,
    recentDemandLost: 2,
    lifetimeDemandReceived: 4,
    lifetimeDemandServed: 2,
    lifetimeDemandLost: 2,
  );

  return initial.copyWith(
    lastResolvedTickAtUtc: DateTime.now().toUtc(),
    resources: _res(200),
    buildings: buildings,
    eventFeed: eventFeed,
  );
}

Future<void> _pumpApp(WidgetTester tester, SimulationState state) async {
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

Future<void> _scrollTo(WidgetTester tester, String sectionTitle) async {
  final finder = find.text(sectionTitle);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.pumpAndSettle();
  expect(finder, findsOneWidget);
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
