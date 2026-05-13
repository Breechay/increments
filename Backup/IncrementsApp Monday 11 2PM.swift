// INCREMENTS — environmental cognition support system
// v1.2 · Phase 1 Complete · SwiftUI + SwiftData
// iOS 17+ · Sora + DM Mono · Dark Warm-Neutral Palette
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
// FIX V01 — Health domain color: inkRed → inkTeal (#5AB8D6) — no threat signal on health items
// FIX V02 — Decay signal separated from amber: domain color at 40% opacity, not a new color
// FIX V03 — Mono metadata minimum raised to 11pt; tab labels 10pt; tracking reduced proportionally
// FIX V04 — Three-tier card hierarchy: Primary (action) / Secondary (context) / Ambient (infrastructure)
// FIX V05 — Background undertone shifted from blue to neutral-warm (chronobiology: melatonin impact)
// FIX V06 — Tab selection: area fill added to supplement 2px line (peripheral vision detectable)
// LAUNCH  — LaunchSequenceView: nodes → corona → wordmark → app load (~2.25s, cold launch only)
//
// "participation in reality"

import SwiftUI
import SwiftData
import UserNotifications

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
    var color: Color {
        switch self {
        case .environment:   return .inkGreen
        case .cognition:     return .violetLight
        case .health:        return .inkTeal   // FIX V01 — sky teal replaces red; no threat signal
        case .operations:    return .warm
        case .participation: return .inkAmber
        }
    }
}

enum RecurrenceType: String, Codable, CaseIterable {
    case daily, weekdays, weekends, weekly, none
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

// MARK: - DATA MODELS

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

    init(title: String, system: SystemTag, points: Int = 10,
         recurrence: RecurrenceType = .daily, scheduledTime: Date? = nil,
         note: String? = nil, cue: String? = nil) {
        self.id = UUID()
        self.title = title
        self.system = system
        self.points = points
        self.recurrence = recurrence
        self.scheduledTime = scheduledTime
        self.note = note
        self.cue = cue
        self.createdAt = Date()
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

    init() {}

    var title: String {
        switch level {
        case 1..<5:   return "New Recruit"
        case 5..<10:  return "Operator Trainee"
        case 10..<12: return "Field Operator"
        case 12..<15: return "Apprentice Operator"
        case 15..<20: return "Senior Operator"
        case 20..<25: return "System Architect"
        default:      return "Master Operator"
        }
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
}

@Model
class DailyLog {
    var date: Date = Date()
    var completedActionIDs: [UUID] = []
    var systemsTouched: [String] = []   // FIX 08 — for morning evidence card
    var specificActionNote: String? = nil
    var clarityLevel: ClarityLevel = ClarityLevel.moderate
    var noiseLevel: NoiseLevel = NoiseLevel.low
    var notes: String? = nil
    var topWin: String? = nil
    var focusTime: Int = 0

    init(date: Date = Date()) { self.date = date }

    var completedCount: Int { completedActionIDs.count }
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
    init() { self.date = Date() }
}

// MARK: - ENERGY STATE (Phase 2 · Priority 3)

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

    // FIX 04 — track which systems had activity this week (not a score)
    var systemActivityThisWeek: [SystemTag: Bool] = {
        var d: [SystemTag: Bool] = [:]
        SystemTag.allCases.forEach { d[$0] = false }
        return d
    }()

    // Kept for internal use only — not displayed as hero metric (FIX 04)
    var systemScores: [SystemTag: Int] = [
        .environment: 74, .cognition: 68, .health: 80, .operations: 62, .participation: 75
    ]

    func scoreLabel(_ score: Int) -> String {
        switch score {
        case 80...: return "Optimal"
        case 70..<80: return "Supportive"
        case 50..<70: return "Needs Attention"
        default: return "Quiet"   // not "Neglected" — no shame language (v1.1 guardrail)
        }
    }

    func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...: return .inkGreen
        case 70..<80: return .violetLight
        case 50..<70: return .inkAmber
        default: return .inkRed
        }
    }

    func updateSystemScore(_ system: SystemTag, completed: Int, total: Int) {
        guard total > 0 else { return }
        systemScores[system] = max(40, min(100, 40 + Int(Double(completed) / Double(total) * 60)))
        if completed > 0 { systemActivityThisWeek[system] = true }
    }

    // FIX 05 — days since last action per system (passed in from views with data access)
    var systemLastActivity: [SystemTag: Date] = [:]

    func daysSinceActivity(_ system: SystemTag) -> Int {
        guard let last = systemLastActivity[system] else { return 999 }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 999
    }
}

// MARK: - NOTIFICATION SERVICE

class NotificationService {
    static let shared = NotificationService()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleAll(quietMode: Bool = false) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard !quietMode else { return }

        // Max 4/day hard cap (FIX architecture enforced)
        let notifications: [(String, String, Int, Int)] = [
            ("Morning", "Open the blinds. Natural light sets the rhythm.", 7, 30),
            ("Midday", "Participate before postponement.", 12, 15),
            ("Afternoon", "One work thread. Not three.", 15, 30),
            ("Evening", "Close the loop before sleep.", 20, 30),
        ]

