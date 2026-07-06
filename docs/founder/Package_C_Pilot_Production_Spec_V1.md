# Package C Pilot — Production Spec (V1)

**Working Title:** Adventurer Town
**Version:** V1
**Status:** SPEC — for founder execution of the authorized pilot. This document certifies
nothing; the pilot is done when its stamps exist, register, and pass founder review.
**Authorized by:** `docs/founder/Package_C_Pilot_Authorization_2026-07-05.md` (commit `4813599`) —
9 non-weapon Blacksmith stamps, method HYBRID, no generation-pipeline code.
**Sources:** `lib/src/domain/overlay_anchor_resolver.dart` · `lib/src/domain/overlay_registration.dart`
· `tools/sprite_pipeline/sprite_geometry.json` (45 sprites) · `docs/founder/FD9_Phase3_Proof_Record_V1.md`
· `docs/founder/Package_C_Outcome_Overlay_Scope_V1.md`.
**Labeling:** every number is tagged **MEASURED** (read from code/data/ratified proof) or
**INFERRED** (recommendation). Arithmetic conversions of MEASURED numbers are shown with their
formula.

---

## 1. The 9 stamps

| Slot (art token → resolver enum) | Stamp IDs (× 3 grades) |
|---|---|
| `shoulders` → `OverlaySlot.shouldersCloak` | `ovl_blacksmith_shoulders_{humble,established,grand}` |
| `torso` → `OverlaySlot.torsoArmor` | `ovl_blacksmith_torso_{humble,established,grand}` |
| `belt` → `OverlaySlot.beltHands` | `ovl_blacksmith_belt_{humble,established,grand}` |

Excluded, do not touch: `ovl_blacksmith_weapon_*` (gated on FD9 D4) and all 39 non-Blacksmith
stamps. (MEASURED — FD9_Phase3_Proof_Record_V1 §5; authorization record.)

## 2. Reference frame and anchor model

**The reference frame is the sprite's 1024 × 1024 shipped canvas** — all 45 game-ready sprites
are 1024² (MEASURED, `sprite_geometry.json`: every `img_w`/`img_h` = 1024). The resolver returns
a `DerivedAnchor(x, y)` as **frame-fractions in [0, 1], origin top-left**, scale-independent
(MEASURED, `overlay_anchor_resolver.dart:84-103`). Multiply by 1024 for pixels on the shipped
frame.

**Anchors are per-sprite and computed at runtime — a stamp is never authored "at" a pixel
position.** Each stamp is drawn once as its own transparent tile; the render layer places the
stamp's **registration origin** at the resolver's per-sprite anchor. This spec fixes that origin
as the **tile center** (INFERRED — simplest unambiguous convention; nothing in code constrains it
yet because no code consumes stamps).

Per-slot anchor rule and its measured landing range across the full 45-sprite cast
(MEASURED rules from `overlay_anchor_resolver.dart:142-171`; ranges computed this session from
`sprite_geometry.json`, frame-fraction × 1024):

| Slot | Anchor rule (FD9 D3) | x on 1024 frame | y on 1024 frame |
|---|---|---|---|
| shouldersCloak | x = content-bbox center; y = `bbox_top + 0.12·bbox_h` | ≈ 511–513 px (frac 0.499–0.501) | 207–420 px (frac 0.2018–0.4106) |
| torsoArmor | mass centroid (x **and** y) | 453–574 px (frac 0.4422–0.5606) | 549–669 px (frac 0.5363–0.6533) |
| beltHands | x = content-bbox center; y = `bbox_top + 0.60·bbox_h` | ≈ 511–513 px | 649–746 px (frac 0.6340–0.7289) |

Authoring consequences (INFERRED from the ranges): the shoulders/belt stamps land essentially
frame-centered horizontally on every sprite; the **torso** stamp lands up to ±61 px off frame
center (centroid x), so it must read correctly without assuming body symmetry around it — keep
the torso stamp's design symmetric about its own tile center.

## 3. Stamp tile dimensions and legibility budget

**MEASURED foundations** (FD9_Phase3_Proof_Record_V1 §§1–2, ratified): Steam Deck detail-view
sprite frame = **176 px** (22% of 800, FD8 A1); Brindle visible content ≈ **116 px** (the binding
floor, `fd9CharacterFloorPx = 116` in `overlay_registration.dart:9`); 1080p frame ≈ 238 px. The
ratified synthetic mark that passed by-eye review measured, at Deck scale: **stroke 2.75 px, full
extent 28.9 px, anchor dot ⌀ 2.41 px**.

**Conversion factor** (arithmetic on MEASURED): Deck frame 176 px vs. shipped frame 1024 px →
1 Deck px = 1024/176 ≈ **5.82 shipped px**. The scope doc's master scale is 2560² ("Masters stay
2560²", MEASURED as a doc statement) → master:shipped = 2.5:1.

Derived budget (each = MEASURED figure × conversion, then INFERRED as a recommendation):

| Quantity | Deck px (proven) | Shipped px (1024 frame) | Master px (2560 scale) |
|---|---|---|---|
| Proven-legible stroke | 2.75 | ≈ 16 | ≈ 40 |
| Absolute stroke floor (1 device px + margin) | ≥ ~1.5 | ≥ ~9 | ≥ ~22 |
| Proven mark full extent | 28.9 | ≈ 168 | ≈ 420 |

