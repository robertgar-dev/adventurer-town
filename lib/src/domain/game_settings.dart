class GameSettings {
  const GameSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.reducedMotion,
    required this.analyticsEnabled,
    required this.eventFeedMaxEntries,
    required this.lastSeenOfflineSummaryAtUtc,
    this.welcomeSeen = false,
    this.resourcesHintSeen = false,
    this.eventFeedHintSeen = false,
    this.buildingDetailHintSeen = false,
    this.offlineHintSeen = false,
    this.firstSessionStarted = false,
    this.firstUpgradePurchased = false,
    this.onboardingCompleted = false,
  });

  factory GameSettings.defaults() {
    return const GameSettings(
      soundEnabled: true,
      musicEnabled: true,
      reducedMotion: false,
      analyticsEnabled: true,
      eventFeedMaxEntries: 100,
      lastSeenOfflineSummaryAtUtc: null,
    );
  }

  factory GameSettings.fromJson(Map<String, Object?> json) {
    return GameSettings(
      soundEnabled: json['soundEnabled'] != false,
      musicEnabled: json['musicEnabled'] != false,
      reducedMotion: json['reducedMotion'] == true,
      analyticsEnabled: json['analyticsEnabled'] != false,
      eventFeedMaxEntries: _maxEntries(json['eventFeedMaxEntries']),
      lastSeenOfflineSummaryAtUtc: _nullableDateTime(
        json['lastSeenOfflineSummaryAtUtc'],
      ),
      // M9 onboarding "seen" flags default false so a player who has never
      // seen a hint (or a save from before M9) gets the onboarding once.
      welcomeSeen: json['welcomeSeen'] == true,
      resourcesHintSeen: json['resourcesHintSeen'] == true,
      eventFeedHintSeen: json['eventFeedHintSeen'] == true,
      buildingDetailHintSeen: json['buildingDetailHintSeen'] == true,
      offlineHintSeen: json['offlineHintSeen'] == true,
      // M10 emit-once analytics flags; default false, missing-key safe.
      firstSessionStarted: json['firstSessionStarted'] == true,
      firstUpgradePurchased: json['firstUpgradePurchased'] == true,
      onboardingCompleted: json['onboardingCompleted'] == true,
    );
  }

  final bool soundEnabled;
  final bool musicEnabled;
  final bool reducedMotion;
  final bool analyticsEnabled;
  final int eventFeedMaxEntries;
  final DateTime? lastSeenOfflineSummaryAtUtc;

  // M9 onboarding display state (presentation only; not simulation/economy).
  final bool welcomeSeen;
  final bool resourcesHintSeen;
  final bool eventFeedHintSeen;
  final bool buildingDetailHintSeen;
  final bool offlineHintSeen;

  // M10 analytics emit-once flags (non-economy meta state).
  final bool firstSessionStarted;
  final bool firstUpgradePurchased;
  final bool onboardingCompleted;

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? reducedMotion,
    bool? analyticsEnabled,
    int? eventFeedMaxEntries,
    DateTime? lastSeenOfflineSummaryAtUtc,
    bool? welcomeSeen,
    bool? resourcesHintSeen,
    bool? eventFeedHintSeen,
    bool? buildingDetailHintSeen,
    bool? offlineHintSeen,
    bool? firstSessionStarted,
    bool? firstUpgradePurchased,
    bool? onboardingCompleted,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      eventFeedMaxEntries: _clampMaxEntries(
        eventFeedMaxEntries ?? this.eventFeedMaxEntries,
      ),
      lastSeenOfflineSummaryAtUtc:
          lastSeenOfflineSummaryAtUtc ?? this.lastSeenOfflineSummaryAtUtc,
      welcomeSeen: welcomeSeen ?? this.welcomeSeen,
      resourcesHintSeen: resourcesHintSeen ?? this.resourcesHintSeen,
      eventFeedHintSeen: eventFeedHintSeen ?? this.eventFeedHintSeen,
      buildingDetailHintSeen:
          buildingDetailHintSeen ?? this.buildingDetailHintSeen,
      offlineHintSeen: offlineHintSeen ?? this.offlineHintSeen,
      firstSessionStarted: firstSessionStarted ?? this.firstSessionStarted,
      firstUpgradePurchased:
          firstUpgradePurchased ?? this.firstUpgradePurchased,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'reducedMotion': reducedMotion,
      'analyticsEnabled': analyticsEnabled,
      'eventFeedMaxEntries': eventFeedMaxEntries,
      'lastSeenOfflineSummaryAtUtc':
          lastSeenOfflineSummaryAtUtc?.toUtc().toIso8601String(),
      'welcomeSeen': welcomeSeen,
      'resourcesHintSeen': resourcesHintSeen,
      'eventFeedHintSeen': eventFeedHintSeen,
      'buildingDetailHintSeen': buildingDetailHintSeen,
      'offlineHintSeen': offlineHintSeen,
      'firstSessionStarted': firstSessionStarted,
      'firstUpgradePurchased': firstUpgradePurchased,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  static int _maxEntries(Object? value) {
    if (value is int) {
      return _clampMaxEntries(value);
    }
    if (value is num) {
      return _clampMaxEntries(value.floor());
    }
    return 100;
  }

  static int _clampMaxEntries(int value) {
    if (value < 1) {
      return 1;
    }
    if (value > 100) {
      return 100;
    }
    return value;
  }

  static DateTime? _nullableDateTime(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
