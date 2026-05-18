import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications
import Foundation

// MARK: - HIDEOUT TAB — Solo Experiment Command Center
// Driven entirely by the Strategic Brief (May 13, 2026)
// Two numbers that matter most: 30-day avg revenue + repeat customer %

struct HideoutTabView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.appMetrics) private var metrics
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @State private var showLogSheet = false
    @State private var selectedTab: Int = 0  // 0 = Dashboard, 1 = Scorecard, 2 = Playbook

    // Friction audit — persisted checkboxes (14 items)
    @AppStorage("friction_street_visible")   private var frictionStreetVisible   = false
    @AppStorage("friction_obvious_3sec")     private var frictionObvious3sec     = false
    @AppStorage("friction_street_signage")   private var frictionStreetSignage   = false
    @AppStorage("friction_elevator_obvious") private var frictionElevatorObvious = false
    @AppStorage("friction_residents_told")   private var frictionResidentsTold   = false
    @AppStorage("friction_qr_lobby")         private var frictionQRLobby         = false
    @AppStorage("friction_watermarc_leasing")private var frictionWatermarcLeasing = false
    @AppStorage("friction_watermarc_concierge") private var frictionWatermarcConcierge = false
    @AppStorage("friction_watermarc_path")   private var frictionWatermarcPath   = false

    // Growth system — System 1: Watermarc card
    @AppStorage("growth_card_designed")      private var growthCardDesigned      = false
    @AppStorage("growth_card_printed")       private var growthCardPrinted       = false
    @AppStorage("growth_card_delivered")     private var growthCardDelivered     = false

    // Growth system — System 2: GBP
    @AppStorage("growth_gbp_reviews")        private var growthGBPReviews        = false
    @AppStorage("growth_gbp_profile")        private var growthGBPProfile        = false
    @AppStorage("growth_gbp_photos")         private var growthGBPPhotos         = false

    // Growth system — System 3: Column boards (replaces A-frame wayfinding — A-frame rejected)
    @AppStorage("growth_board_top_ordered")  private var growthBoardTopOrdered   = false
    @AppStorage("growth_board_bot_ordered")  private var growthBoardBotOrdered   = false
    @AppStorage("growth_boards_installed")   private var growthBoardsInstalled   = false

    // 14-Day Partnership Sprint — cold brew account before June 13
    @AppStorage("sprint_offer_defined")      private var sprintOfferDefined      = false
    @AppStorage("sprint_samples_made")       private var sprintSamplesMade       = false
    @AppStorage("sprint_watermarc_desk")     private var sprintWatermarcDesk     = false
    @AppStorage("sprint_watermarc_leasing")  private var sprintWatermarcLeasing  = false
    @AppStorage("sprint_expansive")          private var sprintExpansive         = false
    @AppStorage("sprint_skyview")            private var sprintSkyview           = false
    @AppStorage("sprint_followup1")          private var sprintFollowup1         = false
    @AppStorage("sprint_salon")              private var sprintSalon             = false
    @AppStorage("sprint_followup2")          private var sprintFollowup2         = false
    @AppStorage("sprint_first_account")      private var sprintFirstAccount      = false
    @AppStorage("sprint_first_delivery")     private var sprintFirstDelivery     = false
    @AppStorage("sprint_converted_weekly")   private var sprintConvertedWeekly   = false

    // Growth system — System 4: Content
    @AppStorage("growth_video_filmed")       private var growthVideoFilmed       = false
    @AppStorage("growth_video_posted")       private var growthVideoPosted       = false

    // Experiment Ledger — expand/collapse state per card (collapsed by default — clean, not busy)
    @AppStorage("exp_7am_expanded")        private var exp7amExpanded        = false
    @AppStorage("exp_sunday_expanded")     private var expSundayExpanded      = false
    @AppStorage("exp_watermarc_expanded")  private var expWatermarcExpanded   = false
    @AppStorage("exp_coldbrew_expanded")   private var expColdBrewExpanded    = false
    @AppStorage("exp_concierge_expanded")  private var expConciergeExpanded   = false

    // Experiment Ledger — status per experiment (continue/kill/modify + notes)
    @AppStorage("exp_7am_status")          private var exp7amStatus          = "active"
    @AppStorage("exp_7am_note")            private var exp7amNote            = ""
    @AppStorage("exp_sunday_status")       private var expSundayStatus       = "active"
    @AppStorage("exp_sunday_note")         private var expSundayNote         = ""
    @AppStorage("exp_watermarc_status")    private var expWatermarcStatus    = "active"
    @AppStorage("exp_watermarc_note")      private var expWatermarcNote      = ""
    @AppStorage("exp_coldbrew_status")     private var expColdBrewStatus     = "pending"
    @AppStorage("exp_coldbrew_note")       private var expColdBrewNote       = ""
    @AppStorage("exp_concierge_status")    private var expConciergeStatus    = "active"
    @AppStorage("exp_concierge_note")      private var expConciergeNote      = ""

    // Weekly Revenue Composition — persisted notes per source (current week)
    @AppStorage("wrc_week_label")          private var wrcWeekLabel          = ""
    @AppStorage("wrc_walkin_rev")          private var wrcWalkinRev          = ""
    @AppStorage("wrc_walkin_stress")       private var wrcWalkinStress       = 0
    @AppStorage("wrc_walkin_repeat")       private var wrcWalkinRepeat       = "high"
    @AppStorage("wrc_regular_rev")         private var wrcRegularRev         = ""
    @AppStorage("wrc_regular_stress")      private var wrcRegularStress      = 0
    @AppStorage("wrc_watermarc_rev")       private var wrcWatermarcRev       = ""
    @AppStorage("wrc_watermarc_stress")    private var wrcWatermarcStress    = 0
    @AppStorage("wrc_concierge_rev")       private var wrcConciergeRev       = ""
    @AppStorage("wrc_concierge_stress")    private var wrcConciergeStress    = 0
    @AppStorage("wrc_partnership_rev")     private var wrcPartnershipRev     = ""
    @AppStorage("wrc_partnership_stress")  private var wrcPartnershipStress  = 0
    @AppStorage("wrc_sunday_tail_rev")     private var wrcSundayTailRev      = ""
    @AppStorage("wrc_sunday_tail_stress")  private var wrcSundayTailStress   = 0
    @AppStorage("wrc_early_am_rev")        private var wrcEarlyAmRev         = ""
    @AppStorage("wrc_early_am_stress")     private var wrcEarlyAmStress      = 0
    @AppStorage("wrc_show_wrc_sheet")      private var showWRCSheet          = false

    // Playbook decision stack — tappable answers
    @AppStorage("decision_q02_answered")     private var decisionQ02Answered     = false
    @AppStorage("decision_q02_text")         private var decisionQ02Text         = ""
    @AppStorage("decision_q03_answered")     private var decisionQ03Answered     = false
    @AppStorage("decision_showQ02Input")     private var showQ02Input            = false
    @AppStorage("decision_showQ03Input")     private var showQ03Input            = false

    // 30-day solo experiment started May 13, 2026
    static let experimentStart = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 13)) ?? Date()
    static let loanDecision     = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 13)) ?? Date()

    var experimentDay: Int {
        max(1, (Calendar.current.dateComponents([.day], from: Self.experimentStart, to: Date()).day ?? 0) + 1)
    }

    var daysToDecision: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: Self.loanDecision).day ?? 0)
    }

    var recentShifts: [HideoutShiftLog] { Array(shifts.prefix(30)) }

    var thirtyDayAvg: Double {
        guard !recentShifts.isEmpty else { return 0 }
        return recentShifts.map(\.grossRevenue).reduce(0, +) / Double(recentShifts.count)
    }

    var currentBand: HideoutPlanningBand {
        recentShifts.isEmpty ? .unknown : HideoutPlanningBand.classify(thirtyDayAvg)
    }

    var trend: TrendDirection {
        guard recentShifts.count >= 4 else { return .unknown }
        let recent = Array(recentShifts.prefix(3)).map(\.grossRevenue).reduce(0, +) / 3
        let earlier = Array(recentShifts.dropFirst(3).prefix(3)).map(\.grossRevenue).reduce(0, +) / 3
        guard earlier > 0 else { return .unknown }
        let delta = (recent - earlier) / earlier
        if delta > 0.05 { return .up }
        if delta < -0.05 { return .down }
        return .flat
    }

    var avgStress: Double {
        let scored = recentShifts.filter { $0.stressScore > 0 }
        guard !scored.isEmpty else { return 0 }
        return Double(scored.map(\.stressScore).reduce(0, +)) / Double(scored.count)
    }

    var avgContribution: Double {
        guard !recentShifts.isEmpty else { return 0 }
        return recentShifts.map(\.estimatedContribution).reduce(0, +) / Double(recentShifts.count)
    }

    var aggregateRepeatPercent: Double? {
        let withData = recentShifts.filter { ($0.repeatCustomerCount + $0.newCustomerCount) > 0 }
        guard !withData.isEmpty else { return nil }
        let totalRepeat = withData.map(\.repeatCustomerCount).reduce(0, +)
        let totalAll = withData.map { $0.repeatCustomerCount + $0.newCustomerCount }.reduce(0, +)
        guard totalAll > 0 else { return nil }
        return Double(totalRepeat) / Double(totalAll)
    }

    var avgPeakBurst: Int {
        let withBurst = recentShifts.filter { $0.peakBurstUpdated > 0 }
        guard !withBurst.isEmpty else { return 0 }
        return withBurst.map(\.peakBurstUpdated).reduce(0, +) / withBurst.count
    }

    var txToNextBand: Int {
        let nextTarget: Double
        switch currentBand {
        case .unknown: nextTarget = 520
        case .survival: nextTarget = 590
        case .stability: nextTarget = 650
        case .comfort: nextTarget = 750
        case .growth: return 0
        }
        guard thirtyDayAvg < nextTarget else { return 0 }
        return Int(ceil((nextTarget - thirtyDayAvg) / 17.29))  // $17.29 = Week 1 solo avg ticket
    }

    var body: some View {
        HideoutAdaptiveShell { metrics in
            ZStack {
                AtmosphericBackground()

                if metrics.useTwoColumn {
                    // ── iPad landscape: two-column layout ──────────────────────
                    HideoutTwoColumnLayout(metrics: metrics) {
                        // Left: always-visible live dashboard
                        VStack(spacing: 0) {
                            ipadLeftHeader(metrics: metrics)
                            ScrollView(showsIndicators: false) {
                                dashboardView
                                    .environment(\.hideoutMetrics, metrics)
                            }
                        }
                    } right: {
                        // Right: active work surface
                        VStack(spacing: 0) {
                            ipadRightTabs(metrics: metrics)
                            ScrollView(showsIndicators: false) {
                                Group {
                                    if selectedTab == 1 {
                                        scorecardView
                                    } else if selectedTab == 2 {
                                        playbookView
                                    } else {
                                        intelView
                                    }
                                }
                                .environment(\.hideoutMetrics, metrics)
                            }
                        }
                    }
                } else {
                    // ── iPhone / iPad portrait: single column ─────────────────
                    VStack(spacing: 0) {
                        phoneHeader(metrics: metrics)
                        phoneTabs(metrics: metrics)
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                            .padding(.horizontal, metrics.hPad)
                        ScrollView(showsIndicators: false) {
                            Group {
                                if selectedTab == 0 {
                                    dashboardView
                                } else if selectedTab == 1 {
                                    scorecardView
                                } else if selectedTab == 2 {
                                    playbookView
                                } else {
                                    intelView
                                }
                            }
                            .environment(\.hideoutMetrics, metrics)
                        }
                    }
                }

                // ── Floating log button (both layouts) ────────────────────────
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showLogSheet = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: metrics.isIPad ? 16 : 14, weight: .semibold))
                                Text("LOG SHIFT")
                                    .font(.system(size: metrics.isIPad ? 13 : 11, weight: .semibold, design: .monospaced))
                                    .tracking(0.8)
                            }
                            .foregroundColor(.bgBase)
                            .padding(.horizontal, metrics.isIPad ? 28 : 20)
                            .padding(.vertical, metrics.isIPad ? 17 : 13)
                            .background(Color.warm)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.warm.opacity(0.4), radius: 14, y: 4)
                        }
                        .padding(.trailing, metrics.hPad)
                        .padding(.bottom, 90)
                    }
                }
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogShiftSheet(isPresented: $showLogSheet, experimentDay: experimentDay)
        }
    }


    // MARK: - LAYOUT HELPERS (adaptive headers + tabs)

    // iPad landscape — left column header (compact, info-dense)
    func ipadLeftHeader(metrics: HideoutLayoutMetrics) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        MonoLabel(text: "HIDEOUT MIAMI · SOLO EXPERIMENT", color: .warm, size: metrics.monoSmall)
                        Text("Day \(experimentDay)")
                            .font(.system(size: metrics.displaySize, weight: .bold, design: .monospaced))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        MonoLabel(text: "LOAN DECISION", color: .textMuted, size: metrics.monoSmall)
                        Text("\(daysToDecision)d")
                            .font(.system(size: metrics.isIPad ? 28 : 22, weight: .medium, design: .monospaced))
                            .foregroundColor(daysToDecision <= 7 ? .inkAmber : .textSecond)
                        MonoLabel(text: "JUNE 13", color: .textMuted, size: metrics.monoSmall)
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)
            .padding(.top, 28)
            .padding(.bottom, 20)
            Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
        }
    }

    // iPad landscape — right column tabs (SCORECARD / PLAYBOOK / INTEL)
    func ipadRightTabs(metrics: HideoutLayoutMetrics) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Tab 0 = dashboard (left column), so right starts at 1
                ForEach([1, 2, 3], id: \.self) { i in
                    Button(action: { withAnimation(.easeOut(duration: 0.2)) { selectedTab = i } }) {
                        VStack(spacing: 8) {
                            Text(["SCORECARD", "PLAYBOOK", "INTEL"][i - 1])
                                .font(.system(size: metrics.monoSize, weight: .medium, design: .monospaced))
                                .foregroundColor(selectedTab == i ? .warm : .textMuted)
                                .tracking(0.8)
                            Rectangle()
                                .fill(selectedTab == i ? Color.warm : Color.clear)
                                .frame(height: 1.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                    .padding(.bottom, 12)
                }
            }
            .padding(.horizontal, metrics.hPad)
            Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
        }
    }

    // iPhone / iPad portrait — full header
    func phoneHeader(metrics: HideoutLayoutMetrics) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    MonoLabel(text: "HIDEOUT MIAMI", color: .warm, size: metrics.monoSmall)
                    MonoLabel(text: "SOLO EXPERIMENT", color: .textMuted, size: metrics.monoSmall)
                }
                Text("Day \(experimentDay)")
                    .font(.system(size: metrics.displaySize, weight: .bold, design: .monospaced))
                    .foregroundColor(.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                MonoLabel(text: "LOAN DECISION", color: .textMuted, size: metrics.monoSmall)
                Text("\(daysToDecision)d")
                    .font(.system(size: metrics.isIPad ? 28 : 22, weight: .medium, design: .monospaced))
                    .foregroundColor(daysToDecision <= 7 ? .inkAmber : .textSecond)
                MonoLabel(text: "JUNE 13", color: .textMuted, size: metrics.monoSmall)
            }
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.top, metrics.isIPad ? 32 : 20)
        .padding(.bottom, metrics.isIPad ? 16 : 12)
    }

    // iPhone / iPad portrait — all 4 tabs
    func phoneTabs(metrics: HideoutLayoutMetrics) -> some View {
        HStack(spacing: 0) {
            ForEach(["DASHBOARD", "SCORECARD", "PLAYBOOK", "INTEL"].indices, id: \.self) { i in
                Button(action: { withAnimation(.easeOut(duration: 0.2)) { selectedTab = i } }) {
                    VStack(spacing: 6) {
                        Text(["DASHBOARD", "SCORECARD", "PLAYBOOK", "INTEL"][i])
                            .font(.system(size: metrics.isIPad ? 11 : 9, weight: .medium, design: .monospaced))
                            .foregroundColor(selectedTab == i ? .warm : .textMuted)
                            .tracking(0.6)
                        Rectangle()
                            .fill(selectedTab == i ? Color.warm : Color.clear)
                            .frame(height: 1.5)
                    }
                    .frame(height: metrics.isIPad ? 52 : 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    // MARK: - DASHBOARD

    var dashboardView: some View {
        VStack(spacing: 14) {

            // ── THE TWO NUMBERS THAT MATTER MOST ─────────────────────────────
            // Section 9: "Everything else flows from these two numbers."
            VStack(alignment: .leading, spacing: 6) {
                MonoLabel(text: "THE TWO NUMBERS THAT MATTER MOST", color: .warm, size: 9)
                    .padding(.horizontal, metrics.hPad)

                HStack(spacing: 10) {
                    // Number 1 — 30-day avg
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            MonoLabel(text: "01  30-DAY AVG", color: .warm.opacity(0.7), size: 9)
                            Text(recentShifts.isEmpty ? "—" : "$\(Int(thirtyDayAvg))")
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundColor(.textPrimary)
                                .minimumScaleFactor(0.7)
                            HStack(spacing: 5) {
                                Circle().fill(currentBand.color).frame(width: 6, height: 6)
                                Text(recentShifts.isEmpty ? "no data yet" : currentBand.label)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(currentBand.color)
                            }
                            if txToNextBand > 0 {
                                MonoLabel(text: "~$\(txToNextBand * 17) rev to next band", color: .textMuted, size: 9)
                            } else if !recentShifts.isEmpty {
                                MonoLabel(text: "at target", color: .inkGreen, size: 9)
                            }
                        }
                    }

                    // Number 2 — Repeat %
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            MonoLabel(text: "02  REPEAT %", color: .warm.opacity(0.7), size: 9)
                            if let rp = aggregateRepeatPercent {
                                Text("\(Int(rp * 100))%")
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundColor(.textPrimary)
                                let diagnosis = rp >= 0.8 ? "acquisition" : rp >= 0.5 ? "mixed" : "retention"
                                let color: Color = rp >= 0.8 ? .inkAmber : rp >= 0.5 ? .inkTeal : .inkRed
                                HStack(spacing: 5) {
                                    Circle().fill(color).frame(width: 6, height: 6)
                                    Text(diagnosis).font(.system(size: 11, design: .monospaced)).foregroundColor(color)
                                }
                                MonoLabel(text: "\(diagnosis) problem", color: .textMuted, size: 9)
                            } else {
                                Text("—")
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundColor(.textMuted)
                                HStack(spacing: 5) {
                                    Circle().fill(Color.textMuted.opacity(0.4)).frame(width: 6, height: 6)
                                    Text("not tracked").font(.system(size: 11, design: .monospaced)).foregroundColor(.textMuted)
                                }
                                MonoLabel(text: "log repeat vs new", color: .textMuted, size: 9)
                            }
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }

            // ── Revenue sparkline ────────────────────────────────────────────
            if !recentShifts.isEmpty {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            MonoLabel(text: "EXPERIMENT TIMELINE", color: .textMuted, size: 10)
                            Spacer()
                            MonoLabel(text: trend.label, color: trend.color, size: 10)
                        }
                        RevenueSparkline(shifts: recentShifts)
                            .frame(height: 54)
                        HStack(spacing: 14) {
                            ForEach([("$520", Color.inkRed), ("$590", Color.inkAmber), ("$650", Color.inkGreen), ("$750", Color.violetLight)], id: \.0) { label, color in
                                HStack(spacing: 4) {
                                    Rectangle().fill(color.opacity(0.5)).frame(width: 10, height: 1.5)
                                    Text(label).font(.system(size: 9, design: .monospaced)).foregroundColor(.textMuted)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }

            // ── Solo economics ───────────────────────────────────────────────
            if !recentShifts.isEmpty {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 10) {
                        MonoLabel(text: "SOLO UNIT ECONOMICS", color: .textMuted, size: 10)
                        HStack(spacing: 0) {
                            econColumn("AVG GROSS", value: "$\(Int(thirtyDayAvg))", color: .textPrimary)
                            Divider().frame(height: 36).background(Color.muted.opacity(0.2)).padding(.horizontal, 12)
                            econColumn("AVG CONTRIB", value: avgContribution > 0 ? "$\(Int(avgContribution))" : "—", color: .inkGreen)
                            Divider().frame(height: 36).background(Color.muted.opacity(0.2)).padding(.horizontal, 12)
                            econColumn("AVG STRESS", value: avgStress > 0 ? "\(String(format: "%.1f", avgStress))/10" : "—",
                                      color: avgStress <= 4 ? .inkGreen : avgStress <= 6 ? .inkAmber : .inkRed)
                            if avgPeakBurst > 0 {
                                Divider().frame(height: 36).background(Color.muted.opacity(0.2)).padding(.horizontal, 12)
                                econColumn("PEAK BURST", value: "\(avgPeakBurst) tx", color: avgPeakBurst <= 15 ? .inkGreen : avgPeakBurst <= 22 ? .inkAmber : .inkRed)
                            }
                            Spacer()
                        }
                        Text("Contribution = revenue × 0.72 (after COGS 25% + Square 3%). Solo: no labor deduction.")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }

            // ── Revenue gap to next band ─────────────────────────────────────
            // Brief (May 2026): old throughput framing retired. Gap closes through revenue
            // quality — recurring partnerships, residential capture, hospitality optimization,
            // extended hours. "Need 9 more customers/day" is the wrong question.
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "REVENUE GAP — QUALITY OVER VOLUME", color: .textMuted, size: 10)
                    VStack(spacing: 0) {
                        gapRow("Survival floor", target: 520, current: thirtyDayAvg, bandColor: .inkRed)
                        Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)
                        gapRow("Stability", target: 590, current: thirtyDayAvg, bandColor: .inkAmber)
                        Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)
                        gapRow("Comfort", target: 650, current: thirtyDayAvg, bandColor: .inkGreen)
                        Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)
                        gapRow("Growth", target: 750, current: thirtyDayAvg, bandColor: .violetLight)
                    }
                    Text("Gap closes through any mix: recurring partnerships · residential capture · hospitality optimization · extended hours. Not strictly more walk-ins.")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // ── Shift log ────────────────────────────────────────────────────
            if recentShifts.isEmpty {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "WEEK 1 — COMPLETE. SEEDING IN PROGRESS.", color: .inkAmber)
                        Text("Week 1 data should be seeded automatically. If you're seeing this, use LOG SHIFT → 'Log a past shift' to enter manually.")
                            .font(.sora(12, weight: .light))
                            .foregroundColor(.textMuted)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(3)
                        VStack(alignment: .leading, spacing: 5) {
                            Group {
                                Text("Day 1  May 13  $419.00 · 28 tx · $14.96 avg · solo")
                                Text("Day 2  May 14  $398.00 · 22 tx · $18.09 avg · solo")
                                Text("Day 3  May 15  $648.00 · 44 tx · $14.73 avg · solo  ← best day")
                                Text("Day 4  May 16  $556.00 · 27 tx · $20.59 avg · solo")
                                Text("Day 5  May 17  $417.77 · 20 tx · $20.89 avg · solo")
                            }
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.warm.opacity(0.7))
                            Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                            Text("Week 1 total: $2,438.77 · 141 tx · $17.29 avg · +17% vs prior week")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.inkGreen.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, metrics.hPad)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(text: "SHIFT LOG").padding(.horizontal, metrics.hPad)
                    ForEach(recentShifts) { shift in
                        ShiftLogRow(shift: shift).padding(.horizontal, metrics.hPad)
                    }
                }
            }

            Spacer(minLength: 100)
        }
        .padding(.top, 16)
    }

    // MARK: - SCORECARD

    var scorecardView: some View {
        VStack(spacing: 14) {

            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    MonoLabel(text: "30-DAY SCORECARD", color: .warm, size: 10)
                    Text("The single most important dataset. Answers everything by June 13.")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)

                    ForEach(1...4, id: \.self) { week in
                        weekRow(week: week)
                        if week < 4 {
                            Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                        }
                    }

                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)

                    HStack {
                        MonoLabel(text: "30-DAY AVERAGE", color: .textMuted, size: 10)
                        Spacer()
                        Text(recentShifts.isEmpty ? "—" : "$\(Int(thirtyDayAvg))")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(recentShifts.isEmpty ? .textMuted : currentBand.color)
                    }
                    if !recentShifts.isEmpty {
                        HStack {
                            MonoLabel(text: "TREND", color: .textMuted, size: 10)
                            Spacer()
                            MonoLabel(text: trend.label, color: trend.color, size: 11)
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            if recentShifts.count >= 2 {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "BEHAVIORAL TECHNIQUES — 4 BEHAVIORS", color: .textMuted, size: 10)
                        let total = recentShifts.count
                        VStack(spacing: 8) {
                            techniqueRow("UPSELL USED",
                                        count: recentShifts.filter { $0.usedScriptedUpsell }.count,
                                        total: total,
                                        note: "\"Want me to warm a croissant?\"")
                            techniqueRow("REGULAR RECOGNIZED",
                                        count: recentShifts.filter { $0.recognizedRegular }.count,
                                        total: total,
                                        note: "\"The usual?\" / anticipated a need")
                            techniqueRow("PEAK-END CLOSE",
                                        count: recentShifts.filter { $0.anchorPhraseUsed }.count,
                                        total: total,
                                        note: "[Name]. Have a great [day].")
                        }

                        let upsellShifts = recentShifts.filter { $0.usedScriptedUpsell && $0.transactionCount > 0 }
                        let noUpsellShifts = recentShifts.filter { !$0.usedScriptedUpsell && $0.transactionCount > 0 }
                        if upsellShifts.count >= 2 && noUpsellShifts.count >= 2 {
                            let uA = upsellShifts.map { $0.grossRevenue / Double($0.transactionCount) }.reduce(0,+) / Double(upsellShifts.count)
                            let bA = noUpsellShifts.map { $0.grossRevenue / Double($0.transactionCount) }.reduce(0,+) / Double(noUpsellShifts.count)
                            let d = uA - bA
                            HStack(spacing: 6) {
                                Circle().fill(d > 0 ? Color.inkGreen : Color.textMuted).frame(width: 4, height: 4)
                                Text(d > 0 ? "+$\(String(format: "%.2f", d)) avg ticket lift when upsell used." : "Upsell lift not yet measurable.")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(d > 0 ? .inkGreen : .textMuted)
                            }
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }

            // ── Peak burst capacity card ──────────────────────────────────────
            if recentShifts.contains(where: { $0.peakBurstUpdated > 0 }) {
                let burstShifts = recentShifts.filter { $0.peakBurstUpdated > 0 }
                let maxBurst = burstShifts.map(\.peakBurstUpdated).max() ?? 0
                let avgBurst = burstShifts.map(\.peakBurstUpdated).reduce(0, +) / burstShifts.count
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            MonoLabel(text: "SOLO CAPACITY — PEAK BURST", color: .textMuted, size: 10)
                            Spacer()
                            MonoLabel(text: "CAPACITY SIGNAL", color: .textMuted, size: 9)
                        }
                        Text("Max tickets in any 30-min window. Determines solo viability ceiling.")
                            .font(.sora(11, weight: .light))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                        HStack(spacing: 0) {
                            let peakColor: Color = maxBurst <= 15 ? .inkGreen : maxBurst <= 22 ? .inkAmber : .inkRed
                            let avgColor: Color = avgBurst <= 15 ? .inkGreen : avgBurst <= 22 ? .inkAmber : .inkRed
                            econColumn("PEAK MAX", value: "\(maxBurst) tx", color: peakColor)
                            Divider().frame(height: 36).background(Color.muted.opacity(0.2)).padding(.horizontal, 12)
                            econColumn("AVG PEAK", value: "\(avgBurst) tx", color: avgColor)
                            Divider().frame(height: 36).background(Color.muted.opacity(0.2)).padding(.horizontal, 12)
                            econColumn("SHIFTS TRACKED", value: "\(burstShifts.count)", color: .textMuted)
                            Spacer()
                        }
                        Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                        let verdict: (String, Color) = maxBurst <= 15
                            ? ("Model scales. Solo ceiling not yet approached.", .inkGreen)
                            : maxBurst <= 22
                            ? ("Approaching solo ceiling. On-call staff ready.", .inkAmber)
                            : ("Solo ceiling hit. Reactive staff needed on peak days.", .inkRed)
                        HStack(spacing: 6) {
                            Circle().fill(verdict.1).frame(width: 4, height: 4)
                            Text(verdict.0)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(verdict.1)
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        MonoLabel(text: "SOURCE ATTRIBUTION TRACKER", color: .textMuted, size: 10)
                        Spacer()
                        MonoLabel(text: "2-WEEK STUDY", color: .inkAmber, size: 9)
                    }
                    Text("Ask every customer: 'How did you find us?' Tally marks. 2 weeks changes the strategy.")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)

                    VStack(spacing: 5) {
                        ForEach([
                            ("Walk-in unknown", "Baseline — where most starts"),
                            ("Google / Maps", "Digital working"),
                            ("Column board / sign", "Threshold signage working"),
                            ("Watermarc", "Residential thesis"),
                            ("SkyView / same-building", "Zero-motion adjacency"),
                            ("Salon", "Adjacent dwell conversion"),
                            ("Partnership / pickup", "Supply relationship converting"),
                            ("Referral / word of mouth", "Feed this engine"),
                            ("Repeat regular", "Retention signal"),
                        ], id: \.0) { src, note in
                            HStack(spacing: 10) {
                                Text(src)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.textSecond)
                                    .frame(width: 140, alignment: .leading)
                                Text(note)
                                    .font(.sora(10, weight: .light))
                                    .foregroundColor(.textMuted)
                                Spacer()
                            }
                        }
                    }

                    let shiftsWithSource = recentShifts.filter { !$0.sourceNotes.isEmpty }
                    if !shiftsWithSource.isEmpty {
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                        MonoLabel(text: "LOGGED NOTES", color: .textMuted, size: 9)
                        ForEach(shiftsWithSource.prefix(5)) { shift in
                            HStack(alignment: .top, spacing: 8) {
                                MonoLabel(text: shift.dayLabel, color: .warm, size: 9)
                                Text(shift.sourceNotes)
                                    .font(.sora(11, weight: .light))
                                    .foregroundColor(.textSecond)
                                    .lineSpacing(2)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // ── Weekly Revenue Composition Review ─────────────────────────
            // Run every Friday after close. 8–10 min. Philosophy without measurement drifts.
            // "Which revenue sources produced clean dollars this week — and which deserve
            //  more energy next week?" — BRICE_OPERATOR_PRODUCT_BRIEF.md, Section 3
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            MonoLabel(text: "WEEKLY REVENUE COMPOSITION", color: .inkAmber, size: 10)
                            Text("Friday after close · 8–10 min · which sources produced clean dollars?")
                                .font(.sora(10, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                        Spacer()
                        Button(action: { showWRCSheet = true }) {
                            HStack(spacing: 5) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 11))
                                MonoLabel(text: "REVIEW", color: .inkAmber, size: 9)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.inkAmber.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                    }

                    // Nervous system economics matrix header
                    HStack(spacing: 0) {
                        Text("SOURCE")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("REV")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .frame(width: 52, alignment: .trailing)
                        Text("STRESS")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .frame(width: 48, alignment: .trailing)
                        Text("REPEAT")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .frame(width: 48, alignment: .trailing)
                    }

                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                    let wrcRows: [(String, String, Int, String, Color)] = [
                        ("Walk-in hospitality",  wrcWalkinRev,      wrcWalkinStress,      wrcWalkinRepeat,      Color.textSecond),
                        ("Regular locals",       wrcRegularRev,     wrcRegularStress,     "high",               Color.inkGreen),
                        ("Watermarc referrals",  wrcWatermarcRev,   wrcWatermarcStress,   "medium",             Color.inkTeal),
                        ("Partnership / pickup", wrcPartnershipRev, wrcPartnershipStress, "high",               Color.inkGreen),
                        ("Sunday tail 3–5PM",    wrcSundayTailRev,  wrcSundayTailStress,  "medium",             Color.inkAmber),
                        ("Early AM 7–8AM",       wrcEarlyAmRev,     wrcEarlyAmStress,     "medium",             Color.inkAmber),
                    ]

                    VStack(spacing: 0) {
                        ForEach(wrcRows.indices, id: \.self) { idx in
                            let row = wrcRows[idx]
                            HStack(spacing: 0) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(row.4.opacity(row.1.isEmpty ? 0.2 : 0.7))
                                        .frame(width: 5, height: 5)
                                    Text(row.0)
                                        .font(.sora(11))
                                        .foregroundColor(row.1.isEmpty ? .textMuted : .textPrimary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Text(row.1.isEmpty ? "—" : "$\(row.1)")
                                    .font(.system(size: 11, weight: row.1.isEmpty ? .regular : .semibold, design: .monospaced))
                                    .foregroundColor(row.1.isEmpty ? .textMuted : .textPrimary)
                                    .frame(width: 52, alignment: .trailing)
                                // Stress dot
                                Group {
                                    if row.2 == 0 {
                                        Text("—")
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(.textMuted)
                                    } else {
                                        let sc: Color = row.2 <= 3 ? .inkGreen : row.2 <= 6 ? .inkAmber : .inkRed
                                        Text("\(row.2)/10")
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(sc)
                                    }
                                }
                                .frame(width: 48, alignment: .trailing)
                                Text(row.3)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.textMuted)
                                    .frame(width: 48, alignment: .trailing)
                            }
                            .padding(.vertical, 7)
                            if idx < wrcRows.count - 1 {
                                Rectangle().fill(Color.muted.opacity(0.08)).frame(height: 0.5)
                            }
                        }
                    }

                    // This-week verdict
                    let allRevEmpty = [wrcWalkinRev, wrcRegularRev, wrcWatermarcRev, wrcPartnershipRev, wrcSundayTailRev, wrcEarlyAmRev].allSatisfy { $0.isEmpty }
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    if allRevEmpty {
                        HStack(spacing: 6) {
                            Circle().fill(Color.inkAmber.opacity(0.5)).frame(width: 4, height: 4)
                            Text("Tap REVIEW every Friday after close. 8 minutes. The data you don't collect can't inform the decision.")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                    } else {
                        // Auto-derive the cleanest source this week
                        let filledRevs: [(String, String)] = [
                            ("Walk-in hospitality", wrcWalkinRev),
                            ("Regular locals", wrcRegularRev),
                            ("Watermarc referrals", wrcWatermarcRev),
                            ("Partnership / pickup", wrcPartnershipRev),
                            ("Sunday tail 3–5PM", wrcSundayTailRev),
                            ("Early AM 7–8AM", wrcEarlyAmRev),
                        ].filter { !$0.1.isEmpty }
                        let totalRev = filledRevs.compactMap { Double($0.1) }.reduce(0, +)
                        HStack(spacing: 6) {
                            Circle().fill(Color.inkGreen.opacity(0.6)).frame(width: 4, height: 4)
                            Text("Week total tracked: ~$\(Int(totalRev)). Double down on whichever source has lowest stress AND non-zero revenue.")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)
            .sheet(isPresented: $showWRCSheet) {
                WeeklyRevenueCompositionSheet(
                    isPresented: $showWRCSheet,
                    weekLabel: $wrcWeekLabel,
                    walkinRev: $wrcWalkinRev,     walkinStress: $wrcWalkinStress,
                    regularRev: $wrcRegularRev,   regularStress: $wrcRegularStress,
                    watermarcRev: $wrcWatermarcRev, watermarcStress: $wrcWatermarcStress,
                    partnershipRev: $wrcPartnershipRev, partnershipStress: $wrcPartnershipStress,
                    sundayTailRev: $wrcSundayTailRev,   sundayTailStress: $wrcSundayTailStress,
                    earlyAmRev: $wrcEarlyAmRev,         earlyAmStress: $wrcEarlyAmStress
                )
            }

            Spacer(minLength: 100)
        }
        .padding(.top, 16)
    }

    // MARK: - PLAYBOOK

    var playbookView: some View {
        VStack(spacing: 14) {

            // ── Loan Decision Stack ──────────────────────────────────────────
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        MonoLabel(text: "LOAN DECISION — JUNE 13", color: .warm, size: 10)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(daysToDecision)")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(.warm)
                            Text("days")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.warm.opacity(0.6))
                        }
                    }
                    Text("Decision made from data, not desperation.")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)

                    // Q01 — dynamic, data-driven
                    interactiveDecisionQ(
                        num: "01",
                        question: "30-day avg trending toward $550+?",
                        answer: thirtyDayAvg >= 550
                            ? "YES — $\(Int(thirtyDayAvg)) avg"
                            : thirtyDayAvg > 0 ? "NOT YET — $\(Int(thirtyDayAvg)) avg"
                            : "No data yet",
                        green: thirtyDayAvg >= 550,
                        isAnswered: thirtyDayAvg > 0,
                        isTappable: false,
                        answerText: .constant(""),
                        showInput: .constant(false),
                        onTap: {}
                    )

                    Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)

                    // Q02 — tappable
                    interactiveDecisionQ(
                        num: "02",
                        question: "Capital has a specific revenue-generating purpose?",
                        answer: decisionQ02Answered ? decisionQ02Text : "Tap to answer before June 13",
                        green: decisionQ02Answered,
                        isAnswered: decisionQ02Answered,
                        isTappable: true,
                        answerText: $decisionQ02Text,
                        showInput: $showQ02Input,
                        onTap: { withAnimation(.spring(response: 0.3)) { showQ02Input.toggle() } }
                    )
                    if showQ02Input {
                        HStack(spacing: 10) {
                            TextField("e.g. equipment, signage, event", text: $decisionQ02Text)
                                .font(.sora(13)).foregroundColor(.textPrimary)
                                .padding(12).background(Color.surface2)
                                .clipShape(RoundedRectangle(cornerRadius: 8)).tint(.warm)
                            Button {
                                decisionQ02Answered = !decisionQ02Text.isEmpty
                                withAnimation(.spring(response: 0.3)) { showQ02Input = false }
                            } label: {
                                Image(systemName: decisionQ02Text.isEmpty ? "xmark" : "checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(decisionQ02Text.isEmpty ? .textMuted : .inkGreen)
                                    .frame(width: 36, height: 36)
                                    .background(decisionQ02Text.isEmpty ? Color.surface2 : Color.inkGreen.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)

                    // Q03 — tappable toggle
                    interactiveDecisionQ(
                        num: "03",
                        question: "Decision being made from stability, not crisis?",
                        answer: decisionQ03Answered ? "CONFIRMED — deciding from data" : "Tap to confirm when ready",
                        green: decisionQ03Answered,
                        isAnswered: decisionQ03Answered,
                        isTappable: true,
                        answerText: .constant(""),
                        showInput: .constant(false),
                        onTap: { withAnimation(.spring(response: 0.3)) { decisionQ03Answered.toggle() } }
                    )

                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Bridge vs. anesthesia. Debt that funds restructuring is defensible. Debt that delays reckoning is not.")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // ── Discovery Friction Audit ─────────────────────────────────────
            let allFrictionItems: [(String, Binding<Bool>)] = [
                ("Can a stranger on the street tell Hideout exists?", $frictionStreetVisible),
                ("Obvious within 3 seconds?", $frictionObvious3sec),
                ("Column boards installed on menu column face?", $frictionStreetSignage),  // repurposed: now tracks boards, not street sign
                ("Elevator access to the patio — obvious?", $frictionElevatorObvious),
                ("Building residents explicitly told Hideout exists?", $frictionResidentsTold),
                ("QR code or menu visible from lobby?", $frictionQRLobby),
                ("Watermarc leasing team introduced?", $frictionWatermarcLeasing),
                ("Watermarc concierge briefed?", $frictionWatermarcConcierge),
                ("Walking path from Watermarc frictionless?", $frictionWatermarcPath),
            ]
            let completedCount = allFrictionItems.filter { $0.1.wrappedValue }.count
            let totalCount = allFrictionItems.count

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        MonoLabel(text: "DISCOVERY FRICTION AUDIT", color: .textMuted, size: 10)
                        Spacer()
                        // Progress pill
                        HStack(spacing: 6) {
                            Text("\(completedCount)/\(totalCount)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(completedCount == totalCount ? .inkGreen : completedCount > 0 ? .inkAmber : .textMuted)
                            if completedCount == totalCount {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.inkGreen)
                            }
                        }
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.surface).frame(height: 3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(completedCount == totalCount ? Color.inkGreen : Color.inkAmber)
                                .frame(width: totalCount > 0 ? geo.size.width * CGFloat(completedCount) / CGFloat(totalCount) : 0, height: 3)
                                .animation(.spring(response: 0.4), value: completedCount)
                        }
                    }
                    .frame(height: 3)

                    Text("Solve physical friction before digital amplification. Tap each item as you complete it.")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)

                    VStack(spacing: 0) {
                        ForEach(allFrictionItems.indices, id: \.self) { idx in
                            let item = allFrictionItems[idx]
                            Button {
                                withAnimation(.spring(response: 0.25)) { item.1.wrappedValue.toggle() }
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(item.1.wrappedValue ? Color.inkGreen.opacity(0.15) : Color.surface)
                                            .frame(width: 20, height: 20)
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(item.1.wrappedValue ? Color.inkGreen : Color.muted.opacity(0.4), lineWidth: 1.5)
                                            .frame(width: 20, height: 20)
                                        if item.1.wrappedValue {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.inkGreen)
                                        }
                                    }
                                    Text(item.0)
                                        .font(.sora(12, weight: .light))
                                        .foregroundColor(item.1.wrappedValue ? .textMuted : .textSecond)
                                        .lineSpacing(2)
                                        .strikethrough(item.1.wrappedValue, color: .textMuted.opacity(0.5))
                                    Spacer()
                                }
                                .padding(.vertical, 9)
                            }
                            .buttonStyle(.plain)
                            if idx < allFrictionItems.count - 1 {
                                Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // MARK: — GROWTH SYSTEM (Locked May 2026)
            let growthSystem1Items: [(String, Binding<Bool>)] = [
                ("Design card in Canva — exact copy locked", $growthCardDesigned),
                ("Place print order (50–100, matte 16pt, Vistaprint)", $growthCardPrinted),
                ("Deliver to Watermarc front desk with coffee/pastries", $growthCardDelivered),
            ]
            let growthSystem2Items: [(String, Binding<Bool>)] = [
                ("Respond to 4 unread reviews (name + specific + invite)", $growthGBPReviews),
                ("Complete profile: hours, description, attributes", $growthGBPProfile),
                ("Upload photos: patio → entrance → plate → coffee", $growthGBPPhotos),
            ]
            let growthSystem3Items: [(String, Binding<Bool>)] = [
                ("Print TOP board: 24×24 matte Dibond — FIRST TIME? START HERE", $growthBoardTopOrdered),
                ("Print BOTTOM board: 24×18 matte Dibond — MADE WITH REAL THINGS", $growthBoardBotOrdered),
                ("Install both boards on column (menu face, above + below menu card)", $growthBoardsInstalled),
            ]
            let growthSystem4Items: [(String, Binding<Bool>)] = [
                ("Film Monday clip before 7 AM (7-shot fixed list)", $growthVideoFilmed),
                ("Post to GBP + Reels + TikTok — same file, 3 surfaces", $growthVideoPosted),
            ]

            let allGrowthItems = growthSystem1Items + growthSystem2Items + growthSystem3Items + growthSystem4Items
            let growthDone = allGrowthItems.filter { $0.1.wrappedValue }.count
            let growthTotal = allGrowthItems.count

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            MonoLabel(text: "GROWTH SYSTEM — LOCKED MAY 2026", color: .inkTeal, size: 10)
                            Text("Gap closes through revenue quality, not volume. Recurring revenue reduces walk-in dependency. Pickup-first: production business, not delivery route.")
                                .font(.sora(10, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(growthDone)/\(growthTotal)")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(growthDone == growthTotal ? .inkGreen : growthDone > 0 ? .inkAmber : .textMuted)
                            if growthDone == growthTotal {
                                MonoLabel(text: "SYSTEM LIVE", color: .inkGreen, size: 9)
                            }
                        }
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.surface).frame(height: 3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(growthDone == growthTotal ? Color.inkGreen : Color.inkTeal)
                                .frame(width: growthTotal > 0 ? geo.size.width * CGFloat(growthDone) / CGFloat(growthTotal) : 0, height: 3)
                                .animation(.spring(response: 0.4), value: growthDone)
                        }
                    }
                    .frame(height: 3)

                    growthSystemSection("01  WATERMARC CARD", items: growthSystem1Items,
                        note: "Code: WATERMARC · QR → GBP · matte credit-card · hospitality, not coupon")
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    growthSystemSection("02  GOOGLE BUSINESS PROFILE", items: growthSystem2Items,
                        note: "Primary digital channel. 316 reviews, 4.7★. Freshness compounds.")
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    growthSystemSection("03  COLUMN BOARDS — LOCKED", items: growthSystem3Items,
                        note: "TOP: FIRST TIME? START HERE. BOTTOM: MADE WITH REAL THINGS + SAVE THIS SPOT QR. Matte Dibond only. Door strips = dead.")
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    growthSystemSection("04  MONDAY CONTENT LOOP", items: growthSystem4Items,
                        note: "One 20–30s clip before opening. Same shot list. 3 surfaces, no decisions.")

                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    HStack(spacing: 6) {
                        Circle().fill(Color.inkTeal.opacity(0.6)).frame(width: 4, height: 4)
                        Text("Signal: attribution mentions appear in weekly review. Any is better than none.")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "IF $1,000 AVAILABLE — VISIBILITY ALLOCATION", color: .textMuted, size: 10)
                    VStack(spacing: 8) {
                        ForEach([
                            ("$120", "Column boards (Dibond print x2)", "FIRST TIME? top + MADE WITH REAL THINGS bottom. This week."),
                            ("$150", "Lobby/elevator resident presence", "Framed menu where residents see it daily."),
                            ("$150", "Resident activation offer", "First-visit hook for residents who haven't been."),
                            ("$150", "Professional photography", "Google profile + Instagram. Quality signal."),
                            ("$430", "Remaining — hold", "Do not spend until column boards show attribution signal."),
                        ], id: \.0) { amt, title, note in
                            HStack(alignment: .top, spacing: 10) {
                                Text(amt)
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.warm)
                                    .frame(width: 44, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(title).font(.sora(12, weight: .light)).foregroundColor(.textPrimary)
                                    Text(note).font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // MARK: — 14-DAY PARTNERSHIP SPRINT
            let sprintItems: [(String, Binding<Bool>)] = [
                ("Day 1: Define offer as pickup-first — 'accounts come to Hideout.' Print cards + make 3 sample bottles", $sprintOfferDefined),
                ("Day 2: Watermarc front desk — 2 samples, leave cards, ask who does amenities", $sprintWatermarcDesk),
                ("Day 3: Watermarc leasing office — 1 sample + food, tour-flow pitch", $sprintWatermarcLeasing),
                ("Day 4: Expansive Biscayne — 2 samples, ask for member experience contact", $sprintExpansive),
                ("Day 5: SkyView 22 concierge — 1 sample, zero-friction adjacency", $sprintSkyview),
                ("Day 6: Follow-up #1 — Watermarc + Expansive, move toward trial", $sprintFollowup1),
                ("Day 8: A Better You salon — 1 sample, corridor neighbor offer", $sprintSalon),
                ("Day 9: Follow-up #2 Expansive — propose trial week, no commitment", $sprintFollowup2),
                ("Day 12: Close first account — warmest lead, lock weekly schedule", $sprintFirstAccount),
                ("Day 13: First delivery — 1 gallon, cups, cards, say nothing else", $sprintFirstDelivery),
                ("Day 14: Convert trial to weekly invoice", $sprintConvertedWeekly),
            ]
            let sprintDone = sprintItems.filter { $0.1.wrappedValue }.count
            let sprintTotal = sprintItems.count
            let sprintComplete = sprintDone == sprintTotal

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            MonoLabel(text: "CURRENT EXPERIMENT — PARTNERSHIP SPRINT", color: .inkAmber, size: 10)
                            Text("Hypothesis: one recurring cold brew account materially changes the economics. Activate when mobility allows.")
                                .font(.sora(10, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(sprintDone)/\(sprintTotal)")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(sprintComplete ? .inkGreen : sprintDone > 0 ? .inkAmber : .textMuted)
                            if sprintComplete {
                                MonoLabel(text: "ACCOUNT LIVE", color: .inkGreen, size: 9)
                            }
                        }
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.surface).frame(height: 3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(sprintComplete ? Color.inkGreen : Color.inkAmber)
                                .frame(width: sprintTotal > 0 ? geo.size.width * CGFloat(sprintDone) / CGFloat(sprintTotal) : 0, height: 3)
                                .animation(.spring(response: 0.4), value: sprintDone)
                        }
                    }
                    .frame(height: 3)

                    VStack(spacing: 8) {
                        ForEach(Array(sprintItems.enumerated()), id: \.offset) { _, item in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: item.1.wrappedValue ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 14))
                                    .foregroundColor(item.1.wrappedValue ? .inkGreen : .textMuted)
                                    .onTapGesture { item.1.wrappedValue.toggle() }
                                Text(item.0)
                                    .font(.sora(11, weight: .light))
                                    .foregroundColor(item.1.wrappedValue ? .textMuted : .textSecond)
                                    .lineSpacing(2)
                                    .strikethrough(item.1.wrappedValue, color: .textMuted)
                                Spacer()
                            }
                        }
                    }

                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.inkAmber.opacity(0.6)).frame(width: 4, height: 4)
                            Text("Outreach windows: 7–9:30AM or 2:30–5PM. Never during hospitality mode.")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                        HStack(spacing: 6) {
                            Circle().fill(Color.inkAmber.opacity(0.6)).frame(width: 4, height: 4)
                            Text("Injury constraint: outreach prep (offer, samples, cards) now. Active delivery onboarding after rhythm stabilizes 10–14 more days.")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                        HStack(spacing: 6) {
                            Circle().fill(Color.inkGreen.opacity(0.6)).frame(width: 4, height: 4)
                            Text("Pickup-first doctrine: all accounts structured as production + scheduled pickup. No route delivery.")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                        HStack(spacing: 6) {
                            Circle().fill(Color.inkGreen.opacity(0.6)).frame(width: 4, height: 4)
                            Text("Tier A (zero-motion): A Better You, SkyView. Tier B (trivial-motion): Expansive pickup, Watermarc. Fastest conversion = hypothesis, not fact.")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "STAFFING RULE", color: .textMuted, size: 10)
                    Text("Do not schedule staff speculatively. One trusted person available to text. Call only if rush is unmanageable. Pay only when called.")
                        .font(.sora(12, weight: .light))
                        .foregroundColor(.textSecond)
                        .lineSpacing(3)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "STAFFED $400", color: .inkRed, size: 10)
                            Text("~$5–90 contribution")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.textMuted)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "SOLO $400", color: .inkGreen, size: 10)
                            Text("~$190–290 contribution")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.textMuted)
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 16)
    }

    // MARK: - Helper views

    func weekRow(week: Int) -> some View {
        let days = ["W", "Th", "F", "Sa", "Su"]
        let weekStart = (week - 1) * 5 + 1
        return VStack(alignment: .leading, spacing: 6) {
            MonoLabel(text: "WEEK \(week)", color: .textMuted, size: 9)
            HStack(spacing: 6) {
                ForEach(days.indices, id: \.self) { i in
                    let dayNum = weekStart + i
                    let shift = recentShifts.first { $0.experimentDay == dayNum }
                    VStack(spacing: 3) {
                        Text(days[i])
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.textMuted)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shift != nil ? HideoutPlanningBand.classify(shift!.grossRevenue).color.opacity(0.25) : Color.surface2)
                            .frame(height: 28)
                            .overlay(
                                Text(shift != nil ? "$\(Int(shift!.grossRevenue))" : (dayNum <= experimentDay ? "—" : ""))
                                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                                    .foregroundColor(shift != nil ? HideoutPlanningBand.classify(shift!.grossRevenue).color : .textMuted)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(dayNum == experimentDay ? Color.warm.opacity(0.5) : Color.clear, lineWidth: 1.5)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            let weekShifts = recentShifts.filter { $0.experimentDay >= weekStart && $0.experimentDay <= weekStart + 4 }
            if !weekShifts.isEmpty {
                HStack {
                    Spacer()
                    Text("Total: $\(Int(weekShifts.map(\.grossRevenue).reduce(0,+)))")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.textMuted)
                }
            }
        }
    }

    func econColumn(_ label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            MonoLabel(text: label, color: .textMuted, size: 9)
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
        }
    }

    func gapRow(_ label: String, target: Double, current: Double, bandColor: Color) -> some View {
        let gap = max(0, target - current)
        // Show revenue gap — not tx count. Brief retired the tx-volume framing.
        // "Which revenue sources close the gap at lowest nervous-system cost?" is the right question.
        let achieved = current > 0 && current >= target
        return HStack(spacing: 10) {
            HStack(spacing: 5) {
                Circle().fill(achieved ? bandColor : Color.textMuted.opacity(0.3)).frame(width: 5, height: 5)
                Text(label).font(.sora(12)).foregroundColor(achieved ? .textPrimary : .textMuted)
            }
            Spacer()
            if achieved {
                MonoLabel(text: "REACHED", color: bandColor, size: 9)
            } else if current > 0 {
                MonoLabel(text: "-$\(Int(gap.rounded()))", color: .textMuted, size: 9)
            } else {
                MonoLabel(text: "$\(Int(target))/day", color: .textMuted, size: 9)
            }
        }
        .padding(.vertical, 8)
    }

    func techniqueRow(_ label: String, count: Int, total: Int, note: String) -> some View {
        let pct = total > 0 ? Double(count) / Double(total) : 0
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 11, weight: .medium, design: .monospaced)).foregroundColor(.textPrimary)
                Text(note).font(.sora(10, weight: .light)).foregroundColor(.textMuted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(count)/\(total)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(pct >= 0.7 ? .inkGreen : pct >= 0.4 ? .inkAmber : .textMuted)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(height: 3)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(pct >= 0.7 ? Color.inkGreen : pct >= 0.4 ? Color.inkAmber : Color.textMuted)
                            .frame(width: geo.size.width * min(1, CGFloat(pct)), height: 3)
                    }
                }
                .frame(width: 50, height: 3)
            }
        }
    }

    func growthSystemSection(_ label: String, items: [(String, Binding<Bool>)], note: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            MonoLabel(text: label, color: .inkTeal.opacity(0.8), size: 9)
            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { idx in
                    let item = items[idx]
                    Button {
                        withAnimation(.spring(response: 0.25)) { item.1.wrappedValue.toggle() }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(item.1.wrappedValue ? Color.inkTeal.opacity(0.15) : Color.surface)
                                    .frame(width: 18, height: 18)
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(item.1.wrappedValue ? Color.inkTeal : Color.muted.opacity(0.4), lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                                if item.1.wrappedValue {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.inkTeal)
                                }
                            }
                            Text(item.0)
                                .font(.sora(11, weight: .light))
                                .foregroundColor(item.1.wrappedValue ? .textMuted : .textSecond)
                                .lineSpacing(2)
                                .strikethrough(item.1.wrappedValue, color: .textMuted.opacity(0.4))
                            Spacer()
                        }
                        .padding(.vertical, 7)
                    }
                    .buttonStyle(.plain)
                    if idx < items.count - 1 {
                        Rectangle().fill(Color.muted.opacity(0.08)).frame(height: 0.5)
                    }
                }
            }
            Text(note)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.textMuted.opacity(0.7))
                .lineSpacing(1.5)
        }
    }

    func pAction(_ timing: String, _ text: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            MonoLabel(text: timing, color: color, size: 9).frame(width: 72, alignment: .leading)
            Text(text).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2)
            Spacer()
        }
    }

    func interactiveDecisionQ(
        num: String, question: String, answer: String, green: Bool,
        isAnswered: Bool, isTappable: Bool,
        answerText: Binding<String>, showInput: Binding<Bool>,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: isTappable ? onTap : {}) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top, spacing: 8) {
                    MonoLabel(text: num, color: isAnswered ? .inkGreen : .warm, size: 11)
                    Text(question).font(.sora(12, weight: .light)).foregroundColor(.textPrimary).lineSpacing(2)
                    Spacer()
                    if isTappable {
                        Image(systemName: isAnswered ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundColor(isAnswered ? .inkGreen : .textMuted)
                    }
                }
                HStack {
                    Spacer()
                    Text(answer)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(green ? .inkGreen : .textMuted)
                }
            }
        }
        .buttonStyle(.plain)
    }

    func decisionQ(_ num: String, _ q: String, answer: String, green: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                MonoLabel(text: num, color: .warm, size: 11)
                Text(q).font(.sora(12, weight: .light)).foregroundColor(.textPrimary).lineSpacing(2)
            }
            HStack {
                Spacer()
                Text(answer)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(green ? .inkGreen : .textMuted)
            }
        }
    }


    // MARK: - INTEL TAB
    // Experiment Ledger — every active hypothesis with pass/fail and mechanism.
    // Cards are collapsed by default. Tap to expand. Clean, not busy.
    // "Doctrine vs hypothesis: principles are durable, tactics are provisional."

    var intelView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Header ────────────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "EXPERIMENT LEDGER", color: .warm, size: 10)
                            Text("Provisional hypotheses. Each runs until the data decides, then closes.")
                                .font(.sora(12, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2.5)
                        }
                        Spacer()
                        HStack(spacing: 12) {
                            legendDot("ACTIVE", color: .inkGreen)
                            legendDot("PENDING", color: .inkAmber)
                            legendDot("CLOSED", color: .textMuted)
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                    .padding(.horizontal, metrics.hPad)
                    .padding(.bottom, 16)

                // ── Experiment cards ──────────────────────────────────────────
                VStack(spacing: 12) {
                    experimentCard(
                        id: "7am",
                        name: "7AM WEEKDAY OPEN",
                        signal: "4–6 wks",
                        status: $exp7amStatus,
                        note: $exp7amNote,
                        isExpanded: $exp7amExpanded,
                        hypothesis: "Earlier open captures building commuters and regulars who'd skip a later start. Tests whether a 7–8AM customer archetype exists in this building population.",
                        pass: "5+ recurring 7–8AM customer types identified within 4 weeks",
                        fail: "Zero 7–8AM revenue after 4 full weeks of consistent execution",
                        mechanism: "Habit formation requires a consistent environmental cue. 7AM open creates that cue. Four weeks is enough to tell whether the archetype exists here — it either forms or it doesn't."
                    )
                    experimentCard(
                        id: "sunday",
                        name: "SUNDAY EXTENSION TO 5PM",
                        signal: "2 wks",
                        status: $expSundayStatus,
                        note: $expSundayNote,
                        isExpanded: $expSundayExpanded,
                        hypothesis: "Brice already inhabits the space Sunday afternoons. Extending from 3→5PM captures tail revenue at near-zero incremental cost — Operator Studio mode.",
                        pass: "Any incremental revenue 3–5PM + stress stays ≤3",
                        fail: "Stress rises OR zero customers in 3–5PM window after 2 weeks",
                        mechanism: "If the operator naturally inhabits the asset, compatible monetization costs nothing. The only question is whether the customer population exists in that window. Stress score is the kill signal — if it rises, the model isn't working."
                    )
                    experimentCard(
                        id: "watermarc",
                        name: "WATERMARC RESIDENTIAL CAPTURE",
                        signal: "2 wks",
                        status: $expWatermarcStatus,
                        note: $expWatermarcNote,
                        isExpanded: $expWatermarcExpanded,
                        hypothesis: "Front desk engagement + leave-behind cards converts luxury neighbors into recurring regulars. The relationship is already warm — front desk proactively suggested the leave-behind.",
                        pass: "5 attributed visits/week from card redemption or front-desk referral",
                        fail: "0–1 attributed visits after 2 full weeks of consistent card presence",
                        mechanism: "Proximity + warm introduction = highest conversion probability of any acquisition channel. Card includes first-visit offer (complimentary drink with breakfast) to lower friction on the initial decision."
                    )
                    experimentCard(
                        id: "coldbrew",
                        name: "COLD BREW — FIRST RECURRING ACCOUNT",
                        signal: "60 days",
                        status: $expColdBrewStatus,
                        note: $expColdBrewNote,
                        isExpanded: $expColdBrewExpanded,
                        hypothesis: "One recurring weekly cold brew pickup account materially changes revenue composition. One invoice can be economically superior to many chaotic walk-ins.",
                        pass: "2 recurring weekly accounts beyond Jimmy within 60 days",
                        fail: "No meetings convert after 3 outreach attempts per target",
                        mechanism: "Pickup-first doctrine: production + scheduled pickup = zero logistics stress. One $45/gallon weekly account = $180/month clean recurring revenue with no table management or route complexity."
                    )
                    experimentCard(
                        id: "concierge",
                        name: "CONCIERGE REFERRAL — SKYVIEW 22",
                        signal: "4 wks",
                        status: $expConciergeStatus,
                        note: $expConciergeNote,
                        isExpanded: $expConciergeExpanded,
                        hypothesis: "SkyView 22 concierge proactively mentioning Hideout in building tours converts a zero-effort distribution channel. 258 units. Same elevator.",
                        pass: "Concierge-sourced visit confirmed ('concierge recommended you')",
                        fail: "No concierge-sourced mentions after 4 weeks of relationship maintenance",
                        mechanism: "Concierge referrals carry implicit trust from the building relationship. A new resident who hears about Hideout from their concierge arrives warmer than any cold walk-in. Cost: a card stack in the lobby."
                    )
                }
                .padding(.horizontal, metrics.hPad)

                // ── Doctrine (the non-provisional principles) ─────────────────
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "DOCTRINE — NOT EXPERIMENTS", color: .textMuted, size: 10)
                        Text("These don't have pass/fail conditions. They're not provisional.")
                            .font(.sora(11, weight: .light))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                        VStack(alignment: .leading, spacing: 8) {
                            doctrineRow("Recurring revenue reduces walk-in dependency")
                            doctrineRow("Pickup-first: production business, not delivery route")
                            doctrineRow("Nervous-system cost is a real economic input — not soft")
                            doctrineRow("Hospitality quality is the soul. Other modes weaken without it.")
                            doctrineRow("Data decides. Romance of the space doesn't excuse bad economics.")
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
                .padding(.top, 12)

                Spacer(minLength: 100)
            }
        }
    }

    // MARK: - INTEL HELPER VIEWS

    func experimentCard(
        id: String,
        name: String,
        signal: String,
        status: Binding<String>,
        note: Binding<String>,
        isExpanded: Binding<Bool>,
        hypothesis: String,
        pass: String,
        fail: String,
        mechanism: String
    ) -> some View {
        let s = status.wrappedValue
        let statusColor: Color = s == "active"   ? .inkGreen
                               : s == "pending"  ? .inkAmber
                               : s == "complete" ? .inkTeal
                               : s == "killed"   ? .inkRed
                               : .textMuted  // modified / other
        let isClosed = s == "killed" || s == "complete"

        return VStack(spacing: 0) {
            // ── Collapsed header row (always visible) ──────────────────────
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    // Status pip
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(name)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(isClosed ? .textMuted : .textPrimary)
                            .tracking(0.5)
                        HStack(spacing: 8) {
                            Text(s.uppercased())
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(statusColor)
                            Text("·")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.textMuted)
                            Text("SIGNAL \(signal)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.textMuted)
                        }
                    }

                    Spacer()

                    // Note indicator
                    if !note.wrappedValue.isEmpty {
                        Image(systemName: "note.text")
                            .font(.system(size: 11))
                            .foregroundColor(.inkAmber.opacity(0.7))
                    }

                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textMuted)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // ── Expanded body ──────────────────────────────────────────────
            if isExpanded.wrappedValue {
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)
                        .padding(.horizontal, 18)

                    VStack(alignment: .leading, spacing: 20) {

                        // Hypothesis
                        VStack(alignment: .leading, spacing: 6) {
                            MonoLabel(text: "HYPOTHESIS", color: .textMuted, size: 9)
                            Text(hypothesis)
                                .font(.sora(12, weight: .light))
                                .foregroundColor(.textSecond)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Pass / Fail — side by side, visually beautiful
                        HStack(alignment: .top, spacing: 0) {
                            // PASS
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(Color.inkGreen)
                                        .frame(width: 2, height: 12)
                                    MonoLabel(text: "PASS", color: .inkGreen, size: 9)
                                }
                                Text(pass)
                                    .font(.sora(11, weight: .light))
                                    .foregroundColor(.inkGreen.opacity(0.8))
                                    .lineSpacing(2.5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.inkGreen.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            Spacer().frame(width: 8)

                            // FAIL
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(Color.inkRed)
                                        .frame(width: 2, height: 12)
                                    MonoLabel(text: "FAIL", color: .inkRed, size: 9)
                                }
                                Text(fail)
                                    .font(.sora(11, weight: .light))
                                    .foregroundColor(.inkRed.opacity(0.8))
                                    .lineSpacing(2.5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.inkRed.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Mechanism
                        VStack(alignment: .leading, spacing: 6) {
                            MonoLabel(text: "MECHANISM", color: .textMuted, size: 9)
                            Text(mechanism)
                                .font(.sora(11, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Status picker + note
                        HStack(alignment: .top, spacing: 10) {
                            // Status pill picker
                            Menu {
                                Button("Active")   { status.wrappedValue = "active" }
                                Button("Pending")  { status.wrappedValue = "pending" }
                                Button("Modified") { status.wrappedValue = "modified" }
                                Button("Complete") { status.wrappedValue = "complete" }
                                Button("Killed")   { status.wrappedValue = "killed" }
                            } label: {
                                HStack(spacing: 6) {
                                    Circle().fill(statusColor).frame(width: 6, height: 6)
                                    Text(s.uppercased())
                                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                        .foregroundColor(statusColor)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(.textMuted)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(statusColor.opacity(0.1))
                                .clipShape(Capsule())
                            }

                            // Decision note inline
                            TextField("Decision or observation…", text: note, axis: .vertical)
                                .font(.sora(11))
                                .foregroundColor(.textPrimary)
                                .lineLimit(1...3)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.surface2)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .tint(.warm)
                        }

                    }
                    .padding(18)
                    .padding(.top, 4)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isExpanded.wrappedValue ? statusColor.opacity(0.25) : Color.muted.opacity(0.15), lineWidth: 1)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isExpanded.wrappedValue)
    }

    func legendDot(_ label: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.textMuted)
        }
    }

    func doctrineRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.warm.opacity(0.4))
                .frame(width: 2, height: 14)
                .padding(.top, 2)
            Text(text)
                .font(.sora(12, weight: .light))
                .foregroundColor(.textSecond)
                .lineSpacing(2.5)
        }
    }

} // end HideoutTabView

