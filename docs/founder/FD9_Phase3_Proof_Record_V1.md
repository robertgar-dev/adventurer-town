# FD9 Phase 3 — Synthetic-Mark Registration Proof Record (V1)

**Working Title:** Adventurer Town
**Version:** V1
**Status:** RATIFIED — **PASS WITH EXCLUSION** (founder by-eye verdict, 2026-07-02)
**Ratifies:** the FD9 Phase 3 synthetic-mark registration proof (executed as the "Phase C" proof
task — the two names refer to the same gate; FD9 and FD7 say "Phase 3", the proof task and its
report say "Phase C").
**Evidence base:** `docs/FD9_PhaseC_SyntheticMark_Proof_Report_V1.md` (measured report, no pass
asserted) · proof sheets `docs/proofs/fd9_phasec/proof_{brindle,durnik,keebo,nym,borrin}.png` ·
numeric data `docs/proofs/fd9_phasec/measured.json` (committed at `5d951b4`).
**Governs:** the Package C generation gate defined in
`Package_C_Outcome_Overlay_Scope_V1` (⛔ Precondition section).
**Authority:** FD9 (`Slot_Registration_Decision_Record_V1`) Phase 2/3; founder ratification
prompt of 2026-07-02 (doc-only authorization).

---

## 1. What ran

- **Resolver under proof:** `OverlayAnchorResolver.resolve(OverlaySlot, SpriteGeometry) → SlotAnchor`
  (`lib/src/domain/overlay_anchor_resolver.dart`) — the FD9 D3 content-relative resolver,
  pure and scale-independent, proved at code-repo HEAD `f766c61` (= FD9-cited baseline
  `9043712` + the 3 commits that *are* the FD9 implementation).
- **Test sprites (5), spanning the cast's content envelope** (metric = `bbox_h_frac`, measured
  from `sprite_geometry.json`):

  | Sprite | `bbox_h_frac` | Role in span |
  |---|---|---|
  | Brindle | 0.6611 | smallest visible content (min; the binding legibility case) |
  | Durnik | 0.7070 | lower-mid interior |
  | Keebo | 0.7725 | non-human (kobold) |
  | Nym | 0.8037 | upper-mid interior |
  | Borrin | 0.8984 | tallest content (max) |

- **Slots proven (6 of 7):** `headFace`, `shouldersCloak`, `packBack`, `torsoArmor`, `beltHands`,
  `feetPosture` — the six proportionally derivable slots per FD9 D3.
  `weaponToolEdge` excluded per FD9 D4 (see §4).
- **Both render scales (FD8 A1, 22% of viewport height):**
  - Steam Deck detail-view — frame 176 px; Brindle visible content ≈ **116 px**, the binding
    character-space floor per FD9 D5;
  - 1080p detail-view — frame ≈ 238 px (Brindle ≈ 157 px).
- **Script:** `tools/fd9_phasec_proof_scratch/phasec_proof_render_test.dart` — throwaway proof
  harness, deliberately not committed (gitignored at `8be233f`). The render path used the real
  resolver anchor × the real FD8 22% transform over the shipped 1024² assets, with the synthetic
  mark composited under one shared downscale (never pre-baked).
- **Proof images:** `docs/proofs/fd9_phasec/proof_brindle.png`, `proof_durnik.png`,
  `proof_keebo.png`, `proof_nym.png`, `proof_borrin.png` (+ `measured.json`).

## 2. Per-sprite × slot results (proof session self-assessment — advisory)

Every derivable resolve call returned `DerivedAnchor`; **no call threw; every anchor landed
inside the sprite's measured content bbox.** Anchor y (frame-fraction) per slot:

| Slot | D3 rule | Brindle | Durnik | Keebo | Nym | Borrin | returned / inside bbox |
|---|---|---|---|---|---|---|---|
| headFace | `bbox_top` | 0.333 | 0.287 | 0.222 | 0.190 | 0.096 | DerivedAnchor / ✅ all |
| shouldersCloak | `+0.12·bbox_h` | 0.412 | 0.372 | 0.314 | 0.287 | 0.204 | DerivedAnchor / ✅ all |
| packBack | `+0.30·bbox_h` | 0.531 | 0.499 | 0.453 | 0.432 | 0.365 | DerivedAnchor / ✅ all |
| torsoArmor | mass centroid | 0.635 | 0.616 | 0.603 | 0.604 | 0.553 | DerivedAnchor / ✅ all |
| beltHands | `+0.60·bbox_h` | 0.730 | 0.711 | 0.685 | 0.673 | 0.635 | DerivedAnchor / ✅ all |
| feetPosture | 0.9941 | 0.994 | 0.994 | 0.994 | 0.994 | 0.994 | DerivedAnchor / ✅ all |

