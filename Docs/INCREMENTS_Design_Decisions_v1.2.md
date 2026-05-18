# INCREMENTS — Design Decisions v1.2
## Visual Design Synthesis · Post Multi-Agent UX Analysis
*Built from 5-agent independent review · Sections 1–8 complete*

---

## How to Read This Document

This document extends v1.1 (behavioral science synthesis) into visual design science.
Same three-tier structure:

- **Confirmed fixes** — changes with consensus across 4+ of 5 agents
- **Implement with care** — changes with 3+ agent agreement, with specific implementation constraints
- **Hold / Re-steer** — things that look like improvements but violate the system's psychological architecture

Each decision includes: the mechanism, the consensus confidence level, and the implementation note.

---

## THE MULTI-AGENT CONSENSUS

Five independent agents reviewed INCREMENTS against the same brief. The following findings appeared in **4 or 5 of 5 analyses** — this is the high-confidence tier.

**Universal agreement:**
1. Health = red is the single most dangerous semantic assignment in the system
2. Amber dual-use (Participation + decay) creates measurable cognitive load penalty
3. Mono metadata (9pt) is below legibility threshold for low-capacity states
4. Uniform card architecture reduces orientation speed and hierarchical clarity
5. The Sora + DM Mono pairing is correct and must be protected
6. The operational copy register is the primary trust mechanism — protect absolutely
7. The absence of streaks/gamification/aggregate scores is architecturally correct
8. The 2-second milestone pause is psychologically well-grounded

---

## PART ONE — CONFIRMED VISUAL FIXES

These changes have 4-5 agent consensus and direct behavioral consequence.
None require new screens. All are color/typography/spacing modifications to existing architecture.

---

### FIX V01 — Reassign Health System Color Away From Red

**The problem:** Red triggers pre-attentive threat response via two mechanisms simultaneously: evolutionary (red = danger signal across species, activating avoidance motivation) and learned interface convention (red = error/failure). For a recovery-phase user whose Health system will frequently show incomplete or quiet states, the hollow red dot is a consistent low-level threat signal. The Analytical mind will override it intellectually — but the override consumes resources needed for behavioral engagement.

**The consensus:** All 5 agents flagged this. No dissent.