// MARK: - REVENUE SPARKLINE

struct RevenueSparkline: View {
    let shifts: [HideoutShiftLog]
    var maxRevenue: Double { max(800, (shifts.map(\.grossRevenue).max() ?? 0) * 1.1) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let rev = Array(shifts.reversed())
            let count = rev.count
            let spacing: CGFloat = count > 1 ? w / CGFloat(count - 1) : w

            ZStack {
                // Reference lines
                ForEach([(520, Color.inkRed), (590, Color.inkAmber), (650, Color.inkGreen), (750, Color.violetLight)], id: \.0) { tgt, color in
                    let y = h - CGFloat(Double(tgt) / maxRevenue) * h
                    Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: w, y: y)) }
                        .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: 0.8, dash: [4, 4]))
                }
                // Area
                if count >= 2 {
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: h))
                        for (i, s) in rev.enumerated() {
                            let x = CGFloat(i) * spacing
                            let y = h - CGFloat(s.grossRevenue / maxRevenue) * h
                            if i == 0 { p.addLine(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        p.addLine(to: CGPoint(x: CGFloat(count-1) * spacing, y: h))
                        p.closeSubpath()
                    }
                    .fill(LinearGradient(colors: [Color.warm.opacity(0.18), Color.clear], startPoint: .top, endPoint: .bottom))

                    Path { p in
                        for (i, s) in rev.enumerated() {
                            let pt = CGPoint(x: CGFloat(i) * spacing, y: h - CGFloat(s.grossRevenue / maxRevenue) * h)
                            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                        }
                    }
                    .stroke(Color.warm, lineWidth: 1.5)
                }
                // Dots
                ForEach(rev.indices, id: \.self) { i in
                    let s = rev[i]
                    Circle()
                        .fill(HideoutPlanningBand.classify(s.grossRevenue).color)
                        .frame(width: 5, height: 5)
                        .position(x: CGFloat(i) * spacing, y: h - CGFloat(s.grossRevenue / maxRevenue) * h)
                }
            }
        }
    }
}

