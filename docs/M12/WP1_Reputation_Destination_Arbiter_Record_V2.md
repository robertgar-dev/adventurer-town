# M12 WP1 Reputation Destination — Ratification & Conformance Record

| Field | Value |
|---|---|
| Working Title | Adventurer Town |
| Record Type | Ratification & Conformance Record (supersedes the V1.1 build-gate Arbiter Record) |
| Version | **V2** |
| Status | **RATIFIED — Robert, 2026-06-28** (1a + 2a). One authorized copy-amendment task pending execution (§6). |
| Document Path | `docs/M12/WP1_Reputation_Destination_Arbiter_Record_V2.md` |
| Supersedes | `WP1_Reputation_Destination_Arbiter_Record_V1.md` (V1.1) — its build-gate framing is moot; WP1 shipped before it was written. |
| Measured against | HEAD `d74b284` · branch `claude/happy-bohr-1rhyw4` · `CLAUDE.md` supreme |
| Depends on | `CLAUDE.md`, `docs/M12_Attachment_Plan_V1.md`, `docs/founder/FD10_*.md`, the WP1 conformance audit (2026-06-28) |

---

## 0. Why V2 replaces V1.1

V1.1 gated a *build* of WP1. The conformance audit proved WP1 **already shipped** at commit `c41b22d` (tagged `m12-stage1-attachment`, an ancestor of HEAD) — eight days **before** the M12 plan, the tribunal, or the record existed. The design track and the code track had drifted apart; neither knew the decision was already implemented.

V2 therefore stops being a build gate and becomes a **ratification + conformance** record: it ratifies Town Standing, audits the shipped code against the decision and against `CLAUDE.md`, closes the authorization drift, and authorizes a single presentation-only copy amendment to make the shipped labels match the ratified decision.

---

## 1. The Ratified Decision

**Reputation is surfaced as Town Standing** — a derived, never-spent, never-persisted named-tier label rendered in the Resource Header, showing the town's trajectory toward a single visible aspiration (§V R1; the form named open in plan §10.3). The shipped implementation at `c41b22d` is **retroactively ratified** as the canonical WP1, subject to the §4 copy amendment.

- **Adventurer Confidence** voice survives only as collective/by-tier flavor in WP3/WP2 — never as the WP1 axis, never individual (§III; §V R3; §VI).
- **Regional Renown** frame rejected (§VI; §V R2).

---

## 2. Conformance Audit Result (measured at HEAD)

No `CLAUDE.md` conflict found in the shipped WP1 code.

| Claim about shipped WP1 | Status | Evidence |
|---|---|---|
| Derived, render-time, returns a value object | CONFIRMED | `town_view_models.dart:19-20, 56-78`; immutable `ReputationDestination` (28-46) |
| Persists nothing; no new field/resource/threshold | CONFIRMED | no Isar write; reuses `EconomyConstants.tierReputationUnlock` |
| Keys off existing thresholds 100/400/1200 | CONFIRMED | `town_view_models.dart:51-53` ≡ `economy_constants.dart:93-95` |
| §V R1 — trajectory→aspiration, not a fill/XP bar | PASS | "more to earn" framing (l.66); "deliberately not a progress/fill bar" (`resource_header.dart:102-103`) |
| §III / §V R10 — never spendable, no new resource | PASS | transient value object; reputation never decremented in this surface |
| §V R6 — no offline Reputation | PASS | derives from current reputation only; no offline path |
| §V R4 — WP1 writes nothing to the Event Feed | PASS | WP3 `_standingMoment` owns the feed line, not WP1 |
| §VI — no new building/resource/axis | PASS | none introduced |
| `lib/src/simulation` untouched by the build | CONFIRMED | `git diff-tree c41b22d` → 0 sim/persistence files |

The architecture the tribunal protected is exactly what is in the tree. The WP1-writes-nothing-to-the-feed / WP3-owns-the-standing-line split (a V1.1 amendment) is already how the code is structured.

---

## 3. Authorization Drift — Recorded and Closed (decision 1a)

**Finding:** `c41b22d` carries no authorizing FD/plan/sign-off. It was committed under the founder's own git identity (Rob Garfinkle, co-authored by Claude, 2026-06-20). The only approval that exists — the M12 plan promotion (`d74b284`, 2026-06-28) — post-dates the build by eight days and explicitly disclaims build authorization.