        for (i, (cat, body, hour, min)) in notifications.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "INCREMENTS · \(cat)"
            content.body = body
            content.sound = .default
            var comps = DateComponents()
            comps.hour = hour; comps.minute = min
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let request = UNNotificationRequest(identifier: "increments-\(i)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
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

// FIX 03 — ActionRow now shows cue below title
struct ActionRow: View {
    let action: Action
    var onComplete: () -> Void
    @State private var glowing = false

    var body: some View {
        HStack(spacing: 14) {
            Button(action: {
                withAnimation(.spring(response: 0.3)) { glowing = true; onComplete() }
            }) {
                ZStack {
                    // Uncompleted: very subtle system-color tint so each row has domain identity
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

            VStack(alignment: .leading, spacing: 3) {
                Text(action.title)
                    .font(.sora(14))
                    .foregroundColor(action.isCompleted ? .textMuted : .textPrimary)
                    .strikethrough(action.isCompleted, color: .textMuted)
                if let cue = action.cue, !cue.isEmpty, !action.isCompleted {
                    Text("When: \(cue)")
                        .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                }
            }
            Spacer()
            SystemBadge(system: action.system)
        }
        .padding(.vertical, 4)
        .onChange(of: glowing) { _, new in
            if new {
                // Instant bright flash, then graceful fade — like a camera shutter
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { glowing = false }
            }
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

// MARK: - TAB 1: HOME — FIX 04 (5-dot system activity row replaces score circle)

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [OperatorProfile]
    @Query(filter: #Predicate<Action> { $0.isCompleted == false }) private var pendingActions: [Action]
    @Bindable var state: AppState
    @State private var appeared = false

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    // FIX 04 — prose summary of which systems are active vs quiet
    var synergyLine: String {
        let active = SystemTag.allCases.filter { state.systemActivityThisWeek[$0] == true }
        let quiet = SystemTag.allCases.filter { state.systemActivityThisWeek[$0] == false }
        if active.isEmpty { return "All systems quiet this week." }
        if quiet.isEmpty { return "All 5 systems active this week." }
        let activeNames = active.map { $0.rawValue.capitalized }.joined(separator: ", ")
        let quietNames = quiet.map { $0.rawValue.capitalized }.joined(separator: ", ")
        return "\(activeNames) moving. \(quietNames) quiet."
    }

    var activeCount: Int { SystemTag.allCases.filter { state.systemActivityThisWeek[$0] == true }.count }

    var body: some View {
        ZStack {
            AtmosphericBackground(enhanced: true)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            MonoLabel(text: "INCREMENTS", color: .violet, size: 11)
                            Text("participation in reality")
                                .font(.sora(13, weight: .light))
                                .foregroundColor(.textSecond)
                                .tracking(0.3)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            MonoLabel(text: "v\(profile.version)", color: .warm, size: 11)
                            MonoLabel(text: profile.title.lowercased(), color: .textMuted, size: 11)
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 28)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
                    .animation(.easeOut(duration: 0.4), value: appeared)

                    // FIX 04 — System Synergy card (replaces Operator Score circle)
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    MonoLabel(text: "SYSTEM SYNERGY", color: .textMuted)
                                    Text("\(activeCount) of 5 systems active this week.")
                                        .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
                                    Text(synergyLine)
                                        .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                                }
                                Spacer()
                            }

                            // 5-dot row — one per system, colored if active
                            HStack(spacing: 10) {
                                ForEach(SystemTag.allCases, id: \.self) { sys in
                                    let active = state.systemActivityThisWeek[sys] ?? false
                                    // FIX V02 — decay state uses domain color at 40% opacity, not amber
                                    let daysSince = state.daysSinceActivity(sys)
                                    let isDecaying = !active && daysSince >= 3 && daysSince < 999
                                    VStack(spacing: 5) {
                                        Circle()
                                            .fill(active ? sys.color : Color.surface2)
                                            .frame(width: 10, height: 10)
                                            .overlay(Circle().stroke(active ? sys.color.opacity(0.4) : Color.muted.opacity(0.4), lineWidth: 1))
                                            // FIX V02 — decay: dim the dot using domain color, not amber
                                            .opacity(isDecaying ? 0.4 : 1.0)
                                            .overlay(isDecaying ? Circle().strokeBorder(sys.color.opacity(0.6), lineWidth: 1) : nil)
                                        MonoLabel(text: String(sys.rawValue.prefix(3)), color: active ? sys.color : .muted, size: 8)
                                    }
                                }
                                Spacer()

                                // Operator level — small, not hero
                                VStack(alignment: .trailing, spacing: 2) {
                                    MonoLabel(text: "Level \(profile.level)", color: .violetLight, size: 11)
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
                                    MonoLabel(text: "\(profile.xpToNextLevel) to next", color: .muted, size: 11)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 14)
                    .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                    // Next sane participation
                    if let next = pendingActions.first {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(text: "NEXT SANE PARTICIPATION")
                            CardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(next.title).font(.sora(15, weight: .medium)).foregroundColor(.textPrimary)
                                        if let cue = next.cue, !cue.isEmpty {
                                            Text("When: \(cue)").font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                        } else if let note = next.note {
                                            Text(note).font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.textMuted)
                                }
                            }
                        }
                        .padding(.horizontal, 24).padding(.top, 28)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 14)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
                    }

                    // System score rows (still present — diagnostic, not hero)
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(text: "SYSTEM STATUS")
                        VStack(spacing: 8) {
                            ForEach(Array(SystemTag.allCases.enumerated()), id: \.element) { i, sys in
                                let score = state.systemScores[sys] ?? 0
                                CardView {
                                    HStack(spacing: 0) {
                                        // Domain color accent — left edge, instant scanability
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(sys.color.opacity(0.7))
                                            .frame(width: 2)
                                            .padding(.trailing, 14)
                                        HStack(spacing: 14) {
                                            Image(systemName: sys.icon).font(.system(size: 14))
                                                .foregroundColor(sys.color).frame(width: 20)
                                            Text(sys.rawValue.capitalized)
                                                .font(.sora(13, weight: .medium)).foregroundColor(.textPrimary)
                                            Spacer()
                                            Text(state.scoreLabel(score))
                                                .font(.mono(11)).foregroundColor(state.scoreColor(score)).tracking(1)
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(width: 60, height: 3)
                                                RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.8))
                                                    .frame(width: 60 * CGFloat(score) / 100, height: 3)
                                            }
                                            Text("\(score)").font(.mono(11)).foregroundColor(.textSecond)
                                                .frame(width: 28, alignment: .trailing)
                                        }
                                    }
                                }
                                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                                .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.04 + 0.15), value: appeared)
                            }
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 28)

                    Button(action: { state.selectedTab = 1 }) {
                        Text("START DAY")
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
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true } }
    }
}

