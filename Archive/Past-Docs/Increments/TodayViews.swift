import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications
import Foundation

// MARK: - TAB 1: HOME — FIX 04 (5-dot system activity row replaces score circle)

// MARK: - WEATHER + SUNRISE (Miami · Open-Meteo · no API key required)

struct WeatherSnapshot {
    let tempF: Int
    let conditionCode: Int
    let windMph: Double
    let sunrise: String   // "6:45 AM"
    let sunset: String    // "8:02 PM"
    let fetchedAt: Date

    var conditionLabel: String {
        switch conditionCode {
        case 0:           return "Clear"
        case 1:           return "Mostly clear"
        case 2:           return "Partly cloudy"
        case 3:           return "Overcast"
        case 45, 48:      return "Foggy"
        case 51, 53, 55:  return "Drizzle"
        case 61, 63, 65:  return "Rain"
        case 71, 73, 75:  return "Snow"
        case 80, 81, 82:  return "Showers"
        case 95:          return "Thunderstorm"
        default:          return "—"
        }
    }

    var conditionIcon: String {
        switch conditionCode {
        case 0:           return "sun.max"
        case 1:           return "sun.min"
        case 2:           return "cloud.sun"
        case 3:           return "cloud"
        case 45, 48:      return "cloud.fog"
        case 51...55:     return "cloud.drizzle"
        case 61...65:     return "cloud.rain"
        case 80...82:     return "cloud.heavyrain"
        case 95:          return "cloud.bolt.rain"
        default:          return "cloud"
        }
    }

