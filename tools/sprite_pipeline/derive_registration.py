"""Phase 2 DRY-RUN: apply the FD9 D3 content-relative anchor rules to measured
geometry and print the per-sprite overlay anchors.

This is a DISPOSABLE artifact. The numbers it prints are NOT authoritative and
are deliberately not committed: they are a function of the current sprite set
(`sprite_geometry.json`) and regenerate verbatim against the FD7 re-rendered art.
The authoritative thing is the RULE (lib/src/domain/overlay_registration.dart),
not the number. Run this to eyeball that the rules resolve sanely; never store
its output as a source of truth.

Source of rules: Slot_Registration_Decision_Record_V1 (FD9 D3/D4), design repo.
Reads sprite_geometry.json beside this script; writes nothing.
"""
import json
import os

_HERE = os.path.dirname(os.path.abspath(__file__))
GEOMETRY = os.path.join(_HERE, "sprite_geometry.json")

# FD9 D3 — content-relative anchor rules. Fractions are bbox_top + k * bbox_h,
# x centered on the content bbox. These are the FD9 Phase-1 starting values
# (refinable in Phase 3 within the same model; refinement is implementation).
# 6 derivable + 1 deferred. Mirrors lib/src/domain/overlay_registration.dart.
HEAD_FACE_K = 0.0
SHOULDERS_CLOAK_K = 0.12
PACK_BACK_K = 0.30
BELT_HANDS_K = 0.60
# torsoArmor: mass centroid (not a bbox_h fraction) — uses measured centroid.
# feetPosture: existing bottom-center anchor (0.9941) — already drift-free.
# weaponToolEdge: pose-dependent, per-sprite annotation (FD9 D4) — NOT derived.


def derive(sprite):
    """Return the derivable anchors (canvas-normalized 0..1) for one sprite."""
    l, t, r, b = sprite["bbox_px"]
    W, H = sprite["img_w"], sprite["img_h"]
    bbox_h = sprite["bbox_h"]
    cx_content = (l + r) / 2.0  # x centered on content bbox, in px

    def y_at(k):
        return (t + k * bbox_h) / H

    x = round(cx_content / W, 4)
    return {
        "headFace": [x, round(y_at(HEAD_FACE_K), 4)],
        "shouldersCloak": [x, round(y_at(SHOULDERS_CLOAK_K), 4)],
        "packBack": [x, round(y_at(PACK_BACK_K), 4)],
        "torsoArmor": [sprite["centroid_x"], sprite["centroid_y"]],
        "beltHands": [x, round(y_at(BELT_HANDS_K), 4)],
        "feetPosture": sprite["feet_anchor"],
        # weaponToolEdge intentionally absent — deferred to per-sprite annotation.
    }


def main():
    with open(GEOMETRY) as f:
        sprites = json.load(f)

    print("DRY-RUN: FD9 D3 content-relative anchors (canvas-normalized y).")
    print("NOT authoritative — regenerates against FD7 re-render. Rule is truth.\n")
    cols = ("name", "head", "shldr", "pack", "torso_y", "belt", "feet_y")
    print("{:<10} {:>6} {:>6} {:>6} {:>7} {:>6} {:>6}".format(*cols))
    for s in sorted(sprites, key=lambda s: s["name"]):
        a = derive(s)
        print("{:<10} {:>6} {:>6} {:>6} {:>7} {:>6} {:>6}".format(
            s["name"],
            a["headFace"][1], a["shouldersCloak"][1], a["packBack"][1],
            a["torsoArmor"][1], a["beltHands"][1], a["feetPosture"][1]))

    print("\nDerived 6/7 slots for {} sprites.".format(len(sprites)))
    print("Deferred (per-sprite annotation, FD9 D4): weaponToolEdge "
          "({} annotations owed at Package C build).".format(len(sprites)))


if __name__ == "__main__":
    main()
