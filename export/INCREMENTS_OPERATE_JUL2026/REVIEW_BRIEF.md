# INCREMENTS Operate Mode — Claude + Chat Review Brief

**Paste this file into a new Claude or Chat session** along with `INCREMENTS_OPERATE_JUL2026.zip`.

---

## Your job

Review the Jul 7 **Operate restructure** of INCREMENTS — Brice's private operator iOS app. He is near **$0 runway**, just paid July bills, and needs **August visibility** without building finance theater.

**Deliver:**

1. **Verdict** — Does Operate + Park solve the morning problem?
2. **Keep / trim / fix** — specific, ranked (max 5 items)
3. **Field protocol** — are CASH / DUE / IN + TODAY / 7-DAY / PARKED sufficient?
4. **Legibility** — is the Operate tab readable on iPhone at a glance?
5. **30-day gate** — anything to add or remove before Aug 6?

**Do not:** propose Plaid, categories, charts, dashboards, gamification, or multi-agent automation. Council already rejected these unanimously.

---

## Context (Jul 7, 2026)

**Operator:** Brice Ikouebe · Miami · Hideout café (solo operator) · FORM/Forge builder

**Problem:** 8-tab app became cognitive overhead at near-$0. Needed to wake up knowing: cash, what's due, what to collect, and 3 tasks today.

**Council adjudication (6 agents + Claude + Chat):**

- Money loop: **CASH / DUE / IN** (manual, weekly review + daily glance)
- Task loop: max 3 TODAY lines, venture prefix (M·/H·/F·/D·), 7-DAY spine, PARKED bucket
- Sequence: manual truth → Operate panel → (later) tab condensation
- Hard no: Plaid, sync, dashboards, gamification, nightly 21:00 ritual

**What shipped Jul 7:**

- **Operate tab** — primary morning surface with TODAY checklist (tap to complete), CASH/DUE strip, IN action card, collapsible edit fields
- **Park tab** — all former tabs (Hideout, You, Signal, Today rail, Physique, Recovery, Capital, legacy Now)
- **Legibility** — iPhone body 12→14pt; Operate uses 17pt tasks, 22pt cash
- **Docs locked** — `OPERATE_MODE_ROADMAP.md`

---

## Files to read first

| Priority | Path |
|----------|------|
| 1 | `docs/increments/OPERATE_MODE_ROADMAP.md` |
| 2 | `code/App/Increments/OperatePanel.swift` |
| 3 | `code/App/Increments/AppShell.swift` (CustomTabBar, RootView) |
| 4 | `code/App/Increments/SharedComponents.swift` (AppMetrics operate* tokens) |
| 5 | `docs/increments/PRODUCT_ARCHITECTURE.md` (Operate addendum) |

---

## Product truth (unchanged)

INCREMENTS is **routing intelligence**, not motivation. Silence when no signal. Operator sovereignty.

**Morning = Operate only.** Evening depth = Park → You. Never strategy essays above fold on execute surfaces.

---

## Operator instructions (what Brice should do this month)

**Daily (60–120 sec):** Open Operate → read TODAY + CASH + DUE NEXT → execute first IN action Mon–Tue if present.

**Sunday (15 min):** Reconcile MONEY + WEEK, rank IN, delete 1–3 PARKED, tap "Mark Sunday review done."

**Day-30 gate (Aug 6):**

1. Next bill from one open
2. Every IN row actioned within 72h
3. Four dated Sunday reviews

---

## Review smell tests

- Would Brice open this before Instagram? If not — why?
- Does Park feel like a junk drawer or a calm archive?
- Is TODAY checklist enough "smart todo" or does he need time blocks / reminders?
- Did we over-build or under-build for a survival month?

---

*Pack generated Jul 7, 2026 · BUILD SUCCEEDED · iPhone 17 Pro sim*
