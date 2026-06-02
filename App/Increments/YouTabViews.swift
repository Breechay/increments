import SwiftUI
import SwiftData

// MARK: - YOU TAB — reimagined May 2026
// Previous: Capital · Brief · Dossier · Lab · Manual · Settings
// Now:      Capital · Brief · Doctrine · Want · Ventures · Intel · Manual · Settings
//
// Lab removed — content not consumed, elaborate infrastructure for unused behavior.
// Dossier stripped to Intel — live observed traits + failure modes only.
//   Agent-facing scaffolding removed; what remains is self-applicable.
// Ventures added — highest-value missing surface. Current state of each venture,
//   distribution approach, what's planted. The thing that evolves and stays relevant.
// Field Manual expanded — distribution principles added alongside existing operator principles.
// Reading mode: iPad evening primary. Prose, not bullets. Arm's-distance legibility.

// MARK: - You tab ambient (extra depth on AtmosphericBackground)

struct YouTabAmbience: View {
    @State private var phase = false

    var body: some View {
        ZStack {
            AtmosphericBackground()
            RadialGradient(
                colors: [Color.violetDim.opacity(0.06), Color.clear],
                center: UnitPoint(x: phase ? 0.15 : 0.85, y: 0.2),
                startRadius: 0,
                endRadius: 320
            )
            RadialGradient(
                colors: [Color.violetDim.opacity(0.05), Color.clear],
                center: UnitPoint(x: phase ? 0.85 : 0.15, y: 0.75),
                startRadius: 0,
                endRadius: 280
            )
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: phase)
        }
        .onAppear { phase = true }
        .ignoresSafeArea()
    }
}

// MARK: - YouView root

struct YouView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var cloudKitMonitor: CloudKitSyncMonitor
    @Query private var profiles: [OperatorProfile]
    @Query private var actions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Bindable var state: AppState
    @State private var selectedSeg = 0
    @State private var showSettings = false
    @AppStorage("you_ipad_reading_focus") private var youReadingFocus = false
    @Environment(\.appMetrics) private var metrics

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    private var iPadRightColumnTitle: String {
        switch selectedSeg {
        case 0: return "Brief"
        case 1: return "Doctrine"
        case 2: return "Want"
        case 3: return "Ventures"
        case 4: return "Intel"
        case 5: return "Manual"
        default: return "You"
        }
    }

    var body: some View {
        ZStack {
            YouTabAmbience()
            VStack(spacing: 0) {
                GlanceTabHeader(kicker: "INCREMENTS", title: profile.firstName.isEmpty ? "You" : profile.firstName, kickerColor: .violetLight) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.textMuted)
                            .font(.system(size: metrics.scaledSize(18), weight: .light))
                    }
                }

                if let line = cloudKitMonitor.health.userLine {
                    CloudSyncStatusBanner(message: line)
                        .padding(.horizontal, metrics.hPad)
                        .padding(.bottom, metrics.cardSpacing)
                }

                if metrics.isIPad {
                    if youReadingFocus {
                        GeometryReader { _ in
                            youIPadRightPane
                                .environment(\.youIPadReadingFocus, true)
                        }
                    } else {
                        IPadMasterDetailLayout(metrics: metrics, leftFraction: metrics.masterDetailLeftFraction) {
                            ScrollView(showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionHeader(text: "CAPITAL · RESOURCE", color: .warm)
                                        .padding(.horizontal, metrics.hPad)
                                        .padding(.bottom, metrics.scaledSize(8))
                                    CapitalTabView()
                                }
                                .padding(.top, metrics.screenTopPadding)
                            }
                        } right: {
                            youIPadRightPane
                                .environment(\.youIPadReadingFocus, false)
                        }
                    }
                } else {
                    segmentControl(["Capital", "Brief", "Doctrine", "Want", "Ventures", "Intel", "Manual"], selected: $selectedSeg)
                        .padding(.horizontal, metrics.hPad)
                        .padding(.bottom, metrics.sectionGap)
                    ScrollView(showsIndicators: false) {
                        switch selectedSeg {
                        case 0: CapitalTabView()
                        case 1: BriefTabView(state: state, profile: profile)
                        case 2: YouDoctrineTabView()
                        case 3: WantDocTabView()
                        case 4: VenturesTabView()
                        case 5: IntelTabView(profile: profile)
                        case 6: YouFieldManualView()
                        default: EmptyView()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsTabView(profile: profile, state: state)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.bgBase)
        }
    }

    // MARK: iPad right pane (Brief · Doctrine · Ventures · Intel · Manual)

    private var youIPadRightPane: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: metrics.scaledSize(10)) {
                VStack(alignment: .leading, spacing: metrics.scaledSize(3)) {
                    MonoLabel(text: "YOU", color: .violetLight, size: 9)
                    Text(iPadRightColumnTitle)
                        .font(.sora(metrics.youReadHeadlineSize, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .animation(.easeOut(duration: 0.2), value: selectedSeg)
                }
                Spacer()
                Button(action: {
                    withAnimation(.easeOut(duration: 0.22)) { youReadingFocus.toggle() }
                }) {
                    Image(systemName: youReadingFocus ? "sidebar.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: metrics.scaledSize(14), weight: .light))
                        .foregroundColor(youReadingFocus ? .violetLight : .textMuted)
                        .frame(width: metrics.scaledSize(36), height: metrics.scaledSize(36))
                        .background(Color.surface2)
                        .clipShape(Circle())
                }
                .accessibilityLabel(youReadingFocus ? "Show Capital" : "Expand reading")
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: metrics.scaledSize(15), weight: .light))
                        .foregroundColor(.textMuted)
                        .frame(width: metrics.scaledSize(34), height: metrics.scaledSize(34))
                        .background(Color.surface2)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, metrics.hPad)
            .padding(.top, metrics.screenTopPadding)
            .padding(.bottom, metrics.scaledSize(8))

            segmentControl(["Brief", "Doctrine", "Want", "Ventures", "Intel", "Manual"], selected: $selectedSeg)
                .padding(.horizontal, metrics.hPad)
                .padding(.bottom, metrics.scaledSize(14))

            ScrollView(showsIndicators: false) {
                Group {
                    switch selectedSeg {
                    case 0: BriefTabView(state: state, profile: profile)
                    case 1: YouDoctrineTabView()
                    case 2: WantDocTabView()
                    case 3: VenturesTabView()
                    case 4: IntelTabView(profile: profile)
                    case 5: YouFieldManualView()
                    default: EmptyView()
                    }
                }
                .youReadingContentWidth(metrics, focus: youReadingFocus)
            }
        }
    }
}