// MARK: - TREND

enum TrendDirection {
    case up, down, flat, unknown
    var label: String {
        switch self {
        case .up: return "↑ TRENDING UP"; case .down: return "↓ TRENDING DOWN"
        case .flat: return "→ FLAT"; case .unknown: return "— BUILDING DATA"
        }
    }
    var color: Color {
        switch self {
        case .up: return .inkGreen; case .down: return .inkRed
        case .flat: return .inkAmber; case .unknown: return .textMuted
        }
    }
}

// MARK: - SHIFT LOG ROW

struct ShiftLogRow: View {
    @Bindable var shift: HideoutShiftLog
    @Environment(\.appMetrics) private var metrics
    @State private var showEdit = false

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            MonoLabel(text: shift.dayLabel, color: shift.planningBand.color, size: 10)
                            MonoLabel(text: "DAY \(shift.experimentDay)", color: .textMuted, size: 9)
                        }
                        Text("$\(Int(shift.grossRevenue))")
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(shift.transactionCount) tx")
                            .font(.system(size: 12, design: .monospaced)).foregroundColor(.textMuted)
                        if shift.averageTicket > 0 {
                            Text("$\(String(format: "%.2f", shift.averageTicket)) avg")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(shift.averageTicket >= 17.29 ? .inkGreen : .inkAmber)
                        }
                        if shift.estimatedContribution > 0 {
                            Text("+$\(Int(shift.estimatedContribution)) contrib")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.inkGreen.opacity(0.7))
                        }
                    }
                    Button(action: { showEdit = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11)).foregroundColor(.textMuted)
                            .frame(width: 26, height: 26).background(Color.surface2).clipShape(Circle())
                    }
                    .padding(.leading, 8)
                }

                HStack(spacing: 10) {
                    if shift.stressScore > 0 {
                        let sc: Color = shift.stressScore <= 4 ? .inkGreen : shift.stressScore <= 6 ? .inkAmber : .inkRed
                        HStack(spacing: 4) {
                            Circle().fill(sc).frame(width: 4, height: 4)
                            Text("stress \(shift.stressScore)").font(.system(size: 9, design: .monospaced)).foregroundColor(.textMuted)
                        }
                    }
                    MonoLabel(text: shift.usedStaff ? "STAFF" : "SOLO", color: shift.usedStaff ? .inkAmber : .inkGreen, size: 9)
                    if shift.peakBurstUpdated > 0 {
                        let burstColor: Color = shift.peakBurstUpdated <= 15 ? .inkGreen : shift.peakBurstUpdated <= 22 ? .inkAmber : .inkRed
                        MonoLabel(text: "↑\(shift.peakBurstUpdated) burst", color: burstColor, size: 9)
                    }
                    if shift.tailRevenue > 0 { MonoLabel(text: "+$\(Int(shift.tailRevenue)) TAIL", color: .textMuted, size: 9) }
                    if shift.lostSales { MonoLabel(text: "LOST SALES", color: .inkAmber, size: 9) }
                    if shift.usedScriptedUpsell { chip("U") }
                    if shift.recognizedRegular  { chip("R") }
                    if shift.anchorPhraseUsed   { chip("P") }
                }

                if !shift.notes.isEmpty {
                    Text(shift.notes).font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(1.5)
                }
            }
        }
        .sheet(isPresented: $showEdit) { EditShiftSheet(shift: shift, isPresented: $showEdit) }
    }

    func chip(_ letter: String) -> some View {
        Text(letter)
            .font(.system(size: 8, weight: .semibold, design: .monospaced)).foregroundColor(.inkGreen)
            .frame(width: 14, height: 14).background(Color.inkGreen.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

// MARK: - EDIT SHIFT SHEET

struct EditShiftSheet: View {
    @Bindable var shift: HideoutShiftLog
    @Environment(\.appMetrics) private var metrics
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var context

    @State private var revenue = ""
    @State private var txCount = ""
    @State private var stressScore = 5
    @State private var usedStaff = false
    @State private var tailRevenue = ""
    @State private var lostSales = false
    @State private var notes = ""
    @State private var repeatCount = ""
    @State private var newCount = ""
    @State private var selectedDate = Date()
    @State private var showDeleteConfirm = false
    @State private var peakBurst = ""
    @State private var sourceNotes = ""
    @State private var usedScriptedUpsell = false
    @State private var recognizedRegular = false
    @State private var anchorPhraseUsed = false

    var rv: Double { Double(revenue) ?? 0 }
    var tv: Int { Int(txCount) ?? 0 }
    var band: HideoutPlanningBand { HideoutPlanningBand.classify(rv) }

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
                        Button(role: .destructive) { showDeleteConfirm = true } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 13)).foregroundColor(.inkRed)
                                .frame(width: 30, height: 30).background(Color.inkRed.opacity(0.12)).clipShape(Circle())
                        }
                        .padding(.trailing, 8)
                        Button("Save") { save() }.font(.sora(14, weight: .medium)).foregroundColor(.warm)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "SHIFT DATE", size: 10)
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                                .foregroundColor(.textMuted)
                            DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                                .labelsHidden()
                                .tint(.warm)
                                .colorScheme(.dark)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "GROSS REVENUE")
                        HStack(spacing: 8) {
                            Text("$").font(.sora(22, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $revenue).font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                            #if os(iOS)
                                
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                #endif
                            #endif
                                .tint(.warm)
                        }
                        if rv > 0 { HStack(spacing: 6) { Circle().fill(band.color).frame(width: 6, height: 6); Text(band.label).font(.mono(11)).foregroundColor(band.color) } }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "TRANSACTIONS")
                        TextField("0", text: $txCount).font(.sora(18)).foregroundColor(.textPrimary)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack { MonoLabel(text: "STRESS SCORE"); Spacer()
                            let sc: Color = stressScore <= 4 ? .inkGreen : stressScore <= 6 ? .inkAmber : .inkRed
                            Text("\(stressScore)/10").font(.mono(11)).foregroundColor(sc) }
                        Slider(value: Binding(get: { Double(stressScore) }, set: { stressScore = Int($0) }), in: 1...10, step: 1).tint(.warm)
                    }

                    Toggle(isOn: $usedStaff) { Text("Used staff").font(.sora(13)).foregroundColor(.textPrimary) }.tint(Color.inkAmber)
                    Toggle(isOn: $lostSales) { Text("Lost sales").font(.sora(13)).foregroundColor(.textPrimary) }.tint(Color.inkAmber)

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "REPEAT VS NEW")
                        HStack(spacing: 12) {
                            TextField("Repeat", text: $repeatCount).font(.sora(16)).foregroundColor(.textPrimary)
                            #if os(iOS)
                                .keyboardType(.numberPad)
                            #endif
                                .padding(12).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                            TextField("New", text: $newCount).font(.sora(16)).foregroundColor(.textPrimary)
                            #if os(iOS)
                                .keyboardType(.numberPad)
                            #endif
                                .padding(12).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "3–5PM TAIL")
                        HStack(spacing: 8) {
                            Text("$").font(.sora(16, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $tailRevenue).font(.sora(16)).foregroundColor(.textPrimary)
                            #if os(iOS)
                                
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                #endif
                            #endif
                                .tint(.warm)
                        }
                        .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "PEAK BURST — MAX TX IN 30 MIN")
                        TextField("0", text: $peakBurst).font(.sora(16)).foregroundColor(.textPrimary)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        Text("Operational capacity signal.")
                            .font(.mono(10)).foregroundColor(.textMuted).tracking(0.2)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        MonoLabel(text: "BEHAVIORAL TECHNIQUES")
                        Toggle(isOn: $usedScriptedUpsell) {
                            Text("Scripted upsell used").font(.sora(13)).foregroundColor(.textPrimary)
                        }.tint(Color.inkGreen)
                        Toggle(isOn: $recognizedRegular) {
                            Text("Recognized a regular").font(.sora(13)).foregroundColor(.textPrimary)
                        }.tint(Color.inkGreen)
                        Toggle(isOn: $anchorPhraseUsed) {
                            Text("Peak-end close with name").font(.sora(13)).foregroundColor(.textPrimary)
                        }.tint(Color.inkGreen)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "SOURCE ATTRIBUTION")
                        TextField("e.g. Watermarc 4, Google 2, word of mouth 5", text: $sourceNotes, axis: .vertical)
                            .font(.sora(13)).foregroundColor(.textPrimary).lineLimit(2...4)
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "NOTES")
                        TextField("Notes", text: $notes, axis: .vertical).font(.sora(13)).foregroundColor(.textPrimary).lineLimit(3...6)
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
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
            repeatCount = shift.repeatCustomerCount > 0 ? "\(shift.repeatCustomerCount)" : ""
            newCount = shift.newCustomerCount > 0 ? "\(shift.newCustomerCount)" : ""
            selectedDate = shift.dateOverride ?? shift.date
            peakBurst = shift.peakBurstUpdated > 0 ? "\(shift.peakBurstUpdated)" : ""
            sourceNotes = shift.sourceNotes
            usedScriptedUpsell = shift.usedScriptedUpsell
            recognizedRegular = shift.recognizedRegular
            anchorPhraseUsed = shift.anchorPhraseUsed
        }
        .confirmationDialog("Delete this shift?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Shift", role: .destructive) { deleteShift() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    func save() {
        shift.grossRevenue = rv; shift.transactionCount = tv; shift.stressScore = stressScore
        shift.usedStaff = usedStaff; shift.tailRevenue = Double(tailRevenue) ?? 0
        shift.lostSales = lostSales; shift.notes = notes
        shift.repeatCustomerCount = Int(repeatCount) ?? 0; shift.newCustomerCount = Int(newCount) ?? 0
        shift.peakBurstUpdated = Int(peakBurst) ?? 0
        shift.sourceNotes = sourceNotes
        shift.usedScriptedUpsell = usedScriptedUpsell
        shift.recognizedRegular = recognizedRegular
        shift.anchorPhraseUsed = anchorPhraseUsed
        // Update date so sorting and dayLabel reflect the chosen date
        let chosenDay = Calendar.current.startOfDay(for: selectedDate)
        shift.date = chosenDay
        shift.dateOverride = chosenDay
        // Recompute experimentDay based on new date
        let experimentStart = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 13)) ?? Date()
        shift.experimentDay = max(1, (Calendar.current.dateComponents([.day], from: experimentStart, to: selectedDate).day ?? 0) + 1)
        isPresented = false
    }

    func deleteShift() {
        context.delete(shift)
        isPresented = false
    }
}

