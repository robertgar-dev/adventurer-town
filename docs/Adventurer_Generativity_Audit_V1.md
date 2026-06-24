# Adventurer Generativity Audit — V1 (Measured)

**Task:** `Adventurer_Generativity_Audit_Task_V1` — measure what the real simulation
actually generates, before investing in a deeper adornment / individuation art system.
**Type:** read-and-measure only. No sim/shipping code was modified.
**Repo:** `C:\Users\rober\Documents\Adventerer Town` (code repo, Flutter/Dart).
**Branch:** `claude/happy-bohr-1rhyw4`.
**HEAD audited:** `5d951b4` (FD9 Phase C proof: synthetic-mark registration evidence).
**Date:** 2026-06-23.

> **How to read this report.** Every claim is tagged **[MEASURED]** (produced by running the
> real `SimulationEngine` and counting its output) or **[INFERRED]** (read from the source, not
> from a run). The headline finding rests on **[MEASURED]** evidence. The plain-language
> life-traces in §7 are the "look at the picture sheets" artifact — read them yourself.

---

## 0. Bottom line (a measured finding, not a verdict)

**[MEASURED]** In the simulation as it runs today, the named cast do **not** live distinct,
identity-driven lives — because **the named cast do not live in the simulation at all.** The
engine produces a stream of **anonymous, single-tick customers**. Each one is created, served or
missed, and marked `departing` **within the same tick**, then never referenced again. The named
characters (Brindle, Borrin, Keebo, Durnik, Nym, …) exist only as **render-layer face stickers**
applied *after the fact* by hashing a disposable adventurer id onto one of 45 catalog faces.

Measured regime (Step 4 framing): **high within-face variety + between-face distinctness that is
statistically indistinguishable from random relabeling** → **"randomness, not character"**
(different dice, same person). In the richer fully-built configuration the between-face signal is
actually *below* random — faces differ *less* than chance would produce.

The decision "is this distinct enough / what to build next" is **handed to the founder** (§9).
This report does not assert it. But the foundation the adornment system would reflect — persistent,
identity-driven adventurer lives — **is not present in the sim core today.** Adornment art can only
ever reflect distinctness the simulation produces; right now there is none to reflect at the
per-adventurer level.

---

## 1. The generativity contract (Step 1) — [MEASURED] + [INFERRED]

| Question | Finding | Source |
|---|---|---|
| **Time model** | Fixed **5 s/tick** (`EconomyConstants.tickIntervalSeconds = 5`). The engine is pure, deterministic Dart. | [INFERRED] `economy_constants.dart`, `simulation_engine.dart` |
| **Headless?** | **Yes.** `SimulationEngine().tick()` / `.runTicks()` run with no UI; `tool/headless_simulation_harness.dart` already does this. This audit drove the same core. | [MEASURED] — ran it |
| **Adventurer instantiation** | Minted **inside the engine each tick** in `_generateDemands`: id `adv_{seed}_{tick}_{slot}_{idx}`, name from a hardcoded 8-name list (`Ari…Hana`), tier by weighted RNG, `wealthBand = (seed+tick+slot) % 3`, `preferredDemandTypes = the whole eligible pool`. **No `characterId` is ever assigned.** | [INFERRED] `simulation_engine.dart:204-257`, `:369-381` |
| **Persistent per-adventurer history?** | **None that accumulates as a life.** Each adventurer is fully resolved in its arrival tick (`departureTick == arrivalTick`). The `adventurers` map technically retains every departed adventurer (it is never pruned — an unbounded-growth quirk), but each entry is terminal and identical-shaped: a one-tick record. | [MEASURED] (172,800 records, all single-tick) + [INFERRED] |
| **Outcome concept** | Exactly two terminal outcomes: **served** (`lastServiceBuildingType` set) or **missed** (capacity full). There is **no** "became a regular / retired / left town / died / leveled" — those are not modeled. | [INFERRED] `simulation_engine.dart:78-152` |
| **Named cast** | 45 `CharacterDefinition`s in `character_catalog.dart` (incl. brindle, borrin, keebo, durnik, nym). **The sim never uses them.** They are resolved at the **render layer** by `characterForAdventurer`, whose own doc says faces resolve "*even before identity assignment is wired into the simulation*." Fallback = `stableHash(adventurer.id) % 45`. | [INFERRED] `character_catalog.dart`, `character_resolver.dart:5-23` |
| **Lifecycle states** | `AdventurerState` declares 6 (`arriving, seekingService, receivingService, departing, returned, removed`). The engine only ever produces **`seekingService → departing`**. The other 4 are dead. `expectedReturnTick` is only ever `null`; **no return mechanic exists.** | [MEASURED] (grep: only 2 states produced) + [INFERRED] |
| **Determinism / seeding** | Fully seedable & reproducible. `SimulationState.newGame(randomSeed:)`; per-tick RNG `seed ^ (tick * 0x45d9f3b)` via `DeterministicRandom`. Same seed → identical run. | [INFERRED] + [MEASURED] (re-runs identical) |