// MARK: - VENTURES TAB
// Current state of each active venture — what it is, what distribution looks like,
// what seeds are planted, what signal is being read.
// This is the content that evolves. Read it, watch it change.

struct VenturesTabView: View {
    @Environment(\.appMetrics) private var metrics
    @AppStorage("forge_v1_gate_passed") private var forgeGateCleared = true
    @Query(sort: \DistributionWeek.weekStartDate, order: .reverse) private var weeks: [DistributionWeek]

    @State private var expandedVentures: Set<String> = []

    var body: some View {
        VStack(spacing: metrics.blockSpacing) {
            ventureCard(
                id: "hideout",
                kicker: "HIDEOUT MIAMI",
                kickerColor: .warm,
                status: "Active · Solo experiment",
                headline: "Neighborhood infrastructure. Edgewater. Six years. The house Brice stewards.",
                body: "Hideout is a 4.7-star outdoor terrace on the Edgewater corridor. The product is conditions — food and coffee are infrastructure, not the point. Regulars, open air, six years of reputation. The current constraint is threshold conversion and residential memory encoding: people who find it love it. The bottleneck is find.\n\nThe solo experiment runs Hideout without staff to test operational floor, revenue stability, and what the house produces at minimum. The stability target is $590/day average.\n\nHideout App (separate build): customer relationship capture — repeat orders, Sunday lineup, private events, B2B gallons. INCREMENTS Hideout tab tracks this solo experiment; the app holds demand the floor cannot keep in memory.",
                distributionSection: hideoutDistribution,
                signalSummary: hideoutSignalSummary
            )

            ventureCard(
                id: "form",
                kicker: "FORM",
                kickerColor: .inkGreen,
                status: "Active · ~5 users · Off-season",
                headline: "Running intelligence. Not a training log — a system that thinks.",
                body: "FORM structures athlete training through programs with real periodization. Each athlete runs their own Today on their own phone — different rep structures, different session types, different program logic. The intelligence is in the sequencing and the ledger: what you logged shapes what comes next.\n\nGhost Protocol is a 6-week run-form curriculum — mechanics, metronome, sessions S01–S36 — that runs alongside a program. It is not a live pace adjuster. The system does not auto-modify sessions in real time. It sequences, routes, and receives logged data.\n\nCurrent athletes: Simon (Speed Emergence), Julien (Hyrox Running). The operator coaches threshold Tuesdays and long run Saturdays — these are the primary content surfaces while he is injured and not running personally.",
                distributionSection: formDistribution,
                signalSummary: formSignalSummary
            )

            ventureCard(
                id: "forge",
                kicker: "FORGE",
                kickerColor: .violetLight,
                status: forgeGateCleared ? "Active · Beta · Gate cleared" : "Beta · Gate pending",
                headline: "Strength execution. The session lives in the app, not in your head.",
                body: forgeGateCleared
                    ? "Forge removes cognitive load from strength training. The plan anchor knows where you are. The session starts in under five seconds. Draft restores after a force-close. The rest timer fires correctly whether the screen is locked, another app is open, or a call came in mid-set.\n\nThe v1 acceptance gate has cleared: five weeks across three athletes with zero moments requiring a workaround. Tim, Tinius, and Cole completed the real-use standard.\n\nDistribution is now allowed. The content approach is the same as FORM — product truth only, one real decision or execution observation per week, no performance, no tutorials."
                    : "Forge removes cognitive load from strength training. The plan anchor knows where you are. The session starts in under five seconds. Draft restores after a force-close. The rest timer fires correctly whether the screen is locked, another app is open, or a call came in mid-set.\n\nThe v1 acceptance gate is still pending. Distribution stays paused until real-use confirms five weeks across three athletes with zero moments requiring a workaround.\n\nUntil then, Forge is not a content surface. It remains a product-readiness surface.",
                distributionSection: forgeDistribution,
                signalSummary: forgeSignalSummary
            )
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.bottom, 80)
        .onAppear {
            if expandedVentures.isEmpty {
                expandedVentures = metrics.isIPad
                    ? ["hideout", "form", "forge"]
                    : ["hideout"]
            }
        }
    }

