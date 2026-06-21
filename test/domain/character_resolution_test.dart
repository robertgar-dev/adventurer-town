import 'package:adventurer_town/src/domain/adventurer.dart';
import 'package:adventurer_town/src/domain/character_catalog.dart';
import 'package:adventurer_town/src/domain/character_resolver.dart';
import 'package:adventurer_town/src/domain/enums.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

/// Slice 1 — the data-driven spine: the catalog is seeded from the manifests,
/// a runtime adventurer resolves to a real cast sprite by id (no hardcoded
/// paths), and the shipped asset globs resolve and bundle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Adventurer adventurer({String id = 'adventurer_test', String? characterId}) {
    return Adventurer.create(
      id: id,
      displayName: 'Test',
      tier: AdventurerTier.novice,
      preferredDemandTypes: const [DemandType.rest],
      arrivalTick: 0,
      characterId: characterId,
    );
  }

  test('catalog is seeded with the full 45-member cast', () {
    expect(characterCatalog.length, 45);
    expect(characterCatalog['korrin'], isNotNull);
    expect(characterCatalog['ysabet']!.tier, AdventurerTier.legendary);
    expect(characterCatalog['korrin']!.tierIsDefaulted, isTrue);
  });

  test('an adventurer resolves to a real cast sprite path (computed, not hardcoded)',
      () {
    final def = characterForAdventurer(adventurer());
    expect(characterCatalog.containsKey(def.id), isTrue);
    expect(def.baseArtPath, startsWith('assets/characters/char_'));
    expect(def.baseArtPath, endsWith('.png'));
  });

  test('the deterministic fallback is stable for a given adventurer id', () {
    final a = characterForAdventurer(adventurer(id: 'adventurer_42'));
    final b = characterForAdventurer(adventurer(id: 'adventurer_42'));
    expect(a.id, b.id);
  });

  test('an explicit characterId resolves to that exact cast member', () {
    expect(characterForAdventurer(adventurer(characterId: 'korrin')).id, 'korrin');
  });

  test('shipped asset globs resolve and bundle (characters + buildings)',
      () async {
    final korrin =
        await rootBundle.load(characterCatalog['korrin']!.baseArtPath);
    expect(korrin.lengthInBytes, greaterThan(0));
    final inn = await rootBundle.load('assets/buildings/bld_inn_humble.png');
    expect(inn.lengthInBytes, greaterThan(0));
  });
}
