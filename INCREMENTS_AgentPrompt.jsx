import { useState } from "react";

const ACCENT = "#8A6EFF";
const SURFACE = "#161422";
const SURFACE2 = "#1C1A2A";
const BG = "#0C0B12";
const TEXT = "#F0ECFF";
const TEXT2 = "#A8A0C8";
const TEXT3 = "#6A6285";
const GREEN = "#5ACEA8";
const AMBER = "#D4933A";
const WARM = "#C8A96E";
const RED = "#D06B6B";
const VIOLET_DIM = "#4A3D88";

const PROMPTS = [
  {
    id: "master",
    label: "MASTER BRIEF",
    tag: "Drop this first — every agent",
    color: ACCENT,
    description: "Full context for any AI agent. Always send this before any specialized prompt.",
    prompt: `You are advising on the design and behavior architecture of a personal iOS app called INCREMENTS — a private life-operations instrument built on the philosophy of "participation in reality."

CORE CONCEPT: INCREMENTS converts small daily actions into visible evidence that life is improving. It is NOT a productivity app, habit tracker with streaks, or wellness dashboard. It is an environmental cognition support system — the premise being that perception is ecological and condition-shaped, and that restoring the conditions of life (environment, body, operations, cognition) is the path back to agency.

PHILOSOPHICAL FOUNDATION:
- "Action reorganizes perception" — behavior comes first, insight follows
- "A dark week is not a dark self" — state is context-dependent, not identity
- "Increments, not collapse/rebirth cycles" — sustainability over heroism
- "Maybe the organism needs restoration before interpretation" — conditions precede meaning
- The reward is not task completion. It is: "The apartment feels lighter." "Money feels less scary." "I participated today."

THE USER PROFILE (this is a personal tool — the user is the only user):
- Recovering from tibial fracture surgery, on crutches, limited mobility
- Extremely high execution when structure is coherent and next action is visible
- Tends toward postponement and degradation loops when structure collapses
- Psychological strengths: Restorative, Achiever, Analytical, Discipline, Focus, Strategic
- Atmosphere-sensitive: light, order, and environment materially affect cognition and output
- Has a history of heroic intensity / collapse cycles — the app is designed to interrupt this pattern
- Values: elegant intelligence, operational precision, calm futurism, visible evidence

5 LIFE SYSTEMS TRACKED:
1. Environment — room order, light, air, noise, temperature
2. Cognition — clarity, mental load, noise, focus windows
3. Health — movement (within surgical clearance), hydration, food, sleep
4. Operations — money, admin, work threads (3 active: FORM coaching app, Hideout café, RunCards running club tool)
5. Participation — showing up, not postponing, daily engagement with life

CURRENT BUILD (Phase 1 MVP — SwiftUI + SwiftData, iOS 17, local only):
- Home (Operator Dashboard with score + system status)
- Today (daily action stack, tap-to-complete)
- Increments (system view, 5 domains with scores)
- Habits (7-day dot visualization, recurring anchors)
- Daily Review (3-question close-the-loop sheet)

HARD GUARDRAILS THE APP MUST NEVER VIOLATE:
- No streak shaming or guilt-based mechanics
- No harsh penalties for inactivity — gentle decay only
- Max 4 notifications per day
- No "you failed" language ever
- If the app creates pressure, something has gone wrong — reduce scope
- The voice is direct and calm: "Open the blinds." "One action now." — never "Crush your goals!"

Your job is to push this concept further using science, psychology, and design thinking. Assume the user is sophisticated and has thought carefully about this — your value is in depth, specificity, and honest challenge, not validation.`
  },
  {
    id: "sequencing",
    label: "SEQUENCING & TIMING",
    tag: "Habit science + circadian",
    color: GREEN,
    description: "The science of what to do when. Circadian rhythms, implementation intentions, habit stacking, the right order of operations for this specific profile.",
    prompt: `Building on the INCREMENTS context above:

FOCUS: Behavioral sequencing — what to do, when, and in what order — using the best available science.

Please address:

1. CIRCADIAN ARCHITECTURE
The user's life systems (Environment, Cognition, Health, Operations, Participation) each have different optimal activation windows based on cortisol rhythms, decision fatigue, and ultradian cycles. Given that this user is post-surgery (limited mobility, crutches, disrupted sleep patterns likely), map out an evidence-based daily sequence that:
- Frontloads low-friction environment/body actions in the first 90 minutes
- Protects the best cognitive window for deep work (Operations)
- Places money/admin touches during moderate energy (not peak, not depleted)
- Uses evening for consolidation, not ambition
Be specific about timing windows, not vague categories.

2. HABIT STACKING OPPORTUNITIES
The app has 8 default habits: Morning Routine, Deep Work, Movement, No Phone First Hour, Night Routine, Money Touch, Apartment Reset. Using implementation intention theory ("When X, then Y"), what are the 5 highest-leverage habit stacks for this specific user profile? Prioritize stacks that work during a recovery phase with limited mobility.

3. THE "2-MINUTE RULE" PROBLEM
The user has a pattern of postponement that escalates when friction compounds. Design a specific sequencing protocol for the app's Today view that uses the psychology of "behavioral momentum" — small wins early that make larger actions feel accessible. What specific sequence of action types (by system category and effort level) would create the strongest momentum cascade for this user?

4. RECOVERY-PHASE SEQUENCING
Post-surgery means the normal movement anchors (morning run, gym) are gone. What replacement anchors from behavioral science — specifically for body-limited states — create the same neuroregulatory effects? What should replace "Move your body" in the daily sequence when movement is medically constrained?

5. THE WEEKLY RESET
The app awards 50 XP for a Weekly Reset. Design the optimal sequence and timing for this ritual based on what cognitive science tells us about consolidation, prospective memory, and restoration. What day? What time? What exact order of the 5 systems?

Be specific, cite mechanisms not just findings, and challenge anything in the current design that contradicts the science.`
  },
  {
    id: "habitforming",
    label: "HABIT FORMATION",
    tag: "Loops, identity, consolidation",
    color: WARM,
    description: "How to make these actions actually stick. The neuroscience of habit formation, identity-based change, and what makes INCREMENTS' approach uniquely effective or potentially flawed.",
    prompt: `Building on the INCREMENTS context above:

FOCUS: The actual neuroscience and psychology of habit formation — what works, what doesn't, and where INCREMENTS' current design is strong or vulnerable.

Please address:

1. THE IDENTITY ARCHITECTURE PROBLEM
James Clear argues habits form best when they're identity-based ("I am someone who...") rather than outcome-based. But INCREMENTS explicitly rejects the motivational framing ("I'm becoming my best self") in favor of operational framing ("action reorganizes perception"). Evaluate this tension:
- Is the operational framing actually MORE effective for this psychological profile (Restorative, Achiever, Analytical)? Or is it avoiding something necessary?
- How does the "Operator Level" progression system interact with identity formation? Is "Apprentice Operator" a meaningful identity anchor or a gamification layer that the user will eventually see through?
- Design a specific modification to the app that captures identity formation benefits WITHOUT adding motivational language.

2. THE CUES PROBLEM
The app has 5 life systems but the current default actions don't have explicit environmental cues designed in. Using BJ Fogg's Tiny Habits model, evaluate the cue architecture:
- Which of the 8 default habits have strong natural cues and which are floating (no reliable trigger)?
- The user is on crutches — how does this change the physical environment as a cue landscape? What new cues exist that didn't before?
- Design 3 specific cue-behavior-reward sequences optimized for the recovery phase.

3. THE CONSOLIDATION WINDOW
Research on habit consolidation (Lally et al.) suggests 18-254 days for automaticity, with a median around 66 days. The app's Phase 1 success condition is 14 days of daily use. Is 14 days enough to establish anything durable, or is it just building familiarity with the interface? What should happen at day 14, 30, 66, and 90 to maximize consolidation? Design specific in-app moments for each milestone.

4. THE PLATEAU PROBLEM
Habit apps often see a cliff at day 21-30 when novelty fades and the behavior hasn't yet automated. How should INCREMENTS be designed to handle this plateau? What specific features or prompts — consistent with the app's no-pressure philosophy — prevent this drop-off?

5. VARIABLE REWARD ARCHITECTURE
The current XP system is fixed (5/10/20/50 points by action type). Variable reward schedules (Skinner) create stronger habit loops than fixed ones. But the app explicitly rejects "gamified dopamine loops." Where is the line between good variable reward design and the dopamine manipulation the app is trying to avoid? Design a specific reward mechanism that uses variability ethically.

6. WHAT THIS APP DOES THAT NO OTHER HABIT APP DOES
Based on your analysis, what is the single most psychologically distinctive thing about INCREMENTS' approach? And what is the single greatest vulnerability in the habit-formation logic?`
  },
  {
    id: "frictiondesign",
    label: "FRICTION DESIGN",
    tag: "When easy is wrong",
    color: AMBER,
    description: "Where to reduce friction (obvious) and where strategic friction actually protects the system. The counterintuitive design moves.",
    prompt: `Building on the INCREMENTS context above:

FOCUS: Friction architecture — the deliberate placement of ease and resistance in the behavior design.

Please address:

1. WHERE CURRENT FRICTION IS WRONG
The app correctly reduces friction for daily actions (tap-to-complete, default action stack, atmospheric design). But some of this friction reduction may be counterproductive. Specifically:
- The Daily Review sheet has a "Skip" button. Based on research on commitment devices and implementation intentions, should skipping be this easy? What happens psychologically when escape is always one tap away?
- The "Add Increment" flow lets users add any action at any time. Does unlimited customization actually reduce or increase the cognitive load that causes postponement?
- The system scores decay "gently" when ignored. Is gentle enough? What does the research say about feedback delay in behavior change — when is soft feedback better than sharp?

2. STRATEGIC FRICTION PLACEMENT
Friction isn't always the enemy. Design 3 specific places where the app should ADD friction to protect the system's integrity:
- What should require deliberate effort (not just a tap)?
- Where should the app slow the user down to force intention rather than enable impulsivity?
- How does friction interact with the "no pressure" guardrail — can you add protective friction without creating anxiety?

3. THE ENVIRONMENT-BEHAVIOR LOOP
The app tracks Environment as a system score, but doesn't yet fully leverage environment as a behavior change tool. Using research on environmental design (nudge theory, choice architecture), what physical environment modifications should the app suggest — specific to someone who is homebound and on crutches — that would make the target behaviors more automatic?

4. FRICTION IN RECOVERY CONTEXT
A person on crutches has profoundly altered friction topography. Movements that were automatic (walking to kitchen = hydration cue) now require effort. How should the app account for this shifted friction landscape? Design a "recovery friction map" — a list of behaviors where crutch-based mobility changes the friction calculus, and how the app should respond.

5. THE POSTPONEMENT LOOP
The user has an identified pattern: postponement that compounds. Using ACT (Acceptance and Commitment Therapy) and behavioral activation research, design a specific in-app intervention for the moment when postponement begins — not a notification, not a streak reminder, but an architectural element in the app itself that interrupts the loop without creating shame. What does it look like? Where does it live in the current screen structure?`
  },
  {
    id: "measurement",
    label: "MEASUREMENT & FEEDBACK",
    tag: "What to track and how",
    color: "#B09AFF",
    description: "The science of self-monitoring, feedback loops, and which metrics actually predict behavior change vs. which ones are vanity metrics that create pressure.",
    prompt: `Building on the INCREMENTS context above:

FOCUS: What to measure, how to feed it back, and the psychology of self-monitoring.

Please address:

1. THE GOODHART'S LAW PROBLEM
"When a measure becomes a target, it ceases to be a good measure." The app tracks Operator Score (0-1000), 5 System Scores (0-100), XP, and Level. Which of these are at risk of becoming targets that distort the underlying behavior? Specifically:
- What happens when the user optimizes for System Score rather than actual restoration?
- Is the Operator Score psychologically useful or does it reduce 5 complex life domains to a number that creates simplistic feedback?
- Design a measurement approach that captures meaningful signal without creating gaming incentives.

2. LEADING VS LAGGING INDICATORS
Current metrics are mostly lagging (completion counts, scores based on past 7 days). What leading indicators — signals that predict good days before they happen — should the app track? For this specific user profile, what are the 3-5 best predictive signals for "today will be a high-participation day"?

3. THE SELF-REPORT PROBLEM
The Daily Review asks 3 questions (what improved my state, what did I postpone, what needs one small action tomorrow). Research on self-report accuracy, memory bias, and end-of-day emotional state suggests significant reliability problems. How should the app design around these limitations? Is end-of-day self-report the right time? What questions actually produce accurate, useful data vs. retrospective rationalization?

4. FEEDBACK TIMING
The app gives immediate visual feedback (green glow, haptic) on action completion. Research distinguishes between immediate reinforcement (dopamine hit) and delayed reflective feedback (meaning-making). The app currently does the first but not the second. Design a feedback timing architecture that:
- Preserves the immediate completion satisfaction
- Adds a delayed (hours later, or next morning) feedback moment that's meaningful, not addictive
- Doesn't require more than 2 taps from the user

5. WHAT NOT TO MEASURE
The app's design philosophy is "no self-quantification hell." Based on research on over-monitoring, self-consciousness effects, and the ironic effects of self-regulation, what should INCREMENTS explicitly refuse to track — even if it could? What data would be technically available but psychologically harmful to surface?

6. THE TIMELINE SCREEN
The app plans a Timeline view (Phase 2) — a vertical log of completed actions with timestamps. Research on narrative self-understanding and "small wins" theory (Amabile & Kramer) strongly supports this kind of evidence accumulation. Design the specific psychological mechanism this screen should exploit — not just "you can see your history" but the precise cognitive effect that makes looking at your own timeline emotionally meaningful.`
  },
  {
    id: "environment",
    label: "ENVIRONMENT SCIENCE",
    tag: "Room affects cognition",
    color: GREEN,
    description: "The ecological psychology underpinning the app's core premise. What the science actually says about environment and cognition, and how to operationalize it.",
    prompt: `Building on the INCREMENTS context above:

FOCUS: The environmental cognition premise — the claim that "perception is ecological and condition-shaped" and that restoring the environment restores the person.

Please address:

1. THE SCIENCE BEHIND THE CLAIM
The app is built on the premise (from ecological psychology, James Gibson's affordance theory, and environmental neuroscience) that environment shapes cognition and action. Evaluate this premise rigorously:
- What does the research actually show about environment → cognition pathways? Where is the evidence strong and where is it overstated?
- Specifically: light quality, room order, air quality, noise — for each, what is the actual effect size on cognition and mood? Is "open the blinds" a genuine intervention or a ritual?
- What is the mechanism? Is it attention restoration (Kaplan), stress physiology (cortisol), or something else?

2. OPERATIONALIZING THE ENVIRONMENT SYSTEM
The app's Environment system score tracks Light, Temperature, Air Quality, Noise, and Order. For someone homebound and on crutches, design the minimum viable environment protocol that would produce the largest measurable improvement in cognitive state:
- Which of the 5 sub-indicators has the highest effect size for homebound recovery states?
- What specific actions (that are crutch-accessible) create the most improvement per unit of effort?
- What is the sequence — in what order should environment interventions happen in the morning?

3. THE ROOM RESET RITUAL
"Apartment reset — one area" is a default action. Research on cognitive offloading, the "extended mind" thesis, and the psychology of physical order suggests that a tidy environment literally reduces cognitive load (the brain stops processing disorder as a background task). Design a specific "minimum viable reset" protocol for someone on crutches — what 3 actions, in 10 minutes, produce the greatest environmental signal for the brain?

4. SENSORY STACK
Beyond visual order, what is the optimal sensory environment for a recovery + deep work state? Address:
- Acoustic: silence vs. background noise vs. specific frequency ranges (brown noise, binaural beats) — what does the research actually support?
- Thermal: what temperature range is associated with best cognitive performance?
- Olfactory: is there evidence for scent-based state change beyond anecdote?
- Light: what is the evidence for specific lighting conditions (color temperature, lux levels) on mood and focus?
Design a "sensory protocol" the app could suggest at day start.

5. THE PARADOX OF CONTROL
The app emphasizes environment as a restoration tool. But research on perceived control and recovery states suggests that the ability to improve one's environment is itself a psychological intervention — it's not just the environment change but the agency enacted. How should the app design around this? Is the "Room Score" metric helping or undermining perceived agency? How do you measure environmental restoration in a way that reinforces rather than tracks?`
  },
  {
    id: "recovery",
    label: "RECOVERY PSYCHOLOGY",
    tag: "Post-surgery + mental states",
    color: RED,
    description: "What the research says about behavior change during physical recovery, and how INCREMENTS should specifically adapt its approach for this context.",
    prompt: `Building on the INCREMENTS context above:

FOCUS: The specific psychology of behavior maintenance and change during physical recovery from surgery — and what this means for INCREMENTS' design.

Please address:

1. THE RECOVERY STATE AS A DESIGN CONSTRAINT
Post-surgical recovery is characterized by: disrupted sleep, elevated pain (even mild), restricted mobility, altered identity (especially for someone who was previously active), potential depressive affect, and a compressed life radius. Research on behavior change during illness and recovery states shows significant differences from baseline:
- What happens to motivation, decision-making capacity, and executive function during physical recovery?
- How should the cognitive load of INCREMENTS' system be calibrated for recovery-phase use vs. full-capacity use?
- Where does the current design assume baseline capacity that may not be available?

2. THE IDENTITY DISRUPTION PROBLEM
A runner on crutches has had a core identity anchor removed. Research on identity-based behavior change and "behavioral voids" suggests this creates vulnerability — habits built around "I am someone who moves" are disrupted, and the vacuum is often filled by degradation behaviors (inactivity, avoidance, screen time, rumination). How should INCREMENTS specifically address this:
- What replacement identity anchors are available during recovery?
- How does the "Operator" framing help or hinder recovery-phase identity maintenance?
- Design a specific onboarding/phase-setting flow for when the user enters a recovery phase.

3. DEPRESSION PREVENTION VS. TREATMENT
The app is not a therapy app (explicitly stated in the spec). But it is designed to prevent the cognitive/emotional degradation that often accompanies injury and restricted mobility. Research on behavioral activation (a core component of CBT for depression) shows that scheduling and completing small pleasurable/meaningful activities is one of the most evidence-based interventions for preventing depressive episodes. How close is INCREMENTS to a behavioral activation protocol? What elements of behavioral activation should be quietly incorporated without making the app clinical?

4. ENERGY MANAGEMENT IN RECOVERY
Post-surgical fatigue is real and often underestimated. Research on "energy envelope theory" (used in chronic fatigue research) suggests that staying within one's energy envelope — not pushing beyond available energy — is critical for recovery speed. How should the app's daily action stack adapt to energy availability? Design a simple "energy state" input (not a mood tracker — something faster and more operational) that adjusts the day's recommended actions in real time.

5. THE SURGEON/PT GUARDRAIL
The app correctly includes medical guardrails ("cleared movement only"). But behavior change research suggests that absolute prohibitions without positive replacements create psychological reactance. What specific alternative movements and body-based actions can fill the behavioral space previously occupied by running — that are (a) safe for tibial fracture recovery, (b) neurologically activating enough to provide the regulatory benefits of exercise, and (c) appropriate for home + crutches? Be specific.

6. RESTORATION THEORY
Attention Restoration Theory (Kaplan & Kaplan) and Stress Recovery Theory (Ulrich) both address how environments and activities support recovery from mental fatigue and stress. What specific design elements should INCREMENTS incorporate — drawing from these theories — to support genuine psychological restoration rather than just task completion?`
  },
  {
    id: "phase2",
    label: "PHASE 2 DESIGN",
    tag: "What to build next",
    color: WARM,
    description: "Evidence-based recommendations for what to add in Phase 2, prioritized by psychological impact not feature appeal.",
    prompt: `Building on the INCREMENTS context above:

FOCUS: Phase 2 design decisions — what to build next and why, grounded in behavioral science rather than feature appeal.

Current Phase 2 candidates (from the spec): Focus Mode (deep work timer), Timeline (visual proof log), Overview Dashboard (life systems balance, spider chart), Cognition detail screen, Notification personalization, Richer habit visualizations, Insights tab.

Please address:

1. PRIORITIZATION BY PSYCHOLOGICAL IMPACT
Rank the Phase 2 features by expected behavior change impact, not by technical interest or visual appeal. For each feature, evaluate:
- What specific psychological mechanism does it target?
- What evidence supports that mechanism?
- What is the risk of it becoming another thing to manage rather than something that supports management?

2. THE TIMELINE SCREEN — DESIGN BRIEF
Research on "small wins" (Amabile & Kramer, The Progress Principle), narrative self-understanding, and autobiographical memory strongly supports a visible evidence log. But execution matters enormously. Design the Timeline screen in detail:
- What granularity of information? (Too much = noise, too little = meaningless)
- What temporal framing? (Today only? 7 days? Scrollable history?)
- What is the emotional trigger the screen is designed to activate? Design every element to serve that specific trigger.
- What would make someone want to look at this screen when they feel worst — which is when it matters most?

3. THE INSIGHTS TAB — HONEST ASSESSMENT
The Insights tab (patterns, best performance windows) requires significant data accumulation to be useful. What is the minimum data threshold before insights are meaningful vs. noise? Research on n=1 self-tracking suggests most personal data patterns require 30+ data points to be reliable. What should the app show before it has enough data? What insights are reliable at low data volumes?

4. FOCUS MODE — EVIDENCE BASE
The planned Focus Mode is a deep work timer. Research on deep work (Newport), flow states (Csikszentmihalyi), and Pomodoro timing suggests specific design parameters. What does the evidence say about:
- Optimal session length for this user profile (Analytical, Achiever, post-surgery = potentially lower sustained focus capacity)
- Transition rituals that reliably enter focused states
- How to exit a focus session in a way that doesn't spike cortisol or create rebound distraction

5. WHAT'S MISSING FROM BOTH PHASES
Given everything you know about this user profile and the behavioral science, what important feature or design element is NOT in either phase that would significantly improve habit formation and life quality? Propose it and justify it.

6. THE 14-DAY GATE
The Phase 1 success condition is 14 days of daily use. Design what specifically should happen at day 14 — not just "decide on Phase 2" but a specific in-app moment that acknowledges the milestone, reinforces the identity being built, and sets up Phase 2 readiness without creating pressure.`
  }
];