// MARK: - TAB 2: TODAY — FIX 06 (One Door) + FIX 08 (Morning Evidence Card)

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query private var actions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Bindable var state: AppState
    @State private var appeared = false
    @State private var showAdd = false
    @State private var firstOpenTime: Date = Date()

    var todayActions: [Action] {
        let all = actions.filter { a in
            let cal = Calendar.current
            if a.isCompleted, let ca = a.completedAt { return cal.isDateInToday(ca) }
            return !a.isCompleted && (a.recurrence != .none || cal.isDateInToday(a.createdAt))
        }.sorted { !$0.isCompleted && $1.isCompleted }

        // Phase 2 — Energy State: silently limit visible stack (no label, no announcement)
        let limit = state.todayEnergyState?.stackLimit ?? 8
        let pending = all.filter { !$0.isCompleted }
        let completed = all.filter { $0.isCompleted }
        let cappedPending = Array(pending.prefix(limit))
        return cappedPending + completed
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

    // FIX 06 — One Door: surface lowest-XP uncompleted action after noon with no completions
    var oneDoorAction: Action? {
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour >= 12, completedCount == 0, !pendingToday.isEmpty else { return nil }
        return pendingToday.min(by: { $0.points < $1.points })
    }

    // FIX 08 — Morning evidence card: yesterday's data, show before noon if ≥3 actions done
    var morningEvidenceText: String? {
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour < 12 else { return nil }
        guard let yesterday = logs.first(where: {
            Calendar.current.isDateInYesterday($0.date)
        }) else { return nil }
        guard yesterday.completedCount >= 3 else { return nil }
        let systems = yesterday.systemsTouched.prefix(2).joined(separator: ", ")
        let extra = systems.isEmpty ? "" : " \(systems) moved."
        if let note = yesterday.specificActionNote {
            return "Yesterday: \(yesterday.completedCount) actions.\(extra) \(note)."
        }
        return "Yesterday: \(yesterday.completedCount) actions.\(extra)"
    }

    let doctrines = [
        "The day is shaped by what you do first.",
        "Restoration can begin in the middle of an ordinary evening.",
        "Small acts are not prep for the story. They are the story.",
        "Action reorganizes perception.",
        "Less postponing. More participation in reality.",
        "A dark week is not a dark self.",
        "One action now."
    ]

    var todayDoctrine: String {
        doctrines[Calendar.current.component(.weekday, from: Date()) % doctrines.count]
    }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        MonoLabel(text: Date().formatted(.dateTime.weekday(.wide).month().day()).uppercased(),
                                  color: .textMuted, size: 11)
                        Text("TODAY").font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    }
                    Spacer()
                    // FIX 02 — cap indicator
                    if totalCount > 0 {
                        MonoLabel(text: "\(totalCount)/8", color: totalCount >= 8 ? .inkAmber : .textMuted, size: 11)
                    }
                    Button(action: {
                        guard totalCount < 8 else { return }
                        showAdd = true
                    }) {
                        Image(systemName: "plus").font(.system(size: 16, weight: .medium))
                            .foregroundColor(totalCount >= 8 ? .muted : .violet)
                            .frame(width: 36, height: 36)
                            .background(Color.violetDim.opacity(totalCount >= 8 ? 0.1 : 0.3))
                            .clipShape(Circle())
                    }
                    .disabled(totalCount >= 8)
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Phase 2 — Energy State input (appears until set, collapses after)
                        if state.todayEnergyState == nil {                            EnergyStateInputCard(state: state)
                                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                                .animation(.easeOut(duration: 0.35), value: appeared)
                        }

                        // FIX 08 — Morning evidence card
                        if let evidence = morningEvidenceText {
                            CardView(style: .secondary) {
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
                                    Text(evidence)
                                        .font(.sora(13, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
                                    Spacer()
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

                        // Progress
                        CardView {
                            HStack(spacing: 16) {
                                CircularProgress(
                                    value: totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0,
                                    size: 52, color: .inkGreen, lineWidth: 3
                                )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's actions").font(.sora(13, weight: .medium)).foregroundColor(.textPrimary)
                                    Text("\(completedCount) of \(totalCount) complete")
                                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                }
                                Spacer()
                                // Completion count as right-side anchor — clean, no ring overlap
                                Text("\(completedCount)")
                                    .font(.sora(28, weight: .semibold))
                                    .foregroundColor(completedCount > 0 ? .inkGreen : .textMuted)
                            }
                        }
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.35).delay(0.06), value: appeared)

                        // Action stack
                        if !todayActions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(text: "TODAY'S INCREMENTS")
                                CardView {
                                    VStack(spacing: 0) {
                                        ForEach(Array(todayActions.enumerated()), id: \.element.id) { i, action in
                                            ActionRow(action: action) { completeAction(action) }
                                            if i < todayActions.count - 1 {
                                                Rectangle()
                                                    .fill(Color.muted.opacity(0.2))
                                                    .frame(height: 0.5)
                                                    .padding(.vertical, 6)
                                            }
                                        }
                                    }
                                }
                            }
                            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                            .animation(.easeOut(duration: 0.35).delay(0.1), value: appeared)
                        }

                        // FIX 02 — cap warning when at 8
                        if totalCount >= 8 {
                            CardView {
                                HStack(spacing: 10) {
                                    Image(systemName: "equal.square").foregroundColor(.inkAmber)
                                    Text("Today already has 8 actions. Remove one first, or move this to tomorrow.")
                                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                }
                            }
                            .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.35).delay(0.12), value: appeared)
                        }

                        // Review CTA
                        Button(action: { state.showReview = true }) {
                            HStack {
                                Image(systemName: "checkmark.circle").font(.system(size: 14))
                                Text("Daily Review").font(.sora(14, weight: .medium))
                            }
                            .foregroundColor(.warm).frame(maxWidth: .infinity).frame(height: 48)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.warm.opacity(0.4), lineWidth: 1))
                        }
                        .padding(.bottom, 80)
                        .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.35).delay(0.15), value: appeared)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .sheet(isPresented: $showAdd) { AddActionSheet(isPresented: $showAdd) }
        .sheet(isPresented: $state.showReview) { DailyReviewSheet(isPresented: $state.showReview, state: state) }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true } }
    }

    func completeAction(_ action: Action) {
        action.isCompleted.toggle()
        action.completedAt = action.isCompleted ? Date() : nil
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let sys = action.system
        let sysActions = todayActions.filter { $0.system == sys }
        state.updateSystemScore(sys, completed: sysActions.filter(\.isCompleted).count, total: sysActions.count)
        if action.isCompleted { state.systemLastActivity[sys] = Date() }
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
    @State private var selecting = false

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
}

