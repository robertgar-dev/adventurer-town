import 'character_art.dart';
import 'enums.dart';

/// Overlay layers stacked above a character's base sprite. Reserved now for the
/// eventual outcome / equipment overlay art (Package C); **empty in slice 1**
/// (no overlay art exists yet — the slots are declared, not filled).
enum OverlaySlot {
  weaponToolEdge,
  torsoArmor,
  packBack,
  facePosture,
}

/// A named cast member: a stable identity plus a layer-stack-ready art shape.
///
/// Seeded from the cast manifests (see the generated `character_catalog.dart`).
/// The base sprite is layer 1, resolved by id via [CharacterArt]; the overlay
/// slots are reserved but unfilled until overlay art is produced.
class CharacterDefinition {
  const CharacterDefinition({
    required this.id,
    required this.displayName,
    required this.tier,
    this.tierIsDefaulted = false,
  });

  final String id;
  final String displayName;
  final AdventurerTier tier;

  /// True when [tier] was defaulted because the manifest did not specify it
  /// (only legendaries are marked). Pending the authoritative cast-scope doc;
  /// not load-bearing for the slice-1 render proof.
  final bool tierIsDefaulted;

  /// Layer 1 — the base sprite path, resolved by id (no hardcoded paths).
  String get baseArtPath => CharacterArt.basePath(id);

  /// The reserved overlay slots, all empty in slice 1 (no overlay art yet).
  static const List<OverlaySlot> reservedOverlaySlots = OverlaySlot.values;
}
