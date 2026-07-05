# Package C — Outcome-Overlay Stamp Scope

**Working Title:** Adventurer Town
**Version:** V1
**Status:** DEFINITION — **PARTIALLY CLEARED for generation** (48 of 51 stamps), per the FD9 Phase 3 proof ratification of 2026-07-02 (**PASS WITH EXCLUSION** — see code-repo `docs/founder/FD9_Phase3_Proof_Record_V1.md`). Cleared: all stamps on the six derivable slots. Still gated: `ovl_blacksmith_weapon_{humble|established|grand}` (weaponToolEdge), pending the 45 per-sprite weapon annotations (FD9 D4) + a supplementary registration proof. **PILOT AUTHORIZED 2026-07-05** for the 9 non-weapon Blacksmith stamps only, production method ruled **HYBRID** (AI-assisted draft → manual finish → committed pipeline; no generation-pipeline code) — see code-repo `docs/founder/Package_C_Pilot_Authorization_2026-07-05.md`. All other generation remains a separate founder authorization (see Precondition and Open production decisions).
**Document Path:** `06_Art_and_Audio/Artifacts/Package_C_Outcome_Overlay_Scope_V1.md`
**Date:** 2026-06-21
**Depends on:** `Slot_Registration_Decision_Record_V1` (FD9 — registration model, 7-slot grammar, ~116 px floor); `Detail_View_Render_Scale_Decision_Record_V1.1` (FD8 A1 — 22% detail-view scale); `Service_Vocabulary_and_Outcomes_V1` (slot grammar source); `Amenity_Module_System_V1` (3-grade ladder).
**Grounded in:** Gate 2 Phase 1 service-slot incidence (45 sprites measured @ code-repo HEAD `9043712`).

---

## ⛔ Precondition — this is a definition, not a generation order

No outcome-overlay art is generated or authored until **FD9's Phase C synthetic-mark proof passes** — i.e., the content-relative resolver is shown to register a synthetic mark correctly on Brindle (0.661), Borrin (0.898), Keebo (non-human), and two mid-range sprites at 22% scale. This document specifies *what* Package C is so it is ready to execute the instant that gate clears. Building the spec now does not advance the gate. **Do not commission stamps against this doc until the proof is green.**

---

## Purpose

Define the complete set of outcome-overlay stamps — the small graphic marks layered onto adventurer sprites to show the *quality of service a town's buildings delivered* (better armor from a Grand Blacksmith, a real meal from an Established Tavern, etc.). Each stamp is drawn **once** and reused across all 45 cast sprites via the FD9 content-relative resolver; it is never repainted per character.

---

## Production unit & naming grammar

The unit of production is **(service × slot × grade)**.

**Filename:** `ovl_[service]_[slot]_[grade].png`

- **service** (5): `inn` · `tavern` · `blacksmith` · `healer` · `market`
- **slot** (7 tokens, mapping to the FD9 `OverlaySlot` enum):
  `head` (headFace) · `shoulders` (shouldersCloak) · `torso` (torsoArmor) · `belt` (beltHands) · `pack` (packBack) · `weapon` (weaponToolEdge) · `feet` (feetPosture)
- **grade** (3): `humble` · `established` · `grand`

Example: `ovl_blacksmith_torso_grand.png`. *(This supersedes the legacy `ovl_blacksmith_gleaming_weapon` example — "gleaming" is replaced by the canonical grade token.)*

---

## Asset count (grounded baseline)

From the Phase 1 service→slot incidence: **17 service-slot pairs × 3 grades = 51 stamps.**

| Service | Slots used | Service-slot pairs | Stamps (×3 grades) |
|---|---|---|---|
| Inn | head, shoulders, pack, feet | 4 | 12 |
| Tavern | head, belt, feet | 3 | 9 |
| Blacksmith | shoulders, torso, belt, weapon | 4 | 12 |
| Healer | head, shoulders, torso, feet | 4 | 12 |
| Market | belt, pack | 2 | 6 |
| **Total** | | **17** | **51** |

**Reconciliation flag (the one input that can raise this):** 51 assumes **one outcome stamp per service-slot pair**. If `Service_Vocabulary_and_Outcomes_V1` enumerates more than one distinct *outcome variant* on any single service-slot (e.g., Blacksmith→weapon as both "sharpened" and "reforged"), the count rises by 3 per extra variant. Reconcile the full manifest below against the vocabulary doc's outcome list before generation; treat 51 as the floor.

---

## Per-stamp requirements (every stamp must satisfy all)

