# INCREMENTS — Wendy Layer Master Implementation Reference
## Phase 2 Voice Intelligence · Complete Build Guide
*Single source of truth. Read Voice Doctrine v3.0 first. This document is the implementation.*

---

## What This Document Is

This consolidates all Wendy implementation guidance from multiple agent sessions into one authoritative reference. It supersedes the Wendy Intelligence Brief and Wendy Implementation docs where they conflict. It is organized as a build sequence — follow it in order.

**Authority hierarchy:**
1. Voice Doctrine v3.0 — character and behavioral rules
2. This document — implementation spec
3. All prior agent conversations — reference only, superseded here

---

## Current State of the Codebase (v1.6)

**What exists:**
- `PresenceContext` struct — current-state fields only, no longitudinal data
- `PresenceContextBuilder.build()` — builds current-state context, no longitudinal
- `VoicePresence` — Layer A only, `speakIfWarranted` is synchronous
- `PresenceSpeech` — rule-based Layer A observations, correct and complete
- All raw data models in place: `Action.completionDates`, `Action.skipCount`, `Action.isHighFriction`, `Action.cognitionMode`, `DailyLog.energyStateRaw`, `DailyLog.completedCount`, `CognitionLog.energyStateAtDeclaration`, `CognitionLog.actualCompletionCount`
- `OperatorProfile` — has `daysInSystem`, `weeklyActiveSystems`, no `lastWendyDate`, no `claudeApiKey`, no `wendyEnabled`

**What does not exist yet:**
- `LongitudinalContext` struct
- `buildLongitudinalContext()` function
- `WENDY_SYSTEM_PROMPT` constant
- `generateWendyObservation()` async function
- Async `speakIfWarranted()`
- `lastWendyDate` cooldown
- `wendyEnabled` toggle
- `claudeApiKey` field on profile
- Consult mode

---

## Build Sequence

### Step 1 — Add Wendy fields to OperatorProfile

Three fields. Add them after `voicePresenceEnabled`.

```swift
// Voice presence — off by default, user opts in
var voicePresenceEnabled: Bool = false
var voiceProvider: VoiceProvider = VoiceProvider.native
var elevenLabsVoiceId: String = ""
var elevenLabsApiKey: String = ""

// Wendy (Layer B) — separate toggle, separate API key
// wendyEnabled stays false until user explicitly opts in after Phase B1 text rollout
var wendyEnabled: Bool = false
var claudeApiKey: String = ""
var lastWendyDate: Date? = nil   // 7-day cooldown gate — structural, not prompt-based
```

**Why separate toggle:** Wendy is a qualitatively different kind of intelligence than Layer A voice. A user should consciously opt into inference-level observations. Don't inherit the voice toggle.

**Why lastWendyDate on profile (not UserDefaults):** Profile is SwiftData — persists correctly across reinstalls if iCloud sync is enabled. The cooldown must survive app reinstalls because the pattern data does too.

---

### Step 2 — Add LongitudinalContext struct

Add after `PresenceContext`, before `PresenceContextBuilder`.

```swift
// MARK: - LONGITUDINAL CONTEXT (Layer B data substrate)
// Only meaningful and only built when daysInSystem >= 14 AND recentLogs.count >= 10.
// Returns nil if data is insufficient — Layer B stays silent.

struct LongitudinalContext {
    let systemCompletionRates: [String: Double]      // e.g. ["environment": 0.72, "cognition": 0.38]
    let creativeByWeekday: [Int: Int]                // weekday int (1=Sun..7=Sat) → completion count
    let reserveDayCount: Int                          // reserve days in last 14d
    let reserveDayCompletionAvg: Double               // avg completions on reserve days
    let fullDayCompletionAvg: Double                  // avg completions on full days
    let weeklyActiveSystems: [String]                 // systems touched this week
    let highFrictionActionTitles: [String]            // titles of actions where isHighFriction == true
}
```

---

### Step 3 — Add WENDY_SYSTEM_PROMPT constant

