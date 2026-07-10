# INCREMENTS — Product Architecture

**Version:** Jul 2026 (Operate mode)  
**Status:** Canonical mental model (not implementation map)

**Implementation detail:** `INCREMENTS_Master.md` · **Code entry:** `AppShell.swift` → `RootView` → `CustomTabBar`  
**Operate mode (Jul 2026):** [`OPERATE_MODE_ROADMAP.md`](OPERATE_MODE_ROADMAP.md)

---

## Operate mode — current shell (Jul 2026)

Near-$0 survival month: **two tabs** replace the morning 8-tab battlefield.

| Tab | Label | Mode | One-sentence job |
|-----|-------|------|------------------|
| 0 | **Operate** | Execute + orient | CASH / DUE / IN + 3-line TODAY — open this every morning |
| 1 | **Park** | Depth archive | Hideout · Signal · You · Today rail · Physique · Recovery · Capital · legacy Now |

**Principle:** Manual truth first. Morning = Operate only. Evening depth = Park → You.

The eight-tab model below remains the **cognitive map** for Park destinations — not the tab bar.

---

## Why eight tabs (Park destinations — pre-Jul 2026 bar)

The product separates **modes of cognition** that break when collapsed into one scroll.

| Tab | Label | Mode | One-sentence job |
|-----|-------|------|------------------|
| 0 | **Now** | Orient | What matters today before you execute |
| 1 | **Today** | Execute | Choreography of the day — rail, protocols, log |
| 2 | **Protocols** | Execute / reference | Session protocols without leaving execution context |
| 3 | **Physique** | Reference | Body architecture — ratio, program, cut (lookup) |
| 4 | **Hideout** | Business operate | Venue experiment — today vs scorecard vs playbook |
| 5 | **Signal** | Execute discipline | Distribution plant · log · adjust (delayed feedback) |
| 6 | **You** | Learn + interpret | Evening orientation — capital, brief, doctrine, ventures, intel, manual |
| 7 | **Recovery** | Reference | Post-op constraints, gates, return path |

**Do not resurrect:** standalone Operator tab, Dossier shell, duplicate Manual on Today, Insights embed, Cognition Lab orphan (removed May 2026).

---

## Surface contracts (non-negotiable)

| Contract | Rule |
|----------|------|
| **Execute** | Literal, immediate, minimal interpretation above fold |
| **Orient** | One dominant read; secondary context disclosed, not stacked |
| **Diagnose** | Structural failure modes; evidence-linked traits |
| **Learn** | Depth allowed; nonlinear reading expected on iPad |
| **Reference** | Jump navigation; no fake “progress” on static truth |

**Violation examples:**

- Wendy hero on Today → wrong mode on wrong surface  
- Loan decision stack above fold on pre-open Hideout day → strategy mode invading operate mode  
- “READ THIS FIRST” on logging sheet → tutorial mode on execute surface  

---

## Now

**Question answered:** What matters today?

**Always visible (phone):**

- Operating priority (not “dominant thread” marketing language)
- Weather, first action, pre-commitment when present

**Behind CONTEXT ↓ (phone):**

- Hideout status, distribution nudge, housing, sleep, training, Wendy observation, open friction

**iPad:** Master-detail — priority column + command column (unchanged principle).

**Not:** eleven equal cards; system score hero; interpretive essays.

---

## Today

**Question answered:** What is the sequence right now?

**Segments:** Rail · Protocols · Log (names retained for muscle memory — rename only if real confusion).

**Owns:** One door, maintenance, timeline, daily review, energy state, action completion.

**Does not own:** Long doctrine reads, dossier traits, distribution methodology treatise.

---

## Protocols

**Question answered:** What is the protocol for this session block?

Standalone tab for session-shaped work; also embedded in Today segment.

Reference-weight execution — still act-adjacent, not evening interpretation.

---

## Physique · Recovery

**Question answered:** What is true about the body / rehab plan? (lookup)

**Interaction:** iPad vertical rail; phone **vertical jump list** (not horizontal pill chrome).

**Not:** Forge programming surface; motivation; adherence gamification.

---

## Hideout

**Question answered:** What is true at the venue today — and what is the experiment status?

**Sub-tabs:**

| Sub-tab | Mode |
|---------|------|
| **Dashboard** | TODAY AT HIDEOUT (always) → EXPERIMENT SYSTEMS ↓ · FRICTION AUDIT ↓ · DECISIONS ↓ |
| **Scorecard** | 30-day dataset, analytics, techniques |
| **Playbook** | Reference execution — scripts, bundles, staffing (not pre-open dashboard) |
| **Intel** | Experiment ledger — provisional hypotheses |

**Not:** hideout-ops-console parity; vanity throughput theater.

**Floating LOG SHIFT:** execution affordance — stays visible.

---

## Signal

**Question answered:** Did I plant, log, and adjust distribution this week?

**Discipline:** Plant · log · adjust — fixed Monday block, Friday log, ledger confirmation.

**Methodology lives in You** (Doctrine, Ventures, Manual) — not duplicated as markdown on execute surface.

**Spec:** `INCREMENTS_DISTRIBUTION_TAB_SPEC.md`  
**OS:** `FORM-iOS/docs/BRICE_OS/DISTRIBUTION_OPERATING_SYSTEM.md`

---

## You (evening instrument)

**Question answered:** What is true about the season, ventures, and operator patterns?

**Segments (phone):** Capital · Brief · Doctrine · Ventures · Intel · Manual · Settings (gear)

**iPad:** Capital left; five doctrine/venture/intel/manual segments + gear sheet.

| Segment | Mode |
|---------|------|
| Capital | Stewardship truth |
| Brief | Situation room + Wendy (interpret) |
| Doctrine | Stable operator + distribution + venture reads |
| Ventures | Live distribution state per venture |
| Intel | Observed traits ↓ · when structure breaks ↓ · distribution state |
| Manual | Principles + crash course tiers |

**Crash course tiering (Manual only):**

- **READ THIS FIRST** — core loop (appropriate here — learning surface)  
- **WHEN SIGNAL IS UNCLEAR ↓** — deep reads (collapsed default per visit)  

Do not globalize that template to Now/Today/Signal.

---

## Daypart split (canonical)

| Daypart | Primary tabs |
|---------|----------------|
| **Morning** | Now → Today · Signal (Monday) · Hideout (work days) |
| **Evening (iPad)** | You — doctrine, ventures, intel |
| **Unclear** | Intel failure modes · Manual · Brief |

Morning = execution. Evening = interpretation. Mixing them erodes both.

---

## Intelligence placement

| Layer | Where |
|-------|-------|
| Structural same-day observation | Today open (sparse; cooldown) |
| Wendy pattern | You → Brief |
| Observed traits / failure modes | You → Intel |
| Pattern brief (30d) | Consult — operator-requested |
| Engine-only (deferred UI) | ObservedIntelligenceCard — do not slot-fill |

---

## Cross-product boundaries

| Product | Relationship |
|---------|----------------|
| **FORM** | Athlete execution — different voice; shared distribution OS |
| **Forge** | Strength execution — not programmed in Physique tab |
| **hideout-ops-console** | Separate operator instrument — do not port dashboards |
| **INCREMENTS** | Private OS — Brice operator only |

---

## Agent checklist (architecture)

Before adding UI, answer:

1. Which mode does this serve?  
2. Which tab owns it?  
3. Does it violate surface contract?  
4. Does it duplicate a removed shell (Operator, Dossier)?  
5. Should it be collapsed by default?  

---

*INCREMENTS Product Architecture · May 2026 · Canonical*
