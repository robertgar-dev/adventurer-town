import 'character_definition.dart';

/// Content geometry for one sprite, as measured by the sprite pipeline and
/// stored in `sprite_geometry.json`. The *frame* is the square sprite canvas
/// (`imgW` × `imgH`); bbox extents are pixel coordinates within it.
///
/// This is the resolver's only input. It carries measured numbers, never a
/// render scale — scale is the render layer's concern, not the registration
/// model's (FD9 D3).
class SpriteGeometry {
  const SpriteGeometry({
    required this.name,
    required this.imgW,
    required this.imgH,
    required this.bboxLeft,
    required this.bboxTop,
    required this.bboxRight,
    required this.bboxBottom,
    required this.centroidX,
    required this.centroidY,
    required this.feetAnchorX,
    required this.feetAnchorY,
  });

  /// Sprite id (e.g. `brindle`).
  final String name;

  /// Frame (canvas) dimensions in pixels.
  final int imgW;
  final int imgH;

  /// Content bounding box in pixels: `bbox_px = [left, top, right, bottom]`.
  final int bboxLeft;
  final int bboxTop;
  final int bboxRight;
  final int bboxBottom;

  /// Mass centroid, frame-fraction in [0, 1] (origin top-left).
  final double centroidX;
  final double centroidY;

  /// The existing bottom-center feet anchor, frame-fraction (FD9 D3: feet reuse
  /// the pipeline's existing anchor, y ≈ 0.9941).
  final double feetAnchorX;
  final double feetAnchorY;

  /// Top of the content bbox as a fraction of frame height.
  double get bboxTopFrac => bboxTop / imgH;

  /// Content bbox height as a fraction of frame height (FD9 spanning metric
  /// `bbox_h_frac`).
  double get bboxHeightFrac => (bboxBottom - bboxTop) / imgH;

  /// Horizontal center of the content bbox as a fraction of frame width — the
  /// "x centered on the content bbox" used by every derivable non-torso slot
  /// (FD9 D3).
  double get bboxCenterXFrac => (bboxLeft + bboxRight) / 2 / imgW;

  /// Parse one entry of `sprite_geometry.json`.
  factory SpriteGeometry.fromJson(Map<String, dynamic> json) {
    final bbox = (json['bbox_px'] as List).cast<num>();
    final feet = (json['feet_anchor'] as List).cast<num>();
    return SpriteGeometry(
      name: json['name'] as String,
      imgW: (json['img_w'] as num).toInt(),
      imgH: (json['img_h'] as num).toInt(),
      bboxLeft: bbox[0].toInt(),
      bboxTop: bbox[1].toInt(),
      bboxRight: bbox[2].toInt(),
      bboxBottom: bbox[3].toInt(),
      centroidX: (json['centroid_x'] as num).toDouble(),
      centroidY: (json['centroid_y'] as num).toDouble(),
      feetAnchorX: feet[0].toDouble(),
      feetAnchorY: feet[1].toDouble(),
    );
  }
}

/// The outcome of resolving one [OverlaySlot] against a sprite's geometry.
sealed class SlotAnchor {
  const SlotAnchor();
}

/// A computed content-relative reference point, expressed as a frame-fraction
/// in [0, 1] with origin at the top-left. Scale-independent by construction:
/// it carries no render scale, so the render layer is free to place it at 22%,
/// the 116 px floor, or any other scale.
final class DerivedAnchor extends SlotAnchor {
  const DerivedAnchor({required this.x, required this.y});

  final double x;
  final double y;

  @override
  bool operator ==(Object other) =>
      other is DerivedAnchor && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'DerivedAnchor($x, $y)';
}

/// The weapon slot's outcome: its position is pose-dependent and cannot be
/// derived from geometry (FD9 D4). It awaits the per-sprite annotation pass
/// (45 sprites × 1 slot). The resolver reports this status rather than
/// computing a (wrong) anchor or throwing.
final class RequiresAnnotation extends SlotAnchor {
  const RequiresAnnotation();

  @override
  bool operator ==(Object other) => other is RequiresAnnotation;

  @override
  int get hashCode => (RequiresAnnotation).hashCode;

  @override
  String toString() => 'RequiresAnnotation()';
}

/// Pure, scale-independent resolver for the FD9 D3 content-relative
/// registration model: maps `(OverlaySlot, SpriteGeometry)` → a [SlotAnchor].
///
/// The six derivable slots compute from the sprite's content bbox / centroid;
/// the weapon slot returns [RequiresAnnotation] (FD9 D4). The anchor-rule
/// fraction constants below are a 1:1 transcription of FD9 D3 and are
/// cross-checked against the human-readable rule strings in
/// `overlay_registration.dart` by the resolver tests.
class OverlayAnchorResolver {
  const OverlayAnchorResolver();

  /// FD9 D3: `bbox_top + 0.12 * bbox_h`.
  static const double shouldersFraction = 0.12;

  /// FD9 D3: `bbox_top + 0.30 * bbox_h`.
  static const double packFraction = 0.30;

  /// FD9 D3: `bbox_top + 0.60 * bbox_h` (belt-center default, FD9 D4).
  static const double beltFraction = 0.60;

  SlotAnchor resolve(OverlaySlot slot, SpriteGeometry g) {
    switch (slot) {
      // x centered on the content bbox; y per the FD9 D3 rule.
      case OverlaySlot.headFace:
        return DerivedAnchor(x: g.bboxCenterXFrac, y: g.bboxTopFrac);
      case OverlaySlot.shouldersCloak:
        return DerivedAnchor(
          x: g.bboxCenterXFrac,
          y: g.bboxTopFrac + shouldersFraction * g.bboxHeightFrac,
        );
      case OverlaySlot.packBack:
        return DerivedAnchor(
          x: g.bboxCenterXFrac,
          y: g.bboxTopFrac + packFraction * g.bboxHeightFrac,
        );
      case OverlaySlot.beltHands:
        return DerivedAnchor(
          x: g.bboxCenterXFrac,
          y: g.bboxTopFrac + beltFraction * g.bboxHeightFrac,
        );
      // Noted exception: torso anchors to the mass centroid (x and y).
      case OverlaySlot.torsoArmor:
        return DerivedAnchor(x: g.centroidX, y: g.centroidY);
      // Feet reuse the existing pipeline anchor (FD9 D3, already drift-free).
      case OverlaySlot.feetPosture:
        return DerivedAnchor(x: g.feetAnchorX, y: g.feetAnchorY);
      // Pose-dependent, non-derivable (FD9 D4).
      case OverlaySlot.weaponToolEdge:
        return const RequiresAnnotation();
    }
  }
}
