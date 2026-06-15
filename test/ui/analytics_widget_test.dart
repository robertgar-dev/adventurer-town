import 'package:adventurer_town/src/analytics/analytics_events.dart';
import 'package:adventurer_town/src/app/adventurer_town_app.dart';
import 'package:adventurer_town/src/app/app_providers.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/recording_analytics_service.dart';

void main() {
  testWidgets('opening a building emits building_detail_opened',
      (tester) async {
    final analytics = RecordingAnalyticsService();
    await _pump(tester, analytics, _onboarded());

    final tavern = find.text('Tavern');
    await tester.scrollUntilVisible(tavern, 240,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(tavern.first);
    await tester.pumpAndSettle();

    final call = analytics.lastOf(AnalyticsEvents.buildingDetailOpened);
    expect(call, isNotNull);
    expect(call!.parameters[AnalyticsProperties.buildingType], 'tavern');
  });

  testWidgets('a populated feed emits event_feed_seen once', (tester) async {
    final analytics = RecordingAnalyticsService();
    await _pump(
      tester,
      analytics,
      _onboarded().copyWith(eventFeed: [_served()]),
    );

    expect(analytics.contains(AnalyticsEvents.eventFeedSeen), isTrue);
    expect(analytics.count(AnalyticsEvents.eventFeedSeen), 1);
  });

  testWidgets('backgrounding emits session_ended with a duration',
      (tester) async {
    final analytics = RecordingAnalyticsService();
    await _pump(tester, analytics, _onboarded());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    final call = analytics.lastOf(AnalyticsEvents.sessionEnded);
    expect(call, isNotNull);
    expect(
      call!.parameters[AnalyticsProperties.sessionDurationSeconds],
      isA<int>(),
    );
  });
}

Future<void> _pump(
  WidgetTester tester,
  RecordingAnalyticsService analytics,
  SimulationState seed,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        simulationRepositoryProvider.overrideWithValue(
          InMemorySimulationRepository(seedState: seed),
        ),
        analyticsServiceProvider.overrideWithValue(analytics),
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

SimulationState _onboarded() {
  final base =
      SimulationState.newGame(nowUtc: DateTime.now().toUtc(), randomSeed: 1001);
  return base.copyWith(
    settings: base.settings.copyWith(
      welcomeSeen: true,
      resourcesHintSeen: true,
      eventFeedHintSeen: true,
      buildingDetailHintSeen: true,
      offlineHintSeen: true,
      firstSessionStarted: true,
    ),
  );
}

EventFeedEntry _served() {
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
