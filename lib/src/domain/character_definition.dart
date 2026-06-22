import 'character_art.dart';
import 'enums.dart';

/// Outcome-overlay slots stacked above a character's base sprite — the canonical
/// **7** "Service Stamp Slots" ratified by FD9 (Slot_Registration_Decision_Record_V1
/// D1/D2). Reserved for Package C outcome/equipment overlay art; **empty in slice 1**
/// (no overlay art exists yet — the slots are declared, not filled).
///
/// FD9 D2 reconciled this enum 4 → 7: the prior `facePosture` was a stub error
/// fusing opposite ends of the body, split here into [headFace] (top) and
/// [feetPosture] (bottom); [shouldersCloak] and [beltHands] were added. Six of the
/// seven are proportionally derivable from a sprite's content bbox/centroid (FD9 D3);
/// only [weaponToolEdge] is pose-dependent and requires per-sprite annotation (D4).
enum OverlaySlot {
  /// Top-center of content (`bbox_top`). Derivable.
  headFace,

  /// Upper body, below head (`bbox_top + 0.12 · bbox_h`). Derivable.
  shouldersCloak,

  /// Mid-torso, at the mass centroid. Derivable.
  torsoArmor,

  /// Waistline center (`bbox_top + 0.60 · bbox_h`). Derivable belt-center (D4).
  beltHands,

  /// Upper back (`bbox_top + 0.30 · bbox_h`). Derivable.
  packBack,

  /// Weapon-in-hand, pose-dependent. The single annotated slot (FD9 D4).
  weaponToolEdge,

  /// Bottom-center feet anchor (0.9941, uniform across all 45). Derivable.
  feetPosture,
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
