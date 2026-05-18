# INCREMENTS — Design Decisions
## Behavioral Science Synthesis · Post Multi-Agent Review
*v1.1 · Built from Phase 1 code + 7-agent behavioral science analysis*

---

## How to Read This Document

Three tiers of decisions:

- **Phase 1 Fixes** — changes to the current Swift build, no new screens required
- **Phase 2 Priorities** — ranked by psychological impact, not feature appeal
- **Hold** — things that sound good but shouldn't be built yet

Each decision includes the mechanism (why it works), the risk (what can go wrong), and the implementation note.

---

## PART ONE — PHASE 1 FIXES

These are changes to the existing build. None require new screens.

---

### FIX 01 — Replace the Daily Review "Skip" Button

**The problem:** A one-tap Skip teaches the nervous system that closure is optional. Easy escape routes undermine commitment consistency and weaken the review's function as a genuine loop-closing ritual. Over repeated exposures, approach motivation toward the review decreases because the exit has been normalized.

**The fix:** Remove the word "Skip" entirely. Replace with a two-option reduced-scope path:

When the user taps the current Skip area, a small confirmation appears:

> *"Close the loop lightly?"*
> - **One sentence only** — a single text field, pre-prompted: "Today looked like..."
> - **Close without review** — available, but requires a second deliberate tap

The psychological move: skipping is now conscious, not reflexive. The difference between a frictionless exit and a two-step exit is enormous behaviorally, even if the behavioral difference looks small.

**Implementation:** Replace `Button("Skip")` in `DailyReviewSheet` with a sheet-within-sheet confirmation flow. The "Close without review" path still exists — this isn't coercion, it's intentionality.

---

### FIX 02 — Cap the Today Stack at 8 Visible Actions

**The problem:** Unlimited "Add Increment" creates action sprawl. For an Analytical/Achiever profile, the customization itself becomes a design project — architecting instead of participating. Actions added during high-motivation states face the lower-motivation self later and create Zeigarnik load without momentum to close them.

**The fix:** Soft cap at 8 visible actions. When a 9th is attempted, the app pauses:

> *"Today already has 8 actions. Remove one first, or move this to tomorrow."*

This forces an active trade-off (prioritization) rather than passive accumulation. The list feels finishable — which is a prerequisite for starting.

**One additional guardrail:** Any new recurring habit added should require two fields before saving: "What existing cue triggers this?" and "What's the smallest version of this action?" If those fields are empty, the habit doesn't save. This prevents fantasy habits created during bursts of motivation.

**Implementation:** Add a count check in `AddActionSheet.addAction()`. Add cue/minimum-scope fields to `AddHabitSheet`.

---

### FIX 03 — Anchor the Default Actions to Explicit Cues

**The problem:** Many of the 8 seeded default actions are floating — they have no reliable environmental trigger. "Floating" habits require self-initiation, working memory, and motivational retrieval, which are precisely the systems that fail under cognitive load. Without a prompt, behavior is inconsistent regardless of intention.

**The mechanism:** BJ Fogg's cue research shows a 2-3x completion advantage when behavior is anchored to an existing routine via "When X, then Y" over free-floating intention.

**The fix:** Add an optional `cue` field to the `Action` model and expose it in the `AddActionSheet`. For the 8 seeded defaults, pre-fill suggested cues:

| Default Action | Suggested Cue |
|---|---|
| Morning light exposure | After first standing transition |
| Open the blinds | When walking to bathroom |
| Hydrate | When placing phone down at desk |
| Move your body | After clearing desk surface |
| Apartment reset — one area | After docking at primary seated position |
| Respond to 3 messages | After first coffee |
| Review priorities | When opening laptop |
| Eat protein | At first meal of day |

Cues appear in small mono text below the action title in `ActionRow`. They're suggestions, not rules. The user can edit or ignore them.

**Implementation:** Add optional `cue: String?` to `Action` model. Display in `ActionRow` below title if populated. Pre-populate in `seedDefaultActions()`.

---

### FIX 04 — Replace the Operator Score with a System Synergy Signal

