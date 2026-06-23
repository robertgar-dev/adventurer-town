# FD9 Phase C — Synthetic-Mark Registration Proof: Measured Report

**Status:** Proof **executed** — measured evidence produced. **No PASS is asserted; the Phase C
gate is not changed.** Acceptance is a human inspection of the proof sheets (see Conclusion).
**Task:** `FD9_PhaseC_SyntheticMark_Proof_Task_V1`
**Repo (code):** `Adventerer Town` (Flutter/Dart) · **Repo (design canon):** `AdventurerTown`
**HEAD proved against:** `f766c616a1d9515d313118e89153253a91a0dc77` (`f766c61`, *"Implement FD9 D3
content-relative resolver (+ tests)"*) — **measured**.
**Proof sheets:** `docs/proofs/fd9_phasec/proof_{brindle,durnik,keebo,nym,borrin}.png`
**Measured data:** `docs/proofs/fd9_phasec/measured.json`
**Throwaway harness (not shipping, not committed):**
`tools/fd9_phasec_proof_scratch/phasec_proof_render_test.dart`

> This report **supersedes** the earlier `docs/FD9_PhaseC_SyntheticMark_Proof_ContractDiscovery_V1.md`
> (a Step-1 BLOCKER written at `d3430c5`, when no executable resolver existed). The resolver that
> §7 of that report named as the unblocking precondition was implemented at `f766c61` and is what
> this proof exercises. The blocker doc is now stale.

---

## 1. The contract (discovered, Step 1 — measured)

| Element | Value | Source (measured) |
|---|---|---|
| **Executable resolver** | `OverlayAnchorResolver.resolve(OverlaySlot, SpriteGeometry) → SlotAnchor` — pure, scale-independent | `lib/src/domain/overlay_anchor_resolver.dart:130-173` |
| Resolver **inputs** | `SpriteGeometry` from `sprite_geometry.json` (`bbox_px`, centroid frac, feet anchor frac, frame `img_w/h`) | `overlay_anchor_resolver.dart:10-77` |
| Resolver **outputs** | `DerivedAnchor(x,y)` (frame-fraction, origin top-left) for 6 slots; `RequiresAnnotation` for weapon | `overlay_anchor_resolver.dart:79-120` |
| What "register a mark" means | resolve a slot → frame-fraction anchor; the render layer multiplies by the on-screen frame size to place the stamp. No scale is baked into the model. | `overlay_anchor_resolver.dart:85-92` |
| `OverlaySlot` grammar (7) | `headFace, shouldersCloak, torsoArmor, beltHands, packBack, weaponToolEdge, feetPosture` | `character_definition.dart:14-35` |
| D3 anchor rules | head=`bbox_top`; shoulders=`bbox_top+0.12·bbox_h`; pack=`bbox_top+0.30·bbox_h`; belt=`bbox_top+0.60·bbox_h`; torso=mass centroid; feet=existing 0.9941; weapon=deferred | `overlay_anchor_resolver.dart:133-171`; FD9 D3 |
| D4 weapon dependency | `weaponToolEdge` → `RequiresAnnotation` (pose-dependent; 45 per-sprite annotations owed) | `overlay_anchor_resolver.dart:169-170`; FD9 D4 |
| **D5 legibility floor** | **116 px** character-space (Brindle on Steam Deck; ≈157 px @ 1080p) + one-chunky-pixel margin | `overlay_registration.dart:9`; FD9 D5 |
| **Detail-view scale (FD8 A1)** | **22%** of viewport height; full 1024² frame scaled to that height | `building_detail_game.dart:118`; FD8 A1 record |
| Master authoring scale | **2560² (2K)** masters; shipped assets are the 1024² downscale; detail-view is a further downscale, never redrawn | FD8 A1; `process_sprites.py` |
| Content metric | **`bbox_h_frac`** (vertical content extent ÷ frame) — *not* `content_fraction` (alpha coverage) | `sprite_geometry.json`; FD9 §Context |

The resolver constants are a 1:1 transcription of the FD9 D3 rule strings in
`overlay_registration.dart` and are cross-checked by the shipped resolver tests
(`test/domain/overlay_anchor_resolver_test.dart`, **61 tests green at this HEAD — measured**).

---

## 2. Proof span (Step 1 — measured + my picks)

Metric = `bbox_h_frac` (measured from `sprite_geometry.json`). The task's stated 0.661 / 0.898
**match** this metric exactly.

| Sprite | `bbox_h_frac` | `head_top_y` | Role | Label |
|---|---|---|---|---|
| **Brindle** | **0.6611** | 0.3330 | smallest visible (min) | measured — matches task's 0.661 |
| **Durnik** | **0.7070** | 0.2871 | mid-range A | **my choice (inferred selection)** — lower-mid interior |
| **Keebo** | **0.7725** | 0.2217 | non-human (kobold) | measured |
| **Nym** | **0.8037** | 0.1904 | mid-range B | **my choice (inferred selection)** — upper-mid interior |
| **Borrin** | **0.8984** | 0.0957 | tallest (max) | measured — matches task's 0.898 |

All 5 assets confirmed present: `assets/characters/char_{brindle,durnik,keebo,nym,borrin}.png`
(cast is 45/45 — measured). The two mid-range picks sit strictly inside the extremes and split the
interior (0.707 lower-mid, 0.804 upper-mid).

The head-top anchor the resolver returns equals each sprite's measured `head_top_y` and spans
**0.0957 (Borrin) → 0.3330 (Brindle) = 0.237 of the frame** — the exact full-cast head drift FD9
predicted, and the reason fixed-canvas registration was rejected. The resolver tracks it.

---

## 3. Per-(sprite, slot) registration — measured

Render path = the real resolver anchor × the FD8 22% transform; mark composited under one shared
downscale (never pre-baked). `anchor` = frame-fraction `(x, y)`. `inside bbox` = anchor within the
sprite's measured content bounding box. **Weapon is excluded here per FD9 D4** (§4). Every derivable
call returned `DerivedAnchor`; **no call threw; every anchor landed inside the content bbox.**

**Anchor y (frame-fraction) per slot** — note how each row scales with the sprite's content:

| Slot | rule | Brindle | Durnik | Keebo | Nym | Borrin | returned / inside bbox |
|---|---|---|---|---|---|---|---|
| headFace | `bbox_top` | 0.333 | 0.287 | 0.222 | 0.190 | 0.096 | DerivedAnchor / ✅ all |
| shouldersCloak | `+0.12·h` | 0.412 | 0.372 | 0.314 | 0.287 | 0.204 | DerivedAnchor / ✅ all |
| packBack | `+0.30·h` | 0.531 | 0.499 | 0.453 | 0.432 | 0.365 | DerivedAnchor / ✅ all |
| torsoArmor | centroid | 0.635 | 0.616 | 0.603 | 0.604 | 0.553 | DerivedAnchor / ✅ all |
| beltHands | `+0.60·h` | 0.730 | 0.711 | 0.685 | 0.673 | 0.635 | DerivedAnchor / ✅ all |
| feetPosture | 0.9941 | 0.994 | 0.994 | 0.994 | 0.994 | 0.994 | DerivedAnchor / ✅ all |

The anchor x is the content-bbox horizontal center for all non-torso slots (≈0.499 across the span;
torso uses the mass centroid x, e.g. Borrin 0.547 — leaning to the sprite's mass, by design). Full
numeric detail (x, y, Deck-floor px, 1080p px) is in `measured.json`.

Sanity reads visible on the sheets: head sits at the crown, feet at the base, the four mid-slots
descend in fixed body proportion, and the spacing **compresses on Brindle** (short content) and
**expands on Borrin** (tall content) — i.e. content-relative registration is doing its job.

---

## 4. Weapon slot (`weaponToolEdge`) — FD9 D4 status (measured)

For all 5 sprites the resolver returned **`RequiresAnnotation`** (not a thrown error, not a guessed
anchor). **No per-sprite weapon annotations exist** for any sprite (the 45-annotation pass has not
been done — confirmed absent). This is a **known separate dependency (the annotation pass), not a
resolver failure**, exactly as the task and FD9 D4 anticipate. The Phase C mechanism proof rides on
the **6 derivable slots**, which all registered.

---

## 5. Legibility at the floor (FD9 D5) — measured

Each composite was downscaled to the **Steam Deck detail-view** (frame **176 px**; Brindle visible
content = 0.6611 × 176 ≈ **116 px** — the binding floor) and, for reference, the **1080p**
detail-view (frame ≈238 px).

The synthetic mark is authored in master (1024-frame) space and scaled with the sprite. **Measured
rendered mark dimensions at the 116 px floor** (identical across sprites and slots, since the mark is
content-independent):

| Quantity | At 116 px floor (Deck, frame 176) | At 1080p (frame 238) |
|---|---|---|
| Crosshair full extent | **28.9 px** | 39.0 px |
| Arm stroke width | **2.75 px** | 3.71 px |
| Center anchor dot ⌀ | **2.41 px** | — |

At the floor the thinnest mark feature (the 2.75 px stroke) is **well above 1 device pixel**, so the
mark carries a clear margin over the "one-chunky-pixel" legibility floor and reads on the bottom row
of every proof sheet. *(Caveat — labeled inferred: the repo defines no numeric "chunky pixel" size;
"one chunky pixel" is FD9/FD8 prose. I therefore report the measured device-pixel dimensions and the
visible read, rather than asserting a pass against an undefined constant.)*

---

## 6. Contradictions surfaced (Discipline #6)

1. **Baseline-commit mismatch (reconciled, benign).** The proof task and FD9 cite baseline HEAD
   **`9043712`**. Actual HEAD is **`f766c61`** = **`9043712` + 3 commits** (measured): `d3430c5`
   enum 4→7, `5d5536d` Phase B substrate registration, `f766c61` the D3 resolver. Those 3 commits
   *are* the FD9 implementation; the resolver this proof needs exists **because** HEAD is ahead of
   the cited baseline. (At the baseline itself there was no resolver — which is why the prior
   discovery report was blocked.)
2. **`Package_C_Outcome_Overlay_Scope_V1` does not exist** in either repo (search-confirmed; only
   pub-cache noise matches). The proof names it as the gated consumer, and it cites a "12-stamp
   Blacksmith pilot / 51 stamps". Those figures are not in the repo; the service vocabulary implies
   5 services × 3 grades. *(inferred gap — absence is measured; the count reconciliation is inferred.)*
3. **The "chunky pixel" margin is not numerically defined** anywhere in the repo or design canon
   (FD8/FD9 use it only as prose). Handled per §5: measured px reported, no pass asserted against an
   undefined unit. *(measured absence.)*
4. **Render source is the 1024² shipped asset, not the 2560² master.** The resolver is
   scale-independent (frame-fractions), so this does not affect anchors; the 22% transform is applied
   from the shipped asset, which is the real runtime art path. Masters were not touched. *(measured;
   noted for completeness.)*

---

## 7. Measured-vs-inferred summary

- **Measured:** HEAD `f766c61`; the resolver exists and is the artifact under proof (full read +
  61 green tests); 7-token grammar; D3/D4/D5 rules; 22% scale; 116 px floor; 2560² masters / 1024²
  assets; all 5 sprites present; `bbox_h_frac` incl. Brindle 0.6611 / Borrin 0.8984; per-(sprite,slot)
  anchors (all `DerivedAnchor`, all inside content bbox, none threw); weapon → `RequiresAnnotation`
  with annotations absent; floor mark dimensions (28.9 px extent / 2.75 px stroke); `9043712` = HEAD~3.
- **Inferred:** my two mid-range picks (Durnik 0.707, Nym 0.804); that the missing Package C scope
  doc's 12-/51-stamp counts map onto the 5×3 service-grade vocabulary; that "content metric" in the
  task = `bbox_h_frac` (values match and FD9 uses it as the span metric); the legibility judgement
  against the undefined "one-chunky-pixel" margin (reported as measured px + visible read, not a pass).

---

## 8. What a human should check on the sheets

Open `docs/proofs/fd9_phasec/proof_*.png`. Per sprite, top row = 1080p detail-view, bottom row =
116 px Steam Deck floor; each cell isolates one slot (color-coded), with an "ALL 6" cell. Confirm,
per sprite: **headFace** sits at the crown, **shouldersCloak** just below, **packBack** upper-back,
**torsoArmor** at mid-mass, **beltHands** at the waist, **feetPosture** at the base — and that each
mark still reads on the bottom (floor) row.

---

*Measured finding: across the proof span (Brindle 0.661, Durnik 0.707, Keebo 0.773, Nym 0.804,
Borrin 0.898), the content-relative resolver registered the synthetic mark for all 6 derivable slots
with zero throws, every anchor inside the sprite's content bounds, anchors that track each sprite's
content geometry, and a mark that measures 2.75 px stroke at the 116 px floor; the weapon slot
returned `RequiresAnnotation` (separate dependency, per FD9 D4).*
**Acceptance (Phase C green / no-go) is a human inspection of the proof sheet, not asserted here.**
No real Package C outcome-overlay art was authored or commissioned; nothing shipping was modified.