// MARK: - PHASE 2: TIMELINE VIEW (Priority 1)
// Shows receipts, not grades. Contradicts "nothing got done" on hard days.
// Gated: appears in tab bar only after 14 days (firstLaunchDate on OperatorProfile).

struct TimelineView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Action.completedAt, order: .reverse) private var allActions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var appeared = false

    // Group completed actions by calendar day, last 30 days
    var actionsByDay: [(Date, [Action])] {
        let cal = Calendar.current
        let completed = allActions.filter {
            $0.isCompleted && $0.completedAt != nil
        }
        // Get unique days
        let days = Array(Set(completed.compactMap { a -> Date? in
            guard let d = a.completedAt else { return nil }
            return cal.startOfDay(for: d)
        })).sorted(by: >)

        return days.map { day in
            let dayActions = completed.filter { a in
                guard let d = a.completedAt else { return false }
                return cal.isDate(d, inSameDayAs: day)
            }.sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
            return (day, dayActions)
        }
    }

    // Summary line per day — "6 actions — Environment, Health"
    func daySummary(for day: Date, actions: [Action]) -> String {
        let cal = Calendar.current
        let count = actions.count
        if count == 0 {
            return "Quiet day."
        }
        let systems = Array(Set(actions.map { $0.system.rawValue.capitalized }))
            .sorted().prefix(3).joined(separator: ", ")
        let noun = count == 1 ? "action" : "actions"
        // Check if today
        if cal.isDateInToday(day) {
            return "\(count) \(noun) so far — \(systems)"
        }
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
                            ForEach(Array(actionsByDay.enumerated()), id: \.element.0) { idx, pair in
                                let (day, actions) = pair

                                // Day header
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: dayHeader(day), color: .violetLight, size: 11)
                                    Text(daySummary(for: day, actions: actions))
                                        .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, idx == 0 ? 0 : 28)
                                .padding(.bottom, 12)
                                .opacity(appeared ? 1 : 0)
                                .animation(.easeOut(duration: 0.3).delay(Double(idx) * 0.04), value: appeared)

                                // Action entries for this day
                                VStack(spacing: 0) {
                                    ForEach(Array(actions.enumerated()), id: \.element.id) { aIdx, action in
                                        TimelineEntryRow(action: action)
                                            .opacity(appeared ? 1 : 0)
                                            .animation(
                                                .easeOut(duration: 0.3).delay(Double(idx) * 0.04 + Double(aIdx) * 0.02),
                                                value: appeared
                                            )

                                        if aIdx < actions.count - 1 {
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
                                                    .padding(.leading, 24 + 44 + 14 + 3) // aligns with dot column
                                                Spacer()
                                            }
                                        }
                                    }
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

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Timestamp — mono, small, left column
            Text(action.completedAt?.formatted(.dateTime.hour().minute()) ?? "")
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
    @State private var points = 10
    @State private var note = ""
    @State private var cue = ""    // FIX 03

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
                    inputField("WHEN (CUE)", placeholder: "e.g. After first standing transition", text: $cue)  // FIX 03

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

                    inputField("NOTE (OPTIONAL)", placeholder: "Context or constraint", text: $note)

                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "POINTS")
                        HStack(spacing: 10) {
                            ForEach([5, 10, 20, 50], id: \.self) { p in
                                Button(action: { points = p }) {
                                    Text("\(p) XP").font(.mono(11))
                                        .foregroundColor(points == p ? .bgBase : .textSecond)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(points == p ? Color.violet : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }

                    primaryButton("ADD INCREMENT", disabled: title.isEmpty) {
                        context.insert(Action(
                            title: title, system: system, points: points,
                            note: note.isEmpty ? nil : note,
                            cue: cue.isEmpty ? nil : cue
                        ))
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

// MARK: - TAB 3: INCREMENTS — FIX 05 (3-day quiet signal)

struct IncrementsView: View {
    @Query private var actions: [Action]
    @Bindable var state: AppState
    @State private var selectedSeg = 0
    @State private var appeared = false

    var completedToday: [Action] {
        actions.filter { $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }
    }

    // FIX 05 — compute days since last activity per system
    func daysSinceActivity(_ sys: SystemTag) -> Int {
        let completed = actions.filter { $0.system == sys && $0.isCompleted }
        guard let last = completed.compactMap({ $0.completedAt }).max() else { return 999 }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 999
    }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                HStack {
                    Text("INCREMENTS").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 16)

                segmentControl(["Active", "Planned", "Someday"], selected: $selectedSeg)
                    .padding(.horizontal, 24).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(Array(SystemTag.allCases.enumerated()), id: \.element) { i, sys in
                            let score = state.systemScores[sys] ?? 0
                            let pending = actions.filter { $0.system == sys && !$0.isCompleted }
                            let done = completedToday.filter { $0.system == sys }.count
                            let quiet = daysSinceActivity(sys)

                            VStack(alignment: .leading, spacing: 4) {
                                CardView {
                                    HStack(spacing: 0) {
                                        // Domain color accent — matches Home tab system row treatment
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

                                // FIX 05 — quiet signal, no alarm, no color
                                if quiet >= 3 && quiet < 999 {
                                    Text("\(sys.rawValue.capitalized) has been quiet for \(quiet) days.")
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
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true } }
    }
}

// MARK: - TAB 4: HABITS — FIX 02 (cue + minimum-scope required fields)

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
    @State private var topWin = ""
    @State private var heavy = ""
    @State private var tomorrow = ""
    @State private var submitted = false

    // FIX 01 — light closure path state
    @State private var showLightClose = false
    @State private var lightSentence = ""
    @State private var confirmedClose = false

    var participationScore: Int { min(100, state.systemScores.values.reduce(0, +) / 5 + 3) }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
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
    }

    // FIX 07 — reworded questions
    var fullReviewView: some View {
        VStack(alignment: .leading, spacing: 24) {
            SheetHandle().frame(maxWidth: .infinity, alignment: .center)
            HStack {
                Text("Daily Review").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                Spacer()
                // FIX 01 — "Close lightly?" instead of "Skip"
                Button("Close lightly?") { withAnimation { showLightClose = true } }
                    .font(.sora(13, weight: .light)).foregroundColor(.textMuted)
            }
            MonoLabel(text: "THREE QUESTIONS. CLOSE THE LOOP.", color: .violet)

            // FIX 07 — new question wording
            reviewField("What reduced friction today?", text: $topWin)
            reviewField("What stayed heavy or unresolved?", text: $heavy)
            reviewField("What's the first visible action tomorrow?", text: $tomorrow)

            Button(action: { withAnimation { submitted = true } }) {
                Text("CLOSE THE LOOP")
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
            Text("Close the loop lightly?")
                .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
            MonoLabel(text: "ONE SENTENCE ONLY", color: .violet)
            TextField("", text: $lightSentence,
                      prompt: Text("Today looked like...").foregroundColor(.textMuted))
                .font(.sora(15)).foregroundColor(.textPrimary)
                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))

            Button(action: { withAnimation { submitted = true } }) {
                Text("CLOSE")
                    .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // FIX 01 — second deliberate tap required for full close-without-review
            Button(action: { isPresented = false }) {
                Text("Close without review")
                    .font(.sora(12, weight: .light)).foregroundColor(.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(28)
    }

    var reviewResultView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 52)
            ZStack {
                Circle().stroke(Color.surface2, lineWidth: 4).frame(width: 110, height: 110)
                Circle()
                    .trim(from: 0, to: CGFloat(participationScore) / 100)
                    .stroke(LinearGradient(colors: [.violet, .inkGreen],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90)).frame(width: 110, height: 110)
                VStack(spacing: 2) {
                    Text("\(participationScore)").font(.sora(32, weight: .semibold)).foregroundColor(.textPrimary)
                    MonoLabel(text: "/100", color: .textMuted, size: 11)
                }
            }

            VStack(spacing: 6) {
                Text("Loop closed.").font(.sora(24, weight: .semibold)).foregroundColor(.textPrimary)
                Text("The record is updated.")
                    .font(.sora(14, weight: .light)).foregroundColor(.textSecond)
            }

            if !topWin.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "REDUCED FRICTION", color: .inkGreen)
                        Text(topWin).font(.sora(13)).foregroundColor(.textPrimary)
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
}

// MARK: - TAB 5: YOU

struct YouView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [OperatorProfile]
    @Query private var workTracks: [WorkTrack]
    @Query private var recoveryPhases: [RecoveryPhase]
    @Bindable var state: AppState
    @State private var selectedSeg = 0

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                HStack {
                    Text("YOU").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                    Image(systemName: "gearshape").foregroundColor(.textMuted)
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 16)

                segmentControl(["Profile", "Work", "Recovery", "Settings"], selected: $selectedSeg)
                    .padding(.horizontal, 24).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    switch selectedSeg {
                    case 0: ProfileTabView(profile: profile)
                    case 1: WorkTracksTabView(workTracks: workTracks)
                    case 2: RecoveryTabView(phase: recoveryPhases.first)
                    case 3: SettingsTabView(profile: profile, state: state)
                    default: EmptyView()
                    }
                }
            }
        }
        .onAppear {
            if workTracks.isEmpty { seedWorkTracks() }
            if recoveryPhases.isEmpty { context.insert(RecoveryPhase()) }
        }
    }

    func seedWorkTracks() {
        context.insert(WorkTrack(id: "form", name: "FORM",
                                  objective: "Coaching app — current build cycle",
                                  nextAction: "Review latest session notes"))
        context.insert(WorkTrack(id: "hideout", name: "HIDEOUT",
                                  objective: "Café / space project",
                                  nextAction: "Define next milestone"))
    }
}

