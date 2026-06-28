# Detail-View Render Scale — Founder Decision Record

**Working Title:** Adventurer Town
**Version:** V1
**Status:** LOCKED (provisional, reversible) — ratification pending one live-run confirmation
**Document Path:** `06_Art_and_Audio/Artifacts/Detail_View_Render_Scale_Decision_Record_V1.md`
**Date:** 2026-06-21
**Resolves:** `Asset_Production_Plan_V2` §10 open question (in-game scale — *detail-view portion only*); `Spatial_TownView_Founder_Decision_Record` owed item (detail-view zoom/scale).
**Filing note:** May be folded into the Spatial record as **FD8** at the founder's discretion; kept standalone here for focus.

---

## Purpose

Unblock **Package C (Outcome-Overlay Stamps)** by resolving the only scale dependency overlays actually have — the detail-view render size — without waiting on the town-view / street scale, which depends on Slice 2 and is deliberately left open.

---

## Context — the tension, decomposed

"Scale lock" was being treated as one monolithic gate ("lock the whole town-view"). It isn't. Two distinct scales were conflated:

- **Street / town-view scale** — sprite size on the navigable iso street. Depends on Slice 2 (street surface, facade zoom). Not built. **Stays open.**
- **Detail-view scale** — sprite size when zoomed into one building's rooms. Produced by **Slice 1**, already built.

Package C stamps are *read* only in the detail view, and the detail view is the **larger** of the two scales — so it is the binding legibility constraint. Street scale is irrelevant to authoring overlays; anything authored to read at detail-view size simply shrinks with the sprite if it ever appears on the street.

Two further things "scale" was bundling, now separated:

- **Registration** (does a stamp land on the right pixel of the sprite) — **master-relative**: defined in the sprite's 2560² coordinate space plus the reserved overlay slots, and it downscales under one uniform transform. **Independent of on-screen scale.**
- **Legibility** (does a stamp's detail survive at final size) — the **only** thing that needs a number.

So the decision reduces to fixing one legibility target and the scaling method that serves it.

---

## Decisions

**D1 — Detail-view sprite height is defined as a fraction of viewport height, not an absolute pixel count.**
Locked value: **detail-view sprite ≈ 22% of viewport height.** Resolution-independent — one decision covers Steam Deck, 1080p, 1440p, and mobile with no per-device tuning.

**D2 — The Package C overlay authoring floor is the smallest size a sprite ever renders.**
On the **Steam Deck (1280×800)** — the smallest screen on the primary platform — 22% ≈ **~170 px** tall. Every outcome stamp is authored and validated against a **~170 px reference sprite, plus one chunky-pixel safety margin.** If a stamp reads there, it reads at every larger size (≈240 px at 1080p, more at 1440p). This **~170 px floor is the binding Package C art spec.**

**D3 — Scaling method is fractional fit from the 2560² masters, not fixed virtual-resolution integer scaling.**
Rationale: the Deck's 800-px height is not an integer multiple of a clean virtual resolution; the HD-2D rendered environments want smooth scaling; and because every asset is downscaled from far above target (2560²), fractional scale stays clean on the pixel characters. Integer-only scaling is explicitly **rejected** for this project.

**D4 — Registration (Package C Gate 2) is unaffected by this record.**
Overlay slots live in the sprite's 2560² master coordinate space. The 22% / ~170 px figures govern **legibility only**. The two gates remain independent and can be worked in parallel.

**D5 — This lock is provisional and reversible by design.**
Masters remain 2560²; a change to the detail-view zoom is a downscale **re-export**, never redrawn art. The lock is taken **now**, against the current Slice 1 camera, specifically to unblock the Package C proof stamp. There is no cost to committing early and no art is at risk if the figure later moves.

---

## Scope boundary — not decided here (by design, not open)

- **Street / town-view sprite scale** — set in **Slice 2**, after the street surface and facade zoom exist. Intentionally out of scope.
- **Cutaway interior fidelity** (full vs partial cutaway vs facade-cues) — governed by `Amenity_Module_System_V1` **OQ-4**; a separate dial, not a scale question.

---

## Ratification

This record is a **decision, not a measurement.** The single owed confirmation is that the Slice 1 cutaway camera actually renders sprites at 22% of viewport — and if it does not, the **camera zoom is adjusted to serve the 22% requirement; the requirement itself does not move.**

Confirmation procedure: the Claude Code ratification step (Phase 1 measure → Phase 2 propose-and-hold). On a clean report (Deck sprites at ~22% / ~170 px), status flips from *"ratification pending"* to **LOCKED**.

---

*Detail_View_Render_Scale_Decision_Record_V1 · Adventurer Town · 06_Art_and_Audio/Artifacts · 2026-06-21*
