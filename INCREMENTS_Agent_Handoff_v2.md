# INCREMENTS — Agent Handoff Document
## v2.0 · Full System State · All Phases · Operator Profile Deep Map
*Read this before writing a single line of code.*

---

## What This App Is

INCREMENTS is a **private iOS life-operations instrument** for one user (Brice). It is not a productivity app, not a wellness app, not a habit tracker with streaks. It is an environmental cognition support system — small daily actions made visible as evidence that life is improving.

**The core operating question the app answers:** "What actions will make my life more inhabitable today?"

**The emotional register:** Cinematic recovery cockpit. Calm, operational, atmospheric, intelligent. Ex Machina energy — quiet intensity, restrained futurism, beautiful interfaces that earn their complexity.

---

## The Operator — Full Psychographic Map

This is the most important section for any agent building this app. Every design decision flows from this profile. Understand it before touching the code.

### Gallup StrengthsFinder Top 5

**1. Restorative** — The primary operating mode. Energized by problems, not dismayed by them. Instinctively analyzes symptoms, identifies root causes, and restores function. Applies this to self ("fix-it" orientation toward own deficits). This strength can tip into self-criticism when there's nothing external to fix. The app must never amplify this by presenting deficits in ways that invite self-directed Restorative behavior (shame spirals). Restorative loves turnaround situations — the app's "quiet system" states should feel like turnaround opportunities, not failures.

**2. Achiever** — Internal combustion engine. Feels zero at day start; must accumulate evidence of movement by day end. Every. Single. Day — including weekends and vacations. The "divine restlessness" this creates is the app's primary ally (gets Brice to open it) and primary risk (the app could become another achievement arena to optimize). Key behavioral note: Achievers move to the next challenge without acknowledging completions. The daily review and close-the-loop mechanics directly counteract this. Also: Achiever + Recovery State = high friction. The gap between drive and physical capacity is the emotional ground the app operates on.

**3. Analytical** — Demands evidence. "Prove it." Builds trust through data, patterns, logic. Will auto-evaluate any new UI element: "What job is this doing?" Elements that can't answer that question fail the trust test. The Analytical profile also means: will detect when the app is not actually tracking what it says it's tracking (e.g., actions that don't reset, reviews that don't save). These bugs destroy trust. Accuracy is not optional.

**4. Individualization** — Sees people as uniquely distinct. Intuitively tailors approaches to individuals. Impatient with generalized systems ("this doesn't apply to me"). This is why generic wellness apps fail for this user. The app must feel specifically built for this person. Every piece of copy that could apply to anyone is a small trust violation.

**5. Competition** — Progress is measured against performance of others (or past self). Winning feels complete; losing is gracious externally, infuriated internally. This strength is the most dangerous one for the app to activate incorrectly. Any visible number becomes a score. Any score becomes a competition. Any competition requires winning. This is why streaks, aggregate scores, percentage trends, and daily XP totals are all refused. Competition strength activated by an improperly designed metric will Goodhart-trap the behavior the metric is measuring.

### ESF (Entrepreneurial StrengthsFinder)

**Dominant (leads naturally):**
- **Confidence** — Clear, accurate self-assessment. Uses awareness to build trust and influence. The app should not undermine this with excessive nudging or low-agency copy.
- **Risk-Taker** — Enthusiasm and positivity when taking on challenges. Sees past barriers. Charismatic and ambitious. The app's operational register matches this — it doesn't hedge, it states.
- **Delegator** — Understands he cannot do everything himself. Identifies special abilities in others. This is relevant to the app: Brice will not maintain it himself long-term without it delivering sufficient daily value. Value must be evident.

**Contributing (must be deliberately applied):**
- **Determination** — Takes on challenges aggressively but delays action to think through options. The app addresses this directly: One Door interrupt reduces decision cost at the "what do I do" moment.
- **Creative Thinker** — Enjoys exploration but may hesitate to ask questions that would reach the answer faster. The app should not require exploration to function.
- **Knowledge-Seeker** — Reactive (understands problems when they arise) rather than proactive. App must not require proactive system-wide review to maintain.
- **Relationship-Builder** — Best when positive attitude shines outward. The app is solo-use, but its operational mode should feel like interacting with an intelligent, warm colleague — not a spartan utility.
- **Promoter** — Subtle approach to promotion. Works with people who communicate boldly on his behalf. Implication: the app won't be shared widely, but if shown to others it should be immediately legible as sophisticated and intentional.

