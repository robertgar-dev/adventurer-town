import 'dart:convert';
import 'dart:io';

import 'package:adventurer_town/src/domain/character_definition.dart';
import 'package:adventurer_town/src/domain/overlay_anchor_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

/// FD9 D3/D4 anchor-resolver — BACKFILL test suite.
///
/// Strengthens the safety net under the content-relative registration domain
/// BEFORE Package C overlay stamps build on it. Complements (does not duplicate)
/// `overlay_anchor_resolver_test.dart`, which already covers: the Brindle
/// hand-oracle (min-span sprite), weapon→RequiresAnnotation, a 5-sprite in-frame
/// span, scale invariance, and constant↔rule-string faithfulness.
///
/// Oracles here are computed by hand from the committed `sprite_geometry.json`,
/// independent of the resolver's own code path (same discipline as the sibling
/// suite). All numbers are exact rational fractions of the 1024² frame.
///
/// ───────────────────────────────────────────────────────────────────────────
/// ORDERED BACKFILL PLAN (one increment per loop pass; later passes continue
/// down this list, never redoing finished work):
///
///   [x] 1. Borrin max-span exact oracle — boundary partner to Brindle's min.
///          bbox_h_frac ≈ 0.8984 (dataset max). Locks the derived anchors at the
///          top of the documented span, not just "in frame".
///   [x] 2. Monotonic body order: head.y < shoulders.y < pack.y < belt.y <
///          feet.y for EVERY sprite — the structural FD9 grammar invariant.
///   [x] 3. SpriteGeometry derived getters (bboxTopFrac / bboxHeightFrac /
///          bboxCenterXFrac) on a constructed geometry with known integer math.
///   [x] 4. SpriteGeometry.fromJson parsing fidelity — bbox_px[l,t,r,b] and
///          feet_anchor[x,y] index mapping; a transposition must fail.
///   [x] 5. torsoArmor uses the mass centroid (x AND y), distinct from the
///          bbox-center x used by every other derivable slot (noted exception).
///   [x] 6. feet anchor uniform via the resolver across ALL sprites: y≈0.9941,
///          x == the sprite's pipeline feet x.
///   [x] 7. bbox_h_frac span endpoints across the full dataset: min == brindle
///          (~0.6611), max == borrin (~0.8984) — the FD9 spanning metric.
///   [ ] 8. DerivedAnchor value semantics: == and hashCode (equal iff x&y equal).
///   [ ] 9. RequiresAnnotation value semantics: all instances equal, stable
///          hashCode, never equal to a DerivedAnchor.
/// ───────────────────────────────────────────────────────────────────────────
void main() {
  const resolver = OverlayAnchorResolver();

  SpriteGeometry geomFor(String name) {
    final file = File('tools/sprite_pipeline/sprite_geometry.json');
    final list = (jsonDecode(file.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    return SpriteGeometry.fromJson(list.firstWhere((s) => s['name'] == name));
  }

  List<SpriteGeometry> allGeometries() {
    final file = File('tools/sprite_pipeline/sprite_geometry.json');
    return (jsonDecode(file.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>()
        .map(SpriteGeometry.fromJson)
        .toList();
  }

  group('FD9 D3 — derivable slots compute the rule (hand oracle: Borrin, '
      'max bbox_h_frac)', () {
    // Borrin: bbox_px [227,98,797,1018], img 1024² →
    //   bbox_top_frac    = 98/1024             = 0.0957031
    //   bbox_h_frac      = (1018-98)/1024       = 920/1024 = 0.8984375  (dataset max)
    //   bbox_center_xfrac= (227+797)/2/1024     = 512/1024 = 0.5
    //   centroid         = (0.5467, 0.553)
    //   feet             = (0.5, 0.9941)
    late DerivedAnchor head, shoulders, pack, belt, torso, feet;

    setUp(() {
      final g = geomFor('borrin');
      head = resolver.resolve(OverlaySlot.headFace, g) as DerivedAnchor;
      shoulders =
          resolver.resolve(OverlaySlot.shouldersCloak, g) as DerivedAnchor;
      pack = resolver.resolve(OverlaySlot.packBack, g) as DerivedAnchor;
      belt = resolver.resolve(OverlaySlot.beltHands, g) as DerivedAnchor;
      torso = resolver.resolve(OverlaySlot.torsoArmor, g) as DerivedAnchor;
      feet = resolver.resolve(OverlaySlot.feetPosture, g) as DerivedAnchor;
    });

    test('headFace = bbox_top, x at content-bbox center', () {
      expect(head.x, closeTo(0.5, 1e-6));
      expect(head.y, closeTo(0.0957031, 1e-6));
    });

    test('shouldersCloak = bbox_top + 0.12 * bbox_h', () {
      // 0.0957031 + 0.12 * 0.8984375 = 0.2035156
      expect(shoulders.x, closeTo(0.5, 1e-6));
      expect(shoulders.y, closeTo(0.2035156, 1e-6));
    });

    test('packBack = bbox_top + 0.30 * bbox_h', () {
      // 0.0957031 + 0.30 * 0.8984375 = 0.3652344
      expect(pack.y, closeTo(0.3652344, 1e-6));
    });

    test('beltHands = bbox_top + 0.60 * bbox_h (belt-center default)', () {
      // 0.0957031 + 0.60 * 0.8984375 = 0.6347656
      expect(belt.y, closeTo(0.6347656, 1e-6));
    });

    test('torsoArmor = mass centroid (x and y)', () {
      expect(torso.x, closeTo(0.5467, 1e-4));
      expect(torso.y, closeTo(0.553, 1e-4));
    });

    test('feetPosture = existing bottom-center anchor (0.9941)', () {
      expect(feet.x, closeTo(0.5, 1e-4));
      expect(feet.y, closeTo(0.9941, 1e-4));
    });
  });

  group('FD9 D3 — anchors descend the body in grammar order (every sprite)', () {
    // The bbox-derived y-rules use strictly increasing coefficients
    // (0 < 0.12 < 0.30 < 0.60) over a positive bbox height, and feet sit at the
    // pipeline floor (~0.9941). So for ANY real sprite the slots must stack
    // head → shoulders → pack → belt → feet top-to-bottom. Package C relies on
    // this ordering for overlay stacking; a sign flip or a swapped coefficient
    // in the resolver would break it here.
    //
    // Torso is intentionally excluded from this chain: it anchors to the mass
    // centroid (FD9 noted exception), not a bbox fraction, so it carries no
    // guaranteed position in the coefficient ordering.
    for (final g in allGeometries()) {
      test('${g.name}: head.y < shoulders.y < pack.y < belt.y < feet.y', () {
        final head = resolver.resolve(OverlaySlot.headFace, g) as DerivedAnchor;
        final shoulders =
            resolver.resolve(OverlaySlot.shouldersCloak, g) as DerivedAnchor;
        final pack = resolver.resolve(OverlaySlot.packBack, g) as DerivedAnchor;
        final belt = resolver.resolve(OverlaySlot.beltHands, g) as DerivedAnchor;
        final feet =
            resolver.resolve(OverlaySlot.feetPosture, g) as DerivedAnchor;

        expect(head.y, lessThan(shoulders.y));
        expect(shoulders.y, lessThan(pack.y));
        expect(pack.y, lessThan(belt.y));
        expect(belt.y, lessThan(feet.y));
      });
    }
  });

  group('SpriteGeometry — bbox→frame-fraction getters (constructed geometry)',
      () {
    // Non-square frame with distinct img_w (1000) and img_h (2000) so a width/
    // height transposition in any getter is caught. bbox left/right are NOT
    // symmetric about the frame, so bboxCenterXFrac must be the BBOX center
    // (0.4), never the frame center (0.5).
    //   bbox_top_frac     = 300 / 2000             = 0.15
    //   bbox_h_frac       = (1900 - 300) / 2000     = 1600/2000 = 0.80
    //   bbox_center_xfrac = (100 + 700) / 2 / 1000  = 400/1000  = 0.40
    const g = SpriteGeometry(
      name: 'constructed',
      imgW: 1000,
      imgH: 2000,
      bboxLeft: 100,
      bboxTop: 300,
      bboxRight: 700,
      bboxBottom: 1900,
      centroidX: 0.42,
      centroidY: 0.58,
      feetAnchorX: 0.5,
      feetAnchorY: 0.9941,
    );

    test('bboxTopFrac = bbox_top / img_h', () {
      expect(g.bboxTopFrac, closeTo(0.15, 1e-12));
    });

    test('bboxHeightFrac = (bbox_bottom - bbox_top) / img_h', () {
      expect(g.bboxHeightFrac, closeTo(0.80, 1e-12));
    });

    test('bboxCenterXFrac is the bbox center (0.4), not the frame center', () {
      expect(g.bboxCenterXFrac, closeTo(0.40, 1e-12));
      expect(g.bboxCenterXFrac, isNot(closeTo(0.5, 1e-6)));
    });
  });

  group('SpriteGeometry.fromJson — array index mapping fidelity', () {
    // Every field gets a DISTINCT value so a swapped bbox_px or feet_anchor
    // index (e.g. right<->bottom, or feet x<->y) cannot pass by coincidence.
    // bbox_px is [left, top, right, bottom]; feet_anchor is [x, y].
    final g = SpriteGeometry.fromJson(const {
      'name': 'parsefix',
      'img_w': 1280,
      'img_h': 960,
      'bbox_px': [11, 22, 33, 44],
      'centroid_x': 0.111,
      'centroid_y': 0.222,
      'feet_anchor': [0.333, 0.444],
    });

    test('scalar fields map by name', () {
      expect(g.name, 'parsefix');
      expect(g.imgW, 1280);
      expect(g.imgH, 960);
      expect(g.centroidX, closeTo(0.111, 1e-12));
      expect(g.centroidY, closeTo(0.222, 1e-12));
    });

    test('bbox_px maps in [left, top, right, bottom] order', () {
      expect(g.bboxLeft, 11);
      expect(g.bboxTop, 22);
      expect(g.bboxRight, 33);
      expect(g.bboxBottom, 44);
    });

    test('feet_anchor maps in [x, y] order', () {
      expect(g.feetAnchorX, closeTo(0.333, 1e-12));
      expect(g.feetAnchorY, closeTo(0.444, 1e-12));
    });

    test('parsed values feed the derived getters', () {
      // bbox_h_frac = (44 - 22) / 960 = 22/960; top = 22/960.
      expect(g.bboxTopFrac, closeTo(22 / 960, 1e-12));
      expect(g.bboxHeightFrac, closeTo(22 / 960, 1e-12));
      expect(g.bboxCenterXFrac, closeTo((11 + 33) / 2 / 1280, 1e-12));
    });
  });

  group('FD9 D3 — torsoArmor anchors to the mass centroid (noted exception)',
      () {
    test('torso = (centroid_x, centroid_y) exactly, for every sprite', () {
      for (final g in allGeometries()) {
        final torso =
            resolver.resolve(OverlaySlot.torsoArmor, g) as DerivedAnchor;
        expect(torso.x, g.centroidX, reason: '${g.name} torso.x == centroid_x');
        expect(torso.y, g.centroidY, reason: '${g.name} torso.y == centroid_y');
      }
    });

    test('torso x is the centroid, NOT the bbox-center x used by other slots',
        () {
      // isolde: centroid_x 0.4472 vs bbox center (230+794)/2/1024 = 0.5.
      // If torso wrongly reused bboxCenterXFrac (like head/shoulders/pack/belt),
      // these would coincide. They must not.
      final g = geomFor('isolde');
      final torso =
          resolver.resolve(OverlaySlot.torsoArmor, g) as DerivedAnchor;
      final head = resolver.resolve(OverlaySlot.headFace, g) as DerivedAnchor;

      expect(torso.x, closeTo(0.4472, 1e-4));
      expect(head.x, closeTo(0.5, 1e-4)); // bbox center
      expect((torso.x - head.x).abs(), greaterThan(0.04),
          reason: 'torso must use centroid x, distinct from the bbox-center x');
    });
  });

  group('FD9 D3 — feetPosture passes through the uniform pipeline anchor', () {
    test('every sprite: feet y ≈ 0.9941 and feet x == the pipeline feet x', () {
      for (final g in allGeometries()) {
        final feet =
            resolver.resolve(OverlaySlot.feetPosture, g) as DerivedAnchor;
        // The resolver reuses the existing drift-free pipeline anchor verbatim:
        // y is the uniform 0.9941 floor; x passes through unchanged (it varies
        // ~0.4985–0.5005 across the set, so this is a real pass-through check,
        // not a constant).
        expect(feet.y, closeTo(0.9941, 1e-3),
            reason: '${g.name} feet y must be the uniform floor');
        expect(feet.x, g.feetAnchorX,
            reason: '${g.name} feet x must pass through the pipeline anchor');
      }
    });
  });

  group('FD9 spanning metric — bbox_h_frac endpoints across the dataset', () {
    // The content-relative model is validated against the empirical envelope of
    // bbox_h_frac. FD9 documents the span as ~0.661 (Brindle, shortest content)
    // to ~0.898 (Borrin, tallest). This test locks BOTH the identity of the
    // endpoint sprites and the values, so a geometry-baseline edit that shifts
    // the envelope (e.g. the FD7 re-render) trips here.
    late List<SpriteGeometry> sprites;

    setUpAll(() => sprites = allGeometries());

    SpriteGeometry minByHeightFrac() => sprites
        .reduce((a, b) => a.bboxHeightFrac <= b.bboxHeightFrac ? a : b);
    SpriteGeometry maxByHeightFrac() => sprites
        .reduce((a, b) => a.bboxHeightFrac >= b.bboxHeightFrac ? a : b);

    test('minimum bbox_h_frac is Brindle at ~0.6611', () {
      final lo = minByHeightFrac();
      expect(lo.name, 'brindle');
      expect(lo.bboxHeightFrac, closeTo(0.6611, 1e-3));
    });

    test('maximum bbox_h_frac is Borrin at ~0.8984', () {
      final hi = maxByHeightFrac();
      expect(hi.name, 'borrin');
      expect(hi.bboxHeightFrac, closeTo(0.8984, 1e-3));
    });

    test('every sprite sits within the [Brindle, Borrin] envelope', () {
      for (final g in sprites) {
        expect(g.bboxHeightFrac, inInclusiveRange(0.6611 - 1e-3, 0.8984 + 1e-3),
            reason: '${g.name} bbox_h_frac escaped the documented FD9 span');
      }
    });
  });
}
