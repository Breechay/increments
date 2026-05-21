# INCREMENTS — Design Doctrine

**Version:** May 2026  
**Status:** Canonical aesthetic system

**Token-level fixes and hex targets:** `INCREMENTS_Design_Decisions_v1.2.md` (V01–V06, hold list)

---

## What it should feel like

**Target register:** **calm precision**

A quiet operating terminal — reflective institutional instrument, high-trust internal OS. Elegant without performing elegance.

**Not:**

- Luxury wellness spa  
- Startup SaaS dashboard  
- Gamified habit app  
- Apple Health clone  
- Cyberpunk command center  
- Screenshot-optimized “atmospheric” product  

**Is:**

- Instrument you inhabit daily  
- Hierarchy readable in peripheral vision  
- Warmth through restraint (gold + violet), not decoration  

---

## Emotional register

| Quality | Weight |
|---------|--------|
| Calm | Primary |
| Sharp | Primary |
| Trustworthy | Primary |
| Contemplative | Secondary (evening reads) |
| Intimate | Light (presence voice, not soft UI) |
| Institutional | Secondary (mono metadata, section kickers) |
| Command-center | Only Hideout/Signal execute moments — not global skin |

---

## Layout doctrine

1. **One dominant read per screen** — eye knows where to land in &lt;3 seconds  
2. **Hierarchy over decoration** — fix alignment and type before color tricks  
3. **Progressive disclosure** — pre-open ≠ Sunday strategy; execute ≠ doctrine depth  
4. **Nonlinear lookup friendly** — Physique, Recovery, Manual, Doctrine allow jump navigation  
5. **Execution above fold** — Now, Today, Signal, Hideout today band  
6. **Doctrine may have depth** — You tab evening reads; collapsed by default where reread is occasional  
7. **No ornamental clutter** — if it doesn’t reduce drag, remove it  

**iPad:** Generous canvas; master-detail where cognition splits (Now, You, Physique, Recovery, Hideout landscape).

**Phone:** Ruthless fold — CONTEXT ↓, TRAITS ↓, not eleven cards.

---

## Typography

- **Sora** — prose, titles, card body  
- **DM Mono** — metadata, kickers, labels, tab bar  
- **Mono minimum 11pt** for metadata under fatigue (see v1.2 FIX V03)  
- Tab bar labels ~10pt — compact chrome, not body text  

Tracked INCREMENTS wordmark on Home — institutional, not playful.

---

## Color doctrine (semantic)

Colors mean **domain**, not mood wallpaper.

| Token / domain | Meaning |
|----------------|---------|
| **inkGreen** | Environment · signal · movement · Physique accent |
| **inkTeal** | Health · recovery · regulation (not alarm red) |
| **violet / violetLight** | Cognition · interpretation · tab selection |
| **warm** | Operations · Hideout · stewardship · capital |
| **inkAmber** | Participation · caution · organism warning (not dual-use decay) |
| **inkRed** | Reserved for true error — not “quiet health” |

**Decay / quiet systems:** domain color at reduced opacity — not a second amber meaning.

**Background:** neutral-warm near-black (`#0D0C0B` family) — not blue undertone (melatonin/chronotype, v1.2 FIX V05).

---

## Card hierarchy (three tiers)

| Tier | Use |
|------|-----|
| **Primary** | Actions, one door, dominant execute cards |
| **Secondary** | Evidence, status, scorecard blocks |
| **Ambient** | Priority framing, open friction — left rule, no heavy fill |

Uniform cards everywhere = orientation failure. Implemented as `CardView` styles.

---

## Motion doctrine

| Rule | Detail |
|------|--------|
| **Calm** | ≤220ms functional transitions; ease-out |
| **No dopamine bait** | No celebration bursts, streak animations, score firework |
| **Functional only** | Tab switch, collapse, sheet present |
| **Launch exception** | ~2.2s brain icon sequence once — then static glyph |
| **Budget** | ~12–15 motion events per session max before UI feels performative |
| **Never** | Continuous ambient background animation on working surfaces |

Completion acknowledgment: brief glow optional — low amplitude, not reward theater.

---

## Icon / brand register

Brain icon: warm gold corona, violet rim, precise anatomy — ceiling for interior effects.

App interior **≤ icon restraint**. No gradient overload, no persistent pulse on Home.

---

## Density doctrine

**Reserve energy state:** silently reduce visible stack, increase spacing — no “we noticed you’re struggling” copy.

**Evening doctrine reads:** full density allowed on iPad when operator is interpreting, not executing.

---

## Anti-patterns (design)

Held from v1.2 — do not build:

- Spider charts, aggregate hero scores  
- Streak bars, level ladders, locked rewards  
- Praise banners (“well executed”)  
- Gold score burst, 82/100 hero  
- Continuous Timeline gradient drift  
- Horizontal pill nav on heavy reference tabs (use vertical jump list)  

---

## Relationship to FORM

Borrow **layout restraint and hierarchy discipline** from `FORM-iOS/docs/form_system_doctrine.md` when useful.

**Never** borrow FORM athlete voice, Forge active-session chrome, or running-record aesthetic into INCREMENTS.

---

## Implementation pointer

Confirmed visual fixes: `INCREMENTS_Design_Decisions_v1.2.md` Part One.  
Code: `Models.swift` color system · `SharedComponents.swift` CardView · `AppShell.swift` tab chrome.

---

*INCREMENTS Design Doctrine · May 2026 · Canonical*
