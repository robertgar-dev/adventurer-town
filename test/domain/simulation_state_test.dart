import 'package:adventurer_town/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulationState', () {
    test('creates a safe default state with approved MVP entities only', () {
      final state = SimulationState.newGame(nowUtc: DateTime.utc(2026, 6, 9));

      expect(ResourceType.values, [ResourceType.gold, ResourceType.reputation]);
      expect(BuildingType.values, [
        BuildingType.inn,
        BuildingType.tavern,
        BuildingType.blacksmith,
        BuildingType.healer,
        BuildingType.market,
      ]);
      expect(DemandType.values, [
        DemandType.rest,
        DemandType.food,
        DemandType.gear,
        DemandType.healing,
        DemandType.supplies,
      ]);
      expect(AdventurerTier.values, [
        AdventurerTier.novice,
        AdventurerTier.veteran,
        AdventurerTier.elite,
        AdventurerTier.legendary,
      ]);
      expect(
          state.tickIntervalSeconds, SimulationState.fixedTickIntervalSeconds);
      expect(state.resources.gold, 0);
      expect(state.resources.reputation, 0);
      expect(state.unlockedTiers, {AdventurerTier.novice});
      expect(state.buildings.length, BuildingType.values.length);
      expect(state.buildings[BuildingType.inn]?.isConstructed, isTrue);
      expect(state.buildings[BuildingType.tavern]?.isConstructed, isTrue);
    });

    test('round-trips through serialization', () {
      final state = SimulationState.newGame(nowUtc: DateTime.utc(2026, 6, 9));
      final restored = SimulationState.fromJson(state.toJson());

      expect(restored.toJson(), state.toJson());
    });

    test('clamps invalid loaded values and preserves required buildings', () {
      final restored = SimulationState.fromJson({
        'tickIntervalSeconds': -9,
        'currentTick': -100,
        'resources': {
          'gold': -10,
          'reputation': -2,
          'lifetimeGoldEarned': -1,
          'lifetimeReputationEarned': -1,
        },
        'buildings': <Object?>[],
        'settings': {'eventFeedMaxEntries': 1000},
      });

      expect(restored.tickIntervalSeconds,
          SimulationState.fixedTickIntervalSeconds);
      expect(restored.currentTick, 0);
      expect(restored.resources.gold, 0);
      expect(restored.resources.reputation, 0);
      expect(restored.buildings.keys.toSet(), BuildingType.values.toSet());
      expect(restored.settings.eventFeedMaxEntries, 100);
    });
  });
}
