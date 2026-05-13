# INCREMENTS — Phase 3 Evolution Brief
## Build Brief for Claude Agent · Read After INCREMENTS_Agent_Handoff.md

*This document is a build specification derived from a 7-agent behavioral science review of the app's expansion potential. Read the handoff doc first. This doc tells you what to build next, in what order, and with what constraints.*

*Do not start building until you have read both documents in full.*

---

## Agent Consensus Summary

Seven independent agents reviewed Q1–Q7 covering sessions, maintenance, hydration, financial layer, science practices, what to refuse, and structural integrity. The consensus was unusually clear:

**Build first:** Session Protocols (unanimous, 7/7)
**Build second:** Maintenance Cadence layer
**Build third:** Hydration as rhythmic prompt (not habit, not counter)
**Build fourth:** Financial clarity layer (Operations domain only)
**Refuse:** HRV dashboard, open journaling, streak substitutes, aggregate financial scoring, spider charts, continuous animation, cold exposure (recovery contraindicated)

Where agents disagreed, this doc adjudicates. Follow this doc, not the raw agent output.

---

## The Governing Test (Q7 Consensus)

Before every build decision, ask:

> "Does this reduce cognitive load and increase participation in reality — or does it increase time spent inside the app?"

If the answer is the latter: do not build it.

The app is a **launch surface**, not a destination. Maximum daily interaction per feature: 45 seconds. If a feature cannot be fully used in 45 seconds, redesign it before building it.

---

## Phase 3 Build Priority Order

### PRIORITY 1 — Session Protocols ← BUILD THIS FIRST

**What it is:** A distinct action type that groups ordered steps into a single behavioral container. The session is the unit of completion. Steps are navigation scaffolding, not individual achievements.

**Why first:** All 7 agents agree. Sessions match the user's existing cognitive architecture (athletic training schemas, operational sequences). For Analytical/INTJ profiles, a session collapses multiple micro-decisions into one commitment gate — reducing the initiation cost that recovery-state executive function struggles with most.

**The psychological mechanism:** Implementation intentions (Gollwitzer). Pre-specifying the sequence at session start eliminates the "what comes next" working memory tax during execution. The app carries the sequence; the user executes.

**Minimum viable version — build exactly this, nothing more:**

```swift
@Model
class Session {
    var id: UUID = UUID()
    var title: String = ""
    var system: SystemTag = .health
    var steps: [String] = []          // ordered, max 6
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var lastCompleted: Date? = nil
    var createdAt: Date = Date()
    var cue: String = ""              // "After shower" / "Before bed"
    var isActive: Bool = true
}
```

**UX logic — critical:**
- Session appears as a card in the Today stack alongside actions
- Tapping opens a full-screen step view (not a sheet — sessions deserve dedicated space)
- Steps display as an ordered read-along list, not independently checkable boxes
- User reads the protocol, executes it in physical space, returns, taps one button: "Protocol closed."
- Steps are NOT individually tracked. The system does NOT know which steps were skipped.
- Completion = session complete. One event. One XP award. One timestamp.
- No step streaks. No session streaks. Last-completed timestamp only (same as habits).

**Step view design:**
- Full screen, bgBase background, AtmosphericBackground()
- Header: session title in sora(22 semibold) + system domain color accent
- MonoLabel: "PROTOCOL · [STEP COUNT] STEPS"
- Steps listed vertically, each with a small index number in mono
- Current step visually distinguished (slightly brighter text, warm left accent)
- Adjacent steps at textMuted — they're coming, not competing
- Single CTA at bottom: "Protocol closed." — sora(14 semibold), primary button style
- On complete: haptic (medium impact), brief inkGreen glow on the button, return to Today

**Voice for sessions:**
- Card label: "PROTOCOL" (not "SESSION" — more operational)
- Completion: "Protocol closed."
- Empty state: "No active protocols."
- Cue display: "When: [cue]" — same pattern as actions

