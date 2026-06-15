/// M10 analytics event names. A small, product-question-driven catalog; the
/// single source of truth for event identifiers so call sites and tests agree.
class AnalyticsEvents {
  const AnalyticsEvents._();

  static const String appStart = 'app_start';
  static const String firstSessionStarted = 'first_session_started';
  static const String sessionEnded = 'session_ended';
  static const String onboardingHintDismissed = 'onboarding_hint_dismissed';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String firstUpgradePurchased = 'first_upgrade_purchased';
  static const String capacityUpgradePurchased = 'capacity_upgrade_purchased';
  static const String valueUpgradePurchased = 'value_upgrade_purchased';
  static const String buildingDetailOpened = 'building_detail_opened';
  static const String eventFeedSeen = 'event_feed_seen';
  static const String offlineReturnSeen = 'offline_return_seen';
}

/// M10 analytics property keys. Properties must be minimal, non-personal,
/// stable, and primitive (string/int). No names, free text, save payloads,
/// feed narrative, or per-entity histories are ever attached.
class AnalyticsProperties {
  const AnalyticsProperties._();

  static const String buildingType = 'building_type';
  static const String upgradeAxis = 'upgrade_axis';
  static const String currentTick = 'current_tick';
  static const String gold = 'gold';
  static const String reputation = 'reputation';
  static const String offlineElapsedSeconds = 'offline_elapsed_seconds';
  static const String demandServed = 'demand_served';
  static const String demandMissed = 'demand_missed';
  static const String hintId = 'hint_id';
  static const String sessionDurationSeconds = 'session_duration_seconds';
  static const String isFirstSession = 'is_first_session';
  static const String wasOffline = 'was_offline';
}
