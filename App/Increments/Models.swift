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
// SCHED-01  — DayType enum: hideout (Wed–Sun 7AM open–5PM) vs base (Mon–Tue).
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
//             Every day: 4:00–5:50 morning anchor stack (4AM wake)
//             Hideout: 7:00 slow open → 7:15 behaviors → 7:30 priorities → 8:30 deep work → 12:00 midday
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
    case hideout = "hideout"   // Wed–Fri 7AM–5PM, Sat–Sun 7AM–3PM — deep work at the hideout
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

    // Brice's schedule (4AM wake):
    // Hideout: arrives 6:00 for prep, open at 7:00 (slow open — coffee, music, setup). Deep work starts 8:30.
    //          Wed–Fri closes 5PM → gym. Sat–Sun closes 3PM → afternoon free.
    // Base (Mon–Tue): cafe/ops rhythm. Gym at 5PM most days.
    var hideoutStartHour: Int { 7 }   // slow open — arrive by 7, not rushed
    var hideoutDeepWorkHour: Int { 8 } // deep work starts 8:30 (shown as "8:30" block)
    var hideoutEndHour: Int {
        let wd = Calendar.current.component(.weekday, from: Date())
        return (wd == 1 || wd == 7) ? 15 : 17   // 3PM weekends (Sat–Sun), 5PM weekdays (Wed–Fri)
    }
    var gymHour: Int { 17 }   // 5:30PM gym anchor — Forge Breechay after hideout

    var isHideoutHours: Bool {
        guard self == .hideout else { return false }
        let h = Calendar.current.component(.hour, from: Date())
        return h >= hideoutStartHour && h < hideoutEndHour
    }
}



// ARCH-01 — PriorityTier: constraint-aware surfacing.
//
// ANCHOR INFLATION GUARD: anchor means "system degrades if omitted repeatedly."
// NOT "important" or "I like this." Test: if skipped 3x in a row, does measurable
// system performance degrade? If no → it is phase, not anchor.
// Current correct anchors: ~13 actions. If anchor count exceeds 18, audit required.
//
// RESERVE interpretation: body/energy constrained. Show anchors only.
//   Exclude: cardio, training, deep work. Protect organism.
// COMPRESSED interpretation: schedule/external disrupted. Show anchor + phase.
//   Preserve continuity. Training may survive. Deep work may not.
//
enum PriorityTier: String, Codable {
    case anchor     = "anchor"      // degrades if omitted repeatedly. ~10–13 actions max.
    case phase      = "phase"       // current protocol. surfaces in full + partial.
    case amplifier  = "amplifier"   // optimization layer. surfaces in full only.
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
    // ARCH-01 — priority tier for constraint-aware surfacing
    var priorityTierRaw: String? = nil   // nil = phase (default)
    // EXPL-01 — two-layer note architecture (May 2026)
    // note = execution cue: short, immediate, what to do
    // mechanismNote = causal mechanism: why it works this way, what breaks if you deviate
    // UI shows note always. mechanismNote behind a tap ("Why this works").
    var mechanismNote: String? = nil

    var priorityTier: PriorityTier {
        guard let raw = priorityTierRaw else { return .phase }
        return PriorityTier(rawValue: raw) ?? .phase
    }

    var prescribedDayType: DayType? {
        guard let raw = dayTypeRaw else { return nil }
        return DayType(rawValue: raw)
    }