**Supporting (needs partnership/reinforcement):**
- **Independent** — Understands power of teamwork. Should avoid last-minute decisions without input. The app's doctrine cards serve this function — pre-set behavioral guidance reduces isolation of decision-making.
- **Business Focus** — Focuses on day-to-day over long-term financial alignment. This is exactly why the Financial Clarity layer (Phase 3 Priority 4) exists: to make the long-term visible without overwhelming the operational present.

### MBTI / Personality

**INTJ** — Introvert (67%), iNtuitive (50%), Thinking (50%), Judging (44%)

What this means architecturally:
- **Introvert:** The app is a private instrument, not a sharing surface. No social features, no external accountability loops.
- **iNtuitive:** Comfortable with abstraction and pattern. The system metaphor (5 domains, scores, synergy) is coherent to this profile. Does not need everything explained.
- **Thinking:** Decisions based on logic and data, not feeling. Copy that appeals to emotion over reason loses credibility. The app's operational register (factual, state-reporting) is correct.
- **Judging:** Prefers structure, closure, decisiveness. The daily review "close the loop" mechanic is psychologically satisfying to a J profile. Incompleteness is mildly aversive — unfinished tasks create open loops.

**SLOAN: SCOAI** (80% Orderliness, 80% Inquisitiveness, 70% Emotional Stability, 66% Extraversion, 60% Accommodation)

Critical flags from SLOAN:
- **80% Orderliness** — High tolerance for and preference toward structure and predictability. Do NOT show countdown timers in quiet Maintenance states — this creates obsessive checking behavior at high-orderliness scores. But DO ensure the app's own behavior is orderly and predictable. Bugs, inconsistencies, and unexpected states are especially costly for this profile.
- **80% Inquisitiveness** — Intellectual curiosity is a primary trait. The Science Note on system cards (explaining the behavioral science behind each domain) directly serves this. Do not remove these. They convert a skeptical INTJ into a committed user.
- **70% Emotional Stability** — More resilient than average. The app can be direct, even blunt, in its operational copy. Does not need emotional buffering on every message.

---

## What Irritates This Profile (Design Failure Modes)

These are the specific patterns that will cause Brice to stop using the app. Each one is grounded in the psychographic data above.

**1. Inaccuracy.** Analytical + INTJ will notice when the app doesn't track what it claims to track. Daily actions not resetting, reviews not saving, scores that don't update — these aren't bugs, they're trust violations. Fixed in v1.3. Must stay fixed.

**2. Vagueness.** Copy that could apply to anyone. "You're doing great!" "Keep going!" Generic motivational language reads as noise to this profile and signals that the system doesn't actually know what's happening.

**3. Premature closure prompts.** The Judging preference means incompleteness is aversive — but being asked to close the loop before the day feels genuinely complete is also irritating. The "Close lightly?" path exists for this reason.

**4. Visible numbers that become scores.** Competition strength is the mechanism. Any counter, any cumulative metric, any trend visualization risks being optimized rather than used. XP-to-next in the Synergy card is the most active current risk. Watch whether it becomes a scoreboard proxy.

**5. Excessive micro-confirmation.** High-orderliness profiles do not need animation confirmation on every tap. The completion glow on actions is sufficient. Add more and it begins to feel like the app is performing for you rather than with you.

**6. Cognitive load at high-friction moments.** Reserve state is when the app matters most. Reserve state is also when decision capacity is lowest. Any feature that adds decisions at Reserve moments (energy input card friction, review questions that feel like demands) will be abandoned precisely when it's most needed.

**7. Design that can't explain itself.** INTJ Analytical profile will ask of every element: "Why is this here?" The answer has to be behavioral — not aesthetic. The brain icon survives because it has three simultaneous answers to that question. Decorative elements that have no behavioral answer will create low-level irritation over time.

**8. Praise language.** Not because it's unwanted — Achievers do need recognition — but because this profile will detect praise that's unearned or disproportionate. "Well done" after completing one action doesn't land. The operational register (factual acknowledgment without evaluation) is correct and must be maintained.

**9. Protocol design as procrastination.** Analytical + Achiever + Creative Thinker = loves designing systems more than running them. The 6-step session cap and minimal AddSessionSheet are structural defenses. If Brice is spending time editing sessions rather than running them, the app is serving the wrong behavior.

