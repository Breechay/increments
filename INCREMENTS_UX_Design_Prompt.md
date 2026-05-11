# INCREMENTS — UX/UI Design Analysis Prompt
## Self-Sustaining Multi-Agent Query Document
*Use this prompt verbatim with any AI agent. It contains everything the agent needs. No context is required beyond this document.*

---

## WHO YOU ARE TALKING TO

You are a UX/UI design consultant with deep knowledge of:
- Perceptual psychology and visual cognition
- Affective computing and emotional design
- Typography and readability science
- Dark mode interface physiology
- Color theory grounded in neuroscience (not aesthetics taste)
- Mobile interaction design and touch ergonomics
- Flow state and cognitive load theory
- The intersection of behavioral science and visual design

You are NOT being asked to evaluate aesthetic preference. You are being asked to evaluate whether the visual design of this system supports or undermines its documented psychological goals. Every recommendation must be grounded in mechanism — why it works, not just what it looks like.

---

## THE SYSTEM: INCREMENTS

INCREMENTS is a private iOS app described as an "environmental cognition support system." It is not a productivity app. It is a behavioral reintegration tool for a specific user profile.

### The User Profile (Brice Ikouebe)

**Gallup StrengthsFinder Top 5 (ranked):**
1. Restorative — energized by diagnosing and fixing problems
2. Achiever — internal drive, must produce daily to feel functional
3. Analytical — data-first, skeptical, requires evidence not inspiration
4. Individualization — keen observer of unique qualities, systems-aware
5. Competition — progress measured by comparison, responds to metrics

**Gallup Entrepreneurial StrengthsFinder Dominant Talents:**
- Confidence, Risk-Taker, Delegator

**Personality Type:** INTJ (SCOAI variant)
- 67% Introversion, 50% Intuition, 50% Thinking, 44% Judging
- Traits: analytical, self-directed, systems-oriented, decisive, high standards, responds poorly to emotional pressure or vague motivation

**What this profile needs from a visual interface:**
- Precision — vagueness reads as untrustworthiness
- Calm authority — not motivational, not clinical, not sterile
- Evidence not encouragement — data over praise
- Low ambient stimulation — easily overstimulated by visual noise
- Operational register — the world of instruments, not wellness apps
- No performative positivity — no confetti, no streak celebrations, nothing saccharine

**What this profile is especially vulnerable to:**
- Goodhart's Law — optimizing the metric instead of the underlying behavior
- Analytical paralysis — architecting the system instead of using it
- High-motivation design sessions creating fantasy structure that fails at low energy
- Shame spirals from punitive visual language (red, warnings, failure framing)

---

## THE SYSTEM ARCHITECTURE

The app has 5 tabs: **Home, Today, Increments, Habits, You**