struct ProfileTabView: View {
    let profile: OperatorProfile
    var body: some View {
        VStack(spacing: 20) {
            CardView {
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        // Avatar — brain glyph from xcassets as operator identity anchor
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
                            Text(profile.title)
                                .font(.sora(16, weight: .semibold)).foregroundColor(.textPrimary)
                            Text(profile.phaseLabel.isEmpty ? "Recovery + Operational Restoration" : profile.phaseLabel)
                                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    Divider().background(Color.muted.opacity(0.3))
                    HStack(spacing: 0) {
                        statCell("LEVEL", value: "\(profile.level)")
                        Divider().background(Color.muted.opacity(0.3)).frame(height: 36)
                        statCell("PHASE", value: "v\(profile.version)")
                        Divider().background(Color.muted.opacity(0.3)).frame(height: 36)
                        statCell("XP TO NEXT", value: "\(profile.xpToNextLevel)")
                    }
                }
            }
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

struct WorkTracksTabView: View {
    let workTracks: [WorkTrack]
    @State private var editingTrack: WorkTrack? = nil
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(text: "ACTIVE WORK TRACKS").padding(.horizontal, 24)
                if workTracks.isEmpty {
                    emptyState(icon: "briefcase", title: "No work tracks", subtitle: "Your active projects live here.")
                }
                ForEach(workTracks, id: \.id) { track in
                    WorkTrackCard(track: track).padding(.horizontal, 24)
                        .onTapGesture { editingTrack = track }
                }
            }
            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "RUNCARDS", color: .muted)
                    HStack {
                        Image(systemName: "pause.circle").foregroundColor(.muted).font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("On pause").font(.sora(14)).foregroundColor(.textMuted)
                            Text("Resuming when the project restarts.")
                                .font(.sora(12, weight: .light)).foregroundColor(.muted)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
        .sheet(item: $editingTrack) { track in EditWorkTrackSheet(track: track) }
    }
}