// MARK: - LOG SHIFT SHEET

struct LogShiftSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.appMetrics) private var metrics
    let experimentDay: Int
    @Environment(\.modelContext) private var context

    @State private var revenue = ""
    @State private var txCount = ""
    @State private var stressScore = 5
    @State private var usedStaff = false
    @State private var tailRevenue = ""
    @State private var lostSales = false
    @State private var notes = ""
    @State private var sourceNotes = ""
    @State private var usedScriptedUpsell = false
    @State private var recognizedRegular = false
    @State private var anchorPhraseUsed = false
    @State private var repeatCount = ""
    @State private var newCount = ""
    @State private var peakBurst = ""
    @State private var selectedDate = Date()
    @State private var isRetroactive = false

    static let experimentStart = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 13)) ?? Date()

    var rv: Double { Double(revenue) ?? 0 }
    var tv: Int { Int(txCount) ?? 0 }
    var band: HideoutPlanningBand { HideoutPlanningBand.classify(rv) }
    var retroDayNum: Int { max(1, (Calendar.current.dateComponents([.day], from: Self.experimentStart, to: selectedDate).day ?? 0) + 1) }
    var logDayLabel: String {
        if Calendar.current.isDateInToday(selectedDate) { return "TODAY" }
        if Calendar.current.isDateInYesterday(selectedDate) { return "YESTERDAY" }
        return selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Log Shift").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                            MonoLabel(text: "DAY \(isRetroactive ? retroDayNum : experimentDay) · \(logDayLabel.uppercased())", color: .warm, size: 10)
                        }
                        Spacer()
                        Button("Save") { save() }.font(.sora(14, weight: .medium))
                            .foregroundColor(rv > 0 ? .warm : .textMuted).disabled(rv == 0)
                    }

                    // ── Retroactive toggle ───────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $isRetroactive.animation()) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Log a past shift").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("Experiment started May 13 — log Days 1, 2, 3 now").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                            }
                        }.tint(.warm)

                        if isRetroactive {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "SHIFT DATE", color: .textMuted, size: 10)
                                DatePicker("", selection: $selectedDate,
                                           in: Self.experimentStart...Date(),
                                           displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .tint(.warm)
                                    .background(Color.surface2)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }

                    // ── Revenue ──────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "GROSS REVENUE")
                        HStack(spacing: 8) {
                            Text("$").font(.sora(22, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $revenue).font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                            #if os(iOS)
                                
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                #endif
                            #endif
                                .tint(.warm)
                        }
                        if rv > 0 {
                            HStack(spacing: 6) {
                                Circle().fill(band.color).frame(width: 6, height: 6)
                                Text(band.label).font(.mono(11)).foregroundColor(band.color).tracking(0.3)
                                Text("·").foregroundColor(.textMuted)
                                Text(band.context).font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                            }
                            Text("+$\(Int(rv * 0.72)) estimated contribution (after COGS + fees)")
                                .font(.mono(10)).foregroundColor(.inkGreen.opacity(0.7)).tracking(0.2)
                        }
                    }

                    // ── Transactions ─────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "TRANSACTION COUNT")
                        TextField("0", text: $txCount).font(.sora(18)).foregroundColor(.textPrimary)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        if tv > 0 && rv > 0 {
                            let avg = rv / Double(tv)
                            // Week 1 solo avg: $17.29. Historical staffed baseline: $16.72.
                            // Solo experiment is already running above baseline — $17.29 is the real floor to hold.
                            let soloFloor = 17.29
                            Text("$\(String(format: "%.2f", avg)) avg ticket · solo floor $17.29")
                                .font(.mono(10)).foregroundColor(avg >= soloFloor ? .inkGreen : .inkAmber).tracking(0.3)
                        }
                    }

                    // ── Stress ───────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            MonoLabel(text: "STRESS SCORE")
                            Spacer()
                            let sc: Color = stressScore <= 4 ? .inkGreen : stressScore <= 6 ? .inkAmber : .inkRed
                            Text("\(stressScore)/10 — \(stressScore <= 4 ? "model scales" : stressScore <= 6 ? "manageable" : "capacity ceiling")")
                                .font(.mono(11)).foregroundColor(sc).tracking(0.3)
                        }
                        Slider(value: Binding(get: { Double(stressScore) }, set: { stressScore = Int($0) }), in: 1...10, step: 1).tint(.warm)
                        HStack { Text("1 — Easy").font(.mono(10)).foregroundColor(.textMuted); Spacer(); Text("10 — Breaking").font(.mono(10)).foregroundColor(.textMuted) }
                    }

                    // ── Peak burst ───────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "PEAK BURST — MAX TX IN 30 MIN")
                        TextField("0", text: $peakBurst).font(.sora(16)).foregroundColor(.textPrimary)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        Text("Operational capacity signal. Determines solo viability ceiling.")
                            .font(.mono(10)).foregroundColor(.textMuted).tracking(0.2)
                    }

                    // ── Signals ──────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "QUICK SIGNALS")
                        Toggle(isOn: $usedStaff) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Used staff today").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("Solo discipline — call only if genuinely needed").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                            }
                        }.tint(Color.inkAmber)
                        Toggle(isOn: $lostSales) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Lost sales").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("Capacity ceiling signal").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                            }
                        }.tint(Color.inkAmber)
                    }

                    // ── Repeat vs new ────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "REPEAT VS NEW CUSTOMERS")
                        MonoLabel(text: "THE MOST STRATEGICALLY CRITICAL DATA POINT", color: .inkAmber, size: 9)
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "REGULARS / REPEAT", color: .textMuted, size: 10)
                                TextField("0", text: $repeatCount).font(.sora(18)).foregroundColor(.textPrimary)
                                #if os(iOS)
                                    .keyboardType(.numberPad)
                                #endif
                                    .padding(12).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "FIRST-TIMERS", color: .textMuted, size: 10)
                                TextField("0", text: $newCount).font(.sora(18)).foregroundColor(.textPrimary)
                                #if os(iOS)
                                    .keyboardType(.numberPad)
                                #endif
                                    .padding(12).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                            }
                        }
                        let r = Int(repeatCount) ?? 0; let n = Int(newCount) ?? 0
                        if r + n > 0 {
                            let pct = Double(r) / Double(r + n)
                            Text("\(Int(pct*100))% repeat · \(pct >= 0.8 ? "acquisition problem" : pct >= 0.5 ? "mixed — work both levers" : "retention problem")")
                                .font(.mono(10)).foregroundColor(.inkAmber).tracking(0.2).lineSpacing(2)
                        }
                    }

                    // ── Behavioral techniques ────────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        MonoLabel(text: "BEHAVIORAL TECHNIQUES — 4 BEHAVIORS")
                        Toggle(isOn: $usedScriptedUpsell) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scripted upsell used").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("\"Want me to warm a croissant to go with that?\"").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                            }
                        }.tint(Color.inkGreen)
                        Toggle(isOn: $recognizedRegular) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recognized a regular").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("'The usual?' / anticipated a need").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                            }
                        }.tint(Color.inkGreen)
                        Toggle(isOn: $anchorPhraseUsed) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Peak-end close with name").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("[Name]. Have a great [day].").font(.sora(10, weight: .light)).foregroundColor(.textMuted)
                            }
                        }.tint(Color.inkGreen)
                    }

                    // ── 3–5PM tail ───────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "3–5PM TAIL REVENUE")
                        HStack(spacing: 8) {
                            Text("$").font(.sora(16, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $tailRevenue).font(.sora(16)).foregroundColor(.textPrimary)
                            #if os(iOS)
                                
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                #endif
                            #endif
                                .tint(.warm)
                        }
                        .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("$60–120/day = $1,200–2,400/month at zero incremental labor cost.")
                            .font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                    }

                    // ── Source attribution ───────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "SOURCE ATTRIBUTION")
                        TextField("e.g. Watermarc 4, Google 2, word of mouth 5, walk-by 3", text: $sourceNotes, axis: .vertical)
                            .font(.sora(13)).foregroundColor(.textPrimary).lineLimit(2...4)
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        Text("Ask casually: 'How did you find us?' 2 weeks of tally marks changes the strategy.")
                            .font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                    }

                    // ── Notes ────────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "NOTES")
                        TextField("What drove today? What broke down? What surprised you?", text: $notes, axis: .vertical)
                            .font(.sora(13)).foregroundColor(.textPrimary).lineLimit(3...6)
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                    }

                    primaryButton("SAVE SHIFT", disabled: rv == 0) { save() }
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
        log.grossRevenue = rv; log.transactionCount = tv; log.stressScore = stressScore
        log.usedStaff = usedStaff; log.tailRevenue = Double(tailRevenue) ?? 0
        log.lostSales = lostSales; log.notes = notes; log.sourceNotes = sourceNotes
        log.usedScriptedUpsell = usedScriptedUpsell; log.recognizedRegular = recognizedRegular
        log.anchorPhraseUsed = anchorPhraseUsed
        log.experimentDay = isRetroactive ? retroDayNum : experimentDay
        log.repeatCustomerCount = Int(repeatCount) ?? 0; log.newCustomerCount = Int(newCount) ?? 0
        if isRetroactive { log.date = selectedDate; log.dateOverride = selectedDate }
        context.insert(log)
        isPresented = false
    }
}


