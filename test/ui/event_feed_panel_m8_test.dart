import 'package:adventurer_town/src/app/town_view_models.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/ui/town/event_feed_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// M8 Event Feed — offline-context labelling (WP-M8-08) and Reputation-as-trust
/// delta framing (WP-M8-07) in the shared EventFeedPanel.
void main() {
  Future<void> pump(WidgetTester tester, List<EventFeedItemViewModel> entries,
      {bool showResourceDeltas = true}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventFeedPanel(
            title: 'Recent Activity',
            entries: entries,
            emptyMessage: 'No recent activity.',
            showResourceDeltas: showResourceDeltas,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('active service spreads trust (word-of-mouth), not a number',
      (tester) async {
    await pump(tester, [_served(offline: false, rep: 1)]);

    expect(find.textContaining('word spread'), findsOneWidget);
    expect(find.text('+5 Gold · word spread'), findsOneWidget);
    // Reputation is never presented as a spendable number.
    expect(find.textContaining('Reputation'), findsNothing);
    expect(find.textContaining('While away'), findsNothing);
  });

  testWidgets('offline rows are labelled and earn no trust', (tester) async {
    await pump(tester, [_served(offline: true, rep: 0)]);

    expect(find.text('While away'), findsOneWidget);
    expect(find.text('+5 Gold'), findsOneWidget); // Gold only.
    expect(find.textContaining('word spread'), findsNothing); // no offline rep.
  });

  testWidgets('mixed feed distinguishes active trust from offline context',
      (tester) async {
    await pump(tester, [
      _served(offline: false, rep: 1),
      _served(offline: true, rep: 0),
    ]);

    expect(find.text('While away'), findsOneWidget); // only the offline row.
    expect(find.textContaining('word spread'), findsOneWidget); // only active.
  });
}

EventFeedItemViewModel _served({required bool offline, required int rep}) {
  return EventFeedItemViewModel(
    id: 'served_${offline}_$rep',
    eventType: EventType.demandServed,
    createdTick: 9,
    description: 'The Tavern served hot meals to hungry adventurers.',
    buildingType: BuildingType.tavern,
    demandType: DemandType.food,
    upgradeAxis: null,
    goldDelta: 5,
    reputationDelta: rep,
    isOffline: offline,
    priority: 1,
  );
}
