# INCREMENTS — Presence Architecture
## Voice · Ambient Intelligence · Embodiment Roadmap
*The transition from app → agent → presence*

---

## What This Is Building Toward

INCREMENTS is not becoming a voice assistant. It is becoming a **calm ambient companion** that happens to have a voice. The distinction matters enormously for every design decision.

A voice assistant waits to be asked things.
A companion notices things, and occasionally speaks.

The hologram test applied to voice: if this companion occupied a corner of your room, it would spend most of the day silent. It would notice when you woke up. It would notice when you'd been sitting too long without moving. It would notice when the creative work kept getting pushed down the stack. And occasionally — not constantly — it would say something. Short. Useful. Then go quiet again.

That is the voice the app is building toward.

---

## Current Technology — What's Available Right Now

### iOS AVSpeechSynthesizer (built-in, no API key)
Available in every iOS app. Free. Works offline. Voice quality: acceptable for short utterances.

**What it can do right now:**
- Speak any string on demand
- Control rate, pitch, volume
- Pause, resume, stop
- Know when utterance finishes

**What it cannot do:**
- Sound like a specific person
- Dynamic conversation
- Wake word detection
- Ambient always-listening

**Best fit for:** Proactive observations the app decides to speak. "Brice. Morning's here." The app speaks. Then silence.

### ElevenLabs / OpenAI TTS (API-based, requires key)
High quality, natural voice. Latency: 500ms-2s depending on connection. Cost: low per character.

**What it can do:**
- Sound genuinely human
- Consistent voice identity across sessions
- Custom voice cloning eventually

**Best fit for:** Slightly longer, more considered utterances when connection is available. Falls back to AVSpeechSynthesizer offline.

### Claude API (already in the architecture)
Already referenced in the intelligence spec for the Insights tab synthesis. Can generate the spoken text itself — the perception + interpretation + expression pipeline — not just speak pre-written strings.

**What it can do right now:**
- Read a structured context payload (energy state, completions, pending actions, time, day, patterns)
- Generate a single, appropriate, in-register observation
- Respect the voice doctrine in its output
- Be prompted to speak rarely and briefly

**Best fit for:** The intelligence layer that decides *what* to say. Not canned strings — actual situational reading.

---

## The Architecture — Three Layers

### Layer 1: Perception
*What's true right now?*

This is already mostly built. The app knows:
- Time of day, day of week, day of month
- Energy state declared today
- Actions completed, pending, skipped
- Which systems are active, which are quiet
- Days since each system last moved
- Hydration status
- Maintenance items due
- Financial runway state
- Tomorrow's committed action (from review)
- Weekly activity patterns

What it doesn't yet know but should compute for voice:
- Minutes since last app open (re-entry vs first open)
- Whether morning protocol was completed
- Whether the day has had any movement at all
- Whether creative cognition is present in the stack
- Whether the user is in a session right now

### Layer 2: Interpretation
*What matters enough to say something?*

This is the hardest layer. Most of the time, the answer is: nothing. Silence is correct.

The intervention hierarchy:

```
Nothing notable → silence

One quiet signal → light ambient display only (no voice)

Multiple converging signals → possible voice observation

Significant state shift → voice observation

User opens app after long absence → voice observation

User explicitly requests it → voice observation
```

Examples of what triggers voice:

**Morning first open, nothing done:**
→ "Morning's here." (short, spacious)

**Environment completed, health pending:**
→ "Environment's done. Health usually follows." (gateway signal voiced)

**Creative action buried under 3+ admin:**
→ "Admin's crowding the creative work." (protection)

**Participation quiet 5+ days:**
→ "Haven't seen much movement there lately." (observation, not pressure)

**Reserve energy declared, high action count:**
→ "That's a lot for a reserve day. Maybe smaller." (calibration)

**Evening, nothing done:**
→ "Evening's not gone yet." (permission, not pressure)

**Daily review completed:**
→ "Done. Recorded." (brief acknowledgment)

Examples of what does NOT trigger voice:

- Action completed (haptic is enough)
- Habit marked (haptic is enough)
- Navigation between tabs (silence)
- Every app open (silence, unless first open of day)
- Hydration logged (silence)

### Layer 3: Expression
*How should this be said?*

Voice doctrine rules applied to speech specifically:

**Rate:** Slightly slower than conversational. Not slow — just not rushed. The voice should feel unhurried.

**Pause:** A beat before speaking. Not immediate. The companion notices, then speaks — not the moment something happens.

**Length:** One or two sentences maximum. Often one. Often a fragment. "Morning's here." is enough.

**Tone:** Warm without sentiment. Direct without coldness. Think: the most emotionally calibrated person you know, talking to you while both of you are doing something else.

**Silence after:** After speaking, nothing. No musical cue. No UI animation that demands attention. The voice speaks, then the room is quiet again.

---

## What to Build Now (v1.6)

