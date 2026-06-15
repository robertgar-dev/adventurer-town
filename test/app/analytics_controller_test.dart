import 'package:adventurer_town/src/analytics/analytics_events.dart';
import 'package:adventurer_town/src/analytics/analytics_service.dart';
import 'package:adventurer_town/src/app/simulation_controller.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/recording_analytics_service.dart';

void main() {
  SimulationController controllerFor(
    AnalyticsService analytics,
    InMemorySimulationRepository repository,
  ) {
    return SimulationController(
      repository: repository,
      engine: const SimulationEngine(),
      analyticsService: analytics,
    );
  }

  group('app / session events', () {
    test('app_start and first_session_started fire once on a fresh save',
        () async {
      final analytics = RecordingAnalyticsService();
      final repository = InMemorySimulationRepository(seedState: _fresh());
      final controller = controllerFor(analytics, repository);

      await controller.loadOrCreate();

      expect(analytics.contains(AnalyticsEvents.appStart), isTrue);
      expect(
        analytics.lastOf(AnalyticsEvents.appStart)!
            .parameters[AnalyticsProperties.isFirstSession],
        1,
      );
      expect(analytics.count(AnalyticsEvents.firstSessionStarted), 1);
      expect(repository.loadState().then((s) => s.settings.firstSessionStarted),
          completion(isTrue));
      controller.dispose();
    });

    test('a returning session is not flagged as first', () async {
      final repository = InMemorySimulationRepository(seedState: _fresh());
      final first = controllerFor(RecordingAnalyticsService(), repository);
      await first.loadOrCreate();
      first.dispose();

      final analytics = RecordingAnalyticsService();
      final second = controllerFor(analytics, repository);
      await second.loadOrCreate();

      expect(
        analytics.lastOf(AnalyticsEvents.appStart)!
            .parameters[AnalyticsProperties.isFirstSession],
        0,
      );
      expect(analytics.contains(AnalyticsEvents.firstSessionStarted), isFalse);
      second.dispose();
    });

    test('offline_return_seen carries summary properties', () async {
      final last = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
      final analytics = RecordingAnalyticsService();
      final repository = InMemorySimulationRepository(
        seedState: _fresh().copyWith(lastResolvedTickAtUtc: last),
      );
      final controller = controllerFor(analytics, repository);

      await controller.loadOrCreate();

      final call = analytics.lastOf(AnalyticsEvents.offlineReturnSeen);
      expect(call, isNotNull);
      expect(call!.parameters[AnalyticsProperties.offlineElapsedSeconds],
          isNonZero);
      expect(call.parameters.containsKey(AnalyticsProperties.demandServed),
          isTrue);
      expect(call.parameters.containsKey(AnalyticsProperties.demandMissed),
          isTrue);
      controller.dispose();
    });
  });

  group('upgrade events', () {
    test('capacity + first_upgrade fire once; value is distinct', () async {
      final analytics = RecordingAnalyticsService();
      final repository = InMemorySimulationRepository(seedState: _withGold(300));
      final controller = controllerFor(analytics, repository);
      await controller.loadOrCreate();

      expect(
        await controller.upgradeBuilding(
            BuildingType.tavern, UpgradeAxis.capacity),
        isTrue,
      );
      expect(analytics.count(AnalyticsEvents.capacityUpgradePurchased), 1);
      expect(analytics.count(AnalyticsEvents.firstUpgradePurchased), 1);
      expect(
        analytics.lastOf(AnalyticsEvents.capacityUpgradePurchased)!
            .parameters[AnalyticsProperties.upgradeAxis],
        'capacity',
      );

      expect(
        await controller.upgradeBuilding(BuildingType.tavern, UpgradeAxis.value),
        isTrue,
      );
      expect(analytics.count(AnalyticsEvents.valueUpgradePurchased), 1);
      // first_upgrade only ever fires once.
      expect(analytics.count(AnalyticsEvents.firstUpgradePurchased), 1);
      controller.dispose();
    });
  });

  group('onboarding events', () {
    test('hint dismissals emit, and completion fires once after four hints',
        () async {
      final analytics = RecordingAnalyticsService();
      final repository = InMemorySimulationRepository(seedState: _fresh());
      final controller = controllerFor(analytics, repository);
      await controller.loadOrCreate();

      await controller.markOnboardingHintSeen(OnboardingHint.welcome);
      await controller.markOnboardingHintSeen(OnboardingHint.resources);
      await controller.markOnboardingHintSeen(OnboardingHint.eventFeed);
      expect(analytics.contains(AnalyticsEvents.onboardingCompleted), isFalse);

      await controller.markOnboardingHintSeen(OnboardingHint.buildingDetail);

      expect(analytics.count(AnalyticsEvents.onboardingHintDismissed), 4);
      expect(analytics.count(AnalyticsEvents.onboardingCompleted), 1);
      expect(
        analytics.lastOf(AnalyticsEvents.onboardingHintDismissed)!
            .parameters[AnalyticsProperties.hintId],
        'buildingDetail',
      );
      controller.dispose();
    });
  });

  group('ui-signalled events', () {
    test('building_detail_opened carries the building type', () async {
      final analytics = RecordingAnalyticsService();
      final repository = InMemorySimulationRepository(seedState: _fresh());
      final controller = controllerFor(analytics, repository);
      await controller.loadOrCreate();

      controller.logBuildingDetailOpened(BuildingType.blacksmith);

      expect(
        analytics.lastOf(AnalyticsEvents.buildingDetailOpened)!
            .parameters[AnalyticsProperties.buildingType],
        'blacksmith',
      );
      controller.dispose();
    });

    test('event_feed_seen fires at most once per session', () async {
      final analytics = RecordingAnalyticsService();
      final repository = InMemorySimulationRepository(
        seedState: _fresh().copyWith(eventFeed: [_servedEvent()]),
      );
      final controller = controllerFor(analytics, repository);
      await controller.loadOrCreate();

      controller.notifyEventFeedSeen();
      controller.notifyEventFeedSeen();

      expect(analytics.count(AnalyticsEvents.eventFeedSeen), 1);
      controller.dispose();
    });

    test('event_feed_seen does not fire while the feed is empty', () async {
      final analytics = RecordingAnalyticsService();
      final repository = InMemorySimulationRepository(seedState: _fresh());
      final controller = controllerFor(analytics, repository);
      await controller.loadOrCreate();

      controller.notifyEventFeedSeen();

      expect(analytics.contains(AnalyticsEvents.eventFeedSeen), isFalse);
      controller.dispose();
    });
  });

  group('safety: analytics never affects gameplay', () {
    for (final entry in <String, AnalyticsService>{
      'noop': const NoopAnalyticsService(),
      'safe-wrapped throwing':
          const SafeAnalyticsService(ThrowingAnalyticsService()),
      'raw throwing': ThrowingAnalyticsService(),
    }.entries) {
      test('gameplay succeeds with ${entry.key} analytics', () async {
        final repository = InMemorySimulationRepository(seedState: _withGold(300));
        final controller = controllerFor(entry.value, repository);

        await controller.loadOrCreate();
        expect(controller.state.simulationState, isNotNull);

        final purchased = await controller.upgradeBuilding(
          BuildingType.tavern,
          UpgradeAxis.capacity,
        );
        expect(purchased, isTrue);
        expect(controller.state.simulationState!.resources.gold, 250);

        await controller.markOnboardingHintSeen(OnboardingHint.welcome);
        expect(controller.state.simulationState!.settings.welcomeSeen, isTrue);

        // No analytics failure surfaced as an error.
        expect(controller.state.errorMessage, isNull);
        controller.dispose();
      });
    }
  });
}

SimulationState _fresh() {
  return SimulationState.newGame(nowUtc: DateTime.now().toUtc(), randomSeed: 1001);
}

SimulationState _withGold(int gold) {
  final base = _fresh();
  final buildings = Map<BuildingType, Building>.from(base.buildings);
  buildings[BuildingType.tavern] = buildings[BuildingType.tavern]!.copyWith(
    isConstructed: true,
    capacityLevel: 1,
    valueLevel: 1,
  );
  return base.copyWith(
    resources: Resources(
      gold: gold,
      reputation: 0,
      lifetimeGoldEarned: gold,
      lifetimeReputationEarned: 0,
    ),
    buildings: buildings,
  );
}

EventFeedEntry _servedEvent() {
  return EventFeedEntry(
    id: 'served_1',
    eventType: EventType.demandServed,
    createdTick: 1,
    createdAtUtc: DateTime.utc(2026, 6, 14),
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
  );
}
