import SwiftUI

// MARK: - Operate Mode (Jul 2026)
//
// Primary tab: CASH / DUE / IN + smart TODAY checklist.
// Park tab: everything else (Hideout, You, Signal, …).
// Canonical protocol: Docs/OPERATE_MODE_ROADMAP.md

enum OperateStorage {
    static let cash = "operate_cash"
    static let due = "operate_due"
    static let incoming = "operate_in"
    static let today = "operate_today"
    static let spine = "operate_spine"
    static let parked = "operate_parked"
    static let lastWeeklyReview = "operate_last_weekly_review"
    static let weeklyReviewHistory = "operate_weekly_review_history"
    static let todayDoneDate = "operate_today_done_date"
    static let todayDoneMask = "operate_today_done_mask"
}

enum ParkDestination: String, Hashable, CaseIterable {
    case today, hideout, signal, you, physique, recovery, capital, now

    var title: String {
        switch self {
        case .today: return "Today"
        case .hideout: return "Hideout"
        case .signal: return "Signal"
        case .you: return "You"
        case .physique: return "Physique"
        case .recovery: return "Recovery"
        case .capital: return "Capital"
        case .now: return "Now"
        }
    }

    var subtitle: String {
        switch self {
        case .today: return "Full day rail · protocols · log"
        case .hideout: return "Venue · shift · playbook"
        case .signal: return "Distribution · plant · log"
        case .you: return "Evening read · doctrine · ventures"
        case .physique: return "Program · cut · reference"
        case .recovery: return "Constraints · return path"
        case .capital: return "Runway · reserves · housing"
        case .now: return "Legacy orientation · context cards"
        }
    }

    var icon: String {
        switch self {
        case .today: return "calendar"
        case .hideout: return "building.2"
        case .signal: return "antenna.radiowaves.left.and.right"
        case .you: return "person"
        case .physique: return "figure.run"
        case .recovery: return "staroflife"
        case .capital: return "dollarsign.circle"
        case .now: return "scope"
        }
    }

    var section: String {
        switch self {
        case .today: return "Execute"
        case .hideout, .signal: return "Work"
        case .you: return "Evening"
        case .physique, .recovery: return "Body"
        case .capital: return "Money depth"
        case .now: return "Archive"
        }
    }
}

enum OperateParsing {
    static func lines(from text: String, max: Int? = nil) -> [String] {
        let raw = text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if let max { return Array(raw.prefix(max)) }
        return raw
    }

    static func spineLineForToday(_ spine: String) -> String? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let keys = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
        let key = keys[weekday - 1]
        return lines(from: spine).first { matchesSpineDay($0, key: key) }
    }

    /// Day key must be followed by whitespace or separator — avoids "Money…" on Monday.
    static func matchesSpineDay(_ line: String, key: String) -> Bool {
        let lower = line.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard lower.hasPrefix(key) else { return false }
        if lower.count == key.count { return true }
        let next = lower[lower.index(lower.startIndex, offsetBy: key.count)]
        let separators: Set<Character> = [" ", "·", "—", "-", ":", "."]
        return separators.contains(next)
    }

    static func reviewHistory(from raw: String) -> [String] {
        raw
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func appendReview(to raw: String, stamp: String, maxEntries: Int = 8) -> String {
        var entries = reviewHistory(from: raw)
        if entries.last != stamp { entries.append(stamp) }
        if entries.count > maxEntries {
            entries = Array(entries.suffix(maxEntries))
        }
        return entries.joined(separator: "\n")
    }

    static func dayStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    static func reviewStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: Date())
    }
}

// MARK: - Operate Tab (primary)

struct OperateTabView: View {
    @Bindable var state: AppState
    @Environment(\.appMetrics) private var metrics

    @AppStorage(OperateStorage.cash) private var cash = ""
    @AppStorage(OperateStorage.due) private var due = ""
    @AppStorage(OperateStorage.incoming) private var incoming = ""
    @AppStorage(OperateStorage.today) private var today = ""
    @AppStorage(OperateStorage.spine) private var spine = ""
    @AppStorage(OperateStorage.parked) private var parked = ""
    @AppStorage(OperateStorage.lastWeeklyReview) private var lastWeeklyReview = ""
    @AppStorage(OperateStorage.weeklyReviewHistory) private var weeklyReviewHistory = ""
    @AppStorage(OperateStorage.todayDoneDate) private var todayDoneDate = ""
    @AppStorage(OperateStorage.todayDoneMask) private var todayDoneMask = ""

