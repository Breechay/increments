import SwiftUI
import SwiftData

// MARK: - Signal tab (Distribution — plant / log / adjust)
// Spec: INCREMENTS_DISTRIBUTION_TAB_SPEC.md v2.3

struct SignalTabView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.appMetrics) private var metrics
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query(sort: \DistributionWeek.weekStartDate, order: .reverse) private var weeks: [DistributionWeek]
    @Query(sort: \DecisionLedger.createdAt, order: .reverse) private var ledgerEntries: [DecisionLedger]

    @AppStorage("forge_v1_gate_passed") private var forgeGateCleared = true
    @AppStorage("forge_post_gate_mondays_completed") private var forgePostGateMondaysCompleted = 3
    @AppStorage("distribution_first_monday_completed_at") private var firstMondayCompletedAt: Double = 0

    @State private var currentWeek: DistributionWeek?
    @State private var showFridaySheet = false
    @State private var expandedDrawer: String?
    @State private var ledgerVenture: AppContentVenture = .form
    @State private var ledgerFragment = ""
    @State private var decisionDraft = ""

    private var weekStart: Date { DistributionCalendar.mondayStart() }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            if metrics.isIPad && horizontalSizeClass == .regular {
                iPadLayout
            } else {
                phoneLayout
            }
        }
        .onAppear { ensureCurrentWeek() }
    }

    private var iPadLayout: some View {
        HStack(alignment: .top, spacing: metrics.sectionGap) {
            mondayBlockSection
                .frame(maxWidth: .infinity)
            ScrollView {
                VStack(spacing: metrics.sectionGap) {
                    formCoachingDayBanner
                    decisionLedgerSection
                    signalLogSection
                    logHistorySection
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.top, metrics.screenTopPadding)
        .padding(.bottom, metrics.tabBarHeight + 24)
    }

    private var phoneLayout: some View {
        ScrollView {
            VStack(spacing: metrics.sectionGap) {
                header
                formCoachingDayBanner
                mondayBlockSection
                if !DistributionCalendar.isMonday { decisionLedgerSection }
                signalLogSection
                logHistorySection
            }
            .padding(.horizontal, metrics.hPad)
            .padding(.top, metrics.screenTopPadding)
            .padding(.bottom, metrics.tabBarHeight + 32)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
            MonoLabel(text: "SIGNAL", color: .inkGreen, size: 11)
            Text("Plant · log · adjust")
                .font(.sora(metrics.titleSize, weight: .semibold))
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var formCoachingDayBanner: some View {
        if let line = DistributionCalendar.formCoachingDayLine {
            Text(line)
                .font(.mono(metrics.captionSize))
                .foregroundColor(.inkGreen.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: Monday block

    @ViewBuilder
    private var mondayBlockSection: some View {
        if let week = currentWeek {
            if week.mondayBlockCompleted {
                mondayCompleteStamp(week: week)
            } else if DistributionCalendar.isMonday {
                mondayActiveCard(week: week)
            } else if weekStart > Date() {
                EmptyView()
            } else {
                mondayMissedOrUpcoming(week: week)
            }
        }
    }

    private func mondayActiveCard(week: DistributionWeek) -> some View {
        CardView(style: .primary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                VStack(alignment: .leading, spacing: 4) {
                    MonoLabel(text: "MONDAY BLOCK", color: .warm, size: 10)
                    Text("Before Hideout opens · 60–90 min")
                        .font(.sora(metrics.bodySize)).foregroundColor(.textSecond)
                    Text("Film before unlocking · empty café")
                        .font(.mono(metrics.monoSmall)).foregroundColor(.inkAmber)
                }

                mondayStepWithDrawer(week: week, index: 0, label: "Film — 7-shot sequence, empty café", done: week.hideoutFilmed) {
                    week.hideoutFilmed = true
                } drawer: { shotListDrawer }

                mondayStepWithDrawer(week: week, index: 1, label: "Edit — assembly only, ≤30 sec", done: week.hideoutEdited, enabled: week.hideoutFilmed) {
                    week.hideoutEdited = true
                } drawer: { editDoctrineDrawer }

                mondayStep(week: week, index: 2, label: "Post — Google Business Profile", done: week.hideoutPostedGBP, enabled: week.hideoutEdited) {
                    week.hideoutPostedGBP = true
                }

                mondayStep(week: week, index: 3, label: "Post — Instagram Reels", done: week.hideoutPostedReels, enabled: week.hideoutPostedGBP) {
                    week.hideoutPostedReels = true
                }

                mondayStep(week: week, index: 4, label: "Post — TikTok · post and leave", done: week.hideoutPostedTikTok, enabled: week.hideoutPostedReels) {
                    week.hideoutPostedTikTok = true
                }

                if !forgeGateCleared {
                    Text("Forge distribution unlocks after v1 gate.")
                        .font(.sora(metrics.captionSize)).foregroundColor(.textMuted)
                        .padding(.top, 4)
                }
                if week.hideoutPostedTikTok || week.hideoutStepsComplete {
                    appContentSection(week: week)
                }

                if canCompleteMonday(week: week) {
                    Button(action: { completeMondayBlock(week: week) }) {
                        Text("COMPLETE BLOCK")
                            .font(.sora(metrics.bodySize, weight: .semibold))
                            .foregroundColor(.bgBase)
                            .frame(maxWidth: .infinity)
                            .frame(height: metrics.touchTarget * 0.85)
                            .background(Color.inkGreen)
                            .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius))
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    @ViewBuilder
    private func appContentSection(week: DistributionWeek) -> some View {
        let venture = week.appContentVenture
        VStack(alignment: .leading, spacing: metrics.blockSpacing) {
            MonoLabel(text: "\(venture.label) THIS WEEK", color: .violetLight, size: 9)

            mondayStepWithDrawer(week: week, index: 5, label: "Confirm decision sentence", done: !week.appContentDecision.isEmpty, enabled: week.hideoutPostedTikTok) {
                if decisionDraft.isEmpty, let pull = latestUnusedLedger(for: venture) {
                    week.appContentDecision = pull.fragment
                    decisionDraft = pull.fragment
                    markLedgerUsed(pull, weekStart: week.weekStartDate)
                } else if !decisionDraft.isEmpty {
                    week.appContentDecision = decisionDraft
                }
            } drawer: { contentPrimitiveDrawer }

            if week.hideoutPostedTikTok {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Decision sentence", text: $decisionDraft, axis: .vertical)
                        .font(.sora(metrics.bodySize))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2...4)
                        .padding(12)
                        .background(Color.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear {
                            if decisionDraft.isEmpty {
                                decisionDraft = week.appContentDecision
                                if decisionDraft.isEmpty, let pull = latestUnusedLedger(for: venture) {
                                    decisionDraft = pull.fragment
                                }
                            }
                        }
                        .onChange(of: decisionDraft) { _, new in
                            week.appContentDecision = new.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                }
            }

            mondayStep(week: week, index: 6, label: "Record — system state · single take", done: week.appContentRecorded, enabled: !week.appContentDecision.isEmpty) {
                week.appContentRecorded = true
            }

            mondayStepWithDrawer(week: week, index: 7, label: "Post", done: week.appContentPosted, enabled: week.appContentRecorded) {
                week.appContentPosted = true
            } drawer: { captionDoctrineDrawer }
        }
        .padding(.top, 8)
    }

    private func mondayStep(
        week: DistributionWeek,
        index: Int,
        label: String,
        done: Bool,
        enabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        mondayStepWithDrawer(week: week, index: index, label: label, done: done, enabled: enabled, action: action) {
            EmptyView()
        }
    }

    private func mondayStepWithDrawer<Drawer: View>(
        week: DistributionWeek,
        index: Int,
        label: String,
        done: Bool,
        enabled: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder drawer: () -> Drawer
    ) -> some View {
        let canTap = enabled && !done
        return VStack(alignment: .leading, spacing: 6) {
            Button(action: {
                guard canTap else { return }
                action()
                save()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: done ? "checkmark.square.fill" : "square")
                        .foregroundColor(done ? .inkGreen : (enabled ? .textMuted : .textMuted.opacity(0.35)))
                    Text(label)
                        .font(.sora(metrics.bodySize))
                        .foregroundColor(enabled ? .textPrimary : .textMuted)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            .disabled(!canTap && !done)
            drawer()
        }
    }

    private func mondayCompleteStamp(week: DistributionWeek) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 6) {
                MonoLabel(text: "MONDAY BLOCK COMPLETE", color: .inkGreen, size: 10)
                Text(week.mondayStampLine)
                    .font(.mono(metrics.bodySize))
                    .foregroundColor(.textPrimary)
            }
        }
    }

    private func mondayMissedOrUpcoming(week: DistributionWeek) -> some View {
        let cal = Calendar.current
        let nextMonday = cal.date(byAdding: .day, value: (9 - cal.component(.weekday, from: Date())) % 7, to: weekStart) ?? weekStart
        let missed = !week.mondayBlockCompleted && !DistributionCalendar.isMonday && Date() > cal.date(byAdding: .day, value: 1, to: weekStart)!

        return CardView(style: .secondary) {
            if missed {
                Text("Monday \(week.weekStartDate.formatted(.dateTime.month(.abbreviated).day())) · not run")
                    .font(.mono(metrics.bodySize))
                    .foregroundColor(.textMuted)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    MonoLabel(text: "NEXT MONDAY BLOCK", color: .textMuted, size: 9)
                    Text(nextMonday, style: .date)
                        .font(.sora(metrics.bodySize))
                        .foregroundColor(.textSecond)
                }
            }
        }
    }

    // MARK: Decision ledger

    @ViewBuilder
    private var decisionLedgerSection: some View {
        if DistributionCalendar.isMonday { EmptyView() }
        else {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    MonoLabel(text: "DECISION LEDGER", color: .violetLight, size: 10)
                    HStack(spacing: 8) {
                        Picker("", selection: $ledgerVenture) {
                            ForEach(AppContentVenture.allCases, id: \.self) { v in
                                Text(v.label).tag(v)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.violetLight)

                        TextField("One sentence", text: $ledgerFragment)
                            .font(.sora(metrics.bodySize))
                            .foregroundColor(.textPrimary)
                            .padding(10)
                            .background(Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button("ADD") { addLedgerEntry() }
                            .font(.mono(metrics.monoSmall, weight: .medium))
                            .foregroundColor(.inkGreen)
                            .disabled(ledgerFragment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    ForEach(ledgerEntries.prefix(12)) { entry in
                        HStack(alignment: .top, spacing: 8) {
                            Text("—")
                                .font(.mono(metrics.monoSmall))
                                .foregroundColor(entry.isUsed ? .textMuted.opacity(0.4) : .textSecond)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.fragment)
                                    .font(.sora(metrics.captionSize))
                                    .foregroundColor(entry.isUsed ? .textMuted : .textPrimary)
                                Text("\(entry.venture.label) · \(entry.dateLabel)")
                                    .font(.mono(metrics.monoSmall))
                                    .foregroundColor(.textMuted)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    // MARK: Signal log

    private var signalLogSection: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                HStack {
                    MonoLabel(text: "SIGNAL LOG", color: .inkGreen, size: 10)
                    Spacer()
                    if let week = currentWeek, !week.fridayLogCompleted {
                        Button(action: { showFridaySheet = true }) {
                            MonoLabel(text: "LOG FRIDAY", color: .inkGreen, size: 9)
                        }
                    }
                }

                if let week = currentWeek {
                    if week.fridayLogCompleted {
                        fridaySummary(week: week)
                        if let line = diagnosticLine(for: week) {
                            Text(line)
                                .font(.sora(metrics.captionSize))
                                .foregroundColor(.inkAmber)
                                .padding(.top, 4)
                        }
                    } else {
                        Text("Week of \(week.weekStartDate.formatted(.dateTime.month(.abbreviated).day()))")
                            .font(.mono(metrics.bodySize))
                            .foregroundColor(.textSecond)
                        Text("Run Friday after close · 8–10 min")
                            .font(.sora(metrics.captionSize))
                            .foregroundColor(.textMuted)
                    }
                }
            }
        }
        .sheet(isPresented: $showFridaySheet) {
            if let week = currentWeek {
                SignalFridayLogSheet(week: week, forgeGateDefault: forgeGateCleared, isPresented: $showFridaySheet)
            }
        }
    }

    private func fridaySummary(week: DistributionWeek) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(week.weekLabel + (week.fridayLogCompletedAt.map { " · \($0.formatted(date: .omitted, time: .shortened))" } ?? ""))
                .font(.mono(metrics.monoSmall))
                .foregroundColor(.textMuted)
            signalRow("Board attributions", "\(week.hideoutBoardAttributions)")
            signalRow("Watermarc", "\(week.hideoutWatermarcRedemptions)")
            signalRow("Source mentions", "\(week.hideoutSourceMentions)")
            signalRow("GBP attributions", "\(week.hideoutGBPAttributions)")
            signalRow("FORM outside", week.formOutsideEngagement ? "Yes" : "No")
            signalRow("Forge gate", week.forgeV1GatePassed ? "Passed" : "—")
            if !week.oneAdjustment.isEmpty {
                Text(week.oneAdjustment)
                    .font(.sora(metrics.bodySize))
                    .foregroundColor(.textPrimary)
                    .padding(.top, 4)
            }
        }
    }

    private func signalRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.sora(metrics.captionSize)).foregroundColor(.textSecond)
            Spacer()
            Text(value).font(.mono(metrics.captionSize)).foregroundColor(.textPrimary)
        }
    }

    // MARK: Log history

    private var logHistorySection: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                if showEightWeekPrompt {
                    Text("8 weeks of logs. Worth a full read.")
                        .font(.sora(metrics.captionSize))
                        .foregroundColor(.inkGreen)
                }
                MonoLabel(text: "LOG HISTORY", color: .textMuted, size: 10)
                ForEach(weeks.prefix(16)) { week in
                    HStack {
                        Text(week.weekLabel)
                            .font(.mono(metrics.captionSize))
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Text("Block \(week.mondayBlockCompleted ? "✓" : "—")")
                            .font(.mono(metrics.monoSmall))
                            .foregroundColor(.textMuted)
                        Text("Log \(week.fridayLogCompleted ? "✓" : "—")")
                            .font(.mono(metrics.monoSmall))
                            .foregroundColor(.textMuted)
                    }
                }
                if weeks.isEmpty {
                    Text("No weeks yet.")
                        .font(.sora(metrics.captionSize))
                        .foregroundColor(.textMuted)
                }
            }
        }
    }

    // MARK: Drawers

    private var shotListDrawer: some View {
        doctrineDrawer(id: "shots", title: "7-SHOT SEQUENCE") {
            Text("Locked positions — empty café, morning light, natural audio on espresso only.")
                .font(.sora(metrics.captionSize)).foregroundColor(.textMuted)
        }
    }

    private var editDoctrineDrawer: some View {
        doctrineDrawer(id: "edit", title: "ASSEMBLY RULES") {
            Text("7 clips · linear · no transitions · natural sound · first frame = cover. Assembly, not editing.")
                .font(.sora(metrics.captionSize)).foregroundColor(.textMuted)
        }
    }

    private var contentPrimitiveDrawer: some View {
        doctrineDrawer(id: "primitive", title: "CONTENT PRIMITIVE") {
            Text("One decision · one outcome · one sentence. Outsider-legible — stranger understands the signal.")
                .font(.sora(metrics.captionSize)).foregroundColor(.textMuted)
        }
    }

    private var captionDoctrineDrawer: some View {
        doctrineDrawer(id: "caption", title: "CAPTION RULES") {
            Text("GBP: factual, one sentence. Reels/TikTok: one-line observation · saved preset · no invention at post time.")
                .font(.sora(metrics.captionSize)).foregroundColor(.textMuted)
        }
    }

    private func doctrineDrawer<Content: View>(id: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { expandedDrawer = expandedDrawer == id ? nil : id }) {
                HStack {
                    Text("\(title) ↓")
                        .font(.mono(metrics.monoSmall))
                        .foregroundColor(.textMuted)
                    Spacer()
                }
            }
            if expandedDrawer == id { content() }
        }
        .padding(.leading, 28)
    }

    // MARK: Logic

    private func ensureCurrentWeek() {
        let start = weekStart
        if let existing = weeks.first(where: { Calendar.current.isDate($0.weekStartDate, inSameDayAs: start) }) {
            currentWeek = existing
            configureWeekVenture(existing)
            if decisionDraft.isEmpty { decisionDraft = existing.appContentDecision }
            return
        }
        let week = DistributionWeek(weekStartDate: start)
        configureWeekVenture(week)
        context.insert(week)
        currentWeek = week
        save()
    }

    private func configureWeekVenture(_ week: DistributionWeek) {
        week.appContentVenture = DistributionCalendar.appContentVenture(
            for: week.weekStartDate,
            forgeGateCleared: forgeGateCleared,
            forgePostGateMondaysCompleted: forgePostGateMondaysCompleted
        )
        if forgeGateCleared && !week.fridayLogCompleted {
            week.forgeV1GatePassed = true
        }
    }

    private func canCompleteMonday(week: DistributionWeek) -> Bool {
        week.hideoutStepsComplete && week.appContentStepsComplete
    }

    private func completeMondayBlock(week: DistributionWeek) {
        week.mondayBlockCompleted = true
        week.mondayBlockCompletedAt = Date()
        if week.appContentVenture == .forge, forgePostGateMondaysCompleted < 3 {
            forgePostGateMondaysCompleted += 1
        }
        if firstMondayCompletedAt == 0 {
            firstMondayCompletedAt = Date().timeIntervalSince1970
        }
        save()
    }

    private func latestUnusedLedger(for venture: AppContentVenture) -> DecisionLedger? {
        ledgerEntries.first { $0.venture == venture && !$0.isUsed }
    }

    private func markLedgerUsed(_ entry: DecisionLedger, weekStart: Date) {
        entry.usedInWeekStart = weekStart
        save()
    }

    private func addLedgerEntry() {
        let text = ledgerFragment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        context.insert(DecisionLedger(venture: ledgerVenture, fragment: text))
        ledgerFragment = ""
        save()
    }

    private func save() { try? context.save() }

    private var showEightWeekPrompt: Bool {
        guard firstMondayCompletedAt > 0 else { return false }
        let start = Date(timeIntervalSince1970: firstMondayCompletedAt)
        let eightWeeks = Calendar.current.date(byAdding: .weekOfYear, value: 8, to: start) ?? start
        return Calendar.current.isDateInToday(eightWeeks) || Date() >= eightWeeks
    }

    private func diagnosticLine(for week: DistributionWeek) -> String? {
        let recent = weeks.prefix(6)
        if week.hideoutWatermarcRedemptions == 0,
           weeks.prefix(3).allSatisfy({ $0.hideoutWatermarcRedemptions == 0 && $0.mondayBlockCompleted }) {
            return "Watermarc zero three weeks. Confirm cards delivered."
        }
        if !week.mondayBlockCompleted,
           week.hideoutSourceMentions == 0,
           week.hideoutBoardAttributions == 0,
           week.hideoutWatermarcRedemptions == 0 {
            return "No block this week. No signal to read."
        }
        if !forgeGateCleared {
            let openWeeks = weeks.filter { !$0.forgeV1GatePassed }.count
            if openWeeks >= 6 { return "Forge distribution stays paused until v1 gate clears." }
        }
        let holdWeeks = recent.filter { $0.oneAdjustment.uppercased() == "HOLD" }
        if holdWeeks.count >= 6,
           week.hideoutWatermarcRedemptions == 0,
           week.oneAdjustment.uppercased() == "HOLD" {
            return "Watermarc unchanged 6 weeks. Change surface or confirm seed is correct."
        }
        return nil
    }
}