    private func ventureCard(
        id: String,
        kicker: String,
        kickerColor: Color,
        status: String,
        headline: String,
        body: String,
        distributionSection: some View,
        signalSummary: some View
    ) -> some View {
        let isExpanded = expandedVentures.contains(id)

        return CardView(style: isExpanded ? .primary : .secondary) {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                        if isExpanded {
                            expandedVentures.remove(id)
                        } else {
                            expandedVentures.insert(id)
                        }
                    }
                }) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: metrics.scaledSize(5)) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(kickerColor)
                                    .frame(width: metrics.scaledSize(6), height: metrics.scaledSize(6))
                                    .shadow(color: kickerColor.opacity(0.6), radius: 4)
                                MonoLabel(text: kicker, color: kickerColor, size: 10)
                            }
                            Text(headline)
                                .font(.sora(metrics.bodySize, weight: .semibold))
                                .foregroundColor(isExpanded ? .textPrimary : .textSecond)
                                .multilineTextAlignment(.leading)
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(kickerColor.opacity(0.5))
                                    .frame(width: metrics.scaledSize(4), height: metrics.scaledSize(4))
                                Text(status)
                                    .font(.mono(metrics.monoSmall))
                                    .foregroundColor(.textMuted)
                            }
                        }
                        Spacer(minLength: 12)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: metrics.scaledSize(11), weight: .medium))
                            .foregroundColor(kickerColor.opacity(isExpanded ? 0.7 : 0.3))
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(alignment: .leading, spacing: metrics.sectionGap) {
                        Rectangle()
                            .fill(kickerColor.opacity(0.15))
                            .frame(height: 0.5)
                            .padding(.top, metrics.scaledSize(14))

                        VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                            ForEach(Array(body.components(separatedBy: "\n\n").filter { !$0.isEmpty }.enumerated()), id: \.offset) { _, paragraph in
                                DoctrineProseBlock(text: paragraph, accent: kickerColor)
                            }
                        }

                        distributionSection

                        Rectangle()
                            .fill(kickerColor.opacity(0.15))
                            .frame(height: 0.5)

                        signalSummary
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .overlay(alignment: .leading) {
            if !isExpanded {
                Rectangle()
                    .fill(kickerColor.opacity(0.4))
                    .frame(width: 2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: metrics.cardRadius)
                .strokeBorder(
                    isExpanded ? kickerColor.opacity(0.18) : Color.muted.opacity(0.08),
                    lineWidth: 0.5
                )
        )
    }

    // MARK: Hideout distribution

    @ViewBuilder
    private var hideoutDistribution: some View {
        VStack(alignment: .leading, spacing: metrics.blockSpacing) {
            MonoLabel(text: "NIGHT READ · DISTRIBUTION", color: .warm, size: 9)

            ventureProseBlock(
                "Current job: convert nearby awareness into first visits, then first visits into clean recurring pickups. Boards, GBP, cards, and warm partnerships all serve that mechanism.",
                color: .warm
            )

            ventureProseBlock(
                "The solo experiment is also a floor test: what Hideout can produce without staff, and what that production costs from the same nervous-system pool used for coaching, building, and thinking.",
                color: .warm
            )

            ventureProseBlock(
                "Execution stays simple: Monday block before open. Friday signal log after close. Full economics and signal doctrine live in You → Doctrine → Hideout.",
                color: .warm
            )

            ventureProseBlock(
                "Hideout App · customer surface (Documents/HideoutApp): reorder, Sunday, event requests, B2B gallons — relationship compression, not ordering theater. Pre-Square on device. Admin: lineup, events queue, catering. This tab = experiment ops; the app = captured demand.",
                color: .warm
            )
        }
    }

    @ViewBuilder
    private var hideoutSignalSummary: some View {
        if let week = weeks.first, week.fridayLogCompleted {
            VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
                MonoLabel(text: "LAST SIGNAL LOG", color: .textMuted, size: 9)
                HStack(spacing: metrics.scaledSize(20)) {
                    signalMiniRow("Board", "\(week.hideoutBoardAttributions)", .warm)
                    signalMiniRow("Watermarc", "\(week.hideoutWatermarcRedemptions)", .warm)
                    signalMiniRow("Source", "\(week.hideoutSourceMentions)", .warm)
                    signalMiniRow("GBP", "\(week.hideoutGBPAttributions)", .warm)
                }
            }
            .padding(12)
            .background(Color.bgBase.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.warm.opacity(0.1), lineWidth: 0.5))
        }
    }

    // MARK: FORM distribution

    @ViewBuilder
    private var formDistribution: some View {
        VStack(alignment: .leading, spacing: metrics.blockSpacing) {
            MonoLabel(text: "NIGHT READ · DISTRIBUTION", color: .inkGreen, size: 9)

            ventureProseBlock(
                "Current job: show product truth while the operator is injured. Tuesday threshold and Saturday long run are the live surfaces; Simon and Julien provide two programs, two phones, one coaching context.",
                color: .inkGreen
            )

            ventureProseBlock(
                "FORM content should show what the app actually routes: one screen, one decision, one sentence. Not tutorials. Not claims. Not a fake coach dashboard.",
                color: .inkGreen
            )

            ventureProseBlock(
                "Ghost Protocol and per-athlete sequencing belong in the full Doctrine read. Ventures should stay current-state and execution-facing.",
                color: .inkGreen
            )
        }
    }

    @ViewBuilder
    private var formSignalSummary: some View {
        if let week = weeks.first, week.fridayLogCompleted {
            VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                MonoLabel(text: "LAST SIGNAL LOG", color: .textMuted, size: 9)
                HStack(spacing: 6) {
                    Circle()
                        .fill(week.formOutsideEngagement ? Color.inkGreen : Color.textMuted.opacity(0.3))
                        .frame(width: metrics.scaledSize(7), height: metrics.scaledSize(7))
                    Text(week.formOutsideEngagement ? "Outside-network engagement logged" : "No outside-network engagement yet")
                        .font(.sora(metrics.captionSize, weight: .light))
                        .foregroundColor(week.formOutsideEngagement ? .inkGreen : .textMuted)
                }
            }
            .padding(12)
            .background(Color.bgBase.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.inkGreen.opacity(0.1), lineWidth: 0.5))
        }
    }

    // MARK: Forge distribution

    @ViewBuilder
    private var forgeDistribution: some View {
        VStack(alignment: .leading, spacing: metrics.blockSpacing) {
            MonoLabel(text: "DISTRIBUTION", color: .violetLight, size: 9)

            if forgeGateCleared {
                ventureProseBlock(
                    "Gate cleared. Distribution is active. Content alternates with FORM in the Monday block — three consecutive Forge weeks post-gate, then rotation resumes. Same content primitive as FORM: one real decision from a real session, one outcome, one sentence of context.",
                    color: .violetLight
                )

                ventureProseBlock(
                    "Forge content is execution observation, not instruction. The wait timer fired before the set was ready. The draft restored to the correct position after a force-close. The plan anchor advanced. These are product truths — things the app did that another app wouldn't have done correctly.",
                    color: .violetLight
                )
            } else {
                ventureProseBlock(
                    "Distribution is paused. The v1 acceptance gate has not yet cleared. Gate conditions: session start under 5 seconds, draft restore after force-close, plan anchor advances correctly, zero motivational copy, interruption recovery, zero dead-ends, timer correctness under stress, full-week real-use integrity. Gate clears when all nine pass.",
                    color: .violetLight
                )
            }
        }
    }

    @ViewBuilder
    private var forgeSignalSummary: some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
            MonoLabel(text: "GATE STATUS", color: .textMuted, size: 9)
            HStack(spacing: 6) {
                Circle()
                    .fill(forgeGateCleared ? Color.inkGreen : Color.inkAmber)
                    .frame(width: metrics.scaledSize(7), height: metrics.scaledSize(7))
                Text(forgeGateCleared
                    ? "v1 gate cleared · 5 weeks, 3 athletes"
                    : "Gate pending · distribution paused")
                    .font(.sora(metrics.captionSize, weight: .light))
                    .foregroundColor(forgeGateCleared ? .inkGreen : .inkAmber)
            }
        }
        .padding(12)
        .background(Color.bgBase.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.violetLight.opacity(0.1), lineWidth: 0.5))
    }

    // MARK: Helpers

    private func ventureProseBlock(_ text: String, color: Color) -> some View {
        DoctrineProseBlock(text: text, accent: color)
    }

    private func signalMiniRow(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.mono(metrics.bodySize, weight: .semibold))
                .foregroundColor(.textPrimary)
            Text(label)
                .font(.mono(metrics.monoSmall))
                .foregroundColor(.textMuted)
        }
    }
}

