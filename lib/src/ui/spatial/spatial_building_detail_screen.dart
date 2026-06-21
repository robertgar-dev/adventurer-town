import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/building_occupancy.dart';
import '../../app/town_view_models.dart' show buildingName, demandName;
import '../../domain/building.dart';
import '../../domain/building_art.dart';
import '../../spatial/building_detail_game.dart';

/// The iso building-detail cutaway surface (Flame), reached by tapping into a
/// building — the eventual street "click-in". Additive: the M5–M12 widget detail
/// is unchanged; this is a separate spatial surface.
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
    )..onOccupantSelected = _showOccupant;
  }

  /// Leg 1 — a minimal on-select read: name · demand · tier only. A lightweight
  /// label, never a character sheet (no bio / motivation / stats).
  void _showOccupant(OccupantSpec spec) {
    if (!mounted) {
      return;
    }
    final parts = [spec.displayName, spec.demandLabel, spec.tierLabel]
        .whereType<String>()
        .join('  ·  ');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          key: const Key('occupant-read'),
          content: Text(parts),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  List<OccupantSpec> _specsFor(List<OccupantView> occupants) => [
        for (final v in occupants)
          OccupantSpec(
            characterId: v.character.id,
            baseArtPath: v.character.baseArtPath,
            displayName: v.character.displayName,
            demandLabel: demandName(v.demand),
            tierLabel: _tierLabel(v.character.tier.name),
            reaction: v.reaction,
          ),
      ];

  String _tierLabel(String name) =>
      name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}';

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
