import 'dart:io';

import 'package:adventurer_town/src/analytics/analytics_service.dart';
import 'package:adventurer_town/src/app/simulation_controller.dart';
import 'package:adventurer_town/src/app/town_view_models.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:adventurer_town/src/simulation/simulation_report.dart';
import 'package:flutter_test/flutter_test.dart';

/// M4 Core Economy Loop acceptance suite.
///
/// Validates the end-to-end idle-management loop: accumulate Gold, view
/// available upgrades, purchase Capacity/Value upgrades, persist the result,
/// reload (app restart), and observe deterministic economic improvement.
void main() {
  group('M4 upgrade persistence and reload', () {
    late Directory directory;
    late File file;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('m4_loop_');
      file = File('${directory.path}${Platform.pathSeparator}state.json');
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    // A fresh repository instance pointed at the same file models an app
    // restart: nothing is shared in memory, the state must come from disk.
    FileSimulationRepository repositoryForFile() {
      return FileSimulationRepository(() async => file);
    }

    SimulationController controllerFor(SimulationRepository repository) {
      return SimulationController(
        repository: repository,
        engine: const SimulationEngine(),
        analyticsService: const NoopAnalyticsService(),
      );
    }

    test('capacity purchase persists and survives an app restart', () async {
      await repositoryForFile().saveState(_seedState(gold: 75));

      final session = controllerFor(repositoryForFile());
      await session.loadOrCreate();
      final purchased = await session.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.capacity,
      );
      session.dispose();
      expect(purchased, isTrue);

      // Restart: brand-new repository + controller reading from disk.
      final reloaded = controllerFor(repositoryForFile());
      await reloaded.loadOrCreate();
      final tavern =
          reloaded.state.simulationState!.buildings[BuildingType.tavern]!;
      expect(tavern.capacityLevel, 2);
      expect(tavern.valueLevel, 1);
      expect(reloaded.state.simulationState!.resources.gold, 25);
      reloaded.dispose();
    });

    test('value purchase persists and survives an app restart', () async {
      await repositoryForFile().saveState(_seedState(gold: 75));

      final session = controllerFor(repositoryForFile());
      await session.loadOrCreate();
      final purchased = await session.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.value,
      );
      session.dispose();
      expect(purchased, isTrue);

      final reloaded = controllerFor(repositoryForFile());
      await reloaded.loadOrCreate();
      final tavern =
          reloaded.state.simulationState!.buildings[BuildingType.tavern]!;
      expect(tavern.valueLevel, 2);
      expect(tavern.capacityLevel, 1);
      expect(reloaded.state.simulationState!.resources.gold, 25);
      reloaded.dispose();
    });

    test('stacked upgrades across two sessions accumulate on reload', () async {
      await repositoryForFile().saveState(_seedState(gold: 250));

      final first = controllerFor(repositoryForFile());
      await first.loadOrCreate();
      expect(
        await first.upgradeBuilding(BuildingType.tavern, UpgradeAxis.capacity),
        isTrue,
      ); // -> capacity 2, cost 50, gold 200
      first.dispose();

      final second = controllerFor(repositoryForFile());
      await second.loadOrCreate();
      expect(
        await second.upgradeBuilding(BuildingType.tavern, UpgradeAxis.capacity),
        isTrue,
      ); // -> capacity 3, cost 100, gold 100
      expect(
        await second.upgradeBuilding(BuildingType.tavern, UpgradeAxis.value),
        isTrue,
      ); // -> value 2, cost 50, gold 50
      second.dispose();

      final reloaded = controllerFor(repositoryForFile());
      await reloaded.loadOrCreate();
      final tavern =
          reloaded.state.simulationState!.buildings[BuildingType.tavern]!;
      expect(tavern.capacityLevel, 3);
      expect(tavern.valueLevel, 2);
      expect(reloaded.state.simulationState!.resources.gold, 50);
      reloaded.dispose();
    });

    test('insufficient Gold leaves no persisted progression after reload',
        () async {
      await repositoryForFile().saveState(_seedState(gold: 49));

      final session = controllerFor(repositoryForFile());
      await session.loadOrCreate();
      final purchased = await session.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.capacity,
      );
      expect(purchased, isFalse);
      session.dispose();

      final reloaded = controllerFor(repositoryForFile());
      await reloaded.loadOrCreate();
      final tavern =
          reloaded.state.simulationState!.buildings[BuildingType.tavern]!;
      expect(tavern.capacityLevel, 1);
      expect(reloaded.state.simulationState!.resources.gold, 49);
      reloaded.dispose();
    });

    test('max-level upgrade is rejected and persists unchanged', () async {
      await repositoryForFile().saveState(
        _seedState(gold: 20000, reputation: 2000, capacityLevel: 10),
      );

      final session = controllerFor(repositoryForFile());
      await session.loadOrCreate();
      final purchased = await session.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.capacity,
      );
      expect(purchased, isFalse);
      session.dispose();

      final reloaded = controllerFor(repositoryForFile());
      await reloaded.loadOrCreate();
      final tavern =
          reloaded.state.simulationState!.buildings[BuildingType.tavern]!;
      expect(tavern.capacityLevel, 10);
      expect(reloaded.state.simulationState!.resources.gold, 20000);
      reloaded.dispose();
    });
  });

  group('M4 upgrade affordability visibility', () {
    test('affordable upgrades expose cost and purchasability', () {
      final detail = buildingDetailViewModelFor(
        building: _tavern(capacityLevel: 1, valueLevel: 1),
        resources: _resources(gold: 75),
      );

      expect(detail.capacityLevel, 1);
      expect(detail.valueLevel, 1);
      expect(detail.capacityUpgrade.costLabel, 'Next Cost 50 Gold');
      expect(detail.capacityUpgrade.canPurchase, isTrue);
      expect(detail.capacityUpgrade.statusLabel, 'Available');
      expect(detail.valueUpgrade.canPurchase, isTrue);
    });

    test('unaffordable upgrades report the Gold shortfall and disable purchase',
        () {
      final detail = buildingDetailViewModelFor(
        building: _tavern(capacityLevel: 1, valueLevel: 1),
        resources: _resources(gold: 0),
      );

      expect(detail.capacityUpgrade.costLabel, 'Next Cost 50 Gold');
      expect(detail.capacityUpgrade.canPurchase, isFalse);
      expect(detail.capacityUpgrade.statusLabel, 'Need 50 Gold');
      expect(detail.valueUpgrade.canPurchase, isFalse);
    });

    test('max-level upgrades report Max Level and disable purchase', () {
      final detail = buildingDetailViewModelFor(
        building: _tavern(capacityLevel: 10, valueLevel: 10),
        resources: _resources(gold: 50000, reputation: 5000),
      );

      expect(detail.capacityUpgrade.isMaxLevel, isTrue);
      expect(detail.capacityUpgrade.costLabel, 'Max Level');
      expect(detail.capacityUpgrade.canPurchase, isFalse);
      expect(detail.valueUpgrade.isMaxLevel, isTrue);
      expect(detail.valueUpgrade.canPurchase, isFalse);
    });
  });

  group('M4 deterministic economic improvement', () {
    final start = DateTime.utc(2026, 6, 9);

    test('Capacity upgrades improve served demand (throughput)', () {
      final baseline = SimulationRunReport.fromState(
        _runTavern(start: start, capacityLevel: 1, valueLevel: 1),
      );
      final upgraded = SimulationRunReport.fromState(
        _runTavern(start: start, capacityLevel: 2, valueLevel: 1),
      );

      // Demand generation is independent of upgrades (same seed, same ticks).
      expect(upgraded.demandGenerated, baseline.demandGenerated);
      expect(
        upgraded.demandGeneratedByType[DemandType.food],
        baseline.demandGeneratedByType[DemandType.food],
      );

      // Higher capacity serves strictly more demand and loses strictly less.
      expect(
        upgraded.demandServedByType[DemandType.food]!,
        greaterThan(baseline.demandServedByType[DemandType.food]!),
      );
      expect(upgraded.demandServed, greaterThan(baseline.demandServed));
      expect(
        upgraded.demandLostByType[DemandType.food]!,
        lessThan(baseline.demandLostByType[DemandType.food]!),
      );

      // Determinism: the same configuration replays to identical results.
      final replay = SimulationRunReport.fromState(
        _runTavern(start: start, capacityLevel: 2, valueLevel: 1),
      );
      expect(replay.demandServed, upgraded.demandServed);
      expect(replay.goldEarned, upgraded.goldEarned);
    });

    test('Value upgrades improve reward efficiency (Gold per service)', () {
      final baseline = SimulationRunReport.fromState(
        _runTavern(start: start, capacityLevel: 2, valueLevel: 1),
      );
      final upgraded = SimulationRunReport.fromState(
        _runTavern(start: start, capacityLevel: 2, valueLevel: 2),
      );

      // Value upgrades do not change throughput: identical served counts.
      expect(upgraded.demandGenerated, baseline.demandGenerated);
      expect(upgraded.demandServed, baseline.demandServed);

      // But each service is worth more Gold.
      expect(upgraded.goldEarned, greaterThan(baseline.goldEarned));
      expect(upgraded.goldPerService, greaterThan(baseline.goldPerService));

      // Determinism check.
      final replay = SimulationRunReport.fromState(
        _runTavern(start: start, capacityLevel: 2, valueLevel: 2),
      );
      expect(replay.goldEarned, upgraded.goldEarned);
      expect(replay.demandServed, upgraded.demandServed);
    });
  });
}

SimulationState _runTavern({
  required DateTime start,
  required int capacityLevel,
  required int valueLevel,
}) {
  final initial = SimulationState.newGame(nowUtc: start, randomSeed: 1001);
  final buildings = Map<BuildingType, Building>.from(initial.buildings);
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    isConstructed: true,
    capacityLevel: capacityLevel,
    valueLevel: valueLevel,
  );

  return const SimulationEngine()
      .runTicks(
        initial.copyWith(
          buildings: buildings,
          unlockedTiers: const {AdventurerTier.novice},
        ),
        count: 100,
        firstResolvedAtUtc: start,
      )
      .state;
}

Building _tavern({required int capacityLevel, required int valueLevel}) {
  return Building.forType(BuildingType.tavern, isConstructed: true).copyWith(
    capacityLevel: capacityLevel,
    valueLevel: valueLevel,
  );
}

Resources _resources({required int gold, int reputation = 0}) {
  return Resources(
    gold: gold,
    reputation: reputation,
    lifetimeGoldEarned: gold,
    lifetimeReputationEarned: reputation,
  );
}

SimulationState _seedState({
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
    resources: _resources(gold: gold, reputation: reputation),
    buildings: buildings,
  );
}