// MARK: - Friday log sheet

struct SignalFridayLogSheet: View {
    @Bindable var week: DistributionWeek
    var forgeGateDefault: Bool
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var context
    @Environment(\.appMetrics) private var metrics

    @State private var adjustment = ""

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: metrics.sectionGap) {
                    SheetHandle().frame(maxWidth: .infinity)
                    MonoLabel(text: "SIGNAL LOG", color: .inkGreen, size: 11)
                    Text(week.weekLabel)
                        .font(.sora(metrics.titleSize, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    stepperRow("Board attributions", value: $week.hideoutBoardAttributions)
                    stepperRow("Watermarc redemptions", value: $week.hideoutWatermarcRedemptions)
                    stepperRow("Source mentions", value: $week.hideoutSourceMentions)
                    stepperRow("GBP attributions", value: $week.hideoutGBPAttributions)

                    Toggle("FORM outside-network engagement", isOn: $week.formOutsideEngagement)
                        .font(.sora(metrics.bodySize))
                        .tint(.inkGreen)

                    Toggle("Forge v1 gate passed", isOn: $week.forgeV1GatePassed)
                        .font(.sora(metrics.bodySize))
                        .tint(.inkGreen)
                        .onAppear { week.forgeV1GatePassed = forgeGateDefault }

                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "ONE ADJUSTMENT OR HOLD", color: .textMuted, size: 9)
                        TextField("One line", text: $adjustment)
                            .font(.sora(metrics.bodySize))
                            .foregroundColor(.textPrimary)
                            .padding(12)
                            .background(Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { adjustment = week.oneAdjustment }
                    }

                    Button(action: save) {
                        Text("SAVE")
                            .font(.sora(metrics.bodySize, weight: .semibold))
                            .foregroundColor(.bgBase)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.inkGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
        }
    }

    private func stepperRow(_ label: String, value: Binding<Int>) -> some View {
        HStack {
            Text(label).font(.sora(metrics.bodySize)).foregroundColor(.textPrimary)
            Spacer()
            Button("−") { value.wrappedValue = max(0, value.wrappedValue - 1) }
                .font(.mono(16))
            Text("\(value.wrappedValue)")
                .font(.mono(18, weight: .semibold))
                .frame(minWidth: 28)
            Button("+") { value.wrappedValue += 1 }
                .font(.mono(16))
        }
    }

    private func save() {
        week.oneAdjustment = adjustment.trimmingCharacters(in: .whitespacesAndNewlines)
        week.fridayLogCompleted = true
        week.fridayLogCompletedAt = Date()
        try? context.save()
        isPresented = false
    }
}
