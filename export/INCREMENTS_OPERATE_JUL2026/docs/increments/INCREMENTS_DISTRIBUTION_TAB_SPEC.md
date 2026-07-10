# INCREMENTS — Signal Tab Spec (Distribution)

**Version:** 2.3  
**Status:** Locked for Cursor implementation — after `FORM-iOS/docs/FORGE_V1_GATE_QA.md` (9 checks)  
**Date:** May 2026  
**Scope:** Hideout · FORM · Forge (RunCards excluded in this tab — paused; OS Monday block retains RunCards when resumed)  
**Tab name:** Signal · **Position:** after Hideout

**Doctrine:** `FORM-iOS/docs/BRICE_OS/DISTRIBUTION_OPERATING_SYSTEM.md`  
**Operator profile:** `FORM-iOS/docs/BRICE_OS/BRICE_OPERATOR_PRODUCT_BRIEF.md` (buy-in + system design corollary)

**Operator reads in app:** INCREMENTS **You → Manual** (distribution crash course + principles), **Doctrine** (Operator · Hideout · FORM night read), **Ventures** (live signal). This spec is agent implementation detail.

---

## 0. Read this first

Distribution is an undeveloped operating discipline — not a motivation problem. The methodology is built through consistent seed-planting and lightweight signal logging. The operator already understands seeds take time. The tab does not reassure him or make accumulation visible.

**Three jobs. Nothing else.**

1. **Plant** — Monday block. Zero decisions. Fixed sequence.
2. **Log** — Friday brief. Minimal. Record signals for later read.
3. **Adjust** — ~8 weeks in, one full read of all Friday logs. Change one thing if warranted.

No dot counters, arc states, progress framing, or intermediate feedback scaffolding.

---

## 1. Data models

### 1.1 DistributionWeek

One record per week. Created on first Signal tab load of that week.

```swift
@Model
final class DistributionWeek {
    var id: UUID
    var weekStartDate: Date           // Monday start of day
    var createdAt: Date

    // Monday Block
    var mondayBlockCompleted: Bool
    var mondayBlockCompletedAt: Date?

    var hideoutFilmed: Bool
    var hideoutEdited: Bool
    var hideoutPostedGBP: Bool
    var hideoutPostedReels: Bool
    var hideoutPostedTikTok: Bool

    var appContentVenture: AppContentVenture  // .form or .forge — pre-decided
    var appContentDecision: String            // from DecisionLedger confirm
    var appContentPosted: Bool

    // Friday Log
    var fridayLogCompleted: Bool
    var fridayLogCompletedAt: Date?

    var hideoutSourceMentions: Int
    var hideoutBoardAttributions: Int
    var hideoutWatermarcRedemptions: Int
    var hideoutGBPAttributions: Int

    var formOutsideEngagement: Bool
    var forgeV1GatePassed: Bool

    var oneAdjustment: String                 // one line or "HOLD"
    var operatorNote: String

    init(weekStartDate: Date) { ... }
}

enum AppContentVenture: String, Codable {
    case form, forge
}
```

### 1.2 DecisionLedger

Append-only scratch. Mid-week capture; Monday step 6 is **confirm**, not reconstruct.

```swift
@Model
final class DecisionLedger {
    var id: UUID
    var createdAt: Date
    var venture: AppContentVenture
    var fragment: String              // one sentence, append-only
    var usedInWeek: Date?             // set when pulled into Monday block
}
```

**Mid-week capture (Tue–Sun):** Persistent field on Signal tab below Monday stamp — venture selector, one line, ADD. No edit after add. **FORM:** after Threshold Tuesdays (Tue/Wed) or Saturday Long Runs (Sat/Sun) — see `DISTRIBUTION_OPERATING_SYSTEM.md` §Threshold Tuesdays · §Saturday Long Runs.

**Monday pull:** Step 6 shows most recent unused entry for this week's venture. Confirm or replace. If none, blank field (bounded judgment).

Week auto-create: `DistributionWeek` for Monday of current week on first tab load if missing.

---

## 2. Tab structure

Single scroll. Monday Block dominant when incomplete.

```
[ MONDAY BLOCK ]       dominant / stamp when done
[ DECISION LEDGER ]    Tue–Sun only; hidden Monday
[ SIGNAL LOG ]         Friday sheet; compact summary otherwise
[ LOG HISTORY ]        plain list; no scoring
```

No subtabs. No dashboard framing.

**Tab bar:** Home · Today · Operator · Hideout · **Signal** · You

---

## 3. Monday Block

### States

| State | Condition | Renders |
|-------|-----------|---------|
| Active | Monday, block not done | Full protocol card |
| Complete | Block done | Compact stamp |
| Upcoming | Tue–Sun before next Monday | Next Monday date |
| Missed | Monday passed, not done | `Monday [date] · not run` — no guilt |

### Protocol card

Fixed sequence. Cannot check step N without N−1.

```
MONDAY BLOCK
Before Hideout opens · 60–90 min · film before unlocking

HIDEOUT
□ 1. Film — 7-shot sequence, empty café (15–20 min)
□ 2. Edit — assembly only, ≤30 sec (10–15 min)
□ 3. Post — Google Business Profile (5 min)
□ 4. Post — Instagram Reels (3 min)
□ 5. Post — TikTok · post and leave · 4 min max

[FORM / FORGE] — [venture] this week · pre-decided
□ 6. Confirm decision sentence
    [pulled from DecisionLedger, or type]
□ 7. Record — system state that drove the decision · single take
□ 8. Post

COMPLETE BLOCK →
```

