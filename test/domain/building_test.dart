import 'package:adventurer_town/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Building', () {
    test('uses the fixed MVP building-to-demand mapping', () {
      expect(demandServedByBuilding(BuildingType.inn), DemandType.rest);
      expect(demandServedByBuilding(BuildingType.tavern), DemandType.food);
      expect(demandServedByBuilding(BuildingType.blacksmith), DemandType.gear);
      expect(demandServedByBuilding(BuildingType.healer), DemandType.healing);
      expect(demandServedByBuilding(BuildingType.market), DemandType.supplies);
    });

    test('clamps upgrade levels to the approved 1 through 10 range', () {
      final tavern = Building.forType(BuildingType.tavern).copyWith(
        capacityLevel: -10,
        valueLevel: 99,
      );

      expect(tavern.capacityLevel, 1);
      expect(tavern.valueLevel, 10);
    });

    test('round-trips through serialization', () {
      final tavern = Building.forType(BuildingType.tavern, isConstructed: true)
          .recordDemandReceived()
          .recordDemandServed(
            goldEarned: 8,
            occupancy: 1,
            eventId: 'event_1',
          );

      final restored = Building.fromJson(tavern.toJson());

      expect(restored?.toJson(), tavern.toJson());
    });

    test('uses approved utilization terminology only', () {
      expect(
        UtilizationState.values.map((state) => state.code),
        ['underused', 'healthy', 'busy', 'overloaded'],
      );
      expect(utilizationStateForRatio(0.20), UtilizationState.underused);
      expect(utilizationStateForRatio(0.70), UtilizationState.healthy);
      expect(utilizationStateForRatio(0.90), UtilizationState.busy);
      expect(utilizationStateForRatio(1), UtilizationState.overloaded);
      expect(
        utilizationStateForRatio(0.10, hasRecentLostDemand: true),
        UtilizationState.overloaded,
      );
    });
  });
}