**The problem:** The Operator Score (0-1000) is the highest-risk metric in the system. It compresses five complex life domains into a single number that will inevitably become a target. When it becomes a target, the user optimizes for the number rather than the underlying conditions — which is exactly what the app is designed to prevent. An analytical profile will unconsciously front-load easy Environment and Participation actions to keep the score high while harder Operations and Cognition work quietly atrophies.

**The fix:** Replace the primary `0-1000` display on the Home screen with a qualitative System Synergy signal:

Instead of: *"Operator Score: 742"*

Show: *"4 of 5 systems active this week."*

Or in the app's voice: *"Environment, Health, Participation moving. Operations and Cognition quiet."*

The 0-1000 number can remain in the data model for internal use but should not be the hero of the Home screen. The System Score cards on the Increments tab already provide better diagnostic information one tap away.

**What replaces it on Home:** A horizontal 5-dot system status row — one dot per system, colored to system color, filled if active this week (any action completed), hollow if quiet. Simple, unambiguous, non-gameable. Below it: the existing score trend line can stay as a 7-day momentum indicator, but de-emphasized.

**Implementation:** Keep `operatorScore` computed property in `AppState` for potential internal use. On `HomeView`, replace the score circle with the 5-dot status row. The `CircularProgress` showing `/1000` should be replaced with a simpler system activity indicator.

---

### FIX 05 — Make Score Decay Visible Without Making It Punitive

**The problem:** 5-point daily decay on a 0-100 scale means a system can be ignored for two weeks before hitting "Neglected" — the signal is too soft to register. But the no-shame philosophy is correct. The resolution is not to make decay harsher but to make it more *visible*.

**The fix:** Add a direction indicator independent of the score. After 3 consecutive days of zero actions in any system, that system's row on the Increments tab adds a quiet signal in the app's voice:

> *"This system has been quiet for 3 days."*

No red. No urgency. No "you failed." Just a factual state report — same register as the rest of the app. The language stays ecological, not moral. The score continues its existing gentle decay. The *visibility* of the drift is what changes.

**Implementation:** In `IncrementsView`, check `lastActivity` per system. If > 3 days without a completed action in that system, show the quiet text below the system row.

---

### FIX 06 — Add the Postponement Interrupt Card

**The problem:** The postponement loop the app is designed to prevent has no architectural counter inside the app. ACT (Acceptance and Commitment Therapy) and Behavioral Activation research identify the intervention: not motivation, not a streak reminder — a single visible micro-action that costs less than the friction of continued avoidance.

**The fix:** A card called "One Door" that appears on the Today screen when:
- No action has been completed past a configurable time threshold (default: noon)
- The user has opened the app multiple times without completing anything

What it looks like: A single calm card, same treatment as the doctrine card, above the action stack.