// MARK: - Operator season (Intel · quick read; full in Doctrine → Operator)

struct OperatorSeasonIntelCard: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                MonoLabel(text: "OPERATOR · THIS SEASON", color: .violetLight, size: 10)

                intelProse(
                    "Running is suspended. FORM content now comes through coaching, pacing, and the intelligence layer: Tuesday threshold, Saturday long run, Sony, one ledger sentence."
                )

                intelProse(
                    "Key diagnostic: Reserve is internal capacity. Compressed is external window. Do not treat one as the other."
                )

                HStack(spacing: 6) {
                    Rectangle()
                        .fill(Color.violetLight.opacity(0.4))
                        .frame(width: 1.5, height: metrics.scaledSize(14))
                    Text("Full read: You → Doctrine → Operator")
                        .font(.mono(metrics.monoSmall))
                        .foregroundColor(.violetLight.opacity(0.85))
                }
            }
        }
    }

    private func intelProse(_ text: String) -> some View {
        DoctrineProseBlock(text: text, accent: .violetLight)
    }
}

// MARK: - INTEL TAB
// Stripped Dossier. Removed: agent-facing header, academic framing, comm protocol preamble.
// Kept: live observed traits (data-derived, genuinely useful),
//       failure modes (self-applicable, diagnostic register).
// Added: distribution system state (where each venture's seeds stand).

