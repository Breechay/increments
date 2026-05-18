import SwiftUI
import SwiftData
import Foundation
import AVFoundation
import Combine

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
        // EXPL-01 — Buy-in mechanics for this operator:
        // When surfacing a missed or skipped action, name the mechanism not the absence.
        // Wrong: 'You've skipped PM oral care.'
        // Right: 'Flossing before brushing is what clears interdental bacteria — brushing after flossing is what makes the sequence effective.'
        // The mechanism is the intervention. Nagging is not.
    ]

    // MARK: Buy-in mechanics (operator-specific, May 2026)
    // Adherence improves through causal understanding, not reminder pressure.
    // "Reality becoming legible" is the emotional product experience.
    // When mechanism is understood: resistance drops, quality rises, repetition becomes intrinsically rewarding.
    static let adherenceMechanism = "causal understanding + structural clarity"
    static let adherenceIsNotImprovedBy = ["guilt", "streak pressure", "motivational language", "simplification alone"]

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

// MARK: - OBSERVED SIGNAL (typed — future Wendy interface)
// Current implementation passes freeform strings into Wendy payload.
// This typed struct is the target architecture when the system matures.
// When confidence model is stable, replace wendyPayloadLines with [ObservedSignal].

struct ObservedSignal {
    enum SignalType {
        case frictionTopology
        case energyCalibration
        case adminDisplacement
        case fragmentation
        case generativeRatio
        case timingPattern
    }

    enum Confidence {
        case low        // do not surface — silence
        case medium     // tentative — "signal suggests"
        case high       // direct — "pattern shows"
        case confirmed  // intervention-grade — sustained across multiple windows
    }

    let type: SignalType
    let confidence: Confidence
    let evidenceWindowDays: Int
    let message: String         // for Wendy payload
    let uiLabel: String?        // for surface display (nil = don't surface yet)
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

    // Close Day debrief signals (self-report — calibration layer)
    let debriefCount: Int
    let operationalTakeoverDays: Int
    let capitalPressureDays: Int
    let meaningfulWorkMovedDays: Int
    let dominantReportedBlocker: String?
    // Sleep correlation
    let roughSleepAvgCompletions: Double
    let goodSleepAvgCompletions: Double
    // Environment reset correlation
    let resetDaysAvgCompletions: Double
    let noResetDaysAvgCompletions: Double
    // Social and location
    let highSocialDrainDays: Int
    let hideoutWorkDays: Int
    let homeWorkDays: Int