    @State private var showEditFields = false
    @State private var appeared = false

    private var todayLines: [String] { OperateParsing.lines(from: today, max: 3) }
    private var dueNext: String {
        OperateParsing.lines(from: due).first ?? "Add what's due next"
    }
    private var firstIN: String? {
        OperateParsing.lines(from: incoming).first
    }
    private var spineToday: String? { OperateParsing.spineLineForToday(spine) }
    private var reviewCount: Int { OperateParsing.reviewHistory(from: weeklyReviewHistory).count }
    private static let reviewGateTarget = 4

    private var doneIndices: Set<Int> {
        guard todayDoneDate == OperateParsing.dayStamp() else { return [] }
        return Set(
            todayDoneMask
                .split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        )
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(enhanced: true)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: metrics.operateSectionGap) {
                    headerBlock
                    todayBlock
                    moneyStrip
                    if let firstIN, !firstIN.isEmpty { inActionBlock(firstIN) }
                    editToggle
                    if showEditFields { editFieldsBlock }
                    reviewButton
                }
                .padding(.horizontal, metrics.hPad)
                .padding(.top, metrics.screenTopPadding)
                .padding(.bottom, metrics.tabBarHeight + metrics.scaledSize(32))
                .adaptiveContentWidth(metrics)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.35), value: appeared)
            }
        }
        .onAppear {
            normalizeTodayDoneForNewDay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { appeared = true }
        }
    }

    // MARK: Blocks

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
            MonoLabel(text: "OPERATE", color: .warm, size: metrics.operateMonoSize)
            Text(formattedToday)
                .font(metrics.fontSora(metrics.operateTitleSize, weight: .semibold))
                .foregroundColor(.textPrimary)
            if let spineToday {
                Text(spineToday)
                    .font(metrics.fontSora(metrics.operateBodySize, weight: .light))
                    .foregroundColor(.textSecond)
                    .lineSpacing(metrics.scaledSize(4))
            } else if !spine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Set today's line in 7-DAY below.")
                    .font(metrics.fontSora(metrics.operateCaptionSize, weight: .light))
                    .foregroundColor(.textMuted)
            }
            if !lastWeeklyReview.isEmpty {
                MonoLabel(text: "REVIEW · \(lastWeeklyReview)", color: .textMuted, size: metrics.operateMonoSize)
            }
            if reviewCount > 0 {
                MonoLabel(
                    text: "REVIEWS · \(min(reviewCount, Self.reviewGateTarget))/\(Self.reviewGateTarget)",
                    color: .textMuted,
                    size: metrics.operateMonoSize
                )
            }
        }
    }

    private var todayBlock: some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(14)) {
            MonoLabel(text: "TODAY", color: .violetLight, size: metrics.operateMonoSize)
            if todayLines.isEmpty {
                Text("Write up to 3 lines — M· / H· / F· / D·")
                    .font(metrics.fontSora(metrics.operateBodySize, weight: .light))
                    .foregroundColor(.textMuted)
                    .padding(.vertical, metrics.scaledSize(8))
            } else {
                ForEach(Array(todayLines.enumerated()), id: \.offset) { index, line in
                    todayRow(index: index, line: line)
                }
            }
        }
        .padding(metrics.operateCardPad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous)
                .strokeBorder(Color.violet.opacity(0.12), lineWidth: 0.5)
        )
    }

    private func todayRow(index: Int, line: String) -> some View {
        let done = doneIndices.contains(index)
        return Button {
            toggleTodayLine(index)
        } label: {
            HStack(alignment: .top, spacing: metrics.scaledSize(14)) {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: metrics.scaledSize(22), weight: .light))
                    .foregroundColor(done ? .inkGreen : .textMuted.opacity(0.5))
                    .padding(.top, metrics.scaledSize(2))
                Text(line)
                    .font(metrics.fontSora(metrics.operateTaskSize, weight: done ? .regular : .medium))
                    .foregroundColor(done ? .textMuted : .textPrimary)
                    .strikethrough(done, color: .textMuted)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(metrics.scaledSize(4))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var moneyStrip: some View {
        HStack(alignment: .top, spacing: metrics.scaledSize(16)) {
            VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                MonoLabel(text: "CASH", color: .textMuted, size: metrics.operateMonoSize)
                Text(cash.isEmpty ? "—" : cash)
                    .font(metrics.fontSora(metrics.operateMoneySize, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.muted.opacity(0.2))
                .frame(width: 0.5)
                .padding(.vertical, metrics.scaledSize(4))

            VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                MonoLabel(text: "DUE NEXT", color: .textMuted, size: metrics.operateMonoSize)
                Text(dueNext)
                    .font(metrics.fontSora(metrics.operateBodySize, weight: .light))
                    .foregroundColor(.textSecond)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(metrics.scaledSize(3))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(metrics.operateCardPad)
        .background(Color.surface.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous))
    }

    private func inActionBlock(_ line: String) -> some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
            MonoLabel(text: "IN · DO THIS", color: .inkAmber, size: metrics.operateMonoSize)
            Text(line)
                .font(metrics.fontSora(metrics.operateBodySize, weight: .medium))
                .foregroundColor(.textPrimary)
                .lineSpacing(metrics.scaledSize(4))
        }
        .padding(metrics.operateCardPad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.inkAmber.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous)
                .strokeBorder(Color.inkAmber.opacity(0.2), lineWidth: 0.5)
        )
    }

    private var editToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) { showEditFields.toggle() }
        } label: {
            HStack {
                Text(showEditFields ? "Hide fields" : "Update money & week")
                    .font(metrics.fontSora(metrics.operateCaptionSize, weight: .medium))
                    .foregroundColor(.textSecond)
                Spacer()
                Image(systemName: showEditFields ? "chevron.up" : "chevron.down")
                    .font(.system(size: metrics.scaledSize(12), weight: .light))
                    .foregroundColor(.textMuted)
            }
        }
        .buttonStyle(.plain)
    }

    private var editFieldsBlock: some View {
        VStack(alignment: .leading, spacing: metrics.operateSectionGap) {
            operateSection(title: "MONEY", accent: .warm) {
                operateField(label: "CASH", hint: "One number — cash on hand now.", text: $cash)
                operateField(label: "DUE", hint: "Earliest first · item · date · amount", text: $due, minHeight: 96)
                operateField(label: "IN", hint: "Priority first · who · amount · next action", text: $incoming, minHeight: 96)
            }
            operateSection(title: "WEEK", accent: .violet) {
                operateField(label: "TODAY", hint: "Max 3 — M· / H· / F· / D·", text: $today, minHeight: 80)
                operateField(label: "7-DAY", hint: "Mon — … · one line per day.", text: $spine, minHeight: 112)
                operateField(label: "PARKED", hint: "Captured, not scheduled. Kill 1–3 each Sunday.", text: $parked, minHeight: 80)
            }
        }
    }

    private var reviewButton: some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
            Button {
                let stamp = OperateParsing.reviewStamp()
                lastWeeklyReview = stamp
                weeklyReviewHistory = OperateParsing.appendReview(to: weeklyReviewHistory, stamp: stamp)
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                #endif
            } label: {
                Text("Mark Sunday review done")
                    .font(metrics.fontSora(metrics.operateCaptionSize, weight: .medium))
                    .foregroundColor(.warm)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, metrics.scaledSize(14))
                    .background(Color.warm.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Helpers

    private var formattedToday: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE · MMM d"
        return f.string(from: Date())
    }

    private func normalizeTodayDoneForNewDay() {
        let stamp = OperateParsing.dayStamp()
        if todayDoneDate != stamp {
            todayDoneDate = stamp
            todayDoneMask = ""
        }
    }

    private func toggleTodayLine(_ index: Int) {
        normalizeTodayDoneForNewDay()
        var set = doneIndices
        if set.contains(index) { set.remove(index) } else { set.insert(index) }
        todayDoneMask = set.sorted().map(String.init).joined(separator: ",")
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }

    @ViewBuilder
    private func operateSection<Content: View>(
        title: String,
        accent: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: metrics.cardSpacing) {
            HStack(spacing: metrics.rowSpacing) {
                Rectangle()
                    .fill(accent)
                    .frame(width: 3, height: metrics.scaledSize(16))
                    .clipShape(RoundedRectangle(cornerRadius: 1.5))
                MonoLabel(text: title, color: accent, size: metrics.operateMonoSize)
            }
            content()
        }
    }

    @ViewBuilder
    private func operateField(
        label: String,
        hint: String,
        text: Binding<String>,
        minHeight: CGFloat = 52
    ) -> some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
            MonoLabel(text: label, color: .textMuted, size: metrics.operateMonoSize)
            Text(hint)
                .font(metrics.fontSora(metrics.operateCaptionSize, weight: .light))
                .foregroundColor(.textMuted.opacity(0.85))
            TextEditor(text: text)
                .font(metrics.fontSora(metrics.operateBodySize, weight: .light))
                .foregroundColor(.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: metrics.scaledSize(minHeight))
                .padding(metrics.scaledSize(12))
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous)
                        .strokeBorder(Color.muted.opacity(0.22), lineWidth: 0.5)
                )
        }
    }
}