**Session card in Today stack:**
- Visually distinct from ActionRow: slightly taller, left accent strip in system color (same as Increments tab rows)
- Shows: title, step count, cue, system badge
- Does NOT show individual steps in Today — those appear only when the protocol is open

**Seed defaults (build these in, user can edit):**
```
Morning Protocol (Health)
  1. Open blinds — natural light first
  2. Hydrate — water before anything else
  3. Medications / supplements
  4. Move — 5 min cleared movement
  5. Stage the day — what are the 3 things
Cue: "Wake"

Evening Shutdown (Operations)
  1. Review tomorrow's first action
  2. Stage clothes / kit
  3. Supplements — mag glycinate
  4. Screens off
  5. Close the loop — journal optional
Cue: "After 9pm"

Grooming Protocol (Health)
  1. Shower
  2. Skin active
  3. Hair care
  4. Brush / floss
  5. Stage tomorrow's clothes
Cue: "Before bed or morning"
```

**Constraints — do not violate:**
- Max 6 steps per session. If a user tries to add a 7th, the field is disabled with: "Protocols cap at 6 steps."
- No substeps. No nesting. No dependencies between steps.
- Sessions must not appear in Habits tab. They are a Today-layer construct.
- Session XP same as action XP (configured on the model, defaults to medium). Do not create separate session XP tier.
- Do not build a "session builder" UI with elaborate customization. Add session sheet mirrors the AddActionSheet: title, system, steps (add up to 6), cue. That's it.
- Sessions belong to today's stack — they are NOT recurring by default unless the user sets them as recurring (same recurrence enum as actions: daily, weekly, as-needed).

**Risk flags to watch:**
- Over-protocolization: the user will want to turn everything into a session. The 6-step cap is structural defense against this. Hold it.
- Analytical drift into protocol design: if the user is spending more time editing sessions than running them, surface the agent note: the reward is procedural closure, not protocol authorship.

---

### PRIORITY 2 — Maintenance Cadence

**What it is:** A temporal signal layer for interval-based behaviors. Not a to-do list. State reporting only.

**Why second:** Maintenance behaviors fail due to temporal invisibility — there's no environmental cue for "change the water filter." Visibility solves this. The risk is that visibility in task-list format produces ambient guilt. The solution is state reporting with no urgency escalation.

**Lives in:** Increments tab, under each relevant system (primarily Operations and Environment). Does NOT appear in Today stack unless actionable and explicitly configured to surface there.

**Data model:**

```swift
@Model
class MaintenanceItem {
    var id: UUID = UUID()
    var title: String = ""
    var system: SystemTag = .operations
    var intervalDays: Int = 30
    var lastCompleted: Date? = nil
    var notes: String = ""
    var isActive: Bool = true
    
    // Computed state — never store, always derive
    var state: MaintenanceState {
        guard let last = lastCompleted else { return .due }
        let daysSince = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        let daysUntil = intervalDays - daysSince
        if daysUntil <= 0 { return .due }
        if daysUntil <= 7 { return .upcoming }
        return .quiet
    }
    
    var daysUntilDue: Int {
        guard let last = lastCompleted else { return 0 }
        let daysSince = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        return max(0, intervalDays - daysSince)
    }
}

enum MaintenanceState {
    case quiet      // within normal interval
    case upcoming   // due within 7 days
    case due        // at or past interval
}
```

**State language — use exactly these words:**

| State | Display text | Color |
|---|---|---|
| quiet | "Quiet" | textMuted |
| upcoming | "Due in [N] days" | inkAmber |
| due | "Attention window open" | inkTeal |

**Never use:** overdue, missed, neglected, behind, late, failed.
**Never use red** for any maintenance state. inkRed is reserved for system errors only.

**UI placement:**
- A "MAINTENANCE" section at the bottom of the Increments tab, below the system cards
- Uses `CardView(style: .ambient)` for each item (left border rule, no background fill)
- Only shows items in `.upcoming` or `.due` state by default
- "Show all" toggle reveals `.quiet` items
- Completing a maintenance item: single tap → "Mark complete" → updates `lastCompleted` → state recalculates