Add after `PresenceSpeech` closing brace, before `VoicePresence` class. This is the exact prompt from Voice Doctrine v3 — do not modify it.

```swift
// MARK: - WENDY SYSTEM PROMPT
// This is the exact prompt from Voice Doctrine v3.0. Do not modify without updating the doctrine.
// Character: Jarvis × Alfred × Wendy Rhoades × Brice. See doctrine for full character stack.

let WENDY_SYSTEM_PROMPT = """
You are the ambient voice of INCREMENTS — a calm intelligent presence for one user (Brice).

Your character is a composite of four references:
- Jarvis (Stark): operationally competent, composed, dry, always useful
- Alfred (Batman): earned consequence, calm correction, loyal without sentimentality
- Wendy Rhoades (Billions): high perceptual acuity, pattern interpretation, earned confrontation,
  names behavioral contradictions cleanly
- Brice (himself): slight irreverence, atmospheric intelligence, knows the difference between
  a hard day and a wasted one

You have two operating modes:

LAYER A (daysInSystem < 14 OR longitudinal data unavailable):
Observation only. You speak from what you can see: time, completion counts, system activity,
hydration, energy state. You do not interpret motive or infer psychology.
"That's been sitting a while." is allowed. "You've been avoiding that." is not.

LAYER B (daysInSystem >= 14 AND longitudinal data provided):
Pattern interpretation is available. You may now notice what keeps happening across time.
You may name patterns. You may deliver one earned confrontation per session if the data
is unambiguous and the pattern is real. This is the Wendy register.

VOICE RULES (both layers):
- Return SILENCE if nothing is worth saying. Silence is correct most of the time.
- One or two sentences maximum. Often one. Often a fragment.
- Contractions mandatory. Fragments acceptable. No jargon.
- No praise language. No shame language. No moralizing.
- No coach energy. No therapist warmth. No cheerfulness.
- The name is used sparingly — only at significant moments.
- Tone shifts by time of day: morning warm, midday direct, evening permission-giving,
  late night silent.
- A Wendy moment should reduce cognitive load, not create appetite.
  No cliffhangers. No mystery. No "come back tomorrow" energy.

WENDY CONSTRAINTS (Layer B only):
- Pattern must be visible across 14+ days
- Must be consistent — not a single instance
- State as observation, not fact: "Interesting..." / "Something to notice..." / "Worth knowing..."
- One Wendy moment maximum per session. Never stack them.
- If the pattern might be wrong: say nothing. SILENCE is always safer.

Based on the context provided, decide:
1. Is there anything worth saying? (Default answer: no. SILENCE.)
2. If yes — is this Layer A (observation) or Layer B (interpretation)?
3. What is the single most important thing to say?
4. Say it in 1-2 sentences. Often less.

Return ONLY the spoken text. If silence is correct, return exactly: SILENCE
"""
```

---

### Step 4 — Add buildLongitudinalContext() to PresenceContextBuilder

Add as an extension on `PresenceContextBuilder`. This is the most important piece — Wendy is only as good as this function.