    // Summary observation for Wendy payload
    var wendyPayloadLines: [String] {
        var lines: [String] = []

        if let ft = dominantFrictionType {
            switch ft {
            case .administrativeDisplacement:
                lines.append("OBSERVED PATTERN: Admin displacement likely contributing — \(adminDisplacementFrequency) of last 14 days showed admin without generative follow-through.")
            case .structuralFragmentation:
                lines.append("OBSERVED PATTERN: Fragmentation signal — \(estimatedOpenFronts) systems with stalled actions.")
            case .sequencingAmbiguity:
                lines.append("OBSERVED PATTERN: Repeated sequencing stalls — high-friction actions suggest unclear execution order.")
            default:
                break
            }
        }

        switch energyDeclarationAccuracy {
        case .inverted:
            lines.append("OBSERVED PATTERN: Reserve days outperforming full declarations. Energy self-model may be underestimating available capacity.")
        case .uncalibrated:
            lines.append("OBSERVED PATTERN: Weak correlation between declared energy and actual output — calibration uncertain.")
        case .calibrated, .insufficient:
            break
        }

        if adminDisplacementRisk && dominantFrictionType != .administrativeDisplacement {
            lines.append("OBSERVED PATTERN: Admin displacement — \(adminDisplacementFrequency) of last 14 days.")
        }

        if estimatedOpenFronts >= OperatorDoctrine.openFrontFragmentationThreshold && dominantFrictionType != .structuralFragmentation {
            lines.append("OBSERVED PATTERN: \(estimatedOpenFronts) stalled systems — fragmentation risk rising.")
        }

        if generativeRatio < 0.25 {
            lines.append("OBSERVED PATTERN: \(Int(generativeRatio * 100))% of recent completions are generative. Operational work dominant.")
        }

        // Debrief-derived signals — self-report calibration layer
        if debriefCount >= 5 {
            if operationalTakeoverDays >= 2 {
                lines.append("DEBRIEF SIGNAL: Upkeep took over on \(operationalTakeoverDays) of \(debriefCount) debriefed days.")
            }
            if capitalPressureDays >= 2 {
                lines.append("DEBRIEF SIGNAL: Money weighed on cognition \(capitalPressureDays) of \(debriefCount) debriefed days.")
            }
            if let blocker = dominantReportedBlocker, blocker != "Nothing really" {
                lines.append("DEBRIEF SIGNAL: Most reported drag — \"\(blocker)\".")
            }
            // Sleep correlation — only surface when delta is meaningful
            if roughSleepAvgCompletions > 0 && goodSleepAvgCompletions > 0 {
                let delta = goodSleepAvgCompletions - roughSleepAvgCompletions
                if delta >= 2 {
                    lines.append("DEBRIEF CORRELATION: Good sleep predicts \(Int(delta)) more completions on average vs rough sleep.")
                }
            }
            // Environment reset correlation
            if resetDaysAvgCompletions > 0 && noResetDaysAvgCompletions > 0 {
                let delta = resetDaysAvgCompletions - noResetDaysAvgCompletions
                if delta >= 2 {
                    lines.append("DEBRIEF CORRELATION: Environment reset days produce \(Int(delta)) more completions on average.")
                }
            }
            if highSocialDrainDays >= 2 {
                lines.append("DEBRIEF SIGNAL: High social drain reported \(highSocialDrainDays) days in window.")
            }
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

        // ── Close Day signal aggregation ─────────────────────────────────
        let debriefLogs = logs.filter { $0.hasFullDebrief }

        // Operational takeover
        let operationalTakeoverDays = debriefLogs.filter {
            $0.operationalTakeover == "Yes" || $0.operationalTakeover == "Yes, and important work got pushed"
        }.count

        // Capital pressure
        let capitalPressureDays = debriefLogs.filter {
            $0.capitalPressure == "Yes" || $0.capitalPressure == "Definitely"
        }.count

        // Meaningful work moved
        let meaningfulWorkMovedDays = debriefLogs.filter {
            $0.meaningfulWorkMoved == "Yes, significantly" || $0.meaningfulWorkMoved == "Yes, a little"
        }.count

        // Sleep correlation — did bad sleep predict worse output?
        let roughSleepDays = debriefLogs.filter {
            $0.sleepQuality == "Rough" || $0.sleepQuality == "Bad"
        }
        let roughSleepAvgCompletions = roughSleepDays.isEmpty ? 0.0 :
            Double(roughSleepDays.map { $0.completedCount }.reduce(0, +)) / Double(roughSleepDays.count)
        let goodSleepDays = debriefLogs.filter {
            $0.sleepQuality == "Slept well" || $0.sleepQuality == "Decent"
        }
        let goodSleepAvgCompletions = goodSleepDays.isEmpty ? 0.0 :
            Double(goodSleepDays.map { $0.completedCount }.reduce(0, +)) / Double(goodSleepDays.count)

        // Environment reset correlation
        let resetDays = debriefLogs.filter {
            $0.environmentReset == "Yes, early — before work started" ||
            $0.environmentReset == "Yes, mid-day"
        }
        let noResetDays = debriefLogs.filter { $0.environmentReset == "No reset today" }
        let resetAvg = resetDays.isEmpty ? 0.0 :
            Double(resetDays.map { $0.completedCount }.reduce(0, +)) / Double(resetDays.count)
        let noResetAvg = noResetDays.isEmpty ? 0.0 :
            Double(noResetDays.map { $0.completedCount }.reduce(0, +)) / Double(noResetDays.count)

        // Dominant reported blocker
        let blockers = debriefLogs.compactMap { $0.mainBlocker }
        let blockerFreq = Dictionary(grouping: blockers) { $0 }.mapValues { $0.count }
        let dominantReportedBlocker = blockerFreq.max(by: { $0.value < $1.value })?.key

        // Social load drag signal
        let highSocialDrainDays = debriefLogs.filter { $0.socialLoad == "Draining" }.count

        // Location pattern
        let hideoutDays = debriefLogs.filter { $0.whereWorked == "Hideout" }.count
        let homeDays = debriefLogs.filter { $0.whereWorked == "Home" }.count
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
            frictionSig = "Signal: admin displacement likely contributing to morning pattern"
        case .structuralFragmentation:
            frictionSig = "Signal: \(stalledSystems) stalled fronts — possible fragmentation"
        case .sequencingAmbiguity:
            frictionSig = "Signal: repeated sequencing stalls detected"
        case .none:
            frictionSig = "No dominant friction signal in current window"
        default:
            frictionSig = "Mixed signals — insufficient pattern"
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
            generativeRatio: generativeRatio,
            debriefCount: debriefLogs.count,
            operationalTakeoverDays: operationalTakeoverDays,
            capitalPressureDays: capitalPressureDays,
            meaningfulWorkMovedDays: meaningfulWorkMovedDays,
            dominantReportedBlocker: dominantReportedBlocker,
            roughSleepAvgCompletions: roughSleepAvgCompletions,
            goodSleepAvgCompletions: goodSleepAvgCompletions,
            resetDaysAvgCompletions: resetAvg,
            noResetDaysAvgCompletions: noResetAvg,
            highSocialDrainDays: highSocialDrainDays,
            hideoutWorkDays: hideoutDays,
            homeWorkDays: homeDays
        )
    }
}
// Intelligence Layer Doctrine v6.0 — coordination intelligence.
// BEHAVIORAL MODEL CORRECTION: this operator does not need activation.
// He needs structural clarity, sequencing, and friction detection.

