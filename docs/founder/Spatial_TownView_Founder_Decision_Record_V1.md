# Adventurer Town — Founder Decision Record: Spatial Town-View

**Version 1** · Status: **Approved (founder)** · Date: 2026-06-20
**Reopens:** `CLAUDE.md` §IV (Town View architecture)
**Promotes:** Design Tension Register **R3** (selective persistence) from reserved → live
**Feeds:** `Claude_Code_Brief_Spatial_Slice1_DetailView_V1.md`

---

## Why this record exists

Claude Code's Phase 2 read-only repo investigation established three facts that force an
architecture decision rather than an art one:

1. **There is no art layer in the game.** No `Image.asset` / `AssetImage` / `.png` references in
   `lib/`. The 45 processed sprites currently have no consumer in code.
2. **The data model is not art-ready.** `Adventurer` has `id`, `displayName`, `tier`, `state`,
   `currentDemandId`, `preferredDemandTypes`, `ticks`, `wealthBand` — but **no character-identity
   field** linking it to the named cast, and no art/sprite field.
3. **The Town View is a state-driven dashboard** (`CLAUDE.md` §IV) — adventurers surface as
   Event-Feed text, not figures. No spatial canvas, no map.

The founder vision — a navigable town street where you watch adventurers enter buildings, peek
through windows at activity inside, see revenue surface as transactions resolve, and click into a
building to see it expand into a full cutaway — is **spatial**. It cannot live on a dashboard. This
record locks that decision and its consequences.

---

## FD1 — The Town View is a spatial scene (§IV reopened)

The Town View becomes a **spatial, living scene**, not a state-driven widget dashboard. `CLAUDE.md`
§IV is formally **reopened and superseded** by this record. The town is "real and living": a place
you see, not a status panel you read.

## FD2 — Projection: isometric, single fixed angle (locked)

The world is **isometric**, authored to **one fixed projection** — standard **2:1 dimetric**
("game iso") unless explicitly revised. Every asset across both render surfaces (facades, the
existing cutaway interiors, environment, sprite placement) is authored to this same angle and a
shared tile footprint. A single projection is non-negotiable: mixed angles will not assemble into a
coherent scene. The existing cutaway interiors already read at a consistent iso angle, so they are
the reference the rest matches.

Amended 2026-06-21 by Detail_View_LookTest_Decision_Record_V1 (LT3): the final sentence of FD2 —
"The existing cutaway interiors already read at a consistent iso angle, so they are the reference
the rest matches" — is struck. Interior projection is mixed in the current art; 2:1 game-iso as
exhibited by the Inn/Tavern is the reference angle. FD2's intent (one fixed projection, shared
footprint) stands.

## FD3 — Two render surfaces on one shared spine

The vision resolves into **two iso render surfaces**, not one, built in sequence:

- **Street (overworld)** — a navigable iso town exterior: buildings as facades along a road,
  adventurers pathing between them, foot traffic, peek-through windows/doors hinting at interior
  activity, and revenue popups as transactions resolve. The ambient living-town layer.
- **Detail (click-in)** — selecting a building expands it into the full iso cutaway (the art we
  already generated), where real occupancy, amenity modules, and grade-flourishing live.

Both surfaces share **one data-driven spine** (FD4). This is the proven sim-game pattern (ambient
outer view + detailed inner view); the two surfaces have different fidelity demands and are built in
separate slices, not at once.

## FD4 — The data model becomes art-ready

The spine both surfaces hang off, and the core net-new work:

- **`CharacterDefinition`** — a table mapping a stable character id → name / tier / art, structured
  for a **layer stack** (base sprite + outcome-overlay slots). This is the bridge to the 45 cast.
- **`Adventurer` gains a character-identity link** — so a runtime adventurer resolves to one of the
  named cast (today its `id` is an instance id like `adventurer_…`, not a cast identity).
- **A resolver** — id → asset path by convention (`char_{id}.png`), so logic never hardcodes an
  image; data names the identity and the path is computed.

## FD5 — R3 (selective persistence) promoted to live (founder ruling owed)

A navigable street where you *recognize* a figure crossing the square makes recurring, named
adventurers land far harder — so the spatial decision **pulls R3 forward** from reserved to live. It
is no longer parked. The actual ruling — how much, which adventurers persist, for how long — remains
a **reserved founder decision** (§VII) and is **not made here**; it is now an active item to decide
deliberately rather than by drift. *(Lean: spatial strongly favors at least the named cast
persisting; decide explicitly.)*

## FD6 — New art sub-package: B-ext (iso building facades)

The street layer needs each building as a **closed iso facade** (exterior; door; windows you can
peek through), at **each grade**, so the outside also visibly flourishes. This is a new sub-package
**B-ext**, ~5 services × 3 grades. It is **additive**, not rework: the existing cutaway interiors
become the click-in target; facades are the street view of the same buildings. Facade zoom/scale is
**deferred** until the street surface exists to size it against (lose-no-information discipline).

## FD7 — Sprite re-render: intended, but sequenced after the look-test

The 45 cast are currently **flat-front** portrait sprites, not iso-facing. Re-rendering them for iso
depth is **on the table and intended** — but **sequenced**, not fired now, because "iso depth" is not
yet a precise spec:

- In the **detail-view cutaway**, flat-front figures placed in an iso room frequently read as an
  intentional **billboard convention** and may need no re-render at all.
- Iso-facing depth genuinely matters mainly on the **street**, with figures walking building-to-
  building (slice two).

So: build the detail view, place the **current** sprites in an iso room, **look at them**, and *then*
decide whether a re-render is needed and what exactly "iso depth" means. Masters are preserved;
nothing is lost by waiting. Re-rendering blind now risks doing 45 sprites twice.

---

## Build sequencing

1. **Slice one — Detail view** (`Claude_Code_Brief_Spatial_Slice1_DetailView_V1`): one iso building
   cutaway, real cast sprites placed in its rooms, occupancy driven by sim state. Proves the
   data-driven renderer + layer stack against **art that already exists** — no pathing, no map, no
   re-render. The architecture proof.
2. **Look-test** (founder): evaluate flat sprites in the iso room → rules FD7 (re-render or not) and
   the flat-vs-iso-facing convention.
3. **Slice two — Street view**: iso overworld, facades (B-ext), adventurer pathing, depth-sorting,
   peek-through, revenue popups.
4. Art resumes unblocked and in parallel: Package C overlays (scale/slots now real), icons/UI
   mini-spec, environment, establishing scenes.

## Open founder decisions (owed)

- **R3 ruling** — how much/which persistence (FD5).
- **Flat vs iso-facing sprites** — resolved by the slice-one look-test (FD7).
- **Facade zoom/scale** — after the street surface exists (FD6).
- **Cutaway MVP fidelity** — full interiors vs partial vs facade-cues (`Amenity_Module_System_V1`
  OQ-4 dial).

## Non-goals (this stage)

- No street/overworld, pathing, camera-map, or depth-sorting in slice one — that is slice two.
- No outcome-overlay generation (Package C) until the layer stack is proven and scale is real.
- No sprite re-render until the look-test rules on it.
- No mixed projections — one fixed iso angle for everything.
- No abandoning the existing cutaway interiors — they are the click-in target, not throwaway.

---

*Spatial_TownView_Founder_Decision_Record_V1 · Adventurer Town · supersedes CLAUDE.md §IV.*