**STOP-gate status.** The task says: *STOP and report if the sim can't run headless, or records
nothing per-adventurer that distinctness could be measured on.* The sim **does** run headless, and
it **does** record a per-adventurer outcome (served/missed) — so the audit proceeded and produced
numbers. **But the deeper STOP condition is effectively met:** there is **no per-adventurer life to
measure** — only one-tick outcomes on disposable, anonymous customers, with the named cast absent
from the simulation. That structural fact is the audit's primary, first-class finding.

---

## 2. What "a few hours of play" means here (horizon justification) — [MEASURED]

At **5 s/tick**, 1 h = 720 ticks, 2 h = 1,440 ticks, 3 h = 2,160 ticks. The audit horizon is
**1,440 ticks (= 2.0 h)** per run — squarely inside "the first few hours." Output volume confirms
this is ample: baseline produces a steady **3 adventurers/tick** → **172,800 adventurer-lives**
across the run set. Extending the horizon cannot change the regime, because nothing in the engine
accumulates across ticks (verified in §1).

**Important caveat (player-driven growth not exercised).** The `SimulationEngine` core does **not**
construct buildings or unlock tiers on its own — those are player/controller actions outside the
engine. A pure headless run therefore holds the town fixed. To avoid under-selling generativity, the
audit ran **two configurations** of the *real engine* (only the initial `SimulationState` differs):
- **`baseline`** — exactly `SimulationState.newGame` (Inn + Tavern built; Novice tier only → only
  `rest`/`food` demands).
- **`fullyBuilt`** — all 5 buildings constructed + all 4 tiers unlocked (all 5 demand types, all
  tiers spawn). This is the most generous static configuration the engine supports.

---

## 3. Run protocol — [MEASURED]

- **Seeds:** 40 (1001–1040), reproducible. **Horizon:** 1,440 ticks each. **Configs:** baseline +
  fullyBuilt. **Total:** 80 runs, **345,608 adventurer-lives** measured.
- **Harness:** a throwaway driver (`tools/generativity_audit_scratch/harness.dart`, **excluded from
  the commit**) that calls the **real** `SimulationEngine.tick()` and harvests the engine's own
  emitted events + retained `Adventurer` objects. It does **not** reimplement or approximate sim
  logic. Faces are resolved with the **real** `characterForAdventurer`.
- **Validity self-check:** the harness prunes departed adventurers between ticks for performance; a
  built-in check confirms **pruned output == unpruned output** over 200 ticks (600 events, exact
  match), because the engine provably never references prior-tick adventurers/demands.

---

## 4. Distinctness dimensions — measurable vs not (Step 2) — [MEASURED]/[INFERRED]

