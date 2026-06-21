"""
Export game-ready, downscaled PNGs from one or more processed/ folders into the
shipped assets/ tree. Reads the square-canvas processed outputs and resizes to
size x size (uniform — preserves the shared bottom-anchored coordinate space).

Source-safe: it only reads from processed/ and writes to --out; it never touches
masters/ or the processed/ originals.

Usage:
  python export_gameready.py --out <assets_dir> --size N <processed_dir> [<processed_dir> ...]
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def main() -> int:
    ap = argparse.ArgumentParser(description="Downscale processed sprites into shipped assets/.")
    ap.add_argument("--out", required=True, help="Destination assets folder (shipped art).")
    ap.add_argument("--size", type=int, required=True, help="Square export size (px).")
    ap.add_argument("srcs", nargs="+", help="One or more processed/ source folders.")
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    count = 0
    for srcdir in args.srcs:
        for f in sorted(Path(srcdir).glob("*.png")):
            with Image.open(f) as im:
                resized = im.convert("RGBA").resize((args.size, args.size), Image.LANCZOS)
                resized.save(out / f.name, "PNG", optimize=True)
            count += 1
            print(f"  {f.name} -> {args.size}x{args.size}")
    print(f"Exported {count} game-ready PNG(s) -> {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
