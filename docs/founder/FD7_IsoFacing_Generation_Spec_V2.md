# FD7 Iso-Facing Re-Render — Generation Spec

**Working Title:** Adventurer Town
**Version:** V2 — supersedes the uncommitted V1 (pre-commit revision; see note)
**Status:** Approved (founder) — generation spec; re-render execution pending against this record.
**Document Path:** `06_Art_and_Audio/Artifacts/FD7_IsoFacing_Generation_Spec_V2.md`
**Date:** 2026-06-22
**Resolves:** the owed item in `Detail_View_LookTest_Decision_Record_V1` — FD7 ruled re-render
needed; "iso-facing depth" was left undefined. This record defines it.
**Inherits baseline from:** the original cast generation prompts (recovered from Higgsfield job
records: shared house-style block + per-character identity block + shared negative block; model
`nano_banana_2`, 2K, HD-2D house style). This spec changes facing, lighting, and grounding only.
**Unblocks downstream:** re-render → re-run `tools/sprite_pipeline/measure_sprites.py` → FD9
registration model re-derives → Package C Phase-3 proof → overlay art.

---

**V1 supersession note.** V1 specified a full/dramatic 3/4 turn (~45°) as the primary depth fix.
On review — before any generation, commit, or credit spend — that was judged to spend cast charm
(partly-hidden faces, identity drift, weakened cozy front-read) to buy depth that lighting and
grounding largely deliver on their own. V2 re-weights accordingly. V1 was never committed; this
is the version to commit and generate against.

---

## Purpose

Re-render the 45 named cast so each figure reads as standing in a 2:1 dimetric room rather than
pasted onto it — fixing the look-test's flat-front problem — without changing identity,
proportion, costume, palette, silhouette read, canvas, or house style. A re-render, not a
redesign. The only intentional changes are lighting direction, ground contact, and a gentle
facing turn.

## Context — what the look-test established, re-read

