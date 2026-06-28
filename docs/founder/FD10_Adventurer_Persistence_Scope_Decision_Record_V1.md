# FD10 — Adventurer Persistence Scope: Decision Record V1

**Working Title:** Adventurer Town
**Type:** Design-governance decision record (an FD). **This is a decision awaiting founder ratification — NOT a build order and NOT a design spec.**
**Status:** ✅ **RATIFIED — Robert, 2026-06-23.**
**Revision note (2026-06-23):** D3 reframed to **witnessed-progression** and added **D3a (personal renown spilling upward)**; companion caveat **C3 amended** to admit per-adventurer renown per founder decision today; **§V legality verified verbatim**.
**Repo (where this lives):** the **design** repo (`AdventurerTown` / `adventurer-town-design`), filed under the FD series as **FD10**.
**Date:** 2026-06-23
**Depends on / grounded in:** `Adventurer_Generativity_Audit_V1` (measured: 345,608 simulated lives, regime = "randomness, not character"); the project Constitution **§VII** (Reserved Decisions — *persistence scope* is reserved to the founder), whose resolution is bound by **§III** (adventurers autonomous; tiers are narrative lenses, never RPG behavior), **§V R2/R3** (town as object of attachment; selective continuity, *not simulation*), and **§VI** (Hard Exclusions — no adventurer leveling/stats, relationship systems, or per-visitor biographies). *(Citation corrected on filing: R2/R3 live in §V, not §VII; verified against the Constitution text at code-repo HEAD `5d951b4`.)*

---

## Why this record exists

The generativity audit measured the real simulation and found the named cast are **render-only face stickers** on anonymous, single-tick customers — there is no persistent identity in the sim, and outcomes are driven by chance, not by who an adventurer is. Before any build, this record fixes the **scope** of the fix: how much persistence the named adventurers get, what drives their behavior, and what "lives you follow" concretely has to feel like — decided **first**, on paper, so a build session can't drift it later.

This record decides scope. It does **not** specify the identity model, and it does **not** authorize a build.

---

## The decision (founder's call, 2026-06-23)

**D1 — How many persist: ~20 core named adventurers.**
A defined core of ~20 named adventurers carry a persistent identity. The remaining population (incl. the other rendered faces) **stays ephemeral** — anonymous churn, served-or-missed, as the engine already does today. Persistence is **selective**, not universal.

**D2 — What drives their decisions: stored identity (traits + accumulated history).**
A persistent adventurer's choices are shaped by **who they are** — their traits and their own accumulated history — not by pure RNG and not solely by town-state. Identity must measurably move behavior (this is the exact thing the audit found *absent*).

**D3 — The felt bar: witnessed progression.**
Adventurers live their own RPG arcs (rise / grow / prosper / fail) **autonomously**; the player **never** develops, levels, or steers them. The player **witnesses** progression only **through the world** — gear / adornment on the body, the scale of their purchases, their bearing, and how the town speaks of them — **never** as stats, levels, skill trees, or any visible number. "Visibly change over time" = **history-driven change shown through the world, not an RPG sheet.**

**D3a — Renown: personal, spilling upward, never a number.**
Personal renown exists and is **earned by deeds.** It **spills upward into the town's renown** — a **tributary, never a rival** — and that spillover also serves as the **balance against any single adventurer's runaway.** Renown is **autonomous** and is **NEVER shown to the player as a number.**

---

## The tension this record must reconcile (read before ratifying)

D1+D2+D3 together describe a **20-person ensemble with identity, memory, and visible change.** That is a real simulation commitment, and it pushes toward the **hero-sim line §VI/§III forbid.** This is not a reason to retreat from the founder's call — 20 was the original vision — but the record must hold the reconciliation explicitly:

> **The town remains the object of attachment and the unit of play.** The ~20 are **selective continuity** — people you come to recognize *within* the town — **not** 20 protagonists each steered through a life. The player manages the town; the persistent cast are texture that deepens it, never avatars the player follows one-by-one.

The existing "face-sticker-on-disposable-customer" mechanic the audit flagged is **not a bug to delete** — it is the correct model for the **background population.** The ~20 core are an *upgrade layer on top of that churn*, not a replacement for it. Town-first is preserved precisely by keeping persistence capped and the general population anonymous.

**This reconciliation was confirmed against the actual Constitution §V/§VII text at ratification (2026-06-23); see the FD10 companion reconciliation.**

---

## Scope guardrails (what this is NOT — to prevent drift)

- **Not a hero-sim.** No single protagonist is controlled or followed; the town is the unit of play.
- **Not 45 (or "everyone").** Persistence is capped at the ~20 core; the broader population stays anonymous churn. The cap is what keeps this both affordable *and* town-first.
- **Not a hand-authored decision tree per character.** A literal branching tree per person is the overbuild trap (20 trees to author + maintain). The recommended, scalable direction is **identity-weighted tendencies** — traits + history *bias* weighted choices, producing divergence without authored branches. *(Recommended, not locked — see Open Questions.)*
- **No art decisions here.** The adornment / individuation art layer stays **parked**; it is downstream of this and gated on it. Decorating randomness was the trap this whole detour avoided.

---

## What "visibly change over time" must mean (so it's buildable and testable)

Change qualifies only if it is: **(a) driven by the adventurer's own history** (not ambient RNG), **(b) legible to the player** (you can tell this person is different now than at the start), and **(c) within the town-first frame.** The specific axes of change (reputation/standing, competence/skill, wealth, relationships, status, …) are **design-time decisions, not decided here.**

---

## Open questions to resolve before any build

1. **Identity model:** which traits/history fields persist per adventurer?
2. **Memory:** what does "remember" concretely record — visit history, outcomes, relationships?
3. **Change axes:** which dimensions visibly evolve (per the section above)?
4. **Interface with the existing engine:** how does the ~20-person persistent layer sit on top of the anonymous-customer churn the audit found?
5. **Decision logic:** identity-weighted choices (recommended) vs. authored per-character trees (overbuild risk) — confirm the approach.
6. **Constitution §VII:** verify the real text; confirm D1–D3 + the reconciliation are consistent with it.
7. **[Parked design idea] "Story-off":** a per-tick chance for a present adventurer to tell a story, checked against others in the same building, for a fixed renown boost; design the personal→town spillover as the brake against rich-get-richer. **To be designed in the design pass, not ratified scope.**

---

## Ratification

This record **locks** only when **both** clear:
1. **Founder sign-off** on D1–D3 and the town-first reconciliation.
2. **§VII reconciliation confirmed** against the actual Constitution text.

Until then it is DRAFT. **Ratifying this record does not authorize a build** — it unlocks a **design pass** (the identity / memory / change model, on paper), which in turn gates a **build pass.**

---

## Sequencing (what follows ratification)

1. **Ratify this record** (sign-off + §VII check).
2. **Design pass** — the persistence model on paper (identity fields, memory, change axes, decision logic). A separate design doc / next FD.
3. **Build pass — smallest real slice first.** Prove persistence on a few of the core adventurers before committing all ~20 — the same measure-first discipline used for the resolver and the Phase C proof.
4. **Acceptance = re-run the generativity audit** against the new system. The audit that diagnosed "randomness, not character" becomes the acceptance test: the regime should move to **identity-driven**, with measured between-character distinctness above the null band. The tool that found the gap proves it closed.

---

*FD10_Adventurer_Persistence_Scope_Decision_Record_V1 · Adventurer Town · design repo · scope decision, RATIFIED 2026-06-23 · gates the persistence design + build*
