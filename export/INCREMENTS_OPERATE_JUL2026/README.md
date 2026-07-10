# INCREMENTS — Operate Mode Review Pack (Jul 2026)

**Purpose:** Claude + Chat review of the Jul 7 Operate restructure — 2-tab shell, survival loop, legibility pass.

**Build:** INCREMENTS scheme · iPhone 17 Pro sim · BUILD SUCCEEDED (Jul 7, 2026)

---

## What changed since last audit pack

| Before (Jul 5 audit) | After (this pack) |
|----------------------|-------------------|
| 7-tab bar (Now · Today · …) | **2 tabs:** Operate + Park |
| Morning spread across Now/Today | **Operate** = CASH / DUE / IN + TODAY checklist |
| Capital categorical in You | Operate manual fields + Capital in Park |
| iPhone body 12pt | iPhone body **14pt** + Operate-specific scale |

**New file:** `code/App/Increments/OperatePanel.swift` — `OperateTabView`, `ParkTabView`, `ParkDestination`

**Canonical protocol:** `docs/increments/OPERATE_MODE_ROADMAP.md`

---

## Read order for reviewers

1. `REVIEW_BRIEF.md` — paste into Claude/Chat with this zip
2. `docs/increments/OPERATE_MODE_ROADMAP.md` — locked council consensus + operator instructions
3. `docs/increments/PRODUCT_ARCHITECTURE.md` — Operate mode addendum
4. `code/App/Increments/OperatePanel.swift` — primary new surface
5. `code/App/Increments/AppShell.swift` — tab bar + legacy migration
6. `code/App/Increments/SharedComponents.swift` — `operate*` typography tokens

---

## Swift map (Jul 2026)

| Surface | File | Job |
|---------|------|-----|
| **Operate** (tab 0) | `OperatePanel.swift` | Morning survival — money + 3-line todo |
| **Park** (tab 1) | `OperatePanel.swift` | Depth archive — links to all former tabs |
| Today rail | `TodayViews.swift` | Park → Execute |
| Hideout | `HideoutViews.swift` | Park → Work |
| Signal | `SignalViews.swift` | Park → Work |
| You | `YouTabViews.swift`, `YouDoctrineViews.swift` | Park → Evening |
| Physique | `PhysiqueViews.swift` | Park → Body |
| Recovery | `RecoveryViews.swift` | Park → Body |
| Capital | `CapitalViews.swift` | Park → Money depth |
| Legacy Now | `TodayViews.swift` (`HomeView`) | Park → Archive |
| Shell | `AppShell.swift` | 2-tab bar, seed, migration |
| Models | `Models.swift` | `AppState.parkRoute` deep-link |
| Shared UI | `SharedComponents.swift` | AppMetrics + legibility bump |

---

## Review questions (for agents)

1. Does Operate answer "what do I do this morning?" in one open?
2. Is Park enough archive without becoming a second battlefield?
3. Are the six manual fields sufficient near $0 — anything missing that isn't dashboard theater?
4. Legibility — readable at arm's length on iPhone without opening edit fields?
5. What should stay parked vs promoted after 30 days of use?

---

## Not included

- Xcode project / assets / PDFs
- `Archive/` historical snapshots
- Full BRICE-OS cross-repo (light kernel + active reality only)

---

*Operator context: post bill-pay Jul 7 · August runway prep · survival month.*
