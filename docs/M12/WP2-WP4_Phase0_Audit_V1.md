# M12 Stage-1 Conformance & Design Audit — WP2/WP3/WP4 — Phase 0 Report V1

| Field | Value |
|---|---|
| Working Title | Adventurer Town |
| Record Type | Phase 0 conformance & design audit (VERIFY ONLY — no build) |
| Version | V1 |
| Measured at | HEAD `5ba9974` · branch `claude/happy-bohr-1rhyw4` · working tree clean · 2026-07-01 |
| Audit authority | `WP2-WP4_Phase0_Audit_Prompt_V1.1` (founder-issued) |
| Delivered | 2026-07-01, in-session (per Phase 0 rules, no file was written at delivery) |
| Filed | 2026-07-01 by FD11 (`docs/founder/FD11_Stage1_Ratification.md`) — content verbatim from the in-session delivery |

---

## 1. Summary table

| WP | Implementation state | Lens A (CLAUDE.md + plan) | Lens B (design constants) | FIX-TO-CONFORM | DESIGN FORKS |
|---|---|---|---|---|---|
| WP2 Offline Story | **SUBSTANTIAL** | **CONFORMS** | Beats 1–2 **absent**; beat 3 partial | 1 (MINOR) | 1 |
| WP3 Notable Moments | **SUBSTANTIAL** | **CONFORMS** (ceiling held, adversarially checked) | Beats 1–2 **absent** in all 3 moment types | 2 (MINOR) | 1 |
| WP4 Upgrade Affirmation | **SUBSTANTIAL** | **CONFORMS** (anti-goal honored) | Beat 3 only; beats 1–2 absent | 1 (MINOR) | 1 |

All three WPs share one authorization-drift finding (§3.0) identical in shape to WP1's, plus one cross-cutting precedence finding on the Lens B constants themselves (§2.6).

## 2. Phase 0.0 — Context verification

1. **Commits.** All three exist: `c41b22d` "M12 Stage 1: attachment presentation pass" (2026-06-19), `49b58b8` "WP1 (M12): town-voice Town Standing labels + single standing source", `5ba9974` "chore: clear 4 pre-existing analyzer issues". **Push status: `5ba9974` is local-only** — `git branch -r --contains 5ba9974` returns empty; `c41b22d` and `49b58b8` are contained in `origin/claude/happy-bohr-1rhyw4`; branch is ahead of origin by exactly that one commit. The "possibly local-only" flag is **confirmed**.
2. **Test baseline.** `flutter test` at HEAD: **336 tests, all passed** (exit 0). Matches the believed baseline exactly. Delta: 0.
3. **Plan of record located — at a different path than claimed.** The audit prompt says `docs/M12/M12_Attachment_Plan_V1`; the actual file (at audit time) was **`docs/M12_Attachment_Plan_V1.md`** (repo `docs/` root). Per the precedence rule, the repo governs; discrepancy reported. *(Corrected post-audit: FD11 moved it to `docs/M12/`.)* The plan's own names and scopes (plan §2a, §6; corroborated by `M12_Stage1_Status_Correction_V1.md` §2):
   - **WP2 "Offline Story"** / "Offline Return as a Story" — "an offline-return narrated beat — derive busiest building, most-missed demand, and up to N notable events from existing `OfflineResolution` + lifetime metrics; reframe the banner" (plan §6).
   - **WP3 "Notable Moments"** / "Notable Town Moments in the Feed" — "a 'notable moment' derivation over existing feed/metric data — readiness-threshold crossings, reputation milestones, a building that carried the day" (plan §6); "derived at render time; no new `EventType`" (Status Correction §2).
   - **WP4 "Upgrade Affirmation"** / "First Upgrade Stakes and Affirmation" — "first-upgrade stakes + affirmation beat — copy + a small visual state keyed off the existing first-upgrade flag" (plan §6). The prompt's shorthand ("Affirmation") is consistent; the plan's names govern the rest of this audit.