> *"One door."*
> *[Smallest-XP uncompleted action from today's stack]*
> *"Open it."*
>
> In small mono text below: *"Nothing else required."*

The action it surfaces is chosen by the system using the simplest criterion: lowest XP value in the uncompleted stack. This removes the last decision. The user's job is binary: tap or don't tap.

The card disappears after the action is completed. It does not persist as a record of a hard day. No judgment, no backlog visibility, no shame.

**Implementation:** Add state tracking in `TodayView` for first-open time and completion status. Surface the card conditionally. Use `min(by: \.points)` on uncompleted `todayActions` to identify the target action.

---

### FIX 07 — Daily Review Questions — Better Wording

**The problem:** "What did I postpone?" asked at end of day creates guilt retrieval. Retrospective self-report is unreliable at the end of the day — mood colors memory. The question invites moral inventory rather than functional observation.

**The fix:** Replace the three review questions with more accurate, less interpretive versions:

| Current | Replace With |
|---|---|
| "What improved my state today?" | "What reduced friction today?" |
| "What did I postpone?" | "What stayed heavy or unresolved?" |
| "What needs one small action tomorrow?" | "What's the first visible action tomorrow?" |

The third question is the highest-leverage change: it's an implementation intention formation prompt rather than a planning exercise. Naming tomorrow's first action dramatically increases the probability of taking it — and the naming should happen at night, when it's the only logical time.

**Implementation:** Update the three `reviewField` prompt strings in `DailyReviewSheet`.

---

### FIX 08 — Add a Morning Evidence Card

**The problem:** The app currently has strong immediate feedback (green glow, haptic on completion) but no reflective feedback layer. Immediate reinforcement activates the dopamine system; reflective feedback activates the prefrontal narrative system — where meaning, identity, and self-efficacy are actually built. The app needs both.

**The fix:** A single card on the Today screen, visible only on the morning open (before noon), generated from the previous day's data. It appears only if at least 3 actions were completed the day before. It disappears after being tapped or after 2 hours.

The card says one sentence in the app's voice:

> *"Yesterday: 6 actions. Environment moved. One work thread opened."*

Or on a lighter day:

> *"Yesterday: 3 actions. You participated."*

No praise. No score. No streak counter. A record being read back. The psychological mechanism: perceived progress on meaningful work (Amabile & Kramer's Progress Principle) is the strongest predictor of positive motivation — stronger than reward, recognition, or interpersonal support. This card delivers that mechanism in one sentence, once per day, in the morning when the nervous system is most receptive.

**Implementation:** Generate from `DailyLog` data. Simple computed property in `TodayView` based on previous day's completed action count and systems touched. Display conditionally in the Today stack before the action list.

---

## PART TWO — PHASE 2 PRIORITIES

Ranked by psychological impact, not feature interest. Build in this order. The success condition for Phase 1 is still 14 days of daily use — don't start Phase 2 until that's met.

---

### PRIORITY 1 — Timeline Screen

**Why first:** The Timeline is the highest-leverage Phase 2 feature because it targets the exact moment when the app is most likely to be abandoned — when the user feels worst and most disconnected from the identity being built. It exploits the Progress Principle (Amabile & Kramer) and self-continuity mechanisms simultaneously.

**The mechanism:** On hard days, the subjective experience is "nothing got done." The Timeline's job is to contradict that experience with evidence. The gap between felt experience (nothing happened) and recorded reality (several things happened) is where self-trust is rebuilt. This gap is predictable, common, and the Timeline is its only reliable correction.

**Design specification:**

*What to show per entry:*
- Timestamp in mono type (HH:MM, small)
- Action name (plain language, Sora, medium weight)
- System icon (color-coded)
- Nothing else — no XP, no score changes, no evaluation

*What to show at the day level:*
- Date header with day of week
- One summary line in small mono: "6 actions — Environment, Health, Participation" — not a score, a count with system names
- If zero actions: "Quiet day." — no red, no gap emphasis

*Temporal framing:*
- Scrollable history, no imposed limit
- Default view: last 7 days, today at top
- Scroll up to go back in time

*What not to include:*
- Summary statistics ("X actions this week")
- Best-day comparisons
- Any visual encoding of "good" vs "bad" days

**The screen's job:** Show receipts, not grades. When the user feels "nothing is improving," the Timeline shows that perception is incomplete.

---

### PRIORITY 2 — Focus Mode

**Why second:** For an Analytical/Achiever profile, the deep work timer does two things: it creates a context shift that signals the brain a different operational mode (implementation intention research shows 2-3x completion advantage when you specify when/where/how), and it converts an amorphous "work" session into a bounded challenge with a clear success condition — exactly the structure this profile responds to.

**Design specification:**

*Entry sequence (3 steps):*
1. Work type: **Deep Work / Review & Edit / Admin / Light Reading** — one tap
2. One-line intention (optional): "What am I doing in this session?" — implementation intention at the moment it matters
3. Timer start — UI simplifies: tab bar disappears, session card fills screen

*Session lengths:* 30 / 45 / 60 minutes, with 45 as default. Not Pomodoro's 25 (too short for complex work, too much transition overhead). Not 90 as default (requires full capacity).

*Counting up, not down:* A timer counting up produces less clock-watching anxiety than a countdown while still providing temporal information.

*Exit sequence (critical):*
- Screen 1: "Session complete. [Time logged: 47 min · Deep Work]" — below it: *"Let it settle before the next thing."* No immediate XP flash, no congratulatory animation.
- Screen 2 (optional): "One line if you want it — what moved?" — text field, auto-dismisses in 10 seconds if nothing entered. If the user writes anything, it becomes a Timeline entry.
- Return to Today screen.

The exit design matters: abruptly returning to high-stimulation content after sustained cognitive work produces a cortisol rebound that degrades the subsequent hour. The 2-screen sequence creates a 60-90 second buffer that initiates normalization.

---

### PRIORITY 3 — Energy State Input

**Why third:** The app currently has no way to calibrate the day's action stack to what's actually available. This matters during recovery phases, high-stress periods, and any day where capacity is genuinely constrained. Without calibration, the same 8-action stack appears on a terrible day as on an optimal one — which trains the user to ignore the stack on hard days, which trains the brain that the app is for good days only.

**Design specification:**

Appears as the first element on Today screen, above the action stack. Collapses after input.

*Input: Three options, icon + label, one tap:*
- 🟢 **Full** — Operational. Normal stack.
- 🟡 **Partial** — Running on partial. Adjust the day.
- 🔴 **Reserve** — Low reserves. Essentials only.

No mood language. Operational register throughout.

*Stack adaptation:*
- **Full:** No change.
- **Partial:** Stack reduces to 5 actions. Lowest-XP actions from each active system. One work track touch only. Doctrine line: *"Partial capacity is still capacity."*
- **Reserve:** Stack collapses to 3 actions: one environment (open blinds), one body (hydrate), one participation (one message). App copy: *"Three things. That's enough."*

*Critical detail:* No visible history of energy states for the user. The app logs this internally for Phase 3 pattern detection, but the user never sees a graph of their "reserve days." Tracking energy depletion would itself consume the energy being tracked.

---

### PRIORITY 4 — Notification Personalization

**Why fourth:** The current notification system uses fixed time windows that may not match actual energy and cognitive rhythms. Cue reliability research (Fogg) shows that notification effectiveness drops sharply when the cue doesn't coincide with a state of readiness. A 7 AM notification received during poor sleep is noise, and repeated noise trains the nervous system to ignore the entire notification category.

**Design specification:**
- Configurable quiet windows (start time, end time)
- Category toggles: Morning Orientation / Midday / Afternoon / Evening / Insights
- Maximum notifications: 4/day hard cap (already in philosophy, should be architecturally enforced)
- A "Derive timing from behavior" option (Phase 3) where notification times migrate toward the user's actual engagement windows

Keep the personalization surface minimal — this should not become a meta-task.

---

### PRIORITY 5 — Insights Tab

**Why fifth (and not before 30 days of data):** The core risk is premature insights. Before 30+ data points per system, almost any visible trend is artifact. If the app surfaces false patterns early, it destroys the "trusted instrument" status — and this profile will notice.

**Data thresholds:**
- Days 1-13: Tab does not appear in navigation at all. Not locked, not grayed out — absent.
- Day 14: Tab appears with descriptor summaries only ("You've logged morning light on 9 of 14 days"). No correlations.
- Day 30+: Basic pattern insights, labeled with confidence basis in small mono text below each: *"Based on 22 days of data. Pattern strengthens over time."*
- Day 90+: Full insight layer including cross-system correlations.

The epistemic humility increases trust for an Analytical profile rather than decreasing it. The user knows the system isn't lying to them.

---

### HOLD — Overview Dashboard / Spider Chart

**Why hold:** The spider chart showing 5 system scores is the Operator Score problem repeated in visual form. It invites optimization of the visual shape — "I need to make it rounder" — rather than of the underlying conditions. The user will see an irregular pentagon and target the weak axis, which means optimizing the score, not the life. This is the highest Goodhart's Law risk in the entire feature set.

The existing system rows on the Increments tab already provide better diagnostic information. The Overview Dashboard adds cognitive overhead without adding signal.

*If it gets built eventually:* Replace the spider chart with 5 directional arrows (up/flat/down trend per system), not score magnitude. Direction is harder to game than a number.

---

### HOLD — Richer Habit Visualizations

**Why hold:** The 7-dot completion trail is aesthetically appealing but psychologically it's a streak counter with better design. The app has correctly prohibited streak-breaking notifications. Richer habit visualizations risk reintroducing streak psychology through the visual layer, which is the back door to the exact pattern the app is designed to prevent.

---

## PART THREE — THE MILESTONE MOMENTS

These are specific in-app moments at consolidation checkpoints. They should feel like the system reviewing itself, not the app celebrating you.

---

### Day 14 — Calibration, Not Celebration

**Trigger:** First open of day 15.

**What happens:**

Large, centered display type:

> *14 DAYS.*

Two seconds. Nothing else.

Then:

> *"The system has been running. Time to look at what it learned."*

Button: *"Review the instrument."*

**Screen 2 — Data, no editorializing:**
- "14 days of participation."
- "[X] actions completed. [Y] systems touched."
- "[Most-completed system]: your most active system."
- "[Least-touched system] has been quiet."

No judgment on the quiet system.

**Screen 3 — The calibration prompt:**
- "Which default actions are you actually using?" (toggle to remove any — low friction)
- "What's missing?" (opens action library, tap to add)
- "Does this phase description still fit?" (one-tap edit)

**Screen 4 — Closing:**

> *"The operator reviews the system. The system improves. The work continues."*

Smaller below:

> *"Phase 2 is available when you're ready. There's no rush. This is already working."*

This is the milestone. Not a badge. A more accurate instrument.

---

### Day 30 — Pattern Detection Begins

A quiet insight surfaces on Home:

> *"Your most completed system is [X]. Your most active window is [time range]."*

No judgment. Just pattern visibility. At 30 days, patterns are real enough to surface.

One offer, optional: "Let's make these your base systems for the next 30 days."

---

### Day 66 — Automaticity Audit

The inverse of normal habit app logic: instead of celebrating a streak, the app suggests *retiring* scaffolding.

> *"You've completed [Habit X] on 55 of the last 66 days. It may not need to be in your Today view anymore."*

The habit has been internalized. The scaffolding can be retired. This demonstrates the app is oriented toward autonomy, not engagement.

---

### Day 90 — Phase Recognition

Operator Profile version update prompt:

> *"Update your current phase?"*

Not a level-up. A phase acknowledgment. The user documents what has changed since day 1. Identity consolidation expressed operationally — not "I've become X" but "the phase has shifted from X to Y."

---

## PART FOUR — VOICE ADDENDUM

A small set of additional copy patterns that emerged from the agent analysis, consistent with the existing voice doctrine:

**The One Door card:**
*"One door. [Action name]. Open it."*
*Nothing else required.*

**After energy state input on Reserve:**
*"Three things. That's enough."*

**After completing an environment action:**
*"The room is more usable than it was this morning."*

**When a system has been quiet for 3 days:**
*"[System] has been quiet for 3 days."*
(No suggested action unless the user taps in.)

**On the morning evidence card:**
*"Yesterday: [N] actions. [System] moved. [One specific action noted]."*

**After completing the One Door action:**
*"Re-entry complete."*
(Not "back on track." Not "streak restored." Just: you re-entered.)

**Day 14 closing:**
*"The operator reviews the system. The system improves. The work continues."*

---

## SUMMARY — WHAT TO BUILD WHEN

### Build Now (Phase 1 fixes, no new screens)
1. Replace "Skip" with reduced-scope closure path
2. Cap Today stack at 8 with soft friction on additions
3. Add `cue` field to actions, pre-fill seeded defaults
4. Replace Operator Score display with 5-dot system activity row
5. Add 3-day quiet signal on Increments tab
6. Build the One Door postponement interrupt card
7. Reword the three Daily Review questions
8. Add morning evidence card to Today

### Build After 14 Days of Phase 1 Use
9. Timeline screen (Priority 1)
10. Focus Mode (Priority 2)
11. Energy State input (Priority 3)
12. Notification personalization (Priority 4)

### Build After 30 Days of Data
13. Insights tab (Priority 5, descriptive only until day 30)

### Hold
- Overview Dashboard / Spider Chart
- Richer habit visualizations

---

*INCREMENTS v1.1 Design Decisions · Built from behavioral science synthesis*
*"participation in reality"*