**Film precondition (header):** Before unlocking. Zero customers. Empty café. Only environmental variable eliminated.

**Shot list** — drawer on step 1 (locked positions, solo-executable).

**Edit doctrine** — drawer on step 2:

```
7 clips only · linear order · no transitions · natural sound only
First frame = cover · export preset in camera roll
Assembly, not editing. No aesthetic decisions.
```

**Content primitive** — drawer on step 6:

```
One real decision or observation · one outcome · one sentence context
Product truth only. Outsider-legible — stranger understands the signal.
```

**Quality gates** — drawer on step 7 (four checks per OS doc).

**Caption doctrine** — drawer on step 8:

```
GBP: factual, local, one sentence
Reels/TikTok: one-line atmospheric observation · saved hashtag preset
No invention at posting time
```

**App content alternation:**

```swift
func appContentVenture(for weekStart: Date, forgeGateCleared: Bool, weeksSinceForgeUnlock: Int) -> AppContentVenture {
    guard forgeGateCleared else { return .form }
    if weeksSinceForgeUnlock < 3 { return .forge }
    let week = Calendar.current.component(.weekOfYear, from: weekStart)
    return week.isMultiple(of: 2) ? .form : .forge
}
```

While gate open: Forge steps hidden; locked line only.

**On COMPLETE:** `mondayBlockCompleted = true`, mark ledger `usedInWeek`, collapse to stamp.

---

## 4. Decision Ledger

Visible Tue–Sun. Hidden Monday.

Append-only list; used entries grayed. Most recent first.

---

## 5. Signal Log

**Pre-log:** `Run Friday after close · 8–10 min` — nothing to read until run.

**Friday sheet:** Steppers/toggles + one adjustment line (or HOLD). Forge gate toggle here.

**HOLD time-bound:** Same HOLD + zero signal for **6 consecutive weeks** → one diagnostic line, then silence until new adjustment.

**Diagnostics (only when unambiguous):**

| Condition | Line |
|-----------|------|
| Watermarc 0 for 3+ weeks | Confirm cards delivered |
| No Monday block + all signals zero | No block · no signal to read |
| Forge gate open 6+ weeks | Forge distribution paused until gate clears |
| HOLD 6+ weeks, signal unchanged | Change surface or confirm seed |

Positive signals: silence.

---

## 6. Log History

Plain list: `Week of [date]  Block ✓/—  Log ✓/—`. Tap → read-only week detail including `appContentDecision`.

**8-week prompt:** On Friday marking 8 weeks from first completed Monday block, header adds: `8 weeks of logs. Worth a full read.` No forced flow. Calendar the date at first block.

---

## 7. Forge v1 gate (implementation blocker)

**Canonical device QA:** `FORM-iOS/docs/FORGE_V1_GATE_QA.md` (9 checks) · `docs/forge_master_brief.md` §12

Includes: start &lt;5s, draft restore, plan anchor, Wait. zero false positives, no motivational copy, interruption recovery, zero dead-ends, timer under stress, **full week ≥5 sessions** on device.

Distribution for Forge does not begin until gate clears. Log pass on Friday toggle.

---

## 8. Copy doctrine

**Prohibited words:** streak, milestone, progress, momentum, on track, behind, keep going, great work, crushing it, consistency, building, growing, you've got this

Register: operational, brief, diagnostic. Silence when nothing actionable.

---

## 9. iPad layout

Portrait: single column.

Landscape: Monday Block fixed left; Ledger + Signal Log + History scroll right.

---

## 10. Integration

| Surface | Change |
|---------|--------|
| Today | `growthVideoFilmed` / `growthVideoPosted` → open Signal Monday block |
| Hideout FridaySignalCard | Retain parallel; `DistributionWeek` canonical for new data |
| `FridaySignalLog` / Models | Do not delete; coexist until Hideout card migrated |

---

## 11. Signal tab acceptance (ship criteria)

| Gate | Criterion |
|------|-----------|
| Zero-decision Monday | Ledger pre-populates step 6 when maintained |
| Film precondition | Header: before unlocking, empty café |
| Edit + caption drawers | Assembly rules step 2; caption rules step 8 |
| Forge gate | Forge steps absent until `forgeV1GatePassed` |
| Post-gate | 3 consecutive Forge weeks then alternation |
| HOLD | 6-week diagnostic then silence |
| 8-week prompt | One line in history header only |
| Copy | Prohibited words absent |
| Diagnostics | Four conditions only; positives silent |

---

## 12. Locked decisions (closed)

| Item | Resolution |
|------|------------|
| Tab name | Signal |
| Position | After Hideout |
| Data | `DistributionWeek` + Hideout shift log parallel |
| Forge gate input | Friday log toggle |
| Mid-week capture | `DecisionLedger` |
| RunCards in tab | Excluded (paused) |

---

## 13. Version history

| Version | Change |
|---------|--------|
| 1.0 | Withdrawn — rep record, arc states, interpretation engine |
| 2.0 | Plant / log / adjust; Monday-dominant |
| 2.1 | Signal tab placement; parallel data model |
| 2.2 | Gate QA doc; post-gate 3 Forge weeks |
| 2.3 | Full implementation spec: `DecisionLedger`, 8-step Monday block, edit/caption doctrine, outsider-legible primitive, HOLD 6-week, 8-week read prompt; gate §9 full-week; OS FORM patch applied |
