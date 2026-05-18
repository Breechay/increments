# INCREMENTS — Agent Handoff Document
## v1.2 · Session Orientation for Claude Agent
*Read this before writing a single line of code.*

---

## What This App Is

INCREMENTS is a **private iOS life-operations instrument** for one user (Brice). It is not a productivity app, not a wellness app, not a habit tracker with streaks. It is an environmental cognition support system — small daily actions made visible as evidence that life is improving.

**The core operating question the app answers:** "What actions will make my life more inhabitable today?"

**The emotional register:** Cinematic recovery cockpit. Calm, operational, atmospheric, intelligent. Ex Machina energy — quiet intensity, restrained futurism, beautiful interfaces that earn their complexity.

**The user:** INTJ. Analytical, Achiever, Restorative, Individualization, Competition (Gallup top 5). Aspiring filmmaker. Atmosphere-sensitive. Detail-appreciative. Currently in physical recovery (tibial fracture, post-op, crutches). The app is built specifically for this profile — not generalized.

---

## The Three Documents You Must Know

Before making any decision, understand the authority hierarchy:

1. **INCREMENTS_App_Master_Document.docx** — Original product spec. Identity, philosophy, voice, screen inventory, data model, scoring logic, guardrails. The founding document.

2. **INCREMENTS_Design_Decisions.md (v1.1)** — Behavioral science synthesis from 7-agent review. Overrides the master doc where they conflict. Contains Phase 1 fixes, Phase 2 priorities, and explicit HOLD items.

3. **INCREMENTS_Design_Decisions_v1_2.md** — Visual design science synthesis from 5-agent review. Confirms and extends v1.1 with visual fixes. Highest authority on color, typography, card hierarchy, animation.

**When in doubt:** v1.2 > v1.1 > Master Doc.

---

## Current Build State

**File:** `IncrementsApp.swift` — single-file SwiftUI + SwiftData app, ~2,800 lines.
**Platform:** iOS 17+, SwiftData, local only, no backend, no auth.
**Fonts:** Sora (UI) + DM Mono (metadata/labels). Both custom-bundled.
**Version:** v1.2, Phase 1 complete.

### What's Built and Working
- Home (Operator Dashboard) — System Synergy 5-dot row, Next Sane Participation, System Status rows with domain color accents
- Today (Daily Execution) — Energy State input, Morning Evidence card, One Door postponement interrupt, doctrine card, action stack (capped at 8), progress ring, Daily Review CTA
- Increments (System View) — 5 system cards with domain accent strips, 3-day quiet signal, completed today section
- Habits — HabitCard with cue + minimum scope, system-color completion button, last-completed indicator (no streak dots)
- You — Profile (BrainGlyph avatar, phase label, level/phase/XP-to-next), Work Tracks, Recovery Phase, Settings
- Timeline — Gated at day 14, shows receipts not grades, violet thread connectors
- Launch Sequence — BrainGlyph nodes → corona → wordmark → app load, 2.25s, cold launch only
- All sheets — custom handle, bgBase background, no iOS default chrome
- Custom tab bar — bgBase not ultraThinMaterial, violet/warm gradient separator, domain bloom behind selected tab

### Phase 2 — Partially Built
- **Energy State** ✓ — Full/Partial/Reserve with silent stack adaptation
- **Timeline** ✓ — Gated, working
- **Focus Mode** ✗ — Not yet built (tab bar disappears, countdown timer)
- **Notification personalization** ✗ — Not yet built
- **Insights tab** ✗ — Blocked until 30 days of data

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
- **Minimum mono size: 11pt** — this is a hard floor. Below 11pt fails legibility under cognitive load.
- **Tab bar labels: 10pt** — documented exception, space-constrained
- **Intentional sub-11pt exceptions:** system dot pictographic labels (8pt — visual keys, not text), day-of-week letters under habit dots (8pt — positional markers), launch screen decorative text
- **Tracking on MonoLabel: 2.0** (reduced from 2.5 to compensate for size increase)

---

## Card Hierarchy (Three Tiers — Do Not Flatten)

```swift
CardView(style: .primary)    // operative actions — surface fill, violet-bloom shadow
CardView(style: .secondary)  // context, evidence — surface2, more padding
CardView(style: .ambient)    // infrastructure, guardrails — no background, warm-violet border rule
```

CardView primary has three shadow layers: warm rim light above, dark grounding shadow below, violet ambient bloom. This is motivated lighting — not decoration.

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

