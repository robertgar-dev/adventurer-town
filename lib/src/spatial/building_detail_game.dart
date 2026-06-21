import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../domain/building_art.dart';
import '../domain/character_definition.dart';
import '../domain/enums.dart';

/// One drawn occupant: which cast member, and the base sprite path to draw.
class OccupantSpec {
  const OccupantSpec({required this.characterId, required this.baseArtPath});

  final String characterId;
  final String baseArtPath;
}

/// Hand-calibrated room slots (normalized within the shell), mirroring the FD7
/// preview anchors. Throwaway slice-1 calibration; the authoritative layout
/// reconciles via the Amenity Module System doc later.
const Map<BuildingType, List<Offset>> _roomSlots = {
  BuildingType.inn: [
    Offset(0.47, 0.40),
    Offset(0.43, 0.65),
    Offset(0.30, 0.85),
    Offset(0.53, 0.93),
  ],
};

const List<Offset> _fallbackSlots = [
  Offset(0.35, 0.82),
  Offset(0.55, 0.88),
  Offset(0.45, 0.95),
];

/// The iso building-detail cutaway: a data-driven shell plus flat-front cast
/// sprites placed in its rooms, with occupancy fed from sim state. The drawn
/// occupants change when the occupancy list changes (AC #3).
class BuildingDetailGame extends FlameGame {
  BuildingDetailGame({required this.buildingType, required this.grade});

  final BuildingType buildingType;
  final BuildingGrade grade;

  final Images _images = Images(prefix: '');
  Rect _shellRect = Rect.zero;
  bool _loaded = false;
  List<OccupantSpec> _pending = const [];
  final List<Component> _occupants = [];

  List<Offset> get _slots => _roomSlots[buildingType] ?? _fallbackSlots;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    final image = await _images.load(BuildingArt.shellPath(buildingType, grade));
    final shell = Sprite(image);

    // Fit the square shell to the canvas, centered, preserving aspect.
    final src = shell.srcSize;
    final scale = math.min(size.x / src.x, size.y / src.y);
    final drawn = src * scale;
    final origin = (size - drawn) / 2;
    _shellRect = Rect.fromLTWH(origin.x, origin.y, drawn.x, drawn.y);

    await add(SpriteComponent(sprite: shell, position: origin, size: drawn));

    _loaded = true;
    if (_pending.isNotEmpty) {
      await setOccupants(_pending);
    }
  }

  /// Replace the drawn occupants. Capped to the building's room slots, so a
  /// changing occupancy list changes who is drawn.
  Future<void> setOccupants(List<OccupantSpec> occupants) async {
    _pending = occupants;
    if (!_loaded) {
      return;
    }

    for (final c in _occupants) {
      c.removeFromParent();
    }
    _occupants.clear();

    final slots = _slots;
    final count = math.min(occupants.length, slots.length);
    final spriteHeight = _shellRect.height * 0.30;

    for (var i = 0; i < count; i++) {
      final image = await _images.load(occupants[i].baseArtPath);
      final slot = slots[i];
      final component = CharacterSpriteComponent(
        sprite: Sprite(image),
        height: spriteHeight,
        position: Vector2(
          _shellRect.left + slot.dx * _shellRect.width,
          _shellRect.top + slot.dy * _shellRect.height,
        ),
      );
      await add(component);
      _occupants.add(component);
    }
  }

  /// Test/inspection hook: how many occupant sprites are currently drawn.
  int get occupantCount => _occupants.length;
}

/// A flat-front, layer-stacked character: a soft ground-contact shadow (layer 0)
/// plus the base sprite (layer 1), bottom-center anchored so the feet sit at the
/// room slot. The four overlay slots are reserved but empty in slice 1.
class CharacterSpriteComponent extends PositionComponent {
  CharacterSpriteComponent({
    required Sprite sprite,
    required double height,
    required Vector2 position,
  })  : _sprite = sprite,
        super(
          position: position,
          anchor: Anchor.bottomCenter,
          size: Vector2(height * sprite.srcSize.x / sprite.srcSize.y, height),
        );

  final Sprite _sprite;

  /// Reserved overlay layers above the base sprite — empty in slice 1 (no
  /// overlay art yet). Declared so the layer stack is ready to fill later.
  final Map<OverlaySlot, Sprite?> overlays = {
    for (final slot in OverlaySlot.values) slot: null,
  };

  @override
  Future<void> onLoad() async {
    // Layer 0 — soft contact shadow so the flat-front sprite reads as standing
    // on the iso floor (the FD7 ground-contact fix, in placement not art).
    await add(_ContactShadow(
      position: Vector2(size.x / 2, size.y),
      width: size.x * 0.6,
    ));
    // Layer 1 — the base sprite.
    await add(SpriteComponent(sprite: _sprite, size: size.clone()));
    // Overlay slots (weapon/torso/pack/face) intentionally left empty.
  }
}

class _ContactShadow extends PositionComponent {
  _ContactShadow({required Vector2 position, required double width})
      : super(
          position: position,
          anchor: Anchor.center,
          size: Vector2(width, width * 0.26),
        );

  static final Paint _paint = Paint()
    ..color = const Color(0x55000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  @override
  void render(Canvas canvas) {
    canvas.drawOval(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }
}
