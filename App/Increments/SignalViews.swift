import SwiftUI
import SwiftData

// MARK: - Signal tab (Distribution — plant / log / adjust)
// Spec: INCREMENTS_DISTRIBUTION_TAB_SPEC.md v2.3
// Beauty pass: May 2026 — header parity, divider, adaptiveContentWidth,
// checkbox sizing, stepper refinement, sheet spacing, iPad left-column header.

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
    @State private var formDayBannerExpanded = false

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

    // MARK: - iPad layout (left fixed / right scroll — matches Hideout pattern)

    private var iPadLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left column — Monday block + header
            VStack(spacing: 0) {
                iPadLeftHeader
                ScrollView {
                    VStack(spacing: metrics.sectionGap) {
                        mondayBlockSection
                    }
                    .padding(.horizontal, metrics.hPad)
                    .padding(.top, metrics.sectionGap)
                    .padding(.bottom, metrics.tabBarHeight + 32)
                    .adaptiveContentWidth(metrics)
                }
            }
            .frame(maxWidth: .infinity)

            // Column divider
            Rectangle()
                .fill(Color.muted.opacity(0.18))
                .frame(width: 0.5)

            // Right column — ledger, log, history
            ScrollView {
                VStack(spacing: metrics.sectionGap) {
                    formCoachingDayBanner
                        .padding(.top, metrics.screenTopPadding)
                    decisionLedgerSection
                    signalLogSection
                    logHistorySection
                }
                .padding(.horizontal, metrics.hPad)
                .padding(.bottom, metrics.tabBarHeight + 32)
                .adaptiveContentWidth(metrics)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // iPad left column header — matches Hideout pattern (kicker + title + divider)
    private var iPadLeftHeader: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: metrics.scaledSize(5)) {
                MonoLabel(text: "SIGNAL", color: .inkGreen, size: 10)
                Text("Plant · log · adjust")
                    .font(.sora(metrics.titleSize, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, metrics.hPad)
            .padding(.top, metrics.screenTopPadding)
            .padding(.bottom, metrics.headerBottomPadding)

            LinearGradient(
                colors: [Color.clear, Color.muted.opacity(0.22), Color.clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(height: 0.5)
            .padding(.horizontal, metrics.hPad)
        }
    }

    // MARK: - Phone layout

    private var phoneLayout: some View {
        ScrollView {
            VStack(spacing: metrics.sectionGap) {
                phoneHeader
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

    // Phone header — matches GlanceTabHeader pattern (kicker + title + divider)
    private var phoneHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: metrics.scaledSize(3)) {
                    MonoLabel(text: "SIGNAL", color: .inkGreen, size: 10)
                    Text("Plant · log · adjust")
                        .font(.sora(metrics.titleSize, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }
                Spacer()
            }
            .padding(.bottom, metrics.headerBottomPadding)

            LinearGradient(
                colors: [Color.clear, Color.muted.opacity(0.18), Color.clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(height: 0.5)
        }
    }

    // MARK: - Coaching day banner

    @ViewBuilder
    private var formCoachingDayBanner: some View {
        if let line = DistributionCalendar.formCoachingDayLine {
            VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) { formDayBannerExpanded.toggle() }
                }) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.inkGreen)
                            .frame(width: 5, height: 5)
                        Text(line)
                            .font(.mono(metrics.captionSize))
                            .foregroundColor(.inkGreen.opacity(0.9))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: formDayBannerExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: metrics.scaledSize(9), weight: .medium))
                            .foregroundColor(.inkGreen.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)

                if formDayBannerExpanded,
                   let title = DistributionCalendar.formCoachingDayExpandedTitle,
                   let body = DistributionCalendar.formCoachingDayExpandedBody {
                    VStack(alignment: .leading, spacing: 4) {
                        MonoLabel(text: title, color: .inkGreen, size: 9)
                        Text(body)
                            .font(.sora(metrics.captionSize))
                            .foregroundColor(.textSecond)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.leading, 13)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Monday block

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
                // Header
                VStack(alignment: .leading, spacing: metrics.scaledSize(4)) {
                    MonoLabel(text: "MONDAY BLOCK", color: .warm, size: 10)
                    Text("Before Hideout opens · 60–90 min")
                        .font(.sora(metrics.bodySize))
                        .foregroundColor(.textSecond)
                    HStack(spacing: 5) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: metrics.scaledSize(9)))
                            .foregroundColor(.inkAmber)
                        Text("Film before unlocking · empty terrace")
                            .font(.mono(metrics.monoSmall))
                            .foregroundColor(.inkAmber)
                    }
                }

                sectionDivider

                // Hideout steps
                MonoLabel(text: "HIDEOUT", color: .textMuted, size: 9)
                    .padding(.bottom, -4)

                mondayStepWithDrawer(week: week, index: 0,
                    label: "Film — 7-shot sequence, empty terrace",
                    done: week.hideoutFilmed) {
                    week.hideoutFilmed = true
                } drawer: { shotListDrawer }

                mondayStepWithDrawer(week: week, index: 1,
                    label: "Edit — assembly only, ≤30 sec",
                    done: week.hideoutEdited, enabled: week.hideoutFilmed) {
                    week.hideoutEdited = true
                } drawer: { editDoctrineDrawer }

                mondayStep(week: week, index: 2,
                    label: "Post — Google Business Profile",
                    done: week.hideoutPostedGBP, enabled: week.hideoutEdited) {
                    week.hideoutPostedGBP = true
                }

                mondayStep(week: week, index: 3,
                    label: "Post — Instagram Reels",
                    done: week.hideoutPostedReels, enabled: week.hideoutPostedGBP) {
                    week.hideoutPostedReels = true
                }

                mondayStep(week: week, index: 4,
                    label: "Post — TikTok · post and leave",
                    done: week.hideoutPostedTikTok, enabled: week.hideoutPostedReels) {
                    week.hideoutPostedTikTok = true
                }

                if !forgeGateCleared {
                    Text("Forge distribution unlocks after v1 gate.")
                        .font(.sora(metrics.captionSize))
                        .foregroundColor(.textMuted)
                        .padding(.top, 2)
                }

                if week.hideoutPostedTikTok || week.hideoutStepsComplete {
                    sectionDivider
                    appContentSection(week: week)
                }

                if canCompleteMonday(week: week) {
                    Button(action: { completeMondayBlock(week: week) }) {
                        Text("COMPLETE BLOCK")
                            .font(.sora(metrics.bodySize, weight: .semibold))
                            .tracking(0.5)
                            .foregroundColor(.bgBase)
                            .frame(maxWidth: .infinity)
                            .frame(height: metrics.touchTarget * 0.85)
                            .background(Color.inkGreen)
                            .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius - 2))
                    }
                    .padding(.top, 6)
                }
            }
        }
    }

    @ViewBuilder
    private func appContentSection(week: DistributionWeek) -> some View {
        let venture = week.appContentVenture
        VStack(alignment: .leading, spacing: metrics.blockSpacing) {
            MonoLabel(text: "\(venture.label) THIS WEEK", color: .violetLight, size: 9)
                .padding(.bottom, -4)

            if venture == .form, let seed = recentFormLedgerSeedLine {
                Text(seed)
                    .font(.mono(metrics.monoSmall))
                    .foregroundColor(.inkGreen.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }

            mondayStepWithDrawer(week: week, index: 5,
                label: "Confirm decision sentence",
                done: !week.appContentDecision.isEmpty,
                enabled: week.hideoutPostedTikTok) {
                if decisionDraft.isEmpty, let pull = latestUnusedLedger(for: venture) {
                    week.appContentDecision = pull.fragment
                    decisionDraft = pull.fragment
                    markLedgerUsed(pull, weekStart: week.weekStartDate)
                } else if !decisionDraft.isEmpty {
                    week.appContentDecision = decisionDraft
                }
            } drawer: { contentPrimitiveDrawer }

            if week.hideoutPostedTikTok {
                TextField("Decision sentence", text: $decisionDraft, axis: .vertical)
                    .font(.sora(metrics.bodySize))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2...4)
                    .padding(12)
                    .background(Color.bgBase.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.violetLight.opacity(0.15), lineWidth: 0.5)
                    )
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

            mondayStep(week: week, index: 6,
                label: "Record — system state · single take",
                done: week.appContentRecorded,
                enabled: !week.appContentDecision.isEmpty) {
                week.appContentRecorded = true
            }

            mondayStepWithDrawer(week: week, index: 7,
                label: "Post",
                done: week.appContentPosted,
                enabled: week.appContentRecorded) {
                week.appContentPosted = true
            } drawer: { captionDoctrineDrawer }
        }
    }

    // MARK: - Step rows

    private func mondayStep(
        week: DistributionWeek,
        index: Int,
        label: String,
        done: Bool,
        enabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        mondayStepWithDrawer(week: week, index: index, label: label,
            done: done, enabled: enabled, action: action) { EmptyView() }
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
        let checkSize = metrics.scaledSize(17)
        return VStack(alignment: .leading, spacing: 5) {
            Button(action: {
                guard canTap else { return }
                action()
                save()
            }) {
                HStack(alignment: .top, spacing: metrics.scaledSize(10)) {
                    // Refined checkbox — consistent size, aligned to cap height
                    Image(systemName: done ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: checkSize, height: checkSize)
                        .foregroundColor(
                            done ? .inkGreen
                            : enabled ? .textMuted
                            : .textMuted.opacity(0.3)
                        )
                        .padding(.top, metrics.scaledSize(1))

                    Text(label)
                        .font(.sora(metrics.bodySize))
                        .foregroundColor(
                            done ? .textMuted
                            : enabled ? .textPrimary
                            : .textMuted.opacity(0.5)
                        )
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .disabled(!canTap && !done)

            drawer()
        }
    }

    private func mondayCompleteStamp(week: DistributionWeek) -> some View {
        CardView(style: .secondary) {
            HStack(spacing: metrics.scaledSize(10)) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.inkGreen)
                    .font(.system(size: metrics.scaledSize(16)))
                VStack(alignment: .leading, spacing: 3) {
                    MonoLabel(text: "MONDAY BLOCK COMPLETE", color: .inkGreen, size: 9)
                    Text(week.mondayStampLine)
                        .font(.mono(metrics.bodySize))
                        .foregroundColor(.textSecond)
                }
                Spacer()
            }
        }
    }

    private func mondayMissedOrUpcoming(week: DistributionWeek) -> some View {
        let cal = Calendar.current
        let nextMonday = cal.date(byAdding: .day,
            value: (9 - cal.component(.weekday, from: Date())) % 7,
            to: weekStart) ?? weekStart
        let missed = !week.mondayBlockCompleted
            && !DistributionCalendar.isMonday
            && Date() > (cal.date(byAdding: .day, value: 1, to: weekStart) ?? weekStart)

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

    // MARK: - Decision ledger

    @ViewBuilder
    private var decisionLedgerSection: some View {
        if !DistributionCalendar.isMonday {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    MonoLabel(text: "DECISION LEDGER", color: .violetLight, size: 10)

                    // Input row
                    HStack(spacing: 8) {
                        Picker("", selection: $ledgerVenture) {
                            ForEach(AppContentVenture.allCases, id: \.self) { v in
                                Text(v.label).tag(v)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.violetLight)
                        .labelsHidden()

                        TextField("One sentence", text: $ledgerFragment)
                            .font(.sora(metrics.bodySize))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.bgBase.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.violetLight.opacity(0.12), lineWidth: 0.5)
                            )

                        Button(action: addLedgerEntry) {
                            Text("ADD")
                                .font(.mono(metrics.monoSmall, weight: .medium))
                                .foregroundColor(.inkGreen)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(Color.inkGreen.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                        .disabled(ledgerFragment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    // Entries
                    if !ledgerEntries.isEmpty {
                        VStack(alignment: .leading, spacing: metrics.scaledSize(10)) {
                            ForEach(ledgerEntries.prefix(12)) { entry in
                                HStack(alignment: .top, spacing: 8) {
                                    Rectangle()
                                        .fill(entry.isUsed ? Color.textMuted.opacity(0.2) : Color.violetLight.opacity(0.5))
                                        .frame(width: 1.5)
                                        .padding(.top, 3)
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
                        .padding(.top, 2)
                    }
                }
            }
        }
    }

    // MARK: - Signal log

    private var signalLogSection: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                HStack {
                    MonoLabel(text: "SIGNAL LOG", color: .inkGreen, size: 10)
                    Spacer()
                    if let week = currentWeek, !week.fridayLogCompleted {
                        Button(action: { showFridaySheet = true }) {
                            HStack(spacing: 4) {
                                Text("LOG FRIDAY")
                                    .font(.mono(metrics.monoSmall))
                                    .foregroundColor(.inkGreen)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: metrics.scaledSize(8), weight: .semibold))
                                    .foregroundColor(.inkGreen.opacity(0.7))
                            }
                        }
                    }
                }

                if let week = currentWeek {
                    if week.fridayLogCompleted {
                        fridaySummary(week: week)
                        if let line = diagnosticLine(for: week) {
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: metrics.scaledSize(10)))
                                    .foregroundColor(.inkAmber)
                                    .padding(.top, 1)
                                Text(line)
                                    .font(.sora(metrics.captionSize))
                                    .foregroundColor(.inkAmber)
                            }
                            .padding(.top, 4)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 5) {
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
        }
        .sheet(isPresented: $showFridaySheet) {
            if let week = currentWeek {
                SignalFridayLogSheet(week: week,
                    forgeGateDefault: forgeGateCleared,
                    isPresented: $showFridaySheet)
            }
        }
    }

    private func fridaySummary(week: DistributionWeek) -> some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(7)) {
            Text(week.weekLabel + (week.fridayLogCompletedAt.map {
                " · \($0.formatted(date: .omitted, time: .shortened))" } ?? ""))
                .font(.mono(metrics.monoSmall))
                .foregroundColor(.textMuted)

            VStack(spacing: metrics.scaledSize(6)) {
                signalRow("Board attributions",   "\(week.hideoutBoardAttributions)")
                signalRow("Watermarc",            "\(week.hideoutWatermarcRedemptions)")
                signalRow("Source mentions",      "\(week.hideoutSourceMentions)")
                signalRow("GBP attributions",     "\(week.hideoutGBPAttributions)")
                Rectangle()
                    .fill(Color.muted.opacity(0.2))
                    .frame(height: 0.5)
                signalRow("FORM outside",         week.formOutsideEngagement ? "Yes" : "No")
                signalRow("Forge gate",           week.forgeV1GatePassed ? "Passed" : "—")
            }

            if !week.oneAdjustment.isEmpty {
                Text(week.oneAdjustment)
                    .font(.sora(metrics.bodySize))
                    .foregroundColor(.textPrimary)
                    .padding(.top, 2)
            }
        }
    }

    private func signalRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.sora(metrics.captionSize))
                .foregroundColor(.textSecond)
            Spacer()
            Text(value)
                .font(.mono(metrics.captionSize))
                .foregroundColor(.textPrimary)
        }
    }

    // MARK: - Log history

    private var logHistorySection: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                if showEightWeekPrompt {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.inkGreen)
                            .frame(width: 5, height: 5)
                        Text("8 weeks of logs. Worth a full read.")
                            .font(.sora(metrics.captionSize))
                            .foregroundColor(.inkGreen)
                    }
                }

                MonoLabel(text: "LOG HISTORY", color: .textMuted, size: 10)

                if weeks.isEmpty {
                    Text("No weeks logged yet.")
                        .font(.sora(metrics.captionSize))
                        .foregroundColor(.textMuted)
                } else {
                    VStack(spacing: metrics.scaledSize(8)) {
                        ForEach(weeks.prefix(16)) { week in
                            HStack(spacing: 0) {
                                Text(week.weekLabel)
                                    .font(.mono(metrics.captionSize))
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                signalPip(filled: week.mondayBlockCompleted, label: "Block")
                                signalPip(filled: week.fridayLogCompleted, label: "Log")
                                    .padding(.leading, metrics.scaledSize(12))
                            }
                        }
                    }
                }
            }
        }
    }

    private func signalPip(filled: Bool, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(filled ? Color.inkGreen : Color.textMuted.opacity(0.25))
                .frame(width: metrics.scaledSize(6), height: metrics.scaledSize(6))
            Text(label)
                .font(.mono(metrics.monoSmall))
                .foregroundColor(filled ? .textSecond : .textMuted.opacity(0.5))
        }
    }

    // MARK: - Drawers

    private var shotListDrawer: some View {
        doctrineDrawer(id: "shots", title: "7-SHOT SEQUENCE") {
            VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                Text("Empty terrace · morning light · natural audio on espresso only. Solo-executable. No substitutions.")
                    .font(.sora(metrics.captionSize))
                    .foregroundColor(.textMuted)
                VStack(alignment: .leading, spacing: 3) {
                    shotPosition("1", "Wide — empty room, door light")
                    shotPosition("2", "Bar — grinder, hands, no face required")
                    shotPosition("3", "Espresso pull — natural sound only")
                    shotPosition("4", "Cup on bar — still life")
                    shotPosition("5", "Patio pillar — column board readable")
                    shotPosition("6", "Street sign or entrance — context")
                    shotPosition("7", "Wide out — lock door, leave")
                }
            }
        }
    }

    private func shotPosition(_ n: String, _ note: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(n)
                .font(.mono(metrics.monoSmall))
                .foregroundColor(.warm.opacity(0.8))
                .frame(width: metrics.scaledSize(14), alignment: .leading)
            Text(note)
                .font(.mono(metrics.monoSmall))
                .foregroundColor(.textSecond)
        }
    }

    private var editDoctrineDrawer: some View {
        doctrineDrawer(id: "edit", title: "ASSEMBLY RULES") {
            Text("7 clips · linear · no transitions · natural sound · first frame = cover. Assembly, not editing.")
                .font(.sora(metrics.captionSize))
                .foregroundColor(.textMuted)
        }
    }

    private var contentPrimitiveDrawer: some View {
        doctrineDrawer(id: "primitive", title: "CONTENT PRIMITIVE") {
            VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                Text("One decision · one outcome · one sentence. Outsider-legible.")
                    .font(.sora(metrics.captionSize))
                    .foregroundColor(.textMuted)

                if ledgerEntries.count >= 3 {
                    MonoLabel(text: "YOUR RECENT LINES", color: .inkGreen, size: 9)
                    ForEach(ledgerEntries.prefix(3)) { entry in
                        Text("“\(entry.fragment)”")
                            .font(.mono(metrics.monoSmall))
                            .foregroundColor(.textSecond)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    MonoLabel(text: "EXAMPLES", color: .textMuted, size: 9)
                    ForEach(DistributionCalendar.formLedgerExampleLines(fallbackCount: 3), id: \.self) { line in
                        Text("“\(line)”")
                            .font(.mono(metrics.monoSmall))
                            .foregroundColor(.textSecond)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var captionDoctrineDrawer: some View {
        doctrineDrawer(id: "caption", title: "CAPTION RULES") {
            Text("GBP: factual, one sentence. Reels/TikTok: one-line observation · saved preset · no invention at post time.")
                .font(.sora(metrics.captionSize))
                .foregroundColor(.textMuted)
        }
    }

    private func doctrineDrawer<Content: View>(
        id: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { withAnimation(.easeOut(duration: 0.15)) {
                expandedDrawer = expandedDrawer == id ? nil : id
            }}) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.mono(metrics.monoSmall))
                        .foregroundColor(.textMuted)
                    Image(systemName: expandedDrawer == id ? "chevron.up" : "chevron.down")
                        .font(.system(size: metrics.scaledSize(8), weight: .medium))
                        .foregroundColor(.textMuted.opacity(0.6))
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if expandedDrawer == id {
                content()
                    .padding(.top, 2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.leading, metrics.scaledSize(27))
    }

    // MARK: - Shared

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.muted.opacity(0.2))
            .frame(height: 0.5)
            .padding(.vertical, metrics.scaledSize(2))
    }

    // MARK: - Logic

    private func ensureCurrentWeek() {
        let start = weekStart
        if let existing = weeks.first(where: {
            Calendar.current.isDate($0.weekStartDate, inSameDayAs: start)
        }) {
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

    /// Most recent unused FORM ledger line — surfaces Tuesday/Saturday seed before Monday step 6.
    private var recentFormLedgerSeedLine: String? {
        guard let entry = ledgerEntries.first(where: { $0.venture == .form && !$0.isUsed }) else { return nil }
        return "Seed from ledger · \(entry.dateLabel): “\(entry.fragment)”"
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
        let recent = weeks.prefix(6)
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

                    VStack(alignment: .leading, spacing: metrics.scaledSize(4)) {
                        MonoLabel(text: "SIGNAL LOG", color: .inkGreen, size: 11)
                        Text(week.weekLabel)
                            .font(.sora(metrics.titleSize, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }

                    // Hideout signals
                    VStack(spacing: 0) {
                        MonoLabel(text: "HIDEOUT", color: .textMuted, size: 9)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, metrics.scaledSize(10))
                        stepperRow("Board attributions", value: $week.hideoutBoardAttributions)
                        sheetDivider
                        stepperRow("Watermarc redemptions", value: $week.hideoutWatermarcRedemptions)
                        sheetDivider
                        stepperRow("Source mentions", value: $week.hideoutSourceMentions)
                        sheetDivider
                        stepperRow("GBP attributions", value: $week.hideoutGBPAttributions)
                    }
                    .padding(metrics.cardPad)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius))

                    // Toggles
                    VStack(spacing: 0) {
                        Toggle("FORM outside-network engagement", isOn: $week.formOutsideEngagement)
                            .font(.sora(metrics.bodySize))
                            .tint(.inkGreen)
                            .padding(.bottom, metrics.scaledSize(12))
                        sheetDivider
                        Toggle("Forge v1 gate passed", isOn: $week.forgeV1GatePassed)
                            .font(.sora(metrics.bodySize))
                            .tint(.inkGreen)
                            .padding(.top, metrics.scaledSize(12))
                            .onAppear { week.forgeV1GatePassed = forgeGateDefault }
                    }
                    .padding(metrics.cardPad)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius))

                    // Adjustment
                    VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
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
                            .tracking(0.5)
                            .foregroundColor(.bgBase)
                            .frame(maxWidth: .infinity)
                            .frame(height: metrics.touchTarget)
                            .background(Color.inkGreen)
                            .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private var sheetDivider: some View {
        Rectangle()
            .fill(Color.muted.opacity(0.2))
            .frame(height: 0.5)
    }

    private func stepperRow(_ label: String, value: Binding<Int>) -> some View {
        HStack {
            Text(label)
                .font(.sora(metrics.bodySize))
                .foregroundColor(.textPrimary)
            Spacer()
            HStack(spacing: metrics.scaledSize(14)) {
                Button(action: { value.wrappedValue = max(0, value.wrappedValue - 1) }) {
                    Image(systemName: "minus")
                        .font(.system(size: metrics.scaledSize(13), weight: .medium))
                        .foregroundColor(.textSecond)
                        .frame(width: metrics.scaledSize(28), height: metrics.scaledSize(28))
                        .background(Color.surface2)
                        .clipShape(Circle())
                }

                Text("\(value.wrappedValue)")
                    .font(.mono(metrics.headlineSize, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(minWidth: metrics.scaledSize(24))
                    .monospacedDigit()

                Button(action: { value.wrappedValue += 1 }) {
                    Image(systemName: "plus")
                        .font(.system(size: metrics.scaledSize(13), weight: .medium))
                        .foregroundColor(.inkGreen)
                        .frame(width: metrics.scaledSize(28), height: metrics.scaledSize(28))
                        .background(Color.inkGreen.opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, metrics.scaledSize(10))
    }

    private func save() {
        week.oneAdjustment = adjustment.trimmingCharacters(in: .whitespacesAndNewlines)
        week.fridayLogCompleted = true
        week.fridayLogCompletedAt = Date()
        try? context.save()
        isPresented = false
    }
}
