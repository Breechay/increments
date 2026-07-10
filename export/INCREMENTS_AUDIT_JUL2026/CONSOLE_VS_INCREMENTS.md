# INCREMENTS vs HTML / Web Consoles — Retirement Read

**Question:** Can you retire the standalone consoles and run everything from INCREMENTS?

**Short answer:** **Yes for daily operator work.** Retire HTML gate boards and duplicate ledgers. **Keep** Hideout web console (or merge Square sync into INCREMENTS later) for venue math INCREMENTS does not compute yet.

---

## Surface inventory

| Surface | Type | Primary job | Persists? |
|---------|------|-------------|-----------|
| **INCREMENTS app** | Native iOS (SwiftData + CloudKit) | Execute + route + log | Yes — actions, shifts, distribution weeks, ledger |
| **forge-operating-console.html** | Static HTML + localStorage | Forge 90-day gates, monetization spine, do-not-touch list | Browser only |
| **form-stranger-launch-console.html** | Static HTML + localStorage | FORM stranger-proof gates, Reddit checklist | Browser only |
| **brice_operator_console.html** | Static HTML (synced from manual) | Direction, ventures, long-form operator manual | Browser only |
| **hideout-ops-console** (web) | Vite + Supabase + Square API | Daily/weekly venue ledger, Square pull, future COGS | Supabase |
| **hideout_console_v16.html** | Static HTML (source for web) | Same as web console, pre-Supabase | localStorage |

---

## Overlap matrix

| Capability | INCREMENTS | Forge HTML | FORM HTML | Brice manual HTML | Hideout web |
|------------|:----------:|:----------:|:---------:|:-----------------:|:-----------:|
| Daily schedule / Today stack | ✅ | — | — | — | — |
| Hideout shift log + 30-day avg | ✅ | — | — | — | ✅ (Square auto-fill) |
| Growth systems checklists | ✅ | — | — | — | partial |
| Monday distribution block | ✅ Signal | — | — | — | — |
| Friday signal log | ✅ Signal | — | — | — | — |
| Decision ledger (FORM/Forge captures) | ✅ Signal | — | — | — | — |
| Venture status + night read | ✅ You | partial | partial | ✅ | — |
| Forge v1 gate / post-gate rotation | ✅ Signal + You | ✅ gates | — | — | — |
| Forge monetization gates (0–5) | ❌ summary only | ✅ full | — | — | — |
| FORM stranger-proof gates | ❌ summary only | — | ✅ full | — | — |
| Long operator manual / direction | ✅ You → Manual | — | — | ✅ | — |
| Square daily revenue sync | ❌ | — | — | — | ✅ |
| Item-level COGS / margin (roadmap) | ❌ | — | — | — | 🔜 planned |
| Checkbox gate progress (localStorage) | N/A (real models) | ✅ | ✅ | — | ✅ |

---

## What each console was for

### Forge operating console
**Job:** Lock the 90-day founding-athlete spine — gates 0–5, paywall copy, cardio-not-gate, TrustMRR pause, “do not touch” list.

**INCREMENTS today:** Signal tab knows Forge gate cleared + post-gate Monday rotation. You → Ventures has status paragraph. **Does not** surface full gate rail or monetization checklist.

**Retire?** **Yes, after one-time import** — copy gate states into You → Ventures or a small “Gates” subsection under Forge venture card. Doctrine stays in markdown (`FORGE_OPERATING_CONSOLE.md`); execution lives in Signal.

### FORM stranger launch console
**Job:** Stranger-proof launch sequence — onboarding gate, Gabriel walk, Reddit hold, proof wall.

**INCREMENTS today:** You → FORM venture + coaching-day banner in Signal. **No** checkbox gate UI.

**Retire?** **Yes, with caveat** — if FORM public launch is imminent, migrate the 5–6 checkboxes into Signal or You (one screen, not a separate browser tab). Until then, keep HTML or copy checklist into a SwiftData `LaunchGate` model.

### Brice operator console (manual HTML)
**Job:** Readable direction doc — wants, sequencing, distribution principles.