The figures read pasted-on for three reasons, not one: (a) flat head-on lighting against
directionally-lit rooms, (b) no ground contact (since softened by the Slice-1.5 contact shadow),
and (c) head-on facing in an iso-projected space. The original prompts (recovered) contain no
facing instruction at all — the model defaulted to flat-front because nothing specified otherwise.
The key insight V2 acts on: of the three causes, lighting and grounding carry no charm cost to
fix (they don't turn the face away or risk identity), while facing does. So depth is solved
primarily by lighting + grounding, and facing is a supporting cue applied gently.

---

## Decisions

### G1 — Facing: gentle 3/4 as the FLOOR, not the lead (locked, climbable)

Each figure is turned to a gentle three-quarter view (~20°) — just enough to break dead-on
flatness and let the figure cast and sit within the iso space, while keeping the face and
front-of-costume fully forward and cozy. The turn is a supporting depth cue; lighting (G4)
and grounding (G2) are the lead mechanism.

- **Anti-profile guard (binding):** turn is toward camera; face substantially visible and
  recognizable; never profile, never away. (Trivially satisfied at ~20°.)
- The ~20° is a **floor, climbable in one direction only.** The calibration gate judges whether
  depth reads. If it reads short, nudge the angle UP (toward ~30°) from this safe, charm-preserving
  floor — never start high and pull down. This makes the gate a single-sided decision: converge up
  from safety, don't oscillate down from overshoot.

### G2 — Grounding invariant: feet 0.9941, weight-centered (load-bearing, now lead)

The pipeline imposes a bottom-center feet anchor at 0.9941; FD9's entire carry-forward property
(six derivable slots re-deriving against new art with no rule changes) depends on the re-render
preserving a grounded, weight-centered stance. Grounding is now part of the primary depth fix,
not just a constraint.

- Both feet planted. No lunging, mid-stride lift, raised foot, seated or crouched pose.
- Weight centered over a bottom-center footprint → post-pipeline feet re-normalize to ~0.9941.
- Upright, consistent vertical extent. No deep crouch/hunch/compression that moves the alpha centroid
  and shifts FD9's torso/belt anchors.
- This clause overrides expressiveness where they conflict.

### G3 — Pose latitude: character in the bearing, grounded in the stance

Slight per-character posture variation is wanted (uniform stance = mannequins). Because the turn is
now gentle, drama and expression no longer compound, so latitude is safer than under V1 — but
the stance stays fixed:

- **Vary:** head tilt, gaze, gesture, weapon/tool-hold, shoulder attitude, expression, bearing.
- **Hold:** upright standing figure, consistent vertical extent, both feet grounded, weight centered.
- Characterful identity posture is preserved but not deepened. Where a character's identity
  includes a posture (e.g. Brindle's slight lean under his overpacked bedroll), keep the slight
  characterful version — it is part of his silhouette (G5) — but do not deepen it into a hunch or
  crouch that breaks G2.

### G4 — Lighting: room-consistent directional key (now lead depth mechanism)

The biggest charm-free depth gain. Replace flat head-on lighting with a directional key light from
the same side the cutaway interiors are lit, plus soft fill and the existing gentle warm rim, so the
figure shares the room's light logic. The cutaway interiors are the lighting reference — match their
key direction (confirm the actual room key direction; the in-room calibration validates it).

### G5 — Hold-constant set (this is a re-render)

Inherited from the original prompts, unchanged — any drift is a reject:

- Identity (recognizably the same individual beside the original), proportion/stature,
  costume, palette, silhouette read, canvas + export (2560² master, 1024² export,
  bottom-center normalized), house style.
- Per-character identity strings are reused verbatim from the recovered original prompts; this
  spec supplies only the facing/lighting/grounding deltas.
- **House-block standardization:** the original prompts drifted across batches — earlier generations
  used a lighter house block, later ones a hardened block with explicit anti-anime/anti-JRPG
  guards. Lock the hardened house block for all 45 (it is strictly better and already the recent
  standard). This is the one deliberate cross-cast normalization permitted.

### G6 — Generation method: image-referenced from the original (identity anchor)

The originals were pure text-to-image (no reference image); re-prompting from text alone would
produce a matching character, not the same one (identity drift → fails the turntable gate). So:

- Re-render **image-referenced:** pass the character's original generation as the identity anchor
  (via its Higgsfield job ID as a reference media — this also avoids the CDN egress block, since
  Higgsfield references its own job internally), with the prompt supplying only the re-pose/lighting
  deltas. Model `nano_banana_2`, 2K, 3:4, as the manifest.
- If image-referenced cannot hold identity through even the gentle turn on the calibration trio, fall
  back to text-prompt with the verbatim identity block at the gentle floor — but image-referenced is
  the default for fidelity.

---

## The calibration gate (one pass, fail-cheap, single-direction)

Single pass over all 45, front-loaded with a 3-sprite calibration gate so a bad recipe fails at
3, not 45. Trio = the geometric/body-type extremes (also FD9's acceptance set):

- **Brindle** — shortest (does the gentle turn + grounding hold his lean without compressing).
- **Borrin** — tallest (frame + grounding at scale).
- **Keebo** — kobold/non-human (silhouette + identity survive a turn at all).

Judged on BOTH axes, independently:

- **Turntable (identity):** each re-render beside its original — unmistakably the same character;
  costume/palette/silhouette/proportion/face intact. Judges identity survived.
- **In-room (depth):** each dropped into a cutaway room at detail-view scale (22% / ~116 px character,
  FD9 D5) — reads as standing in the room, grounded, room-lit. Judges depth got solved.

A trio sprite passes only if both pass. They fail independently, and the failing axis says what to
turn: identity fail → tighten the identity reference / reduce angle; depth fail → nudge angle up
(G1), strengthen the key light (G4) before touching anything else. Only when all three pass both
does the locked recipe run the remaining 42. Never push a failing recipe to 42.

Expectation worth stating: lighting + grounding at the gentle floor may already read as "in the room."
If so, that is success — do not climb the angle for its own sake. Climb only to close a depth gap the
gate actually shows.

---

## Acceptance (re-render is done when)

1. All 45 re-rendered on the single locked recipe that cleared the gate.
2. Identity holds across all 45 (turntable on the extremes + a mid-range sample); spine identity
   tests still pass against the new art.
3. Depth reads: sprites in the cutaway read as standing in the room (look-test verdict reversed).
4. Grounding preserved: re-running `measure_sprites.py` yields feet ≈ 0.9941 (within tolerance)
   and head-top/centroid in sane bands → FD9 re-derives clean, no rule changes (only per-sprite
   numbers recompute; bands may shift — that is the model working, re-baseline the test bands).
5. Masters preserved: flat-front masters archived, not overwritten — reversible
   (lose-no-information; consistent with FD8/FD9).

---

## Scope boundary — not decided here

- Mirrored left/right facings for the street (direction-of-travel) — a Slice-2 question; this pass
  is a single canonical gentle 3/4 facing.
- Weapon/hand annotations (FD9 D4) — produced after the re-render, against the new art.
- Outcome-overlay art (Package C) — gated on this re-render + FD9 Phase-3 proof.
- Street-projection policy / Blacksmith re-render (LookTest LT3 owed) — independent; not here.

---

*FD7_IsoFacing_Generation_Spec_V2 · Adventurer Town · 06_Art_and_Audio/Artifacts · gentle 3/4 floor,
lighting + grounding lead, image-referenced; calibrate Brindle/Borrin/Keebo on identity + depth, climb
the angle only if depth reads short, then run 42 · supersedes uncommitted V1 · 2026-06-22*
