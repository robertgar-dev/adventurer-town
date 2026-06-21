# M12 Stage 1 — Status Correction V1

**Date:** 2026-06-20
**Purpose:** Resolve a contradiction in the branch history: an earlier commit reports that M12
Stage 1 is *not present*, but M12 Stage 1 **is** implemented, validated, committed, and tagged.
**Scope:** documentation correction only — no code, no history rewrite, no rebase.

---

## 1. The contradiction

The branch `claude/happy-bohr-1rhyw4` contains two commits whose claims conflict:

| Commit | Message | Claim | Status |
|---|---|---|---|
| `d0020c5` | "Add M12 Stage 1 validation report (blocked: Stage 1 not present)" | M12 Stage 1 is **not present** | ❌ **Stale / contradicted** |
| `c41b22d` | "M12 Stage 1: attachment presentation pass" | M12 Stage 1 **is implemented** | ✅ **Authoritative** |

`d0020c5` was authored by a concurrent session working from `fa677aa` (M10) **before the M12
Stage 1 implementation existed in the repository**. Its conclusion ("blocked: Stage 1 not present")
was correct *for the tree it saw*, but it is **no longer true**: `c41b22d` — which sits directly
above it in history — **is** the Stage 1 implementation.

```
fa677aa  M10 Analytics
   └─ d0020c5  Add M12 Stage 1 validation report (blocked: Stage 1 not present)   ← stale
        └─ c41b22d  M12 Stage 1: attachment presentation pass   ← HEAD, tag m12-stage1-attachment
```

Any reader who stops at `d0020c5` (or at the `docs/M12_Stage1_Validation_Report.md` it added) will
draw the wrong conclusion. This document is the correction of record.

---

## 2. Authoritative state

**`c41b22d`, tagged `m12-stage1-attachment`, is the authoritative M12 Stage 1 implementation
state.** It supersedes the "not present" finding in `d0020c5`.

M12 Stage 1 (the four presentation-only attachment work packages) is implemented:

- **WP1 — Reputation as a Visible Destination** (trust trajectory near the resource header).
- **WP2 — Offline Return as a Story** (narrated beat over the retained honest scalars).
- **WP3 — Notable Town Moments in the Feed** (derived at render time; no new `EventType`).
- **WP4 — First Upgrade Stakes and Affirmation** (stakes framing + post-purchase affirmation).

All four are strictly presentation-only: no simulation changes, no persistence schema changes, no
monetization, no new gameplay systems.

---

## 3. Validation of record

Run on `c41b22d` (2026-06-20):

- `flutter analyze` → **No issues found.**
- `flutter test` → **189 tests passing.**
- `dart run tool/sprint02_validation_harness.dart scenario5` → **`pass: true`** (deterministic
  replay matches; zero demand backlog; Gold/Reputation never negative; upgrade levels in bounds;
  only approved MVP economy systems present).

This supersedes the `d0020c5` report's "blocked" status.

---

## 4. Recommended follow-up (not performed here)

History is intentionally **not** rewritten — `d0020c5` remains in the branch for provenance. To
remove the lingering contradiction, choose one (a future, separate change):

1. **Add a corrective note** to `docs/M12_Stage1_Validation_Report.md` (introduced by `d0020c5`)
   pointing to this document and to `c41b22d` / tag `m12-stage1-attachment`; **or**
2. **Supersede** that report with a fresh validation report generated against `c41b22d`; **or**
3. Leave the history as-is and treat **this document + the `m12-stage1-attachment` tag** as the
   single source of truth for M12 Stage 1 status.

No option requires touching the `c41b22d` commit or the `m12-stage1-attachment` tag, and none
involves a rebase.

---

*M12_Stage1_Status_Correction_V1 · Adventurer Town · documentation only · no code · no history rewrite · authoritative state: `c41b22d` / tag `m12-stage1-attachment`*
