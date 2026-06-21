import 'adventurer.dart';
import 'character_catalog.dart';
import 'character_definition.dart';

/// Resolves a runtime [Adventurer] to a named cast member.
///
/// Prefers the adventurer's explicit [Adventurer.characterId]; otherwise falls
/// back to a stable, deterministic mapping from the adventurer id, so every
/// adventurer resolves to a consistent face even before identity assignment is
/// wired into the simulation. The fallback is replay-safe — it uses a stable
/// hash, never `String.hashCode` (which is not guaranteed stable across runs).
CharacterDefinition characterForAdventurer(Adventurer adventurer) {
  final explicit = adventurer.characterId;
  if (explicit != null) {
    final def = characterCatalog[explicit];
    if (def != null) {
      return def;
    }
  }
  final keys = characterCatalog.keys.toList()..sort();
  final idx = _stableHash(adventurer.id) % keys.length;
  return characterCatalog[keys[idx]]!;
}

int _stableHash(String value) {
  var hash = 0;
  for (final unit in value.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}