4. **Status Correction doc.** `M12_Stage1_Status_Correction_V1.md` confirmed (at audit time, repo root). It corrects the contradiction between `d0020c5` ("Stage 1 not present" — measured pre-build at `fa677aa`) and `c41b22d` (Stage 1 implemented), declaring `c41b22d` / tag `m12-stage1-attachment` authoritative, with 189 tests green at that commit (§3). Bearing on WP2–WP4: it is the document that establishes all four WPs shipped in `c41b22d` as "strictly presentation-only" (§2). No conflict with the plan (plan §10.9 asked whether this doc exists; it does). **Filing drift:** CLAUDE.md contains **no explicit filing rule** for governance docs (nearest signal: §IV routes FD records to `docs/founder/`, and every other governance artifact lives under `docs/`); the root-level location deviated from repo convention, not from a written rule. Finding, no fix at audit time. *(Corrected post-audit: FD11 moved it to `docs/M12/`.)* Its §4 follow-up option 1 (supersession banner on the validation report) was since executed by `49b58b8` — the banner is present at `docs/M12_Stage1_Validation_Report.md:1`.
5. **Provenance.** `git log --follow` per file: `notable_moments_panel.dart` created in `c41b22d`; `offline_summary_banner.dart` WP2 layer added in `c41b22d` (file itself pre-exists from `facddfe`/M7); WP4 hunks in `building_detail_screen.dart` from `c41b22d`; WP2/WP3 derivations in `town_view_models.dart` from `c41b22d`. **All three WPs rode in `c41b22d` as claimed.** Two later touches verified benign: `cb88b28`/`4e5bd15` (spatial cutaway entry button only — diffs contain zero references to stakes/affirmation code); `49b58b8` (the WP1-authorized standing-source convergence, which rewrote WP3's `_standingMoment` copy — authorized by `WP1_Reputation_Destination_Arbiter_Record_V2.md` §6.1, executed with the record cited in the commit body per its §7 acceptance).
6. **WP1 "closed" claim: CONFIRMED**, with the §6 copy amendment, single standing source, test update, and §5 supersession banner all executed at `49b58b8`; 336 green cited in that commit body. **Cross-cutting precedence finding on the Lens B constants:** the three Phase-0.3 "locked founder decisions" appear in **no in-repo governing document** (searched CLAUDE.md, the plan, FD records, `docs/M12/`) — their in-repo provenance is the audit prompt only: **UNVERIFIED in-repo**. Worse, constant 1's wording ("adventurers are lives being cultivated, **never customers**") directly conflicts with CLAUDE.md §II.2 ("Adventurers are **autonomous customers**, not units to command"). Per the prompt's own precedence rule, the Constitution wins until amended. Beat 1 ("name a life") also sits adjacent to plan C6 ("Recurring named adventurers in the feed — ❌ REJECTED for M12") and the FD10 gate — one-off read-time naming is not recurring persistence, but the boundary needs founder wording. **FD11 must record the constants in-repo and reconcile these three collisions before any beat-conformance build is authorized.**

## 3. Per-WP verdicts

### 3.0 Shared finding — authorization drift (all three WPs, WP1-reconciliation format)

**Finding:** `c41b22d` carries no authorizing FD/plan/sign-off in its commit body; the only approval that exists — plan promotion at `d74b284`, 2026-06-28 — post-dates the build by eight days and "explicitly disclaims build authorization" (plan header: "build of work packages NOT yet authorized"; identical finding for WP1 in `WP1_..._Arbiter_Record_V2.md` §3). **Resolution proposed (mirrors WP1's ratified 1a):** the build preceded the governance rather than violating it; Lens A conformance is clean for all three (below); retroactive ratification via FD11, drift closed, not litigated. The WP1 §3 process tightening (pre-build authority check recorded in the commit body) already exists and was demonstrably followed at `49b58b8`.

### 3.1 WP2 — Offline Story

**Inventory.** Derivation: `offlineStoryLines()` (`town_view_models.dart:180-215`), helpers `_topCountBuilding` (:242-253), copy maps `_offlineBusiestLine` (:217-227) / `_offlineMissedLine` (:229-240). UI: `storyLines` param + render block in `offline_summary_banner.dart:14,29,66-74`, rendered above the retained honest scalars. Wiring: `town_view.dart:76` from the existing `townEventFeedProvider`. Reads only `EventFeedItemViewModel` rows flagged `isOffline`.

**State: SUBSTANTIAL** — complete pure derivation, wired, rendered, tested (unit: `m12_stage1_derivations_test.dart:104-151`; widget: `m12_stage1_test.dart:40-70`).

**CONFORMS (Lens A):**
- Gold-only / no offline Reputation: no WP2 string mentions Gold, Reputation, trust, or spend; Gold stays in the banner's honest scalar (`offline_summary_banner.dart:76`); enforced by forbidden-substring test (`m12_stage1_derivations_test.dart:127-150` forbids `reputation`, `queue`, `backlog`, `recover`, `buy`, `pay`, `unlock`, `restore`, `$`). Pipeline itself withholds offline Reputation (`offline_progression.dart:41-44`).
- No scold (travelers "moved on"/"passed by" — departure framing, `town_view_models.dart:229-240`); no backlog/queue implication; no paid-relief bait. Persistence: **zero** — `c41b22d` touched no persistence file; sole `@collection` is `SimulationSaveRecord`, unmodified.

**Lens B:** Beat 1 **ABSENT** — copy uses exactly the failing aggregate pattern ("Some tired travelers…", "A few hungry adventurers…", `town_view_models.dart:229-240`). Beat 2 **ABSENT** — no tier/arc language. Beat 3 **partial** — town service credited causally ("The Tavern kept the town fed…", :219) but with no life attached. Named-life data exists in the model (`Adventurer.displayName`, `adventurer.dart:75`; `EventFeedEntry.adventurerId/adventurerTier`, `event_feed_entry.dart:56-57`) but is **dropped in the view-model mapping** (`town_view_models.dart:587-599`).

**FIX-TO-CONFORM (1):** test/dead-code hygiene — fallback lines at `town_view_models.dart:204-205, 209-210` are unreachable (both copy maps cover all five `BuildingType` values) and untested, as are the `.take(2)` cap and tie-break. Severity **MINOR**, scope **S**.

**DESIGN FORK (1) — beat retrofit source-of-name.** Options:
- **(a) Read-time join (recommended):** surface `adventurerId`/`adventurerTier` through `EventFeedItemViewModel` and join to `SimulationState.adventurers` for `displayName`. No new persistence. Join is currently safe: no adventurer-removal call exists anywhere in `lib/src/simulation` (departing adventurers get `state: departing` + `departureTick`, `simulation_engine.dart:114-116,145-147`, and stay in the map). Tradeoff: correctness silently depends on the roster never being pruned — needs a guarding test or a graceful no-name fallback.
- **(b) Denormalize `displayName` onto `EventFeedEntry`:** robust to future pruning, but the feed is persisted inside `SimulationSaveRecord.stateJson` (`simulation_save_record.dart:9`), so this **changes persisted shape — a design violation** under the never-persisted rule. Included only to mark the boundary.
- **(c) Beats 1+3 now, beat 2 later:** name the life and credit the town from feed data; defer "what moved them" until arc derivation is settled (per-adventurer offline arc deltas are not currently computed — `offline_progression.dart:97-99,116-118` aggregates only; whether arc movement is reconstructable read-time is UNVERIFIED).
- **Recommendation: (a)**, with (c)'s phasing if beat-2 derivation proves non-trivial.

### 3.2 WP3 — Notable Moments

**Inventory.** `NotableMomentViewModel` (`town_view_models.dart:91-99`), `deriveNotableMoments(SimulationState)` (:105-137), `_standingMoment` (:144-159, copy converged by `49b58b8`), `_topServedBuilding` (:161-175), `townNotableMomentsProvider` (:447-456), `NotableMomentsPanel` (`notable_moments_panel.dart:10-80`), wired above the Event Feed (`town_view.dart:25,103-107`). **Render-time only, confirmed:** no new `EventType` (enum byte-identical to pre-M12), no feed write, no persistence touch.

**State: SUBSTANTIAL.**

**Moment-type enumeration — exactly three, nothing else found:**
1. **Standing reached** (:144-159): "Travelers now know the town as a {Reliable Stop | Trusted Haven | Beacon of the Roads}." — thresholds 100/400/1200 from the shared standing source.
2. **All services open** (:113-123): "Every service in town is open — the Inn, Tavern, Blacksmith, Healer, and Market all stand ready."
3. **Carrier** (:125-134): "{Building} has served more adventurers than anywhere else in town." — max `lifetimeDemandServed`.
Capped at three (:136; panel re-caps, `notable_moments_panel.dart:13`).

**CONFORMS (Lens A — adversarially checked):** all three types derive from real economic outcomes (earned Reputation thresholds; construction state; lifetime served counts — all pre-existing fields, `building.dart:86,97`). No authored plot, no character arc, no branch/choice/quest, no missed-demand scolding (no missed-demand branch exists), no spend implication, **no named cast — FD10 boundary held**. The §V R4 ceiling is not exceeded by any implemented type.

**Lens B:** Beats 1 and 2 **ABSENT in all three types** ("Travelers"/"adventurers" are aggregates); beat 3 present only in Carrier. The central fact: `deriveNotableMoments` already receives the full `SimulationState` — `state.adventurers` with `displayName` and `tier` is **available at read-time and simply never read** (:105-137 reads only `resources.reputation` and `buildings`). The spine gap is a choice, not a data limitation.

**FIX-TO-CONFORM (2):**
1. Standing copy strings are untested — the only standing test asserts an id, not the string (`m12_stage1_derivations_test.dart:63-66`); the `49b58b8` rewrite shipped with no string-level assertion. Add verbatim-copy tests. **MINOR / S**.
2. WP3 strings bypass the spend/offline forbidden-substring guard applied to WP1/WP2 copy (:39-48, :136-146); its own cap test forbids only quest/hero/battle/boss (:96). Extend the guard to WP3 output. **MINOR / S**.

**DESIGN FORK (1) — arc-stakes concentration (DELTA REPORT, not violation — constant post-dates the code).** Current selection: static aggregate maxima (highest threshold crossed; max lifetime served with enum-order tie-break; fixed append order; no recency, no per-adventurer dimension). Delta to arc-stakes selection: `Adventurer` already carries `displayName`, `tier`, `state`, `arrivalTick`, `departureTick`, `expectedReturnTick`, `lastServiceBuildingType`, `lastOutcomeEventId`, `wealthBand` (`adventurer.dart:74-90`) — enough to name a life, show tier, and land beat-3 credit ("the smith who armed her") **entirely read-time**. "Fresh triumph / near-disaster" heat needs derivation over existing feed rows (read-time, feasible) — there is no per-adventurer history counter, and adding one would be **new persistence = violation**; the read-time path avoids it. Options: **(a)** full arc-stakes rework of moment selection (recommended, built last); **(b)** additive — keep the three town-level moments, add adventurer-arc moment types above them; **(c)** defer WP3 entirely to a later FD. **Recommendation: (a)**, sequenced last per scope risk.

### 3.3 WP4 — Upgrade Affirmation

**Inventory.** Single surface, `building_detail_screen.dart`: `firstUpgradePending` select on the **pre-existing** `GameSettings.firstUpgradePurchased` flag (:41-46; flag introduced by `fa677aa`/M10, not by `c41b22d`); `_FirstUpgradeStakesNote` (:430-468, key `first-upgrade-stakes-note`, shown conditionally :174-177); `_upgradeAndAffirm` (:393-418) routing both upgrade buttons (:182, :197) and showing a default `SnackBar` (key `upgrade-affirmation`) with first-time vs repeat copy (:414). **No authored animation, no timer, no confetti.** Later spatial commits verified non-interfering (§2.5). Persists **nothing new**.

**State: SUBSTANTIAL** (widget tests assert the note pre-purchase and the affirmation + intact economics post-purchase: `m12_stage1_test.dart:96-137`).

**CONFORMS (Lens A — anti-goal adversarially checked): no level-up fanfare found.**
- Stakes: "Your first improvement is yours to choose. Capacity helps more adventurers; Value earns more from each one served. Either way, you are deciding what this town is ready for." (:455-457)
- First affirmation: "Your first improvement — the town is more capable now. This is stewardship: you decide what the town is ready for." (:421-422)
- Repeat: "Upgrade complete — the town can do a little more for those who pass through." (:425)
All town-centered stewardship register; no hero/achievement framing; no monetization-hook shape; the code comment at :429 states the intent ("never … a purchase prompt, a wager, or a power boost"). One borderline note: `Icons.flag_outlined` (:448) reads faintly as "planting a flag" — muted, outlined, judged PASS; flag for the eventual art/audio pass.

**Lens B:** Beat 3 present ("the town is more capable now"); beats 1–2 **ABSENT** (aggregates only: "more adventurers", "each one served", "those who pass through"). Mild transactional framing ("earns more from each one served") — a finding **only under the audit prompt's constant 1**, which conflicts with CLAUDE.md §II.2 (§2.6); under the governing corpus as written at audit time, it conforms. Precedence-dependent; resolved by FD11's wording.

**FIX-TO-CONFORM (1):** test gaps — the repeat-affirmation branch is never exercised, and stakes-note disappearance after first upgrade is never asserted. **MINOR / S**.

**DESIGN FORK (1) — connecting affirmation to a life.** Per-adventurer data is **not available at this surface** (it reads `buildingDetailProvider`/`buildingRecentActivityProvider` — aggregates only, :25,:31). Options: **(a)** leave WP4 as beat-3-only — the affirmation is about a decision, not a service event, and forcing a named life into it may be false causality (an upgrade doesn't move any specific adventurer's arc at purchase time); **(b)** read-time enrichment — name a currently-present adventurer the upgrade will serve, no persistence; **(c)** cross-session arc credit — **rejected inline**: requires remembered per-visitor history = new persistence = violation. **Recommendation: (a)**, with (b) as copy-level option if the ratified constants demand beat 1 on every surface — this is the "can beat 3 land on drama-selected subjects" question, answered: at *this* surface, only artificially.

## 4. Out-of-scope findings (report only)

1. **`5ba9974` unpushed** — the branch's analyzer-zero state is not on the remote (§2.1).
2. **Adventurer roster is never pruned** in `lib/src/simulation` (verified by absence: no removal call; departing adventurers remain in `SimulationState.adventurers`). Potential unbounded growth over long saves; whether anything bounds it elsewhere is UNVERIFIED. Also load-bearing for fork WP2-(a).
3. **WP2 fallback copy lines are dead code** (`town_view_models.dart:204-205, 209-210`) — unreachable while both maps cover all five building types.
4. **`M12_Stage1_Status_Correction_V1.md` filing drift** (root vs `docs/` convention) — carried from §2.4. *(Corrected post-audit by FD11.)*

## 5. FD11 readiness statement

WP2–WP4 **can be retired alongside WP1 in a single consolidated FD without a prior build phase.** The drift is identical in shape and remedy to WP1's ratified case: same commit (`c41b22d`), same absence of an authorizing record, same post-dated plan disclaiming build authorization, and — decisive for the 1a remedy — clean Lens A conformance across all three, evidenced above (economic-with-flavor ceiling held in every implemented WP3 moment type; Gold-only offline narration with test enforcement; no fanfare in WP4; zero new persistence anywhere in `c41b22d`; 336 tests green at HEAD). The Lens B beat gaps do not block retirement: the concentration constant is explicitly delta-not-drift, and the beat spine/fantasy constants were not yet recorded in the governing corpus (§2.6) — so non-conformance to them cannot be drift *yet*. FD11 should therefore do three things: ratify WP2–WP4 retroactively (closing `c41b22d` in full), record the three design constants in-repo (reconciling §II.2 wording, plan C6, and the FD10 boundary), and authorize the Phase 1 build below.

## 6. Proposed Phase 1 scope (await authorization)

1. **FD11 documentation** — retire drift; record constants; resolve the three forks (WP2 name-source → recommend read-time join; WP4 → recommend beat-3-only; WP3 → recommend arc-stakes rework). Doc-only; gates everything below.
2. **Push `5ba9974`** (hygiene, not build).
3. **Test hardening** — WP3 standing-copy assertions + forbidden-substring guard extension; WP4 repeat-branch + stakes-note-disappearance tests; WP2 dead-fallback cleanup + cap/tie-break tests. (S, MINOR ×4)
4. **WP2 beat retrofit** — surface `adventurerId`/`tier` through `EventFeedItemViewModel`, read-time name join, beat-conformant copy templates. (M, MAJOR)
5. **WP4 per fork resolution** — likely copy-only or no-op. (S)
6. **WP3 arc-stakes selection rework** — **last, regardless** (highest scope risk): read-time drama selection over existing adventurer fields + feed rows; hard rule of no new persistence. (M–L, MAJOR)

---

*WP2-WP4_Phase0_Audit_V1.md · Adventurer Town · `docs/M12` · Phase 0 verify-only audit · measured at `5ba9974` 2026-07-01 · filed by FD11 · every claim cited or marked UNVERIFIED.*
