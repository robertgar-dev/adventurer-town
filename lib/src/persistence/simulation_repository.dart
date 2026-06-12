import '../domain/domain.dart';

abstract class SimulationRepository {
  Future<SimulationState> loadState();

  Future<void> saveState(SimulationState state);
}
