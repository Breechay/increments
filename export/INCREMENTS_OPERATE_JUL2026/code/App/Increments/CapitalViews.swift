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
    @Environment(\.appMetrics) private var metrics
    @Environment(\.modelContext) private var context
    @State private var showEdit = false
    @State private var showLab = false

    // Housing optimization
    @AppStorage("housing_decision_made")      private var housingDecisionMade     = false
    @AppStorage("housing_approach_selected")  private var housingApproachSelected = ""
    @AppStorage("housing_post_drafted")       private var housingPostDrafted      = false
    @AppStorage("housing_outreach_done")      private var housingOutreachDone     = false
    @AppStorage("housing_screening_done")     private var housingScreeningDone    = false
    @AppStorage("housing_move_in_set")        private var housingMoveInSet        = false

    var current: FinancialState {
        if let s = states.first { return s }
        let s = FinancialState(); return s
    }

    var body: some View {
        VStack(spacing: metrics.blockSpacing) {

            // ── RESOURCE STATE ───────────────────────────────────────────
            CardView {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    HStack {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "CAPITAL", color: .warm)
                            MonoLabel(text: "RESOURCE ARCHITECTURE", color: .textMuted, size: 10)
                        }
                        Spacer()
                        Button(action: { showEdit = true }) {
                            Image(systemName: "pencil")
                                .font(.system(size: metrics.scaledSize(12))).foregroundColor(.textMuted)
                                .frame(width: 28, height: 28)
                                .background(Color.surface)
                                .clipShape(Circle())
                        }
                    }
                    Divider().background(Color.muted.opacity(0.2))

                    // Runway
                    HStack(spacing: metrics.cardSpacing) {
                        Circle()
                            .fill(current.runwayState.color)
                            .frame(width: 8, height: 8)
                            .shadow(color: current.runwayState.color.opacity(0.5), radius: 4)
                        Text(current.runwayState.label)
                            .font(metrics.fontSora(15, weight: .medium)).foregroundColor(.textPrimary)
                        Spacer()
                        MonoLabel(text: "RUNWAY", color: .textMuted, size: 10)
                    }

                    // Clarity
                    HStack {
                        Text("Picture clarity")
                            .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
                        Spacer()
                        MonoLabel(text: current.capitalClarity.rawValue,
                                  color: current.capitalClarity == .clear ? .inkGreen : current.capitalClarity == .partial ? .inkAmber : .textMuted,
                                  size: 11)
                    }

                    // Inflow
                    HStack {
                        Text("Income this period")
                            .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
                        Spacer()
                        MonoLabel(text: current.inflowReceived ? "RECEIVED" : "PENDING",
                                  color: current.inflowReceived ? .inkGreen : .textMuted, size: 11)
                    }

                    // Next obligation
                    if let date = current.nextObligationDate, !current.nextObligationLabel.isEmpty {
                        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                        HStack {
                            Text(current.nextObligationLabel)
                                .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
                            Spacer()
                            MonoLabel(text: days <= 0 ? "DUE" : "IN \(days)D",
                                      color: days <= 3 ? .inkAmber : .textMuted, size: 11)
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // ── ARCHITECTURE SIGNALS ─────────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
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
                        HStack(alignment: .top, spacing: metrics.cardSpacing) {
                            Circle().fill(Color.inkAmber.opacity(0.7)).frame(width: 6, height: 6).padding(.top, 5)
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                MonoLabel(text: "DOMINANT LEAK", color: .inkAmber, size: 10)
                                Text(current.mainLeakCategory.rawValue)
                                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond)
                            }
                        }
                    }

                    if current.activeFinancialFronts >= 3 {
                        HStack(alignment: .top, spacing: metrics.cardSpacing) {
                            Circle().fill(Color.inkAmber.opacity(0.7)).frame(width: 6, height: 6).padding(.top, 5)
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                MonoLabel(text: "FRAGMENTATION", color: .inkAmber, size: 10)
                                Text("\(current.activeFinancialFronts) active financial fronts. Same principles apply as execution.")
                                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // ── RESOURCE DOCTRINES ───────────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
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
                         "Capital is the ability to direct energy. Leaks are routing problems — the same class of friction as operational displacement or fragmentation."),
                        ("PROTECT BASE LAYERS FIRST",
                         "Obligations, buffer, runway. Then experimentation, generosity, and growth. Same architectural principle as environment before cognition."),
                    ]
                    ForEach(doctrines, id: \.0) { doctrine in
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: doctrine.0, color: .warm, size: 10)
                            Text(doctrine.1)
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // ── HOUSING OPTIMIZATION ─────────────────────────────────────
            housingCard
                .padding(.horizontal, metrics.hPad)

            // ── EXPORT ───────────────────────────────────────────────────
            WeeklyExportCard(actions: [], logs: [])
                .padding(.horizontal, metrics.hPad)
        }
        .padding(.bottom, 80)
        .adaptiveContentWidth(metrics)
        .sheet(isPresented: $showEdit) {
            EditCapitalStateSheet(isPresented: $showEdit, state: states.first)
        }
        .onAppear {
            if states.isEmpty { context.insert(FinancialState()) }
        }
    }

    // MARK: — Housing Optimization Card
    var housingCard: some View {
        let approaches: [(String, String, String)] = [
            ("ROOMMATE",        "Find 1 roommate",          "Offset ~$1,500–2,000/mo. Fast. Well-tested in your building. Highest ROI per hour spent."),
            ("SUBLEASE ROOM",   "List spare room short-term","Airbnb or Furnished Finder. Flexible. Higher per-night, lower occupancy certainty."),
            ("NEGOTIATE RENT",  "Talk to building directly", "Lease renewal leverage. May not apply now but worth knowing the number."),
            ("DOWNSIZE",        "Smaller unit",              "Nuclear option. Only if other levers fail. Disruption cost is real — factor it."),
        ]

        let actionItems: [(String, Binding<Bool>)] = [
            ("Draft listing — 3 sentences, one photo, honest tone", $housingPostDrafted),
            ("Post to: Furnished Finder, Facebook Edgewater groups, building board", $housingOutreachDone),
            ("Screen 2–3 candidates — schedule, lifestyle, reliability", $housingScreeningDone),
            ("Move-in date set", $housingMoveInSet),
        ]

        let actionDone = actionItems.filter { $0.1.wrappedValue }.count
        let actionTotal = actionItems.count

        return CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {

                HStack {
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "HOUSING OPTIMIZATION", color: .inkAmber, size: 10)
                        Text("Rent offset = Financial Neutrality architecture. Not failure.")
                            .font(metrics.fontSora(12, weight: .light))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                    }
                    Spacer()
                    if housingDecisionMade {
                        Text("\(actionDone)/\(actionTotal)")
                            .font(.system(size: metrics.scaledSize(12), weight: .semibold, design: .monospaced))
                            .foregroundColor(actionDone == actionTotal ? .inkGreen : .inkAmber)
                    }
                }

                // Approach selection — brainstorm phase
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: housingDecisionMade ? "APPROACH — LOCKED" : "APPROACH — SELECT ONE", color: .textMuted, size: 9)
                    VStack(spacing: 0) {
                        ForEach(approaches.indices, id: \.self) { idx in
                            let ap = approaches[idx]
                            Button {
                                withAnimation(.spring(response: 0.25)) {
                                    housingApproachSelected = ap.0
                                    housingDecisionMade = true
                                }
                            } label: {
                                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                                    ZStack {
                                        Circle()
                                            .fill(housingApproachSelected == ap.0 ? Color.inkAmber.opacity(0.15) : Color.surface)
                                            .frame(width: 18, height: 18)
                                        Circle()
                                            .stroke(housingApproachSelected == ap.0 ? Color.inkAmber : Color.muted.opacity(0.4), lineWidth: 1.5)
                                            .frame(width: 18, height: 18)
                                        if housingApproachSelected == ap.0 {
                                            Circle().fill(Color.inkAmber).frame(width: 8, height: 8)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                        HStack(spacing: metrics.rowSpacing) {
                                            Text(ap.1)
                                                .font(.sora(12, weight: housingApproachSelected == ap.0 ? .medium : .light))
                                                .foregroundColor(housingApproachSelected == ap.0 ? .textPrimary : .textSecond)
                                            MonoLabel(text: ap.0, color: housingApproachSelected == ap.0 ? .inkAmber : .textMuted, size: 8)
                                        }
                                        Text(ap.2)
                                            .font(metrics.fontSora(12, weight: .light))
                                            .foregroundColor(.textMuted)
                                            .lineSpacing(1.5)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                            if idx < approaches.count - 1 {
                                Rectangle().fill(Color.muted.opacity(0.08)).frame(height: 0.5)
                            }
                        }
                    }
                }

                // Action checklist — only shows once approach selected
                if housingDecisionMade {
                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.surface).frame(height: 3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(actionDone == actionTotal ? Color.inkGreen : Color.inkAmber)
                                .frame(width: actionTotal > 0 ? geo.size.width * CGFloat(actionDone) / CGFloat(actionTotal) : 0, height: 3)
                                .animation(.spring(response: 0.4), value: actionDone)
                        }
                    }
                    .frame(height: 3)

                    VStack(spacing: 0) {
                        ForEach(actionItems.indices, id: \.self) { idx in
                            let item = actionItems[idx]
                            Button {
                                withAnimation(.spring(response: 0.25)) { item.1.wrappedValue.toggle() }
                            } label: {
                                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(item.1.wrappedValue ? Color.inkAmber.opacity(0.15) : Color.surface)
                                            .frame(width: 18, height: 18)
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(item.1.wrappedValue ? Color.inkAmber : Color.muted.opacity(0.4), lineWidth: 1.5)
                                            .frame(width: 18, height: 18)
                                        if item.1.wrappedValue {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: metrics.scaledSize(10), weight: .bold))
                                                .foregroundColor(.inkAmber)
                                        }
                                    }
                                    Text(item.0)
                                        .font(metrics.fontSora(13, weight: .light))
                                        .foregroundColor(item.1.wrappedValue ? .textMuted : .textSecond)
                                        .lineSpacing(2)
                                        .strikethrough(item.1.wrappedValue, color: .textMuted.opacity(0.4))
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            if idx < actionItems.count - 1 {
                                Rectangle().fill(Color.muted.opacity(0.08)).frame(height: 0.5)
                            }
                        }
                    }

                    if actionDone == actionTotal {
                        HStack(spacing: metrics.rowSpacing) {
                            Circle().fill(Color.inkGreen).frame(width: 4, height: 4)
                            Text("Housing cost offset active. Pressure reduced. Next: redeploy attention to Hideout + RunCards.")
                                .font(.system(size: metrics.scaledSize(11), design: .monospaced))
                                .foregroundColor(.inkGreen)
                                .lineSpacing(2)
                        }
                    } else {
                        HStack(spacing: metrics.rowSpacing) {
                            Circle().fill(Color.inkAmber.opacity(0.6)).frame(width: 4, height: 4)
                            Text("Mechanism: lower fixed cost → less background pressure → better decisions on everything else.")
                                .font(.system(size: metrics.scaledSize(10), design: .monospaced))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                    }
                }
            }
        }
    }

    func capitalSignal(_ label: String, state: Bool, note: String) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            Circle()
                .fill(state ? Color.inkGreen : Color.muted.opacity(0.3))
                .frame(width: 6, height: 6).padding(.top, 5)
            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                Text(label)
                    .font(.sora(13, weight: state ? .medium : .light))
                    .foregroundColor(state ? .textPrimary : .textMuted)
                if !state {
                    Text(note)
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.muted).lineSpacing(2)
                }
            }
        }
    }
}

