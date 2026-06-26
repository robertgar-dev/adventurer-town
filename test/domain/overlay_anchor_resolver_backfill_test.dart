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
///   [ ] 2. Monotonic body order: head.y < shoulders.y < pack.y < belt.y <
///          feet.y for EVERY sprite — the structural FD9 grammar invariant.
///   [ ] 3. SpriteGeometry derived getters (bboxTopFrac / bboxHeightFrac /
///          bboxCenterXFrac) on a constructed geometry with known integer math.
///   [ ] 4. SpriteGeometry.fromJson parsing fidelity — bbox_px[l,t,r,b] and
///          feet_anchor[x,y] index mapping; a transposition must fail.
///   [ ] 5. torsoArmor uses the mass centroid (x AND y), distinct from the
///          bbox-center x used by every other derivable slot (noted exception).
///   [ ] 6. feet anchor uniform via the resolver across ALL sprites: y≈0.9941,
///          x == the sprite's pipeline feet x.
///   [ ] 7. bbox_h_frac span endpoints across the full dataset: min == brindle
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
}
