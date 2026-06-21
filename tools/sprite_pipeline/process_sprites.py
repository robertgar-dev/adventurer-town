"""
Adventurer Town — reusable sprite asset pipeline.

Given an input folder of AI-downloaded PNGs and its manifest markdown table
(schema: `character | job_id | target_filename`), this script:

  1. Identifies each PNG by the UUID (job_id) in its filename — NEVER by image
     content — and looks it up in the manifest.
  2. Renames manifest "keeper" files to char_<name>.png and MOVES the raw
     download into <input>/masters/ (originals preserved, never deleted).
  3. Removes the solid background with rembg (U^2-Net) -> transparent RGBA.
  4. Applies a single FIXED source->canvas scale (shared across every batch so
     relative character sizes are preserved: a goliath stays bigger than a
     halfling), trims transparent margins, and composites bottom-center (feet at
     the bottom edge) onto a consistent transparent canvas.
  5. Writes an optimized PNG to <input>/processed/.

Anything whose UUID is not a manifest keeper (rejects, duplicates, unknown
extras) is moved to <input>/_unmatched/ and reported — never processed.

Re-runnable: point it at any future batch with --input/--manifest. By default it
skips sprites already present in processed/ (use --force to reprocess, e.g.
after changing the canvas size).

Usage:
  python process_sprites.py --input "<folder>" --manifest "<manifest.md>"
      [--canvas-size 1024] [--content-height 980] [--source-height 2400]
      [--bottom-pad 16] [--limit N] [--force] [--model u2net]
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

UUID_RE = re.compile(
    r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-"
    r"[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
)


def parse_manifest(manifest_path: Path):
    """Return (keepers, doc_uuids) where keepers maps lowercased UUID ->
    (character, target_filename) for every table row that has both a UUID and a
    char_*.png target. doc_uuids is every UUID mentioned anywhere in the file
    (used to label unmatched files as known rejects vs. true unknowns)."""
    text = manifest_path.read_text(encoding="utf-8")
    keepers: dict[str, tuple[str, str]] = {}
    for line in text.splitlines():
        if not line.lstrip().startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 3:
            continue
        uuid_match = next((UUID_RE.fullmatch(c) for c in cells if UUID_RE.fullmatch(c)), None)
        target = next((c for c in cells if c.lower().endswith(".png")), None)
        character = cells[0]
        if uuid_match and target:
            keepers[uuid_match.group(0).lower()] = (character, target)
    doc_uuids = {m.group(0).lower() for m in UUID_RE.finditer(text)}
    return keepers, doc_uuids


def file_uuid(path: Path) -> str | None:
    m = UUID_RE.search(path.name)
    return m.group(0).lower() if m else None


def process_image(
    master_path: Path,
    out_path: Path,
    session,
    *,
    canvas_size: int,
    content_height: int,
    source_height: int,
    bottom_pad: int,
    profile: str = "character",
) -> dict:
    """Background-remove, fixed-scale, trim, and bottom-center onto a square
    transparent canvas. Returns a small dict describing the result."""
    from PIL import Image
    from rembg import remove

    with Image.open(master_path) as im:
        src = im.convert("RGBA")
    src_w, src_h = src.size

    # 1) Background removal -> transparent RGBA.
    cut = remove(src, session=session)
    if cut.mode != "RGBA":
        cut = cut.convert("RGBA")

    # 2/3) Normalize per profile.
    clamped = False
    if profile == "building":
        # Buildings are the scene backdrop: trim transparent margins, then scale
        # to fit the canvas (preserve aspect) anchored on a stable bottom
        # ground-footprint baseline. No character fixed-scale here.
        bbox = cut.getbbox()
        trimmed = cut.crop(bbox) if bbox else cut
        avail = canvas_size - 2 * bottom_pad
        f = min(avail / trimmed.width, avail / trimmed.height)
        content = trimmed.resize(
            (max(1, round(trimmed.width * f)), max(1, round(trimmed.height * f))),
            Image.LANCZOS,
        )
    else:
        # Character: FIXED source->canvas scale (identical for every sprite and
        # batch, so a character drawn larger in the source frame stays larger on
        # the canvas), then trim transparent margins.
        scale = content_height / float(source_height)
        scaled = cut.resize(
            (max(1, round(cut.width * scale)), max(1, round(cut.height * scale))),
            Image.LANCZOS,
        )
        bbox = scaled.getbbox()
        content = scaled.crop(bbox) if bbox else scaled
        max_w, max_h = canvas_size, canvas_size - bottom_pad
        if content.width > max_w or content.height > max_h:
            f = min(max_w / content.width, max_h / content.height)
            content = content.resize(
                (max(1, round(content.width * f)), max(1, round(content.height * f))),
                Image.LANCZOS,
            )
            clamped = True

    # 4) Composite bottom-center (feet at the bottom edge, minus bottom_pad).
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    x = (canvas_size - content.width) // 2
    y = canvas_size - bottom_pad - content.height
    canvas.alpha_composite(content, (x, max(0, y)))

    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out_path, "PNG", optimize=True)
    return {
        "source_px": f"{src_w}x{src_h}",
        "content_px_on_canvas": f"{content.width}x{content.height}",
        "clamped": clamped,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Adventurer Town sprite pipeline.")
    ap.add_argument("--input", required=True, help="Folder of downloaded PNGs.")
    ap.add_argument("--manifest", required=True, help="Manifest .md for this batch.")
    ap.add_argument("--canvas-size", type=int, default=1024)
    ap.add_argument("--content-height", type=int, default=980,
                    help="Canvas px a full-source-frame character maps to.")
    ap.add_argument("--source-height", type=int, default=2400,
                    help="Reference source height the fixed scale is calibrated to.")
    ap.add_argument("--bottom-pad", type=int, default=16)
    ap.add_argument("--profile", choices=["character", "building"], default="character",
                    help="Normalization profile: character = fixed-scale feet-bottom-center "
                         "(preserves relative sizes); building = trim + fit-to-canvas on a stable "
                         "bottom ground-footprint baseline.")
    ap.add_argument("--limit", type=int, default=0, help="Process at most N (0 = all). For sampling.")
    ap.add_argument("--force", action="store_true", help="Reprocess even if processed/ output exists.")
    ap.add_argument("--model", default="u2net", help="rembg model name.")
    args = ap.parse_args()

    inp = Path(args.input)
    manifest = Path(args.manifest)
    if not inp.is_dir():
        print(f"ERROR: input folder not found: {inp}", file=sys.stderr)
        return 2
    if not manifest.is_file():
        print(f"ERROR: manifest not found: {manifest}", file=sys.stderr)
        return 2

    masters = inp / "masters"
    processed = inp / "processed"
    unmatched = inp / "_unmatched"
    for d in (masters, processed, unmatched):
        d.mkdir(parents=True, exist_ok=True)

    keepers, doc_uuids = parse_manifest(manifest)
    print(f"Manifest keepers: {len(keepers)}")

    # --- Step A: ingest loose downloads from the input root. ---
    ingested, set_aside = [], []
    for png in sorted(inp.glob("*.png")):
        uid = file_uuid(png)
        if uid and uid in keepers:
            _char, target = keepers[uid]
            dest = masters / target
            shutil.move(str(png), str(dest))
            ingested.append((target, png.name, uid))
        else:
            dest = unmatched / png.name
            shutil.move(str(png), str(dest))
            reason = ("listed in manifest notes (reject/duplicate)"
                      if uid and uid in doc_uuids else "UUID not in this manifest")
            set_aside.append({"file": png.name, "uuid": uid, "reason": reason})

    # --- Step B: process every master into processed/. ---
    from rembg import new_session
    session = new_session(args.model)

    results, count = [], 0
    # Process every ingested master (char_* and bld_* targets alike).
    masters_by_target = {p.name: p for p in masters.glob("*.png")}
    for target in sorted(masters_by_target):
        if args.limit and count >= args.limit:
            break
        master_path = masters_by_target[target]
        out_path = processed / target
        if out_path.exists() and not args.force:
            results.append({"target": target, "status": "skipped (exists)"})
            continue
        try:
            info = process_image(
                master_path, out_path, session,
                canvas_size=args.canvas_size, content_height=args.content_height,
                source_height=args.source_height, bottom_pad=args.bottom_pad,
                profile=args.profile,
            )
            info.update({"target": target, "status": "processed"})
            results.append(info)
            count += 1
            print(f"  [{count}] {target}  ({info['content_px_on_canvas']} on "
                  f"{args.canvas_size}px canvas)" + ("  CLAMPED" if info["clamped"] else ""))
        except Exception as exc:  # noqa: BLE001 - report and continue the batch
            results.append({"target": target, "status": f"ERROR: {exc}"})
            print(f"  ERROR processing {target}: {exc}", file=sys.stderr)

    report = {
        "input": str(inp),
        "manifest": str(manifest),
        "canvas_size": args.canvas_size,
        "content_height": args.content_height,
        "source_height": args.source_height,
        "bottom_pad": args.bottom_pad,
        "manifest_keeper_count": len(keepers),
        "ingested_count": len(ingested),
        "processed_or_skipped": results,
        "unmatched": set_aside,
    }
    (inp / "_pipeline_report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")

    print(f"\nIngested (renamed -> masters/): {len(ingested)}")
    print(f"Processed this run: {count} | "
          f"skipped existing: {sum(1 for r in results if r.get('status','').startswith('skipped'))}")
    print(f"Set aside (-> _unmatched/): {len(set_aside)}")
    for u in set_aside:
        print(f"   - {u['file']}  [{u['reason']}]")
    print(f"Report: {inp / '_pipeline_report.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
