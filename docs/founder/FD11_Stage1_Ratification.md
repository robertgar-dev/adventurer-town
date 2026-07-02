# FD11 — Stage-1 Consolidated Ratification & Constitutional Amendment

| Field | Value |
|---|---|
| Working Title | Adventurer Town |
| Record Type | Founder Decision — consolidated ratification, design constants, constitutional amendment, filing corrections |
| FD Number | **FD11** (pre-flight confirmed: highest prior FD in `docs/founder/` is FD10; no FD11 exists) |
| Status | **RATIFIED — Robert, 2026-07-01** (via founder-issued `FD11_Execution_Prompt.md`) |
| Document Path | `docs/founder/FD11_Stage1_Ratification.md` |
| Authorization level | DOC-ONLY. This FD records Phase 1 (build) but does **not** authorize it — that is a separate founder action (§5). |
| Evidence base | `docs/M12/WP2-WP4_Phase0_Audit_V1.md` (Phase 0 audit, measured at `5ba9974`, 2026-07-01) · `docs/M12/WP1_Reputation_Destination_Arbiter_Record_V2.md` (RATIFIED 2026-06-28) · `docs/M12/M12_Attachment_Plan_V1.md` (CANONICAL) · `docs/M12/M12_Stage1_Status_Correction_V1.md` |

---

## 0. Pre-flight record

1. **Filing rules.** `CLAUDE.md` contains no explicit filing rule for governance documents (Phase 0 audit §2.4). Repo convention governs: FD records in `docs/founder/`, M12 artifacts in `docs/M12/`. The execution prompt's `docs/M12/` target is consistent with convention and is followed (§6).
2. **§II.2 current wording** quoted verbatim in §4 before amendment.
3. **FD number.** `docs/founder/` contains FD7 (spec), FD10 (×2), and the Spatial record covering FD1–FD7. Next available number is **11** — no discrepancy.
4. **Evidence filing.** The Phase 0 audit was delivered in-session (its prompt forbade writing the file). Because this FD cites it as an input of record, the audit is filed verbatim at `docs/M12/WP2-WP4_Phase0_Audit_V1.md` in this same commit — closing the unfiled-artifact provenance gap this repo has previously had to reconstruct around (see `docs/M12/M12_Attachment_Plan_V1.md` provenance header; `docs/Provenance_Report_2026-06-28.md`).

## 1. Drift retirement — Stage 1 (WP1–WP4), consolidated

**The lineage.** M12 Stage 1 (four presentation-only work packages) shipped at `c41b22d` (tag `m12-stage1-attachment`, 2026-06-19) with no authorizing FD, plan, or sign-off in the commit body. The plan of record was promoted eight days later at `d74b284` (2026-06-28) and explicitly disclaimed build authorization (`docs/M12/M12_Attachment_Plan_V1.md`, header: "build of work packages NOT yet authorized"). For WP1, the drift was reconciled through the arbiter lineage V1 → V1.1 → V2: the V2 record (RATIFIED 2026-06-28) retroactively ratified the shipped WP1 (decision 1a), authorized the town-voice copy amendment executed at `49b58b8` (Town Standing labels + single standing source, commit body citing the record per its §7 acceptance), followed by analyzer-zero hygiene at `5ba9974`. WP1 is closed (Phase 0 audit §2.6).

**The extension.** The same `c41b22d` commit carried WP2 (Offline Story), WP3 (Notable Moments), and WP4 (Upgrade Affirmation), unaudited until Phase 0. The Phase 0 audit (2026-07-01, `docs/M12/WP2-WP4_Phase0_Audit_V1.md`) found all three **SUBSTANTIAL and Lens A-conformant** — the economic-with-flavor ceiling held in every implemented WP3 moment type; Gold-only offline narration with test enforcement in WP2; no level-up fanfare in WP4; **zero unauthorized persistence anywhere in `c41b22d`** (sole `@collection` `SimulationSaveRecord` untouched); 336 tests green at HEAD (audit §§1, 3.1–3.3, 5).

**Ruling.** The retroactive-ratification treatment applied to WP1 (V2 §3, decision 1a) is hereby **extended to WP2, WP3, and WP4**: the builds preceded the governance rather than violating it; they are ratified as conformant after the fact. **The Stage-1 authorization drift pattern — shipped before ratification — is recorded once here and declared RETIRED for Stage 1.** The WP1 V2 §3 process tightening remains binding: before any future build commit, the commit body must cite the authorizing record (as `49b58b8` demonstrably did).

## 2. Design constants — recorded as constitutional design principles

The following constants, previously unrecorded in-repo (audit §2.6), are ratified and recorded. They bind all attachment surfaces alongside `CLAUDE.md` §II and §V.

