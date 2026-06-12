import 'package:adventurer_town/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Demand', () {
    test('targets exactly one matching service building', () {
      final demand = Demand.create(
        id: 'demand_1',
        adventurerId: 'adv_1',
        demandType: DemandType.food,
        createdTick: 1,
        goldValue: 8,
        reputationValue: 1,
      );

      expect(demand.targetBuildingType, BuildingType.tavern);
      expect(demand.status, DemandStatus.pending);
    });

    test('rejects invalid loaded building mapping', () {
      final demand = Demand.fromJson({
        'id': 'demand_1',
        'adventurerId': 'adv_1',
        'demandType': 'food',
        'targetBuildingType': 'inn',
        'createdTick': 1,
        'status': 'pending',
        'goldValue': 8,
        'reputationValue': 1,
        'wasOfflineResolved': false,
      });

      expect(demand, isNull);
    });
  });
}