struct IntelTabView: View {
    @Bindable var profile: OperatorProfile
    @AppStorage("forge_v1_gate_passed") private var forgeGateCleared = true
    @Query private var actions: [Action]
    @Query private var cognitionLogs: [CognitionLog]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query(sort: \DistributionWeek.weekStartDate, order: .reverse) private var weeks: [DistributionWeek]
    @Environment(\.appMetrics) private var metrics

    @State private var failuresExpanded = false
    @State private var traitsExpanded = false

    // MARK: Live computed traits

    var avgFirstActionHour: Int? {
        let hours = logs.compactMap { $0.firstCompletionHour }
        guard !hours.isEmpty else { return nil }
        return hours.reduce(0, +) / hours.count
    }

    var operationalDisplacementDays: Int {
        let cal = Calendar.current
        return logs.prefix(14).filter { log in
            let dayActions = actions.filter { a in
                a.completionDates.contains { cal.isDate($0, inSameDayAs: log.date) }
            }
            let hasAdmin = dayActions.contains { $0.cognitionMode == .administrative }
            let hasCreative = dayActions.contains { $0.cognitionMode == .creative || $0.cognitionMode == .analytical }
            return hasAdmin && !hasCreative
        }.count
    }

    var dominantFrictionSystem: String {
        let highFriction = actions.filter { $0.isHighFriction }
        guard !highFriction.isEmpty else { return "None detected" }
        let bySys = Dictionary(grouping: highFriction) { $0.system }
        if let top = bySys.max(by: { $0.value.count < $1.value.count }) {
            return "\(top.key.rawValue.capitalized) · \(top.value.count) high-friction actions"
        }
        return "Mixed"
    }

    var morningExecutionRate: String {
        let morning = actions.flatMap { $0.completionHours }.filter { $0 < 12 }.count
        let total = actions.flatMap { $0.completionHours }.count
        guard total > 0 else { return "Collecting" }
        return "\(Int(Double(morning) / Double(total) * 100))% of completions before noon"
    }

    var completionClustering: String {
        let allHours = actions.flatMap { $0.completionHours }
        guard allHours.count >= 14 else { return "Collecting" }
        let grouped = Dictionary(grouping: allHours) { $0 }.mapValues { $0.count }
        let topThree = grouped.sorted { $0.value > $1.value }.prefix(3).map { $0.value }.reduce(0, +)
        let pct = Int(Double(topThree) / Double(allHours.count) * 100)
        return pct >= 60 ? "Clustered — \(pct)% in peak 3 hours" : "Distributed"
    }

    var energyAccuracy: String {
        let fullDays = logs.filter { $0.energyStateRaw == EnergyState.full.rawValue }
        let reserveDays = logs.filter { $0.energyStateRaw == EnergyState.reserve.rawValue }
        guard fullDays.count >= 3 && reserveDays.count >= 3 else { return "Collecting" }
        let cal = Calendar.current
        func avg(_ days: [DailyLog]) -> Double {
            let counts = days.compactMap { log -> Double? in
                let n = actions.reduce(0) { n, a in n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count }
                return n > 0 ? Double(n) : nil
            }
            return counts.isEmpty ? 0 : counts.reduce(0, +) / Double(counts.count)
        }
        let fAvg = avg(fullDays), rAvg = avg(reserveDays)
        if fAvg > rAvg * 1.2 { return "Calibrated" }
        if fAvg < rAvg { return "Inverted — reserve days outperform full" }
        return "Weak signal"
    }

