import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'file_simulation_repository.dart';

FileSimulationRepository createFlutterFileSimulationRepository() {
  return FileSimulationRepository(() async {
    final directory = await getApplicationSupportDirectory();
    return File(
        '${directory.path}${Platform.pathSeparator}simulation_state.json');
  });
}
