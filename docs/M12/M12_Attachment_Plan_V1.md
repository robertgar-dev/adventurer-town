# M12 Attachment Plan — V1

**Working Title:** Adventurer Town
**Artifact:** `docs/M12_Attachment_Plan_V1.md`
**Status:** ✅ **CANONICAL — the M12 milestone document. Founder-approved 2026-06-28 (Founder Review
Decision).**
**Type:** Milestone plan (attachment pass). Reconstructed from project knowledge, then promoted to
canonical.
**Supersedes:** the never-committed `M12_Attachment_Plan_V1.md` that `docs/M12_Stage1_Validation_Report.md`
(Step 0) found absent from the code repository.
**Promoted:** 2026-06-28 · **Reconstructed:** 2026-06-28 · **Code-repo HEAD at reconstruction:**
`85f6d27` (FD7 cast re-render integrated)

> **Provenance — reconstruction history preserved.** This document did not survive in the code
> repository on any branch (`docs/M12_Stage1_Validation_Report.md`, Step 0). It was **reconstructed
> on 2026-06-28** from the surrounding approved/ratified canon — the design-repo
> `M12_Attachment_Audit_V1`, the Approved `Thirty_Minute_Attachment_Hypotheses_V1` and
> `Player Value Hypotheses`, the Approved `Audio_Direction_Pack_V1`, the **Ratified `FD10`**, the
> `Spatial_TownView_Founder_Decision_Record_V1` (FD1–FD7), and the measured
> `Adventurer_Generativity_Audit_V1` — and then **approved by the founder as the canonical
> successor**. It is evidence-led: every non-obvious claim cites a source, and every step beyond the
> sources is labelled **[AI INFERENCE]**. The original reconstruction was filed as
> `docs/M12_Attachment_Plan_V1_Reconstructed.md` and **promoted (renamed)** to this canonical path;
> its lineage is preserved in this header.
>
> **Authority & limits.** This is the milestone plan, **subordinate to `CLAUDE.md`** (the
> Constitution); where any line here conflicts with the Constitution, the Constitution wins (§
> references throughout). Promotion to canonical does **not** authorize building any work package —
> the founder gates that separately (see §10 open items; build was explicitly deferred at approval).

---

## Source map (read before trusting anything below)

| Source | Repo | Status | What it anchors here |
|---|---|---|---|
| `CLAUDE.md` (Constitution) | code | **Authoritative** | All constraints; wins every conflict |
| `M12_Attachment_Audit_V1.md` | design (`14_Post_Launch/Monetization`) | Audit artifact | The gap measurement + the "smallest path" WP list |
| `Thirty_Minute_Attachment_Hypotheses_V1.md` | design (`…/Monetization`) | **Approved** | The emotional target M12 serves |
| `Player Value Hypotheses.md` | design (`…/Monetization`) | **Approved** | Player-value + betrayal-risk frame |
| `Audio_Direction_Pack_V1.md` | design (`…/Monetization`) | **Approved** | The Stage 2 (audio) layer |
| `FD10_Adventurer_Persistence_Scope_Decision_Record_V1.md` | design → copied verbatim to `docs/founder/` (2026-06-28) | **Ratified 2026-06-23** | Persistence scope — gates named-cast work OUT of M12 |
| `FD10_Persistence_Scope_Constitution_Reconciliation_V1.md` | design → `docs/founder/` | Verification | Binding caveats C1–C3 |
| `Spatial_TownView_Founder_Decision_Record_V1.md` (FD1–FD7) | design → `docs/founder/` | **Approved 2026-06-20** | The parallel visual/affection track |
| `docs/Adventurer_Generativity_Audit_V1.md` | code | Measured | Why per-adventurer "lives" are absent today |
| `docs/M12_Stage1_Validation_Report.md` | code | Validation | Named the 4 WPs; found the plan missing |
| `M11_Monetization_Plan_V1.md` | design (`…/Monetization`) | Present (not fully read this pass) | Downstream milestone M12 de-risks |

---

## 1. Historical Context — why M12 exists

The economy MVP was built and validated in sequence M4→M10: the core loop (five buildings, demand,
Capacity/Value upgrades, Gold/Reputation), persistence, M6 building detail, M7 offline progression,
M8 Event Feed, M9 onboarding, M10 analytics. `docs/M12_Stage1_Validation_Report.md` (Step 4)
certifies that baseline as analyzer-clean and tests-green.