**What surfaces to Home dashboard:** Only `.due` items, and only if there are fewer than 3 of them. Never show a maintenance backlog on Home. The Home screen is operational, not administrative.

**Seed defaults:**
```
Air filter — 30 days — Environment
Deep clean — 14 days — Environment
Weekly reset — 7 days — Operations
Financial review — 7 days — Operations
```

**Constraints:**
- No countdown timers showing exact days in `.quiet` state — that creates obsessive checking behavior for high-orderliness profiles (this user is 80% orderliness on SLOAN)
- No notification for maintenance items except one optional gentle weekly nudge for `.due` items
- Max 8 maintenance items total. Beyond that, the system becomes ambient guilt architecture.

---

### PRIORITY 3 — Hydration as Rhythmic Prompt

**What it is:** Time-distributed contextual prompts for hydration. Not a habit. Not a counter. Not a completion toggle.

**Why third:** Hydration is a distributed state regulation behavior, not a discrete task. Binary completion tracking fails for distributed behaviors. Counters create Goodhart traps for Analytical/Competition profiles — the number becomes the target, not the physiological state.

**Architecture:**

Hydration is NOT a Habit model entry. It is a system-level rhythmic behavior with its own lightweight model:

```swift
@Model
class HydrationLog {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    // That's it. No amounts. No targets. No streaks.
}
```

**UI — where it lives:**
- A small `HydrationPulse` card in the Today tab, positioned below the doctrine card
- Shows: last hydration timestamp ("Last: 2h ago" / "Last: this morning")
- If quiet for 3+ hours during active day: the card's inkTeal dot pulses gently once (not continuous animation)
- Single tap: logs hydration. No confirmation, no celebration, no XP. Just: timestamp recorded, last-time display updates.
- Card copy: "Water." — that's the entire prompt.

**Notification logic (optional, user-configurable):**
- Max 3 notifications/day
- Times: ~10am, ~1pm, ~4pm
- Copy: "Water." — nothing else. No count, no streak, no "don't forget"
- If the user misses a prompt: nothing happens. No catch-up guilt.

**What is never built:**
- Glass/ounce counter
- Daily hydration target
- Completion badge
- Streak or consistency display
- "Hydration goal achieved" copy
- Comparison across days

**Card states:**
- Recent (< 2 hours): card is visually quiet, dot solid inkTeal
- Approaching (2–3 hours): dot gains a very subtle slow pulse
- Quiet (3+ hours during active hours): pulse more visible, card slightly brighter
- After 8pm: card becomes invisible — no evening hydration pressure

---

### PRIORITY 4 — Financial Clarity Layer

**Gate condition:** Build this only after Priorities 1–3 are stable and in use. Financial signals during early recovery introduce a stress variable before behavioral infrastructure is established.

**What it is:** Operational state reporting for financial conditions. Not budgeting. Not spending analytics. Not performance scoring.

**The governing frame:** Financial clarity, not financial virtue. The system reports operational state. It does not evaluate financial behavior.