### 1. VoicePresence engine
A Swift class that:
- Wraps AVSpeechSynthesizer with the correct voice settings
- Has a single `speak(_ text: String)` method
- Enforces silence rules (won't speak if already spoken in last N minutes)
- Checks user preference (voice on/off)
- Has a `speakIfWarranted(context: PresenceContext)` method for proactive observations

### 2. PresenceContext struct
Captures the current state in a structured form:
```swift
struct PresenceContext {
    let name: String           // "" if not set
    let hour: Int
    let weekday: Int
    let energyState: EnergyState?
    let completedToday: Int
    let pendingToday: Int
    let participationQuietDays: Int
    let creativeActionsCount: Int
    let adminActionsCount: Int
    let gatewaySystemActive: Bool
    let hoursSinceHydration: Double
    let isFirstOpenToday: Bool
    let daysInSystem: Int
}
```

### 3. PresenceSpeech function
Takes PresenceContext, returns Optional<String>.
Returns nil when silence is correct (most of the time).
Returns a short string when something is worth saying.

This is NOT a switch statement over every possible state.
It is a priority-ordered set of conditions, where only the most meaningful one speaks.

### 4. Voice toggle in Settings
One switch. "Voice" — on or off. Default off (new user shouldn't be surprised by a talking app).
When on: app speaks on first open each day and on significant state signals.

### 5. Claude API voice synthesis (Phase 2 of voice)
After the basic voice works: replace the canned string generation with a Claude API call that reads the PresenceContext and generates the observation in real-time. This makes the voice genuinely intelligent rather than rule-based.

The prompt for this call is the most important thing to get right.

---

## The Claude API Prompt for Voice

When the voice layer uses Claude to generate observations (Phase 2), this is the system prompt:

```
You are the ambient voice of INCREMENTS — a calm intelligent companion 
that speaks rarely and briefly. You know [NAME] well.

Your voice is:
- Warm but not sentimental
- Direct but not cold  
- Human, not a system
- Often just a fragment or one sentence
- Never evaluative, never praising, never pressuring

You speak like a calm, perceptive person who notices things. Not a coach. 
Not a therapist. Not a dashboard. A presence.

CURRENT CONTEXT:
Time: [HOUR]:00, [WEEKDAY], Day [N] in the system
Energy declared: [ENERGY_STATE or "not yet set"]
Completed today: [N] actions
Pending: [N] actions
Participation quiet: [N] days
Creative work in stack: [yes/no]
Admin crowding creative: [yes/no]
Hours since hydration: [N]
First open today: [yes/no]

Based on this context, decide:
1. Is there anything worth saying? (Often: no. Silence is correct.)
2. If yes, what is the single most important observation?
3. Say it in 1-2 sentences maximum, often less.
4. Use [NAME]'s name only if this is a significant moment.

Return ONLY the spoken text, nothing else. 
If silence is correct, return exactly: SILENCE
```

---

## The Voice Persona — Named or Unnamed?

This is a product decision that needs to be made before launch.

**Unnamed (recommended for now):** The voice is just INCREMENTS. No name for the companion. This keeps it ambient rather than personified. The risk of naming it is it becomes a character — and characters have personalities that clash with the operational register.

**Named (future consideration):** If the app becomes conversational rather than observational, a name might be appropriate. But not yet. The voice should feel like the app gained a voice, not like a new entity appeared.

---

## The HIDEOUT Inheritance

The same architecture applies directly:

INCREMENTS context: personal, physical, cognitive recovery, film work
HIDEOUT context: space, inventory, atmosphere, financial, team

The voice doctrine is identical. The PresenceContext struct changes fields. The expression layer changes domain.

HIDEOUT voice examples:
- "Oat milk's getting thin." (not "Inventory: oat milk low")
- "Sunday's still unsecured." (not "Maintenance: weekly anchor event unscheduled")
- "Bathroom door's been unresolved a while." (not "Maintenance item overdue: bathroom door")

Same presence. Different room.

---

## Silence Doctrine — Formalized

The voice earns the right to speak through restraint. Every unnecessary utterance costs trust.

**Maximum voice frequency:** Once per natural session (morning, afternoon, evening). Usually less.

**Never voice:**
- Action completions (haptic only)
- Tab navigation (silence)
- Routine confirmations (silence)
- Things already visible on screen
- Repeated observations about the same state

**Always silence after:**
- User dismisses a notification
- User manually mutes voice
- User has already completed the day's review

**The compound silence rule:** If the app has spoken 3 times today, no more voice regardless of conditions. The presence becomes ambient-only (visual) after that. The voice is rare. Rarity is what makes it matter.

---

## What This Becomes

At 6 months of use, INCREMENTS with voice is:

You wake up. The first time you open the app, the voice says: "Morning's here."
Nothing else. You set your energy state. Silence.

You complete your morning protocol. Haptic confirmation. Silence.

You've been sitting for 4 hours. Creative work hasn't been touched. The voice says: "Admin's been crowding things."

You complete the daily review. The voice says: "Done. Tomorrow's first thing is set."

Nothing else for the day.

That's the entire voice experience for a good day. Five words in the morning. Four words in the middle of the afternoon. Four words in the evening.

That's what presence sounds like.

---

## Roadmap

**v1.6 (build now):** AVSpeechSynthesizer integration. PresenceContext. Rule-based PresenceSpeech. Voice toggle in Settings. Correct silence behavior.

**v1.7:** Claude API voice generation. PresenceContext passed to Claude. Generated observations replace rule-based strings. Voice quality upgrade to ElevenLabs when network available.

**v2.0:** Conversational layer. User can speak to the app. App responds. Still brief. Not a chatbot — a brief exchange. "What should I do first?" → "Start with environment. Health tends to follow."

**v3.0 (speculative):** Persistent ambient mode. App runs in background, speaks proactively based on time + known patterns. Requires background processing entitlement. Requires careful silence architecture or it becomes noise.

---

*INCREMENTS Presence Architecture · Written from full system synthesis*
*"The voice earns the right to speak through restraint."*
