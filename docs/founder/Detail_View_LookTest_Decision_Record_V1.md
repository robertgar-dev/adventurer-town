# Detail-View Look-Test — Founder Decision Record

**Working Title:** Adventurer Town
**Version:** V1
**Status:** Approved (founder)
**Document Path:** `06_Art_and_Audio/Artifacts/Detail_View_LookTest_Decision_Record_V1.md`
**Date:** 2026-06-21
**Amends:** `Spatial_TownView_Founder_Decision_Record_V1` — **FD2** (single fixed projection) corrected;
**FD7** (sprite re-render) ruled.
**Corroborates:** `Detail_View_Render_Scale_Decision_Record_V1` — the 22% lock (already LOCKED by
measurement) confirmed to read correctly in-scene.
**Basis:** the post-Slice-1 founder look-test — one live `flutter run -d windows` pass, three
building cutaways captured (Inn, Tavern, Blacksmith).

---

## Why this record exists

The Spatial record's build sequencing placed a **founder look-test** between Slice 1 (detail view)
and Slice 2 (street): build the cutaway, place the current sprites in an iso room, *look at them*,
and only then rule FD7. That look-test has now run against real output. It produced three findings —
two expected rulings and one that **contradicts an approved assertion in the Spatial record (FD2).**
Per the project's standing discipline — repository reality over planning assumption — the
contradicted assertion is corrected here, **before** any Slice 2 / facade work is grounded on it.

## The look-test basis

A single live Windows run; three building cutaways observed. The **Inn** and **Tavern** were
populated with sim-driven occupants at the ratified 22% scale; the **Blacksmith** rendered empty.
The empty Blacksmith is consistent with sim-driven occupancy (no adventurer being served there this
tick) — the picture correctly followed the data. Findings below are read from the captured frames,
not asserted.

## LT1 — Sprite facing: re-render for iso (rules FD7)

The current 45 sprites are **flat-front portrait figures**, and in a true-iso room they **do not read
as an intentional billboard convention** — they read as *pasted onto* the scene rather than *standing
in* it. The rooms are authored in genuine 2:1 iso (floors and furniture recede along the iso
diagonals); the figures are lit and posed head-on to camera. The mismatch is legible and consistent
across all three frames. The sprite art quality is high; the problem is purely **facing.**

**Ruling:** FD7 resolves to **re-render the cast for iso-facing depth.** This is now a *looked-at*
decision, not a blind one — the risk the Spatial record flagged (re-rendering 45 sprites twice) is
retired because the need is confirmed by real output. Masters are preserved; nothing was lost by
waiting.

**Note — the contact shadow is not a substitute.** Slice 1.5 added a soft ground-contact shadow under
each figure (placement, not art) to seat sprites on the floor. That helps grounding but does **not**
address facing; it does not solve FD7 and must not be read as having done so.

## LT2 — Detail-view scale reads correct at 22% (corroborates the Scale record)

The 22% detail-view sprite height — already **LOCKED by measurement** in the Scale record
(176 px Deck / 238 px 1080p) — **reads correctly in-scene.** Figures sit inside their zones with clear
headroom (~58% figure-to-zone height, ~40% clearance above), and rooms have visible space for
additional occupants without crowding. The look-test is the visual corroboration the measured
ratification could not provide on its own. **No change.** 22% stands.

## LT3 — Interior projection is NOT uniform (corrects FD2)

**This is the load-bearing finding.** FD2 asserted a single fixed **2:1 dimetric** projection across
*every* asset, and claimed the existing cutaway interiors **already share that angle** and are
therefore the reference the rest matches. The captured frames **disprove the second claim:**

- The **Inn** and **Tavern** are drawn in true **2:1 game-iso** — flat receding diagonal floors, the
  standard dimetric angle.
- The **Blacksmith** is a **different projection** — a near-symmetric two-wall corner view with a
  perspective / vanishing-point feel the others lack. Placed beside the Inn frame, its floor angle
  does not match.

The interior set is therefore **mixed-projection in the current art** — the exact "mixed angles will
not assemble into a coherent scene" condition FD2 named non-negotiable, already present *inside the
building set* before the street exists.

**Correction to FD2.** The clause *"the existing cutaway interiors already read at a consistent iso
angle, so they are the reference the rest matches"* is **factually wrong and is struck.** FD2's
*intent* — one fixed projection, authored to a shared footprint — **stands** as the target. FD2's
*premise* — that the existing interiors already satisfy it — does not. The reference angle is
**2:1 game-iso as exhibited by the Inn/Tavern**, not "the existing cutaways" taken as a uniform set.

**Consequence, decomposed:**

- **Detail view — survivable.** Each building is its own click-in scene, never co-visible with
  another, so the Blacksmith reading at a different angle is a minor inconsistency, not a break. No
  detail-view action is forced.
- **Street (Slice 2) — real blocker.** Facades (B-ext) and ground-tiling demand one projection on a
  shared ground plane. The Blacksmith cannot sit on the same plane as the Inn until the mismatch is
  resolved. This **must** be decided before B-ext.

## Decided here

1. **FD7 → re-render the cast for iso-facing.** Confirmed by look-test. (The generation angle spec is
   owed — see below.)
2. **Detail-view scale → keep 22%.** Corroborated in-scene; no change.
3. **FD2 corrected → interior projection is mixed, not uniform.** The "existing interiors are the
   matched reference" premise is struck; 2:1 game-iso (Inn/Tavern) is the reference angle.

## Owed (not decided here)

- **Street-projection policy — blocks B-ext / Slice 2.** Two paths: **(a)** re-render the off-angle
  building(s) — at minimum the Blacksmith — to true 2:1 so all interiors and facades share one plane;
  or **(b)** author the street as **facades only**, freshly drawn to 2:1, so the interior projection
  mismatch *never reaches the ground plane* (interiors remain isolated click-ins). **Lean: (b)** —
  cheaper, and it isolates the existing mismatch rather than paying to redraw a finished interior —
  but it is **explicitly owed**, not decided here.
- **The "iso-facing" generation spec for the FD7 re-render.** The precise angle / pose the re-render
  is authored to, so 45 sprites are not done twice. Owed before the re-render fires.
- **Filing reconciliation.** This record amends the Spatial record's FD2 — add a back-reference at
  FD2 pointing here. Separately, the Scale record's pending **FD8** filing (and the `FD8` reference
  already written into code) should be reconciled with the Spatial record's FD-numbering in the same
  pass.

## Non-goals (this record)

- Does **not** re-open the 22% scale (LT2 confirms it).
- Does **not** fire the re-render or define its angle (LT1 rules it *needed*; spec and execution are
  separate and owed).
- Does **not** decide the street-projection policy (owed) or build any Slice 2 surface.
- Does **not** touch sprite masters, the pipeline, manifests, the catalog, or the spine code.

---

*Detail_View_LookTest_Decision_Record_V1 · Adventurer Town · 06_Art_and_Audio/Artifacts · Founder
look-test rulings: FD7 re-render, 22% confirmed, FD2 projection corrected · 2026-06-21*
