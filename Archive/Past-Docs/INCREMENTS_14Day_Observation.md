# INCREMENTS — 14-Day Field Observation
## Session Protocols · What to Watch · What to Record

*This is not a tracking sheet. It is a field notebook.*
*You are the instrument. The app is the subject. Observe without optimizing.*

---

## The One Question That Matters

> Do Session Protocols reduce the friction of starting — or do they add a step before starting?

Everything else in this document is in service of answering that question honestly after 14 days.

---

## What Was Just Built

**Session Protocols (Phase 3 Priority 1)** — a distinct action type where the session is the unit of completion and the steps are navigation scaffolding only.

Four defaults are seeded:
- **Morning Protocol** — Health, daily, 5 steps, cue: Wake
- **Evening Shutdown** — Operations, daily, 5 steps, cue: After 9pm
- **Grooming Protocol** — Health, daily, 5 steps, cue: Before bed or morning
- **Weekly Reset** — Operations, weekly, 5 steps, cue: Sunday evening

You can edit these, delete them, add your own. The cap is 6 steps per protocol. Max sessions: use judgment — if you have more than 5 active protocols appearing in Today, something is wrong.

---

## What To Notice — By Week

### Week 1 (Days 1–7)
*Novelty is present. Don't mistake novelty for signal.*

Notice whether you actually **open** the protocols or scroll past them. There's a difference between:
- "I opened the protocol and ran it" — signal
- "I saw the protocol and felt good about having it" — noise

Notice whether the **step list** inside the execution view helps you or feels like reading instructions you already know. If you already have the sequence memorized, the steps may be redundant. That's fine — you can simplify them to 2–3 anchor points rather than full detail.

Notice whether you **exit early** (tap "Protocol closed." before the final step) or run it to the end. Neither is wrong. But if you're consistently closing early on the same step, that step may not belong.

Notice whether completing a protocol produces **actual relief** — the "loop closed" feeling the spec describes — or just a checkbox dopamine hit. The former means the feature is working. The latter means it's becoming theater.

### Week 2 (Days 8–14)
*Novelty has faded. This is where real signal lives.*

Notice which protocols you still open and which you skip without guilt. The ones you skip may need to be deleted, simplified, or re-cued. The ones you run on hard days are the load-bearing ones.

Notice whether the **cue** is actually triggering the protocol or whether you're opening it voluntarily. The behavioral science says cue-triggered behavior is more durable than intention-triggered. If you're having to remember to run the Evening Shutdown rather than it being pulled by the cue, the cue isn't anchored to anything real.

Notice whether you've started **designing new protocols** instead of running the existing ones. If so, that's the Restorative + Analytical pattern the spec warned about — protocol authorship substituting for protocol execution. Notice it. Don't judge it. Just note it.

---

## Specific Things to Record

You don't need to log these obsessively. Once, at day 7 and once at day 14. Rough notes are enough.

**Which protocols did you actually run this week?**
Just the names. No count, no streak, no percentage.

**Which protocols appeared and got skipped?**
Not a shame question. A design question. Something may need to change.

**Did any protocol get edited?** What changed and why?
If you shortened steps, that's signal that steps were too granular.
If you added steps, that's signal that the sequence felt incomplete.

**Did the execution view feel like overhead or like support?**
"Overhead" = another thing to navigate before the actual behavior.
"Support" = it carried me through something I'd have postponed otherwise.

**Did any protocol surface on a hard day and help?**
This is the highest-value observation. Recovery-state executive function is the exact condition sessions were designed for. If the Grooming Protocol ran on a day when you wouldn't have otherwise started — that's the feature working.

**Did you build any new protocols?**
Name them here. Note whether you ran them more than twice.

---

## Signals That Mean "Keep It"

- You run it on days when you have low energy, not just on good days
- The step list reduced a moment of "where do I start" ambiguity
- Completing it produced a sense of operational closure, not just completion
- You stopped thinking about the steps mid-execution because they became the sequence
- You edited it to be simpler, not more elaborate

## Signals That Mean "Change It"

- You consistently close before the final step on the same protocol
- You open it and feel like you're "reporting" rather than being guided
- The step count is too high and you skim it
- The cue doesn't actually trigger anything — you have to remember it intentionally
- You've run it zero times in 7 days

## Signals That Mean "Delete It"

- You scroll past it without guilt every day
- The behavior happens without it (the protocol is redundant, not harmful)
- It creates a sense of "I should be doing this" on days when you're not
- Opening it makes you feel behind rather than oriented

---

## What the Next Agent Needs to Know

When you return after 14 days, give the agent this document with your field notes filled in above. Then the agent will have what it needs to decide:

**If sessions worked:** Move to Priority 2 — Maintenance Cadence. The behavioral foundation is stable enough to add the next layer.

**If sessions partially worked:** Audit the protocol designs before building anything new. The architecture is right but the content needs calibration.

**If sessions didn't work:** Do not build Priority 2. Understand why sessions failed first. The most likely causes: the cues aren't anchored to real environmental triggers, the steps are too granular, or the execution view is creating overhead rather than reducing it. Fix one of those — don't add a new feature.

---

## Priority 2 — What's Waiting (Don't Build Yet)

For reference only. Do not open Xcode for these until day 14.

**Maintenance Cadence** — interval-based state reporting for things like air filter, deep clean, weekly apartment reset, financial review. Lives in the Increments tab, not Today. Shows state (quiet / upcoming / due) — never urgency language, never red, never "overdue."

**Hydration Rhythm** — a quiet card in Today, not a counter. Single tap to log. Shows "Last: 2h ago." Nothing else. No target, no streak, no daily completion.

**Financial Clarity Layer** — runway state (Stable / Watch / Act), next obligation, inflow signal. Lives in Operations. Manual input only. No budgeting, no categories, no scores.

These are built in that order only. One at a time. 14 days of real use between each.

---

## The Guardrails — Restated Here for You, Not Just the Agent

> No streak shaming. No failure language.
> If the app creates pressure, remove items.
> Gentle decay only — never harsh penalties.
> The app is a constraint, not a canvas.

**And specifically for protocols:**
> If you spend more time editing protocols than running them, stop editing.
> If a protocol makes you feel behind on days you skip it, delete it.
> The reward is procedural closure — not protocol authorship.

---

## The Opening Prompt for the Next Session

Paste this when you return:

```
You are continuing work on INCREMENTS v1.3.
Read INCREMENTS_Agent_Handoff.md and INCREMENTS_Phase3_Evolution.md first.
Then read INCREMENTS_14Day_Observation.md — I've filled in field notes from 14 days of using Session Protocols.
The single Swift file is IncrementsApp.swift.
Based on the field notes, advise whether to proceed to Priority 2 (Maintenance Cadence)
or calibrate the existing session architecture first.
Do not build anything until we've discussed what the field notes show.
```

---

*INCREMENTS · 14-Day Field Observation · Session Protocols*
*"The reward is procedural closure — not protocol authorship."*