1. **Registration (FD9 D3):** authored to register at its slot's content-relative anchor. The slot's reference point on the sprite is the resolver's output; the stamp's own anchor/origin must align to it. Slots and their anchors per FD9 D3.
2. **Legibility floor (FD9 D5):** must read clearly at the **~116 px character height on Steam Deck** (Brindle, the smallest visible character; ≈157 px at 1080p), plus a one-chunky-pixel safety margin. If it turns to mud at 116 px, it fails.
3. **Master authoring scale:** authored at the **2K master scale** to match the sprite pipeline and master-relative registration, then validated at the 116 px Deck render. (Masters stay 2560²; overlays downscale with the sprite under the same transform — never bake a downscale into the stamp.)
4. **Clean alpha:** true transparency, hard-edged where the HD-2D pixel style requires it; no halo, no background fringe. Stamps are composited over arbitrary sprite pixels.
5. **House-style consistency:** the locked Adventurer Town HD-2D look — crisp chunky pixel marks, grounded materials, warm saturated color, no glow/no magic spectacle, no decorative clutter. A stamp must look like it belongs on the same sprite it sits on.
6. **Slot-appropriate silhouette:** the mark must read as the right *kind* of thing for its body region (a torso stamp reads as armor/garment change; a feet stamp as posture/footwear; a pack stamp as carried goods).

---

## Grade-ladder semantics (Humble / Established / Grand)

The grade is the **quality tier of the building that served the adventurer** (per `Amenity_Module_System_V1`), shown as three visual tiers of the *same* outcome on the same slot:

- **Humble** — basic, functional, a little worn. The service happened, modestly.
- **Established** — solid, clean, competent. The expected good outcome.
- **Grand** — refined, polished, visibly superior. The premium result.

All three are the same outcome on the same slot — not three different outcomes. Example (Blacksmith → torso): humble = patched/serviceable mail; established = solid clean armor; grand = ornate, gleaming-finish armor (within house-style limits — sheen, not magic glow).

---

## Full stamp manifest (51)

**Inn** — `head`, `shoulders`, `pack`, `feet` × {humble, established, grand}
→ 12: `ovl_inn_head_{humble|established|grand}`, `ovl_inn_shoulders_*`, `ovl_inn_pack_*`, `ovl_inn_feet_*`

**Tavern** — `head`, `belt`, `feet` × 3
→ 9: `ovl_tavern_head_*`, `ovl_tavern_belt_*`, `ovl_tavern_feet_*`

**Blacksmith** — `shoulders`, `torso`, `belt`, `weapon` × 3
→ 12: `ovl_blacksmith_shoulders_*`, `ovl_blacksmith_torso_*`, `ovl_blacksmith_belt_*`, `ovl_blacksmith_weapon_*`

**Healer** — `head`, `shoulders`, `torso`, `feet` × 3
→ 12: `ovl_healer_head_*`, `ovl_healer_shoulders_*`, `ovl_healer_torso_*`, `ovl_healer_feet_*`

**Market** — `belt`, `pack` × 3
→ 6: `ovl_market_belt_*`, `ovl_market_pack_*`

---

## Open production decisions (need ruling before generation)

1. **Production method — the key unsettled call.** The cast was generated as full characters via Higgsfield `nano_banana_2`. Outcome stamps are different: small marks requiring precise clean alpha, exact registration, legibility at 116 px, and tight consistency across 51 assets — all things diffusion models do *poorly*. Options:
   - (a) **Pure generation** (Higgsfield → rembg cleanup): fastest, but high risk on alpha, consistency, and tiny-detail legibility.
   - (b) **Hand-authored pixel stamps:** most control, best alpha and consistency, highest labor.
   - (c) **Hybrid:** generate a concept/reference per stamp, hand-finish to final pixel art at the 116 px floor.
   - *Recommendation:* lean (b)/(c), not (a). This likely warrants its own founder ruling, since it departs from the cast pipeline and sets the per-stamp cost model. **Do not default to Higgsfield generation by inertia.**

2. **Weapon-slot dependency (FD9 D4).** The 3 `blacksmith_weapon_*` stamps are authored like any other, but they can only *register* once the **45 per-sprite weapon annotations** exist (weapon position is pose-dependent and non-derivable). The annotation pass is a prerequisite specifically for the weapon slot — sequence it before, or in parallel with, the weapon stamps; the other 48 stamps have no such dependency.

---

## Sequencing (once the Phase C proof passes)

1. **Pilot one service end-to-end first** — recommend **Blacksmith** (it exercises the hardest cases: the annotated `weapon` slot and the `torso` centroid slot). Produce its 12 stamps, register them on the 5-sprite proof span, confirm they read at 116 px and look consistent across grades.
2. **Ratify the production method** from the pilot result (decision #1 above) before committing the remaining 39.
3. **Produce the remaining four services** (Inn, Tavern, Healer, Market) against the proven method.
4. **Weapon annotations (45)** sequenced as a dependency for the Blacksmith weapon slot.

---

## Scope boundary — not in Package C

- **The registration mechanism itself** — owned by FD9 + the Gate 2 implementation; Package C consumes it.
- **Per-sprite weapon annotations (45)** — a sprite-side data task (FD9 D4), prerequisite to the weapon slot, not a stamp.
- **Which (service, grade, slot) combinations are economically *triggered* in-game** — governed by the simulation + `Service_Vocabulary_and_Outcomes_V1`, not this art spec. Package C produces the art; the sim decides when a stamp shows.
- **Building art / audio** — separate packages (M12 Stage 2 / later).

---

*Package_C_Outcome_Overlay_Scope_V1 · Adventurer Town · 06_Art_and_Audio/Artifacts · 2026-06-21 · baseline 51 stamps, gated on FD9 Phase C proof*
