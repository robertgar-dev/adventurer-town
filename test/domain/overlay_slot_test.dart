import 'package:adventurer_town/src/domain/character_definition.dart';
import 'package:flutter_test/flutter_test.dart';

/// FD9 (Slot_Registration_Decision_Record_V1) D1/D2 — the outcome-overlay slot
/// grammar is the canonical 7 "Service Stamp Slots", reconciled up from the prior
/// 4-slot stub. This test locks the grammar so a regression to the lossy subset
/// (or a silent re-introduction of the fused `facePosture` stub) fails loudly.
void main() {
  test('OverlaySlot is the canonical FD9 7-slot grammar in body order', () {
    expect(OverlaySlot.values, const [
      OverlaySlot.headFace,
      OverlaySlot.shouldersCloak,
      OverlaySlot.torsoArmor,
      OverlaySlot.beltHands,
      OverlaySlot.packBack,
      OverlaySlot.weaponToolEdge,
      OverlaySlot.feetPosture,
    ]);
    expect(OverlaySlot.values.length, 7);
  });

  test('the fused facePosture stub is split into distinct head + feet slots', () {
    final names = OverlaySlot.values.map((s) => s.name).toSet();
    expect(names, contains('headFace'));
    expect(names, contains('feetPosture'));
    expect(names, isNot(contains('facePosture')));
    // Shoulders/Cloak + Belt/Hands were the two slots missing from the stub.
    expect(names, containsAll(<String>['shouldersCloak', 'beltHands']));
  });

  test('reservedOverlaySlots exposes the full grammar', () {
    expect(CharacterDefinition.reservedOverlaySlots, OverlaySlot.values);
  });
}
