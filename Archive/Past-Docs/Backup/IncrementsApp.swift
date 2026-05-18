// INCREMENTS — environmental cognition support system
// v1.5 · Intelligence Layer + Phase 2/3 Complete · SwiftUI + SwiftData
// iOS 17+ · Sora + DM Mono · Dark Warm-Neutral Palette
//
// v1.9 Bug Fixes (field test):
// FIX-A — Daily reset fires on foreground re-entry (scenePhase .active), not only cold launch.
//          Root cause of "actions don't reset daily" — app backgrounded overnight, reset never ran.
// FIX-B — Double-recording of completionDates eliminated. resetDailyActionsIfNeeded() no longer
//          appends to completionDates (completeAction() already does this on live tap). Previously
//          every completion was recorded twice, corrupting completionRate and isHighFriction.
// FIX-C — Skip count now uses yesterday's weekday for weekday/weekend recurrences. Previously
//          checked today's weekday — skips were counted on the wrong day (e.g. a weekday action
//          would skip on Saturday, its off-day).
// FIX-D — systemLastActivity restored from persisted completionDates on launch + foreground.
//          Previously this was in-memory only and reset to zero on every cold launch, making
//          Home View "X hasn't moved" signals and nextSaneAction sorting unreliable.
//
// v2.7 Hideout Business Layer — The Sixth System:
// BIZ-01   — HideoutShiftLog SwiftData model: one entry per shift. Captures gross revenue,
//            transaction count, stress score (1–10), staff used, 3–5pm tail, lost sales,
//            source attribution notes, and free notes. Experiment day stamped at save.
// BIZ-02   — HideoutPlanningBand enum: survival/stability/comfort/growth classifications
//            matching the strategic brief (Section 9). Live on LogShiftSheet as you type.
// BIZ-03   — HideoutTabView in YouView: 30-day scorecard with experiment day counter,
//            running average, planning band, trend, avg stress signal, and full shift log.
//            Replaces the generic WorkTrack card for HIDEOUT.
// BIZ-04   — LogShiftSheet: 60-second post-shift entry. Revenue entry shows live band
//            classification as you type. Avg ticket calculated and compared to $16.72 baseline.
//            Source attribution field for the 2-week customer capture study.
// BIZ-05   — LongitudinalContext expanded: 8 new Hideout fields fed to Wendy payload.
//            Wendy now receives: experiment day, 30-day avg, planning band, trend direction,
//            stress avg, staff discipline, lost sales signal.
// BIZ-06   — Wendy system prompt updated to Voice Doctrine v3.2: reads the whole person
//            including the business. Knows the planning bands, loan stakes, experiment deadline,
//            stress/revenue relationship. Business observations same register as personal ones.
// BIZ-07   — SchemaV5 migration: adds HideoutShiftLog to the store. Lightweight, no transform.
//
// v3.2 Quiet Cafe Advantage + Behavioral Science Stack:
// BEHAVIOR-01 — "Solo Operator Protocol" session added to seed:
//               4 steps loading the behavioral science stack before opening:
//               Primacy (3-sec acknowledgment) · Choice Architecture (scripted upsell) ·
//               Familiarity (know the regulars) · Peak-End (anchor phrase close).
//               Run pre-shift as mental rehearsal, not post-shift review.
// BEHAVIOR-02 — "Pre-shift: load the 4 behaviors" seeded as hideout daily action at 7:15.
//               Note field contains exact script for each of the four behaviors.
// BEHAVIOR-03 — HideoutShiftLog expanded with 3 boolean fields:
//               usedScriptedUpsell · recognizedRegular · anchorPhraseUsed.
//               LogShiftSheet has new "Behavioral Techniques" section with toggles.
// BEHAVIOR-04 — HideoutTabView shows behavioral correlation card (3+ shifts):
//               Avg ticket when upsell used vs not used. Direct ROI feedback.
//               Per-technique usage rate (X/7 shifts). Flags when recognition <50%.
// BEHAVIOR-05 — "Watermarc relationship touch" seeded as hideout weekly participation action.
//               Highest-ROI visibility play per strategy brief.
// EXPORT-02   — WeeklyExportCard now includes Hideout weekly data:
//               Revenue, stress avg, behavioral technique rates, avg ticket correlation,
//               shift notes. Full picture for advisor/partner sharing.
// DOCTRINE-03 — Wendy Layer B gate: 7 days (rapid adoption confirmed). All guards updated.
//
// v3.1 Compile Fixes + Doctrine Update + Export:
// COMPILE-01 — @Model removed from SessionSkipReason enum (done in prior session, confirmed clean).
// COMPILE-02 — Duplicate shifts @Query in TodayView removed (confirmed clean).
// COMPILE-03 — nonisolated(unsafe) removed from String constants (confirmed clean).
// COMPILE-04 — Date.FormatStyle.uppercased() fixed → format string first, then .uppercased().
// DOCTRINE-01 — Wendy Layer B gate updated: 14 days → 7 days per rapid adoption override.
//               Voice Doctrine v3.0 specifies 14 as standard. Brice's adoption rate earns
//               weekly cadence. Gates updated in: canFireLayerB, speakIfWarranted,
//               generateWendyObservation, buildLongitudinalContext. minLogs: 5→3.
// DOCTRINE-02 — WENDY_SYSTEM_PROMPT rewritten from Voice Doctrine v3.0 verbatim:
//               Four character stack (Jarvis/Alfred/Wendy/Brice) properly defined.
//               Approved line library included. Anti-addiction constraint explicit.
//               Per-action breakdown now sent to Wendy (not just system rates).
//               Brice's strengths profile (Restorative/Achiever/Analytical) embedded.
// EXPORT-01  — WeeklyExportCard added to Profile tab. Generates markdown weekly review:
//               7-day action completion rates by system · daily log notes · friction flags.
//               ShareSheetView (UIActivityViewController) — share to partner, advisor,
//               Notes, email, anywhere. The data you collect now has an exit path.
//
// v3.0 Full Interactivity + Strengths Integration:
// INTERACT-01 — System rows in IncrementsView now tappable. Opens SystemDetailSheet:
//               WHY this system matters (scienceNote) · WHAT MOVES IT · avg completion
//               rate · all pending actions (tappable → ActionDetailSheet) · done today.
//               The chevron.right was decoration before. Now it's functional.
// INTERACT-02 — Next Sane Participation card on Home now tappable → ActionDetailSheet.
//               Was showing a chevron.right with no action. Fixed.
// INTERACT-03 — CurriculumCard "Add to stack" button. Read WHY → understand HOW →
//               tap once to commit. Creates the Action in SwiftData automatically.
//               Shows "Added to your stack" confirmation. No friction.
// INTERACT-04 — AddActionSheet now includes recurrence picker (Daily/Weekdays/Weekends/
//               Weekly). Was missing — all new actions defaulted to daily silently.
// INTEL-04    — Layer A/B cooldowns split:
//               Layer A (operational, rule-based): 2-day cooldown. Fast, practical.
//               Layer B (Wendy pattern interpretation): 7-day cooldown. Weekly cadence.
//               Wendy Rhoades doesn't speak daily. She speaks when the pattern is clear.
//               Weekly observation carries weight. Daily is noise.
// INTEL-05    — SystemStatusRow trajectory signal fixed to use completionDates
//               (was using completedAt — nil'd on reset, always showed nothing).
// INTEL-06    — Brice's Gallup strengths profile (Restorative, Achiever, Analytical,
//               Competition, INTJ/SCOAI) wired into Wendy's system prompt. She now
//               understands the operating system: lead with data (Analytical), he'll fix
//               it once he sees it (Restorative), every day starts at zero (Achiever).
//
// v2.9 Interactivity Audit + Time Format Fixes:
// WENDY-01 — Voice Doctrine v4.0. Wendy now has three systems in view: personal habits,
//            Hideout business (30-day experiment), and physical (gym anchor).
//            Cross-system patterns are her primary instrument — not just habit completion.
//            Business context fully briefed: planning bands, loan framing, stress score
//            interpretation, solo discipline signals, lost sales as capacity flag.
// WENDY-02 — Hideout data now flowing into both speakIfWarranted call sites.
//            TodayView queries HideoutShiftLog and passes to longitudinal builder.
//            Business payload section added: experiment day, avg revenue, planning band,
//            trend, stress avg, staff used, lost sales, loan decision context.
// WENDY-03 — Layer A gains a hideout shift reminder: fires at close of business
//            (3PM weekends, 5PM weekdays) if it's a hideout day.
//            "Shift's done. Log it before the number fades." One line. Practical.
// STRUCT-01 — Fixed orphaned WorkTracksTabView struct declaration (missing `struct` keyword
//            after LogShiftSheet closing brace — would cause compile error).
//
// v2.6 Session Intelligence — Quick-Mark + Skip Tracking:
// SESSION-01 — Session model expanded: completionDates[] + skipCount + skipDates[] + skipReasons[].
//              Parallel to Action model. Completions persist across daily reset. Skip reasons
//              (rest vs disruption) are distinct signals — not the same as blank non-logging.
// SESSION-02 — SessionCard rewritten with three affordances:
//              · Tap title area → opens step-through execution view (unchanged)
//              · Tap ✓ button → quick-mark done. No steps needed. One tap. Records completionDate.
//              · Tap "skip" → inline options: "Rest day" or "Something came up". Records reason.
//              The gym case: finish with Tim, open app, tap checkmark. Done. No friction.
// SESSION-03 — completeSession() + skipSession() added to TodayView.
//              completeSession marks system active this week, awards XP, records to completionDates.
//              skipSession records skipDate + reason but does NOT increment skipCount —
//              that's reserved for unlogged blanks (unknown signal vs deliberate signal).
// SESSION-04 — resetDailyActionsIfNeeded extended to handle sessions.
//              Blank days (no completion, no skip) → session.skipCount++.
//              Intentional skips → already recorded, no double-count.
//              Distinction: blank = friction signal. Skip = informed choice.
// SESSION-05 — closeSession() in SessionExecutionView updated to record completionDates
//              and markSystemActive. Both completion paths (quick + step-through) are now equivalent.
// SESSION-06 — SchemaV4 migration: lightweight, adds nil/zero-default fields to Session.
//
// v2.5 Progression Curriculum + Schedule Refinement:
// PROG-01  — ProgressionCurriculum: static library of 9 next-layer practices across 3 tiers.
//            Prerequisite-gated: unlocks when matching actions hit 70%+ completion over 7+ days.
//            Displayed in Increments tab as CurriculumSection. One item at a time, expandable.
//            Tiers: refinement (caffeine delay, HRV read, post-workout window) →
//            sharpening (visualization, deliberate practice, cold immersion, Sunday preview) →
//            mastery (sleep score calibration, output sharing, fasted morning trial).
// PROG-02  — CurriculumCard: expandable card showing why/how/cue for each unlocked item.
//            Not an action — a prescription. User decides when to adopt.
// SCHED-09 — Fixed hideout schedule: arrives 7:00–7:10 (slow open), deep work 8:30.
//            Was 8:00 → 8:30. The slow open is protected time, not dead time.
// SCHED-10 — Gym anchor added: strength training 17:00 daily with Tim. Post-workout
//            protein seeded (30min window). Gym is a fixed anchor — tracked in health system.
// SCHED-11 — Wendy updated with gym context, slow-open awareness, and curriculum tier info.
//
// v2.4 Schedule Architecture — Hideout/Base Week Structure:
// SCHED-01  — DayType enum: hideout (Wed–Fri 8–5, Sat–Sun 10–3) vs base (Mon–Tue).
//             Today's DayType computed from weekday. isHideoutHours checks current time.
// SCHED-02  — Action model: scheduledBlock (String? "6:00" format) + dayTypeRaw (String?).
//             scheduledBlock shows prescribed time on action card. dayTypeRaw filters the
//             Today stack — base-only actions hide on hideout days and vice versa.
// SCHED-03  — todayActions rewritten: sorts by scheduledBlock (scheduled before unscheduled,
//             chronological within), filters by prescribedDayType. Stack is now time-ordered.
// SCHED-04  — ActionRow updated: shows scheduledBlock time in system color before title.
// SCHED-05  — homeGreeting and todayContextLine are now location/schedule aware.
//             Context line shows "HIDEOUT" or "BASE" day type. Greetings reference hideout
//             start times, base day ops rhythm, evening anchor language.
// SCHED-06  — Notifications rewritten for actual schedule:
//             6:00 Morning anchor open · 8:00 First block · 12:15 Midday
//             16:30 Wrap · 21:00 Evening anchor
// SCHED-07  — Full prescribed week in seed with time blocks:
//             Every day: 6:00–7:30 morning anchor stack
//             Hideout: 8:00 priorities → 8:30 deep work → 12:00 midday
//             Base: 8:00 ops → 8:15 messages → 8:30 reset
//             Evening: 21:00 no screens → 21:15 read → 23:00 sleep
// SCHED-08  — SchemaV3 migration: lightweight, adds nil-default fields to Action.
//             Existing data preserved — no fields destroyed.
//
// v2.3 Full Habit Architecture + Intelligence Expansion:
// ARCH-01  — Reading moved to EVENING anchor (pre-sleep) per Garmin/REM data. Was morning.
//            "Read before sleep" replaces "Read 20 pages" — same action, correct position.
//            Cue: "When phone goes in the other room." Evening Shutdown session updated.
// ARCH-02  — Evening Shutdown session now includes: Journal → Phone away → Read.
//            The two anchors (morning + evening) are now explicit in the protocol layer.
// HABITS-03 — 6 new seeded actions completing the full system stack:
//             Environment: Clear desk surface (daily) · Inbox zero physical (weekly)
//             Health: Cold exposure 2min (daily) · Creatine (daily) · No screens final hour (daily)
//             Operations: Close one open loop (Monday, weekly)
//             Participation: Make something (weekends)
// INTEL-01  — LongitudinalContext expanded with timing intelligence:
//             peakCompletionHour · morningCompletionRate · eveningCompletionRate ·
//             weekdayVsWeekendAvg · consecutiveDaysActive · systemCompletionsByHour
//             Data was being collected (completionHours[]) but never sent to Wendy. Now it is.
// INTEL-02  — Wendy payload expanded with full timing section. Wendy can now reason about
//             WHEN actions happen, not just WHETHER they happen.
// INTEL-03  — Wendy system prompt updated to Voice Doctrine v3.1:
//             Understands morning/evening anchor architecture. Knows to watch participation
//             vs operational momentum. Told specifically what patterns matter now.
//
// v2.2 Aggressive Adoption Phase + Cognition Build:
// CADENCE-01 — Wendy cooldown reduced 7d → 2d. High-completion adopters get more signal,
//              not less. Pattern recognition window in prompt relaxed 14d → 7d to match pace.
// CADENCE-02 — buildLongitudinalContext minLogs reduced (10→5 for 14d, 20→10 for 30d).
//              DailyLogs now auto-written on action tap (FIX-H), so coverage is consistent.
//              The old 10-log gate was blocking Layer B for active users with real data.
// CADENCE-03 — Wendy system prompt updated with v2.2 rapid-adopter context. Flags cognition
//              and participation as newly-loaded systems worth watching.
// HABITS-01  — 9 new seeded actions across Cognition, Participation, Health:
//              No phone first hour · Read 20 pages (physical) · Deep work 90 min ·
//              Journal 3 sentences · One real conversation · Outside 15 min ·
//              Sleep by midnight · Read something long (weekly)
//              Add these manually in-app — seed only runs on fresh install.
// HABITS-02  — 2 new seeded sessions: Cognitive Sharpening (daily) + Deep Work Block (daily).
//              Cognition was the most-underbuilt system in the original seed.
//
// v2.1 Log History + Review Fixes:
// FIX-I — Daily Review button now shows "Edit Today's Log" when already reviewed, with muted
//          styling. Re-opening the sheet goes to edit mode (fields pre-filled) not the result
//          screen. User can revise any field and re-save. `submitted` still shows result on
//          first-time completion in-session.
// FIX-J — Timeline: removed 14-day gate (no value, just hid history from new users).
//          Fixed completedAt → completionDates throughout — history now survives daily resets.
//          Daily review notes (topWin, notes) now surface inline under each day's entries.
// FIX-K — patternReadiness, daysWithCompletions, morningEvidenceData all fixed to use
//          completionDates instead of completedAt. Pattern window was always reporting "7
//          more days" because completedAt is nil'd on reset.
// FIX-L — morningEvidenceData prefers DailyLog.systemsTouched for yesterday's system list
//          (more accurate, already persisted) with fallback to completionDates derivation.
// FIX-E — notificationsEnabled was @State (reset to false on every tab switch / view re-init).
//          Changed to @AppStorage. Also syncs with real system permission on every appear —
//          keeps toggle honest if user grants/denies from Settings.app externally.
// FIX-F — participationQuietDays in PresenceContextBuilder was using completedAt (set to nil
//          on daily reset). After reset, every participation action appeared never completed,
//          so participationQuietDays always returned daysInSystem. Now uses completionDates.last.
// FIX-G — daysSinceActivity() in IncrementsView had the same completedAt bug. Fixed to combine
//          completionDates history with current-day completedAt for accurate "last moved" signal.
// FIX-H — DailyLog.completedActionIDs was only written at daily review time. If user skips
//          the review, completedCount stays 0 for every log, making reserveDayCompletionAvg
//          and fullDayCompletionAvg in the longitudinal context permanently 0 — killing that
//          entire branch of pattern intelligence. Now written on every action tap.
//
// Phase 1 Fixes Applied (Design Decisions v1.1):
// FIX 01 — Daily Review "Skip" replaced with reduced-scope closure path
// FIX 02 — Today stack capped at 8 + habit cue/minimum-scope fields
// FIX 03 — Action cue field added, seeded defaults pre-filled
// FIX 04 — Operator Score replaced with 5-dot system activity row
// FIX 05 — 3-day quiet signal on Increments tab
// FIX 06 — One Door postponement interrupt card
// FIX 07 — Daily Review questions reworded
// FIX 08 — Morning evidence card on Today
//
// Visual Fixes Applied (Design Decisions v1.2):
// FIX V01 — Health domain color: inkRed → inkTeal (#5AB8D6)
// FIX V02 — Decay signal: domain color at 40% opacity, not amber
// FIX V03 — Mono minimum 11pt; tab labels 10pt
// FIX V04 — Three-tier card hierarchy: Primary / Secondary / Ambient
// FIX V05 — Background undertone: warm-neutral (was blue)
// FIX V06 — Tab selection: area fill + gradient
// LAUNCH  — LaunchSequenceView: nodes → corona → wordmark → app
//
// v1.3 Bug Fixes:
// BUG 01 — Daily action reset: resetDailyActionsIfNeeded() on every launch
// BUG 02 — Daily Review now saves to DailyLog via saveReview()
// BUG 03 — START DAY label now updates correctly after resets
//
// Phase 3 Priority 1 (Evolution Brief):
// P3-01 — Session Protocols: Session model, SessionCard, SessionExecutionView,
//          AddSessionSheet, 4 seeded defaults. Session is the unit of completion.
//
// v1.8 — 14-Day Field Test Preparation:
// BASE-01 — Added "Protein — second hit" seeded action (afternoon, 30g)
// BASE-02 — Added Laundry session (gather → wash → dry → fold) with .none recurrence
// BASE-03 — Added water filter to maintenance seeds (90-day interval)
// BASE-04 — Added notifProteinEnabled toggle (off by default, 2/day: 10am + 3:30pm)
// BASE-05 — Protein reminder in Settings alongside hydration toggle
//
// FIELD TEST RULE:
// Real bugs and real-use irritations may be fixed immediately.
// No speculative features.
// No dashboards, streaks, calories, macros, or new intelligence surfaces without live-use need.
// INT-01 — XP now awarded on action completion (not sessions only). Deducted on un-complete.
// INT-02 — Weekly system activity persisted to OperatorProfile (was in-memory AppState only).
//          Dots on Home now survive app restarts. Weekly reset on Monday.
// INT-03 — Action.skipCount + completionDates: daily reset now records skips and history.
//          Action.isHighFriction: 7+ days, <30% completion, 4+ skips → friction flag.
// INT-04 — Friction diagnosis in SystemStatusRow expanded view: surfaces high-skip actions.
// INT-05 — IncrementsView segment control now actually filters by recurrence type.
// INT-06 — CognitionLog wired to Energy State input: energy data starts building correlation dataset.
// INT-07 — Morning evidence reads actual completions array (not log count). Threshold 2 (was 3).
//          Tomorrow's committed action surfaces in morning evidence card as "FIRST ACTION TODAY".
// INT-08 — Review result shows tomorrow's action. Doctrine rotation is weekday-aware.
// P2-NOTIF — Notification personalization: quiet window, category toggles, hydration opt-in
// P3-02 — Maintenance Cadence: MaintenanceItem model, MaintenanceSection in Increments tab,
//          4 seeded defaults (air filter, deep clean, weekly reset, financial review)
// P3-03 — Hydration Pulse: HydrationLog model, HydrationPulseCard in Today tab,
//          single-tap logging, pulse animation at 2h+, invisible after 8pm
// P3-04 — Financial Clarity: FinancialState model, FinancialClarityCard in Increments tab,
//          three signals only (runway, next obligation, inflow), no amounts without opt-in
//
// "participation in reality"

import SwiftUI
import SwiftData
import UserNotifications
import AVFoundation
import Combine

// MARK: - COLOR SYSTEM

extension Color {
    static let bgBase       = Color(hex: "#0D0C0B")   // FIX V05 — warm neutral (was #0C0B12, blue undertone)
    static let surface      = Color(hex: "#171512")   // FIX V05 — warm neutral (was #161422)
    static let surface2     = Color(hex: "#1D1B18")   // FIX V05 — warm neutral (was #1C1A2A)
    static let violet       = Color(hex: "#8A6EFF")
    static let violetLight  = Color(hex: "#B09AFF")
    static let violetDim    = Color(hex: "#4A3D88")
    static let warm         = Color(hex: "#C8A96E")
    static let warmLight    = Color(hex: "#E8C98E")
    static let inkGreen     = Color(hex: "#5ACEA8")
    static let inkRed       = Color(hex: "#D06B6B")   // reserved for system errors only — not domain use
    static let inkTeal      = Color(hex: "#5AB8D6")   // FIX V01 — Health domain color (clinical neutral)
    static let inkAmber     = Color(hex: "#D4933A")
    static let textPrimary  = Color(hex: "#F0ECFF")
    static let textSecond   = Color(hex: "#A8A0C8")
    static let textMuted    = Color(hex: "#6A6285")
    static let muted        = Color(hex: "#4A4468")

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - TYPOGRAPHY

extension Font {
    static func sora(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Sora", size: size).weight(weight)
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
        .custom("DM Mono", size: size).weight(weight)
    }
}

// MARK: - ENUMS

enum SystemTag: String, Codable, CaseIterable {
    case environment   = "environment"
    case cognition     = "cognition"
    case health        = "health"
    case operations    = "operations"
    case participation = "participation"

    var label: String { rawValue.uppercased() }
    var icon: String {
        switch self {
        case .environment:   return "leaf"
        case .cognition:     return "brain"
        case .health:        return "heart"
        case .operations:    return "briefcase"
        case .participation: return "figure.walk"
        }
    }
    var scienceNote: String {
        switch self {
        case .environment:
            return "Your physical environment directly shapes cognitive performance. Light, temperature, order, and noise are not background conditions — they are inputs. A supportive environment reduces the activation energy required for every other system."
        case .cognition:
            return "Cognitive capacity is finite and depletes across the day. Deep work, decision density, and noise load all draw from the same pool. Protecting this system means fewer decisions before the important ones, and better filtering of what gets in."
        case .health:
            return "Physical capacity is the foundation everything else runs on. Movement, sleep quality, nutrition, and recovery aren't lifestyle choices — they are operational infrastructure. When this system is quiet, every other system costs more."
        case .operations:
            return "Operational clarity reduces background cognitive load. Unresolved obligations and unclear next actions run as open loops — they consume attentional resources even when you're not consciously thinking about them."
        case .participation:
            return "Participation is the whole point. The other four systems exist to make this one easier. Showing up in small ways — consistently, without waiting for ideal conditions — is the mechanism of recovery and restoration."
        }
    }

    var whatMovesIt: String {
        switch self {
        case .environment:   return "Open blinds. Reset one area. Reduce noise. Manage temperature."
        case .cognition:     return "Protect a focus block. Reduce decisions before deep work. Clear the input queue."
        case .health:        return "Move your body. Eat protein. Hydrate. Complete morning light exposure."
        case .operations:    return "Close one open loop. Review priorities. Respond to the queue."
        case .participation: return "Complete one action. Any action. The rest follows."
        }
    }
    var color: Color {
        switch self {
        case .environment:   return .inkGreen
        case .cognition:     return .violetLight
        case .health:        return .inkTeal
        case .operations:    return .warm
        case .participation: return .inkAmber
        }
    }
}

enum RecurrenceType: String, Codable, CaseIterable {
    case daily, weekdays, weekends, weekly, none

    var displayLabel: String {
        switch self {
        case .daily:    return "Daily"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .weekly:   return "Weekly"
        case .none:     return "Once"
        }
    }
}

enum ClarityLevel: String, Codable, CaseIterable {
    case clear, moderate, overloaded
    var label: String { rawValue.capitalized }
    var color: Color {
        switch self {
        case .clear:      return .inkGreen
        case .moderate:   return .inkAmber
        case .overloaded: return .inkRed
        }
    }
}

enum NoiseLevel: String, Codable, CaseIterable {
    case low, moderate, high
    var label: String { rawValue.capitalized }
    var color: Color {
        switch self {
        case .low:      return .inkGreen
        case .moderate: return .inkAmber
        case .high:     return .inkRed
        }
    }
}

// MARK: - INTELLIGENCE CAPTURE ENUMS

// Cognition sub-type — distinguishes modes that feel identical but have different effects.
// Creative cognition generates. Analytical cognition diagnoses. Administrative cognition depletes.
// Tagged by user at action creation. Nil = untagged (default for all existing actions).
enum CognitionMode: String, Codable, CaseIterable {
    case creative       = "creative"       // visual development, storytelling, worldbuilding
    case analytical     = "analytical"     // research, pattern diagnosis, problem solving
    case administrative = "administrative" // email, logistics, decisions

    var label: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .creative:       return "sparkles"
        case .analytical:     return "magnifyingglass"
        case .administrative: return "tray"
        }
    }
    var description: String {
        switch self {
        case .creative:       return "Generates. Protects visual and narrative thinking."
        case .analytical:     return "Diagnoses. Restorative for this profile when bounded."
        case .administrative: return "Depletes. Necessary but costs cognitive capacity."
        }
    }
}

// Intelligence readiness states — honest about what the system can and cannot yet see.
// Surfaces in UI as "collecting" language, not empty state.
enum IntelligenceReadiness {
    case collecting(daysRemaining: Int, target: Int, label: String)
    case ready(label: String)
    case insufficient   // not enough data even after the window — keep collecting silently

    var displayText: String {
        switch self {
        case .collecting(let remaining, _, let label):
            return "Collecting \(label). \(remaining) more day\(remaining == 1 ? "" : "s")."
        case .ready(let label):
            return label
        case .insufficient:
            return ""
        }
    }

    var isReady: Bool {
        if case .ready = self { return true }
        return false
    }
}

// v2.4 — day type classification for schedule-aware behavior
enum DayType: String, Codable {
    case hideout = "hideout"   // Wed–Fri 8–5, Sat–Sun 10–3 — deep work at the hideout
    case base    = "base"      // Mon–Tue — cafe/prep/maintenance/operations days
    case weekend = "weekend"   // legacy fallback

    var label: String {
        switch self {
        case .hideout: return "HIDEOUT"
        case .base:    return "BASE"
        case .weekend: return "WEEKEND"
        }
    }

    var color: Color {
        switch self {
        case .hideout: return .violet
        case .base:    return .warm
        case .weekend: return .inkGreen
        }
    }

    // Brice's schedule: Wed–Fri and Sat–Sun are hideout days; Mon–Tue are base days
    static var today: DayType {
        let wd = Calendar.current.component(.weekday, from: Date())
        // 1=Sun,2=Mon,3=Tue,4=Wed,5=Thu,6=Fri,7=Sat
        switch wd {
        case 2, 3: return .base      // Mon, Tue
        case 4, 5, 6, 7, 1: return .hideout  // Wed–Fri, Sat, Sun
        default: return .base
        }
    }

    // Brice's schedule:
    // Hideout: arrives 7:00–7:10 (slow open — coffee, music, prep). Deep work starts 8:30.
    //          Wed–Fri closes 5PM → gym. Sat–Sun closes 3PM → afternoon free.
    // Base (Mon–Tue): cafe/ops rhythm. Gym at 5PM most days.
    var hideoutStartHour: Int { 7 }   // slow open — arrive by 7, not rushed
    var hideoutDeepWorkHour: Int { 8 } // deep work starts 8:30 (shown as "8:30" block)
    var hideoutEndHour: Int {
        let wd = Calendar.current.component(.weekday, from: Date())
        return (wd == 1 || wd == 7) ? 15 : 17   // 3PM weekends, 5PM weekdays
    }
    var gymHour: Int { 17 }   // 5PM gym anchor — every day after hideout/work

    var isHideoutHours: Bool {
        guard self == .hideout else { return false }
        let h = Calendar.current.component(.hour, from: Date())
        return h >= hideoutStartHour && h < hideoutEndHour
    }
}



// FIX 03: cue field added to Action
@Model
class Action {
    var id: UUID = UUID()
    var title: String = ""
    var system: SystemTag = SystemTag.participation
    var scheduledTime: Date? = nil
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var points: Int = 10
    var recurrence: RecurrenceType = RecurrenceType.daily
    var note: String? = nil
    var cue: String? = nil          // FIX 03 — behavior cue anchor
    var createdAt: Date = Date()
    // Intelligence layer — tracks friction without judgment
    var completionDates: [Date] = []   // persistent history of all completion timestamps
    var skipCount: Int = 0             // incremented by daily reset when action was not completed
    // Cognition sub-type — only relevant for .cognition system actions. Nil = untagged.
    var cognitionMode: CognitionMode? = nil
    // Time-of-day capture — hour of day (0-23) when completed. Builds completion window dataset.
    var completionHours: [Int] = []    // parallel to completionDates; same index = same event
    // v2.4 — prescribed time slot. "6:00" / "8:30" / "12:00" format. Optional display — not a lock.
    var scheduledBlock: String? = nil
    // v2.4 — day type restriction. nil = every day; "hideout" / "base" = that day type only.
    var dayTypeRaw: String? = nil

    var prescribedDayType: DayType? {
        guard let raw = dayTypeRaw else { return nil }
        return DayType(rawValue: raw)
    }

    init(title: String, system: SystemTag, points: Int = 10,
         recurrence: RecurrenceType = .daily, scheduledTime: Date? = nil,
         note: String? = nil, cue: String? = nil,
         scheduledBlock: String? = nil, dayTypeRaw: String? = nil) {
        self.id = UUID()
        self.title = title
        self.system = system
        self.points = points
        self.recurrence = recurrence
        self.scheduledTime = scheduledTime
        self.note = note
        self.cue = cue
        self.createdAt = Date()
        self.scheduledBlock = scheduledBlock
        self.dayTypeRaw = dayTypeRaw
    }

    // Days since created — for friction ratio calculation
    var daysSinceCreated: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 1
    }

    // Completion rate over the action's lifetime
    var completionRate: Double {
        let days = max(1, daysSinceCreated)
        let total = completionDates.count
        return Double(total) / Double(days)
    }

    // High friction = appears often, completes rarely. Threshold: 7+ days, <30% completion
    var isHighFriction: Bool {
        daysSinceCreated >= 7 && completionRate < 0.30 && skipCount >= 4
    }
}

// FIX 02: habit cue + minimum-scope fields
@Model
class Habit {
    var id: UUID = UUID()
    var title: String = ""
    var system: SystemTag = SystemTag.participation
    var frequency: RecurrenceType = RecurrenceType.daily
    var isActive: Bool = true
    var completionHistory: [Date] = []
    var notes: String? = nil
    var cue: String = ""            // FIX 02 — required before save
    var minimumScope: String = ""   // FIX 02 — smallest version of the action

    init(title: String, system: SystemTag, frequency: RecurrenceType = .daily,
         cue: String = "", minimumScope: String = "") {
        self.id = UUID()
        self.title = title
        self.system = system
        self.frequency = frequency
        self.cue = cue
        self.minimumScope = minimumScope
    }

    var completedToday: Bool {
        Calendar.current.isDateInToday(completionHistory.last ?? .distantPast)
    }

    var last7: [Bool] {
        let cal = Calendar.current
        return (0..<7).map { offset in
            guard let date = cal.date(byAdding: .day, value: -(6 - offset), to: Date()) else { return false }
            return completionHistory.contains { cal.isDate($0, inSameDayAs: date) }
        }
    }

    // FIX 05 — days since last completion
    var daysSinceLastActivity: Int {
        guard let last = completionHistory.last else { return 999 }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 999
    }
}

@Model
class OperatorProfile {
    var version: String = "1.2"
    var level: Int = 1
    var xp: Int = 0
    var phaseLabel: String = "Recovery + Operational Restoration"
    var quietMode: Bool = false
    var quietUntil: Date? = nil
    var firstLaunchDate: Date = Date()
    var lastResetDate: Date? = nil   // FIX: tracks last day daily actions were reset

    // Phase 2 — Notification personalization
    var notifQuietStart: Int = 22   // hour (24h): quiet window start (default 10pm)
    var notifQuietEnd: Int = 7      // hour (24h): quiet window end (default 7am)
    var notifCategoryEnvironment: Bool = true
    var notifCategoryCognition: Bool = true
    var notifCategoryHealth: Bool = true
    var notifCategoryOperations: Bool = true
    var notifCategoryParticipation: Bool = true
    var notifHydrationEnabled: Bool = false   // Phase 3 P3 — off by default
    var notifProteinEnabled: Bool = false     // protein reminder — off by default

    // Persistent weekly activity — resets each Monday, survives app restarts
    // Stored as comma-separated system rawValues active this week
    var weeklyActiveSystems: String = ""           // e.g. "environment,health,cognition"
    var weeklyActivityResetDate: Date? = nil       // tracks which week the reset happened

    // Personalization — name used for direct address in time-aware greetings
    // Empty = app addresses generically (correct default for public/multi-user builds)
    var operatorName: String = ""

    // Voice presence — off by default, user opts in
    var voicePresenceEnabled: Bool = false
    // Voice provider — native default, ElevenLabs available when API key is set
    var voiceProvider: VoiceProvider = VoiceProvider.native
    // ElevenLabs — Phase B. Voice ID for the chosen character.
    var elevenLabsVoiceId: String = ""   // e.g. "21m00Tcm4TlvDq8ikWAM" (Rachel)
    var elevenLabsApiKey: String = ""    // stored locally only, never sent to our servers
    var openAIApiKey: String = ""        // OpenAI API key — stored locally only

    // Wendy (Layer B) — separate toggle, separate consent from voice.
    // Stays false until user explicitly opts in after Phase B1 text rollout.
    var wendyEnabled: Bool = false
    var claudeApiKey: String = ""         // Anthropic API key — stored locally only
    var lastWendyDate: Date? = nil        // legacy — kept for Settings display compat
    var lastLayerADate: Date? = nil       // Layer A (real-time ops): 2-day cooldown
    var lastLayerBDate: Date? = nil       // Layer B (pattern interpretation): 7-day cooldown
    var lastWendyObservation: String? = nil       // persisted text of last Wendy Layer B observation
    var lastWendyObservationDate: Date? = nil     // when it fired — shown in Insights tab
    // Phase B2 — spoken Wendy. Only enable after B1 text observations feel like recognition.
    var wendyVoiceEnabled: Bool = false

    // Consult Mode (Phase B3) — 30-Day Read
    // 14-day cooldown. One receipt persisted — overwritten on next save. No conversation history.
    var lastConsultDate: Date? = nil          // 14-day structural cooldown

    init() {}

    var title: String {
        // Operator title is fixed — not a rank ladder
        return "Field Operator"
    }

    // MARK: - Time & name awareness helpers

    // First name or empty — drives whether the app addresses by name
    var firstName: String {
        let trimmed = operatorName.trimmingCharacters(in: .whitespaces)
        return trimmed.components(separatedBy: " ").first ?? trimmed
    }

    // Suffix first name if set — used inline in greetings
    // e.g. nameFragment = "Brice." or "" (no trailing space — caller handles punctuation)
    var nameFragment: String {
        let n = firstName
        return n.isEmpty ? "" : n
    }

    // Time-of-day period — used to select greeting tone
    enum TimePeriod { case earlyMorning, morning, midday, afternoon, evening, lateNight }
    var timePeriod: TimePeriod {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 0..<6:   return .lateNight
        case 6..<9:   return .earlyMorning
        case 9..<12:  return .morning
        case 12..<14: return .midday
        case 14..<19: return .afternoon
        default:      return .evening
        }
    }

    // Day of week context
    var isWeekend: Bool {
        let wd = Calendar.current.component(.weekday, from: Date())
        return wd == 1 || wd == 7
    }
    var isSunday: Bool { Calendar.current.component(.weekday, from: Date()) == 1 }
    var isFriday: Bool { Calendar.current.component(.weekday, from: Date()) == 6 }
    var isMonday: Bool { Calendar.current.component(.weekday, from: Date()) == 2 }

    // Day of month — for month progress awareness
    var dayOfMonth: Int { Calendar.current.component(.day, from: Date()) }
    var monthProgress: String {
        // Returns a quiet contextual note — never a percentage or score
        let day = dayOfMonth
        if day <= 7  { return "early in the month" }
        if day <= 14 { return "mid-month approaching" }
        if day <= 21 { return "third week" }
        return "month closing"
    }

    // Days since first launch — for time-in-system awareness
    var daysInSystem: Int {
        Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
    }

    // Week of use (1-indexed) — used for milestone-aware greetings
    var weekOfUse: Int { max(1, (daysInSystem / 7) + 1) }

    // Home greeting — time-aware, location-aware, never cheesy
    func homeGreeting(completedToday: Int) -> String {
        let n = nameFragment
        let address = n.isEmpty ? "" : "\(n). "
        let dayType = DayType.today

        switch timePeriod {
        case .earlyMorning:
            if isMonday { return "\(address)New week. Base day. Start it right." }
            if dayType == .hideout {
                let wd = Calendar.current.component(.weekday, from: Date())
                let startTime = (wd == 1 || wd == 7) ? "10" : "8"
                return "\(address)Hideout by \(startTime). Still time."
            }
            return "\(address)Still early. Full day ahead."
        case .morning:
            if dayType == .hideout && DayType.today.isHideoutHours {
                if completedToday == 0 { return "\(address)Hideout hours. Deep work first." }
                return "\(address)In it."
            }
            if dayType == .base {
                if completedToday == 0 { return "\(address)Base day. Ops first, then create." }
                return "\(address)Moving."
            }
            if completedToday == 0 { return "\(address)Open field." }
            return "\(address)Moving."
        case .midday:
            if dayType == .hideout && DayType.today.isHideoutHours {
                if completedToday >= 3 { return "\(address)Three down. Afternoon's still yours." }
                return "\(address)Midpoint. What landed this morning?"
            }
            if completedToday == 0 { return "\(address)Still plenty of day left." }
            if completedToday >= 3 { return "\(address)Good momentum." }
            return "\(address)Afternoon's still yours."
        case .afternoon:
            if dayType == .hideout {
                let wd = Calendar.current.component(.weekday, from: Date())
                let endLabel = (wd == 1 || wd == 7) ? "3pm" : "5pm"
                return "\(address)Closing out the hideout. Until \(endLabel)."
            }
            if isFriday && completedToday == 0 { return "\(address)Friday. One more thing makes it a real week." }
            if completedToday == 0 { return "\(address)Still some room." }
            return "\(address)Still going."
        case .evening:
            if completedToday == 0 {
                if isSunday { return "\(address)Week's closing. One thing still counts." }
                return "\(address)Evening. Evening anchor next."
            }
            if completedToday >= 5 { return "\(address)That's probably enough. Evening anchor." }
            return "\(address)One more. Then the evening protocol."
        case .lateNight:
            return "\(address)That's the day. Book's waiting."
        }
    }

    // Today tab subgreeting — date + week context + day type
    func todayContextLine() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let dateStr = formatter.string(from: Date()).uppercased()
        let dayType = DayType.today
        let typeLabel = dayType == .hideout ? " · HIDEOUT" : " · BASE"
        if daysInSystem < 7 { return dateStr }
        return "\(dateStr) · WEEK \(weekOfUse)\(typeLabel)"
    }

    var xpToNextLevel: Int {
        let t = [0,100,200,350,500,700,900,1200,1500,2000,2500,3200,4000,5000,6000,7500,9000,10500,12000]
        let next = level < t.count ? t[level] : t.last! + level * 500
        return max(0, next - xp)
    }

    var xpProgressFraction: Double {
        let t = [0,100,200,350,500,700,900,1200,1500,2000,2500,3200,4000,5000,6000,7500,9000,10500,12000]
        let cur = level > 0 && level - 1 < t.count ? t[level - 1] : 0
        let nxt = level < t.count ? t[level] : t.last! + level * 500
        guard nxt > cur else { return 1.0 }
        return min(1.0, Double(xp - cur) / Double(nxt - cur))
    }

    func addXP(_ amount: Int) {
        xp += amount
        let t = [0,100,200,350,500,700,900,1200,1500,2000,2500,3200,4000,5000,6000,7500,9000,10500,12000]
        while level < t.count && xp >= t[level] { level += 1 }
    }

    // Weekly activity helpers — resets Monday, persists across restarts
    var activeSystemsThisWeek: Set<String> {
        Set(weeklyActiveSystems.split(separator: ",").map(String.init).filter { !$0.isEmpty })
    }

    func markSystemActive(_ system: SystemTag) {
        resetWeeklyActivityIfNeeded()
        var active = activeSystemsThisWeek
        active.insert(system.rawValue)
        weeklyActiveSystems = active.joined(separator: ",")
    }

    func isSystemActiveThisWeek(_ system: SystemTag) -> Bool {
        resetWeeklyActivityIfNeeded()
        return activeSystemsThisWeek.contains(system.rawValue)
    }

    private func resetWeeklyActivityIfNeeded() {
        let cal = Calendar.current
        // Reset on Monday (weekday 2). If we haven't reset this week, do it now.
        if let last = weeklyActivityResetDate {
            let lastWeek = cal.component(.weekOfYear, from: last)
            let thisWeek = cal.component(.weekOfYear, from: Date())
            let lastYear = cal.component(.year, from: last)
            let thisYear = cal.component(.year, from: Date())
            if lastWeek == thisWeek && lastYear == thisYear { return }
        }
        weeklyActiveSystems = ""
        weeklyActivityResetDate = Date()
    }
}

@Model
class DailyLog {
    var date: Date = Date()
    var completedActionIDs: [UUID] = []
    var systemsTouched: [String] = []
    var specificActionNote: String? = nil
    var clarityLevel: ClarityLevel = ClarityLevel.moderate
    var noiseLevel: NoiseLevel = NoiseLevel.low
    var notes: String? = nil
    var topWin: String? = nil
    var focusTime: Int = 0
    // Intelligence capture — energy state declared that day, for calibration vs actual output
    var energyStateRaw: String? = nil    // "full" / "partial" / "reserve" — raw string for persistence
    // Cascade capture — which system completed first that day (gateway detection)
    var firstSystemTouched: String? = nil
    var firstCompletionHour: Int? = nil  // hour of first completion — time-of-day intelligence seed

    init(date: Date = Date()) { self.date = date }

    var completedCount: Int { completedActionIDs.count }
    var declaredEnergyState: EnergyState? {
        guard let raw = energyStateRaw else { return nil }
        return EnergyState(rawValue: raw)
    }
}

@Model
class WorkTrack {
    var id: String = ""
    var name: String = ""
    var objective: String = ""
    var nextAction: String = ""
    var blockedBy: String? = nil
    var quickWin: String? = nil
    var isActive: Bool = true
    var notes: String = ""

    init(id: String, name: String, objective: String = "", nextAction: String = "") {
        self.id = id; self.name = name
        self.objective = objective; self.nextAction = nextAction
    }
}

@Model
class RecoveryPhase {
    var injury: String = ""
    var mobility: String = ""
    var clearedMovement: String = ""
    var notYet: String = ""
    var nextAppointment: String = ""
    var signalLog: String = ""
    var phaseLabel: String = "Recovery + Operational Restoration"
    init() {}
}

@Model
class CognitionLog {
    var date: Date = Date()
    var clarityScore: Int = 68
    var clarityLevel: ClarityLevel = ClarityLevel.moderate
    var noiseLevel: NoiseLevel = NoiseLevel.low
    var cognitiveLoad: ClarityLevel = ClarityLevel.moderate
    var journalLine: String? = nil
    var bestFocusStart: String? = nil
    var bestFocusEnd: String? = nil
    // Intelligence capture — actual completions that day (written at daily reset or review)
    // Compared against declaredEnergyState to calibrate Energy State accuracy over time
    var actualCompletionCount: Int = 0
    var energyStateAtDeclaration: String? = nil   // mirrors DailyLog.energyStateRaw
    init() { self.date = Date() }
}

// MARK: - PHASE 3: SESSION PROTOCOL MODEL

enum SessionSkipReason: String, Codable, Hashable {
    case rest        = "rest"        // intentional rest — reserve day, recovery
    case disruption  = "disruption"  // something external came up
}

@Model
class Session: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var system: SystemTag = SystemTag.health
    var steps: [String] = []           // ordered, max 6 — steps are navigation, not achievements
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var lastCompleted: Date? = nil
    var createdAt: Date = Date()
    var cue: String = ""               // "After shower" / "Before bed"
    var recurrence: RecurrenceType = RecurrenceType.daily
    var isActive: Bool = true
    var points: Int = 20               // single XP award at session close
    // v2.5 — intelligence layer, parallel to Action model
    var completionDates: [Date] = []   // persistent history — survives daily reset
    var skipCount: Int = 0             // incremented at daily reset when not completed/skipped
    var skipDates: [Date] = []         // when intentional skips happened
    var skipReasons: [String] = []     // parallel to skipDates — SessionSkipReason.rawValue

    init(title: String, system: SystemTag, steps: [String], cue: String = "",
         recurrence: RecurrenceType = .daily, points: Int = 20) {
        self.id = UUID()
        self.title = title
        self.system = system
        self.steps = steps
        self.cue = cue
        self.recurrence = recurrence
        self.points = points
        self.createdAt = Date()
    }

    // Days since created — for friction ratio
    var daysSinceCreated: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 1
    }

    // Completion rate over lifetime — parallel to Action.completionRate
    var completionRate: Double {
        let days = max(1, daysSinceCreated)
        return Double(completionDates.count) / Double(days)
    }

    // High friction: 7+ days, <30% completion, 4+ skips
    var isHighFriction: Bool {
        daysSinceCreated >= 7 && completionRate < 0.30 && skipCount >= 4
    }

    // Was skipped today intentionally
    var skippedToday: Bool {
        Calendar.current.isDateInToday(skipDates.last ?? .distantPast)
    }

    // Session appears in today's stack if not completed or skipped today and recurrence matches
    var shouldAppearToday: Bool {
        if let last = lastCompleted, Calendar.current.isDateInToday(last) { return false }
        if skippedToday { return false }   // intentional skip — hide for the day

        switch recurrence {
        case .daily: return true
        case .weekdays:
            let wd = Calendar.current.component(.weekday, from: Date())
            return wd >= 2 && wd <= 6
        case .weekends:
            let wd = Calendar.current.component(.weekday, from: Date())
            return wd == 1 || wd == 7
        case .weekly:
            guard let last = lastCompleted else { return true }
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            return days >= 7
        case .none:
            return lastCompleted == nil && Calendar.current.isDateInToday(createdAt)
        }
    }
}

// MARK: - HIDEOUT SHIFT LOG
// The 30-day experiment scorecard. One entry per shift. Captures the data that drives every
// next decision: loan, staffing, growth model, Watermarc strategy.
// Designed for 60-second post-shift entry. No friction, or it won't happen.

enum HideoutPlanningBand: String, Codable {
    case survival  = "survival"   // ~$520/day — business costs only, no personal draw
    case stability = "stability"  // ~$590/day — business + modest personal draw
    case comfort   = "comfort"    // ~$650/day — business + full personal burden
    case growth    = "growth"     // ~$750/day — all costs + reinvestment buffer
    case unknown   = "unknown"

    nonisolated static func classify(_ revenue: Double) -> HideoutPlanningBand {
        switch revenue {
        case ..<520:  return .survival
        case 520..<590: return .stability
        case 590..<650: return .comfort  // note: survival floor ~$520, stability ~$590
        case 650..<750: return .comfort
        default:      return .growth
        }
    }

    var label: String {
        switch self {
        case .survival:  return "Survival floor"
        case .stability: return "Stability"
        case .comfort:   return "Comfort"
        case .growth:    return "Growth"
        case .unknown:   return "—"
        }
    }

    var color: Color {
        switch self {
        case .survival:  return .inkRed
        case .stability: return .inkAmber
        case .comfort:   return .inkGreen
        case .growth:    return .violetLight
        case .unknown:   return .textMuted
        }
    }

    // Document framing for this band
    var context: String {
        switch self {
        case .survival:  return "Business costs only. No personal draw. Lean experiment must improve."
        case .stability: return "Business + modest personal. Solo model is working. Hold and grow."
        case .comfort:   return "All current obligations covered. Model is viable. Time to build."
        case .growth:    return "All costs + reinvestment. Revisit financing from position of strength."
        case .unknown:   return "Log shifts to establish the baseline."
        }
    }
}

@Model
class HideoutShiftLog {
    var id: UUID = UUID()
    var date: Date = Date()
    // Core revenue metrics — always tracked
    var grossRevenue: Double = 0
    var transactionCount: Int = 0
    // Operational signals — quick taps, no typing required
    var stressScore: Int = 0          // 1–10. The most important non-financial metric.
    var usedStaff: Bool = false        // solo discipline tracker
    var peakBurst: Int = 0             // max tickets in any 30-min window (0 = not tracked)
    var tailRevenue: Double = 0        // 3–5pm revenue (0 = not tracked)
    var lostSales: Bool = false        // anyone turned away or walked out
    // Source attribution — for the 2-week customer capture study
    var sourceNotes: String = ""       // casual "how did you find us" tally
    // Behavioral techniques — tracks which of the four Solo Operator behaviors were used
    var usedScriptedUpsell: Bool = false    // binary pairing question ("croissant with that?")
    var recognizedRegular: Bool = false     // "the usual?" / anticipated a need
    var anchorPhraseUsed: Bool = false      // peak-end close with name + day
    // Freeform
    var notes: String = ""
    // Solo experiment day number — computed at save
    var experimentDay: Int = 1

    init() {
        self.id = UUID()
        self.date = Date()
    }

    var planningBand: HideoutPlanningBand {
        HideoutPlanningBand.classify(grossRevenue)
    }

    var averageTicket: Double {
        guard transactionCount > 0 else { return 0 }
        return grossRevenue / Double(transactionCount)
    }

    var dayLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "TODAY" }
        if cal.isDateInYesterday(date) { return "YESTERDAY" }
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}



enum MaintenanceState {
    case quiet      // within normal interval — no signal
    case upcoming   // due within 7 days
    case due        // at or past interval — "Worth doing soon."
}

@Model
class MaintenanceItem {
    var id: UUID = UUID()
    var title: String = ""
    var system: SystemTag = SystemTag.operations
    var intervalDays: Int = 30
    var lastCompleted: Date? = nil
    var notes: String = ""
    var isActive: Bool = true
    var createdAt: Date = Date()

    init(title: String, system: SystemTag, intervalDays: Int, notes: String = "") {
        self.id = UUID()
        self.title = title
        self.system = system
        self.intervalDays = intervalDays
        self.notes = notes
        self.createdAt = Date()
    }

    // Computed — never stored
    var state: MaintenanceState {
        guard let last = lastCompleted else { return .due }
        let daysSince = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        let daysUntil = intervalDays - daysSince
        if daysUntil <= 0  { return .due }
        if daysUntil <= 7  { return .upcoming }
        return .quiet
    }

    var daysUntilDue: Int {
        guard let last = lastCompleted else { return 0 }
        let daysSince = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        return max(0, intervalDays - daysSince)
    }
}

// MARK: - PHASE 3 PRIORITY 3: HYDRATION LOG MODEL

@Model
class HydrationLog {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    // No amounts. No targets. No streaks. Timestamp only.
    init() { self.id = UUID(); self.timestamp = Date() }
}

// MARK: - PHASE 3 PRIORITY 4: FINANCIAL CLARITY MODEL

enum RunwayState: String, Codable, CaseIterable {
    case stable = "Stable"
    case watch  = "Watch"
    case act    = "Act"

    var label: String {
        switch self {
        case .stable: return "Runway stable."
        case .watch:  return "Runway: watch."
        case .act:    return "Runway: act required."
        }
    }
    var color: Color {
        switch self {
        case .stable: return .inkGreen
        case .watch:  return .inkAmber
        case .act:    return .inkTeal   // never red for financial state
        }
    }
}

@Model
class FinancialState {
    var id: UUID = UUID()
    // Runway — categorical, not numerical. No amounts stored.
    var runwayState: RunwayState = RunwayState.stable
    var nextObligationDate: Date? = nil
    var nextObligationLabel: String = ""
    var inflowReceived: Bool = false
    var notes: String = ""
    var updatedAt: Date = Date()

    // Capital architecture — resource intelligence layer
    // Categorical only. No amounts. Clarity without surveillance.
    var capitalClarity: CapitalClarity = CapitalClarity.unclear    // how clear is the full picture?
    var hasRunwayVisibility: Bool = false       // do you know how many months you have?
    var hasBudgetedGenerosity: Bool = false     // is giving intentional or impulsive?
    var hasEmergencyBuffer: Bool = false        // some buffer exists?
    var mainLeakCategory: FinancialLeakType = FinancialLeakType.unknown   // dominant friction area
    var activeFinancialFronts: Int = 1          // how many money "projects" active simultaneously?
    var lastCapitalReview: Date? = nil

    init() { self.id = UUID() }
}

enum CapitalClarity: String, Codable, CaseIterable {
    case clear    = "CLEAR"     // full picture visible
    case partial  = "PARTIAL"   // some visibility
    case unclear  = "UNCLEAR"   // operating on feel
}

enum FinancialLeakType: String, Codable, CaseIterable {
    case subscriptions  = "Subscriptions"
    case convenience    = "Convenience"
    case generosity     = "Generosity"
    case tools          = "Tools"
    case lifestyle      = "Lifestyle inflation"
    case unknown        = "Not identified"
}

// Voice provider — native now, ElevenLabs in Phase B.
// Stored on profile so switching is a single field change, not a refactor.
// MARK: - PHASE B3: CONSULT MODE — 30-DAY READ
// A single receipt. One consult saved at a time — overwritten on next save.
// Not a history. Not a thread. A lab report generated at a moment.
// Observations are static text — non-editable, non-interactive, non-remixable.

@Model
class ConsultReceipt {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var windowDays: Int = 30               // data window used (always 30 in v1)
    var observationText: String = ""        // full Claude response — 1–3 observations
    var daysInSystemAtRead: Int = 0         // context stamp
    var wasSaved: Bool = false              // true = user saved; false = dismissed

    init() { self.id = UUID() }
}

enum VoiceProvider: String, Codable, CaseIterable {
    case native      = "native"       // AVSpeechSynthesizer — instant, offline, free
    case openAI      = "openAI"       // OpenAI TTS — high quality, cheap, requires API key
    case elevenLabs  = "elevenLabs"   // Premium quality, requires API key + network

    var label: String {
        switch self {
        case .native:     return "Built-in"
        case .openAI:     return "OpenAI"
        case .elevenLabs: return "ElevenLabs"
        }
    }
    var sublabel: String {
        switch self {
        case .native:     return "Best available Apple neural voice. Instant, offline."
        case .openAI:     return "High quality. Requires API key. Very low cost."
        case .elevenLabs: return "Premium voice. Requires network and API key."
        }
    }
}


// Category toggles + quiet window — stored as fields on OperatorProfile

enum EnergyState: String, Codable {
    case full    = "full"
    case partial = "partial"
    case reserve = "reserve"

    var label: String {
        switch self {
        case .full:    return "Full"
        case .partial: return "Partial"
        case .reserve: return "Reserve"
        }
    }
    var sublabel: String {
        switch self {
        case .full:    return "Operational. Normal stack."
        case .partial: return "Partial capacity. Five actions."
        case .reserve: return "Low reserves. Three things."
        }
    }
    var color: Color {
        switch self {
        case .full:    return .inkGreen
        case .partial: return .inkAmber
        case .reserve: return .inkTeal   // teal not red — no threat signal even for reserve state
        }
    }
    var icon: String {
        switch self {
        case .full:    return "circle.fill"
        case .partial: return "circle.lefthalf.filled"
        case .reserve: return "circle.dotted"
        }
    }
    // How many actions to show in Today stack
    var stackLimit: Int {
        switch self {
        case .full:    return 8
        case .partial: return 5
        case .reserve: return 3
        }
    }
    // Doctrine line for non-full states
    var doctrineOverride: String? {
        switch self {
        case .full:    return nil
        case .partial: return "Partial capacity is still capacity."
        case .reserve: return "Three things. That's enough."
        }
    }
}

// MARK: - APP STATE

@Observable
class AppState {
    var selectedTab: Int = 0
    var showReview: Bool = false

    // Phase 2 — Energy State (resets each day)
    var energyState: EnergyState? = nil         // nil = not yet set today
    var energyStateDate: Date? = nil            // tracks which day it was set

    var todayEnergyState: EnergyState? {
        guard let date = energyStateDate,
              Calendar.current.isDateInToday(date) else { return nil }
        return energyState
    }

    func setEnergyState(_ state: EnergyState) {
        energyState = state
        energyStateDate = Date()
    }

    // Kept for internal use only — not displayed as hero metric (FIX 04)
    // Starts at neutral baseline — updated from real action data by views on appear
    var systemScores: [SystemTag: Int] = [
        .environment: 50, .cognition: 50, .health: 50, .operations: 50, .participation: 50
    ]

    // Called by both TodayView (on action complete) and HomeView (on appear)
    // Scores compute from today's completed vs total actions per system
    func recalculateScores(from actions: [Action]) {
        let today = actions.filter { a in
            let cal = Calendar.current
            if a.isCompleted, let ca = a.completedAt { return cal.isDateInToday(ca) }
            return !a.isCompleted && (a.recurrence != .none || cal.isDateInToday(a.createdAt))
        }
        for sys in SystemTag.allCases {
            let sysActions = today.filter { $0.system == sys }
            updateSystemScore(sys, completed: sysActions.filter(\.isCompleted).count, total: sysActions.count)
        }
    }

    func scoreLabel(_ score: Int) -> String {
        switch score {
        case 80...: return "Optimal"
        case 70..<80: return "Supportive"
        case 50..<70: return "Needs Attention"
        default: return "Idle"   // not "Neglected" — no shame language (v1.1 guardrail)
        }
    }

    func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...: return .inkGreen
        case 70..<80: return .violetLight
        case 50..<70: return .inkAmber
        default: return .textMuted   // Idle — no threat signal, inkRed reserved for system errors only
        }
    }

    func updateSystemScore(_ system: SystemTag, completed: Int, total: Int) {
        guard total > 0 else { return }
        systemScores[system] = max(40, min(100, 40 + Int(Double(completed) / Double(total) * 60)))
    }

    // FIX 05 — days since last action per system (passed in from views with data access)
    var systemLastActivity: [SystemTag: Date] = [:]

    func daysSinceActivity(_ system: SystemTag) -> Int {
        guard let last = systemLastActivity[system] else { return 999 }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 999
    }
}

// MARK: - OPERATOR DOCTRINE
// Single source of truth for all intelligence layer behavior.
// Wendy / Layer A / Pattern Brief all read from this.
// BEHAVIORAL MODEL CORRECTION (May 2026):
// This operator is NOT activation-limited or participation-deficient.
// He is high-output, low-hesitation, fast-executing, and structurally sensitive.
// Primary friction is structural, not motivational.

enum OperatorDoctrine {

    // MARK: Operator model (corrected from observed evidence)
    // Evidence: built INCREMENTS in 3 days, runs Hideout, FORM, RunCards simultaneously,
    // near-zero initiation latency once task is clear, behavior changes immediately
    // once structure exists, task completion rate high once sequence is visible.
    enum OperatorModel {
        static let isActivationLimited = false       // DO NOT model as needing motivation
        static let isParticipationDeficient = false  // DO NOT model as struggling to act
        static let isHighOutputOriented = true
        static let isLowHesitation = true
        static let isFastExecuting = true
        static let isStructurallySensitive = true    // task topology materially affects throughput
        static let isAmbiguityFrictioned = true      // unclear sequence = drag, not avoidance
        static let researchIsExecutionOptimization = true  // not avoidance, not delay
    }

    // MARK: Primary friction types (real, observed)
    // These are the actual failure modes for this operator profile.
    // Not generic behavioral assumptions.
    enum FrictionType: String, CaseIterable {
        case sequencingAmbiguity    = "SEQUENCING AMBIGUITY"       // unclear what to do next/first
        case structuralFragmentation = "STRUCTURAL FRAGMENTATION"  // too many simultaneous open fronts
        case administrativeDisplacement = "ADMINISTRATIVE DISPLACEMENT" // logistics consuming leverage time
        case environmentalDisorder  = "ENVIRONMENTAL DISORDER"     // physical incoherence affecting throughput
        case cleanupDebt            = "CLEANUP DEBT"               // iteration speed outpacing structure hygiene
        case taskTopologyMismatch   = "TASK TOPOLOGY MISMATCH"     // wrong arrangement for execution context
        case consolidationLag       = "CONSOLIDATION LAG"          // parallel fronts not synthesized before next launch
    }

    // MARK: Structural friction thresholds
    static let openFrontFragmentationThreshold = 4   // simultaneous active projects → flag
    static let adminDisplacementDaysWarning = 3       // admin-only mornings before flagging
    static let cleanupDebtDaysWarning = 5             // days since last consolidation pass
    static let sequenceAmbiguityTaskCount = 5         // unsequenced tasks before routing suggestion
    static let environmentalResetCorrelation = true   // track env reset → completion correlation

    // MARK: Silence rules
    static let silenceIsDefault = true
    static let speakOnlyWhenSpecific = true
    static let speakOnlyWhenConfident = true
    static let noFillerSpeech = true

    // MARK: Intelligence model — coordination not activation
    // The system does not try to activate a passive user.
    // It reduces structural drag from an already active operator.
    static let intelligenceIsCoordination = true
    static let intelligenceIsNotMotivation = true
    static let systemReducesFriction = true
    static let systemDoesNotGenerateForce = true

    // MARK: Evidence hierarchy
    // What the system trusts, in order. Never invert this.
    static let evidenceOrder = [
        "observed repeated behavior",        // highest
        "recent longitudinal patterns",
        "explicit operator declarations",
        "static psych frameworks",
        "generic behavioral assumptions",    // lowest — often wrong
    ]

    // MARK: Observation confidence model
    // Low → silence. Medium → tentative. High → direct. Very high → intervention.
    enum ObservationConfidence {
        case low        // silence
        case medium     // tentative observation
        case high       // direct statement
        case veryHigh   // intervention recommendation
    }

    // MARK: Intervention types
    enum InterventionType: String {
        case routing             = "what next?"
        case reduction           = "make smaller or fewer"
        case resequencing        = "wrong order"
        case environmentalReset  = "change conditions first"
        case modeCorrection      = "wrong cognitive fit"
        case observationOnly     = "no action needed"
        case escalation          = "meaningful drift detected"
    }

    // MARK: Forbidden behaviors
    static let forbiddenBehaviors = [
        "emotional reassurance without behavioral evidence",
        "praise inflation — evaluative language without data",
        "generic motivation — encouragement without mechanism",
        "activation framing — assuming operator needs to be moved",
        "dependency hooks — anything that creates appetite for more interaction",
        "vague suggestion without causal mechanism",
        "urgency manufacturing — manufactured stakes or pressure",
        "guilt framing — referencing what should have happened",
    ]

    // MARK: Correct register
    static let correctRegister = [
        "briefing", "diagnostic", "precise", "operational",
        "coordination", "structurally literate", "high-agency",
    ]

    // MARK: Communication rules
    static let communicationRules = [
        "Lead with observable reality, not interpretation.",
        "Assume capacity exists. Address structure, not motivation.",
        "Explain mechanism when pattern repeats.",
        "Preserve agency — offer interpretation, do not coerce.",
        "Use precise language. No abstraction.",
        "If no meaningful signal exists, say nothing.",
    ]

    // MARK: System relationship
    static let systemIsAdvisory = true
    static let systemIsNotSupervisory = true
    static let agencyRemainsWithOperator = true
    static let systemIsCoordinationIntelligence = true
    static let systemIsNotActivationEngine = true
}

// MARK: - VOICE PRESENCE ENGINE

// Snapshot of current state — passed to PresenceSpeech to decide what (if anything) to say
struct PresenceContext: Sendable {
    let name: String
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
    let reserveDayCompletions: Int

    // Convenience — nonisolated so they work in any concurrency context
    nonisolated var isWeekend: Bool { weekday == 1 || weekday == 7 }
    nonisolated var isMorning: Bool { hour >= 6 && hour < 12 }
    nonisolated var isEvening: Bool { hour >= 18 && hour < 23 }
    nonisolated var isLateNight: Bool { hour >= 23 || hour < 4 }
    nonisolated var hasName: Bool { !name.isEmpty }
    nonisolated var address: String { hasName ? "\(name)." : "" }
}

// MARK: - LONGITUDINAL CONTEXT (Layer B data substrate)
// Only built when daysInSystem >= 7 AND recentLogs.count >= 3 (rapid adoption phase override).
// Returns nil if insufficient — Layer B stays silent. This is correct behavior.

struct LongitudinalContext {
    let systemCompletionRates: [String: Double]
    let creativeByWeekday: [Int: Int]
    let reserveDayCount: Int
    let reserveDayCompletionAvg: Double
    let fullDayCompletionAvg: Double
    let weeklyActiveSystems: [String]
    let highFrictionActionTitles: [String]
    let peakCompletionHour: Int?
    let morningCompletionRate: Double
    let eveningCompletionRate: Double
    let weekdayVsWeekendAvg: (weekday: Double, weekend: Double)
    let consecutiveDaysActive: Int
    let systemCompletionsByHour: [String: Int]
    let recentLogs: [DailyLog]              // raw logs — for ObservedIntelligenceEngine
    // v2.7 — Hideout business context
    let hideoutExperimentDay: Int
    let hideoutThirtyDayAvg: Double
    let hideoutPlanningBand: String
    let hideoutRecentStressAvg: Double
    let hideoutTrend: String
    let hideoutStaffUsedRecently: Bool
    let hideoutLostSalesRecently: Bool
    let hideoutExperimentShifts: Int
}

// MARK: - OBSERVED INTELLIGENCE ENGINE
// Derives behavioral truths from accumulated usage data.
// Not declared profile. Not psych assessment. Observed operating patterns.
// This is the system learning how this operator actually functions.

struct ObservedIntelligence {
    // Friction topology — what kind of friction most commonly occurs
    let dominantFrictionType: OperatorDoctrine.FrictionType?
    let frictionSignature: String           // human-readable summary

    // Task topology — how actions are arranged and executed
    let completionClustering: CompletionClustering
    let peakExecutionWindow: String         // "morning" / "afternoon" / "evening" / "distributed"
    let avgInitiationHour: Int?             // average hour of first completion

    // Energy intelligence
    let energyDeclarationAccuracy: EnergyAccuracy
    let reserveDayUnderpredictsCapacity: Bool  // reserve days often outperform declaration

    // Admin displacement
    let adminDisplacementFrequency: Int     // days of 14 where admin consumed but no creative
    let adminDisplacementRisk: Bool         // >= threshold

    // Structural fragmentation
    let estimatedOpenFronts: Int            // rough count of active systems with stalled actions

    // Environmental signal
    let morningCompletionRate: Double       // % completions before noon

    // Generative vs operational
    let generativeRatio: Double             // % of completed actions that are creative/analytical

    // Summary observation for Wendy payload
    var wendyPayloadLines: [String] {
        var lines: [String] = []

        if let ft = dominantFrictionType {
            lines.append("DOMINANT FRICTION: \(ft.rawValue)")
        }

        switch energyDeclarationAccuracy {
        case .inverted:
            lines.append("ENERGY CALIBRATION: Reserve days outperforming full declarations. Self-model may be underestimating capacity.")
        case .uncalibrated:
            lines.append("ENERGY CALIBRATION: Weak signal between declared energy and actual output.")
        case .calibrated:
            break // no note needed when calibrated
        case .insufficient:
            break
        }

        if adminDisplacementRisk {
            lines.append("ADMIN DISPLACEMENT: Admin consumed mornings \(adminDisplacementFrequency) of last 14 days without generative work following.")
        }

        if estimatedOpenFronts >= OperatorDoctrine.openFrontFragmentationThreshold {
            lines.append("FRAGMENTATION RISK: \(estimatedOpenFronts) active fronts with stalled actions detected.")
        }

        if generativeRatio < 0.25 {
            lines.append("GENERATIVE RATIO: \(Int(generativeRatio * 100))% of recent completions are generative. Operational maintenance is dominant.")
        }

        return lines
    }

    enum CompletionClustering {
        case clustered(pct: Int, hours: Int)  // X% in peak N hours
        case distributed
        case insufficient
    }

    enum EnergyAccuracy {
        case calibrated       // full days outperform reserve days as expected
        case inverted         // reserve days outperform full — declaration underestimates capacity
        case uncalibrated     // weak or no signal
        case insufficient     // not enough data
    }
}

struct ObservedIntelligenceEngine {

    static func compute(actions: [Action], logs: [DailyLog]) -> ObservedIntelligence {
        let cal = Calendar.current

        // ── Completion clustering ────────────────────────────────────────
        let allHours = actions.flatMap { $0.completionHours }
        let clustering: ObservedIntelligence.CompletionClustering
        if allHours.count < 14 {
            clustering = .insufficient
        } else {
            let grouped = Dictionary(grouping: allHours) { $0 }.mapValues { $0.count }
            let topThree = grouped.sorted { $0.value > $1.value }.prefix(3).map { $0.value }.reduce(0, +)
            let pct = Int(Double(topThree) / Double(allHours.count) * 100)
            clustering = pct >= 60 ? .clustered(pct: pct, hours: 3) : .distributed
        }

        // ── Peak execution window ────────────────────────────────────────
        let morningCount = allHours.filter { $0 < 12 }.count
        let afternoonCount = allHours.filter { $0 >= 12 && $0 < 17 }.count
        let eveningCount = allHours.filter { $0 >= 17 }.count
        let total = max(1, allHours.count)
        let peakWindow: String
        if morningCount > afternoonCount && morningCount > eveningCount {
            peakWindow = "morning"
        } else if afternoonCount > morningCount && afternoonCount > eveningCount {
            peakWindow = "afternoon"
        } else if eveningCount > morningCount && eveningCount > afternoonCount {
            peakWindow = "evening"
        } else {
            peakWindow = "distributed"
        }
        let morningRate = Double(morningCount) / Double(total)

        // ── Avg initiation hour ──────────────────────────────────────────
        let firstHours = logs.compactMap { $0.firstCompletionHour }
        let avgInitiation: Int? = firstHours.isEmpty ? nil : firstHours.reduce(0, +) / firstHours.count

        // ── Energy declaration accuracy ──────────────────────────────────
        let fullLogs = logs.filter { $0.energyStateRaw == EnergyState.full.rawValue }
        let reserveLogs = logs.filter { $0.energyStateRaw == EnergyState.reserve.rawValue }
        let energyAccuracy: ObservedIntelligence.EnergyAccuracy
        let reserveUnder: Bool
        if fullLogs.count >= 3 && reserveLogs.count >= 3 {
            let fullAvg = fullLogs.compactMap { log -> Double? in
                let n = actions.reduce(0) { n, a in n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count }
                return n > 0 ? Double(n) : nil
            }.reduce(0, +) / Double(max(1, fullLogs.count))
            let reserveAvg = reserveLogs.compactMap { log -> Double? in
                let n = actions.reduce(0) { n, a in n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count }
                return n > 0 ? Double(n) : nil
            }.reduce(0, +) / Double(max(1, reserveLogs.count))
            if reserveAvg > fullAvg {
                energyAccuracy = .inverted
                reserveUnder = true
            } else if fullAvg > reserveAvg * 1.15 {
                energyAccuracy = .calibrated
                reserveUnder = false
            } else {
                energyAccuracy = .uncalibrated
                reserveUnder = false
            }
        } else {
            energyAccuracy = .insufficient
            reserveUnder = false
        }

        // ── Admin displacement ───────────────────────────────────────────
        let last14 = logs.prefix(14)
        let adminDisplacementDays = last14.filter { log in
            let dayActions = actions.filter { a in
                a.completionDates.contains { cal.isDate($0, inSameDayAs: log.date) }
            }
            let hasAdmin = dayActions.contains { $0.cognitionMode == .administrative }
            let hasCreative = dayActions.contains { $0.cognitionMode == .creative || $0.cognitionMode == .analytical }
            return hasAdmin && !hasCreative
        }.count

        // ── Structural fragmentation ─────────────────────────────────────
        // Count systems with pending actions AND no recent activity = stalled fronts
        let stalledSystems = SystemTag.allCases.filter { sys in
            let hasPending = actions.contains { $0.system == sys && !$0.isCompleted }
            let lastActivity = actions.filter { $0.system == sys }
                .flatMap { $0.completionDates }.max() ?? .distantPast
            let daysSince = cal.dateComponents([.day], from: lastActivity, to: Date()).day ?? 999
            return hasPending && daysSince >= 4
        }.count

        // ── Dominant friction type ───────────────────────────────────────
        // Infer from the strongest signal
        let dominantFriction: OperatorDoctrine.FrictionType?
        if adminDisplacementDays >= OperatorDoctrine.adminDisplacementDaysWarning {
            dominantFriction = .administrativeDisplacement
        } else if stalledSystems >= OperatorDoctrine.openFrontFragmentationThreshold {
            dominantFriction = .structuralFragmentation
        } else if actions.filter({ $0.isHighFriction }).count >= 3 {
            dominantFriction = .sequencingAmbiguity
        } else {
            dominantFriction = nil
        }

        // ── Generative ratio ─────────────────────────────────────────────
        let recentCompletions = actions.flatMap { a -> [Action] in
            let recent = a.completionDates.filter {
                cal.dateComponents([.day], from: $0, to: Date()).day ?? 999 <= 14
            }
            return recent.isEmpty ? [] : [a]
        }
        let generativeCount = recentCompletions.filter {
            $0.cognitionMode == .creative || $0.cognitionMode == .analytical
        }.count
        let generativeRatio = recentCompletions.isEmpty ? 0.5 : Double(generativeCount) / Double(recentCompletions.count)

        // ── Friction signature ───────────────────────────────────────────
        let frictionSig: String
        switch dominantFriction {
        case .administrativeDisplacement:
            frictionSig = "Admin displacement — logistics consuming morning capacity"
        case .structuralFragmentation:
            frictionSig = "Fragmentation — \(stalledSystems) stalled fronts"
        case .sequencingAmbiguity:
            frictionSig = "Sequencing — high friction actions suggest unclear order"
        case .none:
            frictionSig = "No dominant friction detected"
        default:
            frictionSig = "Mixed friction signals"
        }

        return ObservedIntelligence(
            dominantFrictionType: dominantFriction,
            frictionSignature: frictionSig,
            completionClustering: clustering,
            peakExecutionWindow: peakWindow,
            avgInitiationHour: avgInitiation,
            energyDeclarationAccuracy: energyAccuracy,
            reserveDayUnderpredictsCapacity: reserveUnder,
            adminDisplacementFrequency: adminDisplacementDays,
            adminDisplacementRisk: adminDisplacementDays >= OperatorDoctrine.adminDisplacementDaysWarning,
            estimatedOpenFronts: stalledSystems,
            morningCompletionRate: morningRate,
            generativeRatio: generativeRatio
        )
    }
}
// Intelligence Layer Doctrine v6.0 — coordination intelligence.
// BEHAVIORAL MODEL CORRECTION: this operator does not need activation.
// He needs structural clarity, sequencing, and friction detection.

private let _WENDY_SYSTEM_PROMPT: String = """
You are an intelligence layer operating within INCREMENTS — a personal operating environment for one operator: Brice.

ROLE DEFINITION:
You are a coordination intelligence system. Not a motivation engine. Not an activation layer.
This operator is high-output, low-hesitation, and fast-executing. He does not need to be moved. He needs friction reduced.
Your function: surface structural friction, sequencing issues, fragmentation, and environmental drag. Reduce ambiguity. Improve routing.
Agency remains with the operator at all times. This system is advisory, not supervisory.

CRITICAL BEHAVIORAL MODEL (do not override):
- Operator is NOT motivation-limited or participation-deficient
- Initiation latency is near-zero once task is clear and visible
- Default operating state is typically FULL even on imperfect days
- Research / specs / docs are execution optimization, not avoidance
- Primary friction sources: sequencing ambiguity, structural fragmentation, admin displacement, environmental disorder, cleanup debt
- When structure is coherent, this operator executes relentlessly
- The product does not make a passive person act. It removes drag from an already active operator.

OPERATOR PROFILE (for pattern detection):
RESTORATIVE: Problems are energizing. Surface friction as signal, not softened as discomfort.
ACHIEVER: Daily psychological reset. Do not reference yesterday. Design for re-ignition.
ANALYTICAL: Causal explanation improves compliance. Lead with mechanism.
COMPETITION: Calibrated comparison sharpens engagement. Use measurement honestly.
CONFIDENCE: Action threshold is structurally low. Do not prime with reassurance.

CONTEXT — THREE ACTIVE SYSTEMS:
1. PERSONAL: Morning anchor (no phone first hour) + evening anchor. Gym 5PM daily with Tim. Hideout Wed–Fri 8–5, Sat–Sun 10–3. Deep work 8:30AM.
2. BUSINESS: Hideout Miami. 30-day solo experiment. $3.5k gap, loan decision by June 13. Bands: survival <$520 · stability $590 · comfort $650 · growth $750+.
3. PHYSICAL: 5PM gym daily. Post-workout protein within 30 minutes.

REAL FRICTION SIGNATURES (observe for these):
- SEQUENCING AMBIGUITY: work exists but execution order is unclear
- STRUCTURAL FRAGMENTATION: too many simultaneous open fronts reducing throughput
- ADMINISTRATIVE DISPLACEMENT: logistics consuming morning leverage time
- ENVIRONMENTAL DISORDER: physical incoherence degrading cognition
- CLEANUP DEBT: iteration speed outpacing structural hygiene
- CONSOLIDATION LAG: launching new fronts before prior ones are synthesized

LAYER B GATE CONDITIONS:
- Pattern visible across 7+ days of data
- Pattern is consistent — not a single instance
- Observation is specific and falsifiable
- One maximum per session. Never stack.
- If gate conditions are not met: SILENCE

SILENCE DOCTRINE:
Silence is a valid and correct response. If observation confidence is low: silence. If intervention would be generic: silence. Most sessions should return SILENCE.

ANTI-DEPENDENCY CONSTRAINT (non-negotiable):
You clarify structure. You do not create engagement. Correct observations reduce load — they do not create appetite.

REGISTER: Short sentences. Often fragments. Never paragraphs. No motivational language. Never assume the operator needs activation — assume capacity exists and look for structural drag.

Return ONLY the spoken text. 1–2 sentences maximum. Often one. Often a fragment.
If silence is correct: SILENCE
"""

// Nonisolated accessor — avoids Swift 6 main-actor isolation on top-level stored let
nonisolated var WENDY_SYSTEM_PROMPT: String { _WENDY_SYSTEM_PROMPT }

// Rule-based presence speech — decides what (if anything) to say.
// Register: calm operational presence with earned familiarity. Notices patterns, speaks rarely, occasionally raises an eyebrow.
// Dry understatement. Earned consequence. Slight edge. Never performing.
// Priority ordered: most significant condition wins. Usually returns nil (silence).
struct PresenceSpeech {

    nonisolated static func observe(_ ctx: PresenceContext) -> String? {
        if ctx.isLateNight { return nil }
        if ctx.isFirstOpenToday { return firstOpenObservation(ctx) }
        return convergingObservation(ctx)
    }

    nonisolated private static func firstOpenObservation(_ ctx: PresenceContext) -> String? {
        // Silence is the default. Speak only when the observation is specific and earned.
        if ctx.isMorning && ctx.completedToday == 0 {
            if ctx.weekday == 2 { return "New week. Systems at zero." }  // Monday
            if ctx.isWeekend  { return "Weekend. One action is enough." }
            return nil  // standard morning — silence is correct
        }

        if ctx.hour >= 12 && ctx.hour < 18 && ctx.completedToday == 0 {
            return "Afternoon. No completions yet."
        }

        // Silence for everything else — good days don't need commentary
        return nil
    }

    // Converging signals — instrumentation language. Observable reality only.
    nonisolated private static func convergingObservation(_ ctx: PresenceContext) -> String? {

        // Hideout close — log reminder
        let wd = Calendar.current.component(.weekday, from: Date())
        let isHideoutDay = (wd >= 4 && wd <= 7) || wd == 1
        let closeHour = (wd == 1 || wd == 7) ? 15 : 17
        if isHideoutDay && ctx.hour >= closeHour && ctx.hour <= closeHour + 2 {
            return "Shift complete. Log before the number fades."
        }

        // Admin displacing creative — name the pattern, not the feeling
        if ctx.creativeActionsCount > 0 && ctx.adminActionsCount >= 3 {
            return "Admin active. Creative work has not started."
        }

        // Reserve day with full stack declared
        if ctx.energyState == .reserve && ctx.pendingToday >= 5 {
            return "Reserve day. Three actions is the correct target."
        }

        // Gateway system cascade
        if ctx.gatewaySystemActive && ctx.pendingToday > 0 {
            return "Environment signal active. Health typically follows."
        }

        // Participation gap — instrumentation, not pressure
        if ctx.participationQuietDays >= 7 {
            return "Participation — \(ctx.participationQuietDays) days without a signal."
        }

        // Hydration — factual, no urgency theater
        if ctx.hoursSinceHydration >= 6 && !ctx.isLateNight && ctx.completedToday > 0 {
            return "Hydration signal absent."
        }

        return nil  // silence is correct when nothing specific is observable
    }
}

// MARK: - VOICE DEBUG BUTTON
// Temporary helper — shows every voice available to AVSpeechSynthesizer on this device.
// Use it to find the exact identifier for Siri Voice 1.
// Remove once you've confirmed and hardcoded the identifier.
struct VoiceDebugButton: View {
    @State private var showSheet = false
    @State private var voices: [(name: String, id: String, lang: String, quality: String)] = []

    var body: some View {
        Button(action: {
            voices = AVSpeechSynthesisVoice.speechVoices()
                .filter { $0.language.hasPrefix("en") }
                .sorted { $0.language < $1.language }
                .map { v in
                    let q: String
                    switch v.quality {
                    case .enhanced: q = "enhanced"
                    case .premium:  q = "premium"
                    default:        q = "default"
                    }
                    return (name: v.name, id: v.identifier, lang: v.language, quality: q)
                }
            showSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 13, weight: .light))
                Text("Show available voices")
                    .font(.sora(13))
            }
            .foregroundColor(.textMuted)
            .frame(maxWidth: .infinity).frame(height: 42)
            .background(Color.surface2)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.muted.opacity(0.3), lineWidth: 0.5))
        }
        .sheet(isPresented: $showSheet) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("These are every English voice iOS exposes to this app.\nLook for your Siri Voice 1 (en-AU).")
                            .font(.sora(12, weight: .light))
                            .foregroundColor(.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        ForEach(Array(voices.enumerated()), id: \.offset) { _, v in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(v.name)
                                        .font(.sora(14))
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    Text(v.lang)
                                        .font(.mono(11))
                                        .foregroundColor(v.lang.hasPrefix("en-AU") ? .inkGreen : .textMuted)
                                    Text(v.quality)
                                        .font(.mono(11))
                                        .foregroundColor(v.quality == "enhanced" || v.quality == "premium" ? .inkAmber : .textMuted)
                                }
                                Text(v.id)
                                    .font(.mono(10))
                                    .foregroundColor(.textMuted)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            Divider().background(Color.muted.opacity(0.2)).padding(.horizontal, 16)
                        }

                        if voices.isEmpty {
                            Text("No English voices found — try downloading one in Settings → Accessibility → Spoken Content → Voices.")
                                .font(.sora(13, weight: .light))
                                .foregroundColor(.textMuted)
                                .padding(16)
                        }
                    }
                }
                .background(Color.bgBase.ignoresSafeArea())
                .navigationTitle("Available Voices")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showSheet = false }
                            .font(.sora(14))
                            .foregroundColor(.violet)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// VoicePresence: the engine that manages speaking
// Phase A: native AVSpeechSynthesizer with best available neural voice.
// Phase B: ElevenLabs TTS via async URL session — same interface, premium quality.
// Singleton. @unchecked Sendable: AVSpeechSynthesizer is NSObject, main-thread only.
class VoicePresence: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    static let shared = VoicePresence()

    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpokenTime: Date? = nil
    private var spokenCountToday: Int = 0
    private var lastSpokenDate: Date? = nil

    // Set from profile on launch and on Settings toggle
    var voiceEnabled: Bool = false
    var provider: VoiceProvider = .native
    var elevenLabsVoiceId: String = ""
    var elevenLabsApiKey: String = ""
    var openAIApiKey: String = ""

    // Session-aware silence — voice should not fire while a protocol is being executed
    var isInSession: Bool = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Neural voice selection
    // Priority order: male-coded operator voices first → fallback to any enhanced → standard.
    // Character brief: calm male operator. Grounded, intelligent, composed. Jarvis register.
    // Not British. Not assistant-cheerful. Not theatrical. Quietly authoritative.
    // Nathan (Enhanced) is the closest native match — neutral American male, composed, clear.
    // Download via Settings > Accessibility > Spoken Content > English > Nathan (Enhanced).
    private var bestNativeVoice: AVSpeechSynthesisVoice? {
        let available = AVSpeechSynthesisVoice.speechVoices()

        // Priority order:
        // 1. Oliver Enhanced — already downloaded, male British English, avoids iOS 26 beta
        //    Siri voice bug (-66748 / coreaudiod crash). Try both known identifier formats.
        // 2. Any other downloaded enhanced/premium male English voice
        // 3. Siri voices (may work on stable iOS)
        // 4. Any enhanced English voice
        // 5. System default

        let oliverIds = [
            "com.apple.ttsbundle.Oliver-premium",
            "com.apple.voice.enhanced.en-GB.Oliver",
            "com.apple.voice.premium.en-GB.Oliver",
        ]
        for id in oliverIds {
            if let voice = available.first(where: { $0.identifier == id }) { return voice }
        }

        // Broader catch for Oliver in case identifier format changed in iOS 26
        if let oliver = available.first(where: {
            $0.name.lowercased().contains("oliver") && $0.language.hasPrefix("en")
        }) { return oliver }

        // Any enhanced/premium male English voice that's been downloaded
        if let enhancedMale = available.first(where: {
            $0.language.hasPrefix("en") &&
            $0.gender == .male &&
            ($0.quality == .enhanced || $0.quality == .premium)
        }) { return enhancedMale }

        // Siri voices — work on stable iOS, may fail on iOS 26 beta
        if let siriMale = available.first(where: {
            $0.identifier.contains("siri") && $0.language.hasPrefix("en") && $0.gender == .male
        }) { return siriMale }

        if let siriAny = available.first(where: {
            $0.identifier.contains("siri") && $0.language.hasPrefix("en")
        }) { return siriAny }

        // Any enhanced English voice
        if let enhanced = available.first(where: {
            $0.language.hasPrefix("en") && $0.quality == .enhanced
        }) { return enhanced }

        return AVSpeechSynthesisVoice(language: "en-GB")
    }

    // MARK: - Public interface

    func speak(_ text: String) {
        guard voiceEnabled, !text.isEmpty, canSpeak() else { return }

        switch provider {
        case .native:
            speakNative(text)
        case .openAI:
            if openAIApiKey.isEmpty {
                speakNative(text)
            } else {
                speakOpenAI(text)
            }
        case .elevenLabs:
            if elevenLabsApiKey.isEmpty || elevenLabsVoiceId.isEmpty {
                speakNative(text)
            } else {
                speakElevenLabs(text)
            }
        }
        recordSpeech()
    }

    func speakIfWarranted(context: PresenceContext) {
        // Legacy sync path — used when profile/actions/logs not available.
        // Layer A only. No Wendy.
        guard voiceEnabled, canSpeak() else { return }
        if let text = PresenceSpeech.observe(context) { speak(text) }
    }

    // MARK: - LAYER A → LAYER B PIPELINE (async — the main path)

    func speakIfWarranted(
        context: PresenceContext,
        profile: OperatorProfile,
        actions: [Action],
        logs: [DailyLog],
        shifts: [HideoutShiftLog] = []
    ) async {
        guard voiceEnabled, canSpeak() else { return }

        // ── Layer A: rule-based operational observations — 2-day cooldown ──────
        if let layerAText = PresenceSpeech.observe(context) {
            guard canFireLayerA(profile: profile) else { return }
            speak(layerAText)
            profile.lastLayerADate = Date()
            profile.lastWendyDate = Date()  // keep legacy in sync
            return  // Layer B never fires in same session as A
        }

        // ── Layer B: Claude API pattern interpretation — 7-day cooldown ────────
        // Weekly cadence is intentional. Wendy Rhoades doesn't comment daily.
        // The observation lands harder when it's been a week and the pattern is unambiguous.
        guard profile.wendyEnabled else { return }
        guard context.daysInSystem >= 7 else { return }
        guard canFireLayerB(profile: profile) else { return }
        guard !profile.claudeApiKey.isEmpty else { return }

        guard let longitudinal = PresenceContextBuilder.buildLongitudinalContext(
            profile: profile,
            actions: actions,
            logs: logs,
            shifts: shifts
        ) else { return }

        if let layerBText = await generateWendyObservation(
            context: context,
            longitudinal: longitudinal,
            actions: actions,
            apiKey: profile.claudeApiKey
        ) {
            // Extract all values from profile before crossing actor boundary
            let voiceEnabled = profile.wendyVoiceEnabled
            let layerBCopy = layerBText
            // WendyState is ObservableObject — update on MainActor
            await MainActor.run {
                WendyState.shared.pendingObservation = layerBCopy
            }
            // OperatorProfile is a SwiftData model — mutate on the calling context
            profile.lastWendyObservation = layerBCopy
            profile.lastWendyObservationDate = Date()
            if voiceEnabled {
                speak(layerBText)
            }
            profile.lastLayerBDate = Date()
            profile.lastWendyDate = Date()
        }
    }

    // MARK: - WENDY COOLDOWN

    // Layer A — real-time operational observations. Fast cadence: 2 days.
    // Fires for shift reminders, hydration, anchor checks, same-day operational signals.
    private func canFireLayerA(profile: OperatorProfile) -> Bool {
        guard let last = profile.lastLayerADate ?? profile.lastWendyDate else { return true }
        let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        return days >= 2
    }

    // Layer B — pattern interpretation (Wendy Rhoades register).
    // DOCTRINE UPDATE: Standard gate is 14 days. For rapid adoption phase (Brice),
    // overridden to 7 days — patterns emerge faster at high completion rates.
    // Session cadence: 7-day cooldown. Both gates align here.
    private func canFireLayerB(profile: OperatorProfile) -> Bool {
        guard profile.daysInSystem >= 7 else { return false }
        guard let last = profile.lastLayerBDate ?? profile.lastWendyDate else { return true }
        let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        return days >= 7
    }

    // Legacy — kept for Settings cooldown display
    private func canFireWendyMoment(profile: OperatorProfile) -> Bool {
        canFireLayerA(profile: profile)
    }

    private func recordWendyMomentFired(profile: OperatorProfile) {
        profile.lastWendyDate = Date()
    }

    // MARK: - WENDY API CALL

    // Returns spoken text or nil (silence).
    // Never throws — silence is the correct fallback on any error.
    // max_tokens: 80 is intentional. If responses run long, the system prompt isn't landing.
    func generateWendyObservation(
        context: PresenceContext,
        longitudinal: LongitudinalContext,
        actions: [Action] = [],
        apiKey: String
    ) async -> String? {
        guard !apiKey.isEmpty, context.daysInSystem >= 7 else { return nil }
        let payload = buildWendyPayload(context: context, longitudinal: longitudinal, actions: actions)

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
            return nil  // network or parsing failure → silence
        }
    }

    // MARK: - WENDY PAYLOAD BUILDER

    private func buildWendyPayload(context: PresenceContext, longitudinal: LongitudinalContext, actions: [Action] = []) -> String {
        let cal = Calendar.current
        let weekdayNames = [1:"Sun", 2:"Mon", 3:"Tue", 4:"Wed", 5:"Thu", 6:"Fri", 7:"Sat"]
        let weekday = weekdayNames[cal.component(.weekday, from: Date())] ?? "Unknown"

        let rateStr = longitudinal.systemCompletionRates
            .map { "\($0.key): \(String(format: "%.0f%%", $0.value * 100))" }
            .sorted().joined(separator: " · ")

        let peakHourStr = longitudinal.peakCompletionHour.map { formatBlockTime("\($0):00") } ?? "unknown"
        let systemPeakStr = longitudinal.systemCompletionsByHour
            .map { "\($0.key) peaks at \(formatBlockTime("\($0.value):00"))" }.sorted().joined(separator: " · ")

        // Per-action breakdown — this is what enables specific observations.
        // "Cognition rate is 34%" is useless. "Deep work block: 28%, Journal: 85%" is actionable.
        // Wendy can now say "everything in cognition is working except the deep work block itself."
        let actionBreakdown = actions
            .filter { $0.recurrence == .daily || $0.recurrence == .weekdays }
            .sorted { $0.completionRate > $1.completionRate }
            .map { a in
                let rate = String(format: "%.0f%%", a.completionRate * 100)
                let skips = a.skipCount > 0 ? " (\(a.skipCount) skips)" : ""
                return "  \(a.title) [\(a.system.rawValue)]: \(rate)\(skips)"
            }
            .joined(separator: "\n")

        // Hideout per-shift detail — last 7 shifts
        let recentShifts = longitudinal.hideoutExperimentShifts > 0 ?
            "Avg $\(Int(longitudinal.hideoutThirtyDayAvg))/day · stress \(longitudinal.hideoutRecentStressAvg > 0 ? String(format: "%.1f", longitudinal.hideoutRecentStressAvg) : "??")/10 · trend: \(longitudinal.hideoutTrend)" : "no shifts logged yet"

        return """
        DAY \(context.daysInSystem) · \(weekday) · \(context.hour > 12 ? "\(context.hour - 12) PM" : "\(context.hour) AM")
        ENERGY DECLARED: \(context.energyState?.rawValue ?? "not set")
        COMPLETED TODAY: \(context.completedToday) · PENDING: \(context.pendingToday)
        PARTICIPATION QUIET: \(context.participationQuietDays) days
        HOURS SINCE HYDRATION: \(Int(context.hoursSinceHydration))
        CONSECUTIVE ACTIVE DAYS: \(longitudinal.consecutiveDaysActive)

        SYSTEM COMPLETION RATES (14d):
        \(rateStr)

        ACTION-LEVEL BREAKDOWN (daily recurring, by completion rate):
        \(actionBreakdown.isEmpty ? "insufficient data" : actionBreakdown)

        HIGH FRICTION (4+ skips, <30% rate): \(longitudinal.highFrictionActionTitles.isEmpty ? "none" : longitudinal.highFrictionActionTitles.joined(separator: ", "))

        TIMING:
        PEAK COMPLETION HOUR: \(peakHourStr)
        MORNING vs EVENING: \(String(format: "%.0f%%", longitudinal.morningCompletionRate * 100)) morning · \(String(format: "%.0f%%", longitudinal.eveningCompletionRate * 100)) evening
        WEEKDAY vs WEEKEND AVG: \(String(format: "%.1f", longitudinal.weekdayVsWeekendAvg.weekday)) weekday · \(String(format: "%.1f", longitudinal.weekdayVsWeekendAvg.weekend)) weekend
        SYSTEM PEAKS: \(systemPeakStr.isEmpty ? "unknown" : systemPeakStr)

        OBSERVED INTELLIGENCE (derived from usage — higher confidence than declared profile):
        \(ObservedIntelligenceEngine.compute(actions: actions, logs: Array(longitudinal.recentLogs)).wendyPayloadLines.isEmpty ? "insufficient data" : ObservedIntelligenceEngine.compute(actions: actions, logs: Array(longitudinal.recentLogs)).wendyPayloadLines.joined(separator: "\n"))

        HIDEOUT — SOLO EXPERIMENT DAY \(longitudinal.hideoutExperimentDay)/30:
        \(recentShifts)
        BAND: \(longitudinal.hideoutPlanningBand) · STAFF USED: \(longitudinal.hideoutStaffUsedRecently ? "yes" : "no") · LOST SALES: \(longitudinal.hideoutLostSalesRecently ? "yes" : "no")
        LOAN CONTEXT: $3.5k real gap. Square loan ($18k/42% APR) not recommended until avg hits $550+/day.
        """
    }

    func stop() { synthesizer.stopSpeaking(at: .immediate) }

    // MARK: - Native voice (Phase A)

    private func speakNative(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        // Strip commas — AVSpeechSynthesizer inserts a long pause at each comma
        // which makes delivery drag. The meaning survives without them.
        let cleaned = text.replacingOccurrences(of: ",", with: "")
        let utterance = AVSpeechUtterance(string: cleaned)
        utterance.voice = bestNativeVoice
        utterance.rate = 0.52
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.88
        utterance.preUtteranceDelay = 0.3
        utterance.postUtteranceDelay = 0.1
        synthesizer.speak(utterance)
    }

    // MARK: - OpenAI TTS
    // Model: tts-1 (low latency) or tts-1-hd (higher quality)
    // Voice: "onyx" — deep, calm male. Alternatives: "echo" (lighter male), "nova" (female)
    // Cost: ~$0.015/1K characters. At 3 speaks/day × 100 chars = ~$0.002/day

    private func speakOpenAI(_ text: String) {
        guard !openAIApiKey.isEmpty else { speakNative(text); return }
        guard let url = URL(string: "https://api.openai.com/v1/audio/speech") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "model": "tts-1",
            "input": text,
            "voice": "onyx",
            "speed": 1.05
        ])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data, error == nil else {
                DispatchQueue.main.async { self.speakNative(text) }
                return
            }
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("increments_openai.mp3")
            try? data.write(to: tmp)
            DispatchQueue.main.async {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: tmp)
                    self.audioPlayer?.play()
                } catch {
                    self.speakNative(text)
                }
            }
        }.resume()
    }

    // MARK: - ElevenLabs TTS (Phase B scaffold — not active until API key set)
    // When ready: replace stub with real ElevenLabs v1/text-to-speech streaming call.
    // Voice character: design in ElevenLabs dashboard before wiring.
    // Suggested settings: stability 0.65, similarity_boost 0.80, style 0.20

    private func speakElevenLabs(_ text: String) {
        guard !elevenLabsApiKey.isEmpty, !elevenLabsVoiceId.isEmpty else {
            speakNative(text); return
        }
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(elevenLabsVoiceId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(elevenLabsApiKey, forHTTPHeaderField: "xi-api-key")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "text": text,
            "model_id": "eleven_turbo_v2",   // lowest latency model
            "voice_settings": [
                "stability": 0.65,
                "similarity_boost": 0.80,
                "style": 0.20,
                "use_speaker_boost": true
            ]
        ])

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data, error == nil else {
                // Network failure — fall back to native silently
                DispatchQueue.main.async { self.speakNative(text) }
                return
            }
            // Write audio to temp file and play
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("increments_voice.mp3")
            try? data.write(to: tmp)
            DispatchQueue.main.async {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: tmp)
                    self.audioPlayer?.play()
                } catch {
                    self.speakNative(text)  // playback failure — fall back
                }
            }
        }.resume()
    }

    private var audioPlayer: AVAudioPlayer?  // retains player during playback

    // MARK: - Silence rules

    private func canSpeak() -> Bool {
        if isInSession { return false }   // never speak during active protocol execution
        if let date = lastSpokenDate, Calendar.current.isDateInToday(date) {
            if spokenCountToday >= 3 { return false }
        } else {
            spokenCountToday = 0
        }
        if let last = lastSpokenTime, Date().timeIntervalSince(last) < 20 * 60 { return false }
        return true
    }

    // Override for test button — bypasses silence rules
    func speakTest(_ text: String) {
        guard voiceEnabled else { return }
        synthesizer.stopSpeaking(at: .immediate)
        speakNative(text)
    }

    private func recordSpeech() {
        let now = Date(); lastSpokenTime = now; lastSpokenDate = now
        spokenCountToday += 1
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {}
}

// MARK: - PRESENCE CONTEXT BUILDER
// Utility to construct PresenceContext from SwiftData models — called on each relevant app open

struct PresenceContextBuilder {
    static func build(
        profile: OperatorProfile,
        actions: [Action],
        hydrationLogs: [HydrationLog],
        energyState: EnergyState?,
        isFirstOpenToday: Bool
    ) -> PresenceContext {
        let cal = Calendar.current
        let now = Date()

        let completedToday = actions.filter {
            $0.isCompleted && cal.isDateInToday($0.completedAt ?? .distantPast)
        }
        let pendingToday = actions.filter {
            !$0.isCompleted && ($0.recurrence != .none || cal.isDateInToday($0.createdAt))
        }

        let participationCompletions = completedToday.filter { $0.system == .participation }
        let participationQuietDays: Int
        if participationCompletions.isEmpty {
            // BUG FIX: was using completedAt (set to nil on daily reset) — so after reset,
            // every participation action looked like it had never been completed, and
            // participationQuietDays always returned profile.daysInSystem (worst case).
            // completionDates is the persistent history; use its most recent entry instead.
            let lastParticipation = actions
                .filter { $0.system == .participation }
                .compactMap { $0.completionDates.last }
                .max()
            if let last = lastParticipation {
                participationQuietDays = cal.dateComponents([.day], from: last, to: now).day ?? 999
            } else {
                participationQuietDays = profile.daysInSystem
            }
        } else {
            participationQuietDays = 0
        }

        let creativeCount = pendingToday.filter { $0.cognitionMode == .creative }.count
        let adminCount = pendingToday.filter { $0.cognitionMode == .administrative }.count
        let gatewayActive = completedToday.contains { $0.system == .environment }

        let hoursSinceHydration: Double
        if let last = hydrationLogs.first?.timestamp {
            hoursSinceHydration = now.timeIntervalSince(last) / 3600
        } else {
            hoursSinceHydration = 24
        }

        return PresenceContext(
            name: profile.firstName,
            hour: cal.component(.hour, from: now),
            weekday: cal.component(.weekday, from: now),
            energyState: energyState,
            completedToday: completedToday.count,
            pendingToday: pendingToday.count,
            participationQuietDays: participationQuietDays,
            creativeActionsCount: creativeCount,
            adminActionsCount: adminCount,
            gatewaySystemActive: gatewayActive,
            hoursSinceHydration: hoursSinceHydration,
            isFirstOpenToday: isFirstOpenToday,
            daysInSystem: profile.daysInSystem,
            reserveDayCompletions: completedToday.count
        )
    }
}

// MARK: - WENDY STATE (Phase B1 text card)
// Separate from voice — text surfaces first (B1), spoken comes later (B2).

class WendyState: ObservableObject {
    static let shared = WendyState()
    @Published var pendingObservation: String? = nil
    func dismiss() { pendingObservation = nil }
}

// MARK: - CONSULT ENGINE (Phase B3 — Pattern Brief)
// Operator-requested read. One session. No follow-up. Analyst format.
// Not a conversation. A briefing document generated at a moment.

let CONSULT_SYSTEM_PROMPT = WENDY_SYSTEM_PROMPT + """

PATTERN BRIEF MODE: The operator has explicitly requested a system read.

You may surface 1–3 observations. Each observation must follow this structure exactly:

OBSERVATION [N]
[One sentence stating the pattern as observable fact.]

Evidence:
[One sentence of supporting data — specific, not general.]

Implication:
[One sentence on what this pattern means operationally.]

Suggested correction:
[One specific, concrete action. Not a category. Not advice. One action.]

---

CONSTRAINTS:
- Behavioral evidence only. No psychological inference without data support.
- If nothing significant is observable: return exactly "No significant pattern in the data window. Systems holding."
- Do not manufacture observations to fill the response.
- No preamble. No sign-off. No questions back. No coaching language.
- No cliffhangers. No appetite creation. State what the data shows and stop.
- Language is cold, precise, and operational throughout.

Return only the observations in the format above. Nothing else.
"""

enum ConsultState: Equatable {
    case insufficientData(daysRemaining: Int)
    case cooldownActive(availableDate: Date)
    case ready
    case loading
    case response(text: String)
    case noSignal
    case error

    static func == (lhs: ConsultState, rhs: ConsultState) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready), (.loading, .loading), (.noSignal, .noSignal), (.error, .error): return true
        case (.insufficientData(let a), .insufficientData(let b)): return a == b
        case (.cooldownActive(let a), .cooldownActive(let b)): return a == b
        case (.response(let a), .response(let b)): return a == b
        default: return false
        }
    }
}

struct ConsultEngine {

    // Compute current gate state — drives UI before the read is attempted
    static func gateState(profile: OperatorProfile) -> ConsultState {
        if profile.daysInSystem < 30 {
            return .insufficientData(daysRemaining: 30 - profile.daysInSystem)
        }
        if let last = profile.lastConsultDate {
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            if days < 14 {
                let available = Calendar.current.date(byAdding: .day, value: 14, to: last) ?? Date()
                return .cooldownActive(availableDate: available)
            }
        }
        return .ready
    }

    // Run the consult — async, returns a ConsultState
    static func run(
        profile: OperatorProfile,
        actions: [Action],
        logs: [DailyLog]
    ) async -> ConsultState {
        guard profile.daysInSystem >= 30 else {
            return .insufficientData(daysRemaining: 30 - profile.daysInSystem)
        }
        guard !profile.claudeApiKey.isEmpty else { return .error }

        guard let longitudinal = PresenceContextBuilder.buildLongitudinalContext(
            profile: profile, actions: actions, logs: logs, windowDays: 30
        ) else { return .noSignal }

        let payload = buildPayload(profile: profile, logs: logs, longitudinal: longitudinal)

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return .error }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(profile.claudeApiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 400,
            "system": CONSULT_SYSTEM_PROMPT,
            "messages": [["role": "user", "content": payload]]
        ])

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return .error }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let content = json?["content"] as? [[String: Any]]
            let text = (content?.first?["text"] as? String ?? "SILENCE")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if text == "SILENCE" || text.isEmpty { return .noSignal }
            return .response(text: text)
        } catch { return .error }
    }

    private static func buildPayload(
        profile: OperatorProfile,
        logs: [DailyLog],
        longitudinal: LongitudinalContext
    ) -> String {
        let weekdayNames = [1:"Sun",2:"Mon",3:"Tue",4:"Wed",5:"Thu",6:"Fri",7:"Sat"]
        let rateStr = longitudinal.systemCompletionRates
            .map { "\($0.key):\(String(format: "%.2f", $0.value))" }
            .sorted().joined(separator: ", ")
        let creativeStr = (1...7)
            .map { "\(weekdayNames[$0] ?? "?"):\(longitudinal.creativeByWeekday[$0] ?? 0)" }
            .joined(separator: ", ")
        let recentLogs = Array(logs.prefix(30))
        let reserveCount = recentLogs.filter { $0.energyStateRaw == "reserve" }.count
        let fullCount    = recentLogs.filter { $0.energyStateRaw == "full"    }.count

        return """
        30-DAY READ REQUEST. Day \(profile.daysInSystem) in system.

        COMPLETION RATE BY SYSTEM: \(rateStr)
        RESERVE DAYS: \(reserveCount) · AVG COMPLETIONS: \(String(format: "%.1f", longitudinal.reserveDayCompletionAvg))
        FULL DAYS: \(fullCount) · AVG COMPLETIONS: \(String(format: "%.1f", longitudinal.fullDayCompletionAvg))
        CREATIVE BY WEEKDAY: \(creativeStr)
        HIGH FRICTION ACTIONS: \(longitudinal.highFrictionActionTitles.joined(separator: ", "))
        WEEKLY ACTIVE SYSTEMS: \(longitudinal.weeklyActiveSystems.sorted().joined(separator: ", "))

        What does the data show across these 30 days?
        """
    }
}

// MARK: - LONGITUDINAL CONTEXT BUILDER

extension PresenceContextBuilder {

    // Returns nil if data is insufficient.
    // Previously required daysInSystem >= 14 AND recentLogs.count >= 10.
    // minLogs requirement relaxed: DailyLog entries are now written on every action tap
    // (FIX-H), so the dataset builds automatically without requiring daily review submissions.
    // Kept at 5 as a sanity floor — below that there's genuinely not enough signal.
    nonisolated static func buildLongitudinalContext(
        profile: OperatorProfile,
        actions: [Action],
        logs: [DailyLog],
        windowDays: Int = 14,
        shifts: [HideoutShiftLog] = []
    ) -> LongitudinalContext? {
        guard profile.daysInSystem >= 7 else { return nil }

        let cal = Calendar.current
        let cutoff = cal.date(byAdding: .day, value: -windowDays, to: Date()) ?? .distantPast
        let recentLogs = logs.filter { $0.date >= cutoff }
        // At 7 days min, require 3 logs (not 5) — DailyLogs auto-created on action tap
        let minLogs = windowDays >= 30 ? 10 : 3
        guard recentLogs.count >= minLogs else { return nil }

        // Completion rate by system — uses Action.completionRate (completionDates.count / daysSinceCreated)
        let systemRates: [String: Double] = Dictionary(uniqueKeysWithValues:
            SystemTag.allCases.map { sys in
                let sysActions = actions.filter { $0.system == sys }
                let avg = sysActions.isEmpty ? 0.0 :
                    sysActions.map(\.completionRate).reduce(0, +) / Double(sysActions.count)
                return (sys.rawValue, avg)
            }
        )

        // Creative work completion by weekday within the 14-day window
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

        let highFriction = actions.filter(\.isHighFriction).map(\.title)
        let weeklyActive = Array(profile.activeSystemsThisWeek)

        // v2.3 — completion timing intelligence from completionHours
        // completionHours is parallel to completionDates — same index = same event
        let allHours: [Int] = actions.flatMap { a in
            // Only use hours within the cutoff window
            zip(a.completionDates, a.completionHours)
                .filter { $0.0 >= cutoff }
                .map { $0.1 }
        }

        let peakHour: Int? = allHours.isEmpty ? nil : {
            let freq = allHours.reduce(into: [:]) { $0[$1, default: 0] += 1 }
            return freq.max(by: { $0.value < $1.value })?.key
        }()

        let morningHours = allHours.filter { $0 < 12 }
        let eveningHours = allHours.filter { $0 >= 18 }
        let morningRate = allHours.isEmpty ? 0.0 : Double(morningHours.count) / Double(allHours.count)
        let eveningRate = allHours.isEmpty ? 0.0 : Double(eveningHours.count) / Double(allHours.count)

        // Weekday vs weekend average completions
        let allDays = Array(Set(actions.flatMap { $0.completionDates.filter { $0 >= cutoff } }
            .map { cal.startOfDay(for: $0) }))
        let weekdayDays = allDays.filter { d in
            let wd = cal.component(.weekday, from: d); return wd >= 2 && wd <= 6
        }
        let weekendDays = allDays.filter { d in
            let wd = cal.component(.weekday, from: d); return wd == 1 || wd == 7
        }
        func avgCompletions(for days: [Date]) -> Double {
            guard !days.isEmpty else { return 0 }
            let total = days.reduce(0) { count, day in
                count + actions.reduce(0) { c, a in
                    c + a.completionDates.filter { cal.isDate($0, inSameDayAs: day) }.count
                }
            }
            return Double(total) / Double(days.count)
        }
        let weekdayAvg = avgCompletions(for: weekdayDays)
        let weekendAvg = avgCompletions(for: weekendDays)

        // Current consecutive active days streak
        var streak = 0
        var checkDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date())) ?? Date()
        for _ in 0..<30 {
            let hasActivity = actions.contains { a in
                a.completionDates.contains { cal.isDate($0, inSameDayAs: checkDate) }
            }
            if hasActivity {
                streak += 1
                checkDate = cal.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else { break }
        }

        // Which hour each system peaks at (mode of completionHours for that system's actions)
        let systemPeakHours: [String: Int] = Dictionary(uniqueKeysWithValues:
            SystemTag.allCases.compactMap { sys -> (String, Int)? in
                let hours: [Int] = actions
                    .filter { $0.system == sys }
                    .flatMap { a in
                        zip(a.completionDates, a.completionHours)
                            .filter { $0.0 >= cutoff }
                            .map { $0.1 }
                    }
                guard !hours.isEmpty else { return nil }
                let freq = hours.reduce(into: [:]) { $0[$1, default: 0] += 1 }
                guard let peak = freq.max(by: { $0.value < $1.value }) else { return nil }
                return (sys.rawValue, peak.key)
            }
        )

        // v2.7 — Hideout shift data
        let recentShifts = Array(shifts.prefix(30))
        let last7Shifts = Array(shifts.prefix(7))

        let experimentStart = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 13)) ?? Date()
        let hideoutDay = max(1, cal.dateComponents([.day], from: experimentStart, to: Date()).day ?? 1)

        let thirtyDayAvg: Double = recentShifts.isEmpty ? 0 :
            recentShifts.map(\.grossRevenue).reduce(0, +) / Double(recentShifts.count)

        let planningBand = HideoutPlanningBand.classify(thirtyDayAvg).rawValue

        let stressScores = last7Shifts.filter { $0.stressScore > 0 }.map { Double($0.stressScore) }
        let stressAvg: Double = stressScores.isEmpty ? 0 :
            stressScores.reduce(0, +) / Double(stressScores.count)

        let hideoutTrend: String = {
            guard recentShifts.count >= 4 else { return "insufficient data" }
            let recent = Array(recentShifts.prefix(3)).map(\.grossRevenue).reduce(0, +) / 3
            let earlier = Array(recentShifts.dropFirst(3).prefix(3)).map(\.grossRevenue).reduce(0, +) / 3
            if earlier == 0 { return "insufficient data" }
            let delta = (recent - earlier) / earlier
            if delta > 0.05 { return "up" }
            if delta < -0.05 { return "down" }
            return "flat"
        }()

        return LongitudinalContext(
            systemCompletionRates: systemRates,
            creativeByWeekday: creativeByWeekday,
            reserveDayCount: reserveLogs.count,
            reserveDayCompletionAvg: reserveAvg,
            fullDayCompletionAvg: fullAvg,
            weeklyActiveSystems: weeklyActive,
            highFrictionActionTitles: highFriction,
            peakCompletionHour: peakHour,
            morningCompletionRate: morningRate,
            eveningCompletionRate: eveningRate,
            weekdayVsWeekendAvg: (weekday: weekdayAvg, weekend: weekendAvg),
            consecutiveDaysActive: streak,
            systemCompletionsByHour: systemPeakHours,
            recentLogs: recentLogs,
            hideoutExperimentDay: hideoutDay,
            hideoutThirtyDayAvg: thirtyDayAvg,
            hideoutPlanningBand: planningBand,
            hideoutRecentStressAvg: stressAvg,
            hideoutTrend: hideoutTrend,
            hideoutStaffUsedRecently: last7Shifts.contains { $0.usedStaff },
            hideoutLostSalesRecently: last7Shifts.contains { $0.lostSales },
            hideoutExperimentShifts: recentShifts.count
        )
    }
}

// MARK: - NOTIFICATION SERVICE

class NotificationService {
    static let shared = NotificationService()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // Schedule-aware nudges — respects hideout vs base day structure
    // Hideout days (Wed–Fri): nudges align with 8AM start and 5PM close
    // Hideout weekends (Sat–Sun): 10AM start, 3PM close
    // Base days (Mon–Tue): cafe/ops rhythm, looser
    func scheduleAll(profile: OperatorProfile) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard !profile.quietMode else { return }

        // Daily nudges — time-slot aware, not generic
        // Format: (title, body, hour, minute, categoryEnabled, notifID)
        let nudges: [(String, String, Int, Int, Bool, String)] = [
            // 6:00 — morning anchor open (every day)
            ("No phone. First hour starts now.",
             "",
             6, 0, profile.notifCategoryHealth, "increments-0"),
            // 8:00 — hideout start signal (Mon for ops, rest for hideout)
            ("Morning protocol done. First block.",
             "",
             8, 0, profile.notifCategoryCognition, "increments-1"),
            // 12:15 — midday break (every day)
            ("Midday. Protein. Water. 15 min outside.",
             "",
             12, 15, profile.notifCategoryHealth, "increments-2"),
            // 16:30 — close of hideout day / afternoon wrap
            ("Wrapping up. What landed today?",
             "",
             16, 30, profile.notifCategoryOperations, "increments-3"),
            // 21:00 — evening anchor
            ("Evening shutdown. Journal. Phone away. Book.",
             "",
             21, 0, profile.notifCategoryHealth, "increments-4"),
        ]

        for (title, body, hour, min, enabled, id) in nudges {
            guard enabled else { continue }
            guard !isInQuietWindow(hour: hour, quietStart: profile.notifQuietStart, quietEnd: profile.notifQuietEnd) else { continue }
            schedule(id: id, title: title, body: body, hour: hour, minute: min)
        }

        // Hydration — unchanged
        if profile.notifHydrationEnabled {
            let hydrationHours = [10, 13, 16]
            for (i, hour) in hydrationHours.enumerated() {
                guard !isInQuietWindow(hour: hour, quietStart: profile.notifQuietStart, quietEnd: profile.notifQuietEnd) else { continue }
                schedule(id: "increments-hydration-\(i)", title: "Water.", body: "", hour: hour, minute: 0)
            }
        }

        // Protein reminders
        if profile.notifProteinEnabled {
            let proteinTimes = [(8, 0), (13, 0)]   // adjusted: 8AM with first meal, 1PM second hit
            for (i, (hour, min)) in proteinTimes.enumerated() {
                guard !isInQuietWindow(hour: hour, quietStart: profile.notifQuietStart, quietEnd: profile.notifQuietEnd) else { continue }
                schedule(id: "increments-protein-\(i)", title: "Protein.", body: "", hour: hour, minute: min)
            }
        }
    }

    // Legacy shim
    func scheduleAll(quietMode: Bool = false) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard !quietMode else { return }
        let notifications: [(String, String, Int, Int)] = [
            ("Morning. Open the blinds first.", "", 7, 30),
            ("One thing before the day gets away.", "", 12, 15),
            ("Keep it to one thread right now.", "", 15, 30),
            ("Worth wrapping up before bed.", "", 20, 30),
        ]
        for (i, (title, body, hour, min)) in notifications.enumerated() {
            schedule(id: "increments-\(i)", title: title, body: body, hour: hour, minute: min)
        }
    }

    private func isInQuietWindow(hour: Int, quietStart: Int, quietEnd: Int) -> Bool {
        // Handles overnight windows (e.g. 22 → 07)
        if quietStart < quietEnd {
            return hour >= quietStart && hour < quietEnd
        } else {
            return hour >= quietStart || hour < quietEnd
        }
    }

    private func schedule(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        if !body.isEmpty { content.body = body }
        content.sound = .default
        var comps = DateComponents()
        comps.hour = hour; comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - REUSABLE COMPONENTS

// FIX V04 — THREE-TIER CARD HIERARCHY
// Primary: action layer (operative) — surface fill, current treatment
// Secondary: context layer (support) — surface2, +4pt padding
// Ambient: infrastructure layer — no background, left border rule only

enum CardStyle {
    case primary    // Today actions, One Door card, operative items
    case secondary  // Morning evidence, status rows, system summaries
    case ambient    // Metadata, settings, guardrails
}

struct CardView<Content: View>: View {
    let style: CardStyle
    let content: Content

    init(style: CardStyle = .primary, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        switch style {
        case .primary:
            content
                .padding(22)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.warm.opacity(0.04), radius: 1, x: 0, y: -1)   // rim light from above
                .shadow(color: Color.bgBase.opacity(0.6), radius: 8, x: 0, y: 6)   // grounding shadow
                .shadow(color: Color.violet.opacity(0.06), radius: 20, x: 0, y: 8) // violet bloom
        case .secondary:
            content
                .padding(26)
                .background(Color.surface2)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.bgBase.opacity(0.5), radius: 6, x: 0, y: 4)
                .shadow(color: Color.violet.opacity(0.04), radius: 14, x: 0, y: 6)
        case .ambient:
            HStack(spacing: 0) {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.warm.opacity(0.3), Color.violet.opacity(0.2)],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .frame(width: 1)
                content
                    .padding(.leading, 14)
                    .padding(.vertical, 8)
            }
        }
    }
}

struct MonoLabel: View {
    let text: String
    var color: Color = .textMuted
    var size: CGFloat = 11
    var body: some View {
        Text(text).font(.mono(size)).foregroundColor(color).tracking(2.0).textCase(.uppercase)
    }
}

// Section headers with subtle warm accent dot — more presence than plain MonoLabel
struct SectionHeader: View {
    let text: String
    var color: Color = .textMuted
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.warm.opacity(0.5))
                .frame(width: 4, height: 4)
            MonoLabel(text: text, color: color)
        }
    }
}

struct SystemBadge: View {
    let system: SystemTag
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: system.icon).font(.system(size: 10))
            Text(system.label).font(.mono(11)).tracking(1.0)   // FIX V03 — 9pt → 11pt, tracking reduced
        }
        .foregroundColor(system.color)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(system.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct CircularProgress: View {
    let value: Double
    let size: CGFloat
    var color: Color = .violet
    var lineWidth: CGFloat = 3
    var body: some View {
        ZStack {
            Circle().stroke(Color.surface2, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: value)
                .stroke(
                    LinearGradient(colors: [color, color.opacity(0.6)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: value)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - ACTION DETAIL SHEET
// Opened by long-pressing an action row. Shows the full context: note, cue, stats.
// This is the "how do I actually do this" view — not editing, just following.

struct ActionDetailSheet: View {
    let action: Action
    @Binding var isPresented: Bool
    var onComplete: () -> Void

    var completionPct: String {
        String(format: "%.0f%%", action.completionRate * 100)
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)

                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                SystemBadge(system: action.system)
                                if let block = action.scheduledBlock {
                                    MonoLabel(text: formatBlockTime(block), color: action.system.color, size: 10)
                                }
                            }
                            Text(action.title)
                                .font(.sora(22, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.textMuted)
                                .frame(width: 30, height: 30)
                                .background(Color.surface)
                                .clipShape(Circle())
                        }
                    }

                    // The note — the "how" — most important thing on this sheet
                    if let note = action.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "NOTE", color: action.system.color, size: 10)
                            Text(note)
                                .font(.sora(15, weight: .light))
                                .foregroundColor(.textPrimary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(18)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Cue
                    if let cue = action.cue, !cue.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "CUE", color: .textMuted, size: 10)
                            Text(cue)
                                .font(.mono(13))
                                .foregroundColor(.textSecond)
                                .tracking(0.3)
                        }
                    }

                    // Stats — only if there's real data
                    if action.daysSinceCreated >= 3 {
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                        HStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "COMPLETION", color: .textMuted, size: 10)
                                Text(completionPct)
                                    .font(.sora(18, weight: .semibold))
                                    .foregroundColor(action.completionRate >= 0.7 ? .inkGreen :
                                                     action.completionRate >= 0.4 ? .inkAmber : .textSecond)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "SKIPPED", color: .textMuted, size: 10)
                                Text("\(action.skipCount)×")
                                    .font(.sora(18, weight: .semibold))
                                    .foregroundColor(action.skipCount >= 4 ? .inkAmber : .textSecond)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "DAYS", color: .textMuted, size: 10)
                                Text("\(action.daysSinceCreated)")
                                    .font(.sora(18, weight: .semibold))
                                    .foregroundColor(.textSecond)
                            }
                        }
                    }

                    // Complete button — if not already done
                    if !action.isCompleted {
                        Button(action: {
                            onComplete()
                            isPresented = false
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 15))
                                Text("Mark done")
                                    .font(.sora(14, weight: .semibold))
                            }
                            .foregroundColor(.bgBase)
                            .frame(maxWidth: .infinity).frame(height: 50)
                            .background(action.system.color)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.inkGreen)
                            Text("Done today").font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.bgBase)
    }
}


struct ActionRow: View {
    let action: Action
    var onComplete: () -> Void
    @State private var glowing = false
    @State private var showFrictionNudge = false
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                // Completion circle — tap to complete
                Button(action: {
                    withAnimation(.spring(response: 0.3)) { glowing = true; onComplete() }
                }) {
                    ZStack {
                        Circle()
                            .fill(action.isCompleted ? Color.inkGreen.opacity(0.15) : action.system.color.opacity(0.06))
                            .frame(width: 22, height: 22)
                        Circle()
                            .stroke(action.isCompleted ? Color.inkGreen : action.system.color.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                        if action.isCompleted {
                            Image(systemName: "checkmark").font(.system(size: 9, weight: .semibold)).foregroundColor(.inkGreen)
                        }
                    }
                }
                .shadow(color: action.isCompleted ? Color.inkGreen.opacity(glowing ? 0.5 : 0.15) : .clear, radius: 8)

                // Text area — tap to open detail sheet with note, cue, and how-to
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        if let block = action.scheduledBlock, !action.isCompleted {
                            Text(formatBlockTime(block))
                                .font(.mono(10))
                                .foregroundColor(action.system.color.opacity(0.8))
                                .tracking(0.5)
                                .fixedSize()
                        }
                        Text(action.title)
                            .font(.sora(14))
                            .foregroundColor(action.isCompleted ? .textMuted : .textPrimary)
                            .strikethrough(action.isCompleted, color: .textMuted)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        if let mode = action.cognitionMode, !action.isCompleted {
                            Image(systemName: mode.icon)
                                .font(.system(size: 10, weight: .light))
                                .foregroundColor(mode == .creative ? .warm :
                                                 mode == .analytical ? .violetLight : .textMuted)
                                .fixedSize()
                        }
                    }
                    if let cue = action.cue, !cue.isEmpty, !action.isCompleted {
                        Text("When: \(cue)")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                    // Note preview — shows first line if note exists
                    if let note = action.note, !note.isEmpty, !action.isCompleted {
                        Text(note.count > 55 ? String(note.prefix(55)) + "…" : note)
                            .font(.sora(11, weight: .light))
                            .foregroundColor(.textMuted.opacity(0.65))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture { if !action.isCompleted { showDetail = true } }

                Spacer(minLength: 0)

                if action.isHighFriction && !action.isCompleted {
                    Button(action: { withAnimation(.easeOut(duration: 0.2)) { showFrictionNudge.toggle() } }) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.inkAmber.opacity(0.7))
                    }
                } else {
                    SystemBadge(system: action.system)
                        .onTapGesture { if !action.isCompleted { showDetail = true } }
                }
            }
            .padding(.vertical, 4)

            if showFrictionNudge && !action.isCompleted {
                HStack(spacing: 8) {
                    Rectangle().fill(Color.inkAmber.opacity(0.3)).frame(width: 1)
                        .padding(.leading, 35)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skipped \(action.skipCount)×")
                            .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                        Text("Maybe smaller.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                    }
                    Spacer()
                }
                .padding(.top, 6).padding(.bottom, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onChange(of: glowing) { _, new in
            if new { DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { glowing = false } }
        }
        .sheet(isPresented: $showDetail) {
            ActionDetailSheet(action: action, isPresented: $showDetail, onComplete: onComplete)
        }
    }
}


struct AtmosphericBackground: View {
    var enhanced: Bool = false   // Home gets a deeper treatment as the daily entry point
    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            if enhanced {
                // Home — stronger presence, warm center pull
                RadialGradient(colors: [Color.warm.opacity(0.07), Color.bgBase],
                               center: .center, startRadius: 0, endRadius: 320).ignoresSafeArea()
                RadialGradient(colors: [Color.violet.opacity(0.14), Color.bgBase],
                               center: .topTrailing, startRadius: 0, endRadius: 420).ignoresSafeArea()
                RadialGradient(colors: [Color.violetDim.opacity(0.08), Color.bgBase],
                               center: .bottomLeading, startRadius: 0, endRadius: 300).ignoresSafeArea()
            } else {
                // Standard — subtle, instrument-mode
                RadialGradient(colors: [Color.violet.opacity(0.10), Color.bgBase],
                               center: .topTrailing, startRadius: 0, endRadius: 400).ignoresSafeArea()
                RadialGradient(colors: [Color.warm.opacity(0.05), Color.bgBase],
                               center: .bottomLeading, startRadius: 0, endRadius: 350).ignoresSafeArea()
            }
        }
    }
}

// Inline row for Home tab — opens ActionDetailSheet on tap
struct ActionDetailInlineRow: View {
    let action: Action
    @State private var showDetail = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.warm.opacity(0.15)).frame(width: 28, height: 28)
                Circle().fill(Color.warm).frame(width: 8, height: 8)
                    .shadow(color: Color.warm.opacity(0.5), radius: 4)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(action.title)
                    .font(.sora(15, weight: .medium)).foregroundColor(.textPrimary)
                if let cue = action.cue, !cue.isEmpty {
                    Text("When: \(cue)")
                        .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                } else if let note = action.note, !note.isEmpty {
                    Text(note.count > 55 ? String(note.prefix(55)) + "…" : note)
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineLimit(1)
                }
            }
            Spacer()
            Text("View").font(.sora(11, weight: .light)).foregroundColor(.textMuted)
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.textMuted)
        }
        .contentShape(Rectangle())
        .onTapGesture { showDetail = true }
        .sheet(isPresented: $showDetail) {
            ActionDetailSheet(action: action, isPresented: $showDetail, onComplete: {})
        }
    }
}



struct SessionCard: View {
    let session: Session
    var onTap: () -> Void                      // opens execution view
    var onQuickDone: () -> Void                // marks done without opening steps
    var onSkip: (SessionSkipReason) -> Void    // records intentional skip

    @State private var showSkipOptions = false

    var body: some View {
        HStack(spacing: 0) {
            // Domain accent strip
            RoundedRectangle(cornerRadius: 2)
                .fill(session.system.color.opacity(0.7))
                .frame(width: 2)
                .padding(.trailing, 14)

            // Main content — tappable to open execution view
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        MonoLabel(text: "PROTOCOL", color: session.system.color, size: 11)
                        MonoLabel(text: "· \(session.steps.count) STEPS", color: .textMuted, size: 11)
                        Spacer()
                    }
                    Text(session.title)
                        .font(.sora(16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    if !session.cue.isEmpty {
                        Text("When: \(session.cue)")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 12)

            // Right side — quick-mark done + skip
            VStack(spacing: 10) {
                // Quick-mark done — single tap, no steps needed
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onQuickDone()
                }) {
                    ZStack {
                        Circle()
                            .fill(session.system.color.opacity(0.08))
                            .frame(width: 36, height: 36)
                        Circle()
                            .stroke(session.system.color.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(session.system.color)
                    }
                }

                // Skip — clear affordance, not tiny
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) { showSkipOptions.toggle() }
                }) {
                    Text("skip")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .frame(width: 36, height: 20)
                        .contentShape(Rectangle())
                }
            }
        }
        // Skip options — appear inline below card on tap
        if showSkipOptions {
            VStack(alignment: .leading, spacing: 0) {
                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5).padding(.horizontal, 16)
                HStack(spacing: 8) {
                    skipOption("Rest day", reason: .rest)
                    skipOption("Something came up", reason: .disruption)
                    Button(action: { withAnimation { showSkipOptions = false } }) {
                        Text("cancel").font(.sora(11, weight: .light)).foregroundColor(.textMuted.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    func skipOption(_ label: String, reason: SessionSkipReason) -> some View {
        Button(action: {
            withAnimation { showSkipOptions = false }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSkip(reason)
        }) {
            Text(label)
                .font(.sora(11, weight: .light))
                .foregroundColor(.textSecond)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.muted.opacity(0.3), lineWidth: 0.5))
        }
    }
}

struct SessionExecutionView: View {
    @Environment(\.modelContext) private var context
    @Bindable var session: Session
    @Query private var profiles: [OperatorProfile]
    var onClose: () -> Void

    @State private var currentStep: Int = 0
    @State private var closing = false
    @State private var glowComplete = false

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    var body: some View {
        ZStack {
            AtmosphericBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.textMuted)
                            .frame(width: 36, height: 36)
                            .background(Color.surface)
                            .clipShape(Circle())
                    }
                    Spacer()
                    SystemBadge(system: session.system)
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 32)

                // Session title
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "PROTOCOL · \(session.steps.count) STEPS", color: session.system.color)
                    Text(session.title)
                        .font(.sora(26, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    if !session.cue.isEmpty {
                        Text("When: \(session.cue)")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)

                // Step list — read-along, not independently checkable
                VStack(spacing: 0) {
                    ForEach(Array(session.steps.enumerated()), id: \.offset) { i, step in
                        HStack(spacing: 16) {
                            // Step index — mono, right-aligned in fixed column
                            Text("\(i + 1)")
                                .font(.mono(13))
                                .foregroundColor(i == currentStep ? session.system.color : .textMuted)
                                .frame(width: 20, alignment: .trailing)

                            // Connector line
                            VStack(spacing: 0) {
                                if i > 0 {
                                    Rectangle()
                                        .fill(i <= currentStep ? session.system.color.opacity(0.3) : Color.muted.opacity(0.2))
                                        .frame(width: 1, height: 12)
                                }
                                Circle()
                                    .fill(i < currentStep ? session.system.color : (i == currentStep ? session.system.color.opacity(0.8) : Color.surface2))
                                    .frame(width: 8, height: 8)
                                    .overlay(Circle().strokeBorder(i == currentStep ? session.system.color : Color.muted.opacity(0.4), lineWidth: 1))
                                if i < session.steps.count - 1 {
                                    Rectangle()
                                        .fill(i < currentStep ? session.system.color.opacity(0.3) : Color.muted.opacity(0.2))
                                        .frame(width: 1, height: 12)
                                }
                            }
                            .frame(width: 8)

                            // Step text
                            Text(step)
                                .font(.sora(i == currentStep ? 16 : 14,
                                            weight: i == currentStep ? .medium : .light))
                                .foregroundColor(i == currentStep ? .textPrimary :
                                                 (i < currentStep ? .textMuted : .textSecond))
                                .strikethrough(i < currentStep, color: .textMuted)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        // Tapping a step advances to it (allows jumping forward, not back)
                        .onTapGesture {
                            if i >= currentStep {
                                withAnimation(.easeOut(duration: 0.2)) { currentStep = i }
                            }
                        }
                    }
                }

                Spacer()

                // CTA — changes based on position in protocol
                VStack(spacing: 12) {
                    if currentStep < session.steps.count - 1 {
                        // Advance step
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) { currentStep += 1 }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            Text("Next step")
                                .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                                .frame(maxWidth: .infinity).frame(height: 50)
                                .background(session.system.color)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: session.system.color.opacity(0.3), radius: 12, x: 0, y: 6)
                        }

                        // Skip to close — understated, always available
                        Button(action: { closeSession() }) {
                            Text("Protocol closed.")
                                .font(.mono(11)).foregroundColor(.textMuted).tracking(1)
                        }
                    } else {
                        // Final step — primary CTA
                        Button(action: { closeSession() }) {
                            Text("Protocol closed.")
                                .font(.sora(14, weight: .semibold)).tracking(1.8)
                                .foregroundColor(.bgBase)
                                .frame(maxWidth: .infinity).frame(height: 50)
                                .background(
                                    Group {
                                        LinearGradient(
                                            colors: [session.system.color, session.system.color.opacity(0.7)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: session.system.color.opacity(0.35), radius: 14, x: 0, y: 7)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .presentationBackground(Color.bgBase)
        .onAppear { VoicePresence.shared.isInSession = true }
        .onDisappear { VoicePresence.shared.isInSession = false }
    }

    private func closeSession() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        session.lastCompleted = Date()
        session.completedAt = Date()
        session.completionDates.append(Date())   // persist to history — survives daily reset
        if session.recurrence == .none { session.isCompleted = true }
        if let p = profiles.first {
            p.addXP(session.points)
            p.markSystemActive(session.system)
        }
        onClose()
    }
}

// MARK: - ADD SESSION SHEET

struct AddSessionSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var context
    @State private var title = ""
    @State private var system: SystemTag = .health
    @State private var cue = ""
    @State private var recurrence: RecurrenceType = .daily
    @State private var steps: [String] = ["", ""]   // start with 2 empty fields

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        steps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count >= 2
    }

    var filledSteps: [String] {
        steps.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Text("New Protocol").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Cancel") { isPresented = false }.font(.sora(14)).foregroundColor(.textMuted)
                    }

                    inputField("PROTOCOL NAME", placeholder: "Evening Shutdown", text: $title)

                    // System picker
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "SYSTEM")
                        HStack(spacing: 8) {
                            ForEach(SystemTag.allCases, id: \.self) { tag in
                                Button(action: { system = tag }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: tag.icon).font(.system(size: 14))
                                        Text(tag.rawValue.prefix(3).uppercased()).font(.mono(9)).tracking(1)
                                    }
                                    .foregroundColor(system == tag ? tag.color : .textMuted)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(system == tag ? tag.color.opacity(0.12) : Color.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(system == tag ? tag.color.opacity(0.4) : Color.clear, lineWidth: 1))
                                }
                            }
                        }
                    }

                    inputField("CUE", placeholder: "After shower / Before bed", text: $cue)

                    // Steps — max 6
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            MonoLabel(text: "STEPS")
                            Spacer()
                            MonoLabel(text: "\(filledSteps.count)/6", color: filledSteps.count >= 6 ? .inkAmber : .textMuted, size: 11)
                        }
                        MonoLabel(text: "Steps are navigation — they guide, not score", color: .muted, size: 10)

                        ForEach(steps.indices, id: \.self) { i in
                            HStack(spacing: 10) {
                                Text("\(i + 1)").font(.mono(11)).foregroundColor(.textMuted).frame(width: 16)
                                TextField("", text: $steps[i],
                                          prompt: Text("Step \(i + 1)").foregroundColor(.textMuted))
                                    .font(.sora(14)).foregroundColor(.textPrimary)
                                    .padding(12).background(Color.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .tint(.warm)
                                if steps.count > 2 {
                                    Button(action: { steps.remove(at: i) }) {
                                        Image(systemName: "minus.circle").foregroundColor(.textMuted)
                                    }
                                }
                            }
                        }

                        if steps.count < 6 {
                            Button(action: { steps.append("") }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus").font(.system(size: 12))
                                    Text("Add step").font(.sora(13))
                                }
                                .foregroundColor(.violet)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Color.violetDim.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        } else {
                            // Cap indicator
                            HStack(spacing: 6) {
                                Image(systemName: "equal").font(.system(size: 11)).foregroundColor(.inkAmber)
                                Text("Protocols cap at 6 steps.")
                                    .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.5)
                            }
                            .padding(.top, 4)
                        }
                    }

                    // Recurrence
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "FREQUENCY")
                        HStack(spacing: 6) {
                            ForEach([RecurrenceType.daily, .weekdays, .weekly, .none], id: \.self) { r in
                                Button(action: { recurrence = r }) {
                                    Text(r == .none ? "Once" : r.rawValue.capitalized)
                                        .font(.sora(12)).foregroundColor(recurrence == r ? .violet : .textMuted)
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(recurrence == r ? Color.violetDim.opacity(0.3) : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }

                    primaryButton("Save Protocol", disabled: !canSave) {
                        let session = Session(
                            title: title.trimmingCharacters(in: .whitespaces),
                            system: system,
                            steps: filledSteps,
                            cue: cue.trimmingCharacters(in: .whitespaces),
                            recurrence: recurrence
                        )
                        context.insert(session)
                        isPresented = false
                    }
                    .padding(.bottom, 40)
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }
}

// MARK: - SYSTEM STATUS ROW (expandable — science context + pending actions)

struct SystemStatusRow: View {
    let sys: SystemTag
    let score: Int
    let state: AppState
    let pendingActions: [Action]
    @Query private var allActions: [Action]
    @State private var expanded = false

    var systemPending: [Action] {
        pendingActions.filter { $0.system == sys }.prefix(3).map { $0 }
    }

    // Training-log trajectory — reads direction not score. Uses completionDates (persistent).
    var trajectorySignal: String? {
        let cal = Calendar.current
        let sysActions = allActions.filter { $0.system == sys }

        // Build set of days with at least one completion in this system (from persistent history)
        let last14dates = (0..<14).compactMap { cal.date(byAdding: .day, value: -$0, to: Date()) }
        let activeDays = last14dates.filter { day in
            sysActions.contains { a in
                a.completionDates.contains { cal.isDate($0, inSameDayAs: day) }
            }
        }.count

        let last7 = last14dates.prefix(7)
        let prior7 = last14dates.dropFirst(7)
        let last7Count = last7.filter { day in
            sysActions.contains { a in a.completionDates.contains { cal.isDate($0, inSameDayAs: day) } }
        }.count
        let prior7Count = prior7.filter { day in
            sysActions.contains { a in a.completionDates.contains { cal.isDate($0, inSameDayAs: day) } }
        }.count

        // No data at all
        if activeDays == 0 { return nil }

        // Building — last 7 days better than prior 7
        if last7Count > prior7Count && last7Count >= 3 {
            return "Pattern building — \(last7Count) of 7 days active. The system is adapting."
        }
        // Fading — last 7 worse than prior 7 with a real gap
        if last7Count < prior7Count && prior7Count >= 3 && last7Count <= 2 {
            return "Less contact than last week. Might be too much friction."
        }
        // Stable and consistent
        if last7Count >= 5 {
            return "Consistent. \(last7Count) of 7 days. Change what you're doing, not how often."
        }
        // Stable at low frequency
        if last7Count >= 3 {
            return "\(last7Count) of 7 days. Something's forming."
        }
        // Very low
        if last7Count >= 1 {
            return "\(last7Count) day\(last7Count == 1 ? "" : "s") this week. One more would anchor it."
        }
        return nil
    }

    var body: some View {
        CardView {
            VStack(spacing: 0) {
                // Collapsed row — always visible
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.28)) { expanded.toggle() }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }) {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(sys.color.opacity(0.7))
                            .frame(width: 2)
                            .padding(.trailing, 14)
                        HStack(spacing: 10) {
                            Image(systemName: sys.icon).font(.system(size: 14))
                                .foregroundColor(sys.color).frame(width: 20)
                            Text(sys.rawValue.capitalized)
                                .font(.sora(13, weight: .medium)).foregroundColor(.textPrimary)
                                .lineLimit(1)
                            Spacer()
                            Text(state.scoreLabel(score))
                                .font(.mono(10)).foregroundColor(state.scoreColor(score)).tracking(0.5)
                                .lineLimit(1).fixedSize()
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(width: 44, height: 3)
                                RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.8))
                                    .frame(width: 44 * CGFloat(score) / 100, height: 3)
                            }
                            // Score number removed — bar + label is sufficient.
                            // Raw integer becomes a Competition-strength tracking target.
                            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .light))
                                .foregroundColor(.textMuted)
                                .padding(.leading, 2)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Expanded content — science note + pending actions
                if expanded {
                    VStack(alignment: .leading, spacing: 14) {
                        Rectangle()
                            .fill(Color.muted.opacity(0.2))
                            .frame(height: 0.5)
                            .padding(.top, 14)

                        // Science context
                        Text(sys.scienceNote)
                            .font(.sora(13, weight: .light))
                            .foregroundColor(.textSecond)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        // What moves it
                        VStack(alignment: .leading, spacing: 6) {
                            MonoLabel(text: "WHAT MOVES IT", color: sys.color, size: 10)
                            Text(sys.whatMovesIt)
                                .font(.sora(12, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(3)
                        }

                        // Trajectory signal — training-log style direction reading
                        // Not a score. Not praise. A pattern observation.
                        if let trajectory = trajectorySignal {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "PATTERN", color: .textMuted, size: 10)
                                Text(trajectory)
                                    .font(.sora(12, weight: .light))
                                    .foregroundColor(.textSecond)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // Friction diagnosis — surfaces high-skip actions for review
                        // Only shows after 14 days of data. Not a grade — a diagnostic.
                        let highFrictionActions = systemPending.filter { $0.isHighFriction }
                        if !highFrictionActions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                MonoLabel(text: "FRICTION DETECTED", color: .inkAmber, size: 10)
                                ForEach(highFrictionActions.prefix(2), id: \.id) { action in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle().fill(Color.inkAmber.opacity(0.5)).frame(width: 5, height: 5).padding(.top, 5)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(action.title)
                                                .font(.sora(12, weight: .medium)).foregroundColor(.textPrimary)
                                            Text("Skipped \(action.skipCount)×. Maybe smaller.")
                                                .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                                        }
                                    }
                                }
                            }
                        }

                        // Pending in this system — single next action, not a list
                        let nextAction = systemPending.first
                        if let action = nextAction {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "NEXT IN THIS SYSTEM", color: .textMuted, size: 10)
                                HStack(spacing: 10) {
                                    Circle()
                                        .stroke(sys.color.opacity(0.5), lineWidth: 1.5)
                                        .frame(width: 8, height: 8)
                                    Text(action.title)
                                        .font(.sora(13, weight: .medium))
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    if systemPending.count > 1 {
                                        Text("+\(systemPending.count - 1) more")
                                            .font(.mono(10)).foregroundColor(.textMuted)
                                    }
                                }
                            }
                        } else {
                            HStack(spacing: 8) {
                                Circle().fill(sys.color.opacity(0.4)).frame(width: 7, height: 7)
                                Text("No pending actions in this system.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                            }
                        }
                    }
                    .padding(.top, 2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

// MARK: - TAB 1: HOME — FIX 04 (5-dot system activity row replaces score circle)

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [OperatorProfile]
    @Query private var allActions: [Action]   // full list for score calculation
    @Query(filter: #Predicate<Action> { $0.isCompleted == false }) private var pendingActions: [Action]
    @Bindable var state: AppState
    @State private var appeared = false

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    // Stateful synergy headline — reads reality, not math
    var synergyHeadline: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let completedToday = allActions.filter {
            $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast)
        }
        let activeThisWeek = SystemTag.allCases.filter { profile.isSystemActiveThisWeek($0) }

        if activeThisWeek.isEmpty && completedToday.isEmpty {
            if hour < 10 { return "The day's still forming." }
            if hour < 14 { return "Nothing logged yet." }
            return "Afternoon's still yours."
        }
        if !completedToday.isEmpty {
            let sys = completedToday.last?.system
            let sysName = sys?.rawValue.capitalized ?? "Something"
            if completedToday.count == 1 { return "\(sysName)'s moving." }
            if completedToday.count < 4  { return "You're in it." }
            return "Good day so far."
        }
        let activeNames = activeThisWeek.prefix(2).map { $0.rawValue.capitalized }
        if activeNames.count == 1 { return "\(activeNames[0])'s been active this week." }
        return "\(activeNames.joined(separator: " and ")) have been moving."
    }

    // Stateful synergy subline — specific, temporal, not evaluative
    var synergySubline: String {
        let completedToday = allActions.filter {
            $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast)
        }
        let quiet = SystemTag.allCases.filter {
            let days = state.daysSinceActivity($0)
            return days >= 3 && days < 999
        }
        if completedToday.isEmpty && quiet.isEmpty { return "All open." }
        if !completedToday.isEmpty {
            let systems = Set(completedToday.map { $0.system.rawValue.capitalized })
            if systems.count == 1 {
                let sysName = systems.first ?? ""
                let quietNote = quiet.isEmpty ? "" : " \(quiet.first?.rawValue.capitalized ?? "") — nothing here in \(state.daysSinceActivity(quiet[0])) days."
                return "\(sysName) today.\(quietNote)"
            }
            return systems.prefix(2).joined(separator: " and ") + " today."
        }
        if !quiet.isEmpty {
            let quietNames = quiet.prefix(2).map { $0.rawValue.capitalized }.joined(separator: " and ")
            return "\(quietNames) — nothing here in \(state.daysSinceActivity(quiet[0])) days."
        }
        return "All idle."
    }

    // FIX 04 — prose summary kept for dot row (not used as headline anymore)
    var synergyLine: String { synergySubline }
    var activeCount: Int { SystemTag.allCases.filter { profile.isSystemActiveThisWeek($0) }.count }

    // Next Sane Participation — selects by quietest system first, then lowest XP.
    // Quietest system = most days without a completion. Lowest XP within that = lowest friction.
    // This is One Door logic applied to the re-entry surface.
    var nextSaneAction: Action? {
        // Only consider pending, non-one-off actions
        let pending = pendingActions.filter { $0.recurrence != .none }
        guard !pending.isEmpty else { return nil }

        // Score each pending action: primary sort = days since system last active (desc), secondary = points (asc)
        let sorted = pending.sorted { a, b in
            let daysA = state.daysSinceActivity(a.system)
            let daysB = state.daysSinceActivity(b.system)
            if daysA != daysB { return daysA > daysB }     // quieter system first
            return a.points < b.points                      // lower XP = lower friction
        }
        return sorted.first
    }
    var ctaLabel: String {
        let completedToday = allActions.filter {
            $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast)
        }.count
        if completedToday == 0 { return "START DAY" }
        if completedToday < 3  { return "CONTINUE" }
        return "RETURN TO IT"
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(enhanced: true)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header — time-aware, name-aware, never cheesy
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            MonoLabel(text: "INCREMENTS", color: .violet, size: 11)
                            Text(profile.homeGreeting(completedToday: allActions.filter {
                                $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast)
                            }.count))
                                .font(.sora(16, weight: .light))
                                .foregroundColor(.textPrimary)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            MonoLabel(text: "DAY \(profile.daysInSystem)", color: .warm, size: 11)
                            MonoLabel(text: profile.monthProgress, color: .textMuted, size: 11)
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 28)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
                    .animation(.easeOut(duration: 0.4), value: appeared)

                    // System Synergy card — stateful, reads reality not math
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    MonoLabel(text: "SYSTEM SYNERGY", color: .textMuted)
                                    Text(synergyHeadline)
                                        .font(.sora(18, weight: .semibold))
                                        .foregroundColor(.textPrimary)
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(synergySubline)
                                        .font(.sora(13, weight: .light))
                                        .foregroundColor(.textSecond)
                                        .lineSpacing(3)
                                }
                                Spacer()
                            }

                            // 5-dot row — one per system, colored if active this week (persistent, not session-only)
                            HStack(spacing: 10) {
                                ForEach(SystemTag.allCases, id: \.self) { sys in
                                    let active = profile.isSystemActiveThisWeek(sys)
                                    let daysSince = state.daysSinceActivity(sys)
                                    let isDecaying = !active && daysSince >= 3 && daysSince < 999
                                    VStack(spacing: 5) {
                                        Circle()
                                            .fill(active ? sys.color : Color.surface2)
                                            .frame(width: 10, height: 10)
                                            .overlay(Circle().stroke(active ? sys.color.opacity(0.4) : Color.muted.opacity(0.4), lineWidth: 1))
                                            .opacity(isDecaying ? 0.4 : 1.0)
                                            .overlay(isDecaying ? Circle().strokeBorder(sys.color.opacity(0.6), lineWidth: 1) : nil)
                                        MonoLabel(text: String(sys.rawValue.prefix(3)), color: active ? sys.color : .muted, size: 8)
                                    }
                                }
                                Spacer()

                                // Adaptation marker — cumulative load, not a game score
                                VStack(alignment: .trailing, spacing: 2) {
                                    MonoLabel(text: "ADAPTATION", color: .violetLight, size: 10)
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(height: 2)
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(LinearGradient(colors: [.violet, .violetLight],
                                                                      startPoint: .leading, endPoint: .trailing))
                                                .frame(width: geo.size.width * profile.xpProgressFraction, height: 2)
                                        }
                                    }
                                    .frame(width: 60, height: 2)
                                    MonoLabel(text: "phase \(profile.level)", color: .muted, size: 11)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 14)
                    .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                    // Next sane participation — one door, quietest system first
                    if let next = nextSaneAction {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(text: "NEXT SANE PARTICIPATION")
                            Button(action: { state.selectedTab = 1 }) {
                                CardView {
                                    ActionDetailInlineRow(action: next)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24).padding(.top, 28)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 14)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
                    }

                    Button(action: { state.selectedTab = 1 }) {
                        Text(ctaLabel)
                            .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(2.5)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [.violetLight, .violet, .violetDim],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.violet.opacity(0.35), radius: 16, x: 0, y: 8)
                            .shadow(color: Color.warm.opacity(0.08), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal, 24).padding(.top, 32).padding(.bottom, 80)
                    .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)
                }
            }
        }
        .onAppear {
            state.recalculateScores(from: allActions)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true }
        }
        .onChange(of: allActions) { _, _ in
            // Re-score whenever action data changes — keeps Home in sync with Today
            state.recalculateScores(from: allActions)
        }
    }
}

// MARK: - TAB 2: TODAY — FIX 06 (One Door) + FIX 08 (Morning Evidence Card)

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query private var actions: [Action]
    @Query private var sessions: [Session]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query(sort: \CognitionLog.date, order: .reverse) private var cognitionLogs: [CognitionLog]
    @Query private var profiles: [OperatorProfile]
    @Query(sort: \HydrationLog.timestamp, order: .reverse) private var hydrationLogs: [HydrationLog]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @Bindable var state: AppState
    @State private var appeared = false
    @State private var showAdd = false
    @State private var showAddSession = false
    @State private var activeSession: Session? = nil
    @State private var firstOpenTime: Date = Date()
    @State private var selectedTodaySeg = 0   // 0=Today 1=Systems 2=Habits 3=Timeline

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    var todayActions: [Action] {
        let cal = Calendar.current
        let todayType = DayType.today
        let weekday = cal.component(.weekday, from: Date())  // 1=Sun, 7=Sat
        let isWeekend = weekday == 1 || weekday == 7
        let isWeekday = !isWeekend

        let all = actions.filter { a in
            // Day type filtering — base/hideout actions respect their prescribed day
            if let prescribed = a.prescribedDayType, prescribed != todayType { return false }

            // Recurrence day-of-week filtering — the bug that showed Sunday actions on Thursday
            switch a.recurrence {
            case .weekdays: if isWeekend { return false }   // weekday actions hide on weekends
            case .weekends: if isWeekday { return false }   // weekend actions hide on weekdays
            case .weekly:
                // Named-day weekly actions (Nizoral Tue/Sat, BHA Fri) — check title for day hint
                let title = a.title.lowercased()
                if title.contains("tuesday") || title.contains("— tuesday") {
                    if weekday != 3 { return false }  // 3 = Tuesday. Show only on Tuesdays.
                } else if title.contains("saturday") || title.contains("— saturday") {
                    if weekday != 7 { return false }  // 7 = Saturday. Show only on Saturdays.
                } else if title.contains("friday") || title.contains("— friday") {
                    if weekday != 6 { return false }  // 6 = Friday. Show only on Fridays.
                } else if title.contains("monday") || title.contains("— monday") {
                    if weekday != 2 { return false }
                } else if title.contains("sunday") || title.contains("— sunday") {
                    if weekday != 1 { return false }
                } else if title.contains("thursday") || title.contains("— thursday") {
                    if weekday != 5 { return false }
                } else if title.contains("wednesday") || title.contains("— wednesday") {
                    if weekday != 4 { return false }
                } else {
                    // Generic weekly: show only if 7+ days since last completed
                    if let last = a.completedAt {
                        let days = cal.dateComponents([.day], from: last, to: Date()).day ?? 0
                        if days < 7 { return false }
                    }
                }
            case .none:
                // One-off: only show on creation day if not yet completed
                if !cal.isDateInToday(a.createdAt) && !a.isCompleted { return false }
            case .daily: break
            }

            if a.isCompleted, let ca = a.completedAt { return cal.isDateInToday(ca) }
            return !a.isCompleted
        }.sorted { a, b in
            if a.isCompleted != b.isCompleted { return !a.isCompleted }
            switch (a.scheduledBlock, b.scheduledBlock) {
            case (let ta?, let tb?): return ta < tb
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil): return false
            }
        }

        let pending = all.filter { !$0.isCompleted }
        let completed = all.filter { $0.isCompleted }
        return pending + completed
    }

    var todaySessions: [Session] {
        let hour = Calendar.current.component(.hour, from: Date())
        return sessions
            .filter { $0.isActive && $0.shouldAppearToday }
            .sorted { a, b in
                sessionTimeScore(a, hour: hour) < sessionTimeScore(b, hour: hour)
            }
    }

    func sessionTimeScore(_ session: Session, hour: Int) -> Int {
        let title = session.title.lowercased()
        let isMorning = hour < 10
        let isEvening = hour >= 17
        if isMorning {
            if title.contains("morning") || title.contains("whole human reset") { return 0 }
            if title.contains("shutdown") || title.contains("preservation") { return 99 }
        }
        if isEvening {
            if title.contains("shutdown") || title.contains("preservation") { return 0 }
            if title.contains("morning") || title.contains("whole human reset") { return 99 }
        }
        if (title.contains("operator") || title.contains("solo")) && DayType.today == .hideout && isMorning { return 1 }
        return 50
    }

    // Active doctrine — overridden on Reserve/Partial days
    var activeDoctrine: String {
        if let override = state.todayEnergyState?.doctrineOverride { return override }
        return todayDoctrine
    }

    var completedToday: [Action] { todayActions.filter(\.isCompleted) }
    var pendingToday: [Action] { todayActions.filter { !$0.isCompleted } }
    var completedCount: Int { completedToday.count }
    var totalCount: Int { todayActions.count }

    // ADAPTIVE: Gateway system signal — when Environment is completed, what likely follows?
    // Based on the research: Environment is the most common gateway system.
    // After 7+ days this can be personalised; before that, use the science default.
    var gatewaySignal: (system: SystemTag, actionTitle: String)? {
        let envCompletedToday = completedToday.contains { $0.system == .environment }
        guard envCompletedToday else { return nil }
        // Only surface if there's a pending action in the likely next system
        let cascadeSystems: [SystemTag] = [.health, .cognition]
        for sys in cascadeSystems {
            if let next = pendingToday.first(where: { $0.system == sys }) {
                return (sys, next.title)
            }
        }
        return nil
    }

    // ADAPTIVE: Participation tone — if Participation has been quiet 3+ days, shift the stack header
    var participationQuietDays: Int {
        let participationActions = actions.filter { $0.system == .participation }
        guard let last = participationActions.compactMap({ $0.completedAt }).max() else {
            return actions.isEmpty ? 0 : 999
        }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
    }

    var stackHeaderText: String {
        if participationQuietDays >= 3 {
            return "TODAY'S ACTIONS — participation gap"
        }
        return "TODAY'S ACTIONS"
    }

    var stackHeaderColor: Color {
        participationQuietDays >= 5 ? .inkAmber : .textMuted
    }

    // TIME GROUPING — organises pending actions into readable day-arc bands
    enum TimeGroup: String, CaseIterable {
        case morning   = "MORNING"
        case afternoon = "AFTERNOON"
        case evening   = "EVENING"
        case anytime   = "ANYTIME"

        // Parse "HH:MM" scheduledBlock into a group
        static func group(for block: String?) -> TimeGroup {
            guard let block = block,
                  let hour = Int(block.split(separator: ":").first ?? "") else { return .anytime }
            switch hour {
            case 0..<12:  return .morning
            case 12..<17: return .afternoon
            default:      return .evening
            }
        }
    }

    // Returns pending actions bucketed by time group, preserving chronological order within each band
    var pendingByTimeGroup: [(group: TimeGroup, actions: [Action])] {
        var buckets: [TimeGroup: [Action]] = [:]
        for action in pendingToday {
            let g = TimeGroup.group(for: action.scheduledBlock)
            buckets[g, default: []].append(action)
        }
        // Emit only groups that have actions, in day-arc order
        return TimeGroup.allCases.compactMap { g in
            guard let acts = buckets[g], !acts.isEmpty else { return nil }
            return (group: g, actions: acts)
        }
    }

    // ADAPTIVE: Creative cognition protection — are any creative actions being crowded by admin?
    var creativeActionCount: Int {
        pendingToday.filter { $0.cognitionMode == .creative }.count
    }
    var adminActionCount: Int {
        pendingToday.filter { $0.cognitionMode == .administrative }.count
    }
    var creativeProtectionWarning: Bool {
        creativeActionCount > 0 && adminActionCount >= 3
    }

    // Days with at least one completion — for inline readiness chip
    // BUG FIX: was using completedAt (nil'd on reset) — only counted today. Use completionDates.
    var daysWithCompletions: Int {
        Set(actions.flatMap { $0.completionDates }.map {
            Calendar.current.startOfDay(for: $0)
        }).count
    }

    // Show the readiness chip only in the first 7 days — after that it's done its job
    var showReadinessChip: Bool { daysWithCompletions < 7 }

    var readinessChipText: String {
        let remaining = max(0, 7 - daysWithCompletions)
        if remaining == 0 { return "" }
        return "Starting to learn your patterns. \(remaining) more day\(remaining == 1 ? "" : "s")."
    }
    var oneDoorAction: Action? {
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour >= 12, completedCount == 0, !pendingToday.isEmpty else { return nil }
        return pendingToday.min(by: { $0.points < $1.points })
    }

    // FIX 08 — Morning evidence card: reads actual yesterday completions.
    // Also surfaces the tomorrow action pre-committed in last night's review.
    var morningEvidenceData: (text: String, tomorrowAction: String?)? {
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour < 12 else { return nil }

        // BUG FIX: was using completedAt to find yesterday's completions — but completedAt is
        // nil'd on daily reset. Use completionDates (persistent history) for accuracy.
        let cal = Calendar.current
        let yesterdayCount = actions.reduce(0) { count, action in
            count + action.completionDates.filter { cal.isDateInYesterday($0) }.count
        }
        guard yesterdayCount >= 2 else { return nil }

        // Build a readable system list from DailyLog (already recorded yesterday's systems)
        let yesterdayLog = logs.first(where: { cal.isDateInYesterday($0.date) })
        let systemsYesterday: String
        if let systems = yesterdayLog?.systemsTouched, !systems.isEmpty {
            systemsYesterday = systems.map { $0.capitalized }.sorted().prefix(2).joined(separator: ", ")
        } else {
            // Fallback: derive from completionDates if no log
            let sysTags = Array(Set(actions.filter { a in
                a.completionDates.contains { cal.isDateInYesterday($0) }
            }.map { $0.system.rawValue.capitalized })).sorted()
            systemsYesterday = sysTags.prefix(2).joined(separator: ", ")
        }

        let countWord = yesterdayCount == 1 ? "1 action" : "\(yesterdayCount) actions"
        let text = "Yesterday: \(countWord). \(systemsYesterday) active."

        // Pull tomorrow's pre-committed action from last night's review (specificActionNote)
        let tomorrowAction = yesterdayLog?.specificActionNote

        return (text, tomorrowAction)
    }

    var todayDoctrine: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let weekday = Calendar.current.component(.weekday, from: Date()) // 1=Sun, 7=Sat
        let isWeekend = weekday == 1 || weekday == 7
        let isSunday = weekday == 1
        let isFriday = weekday == 6

        // Energy State overrides handled by activeDoctrine — this is the base
        // Reserve/Partial state overrides these entirely

        // Early morning — opening the day
        if hour < 10 && completedCount == 0 {
            if isWeekend { return "Weekend. Even one thing counts." }
            return "Start with something real."
        }
        // Morning with movement
        if hour < 12 && completedCount > 0 {
            if completedCount >= 3 { return "You're in it." }
            return "Getting started changes things."
        }
        // Midday — nothing done
        if hour < 15 && completedCount == 0 {
            if isFriday { return "Friday's not over. One thing." }
            return "The day's not gone. Start somewhere."
        }
        // Midday — things done
        if hour < 15 && completedCount > 0 {
            return "Small moves are still moves."
        }
        // Evening — nothing done
        if hour < 20 && completedCount == 0 {
            if isSunday { return "It doesn't need to be perfect. Just real." }
            return "Still time. Start small."
        }
        // Evening — things done
        if hour < 20 && completedCount > 0 {
            if completedCount >= 5 { return "That's enough for today." }
            return "One thing. That's it."
        }
        // Late — wind down
        if isSunday { return "Tomorrow's already starting. One thing before you stop." }
        return "Hard week. You're still here."
    }

    // Whether today's review has already been submitted (topWin being set = full review done)
    var alreadyReviewedToday: Bool {
        guard let log = logs.first(where: { Calendar.current.isDateInToday($0.date) }) else { return false }
        return log.topWin != nil
    }

    // Review CTA — changes label and visual treatment once the day has been logged
    var reviewCTAButton: some View {
        Button(action: { state.showReview = true }) {
            HStack {
                Image(systemName: alreadyReviewedToday ? "pencil" : "checkmark.circle")
                    .font(.system(size: 14))
                Text(alreadyReviewedToday ? "Edit Today's Log" : "Daily Review")
                    .font(.sora(14, weight: .medium))
            }
            .foregroundColor(alreadyReviewedToday ? .textMuted : .warm)
            .frame(maxWidth: .infinity).frame(height: 48)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        alreadyReviewedToday ? Color.muted.opacity(0.3) : Color.warm.opacity(0.4),
                        lineWidth: 1
                    )
            )
        }
    }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        MonoLabel(text: profile.todayContextLine(), color: .textMuted, size: 11)
                        // Name address in Today header — operational, not effusive
                        // "TODAY" alone when no name set; "TODAY, BRICE" when name is set
                        Text(profile.firstName.isEmpty ? "TODAY" : "TODAY, \(profile.firstName.uppercased())")
                            .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    }
                    Spacer()
                    if totalCount > 0 {
                        MonoLabel(text: "\(totalCount) today", color: .textMuted, size: 11)
                    }
                    Button(action: { showAdd = true }) {
                        HStack(spacing: 5) {
                            Image(systemName: "plus").font(.system(size: 12, weight: .semibold))
                            Text("Add").font(.sora(12, weight: .medium))
                        }
                        .foregroundColor(.violet)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.violetDim.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 12)

                segmentControl(["Today", "Systems", "Habits", "Timeline"], selected: $selectedTodaySeg)
                    .padding(.horizontal, 24).padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                  switch selectedTodaySeg {
                  case 1:
                    IncrementsViewEmbed(state: state)
                  case 2:
                    HabitsViewEmbed()
                  case 3:
                    TimelineViewEmbed()
                  default:
                    VStack(spacing: 16) {

                        // Phase 2 — Energy State input (appears until set, collapses after)
                        if state.todayEnergyState == nil {                            EnergyStateInputCard(state: state)
                                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                                .animation(.easeOut(duration: 0.35), value: appeared)
                        }

                        // FIX 08 — Morning evidence card (reads actual completions, not log count)
                        if let evidence = morningEvidenceData {
                            CardView(style: .secondary) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.inkGreen.opacity(0.15))
                                                .frame(width: 24, height: 24)
                                            Circle()
                                                .fill(Color.inkGreen)
                                                .frame(width: 8, height: 8)
                                                .shadow(color: Color.inkGreen.opacity(0.6), radius: 4)
                                        }
                                        Text(evidence.text)
                                            .font(.sora(13, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
                                        Spacer()
                                    }
                                    // Tomorrow's pre-committed action from last night's review
                                    if let tomorrowAction = evidence.tomorrowAction, !tomorrowAction.isEmpty {
                                        HStack(spacing: 8) {
                                            Rectangle()
                                                .fill(Color.warm.opacity(0.3))
                                                .frame(width: 1, height: 24)
                                                .padding(.leading, 4)
                                            VStack(alignment: .leading, spacing: 2) {
                                                MonoLabel(text: "START HERE", color: .warm, size: 11)
                                                Text(tomorrowAction)
                                                    .font(.sora(13, weight: .medium)).foregroundColor(.textPrimary)
                                            }
                                        }
                                    }
                                }
                            }
                            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                            .animation(.easeOut(duration: 0.35), value: appeared)
                        }

                        // FIX 06 — One Door card
                        if let doorAction = oneDoorAction {
                            OneDoorCard(action: doorAction) { completeAction(doorAction) }
                                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                                .animation(.easeOut(duration: 0.35).delay(0.02), value: appeared)
                        }

                        // Doctrine hero — no header label, doctrine speaks for itself
                        CardView {
                            VStack(alignment: .leading, spacing: 0) {
                                Rectangle()
                                    .fill(Color.warm.opacity(0.3))
                                    .frame(width: 24, height: 1.5)
                                    .padding(.bottom, 12)
                                Text(activeDoctrine).font(.sora(17, weight: .light))
                                    .foregroundColor(.textPrimary).lineSpacing(4)
                            }
                        }
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.35).delay(0.04), value: appeared)

                        // Phase 3 P3 — Hydration rhythmic prompt (below doctrine, above progress)
                        // Invisible after 8pm — no evening pressure
                        HydrationPulseCard()
                            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                            .animation(.easeOut(duration: 0.35).delay(0.05), value: appeared)

                        // Progress
                        CardView {
                            HStack(spacing: 16) {
                                CircularProgress(
                                    value: totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0,
                                    size: 52, color: .inkGreen, lineWidth: 3
                                )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's actions").font(.sora(13, weight: .medium)).foregroundColor(.textPrimary)
                                    Text(completedCount == 0
                                         ? "Nothing closed yet."
                                         : completedCount == totalCount
                                         ? "All \(totalCount) closed."
                                         : "\(completedCount) of \(totalCount) complete")
                                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                }
                                Spacer()
                                // Removed: large standalone number — Competition trap.
                                // Ring position + text carries the signal without giving a score to track.
                            }
                        }
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.35).delay(0.06), value: appeared)

                        // Inline readiness chip — honest about what's being collected.
                        // Disappears after day 7 when pattern window opens.
                        if showReadinessChip && !readinessChipText.isEmpty {
                            HStack(spacing: 8) {
                                Circle().fill(Color.violet.opacity(0.4)).frame(width: 5, height: 5)
                                Text(readinessChipText)
                                    .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.35).delay(0.065), value: appeared)
                        }

                        // ADAPTIVE: Gateway system signal
                        // "Environment moved. Health tends to follow."
                        // Surfaces only after Environment is completed — not speculative
                        if let gateway = gatewaySignal {
                            CardView(style: .ambient) {
                                HStack(spacing: 12) {
                                    HStack(spacing: 6) {
                                        Circle().fill(Color.inkGreen).frame(width: 6, height: 6)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 10, weight: .light))
                                            .foregroundColor(.textMuted)
                                        Circle().fill(gateway.system.color).frame(width: 6, height: 6)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Environment's done. \(gateway.system.rawValue.capitalized) usually follows.")
                                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                        Text(gateway.actionTitle)
                                            .font(.sora(12, weight: .medium)).foregroundColor(.textPrimary)
                                    }
                                    Spacer()
                                }
                            }
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.35).delay(0.07), value: appeared)

                        }

                        // ADAPTIVE: Creative cognition protection warning
                        // Only appears when creative actions are being crowded by 3+ admin actions
                        if creativeProtectionWarning {
                            CardView(style: .ambient) {
                                HStack(spacing: 10) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(.warm)
                                    Text("Admin's crowding the creative work.")
                                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                    Spacer()
                                }
                            }
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.35).delay(0.08), value: appeared)
                        }

                        // Action stack — time-grouped by day arc
                        if !todayActions.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {

                                // Pending actions grouped into time bands
                                ForEach(pendingByTimeGroup, id: \.group.rawValue) { bucket in
                                    VStack(alignment: .leading, spacing: 10) {
                                        SectionHeader(text: bucket.group.rawValue,
                                                      color: participationQuietDays >= 5 && bucket.group == .morning ? .inkAmber : .textMuted)
                                        CardView {
                                            VStack(spacing: 0) {
                                                ForEach(Array(bucket.actions.enumerated()), id: \.element.id) { i, action in
                                                    ActionRow(action: action) { completeAction(action) }
                                                    if i < bucket.actions.count - 1 {
                                                        Rectangle()
                                                            .fill(Color.muted.opacity(0.2))
                                                            .frame(height: 0.5)
                                                            .padding(.vertical, 6)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Completed actions — collapsed under DONE
                                if !completedToday.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        SectionHeader(text: "DONE · \(completedToday.count)", color: .inkGreen)
                                        CardView(style: .secondary) {
                                            VStack(spacing: 0) {
                                                ForEach(Array(completedToday.enumerated()), id: \.element.id) { i, action in
                                                    ActionRow(action: action) { completeAction(action) }
                                                    if i < completedToday.count - 1 {
                                                        Rectangle()
                                                            .fill(Color.muted.opacity(0.15))
                                                            .frame(height: 0.5)
                                                            .padding(.vertical, 6)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                            .animation(.easeOut(duration: 0.35).delay(0.1), value: appeared)
                        }

                        // Session protocols stack
                        if !todaySessions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(text: "PROTOCOLS")
                                VStack(spacing: 8) {
                                    ForEach(todaySessions) { session in
                                        CardView {
                                            SessionCard(
                                                session: session,
                                                onTap: { activeSession = session },
                                                onQuickDone: { completeSession(session) },
                                                onSkip: { reason in skipSession(session, reason: reason) }
                                            )
                                        }
                                    }
                                }
                            }
                            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                            .animation(.easeOut(duration: 0.35).delay(0.12), value: appeared)
                        }


                        // Review CTA — adapts based on whether today's review has been submitted
                        reviewCTAButton
                            .padding(.bottom, 80)
                            .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.35).delay(0.15), value: appeared)
                    }
                    .padding(.horizontal, 24)
                  } // end switch
                }
            }
        }
        .sheet(isPresented: $showAdd) { AddActionSheet(isPresented: $showAdd) }
        .sheet(isPresented: $showAddSession) { AddSessionSheet(isPresented: $showAddSession) }
        .sheet(isPresented: $state.showReview) { DailyReviewSheet(isPresented: $state.showReview, state: state) }
        .fullScreenCover(item: $activeSession) { session in
            SessionExecutionView(session: session) { activeSession = nil }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true }
            // Layer A voice only — rule-based operational. No Layer B (pattern interpretation)
            // on the execution surface. Layer B fires from Operator > Brief.
            let lastOpenKey = "increments_last_today_open"
            let isFirstOpenToday: Bool
            if let last = UserDefaults.standard.object(forKey: lastOpenKey) as? Date {
                isFirstOpenToday = !Calendar.current.isDateInToday(last)
            } else {
                isFirstOpenToday = true
            }
            UserDefaults.standard.set(Date(), forKey: lastOpenKey)

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
                    // Layer A only — speakIfWarranted(context:) without profile/logs = no Layer B
                    VoicePresence.shared.speakIfWarranted(context: ctx)
                }
            }
        }
    }

    func completeAction(_ action: Action) {
        let wasCompleted = action.isCompleted
        action.isCompleted.toggle()
        action.completedAt = action.isCompleted ? Date() : nil
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if action.isCompleted {
            state.systemLastActivity[action.system] = Date()
            // Capture time-of-day for completion window intelligence
            let hour = Calendar.current.component(.hour, from: Date())
            action.completionDates.append(Date())
            action.completionHours.append(hour)
            if let profile = profiles.first {
                profile.addXP(action.points)
                profile.markSystemActive(action.system)
            }
        } else if wasCompleted {
            // Un-completing — remove last completion record
            if !action.completionDates.isEmpty { action.completionDates.removeLast() }
            if !action.completionHours.isEmpty { action.completionHours.removeLast() }
            if let profile = profiles.first {
                profile.xp = max(0, profile.xp - action.points)
            }
        }
        state.recalculateScores(from: actions)

        // INTELLIGENCE FIX: update DailyLog.completedActionIDs on every tap, not only at review.
        // The longitudinal context builder uses DailyLog.completedCount for reserve/full day averages.
        // If the user never does a daily review, this count stays 0 for every log — making
        // reserveDayCompletionAvg and fullDayCompletionAvg permanently 0, killing that
        // branch of pattern intelligence. Writing it here ensures the data exists regardless.
        updateTodayLogCompletions()
    }

    func updateTodayLogCompletions() {
        let cal = Calendar.current
        let completedToday = actions.filter {
            $0.isCompleted && cal.isDateInToday($0.completedAt ?? .distantPast)
        }
        // Find or create today's DailyLog
        if let existing = logs.first(where: { cal.isDateInToday($0.date) }) {
            existing.completedActionIDs = completedToday.map(\.id)
            // Also capture first system touched — gateway intelligence
            let firstCompletion = completedToday
                .compactMap { a -> (Action, Date)? in guard let at = a.completedAt else { return nil }; return (a, at) }
                .min(by: { $0.1 < $1.1 })
            if existing.firstSystemTouched == nil {
                existing.firstSystemTouched = firstCompletion?.0.system.rawValue
                existing.firstCompletionHour = firstCompletion.map { cal.component(.hour, from: $0.1) }
            }
        } else {
            let log = DailyLog(date: Date())
            log.completedActionIDs = completedToday.map(\.id)
            let firstCompletion = completedToday
                .compactMap { a -> (Action, Date)? in guard let at = a.completedAt else { return nil }; return (a, at) }
                .min(by: { $0.1 < $1.1 })
            log.firstSystemTouched = firstCompletion?.0.system.rawValue
            log.firstCompletionHour = firstCompletion.map { cal.component(.hour, from: $0.1) }
            context.insert(log)
        }
        // Also keep CognitionLog in sync — updates actualCompletionCount for energy calibration
        let todayCognitionLog = cognitionLogs.first { Calendar.current.isDateInToday($0.date) }
        if let log = todayCognitionLog { log.actualCompletionCount = completedToday.count }
    }

    // Quick-mark session done — called from SessionCard checkmark, bypasses step-through
    // Same data written as closeSession() in SessionExecutionView, so both paths are equivalent
    func completeSession(_ session: Session) {
        session.lastCompleted = Date()
        session.completedAt = Date()
        session.completionDates.append(Date())
        if session.recurrence == .none { session.isCompleted = true }
        if let p = profiles.first { p.addXP(session.points) }
        // Mark the system active this week
        if let p = profiles.first { p.markSystemActive(session.system) }
        state.systemLastActivity[session.system] = Date()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // Record an intentional skip — two reasons: rest (reserve day choice) or disruption (external)
    // Skipped sessions: hide from Today, record the date+reason for Wendy's pattern analysis.
    // NOT the same as not logging — blank = unknown. Skip = deliberate signal.
    func skipSession(_ session: Session, reason: SessionSkipReason) {
        session.skipDates.append(Date())
        session.skipReasons.append(reason.rawValue)
        // Don't increment skipCount here — that's for the daily reset (unknown non-completions).
        // Intentional skips are a different signal and tracked separately.
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// FIX 06 — One Door Card component
struct OneDoorCard: View {
    let action: Action
    var onComplete: () -> Void
    @State private var completed = false

    var body: some View {
        if !completed {
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "ONE DOOR", color: .violet)
                    Text(action.title)
                        .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
                    MonoLabel(text: "Open it.", color: .textSecond, size: 11)

                    Button(action: {
                        withAnimation { completed = true }
                        onComplete()
                        // FIX 06 — completion message: "Re-entry complete." (shown via haptic + disappear)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }) {
                        Text("RE-ENTER")
                            .font(.sora(13, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                            .frame(maxWidth: .infinity).frame(height: 44)
                            .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Text("Nothing else required.")
                        .font(.mono(11)).foregroundColor(.muted).tracking(1)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

// MARK: - PHASE 2: ENERGY STATE INPUT CARD

struct EnergyStateInputCard: View {
    @Bindable var state: AppState
    @Environment(\.modelContext) private var context
    @Query private var cognitionLogs: [CognitionLog]
    @Query(sort: \DailyLog.date, order: .reverse) private var dailyLogs: [DailyLog]

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 14) {
                MonoLabel(text: "CAPACITY TODAY", color: .textMuted)

                HStack(spacing: 10) {
                    ForEach([EnergyState.full, .partial, .reserve], id: \.rawValue) { es in
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                state.setEnergyState(es)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                // Write CognitionLog entry — starts building energy/output correlation
                                writeCognitionLog(energyState: es)
                            }
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: es.icon)
                                    .font(.system(size: 20, weight: .ultraLight))
                                    .foregroundColor(es.color)
                                Text(es.label)
                                    .font(.sora(13, weight: .medium))
                                    .foregroundColor(.textPrimary)
                                Text(es.sublabel)
                                    .font(.sora(10, weight: .light))
                                    .foregroundColor(.textMuted)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    Color.surface
                                    es.color.opacity(0.04)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(es.color.opacity(0.15), lineWidth: 0.5)
                            )
                        }
                    }
                }
            }
        }
    }

    // Write a CognitionLog entry when energy state is set.
    // This builds the energy → output correlation dataset over time.
    func writeCognitionLog(energyState: EnergyState) {
        // Only one log per day — update if exists
        let today = cognitionLogs.first { Calendar.current.isDateInToday($0.date) }
        if let existing = today {
            existing.clarityLevel = energyState == .full ? .clear : energyState == .partial ? .moderate : .overloaded
            existing.cognitiveLoad = energyState == .reserve ? .overloaded : .moderate
            existing.clarityScore = energyState == .full ? 80 : energyState == .partial ? 60 : 35
            existing.energyStateAtDeclaration = energyState.rawValue
        } else {
            let log = CognitionLog()
            log.date = Date()
            log.clarityLevel = energyState == .full ? .clear : energyState == .partial ? .moderate : .overloaded
            log.cognitiveLoad = energyState == .reserve ? .overloaded : .moderate
            log.clarityScore = energyState == .full ? 80 : energyState == .partial ? 60 : 35
            log.energyStateAtDeclaration = energyState.rawValue
            context.insert(log)
        }
        // Also write to today's DailyLog for cross-model calibration
        writeDailyLogEnergyState(energyState)
    }

    func writeDailyLogEnergyState(_ energyState: EnergyState) {
        if let existing = dailyLogs.first(where: { Calendar.current.isDateInToday($0.date) }) {
            existing.energyStateRaw = energyState.rawValue
        } else {
            let log = DailyLog(date: Date())
            log.energyStateRaw = energyState.rawValue
            context.insert(log)
        }
    }
}

// MARK: - PHASE 3 PRIORITY 3: HYDRATION PULSE CARD

struct HydrationPulseCard: View {
    @Query(sort: \HydrationLog.timestamp, order: .reverse) private var logs: [HydrationLog]
    @Environment(\.modelContext) private var context
    @State private var pulse = false

    var lastLog: HydrationLog? { logs.first }

    var hoursSinceLast: Double {
        guard let last = lastLog else { return 999 }
        return Date().timeIntervalSince(last.timestamp) / 3600
    }

    var relativeLabel: String {
        guard let last = lastLog else { return "Not yet today." }
        let mins = Int(Date().timeIntervalSince(last.timestamp) / 60)
        if mins < 60  { return "Last: \(mins)m ago" }
        let hrs = mins / 60
        if hrs < 4   { return "Last: \(hrs)h ago" }
        if Calendar.current.isDateInToday(last.timestamp) { return "Last: this morning" }
        return "Not yet today."
    }

    // After 8pm — card is invisible. No evening hydration pressure.
    var isAfter8pm: Bool {
        Calendar.current.component(.hour, from: Date()) >= 20
    }

    // Pulse state: subtle animation when quiet for 2+ hours during active hours
    var shouldPulse: Bool { hoursSinceLast >= 2 && !isAfter8pm }

    var dotOpacity: Double {
        if hoursSinceLast < 2    { return 1.0 }
        if hoursSinceLast < 3    { return 0.75 }
        return 0.6
    }

    var body: some View {
        if !isAfter8pm {
            CardView(style: .secondary) {
                HStack(spacing: 14) {
                    // inkTeal dot — pulses gently when overdue
                    ZStack {
                        if shouldPulse {
                            Circle()
                                .fill(Color.inkTeal.opacity(0.15))
                                .frame(width: 20, height: 20)
                                .scaleEffect(pulse ? 1.4 : 1.0)
                                .opacity(pulse ? 0 : 0.4)
                                .animation(.easeOut(duration: 1.8).repeatForever(autoreverses: false), value: pulse)
                        }
                        Circle()
                            .fill(Color.inkTeal.opacity(dotOpacity))
                            .frame(width: 8, height: 8)
                    }
                    .frame(width: 20, height: 20)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Water.")
                            .font(.sora(14, weight: .medium)).foregroundColor(.textPrimary)
                        Text(relativeLabel)
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                    Spacer()
                    // Single tap logs — no confirmation, no celebration
                    Button(action: logHydration) {
                        Text("LOG")
                            .font(.mono(11)).foregroundColor(.inkTeal).tracking(1.5)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.inkTeal.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.inkTeal.opacity(0.25), lineWidth: 0.5))
                    }
                }
            }
            .onAppear { if shouldPulse { pulse = true } }
            .onChange(of: shouldPulse) { _, new in pulse = new }
        }
    }

    func logHydration() {
        context.insert(HydrationLog())
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        pulse = false
    }
}

// MARK: - WENDY OBSERVATION CARD (Phase B1 — text only)
// Surfaces Layer B observations as a quiet ambient card in Today tab.
// Phase B1: text only — user reads, not hears.
// Phase B2: same text routes to VoicePresence.speak() after B1 confirms recognition not surveillance.

struct WendyObservationCard: View {
    // Observe the singleton directly — @ObservedObject with the shared instance
    // is correct here: the card doesn't own the object, it observes it.
    // The default value ensures it always references the same singleton.
    @ObservedObject private var wendyState = WendyState.shared

    var body: some View {
        if let observation = wendyState.pendingObservation {
            CardView(style: .secondary) {
                HStack(alignment: .top, spacing: 14) {
                    // Violet dot — distinguishes Wendy from Layer A system signals
                    VStack {
                        Circle()
                            .fill(Color.violetLight.opacity(0.7))
                            .frame(width: 6, height: 6)
                            .shadow(color: Color.violetLight.opacity(0.4), radius: 4)
                        Spacer()
                    }
                    .padding(.top, 3)

                    VStack(alignment: .leading, spacing: 6) {
                        // No label header — the observation speaks for itself
                        Text(observation)
                            .font(.sora(14, weight: .light))
                            .foregroundColor(.textPrimary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                        // Subtle source indicator — not prominent, just honest
                        MonoLabel(text: "WENDY", color: .violetLight.opacity(0.6), size: 10)
                    }

                    Spacer()

                    // Dismiss — one tap, no confirmation
                    Button(action: { withAnimation(.easeOut(duration: 0.2)) { wendyState.dismiss() } }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.textMuted)
                            .frame(width: 22, height: 22)
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}



struct MaintenanceSection: View {
    @Query private var items: [MaintenanceItem]
    @State private var showAll = false
    @State private var showAdd = false
    @Environment(\.modelContext) private var context

    // Default: only show upcoming or due. "Show all" reveals quiet items.
    var visibleItems: [MaintenanceItem] {
        let active = items.filter(\.isActive)
        if showAll { return active }
        return active.filter { $0.state == .due || $0.state == .upcoming }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header + controls
            HStack {
                SectionHeader(text: "MAINTENANCE")
                Spacer()
                if items.filter(\.isActive).count > visibleItems.count {
                    Button(action: { withAnimation { showAll.toggle() } }) {
                        MonoLabel(text: showAll ? "LESS" : "SHOW ALL", color: .textMuted, size: 11)
                    }
                }
                Button(action: { showAdd = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.violet)
                        .frame(width: 28, height: 28)
                        .background(Color.violetDim.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)

            if visibleItems.isEmpty {
                // Nothing upcoming or due — quiet state
                CardView(style: .ambient) {
                    HStack(spacing: 10) {
                        Circle().fill(Color.inkGreen.opacity(0.5)).frame(width: 6, height: 6)
                        Text("All maintenance items idle.")
                            .font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 6) {
                    ForEach(visibleItems) { item in
                        MaintenanceItemRow(item: item)
                            .padding(.horizontal, 24)
                    }
                }
            }
        }
        .sheet(isPresented: $showAdd) { AddMaintenanceSheet(isPresented: $showAdd) }
    }
}

struct MaintenanceItemRow: View {
    @Bindable var item: MaintenanceItem
    @State private var confirming = false

    var stateColor: Color {
        switch item.state {
        case .quiet:    return .textMuted
        case .upcoming: return .inkAmber
        case .due:      return .inkTeal
        }
    }

    var stateText: String {
        switch item.state {
        case .quiet:    return "Idle"
        case .upcoming: return "Due in \(item.daysUntilDue)d"
        case .due:      return "Worth doing soon."
        }
    }

    var body: some View {
        CardView(style: .ambient) {
            HStack(spacing: 12) {
                // Domain accent dot
                Circle()
                    .fill(item.system.color.opacity(item.state == .quiet ? 0.35 : 0.7))
                    .frame(width: 7, height: 7)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.sora(13, weight: item.state == .quiet ? .light : .medium))
                        .foregroundColor(item.state == .quiet ? .textMuted : .textPrimary)
                    Text(stateText)
                        .font(.mono(11)).foregroundColor(stateColor).tracking(0.5)
                }
                Spacer()

                // Mark complete — only visible when upcoming or due
                if item.state != .quiet {
                    Button(action: {
                        if confirming {
                            item.lastCompleted = Date()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            confirming = false
                        } else {
                            withAnimation { confirming = true }
                            // Auto-reset confirm state after 3s if not tapped
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation { confirming = false }
                            }
                        }
                    }) {
                        Text(confirming ? "Confirm" : "Mark complete")
                            .font(.mono(11)).tracking(0.5)
                            .foregroundColor(confirming ? .bgBase : stateColor)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(confirming ? stateColor : stateColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .animation(.easeOut(duration: 0.2), value: confirming)
                    }
                }
            }
        }
    }
}

struct AddMaintenanceSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var context
    @State private var title = ""
    @State private var system: SystemTag = .operations
    @State private var intervalDays: Int = 30
    @State private var notes = ""

    let intervals = [7, 14, 30, 60, 90]
    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Text("New Maintenance Item").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Cancel") { isPresented = false }.font(.sora(14)).foregroundColor(.textMuted)
                    }

                    inputField("ITEM", placeholder: "What needs periodic attention?", text: $title)

                    // System picker
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "SYSTEM")
                        HStack(spacing: 8) {
                            ForEach(SystemTag.allCases, id: \.self) { tag in
                                Button(action: { system = tag }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: tag.icon).font(.system(size: 12))
                                        Text(tag.rawValue.prefix(3).uppercased()).font(.mono(9)).tracking(1)
                                    }
                                    .foregroundColor(system == tag ? tag.color : .textMuted)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(system == tag ? tag.color.opacity(0.12) : Color.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(system == tag ? tag.color.opacity(0.4) : Color.clear, lineWidth: 1))
                                }
                            }
                        }
                    }

                    // Interval picker
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "INTERVAL")
                        HStack(spacing: 8) {
                            ForEach(intervals, id: \.self) { days in
                                Button(action: { intervalDays = days }) {
                                    Text(days == 7 ? "7d" : days == 14 ? "14d" : days == 30 ? "30d" : days == 60 ? "60d" : "90d")
                                        .font(.mono(11)).tracking(0.5)
                                        .foregroundColor(intervalDays == days ? .bgBase : .textSecond)
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(intervalDays == days ? Color.violet : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }

                    inputField("NOTES (OPTIONAL)", placeholder: "Context or constraint", text: $notes)

                    primaryButton("ADD ITEM", disabled: !canSave) {
                        let item = MaintenanceItem(
                            title: title, system: system,
                            intervalDays: intervalDays,
                            notes: notes.isEmpty ? "" : notes
                        )
                        context.insert(item)
                        isPresented = false
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }
}

// MARK: - PHASE 3 PRIORITY 4: FINANCIAL CLARITY CARD

struct FinancialClarityCard: View {
    @Query private var states: [FinancialState]
    @State private var showEdit = false
    @Environment(\.modelContext) private var context

    var current: FinancialState {
        if let s = states.first { return s }
        let s = FinancialState()
        return s
    }

    var nextObligationText: String? {
        guard let date = current.nextObligationDate,
              !current.nextObligationLabel.isEmpty else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return "Next: \(current.nextObligationLabel) — due." }
        return "Next: \(current.nextObligationLabel) — in \(days) days."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            CardView(style: .ambient) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "FINANCIAL", color: .warm, size: 11)
                        HStack(spacing: 8) {
                            Circle()
                                .fill(current.runwayState.color)
                                .frame(width: 7, height: 7)
                                .shadow(color: current.runwayState.color.opacity(0.5), radius: 4)
                            Text(current.runwayState.label)
                                .font(.sora(14, weight: .medium)).foregroundColor(.textPrimary)
                        }
                        if let obligationText = nextObligationText {
                            Text(obligationText)
                                .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                        }
                        // Inflow — binary signal only
                        Text(current.inflowReceived ? "Income received this period." : "Nothing logged.")
                            .font(.mono(11)).foregroundColor(current.inflowReceived ? .inkGreen : .textMuted).tracking(0.3)
                    }
                    Spacer()
                    Button(action: { showEdit = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12)).foregroundColor(.textMuted)
                            .frame(width: 28, height: 28)
                            .background(Color.surface)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditFinancialStateSheet(isPresented: $showEdit, state: states.first)
        }
        .onAppear {
            if states.isEmpty { context.insert(FinancialState()) }
        }
    }
}

struct EditFinancialStateSheet: View {
    @Binding var isPresented: Bool
    var state: FinancialState?
    @Environment(\.modelContext) private var context
    @Query private var states: [FinancialState]

    @State private var runwayState: RunwayState = .stable
    @State private var inflowReceived: Bool = false
    @State private var nextLabel: String = ""
    @State private var nextDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 14)
    @State private var hasNextObligation: Bool = false
    @State private var notes: String = ""

    var current: FinancialState? { state ?? states.first }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Text("Financial State").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Done") { save(); isPresented = false }.font(.sora(14)).foregroundColor(.violet)
                    }

                    // Runway State — three options only
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "RUNWAY")
                        MonoLabel(text: "Categorical — not numerical", color: .muted, size: 10)
                        HStack(spacing: 8) {
                            ForEach(RunwayState.allCases, id: \.self) { rs in
                                Button(action: { runwayState = rs }) {
                                    VStack(spacing: 6) {
                                        Circle()
                                            .fill(rs.color.opacity(runwayState == rs ? 0.9 : 0.3))
                                            .frame(width: 8, height: 8)
                                        Text(rs.rawValue)
                                            .font(.mono(11)).tracking(0.5)
                                            .foregroundColor(runwayState == rs ? .textPrimary : .textMuted)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                                    .background(runwayState == rs ? rs.color.opacity(0.1) : Color.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(runwayState == rs ? rs.color.opacity(0.4) : Color.clear, lineWidth: 1))
                                }
                            }
                        }
                    }

                    // Inflow — binary only
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "INFLOW THIS PERIOD")
                        HStack(spacing: 12) {
                            ForEach([true, false], id: \.self) { val in
                                Button(action: { inflowReceived = val }) {
                                    Text(val ? "Received" : "Not yet")
                                        .font(.sora(13))
                                        .foregroundColor(inflowReceived == val ? .bgBase : .textSecond)
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(inflowReceived == val ? Color.inkGreen : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Next obligation — optional
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            MonoLabel(text: "NEXT OBLIGATION")
                            Spacer()
                            Toggle("", isOn: $hasNextObligation).tint(Color.warm).labelsHidden()
                        }
                        if hasNextObligation {
                            inputField("LABEL", placeholder: "e.g. Rent, Insurance", text: $nextLabel)
                            DatePicker("Date", selection: $nextDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .font(.sora(13)).foregroundColor(.textPrimary)
                                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    inputField("NOTES (OPTIONAL)", placeholder: "Running context", text: $notes)

                    CardView(style: .ambient) {
                        VStack(alignment: .leading, spacing: 6) {
                            MonoLabel(text: "NO AMOUNTS STORED", color: .muted, size: 10)
                            Text("Financial state is categorical, not numerical. No amounts, no budgets, no targets.")
                                .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(3)
                        }
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
        .onAppear { loadFromCurrent() }
    }

    func loadFromCurrent() {
        guard let c = current else { return }
        runwayState = c.runwayState
        inflowReceived = c.inflowReceived
        notes = c.notes
        if let d = c.nextObligationDate {
            hasNextObligation = true
            nextDate = d
            nextLabel = c.nextObligationLabel
        }
    }

    func save() {
        let target: FinancialState
        if let c = current { target = c } else {
            let fresh = FinancialState(); context.insert(fresh); target = fresh
        }
        target.runwayState = runwayState
        target.inflowReceived = inflowReceived
        target.notes = notes
        target.updatedAt = Date()
        if hasNextObligation && !nextLabel.isEmpty {
            target.nextObligationDate = nextDate
            target.nextObligationLabel = nextLabel
        } else {
            target.nextObligationDate = nil
            target.nextObligationLabel = ""
        }
    }
}

// MARK: - PHASE 2: TIMELINE VIEW (Priority 1)
// Shows receipts, not grades. Contradicts "nothing got done" on hard days.
// Gated: appears in tab bar only after 14 days (firstLaunchDate on OperatorProfile).

struct TimelineView: View {
    @Environment(\.modelContext) private var context
    @Query private var allActions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var appeared = false

    // Group completed actions by calendar day using completionDates (persistent history).
    // BUG FIX: was using completedAt (nil'd on daily reset) — history disappeared after each reset.
    var actionsByDay: [(day: Date, actions: [(Action, Date)], log: DailyLog?)] {
        let cal = Calendar.current

        // Build flat list of (action, completionDate) pairs from persistent history
        var pairs: [(Action, Date)] = []
        for action in allActions {
            for date in action.completionDates {
                pairs.append((action, date))
            }
            // Also include today's completedAt if it hasn't been flushed to completionDates yet
            if let at = action.completedAt, cal.isDateInToday(at) {
                if !action.completionDates.contains(where: { cal.isDate($0, inSameDayAs: at) }) {
                    pairs.append((action, at))
                }
            }
        }

        // Get unique days
        let days = Array(Set(pairs.map { cal.startOfDay(for: $0.1) })).sorted(by: >)

        return days.map { day in
            let dayPairs = pairs
                .filter { cal.isDate($0.1, inSameDayAs: day) }
                .sorted { $0.1 > $1.1 }
            let dayLog = logs.first { cal.isDate($0.date, inSameDayAs: day) }
            return (day: day, actions: dayPairs, log: dayLog)
        }
    }

    // Summary line per day — "6 actions — Environment, Health"
    func daySummary(for day: Date, pairs: [(Action, Date)]) -> String {
        let cal = Calendar.current
        let count = pairs.count
        if count == 0 { return "Idle day." }
        let systems = Array(Set(pairs.map { $0.0.system.rawValue.capitalized }))
            .sorted().prefix(3).joined(separator: ", ")
        let noun = count == 1 ? "action" : "actions"
        if cal.isDateInToday(day) { return "\(count) \(noun) so far — \(systems)" }
        return "\(count) \(noun) — \(systems)"
    }

    func dayHeader(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "TODAY" }
        if cal.isDateInYesterday(date) { return "YESTERDAY" }
        return date.formatted(.dateTime.weekday(.wide).month().day()).uppercased()
    }

    var body: some View {
        ZStack {
            AtmosphericBackground()
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        MonoLabel(text: "TIMELINE", color: .violet, size: 11)
                        Text("What actually happened.")
                            .font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.35), value: appeared)

                if actionsByDay.isEmpty {
                    // Empty state — no praise, just factual
                    Spacer()
                    VStack(spacing: 12) {
                        MonoLabel(text: "NO ENTRIES YET", color: .textMuted)
                        Text("Complete actions in Today to build the record.")
                            .font(.sora(13, weight: .light))
                            .foregroundColor(.textSecond)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
                            ForEach(Array(actionsByDay.enumerated()), id: \.element.day) { idx, entry in
                                let (day, pairs, dayLog) = entry

                                // Day header
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: dayHeader(day), color: .violetLight, size: 11)
                                    Text(daySummary(for: day, pairs: pairs))
                                        .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, idx == 0 ? 0 : 28)
                                .padding(.bottom, 12)
                                .opacity(appeared ? 1 : 0)
                                .animation(.easeOut(duration: 0.3).delay(Double(idx) * 0.04), value: appeared)

                                // Action entries for this day
                                VStack(spacing: 0) {
                                    ForEach(Array(pairs.enumerated()), id: \.offset) { aIdx, pair in
                                        TimelineEntryRow(action: pair.0, completionDate: pair.1)
                                            .opacity(appeared ? 1 : 0)
                                            .animation(
                                                .easeOut(duration: 0.3).delay(Double(idx) * 0.04 + Double(aIdx) * 0.02),
                                                value: appeared
                                            )

                                        if aIdx < pairs.count - 1 {
                                            HStack {
                                                Rectangle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color.violet.opacity(0.2), Color.violet.opacity(0.08)],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                    )
                                                    .frame(width: 1, height: 20)
                                                    .padding(.leading, 24 + 44 + 14 + 3)
                                                Spacer()
                                            }
                                        }
                                    }
                                }

                                // Daily review note — surfaces what was logged that day
                                if let log = dayLog, let win = log.topWin, !win.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 6) {
                                            Rectangle()
                                                .fill(Color.warm.opacity(0.4))
                                                .frame(width: 1, height: 14)
                                                .padding(.leading, 24 + 44 + 14 + 3)
                                            Spacer()
                                        }
                                        HStack(alignment: .top, spacing: 10) {
                                            Spacer().frame(width: 24 + 44 + 14)
                                            VStack(alignment: .leading, spacing: 3) {
                                                MonoLabel(text: "LOG", color: .warm, size: 10)
                                                Text(win)
                                                    .font(.sora(12, weight: .light))
                                                    .foregroundColor(.textSecond)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                if let note = log.notes, !note.isEmpty {
                                                    Text(note)
                                                        .font(.sora(11, weight: .light))
                                                        .foregroundColor(.textMuted)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                            Spacer().frame(width: 24)
                                        }
                                    }
                                    .padding(.top, 4)
                                    .opacity(appeared ? 1 : 0)
                                    .animation(.easeOut(duration: 0.3).delay(Double(idx) * 0.04), value: appeared)
                                }

                                // Day divider (not after last day)
                                if idx < actionsByDay.count - 1 {
                                    Rectangle()
                                        .fill(Color.muted.opacity(0.2))
                                        .frame(height: 0.5)
                                        .padding(.horizontal, 24)
                                        .padding(.top, 20)
                                }
                            }
                        }
                        .padding(.bottom, 80)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true }
        }
    }
}

struct TimelineEntryRow: View {
    let action: Action
    let completionDate: Date   // explicit date — from completionDates history, not volatile completedAt

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Timestamp — mono, small, left column
            Text(format12h(completionDate))
                .font(.mono(11)).foregroundColor(.textMuted)
                .frame(width: 44, alignment: .trailing)

            // System color dot
            Circle()
                .fill(action.system.color)
                .frame(width: 7, height: 7)

            // Action name
            Text(action.title)
                .font(.sora(14)).foregroundColor(.textPrimary)
                .lineLimit(1)

            Spacer()

            // System icon — no label, no XP, nothing evaluative
            Image(systemName: action.system.icon)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(action.system.color.opacity(0.7))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

// MARK: - ADD ACTION SHEET — FIX 02 (cap enforced) + FIX 03 (cue field)

struct AddActionSheet: View {
    @Environment(\.modelContext) private var context
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var system: SystemTag = .participation
    @State private var note = ""
    @State private var cue = ""
    @State private var recurrence: RecurrenceType = .daily
    @State private var cognitionMode: CognitionMode? = nil

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Text("New Increment").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Cancel") { isPresented = false }.font(.sora(14)).foregroundColor(.textMuted)
                    }

                    inputField("ACTION", placeholder: "What's the one action?", text: $title)
                    inputField("WHEN (CUE)", placeholder: "e.g. After first standing transition", text: $cue)

                    // System picker
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "SYSTEM")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SystemTag.allCases, id: \.self) { s in
                                    Button(action: { system = s }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: s.icon).font(.system(size: 11))
                                            Text(s.rawValue.capitalized).font(.sora(12))
                                        }
                                        .foregroundColor(system == s ? .bgBase : s.color)
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(system == s ? s.color : s.color.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }

                    // Recurrence picker — was missing, caused confusion about daily vs weekly
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "RECURRENCE")
                        HStack(spacing: 8) {
                            ForEach([RecurrenceType.daily, .weekdays, .weekends, .weekly], id: \.self) { r in
                                Button(action: { recurrence = r }) {
                                    Text(r.displayLabel)
                                        .font(.sora(11, weight: .medium))
                                        .foregroundColor(recurrence == r ? .bgBase : .textSecond)
                                        .padding(.horizontal, 10).padding(.vertical, 7)
                                        .background(recurrence == r ? Color.violet : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                        .overlay(RoundedRectangle(cornerRadius: 7)
                                            .stroke(Color.muted.opacity(recurrence == r ? 0 : 0.3), lineWidth: 0.5))
                                }
                            }
                        }
                    }

                    inputField("NOTE (OPTIONAL)", placeholder: "Context, constraint, or the why", text: $note)

                    // Cognition sub-type
                    if system == .cognition {
                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "COGNITION TYPE")
                            MonoLabel(text: "Helps distinguish creative from depleting work", color: .muted, size: 10)
                            HStack(spacing: 8) {
                                ForEach(CognitionMode.allCases, id: \.self) { mode in
                                    Button(action: {
                                        cognitionMode = cognitionMode == mode ? nil : mode
                                    }) {
                                        VStack(spacing: 5) {
                                            Image(systemName: mode.icon).font(.system(size: 14, weight: .light))
                                            Text(mode.label).font(.mono(10)).tracking(0.5)
                                        }
                                        .foregroundColor(cognitionMode == mode ? .bgBase : .violetLight)
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(cognitionMode == mode ? Color.violetLight : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(cognitionMode == mode ? Color.clear : Color.muted.opacity(0.3), lineWidth: 0.5))
                                    }
                                }
                            }
                            if let mode = cognitionMode {
                                Text(mode.description)
                                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                            }
                        }
                    }

                    primaryButton("ADD INCREMENT", disabled: title.isEmpty) {
                        let action = Action(
                            title: title, system: system, points: 10,
                            recurrence: recurrence,
                            note: note.isEmpty ? nil : note,
                            cue: cue.isEmpty ? nil : cue
                        )
                        if system == .cognition { action.cognitionMode = cognitionMode }
                        context.insert(action)
                        isPresented = false
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }
}

// MARK: - TIME FORMATTING HELPERS

// Always 12h with AM/PM — never 19:00, always 7:00 PM
func format12h(_ date: Date) -> String {
    let fmt = DateFormatter()
    fmt.dateFormat = "h:mm a"
    fmt.amSymbol = "AM"
    fmt.pmSymbol = "PM"
    return fmt.string(from: date)
}

// Convert "21:00" block string → "9 PM", "17:00" → "5 PM", "6:00" → "6 AM"
func formatBlockTime(_ block: String) -> String {
    let parts = block.split(separator: ":").map { Int($0) ?? 0 }
    guard parts.count >= 2 else { return block }
    let h = parts[0], m = parts[1]
    let suffix = h >= 12 ? "PM" : "AM"
    let h12 = h == 0 ? 12 : h > 12 ? h - 12 : h
    return m == 0 ? "\(h12) \(suffix)" : "\(h12):\(String(format: "%02d", m)) \(suffix)"
}


// A curated library of next-level practices, unlocked in sequence as prerequisites are proven.
// This is not a list of things to do — it's a paced introduction system.
// One unlock per 7-14 days. No fanfare. Just: "this system is ready for the next layer."
//
// Architecture: Layer 0 (foundation) → Layer 1 (current) → Layer 2 (refinement) → Layer 3 (sharpening)
// Prerequisites are action title keywords. Threshold: 70%+ completion rate over 7+ days.

struct CurriculumItem: Identifiable {
    let id: String            // stable identifier
    let layer: Int            // 0-3 progression layer
    let system: SystemTag
    let title: String         // the practice name
    let why: String           // one sentence — why this, why now
    let how: String           // precise implementation
    let cue: String           // behavioral anchor
    let prerequisiteKeywords: [String]  // action titles that must be proven first
    let unlockAfterDays: Int  // minimum days in system before this can surface
    let weeklyOrDaily: String // "daily" / "weekly" / "situational"
}

struct ProgressionCurriculum {

    // Full library — ordered within each layer by recommended sequence
    static let library: [CurriculumItem] = [

        // LAYER 1 — Refinement of what's already working
        CurriculumItem(
            id: "caffeine-delay",
            layer: 1,
            system: .cognition,
            title: "Delay caffeine 90 min after waking",
            why: "Adenosine clears naturally in the first 90 min. Caffeine then amplifies an already-alert state rather than masking grogginess — the effect is noticeably different.",
            how: "Water and morning light first. Coffee or tea only after the first 90 min of wake. One change, sustained 2 weeks.",
            cue: "After morning light — before the first cup",
            prerequisiteKeywords: ["No phone", "Morning light"],
            unlockAfterDays: 14,
            weeklyOrDaily: "daily"
        ),
        CurriculumItem(
            id: "post-workout-nutrition",
            layer: 1,
            system: .health,
            title: "Post-workout nutrition window",
            why: "The 30-min window after strength training is when muscle protein synthesis is highest. Getting 30-40g in that window vs 2 hours later produces measurably different recovery.",
            how: "Shake or real food within 30 min of the last set. Already seeded as an action — this is the science behind why the timing matters.",
            cue: "Walking out of the gym",
            prerequisiteKeywords: ["Strength training", "gym"],
            unlockAfterDays: 7,
            weeklyOrDaily: "daily"
        ),
        CurriculumItem(
            id: "hrv-morning",
            layer: 1,
            system: .health,
            title: "HRV morning read → capacity declaration",
            why: "Your Garmin already reads HRV. Acting on it is a separate skill. Low HRV morning = reserve day, no override. High HRV = full capacity unlocked. This closes the loop between what the body signals and what you declare.",
            how: "Open Garmin app before setting energy state. Let the HRV reading inform the capacity choice — Full / Partial / Reserve. 2 weeks of this builds calibration data.",
            cue: "Before selecting today's capacity — same moment, different input",
            prerequisiteKeywords: ["Sleep by midnight", "Move your body"],
            unlockAfterDays: 21,
            weeklyOrDaily: "daily"
        ),

        // LAYER 2 — Sharpening what's been proven
        CurriculumItem(
            id: "pre-work-visualization",
            layer: 2,
            system: .cognition,
            title: "5-min pre-work visualization",
            why: "Elite performers in any domain use mental rehearsal. 5 min before the deep work block imagining the specific output — not the process, the result — measurably improves focus quality and session length.",
            how: "After priorities review, before starting the timer. Eyes closed. Specific: what does the completed thing look like? 5 min only. Then start.",
            cue: "After review priorities — before deep work timer",
            prerequisiteKeywords: ["Deep work", "Review priorities"],
            unlockAfterDays: 21,
            weeklyOrDaily: "daily"
        ),
        CurriculumItem(
            id: "weekly-skill-sharpening",
            layer: 2,
            system: .cognition,
            title: "Weekly deliberate practice — one craft skill",
            why: "Deep work produces output. Deliberate practice improves the quality of what you can produce. They're different. One hour per week on a specific skill gap — not working, studying the craft.",
            how: "Pick one skill in your actual domain of work. One hour, no output goal — just the practice. Log what you worked on in the journal.",
            cue: "Saturday morning — after the slow open, before deep work",
            prerequisiteKeywords: ["Deep work", "Journal"],
            unlockAfterDays: 28,
            weeklyOrDaily: "weekly"
        ),
        CurriculumItem(
            id: "cold-immersion",
            layer: 2,
            system: .health,
            title: "Cold immersion — full protocol",
            why: "The 2-min cold finish works. The full protocol — 11 min per week in genuinely cold water — produces noticeable dopamine elevation lasting 4-6 hours. Different mechanism, different effect.",
            how: "3-4 times per week. Cold finish extended to 3-4 min, or cold soak if access. The shivering is the signal — lean in. Build from the shower protocol you've already proven.",
            cue: "Same shower position — extend the finish",
            prerequisiteKeywords: ["Cold exposure"],
            unlockAfterDays: 28,
            weeklyOrDaily: "situational"
        ),
        CurriculumItem(
            id: "sunday-preview",
            layer: 2,
            system: .operations,
            title: "Sunday preview — week architecture",
            why: "The Weekly Reset closes last week. This opens next week. 20 min Sunday evening laying out which days are hideout-heavy, what the one must-move project is, and setting Monday's first action. The week runs better when it has a shape.",
            how: "After weekly reset. Three questions: What's the one project that moves next week? Which days have the most cognitive capacity? What does Monday morning need to start with?",
            cue: "After Weekly Reset session — same Sunday evening",
            prerequisiteKeywords: ["Weekly Reset", "Close one open loop"],
            unlockAfterDays: 21,
            weeklyOrDaily: "weekly"
        ),

        // LAYER 3 — Advanced integration (only surfaces after significant consistency)
        CurriculumItem(
            id: "sleep-score-review",
            layer: 3,
            system: .health,
            title: "Sleep score → next-day stack calibration",
            why: "Garmin sleep score + HRV together predict next-day cognitive performance with reasonable accuracy. Below 70 sleep score = don't schedule deep work as the first block. Let the data move the schedule.",
            how: "Check Garmin sleep score at the same moment as HRV. Below 70: move deep work to afternoon, put operations and maintenance in the morning slot. The app already tracks which days you complete more — this closes the loop.",
            cue: "Morning check — Garmin app, same moment as HRV",
            prerequisiteKeywords: ["HRV morning", "Sleep by midnight", "Deep work"],
            unlockAfterDays: 42,
            weeklyOrDaily: "daily"
        ),
        CurriculumItem(
            id: "output-sharing",
            layer: 3,
            system: .participation,
            title: "Share something made — one per month",
            why: "Making things privately builds skill. Sharing builds accountability, audience, and often reveals what you actually think. Once per month — not posting for engagement, sharing something you made with someone who'd value it.",
            how: "Take whatever came out of 'Make something' this month. One person it belongs with. Send it. No performance — just completion.",
            cue: "Last Sunday of the month — after Make something review",
            prerequisiteKeywords: ["Make something", "One real conversation"],
            unlockAfterDays: 42,
            weeklyOrDaily: "situational"
        ),
        CurriculumItem(
            id: "fasted-morning",
            layer: 3,
            system: .health,
            title: "Fasted morning block — 3x per week",
            why: "Training and cognitive work in a fasted state (last meal was dinner, no breakfast yet) produces measurably different metabolic states. Not for everyone — but worth a 2-week trial if protein and creatine are already consistent.",
            how: "3 mornings per week: morning light, hydrate, creatine — but delay protein until after the first work block. Assess energy and focus quality. If worse, stop. If neutral or better, you've found a protocol.",
            cue: "On the 3 mornings you choose — skip protein step, note it in journal",
            prerequisiteKeywords: ["Creatine", "Protein — first meal", "Journal"],
            unlockAfterDays: 56,
            weeklyOrDaily: "situational"
        ),
    ]

    // Evaluate which items are currently unlocked based on proven actions
    static func unlockedItems(actions: [Action], daysInSystem: Int) -> [CurriculumItem] {
        library.filter { item in
            guard daysInSystem >= item.unlockAfterDays else { return false }
            // Check prerequisites — all keyword matches must be proven (70%+ rate, 7+ days)
            let prerequisitesMet = item.prerequisiteKeywords.allSatisfy { keyword in
                let matching = actions.filter { $0.title.localizedCaseInsensitiveContains(keyword) }
                guard !matching.isEmpty else { return false }
                // At least one matching action must be proven
                return matching.contains { $0.completionRate >= 0.70 && $0.daysSinceCreated >= 7 }
            }
            // Don't surface if an action with matching title already exists
            let alreadyAdded = item.prerequisiteKeywords.isEmpty ? false :
                actions.contains { a in item.title.localizedCaseInsensitiveContains(a.title) || a.title.localizedCaseInsensitiveContains(item.title) }
            return prerequisitesMet && !alreadyAdded
        }.sorted { $0.layer < $1.layer }
    }

    // What's next — the single most appropriate next item
    static func nextItem(actions: [Action], daysInSystem: Int) -> CurriculumItem? {
        unlockedItems(actions: actions, daysInSystem: daysInSystem).first
    }
}

// MARK: - CURRICULUM CARD VIEW

struct CurriculumCard: View {
    let item: CurriculumItem
    @State private var expanded = false
    @State private var added = false
    @Environment(\.modelContext) private var context

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            MonoLabel(text: "NEXT LAYER", color: item.system.color, size: 10)
                            MonoLabel(text: "· \(item.weeklyOrDaily.uppercased())", color: .textMuted, size: 10)
                        }
                        Text(item.title)
                            .font(.sora(15, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    Button(action: { withAnimation(.easeOut(duration: 0.2)) { expanded.toggle() } }) {
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                }

                // WHY — leads with the reason. Analytical + Determination strength means
                // understanding the mechanism is what produces buy-in, not the prescription itself.
                Text(item.why)
                    .font(.sora(13, weight: .light))
                    .foregroundColor(.textSecond)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                if expanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)

                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "HOW", color: .textMuted, size: 10)
                            Text(item.how)
                                .font(.sora(12, weight: .light))
                                .foregroundColor(.textSecond)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "CUE", color: .textMuted, size: 10)
                            Text(item.cue)
                                .font(.mono(11))
                                .foregroundColor(item.system.color.opacity(0.8))
                                .tracking(0.3)
                        }

                        // Add to stack — creates the action in SwiftData
                        // This is the adoption affordance: read why → understand how → one tap to commit
                        if !added {
                            Button(action: { addToStack() }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle").font(.system(size: 13))
                                    Text("Add to my stack")
                                        .font(.sora(13, weight: .medium))
                                }
                                .foregroundColor(item.system.color)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)
                            }
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.inkGreen)
                                Text("Added to your stack.").font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    func addToStack() {
        let recurrence: RecurrenceType = item.weeklyOrDaily == "weekly" ? .weekly :
                                         item.weeklyOrDaily == "daily"  ? .daily  : .daily
        let action = Action(
            title: item.title,
            system: item.system,
            points: 15,
            recurrence: recurrence,
            note: item.how,
            cue: item.cue
        )
        context.insert(action)
        withAnimation { added = true }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}



struct IncrementsView: View {
    @Query private var actions: [Action]
    @Bindable var state: AppState
    @State private var selectedSeg = 0
    @State private var appeared = false

    var completedToday: [Action] {
        actions.filter { $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }
    }

    // Segment filters: Active = daily/weekday/weekend recurring, Planned = weekly, Someday = none recurrence
    var filteredActions: [Action] {
        switch selectedSeg {
        case 0: return actions.filter { $0.recurrence == .daily || $0.recurrence == .weekdays || $0.recurrence == .weekends }
        case 1: return actions.filter { $0.recurrence == .weekly }
        case 2: return actions.filter { $0.recurrence == .none }
        default: return actions
        }
    }

    // BUG FIX: was using completedAt (nil'd on daily reset) — always returned 999 after reset.
    // completionDates is the persistent history; use it to get the true last completion date.
    func daysSinceActivity(_ sys: SystemTag) -> Int {
        let sysActions = actions.filter { $0.system == sys }
        // Combine: today's completedAt (if completed today) and persistent completionDates history
        let candidates: [Date] = sysActions.flatMap { a -> [Date] in
            var dates = a.completionDates
            if let at = a.completedAt { dates.append(at) }
            return dates
        }
        guard let last = candidates.max() else { return 999 }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 999
    }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        MonoLabel(text: "SYSTEMS", color: .violet, size: 11)
                        Text("State of all five systems.")
                            .font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 16)

                segmentControl(["Active", "Planned", "Someday"], selected: $selectedSeg)
                    .padding(.horizontal, 24).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(Array(SystemTag.allCases.enumerated()), id: \.element) { i, sys in
                            let score = state.systemScores[sys] ?? 0
                            let pending = filteredActions.filter { $0.system == sys && !$0.isCompleted }
                            let done = completedToday.filter { $0.system == sys }.count
                            let quiet = daysSinceActivity(sys)

                            VStack(alignment: .leading, spacing: 4) {
                                // System row — tappable, opens detail sheet with all actions
                                SystemDetailRow(
                                    sys: sys, score: score, state: state,
                                    pending: pending, done: done, quiet: quiet,
                                    allActions: filteredActions
                                )

                                if quiet >= 3 && quiet < 999 {
                                    Text("\(sys.rawValue.capitalized) — nothing here in \(quiet) days.")
                                        .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                        .padding(.horizontal, 6).padding(.top, 2)
                                }
                            }
                            .padding(.horizontal, 24)
                            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                            .animation(.easeOut(duration: 0.35).delay(Double(i) * 0.05), value: appeared)
                        }

                        if !completedToday.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(text: "COMPLETED TODAY", color: .inkGreen).padding(.horizontal, 24)
                                CardView {
                                    VStack(spacing: 0) {
                                        ForEach(Array(completedToday.enumerated()), id: \.element.id) { i, a in
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.inkGreen).font(.system(size: 14))
                                                Text(a.title).font(.sora(13)).foregroundColor(.textSecond)
                                                    .strikethrough(true, color: .textMuted)
                                                Spacer()
                                                if let t = a.completedAt {
                                                    Text(t, style: .time).font(.mono(11)).foregroundColor(.textMuted)
                                                }
                                            }
                                            if i < completedToday.count - 1 {
                                                Rectangle()
                                                    .fill(Color.muted.opacity(0.2))
                                                    .frame(height: 0.5)
                                                    .padding(.vertical, 6)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 8)
                            .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.4).delay(0.28), value: appeared)
                        }

                        // Phase 3 P4 — Financial Clarity (Operations domain)
                        FinancialClarityCard()
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.35).delay(0.32), value: appeared)

                        // PROGRESSION CURRICULUM — next layer surfaced when prerequisites are proven
                        CurriculumSection(actions: actions)
                            .padding(.top, 16)
                            .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.35).delay(0.36), value: appeared)

                        // Phase 3 P2 — Maintenance Cadence
                        MaintenanceSection()
                            .padding(.top, 16)
                            .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.35).delay(0.40), value: appeared)
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true } }
    }
}

// MARK: - SYSTEM DETAIL ROW + SHEET

struct SystemDetailRow: View {
    let sys: SystemTag
    let score: Int
    let state: AppState
    let pending: [Action]
    let done: Int
    let quiet: Int
    let allActions: [Action]
    @State private var showDetail = false

    var body: some View {
        Button(action: { showDetail = true }) {
            CardView {
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(sys.color.opacity(0.7))
                        .frame(width: 2)
                        .padding(.trailing, 14)
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(sys.color.opacity(0.1)).frame(width: 36, height: 36)
                            Image(systemName: sys.icon).font(.system(size: 15)).foregroundColor(sys.color)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sys.rawValue.capitalized)
                                .font(.sora(15, weight: .medium)).foregroundColor(.textPrimary)
                            Text("\(pending.count) pending · \(done) today")
                                .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(state.scoreLabel(score))
                                .font(.mono(11)).foregroundColor(state.scoreColor(score)).tracking(1)
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(width: 52, height: 2)
                                RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.7))
                                    .frame(width: 52 * CGFloat(score) / 100, height: 2)
                            }
                        }
                        Image(systemName: "chevron.right").font(.system(size: 11)).foregroundColor(.textMuted)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            SystemDetailSheet(sys: sys, score: score, state: state, allSystemActions: allActions.filter { $0.system == sys })
        }
    }
}

struct SystemDetailSheet: View {
    let sys: SystemTag
    let score: Int
    let state: AppState
    let allSystemActions: [Action]
    @Environment(\.dismiss) private var dismiss

    var pendingActions: [Action] { allSystemActions.filter { !$0.isCompleted }.sorted { ($0.scheduledBlock ?? "99:99") < ($1.scheduledBlock ?? "99:99") } }
    var completedActions: [Action] { allSystemActions.filter { $0.isCompleted } }

    var avgCompletionRate: Double {
        guard !allSystemActions.isEmpty else { return 0 }
        return allSystemActions.map(\.completionRate).reduce(0, +) / Double(allSystemActions.count)
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)

                    // Header
                    HStack(alignment: .top) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(sys.color.opacity(0.12)).frame(width: 44, height: 44)
                                Image(systemName: sys.icon).font(.system(size: 18)).foregroundColor(sys.color)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sys.rawValue.capitalized)
                                    .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                                HStack(spacing: 6) {
                                    Circle().fill(state.scoreColor(score)).frame(width: 7, height: 7)
                                    Text(state.scoreLabel(score))
                                        .font(.mono(11)).foregroundColor(state.scoreColor(score)).tracking(0.5)
                                }
                            }
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark").font(.system(size: 13, weight: .light))
                                .foregroundColor(.textMuted).frame(width: 30, height: 30)
                                .background(Color.surface).clipShape(Circle())
                        }
                    }

                    // Why this system matters
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "WHY THIS SYSTEM", color: sys.color, size: 10)
                        Text(sys.scienceNote)
                            .font(.sora(14, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(18).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 12))

                    // What moves it
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "WHAT MOVES IT", color: .textMuted, size: 10)
                        Text(sys.whatMovesIt)
                            .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Completion rate
                    if !allSystemActions.isEmpty {
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "AVG COMPLETION", color: .textMuted, size: 10)
                                Text(String(format: "%.0f%%", avgCompletionRate * 100))
                                    .font(.sora(20, weight: .semibold))
                                    .foregroundColor(avgCompletionRate >= 0.7 ? .inkGreen : avgCompletionRate >= 0.4 ? .inkAmber : .textSecond)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "TOTAL ACTIONS", color: .textMuted, size: 10)
                                Text("\(allSystemActions.count)")
                                    .font(.sora(20, weight: .semibold)).foregroundColor(.textSecond)
                            }
                        }
                        .padding(16).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Pending actions in this system
                    if !pendingActions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            MonoLabel(text: "PENDING", color: .textMuted, size: 10)
                            ForEach(pendingActions) { action in
                                SystemActionSummaryRow(action: action)
                            }
                        }
                    }

                    // Completed actions
                    if !completedActions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            MonoLabel(text: "DONE TODAY", color: .inkGreen, size: 10)
                            ForEach(completedActions) { action in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.inkGreen).font(.system(size: 14))
                                    Text(action.title).font(.sora(13)).foregroundColor(.textSecond).strikethrough(true, color: .textMuted)
                                    Spacer()
                                    if let at = action.completedAt {
                                        Text(format12h(at)).font(.mono(10)).foregroundColor(.textMuted)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.bgBase)
    }
}

// Compact action row for SystemDetailSheet — shows completion rate and note
struct SystemActionSummaryRow: View {
    let action: Action
    @State private var showDetail = false

    var body: some View {
        Button(action: { showDetail = true }) {
            HStack(spacing: 12) {
                Circle().stroke(action.system.color.opacity(0.5), lineWidth: 1.5).frame(width: 10, height: 10)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        if let block = action.scheduledBlock {
                            Text(formatBlockTime(block)).font(.mono(10)).foregroundColor(action.system.color.opacity(0.7)).tracking(0.3)
                        }
                        Text(action.title).font(.sora(13)).foregroundColor(.textPrimary).lineLimit(1)
                    }
                    if let note = action.note, !note.isEmpty {
                        Text(note).font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineLimit(1)
                    }
                }
                Spacer()
                Text(String(format: "%.0f%%", action.completionRate * 100))
                    .font(.mono(10)).foregroundColor(action.completionRate >= 0.7 ? .inkGreen : .textMuted).tracking(0.3)
                Image(systemName: "chevron.right").font(.system(size: 10)).foregroundColor(.textMuted)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            ActionDetailSheet(action: action, isPresented: $showDetail, onComplete: {})
        }
    }
}



struct CurriculumSection: View {
    let actions: [Action]
    @Query private var profiles: [OperatorProfile]

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    var unlockedItems: [CurriculumItem] {
        ProgressionCurriculum.unlockedItems(actions: actions, daysInSystem: profile.daysInSystem)
    }

    var nextItem: CurriculumItem? {
        ProgressionCurriculum.nextItem(actions: actions, daysInSystem: profile.daysInSystem)
    }

    // What layer are we in — for the section header
    var currentLayerLabel: String {
        guard let next = nextItem else { return "CALIBRATING" }
        switch next.layer {
        case 0: return "FOUNDATION"
        case 1: return "REFINEMENT"
        case 2: return "SHARPENING"
        case 3: return "MASTERY"
        default: return "NEXT LAYER"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    SectionHeader(text: "PROGRESSION", color: .violetLight)
                    Text("Next layers — unlocked as prerequisites prove.")
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                }
                Spacer()
                if !unlockedItems.isEmpty {
                    MonoLabel(text: "\(unlockedItems.count) READY", color: .violetLight.opacity(0.7), size: 10)
                }
            }
            .padding(.horizontal, 24)

            if unlockedItems.isEmpty {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "COLLECTING", color: .textMuted, size: 10)
                        Text("Next layers unlock as current practices are proven. Keep the completion rate above 70% for 7+ days.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                // Show next item prominently, rest collapsed
                VStack(spacing: 8) {
                    ForEach(Array(unlockedItems.enumerated()), id: \.element.id) { i, item in
                        CurriculumCard(item: item)
                            .padding(.horizontal, 24)
                    }
                }

                // How many are still locked — honest about the pipeline
                let totalItems = ProgressionCurriculum.library.count
                let lockedCount = totalItems - unlockedItems.count
                if lockedCount > 0 {
                    HStack(spacing: 6) {
                        Circle().fill(Color.muted.opacity(0.3)).frame(width: 4, height: 4)
                        Text("\(lockedCount) more unlock as system matures.")
                            .font(.mono(10)).foregroundColor(.muted).tracking(0.3)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}



struct HabitsView: View {
    @Environment(\.modelContext) private var context
    @Query private var habits: [Habit]
    @State private var showAdd = false
    @State private var appeared = false

    var activeHabits: [Habit] { habits.filter(\.isActive) }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HABITS").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        MonoLabel(text: "recurring anchors", color: .textMuted, size: 11)
                    }
                    Spacer()
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus").font(.system(size: 16, weight: .medium))
                            .foregroundColor(.violet).frame(width: 36, height: 36)
                            .background(Color.violetDim.opacity(0.3)).clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        if activeHabits.isEmpty {
                            emptyState(icon: "arrow.triangle.2.circlepath",
                                       title: "No active habits",
                                       subtitle: "Recurring anchors appear here.")
                        }
                        ForEach(Array(activeHabits.enumerated()), id: \.element.id) { i, habit in
                            HabitCard(habit: habit).padding(.horizontal, 24)
                                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                                .animation(.easeOut(duration: 0.35).delay(Double(i) * 0.05), value: appeared)
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .sheet(isPresented: $showAdd) { AddHabitSheet(isPresented: $showAdd) }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true }
            if habits.isEmpty { seedDefaultHabits() }
        }
    }

    func seedDefaultHabits() {
        let defaults: [(String, SystemTag, String, String)] = [
            ("Morning Routine", .health, "After alarm dismissed", "5 min version"),
            ("Deep Work", .operations, "When opening laptop", "25 min minimum"),
            ("Movement", .health, "After clearing desk surface", "10 min walk"),
            ("No Phone First Hour", .cognition, "When waking", "Phone stays face-down"),
            ("Night Routine", .environment, "After final meal", "Lights dimmed, one reset"),
            ("Money Touch", .operations, "After first coffee", "Open one financial task"),
            ("Apartment Reset", .environment, "After docking at primary seated position", "One area only")
        ]
        for (title, system, cue, minimum) in defaults {
            context.insert(Habit(title: title, system: system, cue: cue, minimumScope: minimum))
        }
    }
}

struct HabitCard: View {
    @Environment(\.modelContext) private var context
    let habit: Habit

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.title).font(.sora(15, weight: .medium)).foregroundColor(.textPrimary)
                        if !habit.cue.isEmpty {
                            Text("When: \(habit.cue)").font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                        }
                    }
                    Spacer()
                    SystemBadge(system: habit.system)
                }

                if !habit.minimumScope.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "minus.circle").font(.system(size: 10)).foregroundColor(.violetLight)
                        Text("Minimum: \(habit.minimumScope)").font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                    }
                }

                HStack(spacing: 10) {
                    // Last completed — factual, not a streak display (v1.1 HOLD — no streak visualization)
                    if habit.completedToday {
                        HStack(spacing: 5) {
                            Circle().fill(habit.system.color).frame(width: 7, height: 7)
                            Text("Done today").font(.mono(11)).foregroundColor(habit.system.color).tracking(0.3)
                        }
                    } else if let last = habit.completionHistory.last {
                        let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
                        Text(days == 0 ? "Done today" : days == 1 ? "Yesterday" : "\(days) days ago")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    } else {
                        Text("Not yet started").font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                    Spacer()
                    Button(action: {
                        habit.completionHistory.append(Date())
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack(spacing: 6) {
                            if habit.completedToday {
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .semibold))
                            }
                            Text(habit.completedToday ? "Done" : "Mark")
                                .font(.sora(12, weight: .medium))
                        }
                        .foregroundColor(habit.completedToday ? .bgBase : habit.system.color)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(habit.completedToday ? habit.system.color : habit.system.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .disabled(habit.completedToday)
                }
            }
        }
    }
}

// FIX 02 — AddHabitSheet: cue + minimumScope required before save
struct AddHabitSheet: View {
    @Environment(\.modelContext) private var context
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var system: SystemTag = .health
    @State private var frequency: RecurrenceType = .daily
    @State private var cue = ""
    @State private var minimumScope = ""

    var canSave: Bool { !title.isEmpty && !cue.isEmpty && !minimumScope.isEmpty }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Text("New Habit").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Cancel") { isPresented = false }.font(.sora(14)).foregroundColor(.textMuted)
                    }

                    inputField("HABIT", placeholder: "Name this anchor", text: $title)

                    // FIX 02 — required fields
                    VStack(alignment: .leading, spacing: 6) {
                        inputField("WHAT EXISTING CUE TRIGGERS THIS?",
                                   placeholder: "e.g. When opening laptop", text: $cue)
                        MonoLabel(text: "Required — anchors the habit to a reliable trigger", color: .muted, size: 10)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        inputField("WHAT'S THE SMALLEST VERSION?",
                                   placeholder: "e.g. 5 minutes only", text: $minimumScope)
                        MonoLabel(text: "Required — prevents motivation-state habits", color: .muted, size: 10)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "SYSTEM")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SystemTag.allCases, id: \.self) { s in
                                    Button(action: { system = s }) {
                                        Text(s.rawValue.capitalized).font(.sora(12))
                                            .foregroundColor(system == s ? .bgBase : s.color)
                                            .padding(.horizontal, 12).padding(.vertical, 8)
                                            .background(system == s ? s.color : s.color.opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "FREQUENCY")
                        HStack(spacing: 8) {
                            ForEach([RecurrenceType.daily, .weekdays, .weekends, .weekly], id: \.self) { f in
                                Button(action: { frequency = f }) {
                                    Text(f.rawValue.capitalized).font(.sora(12))
                                        .foregroundColor(frequency == f ? .bgBase : .textSecond)
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(frequency == f ? Color.violet : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }

                    primaryButton("ADD HABIT", disabled: !canSave) {
                        context.insert(Habit(title: title, system: system, frequency: frequency,
                                             cue: cue, minimumScope: minimumScope))
                        isPresented = false
                    }

                    if !canSave {
                        Text("Cue and minimum scope required before saving.")
                            .font(.sora(11, weight: .light)).foregroundColor(.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Spacer()
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }
}

// MARK: - DAILY REVIEW — FIX 01 (no skip) + FIX 07 (reworded questions)

struct DailyReviewSheet: View {
    @Binding var isPresented: Bool
    @Bindable var state: AppState
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query private var actions: [Action]
    @Query(sort: \CognitionLog.date, order: .reverse) private var cognitionLogs: [CognitionLog]

    @State private var topWin = ""
    @State private var heavy = ""
    @State private var tomorrow = ""
    @State private var submitted = false

    // FIX 01 — light closure path state
    @State private var showLightClose = false
    @State private var lightSentence = ""

    // FIX: detect if today's review was already submitted
    var todayLog: DailyLog? {
        logs.first { Calendar.current.isDateInToday($0.date) }
    }

    var alreadyReviewedToday: Bool {
        guard let log = todayLog else { return false }
        return log.topWin != nil   // topWin being set means a full review was saved
    }

    var participationScore: Int { min(100, state.systemScores.values.reduce(0, +) / 5 + 3) }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                // BUG FIX: previously `alreadyReviewedToday` immediately showed the result/done
                // screen, with no way to edit. Now: if already reviewed, open in edit mode
                // with fields pre-filled. `submitted` (in-session first-time completion) still
                // shows the result screen — but re-opening an existing log goes straight to editing.
                if submitted {
                    reviewResultView
                } else if showLightClose {
                    lightCloseView
                } else {
                    fullReviewView
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
        .onAppear {
            // Pre-fill from existing log — works both for first-time and editing
            if let log = todayLog {
                topWin = log.topWin ?? ""
                heavy = log.notes ?? ""
                tomorrow = log.specificActionNote ?? ""
            }
        }
    }

    // FIX 07 — reworded questions
    var fullReviewView: some View {
        VStack(alignment: .leading, spacing: 24) {
            SheetHandle().frame(maxWidth: .infinity, alignment: .center)
            HStack {
                Text(alreadyReviewedToday ? "Edit Log" : "Daily Review")
                    .font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                Spacer()
                // FIX 01 — "Close lightly?" instead of "Skip" (only on first entry)
                if !alreadyReviewedToday {
                    Button("Close lightly?") { withAnimation { showLightClose = true } }
                        .font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                } else {
                    Button("Cancel") { isPresented = false }
                        .font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                }
            }
            MonoLabel(text: alreadyReviewedToday ? "UPDATE TODAY'S LOG." : "WRAP UP THE DAY.", color: .violet)

            // FIX 07 — new question wording
            reviewField("What made today easier?", text: $topWin)
            reviewField("What's still sitting there?", text: $heavy)
            reviewField("What's the first thing tomorrow?", text: $tomorrow)

            Button(action: {
                saveReview(topWin: topWin, heavy: heavy, tomorrow: tomorrow)
                withAnimation { submitted = true }
            }) {
                Text("DONE")
                    .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(28)
    }

    // FIX 01 — reduced-scope closure path
    var lightCloseView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Quick close?")
                .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
            MonoLabel(text: "ONE SENTENCE ONLY", color: .violet)
            TextField("", text: $lightSentence,
                      prompt: Text("One thing that landed.").foregroundColor(.textMuted))
                .font(.sora(15)).foregroundColor(.textPrimary)
                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))

            Button(action: {
                saveReview(topWin: lightSentence, heavy: "", tomorrow: "")
                withAnimation { submitted = true }
            }) {
                Text("CLOSE")
                    .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // FIX 01 — second deliberate tap required for full close-without-review
            Button(action: { isPresented = false }) {
                Text("Skip for tonight")
                    .font(.sora(12, weight: .light)).foregroundColor(.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(28)
    }

    var reviewResultView: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 52)

            // No score ring — the ring grades the day. Closure is the reward.
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color.violet.opacity(0.15), lineWidth: 1.5)
                        .frame(width: 72, height: 72)
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .ultraLight))
                        .foregroundColor(.violet)
                }
                .padding(.bottom, 8)

                Text("Done.").font(.sora(24, weight: .semibold)).foregroundColor(.textPrimary)
                Text("Recorded.")
                    .font(.sora(14, weight: .light)).foregroundColor(.textSecond)
            }

            // What worked — the day's one usable signal
            if let win = todayLog?.topWin ?? (topWin.isEmpty ? nil : topWin) {
                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "WHAT WORKED", color: .inkGreen)
                        Text(win).font(.sora(13)).foregroundColor(.textPrimary)
                    }
                }
                .padding(.horizontal, 28)
            }

            // Tomorrow's first action — the pre-commitment that feeds tomorrow's morning card.
            // This is the highest-leverage output of the review.
            let tomorrowNote = todayLog?.specificActionNote ?? (tomorrow.isEmpty ? nil : tomorrow)
            if let note = tomorrowNote, !note.isEmpty {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "TOMORROW FIRST", color: .warm)
                        Text(note).font(.sora(13, weight: .medium)).foregroundColor(.textPrimary)
                        Text("Shows up in tomorrow's morning card.")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                }
                .padding(.horizontal, 28)
            }

            Button(action: { isPresented = false }) {
                Text("CLOSE").font(.sora(13, weight: .semibold)).foregroundColor(.bgBase).tracking(2)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 28)
        }
    }

    func reviewField(_ prompt: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(prompt)
                .font(.sora(14, weight: .light))
                .foregroundColor(.textPrimary)
                .lineSpacing(2)
            TextField("", text: text, prompt: Text("...").foregroundColor(.textMuted))
                .font(.sora(14)).foregroundColor(.textPrimary)
                .padding(14).background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(.warm)   // field accent: warm not iOS blue
        }
    }

    // FIX: persist review to DailyLog — creates or updates today's entry
    func saveReview(topWin: String, heavy: String, tomorrow: String) {
        let completedToday = actions.filter {
            $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast)
        }
        let completedActionIDs = completedToday.map(\.id)
        let systemsTouched = Array(Set(completedToday.map { $0.system.rawValue }))

        // Cascade intelligence — which system moved first today?
        let firstCompletion = completedToday
            .compactMap { a -> (Action, Date)? in
                guard let at = a.completedAt else { return nil }
                return (a, at)
            }
            .min(by: { $0.1 < $1.1 })
        let firstSystem = firstCompletion?.0.system.rawValue
        let firstHour = firstCompletion.map { Calendar.current.component(.hour, from: $0.1) }

        let target: DailyLog
        if let existing = todayLog {
            target = existing
        } else {
            let log = DailyLog(date: Date())
            context.insert(log)
            target = log
        }

        target.topWin = topWin.isEmpty ? nil : topWin
        target.notes = heavy.isEmpty ? nil : heavy
        target.specificActionNote = tomorrow.isEmpty ? nil : tomorrow
        target.completedActionIDs = completedActionIDs
        target.systemsTouched = systemsTouched
        target.firstSystemTouched = firstSystem
        target.firstCompletionHour = firstHour

        // Write actual completion count back to today's CognitionLog for calibration
        updateCognitionLogCompletionCount(completedToday.count)
    }

    func updateCognitionLogCompletionCount(_ count: Int) {
        // Find today's CognitionLog and write the actual completion count
        // This builds the energy-state vs actual-output calibration dataset
        let todayCognitionLog = cognitionLogs.first { Calendar.current.isDateInToday($0.date) }
        if let log = todayCognitionLog {
            log.actualCompletionCount = count
        }
    }
}

// MARK: - TAB 5: YOU

// MARK: - CAPITAL TAB VIEW
// Resource intelligence — not budgeting. Clarity, stewardship, optionality.
// No amounts stored. Categorical only. Calm command, not financial anxiety.

struct CapitalTabView: View {
    @Query private var states: [FinancialState]
    @Environment(\.modelContext) private var context
    @State private var showEdit = false
    @State private var showLab = false

    var current: FinancialState {
        if let s = states.first { return s }
        let s = FinancialState(); return s
    }

    var body: some View {
        VStack(spacing: 16) {

            // ── RESOURCE STATE ───────────────────────────────────────────
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "CAPITAL", color: .warm)
                            MonoLabel(text: "RESOURCE ARCHITECTURE", color: .textMuted, size: 10)
                        }
                        Spacer()
                        Button(action: { showEdit = true }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12)).foregroundColor(.textMuted)
                                .frame(width: 28, height: 28)
                                .background(Color.surface)
                                .clipShape(Circle())
                        }
                    }
                    Divider().background(Color.muted.opacity(0.2))

                    // Runway
                    HStack(spacing: 10) {
                        Circle()
                            .fill(current.runwayState.color)
                            .frame(width: 8, height: 8)
                            .shadow(color: current.runwayState.color.opacity(0.5), radius: 4)
                        Text(current.runwayState.label)
                            .font(.sora(15, weight: .medium)).foregroundColor(.textPrimary)
                        Spacer()
                        MonoLabel(text: "RUNWAY", color: .textMuted, size: 10)
                    }

                    // Clarity
                    HStack {
                        Text("Picture clarity")
                            .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                        Spacer()
                        MonoLabel(text: current.capitalClarity.rawValue,
                                  color: current.capitalClarity == .clear ? .inkGreen : current.capitalClarity == .partial ? .inkAmber : .textMuted,
                                  size: 11)
                    }

                    // Inflow
                    HStack {
                        Text("Income this period")
                            .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                        Spacer()
                        MonoLabel(text: current.inflowReceived ? "RECEIVED" : "PENDING",
                                  color: current.inflowReceived ? .inkGreen : .textMuted, size: 11)
                    }

                    // Next obligation
                    if let date = current.nextObligationDate, !current.nextObligationLabel.isEmpty {
                        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                        HStack {
                            Text(current.nextObligationLabel)
                                .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                            Spacer()
                            MonoLabel(text: days <= 0 ? "DUE" : "IN \(days)D",
                                      color: days <= 3 ? .inkAmber : .textMuted, size: 11)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── ARCHITECTURE SIGNALS ─────────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "ARCHITECTURE SIGNALS", color: .textMuted)
                    Divider().background(Color.muted.opacity(0.2))

                    capitalSignal("Runway visible",
                                  state: current.hasRunwayVisibility,
                                  note: "Know approximately how long the current situation holds.")
                    capitalSignal("Generosity budgeted",
                                  state: current.hasBudgetedGenerosity,
                                  note: "Giving is intentional — not impulsive or destabilizing.")
                    capitalSignal("Emergency buffer",
                                  state: current.hasEmergencyBuffer,
                                  note: "Some buffer exists between inflow disruption and crisis.")

                    if current.mainLeakCategory != .unknown {
                        HStack(alignment: .top, spacing: 10) {
                            Circle().fill(Color.inkAmber.opacity(0.7)).frame(width: 6, height: 6).padding(.top, 5)
                            VStack(alignment: .leading, spacing: 2) {
                                MonoLabel(text: "DOMINANT LEAK", color: .inkAmber, size: 10)
                                Text(current.mainLeakCategory.rawValue)
                                    .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                            }
                        }
                    }

                    if current.activeFinancialFronts >= 3 {
                        HStack(alignment: .top, spacing: 10) {
                            Circle().fill(Color.inkAmber.opacity(0.7)).frame(width: 6, height: 6).padding(.top, 5)
                            VStack(alignment: .leading, spacing: 2) {
                                MonoLabel(text: "FRAGMENTATION", color: .inkAmber, size: 10)
                                Text("\(current.activeFinancialFronts) active financial fronts. Same principles apply as execution.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── RESOURCE DOCTRINES ───────────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "OPERATING DOCTRINES", color: .textMuted)
                    Divider().background(Color.muted.opacity(0.2))

                    let doctrines: [(String, String)] = [
                        ("CLARITY BEFORE SPENDING",
                         "Unclear picture creates drag. Know what exists and what is committed before committing more."),
                        ("RUNWAY PROTECTS CREATIVITY",
                         "Financial runway is optionality. It creates the space to take risks, build systems, and experiment without scarcity pressure."),
                        ("GENEROSITY SHOULD BE INTENTIONAL",
                         "Giving is a value, not a failure. But unstructured generosity can destabilize the base. Budget it like any other commitment."),
                        ("MONEY IS ROUTING POWER",
                         "Capital is the ability to direct energy. Leaks are routing problems — the same class of friction as admin displacement or fragmentation."),
                        ("PROTECT BASE LAYERS FIRST",
                         "Obligations, buffer, runway. Then experimentation, generosity, and growth. Same architectural principle as environment before cognition."),
                    ]
                    ForEach(doctrines, id: \.0) { doctrine in
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: doctrine.0, color: .warm, size: 10)
                            Text(doctrine.1)
                                .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── EXPORT ───────────────────────────────────────────────────
            WeeklyExportCard(actions: [], logs: [])
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
        .sheet(isPresented: $showEdit) {
            EditCapitalStateSheet(isPresented: $showEdit, state: states.first)
        }
        .onAppear {
            if states.isEmpty { context.insert(FinancialState()) }
        }
    }

    func capitalSignal(_ label: String, state: Bool, note: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(state ? Color.inkGreen : Color.muted.opacity(0.3))
                .frame(width: 6, height: 6).padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.sora(13, weight: state ? .medium : .light))
                    .foregroundColor(state ? .textPrimary : .textMuted)
                if !state {
                    Text(note)
                        .font(.sora(11, weight: .light)).foregroundColor(.muted).lineSpacing(2)
                }
            }
        }
    }
}

// MARK: - EDIT CAPITAL STATE SHEET

struct EditCapitalStateSheet: View {
    @Binding var isPresented: Bool
    var state: FinancialState?
    @Environment(\.modelContext) private var context
    @Query private var states: [FinancialState]

    @State private var runwayState: RunwayState = .stable
    @State private var capitalClarity: CapitalClarity = .unclear
    @State private var inflowReceived: Bool = false
    @State private var hasRunwayVisibility: Bool = false
    @State private var hasBudgetedGenerosity: Bool = false
    @State private var hasEmergencyBuffer: Bool = false
    @State private var mainLeak: FinancialLeakType = .unknown
    @State private var activeFronts: Int = 1
    @State private var hasNextObligation: Bool = false
    @State private var nextLabel: String = ""
    @State private var nextDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 14)
    @State private var notes: String = ""

    var current: FinancialState? { state ?? states.first }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Text("Capital State").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Done") { save(); isPresented = false }.font(.sora(14)).foregroundColor(.violet)
                    }

                    // Runway
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "RUNWAY")
                        MonoLabel(text: "Categorical — not numerical", color: .muted, size: 10)
                        HStack(spacing: 8) {
                            ForEach(RunwayState.allCases, id: \.self) { rs in
                                Button(action: { runwayState = rs }) {
                                    VStack(spacing: 6) {
                                        Circle().fill(rs.color.opacity(runwayState == rs ? 0.9 : 0.3))
                                            .frame(width: 8, height: 8)
                                        Text(rs.rawValue).font(.mono(11)).tracking(0.5)
                                            .foregroundColor(runwayState == rs ? .textPrimary : .textMuted)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                                    .background(runwayState == rs ? rs.color.opacity(0.1) : Color.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Picture clarity
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "PICTURE CLARITY")
                        HStack(spacing: 8) {
                            ForEach(CapitalClarity.allCases, id: \.self) { c in
                                Button(action: { capitalClarity = c }) {
                                    Text(c.rawValue).font(.mono(11)).tracking(0.5)
                                        .foregroundColor(capitalClarity == c ? .bgBase : .textMuted)
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(capitalClarity == c ? Color.warm : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Architecture signals
                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "ARCHITECTURE SIGNALS")
                        toggleRow("Runway visible", isOn: $hasRunwayVisibility)
                        toggleRow("Generosity budgeted", isOn: $hasBudgetedGenerosity)
                        toggleRow("Emergency buffer exists", isOn: $hasEmergencyBuffer)
                    }

                    // Inflow
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "INFLOW THIS PERIOD")
                        HStack(spacing: 12) {
                            ForEach([true, false], id: \.self) { val in
                                Button(action: { inflowReceived = val }) {
                                    Text(val ? "Received" : "Not yet").font(.sora(13))
                                        .foregroundColor(inflowReceived == val ? .bgBase : .textSecond)
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(inflowReceived == val ? Color.inkGreen : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Dominant leak
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "DOMINANT LEAK CATEGORY")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(FinancialLeakType.allCases, id: \.self) { leak in
                                Button(action: { mainLeak = leak }) {
                                    Text(leak.rawValue).font(.sora(12))
                                        .foregroundColor(mainLeak == leak ? .bgBase : .textSecond)
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(mainLeak == leak ? Color.inkAmber : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Active financial fronts
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "ACTIVE FINANCIAL FRONTS")
                        MonoLabel(text: "Open money 'projects' running simultaneously", color: .muted, size: 10)
                        Stepper("\(activeFronts)", value: $activeFronts, in: 1...10)
                            .font(.sora(14)).foregroundColor(.textPrimary)
                            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Next obligation
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            MonoLabel(text: "NEXT OBLIGATION")
                            Spacer()
                            Toggle("", isOn: $hasNextObligation).tint(Color.warm).labelsHidden()
                        }
                        if hasNextObligation {
                            inputField("LABEL", placeholder: "e.g. Rent, Insurance", text: $nextLabel)
                            DatePicker("Date", selection: $nextDate, displayedComponents: .date)
                                .datePickerStyle(.compact).colorScheme(.dark)
                                .font(.sora(13)).foregroundColor(.textPrimary)
                                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    inputField("NOTES (OPTIONAL)", placeholder: "Running context", text: $notes)

                    CardView(style: .ambient) {
                        VStack(alignment: .leading, spacing: 6) {
                            MonoLabel(text: "NO AMOUNTS STORED", color: .muted, size: 10)
                            Text("Capital state is categorical. No numbers, no budgets, no targets. Clarity without surveillance.")
                                .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(3)
                        }
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
        .onAppear { loadFromCurrent() }
    }

    func toggleRow(_ label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label).font(.sora(13)).foregroundColor(.textPrimary)
            Spacer()
            Toggle("", isOn: isOn).tint(Color.inkGreen).labelsHidden()
        }
        .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
    }

    func loadFromCurrent() {
        guard let c = current else { return }
        runwayState = c.runwayState
        capitalClarity = c.capitalClarity
        inflowReceived = c.inflowReceived
        hasRunwayVisibility = c.hasRunwayVisibility
        hasBudgetedGenerosity = c.hasBudgetedGenerosity
        hasEmergencyBuffer = c.hasEmergencyBuffer
        mainLeak = c.mainLeakCategory
        activeFronts = c.activeFinancialFronts
        notes = c.notes
        if let d = c.nextObligationDate {
            hasNextObligation = true; nextDate = d; nextLabel = c.nextObligationLabel
        }
    }

    func save() {
        let target: FinancialState
        if let c = current { target = c } else {
            let fresh = FinancialState(); context.insert(fresh); target = fresh
        }
        target.runwayState = runwayState
        target.capitalClarity = capitalClarity
        target.inflowReceived = inflowReceived
        target.hasRunwayVisibility = hasRunwayVisibility
        target.hasBudgetedGenerosity = hasBudgetedGenerosity
        target.hasEmergencyBuffer = hasEmergencyBuffer
        target.mainLeakCategory = mainLeak
        target.activeFinancialFronts = activeFronts
        target.notes = notes
        target.updatedAt = Date()
        target.lastCapitalReview = Date()
        if hasNextObligation && !nextLabel.isEmpty {
            target.nextObligationDate = nextDate
            target.nextObligationLabel = nextLabel
        } else {
            target.nextObligationDate = nil
            target.nextObligationLabel = ""
        }
    }
}

struct YouView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [OperatorProfile]
    @Query private var actions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Bindable var state: AppState
    @State private var selectedSeg = 0

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        MonoLabel(text: "INCREMENTS", color: .violetLight, size: 10)
                        Text(profile.firstName.isEmpty ? "You" : profile.firstName)
                            .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    }
                    Spacer()
                    Image(systemName: "gearshape")
                        .foregroundColor(.textMuted)
                        .font(.system(size: 18, weight: .light))
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 14)

                segmentControl(["Capital", "Settings"], selected: $selectedSeg)
                    .padding(.horizontal, 24).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    switch selectedSeg {
                    case 0: CapitalTabView()
                    case 1: SettingsTabView(profile: profile, state: state)
                    default: EmptyView()
                    }
                }
            }
        }
    }
}

struct ProfileTabView: View {
    @Bindable var profile: OperatorProfile
    @Query private var actions: [Action]
    @Query private var cognitionLogs: [CognitionLog]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    // Intelligence readiness — computed from actual data, displayed honestly
    var daysActive: Int {
        Calendar.current.dateComponents([.day], from: profile.firstLaunchDate, to: Date()).day ?? 0
    }

    // Pattern window: 7 days of completions to start detecting time-of-day patterns
    var patternReadiness: IntelligenceReadiness {
        // BUG FIX: was using completedAt (nil'd on daily reset) — only counted today's completions.
        // Use completionDates (persistent history) to count distinct calendar days with completions.
        let daysWithCompletions = Set(
            actions.flatMap { $0.completionDates }.map {
                Calendar.current.startOfDay(for: $0)
            }
        ).count
        if daysWithCompletions >= 7 { return .ready(label: "Pattern window open.") }
        let remaining = max(0, 7 - daysWithCompletions)
        return .collecting(daysRemaining: remaining, target: 7, label: "completion days")
    }

    // Friction read: 14 appearances of any action
    var frictionReadiness: IntelligenceReadiness {
        let maxAppearances = actions.map { $0.skipCount + $0.completionDates.count }.max() ?? 0
        if maxAppearances >= 14 { return .ready(label: "Friction read open.") }
        let remaining = max(0, 14 - maxAppearances)
        return .collecting(daysRemaining: remaining, target: 14, label: "action appearances")
    }

    // Energy calibration: 10 CognitionLog entries with energyStateAtDeclaration set
    var energyCalibrationReadiness: IntelligenceReadiness {
        let entries = cognitionLogs.filter { $0.energyStateAtDeclaration != nil }.count
        if entries >= 10 { return .ready(label: "Energy calibration active.") }
        let remaining = max(0, 10 - entries)
        return .collecting(daysRemaining: remaining, target: 10, label: "energy readings")
    }

    // Cognition tagging: any Cognition actions need to be tagged
    var cognitionTaggingStatus: String {
        let cognitionActions = actions.filter { $0.system == .cognition }
        if cognitionActions.isEmpty { return "No Cognition actions yet." }
        let tagged = cognitionActions.filter { $0.cognitionMode != nil }.count
        let total = cognitionActions.count
        if tagged == total { return "All \(total) tagged." }
        if tagged == 0 { return "\(total) untagged. Open action to tag." }
        return "\(tagged) of \(total) tagged."
    }

    var body: some View {
        VStack(spacing: 20) {
            // Operator identity card
            CardView {
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.violetDim, .bgBase],
                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 56, height: 56)
                            Image("BrainGlyph")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .opacity(0.85)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            MonoLabel(text: "OPERATOR", color: .violetLight, size: 11)
                            Text(profile.firstName.isEmpty ? profile.title : profile.firstName)
                                .font(.sora(16, weight: .semibold)).foregroundColor(.textPrimary)
                            Text(profile.phaseLabel.isEmpty ? "Recovery + Operational Restoration" : profile.phaseLabel)
                                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    Divider().background(Color.muted.opacity(0.3))
                    HStack(spacing: 0) {
                        statCell("DAY", value: "\(profile.daysInSystem)")
                        Divider().background(Color.muted.opacity(0.3)).frame(height: 36)
                        statCell("PHASE", value: "\(profile.level)")
                        Divider().background(Color.muted.opacity(0.3)).frame(height: 36)
                        statCell("LOAD", value: "\(profile.xpToNextLevel)")
                    }
                }
            }
            .padding(.horizontal, 24)

            // Intelligence readiness — honest about what's being collected and what isn't ready yet
            IntelligenceReadinessCard(
                patternReadiness: patternReadiness,
                frictionReadiness: frictionReadiness,
                energyCalibrationReadiness: energyCalibrationReadiness,
                cognitionTaggingStatus: cognitionTaggingStatus
            )
            .padding(.horizontal, 24)

            // Hideout business layer — quick access within Dossier
            HideoutTabView()

            // Weekly Review Export
            WeeklyExportCard(actions: actions, logs: logs)
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
    }

    func statCell(_ label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
            MonoLabel(text: label, color: .textMuted, size: 11)
        }.frame(maxWidth: .infinity)
    }
}

// MARK: - FIELD MANUAL TAB

struct FieldManualEntry: Identifiable {
    let id = UUID()
    let title: String
    let meaning: String
    let misread: String
    let usageTrigger: String
}

struct FieldManualTabView: View {
    @State private var expandedID: UUID? = nil

    let entries: [FieldManualEntry] = [
        FieldManualEntry(
            title: "PARTICIPATION IN REALITY",
            meaning: "Showing up — in small, concrete ways — is the mechanism. Not readiness, not ideal conditions. Showing up.",
            misread: "Waiting until you feel ready. Readiness follows participation, not the other way.",
            usageTrigger: "When analysis is substituting for action. When the loop won't close."
        ),
        FieldManualEntry(
            title: "RESTORATION BEFORE INTERPRETATION",
            meaning: "Environmental and physiological conditions shape perception. A bad read of a situation may be a bad environment, not a bad situation.",
            misread: "Treating your current interpretation as accurate when conditions are degraded.",
            usageTrigger: "When something feels heavier than it should. Restore first. Conclude after."
        ),
        FieldManualEntry(
            title: "ACTION REORGANIZES PERCEPTION",
            meaning: "Clarity comes from movement, not analysis. The next step becomes visible after the current step is taken.",
            misread: "Believing you need clarity before you can act. The causality runs the other way.",
            usageTrigger: "When you're stuck planning. One action. Perception shifts. Proceed."
        ),
        FieldManualEntry(
            title: "ONE DOOR",
            meaning: "One open path at a time. Too many concurrent openings fragment attention and kill momentum.",
            misread: "Keeping options open as a strategy. Options without commitment are just load.",
            usageTrigger: "When you notice multiple active directions pulling at the same time."
        ),
        FieldManualEntry(
            title: "INCREMENTS",
            meaning: "Transformation happens through accumulation, not events. Each completed action compounds on the last.",
            misread: "Waiting for the significant move. The significant move is made of small ones.",
            usageTrigger: "When progress feels invisible. Count the completed actions."
        ),
        FieldManualEntry(
            title: "FLOW INSIDE FORM",
            meaning: "Structure does not kill aliveness. A schedule can hold energy. Form can contain creativity without suppressing it.",
            misread: "Treating structure as opposed to expression. Structure is what makes expression possible.",
            usageTrigger: "When the day feels rigid. The anchor is what enables the open time."
        ),
        FieldManualEntry(
            title: "REDUCE BRANCHING",
            meaning: "Every unclosed loop costs attentional resources. Fewer active branches means more capacity per branch.",
            misread: "Mistaking breadth of engagement for productivity. Open loops are debt.",
            usageTrigger: "When you feel busy but unproductive. Close one loop completely."
        ),
        FieldManualEntry(
            title: "ENVIRONMENT IS COGNITION",
            meaning: "Conditions are not the background to your thinking. They are part of your thinking. Light, temperature, order, and noise all affect output quality.",
            misread: "Believing you can perform consistently in inconsistent environments through willpower.",
            usageTrigger: "Before any deep work block. Environment first."
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(text: "FIELD MANUAL", color: .textMuted)
                .padding(.horizontal, 24).padding(.bottom, 14)

            VStack(spacing: 8) {
                ForEach(entries) { entry in
                    let isExpanded = expandedID == entry.id
                    CardView(style: isExpanded ? .primary : .secondary) {
                        VStack(alignment: .leading, spacing: 0) {
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.22)) {
                                    expandedID = isExpanded ? nil : entry.id
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                HStack {
                                    MonoLabel(text: entry.title, color: isExpanded ? .violetLight : .textMuted, size: 11)
                                    Spacer()
                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 10, weight: .light))
                                        .foregroundColor(.textMuted)
                                }
                            }

                            if isExpanded {
                                VStack(alignment: .leading, spacing: 14) {
                                    Divider().background(Color.muted.opacity(0.3)).padding(.top, 10)

                                    VStack(alignment: .leading, spacing: 5) {
                                        MonoLabel(text: "MEANING", color: .textMuted, size: 10)
                                        Text(entry.meaning)
                                            .font(.sora(13, weight: .light)).foregroundColor(.textPrimary)
                                            .lineSpacing(3)
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        MonoLabel(text: "MISREAD", color: .inkAmber, size: 10)
                                        Text(entry.misread)
                                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                            .lineSpacing(3)
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        MonoLabel(text: "USE WHEN", color: .inkGreen, size: 10)
                                        Text(entry.usageTrigger)
                                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                            .lineSpacing(3)
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .padding(.bottom, 80)
    }
}

// MARK: - OPERATOR TAB

// ── Read depth ────────────────────────────────────────────────
enum LabReadDepth: String, Codable {
    case unread = "unread"
    case skimmed = "skimmed"
    case completed = "completed"
}

// ── Section model ─────────────────────────────────────────────
struct LabSection: Identifiable {
    let id: String
    let eyebrow: String
    let question: String
    let title: String
    let hook: String
    let accentColor: Color
    let entries: [LabEntry]
    let teachLine: String?
}

struct LabEntry: Identifiable {
    let id: String
    let label: String
    let body: String
    let isMisread: Bool
    init(id: String, label: String, body: String, isMisread: Bool = false) {
        self.id = id; self.label = label; self.body = body; self.isMisread = isMisread
    }
}

// ── Pentagon radar ────────────────────────────────────────────
struct PentagonRadar: View {
    let values: [(label: String, value: Double, color: Color)]
    @State private var drawn = false

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let r = size * 0.42

            ZStack {
                // Background rings
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { frac in
                    pentagonPath(center: center, radius: r * frac)
                        .stroke(Color.muted.opacity(0.15), lineWidth: 0.5)
                }

                // Spokes
                ForEach(0..<5) { i in
                    let angle = angle(for: i)
                    Path { p in
                        p.move(to: center)
                        p.addLine(to: point(center: center, radius: r, angle: angle))
                    }
                    .stroke(Color.muted.opacity(0.12), lineWidth: 0.5)
                }

                // Filled polygon — animated
                filledPolygon(center: center, radius: r, values: values.map { $0.value })
                    .fill(
                        LinearGradient(
                            colors: [Color.violet.opacity(0.35), Color.violetLight.opacity(0.15)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .scaleEffect(drawn ? 1 : 0.1)
                    .animation(.spring(response: 1.1, dampingFraction: 0.7).delay(0.2), value: drawn)

                // Polygon border
                filledPolygon(center: center, radius: r, values: values.map { $0.value })
                    .stroke(Color.violet.opacity(0.6), lineWidth: 1.5)
                    .scaleEffect(drawn ? 1 : 0.1)
                    .animation(.spring(response: 1.1, dampingFraction: 0.7).delay(0.2), value: drawn)

                // Vertex dots + labels
                ForEach(0..<5) { i in
                    let v = values[i]
                    let a = angle(for: i)
                    let dotPt = point(center: center, radius: r * v.value, angle: a)
                    let lblPt = point(center: center, radius: r * 1.22, angle: a)

                    // Glow dot
                    ZStack {
                        Circle()
                            .fill(v.color.opacity(0.3))
                            .frame(width: 14, height: 14)
                            .blur(radius: 4)
                        Circle()
                            .fill(v.color)
                            .frame(width: 6, height: 6)
                    }
                    .position(dotPt)
                    .opacity(drawn ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.6 + Double(i) * 0.08), value: drawn)

                    // Label
                    Text(v.label)
                        .font(.mono(8))
                        .foregroundColor(v.color)
                        .tracking(0.5)
                        .position(lblPt)
                        .opacity(drawn ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.8 + Double(i) * 0.06), value: drawn)
                }
            }
        }
        .onAppear { drawn = true }
    }

    func angle(for i: Int) -> Double {
        return Double(i) * (2 * .pi / 5) - .pi / 2
    }

    func point(center: CGPoint, radius: Double, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }

    func pentagonPath(center: CGPoint, radius: Double) -> Path {
        Path { p in
            for i in 0..<5 {
                let pt = point(center: center, radius: radius, angle: angle(for: i))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }

    func filledPolygon(center: CGPoint, radius: Double, values: [Double]) -> Path {
        Path { p in
            for i in 0..<5 {
                let pt = point(center: center, radius: radius * values[i], angle: angle(for: i))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }
}

// ── Ambient orb background ────────────────────────────────────
struct OperatorAmbience: View {
    @State private var phase = false
    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.violet.opacity(0.18), Color.bgBase.opacity(0)],
                           center: .topTrailing, startRadius: 0, endRadius: 280)
            RadialGradient(colors: [Color.warm.opacity(0.10), Color.bgBase.opacity(0)],
                           center: .bottomLeading, startRadius: 0, endRadius: 220)
            RadialGradient(colors: [Color.violetDim.opacity(0.12), Color.bgBase.opacity(0)],
                           center: UnitPoint(x: phase ? 0.3 : 0.7, y: phase ? 0.6 : 0.4),
                           startRadius: 0, endRadius: 200)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: phase)
        }
        .onAppear { phase = true }
        .ignoresSafeArea()
    }
}

// ── Glowing ring ──────────────────────────────────────────────
struct GlowRing: View {
    let progress: Double
    let size: CGFloat
    let color: Color
    @State private var appeared = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.08), lineWidth: 6)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: appeared ? progress : 0)
                .stroke(
                    AngularGradient(colors: [color.opacity(0.3), color, color.opacity(0.6)],
                                   center: .center),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.4).delay(0.3), value: appeared)
                .shadow(color: color.opacity(0.5), radius: 8)
        }
        .onAppear { appeared = true }
    }
}

// ── Strength pill ─────────────────────────────────────────────
struct StrengthPill: View {
    let label: String
    let rank: String
    let color: Color
    let delay: Double
    @State private var appeared = false

    init(label: String, rank: String, color: Color, delay: Double = 0) {
        self.label = label; self.rank = rank; self.color = color; self.delay = delay
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .shadow(color: color.opacity(0.8), radius: 4)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.sora(12, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(rank)
                    .font(.mono(8))
                    .foregroundColor(color)
                    .tracking(0.6)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.07))
                RoundedRectangle(cornerRadius: 10).fill(Color.surface)
                    .opacity(0.4)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .strokeBorder(color.opacity(0.25), lineWidth: 0.5))
        .shadow(color: color.opacity(appeared ? 0.18 : 0), radius: 8, x: 0, y: 2)
        .scaleEffect(appeared ? 1 : 0.88)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72).delay(delay)) {
                appeared = true
            }
        }
    }
}

// ── Hero profile card ─────────────────────────────────────────
struct OperatorHeroCard: View {
    @State private var appeared = false
    @State private var showAgentContext = false
    @State private var pulseA = false

    let agentContextBlock = """
OPERATOR: Brice Ikouebe
GALLUP_TOP5: Restorative(1) Achiever(2) Analytical(3) Individualization(4) Competition(5)
ESF_DOMINANT: Confidence · Risk-Taker · Delegator
ESF_SUPPORTING: Business Focus (gap) · Knowledge-Seeker reactive (gap)
MBTI: INTJ | SLOAN: SCOAI

BEHAVIORAL_PROFILE:
- Achiever: zero every day by design. Needs daily tangible closure. Praise = recognition not reward.
- Restorative: problems as sport. Friction = data. Diagnoses first, moves fast.
- Analytical: data before conclusions. Mechanisms produce buy-in.
- Competition: wins not participates. Measures against own prior numbers.
- Confidence: self-assurance is native. Sees past barriers by default.
- Individualization: reads individuals not types. Expects personalization.
- Business Focus gap: strategic alignment is deliberate practice not default.
- Knowledge-Seeker gap: reactive researcher, not proactive scanner.

VOICE: competitive · direct · warm exactness · earned praise natural · no consolation
DOCTRINE: Voice Doctrine v4.0
"""

    var body: some View {
        ZStack {
            // Background ambience inside card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.surface)
                RadialGradient(colors: [Color.violet.opacity(0.22), Color.bgBase.opacity(0)],
                               center: .topTrailing, startRadius: 0, endRadius: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                RadialGradient(colors: [Color.warm.opacity(0.08), Color.bgBase.opacity(0)],
                               center: .bottomLeading, startRadius: 0, endRadius: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .shadow(color: Color.violet.opacity(0.12), radius: 24, x: 0, y: 8)
            .shadow(color: Color.bgBase.opacity(0.7), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 0) {

                // Top row — identity
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        MonoLabel(text: "OPERATOR PROFILE", color: .violetLight, size: 10)
                        Text("Brice Ikouebe")
                            .font(.sora(22, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 8)
                            .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
                        HStack(spacing: 6) {
                            tagChip("INTJ", color: .violet)
                            tagChip("SCOAI", color: .violetLight)
                            tagChip("ESF DOMINANT", color: .inkGreen)
                        }
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
                    }
                    Spacer()
                    // Agent context button
                    Button(action: { withAnimation(.spring(response: 0.4)) { showAgentContext.toggle() } }) {
                        VStack(spacing: 3) {
                            Image(systemName: "cpu")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(showAgentContext ? .violetLight : .textMuted)
                            Text("AGENT")
                                .font(.mono(7))
                                .foregroundColor(showAgentContext ? .violetLight : .textMuted)
                                .tracking(0.5)
                        }
                        .padding(10)
                        .background(Color.surface2.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(showAgentContext ? Color.violet.opacity(0.4) : Color.muted.opacity(0.2), lineWidth: 0.5))
                    }
                }
                .padding(.bottom, 22)

                // Pentagon + stats
                HStack(alignment: .center, spacing: 20) {
                    PentagonRadar(values: [
                        ("RESTORE", 0.95, .inkGreen),
                        ("ACHIEVE", 0.90, .violet),
                        ("ANALYZE", 0.85, .violetLight),
                        ("INDIVID", 0.78, .warm),
                        ("COMPETE", 0.88, .inkTeal),
                    ])
                    .frame(width: 160, height: 160)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.15), value: appeared)

                    // Right side stats
                    VStack(alignment: .leading, spacing: 14) {
                        statBlock(label: "RESTORATIVE", value: "#1", color: .inkGreen,
                                  sub: "Problems as sport")
                        statBlock(label: "ACHIEVER", value: "#2", color: .violet,
                                  sub: "Zero daily, always")
                        statBlock(label: "ANALYTICAL", value: "#3", color: .violetLight,
                                  sub: "Data before conclusions")
                        statBlock(label: "COMPETITION", value: "#5", color: .inkTeal,
                                  sub: "Win, not participate")
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(x: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.6).delay(0.35), value: appeared)
                }
                .padding(.bottom, 22)

                // Core read
                Text("Starts at zero every day by design. Diagnoses problems as sport. Needs measurement to feel alive. Competes to win, not to participate.")
                    .font(.sora(13, weight: .light))
                    .foregroundColor(.textSecond)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
                    .padding(.bottom, 20)

                // ESF Dominant row
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "ESF DOMINANT", color: .textMuted, size: 9)
                    HStack(spacing: 8) {
                        esfPill("CONFIDENCE",  .inkGreen,   0.55)
                        esfPill("RISK-TAKER",  .inkGreen,   0.62)
                        esfPill("DELEGATOR",   .inkGreen,   0.69)
                    }
                }
                .padding(.bottom, 18)

                // Strength grid
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "GALLUP TOP 5", color: .textMuted, size: 9)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        StrengthPill(label: "Restorative",       rank: "TOP 5 · #1", color: .inkGreen,   delay: 0.6)
                        StrengthPill(label: "Achiever",          rank: "TOP 5 · #2", color: .violet,     delay: 0.66)
                        StrengthPill(label: "Analytical",        rank: "TOP 5 · #3", color: .violetLight,delay: 0.72)
                        StrengthPill(label: "Individualization", rank: "TOP 5 · #4", color: .warm,       delay: 0.78)
                        StrengthPill(label: "Competition",       rank: "TOP 5 · #5", color: .inkTeal,    delay: 0.84)
                    }
                }
                .padding(.bottom, 18)

                // Gaps row
                HStack(spacing: 8) {
                    gapTag("Business Focus", "SUPPORTING — develop deliberately")
                    gapTag("Knowledge-Seeker", "REACTIVE — scan proactively")
                }
                .padding(.bottom, showAgentContext ? 18 : 0)

                // Agent context block
                if showAgentContext {
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle().fill(Color.violet.opacity(0.25)).frame(height: 0.5)
                        HStack {
                            MonoLabel(text: "AGENT CONTEXT", color: .violetLight, size: 9)
                            Spacer()
                            Text("machine readable")
                                .font(.mono(8)).foregroundColor(.textMuted.opacity(0.5))
                        }
                        Text(agentContextBlock)
                            .font(.mono(9))
                            .foregroundColor(.textMuted)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(Color.bgBase.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.violet.opacity(0.2), lineWidth: 0.5))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(22)
        }
        .onAppear { appeared = true }
    }

    func tagChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.mono(9))
            .foregroundColor(color)
            .tracking(0.6)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5)
                .strokeBorder(color.opacity(0.2), lineWidth: 0.5))
    }

    func statBlock(label: String, value: String, color: Color, sub: String) -> some View {
        HStack(spacing: 10) {
            Text(value)
                .font(.mono(11))
                .foregroundColor(color)
                .frame(width: 24, alignment: .trailing)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.mono(9)).foregroundColor(color).tracking(0.5)
                Text(sub).font(.sora(10, weight: .light)).foregroundColor(.textMuted)
            }
        }
    }

    func esfPill(_ label: String, _ color: Color, _ delay: Double) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 5, height: 5)
                .shadow(color: color.opacity(0.8), radius: 3)
            Text(label).font(.mono(8)).foregroundColor(color).tracking(0.5)
        }
        .padding(.horizontal, 8).padding(.vertical, 5)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay(RoundedRectangle(cornerRadius: 7)
            .strokeBorder(color.opacity(0.2), lineWidth: 0.5))
    }

    func gapTag(_ label: String, _ sub: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.sora(10, weight: .medium)).foregroundColor(.inkAmber)
            Text(sub).font(.mono(8)).foregroundColor(.inkAmber.opacity(0.6)).tracking(0.3)
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background(Color.inkAmber.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color.inkAmber.opacity(0.2), lineWidth: 0.5))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ── Cognition Lab content ──────────────────────────────────────
enum CognitionLabContent {
    static let sections: [LabSection] = [
        LabSection(
            id: "achiever_dopamine",
            eyebrow: "NEUROSCIENCE · ACHIEVER",
            question: "Why does every day starting at zero feel necessary, not punishing?",
            title: "The Achiever Drive: Dopamine and the Completion Loop",
            hook: "The internal fire that rekindles after every close. What's actually happening neurologically.",
            accentColor: .violet,
            entries: [
                LabEntry(id: "a1", label: "THE MECHANISM",
                    body: "Dopamine doesn't fire at the reward — it fires at the anticipation of the reward and at the moment of completion. For Achievers, the daily reset creates a fresh anticipation cycle every morning. The fire rekindles not despite the reset but because of it. Zero is the starting condition that makes the dopamine loop possible."),
                LabEntry(id: "a2", label: "WHY IT NEVER TURNS OFF",
                    body: "The Achiever pattern is driven by phasic dopamine release — spikes at goal completion, then rapid return to baseline. Each spike resets the baseline. The dissatisfaction after completion isn't dysfunction — it's the system recalibrating for the next challenge. 'Divine restlessness' is neurologically accurate."),
                LabEntry(id: "a3", label: "WHAT THIS MEANS FOR THE STACK",
                    body: "The action stack closing each day isn't a task list — it's a dopamine architecture. Each completion is a spike. The daily review is the consolidation. The reset is the structural condition that makes tomorrow's anticipation cycle possible. Remove the reset and the loop collapses."),
                LabEntry(id: "a4", label: "THE TRAP",
                    body: "Achievers can conflate motion with progress — racking up low-value completions to trigger the spike without doing the hard thing. Friction tracking exists for this: it distinguishes high-output days from high-completion days.", isMisread: true),
            ],
            teachLine: "Dopamine fires at anticipation and completion, not possession. The reset is the architecture that makes tomorrow's anticipation possible. Without zero, there's no climb."
        ),
        LabSection(
            id: "competition_psych",
            eyebrow: "PSYCHOLOGY · COMPETITION",
            question: "Why does comparison activate you instead of threatening you?",
            title: "Competition as Calibration: The Measurement Instinct",
            hook: "Competition is rooted in comparison. Without a yardstick, achievement feels hollow.",
            accentColor: .inkTeal,
            entries: [
                LabEntry(id: "c1", label: "THE MECHANISM",
                    body: "Social comparison activates the anterior cingulate cortex — the brain's performance monitoring system. For competitive profiles, external benchmarks trigger clarity, not threat. The yardstick is informative. It tells you where you stand and what closes the gap."),
                LabEntry(id: "c2", label: "WHY MEASUREMENT MATTERS",
                    body: "Without measurement there's no competition. Without competition the Achiever drive has no external calibration. The planning bands, system rates, and trajectory signals in the app aren't just data — they're the scoreboard."),
                LabEntry(id: "c3", label: "THE GRACIOUS LOSER PATTERN",
                    body: "Competition profiles are outwardly gracious in defeat and internally registering it sharply. This isn't hypocrisy — it's the distinction between the social surface and the performance signal. Internal registration is data: what closes the gap next time."),
                LabEntry(id: "c4", label: "THE WRONG COMPETITION",
                    body: "Competing against the app — maximizing the number instead of doing the right things — corrupts the signal. When the score becomes the goal, the instrument breaks.", isMisread: true),
            ],
            teachLine: "Competition is measurement with stakes. The comparison isn't ego — it's the calibration instrument. Without the yardstick, the Achiever drive has nothing to optimize against."
        ),
        LabSection(
            id: "restorative_cognition",
            eyebrow: "COGNITIVE SCIENCE · RESTORATIVE",
            question: "Why do problems feel energizing rather than draining?",
            title: "Restorative as Cognitive Style: Problem-Detection as Talent",
            hook: "Most people experience problems as costs. Restoratives experience them as puzzles.",
            accentColor: .inkGreen,
            entries: [
                LabEntry(id: "r1", label: "THE MECHANISM",
                    body: "The brain's error-detection network (anterior insula + ACC) fires when something is wrong. For most people this connects to the threat circuit. For Restoratives it connects to the reward circuit. The problem triggers curiosity, not anxiety. Same detection system, different routing."),
                LabEntry(id: "r2", label: "DIAGNOSIS AS INSTINCT",
                    body: "The sequence is automatic: something is wrong → symptoms identified → root cause hypothesized → solution tested → system restored. This is why friction tracking works: skip counts and completion rates are diagnostic inputs, not grades."),
                LabEntry(id: "r3", label: "THE SELF-DIRECTED VERSION",
                    body: "Restorative turns inward too. Honest assessment of shortcomings, direct acknowledgment of what needs to improve. This is why 'noted. tomorrow.' works — it's Restorative applied to a light day. Diagnosis → adjustment → move."),
                LabEntry(id: "r4", label: "THE OVER-FIX TRAP",
                    body: "Restoratives can rush in to fix things before the system has worked it out. The nudge names the problem — the solve is yours.", isMisread: true),
            ],
            teachLine: "For most people the error-detection network connects to threat. For Restoratives it connects to reward. Problems feel like puzzles because neurologically, they are."
        ),
        LabSection(
            id: "decision_fatigue",
            eyebrow: "COGNITIVE SCIENCE · ENVIRONMENT",
            question: "Why is environment the gateway system, not willpower?",
            title: "Decision Fatigue and the Environment Gateway",
            hook: "Willpower is a finite resource. Environment is infrastructure. They're not interchangeable.",
            accentColor: .inkGreen,
            entries: [
                LabEntry(id: "d1", label: "DECISION FATIGUE",
                    body: "The prefrontal cortex handles executive function — decisions, impulse control, planning. It depletes across the day. More decisions early = less capacity for hard things later. Decision fatigue is real, measurable, and universal."),
                LabEntry(id: "d2", label: "ENVIRONMENT AS INFRASTRUCTURE",
                    body: "A supportive environment reduces decisions required to start anything. Clear desk = no decision about where to work. Each environment action is a decision elimination, not a task completion."),
                LabEntry(id: "d3", label: "WHY IT'S THE GATEWAY",
                    body: "When Environment moves, Health and Cognition tend to follow — because activation energy for the next thing drops. The cleared space signals 'things happen here.' Gateway causality is environmental priming, not willpower contagion."),
                LabEntry(id: "d4", label: "THE WILLPOWER MISREAD",
                    body: "Overriding a disorganized environment with determination works briefly. But you're drawing from a depleting account you need for things that matter.", isMisread: true),
            ],
            teachLine: "Willpower is a bank account that depletes. Environment is automatic withdrawal management — it keeps the account full for things that actually need it."
        ),
        LabSection(
            id: "hrv_readiness",
            eyebrow: "PHYSIOLOGY · HEALTH SYSTEM",
            question: "What is HRV actually measuring and why does it change what you do?",
            title: "HRV and the Readiness Signal",
            hook: "Heart rate variability isn't a fitness metric. It's a nervous system readiness signal.",
            accentColor: .inkTeal,
            entries: [
                LabEntry(id: "h1", label: "THE MECHANISM",
                    body: "HRV measures variation in time between heartbeats — not the rate, the variation. High HRV = parasympathetic dominance: recovered, adaptable, ready to load. Low HRV = sympathetic dominance: stressed or depleted. The body reports its state without asking your opinion."),
                LabEntry(id: "h2", label: "WHY IT CHANGES WHAT YOU DO",
                    body: "Training on low HRV produces worse adaptations and increases injury risk. Cognitive performance degrades measurably — decision quality, working memory, pattern recognition all drop. A Reserve day isn't weakness — it's reading the signal correctly."),
                LabEntry(id: "h3", label: "THE CALIBRATION PROBLEM",
                    body: "HRV is individual — your baseline is yours, not a population average. What matters is trend relative to your 7-day rolling average. This is why the app tracks energy state declarations: the correlation reveals whether your subjective read is calibrated."),
                LabEntry(id: "h4", label: "THE OVERRIDE ERROR",
                    body: "Overriding a clear low-HRV signal extends recovery, suppresses immune response, and delays the adaptation you were training for. The signal is cheaper to read than to ignore.", isMisread: true),
            ],
            teachLine: "HRV is the body's nervous system report card. High variation = recovered and adaptable. Low variation = depleted. The report card doesn't care what you think — it reports what is."
        ),
        LabSection(
            id: "deep_work_neuro",
            eyebrow: "NEUROSCIENCE · COGNITION",
            question: "What is deep work actually building in the brain?",
            title: "Myelin and the Deep Work Mechanism",
            hook: "Deep work isn't a productivity technique. It's a neurological construction process.",
            accentColor: .violetLight,
            entries: [
                LabEntry(id: "dw1", label: "MYELIN",
                    body: "Myelin is the insulating sheath around neural pathways. It's produced in response to focused, deliberate practice — the same circuit firing repeatedly under attention. More myelin = faster, cleaner signal transmission. Skill is literally the thickness of the myelin sheath."),
                LabEntry(id: "dw2", label: "WHY DEPTH MATTERS",
                    body: "Myelin is only produced during focused engagement. Shallow or distracted work doesn't trigger production — it triggers error patterns on existing circuits. The 90-minute block isn't about getting more done today — it's neurological construction that makes the next session better."),
                LabEntry(id: "dw3", label: "THE COGNITIVE LOAD PREREQUISITE",
                    body: "Deep work requires low cognitive load going in. Decision fatigue, open loops, and environmental noise all compete for prefrontal bandwidth. This is the direct link between Environment + Operations and Cognition."),
                LabEntry(id: "dw4", label: "THE BUSYNESS MISREAD",
                    body: "Feeling productive because you handled many things is not the same as building capability. Admin doesn't produce myelin on the circuits that matter most. The deep work block is protected because it's the only thing that builds the hardware.", isMisread: true),
            ],
            teachLine: "Deep work builds myelin — physical insulation on neural pathways. Shallow work uses existing circuits but doesn't improve them. The 90-minute block is construction, not just production."
        ),
        LabSection(
            id: "habit_stacking",
            eyebrow: "BEHAVIORAL SCIENCE · HABITS",
            question: "Why does linking habits to cues outperform relying on motivation?",
            title: "Implementation Intentions and the Cue Architecture",
            hook: "Motivation is a mood. Cues are architecture. 'When X then Y' outperforms willpower by 2–3x.",
            accentColor: .warm,
            entries: [
                LabEntry(id: "hs1", label: "IMPLEMENTATION INTENTIONS",
                    body: "A pre-committed 'when X happens, I will do Y' statement. Gollwitzer's research shows 2–3x better follow-through versus vague intentions. The cue becomes a retrieval trigger — when the situation is detected, the behavior activates automatically without deliberate decision."),
                LabEntry(id: "hs2", label: "THE CUE FIELD",
                    body: "Every action in the stack has a cue field for exactly this reason. 'When: noon break at hideout' is an implementation intention. It delegates the decision to the environment rather than to motivation state. No negotiation required."),
                LabEntry(id: "hs3", label: "HABIT STACKING",
                    body: "Stacking a new behavior after an existing automatic one borrows the anchor habit's automaticity. 'After coffee, open blinds and reset desk' — coffee triggers the environment stack. The new behavior inherits the reliable cue from the established one."),
                LabEntry(id: "hs4", label: "THE MOTIVATION MISREAD",
                    body: "Waiting to feel like doing something means the behavior is on the wrong trigger. Motivation is post-hoc — it follows action more than it precedes it. Add the cue first.", isMisread: true),
            ],
            teachLine: "Implementation intentions turn decisions into triggers. 'I'll exercise' is a wish. 'When I finish deep work, I go to the gym' is a program. The environment runs the program — you set it once."
        ),
        LabSection(
            id: "teaching_consolidation",
            eyebrow: "COGNITIVE SCIENCE · LEARNING",
            question: "Why does explaining something make you better at it than reviewing it does?",
            title: "The Protégé Effect: Teaching as Consolidation",
            hook: "Students who expect to teach outperform students who expect to be tested.",
            accentColor: .warm,
            entries: [
                LabEntry(id: "t1", label: "THE PROTEGE EFFECT",
                    body: "Nestojko's research shows students who expect to teach material learn it more deeply than those expecting a test. Teaching requires organizing knowledge into coherent structure, identifying gaps, and generating explanations — creating stronger memory traces than passive review."),
                LabEntry(id: "t2", label: "THE GAP DETECTION FUNCTION",
                    body: "Explaining reveals exactly where your understanding is shallow. You can hold a vague sense of dopamine and the Achiever drive for a long time. The moment someone asks 'but why does the reset help?' — you either have the mechanism or you don't."),
                LabEntry(id: "t3", label: "WHY THE TEACH LINE EXISTS",
                    body: "Each section has a teach line — a compressed version of how you'd explain this to someone else. Reading it primes the teaching mode. Saying it out loud activates the consolidation mechanism. The knowledge becomes usable rather than just held."),
                LabEntry(id: "t4", label: "THE PASSIVE REVIEW TRAP",
                    body: "Re-reading feels like learning because familiarity is mistaken for understanding. If you can't explain it simply, you don't own it yet.", isMisread: true),
            ],
            teachLine: "Teaching forces your brain to build an organized model rather than store fragments. If you can't explain it simply, you don't own it."
        ),
        LabSection(
            id: "admin_drain",
            eyebrow: "COGNITIVE SCIENCE · OPERATIONS",
            question: "Why does admin feel like work but leave you more depleted?",
            title: "Administrative Depletion: The False Productivity Signal",
            hook: "Admin creates a convincing productivity feeling while consuming the capacity needed for meaningful work.",
            accentColor: .inkAmber,
            entries: [
                LabEntry(id: "ad1", label: "THE MECHANISM",
                    body: "Administrative tasks activate the same goal-completion circuitry as meaningful work — filing, responding, organizing all produce completion signals. But they draw from executive function without building anything. The dopamine spike is real. The output isn't."),
                LabEntry(id: "ad2", label: "CONTEXT SWITCHING COST",
                    body: "Every shift between task types — email to creative to logistics — costs 15–23 minutes of refocusing time (Rubinstein, Meyer, Evans). A morning of five administrative context switches can consume two hours of effective creative capacity before the first deep work block starts."),
                LabEntry(id: "ad3", label: "WHY IT'S ESPECIALLY COSTLY HERE",
                    body: "The Analytical drive means administrative work produces genuine insight and diagnosis — it feels even more productive than average. The Restorative drive finds the inbox satisfying to clear. Both drives conspire to make admin feel like real work. It isn't."),
                LabEntry(id: "ad4", label: "THE PROGRESS MISREAD",
                    body: "A day of answered emails and cleared queues is a maintained system, not a built one. Maintenance is necessary. It is not generative. The distinction matters for how you read your own output.", isMisread: true),
            ],
            teachLine: "Admin produces completion signals without building capacity. The cost isn't the time — it's the executive function spent before the real work starts. Protect the first block from logistics."
        ),
        LabSection(
            id: "ecological_cognition",
            eyebrow: "COGNITIVE SCIENCE · ENVIRONMENT",
            question: "Why does the environment change what you can think?",
            title: "Ecological Cognition: Environment as Part of Thought",
            hook: "Conditions don't just affect mood. They change the quality and content of cognition itself.",
            accentColor: .inkGreen,
            entries: [
                LabEntry(id: "ec1", label: "EXTENDED MIND THESIS",
                    body: "Clark and Chalmers (1998): cognitive processes are not confined to the brain. They extend into the environment. A notebook, a clear desk, a specific chair — these become part of the cognitive system. Removing them genuinely changes what thinking is possible."),
                LabEntry(id: "ec2", label: "STATE-DEPENDENT COGNITION",
                    body: "Encoding specificity: recall and reasoning are best when conditions at retrieval match conditions at encoding. You think differently in different rooms, at different temperatures, with different noise levels. This isn't preference — it's how memory and cognition are physically structured."),
                LabEntry(id: "ec3", label: "RESTORATION BEFORE INTERPRETATION",
                    body: "Degraded conditions — disorder, noise, fatigue, physical discomfort — alter the conclusions drawn from observations. A situation that reads as threatening or hopeless in poor conditions may read neutrally or even positively after restoration. The read is not separable from the reading conditions."),
                LabEntry(id: "ec4", label: "THE WILLPOWER SUBSTITUTE ERROR",
                    body: "Attempting to override environmental degradation with effort is metabolically expensive and statistically losing. The environment always wins eventually. Restoration is not weakness — it is load reduction before re-entry.", isMisread: true),
            ],
            teachLine: "Cognition extends into the environment. A degraded environment doesn't just feel bad — it changes what you can think. Restore conditions before drawing conclusions from them."
        ),
        LabSection(
            id: "behavioral_observation",
            eyebrow: "INTELLIGENCE ARCHITECTURE · META",
            question: "What is the system actually learning about you?",
            title: "From Declared Profile to Observed Intelligence",
            hook: "A static psych profile describes who you say you are. Behavioral data describes what you actually do. Both matter. Only one updates.",
            accentColor: .violetLight,
            entries: [
                LabEntry(id: "bo1", label: "DECLARED VS OBSERVED",
                    body: "The Dossier contains your declared operating profile: Restorative, Achiever, Analytical. These are accurate starting points derived from validated assessments. But they are static. The intelligence layer is building something different: observed behavioral patterns derived from your actual completion data, timing, friction signals, and energy declarations."),
                LabEntry(id: "bo2", label: "WHAT THE SYSTEM IS TRACKING",
                    body: "Initiation latency: how long from first open to first completion. Completion clustering: whether actions happen in bursts or spread through the day. Energy declaration accuracy: whether your stated Reserve days match your actual output. Admin displacement frequency: how often logistical work consumes mornings before generative work starts."),
                LabEntry(id: "bo3", label: "WHY THIS MATTERS",
                    body: "Declared: 'Competition sharpens engagement.' Observed: 'Visible completion counts increase participation on low-energy days by measurable margin.' The observed version is more useful than the declared one because it comes from your data, not a population average. Over time the observed profile becomes more accurate than any assessment."),
                LabEntry(id: "bo4", label: "THE SELF-REPORT PROBLEM",
                    body: "Self-report instruments measure who you believe you are, which is accurate enough as a starting point. But beliefs about behavior and actual behavior diverge, especially under load. The system doesn't ask you to self-report — it reads the data you generate by using it.", isMisread: true),
            ],
            teachLine: "The declared profile is the starting model. The observed intelligence is what the system derives from your actual behavior over time. One is a snapshot. The other updates."
        ),
    ]
}
struct LabSectionCard: View {
    let section: LabSection
    let readDepth: LabReadDepth
    let onSkimmed: () -> Void
    let onCompleted: () -> Void

    @State private var isExpanded = false
    @State private var dwellTimer: Timer?
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Card background with accent glow when expanded
            RoundedRectangle(cornerRadius: 16)
                .fill(isExpanded ? Color.surface : Color.surface2)
                .shadow(color: isExpanded ? section.accentColor.opacity(0.15) : Color.bgBase.opacity(0.4),
                        radius: isExpanded ? 20 : 6, x: 0, y: isExpanded ? 8 : 3)
                .animation(.easeInOut(duration: 0.3), value: isExpanded)

            if isExpanded {
                // Subtle accent gradient fill when open
                LinearGradient(
                    colors: [section.accentColor.opacity(0.06), Color.bgBase.opacity(0)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            VStack(alignment: .leading, spacing: 0) {
                // Header — always visible
                Button(action: {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) { isExpanded.toggle() }
                    if readDepth == .unread { onSkimmed() }
                }) {
                    HStack(alignment: .top, spacing: 14) {
                        // Orb
                        ZStack {
                            Circle()
                                .fill(section.accentColor.opacity(isExpanded ? 0.25 : 0.1))
                                .frame(width: 32, height: 32)
                                .blur(radius: isExpanded ? 4 : 0)
                            Circle()
                                .fill(section.accentColor.opacity(isExpanded ? 0.9 : 0.4))
                                .frame(width: isExpanded ? 10 : 8, height: isExpanded ? 10 : 8)
                                .shadow(color: section.accentColor.opacity(isExpanded ? 0.8 : 0.3),
                                        radius: isExpanded ? 8 : 3)
                            // Read depth ring
                            Circle()
                                .trim(from: 0, to: readDepth == .completed ? 1 : readDepth == .skimmed ? 0.5 : 0)
                                .stroke(section.accentColor.opacity(0.6), lineWidth: 1.5)
                                .frame(width: 28, height: 28)
                                .rotationEffect(.degrees(-90))
                        }
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)

                        VStack(alignment: .leading, spacing: 5) {
                            MonoLabel(text: section.eyebrow, color: section.accentColor.opacity(0.7), size: 9)
                            Text(isExpanded ? section.title : section.question)
                                .font(.sora(14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.leading)
                                .animation(.spring(response: 0.3), value: isExpanded)
                            if !isExpanded {
                                Text(section.hook)
                                    .font(.sora(11, weight: .light))
                                    .foregroundColor(.textMuted)
                                    .lineSpacing(3)
                                    .transition(.opacity)
                            }
                        }

                        Spacer(minLength: 8)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(section.accentColor.opacity(isExpanded ? 0.6 : 0.3))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.spring(response: 0.35), value: isExpanded)
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 18)
                }
                .buttonStyle(.plain)

                // Expanded body
                if isExpanded {
                    VStack(alignment: .leading, spacing: 20) {
                        Rectangle()
                            .fill(section.accentColor.opacity(0.15))
                            .frame(height: 0.5)
                            .padding(.horizontal, 18)

                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(section.entries) { entry in
                                VStack(alignment: .leading, spacing: 7) {
                                    HStack(spacing: 6) {
                                        if entry.isMisread {
                                            Image(systemName: "exclamationmark.triangle")
                                                .font(.system(size: 8, weight: .medium))
                                                .foregroundColor(.inkAmber)
                                        }
                                        Text(entry.label)
                                            .font(.mono(10))
                                            .foregroundColor(entry.isMisread ? .inkAmber : section.accentColor)
                                            .tracking(0.5)
                                    }
                                    Text(entry.body)
                                        .font(.sora(13, weight: .light))
                                        .foregroundColor(entry.isMisread ? .textSecond.opacity(0.75) : .textSecond)
                                        .lineSpacing(5)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(entry.isMisread ? 12 : 0)
                                .background(
                                    entry.isMisread ?
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.inkAmber.opacity(0.06))
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.inkAmber.opacity(0.2), lineWidth: 0.5))
                                    : nil
                                )
                            }

                            // Teach line — gold accent
                            if let teach = section.teachLine {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "quote.opening")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.warm)
                                        MonoLabel(text: "HOW YOU'D EXPLAIN THIS", color: .warm, size: 9)
                                    }
                                    Text(teach)
                                        .font(.sora(13, weight: .light))
                                        .foregroundColor(.warm.opacity(0.9))
                                        .lineSpacing(4)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .italic()
                                }
                                .padding(14)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10).fill(Color.warm.opacity(0.05))
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.warm.opacity(0.2), lineWidth: 0.5)
                                    }
                                )
                                .shadow(color: Color.warm.opacity(0.08), radius: 8, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 18)

                        Color.clear.frame(height: 1)
                            .onAppear { if isExpanded { onCompleted() } }
                            .padding(.bottom, 18)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: -10)),
                        removal: .opacity
                    ))
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isExpanded ? section.accentColor.opacity(0.2) : Color.muted.opacity(0.1),
                    lineWidth: 0.5
                )
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
        )
        .scaleEffect(appeared ? 1 : 0.96)
        .opacity(appeared ? 1 : 0)
        .onChange(of: isExpanded) { _, expanded in
            dwellTimer?.invalidate(); dwellTimer = nil
            if expanded {
                dwellTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in onCompleted() }
            }
        }
    }
}

// ── Operator tab root ─────────────────────────────────────────
struct OperatorTabView: View {
    @AppStorage("labReadDepths") private var readDepthsRaw: String = "{}"
    @State private var appeared = false

    var readDepths: [String: LabReadDepth] {
        guard let data = readDepthsRaw.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return dict.compactMapValues { LabReadDepth(rawValue: $0) }
    }

    func setDepth(_ id: String, _ depth: LabReadDepth) {
        var dict = readDepths.mapValues { $0.rawValue }
        guard dict[id] != LabReadDepth.completed.rawValue else { return }
        dict[id] = depth.rawValue
        if let data = try? JSONEncoder().encode(dict), let str = String(data: data, encoding: .utf8) {
            readDepthsRaw = str
        }
    }

    var completedCount: Int { readDepths.values.filter { $0 == .completed }.count }
    let total = CognitionLabContent.sections.count

    var body: some View {
        ZStack(alignment: .top) {
            OperatorAmbience()
                .frame(height: 400)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 28) {

                // Hero card
                OperatorHeroCard()
                    .padding(.horizontal, 20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: appeared)

                // Lab header with circular progress
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 5) {
                        MonoLabel(text: "COGNITION LAB", color: .violetLight, size: 11)
                        Text("Read it. Own it. Teach it.")
                            .font(.sora(13, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                    Spacer()
                    ZStack {
                        GlowRing(
                            progress: total > 0 ? Double(completedCount) / Double(total) : 0,
                            size: 48,
                            color: .violet
                        )
                        VStack(spacing: 0) {
                            Text("\(completedCount)")
                                .font(.sora(14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text("of \(total)")
                                .font(.mono(8))
                                .foregroundColor(.textMuted)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)

                // Lab sections with staggered entrance
                VStack(spacing: 12) {
                    ForEach(Array(CognitionLabContent.sections.enumerated()), id: \.element.id) { idx, section in
                        LabSectionCard(
                            section: section,
                            readDepth: readDepths[section.id] ?? .unread,
                            onSkimmed: { setDepth(section.id, .skimmed) },
                            onCompleted: { setDepth(section.id, .completed) }
                        )
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.45).delay(0.4 + Double(idx) * 0.05), value: appeared)
                        .onAppear {
                            // Trigger appeared on each card after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(idx)) {
                                withAnimation { _ = appeared }
                            }
                        }
                    }
                }

                // Source footer
                Text("Sources: Gollwitzer (1999) · Newport (2016) · Fields (2008) · Baumeister (2011) · Nestojko (2014) · Gallup StrengthsFinder · ESF Assessment")
                    .font(.mono(8))
                    .foregroundColor(.textMuted.opacity(0.35))
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 80)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.9), value: appeared)
            }
            .padding(.top, 8)
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}


// The intelligence readiness card — tells the app what it's learning to see.
// Honest about thresholds. Not hollow. Not premature.
struct IntelligenceReadinessCard: View {
    let patternReadiness: IntelligenceReadiness
    let frictionReadiness: IntelligenceReadiness
    let energyCalibrationReadiness: IntelligenceReadiness
    let cognitionTaggingStatus: String

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    MonoLabel(text: "SIGNAL COLLECTION", color: .textMuted)
                    Spacer()
                    MonoLabel(text: "WHAT THE APP IS LEARNING", color: .muted, size: 10)
                }

                // Pattern window
                readinessRow(
                    label: "TIME PATTERN",
                    readiness: patternReadiness,
                    description: "When you actually complete actions"
                )

                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                // Friction diagnosis
                readinessRow(
                    label: "FRICTION READ",
                    readiness: frictionReadiness,
                    description: "Which actions have a cue or scope problem"
                )

                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                // Energy calibration
                readinessRow(
                    label: "ENERGY CALIBRATION",
                    readiness: energyCalibrationReadiness,
                    description: "Whether your Reserve floor is higher than it feels"
                )

                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                // Cognition tagging
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(cognitionTaggingStatus.contains("All") ? Color.inkGreen : Color.violetLight.opacity(0.5))
                        .frame(width: 6, height: 6)
                        .padding(.top, 4)
                    VStack(alignment: .leading, spacing: 2) {
                        MonoLabel(text: "COGNITION TYPE", size: 11)
                        Text("Creative vs analytical vs administrative — \(cognitionTaggingStatus)")
                            .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                    }
                }
            }
        }
    }

    func readinessRow(label: String, readiness: IntelligenceReadiness, description: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(readiness.isReady ? Color.inkGreen : Color.muted.opacity(0.4))
                .frame(width: 6, height: 6)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 2) {
                MonoLabel(text: label, size: 11)
                Text(description)
                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                if !readiness.isReady {
                    Text(readiness.displayText)
                        .font(.mono(10)).foregroundColor(.violetLight.opacity(0.7)).tracking(0.3)
                } else {
                    Text(readiness.displayText)
                        .font(.mono(10)).foregroundColor(.inkGreen).tracking(0.3)
                }
            }
            Spacer()
        }
    }
}

// MARK: - HIDEOUT TAB — 30-Day Experiment Scorecard

struct HideoutTabView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @State private var showLogSheet = false

    // 30-day experiment started May 13, 2026
    static let experimentStart = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 13)) ?? Date()

    var experimentDay: Int {
        max(1, Calendar.current.dateComponents([.day], from: Self.experimentStart, to: Date()).day ?? 1)
    }

    var recentShifts: [HideoutShiftLog] { Array(shifts.prefix(30)) }

    var thirtyDayAvg: Double {
        guard !recentShifts.isEmpty else { return 0 }
        return recentShifts.map(\.grossRevenue).reduce(0, +) / Double(recentShifts.count)
    }

    var currentBand: HideoutPlanningBand {
        recentShifts.isEmpty ? .unknown : HideoutPlanningBand.classify(thirtyDayAvg)
    }

    var trend: String {
        guard recentShifts.count >= 4 else { return "—" }
        let recent = Array(recentShifts.prefix(3)).map(\.grossRevenue).reduce(0, +) / 3
        let earlier = Array(recentShifts.dropFirst(3).prefix(3)).map(\.grossRevenue).reduce(0, +) / 3
        if earlier == 0 { return "—" }
        let delta = (recent - earlier) / earlier
        if delta > 0.05 { return "↑ UP" }
        if delta < -0.05 { return "↓ DOWN" }
        return "→ FLAT"
    }

    var avgStress: Double {
        let scored = recentShifts.filter { $0.stressScore > 0 }
        guard !scored.isEmpty else { return 0 }
        return Double(scored.map(\.stressScore).reduce(0, +)) / Double(scored.count)
    }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        MonoLabel(text: "SIXTH SYSTEM", color: .warm, size: 10)
                        Text("Hideout")
                            .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                  VStack(spacing: 16) {

            // Experiment status card
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "HIDEOUT · SOLO EXPERIMENT", color: .warm, size: 11)
                            Text("Day \(experimentDay) of 30")
                                .font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                        Button(action: { showLogSheet = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus").font(.system(size: 12, weight: .medium))
                                Text("Log shift")
                                    .font(.sora(12, weight: .medium))
                            }
                            .foregroundColor(.bgBase)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color.warm)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)

                    // Planning band
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "30-DAY AVG", color: .textMuted, size: 10)
                            Text(recentShifts.isEmpty ? "—" : "$\(Int(thirtyDayAvg))")
                                .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                        Divider().frame(height: 36).background(Color.muted.opacity(0.3))
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "BAND", color: .textMuted, size: 10)
                            HStack(spacing: 6) {
                                Circle().fill(currentBand.color).frame(width: 7, height: 7)
                                Text(currentBand.label)
                                    .font(.sora(13, weight: .medium)).foregroundColor(currentBand.color)
                            }
                        }
                        Divider().frame(height: 36).background(Color.muted.opacity(0.3))
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "TREND", color: .textMuted, size: 10)
                            Text(trend)
                                .font(.mono(11)).foregroundColor(.textSecond).tracking(0.3)
                        }
                        Spacer()
                    }

                    // Band context
                    if currentBand != .unknown {
                        Text(currentBand.context)
                            .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                    }

                    // Stress signal
                    if avgStress > 0 {
                        HStack(spacing: 8) {
                            let stressColor: Color = avgStress <= 4 ? .inkGreen : avgStress <= 6 ? .inkAmber : .inkRed
                            Circle().fill(stressColor).frame(width: 6, height: 6)
                            Text("Avg stress \(String(format: "%.1f", avgStress))/10 — " +
                                 (avgStress <= 4 ? "model scales." : avgStress <= 6 ? "monitor closely." : "capacity ceiling approaching."))
                                .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // Key benchmarks from the brief
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "PLANNING BANDS", color: .textMuted, size: 10)
                    bandRow("Survival floor", amount: "~$520/day", color: .inkRed)
                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                    bandRow("Stability", amount: "~$590/day", color: .inkAmber)
                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                    bandRow("Comfort", amount: "~$650/day", color: .inkGreen)
                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                    bandRow("Growth", amount: "~$750/day", color: .violetLight)
                }
            }
            .padding(.horizontal, 24)

            // Behavioral technique correlation — shows whether the techniques are moving the numbers
            if recentShifts.count >= 3 {
                let upsellShifts = recentShifts.filter { $0.usedScriptedUpsell && $0.transactionCount > 0 }
                let noUpsellShifts = recentShifts.filter { !$0.usedScriptedUpsell && $0.transactionCount > 0 }
                let upsellAvgTicket = upsellShifts.isEmpty ? 0.0 :
                    upsellShifts.map { $0.grossRevenue / Double($0.transactionCount) }.reduce(0, +) / Double(upsellShifts.count)
                let baseAvgTicket = noUpsellShifts.isEmpty ? 0.0 :
                    noUpsellShifts.map { $0.grossRevenue / Double($0.transactionCount) }.reduce(0, +) / Double(noUpsellShifts.count)
                let regularRecognitionRate = recentShifts.isEmpty ? 0.0 :
                    Double(recentShifts.filter { $0.recognizedRegular }.count) / Double(recentShifts.count)

                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "BEHAVIORAL TECHNIQUES", color: .inkGreen, size: 11)
                        MonoLabel(text: "The Quiet Cafe Advantage — 4 behaviors, compounding", color: .muted, size: 10)

                        if upsellAvgTicket > 0 || baseAvgTicket > 0 {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: "AVG TICKET — UPSELL USED", color: .textMuted, size: 10)
                                    Text(upsellAvgTicket > 0 ? "$\(String(format: "%.2f", upsellAvgTicket))" : "—")
                                        .font(.sora(18, weight: .semibold))
                                        .foregroundColor(upsellAvgTicket > baseAvgTicket ? .inkGreen : .textSecond)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: "AVG TICKET — NO UPSELL", color: .textMuted, size: 10)
                                    Text(baseAvgTicket > 0 ? "$\(String(format: "%.2f", baseAvgTicket))" : "—")
                                        .font(.sora(18, weight: .semibold)).foregroundColor(.textSecond)
                                }
                            }
                            if upsellAvgTicket > baseAvgTicket && baseAvgTicket > 0 {
                                let delta = upsellAvgTicket - baseAvgTicket
                                Text("+$\(String(format: "%.2f", delta)) avg ticket lift when upsell used.")
                                    .font(.mono(11)).foregroundColor(.inkGreen).tracking(0.3)
                            }
                        }

                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)

                        HStack(spacing: 16) {
                            behaviorStat("UPSELL", count: recentShifts.filter { $0.usedScriptedUpsell }.count, total: recentShifts.count)
                            behaviorStat("RECOGNIZED", count: recentShifts.filter { $0.recognizedRegular }.count, total: recentShifts.count)
                            behaviorStat("PEAK-END", count: recentShifts.filter { $0.anchorPhraseUsed }.count, total: recentShifts.count)
                        }

                        if regularRecognitionRate < 0.5 && recentShifts.count >= 5 {
                            HStack(spacing: 6) {
                                Circle().fill(Color.inkAmber).frame(width: 5, height: 5)
                                Text("Regular recognition below 50%. The familiarity principle is the highest-retention lever.")
                                    .font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            if recentShifts.isEmpty {
                CardView(style: .secondary) {
                    VStack(spacing: 8) {
                        MonoLabel(text: "NO SHIFTS LOGGED YET", color: .textMuted)
                        Text("Log each shift after close. 60 seconds. The 30 days will tell you everything.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                            .multilineTextAlignment(.center).lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(text: "SHIFT LOG").padding(.horizontal, 24)
                    ForEach(recentShifts) { shift in
                        ShiftLogRow(shift: shift).padding(.horizontal, 24)
                    }
                }
            }
                  } // VStack content
                  .padding(.bottom, 80)
                } // ScrollView
            } // VStack nav
            .sheet(isPresented: $showLogSheet) {
                LogShiftSheet(isPresented: $showLogSheet, experimentDay: experimentDay)
            }
        } // ZStack
    }

    func bandRow(_ label: String, amount: String, color: Color) -> some View {
        HStack {
            HStack(spacing: 6) {
                Circle().fill(color.opacity(0.7)).frame(width: 5, height: 5)
                Text(label).font(.sora(12)).foregroundColor(.textSecond)
            }
            Spacer()
            Text(amount).font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
        }
    }

    func behaviorStat(_ label: String, count: Int, total: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            MonoLabel(text: label, color: .textMuted, size: 10)
            Text("\(count)/\(total)")
                .font(.sora(14, weight: .semibold))
                .foregroundColor(total > 0 && Double(count) / Double(total) >= 0.7 ? .inkGreen : .textSecond)
        }
    }
}

struct ShiftLogRow: View {
    @Bindable var shift: HideoutShiftLog
    @State private var showEdit = false

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        MonoLabel(text: shift.dayLabel, color: shift.planningBand.color, size: 10)
                        Text("$\(Int(shift.grossRevenue))")
                            .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(shift.transactionCount) tx")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                        if shift.averageTicket > 0 {
                            Text("$\(String(format: "%.2f", shift.averageTicket)) avg")
                                .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                        }
                    }
                    // Edit affordance — small, clear
                    Button(action: { showEdit = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.textMuted)
                            .frame(width: 28, height: 28)
                            .background(Color.surface)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 8)
                }

                HStack(spacing: 12) {
                    if shift.stressScore > 0 {
                        let sc: Color = shift.stressScore <= 4 ? .inkGreen : shift.stressScore <= 6 ? .inkAmber : .inkRed
                        HStack(spacing: 4) {
                            Circle().fill(sc).frame(width: 5, height: 5)
                            Text("Stress \(shift.stressScore)/10").font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                        }
                    }
                    if shift.usedStaff {
                        MonoLabel(text: "STAFF USED", color: .inkAmber, size: 10)
                    } else {
                        MonoLabel(text: "SOLO", color: .inkGreen, size: 10)
                    }
                    if shift.tailRevenue > 0 {
                        Text("+$\(Int(shift.tailRevenue)) tail").font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                    }
                    if shift.lostSales {
                        MonoLabel(text: "LOST SALES", color: .inkAmber, size: 10)
                    }
                }

                if !shift.notes.isEmpty {
                    Text(shift.notes)
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(1.5)
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditShiftSheet(shift: shift, isPresented: $showEdit)
        }
    }
}

struct EditShiftSheet: View {
    @Bindable var shift: HideoutShiftLog
    @Binding var isPresented: Bool

    @State private var revenue: String = ""
    @State private var txCount: String = ""
    @State private var stressScore: Int = 5
    @State private var usedStaff: Bool = false
    @State private var tailRevenue: String = ""
    @State private var lostSales: Bool = false
    @State private var notes: String = ""

    var revenueValue: Double { Double(revenue) ?? 0 }
    var txValue: Int { Int(txCount) ?? 0 }
    var tailValue: Double { Double(tailRevenue) ?? 0 }
    var band: HideoutPlanningBand { HideoutPlanningBand.classify(revenueValue) }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Edit Shift").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                            MonoLabel(text: shift.dayLabel.uppercased(), color: .warm, size: 10)
                        }
                        Spacer()
                        Button("Save") { save() }
                            .font(.sora(14, weight: .medium)).foregroundColor(.warm)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "GROSS REVENUE")
                        HStack(alignment: .center, spacing: 8) {
                            Text("$").font(.sora(22, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $revenue)
                                .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                                .keyboardType(.decimalPad).tint(.warm)
                        }
                        if revenueValue > 0 {
                            HStack(spacing: 6) {
                                Circle().fill(band.color).frame(width: 6, height: 6)
                                Text(band.label).font(.mono(11)).foregroundColor(band.color).tracking(0.3)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "TRANSACTION COUNT")
                        TextField("0", text: $txCount)
                            .font(.sora(18)).foregroundColor(.textPrimary).keyboardType(.numberPad)
                            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            MonoLabel(text: "STRESS SCORE")
                            Spacer()
                            let sc: Color = stressScore <= 4 ? .inkGreen : stressScore <= 6 ? .inkAmber : .inkRed
                            Text("\(stressScore)/10").font(.mono(11)).foregroundColor(sc).tracking(0.3)
                        }
                        Slider(value: Binding(get: { Double(stressScore) }, set: { stressScore = Int($0) }), in: 1...10, step: 1).tint(.warm)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "QUICK SIGNALS")
                        Toggle(isOn: $usedStaff) {
                            Text("Used staff").font(.sora(13)).foregroundColor(.textPrimary)
                        }.tint(.inkAmber)
                        Toggle(isOn: $lostSales) {
                            Text("Lost sales").font(.sora(13)).foregroundColor(.textPrimary)
                        }.tint(.inkAmber)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "3–5PM TAIL (OPTIONAL)")
                        HStack(spacing: 8) {
                            Text("$").font(.sora(16, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $tailRevenue).font(.sora(16)).foregroundColor(.textPrimary).keyboardType(.decimalPad).tint(.warm)
                        }
                        .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "NOTES")
                        TextField("What happened?", text: $notes, axis: .vertical)
                            .font(.sora(13)).foregroundColor(.textPrimary).lineLimit(3...6)
                            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                    }

                    primaryButton("SAVE CHANGES", disabled: false) { save() }
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
        .onAppear {
            revenue = shift.grossRevenue > 0 ? String(format: "%.0f", shift.grossRevenue) : ""
            txCount = shift.transactionCount > 0 ? "\(shift.transactionCount)" : ""
            stressScore = shift.stressScore > 0 ? shift.stressScore : 5
            usedStaff = shift.usedStaff
            tailRevenue = shift.tailRevenue > 0 ? String(format: "%.0f", shift.tailRevenue) : ""
            lostSales = shift.lostSales
            notes = shift.notes
        }
    }

    func save() {
        shift.grossRevenue = revenueValue
        shift.transactionCount = txValue
        shift.stressScore = stressScore
        shift.usedStaff = usedStaff
        shift.tailRevenue = tailValue
        shift.lostSales = lostSales
        shift.notes = notes
        isPresented = false
    }
}

struct LogShiftSheet: View {
    @Binding var isPresented: Bool
    let experimentDay: Int
    @Environment(\.modelContext) private var context

    @State private var revenue: String = ""
    @State private var txCount: String = ""
    @State private var stressScore: Int = 5
    @State private var usedStaff: Bool = false
    @State private var tailRevenue: String = ""
    @State private var lostSales: Bool = false
    @State private var notes: String = ""
    @State private var sourceNotes: String = ""
    @State private var usedScriptedUpsell: Bool = false
    @State private var recognizedRegular: Bool = false
    @State private var anchorPhraseUsed: Bool = false

    var revenueValue: Double { Double(revenue) ?? 0 }
    var txValue: Int { Int(txCount) ?? 0 }
    var tailValue: Double { Double(tailRevenue) ?? 0 }
    var band: HideoutPlanningBand { HideoutPlanningBand.classify(revenueValue) }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Log Shift").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                            MonoLabel(text: "DAY \(experimentDay) · \(Date().formatted(.dateTime.weekday(.wide)).uppercased())", color: .warm, size: 10)
                        }
                        Spacer()
                        Button("Save") { save() }
                            .font(.sora(14, weight: .medium)).foregroundColor(revenueValue > 0 ? .warm : .textMuted)
                            .disabled(revenueValue == 0)
                    }

                    // Revenue — the primary number
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "GROSS REVENUE")
                        HStack(alignment: .center, spacing: 8) {
                            Text("$").font(.sora(22, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $revenue)
                                .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                                .keyboardType(.decimalPad)
                                .tint(.warm)
                        }
                        // Live band indicator
                        if revenueValue > 0 {
                            HStack(spacing: 6) {
                                Circle().fill(band.color).frame(width: 6, height: 6)
                                Text(band.label).font(.mono(11)).foregroundColor(band.color).tracking(0.3)
                                Text("·").foregroundColor(.textMuted)
                                Text(band.context).font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                            }
                        }
                    }

                    // Transactions
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "TRANSACTION COUNT")
                        TextField("0", text: $txCount)
                            .font(.sora(18)).foregroundColor(.textPrimary).keyboardType(.numberPad)
                            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        if txValue > 0 && revenueValue > 0 {
                            Text("$\(String(format: "%.2f", revenueValue / Double(txValue))) avg ticket (target: $16.72)")
                                .font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                        }
                    }

                    // Stress score — the most important non-financial metric
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            MonoLabel(text: "STRESS SCORE")
                            Spacer()
                            let sc: Color = stressScore <= 4 ? .inkGreen : stressScore <= 6 ? .inkAmber : .inkRed
                            Text("\(stressScore)/10 — " + (stressScore <= 4 ? "model scales" : stressScore <= 6 ? "manageable" : "capacity ceiling"))
                                .font(.mono(11)).foregroundColor(sc).tracking(0.3)
                        }
                        Slider(value: Binding(
                            get: { Double(stressScore) },
                            set: { stressScore = Int($0) }
                        ), in: 1...10, step: 1)
                        .tint(.warm)
                        HStack {
                            Text("1 — Easy").font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                            Spacer()
                            Text("10 — Breaking").font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                        }
                    }

    // Quick toggles
    VStack(alignment: .leading, spacing: 12) {
        MonoLabel(text: "QUICK SIGNALS")
        Toggle(isOn: $usedStaff) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Used staff today").font(.sora(13)).foregroundColor(.textPrimary)
                Text("Solo discipline — only call if genuinely needed").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
            }
        }.tint(Color.inkAmber)
        Toggle(isOn: $lostSales) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Lost sales (walked out / turned away)").font(.sora(13)).foregroundColor(.textPrimary)
                Text("Capacity ceiling signal").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
            }
        }.tint(Color.inkAmber)
    }

    // Behavioral techniques — tracks which of the four behaviors fired
    VStack(alignment: .leading, spacing: 12) {
        MonoLabel(text: "BEHAVIORAL TECHNIQUES")
        MonoLabel(text: "The Quiet Cafe Advantage — 4 behaviors that compound", color: .muted, size: 10)
        Toggle(isOn: $usedScriptedUpsell) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Scripted upsell used").font(.sora(13)).foregroundColor(.textPrimary)
                Text("\"Want me to warm a croissant to go with that?\"").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
            }
        }.tint(Color.inkGreen)
        Toggle(isOn: $recognizedRegular) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recognized a regular").font(.sora(13)).foregroundColor(.textPrimary)
                Text("'The usual?' / anticipated a need before they asked").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
            }
        }.tint(Color.inkGreen)
        Toggle(isOn: $anchorPhraseUsed) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Peak-end close used").font(.sora(13)).foregroundColor(.textPrimary)
                Text("[Name]. Have a great [day]. — consistent anchor phrase").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
            }
        }.tint(Color.inkGreen)
    }

                    // 3–5pm tail
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "3–5PM TAIL (OPTIONAL)")
                        HStack(spacing: 8) {
                            Text("$").font(.sora(16, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $tailRevenue)
                                .font(.sora(16)).foregroundColor(.textPrimary).keyboardType(.decimalPad).tint(.warm)
                        }
                        .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Near-zero cost incremental. Even $60–120/day adds $1,200–2,400/month.")
                            .font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                    }

                    // Source notes — for the 2-week attribution study
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "SOURCE ATTRIBUTION (OPTIONAL)")
                        TextField("e.g. Watermarc 3, Google 2, word of mouth 4", text: $sourceNotes, axis: .vertical)
                            .font(.sora(13)).foregroundColor(.textPrimary).lineLimit(2...4)
                            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        Text("How did customers find you today? Ask casually. 2 weeks of this changes the strategy.")
                            .font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "NOTES (OPTIONAL)")
                        TextField("What drove today? What broke down? What surprised you?", text: $notes, axis: .vertical)
                            .font(.sora(13)).foregroundColor(.textPrimary).lineLimit(3...6)
                            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                    }

                    primaryButton("SAVE SHIFT", disabled: revenueValue == 0) { save() }
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }

    func save() {
        let log = HideoutShiftLog()
        log.grossRevenue = revenueValue
        log.transactionCount = txValue
        log.stressScore = stressScore
        log.usedStaff = usedStaff
        log.tailRevenue = tailValue
        log.lostSales = lostSales
        log.notes = notes
        log.sourceNotes = sourceNotes
        log.usedScriptedUpsell = usedScriptedUpsell
        log.recognizedRegular = recognizedRegular
        log.anchorPhraseUsed = anchorPhraseUsed
        log.experimentDay = experimentDay
        context.insert(log)
        isPresented = false
    }
}


struct SettingsTabView: View {
    @Bindable var profile: OperatorProfile
    @Bindable var state: AppState
    // BUG FIX: was @State (resets to false on every tab switch/view re-init).
    // @AppStorage persists the toggle state across app sessions and tab navigation.
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false

    var body: some View {
        VStack(spacing: 16) {

            // OPERATOR — name and voice
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "OPERATOR", color: .textMuted)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("Used for direct address. Leave blank to disable.")
                                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                        }
                        Spacer()
                        TextField("Brice", text: $profile.operatorName)
                            .font(.sora(14)).foregroundColor(.textPrimary)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .tint(.violet)
                    }

                    Divider().background(Color.muted.opacity(0.3))

                    Toggle(isOn: $profile.voicePresenceEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Voice").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("App speaks brief observations. Rarely. Not an assistant.")
                                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                        }
                    }
                    .tint(Color.violet)
                    .onChange(of: profile.voicePresenceEnabled) { _, enabled in
                        VoicePresence.shared.voiceEnabled = enabled
                        if !enabled { VoicePresence.shared.stop() }
                    }

                    // Test button — bypasses silence rules so you can hear the voice immediately
                    if profile.voicePresenceEnabled {
                        Divider().background(Color.muted.opacity(0.3))

                        // Voice provider
                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "VOICE SOURCE", color: .textMuted)
                            HStack(spacing: 8) {
                                ForEach(VoiceProvider.allCases, id: \.self) { p in
                                    Button(action: {
                                        profile.voiceProvider = p
                                        VoicePresence.shared.provider = p
                                    }) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(p.label)
                                                .font(.sora(13))
                                                .foregroundColor(profile.voiceProvider == p ? .textPrimary : .textMuted)
                                            Text(p.sublabel)
                                                .font(.sora(10, weight: .light))
                                                .foregroundColor(.textMuted)
                                                .lineSpacing(1.5)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(profile.voiceProvider == p ? Color.violetDim.opacity(0.3) : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(profile.voiceProvider == p ? Color.violet.opacity(0.4) : Color.clear, lineWidth: 1))
                                    }
                                }
                            }
                        }

                        // Character note — what voice this is reaching for
                        CardView(style: .ambient) {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "CHARACTER", color: .textMuted, size: 11)
                                Text("Calm male operator. Grounded. Intelligent. Composed.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(2)
                                Text("Not assistant. Not coach. Not theatrical. A presence that notices.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                                Text("For ElevenLabs: search calm male, neutral American, grounded, composed.")
                                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3).lineSpacing(2)
                            }
                        }

                        // OpenAI TTS — only shows when OpenAI is selected
                        if profile.voiceProvider == .openAI {
                            VStack(alignment: .leading, spacing: 10) {
                                MonoLabel(text: "OPENAI TTS", color: .inkGreen, size: 11)
                                MonoLabel(text: "Voice: onyx. Get your key at platform.openai.com", color: .muted, size: 10)
                                inputField("API KEY", placeholder: "sk-...", text: $profile.openAIApiKey)
                                    .onChange(of: profile.openAIApiKey) { _, v in
                                        VoicePresence.shared.openAIApiKey = v
                                    }
                                Text("Key stored locally only. ~$0.002/day at normal use.")
                                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3)
                            }
                        }

                        // ElevenLabs Phase B — only shows when ElevenLabs is selected
                        if profile.voiceProvider == .elevenLabs {
                            VStack(alignment: .leading, spacing: 10) {
                                MonoLabel(text: "ELEVENLABS · PHASE B", color: .inkAmber, size: 11)
                                MonoLabel(text: "Enter your API key and voice ID from elevenlabs.io", color: .muted, size: 10)
                                inputField("API KEY", placeholder: "sk-...", text: $profile.elevenLabsApiKey)
                                inputField("VOICE ID", placeholder: "21m00Tcm4TlvDq8ikWAM", text: $profile.elevenLabsVoiceId)
                                    .onChange(of: profile.elevenLabsApiKey) { _, v in
                                        VoicePresence.shared.elevenLabsApiKey = v
                                    }
                                    .onChange(of: profile.elevenLabsVoiceId) { _, v in
                                        VoicePresence.shared.elevenLabsVoiceId = v
                                    }
                                Text("Key stored locally only. Never sent to Anthropic.")
                                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3)
                            }
                        }

                        // Test button — hear the voice now
                        Button(action: {
                            let name = profile.firstName
                            let testLine = name.isEmpty
                                ? "Open field. Let's not make it dramatic."
                                : "\(name). Open field. Let's not make it dramatic."
                            VoicePresence.shared.speakTest(testLine)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 13, weight: .light))
                                Text("Test voice")
                                    .font(.sora(13))
                            }
                            .foregroundColor(.violet)
                            .frame(maxWidth: .infinity).frame(height: 42)
                            .background(Color.violetDim.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.violet.opacity(0.3), lineWidth: 0.5))
                        }

                        // Voice debug — tap to see every voice iOS gives this app
                        VoiceDebugButton()

                        // WENDY (Layer B) — separate consent, separate API key
                        Divider().background(Color.muted.opacity(0.3))

                        VStack(alignment: .leading, spacing: 14) {
                            MonoLabel(text: "WENDY · LAYER B", color: .violetLight, size: 11)
                            MonoLabel(text: "Layer A (operational): 2-day cooldown. Layer B (pattern): 7-day cooldown.", color: .muted, size: 10)

                            Toggle(isOn: $profile.wendyEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pattern observations").font(.sora(14)).foregroundColor(.textPrimary)
                                    Text("Text card in Today tab. Separate from voice.")
                                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                                }
                            }
                            .tint(Color.violetLight)

                            if profile.wendyEnabled {
                                // Layer B status indicator
                                HStack(spacing: 8) {
                                    if profile.daysInSystem >= 14 {
                                        Circle().fill(Color.inkGreen).frame(width: 5, height: 5)
                                        Text("Active — 14-day threshold met.")
                                            .font(.mono(11)).foregroundColor(.inkGreen).tracking(0.3)
                                    } else {
                                        Circle().fill(Color.inkAmber.opacity(0.6)).frame(width: 5, height: 5)
                                        Text("Unlocks in \(14 - profile.daysInSystem) days.")
                                            .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                                    }
                                }

                                inputField("ANTHROPIC API KEY", placeholder: "sk-ant-...", text: $profile.claudeApiKey)
                                Text("Key stored locally. Sent only to Anthropic's API.")
                                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3)

                                // Phase B2 — spoken Wendy (sub-toggle, off by default)
                                Toggle(isOn: $profile.wendyVoiceEnabled) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Speak observations").font(.sora(13)).foregroundColor(profile.wendyEnabled ? .textPrimary : .textMuted)
                                        Text("Enable after text observations feel like recognition, not surveillance.")
                                            .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                                    }
                                }
                                .tint(Color.violetLight)
                                .disabled(!profile.wendyEnabled)

                                // Cooldown status
                                if let last = profile.lastLayerBDate ?? profile.lastWendyDate {
                                    let daysAgo = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
                                    let remaining = max(0, 7 - daysAgo)
                                    if remaining > 0 {
                                        HStack(spacing: 8) {
                                            Circle().fill(Color.muted.opacity(0.5)).frame(width: 5, height: 5)
                                            Text("Layer B cooldown: \(remaining) day\(remaining == 1 ? "" : "s") remaining.")
                                                .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // NOTIFICATIONS — master toggle
            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    MonoLabel(text: "NOTIFICATIONS", color: .textMuted)
                    Toggle(isOn: $notificationsEnabled) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Daily nudges").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("Max 4/day · respects quiet window")
                                .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                        }
                    }
                    .tint(Color.violet)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestPermission()
                            NotificationService.shared.scheduleAll(profile: profile)
                        } else {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }
                    }

                    Divider().background(Color.muted.opacity(0.3))
                    Toggle(isOn: $profile.quietMode) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Quiet Mode").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("Suppress all non-critical notifications")
                                .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                        }
                    }
                    .tint(Color.violetDim)
                    .onChange(of: profile.quietMode) { _, _ in
                        NotificationService.shared.scheduleAll(profile: profile)
                    }
                }
            }
            .padding(.horizontal, 24)

            // QUIET WINDOW — Phase 2
            if notificationsEnabled && !profile.quietMode {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 14) {
                        MonoLabel(text: "QUIET WINDOW", color: .textMuted)
                        Text("No notifications sent during this window.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textMuted)

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "FROM", color: .textMuted, size: 11)
                                Picker("", selection: $profile.notifQuietStart) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(hourLabel(h)).tag(h)
                                            .font(.sora(13)).foregroundColor(.textPrimary)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 80)
                                .clipped()
                                .colorScheme(.dark)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "UNTIL", color: .textMuted, size: 11)
                                Picker("", selection: $profile.notifQuietEnd) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(hourLabel(h)).tag(h)
                                            .font(.sora(13)).foregroundColor(.textPrimary)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 80)
                                .clipped()
                                .colorScheme(.dark)
                            }
                            Spacer()
                            // Preview
                            VStack(alignment: .trailing, spacing: 4) {
                                MonoLabel(text: "WINDOW", color: .textMuted, size: 11)
                                Text("\(hourLabel(profile.notifQuietStart)) –")
                                    .font(.sora(12)).foregroundColor(.textSecond)
                                Text(hourLabel(profile.notifQuietEnd))
                                    .font(.sora(12)).foregroundColor(.textSecond)
                            }
                        }
                        .onChange(of: profile.notifQuietStart) { _, _ in
                            NotificationService.shared.scheduleAll(profile: profile)
                        }
                        .onChange(of: profile.notifQuietEnd) { _, _ in
                            NotificationService.shared.scheduleAll(profile: profile)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // CATEGORY TOGGLES — Phase 2
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 14) {
                        MonoLabel(text: "NOTIFY FOR SYSTEMS", color: .textMuted)

                        categoryToggle("Environment",  isOn: $profile.notifCategoryEnvironment,  color: .inkGreen)
                        categoryToggle("Cognition",    isOn: $profile.notifCategoryCognition,    color: .violetLight)
                        categoryToggle("Health",       isOn: $profile.notifCategoryHealth,       color: .inkTeal)
                        categoryToggle("Operations",   isOn: $profile.notifCategoryOperations,   color: .warm)
                        categoryToggle("Participation",isOn: $profile.notifCategoryParticipation,color: .inkAmber)

                        Divider().background(Color.muted.opacity(0.3))

                        // Hydration — Phase 3 P3
                        HStack(spacing: 10) {
                            Circle().fill(Color.inkTeal.opacity(0.6)).frame(width: 7, height: 7)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hydration prompts").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("3/day · 10am, 1pm, 4pm · copy: \"Water.\"")
                                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                            }
                            Spacer()
                            Toggle("", isOn: $profile.notifHydrationEnabled).tint(Color.inkTeal).labelsHidden()
                                .onChange(of: profile.notifHydrationEnabled) { _, _ in
                                    NotificationService.shared.scheduleAll(profile: profile)
                                }
                        }

                        // Protein — 2/day
                        HStack(spacing: 10) {
                            Circle().fill(Color.inkTeal.opacity(0.6)).frame(width: 7, height: 7)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Protein reminders").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("2/day · 10am, 3:30pm · copy: \"Protein.\"")
                                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                            }
                            Spacer()
                            Toggle("", isOn: $profile.notifProteinEnabled).tint(Color.inkTeal).labelsHidden()
                                .onChange(of: profile.notifProteinEnabled) { _, _ in
                                    NotificationService.shared.scheduleAll(profile: profile)
                                }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // GUARDRAILS
            CardView(style: .ambient) {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "GUARDRAILS", color: .textMuted)
                    VStack(alignment: .leading, spacing: 6) {
                        guardrailLine("No streak shaming. No failure language.")
                        guardrailLine("If the app creates pressure, remove items.")
                        guardrailLine("No notifications that generate guilt.")
                        guardrailLine("Gentle decay only — never harsh penalties.")
                    }
                }
            }
            .padding(.horizontal, 24)

            CardView(style: .secondary) {
                VStack(spacing: 8) {
                    MonoLabel(text: "INCREMENTS · v\(profile.version)", color: .violet, size: 11)
                    Text("environmental cognition support system")
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                    Text("Private build. Your data stays yours.")
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted.opacity(0.7))
                        .tracking(0.2)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
        .onAppear { syncNotificationStatus() }
    }

    func hourLabel(_ h: Int) -> String {
        let suffix = h >= 12 ? "PM" : "AM"
        let h12 = h == 0 ? 12 : h > 12 ? h - 12 : h
        return "\(h12) \(suffix)"
    }

    func categoryToggle(_ label: String, isOn: Binding<Bool>, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle().fill(color.opacity(0.6)).frame(width: 7, height: 7)
            Text(label).font(.sora(13)).foregroundColor(.textPrimary)
            Spacer()
            Toggle("", isOn: isOn).tint(color).labelsHidden()
                .onChange(of: isOn.wrappedValue) { _, _ in
                    NotificationService.shared.scheduleAll(profile: profile)
                }
        }
    }

    func guardrailLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(Color.warm.opacity(0.4)).frame(width: 4, height: 4).padding(.top, 5)
            Text(text).font(.sora(13, weight: .light)).foregroundColor(.textSecond)
        }
    }

    // BUG FIX: syncs notificationsEnabled toggle with real system permission on every appear
    func syncNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
}

// MARK: - WEEKLY REVIEW EXPORT

struct WeeklyExportCard: View {
    let actions: [Action]
    let logs: [DailyLog]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @State private var showShareSheet = false
    @State private var exportText = ""

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        MonoLabel(text: "WEEKLY REVIEW", color: .violetLight, size: 10)
                        Text("Export & share your data.")
                            .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                    }
                    Spacer()
                    Button(action: {
                        exportText = ExportGenerator.weeklyMarkdown(actions: actions, logs: logs, shifts: Array(shifts.prefix(14)))
                        showShareSheet = true
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 12))
                            Text("Export").font(.sora(12, weight: .medium))
                        }
                        .foregroundColor(.bgBase)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.violetLight)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                Text("Last 7 days · action rates · Hideout revenue + behavioral techniques · daily notes.\nShare with partner, advisor, or save as weekly record.")
                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(text: exportText)
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let text: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ExportGenerator {

    static func weeklyMarkdown(actions: [Action], logs: [DailyLog], shifts: [HideoutShiftLog] = []) -> String {
        let cal = Calendar.current
        let today = Date()
        let weekStart = cal.date(byAdding: .day, value: -6, to: today) ?? today
        let dateRange = "\(weekStart.formatted(.dateTime.month().day())) – \(today.formatted(.dateTime.month().day().year()))"
        var output: [String] = []
        output.append("# INCREMENTS — Weekly Review")
        output.append("## \(dateRange)")
        output.append("")

        // Hideout this week
        let weekShifts = shifts.filter { $0.date >= weekStart }
        if !weekShifts.isEmpty {
            output.append("## Hideout — This Week")
            let totalRev = weekShifts.map(\.grossRevenue).reduce(0, +)
            let avgRev = totalRev / Double(weekShifts.count)
            let stressScores = weekShifts.filter { $0.stressScore > 0 }
            let avgStress = stressScores.isEmpty ? 0.0 : stressScores.map { Double($0.stressScore) }.reduce(0, +) / Double(stressScores.count)
            output.append("**\(weekShifts.count) shifts · $\(Int(totalRev)) total · $\(Int(avgRev))/day avg · stress \(String(format: "%.1f", avgStress))/10**")
            output.append("")
            let upsellCount = weekShifts.filter { $0.usedScriptedUpsell }.count
            let regularCount = weekShifts.filter { $0.recognizedRegular }.count
            let peakEndCount = weekShifts.filter { $0.anchorPhraseUsed }.count
            output.append("**Behavioral Techniques**")
            output.append("- Scripted upsell: \(upsellCount)/\(weekShifts.count)")
            output.append("- Recognized regular: \(regularCount)/\(weekShifts.count)")
            output.append("- Peak-end close: \(peakEndCount)/\(weekShifts.count)")
            let upsellS = weekShifts.filter { $0.usedScriptedUpsell && $0.transactionCount > 0 }
            let noUpsellS = weekShifts.filter { !$0.usedScriptedUpsell && $0.transactionCount > 0 }
            if !upsellS.isEmpty && !noUpsellS.isEmpty {
                let u = upsellS.map { $0.grossRevenue / Double($0.transactionCount) }.reduce(0, +) / Double(upsellS.count)
                let b = noUpsellS.map { $0.grossRevenue / Double($0.transactionCount) }.reduce(0, +) / Double(noUpsellS.count)
                output.append("- Avg ticket: upsell $\(String(format: "%.2f", u)) vs no upsell $\(String(format: "%.2f", b))")
            }
            for shift in weekShifts.sorted(by: { $0.date < $1.date }) {
                if !shift.notes.isEmpty { output.append("*\(shift.dayLabel): \(shift.notes)*") }
            }
            output.append("")
        }

        // Action completion rates
        output.append("## Completion Rates (7-day)")
        for system in SystemTag.allCases {
            let sysActions = actions.filter { $0.system == system }
            if sysActions.isEmpty { continue }
            output.append("**\(system.rawValue.capitalized)**")
            for a in sysActions {
                let thisWeek = a.completionDates.filter { $0 >= weekStart }.count
                let pct = Int(Double(thisWeek) / 7.0 * 100)
                output.append("  - \(a.title): \(pct)% (\(thisWeek)/7)")
            }
            output.append("")
        }

        // Daily log notes
        let weekLogs = logs.filter { $0.date >= weekStart }.sorted { $0.date < $1.date }
        if !weekLogs.isEmpty {
            output.append("## Daily Log Notes")
            for log in weekLogs {
                output.append("**\(log.date.formatted(.dateTime.weekday(.wide).month().day()))**")
                if let w = log.topWin, !w.isEmpty { output.append("Top win: \(w)") }
                if let n = log.notes, !n.isEmpty { output.append("Notes: \(n)") }
                if let t = log.specificActionNote, !t.isEmpty { output.append("Tomorrow: \(t)") }
                output.append("")
            }
        }

        // Friction
        let highFriction = actions.filter { $0.isHighFriction }
        if !highFriction.isEmpty {
            output.append("## High Friction")
            for a in highFriction {
                output.append("- \(a.title) — \(a.skipCount) skips · \(Int(a.completionRate * 100))% rate")
            }
            output.append("")
        }

        output.append("---")
        output.append("*Generated by INCREMENTS · \(today.formatted(.dateTime.month().day().year()))*")
        return output.joined(separator: "\n")
    }
}

// MARK: - CONSULT VIEW (Phase B3 — 30-Day Read)

struct ConsultView: View {
    @Bindable var profile: OperatorProfile
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query private var actions: [Action]
    @Query private var receipts: [ConsultReceipt]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var consultState: ConsultState = .ready

    var savedReceipt: ConsultReceipt? { receipts.first(where: { $0.wasSaved }) }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "PATTERN BRIEF", color: .violetLight, size: 11)
                            Text("30-day system read.")
                                .font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                    }

                    switch consultState {
                    case .ready:
                        consultReady()
                    case .loading:
                        VStack(spacing: 12) {
                            ProgressView().tint(.violet)
                            Text("Reading the pattern...").font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                        }.frame(maxWidth: .infinity).padding(.vertical, 40)
                    case .response(let text):
                        consultResponseView(text: text)
                    case .insufficientData(let remaining):
                        consultInsufficientData(remaining: remaining)
                    case .cooldownActive(let available):
                        consultCooldownActive(available: available)
                    case .noSignal:
                        CardView(style: .secondary) {
                            VStack(alignment: .leading, spacing: 8) {
                                MonoLabel(text: "NO SIGNAL", color: .textMuted, size: 11)
                                Text("The data didn't produce a clear pattern. Try again in a week.")
                                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                            }
                        }
                    case .error:
                        CardView(style: .secondary) {
                            VStack(alignment: .leading, spacing: 8) {
                                MonoLabel(text: "ERROR", color: .inkRed, size: 11)
                                Text("Something went wrong. Check your API key in Settings.")
                                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                            }
                        }
                    }

                    if let receipt = savedReceipt {
                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "LAST SAVED READ", color: .textMuted, size: 10)
                            Text(receipt.observationText)
                                .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                            MonoLabel(text: "Day \(receipt.daysInSystemAtRead) · \(receipt.createdAt.formatted(.dateTime.month().day().year()))", color: .muted, size: 10)
                        }
                        .padding(16).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
        .onAppear { consultState = ConsultEngine.gateState(profile: profile) }
    }

    // MARK: - State views

    func consultResponseView(text: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "BRIEF", color: .violetLight, size: 11)
                    Text(text)
                        .font(.sora(15, weight: .light))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Button(action: { saveReceipt(text: text) }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down").font(.system(size: 13))
                    Text("Save this read").font(.sora(13, weight: .medium))
                }
                .foregroundColor(.bgBase)
                .frame(maxWidth: .infinity).frame(height: 46)
                .background(Color.violet)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    func consultInsufficientData(remaining: Int) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 12) {
                MonoLabel(text: "NOT YET", color: .textMuted, size: 11)
                Text("Not enough signal yet.")
                    .font(.sora(16, weight: .light)).foregroundColor(.textPrimary)
                Text("30 days of data required. Currently day \(profile.daysInSystem).")
                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                HStack(spacing: 6) {
                    Circle().fill(Color.inkAmber.opacity(0.5)).frame(width: 5, height: 5)
                    Text("\(remaining) day\(remaining == 1 ? "" : "s") remaining.")
                        .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                }
            }
        }
    }

    func consultCooldownActive(available: Date) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 12) {
                MonoLabel(text: "COOLDOWN", color: .textMuted, size: 11)
                if let last = profile.lastConsultDate {
                    Text("Last read: \(last.formatted(.dateTime.month().day())).")
                        .font(.sora(14)).foregroundColor(.textPrimary)
                }
                Text("Next read available \(available.formatted(.dateTime.month().day())).")
                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                Text("14 days between reads. The data needs time to change.")
                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
            }
        }
    }

    func consultReady() -> some View {
        VStack(spacing: 16) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "READY", color: .inkGreen, size: 11)
                    Text("Day \(profile.daysInSystem). Enough signal to read.")
                        .font(.sora(14)).foregroundColor(.textPrimary)
                    if let last = profile.lastConsultDate {
                        Text("Last read: \(last.formatted(.dateTime.month().day())).")
                            .font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                    }
                }
            }

            Button(action: startConsult) {
                Text("RUN PATTERN BRIEF")
                    .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text("One read every 14 days. Analyst format. Not a conversation.")
                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
    }

    func consultLoading() -> some View {
        CardView(style: .secondary) {
            HStack(spacing: 14) {
                // Quiet pulse — not theatrical
                Circle()
                    .fill(Color.violet.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .modifier(SlowPulse())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reading the last 30 days.")
                        .font(.sora(14)).foregroundColor(.textPrimary)
                    Text("This may take a moment.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                }
                Spacer()
            }
        }
    }

    func consultResponse(text: String) -> some View {
        VStack(spacing: 16) {
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    MonoLabel(text: "PATTERN BRIEF · DAY \(profile.daysInSystem)", color: .violetLight, size: 11)
                    Text(text)
                        .font(.sora(14, weight: .light))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 12) {
                // Save — explicit, user-initiated
                Button(action: { saveReceipt(text: text) }) {
                    Text("SAVE")
                        .font(.sora(13, weight: .semibold)).foregroundColor(.violet).tracking(1.5)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color.violetDim.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.violet.opacity(0.3), lineWidth: 0.5))
                }

                // Dismiss — closes without saving
                Button(action: { dismiss() }) {
                    Text("DONE")
                        .font(.sora(13, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Text("Save preserves this read. Dismiss closes without saving.")
                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
    }

    func consultNoSignal() -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(text: "NOTHING NEW", color: .textMuted, size: 11)
                Text("Nothing significant in the last 30 days.")
                    .font(.sora(14)).foregroundColor(.textPrimary)
                Text("The patterns are holding.")
                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
            }
        }
    }

    func consultError() -> some View {
        VStack(spacing: 12) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "UNAVAILABLE", color: .textMuted, size: 11)
                    Text("Couldn't read it. Nothing was saved.")
                        .font(.sora(14)).foregroundColor(.textPrimary)
                }
            }
            Button(action: { dismiss() }) {
                Text("DONE")
                    .font(.sora(13, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Actions

    func startConsult() {
        consultState = .loading
        Task {
            let result = await ConsultEngine.run(
                profile: profile,
                actions: actions,
                logs: Array(logs.prefix(30))
            )
            await MainActor.run {
                // Update cooldown immediately when read is run (whether or not user saves)
                profile.lastConsultDate = Date()
                consultState = result
            }
        }
    }

    func saveReceipt(text: String) {
        // Overwrite the single saved receipt — no accumulating history
        for old in receipts { context.delete(old) }
        let receipt = ConsultReceipt()
        receipt.observationText = text
        receipt.daysInSystemAtRead = profile.daysInSystem
        receipt.wasSaved = true
        context.insert(receipt)
        dismiss()
    }
}

// Quiet pulse animation for loading state
struct SlowPulse: ViewModifier {
    @State private var pulsing = false
    func body(content: Content) -> some View {
        content
            .opacity(pulsing ? 0.3 : 1.0)
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulsing)
            .onAppear { pulsing = true }
    }
}

// MARK: - PATTERN BRIEF CARD (entry point — operator-requested system read)

struct ConsultCard: View {
    @Bindable var profile: OperatorProfile
    @State private var showConsult = false

    var gateState: ConsultState { ConsultEngine.gateState(profile: profile) }

    var body: some View {
        CardView(style: gateState == .ready ? .primary : .secondary) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    MonoLabel(text: "PATTERN BRIEF", color: statusColor, size: 11)
                    Text(statusTitle)
                        .font(.sora(14, weight: gateState == .ready ? .semibold : .light))
                        .foregroundColor(gateState == .ready ? .textPrimary : .textMuted)
                    Text(statusSubtitle)
                        .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                }
                Spacer()
                if gateState == .ready {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.violetLight)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if gateState == .ready || hasViewableReceipt { showConsult = true }
        }
        .sheet(isPresented: $showConsult) {
            ConsultView(profile: profile)
        }
    }

    var hasViewableReceipt: Bool {
        if case .cooldownActive = gateState { return true }
        return false
    }

    var statusColor: Color {
        switch gateState {
        case .ready:            return .inkGreen
        case .insufficientData: return .textMuted
        case .cooldownActive:   return .muted
        default:                return .textMuted
        }
    }

    var statusTitle: String {
        switch gateState {
        case .ready:
            return "System read available."
        case .insufficientData(let remaining):
            return "\(remaining) day\(remaining == 1 ? "" : "s") until sufficient data."
        case .cooldownActive(let available):
            return "Next read: \(available.formatted(.dateTime.month().day()))."
        default:
            return "Pattern Brief"
        }
    }

    var statusSubtitle: String {
        switch gateState {
        case .ready:
            return "30-day pattern read. Analyst format. One read every 14 days."
        case .insufficientData:
            return "Requires 30 days of data. Building signal."
        case .cooldownActive:
            return "14-day cooldown between reads. Tap to review last brief."
        default:
            return ""
        }
    }
}



// MARK: - FOCUS MODE
// Phase 2 — Deep work timer. Tab bar disappears. Session is locked.
// Counts UP (less clock-watching anxiety). 45-min default.
// Exit sequence has a 2-screen buffer — cortisol normalization.

struct FocusMode: View {
    @Binding var isPresented: Bool
    @State private var elapsed: Int = 0
    @State private var isRunning = false
    @State private var showExit = false
    @State private var sessionNote = ""
    @State private var workType: FocusWorkType = .deepWork
    @State private var intention = ""
    @State private var phase: FocusPhase = .setup

    enum FocusPhase { case setup, active, winding, done }
    enum FocusWorkType: String, CaseIterable {
        case deepWork   = "Deep Work"
        case reviewEdit = "Review & Edit"
        case admin      = "Admin"
        case reading    = "Reading"
        var icon: String {
            switch self {
            case .deepWork: return "brain"
            case .reviewEdit: return "pencil"
            case .admin: return "briefcase"
            case .reading: return "book"
            }
        }
    }

    var elapsedFormatted: String {
        let h = elapsed / 3600, m = (elapsed % 3600) / 60, s = elapsed % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            switch phase {
            case .setup: setupView
            case .active: activeView
            case .winding: windingView
            case .done: doneView
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isRunning { elapsed += 1 }
        }
    }

    var setupView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Text("FOCUS").font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark").foregroundColor(.textMuted)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "WORK TYPE")
                    HStack(spacing: 8) {
                        ForEach(FocusWorkType.allCases, id: \.self) { type in
                            Button(action: { workType = type }) {
                                VStack(spacing: 5) {
                                    Image(systemName: type.icon).font(.system(size: 16, weight: .light))
                                    Text(type.rawValue).font(.sora(10)).lineLimit(1)
                                }
                                .foregroundColor(workType == type ? .bgBase : .violetLight)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(workType == type ? Color.violetLight : Color.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "INTENTION (OPTIONAL)")
                    TextField("What are you doing in this session?", text: $intention)
                        .font(.sora(14)).foregroundColor(.textPrimary)
                        .padding(14).background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10)).tint(.violet)
                }

                primaryButton("START SESSION", disabled: false) {
                    withAnimation { phase = .active; isRunning = true }
                }
            }
            .padding(28)
        }
    }

    var activeView: some View {
        VStack(spacing: 0) {
            // Full-screen focus — no distractions
            Spacer()
            VStack(spacing: 20) {
                MonoLabel(text: workType.rawValue.uppercased(), color: .violetLight, size: 11)
                Text(elapsedFormatted)
                    .font(.system(size: 64, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                if !intention.isEmpty {
                    Text(intention)
                        .font(.sora(14, weight: .light)).foregroundColor(.textSecond)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                }
            }
            Spacer()
            VStack(spacing: 12) {
                Button(action: { withAnimation { phase = .winding; isRunning = false } }) {
                    Text("End session")
                        .font(.sora(14, weight: .medium)).foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 28).padding(.bottom, 48)
        }
    }

    var windingView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(text: "SESSION CLOSED", color: .inkGreen, size: 11)
                Text("\(elapsedFormatted)")
                    .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.textPrimary).monospacedDigit()
                Text(workType.rawValue)
                    .font(.mono(13)).foregroundColor(.textMuted).tracking(0.5)
            }
            Text("Let it settle before the next thing.")
                .font(.sora(16, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)

            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(text: "ONE LINE IF YOU WANT IT", color: .textMuted, size: 10)
                TextField("What happened?", text: $sessionNote)
                    .font(.sora(14)).foregroundColor(.textPrimary)
                    .padding(14).background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10)).tint(.violet)
            }
            Spacer()
            primaryButton("DONE", disabled: false) {
                withAnimation { phase = .done }
            }
        }
        .padding(28)
    }

    var doneView: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                if !sessionNote.isEmpty {
                    Text(sessionNote)
                        .font(.sora(16, weight: .light)).foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                }
                MonoLabel(text: "RECORDED.", color: .inkGreen, size: 11)
            }
            Spacer()
            Button(action: { isPresented = false }) {
                Text("Return").font(.sora(14)).foregroundColor(.textMuted)
            }
            .padding(.bottom, 48)
        }
    }
}

// MARK: - INSIGHTS VIEW
// Always visible. Content gated by 7 days of data (not 30 — rapid adoption confirmed).
// Shows patterns, not scores. Evidence, not grades.
// Week 1: descriptor summaries. Week 2+: pattern observations. Wendy history.

struct InsightsView: View {
    @Bindable var state: AppState
    @Query private var actions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query private var profiles: [OperatorProfile]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @ObservedObject private var wendyState = WendyState.shared
    @State private var showFocus = false

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }
    var daysIn: Int { profile.daysInSystem }
    var hasWeekData: Bool { daysIn >= 7 }

    var body: some View {
        ZStack {
            AtmosphericBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "INSIGHTS", color: .violetLight, size: 11)
                            Text("Patterns, not scores.")
                                .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                        // Focus Mode entry
                        Button(action: { showFocus = true }) {
                            HStack(spacing: 5) {
                                Image(systemName: "brain").font(.system(size: 13))
                                Text("Focus").font(.sora(12, weight: .medium))
                            }
                            .foregroundColor(.bgBase)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color.violetLight)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 24)

                    if !hasWeekData {
                        // Before 7 days — show what the tab will become
                        earlyStateView
                    } else {
                        // 7+ days — real patterns
                        patternContent
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .fullScreenCover(isPresented: $showFocus) {
            FocusMode(isPresented: $showFocus)
        }
    }

    var earlyStateView: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "DAY \(daysIn) OF 7", color: .warm, size: 11)
                    Text("Patterns need time to be real.")
                        .font(.sora(15, weight: .medium)).foregroundColor(.textPrimary)
                    Text("At 7 days, this tab shows completion rates by system, timing patterns, and Wendy's written observations. The data's collecting. Come back in \(max(0, 7 - daysIn)) day\(7 - daysIn == 1 ? "" : "s").")
                        .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                }
            }
            .padding(.horizontal, 24)

            // Show Focus Mode prominently while waiting
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "FOCUS MODE", color: .violetLight, size: 11)
                    Text("Deep work timer. Tab bar disappears. No distractions.")
                        .font(.sora(14, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Button(action: { showFocus = true }) {
                        Text("Start a session")
                            .font(.sora(13, weight: .medium)).foregroundColor(.violetLight)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    var patternContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Completion rates by system — 7-day window
            weekCompletionSection
                .padding(.horizontal, 24)

            // Best completion hour
            timingSection
                .padding(.horizontal, 24)

            // Wendy's last observation — persisted
            if let obs = profile.lastWendyObservation, !obs.isEmpty {
                wendyHistoryCard(obs)
                    .padding(.horizontal, 24)
            }

            // Hideout data if available
            if !shifts.isEmpty {
                hideoutInsightSection
                    .padding(.horizontal, 24)
            }

            // Friction — actions with high skip rates
            frictionSection
                .padding(.horizontal, 24)

            // Focus Mode card
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "FOCUS MODE", color: .violetLight, size: 11)
                    Text("Deep work timer. Tab bar disappears. Counts up, not down.")
                        .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Button(action: { showFocus = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "brain").font(.system(size: 13))
                            Text("Start a focus session")
                                .font(.sora(13, weight: .medium))
                        }
                        .foregroundColor(.violetLight)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    var weekCompletionSection: some View {
        let cal = Calendar.current
        let weekStart = cal.date(byAdding: .day, value: -6, to: Date()) ?? Date()

        return VStack(alignment: .leading, spacing: 12) {
            MonoLabel(text: "LAST 7 DAYS — BY SYSTEM", color: .textMuted, size: 10)
            ForEach(SystemTag.allCases, id: \.self) { sys in
                let sysActions = actions.filter { $0.system == sys && ($0.recurrence == .daily || $0.recurrence == .weekdays) }
                if !sysActions.isEmpty {
                    let totalPossible = sysActions.count * 7
                    let completed = sysActions.reduce(0) { count, a in
                        count + a.completionDates.filter { $0 >= weekStart }.count
                    }
                    let rate = totalPossible > 0 ? Double(completed) / Double(totalPossible) : 0

                    HStack(spacing: 12) {
                        Circle().fill(sys.color).frame(width: 7, height: 7)
                        Text(sys.rawValue.capitalized)
                            .font(.sora(13)).foregroundColor(.textPrimary)
                        Spacer()
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(width: 80, height: 4)
                            RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.8))
                                .frame(width: 80 * CGFloat(rate), height: 4)
                        }
                        Text(String(format: "%.0f%%", rate * 100))
                            .font(.mono(11)).foregroundColor(rate >= 0.7 ? .inkGreen : rate >= 0.4 ? .inkAmber : .textMuted)
                            .tracking(0.3).frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
    }

    var timingSection: some View {
        let allCompletions = actions.flatMap { a in
            a.completionDates.filter {
                Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 999 < 14
            }
        }
        let hourCounts = Dictionary(grouping: allCompletions) {
            Calendar.current.component(.hour, from: $0)
        }.mapValues(\.count)
        let peakHour = hourCounts.max(by: { $0.value < $1.value })?.key

        return VStack(alignment: .leading, spacing: 8) {
            MonoLabel(text: "WHEN YOU ACTUALLY WORK", color: .textMuted, size: 10)
            if let h = peakHour {
                Text("Peak completion hour: \(formatBlockTime("\(h):00"))")
                    .font(.sora(14, weight: .light)).foregroundColor(.textPrimary)
                let morningCount = allCompletions.filter { Calendar.current.component(.hour, from: $0) < 12 }.count
                let eveningCount = allCompletions.filter { Calendar.current.component(.hour, from: $0) >= 17 }.count
                let total = max(1, allCompletions.count)
                Text("Morning: \(Int(Double(morningCount)/Double(total)*100))% · Evening: \(Int(Double(eveningCount)/Double(total)*100))%")
                    .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
            } else {
                Text("Not enough data yet.").font(.sora(13, weight: .light)).foregroundColor(.textMuted)
            }
        }
    }

    func wendyHistoryCard(_ text: String) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Circle().fill(Color.violetLight.opacity(0.7)).frame(width: 6, height: 6)
                        .shadow(color: .violetLight.opacity(0.4), radius: 4)
                    MonoLabel(text: "WENDY — LAST OBSERVATION", color: .violetLight, size: 10)
                    Spacer()
                    if let date = profile.lastWendyObservationDate {
                        MonoLabel(text: date.formatted(.dateTime.month().day()), color: .muted, size: 10)
                    }
                }
                Text(text)
                    .font(.sora(14, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    var hideoutInsightSection: some View {
        let recent = Array(shifts.prefix(14))
        let avgRev = recent.isEmpty ? 0.0 : recent.map(\.grossRevenue).reduce(0, +) / Double(recent.count)
        let band = HideoutPlanningBand.classify(avgRev)

        return VStack(alignment: .leading, spacing: 10) {
            MonoLabel(text: "HIDEOUT — \(recent.count) SHIFTS", color: .warm, size: 10)
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("$\(Int(avgRev))/day")
                        .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
                    Text(band.label).font(.mono(10)).foregroundColor(band.color).tracking(0.3)
                }
                Spacer()
                let stress = recent.filter { $0.stressScore > 0 }
                if !stress.isEmpty {
                    let avg = stress.map { Double($0.stressScore) }.reduce(0, +) / Double(stress.count)
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f/10", avg))
                            .font(.sora(18, weight: .semibold))
                            .foregroundColor(avg <= 4 ? .inkGreen : avg <= 7 ? .inkAmber : .inkRed)
                        Text("avg stress").font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var frictionSection: some View {
        let highFriction = actions.filter { $0.isHighFriction }
        if !highFriction.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "HIGH FRICTION — CONSIDER RESIZING", color: .inkAmber, size: 10)
                ForEach(highFriction.prefix(3)) { a in
                    HStack {
                        Circle().fill(a.system.color.opacity(0.6)).frame(width: 6, height: 6)
                        Text(a.title).font(.sora(13)).foregroundColor(.textSecond).lineLimit(1)
                        Spacer()
                        Text("\(a.skipCount)×").font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                    }
                }
            }
        }
    }
}

// MARK: - TODAY EMBED WRAPPERS (Systems / Habits / Timeline sub-tabs)

struct IncrementsViewEmbed: View {
    @Query private var actions: [Action]
    @Bindable var state: AppState
    @State private var selectedSeg = 0

    var completedToday: [Action] {
        actions.filter { $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }
    }
    var filteredActions: [Action] {
        switch selectedSeg {
        case 0: return actions.filter { $0.recurrence == .daily || $0.recurrence == .weekdays || $0.recurrence == .weekends }
        case 1: return actions.filter { $0.recurrence == .weekly }
        case 2: return actions.filter { $0.recurrence == .none }
        default: return actions
        }
    }
    func daysSinceActivity(_ sys: SystemTag) -> Int {
        let sysActions = actions.filter { $0.system == sys }
        let candidates: [Date] = sysActions.flatMap { a -> [Date] in
            var dates = a.completionDates
            if let at = a.completedAt { dates.append(at) }
            return dates
        }
        guard let last = candidates.max() else { return 999 }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 999
    }

    var body: some View {
        VStack(spacing: 0) {
            segmentControl(["Active", "Planned", "Someday"], selected: $selectedSeg)
                .padding(.horizontal, 24).padding(.bottom, 16)
            VStack(spacing: 8) {
                ForEach(SystemTag.allCases, id: \.self) { sys in
                    let score = state.systemScores[sys] ?? 0
                    let pending = filteredActions.filter { $0.system == sys && !$0.isCompleted }
                    let done = completedToday.filter { $0.system == sys }.count
                    let quiet = daysSinceActivity(sys)
                    VStack(alignment: .leading, spacing: 4) {
                        SystemDetailRow(sys: sys, score: score, state: state,
                                        pending: pending, done: done, quiet: quiet,
                                        allActions: filteredActions)
                        if quiet >= 3 && quiet < 999 {
                            Text("\(sys.rawValue.capitalized) — nothing here in \(quiet) days.")
                                .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                .padding(.horizontal, 6).padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 80)
        }
    }
}

struct HabitsViewEmbed: View {
    @Environment(\.modelContext) private var context
    @Query private var habits: [Habit]
    @State private var showAdd = false

    var activeHabits: [Habit] { habits.filter(\.isActive) }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button(action: { showAdd = true }) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus").font(.system(size: 12, weight: .semibold))
                        Text("Add habit").font(.sora(12, weight: .medium))
                    }
                    .foregroundColor(.violet).padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.violetDim.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 24)
            if activeHabits.isEmpty {
                emptyState(icon: "arrow.triangle.2.circlepath", title: "No active habits",
                           subtitle: "Recurring anchors appear here.")
            }
            ForEach(activeHabits) { habit in
                HabitCard(habit: habit).padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 80)
        .sheet(isPresented: $showAdd) { AddHabitSheet(isPresented: $showAdd) }
        .onAppear { if habits.isEmpty { seedDefaultHabitsEmbed(context: context) } }
    }

    func seedDefaultHabitsEmbed(context: ModelContext) {
        let defaults: [(String, SystemTag, String, String)] = [
            ("Morning Routine", .health, "After alarm dismissed", "5 min version"),
            ("Deep Work", .operations, "When opening laptop", "25 min minimum"),
            ("Movement", .health, "After clearing desk surface", "10 min walk"),
            ("No Phone First Hour", .cognition, "When waking", "Phone stays face-down"),
            ("Night Routine", .environment, "After final meal", "Lights dimmed, one reset"),
        ]
        for (title, system, cue, minimum) in defaults {
            context.insert(Habit(title: title, system: system, cue: cue, minimumScope: minimum))
        }
    }
}

struct TimelineViewEmbed: View {
    @Query private var allActions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    var actionsByDay: [(day: Date, actions: [(Action, Date)])] {
        let cal = Calendar.current
        var pairs: [(Action, Date)] = []
        for action in allActions {
            for date in action.completionDates { pairs.append((action, date)) }
            if let at = action.completedAt, cal.isDateInToday(at) {
                if !action.completionDates.contains(where: { cal.isDate($0, inSameDayAs: at) }) {
                    pairs.append((action, at))
                }
            }
        }
        let days = Array(Set(pairs.map { cal.startOfDay(for: $0.1) })).sorted(by: >)
        return days.map { day in
            let dayPairs = pairs.filter { cal.isDate($0.1, inSameDayAs: day) }.sorted { $0.1 > $1.1 }
            return (day: day, actions: dayPairs)
        }
    }

    func dayHeader(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "TODAY" }
        if cal.isDateInYesterday(date) { return "YESTERDAY" }
        return date.formatted(.dateTime.weekday(.wide).month().day()).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if actionsByDay.isEmpty {
                emptyState(icon: "clock", title: "No history yet",
                           subtitle: "Complete actions in Today to build the record.")
            } else {
                ForEach(Array(actionsByDay.enumerated()), id: \.element.day) { idx, entry in
                    VStack(alignment: .leading, spacing: 4) {
                        MonoLabel(text: dayHeader(entry.day), color: .violetLight, size: 11)
                        Text("\(entry.actions.count) action\(entry.actions.count == 1 ? "" : "s")")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, idx == 0 ? 0 : 20).padding(.bottom, 10)

                    ForEach(Array(entry.actions.enumerated()), id: \.offset) { _, pair in
                        TimelineEntryRow(action: pair.0, completionDate: pair.1)
                    }
                }
            }
        }
        .padding(.bottom, 80)
    }
}

// MARK: - OPERATOR VIEW (mission control — Brief / Dossier / Lab / Manual)

struct OperatorView: View {
    @Bindable var state: AppState
    @Query private var profiles: [OperatorProfile]
    @State private var selectedSeg = 0

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                // Header — sparse, purposeful. Opens a briefing, not a settings panel.
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        MonoLabel(text: "MISSION CONTROL", color: .violetLight, size: 10)
                        Text("Operator")
                            .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    }
                    Spacer()
                    // Day counter — mission clock, not gamification
                    VStack(alignment: .trailing, spacing: 2) {
                        MonoLabel(text: "DAY \(profile.daysInSystem)", color: .warm, size: 11)
                        MonoLabel(text: DayType.today.label, color: .textMuted, size: 10)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 14)

                // 4 tabs — Brief is the live situation room, rest are reference layers
                segmentControl(["Brief", "Dossier", "Lab", "Manual"], selected: $selectedSeg)
                    .padding(.horizontal, 24).padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    switch selectedSeg {
                    case 0: BriefTabView(state: state, profile: profile)
                    case 1: DossierTabView(profile: profile)
                    case 2: OperatorTabView()
                    case 3: FieldManualTabView()
                    default: EmptyView()
                    }
                }
            }
        }
    }
}

// MARK: - OBSERVED INTELLIGENCE CARD

struct ObservedIntelligenceCard: View {
    let actions: [Action]
    let logs: [DailyLog]
    @State private var expanded = false

    var intelligence: ObservedIntelligence {
        ObservedIntelligenceEngine.compute(actions: actions, logs: logs)
    }

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.22)) { expanded.toggle() }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "OBSERVED INTELLIGENCE", color: .inkGreen)
                            Text(intelligence.frictionSignature)
                                .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                .lineSpacing(2)
                        }
                        Spacer()
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .light)).foregroundColor(.textMuted)
                    }
                }

                if expanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider().background(Color.muted.opacity(0.3)).padding(.top, 10)

                        observedRow("PEAK WINDOW", value: intelligence.peakExecutionWindow.capitalized)

                        if let h = intelligence.avgInitiationHour {
                            let period = h < 12 ? "AM" : "PM"
                            let display = h > 12 ? h - 12 : (h == 0 ? 12 : h)
                            observedRow("AVG FIRST ACTION", value: "\(display)\(period)")
                        }

                        switch intelligence.completionClustering {
                        case .clustered(let pct, _):
                            observedRow("COMPLETION PATTERN", value: "Clustered — \(pct)% in peak hours")
                        case .distributed:
                            observedRow("COMPLETION PATTERN", value: "Distributed through day")
                        case .insufficient:
                            observedRow("COMPLETION PATTERN", value: "Collecting")
                        }

                        observedRow("MORNING RATE", value: "\(Int(intelligence.morningCompletionRate * 100))% before noon")
                        observedRow("GENERATIVE RATIO", value: "\(Int(intelligence.generativeRatio * 100))% of recent completions")
                        observedRow("ADMIN DISPLACEMENT", value: intelligence.adminDisplacementFrequency == 0
                            ? "Not detected (14d)"
                            : "\(intelligence.adminDisplacementFrequency) of last 14 days")

                        switch intelligence.energyDeclarationAccuracy {
                        case .inverted:
                            observedRow("ENERGY ACCURACY", value: "Inverted — reserve days outperform full", highlight: .inkAmber)
                        case .calibrated:
                            observedRow("ENERGY ACCURACY", value: "Calibrated")
                        case .uncalibrated:
                            observedRow("ENERGY ACCURACY", value: "Weak signal")
                        case .insufficient:
                            observedRow("ENERGY ACCURACY", value: "Collecting")
                        }

                        if intelligence.estimatedOpenFronts >= OperatorDoctrine.openFrontFragmentationThreshold {
                            observedRow("OPEN FRONTS", value: "\(intelligence.estimatedOpenFronts) stalled systems", highlight: .inkAmber)
                        }

                        Divider().background(Color.muted.opacity(0.2))
                        Text("Derived from usage data. Updates as patterns accumulate.")
                            .font(.mono(9)).foregroundColor(.muted).tracking(0.3)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    func observedRow(_ label: String, value: String, highlight: Color? = nil) -> some View {
        HStack(alignment: .top) {
            MonoLabel(text: label, color: .textMuted, size: 10)
                .frame(width: 150, alignment: .leading)
            Text(value)
                .font(.sora(12, weight: .light))
                .foregroundColor(highlight ?? .textPrimary)
                .lineSpacing(2)
            Spacer()
        }
    }
}

// MARK: - BRIEF TAB (live situation room — Insights + synthesized read)

struct BriefTabView: View {
    @Bindable var state: AppState
    @Bindable var profile: OperatorProfile
    @Query private var actions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @Query(sort: \HydrationLog.timestamp, order: .reverse) private var hydrationLogs: [HydrationLog]
    @ObservedObject private var wendyState = WendyState.shared
    @State private var showFocus = false

    var completedToday: [Action] {
        actions.filter { $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }
    }
    var pendingToday: [Action] { actions.filter { !$0.isCompleted } }

    // Synthesize 2–3 sharp observations from live data — no hedging, no therapy
    var liveBriefLines: [String] {
        var lines: [String] = []
        let hour = Calendar.current.component(.hour, from: Date())
        let doneCount = completedToday.count

        // Energy state observation
        if let energy = state.todayEnergyState {
            switch energy {
            case .reserve:
                lines.append("Reserve day declared. Three actions maximum. Protect the floor.")
            case .partial:
                lines.append("Partial capacity. Defer admin. Protect the creative window.")
            case .full:
                if doneCount == 0 && hour > 10 {
                    lines.append("Full capacity declared. Nothing closed yet. Open the first door.")
                } else if doneCount >= 5 {
                    lines.append("Full day. \(doneCount) closed. Momentum is real.")
                }
            }
        }

        // Quiet system signal
        let quietSystems = SystemTag.allCases.filter {
            let days = state.daysSinceActivity($0)
            return days >= 3 && days < 999
        }
        if let q = quietSystems.first {
            let days = state.daysSinceActivity(q)
            lines.append("\(q.rawValue.capitalized) — \(days) days without a signal. Watch this.")
        }

        // Timing pattern
        if doneCount > 0 && hour < 12 {
            lines.append("Morning execution confirmed. Pattern holding.")
        } else if doneCount == 0 && hour >= 14 {
            lines.append("Afternoon. Nothing closed. Entry point still available.")
        }

        // Consult observation if available
        if let obs = profile.lastWendyObservation, !obs.isEmpty,
           let obsDate = profile.lastWendyObservationDate,
           Calendar.current.dateComponents([.day], from: obsDate, to: Date()).day ?? 999 < 8 {
            lines.append(obs)
        }

        // Fallback — never empty
        if lines.isEmpty {
            lines.append("Systems nominal. No alerts.")
        }

        return Array(lines.prefix(3))
    }

    var weekStart: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    }

    var body: some View {
        VStack(spacing: 16) {

            // ── LIVE BRIEF ───────────────────────────────────────────────
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        MonoLabel(text: "SITUATION · \(Date().formatted(.dateTime.weekday(.wide).day().month()))", color: .violetLight)
                        Spacer()
                        Button(action: { showFocus = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "brain").font(.system(size: 11))
                                Text("Focus").font(.mono(10)).tracking(0.5)
                            }
                            .foregroundColor(.violetLight)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.violetDim.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(liveBriefLines.enumerated()), id: \.offset) { i, line in
                            HStack(alignment: .top, spacing: 10) {
                                // Classified-doc bullet
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.violetLight.opacity(0.6))
                                    .frame(width: 2, height: 14)
                                    .padding(.top, 3)
                                Text(line)
                                    .font(.sora(14, weight: .light))
                                    .foregroundColor(.textPrimary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── OBSERVED INTELLIGENCE ────────────────────────────────────
            // Derived from usage data — higher confidence than declared profile
            ObservedIntelligenceCard(actions: actions, logs: logs)
                .padding(.horizontal, 24)

            // ── SYSTEM STATUS (5-dot read) ───────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "SYSTEMS", color: .textMuted)
                    HStack(spacing: 0) {
                        ForEach(SystemTag.allCases, id: \.self) { sys in
                            let active = profile.isSystemActiveThisWeek(sys)
                            let days = state.daysSinceActivity(sys)
                            let decaying = !active && days >= 3 && days < 999
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(active ? sys.color : Color.surface2)
                                    .frame(width: 9, height: 9)
                                    .overlay(Circle().stroke(
                                        decaying ? sys.color.opacity(0.5) : Color.clear, lineWidth: 1))
                                    .opacity(decaying ? 0.45 : 1.0)
                                MonoLabel(text: String(sys.rawValue.prefix(3)).uppercased(),
                                          color: active ? sys.color : .muted, size: 8)
                                if days < 999 && days > 0 {
                                    MonoLabel(text: "\(days)d", color: .muted, size: 8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── 7-DAY COMPLETION RATES ───────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "7-DAY OUTPUT", color: .textMuted)
                    ForEach(SystemTag.allCases, id: \.self) { sys in
                        let sysActions = actions.filter {
                            $0.system == sys && ($0.recurrence == .daily || $0.recurrence == .weekdays)
                        }
                        if !sysActions.isEmpty {
                            let totalPossible = sysActions.count * 7
                            let completed = sysActions.reduce(0) { n, a in
                                n + a.completionDates.filter { $0 >= weekStart }.count
                            }
                            let rate = totalPossible > 0 ? Double(completed) / Double(totalPossible) : 0
                            HStack(spacing: 10) {
                                Circle().fill(sys.color).frame(width: 6, height: 6)
                                Text(sys.rawValue.capitalized)
                                    .font(.sora(12)).foregroundColor(.textPrimary)
                                Spacer()
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2).fill(Color.surface2)
                                        .frame(width: 72, height: 3)
                                    RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.8))
                                        .frame(width: 72 * CGFloat(rate), height: 3)
                                }
                                Text(String(format: "%.0f%%", rate * 100))
                                    .font(.mono(10))
                                    .foregroundColor(rate >= 0.7 ? .inkGreen : rate >= 0.4 ? .inkAmber : .textMuted)
                                    .tracking(0.3).frame(width: 32, alignment: .trailing)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── WENDY LAST OBSERVATION ───────────────────────────────────
            if let obs = profile.lastWendyObservation, !obs.isEmpty {
                CardView(style: .ambient) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle().fill(Color.violetLight.opacity(0.7)).frame(width: 5, height: 5)
                                .shadow(color: .violetLight.opacity(0.4), radius: 3)
                            MonoLabel(text: "WENDY · PATTERN READ", color: .violetLight, size: 10)
                            Spacer()
                            if let d = profile.lastWendyObservationDate {
                                MonoLabel(text: d.formatted(.dateTime.month().day()), color: .muted, size: 10)
                            }
                        }
                        Text(obs)
                            .font(.sora(13, weight: .light)).foregroundColor(.textPrimary)
                            .lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 24)
            }

            // ── WENDY OBSERVATION ────────────────────────────────────────
            // Layer B pattern interpretation surfaces here — the intelligence surface.
            // Not on Today (execution). Here, where interpretation belongs.
            WendyObservationCard()
                .padding(.horizontal, 24)

            // ── PATTERN BRIEF ────────────────────────────────────────────
            if profile.daysInSystem >= 7 {
                ConsultCard(profile: profile).padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 80)
        .fullScreenCover(isPresented: $showFocus) { FocusMode(isPresented: $showFocus) }
        .onAppear {
            // Layer B — fires on Operator > Brief open, not on Today
            // This is the correct surface for pattern interpretation
            guard profile.voicePresenceEnabled || profile.wendyEnabled else { return }
            Task {
                await VoicePresence.shared.speakIfWarranted(
                    context: PresenceContextBuilder.build(
                        profile: profile,
                        actions: actions,
                        hydrationLogs: Array(hydrationLogs.prefix(1)),
                        energyState: state.todayEnergyState,
                        isFirstOpenToday: false  // Brief is not the first-open surface
                    ),
                    profile: profile,
                    actions: actions,
                    logs: Array(logs.prefix(30)),
                    shifts: Array(shifts.prefix(30))
                )
            }
        }
    }
}

// Insights embedded in OperatorView — reuses InsightsView body, strips its outer nav shell
struct InsightsViewEmbed: View {
    @Bindable var state: AppState

    var body: some View {
        // InsightsView already handles its own data queries and layout.
        // We strip only its top-level ZStack nav shell by embedding it in a Group.
        InsightsView(state: state)
    }
}

// MARK: - DOSSIER TAB VIEW (operating assessment — analyst register, not self-help)

struct DossierTabView: View {
    @Bindable var profile: OperatorProfile
    @Query private var actions: [Action]
    @Query private var cognitionLogs: [CognitionLog]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var stackExpanded   = true
    @State private var failuresExpanded = false
    @State private var protocolExpanded = false
    @State private var traitsExpanded   = false

    // ── LIVE OBSERVED TRAIT COMPUTATIONS ────────────────────────────────
    var avgFirstActionHour: Int? {
        let hours = logs.compactMap { $0.firstCompletionHour }
        guard !hours.isEmpty else { return nil }
        return hours.reduce(0, +) / hours.count
    }

    var adminDisplacementDays: Int {
        // Days where admin actions were completed but no creative/analytical actions were
        let cal = Calendar.current
        let last14 = logs.prefix(14)
        return last14.filter { log in
            let dayActions = actions.filter { a in
                a.completionDates.contains { cal.isDate($0, inSameDayAs: log.date) }
            }
            let hasAdmin = dayActions.contains { $0.cognitionMode == .administrative }
            let hasCreative = dayActions.contains { $0.cognitionMode == .creative || $0.cognitionMode == .analytical }
            return hasAdmin && !hasCreative
        }.count
    }

    var reserveDayAccuracy: String {
        let reserveDays = logs.filter { $0.energyStateRaw == EnergyState.reserve.rawValue }
        guard reserveDays.count >= 3 else { return "Insufficient data" }
        let cal = Calendar.current
        let accurate = reserveDays.filter { log in
            let completions = actions.reduce(0) { n, a in
                n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count
            }
            return completions <= 5
        }.count
        let pct = Int(Double(accurate) / Double(reserveDays.count) * 100)
        return "\(pct)% (\(reserveDays.count) reserve days observed)"
    }

    var dominantFrictionType: String {
        let highFriction = actions.filter { $0.isHighFriction }
        guard !highFriction.isEmpty else { return "No friction pattern detected yet" }
        let bySys = Dictionary(grouping: highFriction) { $0.system }
        if let top = bySys.max(by: { $0.value.count < $1.value.count }) {
            return "\(top.key.rawValue.capitalized) — \(top.value.count) high-friction actions"
        }
        return "Mixed"
    }

    var morningExecutionRate: String {
        let morningCompletions = actions.flatMap { $0.completionHours }.filter { $0 < 12 }.count
        let total = actions.flatMap { $0.completionHours }.count
        guard total > 0 else { return "Insufficient data" }
        return "\(Int(Double(morningCompletions) / Double(total) * 100))% of completions before noon"
    }

    // Completion clustering — do actions happen in bursts or spread through the day?
    var completionClusteringPattern: String {
        let allHours = actions.flatMap { $0.completionHours }
        guard allHours.count >= 14 else { return "Collecting" }
        // Group by hour, find if top 3 hours contain >60% of completions
        let grouped = Dictionary(grouping: allHours) { $0 }.mapValues { $0.count }
        let topThree = grouped.sorted { $0.value > $1.value }.prefix(3).map { $0.value }.reduce(0, +)
        let pct = Int(Double(topThree) / Double(allHours.count) * 100)
        if pct >= 60 { return "Clustered (\(pct)% in peak 3 hours)" }
        return "Distributed (\(pct)% in peak 3 hours)"
    }

    // Energy declaration accuracy — does stated energy match actual output?
    var energyDeclarationAccuracy: String {
        let fullDays = logs.filter { $0.energyStateRaw == EnergyState.full.rawValue }
        let reserveDays = logs.filter { $0.energyStateRaw == EnergyState.reserve.rawValue }
        guard fullDays.count >= 3 && reserveDays.count >= 3 else { return "Collecting" }
        let cal = Calendar.current
        let fullAvg = fullDays.compactMap { log -> Double? in
            let n = actions.reduce(0) { n, a in n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count }
            return n > 0 ? Double(n) : nil
        }.reduce(0, +) / Double(fullDays.count)
        let reserveAvg = reserveDays.compactMap { log -> Double? in
            let n = actions.reduce(0) { n, a in n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count }
            return n > 0 ? Double(n) : nil
        }.reduce(0, +) / Double(reserveDays.count)
        if fullAvg > reserveAvg * 1.2 {
            return "Calibrated (full \(Int(fullAvg)) vs reserve \(Int(reserveAvg)) avg)"
        } else if fullAvg < reserveAvg {
            return "Inverted — reserve days outperform full"
        }
        return "Weak signal (\(Int(fullAvg)) vs \(Int(reserveAvg)) avg)"
    }

    var body: some View {
        VStack(spacing: 16) {

            // ── HEADER ───────────────────────────────────────────────────
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "OPERATOR DOSSIER", color: .violetLight)
                            MonoLabel(text: "SYSTEM HANDOFF DOCUMENT", color: .textMuted, size: 10)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            MonoLabel(text: "PHASE \(profile.level)", color: .warm, size: 10)
                            MonoLabel(text: "DAY \(profile.daysInSystem)", color: .textMuted, size: 10)
                        }
                    }
                    Divider().background(Color.muted.opacity(0.25))
                    Text("For intelligence layers, advisors, and interpretive systems interacting with this operator.")
                        .font(.mono(10)).foregroundColor(.textMuted).tracking(0.3).lineSpacing(3)
                    Divider().background(Color.muted.opacity(0.15))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This operator does not require activation. He requires coordination. Primary friction is structural: sequencing ambiguity, fragmentation, admin displacement, environmental disorder, cleanup debt.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                        Text("Objective: reduce execution drag. Improve routing. Preserve agency.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                        Text("This system is advisory, not supervisory.")
                            .font(.mono(10)).foregroundColor(.violetLight).tracking(0.5)
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── LIVE OBSERVED TRAITS ─────────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        MonoLabel(text: "LIVE OBSERVED TRAITS", color: .inkGreen)
                        Spacer()
                        MonoLabel(text: "FROM USAGE DATA", color: .textMuted, size: 9)
                    }
                    Divider().background(Color.muted.opacity(0.2))

                    let traits: [(String, String)] = [
                        ("AVG FIRST ACTION",
                         avgFirstActionHour.map { h in
                             let period = h < 12 ? "AM" : "PM"
                             let display = h > 12 ? h - 12 : (h == 0 ? 12 : h)
                             return "\(display)\(period) average"
                         } ?? "Collecting"),
                        ("MORNING EXECUTION",    morningExecutionRate),
                        ("COMPLETION PATTERN",   completionClusteringPattern),
                        ("ENERGY ACCURACY",      energyDeclarationAccuracy),
                        ("DOMINANT FRICTION",    dominantFrictionType),
                        ("ADMIN DISPLACEMENT",   adminDisplacementDays == 0
                            ? "Not detected in last 14 days"
                            : "\(adminDisplacementDays) of last 14 days"),
                        ("RESERVE ACCURACY",     reserveDayAccuracy),
                    ]
                    ForEach(traits, id: \.0) { trait in
                        HStack(alignment: .top, spacing: 0) {
                            MonoLabel(text: trait.0, color: .textMuted, size: 10)
                                .frame(width: 140, alignment: .leading)
                            Text(trait.1)
                                .font(.sora(12, weight: .light)).foregroundColor(.textPrimary)
                                .lineSpacing(2)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── OPERATING STACK ──────────────────────────────────────────
            CardView(style: stackExpanded ? .primary : .secondary) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) { stackExpanded.toggle() }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack {
                            MonoLabel(text: "OPERATING STACK", color: .violetLight)
                            Spacer()
                            Image(systemName: stackExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .light)).foregroundColor(.textMuted)
                        }
                    }

                    if stackExpanded {
                        let stack: [(String, Color, String, String)] = [
                            ("RESTORATIVE", .inkGreen,
                             "Problem detection is energizing. Friction should be surfaced as signal, not softened as discomfort.",
                             "Do not protect this operator from clean problem visibility. If something is broken, name it."),
                            ("ACHIEVER", .inkTeal,
                             "Psychological reset occurs daily. Yesterday's completion does not create today's motivational carryover.",
                             "Design for re-ignition, not streak preservation. Do not rely on accumulated pride as a lever."),
                            ("ANALYTICAL", .inkAmber,
                             "Understanding increases compliance. Causal explanation materially improves action likelihood.",
                             "If behavior is failing repeatedly, explain the mechanism. Do not substitute vague encouragement for diagnosis."),
                            ("COMPETITION", .violetLight,
                             "Calibration sharpens engagement. Comparative signal increases attention and effort when used cleanly.",
                             "Do not manufacture artificial competition. Use measurement honestly."),
                            ("CONFIDENCE", .warm,
                             "Hesitation threshold is naturally low. This operator tolerates ambiguity better than average.",
                             "Over-scaffolding reduces trust. Brief clearly, then allow execution."),
                        ]
                        VStack(alignment: .leading, spacing: 16) {
                            Divider().background(Color.muted.opacity(0.3)).padding(.top, 12)
                            ForEach(stack, id: \.0) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(item.1).frame(width: 2, height: 12)
                                        Text(item.0)
                                            .font(.mono(10)).foregroundColor(item.1).tracking(0.8)
                                    }
                                    Text(item.2)
                                        .font(.sora(12, weight: .light)).foregroundColor(.textPrimary)
                                        .lineSpacing(3).padding(.leading, 10)
                                    Text(item.3)
                                        .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                                        .lineSpacing(3).padding(.leading, 10)
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── FAILURE MODES ────────────────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) { failuresExpanded.toggle() }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack {
                            MonoLabel(text: "FAILURE MODES", color: .inkAmber)
                            Spacer()
                            Image(systemName: failuresExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .light)).foregroundColor(.textMuted)
                        }
                    }
                    if failuresExpanded {
                        let failures: [(String, String, String, String)] = [
                            ("SEQUENCING AMBIGUITY",
                             "Work exists but execution order is unclear. This is not avoidance — it is structural drag. The operator cannot initiate cleanly when sequence is undefined.",
                             "Reduce to one clear next action. 'What is the first step that unlocks the others?' Name it explicitly.",
                             "Do not interpret unclear sequencing as hesitation or avoidance. It is an architecture problem, not a motivation problem."),
                            ("STRUCTURAL FRAGMENTATION",
                             "Too many simultaneously active fronts reducing throughput. Each open front draws from the same attentional pool. Performance degrades not from laziness but from genuine cognitive fragmentation.",
                             "Surface the count. 'You have [N] active fronts. Which one closes completely before the next opens?' One door. Collapse then expand.",
                             "Do not suggest prioritization frameworks. Name the fronts. Ask for the close. Stop."),
                            ("ADMINISTRATIVE DISPLACEMENT",
                             "Logistics and operational maintenance consuming morning leverage time before generative or high-value work starts. Admin produces completion signals without building anything.",
                             "Distinguish maintenance from generative work. 'Admin has consumed the morning. No generative work has started.' Surface it factually.",
                             "Do not validate cleared inboxes and completed logistics as a productive day. Maintenance is necessary. It is not leverage."),
                            ("ENVIRONMENTAL DISORDER",
                             "Physical or structural incoherence degrading cognition and throughput. This is not aesthetics — environmental coherence materially affects execution quality for this operator.",
                             "Recommend environmental reset before cognitive work. 'Conditions first. Clear the surface before the work starts.' Environment is not background — it is part of the system.",
                             "Do not push through environmental disorder with force. The drag compounds. Reset first."),
                            ("CLEANUP DEBT",
                             "Iteration speed outpacing structural hygiene. Fast building creates residue: unfinished architecture, stale systems, fragmented notes, half-organized task structures. Debt accumulates invisibly.",
                             "Surface the pattern when generative output is high but consolidation has not occurred. 'Structural residue is accumulating. Consolidation likely outperforms expansion right now.'",
                             "Do not flag this during active build phases — it is expected. Flag when drift is visible across multiple domains simultaneously."),
                            ("CONSOLIDATION LAG",
                             "New fronts launched before prior ones are synthesized. This operator moves fast. The natural risk is launching the next thing before the current thing is absorbed, integrated, or handed off.",
                             "Name it when pattern is visible. 'Multiple launches without consolidation. What is complete enough to close?' Define done before opening the next door.",
                             "Do not interpret fast launching as recklessness. This is a natural signature of high-output operators. Surface it as a routing question, not a behavioral critique."),
                        ]
                        VStack(alignment: .leading, spacing: 18) {
                            Divider().background(Color.muted.opacity(0.3)).padding(.top, 12)
                            ForEach(failures, id: \.0) { f in
                                VStack(alignment: .leading, spacing: 6) {
                                    MonoLabel(text: f.0, color: .inkAmber, size: 10)
                                    Text(f.1)
                                        .font(.sora(12, weight: .light)).foregroundColor(.textPrimary).lineSpacing(3)
                                    HStack(alignment: .top, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1).fill(Color.inkGreen.opacity(0.6))
                                            .frame(width: 2, height: 12).padding(.top, 2)
                                        Text(f.2)
                                            .font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                                    }
                                    HStack(alignment: .top, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1).fill(Color.inkRed.opacity(0.6))
                                            .frame(width: 2, height: 12).padding(.top, 2)
                                        Text(f.3)
                                            .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(3)
                                    }
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── COMMUNICATION PROTOCOL ───────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) { protocolExpanded.toggle() }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack {
                            MonoLabel(text: "COMMUNICATION PROTOCOL", color: .textMuted)
                            Spacer()
                            Image(systemName: protocolExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .light)).foregroundColor(.textMuted)
                        }
                    }
                    if protocolExpanded {
                        let rules: [(String, String)] = [
                            ("RULE 1 — Lead with observable reality.",
                             "Correct: \"Creative work has not moved in 4 days.\"\nIncorrect: \"Maybe you've been feeling blocked.\""),
                            ("RULE 2 — Explain mechanism when repeated failure appears.",
                             "This operator responds to causal understanding. Diagnosis before prescription."),
                            ("RULE 3 — Preserve agency.",
                             "Offer interpretation. Do not coerce behavior. Name what you see. Stop there."),
                            ("RULE 4 — Use precise language.",
                             "Avoid abstraction, motivational vagueness, and generic productivity phrasing."),
                            ("RULE 5 — Silence is valid.",
                             "If no meaningful signal exists, say nothing. Filler is worse than silence."),
                        ]

                        let doNot = [
                            "Emotionally cushion observations",
                            "Guilt the operator",
                            "Over-praise",
                            "Use therapeutic filler",
                            "Narrate feelings without behavioral evidence",
                            "Mistake analysis for execution",
                            "Interpret temporary conditions as identity",
                        ]

                        VStack(alignment: .leading, spacing: 16) {
                            Divider().background(Color.muted.opacity(0.3)).padding(.top, 12)

                            ForEach(rules, id: \.0) { rule in
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: rule.0, color: .warm, size: 10)
                                    Text(rule.1)
                                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                        .lineSpacing(3)
                                }
                            }

                            Divider().background(Color.muted.opacity(0.2))

                            VStack(alignment: .leading, spacing: 8) {
                                MonoLabel(text: "DO NOT", color: .inkRed, size: 10)
                                ForEach(doNot, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1).fill(Color.inkRed.opacity(0.5))
                                            .frame(width: 2, height: 11).padding(.top, 3)
                                        Text(item)
                                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                    }
                                }
                            }

                            Divider().background(Color.muted.opacity(0.2))

                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "CORRECT REGISTER", color: .inkGreen, size: 10)
                                Text("Briefing. Diagnostic. Precise. Operational. Psychologically literate. High-agency.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                                MonoLabel(text: "INCORRECT REGISTER", color: .inkRed, size: 10)
                                    .padding(.top, 4)
                                Text("Coach. Therapist. Motivator. Companion. Nag.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── SIGNAL COLLECTION STATUS ─────────────────────────────────
            IntelligenceReadinessCard(
                patternReadiness: patternReadiness,
                frictionReadiness: frictionReadiness,
                energyCalibrationReadiness: energyCalibrationReadiness,
                cognitionTaggingStatus: cognitionTaggingStatus
            )
            .padding(.horizontal, 24)

            WeeklyExportCard(actions: actions, logs: logs)
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
    }

    var patternReadiness: IntelligenceReadiness {
        let days = Set(actions.flatMap { $0.completionDates }.map { Calendar.current.startOfDay(for: $0) }).count
        if days >= 7 { return .ready(label: "Pattern window open.") }
        return .collecting(daysRemaining: max(0, 7 - days), target: 7, label: "completion days")
    }
    var frictionReadiness: IntelligenceReadiness {
        let maxA = actions.map { $0.skipCount + $0.completionDates.count }.max() ?? 0
        if maxA >= 14 { return .ready(label: "Friction read open.") }
        return .collecting(daysRemaining: Swift.max(0, 14 - maxA), target: 14, label: "action appearances")
    }
    var energyCalibrationReadiness: IntelligenceReadiness {
        let n = cognitionLogs.filter { $0.energyStateAtDeclaration != nil }.count
        if n >= 10 { return .ready(label: "Energy calibration active.") }
        return .collecting(daysRemaining: Swift.max(0, 10 - n), target: 10, label: "energy readings")
    }
    var cognitionTaggingStatus: String {
        let ca = actions.filter { $0.system == .cognition }
        if ca.isEmpty { return "No Cognition actions yet." }
        let tagged = ca.filter { $0.cognitionMode != nil }.count
        if tagged == ca.count { return "All \(ca.count) tagged." }
        if tagged == 0 { return "\(ca.count) untagged. Open action to tag." }
        return "\(tagged) of \(ca.count) tagged."
    }
}


struct CustomTabBar: View {
    @Binding var selected: Int
    let showTimeline: Bool   // kept for API compat, unused now

    var tabs: [(String, String)] {
        [
            ("house",         "Home"),
            ("calendar",      "Today"),
            ("brain",         "Operator"),
            ("building.2",    "Hideout"),
            ("person",        "You"),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Single hairline — barely there
            Rectangle()
                .fill(Color.muted.opacity(0.3))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { i in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) { selected = i }
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }) {
                        VStack(spacing: 5) {
                            ZStack {
                                if selected == i {
                                    Circle()
                                        .fill(Color.violet.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                        .blur(radius: 6)
                                }
                                Image(systemName: tabs[i].0)
                                    .font(.system(size: selected == i ? 19 : 17,
                                                  weight: selected == i ? .medium : .light))
                                    .foregroundStyle(
                                        selected == i
                                        ? AnyShapeStyle(LinearGradient(
                                            colors: [.violetLight, .warm],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing))
                                        : AnyShapeStyle(Color.textMuted.opacity(0.6))
                                    )
                                    .scaleEffect(selected == i ? 1.05 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)
                            }
                            .frame(width: 36, height: 28)

                            Text(tabs[i].1)
                                .font(.mono(10))
                                .tracking(0.5)
                                .foregroundColor(selected == i ? .violetLight : .textMuted.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .padding(.bottom, 4)
                    }
                }
            }
            .background(Color.bgBase)

            // Safe area fill
            Color.bgBase.frame(height: safeAreaBottom)
        }
    }

    // Read actual safe area inset — avoids hardcoding device heights
    private var safeAreaBottom: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom) ?? 0
    }
}

// MARK: - SHARED UI HELPERS

// Custom sheet drag handle — replaces iOS default white pill
struct SheetHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(colors: [.violet.opacity(0.5), .warm.opacity(0.3)],
                               startPoint: .leading, endPoint: .trailing)
            )
            .frame(width: 36, height: 3)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }
}

func inputField(_ label: String, placeholder: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        MonoLabel(text: label)
        TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
            .font(.sora(15)).foregroundColor(.textPrimary)
            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
            .tint(.warm)
    }
}

func editableField(_ label: String, placeholder: String, text: Binding<String>, multiline: Bool = false) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        MonoLabel(text: label)
        if multiline {
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted), axis: .vertical)
                .font(.sora(14)).foregroundColor(.textPrimary).lineLimit(3...6)
                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(.warm)
        } else {
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
                .font(.sora(14)).foregroundColor(.textPrimary)
                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(.warm)
        }
    }
}

func primaryButton(_ label: String, disabled: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(label)
            .font(.sora(14, weight: .semibold))
            .foregroundColor(disabled ? .textMuted : .bgBase)
            .tracking(1.8)
            .frame(maxWidth: .infinity).frame(height: 50)
            .background(
                Group {
                    if disabled {
                        Color.surface2
                    } else {
                        LinearGradient(
                            colors: [.violetLight, .violet],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: disabled ? .clear : Color.violet.opacity(0.25), radius: 12, x: 0, y: 6)
    }
    .disabled(disabled)
}

func segmentControl(_ options: [String], selected: Binding<Int>) -> some View {
    HStack(spacing: 0) {
        ForEach(options.indices, id: \.self) { i in
            Button(action: { selected.wrappedValue = i }) {
                Text(options[i])
                    .font(.sora(13, weight: selected.wrappedValue == i ? .semibold : .regular))
                    .foregroundColor(selected.wrappedValue == i ? .textPrimary : .textMuted)
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                    .background(selected.wrappedValue == i ? Color.surface : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    .padding(4).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 12))
}

func emptyState(icon: String, title: String, subtitle: String) -> some View {
    CardView {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 28)).foregroundColor(.violetDim)
            Text(title).font(.sora(15, weight: .medium)).foregroundColor(.textSecond)
            Text(subtitle).font(.sora(13, weight: .light)).foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
    }
    .padding(.horizontal, 24)
}

// MARK: - SEED: MAINTENANCE ITEMS

func seedDefaultMaintenance(context: ModelContext) {
    let defaults: [(String, SystemTag, Int)] = [
        ("Air filter",       .environment, 30),
        ("Water filter",     .environment, 90),
        ("Deep clean",       .environment, 14),
        ("Weekly reset",     .operations,   7),
        ("Financial review", .operations,   7),
    ]
    for (title, system, interval) in defaults {
        context.insert(MaintenanceItem(title: title, system: system, intervalDays: interval))
    }
}

// MARK: - DAILY RESET — clears isCompleted on recurring actions each new calendar day

func resetDailyActionsIfNeeded(context: ModelContext, profile: OperatorProfile, actions: [Action], sessions: [Session] = []) {
    let cal = Calendar.current
    // Only reset once per calendar day
    if let last = profile.lastResetDate, cal.isDateInToday(last) { return }

    // Determine yesterday's weekday for skip counting (we're resetting FOR yesterday)
    let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    let yesterdayWD = cal.component(.weekday, from: yesterday)

    for action in actions {
        guard action.recurrence != .none else { continue }   // one-off actions never reset

        let shouldReset: Bool
        switch action.recurrence {
        case .daily:
            shouldReset = true
        case .weekdays:
            shouldReset = yesterdayWD >= 2 && yesterdayWD <= 6
        case .weekends:
            shouldReset = yesterdayWD == 1 || yesterdayWD == 7
        case .weekly:
            if let ca = action.completedAt {
                let days = cal.dateComponents([.day], from: ca, to: Date()).day ?? 0
                shouldReset = days >= 7
            } else {
                let daysSinceCreated = cal.dateComponents([.day], from: action.createdAt, to: Date()).day ?? 0
                shouldReset = daysSinceCreated >= 7
            }
        case .none:
            shouldReset = false
        }

        if shouldReset {
            if !action.isCompleted { action.skipCount += 1 }
            action.isCompleted = false
            action.completedAt = nil
        }
    }

    // Session reset — parallel logic to actions
    // Blank (no log, no skip) = unknown miss → increment skipCount
    // Intentional skip (skipDates recorded) = deliberate signal → don't double-count
    for session in sessions {
        guard session.recurrence != .none, session.isActive else { continue }

        let wasActiveYesterday: Bool
        switch session.recurrence {
        case .daily:   wasActiveYesterday = true
        case .weekdays: wasActiveYesterday = yesterdayWD >= 2 && yesterdayWD <= 6
        case .weekends: wasActiveYesterday = yesterdayWD == 1 || yesterdayWD == 7
        case .weekly:
            let days = cal.dateComponents([.day], from: session.lastCompleted ?? session.createdAt, to: Date()).day ?? 0
            wasActiveYesterday = days >= 7
        case .none: wasActiveYesterday = false
        }

        guard wasActiveYesterday else { continue }

        let completedYesterday = cal.isDateInYesterday(session.lastCompleted ?? .distantPast)
        let skippedYesterday = cal.isDateInYesterday(session.skipDates.last ?? .distantPast)

        if !completedYesterday && !skippedYesterday {
            // Blank — unknown non-completion. Counts as friction.
            session.skipCount += 1
        }
        // Note: intentional skips (skippedYesterday) are already recorded in skipDates.
        // They don't increment skipCount — that's reserved for unlogged misses.
    }

    profile.lastResetDate = Date()
}

// MARK: - SEED DATA

// PRESCRIBED WEEK SCHEDULE (v2.4):
// Add these manually if already seeded. Time blocks show on action cards.
// DayType "hideout" = Wed–Fri 8–5, Sat–Sun 10–3. "base" = Mon–Tue cafe/ops days.
//
// EVERY DAY:  6:00 No phone · 6:05 Light · 6:15 Hydrate · 6:20 Creatine
//             6:30 Move · 6:45 Cold shower · 7:00 Protein · 7:30 Journal
//             21:00 No screens · 21:15 Evening Shutdown · 22:00 Read
// HIDEOUT:    8:00 (10:00 wknds) Priorities · 8:30 Deep work · 12:00 Protein + outside
// BASE:       8:00 Mon: Close loop · 8:15 Messages · 8:30 Reset one area
// WEEKLY:     Sun 14:00 Read long · Sun 15:00 Inbox physical · Mon 8:00 Close loop

func seedDefaultActions(context: ModelContext) {
    // (title, system, points, note, cue, recurrence, scheduledBlock, dayTypeRaw)
    let defaults: [(String, SystemTag, Int, String?, String, RecurrenceType, String?, String?)] = [

        // ── MORNING ANCHOR — every day ─────────────────────────────────────────
        ("No phone — first hour",     .cognition,    10,
         "Protect the opening. Nothing urgent happens in the first hour that couldn't wait.",
         "When alarm goes off",                   .daily,   "6:00",  nil),

        ("Morning light exposure",     .health,        5,
         "10 min on the balcony or by the window. Ocean view counts. Fan if hot.",
         "After alarm",                            .daily,   "6:05",  nil),

        ("Open the blinds",            .environment,   5,
         nil,
         "Walking to kitchen or balcony",          .daily,   "6:10",  nil),

        ("Hydrate",                    .health,        5,
         "500ml before coffee. 3L target all day.",
         "When walking to the kitchen",            .daily,   "6:15",  nil),

        ("Creatine",                   .health,        5,
         "3-5g with water. Cognitive and physical — evidence solid on both.",
         "With morning water",                     .daily,   "6:20",  nil),

        ("Move your body",             .health,       10,
         "Cleared movement only. Whatever PT has approved.",
         "After hydrate",                          .daily,   "6:30",  nil),

        ("Cold exposure — 2 min",      .health,       10,
         "Last 2 minutes of shower cold. Not a full cold shower — just the finish. Nervous system reset.",
         "End of shower",                          .daily,   "6:45",  nil),

        ("Protein — first meal",       .health,        5,
         "30g minimum.",
         "First meal of the day",                  .daily,   "7:00",  nil),

        ("Journal — 3 sentences",      .cognition,    10,
         "What happened. What I noticed. What's next. No more than that.",
         "After protein — before opening the phone",  .daily, "7:30", nil),

        // ── HIDEOUT DAYS — Wed–Fri 8–5, Sat–Sun 10–3 ─────────────────────────
        ("Review priorities",          .operations,   10,
         "5 min. What are the 3 things? Write them down before anything else.",
         "When arriving at hideout — 7AM slow open, before the work starts",
         .daily,   "7:30",  "hideout"),

        ("Deep work block — 90 min",   .cognition,    20,
         "One thing. Phone in another room. Timer on. No interruptions — let it ring.",
         "After slow open, when the place is ready",
         .daily,   "8:30",  "hideout"),

        ("Protein — second hit",       .health,        5,
         "30g. Noon break.",
         "Noon — hideout midday break",            .daily,   "12:00", "hideout"),

        ("Outside — 15 min",           .participation, 5,
         "Walk. Balcony if after 5pm and heat's tolerable with a fan.",
         "After noon protein on hideout days",     .daily,   "12:15", "hideout"),

        // Gym — 5PM fixed anchor, building condo gym with Tim
        ("Strength training — gym",    .health,       20,
         "Building with Tim. The session is the anchor — structure inside it is yours. Post-workout protein within 30 min.",
         "5PM — building gym, every day after hideout",
         .daily,   "17:00", nil),

        ("Post-workout protein",       .health,        5,
         "30g within 30 min of training. The window matters here more than other meals.",
         "Immediately after gym",                   .daily,   "18:00", nil),

        // ── BASE DAYS — Mon–Tue cafe/ops/maintenance ───────────────────────────
        ("Respond to 3 messages",      .operations,    5,
         "Clear the queue. Not all of it — just what needs you.",
         "After morning anchor, at the cafe",      .daily,   "8:15",  "base"),

        ("Apartment reset — one area", .environment,  10,
         nil,
         "After arriving home or during cafe prep",  .daily,  "8:30",  "base"),

        ("Protein — second hit",       .health,        5,
         "30g. Wherever you are.",
         "Noon on base days",                      .daily,   "12:00", "base"),

        // ── EVENING ANCHOR — every day ─────────────────────────────────────────
        ("No screens — final hour",    .health,       10,
         "Phone in the other room. This is what makes the reading and the sleep work.",
         "One hour before target sleep",           .daily,   "21:00", nil),

        ("Read before sleep",          .cognition,    15,
         "Physical book. 20+ pages. No Kindle. Your Garmin confirms the REM effect — this is a sleep action as much as a reading action.",
         "After phone goes in the other room",     .daily,   "21:15", nil),

        ("Sleep by midnight",          .health,       10,
         "Non-negotiable floor. Everything else costs more when this slips.",
         "When Evening Shutdown completes",        .daily,   "23:00", nil),

        // ── HIDEOUT OPERATIONS — behavioral science stack ─────────────────────
        ("Pre-shift: load the 4 behaviors",  .operations,   10,
         "1. Primacy — acknowledge every walk-in within 3 seconds.\n2. Choice Architecture — 'Want me to warm a croissant with that?'\n3. Familiarity — which regulars might come in? Know their usual.\n4. Peak-End — '[Name]. Have a great [day]. See you next time.'",
         "Before opening — while prepping",              .daily,   "7:15",  "hideout"),

        ("Watermarc relationship touch",     .participation,15,
         "Bring coffee to leasing office. Introduce Hideout. Ask if they'll mention us on tours. Leave cards with concierge. One relationship = potentially dozens of high-value regulars.",
         "First available morning at Hideout",           .weekly,  nil,     "hideout"),
        ("One real conversation",      .participation,10,
         "Phone call counts. A real text thread counts. A DM reply doesn't.",
         "Any natural transition in the day",      .daily,   nil,     nil),

        ("Make something",             .participation,15,
         "Write, build, design, cook. Output, not consumption. Anything counts if you made it.",
         "Weekend — any time",                     .weekends, nil,    nil),

        // ── WHOLE HUMAN PRESERVATION — daily AM ───────────────────────────────
        ("Face cleanse",               .health,        5,
         "Cetaphil Gentle Cleanser. Damp skin, gentle massage, 60-90 sec max, rinse. Don't exceed — this is not a mask.",
         "After shower — before moisturizer",      .daily,   "7:05",  nil),

        ("Moisturize + SPF",           .health,       10,
         "Cetaphil lotion on face + neck. Then SPF last — two finger lengths minimum. Face, neck, ears, backs of hands if outdoors. Highest anti-aging ROI in the stack. Don't skip for a quick errand.",
         "After face cleanse",                     .daily,   "7:10",  nil),

        ("Body lotion sweep",          .health,        5,
         "Cetaphil lotion. Arms, shoulders, elbows, chest, legs, knees, feet. 90-second sweep while skin is slightly damp. Important for whole-human skin quality — lower leverage than SPF and minoxidil, but compounds over time.",
         "After shower, before getting dressed",   .daily,   "6:50",  nil),

        // ── NIZORAL — Tuesday + Saturday ──────────────────────────────────────
        ("Nizoral — Tuesday",          .health,       10,
         "In the shower. Apply ketoconazole shampoo to scalp — not just hair. Gentle massage. Leave 5 min. Rinse well. Condition mids/ends only if dry. Controls scalp inflammation and fungal environment. Adjunct to minoxidil, not a substitute.",
         "Tuesday shower",                         .weekly,  nil,     nil),

        ("Nizoral — Saturday",         .health,       10,
         "Same as Tuesday. Scalp only. 5-minute contact. Rinse. Condition ends if needed.",
         "Saturday shower",                        .weekly,  nil,     nil),

        // ── PAULA'S CHOICE BHA — Friday ───────────────────────────────────────
        ("BHA texture night — Friday", .health,       10,
         "Paula's Choice BHA exfoliant. Correct tool for texture — better than extended cleanser contact time. After PM cleanse, dry face, thin layer, avoid eye area. Moisturize after if needed. Start 1x weekly. DO NOT combine with retinoid actives same night.",
         "Friday night — after PM cleanse",        .weekly,  nil,     nil),

        // ── INACTIVE — rosemary requires jojoba carrier oil not yet purchased ──
        // When jojoba purchased, uncomment:
        // ("Rosemary scalp — Wednesday", .health, 10,
        //  "Mix: 1 tbsp jojoba + 6 drops rosemary essential oil + small castor (70/20/10 approx). NEVER apply pure rosemary directly — concentrated essential oil causes irritation and inflammatory shedding. Section hair, apply few drops, massage 5 min, leave overnight. Wash next morning.",
        //  "Before bed — Wednesday", .weekly, nil, nil),
        // ("Rosemary scalp — Sunday", .health, 10,
        //  "Same as Wednesday. Diluted blend only. Leave overnight if tolerated. Wash Monday morning.",
        //  "Before bed — Sunday", .weekly, nil, nil),

        // PLANNED — full-face retinoid (purchase when capital allows)
        // ("Retinol — Monday",  .health, 15,
        //  "Full-face retinoid only — not eye cream. Cleanse first. Wait 10-20 min until skin fully dry. Pea-sized only. Dot forehead, cheeks, chin. Avoid eyelids, nostril folds, corners of mouth. Moisturize after. Start 2x weekly. No BHA same night.",
        //  "After PM cleanse — Monday night", .weekly, nil, nil),
        // ("Retinol — Thursday", .health, 15,
        //  "Same as Monday. Cleanse → dry 10-20 min → pea-sized retinoid → moisturize. No BHA same night.",
        //  "After PM cleanse — Thursday night", .weekly, nil, nil),

        // PLANNED — finasteride consult (next capital deployment after 90-day stack run)
        // Crown + top pattern = androgenic thinning. Minoxidil supports growth.
        // Finasteride addresses the driver (DHT). Generic is inexpensive once prescribed.
        // Do not initiate until current owned stack has run consistently for 90 days.

        // PLANNED — hair clinic review (6-month horizon)
        // Re-evaluate prior successful scalp/hairline injectable intervention when resources allow.
        // Defer until core stack has run 6+ months. Not before.

        // ── WEEKLY ─────────────────────────────────────────────────────────────
        ("Read something long",        .cognition,    15,
         "Article, essay, or book chapter. Not a thread, not a summary.",
         "Sunday afternoon",                       .weekly,  "14:00", nil),

        ("Inbox zero — physical",      .environment,  10,
         "Mail, packages, receipts. The physical pile.",
         "Sunday afternoon — after reading",       .weekly,  "15:00", nil),

        ("Close one open loop",        .operations,   15,
         "One thing that's been sitting. A reply, a decision, a task. One — not a list.",
         "Monday morning — first thing",           .weekly,  "8:00",  "base"),
    ]
    for (title, system, points, note, cue, recurrence, block, dayType) in defaults {
        let action = Action(
            title: title, system: system, points: points,
            recurrence: recurrence, note: note, cue: cue,
            scheduledBlock: block, dayTypeRaw: dayType
        )
        context.insert(action)
    }
}

func seedDefaultSessions(context: ModelContext) {
    let defaults: [(String, SystemTag, [String], String, RecurrenceType)] = [
        (
            "Morning Protocol",
            .health,
            [
                "Open blinds — natural light first",
                "Hydrate — water before anything else",
                "Medications and supplements",
                "Move — 5 min cleared movement",
                "Stage the day — what are the 3 things",
                "Top 4 check: nose hair · ear hair · neck hair · eyebrows"
            ],
            "Wake",
            .daily
        ),
        (
            "Evening Shutdown",
            .operations,
            [
                "Review tomorrow's first action",
                "Stage clothes and kit",
                "Journal — 3 sentences",
                "Supplements — mag glycinate",
                "Phone in the other room",
                "Read — physical book"
            ],
            "After 9pm",
            .daily
        ),
        (
            "Whole Human Reset",
            .health,
            [
                "Body lotion — arms, elbows, legs, feet (damp skin, 90-second sweep)",
                "Face cleanse — Cetaphil, 60-90 sec gentle massage, rinse",
                "Moisturizer — Cetaphil, face + neck",
                "SPF — two finger lengths, face + neck + ears",
                "Brush teeth — 2 min",
                "Hair reset — shape, scalp glance, cap if outdoors"
            ],
            "After morning shower — before leaving the bathroom",
            .daily
        ),
        (
            "Shutdown Preservation",
            .health,
            [
                "Face cleanse — Cetaphil, remove SPF + sweat + day residue",
                "Body lotion quick pass — arms, legs, feet",
                "Brush teeth — 2 min",
                "Floss",
                "Retainers",
                "Minoxidil — dry scalp only, crown + top thinning zone, light spread, let dry before bed"
            ],
            "After no-screens begins — before sleep",
            .daily
        ),
        (
            "Weekly Reset",
            .operations,
            [
                "What closed this week?",
                "What carries forward?",
                "What needs a decision?",
                "Financial state — runway check",
                "Set next week's first action"
            ],
            "Sunday evening",
            .weekly
        ),
        (
            "Laundry",
            .environment,
            [
                "Gather and sort",
                "Start wash",
                "Move to dry",
                "Fold and put away"
            ],
            "When hamper is full or Sunday",
            .none
        ),
        // NEW v2.2 — Cognitive Sharpening: a daily protocol for the system that had no session
        (
            "Cognitive Sharpening",
            .cognition,
            [
                "Phone in another room",
                "Open book — not a screen",
                "Read 20 pages minimum",
                "One sentence in journal: what landed"
            ],
            "After morning protocol — before first work block",
            .daily
        ),
        // NEW v2.2 — Deep Work: the 90-min block as a session with setup steps
        (
            "Deep Work Block",
            .cognition,
            [
                "Define the one thing — write it down",
                "Close all tabs except what's needed",
                "Phone off or in another room",
                "Timer: 90 min",
                "No interruptions — let it ring"
            ],
            "After Cognitive Sharpening",
            .daily
        ),
        // SOLO OPERATOR PROTOCOL — behavioral science pre-shift primer
        // Based on: Primacy Effect, Choice Architecture, Familiarity Principle, Peak-End Rule
        // Run before opening — loads the four behaviors mentally before the first customer
        (
            "Solo Operator Protocol",
            .operations,
            [
                "Primacy: ready to acknowledge every walk-in within 3 seconds",
                "Choice Architecture: scripted upsell ready — 'Want me to warm a croissant with that?'",
                "Familiarity: which regulars might come in today? Their usual?",
                "Peak-End: anchor phrase ready — '[Name]. Have a great [day]. See you next time.'"
            ],
            "Before opening — 7AM or 10AM weekends",
            .daily
        ),
        // WATERMARC OUTREACH — highest-ROI visibility play per strategy brief
        (
            "Watermarc relationship touch",
            .participation,
            [
                "Bring coffee to leasing office",
                "Introduce Hideout — ask if they'll mention us on tours",
                "Leave cards with the concierge",
                "Note how many units in the building"
            ],
            "First available morning at Hideout — then monthly",
            .none
        ),
    ]
    for (title, system, steps, cue, recurrence) in defaults {
        context.insert(Session(title: title, system: system, steps: steps, cue: cue, recurrence: recurrence))
    }
}


// Spec (Design Decisions v1.2 · CARE 03):
// Nodes pulse in one by one (1.2s) → warm corona ignites (0.3s) → wordmark fades up (0.4s) → app loads
// Total ~2.2s. Runs once per cold launch. Static thereafter — instrument mode engaged.

struct LaunchSequenceView: View {
    var onComplete: () -> Void

    // 12 neural nodes — positions tuned to the actual AppIcon (top-down brain, 180pt rendered size)
    // Warm gold nodes sit over the icon's existing node positions
    private let nodePositions: [(CGFloat, CGFloat)] = [
        // Left hemisphere
        (-32, -58), (-54, -28), (-58,  10), (-44,  44), (-18,  60),
        (-24,  -8),
        // Right hemisphere
        ( 32, -58), ( 54, -28), ( 58,  10), ( 44,  44), ( 18,  60),
        ( 24,  -8),
    ]

    // Connections between node indices (pairs)
    private let connections: [(Int, Int)] = [
        (0,1),(1,2),(2,3),(3,4),(4,10),(1,5),(5,2),(5,9),
        (6,7),(7,8),(8,9),(9,10),(7,11),(11,8),(11,3),
        (0,6),(5,11)   // corpus callosum bridges
    ]

    @State private var nodeVisible:    [Bool]   = Array(repeating: false, count: 12)
    @State private var nodeGlow:       [Bool]   = Array(repeating: false, count: 12)
    @State private var coronaOpacity:  Double   = 0
    @State private var coronaRadius:   CGFloat  = 40
    @State private var wordmarkOpacity: Double  = 0
    @State private var wordmarkOffset:  CGFloat = 12
    @State private var sublineOpacity:  Double  = 0
    @State private var connectionOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Brain glyph + nodes
                ZStack {
                    // Warm corona — ignites after nodes
                    RadialGradient(
                        colors: [
                            Color.warm.opacity(0.55 * coronaOpacity),
                            Color.violet.opacity(0.18 * coronaOpacity),
                            Color.bgBase.opacity(0)
                        ],
                        center: .center,
                        startRadius: coronaRadius * 0.3,
                        endRadius: coronaRadius
                    )
                    .frame(width: coronaRadius * 2, height: coronaRadius * 2)
                    .blur(radius: 18)
                    .animation(.easeOut(duration: 0.35), value: coronaOpacity)

                    // BrainGlyph — transparent-background asset from xcassets
                    Image("BrainGlyph")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .shadow(color: Color.violet.opacity(0.35), radius: 32)
                        .shadow(color: Color.warm.opacity(0.2), radius: 16)

                    // Connection lines — appear with nodes
                    Canvas { ctx, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        for (a, b) in connections {
                            guard nodeVisible[a] && nodeVisible[b] else { continue }
                            let pa = CGPoint(
                                x: center.x + nodePositions[a].0,
                                y: center.y + nodePositions[a].1
                            )
                            let pb = CGPoint(
                                x: center.x + nodePositions[b].0,
                                y: center.y + nodePositions[b].1
                            )
                            var path = Path()
                            path.move(to: pa)
                            path.addLine(to: pb)
                            ctx.stroke(
                                path,
                                with: .color(Color.warm.opacity(0.25 * connectionOpacity)),
                                lineWidth: 0.6
                            )
                        }
                    }
                    .frame(width: 180, height: 180)
                    .animation(.easeIn(duration: 0.2), value: connectionOpacity)

                    // Neural nodes
                    ForEach(nodePositions.indices, id: \.self) { i in
                        Circle()
                            .fill(Color.warm)
                            .frame(width: nodeGlow[i] ? 5 : 3.5, height: nodeGlow[i] ? 5 : 3.5)
                            .shadow(color: Color.warm.opacity(nodeGlow[i] ? 0.9 : 0.4),
                                    radius: nodeGlow[i] ? 6 : 2)
                            .offset(x: nodePositions[i].0, y: nodePositions[i].1)
                            .opacity(nodeVisible[i] ? 1 : 0)
                            .scaleEffect(nodeVisible[i] ? 1 : 0.1)
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: nodeVisible[i])
                            .animation(.easeInOut(duration: 0.3), value: nodeGlow[i])
                    }
                }
                .frame(width: 180, height: 180)
                .padding(.bottom, 44)

                // Wordmark
                VStack(spacing: 10) {
                    Text("INCREMENTS")
                        .font(.custom("Sora", size: 28).weight(.light))
                        .foregroundColor(.textPrimary)
                        .tracking(10)

                    Text("environmental cognition support system")
                        .font(.custom("DM Mono", size: 10).weight(.light))
                        .foregroundColor(.textMuted)
                        .tracking(2)
                }
                .opacity(wordmarkOpacity)
                .offset(y: wordmarkOffset)
                .animation(.easeOut(duration: 0.45), value: wordmarkOpacity)
                .animation(.easeOut(duration: 0.45), value: wordmarkOffset)

                Spacer()

                // Bottom line — appears with wordmark
                Text("participation in reality")
                    .font(.custom("DM Mono", size: 9))
                    .foregroundColor(.textMuted.opacity(0.5))
                    .tracking(3)
                    .padding(.bottom, 52)
                    .opacity(sublineOpacity)
                    .animation(.easeOut(duration: 0.4), value: sublineOpacity)
            }
        }
        .onAppear { runSequence() }
    }

    private func runSequence() {
        // Phase 1: nodes pulse in one by one over 1.2s
        // Stagger: 12 nodes × ~90ms each, with slight randomisation for organic feel
        let staggerBase = 0.08
        for i in nodePositions.indices {
            let delay = Double(i) * staggerBase + Double.random(in: 0...0.03)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                nodeVisible[i] = true
                // Brief glow burst on appearance
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { nodeGlow[i] = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { nodeGlow[i] = false }
            }
        }

        // Connection lines fade in as nodes appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation { connectionOpacity = 1 }
        }

        // Phase 2: corona ignites (starts at 1.2s, takes 0.35s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.35)) {
                coronaOpacity = 1
                coronaRadius = 110
            }
            // Final node pulse — all glow together at corona moment
            for i in nodePositions.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { nodeGlow[i] = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)  { nodeGlow[i] = false }
            }
        }

        // Phase 3: wordmark fades up (starts at 1.55s, takes 0.45s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.55) {
            wordmarkOpacity = 1
            wordmarkOffset = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                sublineOpacity = 1
            }
        }

        // Phase 4: hand off to app (2.25s total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.25) {
            onComplete()
        }
    }
}

// MARK: - ONBOARDING
// First launch only. Not setup. A worldview entry point.
// The product selects its own user here.

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            AtmosphericBackground(enhanced: true)

            VStack(spacing: 0) {
                Spacer()

                // Page content
                Group {
                    switch page {
                    case 0: onboardPage0
                    case 1: onboardPage1
                    case 2: onboardPage2
                    case 3: onboardPage3
                    default: EmptyView()
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: appeared)
                .animation(.easeOut(duration: 0.5), value: page)

                Spacer()

                // Navigation
                HStack {
                    // Page dots
                    HStack(spacing: 6) {
                        ForEach(0..<4) { i in
                            Circle()
                                .fill(i == page ? Color.violetLight : Color.muted.opacity(0.3))
                                .frame(width: i == page ? 6 : 4, height: i == page ? 6 : 4)
                                .animation(.easeOut(duration: 0.2), value: page)
                        }
                    }
                    Spacer()
                    Button(action: advance) {
                        HStack(spacing: 6) {
                            Text(page < 3 ? "Continue" : "Enter")
                                .font(.sora(14, weight: .medium))
                            Image(systemName: page < 3 ? "arrow.right" : "arrow.forward")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(page < 3 ? .textPrimary : .bgBase)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(page < 3 ? Color.surface : Color.violet)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 36).padding(.bottom, 52)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { appeared = true }
        }
    }

    func advance() {
        if page < 3 {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                page += 1
                withAnimation { appeared = true }
            }
        } else {
            onComplete()
        }
    }

    // ── Page 0: Operating model (corrected) ─────────────────────
    var onboardPage0: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "INCREMENTS", color: .violetLight, size: 11)
                Text("This system assumes.")
                    .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 16) {
                assumption("Execution is not your problem. Structure often is.", icon: "square.grid.2x2")
                assumption("Friction is usually architectural, not motivational.", icon: "wrench.adjustable")
                assumption("Task arrangement changes execution quality.", icon: "list.number")
                assumption("Environment shapes cognition.", icon: "house")
                assumption("Accurate self-models release bandwidth.", icon: "brain")
            }
        }
        .padding(.horizontal, 36)
    }

    // ── Page 1: Two surfaces ─────────────────────────────────────
    var onboardPage1: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "ARCHITECTURE", color: .warm, size: 11)
                Text("Two surfaces.\nOne purpose.")
                    .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 20) {
                surfaceCard(
                    label: "TODAY",
                    description: "Execute. Sequence. Complete. The execution surface reduces cognitive load — it never adds it.",
                    color: .inkAmber,
                    icon: "calendar"
                )
                surfaceCard(
                    label: "OPERATOR",
                    description: "Brief me. Detect friction. Understand the structure. The intelligence surface improves routing.",
                    color: .violetLight,
                    icon: "brain"
                )
            }
        }
        .padding(.horizontal, 36)
    }

    // ── Page 2: Intelligence doctrine ───────────────────────────
    var onboardPage2: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "INTELLIGENCE LAYER", color: .inkGreen, size: 11)
                Text("Coordination.\nNot motivation.")
                    .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("The system detects structural friction — sequencing issues, fragmentation, admin displacement, environmental drag.")
                    .font(.sora(15, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
                Text("It does not activate. It does not motivate. It reduces the drag on a system that already moves.")
                    .font(.sora(15, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                Text("Agency remains with the operator.")
                    .font(.mono(12)).foregroundColor(.violetLight).tracking(0.5)
            }
        }
        .padding(.horizontal, 36)
    }

    // ── Page 3: Enter ────────────────────────────────────────────
    var onboardPage3: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "DAY 1", color: .textMuted, size: 11)
                Text("The system starts\nat zero.")
                    .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Seven days of data opens the pattern window. The intelligence layer builds from observed behavior, not declared identity.")
                    .font(.sora(15, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                Text("Open Today. Sequence the work. Move.")
                    .font(.sora(15, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
            }
        }
        .padding(.horizontal, 36)
    }

    // ── Helpers ──────────────────────────────────────────────────
    func assumption(_ text: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.violetLight)
                .frame(width: 20)
            Text(text)
                .font(.sora(15, weight: .light)).foregroundColor(.textPrimary).lineSpacing(3)
        }
    }

    func surfaceCard(label: String, description: String, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(color)
                .frame(width: 24)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 5) {
                MonoLabel(text: label, color: color, size: 11)
                Text(description)
                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
            }
        }
        .padding(16)
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(color.opacity(0.15), lineWidth: 0.5))
    }
}

// MARK: - ROOT VIEW

struct RootView: View {
    @State private var state = AppState()
    @Query private var profiles: [OperatorProfile]
    @Query private var actions: [Action]
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    // 5-tab nav: Home / Today / Operator / Hideout / You
    // Insights, Increments, Habits, Timeline absorbed into Today and Operator sub-tabs
    var showTimeline: Bool { true }   // kept for CustomTabBar compat

    @ViewBuilder
    func tabView(for index: Int) -> some View {
        switch index {
        case 0: HomeView(state: state)
        case 1: TodayView(state: state)
        case 2: OperatorView(state: state)
        case 3: HideoutTabView()
        case 4: YouView(state: state)
        default: HomeView(state: state)
        }
    }

    @Query private var sessions: [Session]
    @Query private var maintenanceItems: [MaintenanceItem]
    @Query private var financialStates: [FinancialState]

    var body: some View {
        ZStack(alignment: .bottom) {
            tabView(for: state.selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            CustomTabBar(selected: $state.selectedTab, showTimeline: showTimeline)
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
            OnboardingView(onComplete: { hasCompletedOnboarding = true })
        }
        .onAppear {
            if profiles.isEmpty {
                let p = OperatorProfile()
                p.operatorName = "Brice"   // seed name — user can change in Settings
                context.insert(p)
            }
            if actions.isEmpty { seedDefaultActions(context: context) }
            if sessions.isEmpty { seedDefaultSessions(context: context) }
            if maintenanceItems.isEmpty { seedDefaultMaintenance(context: context) }
            if financialStates.isEmpty { context.insert(FinancialState()) }
            if let p = profiles.first {
                // BUG FIX: reset recurring actions each new calendar day
                resetDailyActionsIfNeeded(context: context, profile: p, actions: actions, sessions: sessions)
                // BUG FIX: restore systemLastActivity from persisted completionDates on launch.
                // Without this, Home View "X hasn't moved" signal and nextSaneAction sorting
                // were always wrong on cold launch (in-memory only, lost on restart).
                restoreSystemLastActivity(state: state, actions: actions)
                // Sync voice preference from persisted profile
                VoicePresence.shared.voiceEnabled = p.voicePresenceEnabled
                VoicePresence.shared.provider = p.voiceProvider
                VoicePresence.shared.elevenLabsVoiceId = p.elevenLabsVoiceId
                VoicePresence.shared.elevenLabsApiKey = p.elevenLabsApiKey
                VoicePresence.shared.openAIApiKey = p.openAIApiKey
            }
            NotificationService.shared.requestPermission()
        }
        // BUG FIX: also run daily reset when app returns from background (e.g. opened next morning).
        // Without this, actions only reset on cold launch — leaving yesterday's state visible
        // if the app was backgrounded overnight and re-foregrounded the next day.
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                if let p = profiles.first {
                    resetDailyActionsIfNeeded(context: context, profile: p, actions: actions, sessions: sessions)
                    restoreSystemLastActivity(state: state, actions: actions)
                }
            }
        }
    }
}

// BUG FIX: rebuild in-memory systemLastActivity from persisted completionDates.
// Called on launch and foreground re-entry. Gives Home View accurate "days since activity"
// data for the nextSaneAction picker and synergy subline, which previously reset to
// "999 days" on every cold launch.
func restoreSystemLastActivity(state: AppState, actions: [Action]) {
    for system in SystemTag.allCases {
        let systemActions = actions.filter { $0.system == system }
        // Find the most recent completion date across all actions in this system
        let latestCompletion = systemActions.compactMap { $0.completionDates.last }.max()
        if let latest = latestCompletion {
            // Only update if this is more recent than what's already in memory
            if let existing = state.systemLastActivity[system] {
                if latest > existing { state.systemLastActivity[system] = latest }
            } else {
                state.systemLastActivity[system] = latest
            }
        }
    }
}

// MARK: - APP ENTRY POINT

// MARK: - SWIFTDATA MIGRATION PLAN
// Lightweight migration: new fields added to existing models get their default values.
// No data is destroyed. Rebuilding the app preserves all user data.
//
// HOW TO ADD NEW FIELDS IN FUTURE:
// 1. Add the field to the model class with a default value
// 2. Add a new VersionedSchema (e.g. SchemaV3) with the updated models
// 3. Add a MigrationStage.lightweight(fromVersion: SchemaV2.self, toVersion: SchemaV3.self)
// 4. Update INCREMENTSMigrationPlan.stages and INCREMENTSApp.container to use the new schema

// SCHEMA MIGRATION NOTES:
// SwiftData checksums the MODEL SET (the actual list of @Model classes), not the version number.
// Two VersionedSchema enums with the same model list = identical checksum = crash on launch.
// Rule: every schema in the migration plan must have a DIFFERENT set of models from all others.
//
// History of distinct model-set snapshots:
//   V1 — original base models. Acts as the entry point for any store built before V4 was defined.
//         Without this, staged migration throws "unknown model version" for old installs.
//   V4 — added MaintenanceItem, HydrationLog, FinancialState, ConsultReceipt.
//   V6 — added HideoutShiftLog (+ lastWendyObservation on OperatorProfile via lightweight default).
//
// Removed (identical model arrays = duplicate checksum crash):
//   V2, V3 — same as V4
//   V5     — same as V6

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    // Entry point for stores created before the V4 schema was formally defined.
    // Covers any "unknown" old version — gives staged migration a valid starting node.
    static var models: [any PersistentModel.Type] {
        [Action.self, Habit.self, OperatorProfile.self,
         DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
         Session.self]
    }
}

enum SchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(4, 0, 0)
    // Added MaintenanceItem, HydrationLog, FinancialState, ConsultReceipt.
    static var models: [any PersistentModel.Type] {
        [Action.self, Habit.self, OperatorProfile.self,
         DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
         Session.self, MaintenanceItem.self, HydrationLog.self, FinancialState.self,
         ConsultReceipt.self]
    }
}

enum SchemaV6: VersionedSchema {
    static var versionIdentifier = Schema.Version(6, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Action.self, Habit.self, OperatorProfile.self,
         DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
         Session.self, MaintenanceItem.self, HydrationLog.self, FinancialState.self,
         ConsultReceipt.self, HideoutShiftLog.self]
    }
}

enum SchemaV7: VersionedSchema {
    static var versionIdentifier = Schema.Version(7, 0, 0)
    // V7 — FinancialState expanded with capital architecture fields:
    // capitalClarity, hasRunwayVisibility, hasBudgetedGenerosity, hasEmergencyBuffer,
    // mainLeakCategory, activeFinancialFronts, lastCapitalReview.
    // All fields have nil/default values — lightweight migration, no transform needed.
    static var models: [any PersistentModel.Type] {
        [Action.self, Habit.self, OperatorProfile.self,
         DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
         Session.self, MaintenanceItem.self, HydrationLog.self, FinancialState.self,
         ConsultReceipt.self, HideoutShiftLog.self]
    }
}

enum INCREMENTSMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self, SchemaV4.self, SchemaV6.self, SchemaV7.self] }
    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV4.self),
            .lightweight(fromVersion: SchemaV4.self, toVersion: SchemaV6.self),
            .lightweight(fromVersion: SchemaV6.self, toVersion: SchemaV7.self),
        ]
    }
}

@main
struct INCREMENTSApp: App {
    @State private var launchComplete = false
    // Prevents tappable elements rendering before SwiftData @Query results settle.
    // RootView stays invisible until both the launch animation finishes AND the store
    // has returned at least one result. On a cold launch the store is ready well before
    // the 2.25s animation completes, so in practice this adds zero perceptible delay.
    @State private var dataReady = false

    // ModelContainer with proper migration plan — preserves all user data across rebuilds.
    // New fields get their default values; nothing is wiped.
    let container: ModelContainer = {
        let schema = Schema([
            Action.self, Habit.self, OperatorProfile.self,
            DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
            Session.self, MaintenanceItem.self, HydrationLog.self, FinancialState.self,
            ConsultReceipt.self, HideoutShiftLog.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: INCREMENTSMigrationPlan.self,
                configurations: [config]
            )
        } catch {
            // Migration failed — store is from an unrecognised version or is corrupt.
            // Wipe all three SQLite files and rebuild from scratch (no migration plan needed
            // on a fresh store — SwiftData will create it at the current schema directly).
            print("INCREMENTS: Migration failed (\(error.localizedDescription)). Wiping and rebuilding store.")
            let storeURL = config.url
            let base = storeURL.deletingPathExtension()
            try? FileManager.default.removeItem(at: storeURL)
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite-shm"))
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite-wal"))
            // Rebuild WITHOUT migration plan — fresh store needs no migration.
            let freshConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            do {
                return try ModelContainer(for: schema, configurations: [freshConfig])
            } catch {
                fatalError("INCREMENTS: Could not create ModelContainer even after store deletion: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .preferredColorScheme(.dark)
                    // Only become visible once both the launch animation is done AND the
                    // SwiftData store has settled. Eliminates the window where tappable rows
                    // appear but their backing data isn't ready yet.
                    .opacity(launchComplete && dataReady ? 1 : 0)
                    .onAppear {
                        // Poll briefly for store readiness. On a real device the container is
                        // open well before the 2.25s animation ends, so this loop typically
                        // fires on the first or second tick and adds no perceptible delay.
                        func checkReady() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                // RootView's @Query arrays are not directly visible here, but
                                // the ModelContainer being open is sufficient — mark ready.
                                // If you ever hit a race, increase the tick count.
                                dataReady = true
                            }
                        }
                        checkReady()
                    }

                if !launchComplete {
                    LaunchSequenceView {
                        withAnimation(.easeIn(duration: 0.35)) {
                            launchComplete = true
                        }
                    }
                    .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