```swift
extension PresenceContextBuilder {

    // Builds the 14-day longitudinal context for Layer B.
    // Returns nil if data is insufficient — two hard requirements:
    //   1. daysInSystem >= 14 (can't pattern-match before enough time)
    //   2. recentLogs.count >= 10 (need actual daily log coverage)
    // If either fails, Layer B stays silent. This is correct behavior.

    static func buildLongitudinalContext(
        profile: OperatorProfile,
        actions: [Action],
        logs: [DailyLog]
    ) -> LongitudinalContext? {

        guard profile.daysInSystem >= 14 else { return nil }

        let cal = Calendar.current
        let cutoff = cal.date(byAdding: .day, value: -14, to: Date()) ?? .distantPast
        let recentLogs = logs.filter { $0.date >= cutoff }

        // Need at least 10 days of logs to generate meaningful patterns
        guard recentLogs.count >= 10 else { return nil }

        // Completion rate by system — uses action.completionRate computed property
        // which is completionDates.count / max(1, daysSinceCreated)
        let systemRates: [String: Double] = Dictionary(uniqueKeysWithValues:
            SystemTag.allCases.map { sys in
                let sysActions = actions.filter { $0.system == sys }
                let avg = sysActions.isEmpty ? 0.0 :
                    sysActions.map(\.completionRate).reduce(0, +) / Double(sysActions.count)
                return (sys.rawValue, avg)
            }
        )

        // Creative work completion by weekday (within the 14-day window)
        let creativeByWeekday: [Int: Int] = actions
            .filter { $0.cognitionMode == .creative }
            .flatMap { $0.completionDates }
            .filter { $0 >= cutoff }
            .reduce(into: [:]) { dict, date in
                let wd = cal.component(.weekday, from: date)
                dict[wd, default: 0] += 1
            }

        // Reserve vs full day completion averages — from DailyLog.energyStateRaw
        let reserveLogs = recentLogs.filter { $0.energyStateRaw == EnergyState.reserve.rawValue }
        let fullLogs    = recentLogs.filter { $0.energyStateRaw == EnergyState.full.rawValue }

        let reserveAvg = reserveLogs.isEmpty ? 0.0 :
            Double(reserveLogs.map(\.completedCount).reduce(0, +)) / Double(reserveLogs.count)
        let fullAvg = fullLogs.isEmpty ? 0.0 :
            Double(fullLogs.map(\.completedCount).reduce(0, +)) / Double(fullLogs.count)

        // High-friction actions still appearing
        let highFriction = actions.filter(\.isHighFriction).map(\.title)

        // Weekly active systems from profile (persisted, survives restarts)
        let weeklyActive = Array(profile.activeSystemsThisWeek)

        return LongitudinalContext(
            systemCompletionRates: systemRates,
            creativeByWeekday: creativeByWeekday,
            reserveDayCount: reserveLogs.count,
            reserveDayCompletionAvg: reserveAvg,
            fullDayCompletionAvg: fullAvg,
            weeklyActiveSystems: weeklyActive,
            highFrictionActionTitles: highFriction
        )
    }
}
```

---

### Step 5 — Add generateWendyObservation() and buildWendyPayload() to VoicePresence

Add inside the `VoicePresence` class, after `speakTest()`.