// MARK: - WEEKLY REVENUE COMPOSITION SHEET
// Friday after close · 8–10 minutes · every week
// "Philosophy without measurement drifts." — BRICE_OPERATOR_PRODUCT_BRIEF.md

struct WeeklyRevenueCompositionSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.appMetrics) private var metrics
    @Binding var weekLabel: String
    @Binding var walkinRev: String;     @Binding var walkinStress: Int
    @Binding var regularRev: String;    @Binding var regularStress: Int
    @Binding var watermarcRev: String;  @Binding var watermarcStress: Int
    @Binding var partnershipRev: String; @Binding var partnershipStress: Int
    @Binding var sundayTailRev: String; @Binding var sundayTailStress: Int
    @Binding var earlyAmRev: String;    @Binding var earlyAmStress: Int

    // Previous week — stored separately so we can show comparison
    @AppStorage("wrc_prev_week_label")       private var prevWeekLabel       = ""
    @AppStorage("wrc_prev_walkin_rev")       private var prevWalkinRev       = ""
    @AppStorage("wrc_prev_regular_rev")      private var prevRegularRev      = ""
    @AppStorage("wrc_prev_watermarc_rev")    private var prevWatermarcRev    = ""
    @AppStorage("wrc_prev_partnership_rev")  private var prevPartnershipRev  = ""
    @AppStorage("wrc_prev_sunday_tail_rev")  private var prevSundayTailRev   = ""
    @AppStorage("wrc_prev_early_am_rev")     private var prevEarlyAmRev      = ""

    @State private var showPrevComparison = false

    var weekTotal: Double {
        [walkinRev, regularRev, watermarcRev, partnershipRev, sundayTailRev, earlyAmRev]
            .compactMap { Double($0) }.reduce(0, +)
    }

    var prevTotal: Double {
        [prevWalkinRev, prevRegularRev, prevWatermarcRev, prevPartnershipRev, prevSundayTailRev, prevEarlyAmRev]
            .compactMap { Double($0) }.reduce(0, +)
    }

    var cleanestSource: (name: String, color: Color) {
        let sources: [(String, String, Int, Color)] = [
            ("Partnership / pickup", partnershipRev, partnershipStress, .inkGreen),
            ("Regular locals",       regularRev,     regularStress,     .inkGreen),
            ("Watermarc referrals",  watermarcRev,   watermarcStress,   .inkTeal),
            ("Sunday tail 3–5PM",    sundayTailRev,  sundayTailStress,  .inkAmber),
            ("Early AM 7–8AM",       earlyAmRev,     earlyAmStress,     .inkAmber),
            ("Walk-in hospitality",  walkinRev,      walkinStress,      .textSecond),
        ]
        let active = sources.filter { !$0.1.isEmpty && (Double($0.1) ?? 0) > 0 }
        let best = active.sorted {
            $0.2 != $1.2 ? $0.2 < $1.2 : (Double($0.1) ?? 0) > (Double($1.1) ?? 0)
        }.first
        return (best?.0 ?? "—", best?.3 ?? .textMuted)
    }

    let sources: [(label: String, note: String, revKey: String)] = [
        ("WALK-IN HOSPITALITY",  "Classic café traffic. The baseline.",                      "walkin"),
        ("REGULAR LOCALS",       "Customers you recognise. Retention signal.",               "regular"),
        ("WATERMARC REFERRALS",  "Card redemptions + front-desk referrals.",                 "watermarc"),
        ("PARTNERSHIP / PICKUP", "Jimmy, recurring accounts, any invoice revenue.",           "partnership"),
        ("SUNDAY TAIL 3–5PM",    "Extension experiment — track separately.",                 "sundayTail"),
        ("EARLY AM 7–8AM",       "7AM open experiment — track separately.",                  "earlyAm"),
    ]

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)

                    // ── Header ────────────────────────────────────────────────
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Weekly Review")
                                .font(.sora(22, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            MonoLabel(text: "REVENUE COMPOSITION · NERVOUS SYSTEM ECONOMICS", color: .warm, size: 9)
                        }
                        Spacer()
                        Button("Done") { saveAndClose() }
                            .font(.sora(15, weight: .medium))
                            .foregroundColor(.warm)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                    // ── Week label ────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "WEEK ENDING")
                        TextField("e.g. May 17 · Week 1", text: $weekLabel)
                            .font(.sora(17))
                            .foregroundColor(.textPrimary)
                            .padding(16)
                            .background(Color.surface2)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .tint(.warm)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)

                    // ── Instruction ───────────────────────────────────────────
                    Text("Revenue per source this week. Stress 1–10 — how chaotic was fulfilling it? Leave blank if zero contribution.")
                        .font(.sora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 20)

                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                        .padding(.horizontal, 28)

                    // ── Source rows ───────────────────────────────────────────
                    VStack(spacing: 0) {
                        wrcRow(
                            label: "WALK-IN HOSPITALITY",
                            note: "Classic café traffic. The baseline.",
                            stressContext: "Batch arrivals = real ceiling. Solo stress threshold is ≤5.",
                            prevRev: prevWalkinRev,
                            rev: $walkinRev, stress: $walkinStress,
                            accentColor: .textSecond
                        )
                        divider()
                        wrcRow(
                            label: "REGULAR LOCALS",
                            note: "Customers you recognise. 'The usual?' Retention signal.",
                            stressContext: "Regulars should be near-zero stress. They already know the system.",
                            prevRev: prevRegularRev,
                            rev: $regularRev, stress: $regularStress,
                            accentColor: .inkGreen
                        )
                        divider()
                        wrcRow(
                            label: "WATERMARC REFERRALS",
                            note: "Card redemptions + front-desk referrals. Track separately from walk-in.",
                            stressContext: "Card captures are passive. If stress is high, the referral pipeline is creating chaos.",
                            prevRev: prevWatermarcRev,
                            rev: $watermarcRev, stress: $watermarcStress,
                            accentColor: .inkTeal
                        )
                        divider()
                        wrcRow(
                            label: "PARTNERSHIP / PICKUP",
                            note: "Jimmy, recurring accounts, any invoice-based revenue. Target source.",
                            stressContext: "Should be 1–2. If stress >3, revisit the pickup-first doctrine.",
                            prevRev: prevPartnershipRev,
                            rev: $partnershipRev, stress: $partnershipStress,
                            accentColor: .inkGreen
                        )
                        divider()
                        wrcRow(
                            label: "SUNDAY TAIL 3–5PM",
                            note: "Extension experiment. Near-zero cost if stress stays low.",
                            stressContext: "Experiment pass condition: stress ≤3. Above that, close early.",
                            prevRev: prevSundayTailRev,
                            rev: $sundayTailRev, stress: $sundayTailStress,
                            accentColor: .inkAmber
                        )
                        divider()
                        wrcRow(
                            label: "EARLY AM 7–8AM",
                            note: "7AM open experiment. Does the customer archetype exist?",
                            stressContext: "Low by design — Brice is already there. Revenue or no revenue tells the story.",
                            prevRev: prevEarlyAmRev,
                            rev: $earlyAmRev, stress: $earlyAmStress,
                            accentColor: .inkAmber
                        )
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 8)

                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)

                    // ── Diagnosis ─────────────────────────────────────────────
                    if weekTotal > 0 {
                        VStack(alignment: .leading, spacing: 20) {

                            // Big numbers row
                            HStack(alignment: .bottom, spacing: 0) {
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: "TRACKED THIS WEEK", color: .textMuted, size: 9)
                                    Text("$\(Int(weekTotal))")
                                        .font(.system(size: 38, weight: .bold, design: .monospaced))
                                        .foregroundColor(.textPrimary)
                                    if prevTotal > 0 {
                                        let delta = weekTotal - prevTotal
                                        let sign = delta >= 0 ? "+" : ""
                                        Text("\(sign)$\(Int(delta)) vs \(prevWeekLabel.isEmpty ? "last week" : prevWeekLabel)")
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(delta >= 0 ? .inkGreen : .inkRed)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    MonoLabel(text: "CLEANEST SOURCE", color: .textMuted, size: 9)
                                    Text(cleanestSource.name)
                                        .font(.sora(14, weight: .medium))
                                        .foregroundColor(cleanestSource.color)
                                        .multilineTextAlignment(.trailing)
                                    MonoLabel(text: "DOUBLE DOWN", color: cleanestSource.color.opacity(0.7), size: 9)
                                }
                            }

                            // Governing question
                            HStack(alignment: .top, spacing: 10) {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.warm.opacity(0.5))
                                    .frame(width: 2, height: 44)
                                Text("Which source produced clean dollars at the lowest nervous-system cost? That source deserves more energy next week. Not the biggest — the cleanest.")
                                    .font(.sora(12, weight: .light))
                                    .foregroundColor(.textMuted)
                                    .lineSpacing(3)
                            }

                            Button(action: saveAndClose) {
                                Text("SAVE REVIEW")
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .tracking(1)
                                    .foregroundColor(.bgBase)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.warm)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    } else {
                        Text("Enter at least one revenue source to see this week's diagnosis.")
                            .font(.sora(12, weight: .light))
                            .foregroundColor(.textMuted)
                            .padding(.horizontal, 28)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }

    // Archive current week → prev, then close
    func saveAndClose() {
        prevWeekLabel      = weekLabel
        prevWalkinRev      = walkinRev
        prevRegularRev     = regularRev
        prevWatermarcRev   = watermarcRev
        prevPartnershipRev = partnershipRev
        prevSundayTailRev  = sundayTailRev
        prevEarlyAmRev     = earlyAmRev
        isPresented = false
    }

    func divider() -> some View {
        Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
    }

    func wrcRow(
        label: String,
        note: String,
        stressContext: String,
        prevRev: String,
        rev: Binding<String>,
        stress: Binding<Int>,
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(accentColor.opacity(0.6))
                    .frame(width: 2, height: 18)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    MonoLabel(text: label, color: accentColor.opacity(0.9), size: 9)
                    Text(note)
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                }
            }

            HStack(alignment: .center, spacing: 12) {
                // Revenue input
                HStack(spacing: 8) {
                    Text("$")
                        .font(.system(size: 20, weight: .light, design: .monospaced))
                        .foregroundColor(.textMuted)
                    TextField("0", text: rev)
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundColor(.textPrimary)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .tint(.warm)
                        .frame(minWidth: 60)

                    // Week-over-week delta
                    if !prevRev.isEmpty, let prev = Double(prevRev), let curr = Double(rev.wrappedValue), curr > 0 {
                        let d = curr - prev
                        let sign = d >= 0 ? "+" : ""
                        Text("\(sign)$\(Int(d))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(d >= 0 ? .inkGreen : .inkRed)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background((d >= 0 ? Color.inkGreen : Color.inkRed).opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.surface2)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Stress slider
                VStack(alignment: .leading, spacing: 4) {
                    let sc: Color = stress.wrappedValue == 0 ? .textMuted
                        : stress.wrappedValue <= 3 ? .inkGreen
                        : stress.wrappedValue <= 6 ? .inkAmber
                        : .inkRed
                    HStack {
                        MonoLabel(text: "STRESS", color: .textMuted, size: 9)
                        Spacer()
                        if stress.wrappedValue > 0 {
                            Text("\(stress.wrappedValue)/10")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(sc)
                        }
                    }
                    Slider(
                        value: Binding(
                            get: { Double(stress.wrappedValue) },
                            set: { stress.wrappedValue = Int($0) }
                        ),
                        in: 0...10, step: 1
                    )
                    .tint(stress.wrappedValue == 0 ? .muted : sc)
                }
                .frame(maxWidth: .infinity)
            }

            // Stress context line — only shows when slider > 0
            if stress.wrappedValue > 0 {
                Text(stressContext)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.textMuted.opacity(0.7))
                    .lineSpacing(2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 16)
        .animation(.easeOut(duration: 0.2), value: stress.wrappedValue)
    }
}

// MARK: - IPAD ADAPTIVE LAYOUT (Hideout)
// HideoutLayoutMetrics is a typealias for AppMetrics — one system, one set of values.
// Hideout-specific properties (useTwoColumn, leftColWidth) added via extension in SharedComponents.
// HideoutAdaptiveShell reads from the AppMetrics environment injected at RootView.

typealias HideoutLayoutMetrics = AppMetrics

// hideoutMetrics is a convenience alias for appMetrics — same key, same value.
// Cannot reference AppMetricsKey directly (private to SharedComponents),
// so we read/write via the appMetrics keypath instead.
extension EnvironmentValues {
    var hideoutMetrics: AppMetrics {
        get { self.appMetrics }
        set { self.appMetrics = newValue }
    }
}

// HideoutAdaptiveShell now reads from AppMetrics environment rather than creating its own
struct HideoutAdaptiveShell<Content: View>: View {
    let content: (AppMetrics) -> Content
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        GeometryReader { geo in
            // Re-compute with current geometry so orientation changes propagate
            let isIPad     = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = geo.size.width > geo.size.height
            let freshMetrics = AppMetrics(isIPad: isIPad, isLandscape: isLandscape)
            content(freshMetrics)
                .environment(\.appMetrics, freshMetrics)
        }
    }
}

// Two-column container for iPad landscape
struct HideoutTwoColumnLayout<Left: View, Right: View>: View {
    let metrics: AppMetrics
    let left: Left
    let right: Right

    init(metrics: AppMetrics, @ViewBuilder left: () -> Left, @ViewBuilder right: () -> Right) {
        self.metrics = metrics
        self.left = left()
        self.right = right()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left column — live numbers dashboard, always visible in landscape
            left
                .frame(width: metrics.leftColWidth)

            Rectangle()
                .fill(Color.muted.opacity(0.15))
                .frame(width: 0.5)

            // Right column — active work surface (Scorecard / Playbook / Intel)
            right
                .frame(maxWidth: .infinity)
        }
    }
}

