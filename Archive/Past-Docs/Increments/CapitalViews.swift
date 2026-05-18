import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications
import Foundation

// MARK: - TAB 5: YOU

// MARK: - CAPITAL TAB VIEW
// Resource intelligence — not budgeting. Clarity, stewardship, optionality.
// No amounts stored. Categorical only. Calm command, not financial anxiety.
//
// ARCHITECTURE NOTE: Capital is currently housed in You → Capital sub-tab.
// It is designed as an autonomous domain and should be promoted to a top-level
// tab when it warrants the real estate. Promotion is a one-line RootView change.
// Do not let placement in You cause it to be designed as a profile feature.
// It is an operational system peer to Hideout, not a settings subsection.

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
        // Nutrition + Cardio Protocol — synthesized from multi-agent review
        NutritionProtocolView()
            .padding(.top, 24)

        .padding(.bottom, 80)
    }
}

// MARK: - NUTRITION + CARDIO PROTOCOL

struct NutritionMeal: Identifiable {
    let id = UUID()
    let time: String
    let name: String
    let foods: String
    let rule: String
    let tag: String  // "carb" | "protein" | "fast" | "lift" | ""
    let kcal: String
}

struct NutritionProtocolView: View {
    @State private var expanded: String? = nil   // "workday" | "baseday" | "cardio" | "failure"
    @State private var dayMode: Int = 0  // 0 = workday, 1 = base day

    let workdayMeals: [NutritionMeal] = [
        NutritionMeal(time: "4:00 AM", name: "Wake protocol",
            foods: "500ml water · 5g creatine · matcha",
            rule: "Wake = water + creatine + matcha. Nothing else.",
            tag: "fast", kcal: "0 kcal"),
        NutritionMeal(time: "4:30–5:10 AM", name: "Fasted cardio",
            foods: "Zone 2 · bike or elliptical · 35–40 min · HR 130–145",
            rule: "Default fasted. Half banana allowed: poor sleep, HRV off, legs empty.",
            tag: "fast", kcal: "−300–350 kcal"),
        NutritionMeal(time: "5:15 AM", name: "Post-cardio protein anchor",
            foods: "Pumpkin seed protein in oat milk · 2 hard boiled eggs optional",
            rule: "Shake only. No carbs yet. Fat oxidation window still open.",
            tag: "protein", kcal: "~340 kcal · 40g P"),
        NutritionMeal(time: "9:30 AM", name: "First solid meal (at Hideout)",
            foods: "1 banana · 100g roasted chicken · 2 hard boiled eggs",
            rule: "Banana + chicken + 2 eggs. Same every shift day.",
            tag: "carb", kcal: "~490 kcal · 55g P"),
        NutritionMeal(time: "1:30 PM", name: "Midday protein + greens",
            foods: "Spinach/arugula · 130g roasted chicken · olive oil · balsamic glaze",
            rule: "Greens + chicken + olive oil. No bread at lunch.",
            tag: "protein", kcal: "~390 kcal · 50g P"),
        NutritionMeal(time: "5:00 PM", name: "Pre-lift carb prime ← most critical",
            foods: "2 slices Zak sourdough · 1.5 tbsp peanut or almond butter",
            rule: "2 slices sourdough + nut butter. Every lift day. Pack it, don't decide it.",
            tag: "lift", kcal: "~400 kcal · 55g carbs"),
        NutritionMeal(time: "6:30–7:00 PM", name: "Post-lift anabolic window",
            foods: "Pumpkin seed shake in regular milk · banana OR watermelon OR strawberries",
            rule: "Shake + fruit. Within 30 min of rack. No skipping.",
            tag: "carb", kcal: "~480 kcal · 42g P"),
        NutritionMeal(time: "7:30–8:00 PM", name: "Final meal",
            foods: "120–150g roasted chicken · avocado · spinach/arugula · olive oil",
            rule: "Chicken + avocado + greens. Kitchen closed at 8:30 PM.",
            tag: "protein", kcal: "~480 kcal · 50g P"),
    ]