    var body: some View {
        VStack(spacing: metrics.blockSpacing) {

            OperatorSeasonIntelCard()
                .padding(.horizontal, metrics.hPad)

            // Live observed traits — collapsed by default (diagnostic, not personality report)
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) { traitsExpanded.toggle() }
                    }) {
                        HStack {
                            MonoLabel(text: traitsExpanded ? "TRAITS" : "TRAITS ↓", color: .inkGreen, size: 10)
                            Spacer()
                            Image(systemName: traitsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: metrics.scaledSize(10), weight: .medium))
                                .foregroundColor(.textMuted.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)

                    if traitsExpanded {
                    HStack {
                        Spacer()
                        Text("FROM USAGE DATA")
                            .font(.mono(metrics.monoSmall))
                            .foregroundColor(.textMuted.opacity(0.4))
                            .tracking(1.0)
                    }
                    .padding(.top, metrics.scaledSize(8))

                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                        .padding(.top, metrics.scaledSize(8))

                    let traits: [(String, String, Color?)] = [
                        ("AVG FIRST ACTION", avgFirstActionHour.map { h in
                            let p = h < 12 ? "AM" : "PM"
                            let d = h > 12 ? h - 12 : (h == 0 ? 12 : h)
                            return "\(d)\(p)"
                        } ?? "Collecting", nil),
                        ("MORNING EXECUTION", morningExecutionRate, nil),
                        ("COMPLETION PATTERN", completionClustering, nil),
                        ("ENERGY ACCURACY", energyAccuracy,
                         energyAccuracy.contains("Inverted") ? .inkAmber : nil),
                        ("DOMINANT FRICTION", dominantFrictionSystem, nil),
                        ("ADMIN DISPLACEMENT", operationalDisplacementDays == 0
                            ? "Not detected (14d)"
                            : "\(operationalDisplacementDays) of last 14 days",
                         operationalDisplacementDays >= 4 ? .inkAmber : nil),
                    ]

                    VStack(spacing: metrics.scaledSize(6)) {
                        ForEach(Array(traits.enumerated()), id: \.element.0) { index, trait in
                            let warn = trait.2 == .inkAmber
                            HStack(alignment: .top, spacing: 8) {
                                Text(trait.0)
                                    .font(.mono(metrics.monoSmall))
                                    .foregroundColor(.textMuted)
                                    .frame(width: metrics.scaledSize(130), alignment: .leading)
                                HStack(alignment: .top, spacing: 6) {
                                    if warn {
                                        Circle()
                                            .fill(Color.inkAmber)
                                            .frame(width: metrics.scaledSize(4), height: metrics.scaledSize(4))
                                            .padding(.top, metrics.scaledSize(5))
                                    }
                                    Text(trait.1)
                                        .font(.sora(metrics.captionSize, weight: .light))
                                        .foregroundColor((trait.2 ?? .textPrimary).opacity(0.92))
                                        .lineSpacing(metrics.scaledSize(4))
                                        .tracking(0.1)
                                }
                                Spacer()
                            }
                            .padding(.vertical, metrics.scaledSize(8))
                            .padding(.horizontal, metrics.scaledSize(10))
                            .background(
                                index.isMultiple(of: 2)
                                    ? Color.bgBase.opacity(0.3)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.top, metrics.scaledSize(4))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Failure modes — the diagnostic register, self-applicable
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) { failuresExpanded.toggle() }
                    }) {
                        HStack {
                            MonoLabel(
                                text: failuresExpanded ? "WHEN STRUCTURE BREAKS" : "WHEN STRUCTURE BREAKS ↓",
                                color: .inkAmber,
                                size: 10
                            )
                            Spacer()
                            Image(systemName: failuresExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: metrics.scaledSize(10), weight: .medium))
                                .foregroundColor(.textMuted.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)

                    if failuresExpanded {
                        VStack(alignment: .leading, spacing: metrics.sectionGap) {
                            Rectangle().fill(Color.inkAmber.opacity(0.15)).frame(height: 0.5)
                                .padding(.top, metrics.scaledSize(12))

                            ForEach(failureModes, id: \.0) { f in
                                VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
                                    MonoLabel(text: f.0, color: .inkAmber, size: 9)
                                    Text(f.1)
                                        .font(.sora(metrics.captionSize, weight: .light))
                                        .foregroundColor(.textPrimary)
                                        .lineSpacing(metrics.scaledSize(4))
                                    HStack(alignment: .top, spacing: 8) {
                                        Rectangle()
                                            .fill(Color.inkGreen.opacity(0.5))
                                            .frame(width: 1.5)
                                            .padding(.top, metrics.scaledSize(3))
                                        Text(f.2)
                                            .font(.sora(metrics.captionSize, weight: .light))
                                            .foregroundColor(.textSecond)
                                            .lineSpacing(metrics.scaledSize(4))
                                    }
                                }
                            }
                        }
                        .padding(.top, metrics.scaledSize(4))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Distribution system state — compact read across all three ventures
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    MonoLabel(text: "DISTRIBUTION STATE", color: .textMuted, size: 10)

                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                    distributionStateRow("HIDEOUT", "Monday block · physical seeds · Friday log", .warm, true)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    distributionStateRow("FORM", "Threshold Tuesdays · Saturday long run · problem-space", .inkGreen, true)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    distributionStateRow("FORGE", forgeGateCleared ? "Active · alternating Monday block" : "Paused · v1 gate pending", .violetLight, forgeGateCleared)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Weekly export
            WeeklyExportCard(actions: actions, logs: logs)
                .padding(.horizontal, metrics.hPad)
        }
        .padding(.bottom, 80)
    }

    private func distributionStateRow(_ venture: String, _ state: String, _ color: Color, _ active: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(active ? color : Color.textMuted.opacity(0.3))
                .frame(width: metrics.scaledSize(6), height: metrics.scaledSize(6))
                .padding(.top, metrics.scaledSize(4))
            VStack(alignment: .leading, spacing: 2) {
                Text(venture)
                    .font(.mono(metrics.monoSmall))
                    .foregroundColor(active ? color : .textMuted)
                Text(state)
                    .font(.sora(metrics.captionSize, weight: .light))
                    .foregroundColor(.textSecond)
            }
            Spacer()
        }
        .padding(.vertical, metrics.scaledSize(4))
    }

    private let failureModes: [(String, String, String)] = [
        ("SEQUENCING AMBIGUITY",
         "Work exists but execution order is unclear. Not avoidance — structural drag. The operator cannot initiate cleanly when sequence is undefined.",
         "Reduce to one clear next action. What is the first step that unlocks the others? Name it."),
        ("STRUCTURAL FRAGMENTATION",
         "Too many simultaneously active fronts reducing throughput. Each open front draws from the same attentional pool.",
         "Name the fronts. Which one closes completely before the next opens? One door. Collapse then expand."),
        ("OPERATIONAL DISPLACEMENT",
         "Logistics and maintenance consuming morning leverage time before generative work starts. Admin produces completion signals without building anything.",
         "Distinguish maintenance from forward work. Admin has consumed the morning. No forward work has started. Surface it, move on."),
        ("ENVIRONMENTAL DISORDER",
         "Physical incoherence degrading cognition and throughput. Not aesthetics — environmental coherence materially affects execution quality.",
         "Reset conditions before cognitive work. Environment first. Always."),
        ("CLEANUP DEBT",
         "Iteration speed outpacing structural hygiene. Fast building creates residue: unfinished architecture, stale systems, fragmented notes.",
         "Surface when leverage output is high but consolidation hasn't occurred. Structural residue accumulating. Consolidation likely outperforms expansion right now."),
    ]
}