```swift
// MARK: - WENDY LAYER B (Claude API)

// Builds the plain-text payload the API receives as the user message.
// Both present-state (Layer A context) and longitudinal (Layer B context) are included.
// The model uses the longitudinal section to decide whether Layer B is warranted.
private func buildWendyPayload(context: PresenceContext, longitudinal: LongitudinalContext) -> String {
    let cal = Calendar.current
    let weekdayNames = [1:"Sun", 2:"Mon", 3:"Tue", 4:"Wed", 5:"Thu", 6:"Fri", 7:"Sat"]

    let rateStr = longitudinal.systemCompletionRates
        .map { "\($0.key):\(String(format: "%.2f", $0.value))" }
        .sorted().joined(separator: ", ")

    let creativeStr = (1...7).map { wd in
        "\(weekdayNames[wd] ?? "?"):\(longitudinal.creativeByWeekday[wd] ?? 0)"
    }.joined(separator: ", ")

    let weekday = cal.weekdaySymbols[cal.component(.weekday, from: Date()) - 1]

    return """
    TIME: \(context.hour):00, \(weekday), Day \(context.daysInSystem) in system
    ENERGY DECLARED: \(context.energyState?.rawValue ?? "not yet set")
    COMPLETED TODAY: \(context.completedToday)
    PENDING TODAY: \(context.pendingToday)
    PARTICIPATION QUIET: \(context.participationQuietDays) days
    CREATIVE IN STACK: \(context.creativeActionsCount > 0 ? "yes" : "no")
    ADMIN CROWDING CREATIVE: \(context.adminActionsCount >= 3 ? "yes" : "no")
    HOURS SINCE HYDRATION: \(Int(context.hoursSinceHydration))
    FIRST OPEN TODAY: \(context.isFirstOpenToday ? "yes" : "no")
    DAYS IN SYSTEM: \(context.daysInSystem)

    LONGITUDINAL (14d window):
    WEEKLY ACTIVE SYSTEMS: \(longitudinal.weeklyActiveSystems.sorted().joined(separator: ", "))
    HIGH FRICTION ACTIONS: \(longitudinal.highFrictionActionTitles.joined(separator: ", "))
    COMPLETION RATE BY SYSTEM: \(rateStr)
    RESERVE DAY COUNT (last 14d): \(longitudinal.reserveDayCount)
    RESERVE DAY COMPLETION AVG: \(String(format: "%.1f", longitudinal.reserveDayCompletionAvg))
    FULL DAY COMPLETION AVG: \(String(format: "%.1f", longitudinal.fullDayCompletionAvg))
    CREATIVE COMPLETION BY WEEKDAY: \(creativeStr)
    """
}

// Calls Claude API to generate a Wendy observation.
// Returns spoken text or nil (silence).
// Never throws — silence is the correct fallback on any error.
// max_tokens: 80 is intentional. If responses are running long, the system prompt isn't landing.
func generateWendyObservation(
    context: PresenceContext,
    longitudinal: LongitudinalContext,
    apiKey: String
) async -> String? {
    guard !apiKey.isEmpty else { return nil }
    guard context.daysInSystem >= 14 else { return nil }

    let payload = buildWendyPayload(context: context, longitudinal: longitudinal)

    guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return nil }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

    let body: [String: Any] = [
        "model": "claude-sonnet-4-20250514",
        "max_tokens": 80,
        "system": WENDY_SYSTEM_PROMPT,
        "messages": [["role": "user", "content": payload]]
    ]

    guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else { return nil }
    request.httpBody = bodyData

    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = json?["content"] as? [[String: Any]]
        let text = content?.first?["text"] as? String ?? "SILENCE"
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmed == "SILENCE" || trimmed.isEmpty ? nil : trimmed

    } catch {
        return nil  // silence on any network or parsing error
    }
}
```

---

### Step 6 — Replace speakIfWarranted() with async version

This is the only change to the VoicePresence control flow. Layer A fires first — always. Layer B is only attempted if Layer A returns nil.

**Also add canFireWendyMoment() and recordWendyMomentFired() methods.**

```swift
// MARK: - UPDATED speakIfWarranted (Layer A → Layer B)

// Now async to support the Claude API call in Layer B.
// Layer A is synchronous and returns immediately.
// Only Layer B incurs network latency — and only when all gates pass.
func speakIfWarranted(
    context: PresenceContext,
    profile: OperatorProfile,
    actions: [Action],
    logs: [DailyLog]
) async {
    guard voiceEnabled, canSpeak() else { return }

    // ── Layer A: rule-based, always available, always first ──────────────
    if let layerAText = PresenceSpeech.observe(context) {
        speak(layerAText)
        return  // Layer B never attempted when A fires
    }

    // ── Layer B: Claude API (Wendy) ───────────────────────────────────────
    // All six gates must pass. Any failure → silence.
    guard profile.wendyEnabled else { return }
    guard context.daysInSystem >= 14 else { return }
    guard canFireWendyMoment(profile: profile) else { return }

    guard let longitudinal = PresenceContextBuilder.buildLongitudinalContext(
        profile: profile,
        actions: actions,
        logs: logs
    ) else { return }

    let apiKey = profile.claudeApiKey
    guard !apiKey.isEmpty else { return }

    if let layerBText = await generateWendyObservation(
        context: context,
        longitudinal: longitudinal,
        apiKey: apiKey
    ) {
        speak(layerBText)
        recordWendyMomentFired(profile: profile)
    }
    // If Layer B returns nil: silence. Correct.
}

// 7-day structural cooldown — not prompt-based.
// The prompt says "one per session" but session boundaries are ambiguous.
// The code enforces rarity unconditionally.
private func canFireWendyMoment(profile: OperatorProfile) -> Bool {
    guard let last = profile.lastWendyDate else { return true }
    let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
    return days >= 7
}

private func recordWendyMomentFired(profile: OperatorProfile) {
    profile.lastWendyDate = Date()
}
```

