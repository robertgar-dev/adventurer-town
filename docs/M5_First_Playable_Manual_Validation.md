# M5 First Playable — Manual Validation Script

**Working Title:** Adventurer Town
**Milestone:** M5 First Playable (WP-M5-10)
**Completion authority:** `First_Playable_Definition_V1.md`
**Purpose:** Provide a repeatable, player-facing playtest for Human Product
Owner sign-off. The entire loop must be completable using only the in-app UI —
no logs, debug views, developer tools, or test harnesses.

---

## 0. Preconditions

- A normal (non-test) build of the app on a target device or emulator
  (mobile portrait is the reference layout).
- A clean install **or** an explicit "new game" state for Step 1 (so starting
  resources are observable). To force a clean state, clear app data /
  reinstall, or delete the app's persisted save (`simulation_state.json` /
  the Isar `adventurer_town` store) — outside the app, before launch.
- No DevTools, no console, no test runner. If any step can only be completed
  by inspecting logs or running a harness, that step **FAILS**.

> Reference automated coverage for each check is listed in the right-hand
> column. Manual validation is still required for milestone completion;
> automated tests support but do not replace the playtest.

---

## 1. Validation Steps

Perform the steps in order. Mark each PASS / FAIL.

| # | Action | Expected result (player-facing) | Acceptance criterion | Automated backup |
|---|--------|---------------------------------|----------------------|------------------|
| 1 | Launch the app from a clean state | App opens directly to the **Town View** (title "Adventurer Town"). No menus, no developer screens. | Open the game | `m5_first_playable_test.dart` (WP-M5-01) |
| 2 | Read the top of the screen | A **Resource Header** shows **Gold** with a numeric value. | Gold visible | `m5_first_playable_test.dart` (WP-M5-02) |
| 3 | Read the top of the screen | The Resource Header also shows **Reputation** with a numeric value. | Reputation visible | `m5_first_playable_test.dart` (WP-M5-02) |
| 4 | Scroll the town list | Exactly five service buildings appear: **Inn, Tavern, Blacksmith, Healer, Market** — and no others. | Town/building state visible | `m5_first_playable_test.dart` (WP-M5-03) |
| 5 | Let the simulation run for ~30–60 seconds and watch building cards and the Event Feed | Demand outcomes are visible: building cards show a utilization state (e.g. *Underused / Healthy / Busy / Overloaded*) and a **Lost demand N** line; the Event Feed lists **served** and **missed** demand. Gold and/or Reputation change over time. No "task queue" or backlog is implied. | Observe service demand outcomes; observe Gold/Reputation change | `m5_feedback_and_upgrade_test.dart` (WP-M5-04) |
| 6 | Tap a building card (e.g. **Tavern**) | A **building detail** screen opens showing name, demand served, **Capacity Level**, **Value Level**, utilization, recent lost demand, recent activity, and an **Upgrade Section**. | Inspect a building | `m5_feedback_and_upgrade_test.dart` (WP-M5-05); `building_detail_screen_test.dart` |
| 7 | In the Upgrade Section, find **Upgrade Capacity**, confirm it shows current level, next cost, and affordability, then tap it (ensure enough Gold) | Purchase succeeds: **Capacity Level** increases by 1; the next cost updates; a "… Capacity upgraded to Level N" entry appears in Recent Activity. | Purchase an upgrade (Capacity) | `building_upgrade_flow_test.dart`; `m5_feedback_and_upgrade_test.dart` (WP-M5-07) |
| 8 | If Gold permits, tap **Upgrade Value** | Purchase succeeds: **Value Level** increases by 1; the next cost updates. | Purchase an upgrade (Value) | `building_upgrade_flow_test.dart` |
| 9 | Observe the Resource Header before vs after each purchase | **Gold decreases** by exactly the shown cost. Reputation is **not** spent and has **no** spend control. | Observe Gold changes | `building_upgrade_flow_test.dart`; `m5_feedback_and_upgrade_test.dart` (WP-M5-07) |
| 10 | Re-read the building detail / card | The upgraded **level value(s) are visibly updated** (e.g. "Capacity Lv 2"). | Upgrade levels update visibly | `m5_feedback_and_upgrade_test.dart` (WP-M5-07); `m5_persistence_reload_test.dart` |
| 11 | Return to Town View and let the simulation run again under demand pressure | The upgrade's **effect is observable**: a capacity-upgraded building serves more demand / loses less; a value-upgraded building earns more Gold per service. | Observe upgrade effect | `m4_core_economy_loop_test.dart` (deterministic capacity/value); Scenario 2 & 3 |
| 12 | Fully close the app, then relaunch it | After reload, the **Town View shows the same Gold and the upgraded building level(s)** — progression persists; nothing is lost or duplicated. | Save and reload progression | `m5_persistence_reload_test.dart` (WP-M5-08); `m4_core_economy_loop_test.dart` |
| 13 | Reflect on the whole run | Every step above was completed using only on-screen UI — **no logs, debug views, developer tools, or test harnesses** were needed. | Tool independence | All M5 widget tests run UI-only |
| 14 | Scan all screens | **No excluded systems** appear: no inventory, crafting, equipment, combat, quests, guilds, adventurer management, staffing, specialization, premium currency, offline progression UI, new buildings, or new resources. | Scope integrity | Scope audit in milestone report |

---

## 2. Pass / Fail Determination

- **PASS** — Steps 1–14 all pass; the player can observe, inspect, upgrade,
  observe the effect, and reload without developer tooling; no excluded
  systems appear; Human Product Owner approves.
- **CONDITIONAL PASS** — The core loop (Steps 1–12) passes, but minor UI
  clarity/copy issues remain that do not block comprehension; Human Product
  Owner accepts explicit follow-up tasks.
- **FAIL** — Any of: app does not launch to Town View; Gold or Reputation not
  visible; demand outcomes not visible; a building cannot be inspected;
  Capacity or Value upgrade is not purchasable through UI; Gold does not
  decrease; upgrade levels do not update; upgrade effect cannot be observed;
  progression is lost on reload; any step requires developer tooling; or an
  excluded system appears.

---

## 3. Result Record

| Field | Value |
|-------|-------|
| Build / commit | __________ |
| Device / OS | __________ |
| Date | __________ |
| Tester (Human Product Owner) | __________ |
| Result (PASS / CONDITIONAL / FAIL) | __________ |
| Notes / follow-ups | __________ |

---

## 4. Notes

- Steps 7–8 require enough Gold for the first upgrade (50 Gold). If a clean
  launch starts at 0 Gold, let the simulation run until at least 50 Gold has
  accumulated before attempting a purchase, or validate after some active play.
- This script is presentation-only validation. The underlying economy,
  persistence, and upgrade systems are already validated by the automated
  suite (`flutter test`) and the deterministic scenario harness.
