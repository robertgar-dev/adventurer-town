import 'dart:convert';
import 'dart:io';

import 'package:adventurer_town/src/domain/character_definition.dart';
import 'package:adventurer_town/src/domain/overlay_anchor_resolver.dart';
import 'package:adventurer_town/src/domain/overlay_registration.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faithfulness tests for the FD9 D3 content-relative resolver.
///
/// Oracles are computed by hand from the committed `sprite_geometry.json`
/// (bbox_px / img size), independent of the resolver's own code path:
///   y(head)      = bbox_top / img_h
///   y(shoulders) = bbox_top/img_h + 0.12 * bbox_h/img_h
///   y(pack)      = bbox_top/img_h + 0.30 * bbox_h/img_h
///   y(belt)      = bbox_top/img_h + 0.60 * bbox_h/img_h
///   torso        = (centroid_x, centroid_y)
///   feet         = existing feet_anchor [x, 0.9941]
///   x (non-torso, non-feet) = bbox center = (left+right)/2/img_w
void main() {
  const resolver = OverlayAnchorResolver();

  SpriteGeometry geomFor(String name) {
    final file = File('tools/sprite_pipeline/sprite_geometry.json');
    final list = (jsonDecode(file.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    return SpriteGeometry.fromJson(
        list.firstWhere((s) => s['name'] == name));
  }

  const derivableSlots = [
    OverlaySlot.headFace,
    OverlaySlot.shouldersCloak,
    OverlaySlot.torsoArmor,
    OverlaySlot.beltHands,
    OverlaySlot.packBack,
    OverlaySlot.feetPosture,
  ];

  group('FD9 D3 — derivable slots compute the rule (hand oracle: Brindle)', () {
    // Brindle: bbox_px [231,341,792,1018], img 1024² → top 0.333008,
    // h 0.661133, center_x 0.499512, centroid (0.5094,0.6352), feet (0.4995,0.9941).
    late DerivedAnchor head, shoulders, pack, belt, torso, feet;

    setUp(() {
      final g = geomFor('brindle');
      head = resolver.resolve(OverlaySlot.headFace, g) as DerivedAnchor;
      shoulders =
          resolver.resolve(OverlaySlot.shouldersCloak, g) as DerivedAnchor;
      pack = resolver.resolve(OverlaySlot.packBack, g) as DerivedAnchor;
      belt = resolver.resolve(OverlaySlot.beltHands, g) as DerivedAnchor;
      torso = resolver.resolve(OverlaySlot.torsoArmor, g) as DerivedAnchor;
      feet = resolver.resolve(OverlaySlot.feetPosture, g) as DerivedAnchor;
    });

    test('headFace = bbox_top, x at content-bbox center', () {
      expect(head.x, closeTo(0.499512, 1e-5));
      expect(head.y, closeTo(0.333008, 1e-5));
    });

    test('shouldersCloak = bbox_top + 0.12 * bbox_h', () {
      expect(shoulders.y, closeTo(0.412344, 1e-5));
      expect(shoulders.x, closeTo(0.499512, 1e-5));
    });

    test('packBack = bbox_top + 0.30 * bbox_h', () {
      expect(pack.y, closeTo(0.531348, 1e-5));
    });

    test('beltHands = bbox_top + 0.60 * bbox_h (belt-center default)', () {
      expect(belt.y, closeTo(0.729688, 1e-5));
    });

    test('torsoArmor = mass centroid (x and y)', () {
      expect(torso.x, closeTo(0.5094, 1e-4));
      expect(torso.y, closeTo(0.6352, 1e-4));
    });

    test('feetPosture = existing bottom-center anchor (0.9941)', () {
      expect(feet.y, closeTo(0.9941, 1e-4));
      expect(feet.x, closeTo(0.4995, 1e-4));
    });
  });

  group('FD9 D4 — weapon slot is annotated, not computed', () {
    test('weaponToolEdge returns RequiresAnnotation (no anchor, no throw)', () {
      final r = resolver.resolve(OverlaySlot.weaponToolEdge, geomFor('brindle'));
      expect(r, isA<RequiresAnnotation>());
    });
  });

  group('Proof span — every derivable slot resolves to a defined anchor', () {
    // Brindle (min 0.6611), Borrin (max 0.8984), Keebo (non-human), + two mid.
    const span = ['brindle', 'borrin', 'keebo', 'durnik', 'nym'];
    for (final name in span) {
      for (final slot in derivableSlots) {
        test('$name / $slot → in-frame anchor, no throw', () {
          final r = resolver.resolve(slot, geomFor(name));
          expect(r, isA<DerivedAnchor>());
          final a = r as DerivedAnchor;
          expect(a.x, inInclusiveRange(0.0, 1.0));
          expect(a.y, inInclusiveRange(0.0, 1.0));
        });
      }
      test('$name / weapon → RequiresAnnotation', () {
        expect(resolver.resolve(OverlaySlot.weaponToolEdge, geomFor(name)),
            isA<RequiresAnnotation>());
      });
    }
  });

  group('Scale invariance — content-relative output is frame-size agnostic', () {
    // Same proportions, frame 1024² vs 2048² → identical normalized anchors.
    const g1 = SpriteGeometry(
      name: 't1',
      imgW: 1024,
      imgH: 1024,
      bboxLeft: 200,
      bboxTop: 300,
      bboxRight: 800,
      bboxBottom: 1000,
      centroidX: 0.5,
      centroidY: 0.6,
      feetAnchorX: 0.5,
      feetAnchorY: 0.9941,
    );
    const g2 = SpriteGeometry(
      name: 't2',
      imgW: 2048,
      imgH: 2048,
      bboxLeft: 400,
      bboxTop: 600,
      bboxRight: 1600,
      bboxBottom: 2000,
      centroidX: 0.5,
      centroidY: 0.6,
      feetAnchorX: 0.5,
      feetAnchorY: 0.9941,
    );

    for (final slot in derivableSlots) {
      test('$slot identical across 1024² and 2048²', () {
        expect(resolver.resolve(slot, g1), resolver.resolve(slot, g2));
      });
    }
  });

  group('Faithfulness — constants match overlay_registration.dart rule strings',
      () {
    double coeff(OverlaySlot slot) {
      final rule = overlayRegistration[slot]!.anchorRule;
      final m = RegExp(r'([0-9.]+)\s*\*\s*bbox_h').firstMatch(rule);
      expect(m, isNotNull, reason: '$slot rule "$rule" must carry a bbox_h coeff');
      return double.parse(m!.group(1)!);
    }

    test('shouldersCloak 0.12 matches', () {
      expect(OverlayAnchorResolver.shouldersFraction,
          closeTo(coeff(OverlaySlot.shouldersCloak), 1e-9));
    });
    test('packBack 0.30 matches', () {
      expect(OverlayAnchorResolver.packFraction,
          closeTo(coeff(OverlaySlot.packBack), 1e-9));
    });
    test('beltHands 0.60 matches', () {
      expect(OverlayAnchorResolver.beltFraction,
          closeTo(coeff(OverlaySlot.beltHands), 1e-9));
    });
  });
}
