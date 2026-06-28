# Adventurer Town — Project Constitution

This document loads into every session. It is the standing constitution for Adventurer Town:
the settled account of what this product is, what is decided, and what may not be reopened
without explicit founder direction. It governs all design, architectural, and scope decisions
made in this repository. Where a proposal conflicts with this document, this document wins until
the founder amends it.

The design canon this constitution rests on lives in a separate design repository
(`C:\Users\rober\Documents\AdventurerTown\`), not in this code repository. Paths to every
source document appear in **Source Canon** at the end.

---

## I. The One Sentence

> **You built the town that made the adventurers successful.**

Every system, every line of copy, and every design decision is downstream of this sentence.
The player is never the hero. The player is the reason heroism is possible. The emotional
register is quiet responsibility — the warm bed before the hard road, the meal before the
journey, the repaired blade, the healer's open door, the supplies that make return possible.

The town is the protagonist. The arc belongs to the place, not to the player and not to any
individual adventurer. A session should end with the player remembering the *state of the town*,
not the size of a number. The single memory the product is engineered to produce is:
*"My town was not ready before. Now it is."*

---

## II. Design Philosophy — Binding Principles

These are not aspirations. They are constraints on what may be built.

1. **Players are economic architects.** The player shapes conditions, never commands. Pride
   comes from preparedness; concern comes from missed service. Responsibility is for the town,
   never for individual adventurer outcomes.

2. **Adventurers are autonomous customers, not units to command.** They arrive with needs,
   spend when served, succeed or struggle off-screen, leave, and may return. They are not
   inventory, employees, troops, party members, or puzzle pieces. The emotional contract is
   exact: *the player affects adventurers' lives but does not control them.* This line is the
   genre's identity. Crossing it toward control makes the game hero management; retreating from
   it toward pure abstraction makes the game a spreadsheet.

3. **Automation is progression.** The reward of the idle economy is passive progression and
   accumulated mastery — the town working, and working better, increasingly without the player's
   moment-to-moment attention. Progress is felt as the town becoming more capable, not as the
   player performing more actions.

4. **Micromanagement is a failure state, not a feature.** Manual serving, tap-to-transact
   chores, operational shift work, and per-adventurer handling are prohibited. The fantasy is
   architectural responsibility, not labor.

5. **Success creates pressure, not slack.** A better town attracts more adventurers and stronger
   ones, with higher expectations. Growth manufactures its own bottlenecks. This counterintuitive
   engine is what makes Adventurer Town a game and not an idle toy. It is never softened.

6. **Warmth under pressure is non-negotiable.** The world is demanding; the town is never bleak.
   The relaxed, low-stress audience is the retention base. Tension must enrich the cozy
   experience, never threaten it. Failure is *missed opportunity* and produces concern — never
   shame, guilt, punishment, or graphic harm.

7. **Clarity before flavor, always.** Every player-facing surface — the Event Feed above all —
   must keep the economy legible. If the player cannot tell which building, which demand type,
   and which outcome an entry refers to, the writing has failed.

8. **Systems generate content; stories are the reward layer.** There is no separate fiction
   engine. The story is the economy becoming visible and felt. Flatness in the product is a
   presentation problem, not a missing-systems problem — the highest-leverage work is editorial
   and visual, never mechanical.

**The micromanagement veto.** Any proposal that turns the player into a micromanager — direct
adventurer control, manual serving, per-unit assignment, operational busywork, or any mechanic
that makes attention the resource being optimized — violates the product's identity. It must be
named as such and flagged before it is offered, not slipped in as a feature.

---

## III. The Locked MVP — Fixed Facts

These facts are not open to reinterpretation by any design, UX, narrative, or polish work.

- **Buildings (five, fixed):** Inn, Tavern, Blacksmith, Healer, Market.
- **Demand types (five, fixed):** Rest, Food, Gear, Healing, Supplies.
- **Resources (two):** Gold and Reputation.
- **Upgrade axes (two):** Capacity and Value.
- **Adventurer tiers (four, narrative lenses only):** Novice, Veteran, Elite, Legendary. Tiers
  differ through service pressure, spending value, and story expression — never through RPG
  behavior.

**Core economic rules:**
- Demand does not queue. Unserved demand is lost — a person leaving with a need unmet, never a
  delayed or recoverable transaction.
- Gold is the only spendable currency and the only upgrade cost.
- Reputation is earned and never spent. It is Trust — the town's accumulated social memory and a
  progression threshold, not a currency, a second wallet, a popularity meter, or a moral score.
- Reputation is earned only through witnessed, active service. It is never awarded by idle time
  or possession.
- Offline progression produces Gold, never Reputation.
- Adventurers are autonomous; the player does not control them.
- No premium currency.

Each building carries a human meaning that is the reason its economics matter: the Inn is
shelter, the Tavern is hunger and morale, the Blacksmith is readiness, the Healer is recovery
and mercy, the Market is the confidence to depart. Surface, frame, and dramatize what already
exists. Do not add.

---

## IV. Locked Technical Decisions

Settled by founder directive and the established architecture. These are constraints, not
options. Do not reopen them or propose alternatives unless the founder explicitly asks.

> **Amendment — founder decision, 2026-06-20 (FD1).** The **no-game-engine** invariant and the
> **widget-dashboard-only** Town View constraint below were **lifted by founder ruling**. The Town
> View is reopened from a widget-only dashboard to a **spatial, data-driven render surface**, and
> **Flame** is adopted as the render engine for it. Flutter/Dart remains the app and simulation
> foundation. The two affected bullets are annotated inline; where this amendment conflicts with
> the original wording, the amendment governs. Authority: `Spatial_TownView_Founder_Decision_Record_V1`
> (FD1, FD7) — **delivered 2026-06-28** to `docs/founder/Spatial_TownView_Founder_Decision_Record_V1.md`
> (verbatim copy; the design repo `AdventurerTown\06_Art_and_Audio\Artifacts\` remains the source of
> truth). Provenance gap closed; see `docs/Provenance_Report_2026-06-28.md`.

- ~~**Pure Flutter / Dart. No game engine.**~~ — **Amended 2026-06-20 (FD1):** Flutter/Dart remains
  the app and simulation foundation, but a game engine (**Flame**) is now permitted, scoped to the
  spatial render surface.
- **Riverpod** for state management.
- **Isar** for local-first persistence.
- **Firebase Analytics**, used only through a non-blocking wrapper. Analytics never block,
  gate, or alter gameplay, and instrument approved events only.
- **5-second active tick interval.** The simulation domain is pure Dart and deterministic
  (headless replay must hold).
- **8-hour offline cap at 65% efficiency.** Offline accrual is Gold-only (see §III).
- ~~**The Town View is a state-driven widget dashboard, not a spatial canvas.** There is no map,
  grid, free placement, or spatial logistics layer.~~ — **Amended 2026-06-20 (FD1):** the Town View
  is now a **spatial, data-driven canvas** (iso). Map / grid / placement / depth layers are built in
  slices; slice 1 is the building-detail cutaway. The render stays data-driven (sim state → picture).

---

## V. The Design Tension Register — Protected Core

**This is the most important section.** The Register is the protected core of the product's
identity: the set of tensions the canon has already resolved. Before proposing any design
change, feature, framing, or architectural choice, check it against this Register.

**If a proposal would reopen a resolved tension, stop. Name the specific tension below, state
that the proposal reopens it, and do not proceed until the founder confirms they want to revisit
it.** Treat every entry as closed.

| # | Resolved Tension | Settled Resolution | Source |
|---|---|---|---|
| R1 | Reputation must mean something, yet must not become spendable | Display, not redesign: surface Reputation's *trajectory* toward a single visible aspiration. It remains earned, never spent. "Make Reputation spendable" is out of scope. | Reputation_And_Social_Ecology_V1; Living_World_Context_Pack_V1 |
| R2 | What is the object of attachment — the town or the adventurers? | The persistent **town** is the primary object of attachment. Recurring adventurers are the light-touch means by which the town's history becomes visible and personal. | Living_World_Context_Pack_V1; Adventurer_Lifecycle_V1 |
| R3 | How much adventurer persistence? | **Selective continuity, not simulation:** a small named cast, tier, recent service outcome, return condition, repeat appearance, occasional notable Event Feed memory. Noticeable when it creates emotion, invisible when it would create burden. | Adventurer_Lifecycle_V1 |
| R4 | How far can the Event Feed go? | **Economic-with-flavor is the ceiling.** The feed is the town's diary, not a receipt and not a fiction engine. Stories are a reward layer over existing outcomes — never branches, choices, quests, character arcs, or authored plot. | Event_Feed_Narrative_Framework_V1; Living_World_Context_Pack_V1 |
| R5 | Is missed demand a punishment? | **Missed opportunity first, never a penalty.** Normal bottlenecks are the intended optimization driver and are never punished. Any future Reputation loss is slow, legible, and pattern-based only. | Emotional_Economy_Framework_V1; Reputation_And_Social_Ecology_V1 |
| R6 | Does offline time award Reputation? | **No. Offline is Gold-only**, preserving Reputation as a record of witnessed active service. | Reputation_And_Social_Ecology_V1; Living_World_Strategy_V1 |
| R7 | Should growth relax the game? | **No. Success creates pressure.** Growth must attract more and stronger demand. This engine is protected at all costs. | Living_World_Strategy_V1 |
| R8 | Player role: economic architect or shopkeeper-lord? | **Economic architect is the design truth.** "Shopkeeper / town steward" is market-facing flavor for discovery only, and never implies manual labor or ownership of adventurers. | Positioning_Discoverability_V1; Final_Strategy_Document_V1/V2 |
| R9 | Solve emotional flatness with features? | **No.** Flatness is a presentation and surfacing problem. New systems would delay the MVP for marginal gain and multiply scope risk. Wins are editorial and visual. | Living_World_Context_Pack_V1 |
| R10 | Can the economy be touched in the name of "meaning"? | **No.** Do not make Reputation spendable, add a second cost, or let demand queue. Surface meaning; never re-architect it. | Living_World_Context_Pack_V1; Emotional_Economy_Framework_V1 |

---

## VI. Hard Exclusions — Never Build

Excluded by MVP scope and by every approved framework. No reframing, flavor, "emotional
engagement," or "premium appeal" rationale reopens them:

Combat · Quests · Inventory · Crafting · Equipment management · Staffing · Hero/party control ·
Adventurer leveling or stats · Adventurer classes · Factions · Relationship systems ·
Dialogue trees · Authored character campaigns or per-visitor biographies · Premium currency ·
Trade routes · Politics · Weather · New buildings · New demand types · New upgrade axes ·
Demand queues, reservations, or refunds · Production chains · Manual/tap serving ·
Spatial zoning or map placement.

**Identity failures to avoid:** making the player the hero; treating adventurers as owned assets;
turning service into busywork; making failure cruel; making the town kingdom-scale or
chosen-one. The town matters because it is useful and trusted, not grand.

---

## VII. Commercial Layer — Locked Ethics, Reserved Decisions

**The ethical invariants are settled and identical across every commercial document, V1 and V2.
They are locked:**

- Revenue = **price × units + optional editions + paid expansions**. Never extraction.
- **The economy is never for sale.** Prohibited without exception: pay-for-power; paid Gold,
  Reputation, Capacity, Value, throughput, arrival rate, offline progress, or bottleneck relief;
  premium currency; gacha or randomized purchases; ads; battle/season pass; subscriptions;
  energy systems; FOMO, countdowns, artificial scarcity, fake anchors; failure-state purchase
  prompts; starter packs that grant economic advantage.
- Anything sold is **gratitude, identity, attachment, cosmetics, recognition, or genuine new
  content** — permanent, non-random, non-mechanical, clearly optional.
- Handcrafted art is the production stance. Real gameplay capture is the primary marketing proof.
- No paid user acquisition until organic validation gates clear.

**The following are NOT settled. They are reserved to the founder. An agent must not assume,
default to, or quietly resolve either side:**

- **Commercial model:** free-mobile + premium-Steam (Approved in V1) vs. premium-led across
  platforms (recommended in `Final_Strategy_Document_V2.md`, *Draft — pending founder approval*).
- **Base price and edition structure:** $9.99 + Supporter/Patron IAP (V1) vs. $11.99 Standard /
  $19.99 Deluxe / $29.99 Collector (V2).
- **Persistence scope:** scoped-down Event-Feed memory vs. richer living-adventurer continuity.
  V2 reopens this. **Either resolution must still obey §III, §V (R3), and §VI** — richer
  persistence never authorizes hero control, combat, inventory, relationships, parties, quests,
  or per-visitor biographies.

When work touches any reserved decision, surface it as the founder's to make. Do not encode a
choice the canon has not made.

---

## VIII. Scope Discipline

This is a **four-month MVP built by a solo developer.** Scope creep is the primary risk to the
project.

- Default to the **smallest change that satisfies the intent.** Deepen and reuse existing systems
  before adding anything.
- The MVP commercial and design asset is fixed: five buildings, two resources, two upgrade axes,
  four tiers, demand, service consumption, building upgrades, offline progression, and the Event
  Feed. Anything beyond this belongs to a post-MVP decision, not to an agent's initiative.
- **Flag scope creep when you see it** — including scope creep disguised as polish, "emotional
  engagement," or premium positioning. The Event Feed carries the strongest gravity toward
  becoming a different game; hold its boundary (R4) hardest.

---

## IX. Source Canon

The standing design canon. Reference these for the detailed wording of any principle above.

**Vision & Living World**
- `C:\Users\rober\Documents\AdventurerTown\Post_Playable\Living_World_Strategy_V1.md` — the soul document; tiebreaker for what the game *means*.
- `C:\Users\rober\Documents\AdventurerTown\Post_Playable\Living_World_Context_Pack_V1.md` — authoritative identity synthesis.
- `C:\Users\rober\Documents\AdventurerTown\Post_Playable\Emotional_Economy_Framework_V1.md` — the human meaning of each building and outcome.
- `C:\Users\rober\Documents\AdventurerTown\Post_Playable\Reputation_And_Social_Ecology_V1.md` — Reputation as Trust; earned, never spent.
- `C:\Users\rober\Documents\AdventurerTown\Post_Playable\Adventurer_Lifecycle_V1.md` — autonomous customers; selective continuity.
- `C:\Users\rober\Documents\AdventurerTown\Post_Playable\Event_Feed_Narrative_Framework_V1.md` — the town's diary; economic-with-flavor ceiling.

**Commercial & Positioning**
- `C:\Users\rober\Documents\AdventurerTown\Post_Playable\Final_Strategy_Document_V2.md` — current commercial revision (*Draft — pending founder approval*).
- `C:\Users\rober\Documents\AdventurerTown\Post_Playable\Premium_Pricing_Gameplay_Loop_Assessment_V1.md` — price-vs-loop assessment.
- `C:\Users\rober\Documents\AdventurerTown\14_Post_Launch\Monetization\Final_Strategy_Document_V1.md` — approved V1 strategy.
- `C:\Users\rober\Documents\AdventurerTown\14_Post_Launch\Monetization\Commercial_Approach_V1.md` — approved market/commercial reconciliation.
- `C:\Users\rober\Documents\AdventurerTown\14_Post_Launch\Monetization\Monetization_And_Operations_Approach_V1.md` — approved monetization model and guardrails.
- `C:\Users\rober\Documents\AdventurerTown\14_Post_Launch\Monetization\Positioning_Discoverability_V1.md` — approved positioning and ASO.

On any conflict over detailed wording, the originating approved artifact governs. Where V1 and
V2 commercial documents disagree, the decision is reserved to the founder (see §VII).