struct WorkTrackCard: View {
    let track: WorkTrack
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        MonoLabel(text: track.name, color: .warm, size: 11)
                        Text(track.objective.isEmpty ? "No objective set" : track.objective)
                            .font(.sora(14, weight: .medium)).foregroundColor(.textPrimary).lineLimit(2)
                    }
                    Spacer()
                    if track.isActive {
                        Text("ACTIVE").font(.mono(11)).foregroundColor(.inkGreen)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Color.inkGreen.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                Divider().background(Color.muted.opacity(0.3))
                VStack(alignment: .leading, spacing: 6) {
                    MonoLabel(text: "NEXT ACTION", color: .textMuted, size: 11)
                    Text(track.nextAction.isEmpty ? "Define next action" : track.nextAction)
                        .font(.sora(13)).foregroundColor(track.nextAction.isEmpty ? .textMuted : .textPrimary)
                }
                if let blocked = track.blockedBy, !blocked.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle").font(.system(size: 11)).foregroundColor(.inkAmber)
                        Text("Blocked: \(blocked)").font(.sora(11, weight: .light)).foregroundColor(.inkAmber)
                    }
                }
            }
        }
    }
}

struct EditWorkTrackSheet: View {
    @Bindable var track: WorkTrack
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        MonoLabel(text: track.name, color: .warm, size: 12)
                        Spacer()
                        Button("Done") { dismiss() }.font(.sora(14)).foregroundColor(.violet)
                    }
                    editableField("OBJECTIVE", placeholder: "Current objective", text: $track.objective)
                    editableField("NEXT ACTION", placeholder: "One-line next action", text: $track.nextAction)
                    editableField("BLOCKED BY", placeholder: "What is blocking this?",
                                  text: Binding(get: { track.blockedBy ?? "" },
                                                set: { track.blockedBy = $0.isEmpty ? nil : $0 }))
                    editableField("QUICK WIN", placeholder: "30-min win available?",
                                  text: Binding(get: { track.quickWin ?? "" },
                                                set: { track.quickWin = $0.isEmpty ? nil : $0 }))
                    editableField("NOTES", placeholder: "Running notes", text: $track.notes, multiline: true)
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }
}