1. **Fantasy — soil, not hero.** The player is the town that raises adventurers to greatness. Adventurers are lives being cultivated — never customers, never units, never player-controlled.
2. **Consistency spine.** Every attachment surface follows three beats in order: **name a life** (a specific adventurer, never an aggregate) → **show the arc** (where they stand between novice and great, and what just moved them) → **credit the town** (tie the movement causally to the town's services and care).
3. **Concentration.** Emergent core cast: no authored roster. Selection is **arc-stakes** (whoever's story is hottest now — mid-venture, fresh triumph, near-disaster), derived at read-time. Framing is **cultivation**: beat 3 must land on drama-selected subjects. **No new persistence** — attachment surfaces are derived, never stored.
4. **Playtest hypothesis (pre-registered).** Town-credit framing carries the cultivation feeling even under drama-driven selection. Failure signature: testers report excitement without ownership. Pre-committed remedy: hybrid weighting (arc-stakes primary, cumulative bond as tiebreaker) — a tuning change, not a redesign.

**Reconciliations** (the three collisions the audit flagged, §2.6):
- **CLAUDE.md §II.2 "customers"** — resolved by the §4 amendment below.
- **Plan C6 ("Recurring named adventurers in the feed — REJECTED for M12") and the FD10 gate.** Constant 2's "name a life" is read-time naming of adventurers already present in live simulation state (`Adventurer.displayName` exists since before M12). It introduces **no persistence, no authored roster, no recurring-cast memory** — the things C6 rejected and FD10 gates. C6 and FD10 remain in force; constant 3's "no new persistence" rule restates their boundary. Any future durable per-adventurer memory remains on the FD10 design→build track, not this one.
- **Tier lens (§III).** Constant 2's "novice ↔ great" arc is expressed through the existing four tiers as narrative lenses — no adventurer leveling, stats, or classes (§III, §VI unchanged).

## 3. Fork resolutions (founder-ratified)

Per the Phase 0 audit's fork presentations (§§3.1–3.3), the founder resolves:

- **WP2 name-source → read-time join** (audit fork 3.1, option a). Surface `adventurerId`/`adventurerTier` through `EventFeedItemViewModel`; names joined at read-time against `SimulationState.adventurers`; beat-conformant copy templates. No new persistence. The join's dependence on the never-pruned roster (audit §4.2) must be guarded by test or a graceful no-name fallback.
- **WP4 → beat-3-only** (audit fork 3.3, option a). The affirmation credits the town's care; no added ceremony. The anti-goal (level-up fanfare) remains in force.
- **WP3 → arc-stakes selection rework** (audit fork 3.2, option a). Read-time drama selection over existing adventurer fields and feed rows. Sequenced **last** in Phase 1 regardless of convenience (highest scope risk). The §V R4 economic-with-flavor ceiling remains in force.

## 4. Constitutional amendment — CLAUDE.md §II.2

**Current wording, quoted verbatim before amendment** (`CLAUDE.md` §II, principle 2):

> **Adventurers are autonomous customers, not units to command.** They arrive with needs,
> spend when served, succeed or struggle off-screen, leave, and may return. They are not
> inventory, employees, troops, party members, or puzzle pieces. The emotional contract is
> exact: *the player affects adventurers' lives but does not control them.* This line is the
> genre's identity. Crossing it toward control makes the game hero management; retreating from
> it toward pure abstraction makes the game a spreadsheet.

**Ruling.** **"Autonomous" is architecture and stands** — adventurers are never player-controlled; the emotional contract sentence survives intact. **"Customers" is legacy framing from the mobile-idle era and is retired** as contradicting the ratified fantasy (constant 1, §2 above).

**Amended wording** (bold lead sentence only; the remainder of the principle is unchanged):

> **Adventurers are autonomous residents whose growth the town cultivates, not units to command.**

Residual occurrence noted, not amended: `CLAUDE.md` §IX describes the design-repo source document `Adventurer_Lifecycle_V1.md` as "autonomous customers; selective continuity" — that line describes an external historical artifact, not the constitutional principle, and is left intact.

## 5. Phase 1 scope of record

Documented here for the record. **Authorization to begin is a separate founder action — nothing below is authorized by this FD.**

1. **Push `5ba9974`** (hygiene; founder pushes).
2. **Test hardening — invariant-targeting only.** WP3 forbidden-substring guard extension and standing-copy invariants; WP4 repeat-branch and stakes-note-disappearance tests; WP2 cap/tie-break tests. Assertions must target invariants that survive items 3–5, not current copy strings. The WP2 dead-fallback cleanup (`town_view_models.dart:204-205, 209-210`, unreachable) is a code change riding in this step — its commit message must label it as such.
3. **WP2 beat retrofit** (M, MAJOR) — per §3 fork resolution.
4. **WP4 per fork resolution** (S) — likely copy-only or no-op.
5. **WP3 arc-stakes rework** (M–L, MAJOR) — **last, regardless**. Hard rule: no new persistence.

## 6. Filing corrections (drift corrections, recorded)

Both executed in this commit via `git mv` (history preserved):

| Document | From | To |
|---|---|---|
| `M12_Attachment_Plan_V1.md` | `docs/` | `docs/M12/` |
| `M12_Stage1_Status_Correction_V1.md` | repo root | `docs/M12/` |

Historical references to the old paths (in `docs/Provenance_Report_2026-06-28.md`, `docs/M12_Stage1_Validation_Report.md`, `docs/M12/WP1_Reputation_Destination_Arbiter_Record_V2.md`, and the plan's own promotion header) are **left unedited** — they are point-in-time records; this table is the redirect of record.

---

*FD11_Stage1_Ratification.md · Adventurer Town · `docs/founder` · RATIFIED 2026-07-01 · doc-only · retires Stage-1 authorization drift (WP1–WP4) · records design constants 1–4 · amends CLAUDE.md §II.2 · Phase 1 recorded, NOT authorized.*