**Recommended tile sizes (INFERRED):**
- **Shipped export: 256 × 256 px** per stamp tile. Rationale: holds the proven ~168 px extent
  with padding; ¼ of the sprite frame; integer 0.4× of the master tile. This is deliberately NOT
  the 1024 character canvas — a stamp is a small mark placed at an anchor, not a full-frame
  sprite; exporting stamps at 1024 would waste 94% of the tile in empty alpha.
- **Master authoring: 640 × 640 px** (256 × 2.5, matching the 2560→1024 master transform), content
  drawn around tile center, extent ≈ 300–420 px, no stroke thinner than ~40 px, hard-edged alpha.
- Keep total stamp extent ≤ ~170 shipped px (INFERRED ceiling: the narrowest cast content is
  333 px wide on the shipped frame — MEASURED min `bbox_w` — and a stamp wider than ~half the
  narrowest body reads as costume, not mark).

Validate every finished stamp by eye at the 116 px floor (downscale a test composite to a 176 px
frame) before calling it done — the FD9 discipline: measured numbers inform; the by-eye read at
floor scale decides.

## 4. The 5-step workflow (per stamp; authorization order preserved)

1. **AI-assisted draft.** Produce a draft image per stamp via in-session generation tooling
   (interactive use only — building scripted generation code is explicitly unauthorized). Draft
   at ≥ 640 px content scale so step 2 never upscales. Grade semantics per the scope doc:
   humble = patched/serviceable · established = solid/clean · grand = refined sheen, no glow.
2. **Manual size/position.** Hand-finish to house style; scale and place the content onto a
   640 × 640 transparent-capable master tile with the registration origin at tile center
   (§2 convention). This is the "manual fix and cleanup" the HYBRID ruling requires.
3. **rembg.exe CLI** — only if the draft still carries a background:
   `tools/sprite_pipeline/.venv/Scripts/rembg.exe i <draft> <cutout>` (rembg 2.0.76, MEASURED
   present). Deliberately the bare CLI, not `process_sprites.py`: the script has no
   stamp-appropriate profile — its `character`/`building` normalizations (fixed body scale,
   feet-bottom compositing) are wrong for stamps and there is no bypass flag (MEASURED,
   discovery report 2026-07-05). Skip this step entirely for stamps hand-finished on
   transparency.
4. **`processed/` folder.** Place each finished 640² master tile at
   `art_src/package_c_pilot/processed/<stamp_id>.png` (final `ovl_*` name, exact ID from §1).
5. **Export.** `python tools/sprite_pipeline/export_gameready.py --out assets/overlays --size 256
   art_src/package_c_pilot/processed` — resizes 640² → 256² (LANCZOS) into the shipped tree.
   Commit **each stamp as its own labeled commit**, body citing
   `Package_C_Pilot_Authorization_2026-07-05.md` (FD11 §1 process rule: build commits cite their
   authorizing record).

**⚠ Pre-export gap (MEASURED):** `.gitattributes` LFS-tracks only `assets/characters/**/*.png`
and `assets/buildings/**/*.png`. Before the first export commit, add
`assets/overlays/**/*.png filter=lfs diff=lfs merge=lfs -text` — otherwise stamp PNGs commit as
plain blobs, breaking the established LFS convention. One config line; not pipeline code.

## 5. Staging convention

`art_src/` is the established, gitignored staging root (MEASURED: `.gitignore` "source/work
staging only"; four precedent batches — `buildings`, `cast_core`, `cast_expanded`,
`cast_rerender_iso` — each `art_src/<batch>/` + manifest + `masters/`/`processed/`). This pilot
follows it:

```
art_src/package_c_pilot/
  Stamp_Manifest_PackageC_Pilot_V1.md   ← manifest (schema below)
  masters/                              ← raw AI drafts + working files (step 1–2 inputs)
  processed/                            ← finished 640² master tiles, final ovl_* names (step 4)
```

Manifest schema (INFERRED — adapted from the cast manifests' `character | job_id |
target_filename` table; stamps are hand-placed, so the UUID column becomes a free-form source
reference):

```
| stamp            | source (job-id / draft file / "hand") | target_filename                        |
|------------------|----------------------------------------|----------------------------------------|
| shoulders humble | <ref>                                  | ovl_blacksmith_shoulders_humble.png    |
| ... (9 rows, exactly the §1 IDs)                                                                 |
```

Nothing under `art_src/` is ever committed; only the step-5 exports under `assets/overlays/`
enter git (via LFS, after the §4 gap is closed).

## 6. Out of scope for this spec

Weapon stamps (gated) · the other 39 stamps (unauthorized) · any generation-pipeline code
(unauthorized) · the runtime `ovl_*`-filename→`OverlaySlot` lookup and stamp rendering (no code
consumes stamps yet — MEASURED, zero `ovl_` references in `lib/`; wiring stamps into the game is
a future, separately-scoped task) · registration proof of the finished stamps on the 5-sprite
span (the scope doc's pilot sequencing step — run after production, ruled by founder review).

---

*Package_C_Pilot_Production_Spec_V1 · Adventurer Town · docs/founder · 2026-07-05 · spec for
founder execution — certifies nothing · 9 stamps · tile 640² master / 256² shipped · anchors
per-sprite via OverlayAnchorResolver*