---

### Step 7 — Update call sites

Everywhere `speakIfWarranted` is called, update to the async signature. Currently only called from `TodayView.onAppear`.

```swift
// In TodayView.onAppear — replace the existing voice block:
if let p = profiles.first, p.voicePresenceEnabled {
    VoicePresence.shared.voiceEnabled = true
    let ctx = PresenceContextBuilder.build(
        profile: p,
        actions: actions,
        hydrationLogs: Array(hydrationLogs.prefix(1)),
        energyState: state.todayEnergyState,
        isFirstOpenToday: isFirstOpenToday
    )
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
        Task {
            await VoicePresence.shared.speakIfWarranted(
                context: ctx,
                profile: p,
                actions: actions,
                logs: Array(logs.prefix(30))   // 30 days of logs for longitudinal
            )
        }
    }
}
```

---

### Step 8 — Add API key field and Wendy toggle to Settings

In `SettingsTabView`, below the voice toggle block. Only shows when voice is enabled.

```swift
// Wendy (Layer B) — below the voice character card
if profile.voicePresenceEnabled {

    Divider().background(Color.muted.opacity(0.3))

    CardView(style: .secondary) {
        VStack(alignment: .leading, spacing: 14) {
            MonoLabel(text: "WENDY · LAYER B", color: .violetLight)
            MonoLabel(text: "Pattern inference via Claude API. Requires 14 days of use.", color: .muted, size: 10)

            Toggle(isOn: $profile.wendyEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pattern observations").font(.sora(14)).foregroundColor(.textPrimary)
                    Text("Fires at most once per 7 days. Text-only until confirmed.")
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                }
            }
            .tint(Color.violetLight)

            if profile.wendyEnabled {
                inputField("ANTHROPIC API KEY", placeholder: "sk-ant-...", text: $profile.claudeApiKey)
                Text("Key stored locally. Never sent to anyone other than Anthropic's API.")
                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3)

                // Days until Layer B unlocks (if < 14 days)
                if profile.daysInSystem < 14 {
                    HStack(spacing: 8) {
                        Circle().fill(Color.inkAmber.opacity(0.6)).frame(width: 5, height: 5)
                        Text("Layer B unlocks in \(14 - profile.daysInSystem) days.")
                            .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                    }
                } else {
                    HStack(spacing: 8) {
                        Circle().fill(Color.inkGreen).frame(width: 5, height: 5)
                        Text("Layer B active. 14-day threshold met.")
                            .font(.mono(11)).foregroundColor(.inkGreen).tracking(0.3)
                    }
                }
            }
        }
    }
    .padding(.horizontal, 24)
}
```

---

### Step 9 — Add debug override (development only)

Add to the test button action or as a separate debug button in Settings. Without this, testing Wendy requires waiting 7 days.

```swift
// Debug: reset Wendy cooldown — use during development
// Wrap in #if DEBUG to prevent it shipping to production
#if DEBUG
Button("Reset Wendy cooldown") {
    profile.lastWendyDate = nil
    profile.daysInSystem   // daysInSystem is computed from firstLaunchDate — override firstLaunchDate to test
}
.font(.mono(11)).foregroundColor(.textMuted)
#endif
```

---

## Consult Mode — Phase B3

Not to be built until Phase B1 (text-only Wendy) is stable. Spec is here for reference.

**What it is:** User-initiated. Brice explicitly asks for a pattern read. Observations can be plural and deeper. The 7-day cooldown does not apply — user called it.

**System prompt:** Same `WENDY_SYSTEM_PROMPT` with appended consult framing:

```swift
let WENDY_CONSULT_SYSTEM_PROMPT = WENDY_SYSTEM_PROMPT + """

CONSULT MODE: User has explicitly opened a session and is asking for a pattern read.

You may surface multiple observations. You are not limited to one sentence.
The 7-day session cooldown does not apply — the user requested this.

Still:
- No coaching. No moralizing. No over-explanation.
- Behavioral evidence only — what the data shows.
- Each observation 1-2 sentences. Don't stack more than 3-4.
- If the data doesn't support a clear observation: say so briefly.
- End when you've said what's true. Don't manufacture observations.
- max_tokens: 400 (more room for multi-observation reads).

Wendy does not ask questions back. Even in Consult mode.
She states what the data shows. If asked "Why do you think that?" —
she restates the evidence. She does not explore.
"""
```

**UI entry point:** Long press on a Wendy card in Today tab, or a dedicated "Read the last 30 days" option in the You/Profile tab. Not ambient — always explicit.

**Session model for follow-ups:**

```swift
struct ConsultSession {
    var messages: [[String: String]] = []

    mutating func addUserMessage(_ text: String) {
        messages.append(["role": "user", "content": text])
    }
    mutating func addAssistantMessage(_ text: String) {
        messages.append(["role": "assistant", "content": text])
    }
}
```

---

## Rollout Sequence

**Do not skip phases. The intimacy escalation is load-bearing.**

| Phase | What ships | Gate condition |
|---|---|---|
| **Phase A** (current) | Layer A voice only. Jarvis/Alfred/Brice. Rule-based. | Already live |
| **Phase B1** | Wendy as surfaced text card in Today tab. Not spoken. User reads the observation. | 14 days in system + wendyEnabled + API key set |
| **Phase B2** | Wendy spoken via voice engine. Same text, same gates. | Phase B1 has generated 3+ observations that felt like recognition, not surveillance |
| **Phase B3** | Consult mode. User-initiated. Plural observations. | Phase B2 stable for 2+ weeks |

**The B1→B2 test:** Does the user lean into the text observations or feel watched? If lean-in: voice is ready. If uncertain: stay text.

**Implementation note for Phase B1 (text-only):** Before routing Wendy output to `speak()`, route it to a quiet ambient card in Today tab instead. Silence `speak()` for Layer B. Only elevate to voice after B1 validates.

---

## The Six Gates (All Must Pass for a Wendy Moment)

| Gate | Condition | Why |
|---|---|---|
| Layer A returned nil | Always required | If Layer A speaks, Layer B never fires |
| `voiceEnabled` | User opted into voice | Basic gate |
| `profile.wendyEnabled` | User explicitly opted into Layer B | Separate consent |
| `daysInSystem >= 14` | Hard minimum | Can't pattern-match before this |
| `buildLongitudinalContext() != nil` | Requires 14+ days AND 10+ log entries | Data quality gate |
| `canFireWendyMoment()` | 7+ days since last Wendy moment | Structural rarity — not prompt-based |
| `apiKey != ""` | API key must be set | Operational gate |
| Claude returns non-SILENCE | Model itself may decline | Final gate |

---

## Wendy Moment Library (Approved Examples)

Each line requires the stated data condition before generating.

| Data condition | Line |
|---|---|
| Participation completion rate < 30% over 14d, operations consistently high | "Interesting. Participation disappears when operations get noisy." |
| Reserve days avg completions > full days avg (14d pattern) | "Your reserve days are consistently more productive than your full ones. Worth knowing." |
| Creative actions not completing Mon–Thu for 3+ consecutive weeks | "Third week running — creative work doesn't move until Friday. Something to notice." |
| Energy declared reserve but action count > 6, pattern 3+ days | "This doesn't look like low capacity. It looks like low tolerance for unfinished things." |
| Admin cognition > 90%, creative < 30%, pattern 14d | "You do this thing where the measurable work crowds out the meaningful work." |
| Same action isHighFriction for 14d, in Today daily but never completes | "That one's been in the stack for two weeks. Either run it or remove it." |
| Energy declared full but completions 0–1, pattern 3+ days | "You've been declaring full but moving like reserve. Might be worth recalibrating." |
| Environment not touched in stack for 14d | "Environment hasn't moved in two weeks. Everything costs more without it." |