| Intended dimension | Measurable? | Finding |
|---|---|---|
| **Distinct outcomes/endings** | Partially | Only two outcomes exist (served@building / missed). The *space* of possible "lives" per adventurer = `#demand-types × {served, missed}` = **4** (baseline) / **10** (fullyBuilt), each **one tick long**. No durable end-states. **[MEASURED]** |
| **Relational texture** | **No (absent)** | The engine has **zero** inter-adventurer interaction: adventurers never reference, affect, remember, or meet each other, named others, or a town history. Nothing to measure. **[INFERRED]** |
| **Trajectory variety** | **No (absent)** | There is no trajectory: every adventurer exists for exactly one tick. "Path divergence over a horizon" is undefined. **[INFERRED + MEASURED]** (all 345,608 lives are single-tick) |
| **Identity-drivenness (acid test)** | Yes | Measurable as a near-null result — see §5–§6. Outcome is driven by **demand type (RNG) + capacity + arrival order**, not by any stored identity. **[MEASURED]** |

---

## 5. Within vs between regime (Step 4) — [MEASURED]

**Within-face variety** (does the *same* named face get different lives across seeds?) — yes, but it
is pure sampling noise over a tiny outcome space:

| Face | seeds w/ appearances | served-rate mean | std across seeds | distinct "life" types |
|---|---|---|---|---|
| Brindle | 40 | 0.755 | 0.043 | 4 |
| Borrin | 40 | 0.736 | 0.036 | 4 |
| Keebo | 40 | 0.746 | 0.037 | 4 |
| Durnik | 40 | 0.758 | 0.043 | 4 |
| Nym | 40 | 0.761 | 0.038 | 4 |
*(baseline; fullyBuilt is the same picture with 10 life-types instead of 4.)*

**Between-face distinctness** (is Brindle's distribution of lives different from Borrin's?) —
**no, within noise.** Observed spread of served-rate across faces vs a **random-relabel null**
(200 permutations that re-assign face labels at random to the same adventurer pool):

| Config | observed cross-face std | random-null 95% band | verdict |
|---|---|---|---|
| **baseline** | 0.0074 | [0.0054, 0.0085] | **inside the null band** → indistinguishable from random |
| **fullyBuilt** | 0.0031 | [0.0045, 0.0066] | **below the null band** → faces differ *less* than chance |

Read together: **high within + ~zero between → "randomness, not character."** Per the task's own
rubric, this is the *"different dice, same person"* regime — and more pointedly, there is no
"person" to begin with: a face is a random sticker on a one-tick stranger.

---

## 6. Is any divergence tied to *who the adventurer is*? — [MEASURED]

The only identity fields the engine attaches are `tier`, `wealthBand`, `displayName`,
`preferredDemandTypes`. Conditioning the served-rate on them:

- **wealthBand:** served-rate **0.751 / 0.750 / 0.749** for bands 0/1/2 (baseline) — **zero effect.**
- **preferredDemandTypes:** **identical for everyone** (the whole eligible pool) — carries no
  individuation by construction.
- **tier:** baseline is novice-only. fullyBuilt: novice 0.858, veteran 0.865, elite 0.867,
  **legendary 0.625**. The legendary dip is **not** "legendaries live different lives" — it is a
  **volume artifact**: `demandsPerGeneration[legendary] = 2`, so a legendary injects two demands
  that compete for capacity-1 buildings and miss more often. Tier also scales *reward magnitude*
  (gold/reputation multipliers) but **does not change** the served/missed outcome shape.

**Conclusion:** outcome divergence is driven by **demand type (RNG), building capacity, and
within-tick arrival order** — **not** by stored identity. Swap every name and the distributions are
unchanged. This is the acid test failing, measured.

---

## 7. Plain-language life-traces — read these yourself (Step 5)

Each "appearance" below is a **different `adv_…` id** that merely *hashed* to that face. There is no
shared memory, no continuity, no return — just a face reused on unrelated one-tick customers. Full
data in `docs/generativity_audit/life_traces.json`; readable form in
`docs/generativity_audit/life_traces_readable.md`.

