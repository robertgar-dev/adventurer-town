# Adventurer Town

> **You built the town that made the adventurers successful.**

A cozy idle / economy game built in **Flutter**. You are not the hero — you are the
**economic architect** of a town whose Inn, Tavern, Blacksmith, Healer, and Market make heroism
possible. Adventurers arrive as autonomous customers, spend when served, succeed or struggle
off‑screen, and the town becomes more capable over time. The town is the protagonist; a session
should end with the player remembering *the state of the town*, not the size of a number.

The binding **project constitution** lives in [`CLAUDE.md`](./CLAUDE.md) (loaded into every
session). That document — not this README — governs scope, design, and architecture. The detailed
design canon lives in a separate design repository (`Documents/AdventurerTown/`).

> **Repo-name note:** the working folder is `Adventerer Town` (historical misspelling); the product
> is **Adventurer Town** and the Dart package is `adventurer_town`.

---

## Project overview

Adventurer Town is a single‑player, offline‑first idle economy sim. The player shapes conditions —
building and upgrading services — and never directly commands adventurers. The counter‑intuitive
engine is that **success creates pressure, not slack**: a better town attracts more and stronger
adventurers with higher expectations, which manufactures the next bottleneck. Warmth is
non‑negotiable; failure is *missed opportunity*, never punishment.

---

## Current feature set

The core game is playable end to end and covered by tests.

**Gameplay**
- Five fixed buildings — **Inn, Tavern, Blacksmith, Healer, Market** — each serving one demand type.
- Five demand types — **Rest, Food, Gear, Healing, Supplies**. Demand never queues; unserved demand
  is lost.
- Two resources — **Gold** (spendable; the only upgrade cost) and **Reputation** (earned trust,
  never spent; gates four adventurer tiers).
- Two upgrade axes per building — **Capacity** (throughput) and **Value** (Gold per service), each
  10 levels on a doubling cost curve (50 → 12,800 Gold), gated by Reputation at levels 4 / 7 / 10.
- Four adventurer tiers — **Novice / Veteran / Elite / Legendary** (narrative lenses; they differ by
  service pressure and spend, never RPG behavior).
- Deterministic **5‑second tick**; **offline progression** replays the same approved economy
  (Gold‑only, **8‑hour cap at 65% efficiency**).

**Presentation & feel**
- Building Detail decision‑support and an economic‑with‑flavor **Event Feed**.
- One‑time **onboarding** hints and a non‑blocking **analytics** seam.
- **Attachment pass (M12 Stage 1):** Reputation shown as a *destination* (trust with somewhere to go,
  never a wallet); offline return narrated as a short **story** over the honest scalars; **notable
  town moments** derived in the feed; first‑upgrade **stakes framing + affirmation**.
- **Spatial Town View — Slice 1 (in progress):** a data‑driven **Flame** render surface. The first
  slice is the **building‑detail cutaway** (Flame Inn cutaway with sim‑occupancy render, entered from
  a visible body button), with the detail‑view render scale ratified at 22% (FD8). The full
  navigable iso street view is a later slice and is **not built yet** (see Roadmap).

There is **no premium currency and the economy is never for sale.**

---

## Development status

Active development toward a **4‑month solo‑dev MVP**. Status is tracked by milestone and tag rather
than by a moving commit SHA.

| Milestone | Area | State | Tag |
|---|---|---|---|
| Sprint 01–02 | Flutter/Riverpod shell, pure‑Dart deterministic simulation | ✅ committed | `sprint-02-complete` |
| M3 | Persistence — Isar production path, schema gating, recovery | ✅ | — |
| M4 | Core economy loop | ✅ | `m4-core-economy-loop` |
| M5 | First Playable — Town View | ✅ | `m5-first-playable` |
| M6 | Building Detail UX | ✅ | `m6-building-detail-ux` |
| M7 | Offline progression (Gold‑only, capped, idempotent) | ✅ | `m7-offline-progression` |
| M8 | Event Feed | ✅ | `m8-event-feed` |
| M9 | Onboarding (one‑time hints) | ✅ committed | *(no tag)* |
| M10 | Analytics (non‑blocking instrumentation) | ✅ | `m10-analytics` |
| M12 Stage 1 | Attachment presentation pass (WP1–WP4) | ✅ committed | `m12-stage1-attachment` |
| Spatial Slice 1 (+1.5) | Building‑detail cutaway on a data‑driven **Flame** surface; detail‑view render scale ratified at 22% (FD8); 45/45 cast sprites | ✅ committed | *(no tag)* |
| M11 | Monetization | ⏳ planned (founder‑gated) | — |
| Spatial Slice 2+ | Navigable iso street / town view | ⏳ planned | — |
| M12 Stage 2 | Attachment: building art + audio | ⏳ planned | — |

---

## Architecture overview

Flutter / Dart, layered with a one‑way dependency flow:

```
domain/       Pure data + rules: buildings, demand, resources, economy constants, upgrades, settings
  ↓
simulation/   Deterministic engine, offline progression, seeded RNG, reports (no Flutter imports)
  ↓
persistence/  Repository boundary: Isar (production), file, in‑memory; state codec + schema gating
  ↓
app/          Riverpod providers, simulation controller, view models
  ↓
ui/           Town View, building detail, event feed, onboarding, attachment surfaces;
              Flame spatial render surface (building‑detail cutaway, Slice 1)
analytics/    Non‑blocking wrapper + event definitions (never gates gameplay)
```

**Invariants**
- The simulation domain is **pure Dart and deterministic** (headless replay must hold).
- The Town View is a **data‑driven spatial render surface** built on **Flame** and grown in slices;
  the render stays **data‑driven** (sim state → picture), never an authored scene. *(Authority:
  `CLAUDE.md` §IV FD1, 2026‑06‑20 — founder ruling adopting Flame as the engine for the spatial
  render surface.)*
- **Analytics never block, gate, or alter** gameplay; they degrade to a silent no‑op.
- Persistence stays behind the repository boundary; UI sends intent and renders state only.

**Stack:** Flutter (stable channel) · **Flame** (spatial render surface) · Riverpod ·
Isar (`isar_community`) · Firebase Analytics (via non‑blocking wrapper) · Dart `>=3.5.0 <4.0.0`.

---

## Validation status

Validation is tied to the commands and date below; **re‑run them after any change** rather than
treating the figures as permanent.

As of **2026-06-20**:

- `flutter analyze` → **No issues found.**
- `flutter test` → an extensive test suite passing — **100+ tests across sim, spatial, and pipeline.**
- `dart run tool/sprint02_validation_harness.dart scenario5` → **`pass: true`** (deterministic replay
  matches, zero demand backlog, Gold/Reputation never negative, upgrade levels in bounds, only
  approved MVP economy systems present).

---

## Roadmap

- **M11 — Monetization** *(planned; founder‑gated).* Ethics are locked (price × units + optional
  cosmetic editions + paid expansions; the economy is never for sale). The **commercial model, base
  price, and edition structure are reserved founder decisions** (CLAUDE.md §VII) — consistent with a
  **"Hobby Studio"** posture: a polished, respectful solo‑dev game, not live‑service extraction.
- **Spatial Town View — Slice 2+.** Build outward from the Slice 1 building‑detail cutaway toward the
  navigable iso street / town view (map, depth layers). The render stays data‑driven (sim state →
  picture). Authority: `CLAUDE.md` §IV FD1 / FD7.
- **M12 Stage 2 — Attachment (sensory).** Minimal building‑state **art** + an **audio** foundation
  with core cues (the affection‑closing work; Stage 1 deliberately did not move "affection").
- **Launch gates.** See `Release_Readiness_Guardrails_V1` (design repo): human playtest sign‑off,
  privacy/data‑safety labels, accessibility, and store readiness before beta → soft launch → release.

---

## Screenshots

> _Placeholder — add gameplay capture before store/marketing use._

| | |
|---|---|
| Town View | _TODO: screenshot_ |
| Building Detail (Capacity vs Value) | _TODO: screenshot_ |
| Building‑detail cutaway (Flame, Slice 1) | _TODO: screenshot_ |
| Event Feed + notable moments | _TODO: screenshot_ |
| Offline return story | _TODO: screenshot_ |

Real gameplay capture is the primary marketing proof; handcrafted art is the production stance.

---

## Steam wishlist

> _Placeholder — add the Steam store/wishlist link once the page is live._
>
> **Wishlist Adventurer Town on Steam:** _TODO: store URL_

(The commercial model is a reserved founder decision; do not publish pricing or platform claims here
until it is settled.)

---

## Getting started / Contributing

Requires the Flutter SDK (Dart `>=3.5.0 <4.0.0`).

```bash
flutter pub get

# Generate Isar code (the *.g.dart files are committed; re-run after schema changes)
dart run build_runner build --delete-conflicting-outputs

flutter run            # run the app (Windows / Android / iOS)
flutter analyze        # static analysis
flutter test           # full test suite

# Deterministic, UI-free validation harnesses
dart run tool/headless_simulation_harness.dart
dart run tool/sprint02_validation_harness.dart
```

> **Windows note:** the Isar native library (`libisar.dll`) must be present at the repo root to run
> on Windows. It is git‑ignored as a runtime artifact — obtain it via the Isar tooling rather than
> committing it.

**Contribution rules**
- **`CLAUDE.md` is binding.** Before proposing a change, check the Design Tension Register (§V) and
  Hard Exclusions (§VI). If a change reopens a resolved tension, stop and flag it for the founder.
- **Smallest change that satisfies the intent.** Deepen and reuse existing systems before adding
  anything; flag scope creep — including creep disguised as "polish."
- **Do not touch the economy to add "meaning."** Reputation is never spendable; demand never queues;
  offline is Gold‑only.
- **Keep the simulation pure and deterministic**, analytics non‑blocking, and the spatial render
  data‑driven (sim state → picture).
- Run `flutter analyze`, `flutter test`, and the scenario harness before opening a PR.

## Documentation
- [`CLAUDE.md`](./CLAUDE.md) — the project constitution (authoritative).
- [`docs/`](./docs/) — milestone validation and launch notes.