**Lives in:** Operations system tab (warm #C8A96E domain). A section within the existing Operations card in Increments tab.

**Data model:**

```swift
@Model
class FinancialState {
    var id: UUID = UUID()
    var runwayState: RunwayState = .stable
    var nextObligationDate: Date? = nil
    var nextObligationLabel: String = ""    // "Rent", "Insurance"
    var notes: String = ""
    var updatedAt: Date = Date()
}

enum RunwayState: String, Codable {
    case stable     = "Stable"
    case watch      = "Watch"
    case act        = "Act"
}
```

**Three signals only — no more:**

1. **Runway State** — categorical, not numerical
   - "Runway stable." — inkGreen dot
   - "Runway: watch." — inkAmber dot  
   - "Runway: act required." — inkTeal dot (not red — never red for financial state)

2. **Next Obligation** — date + label only
   - "Next: Rent — in 12 days."
   - No dollar amounts displayed unless user explicitly enables them in settings

3. **Inflow Signal** — binary
   - "Income received this period." or "Quiet."
   - No amounts. No trends. No month-over-month.

**What is never built:**
- Spending categories or percentages
- Budget targets with progress bars
- Net worth display
- Month-over-month comparison
- "Over budget" language
- Savings streaks or goals
- Any financial score or aggregate metric

**Update mechanism:** Manual input only. The user updates the financial state card periodically (weekly review session is the natural anchor for this). No bank API integration. No automatic sync. Operational clarity requires user judgment, not algorithmic certainty.

---

## What Is Definitively Refused — Phase 3

These came from the agent review and supersede any request to build them:

**HRV dashboard inside the app**
Mechanism of failure: Analytical + Competition profile will optimize the HRV number, not the recovery state it represents. HRV obsession is documented in high-Achiever athletic profiles. If the user wants to use HRV data, they should read it from their external device and use it to inform their Energy State input on Today. The app does not display HRV.

**Hydration counter / ounce tracking**
Mechanism of failure: Competition strength turns any visible number into a score. The target becomes hitting the number, not physiological regulation.

**Session streaks**
Mechanism of failure: Same as habit streaks. Adds shame-reward oscillation to what should be neutral operational closure.

**Cold exposure / heat-cold contrast**
Contraindicated. Post-op tibial fracture. Vasoconstriction risk affects periosteal blood supply. Do not build, do not suggest. Revisit only when user reports full weight-bearing clearance.

**Open financial goal tracking**
Mechanism of failure: Achievement targets with visible progress bars activate Competition-strength optimization behavior. Financial goal bars in an achievement system become game objectives.

**Spider/radar charts**
Mechanism of failure: Analytical profile will diagnose the chart rather than execute behavior. The cognitive mode shifts from operational to evaluative.

**Infinite protocol customization in sessions**
Mechanism of failure: Architectural procrastination. The user will design protocols rather than run them. The 6-step cap and minimal add-session UI are structural defenses. Hold them.

**AI coaching language**
Mechanism of failure: The app's philosophical basis is "system reporting on itself." The moment the app says "I think you should..." it becomes a coach, not an instrument. The voice is observational, not advisory.

**Time-restricted eating as a tracked metric**
Conditional only as an environmental framing ("Eating window"). Never as a streak, counter, or daily completion toggle. High-Achiever + dietary restriction rules can create over-optimization or rigidity. Especially risky during physical recovery when protein timing for tissue repair matters more than eating window discipline.

**Sauna / heat protocols**
Hold until full weight-bearing clearance confirmed by user. High optimization-theater risk for this profile even when cleared.

---

## Adjudicated Disagreements from Agent Review

**HRV:** Agents split. One recommended including as an input to Energy State. Others recommended refusing. **Decision: Refuse inside the app.** The user should use HRV data from external hardware to inform their own Energy State selection. The app does not display, store, or respond to HRV values. This preserves the user as the interpreter of their own physiological state.

**Creatine / magnesium as habit entries:** Agents agreed these pass the science filter. **Decision: Include as optional seeds in grooming/morning protocols as steps, not as standalone habits.** "Creatine." and "Mag." are steps inside the Morning Protocol and Evening Shutdown respectively. This keeps the supplement cadence inside the session architecture rather than creating a separate supplements tracking surface.

**Zone 2 cardio:** Already built as a Health action/habit. **Decision: No additional tracking surface.** Do not add session-level exercise tracking or workout logging. What's there is enough.

**Weekly review ritual:** Multiple agents flagged this as high-leverage. **Decision: Build as a Session Protocol** with prompted questions (not open fields). Belongs in Operations domain. Cue: "Sunday evening" or user-defined. Prompted structure:
- "What closed this week?"
- "What carries forward?"
- "What needs a decision?"
Each prompt has a text field (max 100 chars) that feeds the daily log for that day. Completion: "Week closed."

---

## Integration Points With Existing Code

**Sessions in Today stack:**
- Add `Session` to SwiftData model container alongside `Action`, `Habit`
- `TodayView` fetches both `Action` and `Session` items for today
- Render SessionCard between ActionRows in the same VStack
- SessionCard taps to a new `SessionExecutionView` (full screen, not sheet)

**Maintenance in Increments tab:**
- Add `MaintenanceItem` to model container
- Render a new `MaintenanceSection` below the existing system cards in `IncrementsView`
- Uses `CardView(style: .ambient)` for each item

**Hydration in Today:**
- Add `HydrationLog` to model container
- Add `HydrationPulse` card to `TodayView` scroll content, below doctrine card
- Add optional notification scheduling in `NotificationService`

**Financial in You/Operations:**
- Add `FinancialState` to model container
- Surface in a new `FinancialClarityCard` inside the Operations section of the Increments tab
- Settings toggle: "Show dollar amounts" (off by default)

---

## Build Sequence

Do these in order. Do not parallelize. Each needs real-use settling before the next is added.

```
1. Session Protocols
   - Model, SessionCard, SessionExecutionView, AddSessionSheet
   - Seed 3 defaults (Morning, Evening Shutdown, Grooming)
   - Wire into Today stack and SwiftData container
   - Test for 14 days before next addition

2. Maintenance Cadence
   - Model, MaintenanceSection in Increments tab
   - Seed 4 defaults (air filter, deep clean, weekly reset, financial review)
   - No notifications yet — test passive visibility first

3. Hydration Rhythmic Prompt
   - HydrationLog model, HydrationPulse card
   - Local notification scheduling (optional, user-enables in Settings)
   - Watch: does the card get used or ignored?

4. Financial Clarity Layer
   - FinancialState model, FinancialClarityCard
   - Manual input only
   - Weekly review session is the natural update anchor
```

---

## Voice for New Features

**Sessions:**
- "PROTOCOL" not "Session" or "Routine"
- "Protocol closed." on completion
- "Run the protocol." as CTA
- "No active protocols." as empty state

**Maintenance:**
- "Attention window open." for due items
- "Due in [N] days." for upcoming
- "Quiet." for within-interval
- "Mark complete." as CTA

**Hydration:**
- "Water." — the entire prompt
- "Last: [relative time]" — the only displayed data
- Nothing else

**Financial:**
- "Runway stable." / "Runway: watch." / "Runway: act required."
- "Next: [label] — in [N] days."
- "Quiet." for no upcoming obligations
- Never: "overdue", "behind", "missed payment"

---

## The Line — Restated for Phase 3

The app broke when sessions become project management. It breaks when maintenance becomes a guilt backlog. It breaks when hydration becomes a counter. It breaks when financial clarity becomes a budgeting system.

Every addition in Phase 3 is one step from its dangerous version. The distance between "operational signal" and "performance metric" is small. The guardrails in this doc are the defense.

When in doubt, make the feature smaller and more silent, not larger and more visible.

---

## Opening Prompt for Next Session

```
You are building Phase 3 of INCREMENTS — a private iOS environmental cognition support system 
for one user (Brice). Read INCREMENTS_Agent_Handoff.md for the full behavioral architecture, 
visual system, and voice register. Then read INCREMENTS_Phase3_Evolution.md for what to build, 
in what order, and with what constraints. 

Start with Priority 1: Session Protocols. Build exactly what the spec describes. 
Do not add features beyond the spec. Do not redesign anything that exists.
The single Swift file is IncrementsApp.swift (~2,800 lines).
```

---

*INCREMENTS Phase 3 Evolution Brief · Synthesized from 7-agent behavioral science review*
*"The session is the unit of completion. Steps are navigation."*