**INCREMENTS today:** You → Manual, Doctrine, Ventures **already subsume this** for in-app reading. HTML is a prettier export of `BRICE_OPERATOR_MANUAL.md`.

**Retire?** **Yes** — manual markdown + INCREMENTS You tab is the canonical read path per `DISTRIBUTION_OPERATING_SYSTEM.md`.

### Hideout ops console (web)
**Job:** Venue operator instrument — Square-backed daily numbers, weekly review, future inventory/COGS.

**INCREMENTS today:** Hideout tab = growth bands, shift log, playbooks, friction audit, partnership sprint. **Manual revenue entry.** No Square API. No item-level margin.

**Retire?** **Not yet** — unless you accept manual shift logging forever OR build Square read-only into INCREMENTS Hideout tab (Phase A from `OPERATOR_INTELLIGENCE_ROADMAP.md` is ~1 week of work).

**Recommended split:**
- **INCREMENTS** = growth, distribution, nervous-system economics, operator schedule
- **Hideout web** = Square truth + future COGS (or merge Phase A into INCREMENTS and retire web)

---

## Roadmap comparison

| Roadmap doc | Lives in | INCREMENTS coverage |
|-------------|----------|---------------------|
| `DISTRIBUTION_OPERATING_SYSTEM.md` | FORM-iOS/docs | **Signal tab implements v2.3 spec** |
| `INCREMENTS_DISTRIBUTION_TAB_SPEC.md` | INCREMENTS/Docs | **Native implementation** |
| `OPERATOR_ROADMAP_JUNE2026.md` | FORM-iOS/docs | Partial — You ventures; no “parked products” board |
| `FORGE_90_DAY_ROADMAP.md` / operating console | FORM-iOS/docs | Doctrine only in app; gates in HTML |
| `OPERATOR_INTELLIGENCE_ROADMAP.md` | hideout-ops-console | **Not in INCREMENTS** — venue intelligence |
| `ACTIVE_REALITY.md` | FORM-iOS/docs | Reflected in seed/migration; not a live tab |

---

## Retirement recommendation (phased)

### Phase 1 — Now (low risk)
- Stop opening **brice_operator_console.html** — use INCREMENTS You → Manual/Doctrine
- Use **Signal tab** as sole Monday/Friday distribution surface
- Keep Forge/FORM HTML gates until checkboxes migrated (optional)

### Phase 2 — After checkbox migration
- Archive `forge-operating-console.html` + `form-stranger-launch-console.html` to `export/` only
- Add compact **Gate status** rows under You → Ventures (Forge + FORM) — read-only from AppStorage keys Signal already uses

### Phase 3 — Hideout console decision
**Option A (minimal):** Keep hideout-ops-console for Square + COGS only; INCREMENTS for everything else.

**Option B (unify):** Port Square daily-summary into INCREMENTS Hideout tab (prefill shift log). Retire web console when COGS not needed yet.

**Option C (full unify):** Build COGS in INCREMENTS — largest scope; only if web console feels like duplicate friction.

---

## Does INCREMENTS “do it all”?

**For Brice-as-operator across ventures:** **Almost.**

| Domain | INCREMENTS owns it? |
|--------|---------------------|
| Personal execution (wake, training, recovery) | ✅ |
| Hideout growth + shift memory | ✅ |
| Distribution plant/log/adjust | ✅ |
| Venture orientation + doctrine | ✅ |
| FORM/Forge product gates (detailed) | ⚠️ partial — add gate rows or keep HTML briefly |
| Hideout Square sync + margin math | ❌ — web console or future INCREMENTS build |
| RunCards distribution | ⚠️ spec includes it; tab paused |

**The consoles were scaffolding** — static gate boards and readable manuals while INCREMENTS caught up. Jul 2026 refresh closes the schedule/Hideout gap. **Signal + You already implement the distribution OS the HTML boards pointed at.**

Retiring HTML consoles is coherent. Retiring **Hideout web** only makes sense after Square prefill lands in INCREMENTS or you accept manual logging.
