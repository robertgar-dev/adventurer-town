import 'package:isar_community/isar.dart';

part 'simulation_save_record.g.dart';

@collection
class SimulationSaveRecord {
  Id id = 1;

  late String stateJson;

  late DateTime savedAtUtc;
}
