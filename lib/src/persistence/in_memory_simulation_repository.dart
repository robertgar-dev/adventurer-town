import '../domain/domain.dart';
import 'simulation_repository.dart';

class InMemorySimulationRepository implements SimulationRepository {
  InMemorySimulationRepository({SimulationState? seedState})
      : _json = seedState?.toJson();

  Map<String, Object?>? _json;
  int saveCount = 0;

  @override
  Future<SimulationState> loadState() async {
    final json = _json;
    if (json == null) {
      final state = SimulationState.newGame();
      await saveState(state);
      return state;
    }
    return SimulationState.fromJson(json);
  }

  @override
  Future<void> saveState(SimulationState state) async {
    saveCount += 1;
    _json = state.toJson();
  }
}
