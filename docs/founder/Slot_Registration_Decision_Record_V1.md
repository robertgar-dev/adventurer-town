# Outcome-Overlay Slot Registration — Founder Decision Record (FD9)

**Working Title:** Adventurer Town
**Version:** V1
**Status:** **LOCKED — RATIFIED** (registration model + slot grammar). Implementation pending (Phase 2/3 against this record).
**Document Path:** `06_Art_and_Audio/Artifacts/Slot_Registration_Decision_Record_V1.md`
**Date:** 2026-06-21
**Resolves:** Package C **Gate 2** (the slot-registration problem flagged in `Asset_Production_Plan_V2` §10). Binds the overlay floor question carried forward from `Detail_View_Render_Scale_Decision_Record_V1.1` (FD8 A1) D2.
**Grounded in:** Gate 2 Phase 1 empirical investigation (45 sprites measured via the sprite-pipeline venv; `sprite_geometry.json`), branch `claude/happy-bohr-1rhyw4` at HEAD `9043712`.
**Filing note:** Sequential founder decision; may be cross-filed as **FD9**.

---

## Purpose

Resolve how a **single** outcome-overlay stamp — drawn once per (service, grade, slot) and reused across all 45 cast sprites — registers onto the correct body region of sprites whose visible content ranges from a short halfling to a tall goliath to a non-human kobold. This is the prerequisite that unblocks Package C art generation. This record ratifies the slot grammar, the registration model, and the resulting overlay floor; Phase 2/3 implement against it.

---

## Context — what Phase 1 established (empirical)

Measured across all 45 game-ready sprites (1024² canvas, normalized):

- **bbox-height fraction** (vertical content extent ÷ canvas — the metric that drives slot drift): **Brindle 0.661 (min) → Borrin 0.898 (max)**, swing 0.237. *(Naming note: prior docs, incl. FD8 A1, called this "content fraction." It is bbox-height fraction, not alpha coverage — true alpha coverage is 0.16–0.32. The slot-drift conclusions are unaffected; this record uses the precise term and supersedes the loose usage.)*
- **Head-top drift** between the extremes: **~0.237 of canvas height (~243 px)**. A fixed-canvas head slot would miss by this much between Borrin and Brindle.
- **Feet anchor: uniform at 0.9941 across all 45** — the existing bottom-center anchor is drift-free.
- **Keebo (kobold, non-human):** mid-range (height 0.773, head-top 0.222) — tests body-type generality without being a geometric extreme.

**Conclusion forced by the data:** fixed-canvas registration is dead (it drifts the full ~243 px on the head slot). Content-relative registration is the answer, and it is already proven correct where it exists (feet, 0.9941 everywhere).

---

## Decisions

### D1 — Ratify the canonical 7-slot grammar

The binding slot set is the **7 "Service Stamp Slots"** from `Service_Vocabulary_and_Outcomes_V1`:

| # | Slot | Body region |
|---|---|---|
| 1 | Head/Face | top-center of content |
| 2 | Shoulders/Cloak | upper body, below head |
| 3 | Torso/Armor | mid-torso (centroid) |
| 4 | Belt/Hands | waistline / hands |
| 5 | Pack/Back | upper back |
| 6 | Weapon/Tool Edge | weapon in hand |
| 7 | Feet/Posture | bottom-center (feet) |

Package C reconciles the data model **up to these 7**. No slots beyond the grammar are invented.

### D2 — `facePosture` is a stub error; the enum is expanded 4 → 7

The current `OverlaySlot` enum (`weaponToolEdge, torsoArmor, packBack, facePosture`) is a lossy subset and is **corrected**, not preserved:

- **`facePosture` is ruled a stub error.** It fuses Head/Face (slot 1, top of body) with Feet/Posture (slot 7, bottom of body) — opposite ends of the sprite. It is **split** into two distinct slots: `headFace` and `feetPosture`.
- **`shouldersCloak` and `beltHands` are added** (currently missing).
- `weaponToolEdge`, `torsoArmor`, `packBack` are retained.

