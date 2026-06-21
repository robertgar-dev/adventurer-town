import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/character_definition.dart';
import '../domain/character_resolver.dart';
import '../domain/enums.dart';
import 'app_providers.dart';

/// The cast members currently being served at [type], derived from live sim
/// state: every adventurer whose most recent service was this building, resolved
/// through the spine to a [CharacterDefinition]. It re-emits whenever the
/// simulation state changes, so the cutaway's drawn occupants follow the data
/// (AC #3). Order is stable (by adventurer id) for a deterministic draw order.
final buildingOccupancyProvider =
    Provider.family<List<CharacterDefinition>, BuildingType>((ref, type) {
  final state = ref.watch(
    simulationControllerProvider.select((value) => value.simulationState),
  );
  if (state == null) {
    return const [];
  }
  final served = state.adventurers.values
      .where((a) => a.lastServiceBuildingType == type)
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  return [for (final a in served) characterForAdventurer(a)];
});
