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
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @State private var showLogSheet = false
    @State private var selectedTab: Int = 0  // 0 = Dashboard, 1 = Scorecard, 2 = Playbook

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
        return Int(ceil((nextTarget - thirtyDayAvg) / 16.72))
    }

    var body: some View {
        ZStack {
            AtmosphericBackground()

            VStack(spacing: 0) {
                // ── Header ──────────────────────────────────────────────────────
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            MonoLabel(text: "HIDEOUT MIAMI", color: .warm, size: 10)
                            MonoLabel(text: "SOLO EXPERIMENT", color: .textMuted, size: 10)
                        }
                        Text("Day \(experimentDay)")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        MonoLabel(text: "LOAN DECISION", color: .textMuted, size: 10)
                        Text("\(daysToDecision)d")
                            .font(.system(size: 22, weight: .medium, design: .monospaced))
                            .foregroundColor(daysToDecision <= 7 ? .inkAmber : .textSecond)
                        MonoLabel(text: "JUNE 13", color: .textMuted, size: 10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 12)

                // ── Sub-tabs ────────────────────────────────────────────────────
                HStack(spacing: 0) {
                    ForEach(["DASHBOARD", "SCORECARD", "PLAYBOOK"].indices, id: \.self) { i in
                        Button(action: { withAnimation(.easeOut(duration: 0.2)) { selectedTab = i } }) {
                            VStack(spacing: 6) {
                                Text(["DASHBOARD", "SCORECARD", "PLAYBOOK"][i])
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(selectedTab == i ? .warm : .textMuted)
                                    .tracking(0.8)
                                Rectangle()
                                    .fill(selectedTab == i ? Color.warm : Color.clear)
                                    .frame(height: 1.5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 2)

                Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    if selectedTab == 0 {
                        dashboardView
                    } else if selectedTab == 1 {
                        scorecardView
                    } else {
                        playbookView
                    }
                }
            }

            // ── Floating log button ──────────────────────────────────────────
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showLogSheet = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("LOG SHIFT")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .tracking(0.8)
                        }
                        .foregroundColor(.bgBase)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                        .background(Color.warm)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.warm.opacity(0.4), radius: 12, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogShiftSheet(isPresented: $showLogSheet, experimentDay: experimentDay)
        }
    }

    // MARK: - DASHBOARD

    var dashboardView: some View {
        VStack(spacing: 14) {

            // ── The Two Numbers That Matter Most ─────────────────────────────
            HStack(spacing: 10) {
                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "30-DAY AVG", color: .textMuted, size: 10)
                        Text(recentShifts.isEmpty ? "—" : "$\(Int(thirtyDayAvg))")
                            .font(.system(size: 30, weight: .bold, design: .monospaced))
                            .foregroundColor(.textPrimary)
                        HStack(spacing: 5) {
                            Circle().fill(currentBand.color).frame(width: 6, height: 6)
                            Text(recentShifts.isEmpty ? "no data yet" : currentBand.label)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(currentBand.color)
                        }
                        if txToNextBand > 0 {
                            MonoLabel(text: "+\(txToNextBand) TX TO NEXT", color: .textMuted, size: 9)
                        }
                    }
                }

                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "REPEAT %", color: .textMuted, size: 10)
                        if let rp = aggregateRepeatPercent {
                            Text("\(Int(rp * 100))%")
                                .font(.system(size: 30, weight: .bold, design: .monospaced))
                                .foregroundColor(.textPrimary)
                            let diagnosis = rp >= 0.8 ? "acquisition" : rp >= 0.5 ? "mixed" : "retention"
                            let color: Color = rp >= 0.8 ? .inkAmber : rp >= 0.5 ? .inkTeal : .inkRed
                            MonoLabel(text: "\(diagnosis.uppercased()) PROBLEM", color: color, size: 9)
                        } else {
                            Text("—")
                                .font(.system(size: 30, weight: .bold, design: .monospaced))
                                .foregroundColor(.textMuted)
                            MonoLabel(text: "START TRACKING", color: .textMuted, size: 9)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

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
                .padding(.horizontal, 24)
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
                            Spacer()
                        }
                        Text("Contribution = revenue × 0.72 (after COGS 25% + Square 3%). Solo: no labor deduction.")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                    }
                }
                .padding(.horizontal, 24)
            }

            // ── Transaction gap to next band ─────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "TRANSACTION GAP — $16.72 AVG TICKET", color: .textMuted, size: 10)
                    VStack(spacing: 0) {
                        gapRow("Survival floor", target: 520, current: thirtyDayAvg, bandColor: .inkRed)
                        Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)
                        gapRow("Stability", target: 590, current: thirtyDayAvg, bandColor: .inkAmber)
                        Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)
                        gapRow("Comfort", target: 650, current: thirtyDayAvg, bandColor: .inkGreen)
                        Rectangle().fill(Color.muted.opacity(0.12)).frame(height: 0.5)
                        gapRow("Growth", target: 750, current: thirtyDayAvg, bandColor: .violetLight)
                    }
                    MonoLabel(text: "THIS IS A TX VOLUME PROBLEM, NOT A PRICING PROBLEM", color: .textMuted, size: 9)
                }
            }
            .padding(.horizontal, 24)

            // ── Shift log ────────────────────────────────────────────────────
            if recentShifts.isEmpty {
                CardView(style: .secondary) {
                    VStack(spacing: 10) {
                        MonoLabel(text: "NO SHIFTS LOGGED YET", color: .textMuted)
                        Text("The experiment started May 13. Log each day after close. The 30 days answer everything.")
                            .font(.sora(12, weight: .light))
                            .foregroundColor(.textMuted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                        VStack(spacing: 4) {
                            Text("Day 1 (May 13): $419 · 28 tx · $14.96 avg · solo · clean kitchen")
                            Text("Day 2 (May 14): —")
                            Text("Day 3 (May 15): —")
                        }
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.warm.opacity(0.6))
                        .multilineTextAlignment(.center)
                        Text("Use LOG SHIFT → toggle 'Log a past shift' to enter these retroactively.")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 24)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(text: "SHIFT LOG").padding(.horizontal, 24)
                    ForEach(recentShifts) { shift in
                        ShiftLogRow(shift: shift).padding(.horizontal, 24)
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
            .padding(.horizontal, 24)

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
                .padding(.horizontal, 24)
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
                            ("Watermarc resident", "Primary thesis"),
                            ("Other nearby tower", "Expand playbook"),
                            ("Google / Maps", "Digital working"),
                            ("Word of mouth", "Feed this engine"),
                            ("Walking by / signage", "Wayfinding gap"),
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
            .padding(.horizontal, 24)

            Spacer(minLength: 100)
        }
        .padding(.top, 16)
    }

    // MARK: - PLAYBOOK

    var playbookView: some View {
        VStack(spacing: 14) {

            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        MonoLabel(text: "LOAN DECISION — JUNE 13", color: .warm, size: 10)
                        Spacer()
                        Text("\(daysToDecision) days")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.warm)
                    }
                    Text("Decision made from data, not desperation.")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)

                    VStack(spacing: 10) {
                        decisionQ("01", "30-day avg trending toward $550+?",
                                  answer: thirtyDayAvg >= 550 ? "YES — $\(Int(thirtyDayAvg)) avg" : thirtyDayAvg > 0 ? "NOT YET — $\(Int(thirtyDayAvg)) avg" : "No data yet",
                                  green: thirtyDayAvg >= 550)
                        decisionQ("02", "Capital has specific revenue-generating purpose?", answer: "Answer before June 13", green: false)
                        decisionQ("03", "Decision made from stability, not crisis?", answer: "Data quality determines this", green: false)
                    }

                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Bridge vs. anesthesia. Debt that funds restructuring is defensible. Debt that delays reckoning is not.")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2.5)
                }
            }
            .padding(.horizontal, 24)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "DISCOVERY FRICTION AUDIT", color: .textMuted, size: 10)
                    Text("Solve physical friction before digital amplification. No point driving traffic to a location people can't find.")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                    VStack(spacing: 6) {
                        ForEach([
                            "Can a stranger on the street tell Hideout exists?",
                            "Is it obvious within 3 seconds?",
                            "Visible signage at street level?",
                            "Elevator access to the patio — obvious?",
                            "Building residents explicitly told Hideout exists?",
                            "QR code or menu visible from lobby?",
                            "Watermarc leasing team introduced?",
                            "Watermarc concierge briefed?",
                            "Walking path from Watermarc frictionless?",
                        ], id: \.self) { item in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "square")
                                    .font(.system(size: 11))
                                    .foregroundColor(.textMuted)
                                Text(item)
                                    .font(.sora(12, weight: .light))
                                    .foregroundColor(.textSecond)
                                    .lineSpacing(2)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        MonoLabel(text: "WATERMARC PLAYBOOK", color: .inkTeal, size: 10)
                        Spacer()
                        MonoLabel(text: "PRIMARY TARGET", color: .textMuted, size: 9)
                    }
                    Text("One leasing office relationship could outperform any ad spend.")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                    VStack(spacing: 8) {
                        pAction("THIS WEEK", "Introduce to Watermarc leasing team. Bring coffee. Zero cost.", .inkTeal)
                        pAction("THIS WEEK", "Brief the building concierge. Cards at desk. Zero cost.", .inkTeal)
                        pAction("THIS MONTH", "Resident welcome offer — attract without training discount behavior.", .inkAmber)
                        pAction("WHEN READY", "$1,000 Google Ads credit (unclaimed) — hyper-local Edgewater radius.", .textMuted)
                    }
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Hypothesis: Hideout functions as neighborhood validation for prospective Watermarc residents. This referral compounds.")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2.5)
                }
            }
            .padding(.horizontal, 24)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "IF $1,000 AVAILABLE — VISIBILITY ALLOCATION", color: .textMuted, size: 10)
                    VStack(spacing: 8) {
                        ForEach([
                            ("$300", "Street-level wayfinding signage", "Most basic friction. Most impactful fix."),
                            ("$250", "One Sunday discovery event", "20–30 new people. Some become regulars."),
                            ("$150", "Lobby/elevator resident presence", "Framed menu where residents see it daily."),
                            ("$150", "Resident activation offer", "First-visit hook for residents who haven't been."),
                            ("$150", "Professional photography", "Google profile + Instagram. Quality signal."),
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
            .padding(.horizontal, 24)

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
            .padding(.horizontal, 24)

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
        let txNeeded = gap > 0 ? Int(ceil(gap / 16.72)) : 0
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
                MonoLabel(text: "+\(txNeeded) TX", color: .textMuted, size: 9)
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

    func pAction(_ timing: String, _ text: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            MonoLabel(text: timing, color: color, size: 9).frame(width: 72, alignment: .leading)
            Text(text).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2)
            Spacer()
        }
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
}

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
                                .foregroundColor(shift.averageTicket >= 16.72 ? .inkGreen : .inkAmber)
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
    @Binding var isPresented: Bool

    @State private var revenue = ""
    @State private var txCount = ""
    @State private var stressScore = 5
    @State private var usedStaff = false
    @State private var tailRevenue = ""
    @State private var lostSales = false
    @State private var notes = ""
    @State private var repeatCount = ""
    @State private var newCount = ""

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
                        Button("Save") { save() }.font(.sora(14, weight: .medium)).foregroundColor(.warm)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "GROSS REVENUE")
                        HStack(spacing: 8) {
                            Text("$").font(.sora(22, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $revenue).font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary).keyboardType(.decimalPad).tint(.warm)
                        }
                        if rv > 0 { HStack(spacing: 6) { Circle().fill(band.color).frame(width: 6, height: 6); Text(band.label).font(.mono(11)).foregroundColor(band.color) } }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "TRANSACTIONS")
                        TextField("0", text: $txCount).font(.sora(18)).foregroundColor(.textPrimary).keyboardType(.numberPad)
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
                            TextField("Repeat", text: $repeatCount).font(.sora(16)).foregroundColor(.textPrimary).keyboardType(.numberPad)
                                .padding(12).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                            TextField("New", text: $newCount).font(.sora(16)).foregroundColor(.textPrimary).keyboardType(.numberPad)
                                .padding(12).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "3–5PM TAIL")
                        HStack(spacing: 8) {
                            Text("$").font(.sora(16, weight: .light)).foregroundColor(.textMuted)
                            TextField("0", text: $tailRevenue).font(.sora(16)).foregroundColor(.textPrimary).keyboardType(.decimalPad).tint(.warm)
                        }
                        .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10))
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
        }
    }

    func save() {
        shift.grossRevenue = rv; shift.transactionCount = tv; shift.stressScore = stressScore
        shift.usedStaff = usedStaff; shift.tailRevenue = Double(tailRevenue) ?? 0
        shift.lostSales = lostSales; shift.notes = notes
        shift.repeatCustomerCount = Int(repeatCount) ?? 0; shift.newCustomerCount = Int(newCount) ?? 0
        isPresented = false
    }
}