export default function IncrementsPROMPT() {
  const [selected, setSelected] = useState("master");
  const [copied, setCopied] = useState(false);

  const current = PROMPTS.find(p => p.id === selected);

  const handleCopy = () => {
    const masterPrompt = PROMPTS.find(p => p.id === "master").prompt;
    const fullPrompt = selected === "master"
      ? current.prompt
      : masterPrompt + "\n\n---\n\n" + current.prompt;

    navigator.clipboard.writeText(fullPrompt).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2200);
    });
  };

  return (
    <div style={{
      background: BG,
      minHeight: "100vh",
      fontFamily: "'DM Mono', 'Courier New', monospace",
      color: TEXT,
      padding: "0 0 60px 0"
    }}>
      {/* Header */}
      <div style={{
        padding: "32px 28px 24px",
        borderBottom: `1px solid rgba(138,110,255,0.15)`
      }}>
        <div style={{ fontSize: 10, letterSpacing: "3px", color: ACCENT, marginBottom: 8, fontFamily: "'DM Mono', monospace" }}>
          INCREMENTS · AGENT PROMPT TOOLKIT
        </div>
        <div style={{ fontSize: 22, fontFamily: "'Sora', sans-serif", fontWeight: 600, color: TEXT, marginBottom: 6 }}>
          Multi-Agent Brief
        </div>
        <div style={{ fontSize: 13, color: TEXT3, fontFamily: "'Sora', sans-serif", fontWeight: 300 }}>
          7 specialized prompts · behavioral science · habit architecture · recovery psychology
        </div>
      </div>

      {/* Instructions */}
      <div style={{
        margin: "20px 28px 0",
        padding: "16px 18px",
        background: `rgba(138,110,255,0.07)`,
        border: `1px solid rgba(138,110,255,0.2)`,
        borderRadius: 10,
        fontSize: 12,
        color: TEXT2,
        lineHeight: 1.7,
        fontFamily: "'Sora', sans-serif",
        fontWeight: 300
      }}>
        <span style={{ color: ACCENT, fontFamily: "'DM Mono', monospace", fontSize: 10, letterSpacing: "1.5px" }}>HOW TO USE · </span>
        Start with <strong style={{ color: TEXT, fontWeight: 500 }}>Master Brief</strong> — paste it to any agent first. Then pick a specialized prompt and paste that as a follow-up. Each copy button auto-prepends the Master Brief so every agent has full context. Run the same specialized prompt across Claude, GPT-4, and Gemini for different angles.
      </div>

      {/* Prompt selector */}
      <div style={{ padding: "24px 28px 0" }}>
        <div style={{ fontSize: 10, letterSpacing: "2px", color: TEXT3, marginBottom: 14 }}>SELECT PROMPT</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {PROMPTS.map(p => (
            <button
              key={p.id}
              onClick={() => setSelected(p.id)}
              style={{
                background: selected === p.id ? SURFACE : "transparent",
                border: selected === p.id
                  ? `1px solid ${p.color}40`
                  : `1px solid rgba(74,68,104,0.5)`,
                borderRadius: 10,
                padding: "12px 16px",
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                gap: 12,
                textAlign: "left",
                transition: "all 0.15s ease",
                boxShadow: selected === p.id ? `0 0 20px ${p.color}12` : "none"
              }}
            >
              <div style={{
                width: 8,
                height: 8,
                borderRadius: "50%",
                background: p.color,
                flexShrink: 0,
                opacity: selected === p.id ? 1 : 0.4
              }} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 10, flexWrap: "wrap" }}>
                  <span style={{
                    fontSize: 11,
                    letterSpacing: "1.5px",
                    color: selected === p.id ? p.color : TEXT3,
                    fontFamily: "'DM Mono', monospace"
                  }}>
                    {p.label}
                  </span>
                  <span style={{
                    fontSize: 10,
                    color: TEXT3,
                    background: "rgba(74,68,104,0.4)",
                    padding: "2px 8px",
                    borderRadius: 4,
                    letterSpacing: "0.5px"
                  }}>
                    {p.tag}
                  </span>
                </div>
                <div style={{
                  fontSize: 12,
                  color: selected === p.id ? TEXT2 : TEXT3,
                  marginTop: 3,
                  fontFamily: "'Sora', sans-serif",
                  fontWeight: 300,
                  lineHeight: 1.4
                }}>
                  {p.description}
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Prompt display */}
      {current && (
        <div style={{ padding: "28px 28px 0" }}>
          <div style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: 14
          }}>
            <div>
              <div style={{
                fontSize: 11,
                letterSpacing: "2px",
                color: current.color,
                fontFamily: "'DM Mono', monospace"
              }}>
                {current.label}
              </div>
              {selected !== "master" && (
                <div style={{ fontSize: 10, color: TEXT3, marginTop: 3, fontFamily: "'Sora', sans-serif" }}>
                  ↑ Master Brief auto-included when you copy
                </div>
              )}
            </div>
            <button
              onClick={handleCopy}
              style={{
                background: copied ? `rgba(90,206,168,0.15)` : `rgba(138,110,255,0.15)`,
                border: `1px solid ${copied ? GREEN + "40" : ACCENT + "40"}`,
                borderRadius: 8,
                padding: "8px 16px",
                cursor: "pointer",
                color: copied ? GREEN : ACCENT,
                fontSize: 11,
                fontFamily: "'DM Mono', monospace",
                letterSpacing: "1px",
                transition: "all 0.2s ease",
                display: "flex",
                alignItems: "center",
                gap: 7
              }}
            >
              {copied ? "✓ COPIED" : "COPY PROMPT"}
            </button>
          </div>

          <div style={{
            background: SURFACE,
            border: `1px solid rgba(74,68,104,0.5)`,
            borderRadius: 12,
            padding: "20px 22px",
            maxHeight: 480,
            overflowY: "auto",
            fontSize: 12,
            lineHeight: 1.75,
            color: TEXT2,
            fontFamily: "'Sora', sans-serif",
            fontWeight: 300,
            whiteSpace: "pre-wrap",
            letterSpacing: "0.01em"
          }}>
            {current.prompt}
          </div>
        </div>
      )}

      {/* Agent deployment guide */}
      <div style={{ padding: "28px 28px 0" }}>
        <div style={{ fontSize: 10, letterSpacing: "2px", color: TEXT3, marginBottom: 14 }}>
          DEPLOYMENT GUIDE
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
          {[
            { agent: "Claude Sonnet/Opus", best: "Sequencing, Habit Formation, Phase 2", color: ACCENT },
            { agent: "GPT-4o", best: "Recovery Psychology, Measurement", color: WARM },
            { agent: "Gemini 1.5 Pro", best: "Environment Science, Friction Design", color: GREEN },
            { agent: "Run same prompt ×2", best: "Compare divergent answers — keep disagreements", color: TEXT3 }
          ].map((item, i) => (
            <div key={i} style={{
              background: SURFACE2,
              border: "1px solid rgba(74,68,104,0.4)",
              borderRadius: 10,
              padding: "14px 16px"
            }}>
              <div style={{
                fontSize: 10,
                letterSpacing: "1.5px",
                color: item.color,
                fontFamily: "'DM Mono', monospace",
                marginBottom: 6
              }}>
                {item.agent}
              </div>
              <div style={{
                fontSize: 11,
                color: TEXT3,
                fontFamily: "'Sora', sans-serif",
                fontWeight: 300,
                lineHeight: 1.5
              }}>
                {item.best}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Footer doctrine */}
      <div style={{
        margin: "32px 28px 0",
        textAlign: "center",
        fontSize: 11,
        color: TEXT3,
        fontFamily: "'Sora', sans-serif",
        fontWeight: 300,
        fontStyle: "italic",
        letterSpacing: "0.02em"
      }}>
        participation in reality
      </div>
    </div>
  );
}