**Never write:**
- Praise language: "Well executed", "You showed up", "Great job"
- Shame language: "Neglected", "You failed", "Streak broken"
- Motivational-speaker cadence: "Crush your goals", "Level up your life"
- Urgency: "You haven't opened the app", "Don't break your streak"
- Evaluative framing on completion: "Perfect", "Excellent"

**The register:** Operational. Ecological. The system reports state without judging it. A system reporting on itself, not a coach talking to a student.

---

## Behavioral Architecture — What Must Never Change

These are the load-bearing decisions from v1.1. Do not override them without re-reading the full rationale:

1. **No aggregate operator score as hero element.** XP exists internally; never display XP total. "XP to next" is acceptable.
2. **No streak counters.** The 7-day habit dot trail is explicitly held. Use last-completed indicator only.
3. **No streak-shaming notifications.** Ever.
4. **Health system is inkTeal, not inkRed.** Red on health creates threat response.
5. **System decay uses opacity modifier, not amber.** Decaying dots dim in their domain color at 40% opacity.
6. **One Door surfaces lowest-XP action.** The last decision is made by the system — user's job is binary.
7. **Daily Review has no Skip button.** "Close lightly?" requires a second deliberate tap to fully dismiss.
8. **Energy State stack reduction is silent.** No label, no announcement when the app reduces your stack.
9. **scoreLabel returns "Quiet" not "Neglected"** for systems below 50 score.
10. **Timeline gated at day 14.** Absent from tab bar entirely before then — not locked, not greyed.

---

## What Is Explicitly Held (Do Not Build)

From v1.1 HOLD and v1.2 HOLD sections:

- **Spider chart / Overview Dashboard** — highest Goodhart's Law risk in the feature set
- **Streak counters in any form** — including visual representations
- **Aggregate Operator Score as displayed metric**
- **Continuous ambient animation** — the launch sequence is the one atmospheric moment, then static
- **Praise language in any copy context**
- **Gamification ladder / level rewards screen**
- **Journal entry as open canvas** — creates blank-field anxiety for Analytical profile
- **Percentage trend comparisons** — Competition strength Goodhart's trap
- **"Best streak" display anywhere**

---

## Phase 2 — Build Gate

**Gate condition:** 14 days of daily Phase 1 use.

**Remaining Phase 2 items (in priority order):**
1. **Focus Mode** — deep work timer, tab bar disappears during session, 2-screen exit sequence with buffer. 30/45/60 min options, 45 default. Counts up not down (less clock-watching anxiety).
2. **Notification personalization** — quiet windows, category toggles, 4/day hard cap (already enforced in code).
3. **Insights tab** — blocked until 30 days of data. Tab does not appear before then.

---

## Assets in Xcassets

- **AppIcon** — the brain icon with dark background, used as home screen icon
- **BrainGlyph** — same brain, transparent background, used in LaunchSequenceView and ProfileTabView avatar

The launch sequence references `Image("BrainGlyph")` — ensure this asset exists when building.

---

## Things to Watch in Real Use

These are live questions that only use answers:

- **Energy State card** — does it get used, or does it become friction at the top of Today on hard days? If it's getting dismissed without input, consider making it optional/collapsible or moving it.
- **XP-to-next in Synergy card** — will the Competition strength turn this into a score proxy? Watch for it.
- **Doctrine rotation by weekday** — predictability dulls the line over time. Phase 2 might want a smarter rotation (data-driven or genuinely random).
- **One Door trigger at noon with zero completions** — does this catch the right moments, or does it fire on days when you're just busy in the morning?

---

## The Guardrails (Embedded in App — Also Here for Agent)

> No streak shaming. No failure language.
> If the app creates pressure, remove items.
> No notifications that generate guilt.
> Gentle decay only — never harsh penalties.

**And for the build process:**
> Do not add more features without a specific real use case identified through actual use.
> Do not redesign the visual system. The palette is committed.
> Do not add a backend until local persistence is genuinely insufficient.
> The app is a constraint, not a canvas.

---

## Opening Prompt for Next Session

If you want to orient a fresh agent quickly, paste this:

```
You are working on INCREMENTS — a private iOS environmental cognition support system 
built for one user (Brice). Read INCREMENTS_Agent_Handoff.md before doing anything. 
It contains the full behavioral architecture, visual system, voice register, what's 
been built, what's held, and what to watch. The single Swift file is IncrementsApp.swift. 
Do not add features. Do not redesign the visual system. Work only on what's specified.
```

---

*INCREMENTS Agent Handoff · v1.2 · Built from full session synthesis*
*"participation in reality"*