Resulting enum (7): `headFace, shouldersCloak, torsoArmor, beltHands, packBack, weaponToolEdge, feetPosture`. This is a data-model change and is authorized here as a founder ruling so it is not smuggled into an implementation commit.

### D3 — Registration model: content-relative, with one annotated exception

Each slot anchor is expressed **relative to the sprite's measured content bounding box** (not fixed canvas coordinates). A stamp is authored once at reference size and translated/scaled per sprite from that sprite's bbox. **6 of 7 slots are proportionally derivable** with these anchor rules (x centered on the content bbox unless noted):

| Slot | Anchor rule (from content bbox) | Class |
|---|---|---|
| Head/Face | `bbox_top` (top-center) | Derivable |
| Shoulders/Cloak | `bbox_top + 0.12 · bbox_h` | Derivable |
| Pack/Back | `bbox_top + 0.30 · bbox_h` | Derivable |
| Torso/Armor | mass centroid | Derivable |
| Belt/Hands | `bbox_top + 0.60 · bbox_h` | Derivable |
| Feet/Posture | existing bottom-center anchor (0.9941) | Derivable (already exists) |
| **Weapon/Tool Edge** | **weapon-in-hand, pose-dependent** | **Per-sprite annotation** |

*(The fraction constants above are the Phase 1 starting values; Phase 3's synthetic-mark proof may refine them within this model. Refinement of a constant is implementation, not a new decision.)*

### D4 — Weapon/Tool Edge is the single annotated slot

Only **Weapon/Tool Edge** cannot be derived from a bounding box (weapon position is pose-dependent). It requires **per-sprite annotation: 45 sprites × 1 slot = 45 annotations** (any adventurer may use the Blacksmith). This is the entire annotation burden — the other 6 slots are automatic.

**Worst-case +45:** *if* Belt/Hands outcomes need a true hand anchor (a hand-held prop) rather than a belt-center stamp, Belt/Hands also becomes annotated (→ 90 total). **Ruling:** Belt/Hands defaults to the **derivable belt-center** anchor; a hand-specific anchor is adopted *only if* Phase 3 shows a belt-center stamp reads wrong for a specific Blacksmith/Market outcome. Do not pre-emptively annotate hands.

### D5 — Bound overlay floor (resolves FD8 A1 D2)

FD8 A1 defined two candidate floors (box-space 176 px Deck vs character-space ~116 px Deck) and deferred the choice to this investigation. Because the registration model (D3) anchors stamps to **character content geometry**, the binding floor is the **character-space floor**:

- **Package C overlays are authored to read at the smallest visible character: Brindle, ~116 px tall on Steam Deck** (≈157 px at 1080p), plus a one-chunky-pixel safety margin.

A stamp authored to the 176 px box floor would render ~1.45× oversized on Brindle. The ~116 px character-space floor is therefore the binding Package C authoring spec.

---

## Scope boundary — not decided here

- **Exact final fraction constants** for the 6 derivable slots — starting values are in D3; Phase 3 may refine within the content-relative model. Not re-ratified per tweak.
- **Per-sprite weapon annotations** (the 45) — produced during Package C build, not enumerated here.
- **Which (service, grade, slot) combinations exist** — governed by `Service_Vocabulary_and_Outcomes_V1` + `Amenity_Module_System_V1` (3-grade ladder), not this record.

---

## Acceptance (Phase 3 proof gate)

This model is proven — and Package C cleared to generate real overlay art — when a **synthetic** high-contrast test mark (not real art, not generated), placed via the content-relative resolver on one derivable slot at detail-view scale (22%; ~116 px character on Deck), **registers on the correct body region across the extreme span: Brindle (0.661, min), Borrin (0.898, max), Keebo (kobold/non-human), plus two mid-range human/elf sprites.** Pass/fail per sprite. No art is commissioned until this passes.

---

*Slot_Registration_Decision_Record_V1 (FD9) · Adventurer Town · 06_Art_and_Audio/Artifacts · 2026-06-21 · grounded in Gate 2 Phase 1 @ HEAD 9043712*