After M10, a single question was put to the repository — *"Would a new player likely care about the
town after 30 minutes?"* — and answered by `M12_Attachment_Audit_V1.md`. The audit's measured
verdict:

> **"Conditionally attached — legible and warm in language, but not yet an inhabited place."**
> Overall Attachment Readiness ≈ **50/100**. (`M12_Attachment_Audit_V1.md` §9, §11)

The audit decomposed that score: comprehension and linguistic warmth are strong (the real asset of
M5–M10), but the *felt* layer is thin — Affection scored **3/10** (the decisive weakness), Trust
**5/10** (Reputation is "a bare integer beside Gold… no destination or trajectory"), Curiosity
**5/10** (offline reads as "a payout screen," not "a story"). The audit's explicit recommendation
(§11) was:

> **"B) Needs M12 attachment work first — before M11 monetization."**

That is the origin of M12. It exists because shipping monetization (M11) onto a town players
understand but do not yet *care about* would, in the audit's words, "risk monetizing a town players
don't yet care about." M12 is the milestone that converts **comprehension → care** before any
payment question is appropriate — which is itself the central thesis of the two Approved hypotheses
docs (`Thirty_Minute_Attachment_Hypotheses_V1.md` §7; `Player Value Hypotheses.md` §9: *"Monetization
should follow player value. It should not manufacture player value by withholding relief."*).

**[AI INFERENCE]** The plan was named `M12_Attachment_Plan_V1.md` and split into a **Stage 1
(presentation)** and a **Stage 2 (audio/sensory)**. This split is not stated in a surviving plan
doc, but it is implied directly by `docs/M12_Stage1_Validation_Report.md`, which validates a "Stage
1" of four work packages and renders a separate "Stage 2 (Audio/Sensory) Go/No-Go." The audio layer
maps to the Approved `Audio_Direction_Pack_V1.md`. This reconstruction adopts that two-stage shape.

---

## 2. Founder Intent

### 2a. Explicit founder decisions (sourced, not inferred)

- **Attachment is the object; the town is the protagonist.** *"The attachment target is the town,
  not an individual hero, collection, questline, inventory, or paid reward."*
  (`Thirty_Minute_Attachment_Hypotheses_V1.md` §1). Reinforced by Constitution §I and §V R2.
- **The single engineered memory:** *"This town was not ready before. Now it is more ready because of
  me."* (`Thirty_Minute_Attachment_Hypotheses_V1.md` §1; Constitution §I — *"My town was not ready
  before. Now it is."*).
- **Care must precede payment.** *"Do not ask players to pay to relieve pressure. Ask only after the
  town has earned affection and trust."* (`Thirty_Minute_Attachment_Hypotheses_V1.md` §7).
- **Surface, frame, dramatize — do not add.** The Constitution's §V R9 (*"Flatness is a presentation
  and surfacing problem… Wins are editorial and visual"*) and §III (*"Surface, frame, and dramatize
  what already exists. Do not add."*) The audit operationalized this: its "Smallest Path"
  (`M12_Attachment_Audit_V1.md` §10) marks the highest-leverage fixes **"Presentation Only."**
- **The four Stage-1 work packages.** `docs/M12_Stage1_Validation_Report.md` enumerates them by
  name: **WP1 Reputation Destination, WP2 Offline Story, WP3 Notable Moments, WP4 Upgrade
  Affirmation.** The validation report states these came from "the task structure itself" — i.e. the
  founder's validation prompt — which means the WP set is **founder-originated**, not AI-invented.
- **Persistence scope is decided, and it is NOT part of the cheap pass.** FD10 (Ratified 2026-06-23)
  fixes persistence at ~20 named adventurers with witnessed progression, but **explicitly does not
  authorize a build** and gates a design pass first (`FD10…Decision_Record_V1.md`, "Sequencing").
  The audit independently flagged recurring/named-visitor flavor as *"optional, scope-risky… Defer."*

### 2b. AI inference (labelled)

- **[AI INFERENCE]** Each Stage-1 WP traces to one row of `M12_Attachment_Audit_V1.md` §10:

  | WP (from validation report) | Audit §10 row it implements | Audit category |
  |---|---|---|
  | WP1 Reputation Destination | "Reputation 'north-star'/trajectory in/near the header" | **Presentation Only** |
  | WP2 Offline Story | "Offline return → narrated beat (busiest building, most-missed demand, up to N notable feed events)" | **Presentation Only** |
  | WP3 Notable Moments | "'Notable town moment' / readiness-threshold / reputation-milestone feed lines" | **Presentation Only** |
  | WP4 Upgrade Affirmation | "First-upgrade 'bet'/stakes framing & a small celebratory affirmation" | **Presentation Only** |

  The 1:1 fit is strong evidence the plan's Stage 1 *was* the audit's "Presentation Only" set, but
  the mapping itself is reconstructed, not quoted.
- **[AI INFERENCE]** M12's number (after M11) is a roadmap artifact, not a run-order: the audit
  recommends M12 run *before* M11. The plan most likely encoded this inversion (attachment first,
  monetization downstream).

---

## 3. Player Outcome (emotional target — no implementation here)

M12 succeeds when, after a first ~30-minute session, a new player **cares about the town**, not just
understands it. The Approved hypotheses define the felt end-state
(`Thirty_Minute_Attachment_Hypotheses_V1.md` §4; `Player Value Hypotheses.md` §2). The dominant note
is **"warm responsibility."** Concretely the player should leave feeling:

- **Readiness** — *"This town was not ready before. Now it is more ready because of me."* The session
  crystallizes one "now it is" moment instead of just moving numbers.
- **Stewardship** — the town is theirs to ready, through shaping conditions, never micromanagement.
- **Pride** — the town served people because it was prepared.
- **Concern** — a missed adventurer mattered; it produced *"I want to catch that next time,"* never
  shame (Constitution §II.6, §V R5).
- **Trust** — Reputation reads as the town becoming *known and trusted*, with a visible direction of
  travel — not a second wallet.
- **Curiosity** — they want to know *what happened while they were away*, and they leave with a next
  improvement in mind.
- **Affection** — the weakest signal today (3/10); the town should feel *worth checking on*.

The target memory the whole milestone is engineered to produce (Constitution §I): **"My town was not
ready before. Now it is."**

This section deliberately stops at emotion. The mechanisms that *produce* these feelings are §6–§8.

---

## 4. Design Constraints (every constraint that binds M12)

From the Constitution (authoritative) and the Approved/ratified canon:

1. **Presentation over simulation complexity.** Surface/frame/dramatize what exists; do not add
   systems (§III; §V R9; §VIII; audit §10 "Presentation Only").
2. **Economy is untouchable.** No new cost, no spendable Reputation, no demand queue
   (§III; §V R1/R10). WP1 in particular must derive a Reputation *destination* from existing
   thresholds **without** making Reputation spendable.
3. **Reputation = earned, witnessed trust; never offline, never a number-with-a-wallet** (§III; §V
   R6). A trajectory display must not imply it can be spent or passively earned.
4. **Missed demand stays "missed opportunity," never punishment** (§II.6; §V R5). WP2/WP3 copy must
   not scold.
5. **Event Feed ceiling = "economic-with-flavor"** (§V R4). Notable Moments (WP3) are *derived
   editorial highlights over real outcomes*, never quests, branches, authored plot, or character
   arcs.
6. **Town-first; selective continuity, not simulation** (§V R2/R3). M12 must not smuggle in
   per-adventurer biographies or recurring named cast — that is FD10's separate, gated track.
7. **Offline produces Gold only; offline never awards Reputation** (§III; §IV; §V R6). WP2's
   "story" reframes existing `OfflineResolution` data; it must not narrate Reputation gains.
8. **No micromanagement; player shapes conditions, never commands** (§II.1–4, the micromanagement
   veto).
9. **Deterministic, pure-Dart simulation domain; headless replay must hold** (§IV). M12 work lives in
   presentation/derivation layers, leaving the sim core unchanged (consistent with the audit's
   finding that `lib/src/simulation` was untouched since M9).
10. **Care before payment; nothing M12 builds may become a monetization hook** (§VII; `Player Value
    Hypotheses.md` §6 betrayal risks).
11. **Solo, four-month MVP; scope creep is the primary risk** (§VIII). Default to the smallest change
    that delivers the emotional outcome.

---

## 5. Existing Building Blocks (what M12 leverages, already built)

All present at code-repo HEAD; the audit confirms each exists (`M12_Attachment_Audit_V1.md` §1).

- **Reputation** — earned, gates tiers via `tierReputationUnlock` thresholds; rendered today as a
  bare integer (`resource_header.dart`). The thresholds are the raw material for WP1's trajectory.
- **Offline progression (M7)** — `OfflineProgressionResolver` + `OfflineResolution` data + per-building
  lifetime metrics + `OfflineSummaryBanner`. All the data WP2 needs already exists; only the framing
  is numeric.
- **Event Feed (M8)** — `event_feed_panel.dart`, `eventFeedNarrative()`, bounded retention
  (`eventFeedMaxEntries`). The surface WP3 highlights into.
- **Building detail + upgrade flow (M6/M5)** — `building_detail_screen.dart`,
  `_upgradeEffectLabel`, before→after effects, `SimulationController.upgradeBuilding`,
  `GameSettings.firstUpgradePurchased`. The surface and the first-upgrade signal WP4 dramatizes.
- **Onboarding (M9)** — trust framing copy already teaches "Reputation is trust… never spent."
- **Analytics (M10)** — discrete, well-named events already fire at every meaningful moment
  (`analytics_events.dart`), non-blocking `SafeAnalyticsService`. The measurement spine for §9.
- **Spatial Town View track (FD1–FD9, parallel)** — Flame iso renderer, 45/45 cast re-rendered
  (FD7), overlay anchor resolver (FD9). This is the **affection / visual-place-making** lever the
  audit calls "Asset Driven… the biggest affection lever" — being delivered on its own track, not by
  M12 Stage 1.
- **Generativity audit tooling (code repo)** — the headless harness that measured "randomness, not
  character"; reusable to check M12 doesn't accidentally drift the sim.
- **Audio settings flags** — `soundEnabled` / `musicEnabled` persist in `GameSettings` with no
  consumer yet (audit §8): the latch Stage 2 hangs off.

---

## 6. Missing Capabilities (minimum new work)

Separated by necessity. "Required" = needed to hit the §3 outcome at Stage 1.

### Required (Stage 1 — all presentation/derivation; zero economy change)

- **A Reputation trajectory/destination view** near the header — derived from current Reputation +
  existing tier thresholds. (WP1)
- **An offline-return narrated beat** — derive busiest building, most-missed demand, and up to N
  notable events from existing `OfflineResolution` + lifetime metrics; reframe the banner. (WP2)
- **A "notable moment" derivation** over existing feed/metric data — readiness-threshold crossings,
  reputation milestones, a building that carried the day. (WP3)
- **First-upgrade stakes + affirmation beat** — copy + a small visual state keyed off the existing
  first-upgrade flag. (WP4)

### Helpful (strengthens the outcome; not strictly required)

- A single crystallizing **"now it is" readiness affirmation** when a building crosses from "Under
  pressure" to "Healthy" (extends WP3/WP4; the audit notes no moment "crystallizes 'now it is'").
- Light **service/upgrade/offline audio cues** (Stage 2 subset) — hooks already exist; needs an audio
  service + assets + a settings surface (audit §8).

### Future (explicitly deferred — NOT M12 Stage 1)

- **Recurring named-adventurer continuity / persistence (~20 cast).** Owned by **FD10**, which gates a
  design pass *then* a build pass; the audit marks it "scope-risky… Defer." Out of M12.
- **Full spatial street view / pathing** (FD3 slice two) — its own track.
- **Full audio production** beyond the high-priority cue set (Audio Pack §13 MVP scope).

---

## 7. Candidate Features

Each candidate rated for Purpose / Player value / Complexity / Risk / Constitution alignment.
**Rejected** candidates are kept visible so the boundary is legible.

### C1 — Reputation Destination (WP1) ✅ recommended
- **Purpose:** give the Reputation number a visible *direction of travel* toward a single aspiration.
- **Player value:** converts "second wallet" perception into *trust becoming something*. Lifts Trust
  (5/10) and Curiosity.
- **Complexity:** Low. Derive from current Reputation + `tierReputationUnlock`; render near header.
- **Risk:** Medium-low. Must **not** imply Reputation is spendable or a progress bar to "buy."
- **Constitution alignment:** ✅ with §V R1 ("surface Reputation's *trajectory* toward a single
  visible aspiration… remains earned, never spent") — this WP is the literal thing R1 authorizes.

### C2 — Offline Story (WP2) ✅ recommended
- **Purpose:** turn the offline banner from a payout into a catch-up *story*.
- **Player value:** the audit calls offline-return *"the strongest early proof the town is alive."*
  Lifts Curiosity; the #1 retention hook (`Player Value Hypotheses.md` §3).
- **Complexity:** Low-medium. Derivations over existing `OfflineResolution` + lifetime metrics.
- **Risk:** Medium. Must narrate Gold/served/missed only — **never** Reputation (§V R6); must not read
  as backlog or paid-relief bait.
- **Constitution alignment:** ✅ §V R5/R6; Audio Pack §8 reinforces the same beat for Stage 2.

### C3 — Notable Moments (WP3) ✅ recommended
- **Purpose:** lift specific, earned highlights out of the flat feed ("the Tavern carried the day,"
  "travelers are starting to trust the town").
- **Player value:** creates *town memory* and shareable small stories (`Player Value Hypotheses.md`
  §4). Lifts Affection and Pride.
- **Complexity:** Medium. A derivation/selection pass over existing metrics + feed.
- **Risk:** **Highest of the four** — this is where the Event Feed gravity toward a fiction engine is
  strongest (§VIII). Must stay derived-from-real-outcomes; no authored plot, no character arcs, no
  recurring named cast.
- **Constitution alignment:** ✅ only if held at §V R4's "economic-with-flavor" ceiling. Flag at
  review.

### C4 — Upgrade Affirmation (WP4) ✅ recommended
- **Purpose:** make the first upgrade feel like a *stewardship bet*, then affirm it landed.
- **Player value:** converts a "spreadsheet choice" (audit stage 5) into ownership/pride.
- **Complexity:** Low. Copy + a small visual state on the existing first-upgrade flag.
- **Risk:** Low. Keep affirmation cozy, not a level-up fanfare (Audio Pack §11 anti-goals).
- **Constitution alignment:** ✅ §II, §V R8.

### C5 — Minimal audio cue set (Stage 2) 🟡 sequenced after Stage 1
- **Purpose:** the sensory layer for the same moments (service, missed, upgrade, offline, Reputation).
- **Player value:** addresses the Affection gap from the audio side (Audio Pack §2).
- **Complexity:** Medium + asset-dependent. Needs an audio service behind a Safe/no-op wrapper, assets,
  and a settings surface for the existing flags.
- **Risk:** Medium. Must obey Audio Pack anti-goals (no fanfare, no shame buzzer, no casino tones).
- **Constitution alignment:** ✅ Approved Audio Pack; non-blocking, optional.

### C6 — Recurring named adventurers in the feed ❌ REJECTED for M12
- **Why rejected:** reopens FD10's gated persistence track and risks §V R2/R3 + §VI (per-visitor
  biographies). The audit itself defers it. Belongs to the FD10 design→build sequence, not the cheap
  attachment pass.

### C7 — Visual place-making inside M12 ❌ REJECTED (belongs to the spatial track)
- **Why rejected:** the affection-via-visuals lever is real but is being delivered by FD1–FD9 (Flame
  iso). Folding it into M12 would blow the "presentation-only, smallest change" scope (§VIII).
  M12 and the spatial track are complementary, not the same milestone.

### C8 — Make Reputation spendable to create "meaning" ❌ REJECTED (hard veto)
- **Why rejected:** directly violates §V R1/R10 and §III. Named here only to mark the boundary.

---

## 8. Recommended Scope (smallest implementation that delivers the outcome)

**Stage 1 — the attachment presentation pass (recommended M12 deliverable):**
ship **C1–C4** (WP1 Reputation Destination, WP2 Offline Story, WP3 Notable Moments, WP4 Upgrade
Affirmation), all derived from existing data, all in presentation/derivation layers, **zero**
economy/sim change. This is the audit's "Smallest Path To Emotional Completeness" — the cheap,
high-leverage half — and it is the set the founder's own validation prompt already enumerated.

**Stage 2 — sensory pass (sequenced after Stage 1 proves out):** the high-priority audio cue set
(C5), per `Audio_Direction_Pack_V1.md` §13, behind a non-blocking audio service + a settings surface.

**Explicitly out of M12:** named-adventurer persistence (FD10 track), spatial street view (FD3 slice
two), and any economy touch. The biggest single affection lever (visual place-making) is delivered in
parallel by the spatial track, **not** by M12 — M12's job is the editorial/derivation layer the audit
proved is cheap and missing.

**[AI INFERENCE]** Recommending C1→C4→C2→C3 as the build order within Stage 1 (see implementation
order at the end) — sources rank by leverage, not by build order, so the ordering is reconstructed.

---

## 9. Validation Plan (how we know M12 succeeded)

The Approved hypotheses are explicit that **analytics alone cannot prove attachment** — qualitative
playtest is required (`Thirty_Minute_Attachment_Hypotheses_V1.md` §9; `Player Value Hypotheses.md`
§8). M12 validation is therefore two-track.

### Quantitative (analytics — spine already instrumented, M10)
- **First-upgrade conversion** and **time-to-first-upgrade** (does WP4 land?).
- **Offline-return view/engagement** rate (does WP2 get seen and dwelt on?).
- **Day-1 return** (does the session leave unfinished intention?).
- **Reputation-destination view** engagement (does WP1 get noticed?).
- No regression in analyzer-clean / tests-green health gate (`M12_Stage1_Validation_Report.md` §4
  shape).

### Qualitative (playtest — the decisive evidence)
From `Thirty_Minute_Attachment_Hypotheses_V1.md` §9 / `Player Value Hypotheses.md` §8, players should,
unprompted:
- Describe Reputation as **trust**, not spendable currency.
- Read missed demand as **lost opportunity**, not punishment.
- Recall the **Event Feed** / a notable moment as town memory.
- Respond to offline return as a **story**, not only a payout.
- Leave with a **next improvement** in mind, and articulate why they'd return tomorrow.
- The strongest positive signal: a player saying, in their own words, *"I want to make the town
  better before more adventurers come through."*

### Per-WP acceptance (reconstructed from the audit's intent)
- **WP1 PASS:** Reputation shows a destination/trajectory; players stop reading it as a wallet.
- **WP2 PASS:** offline return narrates busiest building + most-missed demand + ≤N notable events;
  players react with curiosity.
- **WP3 PASS:** the feed surfaces ≥1 derived notable moment that players recall.
- **WP4 PASS:** first upgrade reads as a stewardship bet + a cozy affirmation; players report
  ownership, not compliance.

### Retention hypotheses being tested
- Offline-return-as-story raises Day-1/Day-N return (`Player Value Hypotheses.md` §3).
- A visible Reputation destination raises multi-session return ("the town becoming known").
- "One affordable, several wanted" session rhythm sustains return without manufactured friction.

### Acceptance gate for Stage 2 and for M11
- Stage 2 (audio) begins only after Stage 1 ships and shows attachment lift (the
  `M12_Stage1_Validation_Report.md` Go/No-Go shape).
- **M11 monetization stays downstream of demonstrated attachment/retention** (audit §11).

---

## 10. Open Founder Decisions (do not invent answers)

1. **Does this reconstruction correctly stand in for the missing `M12_Attachment_Plan_V1.md`?** Or
   does an authoritative copy exist off-repo that should govern instead?
2. **Stage-1 WP set confirmation:** are WP1–WP4 exactly the four, with the audit-§10 mapping, the
   intended scope? Any WP to add/cut?
3. **Reputation Destination form (WP1):** what is the *single visible aspiration* Reputation travels
   toward (§V R1 names one but does not specify it)? A named trust tier? A town-standing label? This
   is a founder framing call.
4. **Notable Moments ceiling (WP3):** confirm the editorial line — which derived highlights are
   in-bounds, and the hard stop short of authored narrative (§V R4).
5. **Stage 2 timing & audio production:** approve sequencing audio after Stage 1, and the
   high-priority cue set + settings surface (Audio Pack §13). Asset production owner?
6. **M12-before-M11 run order:** confirm attachment ships before monetization despite the numbering.
7. **Relationship to FD10:** confirm named-adventurer persistence stays **out** of M12 and on the
   FD10 design→build track.
8. **Relationship to the spatial track:** confirm visual place-making (affection lever) is owned by
   FD1–FD9, not M12.
9. **`M12_Stage1_Status_Correction_V1.md`:** the code-repo Open Loops references a possible status
   correction — does it exist, and does it change any of the above?

---

## Confidence Assessment

**Overall: HIGH confidence on intent and Stage-1 scope; MEDIUM on exact form; LOW only on a handful
of framing specifics reserved to the founder.**

- **HIGH** — *What player problem M12 solved* (comprehension→care; ~50/100 attachment): triangulated
  across the audit (measured), both Approved hypotheses docs, and the Constitution. Multiple
  independent sources agree.
- **HIGH** — *The Stage-1 WP set*: the four WP names come from the founder's own validation prompt
  (`M12_Stage1_Validation_Report.md`) and map cleanly onto the audit's "Presentation Only" rows.
- **HIGH** — *The constraints*: lifted verbatim from the authoritative Constitution and ratified FD10.
- **MEDIUM** — *The exact two-stage shape and that "Stage 1 = these four"*: inferred from the
  validation report's Stage-1/Stage-2 structure, not from a surviving plan doc.
- **LOW / founder-reserved** — *Specific form of the Reputation destination, the precise Notable-Moment
  catalog, audio timing*: deliberately left to §10.

## Missing Evidence

- The **original `M12_Attachment_Plan_V1.md`** — never located in either repo; this is a
  reconstruction, not a recovery.
- **`Current_State_V10.md`** — referenced as unavailable by *three* approved docs (the hypotheses
  docs + audit); its absence is a recurring gap in the canon.
- **`M11_Monetization_Plan_V1.md`** — present but not fully read this pass; M12-before-M11 sequencing
  rests on the audit's recommendation, not on M11's own text.
- **`Package_C_Outcome_Overlay_Scope_V1`** — referenced by FD9/spatial work but confirmed absent
  (per `docs/FD9_PhaseC_SyntheticMark_Proof_Report_V1.md` §6); not an M12 dependency, noted for
  completeness.
- **A formal `M12_Stage1_Status_Correction_V1.md`** — referenced in RobOS Open Loops; existence
  unconfirmed.

## Contradictions Discovered

1. **"Plan missing" vs. "substance present."** `docs/M12_Stage1_Validation_Report.md` correctly found
   no `M12_Attachment_Plan_V1.md` in the **code** repo and concluded Stage 1 could not be validated.
   But the plan's *substance* lives in the **design** repo (the audit + hypotheses) the validator
   couldn't see. The blocker was real; the intent was never actually lost — only un-committed to code.
2. **WP names "from the task," not from a plan.** The validator says the WP names came "from the task
   structure itself." So the four WPs are founder-authored via the prompt, even though no plan doc
   carried them — consistent, but worth flagging that the WP list's provenance is the prompt, not a
   document.
3. **FD10 admits per-adventurer renown; M12 must still exclude named-cast persistence.** FD10 (and its
   reconciliation caveat C3) *opened* per-adventurer renown — which could be read as license to add
   recurring named adventurers now. It is **not**: FD10 explicitly gates a design pass before any
   build, and the audit defers the same feature. M12 Stage 1 must hold that line; the tension is real
   and is surfaced (§6 Future, C6, §10.7).
4. **Numbering vs. run-order.** M12 is numbered after M11 but the audit recommends it run *before*.
   Not a true contradiction, but an inversion that the plan must state plainly.

## Questions Requiring Founder Review

The nine items in **§10** are the founder-reserved questions. The three most load-bearing:
- **§10.1** — does this reconstruction stand in for the missing plan?
- **§10.3** — what is Reputation's single visible destination (WP1)?
- **§10.4** — where exactly is the Notable-Moments editorial ceiling (WP3)?

## Recommended Implementation Order

Pending founder approval of §8 scope, and **TDD-first** (write the failing
derivation/presentation tests before the implementation), build Stage 1 in leverage-and-safety order:

1. **WP1 — Reputation Destination.** Lowest complexity, highest trust leverage, and the literal thing
   §V R1 authorizes. Derivation + header-adjacent view. **[AI INFERENCE]** ordered first.
2. **WP4 — Upgrade Affirmation.** Low complexity, low risk; keyed off the existing first-upgrade flag.
3. **WP2 — Offline Story.** Medium; reframes existing `OfflineResolution` into a narrated beat.
   Highest retention payoff.
4. **WP3 — Notable Moments.** Last within Stage 1 — highest scope-risk (Event Feed gravity), so build
   it once the cheaper wins are proven and reviewed against §V R4.
5. **Validate Stage 1** (analytics + playtest, §9). Only on a pass:
6. **Stage 2 — minimal audio cue set** (C5), per Audio Pack §13.
7. **Then** revisit **M11 monetization**, now downstream of demonstrated attachment.

Throughout: sim/persistence domains stay untouched; re-run the generativity-audit harness if any
change risks touching the engine, to prove headless determinism still holds.

---

*M12_Attachment_Plan_V1.md · Adventurer Town · CANONICAL M12 milestone document · founder-approved
2026-06-28 · reconstructed from project knowledge at code-repo HEAD `85f6d27` · subordinate to
CLAUDE.md · build of work packages NOT yet authorized (see §10 open founder items).*
