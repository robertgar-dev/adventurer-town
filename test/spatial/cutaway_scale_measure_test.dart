import 'package:adventurer_town/src/domain/building_art.dart';
import 'package:adventurer_town/src/domain/enums.dart';
import 'package:adventurer_town/src/spatial/building_detail_game.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// READ-ONLY measurement harness (FD8 ratification, Phase 1). Renders the
/// existing Slice 1 Inn cutaway at two viewports and reports the actual drawn
/// sprite-box height after the camera transform. Changes no scene/camera/asset.
void main() {
  for (final vp in const [Size(1280, 800), Size(1920, 1080)]) {
    testWidgets('measure ${vp.width.toInt()}x${vp.height.toInt()}', (tester) async {
      await tester.binding.setSurfaceSize(vp);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final game = BuildingDetailGame(
        buildingType: BuildingType.inn,
        grade: BuildingGrade.humble,
      );
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: GameWidget(game: game))),
        );
        for (var i = 0; i < 120 && !game.isLoaded; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await tester.pump();
        }
        await game.setOccupants(const [
          OccupantSpec(
            characterId: 'korrin',
            baseArtPath: 'assets/characters/char_korrin.png',
          ),
        ]);
        await tester.pump();

        final shells = game.children.whereType<SpriteComponent>().toList();
        final occs = game.children.whereType<CharacterSpriteComponent>().toList();
        // ignore: avoid_print
        print('DIAG| isLoaded=${game.isLoaded} size=${game.size.x.toInt()}x'
            '${game.size.y.toInt()} shells=${shells.length} occs=${occs.length} '
            'children=${game.children.map((c) => c.runtimeType).toList()}');
        if (shells.isEmpty || occs.isEmpty) {
          return;
        }
        final shell = shells.first;
        final occ = occs.first;
        final vh = game.size.y;
        // ignore: avoid_print
        print('MEASURE| viewport=${game.size.x.toInt()}x${game.size.y.toInt()} '
            'shellDrawnH=${shell.size.y.toStringAsFixed(0)} '
            'spriteBoxH=${occ.size.y.toStringAsFixed(0)} '
            'spritePctVp=${(occ.size.y / vh * 100).toStringAsFixed(1)}% '
            'cutawayFillH=${(shell.size.y / vh * 100).toStringAsFixed(1)}% '
            'slotTopY=${occ.position.y.toStringAsFixed(0)}');

        // FD8 regression guard — detail-view sprite locked at EXACTLY 22% of
        // viewport height (Deck 1280x800 -> 176 px; 1080p 1920x1080 -> ~238 px).
        expect(occ.size.y / vh, closeTo(0.22, 1e-6));
        expect(occ.size.y, closeTo(vh * 0.22, 0.5));
        // Cutaway shell fills viewport height (the fit the 22% rides on).
        expect(shell.size.y, closeTo(vh, 0.5));
      });
    });
  }
}