**10. Unpredictability.** The 80% Orderliness score means the app's own behavior must be consistent. Doctrine cards that feel random, UI elements that appear and disappear without clear logic, features that work differently on second use — all undermine the sense of a reliable instrument.

---

## Areas of Improvement — Live Watch Items

These are patterns to monitor in real use. They're not bugs yet, but they could become structural problems.

**Energy State input friction on hard days.** The card appears until set, which is correct. But on Reserve days — when the app matters most — even choosing between three options may feel like too much. If the card is being dismissed without input, it should become optional/collapsible. Currently watching.

**XP-to-next as score proxy.** The Competition strength may convert this small number into a daily objective. If Brice notices himself checking it, or if the app open patterns suggest it's a primary motivation, the number should be hidden or removed. Internal only.

**Doctrine line predictability.** Rotating by weekday makes the line predictable by day 7. Predictable doctrine lines become wallpaper. Phase 2 should evaluate a smarter rotation — data-informed or genuinely random.

**One Door trigger timing.** Currently fires at noon with zero completions. On genuinely busy mornings, this may fire on days when the absence of completions reflects external demands rather than avoidance. If the interrupt becomes unwelcome, the trigger logic needs refinement.

**Daily Review as a "completion" achievement.** Achiever strength may treat opening the Daily Review as an item to check off rather than a reflection practice. Watch whether the answers are getting shorter and more perfunctory over time.

**Maintenance items as ambient guilt.** The 8-item cap is structural defense, but even 3–4 "Attention window open" items visible simultaneously will feel like a failure backlog to an Achiever. If this happens, increase the threshold for surfacing items or reduce seeded defaults.

**Financial Clarity Layer timing.** This is Phase 3 Priority 4 for a reason — financial signals during early recovery introduce stress before behavioral infrastructure is established. Do not build this until Priorities 1–3 have at least 14 days of stable use.

---

## The Color System

```
bgBase       #0D0C0B   warm neutral base (NOT blue-undertoned)
surface      #171512   primary card background
surface2     #1D1B18   secondary card, context layer
violet       #8A6EFF   primary accent, interactive
violetLight  #B09AFF   text highlights, selected states
violetDim    #4A3D88   subdued violet, tab backgrounds
warm         #C8A96E   secondary accent, emotional warmth
warmLight    #E8C98E   warm highlight
inkGreen     #5ACEA8   completion, environment system, positive
inkRed       #D06B6B   RESERVED FOR SYSTEM ERRORS ONLY — never domain use
inkTeal      #5AB8D6   Health system color (clinical neutral — not red)
inkAmber     #D4933A   Participation system, caution signals
textPrimary  #F0ECFF   primary readable text
textSecond   #A8A0C8   secondary, card body
textMuted    #6A6285   metadata, labels
muted        #4A4468   placeholders, dividers
```

**System domain colors:**
- Environment → inkGreen
- Cognition → violetLight
- Health → inkTeal (NOT red — this was a critical fix)
- Operations → warm
- Participation → inkAmber

---

## Typography Rules

- **Sora** — all UI text, headings, body copy
- **DM Mono** — labels, metadata, MonoLabel component only
- **Minimum mono size: 11pt** — hard floor. Below 11pt fails legibility under cognitive load.
- **Tab bar labels: 10pt** — documented exception, space-constrained
- **Intentional sub-11pt exceptions:** system dot pictographic labels (8pt), day-of-week habit dot letters (8pt), launch screen decorative text
- **Tracking on MonoLabel: 2.0** (reduced from 2.5 to compensate for size increase)

---

## Card Hierarchy (Three Tiers — Do Not Flatten)

```swift
CardView(style: .primary)    // operative actions — surface fill, violet-bloom shadow
CardView(style: .secondary)  // context, evidence — surface2, more padding
CardView(style: .ambient)    // infrastructure, guardrails — no background, warm-violet border rule
```

CardView primary has three shadow layers: warm rim light above, dark grounding shadow below, violet ambient bloom.

---

## Voice & Copy Register

**Write like this:**
- "Open the blinds."
- "One action now."
- "Close the loop before sleep."
- "Loop closed. The record is updated."
- "Quiet." (for neglected systems — never "Neglected")
- "Quiet day." (for empty timeline days)
- "Participate before postponement."
- "Protocol closed."
- "Attention window open."
- "Water."
- "Runway stable." / "Runway: watch." / "Runway: act required."