struct RecoveryTabView: View {
    let phase: RecoveryPhase?
    @State private var isEditing = false
    var current: RecoveryPhase { phase ?? RecoveryPhase() }
    var body: some View {
        VStack(spacing: 16) {
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "RECOVERY PHASE", color: .inkAmber, size: 11)
                            Text(current.phaseLabel.isEmpty ? "Recovery + Operational Restoration" : current.phaseLabel)
                                .font(.sora(15, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil").font(.system(size: 13))
                                .foregroundColor(.violet).padding(8)
                                .background(Color.violet.opacity(0.12)).clipShape(Circle())
                        }
                    }
                    Divider().background(Color.muted.opacity(0.3))
                    recoveryRow(icon: "bandage", label: "INJURY",
                                value: current.injury.isEmpty ? "Not set" : current.injury)
                    recoveryRow(icon: "figure.walk", label: "MOBILITY",
                                value: current.mobility.isEmpty ? "Not set" : current.mobility)
                }
            }
            .padding(.horizontal, 24)

            HStack(spacing: 12) {
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.inkGreen).frame(width: 6, height: 6)
                            MonoLabel(text: "CLEARED", color: .inkGreen, size: 11)
                        }
                        Text(current.clearedMovement.isEmpty ? "Define with your PT" : current.clearedMovement)
                            .font(.sora(12, weight: .light)).foregroundColor(.textPrimary).lineLimit(4)
                    }
                }
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.inkRed).frame(width: 6, height: 6)
                            MonoLabel(text: "NOT YET", color: .inkRed, size: 11)
                        }
                        Text(current.notYet.isEmpty ? "Not defined" : current.notYet)
                            .font(.sora(12, weight: .light)).foregroundColor(.textPrimary).lineLimit(4)
                    }
                }
            }
            .padding(.horizontal, 24)

            CardView {
                HStack(spacing: 10) {
                    Image(systemName: "shield.checkered").foregroundColor(.inkAmber)
                    Text("All movement fields follow surgeon and PT clearance only.")
                        .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
        .sheet(isPresented: $isEditing) {
            EditRecoverySheet(phase: phase ?? RecoveryPhase(), isPresented: $isEditing)
        }
    }

    func recoveryRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 13)).foregroundColor(.inkAmber).frame(width: 18)
            VStack(alignment: .leading, spacing: 2) {
                MonoLabel(text: label, size: 11)
                Text(value).font(.sora(13)).foregroundColor(.textPrimary)
            }
        }
    }
}

struct EditRecoverySheet: View {
    @Bindable var phase: RecoveryPhase
    @Binding var isPresented: Bool
    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Text("Recovery Phase").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Done") { isPresented = false }.font(.sora(14)).foregroundColor(.violet)
                    }
                    MonoLabel(text: "All movement fields follow PT/surgeon clearance only.", color: .inkAmber)
                    editableField("PHASE LABEL", placeholder: "e.g. Recovery + Operational Restoration", text: $phase.phaseLabel)
                    editableField("INJURY", placeholder: "e.g. Tibial fracture, post-op", text: $phase.injury)
                    editableField("MOBILITY", placeholder: "e.g. Crutches, partial weight bearing", text: $phase.mobility)
                    editableField("CLEARED MOVEMENT", placeholder: "What is cleared by PT/surgeon", text: $phase.clearedMovement, multiline: true)
                    editableField("NOT YET", placeholder: "What is not yet cleared", text: $phase.notYet, multiline: true)
                    editableField("NEXT APPOINTMENT", placeholder: "Date + what to ask", text: $phase.nextAppointment)
                    editableField("SIGNAL LOG", placeholder: "Pain signals, progress, flags", text: $phase.signalLog, multiline: true)
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }
}