### Tab: Home
- Morning evidence card (shows yesterday's completion in one sentence)
- 5-dot system activity row (one dot per life system, colored if active, hollow if quiet)
- 7-day momentum line (de-emphasized)
- One Door interrupt card (surfaces lowest-XP uncompleted action after noon if nothing completed)

### Tab: Today
- Energy state selector (Full / Partial / Reserve) — operational language, not mood language
- Today's action stack (capped at 8)
- Each action: title, system tag, optional cue line in mono, completion tap
- Daily Review ritual (end of day): 3 questions + minimal text fields

### Tab: Increments
- 5 life systems: Environment, Cognition, Health, Operations, Participation
- Per system: current score (0-100), 7-day trend, quiet signal after 3 days inactive
- No aggregate score visible

### Tab: Habits
- Recurring habits with 7-dot completion trail
- Each habit requires: title, system, cue trigger, minimum scope definition

### Tab: You (Settings + Identity)
- Operator Profile: level, phase label, XP
- Phase label editable — identity marker, not a game mechanic
- Notification controls
- Guardrails visible as permanent reminders

### Milestone Moments (Non-tab events)
- Day 14: Calibration review — "The system has been running. Time to look at what it learned."
- Day 30: First pattern surface — quiet, factual
- Day 66: Automaticity audit — app suggests retiring scaffolding the user no longer needs
- Day 90: Phase recognition — user documents what has changed

---

## THE EXISTING DESIGN LANGUAGE

**Color System:**
```
Background:    #0C0B12  (bgBase — near-black with blue undertone)
Surface:       #161422  (card background)
Surface2:      #1C1A2A  (secondary surface, segment controls)
Violet:        #8A6EFF  (primary accent — active states, primary actions)
VioletLight:   #B09AFF  (tab labels, light emphasis)
VioletDim:     #4A3D88  (muted violet, backgrounds)
Warm:          #C8A96E  (Operations system, secondary warmth)
WarmLight:     #E8C98E  (lighter warm)
InkGreen:      #5ACEA8  (Environment system, positive/complete states)
InkRed:        #D06B6B  (Health system — NOT used for errors/failure)
InkAmber:      #D4933A  (Participation system, decay signals)
TextPrimary:   #F0ECFF  (warm white with violet undertone)
TextSecond:    #A8A0C8  (secondary text)
TextMuted:     #6A6285  (labels, system tags, timestamps)
Muted:         #4A4468  (decorative elements, dividers)
```

**System Colors (each life domain has a dedicated color):**
- Environment → InkGreen (#5ACEA8)
- Cognition → VioletLight (#B09AFF)
- Health → InkRed (#D06B6B)
- Operations → Warm (#C8A96E)
- Participation → InkAmber (#D4933A)

**Typography:**
- `Sora` — humanist sans-serif, used for body text, action titles, primary content
- `DM Mono` — monospace, used for system tags, labels, timestamps, scores, metadata

**Type Scale (approximate):**
- System tag labels: Mono 9-11pt, tracked +1-2
- Action titles: Sora 15pt
- Body / review text: Sora 13-14pt
- Scores / data: Mono 14-18pt
- Hero numbers: Mono 24-32pt

**Visual Elements:**
- Cards: RoundedRectangle, cornerRadius 12-16, Surface fill
- Completion states: Green glow, haptic feedback
- Tab bar: ultraThinMaterial background, 2px gradient top indicator on selected tab
- Violet → VioletLight gradient on primary action buttons

**Voice / Copy Style:**
- Operational, not motivational
- Ecological, not moral
- Factual state reports: "This system has been quiet for 3 days." (not "You're falling behind")
- Completion language: "Re-entry complete." (not "You're back on track!")
- The phrase: "participation in reality" (app's core thesis)

**Design Guardrails (documented):**
- No streak shaming. No failure language.
- No notifications that generate guilt.
- Gentle decay only — never harsh penalties.
- If the app creates pressure, the user should remove items.

---

## THE CORE DESIGN TENSION

The app must be visually compelling enough to open daily — but not so stimulating that it activates the dopamine-seeking behavior it's designed to interrupt.

It must look serious and trustworthy to an Analytical/INTJ profile — but feel inhabitable, not clinical.

It must communicate progress — but not in ways that are gameable or that generate shame when stalled.

It must feel like a precision instrument — not a wellness app, not a game, not a corporate tool.

---

## YOUR TASK

Analyze the visual design of INCREMENTS through the lens of perceptual and cognitive science. Your analysis should address the following questions. Answer each in sequence. Be specific. Cite mechanisms, not preferences.

---

### SECTION 1 — COLOR PSYCHOLOGY & PHYSIOLOGICAL IMPACT

1. **Dark mode physiology:** The background is #0C0B12 — near-black with a blue undertone. Evaluate this choice. What does science say about very dark backgrounds with cool undertones vs. neutral dark vs. warm dark for sustained daily use? Are there documented effects on melatonin, cortisol, or arousal that are relevant to a system designed for morning and evening use?

2. **The violet primary accent (#8A6EFF):** Violet sits at the edge of visible spectrum. What are the documented perceptual and psychological effects of violet-spectrum hues as interface primary colors? Does this choice support or undermine the "precision instrument" aesthetic? Is there a risk of it reading as "wellness app" or "spiritual" rather than operational?

3. **System color semantics:** Health is assigned InkRed (#D06B6B). In standard visual language, red means danger/failure. This system uses it for a life domain, not for errors. Evaluate the risk of this assignment. Does the research on learned color-meaning associations suggest the user's nervous system will respond to Health actions with a threat signal? Is there a better assignment?

4. **Color for decay and warning:** The system uses InkAmber for Participation AND for decay signals ("quiet for 3 days"). Evaluate the double-use of a single color for both a system identity and a warning state. Does this create semantic confusion? What does cognitive load theory say about color overloading?

5. **Warm white text (#F0ECFF with violet undertone):** The primary text color has a violet tint. Evaluate this for readability on the dark background. Is the cool-on-cool combination supported by readability research? What contrast ratio does this achieve and is it sufficient for mobile OLED displays?

---

### SECTION 2 — TYPOGRAPHY SCIENCE

6. **Sora + DM Mono dual-type system:** The app uses a humanist sans (Sora) for content and a monospace (DM Mono) for metadata and system labels. Evaluate this pairing. What does typography research say about the cognitive role of monospace type in building an "instrument" aesthetic? Does this pairing serve the Analytical/INTJ profile?

7. **Type hierarchy for action items:** Actions appear as Sora 15pt titles with DM Mono 9-11pt system tags below. Evaluate whether this hierarchy supports rapid scanning for a high-frequency daily interaction. What does F-pattern and Z-pattern eye-tracking research say about mobile list scanning? Is there a risk that the mono labels get ignored?

8. **Reading at low capacity:** The app is designed to be used on low-energy days ("Reserve" state). Evaluate the typography for readability under cognitive load. Research shows readability degrades under stress, fatigue, and low motivation. Does the current type system protect against this? Are there specific adjustments (weight, spacing, size) that would improve low-capacity readability?

9. **Letter-spacing on caps labels:** The app uses tracked uppercase mono text for labels (e.g., "ENVIRONMENT", "TODAY", "ACTIONS"). What does research say about tracking on uppercase labels in terms of readability vs. legibility? Is there a cognitive load penalty to this style?

---

### SECTION 3 — LAYOUT, HIERARCHY & COGNITIVE LOAD

10. **Card-based layout:** Every content section uses a card (rounded rectangle, surface fill, padding). Evaluate the cognitive effect of a uniformly card-based layout. Does visual similarity between all cards reduce the user's ability to quickly orient? What does Gestalt theory say about using containment as the sole differentiator?

11. **The Today stack — 8 action items:** Research on visual working memory and list comprehension. What is the documented ideal visible list length for task-based mobile interfaces? Is 8 items in the right range, too many, or too few? How does the card treatment of each item affect perceived list length?

12. **Information density calibration:** The app shows: action title + system tag + optional cue + completion state + points value, per list item. Evaluate this density. What does progressive disclosure research say about the risk of showing all fields vs. hiding secondary information behind a tap? Would a collapsed row + expansion model improve usability for this profile?

13. **The 5-dot system status row:** Five dots, one per life system, colored if active/hollow if not. Evaluate this as a status visualization. What does the research on status indicator design say about dot-based systems? Is this the right encoding for "active this week vs. quiet"? What visual patterns (size, fill, animation) would improve signal clarity?

14. **The One Door card:** A high-stakes intervention card that appears mid-screen when nothing has been completed by noon. Evaluate the visual design requirements for this card. It must: feel calm (not alarming), create a clear action path, not generate shame, and be dismissable without guilt. What visual design principles (contrast, isolation, whitespace, type weight) would make this card work psychologically?

---

### SECTION 4 — INTERACTION DESIGN & FEEDBACK STATES

15. **Completion feedback:** The app uses a green glow + haptic on action completion. Evaluate this combination. What does research on immediate reinforcement and sensory feedback say about the optimal completion signal? Is visual glow + haptic the right pairing? What duration, intensity, and decay curve would maximize reinforcement without training dopamine-seeking behavior?

16. **The Daily Review as end-of-day ritual:** Three questions, text fields. Evaluate the interaction design of a low-friction daily review for an Achiever/Analytical profile at end of day (low energy, low motivation). What does ritual design research say about the ideal length, format, and friction level for a sustained daily reflection practice?

17. **Micro-interactions and animation:** The app uses subtle animations (easeInOut 0.2s for tab transitions). Evaluate the role of animation in building "instrument" aesthetic vs. undermining it. What does research on animation and perceived quality say for this profile? Is there a risk that animation feels too "app-like" and breaks the operational register?

18. **The tab bar:** ultraThinMaterial background, 2px gradient top indicator, mono 9pt labels. Evaluate the tab bar design for a 5-tab navigation system with daily use. What does iOS navigation research say about persistent bottom tab bars vs. alternatives for high-frequency apps? Is there a cognitive cost to the 2px top indicator vs. a more standard selection state?

---

### SECTION 5 — EMOTIONAL DESIGN & PSYCHOLOGICAL SAFETY

19. **The "instrument aesthetic" vs. emotional accessibility:** The app deliberately avoids warm, encouraging visual language. But research shows that cold, clinical interfaces can trigger avoidance behavior in users under stress — the exact state when the app is most needed. Where is the minimum threshold of visual warmth required to keep the interface approachable on a Reserve day? What visual elements carry warmth without compromising the operational register?

20. **Empty states and zero days:** When no actions are completed ("Quiet day" in the Timeline, hollow dots in the status row), what does the research on psychological safety and non-judgmental feedback design say about the optimal visual treatment? Is hollow + label sufficient, or does the absence itself carry a punitive quality?

21. **Identity markers in the You tab:** The user can set a "phase label" (e.g., "Recovery + Operational Restoration"). This is an identity signal, not a game mechanic. Evaluate the visual design requirements for this element. What does self-affirmation theory say about the placement, size, and visual treatment of identity labels in personal tools?

22. **The Milestone Moments:** Day 14 shows "14 DAYS." in large centered display type, two seconds of silence, then a data review. Evaluate this design for the INTJ/Analytical profile. What does research on meaningful pause, anticipatory moments, and the design of contemplative interfaces say about this pattern? Is the "two seconds of nothing" concept supported by attention research?

---

### SECTION 6 — SUSTAINED USE OVER TIME

23. **Visual fatigue and novelty decay:** The interface will be used every single day. What does research on interface habituation, visual fatigue, and novelty decay say about the risks of a highly styled dark interface over months of use? Are there documented strategies for sustaining visual engagement without introducing disruptive redesigns?

24. **Morning vs. evening use — physiological context:** The app is used at two primary times: morning (after wake, still in low-arousal state) and evening (end-of-day review, after cognitive depletion). What does chronobiology and perceptual research say about designing for these two distinct physiological states? Should any elements shift between morning and evening use?

25. **The trust arc:** For an Analytical profile, trust in the system is built through consistency, accuracy, and the absence of manipulation. What visual design elements over a 90-day arc would reinforce the sense that this is a "trusted instrument"? What are the highest-risk visual elements for eroding that trust?

---

### SECTION 7 — SPECIFIC RECOMMENDATIONS

After completing the analysis above, provide 5-10 concrete, prioritized visual design recommendations. For each:

- **Change:** What specifically to change (be precise — specific elements, colors, type treatments)
- **Mechanism:** Why this matters (the psychological or perceptual science behind it)
- **Risk if not changed:** What problem persists
- **Implementation notes:** How to implement in SwiftUI without disrupting the existing architecture

Order by impact. The first recommendation should be the one with the highest behavioral consequence for daily sustained use.

---

### SECTION 8 — WHAT NOT TO CHANGE

Identify 3-5 elements of the current design that are working correctly and should be protected from well-intentioned modification. For each, explain the mechanism that makes it work and the specific risk of changing it.

This section exists because design iteration often damages working elements. Protecting what's right is as important as fixing what's wrong.

---

## OPERATING INSTRUCTIONS FOR THE AGENT

1. **Mechanism first.** Every observation must be grounded in a named psychological, perceptual, or cognitive mechanism. "Looks cleaner" is not acceptable. "Reduces extraneous cognitive load by eliminating competing visual channels (Sweller, 1988)" is acceptable.

2. **Profile specificity.** Recommendations must account for the INTJ/Analytical/Achiever profile. What works for a general consumer app may fail for this user. Justify your recommendations against the specific profile.

3. **Behavioral consequence.** The goal is not aesthetic quality. The goal is daily sustained use over 90+ days that results in genuine behavioral change. Evaluate every element through that lens.

4. **No feature creep.** Do not suggest new features. This prompt is about the visual design of existing features. New features are a separate conversation.

5. **Honesty about uncertainty.** If research on a specific question is thin or contested, say so. The user is Analytical and will trust calibrated uncertainty more than confident overstatement.

6. **Voice consistency.** Any suggested copy changes must maintain the app's operational register. "Participation in reality" is the thesis. Motivational language is explicitly prohibited.

---

## HOW TO USE THIS DOCUMENT

This document is self-contained. Copy the entire text and paste it to any AI agent with strong UX/design knowledge. The agent needs nothing else to complete the analysis.

For sequential multi-agent review: run the full document with each agent independently, then compare section-by-section. Divergences are high-signal — they indicate areas of genuine design uncertainty worth investigating.

After receiving responses: use the Section 7 recommendations to draft a v1.2 design decisions document in the same format as the existing INCREMENTS Design Decisions document.

---

*INCREMENTS UX Design Prompt v1.0*
*"participation in reality"*