**Never write:**
- Praise language: "Well executed", "You showed up", "Great job"
- Shame language: "Neglected", "You failed", "Streak broken", "Missed", "Behind", "Overdue"
- Motivational-speaker cadence: "Crush your goals", "Level up your life"
- Urgency: "You haven't opened the app", "Don't break your streak"
- Evaluative framing on completion: "Perfect", "Excellent"
- AI coaching language: "I think you should...", "Consider trying..."

**The register:** Operational. Ecological. The system reports state without judging it. A system reporting on itself, not a coach talking to a student.

---

## Behavioral Architecture — What Must Never Change

1. **No aggregate operator score as hero element.** XP exists internally; never display XP total.
2. **No streak counters.** Use last-completed indicator only.
3. **No streak-shaming notifications.** Ever.
4. **Health system is inkTeal, not inkRed.**
5. **System decay uses opacity modifier, not amber.**
6. **One Door surfaces lowest-XP action.** User's job is binary.
7. **Daily Review has no Skip button.** "Close lightly?" requires a second deliberate tap.
8. **Energy State stack reduction is silent.** No label, no announcement.
9. **scoreLabel returns "Quiet" not "Neglected"** for systems below 50 score.
10. **Timeline gated at day 14.** Absent from tab bar entirely before then.
11. **Daily actions reset each calendar day.** Handled by `resetDailyActionsIfNeeded()`. One-off (.none) actions never reset.
12. **Daily Review saves to DailyLog.** Re-opening same day's review shows saved state, not blank form.

---

## Current Build State

**File:** `IncrementsApp.swift` — single-file SwiftUI + SwiftData app, ~3,655 lines.
**Platform:** iOS 17+, SwiftData, local only, no backend, no auth.
**Fonts:** Sora (UI) + DM Mono (metadata/labels). Both custom-bundled.
**Version:** v1.3

### What's Built and Working

**Phase 1 — Complete:**
- Home (Operator Dashboard) — System Synergy 5-dot row, Next Sane Participation, System Status rows with domain color accents
- Today (Daily Execution) — Energy State input, Morning Evidence card, One Door postponement interrupt, doctrine card, action stack (capped at 8), progress ring, Daily Review CTA
- Increments (System View) — 5 system cards with domain accent strips, 3-day quiet signal, completed today section
- Habits — HabitCard with cue + minimum scope, system-color completion button, last-completed indicator (no streak dots)
- You — Profile (BrainGlyph avatar, phase label, level/phase/XP-to-next), Work Tracks, Recovery Phase, Settings
- Timeline — Gated at day 14, shows receipts not grades, violet thread connectors
- Launch Sequence — BrainGlyph nodes → corona → wordmark → app load, 2.25s, cold launch only
- All sheets — custom handle, bgBase background, no iOS default chrome
- Custom tab bar — bgBase not ultraThinMaterial, violet/warm gradient separator, domain bloom behind selected tab

**Phase 2 — Partially Built:**
- Energy State ✓ — Full/Partial/Reserve with silent stack adaptation
- Timeline ✓ — Gated, working
- Focus Mode ✗ — Not yet built (tab bar disappears, countdown timer)
- Notification personalization ✗ — Not yet built
- Insights tab ✗ — Blocked until 30 days of data

**Phase 3 — Priority 1 Complete:**
- Session Protocols ✓ — Session model, SessionCard, SessionExecutionView, AddSessionSheet
- 4 seeded defaults: Morning Protocol, Evening Shutdown, Grooming Protocol, Weekly Reset
- Session is the unit of completion. Steps are navigation.

**Phase 3 — Priorities 2–4 — Not Yet Built:**
- Priority 2: Maintenance Cadence layer
- Priority 3: Hydration as rhythmic prompt
- Priority 4: Financial Clarity layer (build last, after 14+ days of P1–P3 stable use)

**Bug Fixes Applied in v1.3:**
- Daily action reset: `resetDailyActionsIfNeeded()` runs on every launch, resets recurring actions each new calendar day. One-off actions never reset.
- `OperatorProfile.lastResetDate` tracks which day reset occurred.
- Daily Review now saves to `DailyLog` via `saveReview()`. Re-opening same day goes straight to result view. Light close also saves.

---