// MARK: - LOG SHIFT SHEET

struct LogShiftSheet: View {
    @Binding var isPresented: Bool
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
                            TextField("0", text: $revenue).font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary).keyboardType(.decimalPad).tint(.warm)
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
                        TextField("0", text: $txCount).font(.sora(18)).foregroundColor(.textPrimary).keyboardType(.numberPad)
                            .padding(14).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                        if tv > 0 && rv > 0 {
                            let avg = rv / Double(tv)
                            Text("$\(String(format: "%.2f", avg)) avg ticket · target $16.72")
                                .font(.mono(10)).foregroundColor(avg >= 16.72 ? .inkGreen : .inkAmber).tracking(0.3)
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
                        TextField("0", text: $peakBurst).font(.sora(16)).foregroundColor(.textPrimary).keyboardType(.numberPad)
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
                                TextField("0", text: $repeatCount).font(.sora(18)).foregroundColor(.textPrimary).keyboardType(.numberPad)
                                    .padding(12).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 10)).tint(.warm)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "FIRST-TIMERS", color: .textMuted, size: 10)
                                TextField("0", text: $newCount).font(.sora(18)).foregroundColor(.textPrimary).keyboardType(.numberPad)
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
                            TextField("0", text: $tailRevenue).font(.sora(16)).foregroundColor(.textPrimary).keyboardType(.decimalPad).tint(.warm)
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
