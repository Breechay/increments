# INCREMENTS — Operate Mode

**Status:** Locked · Jul 2026  
**Trigger:** Near-$0 runway · need daily money grip + 3-task execution without 8-tab cognitive load.

This doc is **canonical** for the Operate restructure. Council adjudication (6 agents + Claude + Chat) is consolidated here.

---

## The job

Open the app in the morning. In under 2 minutes, know:

1. **What money is doing** — cash on hand, what's due, what to collect
2. **What to do today** — max 3 lines, venture-prefixed
3. **How the week is shaped** — one line per day

Everything else lives under **Park** — depth when the task requires the full room.

---

## App shape (shipped Jul 2026)

| Tab | Label | Job |
|-----|-------|-----|
| 0 | **Operate** | Morning survival + smart todo |
| 1 | **Park** | Hideout · Signal · You · Today rail · Physique · Recovery · Capital · legacy Now |

**No third tab.** No Plaid. No charts. No sync. No auto-rollover. No nightly 21:00 ritual.

---

## Canonical fields

### MONEY

| Field | Rule |
|-------|------|
| **CASH** | One number — cash on hand right now |
| **DUE** | Next 14 days — `item · date · amount` (one per line) |
| **IN** | `who · amount · next action` — action verb required, not status |

### WEEK

| Field | Rule |
|-------|------|
| **TODAY** | Max 3 lines — prefix `M·` / `H·` / `F·` / `D·` |
| **7-DAY** | One line per day — `Mon — …` |
| **PARKED** | Captured, not scheduled — kill 1–3 each Sunday |

---

## Daily rhythm

| When | What | Duration |
|------|------|----------|
| **Morning** | Open Operate → read TODAY + CASH + DUE NEXT + IN action | 60–120 sec |
| **Mon–Tue** | Execute IN collection actions before noon | — |
| **Saturday** | Silent — no review | — |
| **Sunday** | Reconcile MONEY + WEEK, rank IN (amount × likelihood × speed), delete 1–3 PARKED, tap **Mark Sunday review done** | ~15 min |

**Rejected:** double daily ritual (07:00 + 21:00). Evening close-out is **weekly only**.

---

## Sunday review output (four blocks)

1. **Runway line** — CASH minus next 14-day DUE total (one sentence)
2. **Collection triage** — IN rows ranked by amount × likelihood × speed
3. **Due-date risks** — anything inside 72 hours without cash plan
4. **Next spine** — rewrite 7-DAY for the coming week

**Addition (locked):** **Deletion log** — 1–3 PARKED items killed permanently each week so PARKED doesn't become a swamp.

---

## Hard no list (unanimous — do not reopen without operator sign-off)

- Plaid / bank sync
- Categories / budgeting taxonomy
- Forecasting / charts / dashboards
- Unified inbox
- Gamification / streaks
- Auto-rollover of incomplete tasks
- Multi-agent automation
- Merged venture task swamp (prefixes prevent this)

---

## Council sequence (adjudicated)

```
Manual truth first → Operate tab → Park consolidation → (future) 2-tab identity only if earned
```

| Phase | Surface | Gate |
|-------|---------|------|
| **1** | Paper / Notes optional — same six fields | Loop survives 7–14 days |
| **2** | `OperateTabView` — **shipped** | Daily use |
| **3** | Park holds depth tabs | 30 days |
| **4** | Further shell trim | Only if Operate + Park usage data proves it |

**Day-30 gate (panel earned):**

1. Next bill date from one open — no hunting
2. Every IN row actioned within 72 hours
3. Four dated Sunday reviews in history

Fail any → fix the loop, not the surface.

---

## Code map

| File | Role |
|------|------|
| `OperatePanel.swift` | `OperateTabView`, `ParkTabView`, `ParkDestination`, storage keys |
| `AppShell.swift` | 2-tab `CustomTabBar`, legacy tab migration |
| `SharedComponents.swift` | `operate*` typography scale + global iPhone body bump |
| `Models.swift` | `AppState.parkRoute` deep-link |

Storage: `@AppStorage` keys in `OperateStorage` — local only. Sunday reviews append to `operate_weekly_review_history` (max 8); header shows `REVIEWS · n/4`.

---

## Roadmap (Jul 2026 → Aug 2026)

### This week (Jul 7+)

- [x] Ship Operate + Park tabs
- [x] Bump iPhone legibility (body 14pt base, Operate task 17pt)
- [ ] **Operator:** Fill CASH / DUE / IN for August after bill pay
- [ ] **Operator:** Write first WEEK block (7-DAY + 3 TODAY lines)
- [ ] First Sunday review Jul 13

### Week 2–4

- [ ] Prove morning open < 2 min for 14 consecutive days
- [ ] IN actions cleared Mon–Tue when rows exist
- [ ] PARKED deletion log every Sunday — no growth

### Day 30 (Aug 6)

- [ ] Run three gate checks (bill memory, IN 72h, four reviews)
- [ ] Decide: keep Park as-is, or demote unused destinations

### Not before day 30

- Tab bar rename to Operate · Read
- Capital ↔ Operate merge
- Plaid or any bank connection
- Widget / notification nudges

---

## Operator instructions — start tonight

After paying bills, open **Operate** and paste this skeleton:

**CASH**  
`[number after today's payments]`

**DUE**  
```
Rent · Aug 1 · $____
[card] · Aug __ · $____
[insurance] · Aug __ · $____
```

**IN**  
```
[name] · $____ · [text/call/send by Tue]
```

**TODAY** (3 max)  
```
M· Confirm August DUE list complete
H· [one Hideout action]
D· [one other if needed]
```

**7-DAY**  
```
Mon — Money-in · IN actions first
Tue — Hideout growth
Wed — 
Thu — 
Fri — Hideout shift prep if applicable
Sat — silent
Sun — 15-min review + deletion log
```

**PARKED**  
Anything you're not doing this week — one line each.

---

## Related docs

- `PRODUCT_ARCHITECTURE.md` — Operate mode addendum
- `PRODUCT_DOCTRINE.md` — routing not motivation (unchanged)
- `INCREMENTS_Master.md` — engineering changelog
- `FORM-iOS/docs/BRICE_OS/CONDUCT_FILTER.md` — weekly delete filter

---

*Manual truth first. Panel second. App restructure last. Operate mode skips straight to panel because the operator asked for code — fields remain manual.*