    let baseMeals: [NutritionMeal] = [
        NutritionMeal(time: "4:00 AM", name: "Wake protocol",
            foods: "500ml water · 5g creatine · matcha",
            rule: "Same every day. No variation.",
            tag: "fast", kcal: "0 kcal"),
        NutritionMeal(time: "4:30–5:10 AM", name: "Fasted cardio (lower intensity)",
            foods: "Zone 2 · HR 120–135 · active recovery pace",
            rule: "Base day cardio = same time, lower intensity. Fasted default.",
            tag: "fast", kcal: "−250–300 kcal"),
        NutritionMeal(time: "5:15 AM", name: "Post-cardio protein anchor",
            foods: "Pumpkin seed protein in oat milk",
            rule: "Same as workday.",
            tag: "protein", kcal: "~340 kcal · 40g P"),
        NutritionMeal(time: "9:00 AM", name: "Meal 1 (at home)",
            foods: "2–3 hard boiled eggs · spinach · avocado · olive oil. No banana — no training carb need.",
            rule: "No banana on base days. Eggs + greens + fat only.",
            tag: "protein", kcal: "~330 kcal · 22g P"),
        NutritionMeal(time: "12:30 PM", name: "Midday meal (largest of base day)",
            foods: "160g roasted chicken · large arugula salad · avocado · olive oil · balsamic · strawberries/watermelon (100g)",
            rule: "Biggest protein meal is lunch on base days.",
            tag: "protein", kcal: "~510 kcal · 60g P"),
        NutritionMeal(time: "4:00 PM", name: "Afternoon protein",
            foods: "Protein shake in regular milk · 1 tbsp peanut butter. No fruit.",
            rule: "Shake + PB. No fruit — rest day means rest from training carbs.",
            tag: "protein", kcal: "~330 kcal · 40g P"),
        NutritionMeal(time: "7:00 PM", name: "Final meal",
            foods: "120g roasted chicken · spinach · avocado · olive oil. No sourdough, no banana bread.",
            rule: "Protein + fat only. No starch on base days.",
            tag: "protein", kcal: "~440 kcal · 46g P"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            VStack(alignment: .leading, spacing: 6) {
                MonoLabel(text: "NUTRITION + CARDIO PROTOCOL", color: .inkTeal, size: 10)
                Text("Slow cut · 8–10% BF target · Forge Breechay preserved")
                    .font(.sora(14, weight: .light))
                    .foregroundColor(.textPrimary)
                MonoLabel(text: "SYNTHESIZED FROM MULTI-AGENT REVIEW · MAY 2026", color: .textMuted, size: 10)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Daily targets row
            HStack(spacing: 8) {
                NutritionTargetCard(value: "2,200–2,350", unit: "kcal", label: "Workdays")
                NutritionTargetCard(value: "1,900–2,100", unit: "kcal", label: "Base days")
                NutritionTargetCard(value: "190–210g", unit: "protein", label: "Every day")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Rationale blurb
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 6) {
                    MonoLabel(text: "DESIGN RATIONALE", color: .textMuted, size: 10)
                    Text("Estimated maintenance ~2,650 kcal. A 300–450 kcal deficit produces 0.5–0.75 lb/week fat loss — slow enough to protect Forge Breechay performance. Protein at 190–210g (~1g/lb lean mass) is the primary lever against muscle loss on a cut. Fasted Zone 2 cardio adds ~300 kcal deficit without touching training nutrition. Do not cut below 1,900 kcal on any day.")
                        .font(.sora(12, weight: .light))
                        .foregroundColor(.textSecond)
                        .lineSpacing(3)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Day toggle
            HStack(spacing: 6) {
                ForEach(["WORKDAY (Wed–Sun)", "BASE DAY (Mon–Tue)"].indices, id: \.self) { i in
                    Button(action: { dayMode = i }) {
                        MonoLabel(text: ["WORKDAY (Wed–Sun)", "BASE DAY (Mon–Tue)"][i],
                                  color: dayMode == i ? .inkTeal : .textMuted, size: 10)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(dayMode == i ? Color.inkTeal.opacity(0.12) : Color.clear)
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            // Meal timeline
            VStack(spacing: 0) {
                ForEach(dayMode == 0 ? workdayMeals : baseMeals) { meal in
                    NutritionMealRow(meal: meal)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Cardio protocol block
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "CARDIO PROTOCOL", color: .textMuted, size: 10)

                    HStack(spacing: 8) {
                        NutritionTagChip(text: "Zone 2 only", color: .inkTeal)
                        NutritionTagChip(text: "Fasted (default)", color: .inkAmber)
                        NutritionTagChip(text: "No intervals this phase", color: .inkRed)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        NutritionProtoRow(key: "TYPE", value: "Steady-state Zone 2 · bike preferred, elliptical OK")
                        NutritionProtoRow(key: "DURATION", value: "35–40 min · 4:30–5:10 AM window")
                        NutritionProtoRow(key: "HEART RATE", value: "130–145 BPM · conversational pace")
                        NutritionProtoRow(key: "FREQUENCY", value: "5x/week · one full rest day (Sat or Sun)")
                        NutritionProtoRow(key: "STATE", value: "Fasted (default) · half banana allowed if sleep was poor, HRV off, or legs feel empty")
                        NutritionProtoRow(key: "INTERVALS", value: "Not the default · reserve for base days only if needed")
                    }

                    Text("Zone 2 maximizes fat oxidation without cortisol load that competes with 5:30 PM hypertrophy. Fasted is the default — it keeps the fat-burn mechanism intact. Override with half a banana if sleep was poor, HRV is off, or legs feel genuinely empty before you start. No intervals during the cut — this phase is leanness + muscle retention. Intervals return when the cut is done.")
                        .font(.sora(12, weight: .light))
                        .foregroundColor(.textSecond)
                        .lineSpacing(3)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Failure modes
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "FAILURE MODES", color: .inkRed, size: 10)

                    NutritionFailureRow(
                        num: "01",
                        title: "Pre-lift meal skipped",
                        body: "Busy close, late customer, forgotten bag. When this is skipped you lift glycogen-depleted after an 8-hour shift. Over time this is the primary driver of strength regression on a cut.",
                        fix: "Pack sourdough + nut butter every morning with commute prep. It lives in the bag, not in a decision."
                    )
                    NutritionFailureRow(
                        num: "02",
                        title: "Under-eating during shift",
                        body: "Hideout produces appetite suppression from activity and stimulation. Easy to reach 5 PM having only eaten the 9:30 AM meal. Calorie deficit from missed midday eating cannot be compensated post-lift.",
                        fix: "Pack midday meal in container. 1:30 PM phone reminder: 'eat now' — not 'eat if hungry.' Hunger signal is unreliable during shift work."
                    )
                    NutritionFailureRow(
                        num: "03",
                        title: "Sleep compression crushing recovery",
                        body: "4 AM wake + 9:30 PM sleep = 6.5 hr ceiling. Any disruption leaves 5.5 hr. Sleep restriction elevates cortisol, suppresses testosterone, and directly impairs fat loss regardless of how clean the nutrition is.",
                        fix: "9:15 PM is a hard stop. If shift runs late and you won't be home by 8:30 PM, skip next morning's cardio. Sleep takes priority over cardio, always."
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct NutritionTargetCard: View {
    let value: String
    let unit: String
    let label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(.textPrimary)
            MonoLabel(text: unit, color: .textMuted, size: 10)
            MonoLabel(text: label, color: .textMuted, size: 10)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface2)
        .cornerRadius(8)
    }
}

struct NutritionMealRow: View {
    let meal: NutritionMeal
    var tagColor: Color {
        switch meal.tag {
        case "carb":    return .inkAmber
        case "protein": return .inkTeal
        case "lift":    return .violetLight
        case "fast":    return .textMuted
        default:        return .textMuted
        }
    }
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline dot + line
            VStack(spacing: 0) {
                Circle()
                    .fill(meal.tag == "lift" ? Color.violetLight : (meal.tag == "fast" ? Color.surface2 : tagColor))
                    .frame(width: 7, height: 7)
                    .overlay(Circle().stroke(tagColor.opacity(0.5), lineWidth: 1))
                    .padding(.top, 4)
                Rectangle()
                    .fill(Color.surface2)
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 7)

            VStack(alignment: .leading, spacing: 3) {
                MonoLabel(text: meal.time, color: .textMuted, size: 10)
                Text(meal.name)
                    .font(.sora(13, weight: meal.tag == "lift" ? .semibold : .light))
                    .foregroundColor(meal.tag == "lift" ? .violetLight : .textPrimary)
                Text(meal.foods)
                    .font(.sora(12, weight: .light))
                    .foregroundColor(.textSecond)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(meal.rule)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(tagColor)
                    .padding(.top, 1)
                MonoLabel(text: meal.kcal, color: .textMuted, size: 10)
            }
            .padding(.bottom, 14)
            Spacer()
        }
    }
}

struct NutritionProtoRow: View {
    let key: String
    let value: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            MonoLabel(text: key, color: .textMuted, size: 10)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.sora(12, weight: .light))
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

struct NutritionTagChip: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(4)
    }
}

struct NutritionFailureRow: View {
    let num: String
    let title: String
    let body: String
    let fix: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                MonoLabel(text: num, color: .inkRed, size: 11)
                Text(title)
                    .font(.sora(13, weight: .medium))
                    .foregroundColor(.textPrimary)
            }
            Text(body)
                .font(.sora(12, weight: .light))
                .foregroundColor(.textSecond)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .top, spacing: 4) {
                MonoLabel(text: "→", color: .inkTeal, size: 11)
                Text(fix)
                    .font(.sora(12, weight: .light))
                    .foregroundColor(.inkTeal)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(8)
            .background(Color.inkTeal.opacity(0.06))
            .cornerRadius(6)
        }
    }
}

