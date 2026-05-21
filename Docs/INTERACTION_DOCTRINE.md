# INCREMENTS — Interaction Doctrine

**Version:** May 2026  
**Status:** Canonical

---

## What interaction should feel like

Like using a **trusted instrument** — not a feed, not a game, not a coach shouting over your shoulder.

- Immediate where execution matters  
- Calm where interpretation matters  
- Predictable input (especially time/pace-like fields — no cursor jump)  
- Disclosure before scroll when modes differ  

---

## Friction philosophy

| Context | Friction stance |
|---------|-----------------|
| **Execute** | Low — protective friction only (confirm irreversible, hold-to-adjust if needed) |
| **Reflect / read** | Low navigation friction — jump lists, collapse, remember section |
| **Interpret** | No extra taps to hide intelligence — collapse defaults instead |

**Acceptable protective friction:** confirming destructive edits, explicit log submit, Forge-style hold — not busywork.

**Unacceptable:** tap-to-reveal XP on every row, modal chains to see “why,” forced daily review essay.

---

## Progressive disclosure (canonical)

**Principle:** Show what the operator needs **for this moment**; tuck strategy, depth, and secondary context behind labeled collapses.

**Shipped patterns:**

| Surface | Default visible | Collapsed |
|---------|-----------------|-----------|
| Now (phone) | Priority, weather, first action | CONTEXT ↓ |
| Hideout dashboard | TODAY AT HIDEOUT | Experiment · friction · decisions |
| Intel | Operator card, distribution state | Traits · failure modes |
| Manual crash course | READ THIS FIRST | WHEN SIGNAL IS UNCLEAR ↓ |
| Physique / Recovery (phone) | Jump list + one section | Other sections via list, not pills |

**Reset behavior:** `deepReadExpanded` in crash course resets each visit — intentional (first open = core only). AppStorage only when persistence is product-true.

---

## Nonlinear reading

Evening **Doctrine**, **Manual**, **Physique**, **Recovery** assume:

- Operator may land mid-document  
- Jump navigation beats sequential wizard  
- iPad rail = zero-tap section switch  

Do not force scroll-from-top storytelling on reference surfaces.

---

## Sheets and modals

- **Log sheets** — one purpose line top; fields obvious; save = done  
- **Settings** — gear on You, not a tab slot consumer  
- **Focus mode** — optional deep work shell; not default Today experience  

Sheets dismiss back to execute — no nested coaching monologue.

---

## Motion (interaction layer)

See `DESIGN_DOCTRINE.md` — functional transitions only; collapses animate ~0.18–0.22s ease-out.

No haptic fireworks. Soft tab haptic OK.

---

## Notifications

**Almost nothing.** Surface has no evidence → no push copy.

Structural reminders only when explicitly specced — not engagement reactivation.

---

## Irreversible actions

- Calm confirmation  
- Plain language (“Delete this shift?”)  
- No guilt, no “are you sure you want to give up”  

---

## Anti-patterns

- Surprise interruptions mid-execute  
- Manipulative urgency (“last chance today”)  
- Streak-break shame dialogs  
- Auto-expanding coaching on every tab switch  
- Long scroll with no anchors on 8+ section reference tabs  
- Horizontal pill strip on phone for heavy reference (use vertical jump list)  

---

## iPad vs phone

| Pattern | iPad | Phone |
|---------|------|-------|
| Now | Master-detail | Single column + CONTEXT ↓ |
| You | Capital + 5 segments | Six segments + gear |
| Physique / Recovery | Left rail | Jump list + content |
| Hideout landscape | Dashboard left, work right | Single column tabs |

Do not shrink iPad to phone density “for consistency.”

---

*INCREMENTS Interaction Doctrine · May 2026 · Canonical*