## Phase 2 — Remaining Build Items

**Gate condition:** 14 days of daily Phase 1 use.

**1. Focus Mode**
- Deep work timer: tab bar disappears during session
- 2-screen exit sequence with buffer
- 30/45/60 min options, 45 default
- Counts up not down (less clock-watching anxiety)
- Session locked — no notifications during

**2. Notification personalization**
- Quiet windows (user-configurable hours)
- Category toggles (which domains can notify)
- 4/day hard cap (already enforced in code)

**3. Insights tab**
- Blocked until 30 days of data
- Tab does not appear before then
- Shows pattern observations, not scores

---

## Phase 3 — Full Build Specification

### PRIORITY 2 — Maintenance Cadence
*(Build after 14 days of P1 Session Protocol use)*

**What it is:** A temporal signal layer for interval-based behaviors. State reporting only — not a to-do list.

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

**State language:**

| State | Display text | Color |
|---|---|---|
| quiet | "Quiet" | textMuted |
| upcoming | "Due in [N] days" | inkAmber |
| due | "Attention window open" | inkTeal |

**Never:** overdue, missed, neglected, behind, late, failed. **Never red** for any maintenance state.

**UI placement:**
- "MAINTENANCE" section at bottom of Increments tab, below system cards
- Uses `CardView(style: .ambient)` for each item
- Only shows `.upcoming` or `.due` items by default
- "Show all" toggle reveals `.quiet` items
- Single tap → "Mark complete" → updates `lastCompleted` → state recalculates

**Surfaces to Home:** Only `.due` items, and only if fewer than 3. Never show a maintenance backlog on Home.

**Seed defaults:**
- Air filter — 30 days — Environment
- Deep clean — 14 days — Environment
- Weekly reset — 7 days — Operations
- Financial review — 7 days — Operations

**Constraints:**
- No countdown timers in `.quiet` state (80% orderliness → obsessive checking risk)
- No notification except one optional gentle weekly nudge for `.due` items
- Max 8 maintenance items total
- No notification for maintenance items except one optional gentle weekly nudge for `.due` items

---

### PRIORITY 3 — Hydration as Rhythmic Prompt
*(Build after P2 Maintenance is stable)*

**What it is:** Time-distributed contextual prompts. Not a habit. Not a counter. Not a completion toggle.

**Data model:**
```swift
@Model
class HydrationLog {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    // That's it. No amounts. No targets. No streaks.
}
```

**UI — where it lives:**
- Small `HydrationPulse` card in Today tab, below doctrine card
- Shows: last hydration timestamp ("Last: 2h ago" / "Last: this morning")
- 3+ hours quiet during active day: inkTeal dot pulses gently once (not continuous)
- Single tap: logs timestamp. No confirmation, no XP. Just: last-time display updates.
- Card copy: "Water." — the entire prompt.

**Card states:**
- Recent (< 2 hours): quiet, dot solid inkTeal
- Approaching (2–3 hours): dot gains very subtle slow pulse
- Quiet (3+ hours during active hours): pulse more visible, card slightly brighter
- After 8pm: card invisible — no evening hydration pressure

**Notifications (optional, user-configurable):**
- Max 3/day: ~10am, ~1pm, ~4pm
- Copy: "Water." — nothing else
- Missed prompt: nothing happens. No catch-up guilt.

**What is never built:** Glass/ounce counter, daily target, completion badge, streak, comparison across days, "hydration goal achieved" copy.

---

### PRIORITY 4 — Financial Clarity Layer
*(Build last — only after P1–P3 stable for 14+ days)*

**Gate condition:** Financial signals during early recovery introduce a stress variable before behavioral infrastructure is established.

**What it is:** Operational state reporting for financial conditions. Not budgeting. Not performance scoring.

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

**Three signals only:**
1. **Runway State** — categorical, never numerical
   - "Runway stable." — inkGreen dot
   - "Runway: watch." — inkAmber dot
   - "Runway: act required." — inkTeal dot (never red for financial state)

2. **Next Obligation** — date + label only
   - "Next: Rent — in 12 days."
   - No dollar amounts displayed unless user explicitly enables in Settings

3. **Inflow Signal** — binary
   - "Income received this period." or "Quiet."
   - No amounts. No trends. No month-over-month.

**Lives in:** Operations system section of Increments tab. Manual input only. Weekly Reset session is the natural update anchor.

