import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/building_occupancy.dart';
import '../../app/town_view_models.dart' show buildingName;
import '../../domain/building.dart';
import '../../domain/building_art.dart';
import '../../domain/character_definition.dart';
import '../../spatial/building_detail_game.dart';

/// The iso building-detail cutaway surface (Flame), reached by tapping into a
/// building — the eventual street "click-in". It is additive: the M5–M12 widget
/// detail is unchanged; this is a separate spatial surface.
class SpatialBuildingDetailScreen extends ConsumerStatefulWidget {
  const SpatialBuildingDetailScreen({required this.building, super.key});

  final Building building;

  @override
  ConsumerState<SpatialBuildingDetailScreen> createState() =>
      _SpatialBuildingDetailScreenState();
}

class _SpatialBuildingDetailScreenState
    extends ConsumerState<SpatialBuildingDetailScreen> {
  late final BuildingDetailGame _game;

  @override
  void initState() {
    super.initState();
    _game = BuildingDetailGame(
      buildingType: widget.building.buildingType,
      grade: BuildingArt.gradeForLevel(widget.building.capacityLevel),
    );
  }

  List<OccupantSpec> _specsFor(List<CharacterDefinition> occupants) => [
        for (final c in occupants)
          OccupantSpec(characterId: c.id, baseArtPath: c.baseArtPath),
      ];

  @override
  Widget build(BuildContext context) {
    final type = widget.building.buildingType;
    // Push current occupancy into the live scene; rebuilds on sim-state change,
    // so the drawn occupants follow the data.
    final occupancy = ref.watch(buildingOccupancyProvider(type));
    _game.setOccupants(_specsFor(occupancy));

    return Scaffold(
      appBar: AppBar(title: Text('${buildingName(type)} — cutaway')),
      body: ColoredBox(
        color: const Color(0xFF15110D),
        child: GameWidget(game: _game),
      ),
    );
  }
}