    init(title: String, system: SystemTag, points: Int = 10,
         recurrence: RecurrenceType = .daily, scheduledTime: Date? = nil,
         note: String? = nil, cue: String? = nil,
         scheduledBlock: String? = nil, dayTypeRaw: String? = nil,
         priorityTierRaw: String? = nil, mechanismNote: String? = nil) {
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
        self.priorityTierRaw = priorityTierRaw
        self.mechanismNote = mechanismNote
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
    var trainingProgramStartDate: Date = Calendar.current.date(byAdding: .day, value: -22, to: Date()) ?? Date() // default: ~week 4
    var lastResetDate: Date? = nil   // FIX: tracks last day daily actions were reset

    // Phase 2 — Notification personalization
    var notifQuietStart: Int = 21   // hour (24h): quiet window start (9pm — 9:30 sleep)
    var notifQuietEnd: Int = 4      // hour (24h): quiet window end (4am wake)
    var notifCategoryEnvironment: Bool = true
    var notifCategoryCognition: Bool = true
    var notifCategoryHealth: Bool = true
    var notifCategoryOperations: Bool = true
    var notifCategoryParticipation: Bool = true
    var notifHydrationEnabled: Bool = true    // on by default — habit training
    var notifProteinEnabled: Bool = true      // on by default — habit training

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

    var trainingWeek: Int {
        let days = Calendar.current.dateComponents([.day], from: trainingProgramStartDate, to: Date()).day ?? 0
        return max(1, (days / 7) + 1)
    }

    // Home greeting — time-aware, location-aware, never cheesy
    func homeGreeting(completedToday: Int) -> String {
        let n = nameFragment
        let address = n.isEmpty ? "" : "\(n). "
        let dayType = DayType.today

        switch timePeriod {
        case .earlyMorning:
            if isMonday { return "\(address)New week. Base day. Start it right." }
            if dayType == .hideout {
                return "\(address)Hideout opens at 7. Morning anchor first."
            }
            return "\(address)4AM. Morning anchor. Full day ahead."
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
                let hour = Calendar.current.component(.hour, from: Date())
                let endHour = DayType.today.hideoutEndHour
                if hour >= endHour {
                    // Past closing time
                    if completedToday == 0 { return "\(address)Hideout closed. Log the shift." }
                    return "\(address)Hideout closed. Gym next."
                }
                let wd = Calendar.current.component(.weekday, from: Date())
                let endLabel = (wd == 1 || wd == 7) ? "3pm" : "5pm"
                return "\(address)Closing window. Until \(endLabel)."
            }
            if isFriday && completedToday == 0 { return "\(address)Friday afternoon." }
            if completedToday == 0 { return "\(address)Afternoon." }
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
    var energyStateRaw: String? = nil
    var firstSystemTouched: String? = nil
    var firstCompletionHour: Int? = nil

    // ── CLOSE DAY — FULL SIGNAL CAPTURE ─────────────────────────────────
    // Every field feeds ObservedIntelligenceEngine.
    // Human language in UI. Taxonomy lives in the engine.

    // BLOCK 1 — Physical foundation
    var sleepQuality: String? = nil
    // "Slept well" / "Decent" / "Rough" / "Bad"

    var physicalMovement: String? = nil
    // "Full workout" / "Light movement" / "Walk only" / "Nothing"

    var bodyFeel: String? = nil
    // "Good" / "Fine" / "Stiff/sore" / "Low energy" / "Off"

    // BLOCK 2 — Operating state
    var dayFeel: String? = nil
    // "Sharp" / "Smooth" / "Fine" / "Scattered" / "Heavy" / "Drained" / "Reactive"

    var momentumAtClose: String? = nil
    // "Strong" / "Solid" / "Okay" / "Lost it" / "Never had it"

    var decisionFatigue: String? = nil
    // "Fresh" / "Mild" / "Noticeably tired" / "Fried"

    // BLOCK 3 — Work quality
    var meaningfulWorkMoved: String? = nil
    // "Yes, significantly" / "Yes, a little" / "Not really" / "No, life stuff took over"

    var deepestFocusBlock: String? = nil
    // "2+ hours" / "1 hour" / "30 minutes" / "Fragmented — no real block"

    var whereWorked: String? = nil
    // "Hideout" / "Home" / "Café" / "Mixed" / "Mostly out"

    var systemThatMovedMost: String? = nil
    // System tag raw value — self-reported vs passively detected

    // BLOCK 4 — Drag sources
    var mainBlocker: String? = nil
    // "Too many things open" / "Didn't know what to do first" /
    // "Small tasks ate the day" / "Messy environment" / "Interruptions" /
    // "Low energy" / "Money on my mind" / "Hideout/business" /
    // "Other people" / "Body wasn't cooperating" / "Nothing really"

    var operationalTakeover: String? = nil
    // "No" / "A little" / "Yes" / "Yes, and important work got pushed"

    var socialLoad: String? = nil
    // "Low — mostly solo" / "Normal" / "High — lots of people" / "Draining"

    // BLOCK 5 — Environment
    var environmentEffect: String? = nil
    // "Helped" / "Neutral" / "Hurt" / "Reset fixed it"

    var environmentReset: String? = nil
    // "Yes, early" / "Yes, mid-day" / "Yes, late" / "No reset"

    // BLOCK 6 — External pressures
    var capitalPressure: String? = nil
    // "No" / "Slightly" / "Yes" / "Definitely"

    var hideoutPressure: String? = nil
    // "No shift today" / "Good shift" / "Okay shift" / "Tough shift" / "Stressful"

    // BLOCK 7 — What worked
    var mainUnlock: String? = nil
    // "Cleaning/reset" / "Workout" / "Walk" / "Food" / "Music" / "Clear plan" /
    // "Getting out" / "One small win" / "Conversation" / "Sleep" / "Money clarity" /
    // "Structure" / "Nothing specific"

    // BLOCK 8 — Close
    var closingNote: String? = nil
    var tomorrowPriority: String? = nil  // pre-commitment — shows in morning

    // Computed
    var hasFullDebrief: Bool { dayFeel != nil && meaningfulWorkMoved != nil }

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
            // Named Sunday-only sessions: only appear on Sunday (weekday == 1)
            let isSunday = Calendar.current.component(.weekday, from: Date()) == 1
            let titleLower = title.lowercased()
            let isSundaySession = titleLower.contains("weekly reset") || titleLower.contains("make something")
            if isSundaySession && !isSunday { return false }
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
        // Bands from brief: Survival floor ~$520, Stability ~$590, Comfort ~$650, Growth ~$750.
        // Below $520 = below survival. $520–$589 = survival floor met. $590–$649 = stability.
        // $650–$749 = comfort. $750+ = growth.
        switch revenue {
        case ..<520:      return .unknown    // below survival floor — not yet viable
        case 520..<590:   return .survival   // survival floor met; gap to stability remains
        case 590..<650:   return .stability  // stability target met; comfort in reach
        case 650..<750:   return .comfort    // comfort met; reinvestment possible
        default:          return .growth     // growth band — all costs + reinvestment buffer
        }
    }

    var label: String {
        switch self {
        case .unknown:   return "Below survival"
        case .survival:  return "Survival floor"
        case .stability: return "Stability"
        case .comfort:   return "Comfort"
        case .growth:    return "Growth"
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
    // Repeat vs new customer tracking — the most strategically critical data point
    var repeatCustomerCount: Int = 0    // regulars / returning customers today
    var newCustomerCount: Int = 0       // first-timers today
    // Peak burst — operational capacity signal
    var peakBurstUpdated: Int = 0       // max tickets in any 30-min window (replaces peakBurst)
    // Freeform
    var notes: String = ""
    // Solo experiment day number — computed at save
    var experimentDay: Int = 1
    // Date override — for retroactive logging
    var dateOverride: Date? = nil       // if set, use this instead of date for display

    var logDate: Date { dateOverride ?? date }

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

    var repeatPercent: Double? {
        let total = repeatCustomerCount + newCustomerCount
        guard total > 0 else { return nil }
        return Double(repeatCustomerCount) / Double(total)
    }

    // Estimated contribution after COGS (25%) and Square fees (3%)
    var estimatedContribution: Double {
        grossRevenue * (1 - 0.25 - 0.03)
    }

    // Solo contribution (no labor cost)
    var soloContribution: Double {
        usedStaff ? grossRevenue * 0.72 - 160 : grossRevenue * 0.72
    }

    var dayLabel: String {
        let cal = Calendar.current
        let d = logDate
        if cal.isDateInToday(d) { return "TODAY" }
        if cal.isDateInYesterday(d) { return "YESTERDAY" }
        return d.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
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
    case full       = "full"
    case partial    = "partial"
    case reserve    = "reserve"
    case compressed = "compressed"  // schedule collapse: hideout chaos, travel, illness. anchors + ops only.

    var label: String {
        switch self {
        case .full:       return "Full"
        case .partial:    return "Partial"
        case .reserve:    return "Reserve"
        case .compressed: return "Compressed"
        }
    }
    var sublabel: String {
        switch self {
        case .full:       return "Operational. Full stack."
        case .partial:    return "Partial. Anchors + phase actions."
        case .reserve:    return "Body constrained. Infrastructure only. Skip training and cardio."
        case .compressed: return "Schedule disrupted. Anchors + continuity. Training survives if time allows."
        }
    }
    var color: Color {
        switch self {
        case .full:       return .inkGreen
        case .partial:    return .inkAmber
        case .reserve:    return .inkTeal
        case .compressed: return .textMuted
        }
    }
    var icon: String {
        switch self {
        case .full:       return "circle.fill"
        case .partial:    return "circle.lefthalf.filled"
        case .reserve:    return "circle.dotted"
        case .compressed: return "minus.circle"
        }
    }
    // How many actions to show in Today stack
    // stackLimit retained for legacy compatibility — tier-aware surfacing is now primary via visibleTiers
    var stackLimit: Int { 999 }
    // Doctrine line for non-full states
    var doctrineOverride: String? {
        switch self {
        case .full:       return nil
        case .partial:    return nil  // rail filtered to anchor + phase — that's the signal
        case .reserve:    return "Reserve. Anchors only. Protect the body."
        case .compressed: return "Compressed. Anchors + continuity. Protect the thread."
        }
    }

    var visibleTiers: Set<PriorityTier> {
        switch self {
        case .full:       return [.anchor, .phase, .amplifier]
        case .partial:    return [.anchor, .phase]
        case .reserve:    return [.anchor]           // body constrained — skeleton only
        case .compressed: return [.anchor, .phase]  // schedule constrained — continuity matters
        }
    }
}

// MARK: - APP STATE

@Observable
class AppState {
    var selectedTab: Int = 1
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