// Wrapped in a nonisolated enum so the string is accessible from any concurrency context.
// File-scope `let` gets main-actor isolation in Swift 6; static on a nonisolated type does not.
nonisolated enum WendyPrompts {
    static let system: String = _wendySystemPromptValue
    static let consult: String = _consultSystemPromptValue
}

// The actual string — stored as a file-scope private let for heredoc syntax.
// Access via WendyPrompts.system, never directly.
nonisolated(unsafe) private let _wendySystemPromptValue: String = """
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
1. PERSONAL: 4AM wake. Morning anchor + cardio (bike/elliptical) 4:30–5:10AM. Commute: 26th floor condo → elevated terrace patio (same building, second floor). Hideout Wed–Fri 7AM–5PM, Sat–Sun 7AM–3PM. Mon–Tue base days. Deep work 8:30AM. Evening: Forge Breechay hypertrophy ~5:30PM. Sleep target 9:15–9:30PM.
2. BUSINESS: Hideout Miami — outdoor elevated terrace café, second floor of condo building. 30-day solo experiment. $3.5k gap, loan decision by June 13. Bands: survival <$520 · stability $590 · comfort $650 · growth $750+.
3. PHYSICAL: Currently ~12–13% body fat, goal 8–10%. Forge Breechay Hypertrophy Week 4+. Running limited — cardio via bike/elliptical. Strength training ~5:30PM. Post-workout protein within 30 minutes. Hideout is outdoor/terrace — natural light, open air.

ADAPTIVE EXECUTION ARCHITECTURE:
Actions are tiered: anchor (16 — system degrades if omitted), phase (39 — current protocol), amplifier (17 — full days only). Energy states: full (all tiers), partial (anchor+phase), reserve (anchors only — body constrained, skip training/cardio), compressed (anchor+phase — schedule disrupted, training may survive). Default (no state set) = partial behavior.

RESERVE vs COMPRESSED distinction is intelligence-relevant:
- Reserve = internal constraint. 5 reserve days in a row = possible burnout signal. Training/cardio should not appear.
- Compressed = external constraint. 5 compressed days = environment pressure, not operator degradation. Training may still occur.
When analyzing patterns, distinguish these — they have different causes and different interventions.

ANCHOR INFLATION GUARD: anchor count should stay ≤18. If you observe anchor-tier actions being consistently skipped, that is a tier misclassification signal, not a motivation problem.

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

// Access via WendyPrompts.system

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

        // Reserve day declared — but protecting organism means the right things, not fewer things
        if ctx.energyState == .reserve && ctx.hour < 8 {
            return "Reserve. Infrastructure only — hydrate, supplements, protein, hygiene, sleep. No cardio, no training. Protect the system."
        }

        // State mismatch signal — declared reserve but performing full-day behavior
        if ctx.energyState == .reserve && ctx.completedToday >= 10 {
            return "Declared reserve. Completing \(ctx.completedToday) actions. Actual capacity may be higher than declared — worth noting."
        }

        // Compressed day — continuity framing
        if ctx.energyState == .compressed && ctx.hour < 10 {
            return "Compressed day. Anchors first. Deep work and training survive if a window opens. Amplifiers don't."
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
            "system": WendyPrompts.system,
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

// Consult prompt appended to Wendy system prompt — also stored on WendyPrompts for isolation safety.
// Access via WendyPrompts.consult
nonisolated(unsafe) private let _consultSystemPromptValue = WendyPrompts.system + """

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
            "system": WendyPrompts.consult,
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
    // 4AM wake architecture: anchor stack 4:00–5:50AM, hideout 7AM open
    // Hideout days (Wed–Fri): 7AM open, 5PM close
    // Hideout weekends (Sat–Sun): 7AM open, 3PM close. Commute: 26th floor condo → terrace patio.
    // Base days (Mon–Tue): ops/maintenance rhythm
    func scheduleAll(profile: OperatorProfile) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard !profile.quietMode else { return }

        // Daily nudges — time-slot aware, not generic
        // Format: (title, body, hour, minute, categoryEnabled, notifID)
        let nudges: [(String, String, Int, Int, Bool, String)] = [
            // 4:00 — morning anchor open (every day, 4AM wake)
            ("No phone. First hour starts now.",
             "",
             4, 0, profile.notifCategoryHealth, "increments-0"),
            // 7:30 — hideout open, priorities block
            ("Hideout open. Priorities first.",
             "",
             7, 30, profile.notifCategoryCognition, "increments-1"),
            // 12:00 — midday break (every day)
            ("Midday. Protein. Water. 15 min outside.",
             "",
             12, 0, profile.notifCategoryHealth, "increments-2"),
            // 16:30 — close of hideout day / afternoon wrap
            ("Wrapping up. What landed today?",
             "",
             16, 30, profile.notifCategoryOperations, "increments-3"),
            // 20:30 — evening anchor (early for 4AM wake / 9:30PM sleep)
            ("Evening shutdown. Journal. Phone away. Book.",
             "",
             20, 30, profile.notifCategoryHealth, "increments-4"),
        ]

        for (title, body, hour, min, enabled, id) in nudges {
            guard enabled else { continue }
            guard !isInQuietWindow(hour: hour, quietStart: profile.notifQuietStart, quietEnd: profile.notifQuietEnd) else { continue }
            schedule(id: id, title: title, body: body, hour: hour, minute: min)
        }

        // Hydration — 4AM wake schedule: covers full active window 7AM–7PM
        if profile.notifHydrationEnabled {
            let hydrationHours = [7, 10, 13, 16, 19]
            for (i, hour) in hydrationHours.enumerated() {
                guard !isInQuietWindow(hour: hour, quietStart: profile.notifQuietStart, quietEnd: profile.notifQuietEnd) else { continue }
                schedule(id: "increments-hydration-\(i)", title: "Water.", body: "", hour: hour, minute: 0)
            }
        }

        // Protein reminders
        if profile.notifProteinEnabled {
            let proteinTimes = [(9, 30), (13, 30), (18, 30)]   // 9:30AM first solid meal · 1:30PM midday · 6:30PM post-lift
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

