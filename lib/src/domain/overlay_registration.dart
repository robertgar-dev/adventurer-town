import 'character_definition.dart';

/// FD9 D5 — the Package C overlay legibility floor is CHARACTER-SPACE, not box.
/// Stamps anchor to character content geometry (FD9 D3), so the binding floor is
/// the smallest VISIBLE character (Brindle, ~116 px on Steam Deck / ~157 px at
/// 1080p) plus a one-chunky-pixel margin. A 176 px box-space floor would render
/// ~1.45x oversized on Brindle, so it is NOT used here.
/// Source of truth: Slot_Registration_Decision_Record_V1 (FD9 D5), design repo.
const int fd9CharacterFloorPx = 116;

/// Whether a slot's anchor is derivable now (content-relative rule) or deferred
/// to per-sprite annotation against the FD7 re-rendered art (FD9 D4).
enum SlotRegistrationStatus { registered, deferredAnnotated }

/// Substrate-independent registration for one overlay slot: STATUS + the
/// content-bbox-relative anchor RULE. No per-sprite numbers live here — the rule
/// is a body-proportion statement that re-derives against any sprite set
/// (including the FD7 re-render); only the per-sprite number recomputes.
class SlotRegistration {
  const SlotRegistration({
    required this.slot,
    required this.status,
    required this.anchorRule,
  });

  final OverlaySlot slot;
  final SlotRegistrationStatus status;

  /// Content-relative anchor rule (FD9 D3). Non-empty for registered slots;
  /// empty for the deferred-annotated [OverlaySlot.weaponToolEdge].
  final String anchorRule;

  bool get isRegistered => status == SlotRegistrationStatus.registered;
}

/// FD9 D3/D4 registration model — rules + status only. Six slots are
/// content-relative DERIVABLE and registered now; Weapon/Tool-Edge is
/// pose-dependent and deferred to per-sprite annotation (FD9 D4).
///
/// Anchors are x-centered on the content bbox unless noted. The fraction
/// constants are FD9 Phase-1 starting values, refinable in Phase 3 (refining a
/// constant is implementation, not a new decision — FD9 D3).
const Map<OverlaySlot, SlotRegistration> overlayRegistration = {
  OverlaySlot.headFace: SlotRegistration(
    slot: OverlaySlot.headFace,
    status: SlotRegistrationStatus.registered,
    anchorRule: 'bbox_top (top-center)',
  ),
  OverlaySlot.shouldersCloak: SlotRegistration(
    slot: OverlaySlot.shouldersCloak,
    status: SlotRegistrationStatus.registered,
    anchorRule: 'bbox_top + 0.12 * bbox_h',
  ),
  OverlaySlot.torsoArmor: SlotRegistration(
    slot: OverlaySlot.torsoArmor,
    status: SlotRegistrationStatus.registered,
    anchorRule: 'mass centroid',
  ),
  OverlaySlot.beltHands: SlotRegistration(
    slot: OverlaySlot.beltHands,
    status: SlotRegistrationStatus.registered,
    anchorRule: 'bbox_top + 0.60 * bbox_h (belt-center default, FD9 D4)',
  ),
  OverlaySlot.packBack: SlotRegistration(
    slot: OverlaySlot.packBack,
    status: SlotRegistrationStatus.registered,
    anchorRule: 'bbox_top + 0.30 * bbox_h',
  ),
  OverlaySlot.weaponToolEdge: SlotRegistration(
    slot: OverlaySlot.weaponToolEdge,
    status: SlotRegistrationStatus.deferredAnnotated,
    anchorRule: '',
  ),
  OverlaySlot.feetPosture: SlotRegistration(
    slot: OverlaySlot.feetPosture,
    status: SlotRegistrationStatus.registered,
    anchorRule: 'bottom-center 0.9941 (existing)',
  ),
};