    // Time until sunrise — useful at 4AM
    var minutesToSunrise: Int? {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        guard let srDate = fmt.date(from: sunrise) else { return nil }
        let now = Date()
        let cal = Calendar.current
        let todaySR = cal.date(bySettingHour: cal.component(.hour, from: srDate),
                               minute: cal.component(.minute, from: srDate),
                               second: 0, of: now) ?? srDate
        let diff = Int(todaySR.timeIntervalSince(now) / 60)
        return diff > 0 && diff < 300 ? diff : nil
    }
}

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var snapshot: WeatherSnapshot? = nil
    @Published var isLoading = false

    // Miami coordinates — hardcoded, no CLLocation needed
    private let lat = 25.7617
    private let lon = -80.1918

    func fetchIfNeeded() {
        // Refresh if no data or data is >30 min old
        if let s = snapshot, Date().timeIntervalSince(s.fetchedAt) < 1800 { return }
        Task { await fetch() }
    }

    private func fetch() async {
        isLoading = true
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,weathercode,windspeed_10m&daily=sunrise,sunset&temperature_unit=fahrenheit&windspeed_unit=mph&timezone=America%2FNew_York&forecast_days=1"
        guard let url = URL(string: urlStr) else { isLoading = false; return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let current = json?["current"] as? [String: Any]
            let daily = json?["daily"] as? [String: Any]

            let tempF = Int((current?["temperature_2m"] as? Double) ?? 0)
            let code = Int((current?["weathercode"] as? Double) ?? 0)
            let wind = (current?["windspeed_10m"] as? Double) ?? 0

            // Parse sunrise/sunset — format "2026-05-15T06:45"
            let srRaw = (daily?["sunrise"] as? [String])?.first ?? ""
            let ssRaw = (daily?["sunset"] as? [String])?.first ?? ""

            func parseTime(_ raw: String) -> String {
                let parts = raw.split(separator: "T")
                guard parts.count == 2 else { return "—" }
                let timeParts = parts[1].split(separator: ":")
                guard timeParts.count >= 2,
                      let h = Int(timeParts[0]),
                      let m = Int(timeParts[1]) else { return "—" }
                let hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h)
                let ampm = h < 12 ? "AM" : "PM"
                return String(format: "%d:%02d %@", hour12, m, ampm)
            }

            snapshot = WeatherSnapshot(
                tempF: tempF, conditionCode: code, windMph: wind,
                sunrise: parseTime(srRaw), sunset: parseTime(ssRaw),
                fetchedAt: Date()
            )
        } catch {}
        isLoading = false
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [OperatorProfile]
    @Query private var allActions: [Action]
    @Query(filter: #Predicate<Action> { $0.isCompleted == false }) private var pendingActions: [Action]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query(sort: \FinancialState.updatedAt, order: .reverse) private var financialStates: [FinancialState]
    @Bindable var state: AppState
    @State private var appeared = false
    @StateObject private var weather = WeatherViewModel()

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }
    var todayLog: DailyLog? { logs.first(where: { Calendar.current.isDateInToday($0.date) }) }
    var yesterdayLog: DailyLog? { logs.first(where: { Calendar.current.isDateInYesterday($0.date) }) }
    var latestShift: HideoutShiftLog? { shifts.first }
    var financial: FinancialState? { financialStates.first }

    var completedToday: Int {
        allActions.filter { $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }.count
    }

    // First irreversible action — the one pending action that unlocks the most
    var firstIrreversible: Action? {
        let pending = pendingActions.filter { $0.recurrence != .none }
        guard !pending.isEmpty else { return nil }
        // Prefer morning-scheduled actions not yet done; then quietest system
        let hour = Calendar.current.component(.hour, from: Date())
        let morning = pending.filter {
            if let block = $0.scheduledBlock, let blockHour = Int(block.prefix(2)) {
                return blockHour <= hour + 2
            }
            return false
        }.sorted { ($0.points) > ($1.points) }
        if let first = morning.first { return first }
        // Fall back: quietest system, lowest friction
        return pending.sorted {
            let dA = state.daysSinceActivity($0.system)
            let dB = state.daysSinceActivity($1.system)
            if dA != dB { return dA > dB }
            return $0.points < $1.points
        }.first
    }

    // Tomorrow pre-commitment from last night's review
    var tomorrowCommit: String? { yesterdayLog?.tomorrowPriority ?? yesterdayLog?.specificActionNote }

    // Sleep signal from last night's debrief
    var sleepSignal: String? { yesterdayLog?.sleepQuality }

    // Hideout shift status
    var todayIsHideoutDay: Bool { DayType.today == .hideout }
    var shiftLoggedToday: Bool {
        guard let s = latestShift else { return false }
        return Calendar.current.isDateInToday(s.date)
    }
    var hideoutStatusLine: String {
        if !todayIsHideoutDay { return "Base day." }
        if shiftLoggedToday, let s = latestShift {
            return "Shift logged. \(s.planningBand.label) · $\(Int(s.grossRevenue))"
        }
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 7  { return "Hideout opens at 7. Prep window." }
        if hour < 15 { return "Shift active. Log after close." }
        return "Shift not logged yet."
    }

    // Unresolved friction from yesterday's debrief
    var unresolvedFriction: String? {
        guard let log = yesterdayLog, let blocker = log.mainBlocker, !blocker.isEmpty else { return nil }
        return blocker
    }

    // Body readiness signal
    var bodySignal: String? {
        guard let feel = yesterdayLog?.bodyFeel, !feel.isEmpty else { return nil }
        return feel
    }

    var ctaLabel: String {
        if completedToday == 0 { return "START DAY" }
        if completedToday < 3  { return "CONTINUE" }
        return "OPEN TODAY"
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(enhanced: true)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            MonoLabel(text: "INCREMENTS", color: .violet, size: 11)
                            Text(profile.homeGreeting(completedToday: completedToday))
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
                    .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 20)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
                    .animation(.easeOut(duration: 0.4), value: appeared)

                    // ── COMMAND CENTER ─────────────────────────────────────────────────
                    // Answers one question: what matters now in this life architecture?

                    VStack(spacing: 12) {

                        // 0. WEATHER + SUNRISE — Miami · updates on open
                        WeatherCard(weather: weather)

                        // 1. FIRST ACTION — the one move that unlocks today
                        if let action = firstIrreversible {
                            CardView {
                                VStack(alignment: .leading, spacing: 10) {
                                    MonoLabel(text: "FIRST ACTION", color: .textMuted)
                                    HStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(action.system.color)
                                            .frame(width: 3, height: 36)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(action.title)
                                                .font(.sora(15, weight: .semibold))
                                                .foregroundColor(.textPrimary)
                                            if let block = action.scheduledBlock {
                                                MonoLabel(text: block, color: action.system.color, size: 11)
                                            }
                                        }
                                        Spacer()
                                        Button(action: { state.selectedTab = 1 }) {
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.textMuted)
                                        }
                                    }
                                }
                            }
                        }

                        // 2. TOMORROW PRE-COMMITMENT — from last night's review
                        if let commit = tomorrowCommit, !commit.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 6) {
                                    MonoLabel(text: "PRE-COMMITTED", color: .textMuted)
                                    Text(commit)
                                        .font(.sora(14, weight: .light))
                                        .foregroundColor(.textPrimary)
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }

                        // 3. HIDEOUT STATUS — shift readout or prep signal
                        CardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: "HIDEOUT", color: .textMuted)
                                    Text(hideoutStatusLine)
                                        .font(.sora(14, weight: .light))
                                        .foregroundColor(shiftLoggedToday ? .inkGreen : .textPrimary)
                                }
                                Spacer()
                                if todayIsHideoutDay && !shiftLoggedToday {
                                    Button(action: { state.selectedTab = 3 }) {
                                        MonoLabel(text: "LOG →", color: .warm, size: 11)
                                    }
                                }
                            }
                        }

                        // 4. FINANCIAL STATE — runway signal, categorical only
                        if let fin = financial {
                            CardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        MonoLabel(text: "RUNWAY", color: .textMuted)
                                        Text(fin.runwayState.label)
                                            .font(.sora(14, weight: .light))
                                            .foregroundColor(fin.runwayState.color)
                                        if !fin.nextObligationLabel.isEmpty {
                                            MonoLabel(text: fin.nextObligationLabel.uppercased(), color: .textMuted, size: 10)
                                        }
                                    }
                                    Spacer()
                                    Circle()
                                        .fill(fin.runwayState.color.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle().stroke(fin.runwayState.color.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        }

                        // 5. RECOVERY READINESS — sleep + body signal from debrief
                        if let sleep = sleepSignal, !sleep.isEmpty {
                            CardView {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        MonoLabel(text: "RECOVERY", color: .textMuted)
                                        Text("Sleep: \(sleep.lowercased())")
                                            .font(.sora(13, weight: .light))
                                            .foregroundColor(.textSecond)
                                        if let body = bodySignal {
                                            Text("Body: \(body.lowercased())")
                                                .font(.sora(13, weight: .light))
                                                .foregroundColor(.textSecond)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }

                        // 5b. SLEEP CORRIDOR — target window status
                        CardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: "SLEEP CORRIDOR", color: .textMuted)
                                    let hour = Calendar.current.component(.hour, from: Date())
                                    let minute = Calendar.current.component(.minute, from: Date())
                                    let totalMin = hour * 60 + minute
                                    let targetMin = 21 * 60 + 15  // 9:15PM
                                    let shutdownMin = 20 * 60 + 30 // 8:30PM no-screens
                                    if totalMin >= targetMin {
                                        Text("In corridor. Sleep now.")
                                            .font(.sora(13, weight: .light))
                                            .foregroundColor(.inkGreen)
                                    } else if totalMin >= shutdownMin {
                                        let remaining = (targetMin - totalMin)
                                        Text("\(remaining) min to target. Screens down.")
                                            .font(.sora(13, weight: .light))
                                            .foregroundColor(.inkAmber)
                                    } else {
                                        Text("Target: 9:15 PM · Wake: 4:00 AM")
                                            .font(.sora(13, weight: .light))
                                            .foregroundColor(.textSecond)
                                    }
                                    MonoLabel(text: "6H 45MIN WINDOW", color: .textMuted, size: 10)
                                }
                                Spacer()
                            }
                        }

                        // 6. TRAINING STATUS — week context (Forge Breechay)
                        CardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: "TRAINING", color: .textMuted)
                                    let gymDone = allActions.first(where: {
                                        $0.title.lowercased().contains("strength") || $0.title.lowercased().contains("gym")
                                    })
                                    let done = gymDone?.isCompleted == true &&
                                        Calendar.current.isDateInToday(gymDone?.completedAt ?? .distantPast)
                                    Text(done ? "Strength done today." : "Strength pending. 5:30PM.")
                                        .font(.sora(13, weight: .light))
                                        .foregroundColor(done ? .inkGreen : .textSecond)
                                    MonoLabel(text: "FORGE BREECHAY · WEEK 4", color: .textMuted, size: 10)
                                }
                                Spacer()
                            }
                        }

                        // 6b. WENDY OBSERVATION — rare, surfaces on Home when present
                        WendyObservationCard()

                        // 7. UNRESOLVED FRICTION — carried from yesterday's debrief
                        if let friction = unresolvedFriction {
                            CardView {
                                VStack(alignment: .leading, spacing: 6) {
                                    MonoLabel(text: "OPEN FRICTION", color: .inkAmber)
                                    Text(friction)
                                        .font(.sora(13, weight: .light))
                                        .foregroundColor(.textSecond)
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }

                        // 8. ADAPTATION PHASE — where we are in the system arc
                        CardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: "ADAPTATION PHASE", color: .textMuted)
                                    Text(profile.phaseLabel)
                                        .font(.sora(13, weight: .light))
                                        .foregroundColor(.textSecond)
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(height: 2)
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(LinearGradient(colors: [.violet, .violetLight],
                                                                      startPoint: .leading, endPoint: .trailing))
                                                .frame(width: geo.size.width * profile.xpProgressFraction, height: 2)
                                        }
                                    }
                                    .frame(width: 48, height: 2)
                                    MonoLabel(text: "phase \(profile.level)", color: .muted, size: 10)
                                }
                            }
                        }

                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 14)
                    .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                    // CTA — direct, not decorative
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
                    }
                    .padding(.horizontal, 24).padding(.top, 28).padding(.bottom, 80)
                    .opacity(appeared ? 1 : 0).animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)
                }
            }
        }
        .onAppear {
            state.recalculateScores(from: allActions)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true }
            weather.fetchIfNeeded()
        }
        .onChange(of: allActions) { _, _ in
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
        }.filter { a in
            // ARCH-01 — tier-aware surfacing: filter by energy state
            // Completed actions always show (already done = always visible in stack)
            if a.isCompleted { return true }
            // No state set = default to partial behavior (anchor + phase). Full requires explicit declaration.
            let effectiveTiers: Set<PriorityTier>
            if let energyState = state.todayEnergyState {
                effectiveTiers = energyState.visibleTiers
            } else {
                effectiveTiers = [.anchor, .phase]  // partial as default — full requires opt-in
            }
            return effectiveTiers.contains(a.priorityTier)
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
    @Query(sort: \DailyLog.date, order: .reverse) private var recentLogs: [DailyLog]

    // Inferred state suggestion — advisory only, operator overrides
    // Reads yesterday's sleep quality + recent completion rate
    var inferredStateLabel: String? {
        guard let yesterday = recentLogs.first(where: {
            Calendar.current.isDateInYesterday($0.date ?? .distantPast)
        }) else { return nil }

        let sleepQuality = yesterday.sleepQuality ?? ""
        let hourOfDay = Calendar.current.component(.hour, from: Date())

        // Early morning inference at 4AM wake
        if hourOfDay < 6 {
            if sleepQuality == "Rough" || sleepQuality == "Bad" {
                return "RESERVE"
            }
            if sleepQuality == "Slept well" {
                return "FULL"
            }
            return "PARTIAL"
        }
        return nil
    }
    @Environment(\.modelContext) private var context
    @Query private var cognitionLogs: [CognitionLog]
    @Query(sort: \DailyLog.date, order: .reverse) private var dailyLogs: [DailyLog]

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    MonoLabel(text: "CAPACITY TODAY", color: .textMuted)
                    Spacer()
                    if let suggestion = inferredStateLabel {
                        MonoLabel(text: "SUGGESTED: \(suggestion)", color: .inkAmber, size: 10)
                    }
                }

                HStack(spacing: 10) {
                    ForEach([EnergyState.full, .partial, .reserve, .compressed], id: \.rawValue) { es in
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




// MARK: - WEATHER CARD

struct WeatherCard: View {
    @ObservedObject var weather: WeatherViewModel

    var body: some View {
        CardView(style: .secondary) {
            if weather.isLoading && weather.snapshot == nil {
                HStack {
                    MonoLabel(text: "MIAMI · LOADING...", color: .textMuted, size: 10)
                    Spacer()
                }
            } else if let w = weather.snapshot {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        MonoLabel(text: "MIAMI · NOW", color: .textMuted, size: 10)
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(w.tempF)°")
                                .font(.system(size: 28, weight: .light, design: .monospaced))
                                .foregroundColor(.textPrimary)
                            Image(systemName: w.conditionIcon)
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.textSecond)
                        }
                        Text(w.conditionLabel)
                            .font(.sora(12, weight: .light))
                            .foregroundColor(.textSecond)
                        if w.windMph > 8 {
                            MonoLabel(text: "WIND \(Int(w.windMph)) MPH", color: .inkAmber, size: 10)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        VStack(alignment: .trailing, spacing: 2) {
                            MonoLabel(text: "SUNRISE", color: .textMuted, size: 10)
                            Text(w.sunrise)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(.inkAmber)
                            if let mins = w.minutesToSunrise {
                                MonoLabel(text: "\(mins) MIN OUT", color: .textMuted, size: 10)
                            }
                        }
                        VStack(alignment: .trailing, spacing: 2) {
                            MonoLabel(text: "SUNSET", color: .textMuted, size: 10)
                            Text(w.sunset)
                                .font(.system(size: 12, weight: .light, design: .monospaced))
                                .foregroundColor(.textSecond)
                        }
                    }
                }
            } else {
                HStack {
                    MonoLabel(text: "MIAMI · WEATHER UNAVAILABLE", color: .textMuted, size: 10)
                    Spacer()
                }
            }
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

    // BLOCK 1 — Physical foundation
    @State private var sleepQuality: String? = nil
    @State private var physicalMovement: String? = nil
    @State private var bodyFeel: String? = nil

    // BLOCK 2 — Operating state
    @State private var dayFeel: String? = nil
    @State private var momentumAtClose: String? = nil
    @State private var decisionFatigue: String? = nil

    // BLOCK 3 — Work quality
    @State private var meaningfulWork: String? = nil
    @State private var deepestFocus: String? = nil
    @State private var whereWorked: String? = nil
    @State private var systemMoved: String? = nil

    // BLOCK 4 — Drag sources
    @State private var mainBlocker: String? = nil
    @State private var operationalTakeover: String? = nil
    @State private var socialLoad: String? = nil

    // BLOCK 5 — Environment
    @State private var environmentEffect: String? = nil
    @State private var environmentReset: String? = nil

    // BLOCK 6 — External pressures
    @State private var capitalPressure: String? = nil
    @State private var hideoutPressure: String? = nil

    // BLOCK 7 — What worked
    @State private var mainUnlock: String? = nil

    // BLOCK 8 — Close
    @State private var closingNote: String = ""
    @State private var tomorrowFirst: String = ""

    @State private var submitted = false
    @State private var page = 0

    let totalPages = 19  // 17 signal pages + final page

    var todayLog: DailyLog? {
        logs.first { Calendar.current.isDateInToday($0.date) }
    }
    var alreadyDebriefed: Bool { todayLog?.hasFullDebrief ?? false }
    var completedToday: [Action] {
        actions.filter { $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            if submitted {
                closeDayResult
            } else {
                closeDayFlow
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
        .onAppear { loadExisting() }
    }

    // MARK: — CLOSE DAY FLOW

    var closeDayFlow: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    MonoLabel(text: "CLOSE DAY · \(page + 1) of \(totalPages)", color: .violetLight, size: 11)
                    Text(blockTitle)
                        .font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                }
                Spacer()
                Button("Skip tonight") { isPresented = false }
                    .font(.sora(13, weight: .light)).foregroundColor(.textMuted)
            }
            .padding(.horizontal, 28).padding(.top, 24).padding(.bottom, 12)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.muted.opacity(0.15))
                        .frame(height: 2)
                    RoundedRectangle(cornerRadius: 2).fill(Color.violetLight.opacity(0.6))
                        .frame(width: geo.size.width * CGFloat(page + 1) / CGFloat(totalPages), height: 2)
                        .animation(.easeOut(duration: 0.3), value: page)
                }
            }
            .frame(height: 2)
            .padding(.horizontal, 28).padding(.bottom, 20)

            // Questions
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    switch page {
                    // BLOCK 1 — Physical
                    case 0: questionPage("How did you sleep?",
                        options: ["Slept well", "Decent", "Rough", "Bad"],
                        colors:  [.inkGreen, .inkGreen, .inkAmber, .inkRed],
                        selected: $sleepQuality)

                    case 1: questionPage("Did you move your body?",
                        options: ["Full workout", "Light movement", "Walk only", "Nothing"],
                        colors:  [.inkGreen, .inkGreen, .inkTeal, .textMuted],
                        selected: $physicalMovement)

                    case 2: questionPage("How did your body feel today?",
                        options: ["Good", "Fine", "Stiff / sore", "Low energy", "Off"],
                        colors:  [.inkGreen, .inkGreen, .inkAmber, .inkAmber, .inkRed],
                        selected: $bodyFeel)

                    // BLOCK 2 — Operating state
                    case 3: questionPage("How did today feel overall?",
                        options: ["Sharp", "Smooth", "Fine", "Scattered", "Heavy", "Drained", "Reactive"],
                        colors:  [.inkGreen, .inkGreen, .textMuted, .inkAmber, .inkAmber, .inkAmber, .inkRed],
                        selected: $dayFeel)

                    case 4: questionPage("How's your momentum right now?",
                        sublabel: "as you close the day",
                        options: ["Strong", "Solid", "Okay", "Lost it", "Never had it"],
                        colors:  [.inkGreen, .inkGreen, .textMuted, .inkAmber, .inkRed],
                        selected: $momentumAtClose)

                    case 5: questionPage("Decision fatigue by end of day?",
                        options: ["Fresh", "Mild", "Noticeably tired", "Fried"],
                        colors:  [.inkGreen, .textMuted, .inkAmber, .inkRed],
                        selected: $decisionFatigue)

                    // BLOCK 3 — Work quality
                    case 6: questionPage("Did you move anything meaningful?",
                        sublabel: "built, created, advanced — something that actually matters",
                        options: ["Yes, significantly", "Yes, a little", "Not really", "No, life stuff took over"],
                        colors:  [.inkGreen, .inkGreen, .textMuted, .inkAmber],
                        selected: $meaningfulWork)

                    case 7: questionPage("What was your deepest focus block?",
                        options: ["2+ hours", "1 hour", "30 minutes", "Fragmented — no real block"],
                        colors:  [.inkGreen, .inkGreen, .inkAmber, .inkRed],
                        selected: $deepestFocus)

                    case 8: questionPage("Where did you mostly work?",
                        options: ["Hideout", "Home", "Café", "Mixed", "Mostly out and about"],
                        colors:  [.warm, .inkTeal, .violetLight, .textMuted, .textMuted],
                        selected: $whereWorked)

                    case 9: questionPage("Which system moved most today?",
                        sublabel: "your gut read — cross-checks with what your taps show",
                        options: SystemTag.allCases.map { $0.rawValue.capitalized },
                        colors:  SystemTag.allCases.map { $0.color },
                        selected: $systemMoved)

                    // BLOCK 4 — Drag
                    case 10: questionPage("What got in the way most?",
                        options: ["Too many things open", "Didn't know what to do first", "Small tasks ate the day", "Messy environment", "Interruptions", "Low energy", "Body wasn't cooperating", "Money on my mind", "Hideout / business", "Other people", "Nothing really"],
                        colors:  [.inkAmber, .inkAmber, .inkAmber, .inkAmber, .inkAmber, .inkAmber, .inkAmber, .warm, .warm, .warm, .inkGreen],
                        selected: $mainBlocker)

                    case 11: questionPage("Did upkeep take over?",
                        sublabel: "errands, email, chores, coordination, logistics",
                        options: ["No", "A little", "Yes", "Yes, and important work got pushed"],
                        colors:  [.inkGreen, .textMuted, .inkAmber, .inkRed],
                        selected: $operationalTakeover)

                    case 12: questionPage("How was your social load today?",
                        options: ["Low — mostly solo", "Normal", "High — lots of people", "Draining"],
                        colors:  [.inkGreen, .textMuted, .inkAmber, .inkRed],
                        selected: $socialLoad)

                    // BLOCK 5 — Environment
                    case 13: questionPage("Did your environment help or hurt?",
                        options: ["Helped", "Neutral", "Hurt", "Reset fixed it"],
                        colors:  [.inkGreen, .textMuted, .inkRed, .inkTeal],
                        selected: $environmentEffect)

                    case 14: questionPage("Did you reset your environment at any point?",
                        options: ["Yes, early — before work started", "Yes, mid-day", "Yes, late", "No reset today"],
                        colors:  [.inkGreen, .inkGreen, .inkTeal, .textMuted],
                        selected: $environmentReset)

                    // BLOCK 6 — Pressures
                    case 15: questionPage("Did money weigh on you today?",
                        options: ["No", "Slightly", "Yes", "Definitely"],
                        colors:  [.inkGreen, .textMuted, .inkAmber, .inkRed],
                        selected: $capitalPressure)

                    case 16: questionPage("How was Hideout today?",
                        options: ["No shift today", "Good shift", "Solid shift", "Okay shift", "Tough shift", "Stressful"],
                        colors:  [.textMuted, .inkGreen, .inkGreen, .textMuted, .inkAmber, .inkRed],
                        selected: $hideoutPressure)

                    // BLOCK 7 — Unlock
                    case 17: questionPage("What helped most today?",
                        options: ["Cleaning / reset", "Workout", "Walk", "Food", "Music", "Clear plan", "Getting out", "One small win", "Conversation", "Sleep", "Money clarity", "Structure / sequencing", "Nothing specific"],
                        colors: Array(repeating: Color.inkGreen, count: 12) + [.textMuted],
                        selected: $mainUnlock)

                    // BLOCK 8 — Close
                    case 18: finalPage

                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 28)
            }

            // Navigation
            HStack(spacing: 12) {
                if page > 0 {
                    Button(action: { withAnimation(.easeOut(duration: 0.2)) { page -= 1 } }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textMuted)
                            .frame(width: 48, height: 50)
                            .background(Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Button(action: advance) {
                    Text(page < totalPages - 1 ? "NEXT" : "CLOSE DAY")
                        .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.2)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(canAdvance ? Color.violetLight : Color.muted.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canAdvance)
            }
            .padding(.horizontal, 28).padding(.bottom, 36).padding(.top, 16)
        }
    }

    var blockTitle: String {
        switch page {
        case 0...2: return "Physical foundation"
        case 3...5: return "Operating state"
        case 6...9: return "Work quality"
        case 10...12: return "Drag sources"
        case 13...14: return "Environment"
        case 15...16: return "External pressures"
        case 17: return "What worked"
        case 18: return "Close"
        default: return ""
        }
    }

    var canAdvance: Bool {
        switch page {
        case 0:  return sleepQuality != nil
        case 1:  return physicalMovement != nil
        case 2:  return bodyFeel != nil
        case 3:  return dayFeel != nil
        case 4:  return momentumAtClose != nil
        case 5:  return decisionFatigue != nil
        case 6:  return meaningfulWork != nil
        case 7:  return deepestFocus != nil
        case 8:  return whereWorked != nil
        case 9:  return systemMoved != nil
        case 10: return mainBlocker != nil
        case 11: return operationalTakeover != nil
        case 12: return socialLoad != nil
        case 13: return environmentEffect != nil
        case 14: return environmentReset != nil
        case 15: return capitalPressure != nil
        case 16: return hideoutPressure != nil
        case 17: return mainUnlock != nil
        case 18: return true
        default: return false
        }
    }

    func advance() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if page < totalPages - 1 {
            withAnimation(.easeOut(duration: 0.25)) { page += 1 }
        } else {
            saveDebrief()
            withAnimation { submitted = true }
        }
    }

    // MARK: — QUESTION PAGE

    func questionPage(_ question: String, sublabel: String? = nil, options: [String], colors: [Color], selected: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(question)
                    .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary).lineSpacing(3)
                if let sub = sublabel {
                    Text(sub)
                        .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(3)
                }
            }
            VStack(spacing: 8) {
                ForEach(Array(options.enumerated()), id: \.offset) { i, option in
                    let color = i < colors.count ? colors[i] : Color.textMuted
                    let isSelected = selected.wrappedValue == option
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        selected.wrappedValue = isSelected ? nil : option
                    }) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(isSelected ? color : Color.muted.opacity(0.2))
                                .frame(width: 8, height: 8)
                            Text(option)
                                .font(.sora(14, weight: isSelected ? .medium : .light))
                                .foregroundColor(isSelected ? .textPrimary : .textSecond)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(color)
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 13)
                        .background(isSelected ? color.opacity(0.08) : Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? color.opacity(0.3) : Color.clear, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: — FINAL PAGE

    var finalPage: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Anything worth noting?")
                .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
            Text("Optional. What actually happened today — the thing the data won't see.")
                .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(3)

            TextField("", text: $closingNote,
                      prompt: Text("One honest sentence.").foregroundColor(.textMuted))
                .font(.sora(14)).foregroundColor(.textPrimary)
                .padding(14).background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(.violetLight)

            Divider().background(Color.muted.opacity(0.2))

            Text("What's first tomorrow?")
                .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
            Text("Pre-commitment. Shows up in your morning card.")
                .font(.sora(12, weight: .light)).foregroundColor(.textMuted)

            TextField("", text: $tomorrowFirst,
                      prompt: Text("One specific action.").foregroundColor(.textMuted))
                .font(.sora(14)).foregroundColor(.textPrimary)
                .padding(14).background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(.violetLight)
        }
        .padding(.bottom, 20)
    }

    // MARK: — RESULT

    var closeDayResult: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 48)
            ZStack {
                Circle().stroke(Color.violetLight.opacity(0.15), lineWidth: 1.5).frame(width: 72, height: 72)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .ultraLight))
                    .foregroundColor(.violetLight)
            }
            VStack(spacing: 6) {
                Text("Closed.").font(.sora(24, weight: .semibold)).foregroundColor(.textPrimary)
                Text("19 signals captured.")
                    .font(.sora(14, weight: .light)).foregroundColor(.textSecond)
            }

            // Key signals summary
            VStack(spacing: 8) {
                if let feel = dayFeel { closedRow("Today", feel) }
                if let work = meaningfulWork { closedRow("Meaningful work", work) }
                if let blocker = mainBlocker { closedRow("Main drag", blocker) }
                if let unlock = mainUnlock { closedRow("What helped", unlock) }
                if let sleep = sleepQuality { closedRow("Sleep", sleep) }
                if let env = environmentEffect { closedRow("Environment", env) }
            }
            .padding(.horizontal, 28)

            if !tomorrowFirst.isEmpty {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "TOMORROW FIRST", color: .warm)
                        Text(tomorrowFirst)
                            .font(.sora(13, weight: .medium)).foregroundColor(.textPrimary)
                    }
                }
                .padding(.horizontal, 28)
            }

            Button(action: { isPresented = false }) {
                Text("DONE")
                    .font(.sora(13, weight: .semibold)).foregroundColor(.bgBase).tracking(2)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(Color.violetLight).clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 28)
            Spacer()
        }
    }

    func closedRow(_ label: String, _ value: String) -> some View {
        HStack {
            MonoLabel(text: label.uppercased(), color: .textMuted, size: 10)
                .frame(width: 120, alignment: .leading)
            Text(value).font(.sora(12, weight: .light)).foregroundColor(.textPrimary)
            Spacer()
        }
    }

    // MARK: — LOAD / SAVE

    func loadExisting() {
        guard let log = todayLog else { return }
        sleepQuality = log.sleepQuality
        physicalMovement = log.physicalMovement
        bodyFeel = log.bodyFeel
        dayFeel = log.dayFeel
        momentumAtClose = log.momentumAtClose
        decisionFatigue = log.decisionFatigue
        meaningfulWork = log.meaningfulWorkMoved
        deepestFocus = log.deepestFocusBlock
        whereWorked = log.whereWorked
        systemMoved = log.systemThatMovedMost
        mainBlocker = log.mainBlocker
        operationalTakeover = log.operationalTakeover
        socialLoad = log.socialLoad
        environmentEffect = log.environmentEffect
        environmentReset = log.environmentReset
        capitalPressure = log.capitalPressure
        hideoutPressure = log.hideoutPressure
        mainUnlock = log.mainUnlock
        closingNote = log.closingNote ?? ""
        tomorrowFirst = log.specificActionNote ?? ""
        if alreadyDebriefed { page = 18 }
    }

    func saveDebrief() {
        let target: DailyLog
        if let existing = todayLog {
            target = existing
        } else {
            let log = DailyLog(date: Date())
            context.insert(log)
            target = log
        }

        // Physical
        target.sleepQuality = sleepQuality
        target.physicalMovement = physicalMovement
        target.bodyFeel = bodyFeel

        // Operating state
        target.dayFeel = dayFeel
        target.momentumAtClose = momentumAtClose
        target.decisionFatigue = decisionFatigue

        // Work quality
        target.meaningfulWorkMoved = meaningfulWork
        target.deepestFocusBlock = deepestFocus
        target.whereWorked = whereWorked
        target.systemThatMovedMost = systemMoved

        // Drag
        target.mainBlocker = mainBlocker
        target.operationalTakeover = operationalTakeover
        target.socialLoad = socialLoad

        // Environment
        target.environmentEffect = environmentEffect
        target.environmentReset = environmentReset

        // Pressures
        target.capitalPressure = capitalPressure
        target.hideoutPressure = hideoutPressure

        // Unlock + close
        target.mainUnlock = mainUnlock
        target.closingNote = closingNote.isEmpty ? nil : closingNote
        target.specificActionNote = tomorrowFirst.isEmpty ? nil : tomorrowFirst

        // Legacy compat
        target.topWin = mainUnlock ?? (closingNote.isEmpty ? nil : closingNote)
        target.notes = mainBlocker

        // Passive completion data
        let completedIDs = completedToday.map(\.id)
        let systems = Array(Set(completedToday.map { $0.system.rawValue }))
        let first = completedToday
            .compactMap { a -> (Action, Date)? in
                guard let at = a.completedAt else { return nil }
                return (a, at)
            }
            .min(by: { $0.1 < $1.1 })

        target.completedActionIDs = completedIDs
        target.systemsTouched = systems
        target.firstSystemTouched = first?.0.system.rawValue
        target.firstCompletionHour = first.map { Calendar.current.component(.hour, from: $0.1) }

        updateCognitionLogCompletionCount(completedToday.count)
    }

    func updateCognitionLogCompletionCount(_ count: Int) {
        let todayCognitionLog = cognitionLogs.first { Calendar.current.isDateInToday($0.date) }
        if let log = todayCognitionLog { log.actualCompletionCount = count }
    }

}
