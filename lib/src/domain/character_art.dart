/// Resolves character art paths by id. Logic holds ids only; every path is
/// computed here by convention — there are no hardcoded image references
/// anywhere else in the codebase.
///
/// The committed asset path (`assets/characters/`) is fixed by the founder
/// ruling on the source/shipped split (2026-06-20) and declared in `pubspec.yaml`
/// under `flutter: assets:`.
class CharacterArt {
  const CharacterArt._();

  /// Shipped, game-ready sprite directory.
  static const String charactersDir = 'assets/characters';

  /// Layer-1 (base) sprite for a character id, e.g.
  /// `assets/characters/char_korrin.png`.
  static String basePath(String id) => '$charactersDir/char_$id.png';
}
