import 'package:adventurer_town/src/analytics/analytics_service.dart';
import 'package:adventurer_town/src/app/simulation_controller.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulationController', () {
    test('loads state and saves after a manual tick', () async {
      final repository = InMemorySimulationRepository();
      final controller = SimulationController(
        repository: repository,
        engine: const SimulationEngine(),
        analyticsService: const NoopAnalyticsService(),
      );

      await controller.loadOrCreate();
      await controller.tickOnce(resolvedAtUtc: DateTime.utc(2026, 6, 9));

      expect(controller.state.simulationState?.currentTick, 1);
      expect(repository.saveCount, greaterThanOrEqualTo(2));
      controller.dispose();
    });

    test('active loop can start and stop', () async {
      final controller = SimulationController(
        repository: InMemorySimulationRepository(),
        engine: const SimulationEngine(),
        analyticsService: const NoopAnalyticsService(),
        activeTickInterval: const Duration(milliseconds: 1),
      );

      await controller.loadOrCreate();
      controller.startActiveLoop();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      controller.stopActiveLoop();

      expect(controller.state.isTicking, isFalse);
      expect(controller.state.simulationState?.currentTick, greaterThan(0));
      controller.dispose();
    });

    test('capacity upgrade spends Gold and increases level by one', () async {
      final repository = InMemorySimulationRepository(
        seedState: _upgradeState(gold: 75),
      );
      final controller = _controller(repository);

      await controller.loadOrCreate();
      final purchased = await controller.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.capacity,
      );

      final state = await repository.loadState();
      expect(purchased, isTrue);
      expect(state.resources.gold, 25);
      expect(state.buildings[BuildingType.tavern]?.capacityLevel, 2);
      expect(state.buildings[BuildingType.tavern]?.valueLevel, 1);
      expect(state.eventFeed.first.eventType, EventType.buildingUpgraded);
      expect(state.eventFeed.first.buildingType, BuildingType.tavern);
      expect(state.eventFeed.first.upgradeAxis, UpgradeAxis.capacity);
      expect(state.eventFeed.first.goldDelta, -50);
      expect(state.eventFeed.first.variables['level'], '2');
      controller.dispose();
    });

    test('value upgrade spends Gold and increases level by one', () async {
      final repository = InMemorySimulationRepository(
        seedState: _upgradeState(gold: 75),
      );
      final controller = _controller(repository);

      await controller.loadOrCreate();
      final purchased = await controller.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.value,
      );

      final state = await repository.loadState();
      expect(purchased, isTrue);
      expect(state.resources.gold, 25);
      expect(state.buildings[BuildingType.tavern]?.capacityLevel, 1);
      expect(state.buildings[BuildingType.tavern]?.valueLevel, 2);
      expect(state.eventFeed.first.eventType, EventType.buildingUpgraded);
      expect(state.eventFeed.first.buildingType, BuildingType.tavern);
      expect(state.eventFeed.first.upgradeAxis, UpgradeAxis.value);
      expect(state.eventFeed.first.goldDelta, -50);
      expect(state.eventFeed.first.variables['level'], '2');
      controller.dispose();
    });

    test('upgrade fails safely when Gold is insufficient', () async {
      final repository = InMemorySimulationRepository(
        seedState: _upgradeState(gold: 49),
      );
      final controller = _controller(repository);

      await controller.loadOrCreate();
      final purchased = await controller.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.capacity,
      );

      final state = await repository.loadState();
      expect(purchased, isFalse);
      expect(controller.state.errorMessage, 'Need 50 Gold.');
      expect(state.resources.gold, 49);
      expect(state.buildings[BuildingType.tavern]?.capacityLevel, 1);
      controller.dispose();
    });

    test('capacity upgrade cannot exceed max level', () async {
      final repository = InMemorySimulationRepository(
        seedState: _upgradeState(
          gold: 20000,
          reputation: 2000,
          capacityLevel: 10,
        ),
      );
      final controller = _controller(repository);

      await controller.loadOrCreate();
      final purchased = await controller.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.capacity,
      );

      final state = await repository.loadState();
      expect(purchased, isFalse);
      expect(state.resources.gold, 20000);
      expect(state.buildings[BuildingType.tavern]?.capacityLevel, 10);
      controller.dispose();
    });

    test('value upgrade cannot exceed max level', () async {
      final repository = InMemorySimulationRepository(
        seedState: _upgradeState(
          gold: 20000,
          reputation: 2000,
          valueLevel: 10,
        ),
      );
      final controller = _controller(repository);

      await controller.loadOrCreate();
      final purchased = await controller.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.value,
      );

      final state = await repository.loadState();
      expect(purchased, isFalse);
      expect(state.resources.gold, 20000);
      expect(state.buildings[BuildingType.tavern]?.valueLevel, 10);
      controller.dispose();
    });

    test('event feed remains bounded after upgrade events', () async {
      const maxEntries = 3;
      final existingEvents = [
        for (var index = 0; index < maxEntries; index += 1)
          _event(id: 'old_$index', tick: index),
      ];
      final repository = InMemorySimulationRepository(
        seedState: _upgradeState(
          gold: 75,
          currentTick: 10,
          eventFeed: existingEvents,
          settings: GameSettings.defaults().copyWith(
            eventFeedMaxEntries: maxEntries,
          ),
        ),
      );
      final controller = _controller(repository);

      await controller.loadOrCreate();
      final purchased = await controller.upgradeBuilding(
        BuildingType.tavern,
        UpgradeAxis.capacity,
      );

      final state = await repository.loadState();
      expect(purchased, isTrue);
      expect(state.eventFeed, hasLength(maxEntries));
      expect(state.eventFeed.first.eventType, EventType.buildingUpgraded);
      expect(state.eventFeed.any((entry) => entry.id == 'old_0'), isFalse);
      controller.dispose();
    });
  });
}

SimulationController _controller(InMemorySimulationRepository repository) {
  return SimulationController(
    repository: repository,
    engine: const SimulationEngine(),
    analyticsService: const NoopAnalyticsService(),
  );
}

SimulationState _upgradeState({
  required int gold,
  int reputation = 0,
  int capacityLevel = 1,
  int valueLevel = 1,
  int currentTick = 0,
  List<EventFeedEntry> eventFeed = const [],
  GameSettings? settings,
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
    resources: Resources(
      gold: gold,
      reputation: reputation,
      lifetimeGoldEarned: gold,
      lifetimeReputationEarned: reputation,
    ),
    buildings: buildings,
    currentTick: currentTick,
    eventFeed: eventFeed,
    settings: settings,
  );
}

EventFeedEntry _event({
  required String id,
  required int tick,
}) {
  return EventFeedEntry(
    id: id,
    eventType: EventType.demandServed,
    createdTick: tick,
    createdAtUtc: DateTime.utc(2026, 6, 9),
    templateId: 'demand_served',
    adventurerId: null,
    adventurerTier: null,
    buildingType: BuildingType.inn,
    demandType: DemandType.rest,
    upgradeAxis: null,
    goldDelta: 5,
    reputationDelta: 1,
    wasOffline: false,
    priority: 1,
    variables: const {},
  );
}