// MARK: - EDIT CAPITAL STATE SHEET

struct EditCapitalStateSheet: View {
    @Environment(\.appMetrics) private var metrics
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
                VStack(alignment: .leading, spacing: metrics.sectionGap) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Text("Capital State").font(metrics.fontSora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Done") { save(); isPresented = false }.font(metrics.fontSora(15)).foregroundColor(.violet)
                    }

                    // Runway
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "RUNWAY")
                        MonoLabel(text: "Categorical — not numerical", color: .muted, size: 10)
                        HStack(spacing: metrics.rowSpacing) {
                            ForEach(RunwayState.allCases, id: \.self) { rs in
                                Button(action: { runwayState = rs }) {
                                    VStack(spacing: metrics.rowSpacing) {
                                        Circle().fill(rs.color.opacity(runwayState == rs ? 0.9 : 0.3))
                                            .frame(width: 8, height: 8)
                                        Text(rs.rawValue).font(metrics.fontMono(12)).tracking(0.5)
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
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "PICTURE CLARITY")
                        HStack(spacing: metrics.rowSpacing) {
                            ForEach(CapitalClarity.allCases, id: \.self) { c in
                                Button(action: { capitalClarity = c }) {
                                    Text(c.rawValue).font(metrics.fontMono(12)).tracking(0.5)
                                        .foregroundColor(capitalClarity == c ? .bgBase : .textMuted)
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(capitalClarity == c ? Color.warm : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Architecture signals
                    VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                        MonoLabel(text: "ARCHITECTURE SIGNALS")
                        toggleRow("Runway visible", isOn: $hasRunwayVisibility)
                        toggleRow("Generosity budgeted", isOn: $hasBudgetedGenerosity)
                        toggleRow("Emergency buffer exists", isOn: $hasEmergencyBuffer)
                    }

                    // Inflow
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "INFLOW THIS PERIOD")
                        HStack(spacing: metrics.cardSpacing) {
                            ForEach([true, false], id: \.self) { val in
                                Button(action: { inflowReceived = val }) {
                                    Text(val ? "Received" : "Not yet").font(metrics.fontSora(14))
                                        .foregroundColor(inflowReceived == val ? .bgBase : .textSecond)
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(inflowReceived == val ? Color.inkGreen : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Dominant leak
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "DOMINANT LEAK CATEGORY")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: metrics.rowSpacing) {
                            ForEach(FinancialLeakType.allCases, id: \.self) { leak in
                                Button(action: { mainLeak = leak }) {
                                    Text(leak.rawValue).font(metrics.fontSora(13))
                                        .foregroundColor(mainLeak == leak ? .bgBase : .textSecond)
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(mainLeak == leak ? Color.inkAmber : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Active financial fronts
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "ACTIVE FINANCIAL FRONTS")
                        MonoLabel(text: "Open money 'projects' running simultaneously", color: .muted, size: 10)
                        Stepper("\(activeFronts)", value: $activeFronts, in: 1...10)
                            .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Next obligation
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        HStack {
                            MonoLabel(text: "NEXT OBLIGATION")
                            Spacer()
                            Toggle("", isOn: $hasNextObligation).tint(Color.warm).labelsHidden()
                        }
                        if hasNextObligation {
                            inputField("LABEL", placeholder: "e.g. Rent, Insurance", text: $nextLabel)
                            DatePicker("Date", selection: $nextDate, displayedComponents: .date)
                                .datePickerStyle(.compact).colorScheme(.dark)
                                .font(metrics.fontSora(14)).foregroundColor(.textPrimary)
                                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    inputField("NOTES (OPTIONAL)", placeholder: "Running context", text: $notes)

                    CardView(style: .ambient) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "NO AMOUNTS STORED", color: .muted, size: 10)
                            Text("Capital state is categorical. No numbers, no budgets, no targets. Clarity without surveillance.")
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(3)
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
            Text(label).font(metrics.fontSora(14)).foregroundColor(.textPrimary)
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

// YouView — see YouTabViews.swift (Capital · Brief · Ventures · Intel · Manual · Settings)

struct ProfileTabView: View {
    @Bindable var profile: OperatorProfile
    @Query private var actions: [Action]
    @Environment(\.appMetrics) private var metrics
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
        VStack(spacing: metrics.sectionGap) {
            // Operator identity card
            CardView {
                VStack(spacing: metrics.blockSpacing) {
                    HStack(spacing: metrics.blockSpacing) {
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
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "OPERATOR", color: .violetLight, size: 11)
                            Text(profile.firstName.isEmpty ? profile.title : profile.firstName)
                                .font(metrics.fontSora(16, weight: .semibold)).foregroundColor(.textPrimary)
                            Text(profile.phaseLabel.isEmpty ? "Recovery + Operational Restoration" : profile.phaseLabel)
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
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
            .padding(.horizontal, metrics.hPad)

            // Intelligence readiness — honest about what's being collected and what isn't ready yet
            IntelligenceReadinessCard(
                patternReadiness: patternReadiness,
                frictionReadiness: frictionReadiness,
                energyCalibrationReadiness: energyCalibrationReadiness,
                cognitionTaggingStatus: cognitionTaggingStatus
            )
            .padding(.horizontal, metrics.hPad)

            // Hideout business layer — quick access within Dossier
            HideoutTabView()

            // Weekly Review Export
            WeeklyExportCard(actions: actions, logs: logs)
                .padding(.horizontal, metrics.hPad)
        }
        .padding(.bottom, 80)
    }

    func statCell(_ label: String, value: String) -> some View {
        VStack(spacing: metrics.rowSpacing) {
            Text(value).font(metrics.fontSora(18, weight: .semibold)).foregroundColor(.textPrimary)
            MonoLabel(text: label, color: .textMuted, size: 11)
        }.frame(maxWidth: .infinity)
    }
}

// Field manual — YouFieldManualView in YouTabViews.swift
// Nutrition protocol lives in Physique → meal rail (Capital tab no longer duplicates it).


