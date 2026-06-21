import 'package:adventurer_town/src/domain/building_art.dart';
import 'package:adventurer_town/src/domain/enums.dart';
import 'package:adventurer_town/src/spatial/building_detail_game.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Slice 1 — runtime check of the Flame cutaway: the data-driven shell loads,
/// occupancy is drawn capped to the room slots, and a change in occupancy
/// changes who is drawn (AC #2/#3). Headless via GameWidget; the live visual is
/// confirmed separately with `flutter run`.
void main() {
  test('grade is data-driven from the upgrade band; paths are computed', () {
    expect(BuildingArt.gradeForLevel(1), BuildingGrade.humble);
    expect(BuildingArt.gradeForLevel(3), BuildingGrade.humble);
    expect(BuildingArt.gradeForLevel(5), BuildingGrade.established);
    expect(BuildingArt.gradeForLevel(9), BuildingGrade.grand);
    expect(
      BuildingArt.shellPath(BuildingType.inn, BuildingGrade.humble),
      'assets/buildings/bld_inn_humble.png',
    );
  });

  testWidgets('Inn cutaway loads its shell and draws occupancy (capped, reactive)',
      (tester) async {
    final game = BuildingDetailGame(
      buildingType: BuildingType.inn,
      grade: BuildingGrade.humble,
    );
    // Real PNG decode needs runAsync (fake-async won't decode images).
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameWidget(game: game))),
      );
      for (var i = 0; i < 60 && !game.isLoaded; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
      expect(game.isLoaded, isTrue);

      // The building shell is drawn.
      expect(
        game.children.whereType<SpriteComponent>().isNotEmpty,
        isTrue,
        reason: 'building shell sprite present',
      );

      // Five occupants cap to the four Inn room slots.
      await game.setOccupants([
        for (final id in const ['korrin', 'sera', 'brindle', 'pip', 'tavi'])
          OccupantSpec(
            characterId: id,
            baseArtPath: 'assets/characters/char_$id.png',
          ),
      ]);
      expect(game.occupantCount, 4);

      // A change in occupancy changes who is drawn.
      await game.setOccupants(const [
        OccupantSpec(
          characterId: 'korrin',
          baseArtPath: 'assets/characters/char_korrin.png',
        ),
      ]);
      expect(game.occupantCount, 1);
    });
  });
}