struct SettingsTabView: View {
    @Bindable var profile: OperatorProfile
    @Bindable var state: AppState
    @State private var notificationsEnabled = false
    var body: some View {
        VStack(spacing: 16) {
            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    MonoLabel(text: "NOTIFICATIONS", color: .textMuted)
                    Toggle(isOn: $notificationsEnabled) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Daily nudges").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("Max 4/day · Morning, midday, afternoon, evening")
                                .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                        }
                    }
                    .tint(Color.violet)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestPermission()
                            NotificationService.shared.scheduleAll(quietMode: profile.quietMode)
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
                    .onChange(of: profile.quietMode) { _, quiet in
                        NotificationService.shared.scheduleAll(quietMode: quiet)
                    }
                }
            }
            .padding(.horizontal, 24)

            CardView(style: .ambient) {   // FIX V04 — infrastructure layer, no card background
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
    }

    func guardrailLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(Color.warm.opacity(0.4)).frame(width: 4, height: 4).padding(.top, 5)
            Text(text).font(.sora(13, weight: .light)).foregroundColor(.textSecond)
        }
    }
}

// MARK: - CUSTOM TAB BAR

struct CustomTabBar: View {
    @Binding var selected: Int
    let showTimeline: Bool

    var tabs: [(String, String)] {
        var t: [(String, String)] = [
            ("house",                       "Home"),
            ("calendar",                    "Today"),
            ("equal",                       "Increments"),
            ("arrow.triangle.2.circlepath", "Habits"),
        ]
        if showTimeline { t.append(("clock", "Timeline")) }
        t.append(("person", "You"))
        return t
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

// MARK: - SEED DATA — FIX 03 (cues pre-filled)

func seedDefaultActions(context: ModelContext) {
    let defaults: [(String, SystemTag, Int, String?, String)] = [
        ("Morning light exposure",    .health,       5,  "10 min outside or by window",         "After first standing transition"),
        ("Open the blinds",           .environment,  5,  nil,                                   "When walking to bathroom"),
        ("Hydrate",                   .health,       5,  "3L target",                           "When placing phone down at desk"),
        ("Move your body",            .health,       10, "Cleared movement only — crutches walk","After clearing desk surface"),
        ("Apartment reset — one area",.environment,  10, nil,                                   "After docking at primary seated position"),
        ("Respond to 3 messages",     .operations,   5,  "Clear the queue",                     "After first coffee"),
        ("Review priorities",         .operations,   10, "5 minutes — what matters today",      "When opening laptop"),
        ("Eat protein",               .health,       5,  "30g minimum",                         "At first meal of day"),
    ]
    for (title, system, points, note, cue) in defaults {
        context.insert(Action(title: title, system: system, points: points, note: note, cue: cue))
    }
}

// MARK: - LAUNCH SEQUENCE
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

// MARK: - ROOT VIEW

struct RootView: View {
    @State private var state = AppState()
    @Query private var profiles: [OperatorProfile]
    @Query private var actions: [Action]
    @Environment(\.modelContext) private var context

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    // Phase 2 — Timeline appears after 14 days of use
    var showTimeline: Bool {
        let days = Calendar.current.dateComponents([.day], from: profile.firstLaunchDate, to: Date()).day ?? 0
        return days >= 14
    }

    // Tab index mapping accounts for Timeline being inserted at index 4 after day 14
    // Without Timeline: 0=Home 1=Today 2=Increments 3=Habits 4=You
    // With Timeline:    0=Home 1=Today 2=Increments 3=Habits 4=Timeline 5=You
    @ViewBuilder
    func tabView(for index: Int) -> some View {
        if showTimeline {
            switch index {
            case 0: HomeView(state: state)
            case 1: TodayView(state: state)
            case 2: IncrementsView(state: state)
            case 3: HabitsView()
            case 4: TimelineView()
            case 5: YouView(state: state)
            default: HomeView(state: state)
            }
        } else {
            switch index {
            case 0: HomeView(state: state)
            case 1: TodayView(state: state)
            case 2: IncrementsView(state: state)
            case 3: HabitsView()
            case 4: YouView(state: state)
            default: HomeView(state: state)
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabView(for: state.selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            CustomTabBar(selected: $state.selectedTab, showTimeline: showTimeline)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if profiles.isEmpty { context.insert(OperatorProfile()) }
            if actions.isEmpty { seedDefaultActions(context: context) }
            NotificationService.shared.requestPermission()
        }
    }
}

// MARK: - APP ENTRY POINT

@main
struct INCREMENTSApp: App {
    @State private var launchComplete = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .preferredColorScheme(.dark)
                    .opacity(launchComplete ? 1 : 0)

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
        .modelContainer(for: [
            Action.self, Habit.self, OperatorProfile.self,
            DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self
        ])
    }
}
