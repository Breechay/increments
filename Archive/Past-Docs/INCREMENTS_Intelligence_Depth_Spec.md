# INCREMENTS — Intelligence Depth Specification
## What the App Becomes · Science Foundation · Agent Research Brief
*Written for multi-agent development. Each section is a complete research and build mandate.*

---

## Who This Is For and Why It Matters

This document exists because there is a gap between what INCREMENTS currently does (record behavior and report state) and what it could do (understand a specific person well enough to meaningfully accelerate their development). That gap is not a feature list. It is an intelligence architecture problem.

The operator is Brice Ikouebe. The profile is known and precise:

**Gallup Top 5:** Restorative · Achiever · Analytical · Individualization · Competition
**ESF Dominant:** Confidence · Risk-Taker · Delegator
**MBTI:** INTJ (Introvert 67% · iNtuitive 50% · Thinking 50% · Judging 44%)
**SLOAN:** SCOAI — 80% Orderliness · 80% Inquisitiveness · 70% Emotional Stability
**Current state:** Physical recovery (tibial fracture, post-op, crutches). Aspiring filmmaker. Projects: FORM (coaching app), HIDEOUT (café/space concept).
**The operating question the app answers:** "What actions will make my life more inhabitable today?"

This is not a generic productivity profile. Every intelligence layer must be designed for this specific combination — not for "motivated people" or "analytical types" in general, but for the exact intersection of Restorative + Achiever + Analytical + Competition + INTJ + SCOAI in a physical recovery context pursuing creative and entrepreneurial work.

---

## What the App Currently Knows

As of v1.5, the data layer includes:

- `Action` — title, system, recurrence, completedAt, completionDates[], skipCount, isHighFriction
- `Habit` — completionHistory[], last7[], cue, minimumScope
- `Session` — steps[], lastCompleted, recurrence, points
- `DailyLog` — completedActionIDs[], systemsTouched[], topWin, notes (heavy/unresolved), specificActionNote (tomorrow's action)
- `CognitionLog` — date, clarityLevel, cognitiveLoad, clarityScore (written when Energy State is set)
- `HydrationLog` — timestamp only
- `FinancialState` — runwayState, nextObligationDate, inflowReceived
- `MaintenanceItem` — intervalDays, lastCompleted, state
- `OperatorProfile` — xp, level, weeklyActiveSystems, notif preferences, firstLaunchDate
- `EnergyState` (in-session) — Full / Partial / Reserve, set daily

**What it does NOT yet know:**
- Time-of-day completion patterns (which hours produce actual completions)
- Cross-system correlation (does Environment activity predict Health activity?)
- Habit-to-action transfer (do completed habits reduce friction on actions in the same system?)
- Creative output patterns (what conditions precede or follow deep Cognition work?)
- Energy State calibration accuracy (do Reserve days actually produce fewer completions, or is the self-report noisy?)
- Skill development trajectory (is capacity for certain action types growing over time?)
- Recovery phase correlation (does physical improvement correlate with system activation patterns?)

---

## The Intelligence Architecture — Four Layers

### Layer 1: Pattern Recognition (Days 1–14)
*What is actually happening, without judgment*

The app needs to move from "here is what you did today" to "here is what your behavior looks like as a pattern." This layer is purely observational — no recommendations, no scores, no evaluations. Just honest pattern reading that an Analytical profile can trust because it's grounded in actual data.

**What to build:**
- Time-of-day completion histograms per system (when does Health actually get done? morning? never?)
- Day-of-week activity maps (is Cognition always dead on Mondays? does Participation cluster on weekends?)
- Energy State correlation: when Reserve days are declared, what actually happens to completions? Does the self-report match the outcome?
- Habit-action co-occurrence: on days when the Morning Protocol is completed, how many actions follow vs days without it?
- Skip pattern clustering: which actions get skipped together? (If "Review priorities" and "Respond to 3 messages" are always skipped together, that's a different problem than each being skipped independently)

**The science foundation an agent should research:**
- Ultradian rhythm and performance windows (Peretz Lavie's work on alertness cycles) — do Brice's completion timestamps cluster around natural 90-min high-performance windows?
- Implementation intention research (Gollwitzer & Sheeran 2006 meta-analysis) — what makes a cue effective? The app has cues but doesn't yet evaluate whether they're working.
- Temporal self-regulation theory (Hall & Fong) — people with high self-control don't exert willpower, they engineer their environments. What patterns in the data reveal environments being engineered vs willpower being exerted?

---

### Layer 2: Friction Diagnosis (Days 14–30)
*Why things aren't working, specifically*

This is Restorative applied to the system itself. The app should be able to say "this specific action has been on your stack 18 days and closed 3 times — the problem is probably the cue, not the action" and distinguish that from "this action has been skipped for 3 consecutive days but was completing consistently before that — something changed."

**What to build:**

**Action friction classifier:**
- Chronic friction (skipCount high, consistent since creation) → cue problem or scope too large
- Acute friction (sudden drop in completion after consistent period) → context change or competing demand
- Temporal friction (only skips on certain days/times) → scheduling mismatch
- System friction (whole system going quiet, not one action) → environmental barrier vs motivational barrier

**The distinction matters because the intervention is different:**
- Cue problem → suggest changing the "When:" field
- Scope problem → suggest minimum scope reduction ("What's the 2-minute version?")
- Scheduling → suggest time-shifting the action
- Environmental → ask what changed in the environment or recovery status

**Habit effectiveness assessment:**
After 21+ completions of a habit, does it show automaticity signatures? (Automaticity = completion without the cue being consciously noticed, faster completion, reduced decision cost visible as consistent early-day timing). The app can't measure automaticity directly but can approximate it: is the habit being completed at increasingly consistent times? Is it completed before or after other actions in predictable order?

**The science foundation an agent should research:**
- Habit formation research (Phillippa Lally, UCL 2010) — the "21 days" myth vs actual data. Habits form between 18 and 254 days depending on complexity. Simple habits (hydration) form fast. Complex ones (morning protocol) take months. The app should calibrate its "rhythm forming" language to complexity, not just duration.
- Friction science (BJ Fogg, Tiny Habits) — specifically the motivation-ability seesaw. An INTJ Analytical profile has high motivation but often sets ability requirements too high. The app should detect this pattern: actions with long titles, elaborate cues, and high points values that never get completed. These are ability-constrained, not motivation-constrained.
- Self-determination theory (Deci & Ryan) — specifically the difference between identified regulation (doing something because you see why it matters) and introjected regulation (doing it to avoid guilt). The INCREMENTS behavioral architecture is explicitly designed to prevent introjection (no shame, no streaks, no guilt notifications). But the friction diagnosis layer needs to recognize when introjection is creeping in through other mechanisms — for example, if the user is only completing actions that were visible to an imagined audience, or only completing "achievement" actions and never "maintenance" ones.

---

### Layer 3: Adaptive Intelligence (Days 30–90)
*The system responds to what it learns about you*

This is where the app stops being a tracking tool and starts being a thinking partner. After 30 days it has enough data to make real inferences. The intelligence at this stage is not about telling Brice what to do — the app explicitly never does that. It's about the system presenting what it observes in a way that is so accurate and specific that Brice can make better decisions with less cognitive effort.

**What to build:**

**Personal operating model — the app's internal understanding of Brice that shapes every surface:**

*Best window detection:* Using completionDates timestamps across all actions, compute the 2-hour window where completions are statistically most likely. Surface this as a soft signal: "Your best window appears to be 9–11am. Today's highest-friction actions are scheduled for 3pm." Don't move them automatically — report the observation.

*System cascade detection:* When System A is active, does System B follow within 24-48 hours? If Environment (open blinds, reset area) reliably precedes Health and Cognition actions, then the app knows that Environment is a gateway system — touching it first opens the others. Surface this as: "Environment moves first for you. The rest tends to follow." This is the most valuable insight the app can generate because it means one action has disproportionate leverage.

*Energy State calibration:* After 30+ CognitionLog entries, compare declared energy state to actual completion count. Is Reserve producing 1-2 completions or 5? Is Full producing 6-8 or 3? If the self-report is systematically miscalibrated (e.g., Reserve days consistently producing 4+ completions), the app should gently surface this: "Reserve days have been producing more than expected. The energy floor may be higher than it feels." This is not praise — it's a calibration observation. The Analytical profile will appreciate the accuracy correction.

*Recovery-behavior correlation:* Over 60-90 days, as physical mobility improves, system activation should shift. Early recovery: Health and Environment dominate (small physical actions). Mid-recovery: Cognition and Operations activate (mental work becomes possible). Late recovery: Participation activates (external engagement). If this pattern isn't occurring, that's signal. The app should be able to observe: "Health activation has been flat for 3 weeks while Cognition has grown. The cognitive recovery is outpacing physical re-engagement."

**The science foundation an agent should research:**

- Default Mode Network and INTJ creative cognition (Kaufman et al.) — INTJs show elevated DMN activity during problem-solving, which means the rest-active-rest rhythm is especially important for this profile. The app's Energy State layer and rest signals should account for the fact that "doing nothing" for an INTJ Analytical profile is often not nothing — it's processing. How should INCREMENTS account for this?

- Cognitive flexibility and Achiever profiles (research on high-need-for-achievement individuals) — Achievers are susceptible to what Heidi Grant Halvorson calls "prevention focus" during setbacks. Physical recovery is a textbook prevention-focus trigger (protecting against further loss rather than achieving gains). The app should detect this shift: if the action stack is dominated by maintenance and protective actions with no growth-oriented actions, the system may have shifted into prevention mode. How should the app recognize and gently redirect this?

- Temporal motivation theory (Piers Steel) — procrastination peaks when tasks are low urgency, low certainty, or have distant rewards. For an INTJ Creative Thinker with filmmaking goals, the most important actions (develop the visual language, study filmmakers, outline the project) are often the ones with no deadline and no immediate feedback. TMT predicts these will be systematically underweighted. The app needs to protect these actions structurally.

- Flow state prerequisites (Csikszentmihalyi) — specifically the challenge-skill balance. After 90 days, the app has enough data to detect whether actions in the Cognition domain are being consistently abandoned (too hard), consistently completed in under 5 minutes (too easy), or completing at a rate that suggests genuine engagement. This matters for filmmaking skill development specifically.

---

### Layer 4: Capability Architecture (Day 90+)
*The app develops you, not just tracks you*

This is the layer you named: not just "what did you do today" but "what are you becoming." This is the hardest layer to build without turning the app into a coaching platform (which it must never become). The distinction is:

**Coaching says:** "You should develop your storytelling skills. Here are 3 exercises."
**INCREMENTS says:** "Cognition has been active 5 of 7 days for 4 consecutive weeks. The creative thread is building."

The app observes capacity growth from behavioral evidence — it never prescribes it.

**What to build:**

**Capacity signals — observable from behavior, not self-report:**

*Cognitive endurance:* Are Cognition-domain sessions (deep work protocols) getting completed more consistently over time? Is the Morning Protocol completing earlier in the day (lower friction = higher automaticity = more capacity)? Is the "what stayed heavy" field in daily reviews getting shorter or less frequent? These are behavioral proxies for cognitive recovery and growing capacity.

*Operational clarity:* Are WorkTrack "next actions" getting more specific over time? (A vague "Define next milestone" vs a specific "Write the first 3 scenes of FORM onboarding flow" indicates operational sharpness.) Is the financial review maintenance item being completed on schedule? This is the Business Focus competency developing — currently a Supporting strength, but one that can be deliberately built.

*Participation activation:* Is the Participation system moving from consistently quiet to sporadically active to regularly active? This tracks recovery progress directly — Participation was identified in the behavioral architecture as "the whole point" — the reason the other four systems exist. Its activation pattern over time is the most meaningful single signal about whether the system is working.

*Promoter development:* Promoter is a Supporting ESF strength — one that needs to be deliberately built. The app can proxy this through WorkTrack entries: is Brice writing external communications, pitching, sharing? The Operations and Participation systems are where this shows up. What patterns in those systems suggest Promoter behavior is increasing vs contracting?

**The filmmaking dimension specifically:**

The Cognition system is where creative development lives. But the app currently has no vocabulary for distinguishing between:
- Administrative cognition (email, decisions, logistics)
- Analytical cognition (research, pattern analysis, problem diagnosis)
- Creative cognition (visual development, storytelling, worldbuilding)

For an aspiring filmmaker with INTJ + Creative Thinker + Knowledge-Seeker profile, these are critically different modes. Administrative cognition is cognitive load — it depletes. Analytical cognition can be restorative for this profile (Restorative strength activated). Creative cognition is generative but also uncertain and therefore susceptible to avoidance.

The app needs a way to recognize when Cognition actions are creative vs analytical vs administrative — even if only through user-set tags — so that the system can observe: "Creative cognition has been absent for 11 days. The administrative load is crowding it out."

**What should develop over time that the app can observe:**
- FORM project: does "next action" in WorkTrack get more specific and technical? (Coaching app development requires both Analytical and Individualization — the app can observe whether these domains are feeding the project)
- HIDEOUT project: does it appear in daily completions, or is it consistently in the backlog? (This project likely requires Participation and Relationship-Builder behaviors — Supporting ESF strengths that need deliberate attention)
- Filmmaking: does any Cognition action pattern suggest visual research, study, or creative output? This is what the system should be watching for — not the output itself, but the behavioral conditions that precede it.

---

## The Insights Tab — What It Actually Is

The Insights tab is gated at 30 days. When it appears, it should not be a dashboard. It should be a reading — a single, carefully worded observation about what the data shows, updated weekly.

**Not this:**
Charts, graphs, trend lines, completion percentages, system scores over time.

**This:**
A single paragraph. Written in the operational register. Observational, not evaluative. Specific, not generic. Honest about uncertainty.

Example at day 30:
> "Health has been the most consistent system — 18 of 30 days. Environment tends to precede it by 6–12 hours when both occur on the same day. Cognition is the quietest: 7 of 30 days. The best completion window appears to be 9–11am. Reserve energy state was declared 11 times; on 8 of those days, at least 2 actions were completed. The floor may be higher than it feels."

Example at day 60:
> "The last two weeks show a shift: Cognition has risen from 1–2 days/week to 4–5 days/week. The morning protocol appears to be the anchor — days it's completed show 3x more Cognition activity than days it isn't. The FORM work track has had a specific next action 8 of the last 14 days (up from 3 of 14 in the prior period). Operational clarity is building."

This requires a synthesis function that reads across all models and produces a single composed observation. The language model (Claude API inside the artifact, or a prompt-based synthesis) is the right tool for this — not algorithmic copy, but actual interpretation of the pattern data.

---

## The Science the App Should Know But Doesn't

These are the domains where peer-reviewed research directly applies to this profile and could meaningfully inform the intelligence layer. Agents should research each of these with specificity to INTJ/Analytical/Restorative/Achiever/Competition profiles:

**1. Identity-based habit formation (James Clear, building on Duhigg)**
The most durable behavior change happens when the behavior is tied to an identity claim rather than an outcome goal. "I am someone who moves every day" vs "I want to recover faster." For an INTJ profile with strong Individualization, the identity framing matters: how does the system reflect back an identity narrative based on what Brice actually does, not what he aspires to do?

**2. Interoceptive accuracy and decision quality (Craig, Damasio)**
INTJs are often low in interoceptive accuracy — awareness of internal body signals. This creates a specific risk during physical recovery: the cognitive signal ("I should push harder") overrides the somatic signal ("the body isn't ready"). The Energy State card is a partial intervention. But research suggests that people with low interoceptive accuracy benefit from structured somatic check-in practices that build the skill over time. What should INCREMENTS do at 90 days to support interoceptive development?

**3. Creative recovery and incubation (Dijksterhuis, unconscious thought theory)**
For creative work (filmmaking), the evidence suggests that periods of non-directed rest after an intensive creative session produce more novel output than continued directed effort. An INTJ Achiever will resist this — the internal fire will push toward continued productive activity. The app should recognize when the Cognition system shows high consecutive-day activity and gently surface the incubation opportunity without framing it as rest (which Achievers resist) — framing it as processing.

**4. Strength stacking and the dark side of strengths (Kahneman, Rath)**
Every Gallup strength has a shadow. Restorative → can create endless self-improvement projects that crowd out participation. Achiever → can produce a feeling of perpetual insufficiency even on objectively productive days. Analytical → can produce paralysis-by-analysis and prevent action during the analytical phase. Competition → can make collaboration feel like defeat. Individualization → can make systemic approaches feel like compromises. The app is well-designed to avoid activating the Competition shadow (no scores, no comparisons). But what about the others? The Restorative shadow — using the app itself as a self-improvement project rather than a life-operating tool — is the most immediate risk.

**5. Post-traumatic growth and recovery trajectories (Tedeschi & Calhoun)**
Physical recovery from significant injury (tibial fracture, post-op) often follows a non-linear trajectory where cognitive capacity and mood do not recover in sync with physical capacity. Some days physical progress is visible but motivation is low. Other days the cognitive energy is high but the body constrains action. The app needs to hold this without pathologizing the variation. The current Energy State card is a good intervention. But over time, research suggests that people who recover well are those who develop an increasingly accurate internal model of their own state. How does the app support that calibration?

---

## The Multi-Agent Research Brief

*Paste this to any agent you want to develop a specific layer. It is self-contained.*

---

```
CONTEXT: You are developing intelligence for INCREMENTS — a private iOS life-operations instrument 
built for one specific user named Brice. This is not a generic productivity app. Every decision 
must be grounded in his specific profile and current situation.

THE OPERATOR PROFILE:
- Gallup Top 5: Restorative (1), Achiever (2), Analytical (3), Individualization (4), Competition (5)
- ESF Dominant: Confidence, Risk-Taker, Delegator
- MBTI: INTJ — Introvert (67%), iNtuitive (50%), Thinking (50%), Judging (44%)
- SLOAN: SCOAI — 80% Orderliness, 80% Inquisitiveness, 70% Emotional Stability
- Current state: Physical recovery from tibial fracture (post-op, crutches)
- Work: Aspiring filmmaker. Active projects: FORM (coaching app), HIDEOUT (café/space concept)
- Operating question: "What actions will make my life more inhabitable today?"

THE APP'S PHILOSOPHY:
- Environmental cognition support system — small daily actions made visible as evidence that life 
  is improving
- Emotional register: cinematic recovery cockpit. Calm, operational, atmospheric.
- The system reports state without judging it. Never a coach. Never evaluative.
- No streaks. No praise language. No aggregate scores as hero metrics.
- No shame language. Gentle decay signals only.
- The app is a launch surface, not a destination. Max 45 seconds per feature per day.

THE FIVE SYSTEMS:
- Environment: physical space, light, order, noise — the inputs to everything else
- Cognition: deep work, decision quality, focus protection, creative output
- Health: movement (cleared by PT only), sleep, nutrition, recovery progress
- Operations: open loops, WorkTracks (FORM + HIDEOUT), financial clarity
- Participation: showing up externally — the whole point; the reason the other four exist

THE DATA THAT EXISTS:
- Action model: title, system, recurrence, completedAt, completionDates[], skipCount, isHighFriction
- Habit model: completionHistory[], cue, minimumScope
- Session model: steps[], lastCompleted (protocol completion unit)
- DailyLog: completedActionIDs[], systemsTouched[], topWin, notes (what stayed heavy), 
  specificActionNote (tomorrow's first action)
- CognitionLog: date, clarityLevel, cognitiveLoad, clarityScore (written when Energy State is set)
- HydrationLog: timestamp
- FinancialState: runwayState (stable/watch/act), nextObligationDate, inflowReceived
- MaintenanceItem: title, system, intervalDays, lastCompleted
- OperatorProfile: xp, level, weeklyActiveSystems, firstLaunchDate, lastResetDate

THE INTELLIGENCE LAYERS TO DEVELOP (pick one per agent session):

LAYER A — PATTERN RECOGNITION (Days 1–14):
Research and specify: How should the app detect and surface time-of-day completion patterns, 
day-of-week system activity maps, and Energy State calibration accuracy? What does the science 
say about ultradian rhythms and performance windows for this profile? How should patterns be 
surfaced without turning them into scores? Produce: (1) the specific algorithms for detecting 
these patterns from existing data models, (2) the copy register for surfacing them, 
(3) any new data fields needed.

LAYER B — FRICTION DIAGNOSIS (Days 14–30):
Research and specify: How should the app classify action friction as chronic vs acute vs temporal 
vs systemic? What does habit formation science say about the difference between a cue problem, a 
scope problem, and a scheduling problem — and how can these be distinguished from behavioral data 
alone? What is the Analytical profile's specific risk during friction (paralysis vs diagnosis)? 
Produce: (1) the friction classifier logic with specific thresholds, (2) the intervention 
language for each friction type (in the operational, non-coaching register), (3) how this 
surfaces in the existing SystemStatusRow or a new component.

LAYER C — ADAPTIVE INTELLIGENCE (Days 30–90):
Research and specify: What does research say about gateway behaviors — actions that reliably 
unlock other actions? How should the app detect system cascade patterns (A precedes B)? What 
does cognitive flexibility research say about INTJ Achievers in prevention-focus states during 
recovery — how does the app detect this shift and what should it do? What is the correct 
architecture for the Insights tab at day 30 — specifically, how does a language model synthesize 
behavioral data into a single weekly observation in the operational register? Produce: (1) the 
cascade detection algorithm, (2) the Insights tab specification including the synthesis prompt 
for the Claude API call, (3) the language model prompt that produces observations in the 
correct voice.

LAYER D — CAPABILITY ARCHITECTURE (Day 90+):
Research and specify: How does the app observe capability growth from behavioral evidence without 
prescribing it? What are the behavioral proxies for cognitive endurance, operational clarity, and 
creative development in a filmmaker-profile INTJ? How should the Cognition system distinguish 
between administrative, analytical, and creative cognition — what is the minimum viable data 
structure that allows this without adding significant user friction? What does temporal motivation 
theory say about protecting low-urgency high-importance creative actions from systematic 
under-weighting? Produce: (1) the data model extensions needed, (2) the Cognition sub-type 
tagging mechanism, (3) the capability growth observation language.

LAYER E — THE INSIGHTS TAB (Day 30 gate):
Research and specify: What is the correct design for a weekly behavioral intelligence report 
for an Analytical INTJ Achiever who has Competition strength? What formats and framings 
will activate Competition shadow (avoid) vs support honest self-assessment (pursue)? 
Design the full Insights tab: what it shows, in what order, with what language, and what it 
explicitly refuses to show. Include the Claude API synthesis prompt that takes the behavioral 
data and produces a single weekly observation paragraph. The observation must be specific, 
grounded in data, operationally worded, and free of evaluative framing. Produce: 
(1) full SwiftUI view specification, (2) the data synthesis function, 
(3) the Claude API prompt with example inputs and outputs.

LAYER F — RECOVERY-INTELLIGENCE INTEGRATION:
Research and specify: What does post-traumatic growth research say about the non-linear 
relationship between physical recovery and behavioral capacity? How should the app account for 
the fact that on some days physical progress is visible but motivation is low, and on others 
cognitive energy is high but the body constrains action? What should the Recovery tab surface 
beyond the current injury/mobility/cleared-movement fields? How does the app use the 
RecoveryPhase model to inform action stack composition — should Reserve Energy State and 
recovery phase interact? What does interoceptive accuracy research suggest about how to build 
the skill of internal state reading over time, and how does the Energy State card evolve to 
support this? Produce: (1) RecoveryPhase model extensions, (2) the recovery-behavior 
correlation algorithm, (3) the evolution of the Energy State card over time.

CONSTRAINTS ALL AGENTS MUST HONOR:
1. No scores displayed as hero metrics. XP is internal only.
2. No streaks in any form. No "best streak" display.
3. No praise language. Operational register only.
4. No aggregate system score as displayed metric.
5. No continuous ambient animation.
6. No spider/radar charts.
7. No AI coaching language ("I think you should..." / "Consider trying...").
8. The app reports state. It never prescribes behavior.
9. No shame language for missed actions. Gentle decay signals only.
10. 45-second maximum daily interaction per feature. If a feature takes longer, 
    redesign before building.
11. Health domain color is inkTeal (#5AB8D6), never red.
12. The visual register is: dark warm-neutral, operational, restrained. 
    Sora (UI) + DM Mono (metadata). Three-tier card hierarchy.

THE END STATE:
INCREMENTS at 12 months is a private instrument that knows Brice well enough that opening it 
every morning takes under 20 seconds to orient. It has surfaced which system is the gateway to 
his particular pattern of movement. It has diagnosed which actions were friction-constrained and 
prompted scope reduction. It has observed capability growth in the Cognition system as the 
filmmaking work deepens. It has correlated physical recovery progress with behavioral capacity. 
It has never praised him, never guilted him, never told him what to do. It has only reported 
what it observes — with enough accuracy and specificity that he has trusted it, used it, and 
grown with it.

"participation in reality"
```

---

## What the App Does Not Know About Itself Yet

These are the questions the app should eventually be able to answer from its own data. They frame the intelligence work:

**About behavior:**
- At what time of day do you actually complete actions? (Not when you plan to — when you actually do.)
- Which system, when touched first, is most predictive of a high-completion day?
- How long does it take a new action to become reliable (completion rate >70%)?
- What is your actual Reserve floor — how many actions do Reserve days actually produce?

**About friction:**
- Which actions have been on your stack for 14+ days with <30% completion?
- What do chronically skipped actions have in common? (Time? System? Scope? Cue type?)
- Are there days where everything gets skipped regardless of action? (Environmental day, not action problem)
- Do completed habits in a system reduce friction on actions in the same system?

**About capacity:**
- Is the Morning Protocol becoming more automatic over time? (Earlier completion, more consistent timing)
- Are Cognition sessions producing more completions in adjacent systems the same day?
- Is the FORM work track showing increasingly specific next actions over time?
- Is Participation being touched more frequently as recovery progresses?

**About the creative work specifically:**
- Is there any behavioral signature that precedes or follows deep creative work in Cognition?
- What conditions (Energy State, systems active, time of day) co-occur with Cognition completions?
- Is the creative thread alive or contracting? (Observable from Cognition system activity patterns)

---

## The Guardrails — Restated for Intelligence Work

The intelligence layer carries higher risks than the tracking layer because it interprets. Every interpretation can be wrong, and for an Analytical INTJ, a wrong interpretation that's stated confidently destroys more trust than saying nothing.

**The intelligence guardrails:**

**Report ranges, not certainties.** "Your best window appears to be 9–11am" not "Your peak performance window is 9–11am." The data is sparse and personal. The language must honor that.

**Name the data basis.** "Based on 23 days of completions" gives the Analytical profile the ability to assess the confidence of the observation. Don't hide the sample size.

**Never explain what the pattern means for identity.** "Health has been quiet for 11 days" is acceptable. "You may be struggling with self-care" is not. Report the data. Let Brice draw the inference.

**The Competition shadow is the biggest risk in the intelligence layer.** Any observation that could be read as a ranking, a comparison to a previous self, or a target will be optimized rather than observed. "Your completion rate was 62% this week" will be targeted at 63% next week. This is the wrong behavior. The observations must be framed as pattern readings, not performance reports.

**Observations become noise if they're always there.** A weekly observation that appears every week, on schedule, becomes wallpaper. The intelligence layer should surface observations when they are earned — when there is genuinely something new to say — not on a mechanical schedule. Silence is correct when there is no new signal.

---

*INCREMENTS Intelligence Depth Specification · Written from full behavioral science synthesis*
*"The app is a launch surface, not a destination. The life is the destination."*