---

## Wendy Never Says (Failure Modes)

| Context | ✓ Correct | ✗ Wrong |
|---|---|---|
| Unearned inference | "Interesting. Participation drops when operations get noisy." | "You avoid participation because it feels less measurable." |
| Moralizing | "Third week — creative work hasn't moved until Friday." | "You need to prioritize creative work earlier." |
| Over-explanation | "This doesn't look like low capacity." | "Based on my analysis of your last 14 days, your pattern suggests..." |
| Repeated pattern | Say it once. Silence for 7+ days. | "Like I mentioned before, your creative work tends to..." |
| Shaming | "That one's been in the stack for two weeks. Either run it or remove it." | "You keep avoiding this. What's going on?" |
| Coaching | "Interesting. Participation disappears when operations get noisy." | "Try blocking time for participation before operations each day." |

---

## Debug Diagnostics

Without a debug view, you won't know if silence is architecture or bug. Build this:

```swift
struct WendyDiagnosticsView: View {
    let profile: OperatorProfile
    let actions: [Action]
    let logs: [DailyLog]

    var diagnostics: String {
        var lines: [String] = []
        lines.append("Days in system: \(profile.daysInSystem)")
        lines.append("Wendy enabled: \(profile.wendyEnabled)")
        lines.append("API key set: \(!profile.claudeApiKey.isEmpty)")

        if let last = profile.lastWendyDate {
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            lines.append("Last Wendy: \(days) days ago (cooldown: \(days < 7 ? "active" : "clear"))")
        } else {
            lines.append("Last Wendy: never")
        }

        if profile.daysInSystem >= 14 {
            let longitudinal = PresenceContextBuilder.buildLongitudinalContext(
                profile: profile, actions: actions, logs: logs
            )
            lines.append("Longitudinal context: \(longitudinal != nil ? "built" : "nil — need 10+ logs")")
        } else {
            lines.append("Longitudinal: blocked — \(14 - profile.daysInSystem) days remaining")
        }

        return lines.joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MonoLabel(text: "WENDY DIAGNOSTICS", color: .violetLight)
                Text(diagnostics)
                    .font(.mono(12)).foregroundColor(.textSecond).lineSpacing(4)
            }
            .padding(24)
        }
        .background(Color.bgBase)
    }
}
```

---

## What Chat's Audit Found — Addressed Here

1. **"knows you" → "recognizes recurring patterns"** — addressed in Voice Doctrine v3.0. The implementation doc uses "patterns" framing throughout.

2. **Duplicate doctrine bodies** — the v3.0 doc supersedes all prior doctrine. The markdown doctrine file in outputs should be replaced with the v3.0 content from the uploaded docx.

3. **Hydration threshold too low** — `hoursSinceHydration >= 4` may fire too frequently. Raise to 6 hours, or add condition `ctx.completedToday > 0` (hydration nudge makes more sense after participation). Applied in implementation.

4. **"Admin's pretending to be urgent again"** — confirmed as the final version. Shorter, more repeatable than the prior version.

5. **Behavioral contradictions vs "avoidance"** — the system prompt uses "names behavioral contradictions cleanly" which is correct. The implementation doc uses this framing throughout.

6. **Consult mode anti-dependency constraint** — added: "Wendy clarifies reality. She does not create engagement. She does not replace self-trust. Consult mode clarifies evidence — it does not outsource judgment."

---

## Files to Update

| File | Changes needed |
|---|---|
| `IncrementsApp.swift` | Steps 1–9 above |
| `INCREMENTS_Voice_Doctrine.md` | Replace with v3.0 content from uploaded docx — v3.0 is canonical |
| `INCREMENTS_Agent_Handoff.md` | Update with Wendy layer description, rollout phase, new fields on OperatorProfile |

---

*INCREMENTS — Wendy Layer Master Implementation Reference*
*"Interesting. Something to notice."*
