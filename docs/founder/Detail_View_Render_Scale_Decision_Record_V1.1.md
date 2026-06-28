# Detail-View Render Scale — Amendment A1 (Ratification & Geometry Reconciliation)

**Working Title:** Adventurer Town
**Version:** V1.1 (Amendment A1)
**Status:** **LOCKED — RATIFIED**
**Document Path:** `06_Art_and_Audio/Artifacts/Detail_View_Render_Scale_Decision_Record_V1.1.md`
**Date:** 2026-06-21
**Amends:** `Detail_View_Render_Scale_Decision_Record_V1` (D1, D2). D3–D5 unchanged.
**Implementing commit:** `846ed45` — "Spatial Slice 1.5: ratify detail-view render scale to 22% (FD8)" · branch `claude/happy-bohr-1rhyw4` · pushed to origin.
**Regression guard:** `test/spatial/cutaway_scale_measure_test.dart` — asserts the 22% fraction at 1280×800 and 1920×1080. Suite green (198 tests); Windows .exe builds.

---

## Why this amendment exists

FD8 V1 locked the detail-view sprite at 22% of viewport **provisionally**, pending one live-run confirmation. That confirmation happened. It did two things FD8 did not anticipate: it **falsified two of the three assumptions** behind the 22% figure, and it **surfaced a box-vs-character distinction** that makes D2's overlay floor wrong as originally stated. This amendment reconciles the record against the measured repository reality, ratifies the value, and corrects D2. It changes no part of the locked *value* — only its justification and the overlay-floor unit.

---

## Reconciliation against repository reality (measured)

All figures empirical, read from the live Flame scene via the measurement harness.

| State | Constant | Box height — Deck (1280×800) | Box % of viewport | Box height — 1080p |
|---|---|---|---|---|
| Slice 1 (pre-amendment) | `_shellRect.height * 0.30` | 240 px | 30.0% | 324 px |
| **Ratified (committed `846ed45`)** | `_shellRect.height * 0.22` | **176 px** | **22.0%** | **238 px** |

- **Governing constant (single knob):** `final spriteHeight = _shellRect.height * 0.22;` in `lib/src/spatial/building_detail_game.dart`, `setOccupants()`. Shell-fit (100% of viewport height) is correct and untouched; the multiplier is the only scale control.
- **Resolution-independence confirmed:** both viewports read identical % (22.0% / 22.0%), validating FD8 D1's fraction-of-viewport premise.
- **Render-only:** masters remain 2560²; pipeline, manifests, catalog, and the 45 assets are untouched. This bakes no downscale into any asset.

---

## Amended decisions

### D1 — Detail-view sprite height (value RECONFIRMED, derivation CORRECTED)

**Value stands: detail-view sprite = 22% of viewport height** (≈176 px on Steam Deck, ≈238 px at 1080p).

**Derivation corrected.** FD8 V1 derived 22% from three assumptions; measurement falsified two:

| Assumption (FD8 V1) | Measured reality | Status |
|---|---|---|
| Cutaway fills ~90% of viewport | Fills **100%** (square shell fit to height, centered, ~62% width) | Falsified |
| ~3 stacked zones | **2 stacked floors / 4 room slots** | Falsified |
| Character ~75% of a zone | At 22%, character fills **~58%** of a zone's clear interior height | Re-grounded |

The 3-zone arithmetic no longer points at 22%. The value is now justified on **headroom**, not zone count: at `0.30` the visible character fills ~79% of a zone's clear height (crowding the ceiling — the "oversized" read in the Slice-1 preview); at `0.22` it sits at ~58% with comfortable headroom; `0.26` would be ~68%. 22% is retained as the value with the most headroom without floating small. This is a deliberate look call grounded in the measured 2-zone geometry, not a calculation.

### D2 — Package C overlay authoring floor (CORRECTED: box-space vs character-space)

FD8 V1 stated a single "~170 px" overlay floor. Measurement shows that figure is the **bounding-box** height, which is **not** the binding floor for overlays that attach to a character feature. The scaler normalizes the *box*; the *visible character* inside it varies by species:

- **Cast content fraction:** 0.66 (Brindle, halfling — smallest) → 0.90 (Borrin, goliath — largest); mean 0.82. This ~36% spread is a **feature** (it tracks species scale) and box-normalization correctly preserves it. It is **not** to be "fixed" by content-normalization.

Two floors are therefore defined, and which one binds depends on how a stamp registers:

| Overlay type | Binding floor (Steam Deck) | Binding floor (1080p) |
|---|---|---|
| **Box-space** (registers to the sprite's bounding box / fixed slot) | box height = **176 px** | 238 px |
| **Character-attached** (registers to a body feature — wound, weapon mark) | smallest visible character = Brindle 0.66 × 176 = **~116 px** | ~157 px |

**Any Package C stamp that attaches to character anatomy must read at the ~116 px Deck floor**, not 176 px — authoring to 176 px would render ~1.45× oversized on Brindle. This ~116 px figure is the quantified face of the Gate 2 (slot-registration) problem: the 0.66–0.90 spread is precisely *why* fixed-canvas slots will not register cleanly across the cast.

### D3, D4, D5 — UNCHANGED

- **D3** (fractional fit from 2560² masters; integer-scaling rejected) — stands.
- **D4** (registration is master-relative, defined in 2560² space, independent of on-screen scale) — stands, and is **reinforced**: the box-vs-character finding above is the empirical case for keeping registration in box/master space rather than chasing on-screen pixels.
- **D5** (provisional, reversible by design; masters stay 2560²) — stands. See reversibility note below.

---

## Ratification record

The FD8 confirmation procedure specified a **founder by-eye pick** across 0.22 / 0.26 / 0.30 before locking. In practice, a **concurrent Claude Code session committed `0.22` directly** (`846ed45`), bundling the one-line constant change, the explanatory comment, and the regression-guard test, and pushed it to origin.

This is **accepted as the ratified value** on three grounds:
1. **Independent support** — the headroom analysis above lands on 22% regardless of the skipped by-eye step; the value is correct, not merely incumbent.
2. **Guarded against drift** — `cutaway_scale_measure_test.dart` asserts the exact fraction at both viewports, so the value cannot silently regress.
3. **Cheap to revise** — per D5, a change is a one-line forward commit through the guarded path, not history surgery or re-art.

Status flips from *"LOCKED (provisional) — ratification pending"* to **LOCKED — RATIFIED at 0.22**.

*Process note (non-blocking):* the direct-commit path bypassed the intended founder gate. The value is sound, but the gate existed for a reason — recorded here so the deviation is visible, not silently normalized.

---

## Scope boundary — handed to other documents (not open questions here)

- **Which overlay floor binds Package C** (box-space vs character-attached) is set by the **Gate 2 slot-registration investigation**, not by this record. D2 supplies both measured floors; the registration technique selects between them.
- **Street / town-view sprite scale** remains owed to **Slice 2** (street surface + facade zoom). Out of scope by design.

---

## Reversibility (reaffirmed)

The lock is reversible by a single forward edit: `_shellRect.height * 0.22 → * 0.26` (or other), re-run the guard test to re-assert the new fraction, commit. Masters remain 2560², so any scale change is a downscale **re-export**, never redrawn art. There is no art risk in having ratified early.

---

*Detail_View_Render_Scale_Decision_Record_V1.1 (Amendment A1) · Adventurer Town · 06_Art_and_Audio/Artifacts · 2026-06-21 · ratified at constant 0.22 / commit 846ed45*
