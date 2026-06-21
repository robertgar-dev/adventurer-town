import 'package:adventurer_town/src/domain/building_art.dart';
import 'package:adventurer_town/src/domain/enums.dart';
import 'package:adventurer_town/src/domain/reaction.dart';
import 'package:adventurer_town/src/spatial/building_detail_game.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Leg 1 — selecting an occupant fires the on-select read with name/demand/tier,
/// and the occupant carries the leg-2 reaction state (rendered as nothing).
void main() {
  testWidgets('tapping an occupant surfaces its identity read + reaction state',
      (tester) async {
    OccupantSpec? selected;
    final game = BuildingDetailGame(
      buildingType: BuildingType.inn,
      grade: BuildingGrade.humble,
    )..onOccupantSelected = (s) => selected = s;

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameWidget(game: game))),
      );
      for (var i = 0; i < 80 && !game.isLoaded; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
      await game.setOccupants(const [
        OccupantSpec(
          characterId: 'ysabet',
          baseArtPath: 'assets/characters/char_ysabet.png',
          displayName: 'Ysabet Crowglass',
          demandLabel: 'Rest',
          tierLabel: 'Legendary',
          reaction: Reaction.served,
        ),
      ]);
      await tester.pump();

      final occ = game.children.whereType<CharacterSpriteComponent>().first;
      // Bottom-center anchored: the box center is up by size.y / 2.
      await tester.tapAt(
        Offset(occ.position.x, occ.position.y - occ.size.y / 2),
      );
      await tester.pump();
    });

    expect(selected, isNotNull);
    expect(selected!.displayName, 'Ysabet Crowglass');
    expect(selected!.demandLabel, 'Rest');
    expect(selected!.tierLabel, 'Legendary');
    // Leg 2: reaction state is carried on the occupant (renders nothing).
    expect(selected!.reaction, Reaction.served);
  });
}