**The fix:** Replace InkRed (#D06B6B) for the Health domain with a desaturated sky teal.
Recommended target: #5AB8D6 (sky teal) or #4FC3D4

Why teal?
- Evokes clinical neutrality without "hospital aesthetic"
- Associated with regulation, restoration, respiration
- No existing negative semantic loading in interface conventions
- Harmonizes with InkGreen (Environment) without visual conflict

**What happens to InkRed:** Retire it from the domain palette entirely. If a true system-error state ever needs visual treatment (not a "quiet" signal — an actual error), InkRed can serve that role. But it must be reserved for that use only, not as a permanent domain color.

**Implementation:** Replace the `.health` case in `SystemTag.color` in the color extension. Update all Health system tags, dots, and card indicators. The word "red" should not appear in any domain semantic token after this change.

---

### FIX V02 — Separate Decay Signal From Participation Color

**The problem:** InkAmber currently serves two meanings: Participation domain identity AND the 3-day quiet signal. This forces disambiguation on every amber encounter — a small but compounding extraneous cognitive load tax. Under fatigue, the disambiguation cost is highest precisely when the signal most needs to be clear.

**The consensus:** All 5 agents flagged this. Two agents noted it compounds specifically in Days 7–30 when the user is still building their interaction model.

**The fix:** Two separate changes:

1. Retain InkAmber as the Participation domain color. It's warm without being threatening, and domain colors need stability.

2. For decay signals ("quiet for 3 days"), do NOT use amber. Instead: apply a cross-domain decay modifier — the domain color at 40% opacity, with a faint stroke border at 60% opacity. This makes decay visually encoded as "a quieter version of the domain" rather than a separate color. The semantic is transparent: any dimmed system dot = quiet. No new color to learn.

**Implementation:** Add a `decayModifier` state to the system dot view. When `daysSinceLastActivity >= 3`, apply:
```swift
.opacity(0.4)
.overlay(Circle().strokeBorder(system.color.opacity(0.6), lineWidth: 1))
```
No new colors. Existing palette, existing logic, new rendering state.

---

### FIX V03 — Increase Mono Metadata Minimum to 11pt

**The problem:** DM Mono at 9pt is below the legibility threshold for low-capacity reading. Under fatigue, stress, and low motivation (precisely the Reserve states where the app must continue functioning), smaller type requires letter-by-letter decoding rather than word-shape recognition. Metadata labeled at 9pt becomes ambient texture — visually present but functionally ignored.

**The consensus:** 4 of 5 agents flagged this explicitly. One noted the compounding risk: if system tags become invisible to the Analytical user, the taxonomy that organizes the whole system becomes decorative.

**The fix:** Raise all DM Mono metadata labels to minimum 11pt. Slightly reduce tracking to compensate (tracked text at larger sizes can feel too spaced). Specific targets:
- System tags on action rows: 9pt → 11pt
- Tab bar labels: 9pt → 10pt
- Header labels (TODAY, ENVIRONMENT, etc.): keep uppercase, reduce to +1 tracking (from +2)

**Implementation:** Update `Font.mono()` usage throughout. No layout breakage — monospace is width-predictable.

---

### FIX V04 — Introduce Card Hierarchy Variation

**The problem:** Every content block uses the same card treatment (Surface fill, radius 12–16, same padding). Gestalt similarity law groups identical-looking elements together — which works within a section (all action items should look alike) but collapses orientation across sections. The user cannot peripherally distinguish a morning evidence card from an action row from a Daily Review prompt. Every time they open the app, visual search is required.

**The consensus:** All 5 agents flagged this. One noted that spatial memory maps — the user's ability to navigate by muscle memory — form faster when distinct visual signatures anchor each region.

**The fix:** Three card tiers:
- **Primary** (Today actions, One Door card): Surface (#161422), current treatment
- **Secondary** (Morning evidence card, status rows, system summaries): Surface2 (#1C1A2A), slightly more breathing room, +4pt vertical padding
- **Ambient** (metadata blocks, settings areas, guardrail display): no card background, just subtle left border rule in .muted

The result: action cards feel like the operative layer. Context cards feel like support. Settings feel like infrastructure. The difference is legible in peripheral vision.

**Implementation:** Create three `CardView` variants or a `cardStyle: CardStyle` parameter. No structural changes.

---

### FIX V05 — Shift Background Undertone From Blue to Neutral-Warm

**The problem:** #0C0B12 has a blue undertone. Blue-wavelength light (even at near-black luminance levels) activates melanopsin-containing retinal ganglion cells, measurably suppressing melatonin. For an app used at morning wake and evening wind-down, the background color is working against the user's chronobiology at both anchor points. This effect is small in any single session but compounds across 90+ days of daily use.

**The consensus:** 3 of 5 agents flagged this, with calibrated uncertainty about magnitude. Two noted the absolute luminance is so low that the effect is minor. Recommendation stands because: (a) the fix is effectively invisible as a visual design change, and (b) cost is zero.

**The fix:** Shift three background values by 2–3 hex points toward warm-neutral:
- bgBase: #0C0B12 → #0D0C0B
- surface: #161422 → #171512
- surface2: #1C1A2A → #1D1B18

The perceptual difference in screenshots: none. The physiological difference over time: measurable.

**Implementation:** Three color token replacements. Nothing else changes.

---

### FIX V06 — Strengthen Tab Selection State

**The problem:** The current 2px gradient top indicator is the sole selection signal for a 5-tab navigation system used multiple times per day. A 2px line requires intentional fixation to perceive — it is not detectable in peripheral vision. For high-frequency navigation across 5 tabs (at the iOS cognitive ceiling), the "am I on the right tab?" verification adds micro-costs that compound across hundreds of daily sessions.

**The consensus:** 4 of 5 agents. One described it as "the one form of interface uncertainty that should not exist."

**The fix:** Supplement the existing 2px line with an area fill behind the selected tab:
```swift
.background(selected == i ? Color.violetDim.opacity(0.25) : Color.clear)
.clipShape(RoundedRectangle(cornerRadius: 6))
```
The fill spans the full tab width. The 2px line remains. Together they create a signal detectable in peripheral vision without adding visual weight to the tab bar.

**Implementation:** One modifier addition to the tab button in `CustomTabBar`. No layout change.

---

## PART TWO — IMPLEMENT WITH CARE

These changes have 3+ agent agreement but carry specific implementation risks that must be respected.

---

### CARE 01 — Progressive Disclosure on Action Rows

**What 3 agents recommend:** Collapse cue + XP to a secondary state. Default row shows title + system tag only. Tap or long press reveals metadata.

**The behavioral benefit:** Reduces information density. Helps Reserve-state use. Prevents the Achiever profile from fixating on XP totals.

**The implementation risk for this specific profile:** The Restorative strength includes a specific vulnerability — ambiguity about what's hidden creates a mild "what am I missing?" signal. A collapsed row that might conceal relevant data is a minor aversion trigger. If the cue isn't visible, the habit cue architecture (Fix 03 from v1.1) loses some of its passive reinforcement.

**The correct implementation:** Progressive disclosure grounded in data existence, not interaction tap. Show the cue line only when a cue exists. Don't show a collapsed-row affordance implying something is hidden when there's nothing there. The XP points can move to a long-press detail view. The cue stays visible as a second line when populated.

---

### CARE 02 — Reserve-State Density Reduction

**What 4 agents recommend:** When Energy State = Reserve, automatically increase spacing, reduce visible items, and hide secondary metadata.

**The behavioral benefit:** Significant. Reserve days are exactly when cognitive load must be minimized. An 8-card Today stack at Reserve capacity is a friction generator.

**The implementation risk:** This must not feel like the app "knows you're struggling" in an emotionally loaded way. The change should be purely structural — more whitespace, fewer rows — not a mood-sensitive UI shift.

**The correct implementation:** Reserve state triggers:
- Today stack visible items: 8 → 3 (the lowest-XP items only, same as One Door logic)
- Line spacing: +4pt across all text
- Card padding: +8pt
- No labels, no copy change indicating this is "Reserve mode"

The operational register applies here: the interface adjusts, silently. No announcement.

---

### CARE 03 — Atmospheric Visual Depth (Glow, Depth, Texture)

**Context:** One Claude agent, responding to the mockup images, began building an atmospheric home screen with animated glow, neural node pulse animations, "deeper card glow — violet inner shadow," "slow-drifting radial gradient," and particle effects. This needs specific guidance rather than a blanket stop or go.

**What the science supports:**
- The icon as a launch splash: YES. Brain with node pulse animation → wordmark fade → app load. This is a contained atmospheric moment that front-loads the emotional hook before the instrument interface begins. Duration 2–2.5s. The warm gold corona on the brain is the right register.
- Subtle ambient depth on the Home screen hero area: YES. A very low-opacity radial gradient behind the brain glyph on Home, warmth emanating from center. Not animated. Static atmospheric depth.
- Completion glow: Already in spec. Low amplitude, 400–600ms, fade-out.

**What the science does NOT support:**
- Continuously animated backgrounds (TimelineView drifting gradient): Instrument panels do not animate continuously. Continuous ambient animation trains the interface to feel like an experience rather than a tool. It is the first step toward "wellness app" aesthetic drift.
- Animated elements on every interaction: The animation budget for a daily session is approximately 12–15 events before the interface starts feeling performative.
- The visual language in the mockup screen 3 (spider chart, gold score burst, celebration ring on Daily Review): These are high-stimulation reward aesthetics that violate the behavioral guardrails. Do not build these.

**The correct implementation of "atmospheric":**
- Launch screen: YES — animated, 2.5s, full atmospheric treatment with the brain icon
- Home tab hero: Subtle static depth. One low-opacity radial behind the system status area.
- Everything else: Instrument. Precise. Restrained.

The mockups show what the app could look like if it were optimizing for screenshots. INCREMENTS optimizes for daily inhabitation, not first impressions.

---

## PART THREE — HOLD / RE-STEER

Elements from the agent conversation and mockups that should not be built.

---

### HOLD — The Mockup Architecture (Image 3)

The Claude-generated mockups (10-screen layout) contain multiple elements that are explicitly contradicted by the v1.1 behavioral science decisions:

| Mockup Element | Why It's a Problem |
|---|---|
| Spider chart (Overview tab) | Explicitly held in v1.1: "highest Goodhart's Law risk in the feature set" |
| "Best streak: 14 days" | Streak psychology through the visual layer — the back door the v1.1 doc specifically warns against |
| "Well executed. You participated in reality today." | Praise language. Violates operational register. "Well executed" is exactly the kind of evaluative framing the system is designed to avoid |
| "82 /100" with gold burst glow | Aggregate score as hero element — held in v1.1 |
| Level rewards screen with locked features | Gamification ladder. The opposite of the system's orientation toward autonomy |
| "JOURNAL ENTRY" as Daily Review CTA | Open-canvas journaling creates blank-field anxiety for an Analytical profile at end of day |
| "12%" momentum arrow | Percentage trend comparison — the Competition strength's Goodhart's Law trap |
| Streak bar under "CONSISTENCY" | Explicit streak mechanic |

The mockups are beautiful. They are also a different app. They should serve as reference for the visual register — the dark palette, the brain imagery, the layout density — not the feature set.

---

### HOLD — Aggregate Operator Score as Featured Element

The Claude agent's Home screen description includes the score prominently ("Operator Score: 782/1000"). This was replaced in v1.1 (Fix 04) with the 5-dot system activity row. The v1.2 analysis confirms this was the right call. Five agents reviewed the scoring question and none recommended restoring the aggregate.

---

### HOLD — Continuous Animation / "Atmospheric" Background Effects

As documented in CARE 03 above. The emotional hook the Claude agent correctly identified ("I want to open this again") should come from the launch sequence and the single atmospheric moment on Home, not from persistent ambient animation. Continuous motion in a daily-use behavioral tool gradually shifts it from instrument to environment — and environments are easier to ignore.

---

## PART FOUR — THE VISUAL REGISTER (IMAGES 1 + 2)

The brain icon and brand sheet (Images 1 and 2) establish the correct visual register for INCREMENTS. Document it here so future build sessions have a reference.

**What the icon gets right:**
- Warm gold corona emanating from the corpus callosum center — warmth without wellness
- Violet rim light on the brain exterior — the system color, correctly atmospheric not aggressive
- Neural nodes as small warm gold points connected by thin lines — the "network" metaphor without cyberpunk excess
- Dark near-black background — deep, not pure black
- The brain reads as precise and anatomical, not cartoon or illustrative

**What this means for the app interior:**
- The icon's color temperature (warm center, cool violet rim) maps to the app's color hierarchy: Warm (#C8A96E) as the secondary accent that carries emotional approachability, violet as the operational signal
- The icon's restraint (no gradients, no glow overload) should be the ceiling for interior UI effects
- The lockup's tracked letterform "INCREMENTS" is exactly the right typographic register for the Home tab wordmark — consider using this exact treatment

**App icon implementation notes:**
- Recommended variant (glow + dark bg) for primary App Store presence
- Launch animation: the nodes pulse in one by one over 1.2s, then the warm corona ignites (0.3s), then the wordmark fades up (0.4s), then the app loads. Total: ~2.2s.
- Do not animate the icon on Home tab. Static. The launch sequence is the one moment of animation. After that, it appears as a static glyph — instrument mode engaged.

---

## SUMMARY — WHAT TO BUILD WHEN

### Confirmed Visual Fixes (build with current Phase 1 code)
1. Replace Health red with sky teal (#5AB8D6)
2. Separate decay signal from amber — use opacity modifier instead
3. Raise mono metadata to 11pt minimum
4. Introduce three-tier card hierarchy (Primary / Secondary / Ambient)
5. Shift background undertone from blue to neutral-warm
6. Strengthen tab selection with area fill

### Implement with Care
7. Progressive disclosure: show cue when exists, hide XP behind long-press
8. Reserve-state density reduction: 3 items, +4pt spacing, +8pt padding
9. Launch sequence animation (2.2s) — brain icon with node pulse + corona

### After 14 Days of Phase 1 Use
10. All Phase 2 features from v1.1 (Timeline, Focus Mode, Energy State, Notifications)

### Hold
- Mockup architecture (scores as heroes, streaks, rewards ladder, spider chart)
- Continuous ambient animation
- Praise language in any copy context

---

## RE-STEERING THE AGENT

If building with a Claude Code agent or conversational Claude, use this instruction:

> "INCREMENTS is an environmental cognition support system, not a productivity app and not a wellness app. The visual language is a precision instrument — dark, restrained, operational. Do not add: spider charts, streak counters, aggregate scores as hero elements, praise language, gamification rewards, or continuous ambient animation. Do add: launch sequence animation using the brain icon, subtle atmospheric depth on the Home hero area only, three-tier card hierarchy, and the confirmed color fixes (Health → teal, decay → opacity modifier, mono type → 11pt minimum). The mockup images are reference for visual register only — not for feature set. The behavioral science document (Design Decisions v1.1) takes precedence over any feature that 'looks good' in a mockup."

---

*INCREMENTS v1.2 Design Decisions · Built from 5-agent visual design synthesis*
*"participation in reality"*
