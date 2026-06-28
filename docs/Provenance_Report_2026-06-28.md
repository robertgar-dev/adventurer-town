# Documentation Provenance Report — 2026-06-28

**Working Title:** Adventurer Town
**Pass type:** Documentation integrity (NOT feature implementation — no M12 work package built).
**Trigger:** Founder Review Decision, 2026-06-28 — approve M12 reconstruction; promote to canonical;
close the documentation provenance gap.
**Code-repo HEAD at pass:** `85f6d27` · **Branch:** `claude/happy-bohr-1rhyw4`.
**Design repo (source of truth):** `C:\Users\rober\Documents\AdventurerTown\`.

---

## 1. Documents added

### 1a. Canonical milestone document (promoted from reconstruction)
| Path | Action | Notes |
|---|---|---|
| `docs/M12_Attachment_Plan_V1.md` | **Promoted to CANONICAL** | Renamed from `docs/M12_Attachment_Plan_V1_Reconstructed.md`. Header now carries CANONICAL status + founder approval 2026-06-28 + full reconstruction provenance. Footer + Source Map updated. Reconstruction file no longer exists as a separate doc (lineage preserved in the header → no duplicate). |

### 1b. Founder decision records copied verbatim → `docs/founder/`
All copies verified **byte-identical to source by SHA-256** at copy time. Source dir:
`AdventurerTown\06_Art_and_Audio\Artifacts\`.

| File (now under `docs/founder/`) | FD lineage | Lines |
|---|---|---|
| `Spatial_TownView_Founder_Decision_Record_V1.md` | FD1–FD7 (supersedes `CLAUDE.md` §IV) | 141 |
| `Detail_View_LookTest_Decision_Record_V1.md` | amends Spatial FD2 (LT3) | 124 |
| `Detail_View_Render_Scale_Decision_Record_V1.md` | FD8 (provisional) | 71 |
| `Detail_View_Render_Scale_Decision_Record_V1.1.md` | FD8 Amendment A1 (ratifies 22%) | 102 |
| `Slot_Registration_Decision_Record_V1.md` | FD9-related (overlay slots) | 107 |
| `FD7_IsoFacing_Generation_Spec_V2.md` | FD7 iso-facing spec (supersedes uncommitted V1) | 177 |
| `FD10_Adventurer_Persistence_Scope_Decision_Record_V1.md` | FD10 (persistence scope) | 95 |
| `FD10_Persistence_Scope_Constitution_Reconciliation_V1.md` | FD10 companion | 63 |

### 1c. Provenance metadata (new, not copied)
| Path | Action | Notes |
|---|---|---|
| `docs/founder/README.md` | Added | Pure manifest (filename · FD lineage · self-stated status). Does **not** rewrite/reinterpret/summarize record content. |
| `docs/Provenance_Report_2026-06-28.md` | Added | This report. |

---

## 2. References repaired

| Location | Before | After |
|---|---|---|
| `CLAUDE.md` §IV (FD1 amendment note) | Spatial record *"owed from the founder, not yet delivered to this repo; to be committed to `docs/` when provided"* | Now *"delivered 2026-06-28 to `docs/founder/Spatial_TownView_Founder_Decision_Record_V1.md` (verbatim copy; design repo remains source of truth)."* **Surgical pointer update only — no rule, constraint, or governance text changed.** Fulfills the clause's own stated condition; explicitly authorized by founder instruction #5. |
| `docs/M12_Attachment_Plan_V1.md` Source Map | FD10 ×2 + Spatial record listed as design-repo-only | Now annotated `design → docs/founder/` (local verbatim copies). |
| Missing `M12_Attachment_Plan_V1.md` (referenced by `docs/M12_Stage1_Validation_Report.md` Step 0) | Absent on every branch — validation "BLOCKED, nothing to validate" | The canonical `docs/M12_Attachment_Plan_V1.md` now exists, resolving the reference. (The validation report itself is left **unedited** — it is a point-in-time measured artifact; see §3.) |

---

## 3. Deliberately NOT edited (and why)

- **`docs/M12_Stage1_Validation_Report.md`** — a measured, point-in-time validation artifact dated to
  HEAD `fa677aa`. Editing it would falsify a historical measurement. Its "plan missing" finding is now
  **superseded in fact** by the canonical M12 doc; supersession is recorded here and in the canonical
  doc's header rather than by rewriting the report.
- **The 8 verbatim founder records** — copied unaltered per founder instruction ("Do not rewrite /
  reinterpret / summarize"). Their internal cross-references (§4) are left intact even where they do
  not resolve locally.
- **`CLAUDE.md` governance content** — only the single provenance pointer in §IV was touched. No
  principle, tension (R1–R10), exclusion, locked fact, or commercial clause was modified.

---

## 4. Remaining unresolved references

These are references **inside the verbatim founder records** to other design-repo documents that were
**not** copied (they are out of scope for "founder decision records," and the design repo remains
their source of truth). Left intact by the no-edit rule; they resolve only in the design repo.

| Referenced doc (design repo) | Cited by (in `docs/founder/`) | Resolution status |
|---|---|---|
| `Claude_Code_Brief_Spatial_Slice1_DetailView_V1` | Spatial record (lines 6, 112) | Unresolved in code repo (design-repo brief; by design) |
| `Amenity_Module_System_V1` | Spatial record (128); Render_Scale V1 (59); Slot_Registration (97) | Unresolved in code repo (design-repo system doc) |
| `Asset_Production_Plan_V2` | Render_Scale V1 (8); Slot_Registration (8) | Unresolved in code repo (design-repo plan) |
| `Service_Vocabulary_and_Outcomes_V1` | Slot_Registration (37, 97) | Unresolved in code repo (design-repo vocab) |
| `Package_C_Outcome_Overlay_Scope_V1` | `docs/FD9_PhaseC_SyntheticMark_Proof_Report_V1.md` §6 | **Confirmed nonexistent in BOTH repos** (search-verified previously). Not a copy gap — an unwritten doc. Flagged for founder (it is the intended consumer of the FD9 overlay resolver). |
| `Current_State_V10.md` | cited-as-unavailable by 3 design-repo approved docs | Absent in both repos when those docs were written; recurring canon gap. Informational. |

Cross-references that now **DO** resolve locally after this pass: every founder record's links to
*other* founder records (all 8 co-located in `docs/founder/`), and FD10's citation of
`Adventurer_Generativity_Audit_V1` (present at `docs/Adventurer_Generativity_Audit_V1.md`).

---

## 5. Duplicate / conflicting documents discovered

| Finding | Detail | Disposition |
|---|---|---|
| **Reconstruction vs canonical (resolved)** | `M12_Attachment_Plan_V1_Reconstructed.md` was promoted/renamed to `M12_Attachment_Plan_V1.md`. | **No duplicate remains** — single canonical file; reconstruction lineage preserved in header. |
| **Render-Scale V1 vs V1.1 (intentional amendment chain, NOT a conflict)** | `Detail_View_Render_Scale_Decision_Record_V1.md` (FD8, "LOCKED provisional") and `…_V1.1.md` (Amendment A1, "LOCKED — RATIFIED"; amends V1 D1/D2, D3–D5 unchanged; ratifies the 22% value). | Both copied intentionally; V1.1 is the operative ratification, V1 retained for history. Readers should treat **V1.1 as current**. Flagged, not "fixed" (editing verbatim records is prohibited). |
| **FD7 spec V2 supersedes uncommitted V1** | `FD7_IsoFacing_Generation_Spec_V2.md` states it supersedes an uncommitted V1. | No V1 exists to copy; no action. |
| **`M12_Attachment_Audit_V1` vs `M12_Attachment_Plan_V1`** | Audit (design repo) and Plan (code repo, canonical) are **related but distinct** — diagnosis vs plan. | Not a duplicate. Audit remains design-repo evidence; Plan is the milestone doc. |
| **Design-repo triplicate one-pagers (informational)** | e.g. `Game_Concept_One_Pager_V1.md`, `Target_Player_V1.md` exist 3× across `AdventurerTown\Master\`, `Preproduction_Package_V1\`, `AdventurerTown_Impacted_Folders_Update\…`. | Out of scope (design-repo housekeeping); noted only. |

---

## 6. Verification

- All 8 founder copies: SHA-256 source==dest at copy time (8/8 OK).
- Canonical M12 doc: header/footer/Source Map reflect CANONICAL + founder approval; filename is the
  authoritative `M12_Attachment_Plan_V1.md`.
- `CLAUDE.md`: single surgical pointer edit applied; governance content unchanged.
- No simulation, persistence, UI, or test code touched. No M12 work package implemented (per founder
  "Stop before implementing any M12 work packages").

---

## 7. Open founder-only items carried forward (not answered here)

Surfaced separately to the founder; **not** silently resolved. The load-bearing ones:
1. `M12_Attachment_Plan_V1.md` §10.3 — the single visible **Reputation destination** (form).
2. §10.4 — the exact **Notable Moments** editorial ceiling (§V R4 boundary).
3. §10.5 — **Stage 2 audio** timing + asset-production owner.
4. **`Package_C_Outcome_Overlay_Scope_V1`** — the unwritten consumer of the FD9 overlay resolver:
   author it, or confirm it stays parked.
5. **`M12_Stage1_Status_Correction_V1.md`** — does a formal status-correction doc exist (RobOS Open
   Loops references it)? If so, reconcile against the now-canonical plan.

---

*Provenance_Report_2026-06-28.md · Adventurer Town · documentation-integrity pass · no feature code
changed · founder decision records are verbatim copies; design repo remains source of truth.*
