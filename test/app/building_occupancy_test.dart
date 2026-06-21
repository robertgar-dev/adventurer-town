import 'package:adventurer_town/src/app/building_occupancy.dart';
import 'package:adventurer_town/src/domain/adventurer.dart';
import 'package:adventurer_town/src/domain/building.dart';
import 'package:adventurer_town/src/domain/enums.dart';
import 'package:adventurer_town/src/domain/reaction.dart';
import 'package:adventurer_town/src/domain/simulation_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Slice 1.5 legs 1+2 over the REAL path: occupantsForBuilding threads
/// building grade -> reaction, served demand, and the spine-resolved character.
void main() {
  SimulationState stateWith({
    required BuildingType type,
    required int capacityLevel,
    required Adventurer adventurer,
  }) {
    final base = SimulationState.newGame(
      nowUtc: DateTime.utc(2026, 6, 21),
      randomSeed: 7,
    );
    final buildings = Map<BuildingType, Building>.from(base.buildings);
    buildings[type] = buildings[type]!.copyWith(
      isConstructed: true,
      capacityLevel: capacityLevel,
    );
    return base.copyWith(
      buildings: buildings,
      adventurers: {adventurer.id: adventurer},
    );
  }

  test('Grand-grade Blacksmith service yields elated end-to-end (wiring proof)', () {
    final adv = Adventurer.create(
      id: 'adv_1',
      displayName: 'generated',
      tier: AdventurerTier.veteran,
      preferredDemandTypes: const [DemandType.gear],
      arrivalTick: 0,
      characterId: 'korrin',
    ).copyWith(lastServiceBuildingType: BuildingType.blacksmith);

    // capacityLevel 8 -> grade Grand.
    final state = stateWith(
      type: BuildingType.blacksmith,
      capacityLevel: 8,
      adventurer: adv,
    );
    final occupants = occupantsForBuilding(state, BuildingType.blacksmith);

    expect(occupants, hasLength(1));
    expect(occupants.single.reaction, Reaction.elated); // grand -> elated
    expect(occupants.single.demand, DemandType.gear); // demand they came for
    expect(occupants.single.character.id, 'korrin'); // resolved via spine
  });

  test('identity read resolves name + tier via CharacterDefinition, not the adventurer',
      () {
    final adv = Adventurer.create(
      id: 'adv_2',
      displayName: 'generated',
      tier: AdventurerTier.novice, // deliberately differs from the cast tier
      preferredDemandTypes: const [DemandType.rest],
      arrivalTick: 0,
      characterId: 'ysabet',
    ).copyWith(lastServiceBuildingType: BuildingType.inn);

    final state = stateWith(
      type: BuildingType.inn,
      capacityLevel: 1, // humble -> served
      adventurer: adv,
    );
    final occ = occupantsForBuilding(state, BuildingType.inn).single;

    expect(occ.character.displayName, 'Ysabet Crowglass');
    expect(occ.character.tier, AdventurerTier.legendary); // from the catalog
    expect(occ.demand, DemandType.rest);
    expect(occ.reaction, Reaction.served);
  });

  test('a building with no served adventurers has no occupants', () {
    final adv = Adventurer.create(
      id: 'adv_3',
      displayName: 'x',
      tier: AdventurerTier.novice,
      preferredDemandTypes: const [DemandType.food],
      arrivalTick: 0,
    ).copyWith(lastServiceBuildingType: BuildingType.tavern);
    final state = stateWith(
      type: BuildingType.tavern,
      capacityLevel: 1,
      adventurer: adv,
    );
    expect(occupantsForBuilding(state, BuildingType.inn), isEmpty);
  });
}
