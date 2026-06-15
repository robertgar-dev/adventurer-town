import 'package:adventurer_town/src/analytics/analytics_service.dart';

/// A captured analytics call.
class AnalyticsCall {
  const AnalyticsCall(this.name, this.parameters);

  final String name;
  final Map<String, Object?> parameters;
}

/// Test double that records every analytics call for assertions.
class RecordingAnalyticsService implements AnalyticsService {
  final List<AnalyticsCall> calls = <AnalyticsCall>[];

  Iterable<String> get names => calls.map((call) => call.name);

  bool contains(String name) => names.contains(name);

  AnalyticsCall? lastOf(String name) {
    for (final call in calls.reversed) {
      if (call.name == name) {
        return call;
      }
    }
    return null;
  }

  int count(String name) => calls.where((call) => call.name == name).length;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    calls.add(AnalyticsCall(name, parameters));
  }
}

/// Test double whose every call throws, used to prove failure isolation.
class ThrowingAnalyticsService implements AnalyticsService {
  const ThrowingAnalyticsService();

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    throw StateError('analytics is down: $name');
  }
}
