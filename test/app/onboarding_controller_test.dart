import 'package:adventurer_town/src/analytics/analytics_service.dart';
import 'package:adventurer_town/src/app/simulation_controller.dart';
import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:adventurer_town/src/simulation/simulation_engine.dart';
import 'package:adventurer_town/src/ui/town/onboarding_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameSettings onboarding flags (WP-M9-01)', () {
    test('default to unseen', () {
      const settings = GameSettings(
        soundEnabled: true,
        musicEnabled: true,
        reducedMotion: false,
        analyticsEnabled: true,
        eventFeedMaxEntries: 100,
        lastSeenOfflineSummaryAtUtc: null,
      );
      expect(settings.welcomeSeen, isFalse);
      expect(settings.resourcesHintSeen, isFalse);
      expect(settings.eventFeedHintSeen, isFalse);
      expect(settings.buildingDetailHintSeen, isFalse);
      expect(settings.offlineHintSeen, isFalse);
    });

    test('round-trip through JSON', () {
      final settings = GameSettings.defaults().copyWith(
        welcomeSeen: true,
        resourcesHintSeen: true,
        eventFeedHintSeen: true,
        buildingDetailHintSeen: true,
        offlineHintSeen: true,
      );
      final restored = GameSettings.fromJson(settings.toJson());

      expect(restored.welcomeSeen, isTrue);
      expect(restored.resourcesHintSeen, isTrue);
      expect(restored.eventFeedHintSeen, isTrue);
      expect(restored.buildingDetailHintSeen, isTrue);
      expect(restored.offlineHintSeen, isTrue);
    });

    test('missing flags decode to unseen (pre-M9 saves)', () {
      final legacy = GameSettings.defaults().toJson()
        ..remove('welcomeSeen')
        ..remove('resourcesHintSeen')
        ..remove('eventFeedHintSeen')
        ..remove('buildingDetailHintSeen')
        ..remove('offlineHintSeen');
      final restored = GameSettings.fromJson(legacy);

      expect(restored.welcomeSeen, isFalse);
      expect(restored.offlineHintSeen, isFalse);
    });
  });

  group('markOnboardingHintSeen (WP-M9-07)', () {
    test('sets the flag, persists it, and is idempotent', () async {
      final repository = InMemorySimulationRepository(
        seedState: SimulationState.newGame(randomSeed: 1001),
      );
      final controller = SimulationController(
        repository: repository,
        engine: const SimulationEngine(),
        analyticsService: const NoopAnalyticsService(),
      );

      await controller.loadOrCreate();
      expect(
        controller.state.simulationState!.settings.welcomeSeen,
        isFalse,
      );

      await controller.markOnboardingHintSeen(OnboardingHint.welcome);
      expect(controller.state.simulationState!.settings.welcomeSeen, isTrue);

      // Persisted to the repository.
      final persisted = await repository.loadState();
      expect(persisted.settings.welcomeSeen, isTrue);

      // Idempotent: a second mark does not write again.
      final savesAfterFirst = repository.saveCount;
      await controller.markOnboardingHintSeen(OnboardingHint.welcome);
      expect(repository.saveCount, savesAfterFirst);

      controller.dispose();
    });

    test('marking one hint leaves the others unseen', () async {
      final repository = InMemorySimulationRepository(
        seedState: SimulationState.newGame(randomSeed: 1001),
      );
      final controller = SimulationController(
        repository: repository,
        engine: const SimulationEngine(),
        analyticsService: const NoopAnalyticsService(),
      );

      await controller.loadOrCreate();
      await controller.markOnboardingHintSeen(OnboardingHint.resources);

      final settings = controller.state.simulationState!.settings;
      expect(settings.resourcesHintSeen, isTrue);
      expect(settings.welcomeSeen, isFalse);
      expect(settings.eventFeedHintSeen, isFalse);

      controller.dispose();
    });
  });

  group('onboarding copy guardrails (WP-M9-03/09)', () {
    const banned = <String>[
      'queue',
      'refund',
      'recover',
      'reservation',
      'quest',
      'combat',
      'inventory',
      'craft',
      'faction',
      'staff',
      'spend reputation',
      'buy reputation',
      'command',
      'control them',
      'assign',
    ];

    test('every hint string is clean, concise, and on-message', () {
      for (final copy in onboardingHintCopy.values) {
        final text = '${copy.title} ${copy.body}'.toLowerCase();
        for (final word in banned) {
          expect(text.contains(word), isFalse,
              reason: 'onboarding copy must not contain "$word": $text');
        }
        expect(copy.body.length, lessThanOrEqualTo(220));
      }
    });

    test('Reputation is framed as earned, never-spent trust', () {
      final resources = onboardingHintCopy[OnboardingHint.resources]!;
      final text = '${resources.title} ${resources.body}'.toLowerCase();
      expect(text, contains('trust'));
      expect(text, contains('never spent'));
      expect(text.contains('currency'), isFalse);
    });

    test('offline copy reinforces Gold-only / no offline Reputation', () {
      final offline = onboardingHintCopy[OnboardingHint.offline]!;
      expect(offline.body, contains('Gold'));
      expect(offline.body.toLowerCase(), contains('reputation'));
      expect(offline.body.toLowerCase(), contains('watching'));
    });
  });
}
