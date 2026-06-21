import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/building_art.dart';
import '../domain/character_definition.dart';
import '../domain/character_resolver.dart';
import '../domain/enums.dart';
import '../domain/reaction.dart';
import '../domain/simulation_state.dart';
import 'app_providers.dart';

/// A semantic occupant read for the detail view (app layer): the resolved cast
/// member, the demand they came for, and their reaction to the service. The
/// Flame render layer consumes a flattened OccupantSpec built from this — this
/// is the OccupantView (semantic) vs OccupantSpec (render) seam.
class OccupantView {
  const OccupantView({
    required this.character,
    required this.demand,
    required this.reaction,
  });

  final CharacterDefinition character;
  final DemandType demand;
  final Reaction reaction;
}

/// Pure derivation: who is currently being served at [type], read end-to-end
/// from sim state — serving building's grade -> reaction, served demand, and the
/// resolved cast member (via the spine). Order-stable by adventurer id. No
/// engine or persistence change; everything is derived display-side.
List<OccupantView> occupantsForBuilding(SimulationState state, BuildingType type) {
  final building = state.buildings[type];
  if (building == null) {
    return const [];
  }
  final reaction = reactionForServiceGrade(
    BuildingArt.gradeForLevel(building.capacityLevel),
  );
  final demand = building.servedDemandType;
  final served = state.adventurers.values
      .where((a) => a.lastServiceBuildingType == type)
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  return [
    for (final a in served)
      OccupantView(
        character: characterForAdventurer(a),
        demand: demand,
        reaction: reaction,
      ),
  ];
}

/// Live occupancy for [type], re-emitting on sim-state change so the cutaway's
/// drawn occupants follow the data.
final buildingOccupancyProvider =
    Provider.family<List<OccupantView>, BuildingType>((ref, type) {
  final state = ref.watch(
    simulationControllerProvider.select((value) => value.simulationState),
  );
  if (state == null) {
    return const [];
  }
  return occupantsForBuilding(state, type);
});