**Resolution (1a — retroactive ratification):** the build preceded the governance rather than violating it. It is hereby ratified as conformant after the fact (see §2). The drift is **closed**, not litigated. This is not a breach review.

**Process tightening (so it can't recur):** before any future Stage-1/M12 build commit, a one-line pre-build check is required — *"Does an authorizing record (FD / plan WP / ratified arbiter record) exist in-repo for this work?"* — recorded in the commit body. Drift is prevented by making authority a commit-time fact, not a later reconciliation.

---

## 4. Label Amendment (decision 2a) — town voice, single source

**Problem.** The shipped intermediate labels name *the cohort attracted* — "seasoned / elite / legendary adventurers" — which is the tier-readiness framing the tribunal **rejected**. Only the apex line speaks in town voice. A second, divergent standing copy set lives in WP3 (`_standingMoment`, `town_view_models.dart:131-153`) on the same thresholds.

**Decision (2a).** Hold **Town Standing**. Rewrite the three intermediate labels to town voice and converge WP1 and WP3 onto **one** canonical standing source. Presentation-only — thresholds, derivation logic, value-object shape, and persistence are untouched.

**Canonical Town Standing set** (keyed to the existing, unchanged `tierReputationUnlock` thresholds):

| Existing threshold | Town Standing label (NEW) | Replaces (shipped) |
|---|---|---|
| 100 | **Reliable Stop** | "seasoned adventurers" |
| 400 | **Trusted Haven** | "elite adventurers" |
| 1200 | **Beacon of the Roads** | "legendary champions" |
| apex copy (rep ≥ 1200) | **"Known and trusted across the land"** *(retained — already town voice)* | — |

Trajectory template is unchanged: `Trust growing toward {label} — {remaining} more to earn` → now reads e.g. *"Trust growing toward Trusted Haven — 240 more to earn."* The label strings above are the recommended set and remain founder-tweakable; the **structure** (town voice, one source, no logic change) is ratified.

---

## 5. Doc Reconciliation

`docs/M12_Stage1_Validation_Report.md` reports "0/4 BLOCKED," measured at `fa677aa` (pre-build), and is superseded by `M12_Stage1_Status_Correction_V1.md`. Both live in the repo — a hazard for the next reader. Apply a 3-line supersession banner to the **top** of the validation report only (no body edit, no history rewrite):

> ⚠️ SUPERSEDED — measured at `fa677aa` (pre-build). M12 Stage 1 shipped at `c41b22d` (tag `m12-stage1-attachment`); see `M12_Stage1_Status_Correction_V1.md`. The "0/4 / BLOCKED" verdict below is stale.

---

## 6. Authorized Execution Scope (what Claude Code may do)

This record **authorizes one bounded, presentation-only task** — no build gate remains. Claude Code may:

1. Extract a single canonical standing source (label-per-threshold + apex copy) and have **both** WP1's trajectory derivation and WP3's `_standingMoment` consume it.
2. Apply the §4 town-voice labels.
3. Update any test that asserts the old label strings to the new strings (threshold/logic assertions unchanged).
4. Apply the §5 supersession banner.

**Red lines (MUST NOT):** change thresholds 100/400/1200 · alter the derivation logic or the `ReputationDestination` value-object shape · add/remove a band · introduce any persisted field · touch `lib/src/simulation` or persistence · alter offline behavior, WP2, or WP4 · make Reputation spendable · add any Event Feed *semantics* (copy convergence only).

---

## 7. Acceptance

- `flutter test` **green at HEAD** before the edit (baseline; the audit cited 189 passing at `c41b22d`, not re-run at HEAD) **and** green after.
- Header trajectory renders the new town-voice labels; apex copy unchanged.
- Exactly **one** standing source; WP1 and WP3 no longer diverge.
- `git diff` confirms: no threshold/logic/field/sim change; edits confined to label strings, the shared source, affected tests, and the validation-report banner.
- Commit body cites this record (`WP1_Reputation_Destination_Arbiter_Record_V2.md`) as authority — closing the drift per §3.

---

*WP1_Reputation_Destination_Arbiter_Record_V2.md · Adventurer Town · `docs/M12` · Ratification & Conformance · RATIFIED 2026-06-28 · supersedes V1.1 · authorizes one presentation-only copy amendment (§6).*
