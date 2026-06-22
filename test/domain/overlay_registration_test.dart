import 'dart:convert';
import 'dart:io';

import 'package:adventurer_town/src/domain/character_definition.dart';
import 'package:adventurer_town/src/domain/overlay_registration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FD9 registration model — schema totality', () {
    test('every OverlaySlot has exactly one registration entry', () {
      expect(overlayRegistration.length, OverlaySlot.values.length);
      for (final slot in OverlaySlot.values) {
        expect(overlayRegistration.containsKey(slot), isTrue,
            reason: '$slot must be registered');
        expect(overlayRegistration[slot]!.slot, slot,
            reason: '$slot entry must self-identify');
      }
    });

    test('6 registered, exactly 1 deferred-annotated (FD9 D3/D4)', () {
      final registered = overlayRegistration.values
          .where((r) => r.status == SlotRegistrationStatus.registered)
          .toList();
      final deferred = overlayRegistration.values
          .where((r) => r.status == SlotRegistrationStatus.deferredAnnotated)
          .toList();
      expect(registered.length, 6);
      expect(deferred.length, 1);
      expect(deferred.single.slot, OverlaySlot.weaponToolEdge,
          reason: 'Weapon/Tool Edge is the single annotated slot (FD9 D4)');
    });

    test('registered slots carry a non-empty rule; weapon is empty', () {
      for (final r in overlayRegistration.values) {
        if (r.isRegistered) {
          expect(r.anchorRule, isNotEmpty,
              reason: '${r.slot} is registered → must state its anchor rule');
        } else {
          expect(r.anchorRule, isEmpty,
              reason: '${r.slot} is deferred → no derivable rule yet');
        }
      }
    });

    test('character-space floor is 116 px, not the 176 px box floor (FD9 D5)',
        () {
      expect(fd9CharacterFloorPx, 116);
      expect(fd9CharacterFloorPx, isNot(176));
    });
  });

  group('FD9 geometry — measured baseline stays within model bands', () {
    // sprite_geometry.json is the committed Phase-1 baseline; these bands are
    // the empirical envelope the content-relative model must register within.
    // If the FD7 re-render shifts geometry outside a band, this test is the
    // tripwire that says the starting constants need Phase-3 refinement.
    late List<Map<String, dynamic>> sprites;

    setUpAll(() {
      final file =
          File('tools/sprite_pipeline/sprite_geometry.json');
      expect(file.existsSync(), isTrue,
          reason: 'geometry baseline must ship beside the pipeline script');
      final decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      sprites = decoded.cast<Map<String, dynamic>>();
      expect(sprites, isNotEmpty);
    });

    test('feet anchor is the uniform pipeline-imposed 0.9941 (closeTo)', () {
      for (final s in sprites) {
        final feetY = (s['feet_anchor'] as List)[1] as num;
        expect(feetY, closeTo(0.9941, 1e-3),
            reason: '${s['name']} feet anchor must hold the uniform value');
      }
    });

    test('head-top y stays within [0.09, 0.34]', () {
      for (final s in sprites) {
        final headTopY = (s['head_top'] as List)[1] as num;
        expect(headTopY, inInclusiveRange(0.09, 0.34),
            reason: '${s['name']} head-top out of band');
      }
    });

    test('mass centroid_y stays within [0.53, 0.65]', () {
      for (final s in sprites) {
        final centroidY = s['centroid_y'] as num;
        expect(centroidY, inInclusiveRange(0.53, 0.65),
            reason: '${s['name']} centroid_y out of band');
      }
    });
  });
}