**Brindle Mosscap — baseline, seed 1001 (97 "appearances", all single-tick):**
```
tick 14   adv_1001_14_1_0    wants food   -> served@tavern
tick 24   adv_1001_24_0_0    wants food   -> served@tavern
tick 31   adv_1001_31_2_0    wants food   -> MISSED
tick 41   adv_1001_41_1_0    wants rest   -> served@inn
tick 51   adv_1001_51_0_0    wants food   -> served@tavern
tick117   adv_1001_117_2_0   wants food   -> MISSED
tick127   adv_1001_127_1_0   wants food   -> served@tavern
```
Every line is a distinct, unrelated adventurer. "Brindle" is the face; the lives belong to nobody.

**Borrin Chapelback — baseline, seed 1001 (101 "appearances"):**
```
tick 13   adv_1001_13_0_0    wants food   -> served@tavern
tick 20   adv_1001_20_2_0    wants rest   -> served@inn
tick 30   adv_1001_30_1_0    wants rest   -> served@inn
tick 40   adv_1001_40_0_0    wants food   -> served@tavern
tick 98   adv_1001_98_2_0    wants food   -> MISSED
```
Statistically interchangeable with Brindle (served-rate 0.736 vs 0.755; both rest/food ≈ 50/50).

**Keebo Clatterpin — fullyBuilt, seed 1001 (94 "appearances"):**
```
tick 12   adv_1001_12_0_0    wants rest      -> served@inn
tick105   adv_1001_105_2_0   wants rest      -> MISSED
tick115   adv_1001_115_1_0   wants food      -> served@tavern
tick125   adv_1001_125_0_0   wants gear      -> served@blacksmith
tick142   adv_1001_142_1_0   wants supplies  -> served@market
```
More demand variety (5 types) — but still one-tick strangers; the face carries nothing between them.

---

## 8. Measured-vs-inferred summary

- **[MEASURED] (from 80 real-engine runs, 345,608 lives):** single-tick lifespan of every
  adventurer; overall served-rate 0.750 (baseline) / 0.858 (fullyBuilt); between-face distinctness
  inside/below the random-null band; wealthBand has no effect on outcome; legendary served-rate dip
  is a demand-volume artifact; 4/10 total possible "life" shapes; faces span all 45 catalog members
  by id-hash.
- **[INFERRED] (from source at HEAD `5d951b4`):** named cast is render-only; `characterId` never
  assigned by the engine; no return mechanic; 4 of 6 lifecycle states are dead; preferences are
  uniform; no inter-adventurer relations exist.
- **Unmeasurable intended dimensions, and why:** **relational texture** and **trajectory variety**
  could not be measured because they are **not present in the engine** (no inter-adventurer
  interaction; no multi-tick existence). Their absence is itself the finding.

---

## 9. Hand-off to the founder

What was measured: HEAD `5d951b4`; **40 seeds × 1,440 ticks (2.0 h) × 2 configs = 345,608
adventurer-lives**; regime = **"randomness, not character"** (within-face variety present;
between-face distinctness inside/below the random-relabel null band, numbers in §5); per-named-face
outcomes statistically interchangeable (§5, §7); **relational texture and trajectory variety
unmeasurable because absent** (§4, §8).

The call that belongs to **you**, informed by this evidence:
1. The adornment / individuation art system was premised on adventurers *"whose lives you follow."*
   **Measured:** there are no followable lives in the sim core today — only one-tick anonymous
   service events with face stickers. An adornment layer built now would decorate randomness.
2. So the real fork is a **design/scope decision, not an art decision**: whether to invest in
   *persistent, identity-driven adventurers* in the simulation first (note §VII reserved "persistence
   scope" in the Constitution, and the R2/R3 guardrails — the **town** stays the object of
   attachment; any persistence must be selective continuity, never hero-sim). That is **your call**;
   this audit only supplies the measurement.

**Read for yourself:** §7 above and `docs/generativity_audit/life_traces_readable.md`.

---

*Evidence artifacts: `docs/generativity_audit/aggregate.json` (full per-face / per-seed / regime
numbers), `docs/generativity_audit/life_traces.json` + `…/life_traces_readable.md` (life-traces).
Throwaway harness `tools/generativity_audit_scratch/harness.dart` is excluded from the commit.*