// MARK: - MANUAL TAB
// Field Manual — operator principles + distribution principles.
// Same format throughout: title, meaning, misread, usage trigger.
// This is the reference you open when something is stuck.

struct YouFieldManualView: View {
    @Environment(\.appMetrics) private var metrics
    @State private var expandedID: UUID? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: metrics.scaledSize(4)) {
                MonoLabel(text: "FIELD MANUAL", color: .textMuted, size: 10)
                Text("Principles when stuck · crash course when learning.")
                    .font(.sora(metrics.captionSize, weight: .light))
                    .foregroundColor(.textMuted)
            }
            .padding(.bottom, metrics.sectionGap)

            VStack(spacing: metrics.scaledSize(2)) {
                ForEach(allEntries) { entry in
                    manualEntry(entry)
                }
            }

            Rectangle()
                .fill(Color.muted.opacity(0.15))
                .frame(height: 0.5)
                .padding(.vertical, metrics.sectionGap)

            DistributionCrashCourseReading()
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.bottom, 80)
    }

    private func manualEntry(_ entry: ManualEntry) -> some View {
        let isExpanded = expandedID == entry.id

        return Button(action: {
            withAnimation(.easeOut(duration: 0.22)) {
                expandedID = isExpanded ? nil : entry.id
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: metrics.scaledSize(12)) {
                    Rectangle()
                        .fill(isExpanded ? entry.accentColor : Color.muted.opacity(0.35))
                        .frame(width: 2)
                        .frame(minHeight: metrics.scaledSize(44))
                        .animation(.easeOut(duration: 0.2), value: isExpanded)

                    VStack(alignment: .leading, spacing: metrics.scaledSize(5)) {
                        Text(entry.title)
                            .font(.mono(metrics.captionSize))
                            .foregroundColor(isExpanded ? entry.accentColor : .textSecond)
                            .tracking(0.5)
                        Text(entry.trigger)
                            .font(.sora(metrics.isIPad ? metrics.youReadBodySize : metrics.bodySize, weight: .light))
                            .foregroundColor(isExpanded ? .textPrimary.opacity(0.92) : .textMuted.opacity(0.75))
                            .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(4))
                            .tracking(0.1)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: metrics.scaledSize(9), weight: .medium))
                        .foregroundColor(.textMuted.opacity(0.5))
                        .padding(.top, metrics.scaledSize(4))
                }
                .padding(.vertical, metrics.scaledSize(14))
                .padding(.horizontal, metrics.scaledSize(2))

                if isExpanded {
                    VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                        Rectangle()
                            .fill(entry.accentColor.opacity(0.12))
                            .frame(height: 0.5)
                            .padding(.leading, metrics.scaledSize(14))

                        VStack(alignment: .leading, spacing: metrics.scaledSize(18)) {
                            manualBlock("MEANING", text: entry.meaning, color: entry.accentColor)
                            manualMisreadBlock(text: entry.misread)
                        }
                        .padding(.leading, metrics.scaledSize(14))
                        .padding(.bottom, metrics.scaledSize(14))
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Rectangle()
                    .fill(Color.muted.opacity(0.1))
                    .frame(height: 0.5)
            }
        }
        .buttonStyle(.plain)
    }

    private func manualBlock(_ label: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(5)) {
            MonoLabel(text: label, color: color, size: 9)
            Text(text)
                .font(.sora(metrics.isIPad ? metrics.youReadBodySize : metrics.bodySize, weight: .light))
                .foregroundColor(.textPrimary.opacity(0.92))
                .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(6))
                .tracking(0.1)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func manualMisreadBlock(text: String) -> some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(5)) {
            MonoLabel(text: "MISREAD", color: .inkAmber, size: 9)
            Text(text)
                .font(.sora(metrics.isIPad ? metrics.youReadBodySize : metrics.bodySize, weight: .light))
                .foregroundColor(.textSecond)
                .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(6))
                .tracking(0.1)
                .fixedSize(horizontal: false, vertical: true)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.inkAmber.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // All entries — operator principles + distribution principles
    private let allEntries: [ManualEntry] = [
        // Operator principles
        ManualEntry(
            title: "PARTICIPATION IN REALITY",
            meaning: "Showing up — in small, concrete ways — is the mechanism. Not readiness, not ideal conditions. Showing up.",
            misread: "Waiting until you feel ready. Readiness follows participation, not the other way.",
            trigger: "When analysis is substituting for action. When the loop won't close.",
            accentColor: .violetLight
        ),
        ManualEntry(
            title: "RESTORATION BEFORE INTERPRETATION",
            meaning: "Environmental and physiological conditions shape perception. A bad read of a situation may be a bad environment, not a bad situation.",
            misread: "Treating your current interpretation as accurate when conditions are degraded.",
            trigger: "When something feels heavier than it should. Restore first. Conclude after.",
            accentColor: .inkGreen
        ),
        ManualEntry(
            title: "ACTION REORGANIZES PERCEPTION",
            meaning: "Clarity comes from movement, not analysis. The next step becomes visible after the current step is taken.",
            misread: "Believing you need clarity before you can act. The causality runs the other way.",
            trigger: "When you're stuck planning. One action. Perception shifts. Proceed.",
            accentColor: .violet
        ),
        ManualEntry(
            title: "ONE DOOR",
            meaning: "One open path at a time. Too many concurrent openings fragment attention and kill momentum.",
            misread: "Keeping options open as a strategy. Options without commitment are just load.",
            trigger: "When multiple active directions are pulling at the same time.",
            accentColor: .warm
        ),
        ManualEntry(
            title: "INCREMENTS",
            meaning: "Output accumulates through action completion, not through planning or intention. Each logged action is a data point and a deposit.",
            misread: "Treating a day without a significant event as a day without progress. Accumulation is not visible until it is.",
            trigger: "When progress is not visible. Review completion history. The record is the evidence.",
            accentColor: .violetLight
        ),
        ManualEntry(
            title: "FLOW INSIDE FORM",
            meaning: "Structure does not kill aliveness. A schedule can hold energy. Form can contain creativity without suppressing it.",
            misread: "Treating structure as opposed to expression. Structure is what makes expression possible.",
            trigger: "When the day feels rigid. The anchor is what enables the open time.",
            accentColor: .inkTeal
        ),
        ManualEntry(
            title: "REDUCE BRANCHING",
            meaning: "Every unclosed loop costs attentional resources. Fewer active branches means more capacity per branch.",
            misread: "Mistaking breadth of engagement for productivity. Open loops are debt.",
            trigger: "When you feel busy but unproductive. Close one loop completely.",
            accentColor: .inkAmber
        ),
        ManualEntry(
            title: "ENVIRONMENT IS COGNITION",
            meaning: "Conditions are not the background to your thinking. They are part of your thinking. Light, temperature, order, and noise all affect output quality.",
            misread: "Believing you can perform consistently in inconsistent environments through willpower.",
            trigger: "Before any deep work block. Environment first.",
            accentColor: .inkGreen
        ),

        // Distribution principles — added May 2026
        ManualEntry(
            title: "SEEDS TAKE TIME",
            meaning: "Distribution is a trained discipline with delayed signal. A board goes up, a card gets placed, a Monday block runs — the signal may appear in three weeks or ten. This is not failure. This is how seeds work.",
            misread: "Reading week-two zero-signal as evidence the system isn't working. The system needs reps before signal appears.",
            trigger: "When nothing has visibly happened from distribution activity. Count the reps, not the results.",
            accentColor: .inkGreen
        ),
        ManualEntry(
            title: "PLANT THE RIGHT SEED",
            meaning: "Not all surfaces produce signal. A TikTok post is an exhaust pipe. A Watermarc card in a 258-unit building is a seed. The mechanism matters. Does this surface have a plausible path to the person who would actually come?",
            misread: "Treating all distribution activity as equivalent. Volume without mechanism is noise.",
            trigger: "Before adding a new distribution surface. What is the actual mechanism from this seed to a customer?",
            accentColor: .warm
        ),
        ManualEntry(
            title: "ONE ADJUSTMENT",
            meaning: "When signal says something isn't working, change one thing. Not the whole system. One variable. Wait for signal. Then decide again.",
            misread: "Changing multiple surfaces simultaneously when signal is low. Now you can't read which change produced the result.",
            trigger: "When Friday log shows consistent zero on a specific signal. Change one thing and watch.",
            accentColor: .violetLight
        ),
        ManualEntry(
            title: "THE BLOCK NEVER CHANGES",
            meaning: "The Monday content block is the same sequence every week. Same shots, same order, same edit rules, same posting flow. No decisions at execution time. The discipline is in the lock, not the creativity.",
            misread: "Treating the block as a creative prompt. It is not. It is a fixed seed-planting protocol.",
            trigger: "When the Monday block feels slow or starts expanding. Tighten the sequence. No new shots.",
            accentColor: .warm
        ),
        ManualEntry(
            title: "PRODUCT TRUTH ONLY",
            meaning: "Content is what the product actually did. One real decision, one real outcome, one sentence of context. Outsider-legible — a stranger understands the signal without knowing the product. Not a tutorial. Not enthusiasm. Not a demo.",
            misread: "Explaining the product, talking about what it could do, performing excitement about a feature. None of that is product truth.",
            trigger: "Before posting anything. Would someone who has never heard of this product understand what actually happened?",
            accentColor: .inkGreen
        ),
    ]
}

// MARK: - ManualEntry model

struct ManualEntry: Identifiable {
    let id = UUID()
    let title: String
    let meaning: String
    let misread: String
    let trigger: String
    let accentColor: Color
}