// MARK: - Park Tab (depth archive)

struct ParkTabView: View {
    @Bindable var state: AppState
    @Environment(\.appMetrics) private var metrics
    @State private var path = NavigationPath()
    @State private var appeared = false

    private var grouped: [(String, [ParkDestination])] {
        let order = ["Execute", "Work", "Evening", "Body", "Money depth", "Archive"]
        return order.compactMap { section in
            let items = ParkDestination.allCases.filter { $0.section == section }
            return items.isEmpty ? nil : (section, items)
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AtmosphericBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                        VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                            MonoLabel(text: "PARK", color: .violetLight, size: metrics.operateMonoSize)
                            Text("Depth when you need it.")
                                .font(metrics.fontSora(metrics.operateTitleSize, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text("Morning lives on Operate. Open these when the task requires the full room.")
                                .font(metrics.fontSora(metrics.operateBodySize, weight: .light))
                                .foregroundColor(.textSecond)
                                .lineSpacing(metrics.scaledSize(4))
                        }
                        .padding(.bottom, metrics.scaledSize(4))

                        ForEach(grouped, id: \.0) { section, items in
                            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                                MonoLabel(text: section.uppercased(), color: .textMuted, size: metrics.operateMonoSize)
                                ForEach(items, id: \.self) { dest in
                                    Button {
                                        path.append(dest)
                                    } label: {
                                        parkRow(dest)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, metrics.hPad)
                    .padding(.top, metrics.screenTopPadding)
                    .padding(.bottom, metrics.tabBarHeight + metrics.scaledSize(24))
                    .adaptiveContentWidth(metrics)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: appeared)
                }
            }
            .navigationDestination(for: ParkDestination.self) { dest in
                parkDestinationView(dest)
                    .navigationTitle(dest.title)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { appeared = true }
            if let route = state.parkRoute {
                path.append(route)
                state.parkRoute = nil
            }
        }
        .onChange(of: state.parkRoute) { _, route in
            guard let route else { return }
            path.append(route)
            state.parkRoute = nil
        }
    }

    private func parkRow(_ dest: ParkDestination) -> some View {
        HStack(spacing: metrics.scaledSize(14)) {
            Image(systemName: dest.icon)
                .font(.system(size: metrics.scaledSize(18), weight: .light))
                .foregroundColor(.violetLight)
                .frame(width: metrics.scaledSize(28))
            VStack(alignment: .leading, spacing: metrics.scaledSize(4)) {
                Text(dest.title)
                    .font(metrics.fontSora(metrics.operateBodySize, weight: .medium))
                    .foregroundColor(.textPrimary)
                Text(dest.subtitle)
                    .font(metrics.fontSora(metrics.operateCaptionSize, weight: .light))
                    .foregroundColor(.textMuted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: metrics.scaledSize(11), weight: .light))
                .foregroundColor(.textMuted.opacity(0.5))
        }
        .padding(metrics.operateCardPad)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius, style: .continuous))
    }

    @ViewBuilder
    private func parkDestinationView(_ dest: ParkDestination) -> some View {
        switch dest {
        case .today: TodayView(state: state)
        case .hideout: HideoutTabView()
        case .signal: SignalTabView()
        case .you: YouView(state: state)
        case .physique: PhysiqueTabView()
        case .recovery: RecoveryTabView()
        case .capital: CapitalTabView()
        case .now: HomeView(state: state)
        }
    }
}

// MARK: - Legacy sheet (unused — kept for reference during transition)

struct OperatePanelView: View {
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        OperateTabView(state: AppState())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundColor(.warm)
                }
            }
    }
}