**What is never built:** Spending categories, budget targets with progress bars, net worth display, month-over-month comparison, "over budget" language, savings streaks or goals, any aggregate financial score.

---

## What Is Definitively Refused — All Phases

| Feature | Why Refused |
|---|---|
| Spider/radar chart | Goodhart's Law #1 risk. Analytical profile diagnoses the chart, not the behavior. |
| Streak counters (any form) | Shame-reward oscillation. Held absolutely. |
| Aggregate Operator Score as hero | Competition strength turns it into a game objective. |
| Continuous ambient animation | Shifts app from instrument to environment. Easier to ignore. |
| Praise language (any context) | Copy register violation. Trust loss. |
| Gamification ladder / level rewards | Opposite of autonomy orientation. |
| Open-canvas journaling | Blank-field anxiety for Analytical at end of day. |
| Percentage trend comparisons | Competition strength Goodhart's trap. |
| "Best streak" display | Streak psychology through visual layer — the back door. |
| HRV dashboard | Analytical + Competition will optimize the number, not the state it represents. |
| Hydration counter / ounce tracking | Competition turns any visible number into a score. |
| Session streaks | Same mechanism as habit streaks. |
| Cold exposure / heat contrast | Contraindicated. Post-op tibial fracture, vasoconstriction risk. Revisit only when full weight-bearing confirmed. |
| Sauna / heat protocols | High optimization-theater risk. Hold until cleared. |
| Open financial goal tracking | Achievement targets with progress bars become game objectives. |
| Infinite protocol customization | Architectural procrastination. Designing protocols, not running them. |
| AI coaching language ("I think you should...") | Shifts app from instrument to coach. Wrong orientation. |
| Time-restricted eating as tracked metric | Achiever + dietary rules = over-optimization. Recovery protein timing more important. |
| Insights tab before 30 days | No meaningful patterns. Premature data creates noise. |

---

## Phase 3 Voice Reference

**Sessions:**
- "PROTOCOL" not "Session" or "Routine"
- "Protocol closed." on completion
- "No active protocols." as empty state
- "When: [cue]" for cue display

**Maintenance:**
- "Attention window open." for due items
- "Due in [N] days." for upcoming
- "Quiet." for within-interval
- "Mark complete." as CTA

**Hydration:**
- "Water." — the entire prompt
- "Last: [relative time]" — the only displayed data

**Financial:**
- "Runway stable." / "Runway: watch." / "Runway: act required."
- "Next: [label] — in [N] days."
- "Quiet." for no upcoming obligations

---

## Assets in Xcassets

- **AppIcon** — brain icon with dark background, home screen icon
- **BrainGlyph** — same brain, transparent background, used in LaunchSequenceView and ProfileTabView avatar

The launch sequence references `Image("BrainGlyph")` — ensure this asset exists when building.

---

## The Governing Test

Before every build decision:

> "Does this reduce cognitive load and increase participation in reality — or does it increase time spent inside the app?"

If the latter: do not build it.

The app is a **launch surface**, not a destination. Maximum daily interaction per feature: 45 seconds. If a feature cannot be fully used in 45 seconds, redesign it before building it.

---

## The Guardrails

> No streak shaming. No failure language.
> If the app creates pressure, remove items.
> No notifications that generate guilt.
> Gentle decay only — never harsh penalties.

**For the build process:**
> Do not add more features without a specific real use case identified through actual use.
> Do not redesign the visual system. The palette is committed.
> Do not add a backend until local persistence is genuinely insufficient.
> The app is a constraint, not a canvas.

---

## Opening Prompt for Next Session

```
You are working on INCREMENTS — a private iOS environmental cognition support system 
built for one user (Brice). Read INCREMENTS_Agent_Handoff_v2.md before doing anything. 
It contains the full operator psychographic profile, behavioral architecture, visual system, 
voice register, complete phase map, what's built, what's refused, and what to watch.
The single Swift file is IncrementsApp.swift (~3,655 lines).
Do not add features. Do not redesign the visual system. Work only on what's specified.
Current build state: Phase 1 complete, Phase 2 partial, Phase 3 Priority 1 complete.
Next to build: Phase 3 Priority 2 — Maintenance Cadence.
```

---

*INCREMENTS Agent Handoff · v2.0 · Full system synthesis including all phases and operator deep map*
*"participation in reality"*
