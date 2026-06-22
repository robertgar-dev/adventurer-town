"""Phase 1 read-only sprite geometry measurement (Gate 2, Package C).

Reads the 45 game-ready PNGs and reports, per sprite: alpha-content bbox,
centroid, content-fraction, feet-anchor (bottom-center of content), head-top,
overall extent. NO writes to any repo asset. Output is printed + a JSON dump to
the job tmp dir only.
"""
import json
import os

from PIL import Image

try:
    import numpy as np
    HAVE_NP = True
except Exception:
    HAVE_NP = False

# Repo-relative so this re-grounds from a committed source on any machine:
# script lives in tools/sprite_pipeline/, shipped sprites in <repo>/assets/characters.
_HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(_HERE, "..", "..", "assets", "characters")
OUT = os.path.join(_HERE, "sprite_geometry.json")

rows = []
for fn in sorted(os.listdir(SRC)):
    if not fn.lower().endswith(".png"):
        continue
    name = fn[len("char_"):-len(".png")] if fn.startswith("char_") else fn[:-4]
    im = Image.open(os.path.join(SRC, fn)).convert("RGBA")
    W, H = im.size
    alpha = im.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        continue
    l, t, r, b = bbox
    bw, bh = r - l, b - t

    if HAVE_NP:
        a = np.asarray(alpha, dtype=np.float64)
        mask = a > 0
        total = int(mask.sum())
        ys, xs = np.nonzero(mask)
        wsum = a[mask].sum()
        cx = float((xs * a[mask]).sum() / wsum)
        cy = float((ys * a[mask]).sum() / wsum)
    else:
        a = alpha.load()
        total = 0
        sx = sy = sw = 0.0
        for y in range(H):
            for x in range(W):
                v = a[x, y]
                if v > 0:
                    total += 1
                    sx += x * v
                    sy += y * v
                    sw += v
        cx, cy = sx / sw, sy / sw

    content_fraction = total / float(W * H)
    bbox_fill = total / float(bw * bh)

    rows.append({
        "name": name,
        "img_w": W, "img_h": H,
        "bbox_px": [l, t, r, b],
        "bbox_w": bw, "bbox_h": bh,
        "bbox_w_frac": round(bw / W, 4), "bbox_h_frac": round(bh / H, 4),
        "centroid_x": round(cx / W, 4), "centroid_y": round(cy / H, 4),
        "content_fraction": round(content_fraction, 4),
        "bbox_fill": round(bbox_fill, 4),
        "feet_anchor": [round((l + r) / 2 / W, 4), round(b / H, 4)],
        "head_top": [round((l + r) / 2 / W, 4), round(t / H, 4)],
    })

with open(OUT, "w") as f:
    json.dump(rows, f, indent=2)

hdr = ("name", "img", "bboxW%", "bboxH%", "cx", "cy", "content", "bboxfill", "headT_y", "feet_y")
print("{:<10} {:>9} {:>6} {:>6} {:>5} {:>5} {:>7} {:>8} {:>7} {:>6}".format(*hdr))
for r in rows:
    print("{:<10} {:>4}x{:<4} {:>6} {:>6} {:>5} {:>5} {:>7} {:>8} {:>7} {:>6}".format(
        r["name"], r["img_w"], r["img_h"],
        r["bbox_w_frac"], r["bbox_h_frac"],
        r["centroid_x"], r["centroid_y"],
        r["content_fraction"], r["bbox_fill"],
        r["head_top"][1], r["feet_anchor"][1]))

cf = sorted(rows, key=lambda r: r["content_fraction"])
print("\n=== content_fraction spread (full-canvas alpha coverage) ===")
print("  count:", len(rows))
print("  min :", cf[0]["name"], cf[0]["content_fraction"])
print("  max :", cf[-1]["name"], cf[-1]["content_fraction"])
print("  median:", cf[len(cf) // 2]["name"], cf[len(cf) // 2]["content_fraction"])
print("  lowest 3:", [(r["name"], r["content_fraction"]) for r in cf[:3]])
print("  highest 3:", [(r["name"], r["content_fraction"]) for r in cf[-3:]])

bh = sorted(rows, key=lambda r: r["bbox_h_frac"])
print("\n=== bbox height fraction spread ===")
print("  min :", bh[0]["name"], bh[0]["bbox_h_frac"], "| max :", bh[-1]["name"], bh[-1]["bbox_h_frac"])
ct = sorted(rows, key=lambda r: r["head_top"][1])
print("=== head-top y (smaller=higher) min:", ct[0]["name"], ct[0]["head_top"][1],
      "| max:", ct[-1]["name"], ct[-1]["head_top"][1])
fb = sorted(rows, key=lambda r: r["feet_anchor"][1])
print("=== feet-anchor y  min:", fb[0]["name"], fb[0]["feet_anchor"][1],
      "| max:", fb[-1]["name"], fb[-1]["feet_anchor"][1])
cxs = sorted(rows, key=lambda r: r["centroid_y"])
print("=== centroid_y  min:", cxs[0]["name"], cxs[0]["centroid_y"],
      "| max:", cxs[-1]["name"], cxs[-1]["centroid_y"])
