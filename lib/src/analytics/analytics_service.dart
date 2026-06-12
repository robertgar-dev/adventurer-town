import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsService {
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  });
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {}
}

class SafeAnalyticsService implements AnalyticsService {
  const SafeAnalyticsService(this._delegate);

  final AnalyticsService _delegate;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    try {
      await _delegate.logEvent(name, parameters: parameters);
    } catch (_) {
      // Analytics must never block launch, simulation, persistence, or UI.
    }
  }
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters.map(
        (key, value) => MapEntry(key, _primitive(value)),
      ),
    );
  }

  Object _primitive(Object? value) {
    if (value is String) {
      return value;
    }
    if (value is num) {
      return value;
    }
    if (value is bool) {
      return value;
    }
    return value?.toString() ?? '';
  }
}
