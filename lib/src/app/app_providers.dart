import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../persistence/persistence.dart';
import '../simulation/simulation_engine.dart';
import 'simulation_controller.dart';

final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  return createFlutterFileSimulationRepository();
});

final simulationEngineProvider = Provider<SimulationEngine>((ref) {
  return const SimulationEngine();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return const SafeAnalyticsService(NoopAnalyticsService());
});

final simulationControllerProvider =
    StateNotifierProvider<SimulationController, SimulationControllerState>(
        (ref) {
  return SimulationController(
    repository: ref.watch(simulationRepositoryProvider),
    engine: ref.watch(simulationEngineProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
  );
});
