import 'package:adventurer_town/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Resources', () {
    test('adds and spends Gold without allowing negative balances', () {
      final resources = Resources.initial().addGold(25);

      expect(resources.gold, 25);
      expect(resources.lifetimeGoldEarned, 25);
      expect(resources.spendGold(10).gold, 15);
      expect(() => resources.spendGold(26), throwsStateError);
    });

    test('adds Reputation without exposing a spend operation', () {
      final resources = Resources.initial().addReputation(4);

      expect(resources.reputation, 4);
      expect(resources.lifetimeReputationEarned, 4);
    });

    test('clamps invalid loaded resource values', () {
      final resources = Resources.fromJson({
        'gold': -1,
        'reputation': -1,
        'lifetimeGoldEarned': -5,
        'lifetimeReputationEarned': -5,
      });

      expect(resources.gold, 0);
      expect(resources.reputation, 0);
      expect(resources.lifetimeGoldEarned, 0);
      expect(resources.lifetimeReputationEarned, 0);
    });
  });
}