Head-top anchors track the measured full-cast head drift (0.0957 → 0.3330 = 0.237 of frame —
the drift that made fixed-canvas registration untenable). Legibility at the 116 px floor:
synthetic-mark stroke measured **2.75 px** (full extent 28.9 px, anchor dot ⌀ 2.41 px) — above
one device pixel with margin; the repo defines no numeric "chunky pixel", so the report gave
measured px + the visible read rather than asserting a pass (its stated discipline).

The proof report **asserted no PASS**; acceptance was explicitly reserved for human inspection
of the proof sheets. That inspection is the ratifying act below.

## 3. The ratifying act — founder by-eye verdict

> **VERDICT: PASS WITH EXCLUSION** — derivable slots pass; `weaponToolEdge` remains
> excluded-pending-annotation.

Delivered by the founder on **2026-07-02**, in response to the FD9 Phase 3 ratification prompt,
after by-eye review of the five proof sheets at both scales. The by-eye ruling governs over the
proof run's self-assessment; here the two agree (self-assessment advisory-positive on all six
derivable slots; founder confirms by eye).

## 4. Exclusion — `weaponToolEdge` (verbatim scope)

For all 5 sprites the resolver returned **`RequiresAnnotation`** (not a thrown error, not a
guessed anchor). No per-sprite weapon annotations exist for any sprite — the 45-annotation pass
has not been done (confirmed absent). This is a known separate dependency per FD9 D4, not a
resolver failure.

**Annotation data required to prove this slot later:** a per-sprite weapon/tool-edge anchor
(frame-fraction x, y, authored against the sprite's pose — weapon position is pose-dependent and
non-derivable) for each of the **45 cast sprites**, consumed by the resolver's annotation path;
followed by a **supplementary registration proof** of the weapon slot on the same 5-sprite span
at both scales. Until then, `weaponToolEdge` registration is unproven and everything that
depends on it stays gated.

## 5. The ruling

**FD9 Phase 3 PASSED (with the weaponToolEdge exclusion). The Package C precondition is
satisfied partially:** the generation gate lifts **only for stamps on the six proven slots**;
every stamp touching `weaponToolEdge` stays gated pending the 45-annotation pass + supplementary
proof.

### Cleared vs. gated — enumerated from the scope doc's service-slot table (51 total)

Per `Package_C_Outcome_Overlay_Scope_V1` (17 service-slot pairs × 3 grades; 51 is the doc's
floor pending its own vocabulary reconciliation flag):

**Cleared — 48 stamps (16 service-slot pairs × 3 grades):**

| Service | Cleared slots | Cleared stamps |
|---|---|---|
| Inn | head, shoulders, pack, feet | 12 — `ovl_inn_{head,shoulders,pack,feet}_{humble,established,grand}` |
| Tavern | head, belt, feet | 9 — `ovl_tavern_{head,belt,feet}_{humble,established,grand}` |
| Blacksmith | shoulders, torso, belt | 9 — `ovl_blacksmith_{shoulders,torso,belt}_{humble,established,grand}` |
| Healer | head, shoulders, torso, feet | 12 — `ovl_healer_{head,shoulders,torso,feet}_{humble,established,grand}` |
| Market | belt, pack | 6 — `ovl_market_{belt,pack}_{humble,established,grand}` |

**Gated — 3 stamps (1 service-slot pair × 3 grades):**

- `ovl_blacksmith_weapon_humble`
- `ovl_blacksmith_weapon_established`
- `ovl_blacksmith_weapon_grand`

Gate condition for the remainder: FD9 D4 45-sprite weapon annotation pass + supplementary
registration proof (see §4), then a founder ruling on that proof.

### What this ruling does NOT authorize

Package C **generation is not authorized by this record.** The gate-lift satisfies the proof
precondition only. The production run remains a separate, future founder authorization, and the
scope doc's open production decisions (production method; weapon-annotation sequencing) still
need rulings before any stamp is commissioned.

## 6. Filing note — scope-doc delivery

At ratification time, `Package_C_Outcome_Overlay_Scope_V1` existed only as the founder-authored
file in `C:\Users\rober\Downloads\` — confirmed absent from both repos by the proof report (§6.2),
`docs/Provenance_Report_2026-06-28.md`, and `docs/M12/M12_Attachment_Plan_V1.md` §Open items.
As part of this ratification it was delivered verbatim to its declared canonical path
(design repo `06_Art_and_Audio/Artifacts/Package_C_Outcome_Overlay_Scope_V1.md`) and copied to
code-repo `docs/founder/Package_C_Outcome_Overlay_Scope_V1.md`, per the established FD delivery
pattern (CLAUDE.md §IV amendment note). The single status-line amendment recording this ruling
was applied to both copies; the pre-amendment status line is quoted in the governance commit.

---

*FD9_Phase3_Proof_Record_V1 · Adventurer Town · docs/founder · ratified 2026-07-02 ·
PASS WITH EXCLUSION · Package C gate lifted for 48 of 51 stamps*
