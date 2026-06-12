class GameSettings {
  const GameSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.reducedMotion,
    required this.analyticsEnabled,
    required this.eventFeedMaxEntries,
    required this.lastSeenOfflineSummaryAtUtc,
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
    );
  }

  final bool soundEnabled;
  final bool musicEnabled;
  final bool reducedMotion;
  final bool analyticsEnabled;
  final int eventFeedMaxEntries;
  final DateTime? lastSeenOfflineSummaryAtUtc;

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? reducedMotion,
    bool? analyticsEnabled,
    int? eventFeedMaxEntries,
    DateTime? lastSeenOfflineSummaryAtUtc,
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
