import 'dart:math';

class Resources {
  const Resources({
    required this.gold,
    required this.reputation,
    required this.lifetimeGoldEarned,
    required this.lifetimeReputationEarned,
  });

  factory Resources.initial() {
    return const Resources(
      gold: 0,
      reputation: 0,
      lifetimeGoldEarned: 0,
      lifetimeReputationEarned: 0,
    );
  }

  factory Resources.fromJson(Map<String, Object?> json) {
    final gold = _nonNegativeInt(json['gold']);
    final reputation = _nonNegativeInt(json['reputation']);

    return Resources(
      gold: gold,
      reputation: reputation,
      lifetimeGoldEarned: max(
        gold,
        _nonNegativeInt(json['lifetimeGoldEarned']),
      ),
      lifetimeReputationEarned: max(
        reputation,
        _nonNegativeInt(json['lifetimeReputationEarned']),
      ),
    );
  }

  final int gold;
  final int reputation;
  final int lifetimeGoldEarned;
  final int lifetimeReputationEarned;

  Resources addGold(int amount) {
    if (amount <= 0) {
      return this;
    }

    return copyWith(
      gold: gold + amount,
      lifetimeGoldEarned: lifetimeGoldEarned + amount,
    );
  }

  bool canSpendGold(int amount) {
    return amount >= 0 && gold >= amount;
  }

  Resources spendGold(int amount) {
    if (amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Gold spend cannot be negative.');
    }
    if (!canSpendGold(amount)) {
      throw StateError('Insufficient Gold.');
    }

    return copyWith(gold: gold - amount);
  }

  Resources addReputation(int amount) {
    if (amount <= 0) {
      return this;
    }

    return copyWith(
      reputation: reputation + amount,
      lifetimeReputationEarned: lifetimeReputationEarned + amount,
    );
  }

  Resources copyWith({
    int? gold,
    int? reputation,
    int? lifetimeGoldEarned,
    int? lifetimeReputationEarned,
  }) {
    return Resources(
      gold: _clamp(gold ?? this.gold),
      reputation: _clamp(reputation ?? this.reputation),
      lifetimeGoldEarned: _clamp(lifetimeGoldEarned ?? this.lifetimeGoldEarned),
      lifetimeReputationEarned: _clamp(
        lifetimeReputationEarned ?? this.lifetimeReputationEarned,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'gold': gold,
      'reputation': reputation,
      'lifetimeGoldEarned': lifetimeGoldEarned,
      'lifetimeReputationEarned': lifetimeReputationEarned,
    };
  }

  static int _nonNegativeInt(Object? value) {
    if (value is int) {
      return _clamp(value);
    }
    if (value is num) {
      return _clamp(value.floor());
    }
    return 0;
  }

  static int _clamp(int value) {
    return value < 0 ? 0 : value;
  }
}
