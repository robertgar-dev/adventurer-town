"""
FD7 look-test preview: composite real cast sprites into the real Inn shell at
the hand-calibrated room anchors, exactly as the Flame cutaway will (flat-front
billboard sprites, bottom-center anchored at each room slot, relative sizes
preserved). This is a static stand-in for the live Flame render so the founder
can rule on FD7 (flat-front-as-billboard vs. needs-iso-re-render) without running
the app. Anchors here mirror the slice-1 hand-calibration in the Flame scene.

Usage:
  python preview_cutaway.py --out <preview.png>
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

BASE = Path(__file__).resolve().parents[2]
SHELL = BASE / "assets" / "buildings" / "bld_inn_humble.png"
CHAR_DIR = BASE / "assets" / "characters"

# Hand-calibrated Inn room slots (normalized x, y of the bottom-center feet
# point) paired with a representative cast member. Throwaway slice-1 values.
SLOTS = [
    ("korrin", 0.47, 0.40),   # upper-level bed
    ("sera", 0.43, 0.65),     # mid bed by the hearth
    ("brindle", 0.30, 0.85),  # front-left bed (shortest in the cast)
    ("pip", 0.53, 0.93),      # front bed (widest)
]
SPRITE_FRACTION = 0.30  # sprite square height as a fraction of shell height


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    shell = Image.open(SHELL).convert("RGBA")
    sw, sh = shell.size
    canvas = shell.copy()

    sprite_h = int(sh * SPRITE_FRACTION)
    for name, nx, ny in SLOTS:
        path = CHAR_DIR / f"char_{name}.png"
        spr = Image.open(path).convert("RGBA")
        scale = sprite_h / spr.height
        spr = spr.resize((max(1, round(spr.width * scale)), sprite_h), Image.LANCZOS)
        # The sprite square is bottom-anchored content, so its bottom edge is the
        # feet. Place bottom-center at the slot anchor.
        x = int(sw * nx) - spr.width // 2
        y = int(sh * ny) - spr.height
        canvas.alpha_composite(spr, (x, max(0, y)))

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out, "PNG")
    print(f"Wrote cutaway preview -> {out} ({len(SLOTS)} occupants)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
