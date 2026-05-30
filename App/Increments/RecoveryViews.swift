import SwiftUI
import SwiftData

// MARK: - RECOVERY TAB
// Tibia recovery protocol — IM nail fixation, April 13 2026
// Accent: inkTeal. Static reference + weekly signal log.
// 7 sections: Phase / Daily / Cardio / Signals / Gates / Return / Log
//
// RECOVERY-01 — RecoveryTabView: 7-section pill-nav, same pattern as PhysiqueTabView.
//               Static reference sections (Phase–Return) have no SwiftData dependency.
//               Log section reads/writes TibiaRecoveryLog entries via @Query.
// RECOVERY-02 — TibiaRecoveryLog model defined in Models.swift.
// RECOVERY-03 — LogEntrySheet: tap "Log This Week" to open. Pre-fills weekNumber from
//               surgery date. Saves on dismiss. One entry per calendar week enforced.
// RECOVERY-04 — Phase header auto-computes current week from surgeryDate constant.
//               No manual update required week-to-week.
// RECOVERY-05 — Gates section renders a visual timeline with computed status
//               (past / current / upcoming) based on today's date.
// RECOVERY-06 — iPad: IPadMasterDetailLayout (nav rail left, content right).
//               Content pane uses two-column grids where appropriate — not a
//               stretched single column.

// ── Surgery anchor ────────────────────────────────────────────────────────────
private let surgeryDate: Date = {
    var c = DateComponents()
    c.year = 2026; c.month = 4; c.day = 13
    return Calendar.current.date(from: c)!
}()

private var currentWeekPostOp: Int {
    let days = Calendar.current.dateComponents([.day], from: surgeryDate, to: Date()).day ?? 0
    return max(0, days / 7)
}

// ── Phase helper ──────────────────────────────────────────────────────────────
private enum RecoveryPhaseStage: String {
    case phaseI   = "Phase I"
    case phaseII  = "Phase II"
    case phaseIII = "Phase III"
    case phaseIV  = "Phase IV"
}

private var currentStage: RecoveryPhaseStage {
    let w = currentWeekPostOp
    if w < 8  { return .phaseI }
    if w < 16 { return .phaseII }
    if w < 26 { return .phaseIII }
    return .phaseIV
}

// ── Gate dates ────────────────────────────────────────────────────────────────
private struct RecoveryGate: Identifiable {
    let id = UUID()
    let label: String
    let sublabel: String
    let targetDate: Date
    let icon: String

    var status: GateStatus {
        let now = Date()
        if now > targetDate { return .passed }
        let days = Calendar.current.dateComponents([.day], from: now, to: targetDate).day ?? 0
        if days <= 21 { return .approaching }
        return .upcoming
    }

    enum GateStatus { case passed, approaching, upcoming }
}

private let recoveryGates: [RecoveryGate] = {
    func date(_ m: Int, _ d: Int) -> Date {
        var c = DateComponents(); c.year = 2026; c.month = m; c.day = d
        return Calendar.current.date(from: c)!
    }
    return [
        RecoveryGate(label: "Phase II",      sublabel: "Ortho clearance · callus on X-ray",          targetDate: date(6, 8),  icon: "checkmark.seal"),
        RecoveryGate(label: "Phase III",     sublabel: "Full weight-bearing · lower body pain-free",  targetDate: date(8, 3),  icon: "checkmark.seal"),
        RecoveryGate(label: "Road Cycling",  sublabel: "Phase III cleared · balance restored",        targetDate: date(8, 17), icon: "figure.outdoor.cycle"),
        RecoveryGate(label: "Treadmill Run", sublabel: "Month 5 minimum",                             targetDate: date(9, 13), icon: "figure.run"),
        RecoveryGate(label: "Outdoor Run",   sublabel: "Treadmill protocol complete without issue",   targetDate: date(10, 13),icon: "figure.run.circle"),
    ]
}()

// MARK: - ROOT VIEW

struct RecoveryTabView: View {
    @Environment(\.appMetrics) private var metrics
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSection = 0
    @State private var showLogSheet = false
    @Query(sort: \TibiaRecoveryLog.weekEndingDate, order: .reverse) private var logs: [TibiaRecoveryLog]

    let sections = ["Phase", "Daily", "Cardio", "Signals", "Gates", "Return", "Log"]

    var body: some View {
        ZStack {
            AtmosphericBackground()
            VStack(spacing: metrics.cardSpacing) {

                GlanceTabHeader(
                    kicker: "PHYSICAL INFRASTRUCTURE",
                    title: metrics.isIPad ? "Recovery Protocol" : "Recovery",
                    kickerColor: .inkTeal
                ) {
                    if metrics.isIPad {
                        VStack(alignment: .trailing, spacing: metrics.scaledSize(4)) {
                            HStack(spacing: metrics.scaledSize(6)) {
                                MonoLabel(text: "WK", color: .textMuted, size: 9)
                                MonoLabel(text: "\(currentWeekPostOp)", color: .inkTeal, size: 13)
                            }
                            MonoLabel(text: currentStage.rawValue.uppercased(), color: .textMuted, size: 8)
                        }
                    } else {
                        MonoLabel(text: "WK \(currentWeekPostOp) · \(currentStage.rawValue.uppercased())", color: .inkTeal, size: 9)
                    }
                }

                if metrics.isIPad {
                    IPadMasterDetailLayout(metrics: metrics, leftFraction: 0.30) {
                        // ── Left rail: nav ────────────────────────────────
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: metrics.scaledSize(2)) {
                                SectionHeader(text: "SECTIONS", color: .textMuted)
                                    .padding(.horizontal, metrics.hPad)
                                    .padding(.top, metrics.scaledSize(12))
                                    .padding(.bottom, metrics.scaledSize(6))
                                ForEach(sections.indices, id: \.self) { i in
                                    navRailButton(i)
                                }

                                // ── Phase status card in left rail (iPad only) ──
                                Divider()
                                    .opacity(0.15)
                                    .padding(.horizontal, metrics.hPad)
                                    .padding(.vertical, metrics.scaledSize(12))

                                VStack(alignment: .leading, spacing: metrics.scaledSize(10)) {
                                    MonoLabel(text: "STATUS", color: .textMuted, size: 9)
                                        .padding(.horizontal, metrics.hPad)

                                    CardView(style: .secondary) {
                                        VStack(alignment: .leading, spacing: metrics.scaledSize(10)) {
                                            HStack(spacing: metrics.scaledSize(8)) {
                                                Circle().fill(Color.inkTeal).frame(width: 6, height: 6)
                                                MonoLabel(text: "WK \(currentWeekPostOp) · POST-OP", color: .inkTeal, size: 9)
                                            }
                                            // Use abbreviated phase name to avoid wrapping in narrow rail
                                            Text(phaseShortTitle)
                                                .font(metrics.fontSora(11, weight: .medium))
                                                .foregroundColor(.textPrimary)
                                                .lineSpacing(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                                            Text(railGateText)
                                                .font(metrics.fontMono(9))
                                                .foregroundColor(.textMuted)
                                                .lineSpacing(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .padding(.horizontal, metrics.hPad)
                                }
                            }
                            .padding(.vertical, metrics.scaledSize(8))
                            .padding(.bottom, 80)
                        }
                    } right: {
                        // ── Right pane: content ───────────────────────────
                        ScrollView(showsIndicators: false) {
                            Group {
                                switch selectedSection {
                                case 0: phaseSection
                                case 1: dailySection
                                case 2: cardioSection
                                case 3: signalsSection
                                case 4: gatesSection
                                case 5: returnSection
                                case 6: logSection
                                default: phaseSection
                                }
                            }
                            .adaptiveContentWidth(metrics)
                            .padding(.top, metrics.scaledSize(8))
                        }
                    }
                } else {
                    // iPhone: single-line section chips — content gets the screen
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: metrics.scaledSize(6)) {
                                ForEach(sections.indices, id: \.self) { i in
                                    recoverySectionChip(i)
                                }
                            }
                            .padding(.horizontal, metrics.hPad)
                            .padding(.vertical, metrics.scaledSize(6))
                        }

                        Rectangle()
                            .fill(Color.muted.opacity(0.2))
                            .frame(height: 0.5)
                            .padding(.horizontal, metrics.hPad)

                        ScrollView(showsIndicators: false) {
                            Group {
                                switch selectedSection {
                                case 0: phaseSection
                                case 1: dailySection
                                case 2: cardioSection
                                case 3: signalsSection
                                case 4: gatesSection
                                case 5: returnSection
                                case 6: logSection
                                default: phaseSection
                                }
                            }
                            .adaptiveContentWidth(metrics)
                            .padding(.top, metrics.scaledSize(8))
                            .padding(.bottom, 80)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogEntrySheet(existingLogs: logs)
        }
    }

    @ViewBuilder
    private func navRailButton(_ i: Int) -> some View {
        Button(action: { withAnimation(.easeOut(duration: 0.18)) { selectedSection = i } }) {
            HStack(spacing: metrics.scaledSize(12)) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(selectedSection == i ? Color.inkTeal : Color.inkTeal.opacity(0.15))
                    .frame(width: metrics.scaledSize(3), height: metrics.scaledSize(28))
                Text(sections[i])
                    .font(metrics.fontMono(11))
                    .foregroundColor(selectedSection == i ? .textPrimary : .textMuted)
                    .tracking(0.8)
                Spacer()
                if selectedSection == i {
                    Image(systemName: "chevron.right")
                        .font(.system(size: metrics.scaledSize(10), weight: .medium))
                        .foregroundColor(.inkTeal.opacity(0.6))
                }
            }
            .padding(.vertical, metrics.scaledSize(10))
            .padding(.horizontal, metrics.hPad)
            .background(selectedSection == i ? Color.inkTeal.opacity(0.07) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius * 0.6))
        }
        .buttonStyle(.plain)
    }

    private func recoverySectionChip(_ i: Int) -> some View {
        Button(action: { withAnimation(.easeOut(duration: 0.18)) { selectedSection = i } }) {
            Text(sections[i].uppercased())
                .font(metrics.fontMono(9))
                .foregroundColor(selectedSection == i ? .bgBase : .textMuted)
                .tracking(0.5)
                .lineLimit(1)
                .padding(.horizontal, metrics.scaledSize(10))
                .padding(.vertical, metrics.scaledSize(7))
                .background(selectedSection == i ? Color.inkTeal : Color.surface2)
                .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius * 0.45))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 1. PHASE

extension RecoveryTabView {
    var phaseSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            // Phase banner
            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle()
                            .fill(Color.inkTeal)
                            .frame(width: 3, height: 36)
                            .clipShape(RoundedRectangle(cornerRadius: 1.5))
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "CURRENT PHASE · WEEK \(currentWeekPostOp) POST-OP", color: .inkTeal, size: 10)
                            Text(phaseTitle)
                                .font(metrics.fontSora(15, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    Text(phaseBiology)
                        .font(metrics.fontSora(14, weight: .light))
                        .foregroundColor(.textSecond)
                        .lineSpacing(3)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    HStack {
                        MonoLabel(text: "GATE", color: .textMuted, size: 9)
                        Spacer()
                        MonoLabel(text: phaseGateText, color: .inkTeal, size: 9)
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Last signal log — only shown when data exists
            if let last = logs.first {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                        HStack {
                            MonoLabel(text: "LAST LOG · WK \(last.weekNumber)", color: .textMuted, size: 9)
                            Spacer()
                            MonoLabel(
                                text: last.weekEndingDate.formatted(.dateTime.month(.abbreviated).day()),
                                color: .textMuted,
                                size: 9
                            )
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                        HStack(spacing: metrics.scaledSize(24)) {
                            lastLogPill(label: "ANKLE ROM", value: last.ankleROM.label, color: last.ankleROM.color)
                            lastLogPill(label: "TIBIAL PAIN", value: last.tibialPain.label, color: last.tibialPain.color)
                            lastLogPill(label: "BIKE", value: "\(last.bikeSessionsCompleted)/6", color: .inkTeal)
                            Spacer()
                            Button(action: { withAnimation(.easeOut(duration: 0.18)) { selectedSection = 6 } }) {
                                MonoLabel(text: "ALL LOGS →", color: .inkTeal, size: 9)
                            }
                            .buttonStyle(.plain)
                        }
                        if !last.notes.isEmpty {
                            Text(last.notes)
                                .font(metrics.fontSora(12, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }

            // Cleared vs suppressed — side by side on iPad
            if metrics.isIPad {
                HStack(alignment: .top, spacing: metrics.blockSpacing) {
                    clearedCard
                    suppressedCard
                }
                .padding(.horizontal, metrics.hPad)
            } else {
                clearedCard.padding(.horizontal, metrics.hPad)
                suppressedCard.padding(.horizontal, metrics.hPad)
            }
        }
        .padding(.bottom, 80)
    }

    @ViewBuilder
    private func lastLogPill(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(3)) {
            Text(value)
                .font(metrics.fontSora(13, weight: .medium))
                .foregroundColor(color)
            MonoLabel(text: label, color: .textMuted, size: 8)
        }
    }

    private var clearedCard: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                MonoLabel(text: "CLEARED", color: .inkTeal, size: 10)
                VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                    ForEach(clearedItems, id: \.self) { item in
                        HStack(alignment: .top, spacing: metrics.scaledSize(8)) {
                            Circle().fill(Color.inkTeal).frame(width: 4, height: 4).padding(.top, 5)
                            Text(item)
                                .font(metrics.fontSora(13, weight: .light))
                                .foregroundColor(.textSecond)
                                .lineSpacing(2)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: metrics.isIPad ? .infinity : nil)
    }

    private var suppressedCard: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                MonoLabel(text: "NOT YET CLEARED", color: .inkRed, size: 10)
                VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                    ForEach(suppressedItems, id: \.0) { item, reason in
                        HStack(alignment: .top, spacing: metrics.scaledSize(8)) {
                            Circle().fill(Color.inkRed.opacity(0.6)).frame(width: 4, height: 4).padding(.top, 5)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item)
                                    .font(metrics.fontSora(13, weight: .light))
                                    .foregroundColor(.textSecond)
                                Text(reason)
                                    .font(metrics.fontMono(9))
                                    .foregroundColor(.textMuted)
                                    .tracking(0.5)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: metrics.isIPad ? .infinity : nil)
    }

    private var phaseTitle: String {
        switch currentStage {
        case .phaseI:   return "Phase I — Consolidation + Unloaded Strength"
        case .phaseII:  return "Phase II — Progressive Loading + Bone Maturation"
        case .phaseIII: return "Phase III — Return to Full Training"
        case .phaseIV:  return "Phase IV — Restored Capacity"
        }
    }

    // Shorter version for the narrow left rail status card
    private var phaseShortTitle: String {
        switch currentStage {
        case .phaseI:   return "Phase I · Consolidation"
        case .phaseII:  return "Phase II · Progressive Loading"
        case .phaseIII: return "Phase III · Return to Training"
        case .phaseIV:  return "Phase IV · Full Capacity"
        }
    }

    private var phaseBiology: String {
        switch currentStage {
        case .phaseI:
            return "Soft callus formation. Osteoblasts depositing collagen matrix at the fracture site. The IM nail is load-sharing — the bone is not the primary load carrier yet. Controlled axial stress accelerates callus maturation. Goal: progressive load, not immobilization."
        case .phaseII:
            return "Hard callus formation. Woven bone converting to organized lamellar bone. Progressive axial loading now accelerates cortical remodeling. Lower body training reintegration begins here — not before."
        case .phaseIII:
            return "Bone remodeling ongoing but structurally sufficient for full training loads. The IM nail remains permanent — it protects the tibia under high load during this phase."
        case .phaseIV:
            return "Full training capacity. All three return-to-activity targets cleared and building. Upper body ahead of pre-injury baseline. Race return decision point."
        }
    }

    private var phaseGateText: String {
        switch currentStage {
        case .phaseI:   return "~June 8 · Ortho follow-up · callus on X-ray"
        case .phaseII:  return "~Aug 3 · Full weight-bearing · lower body pain-free"
        case .phaseIII: return "~Oct 5 · Physician signoff"
        case .phaseIV:  return "Full capacity"
        }
    }

    // Shorter gate text for the narrow left rail
    private var railGateText: String {
        switch currentStage {
        case .phaseI:   return "~June 8 · Ortho + X-ray"
        case .phaseII:  return "~Aug 3 · Full load"
        case .phaseIII: return "~Oct 5 · Signoff"
        case .phaseIV:  return "Full capacity"
        }
    }

    private var clearedItems: [String] {
        switch currentStage {
        case .phaseI:
            return [
                "Stationary bike — low-to-moderate resistance, full pedal stroke",
                "Elliptical — low resistance, controlled pace",
                "Upper body — Breechay Sculpt Phase 1 (injury-modified). Full program, no restriction. This is the active training architecture for this phase.",
                "Ankle pumps + circles — 3× daily minimum",
                "Calf stretch (seated/standing) — daily",
                "Terminal knee extensions — light band, both sides",
                "Quad sets — isometric, both sides",
                "Clamshells, banded hip abduction — both sides",
                "Single-leg glute bridge — right/uninjured side only",
                "Standing hip abduction — left, supported, pain-free range",
                "Walking with crutch support — per surgeon's protocol",
                "Single-leg balance — right leg only (Week 6+)",
            ]
        case .phaseII:
            return [
                "Full weight-bearing walking, crutch-free (Week 8–10)",
                "Bodyweight squat, goblet squat, bodyweight hip thrust",
                "Resistance added at Week 10–12 (start light, progress by response)",
                "Progressive overload from Week 12–14",
                "Full lower body program by Week 14–16",
                "Aqua jogging — zero tibial stress",
                "Zone 3 bike intervals (Week 12+)",
                "Single-leg balance — left leg, clearance required",
            ]
        case .phaseIII, .phaseIV:
            return [
                "Full bilateral lower body program",
                "Stairmaster — begin 15 min at low pace",
                "Loaded hip thrusts, RDLs, full posterior chain",
                "Road cycling (Week 16–18)",
                "Treadmill running (~Month 5)",
                "Outdoor running (~Month 6, after treadmill protocol complete)",
            ]
        }
    }

    private var suppressedItems: [(String, String)] {
        switch currentStage {
        case .phaseI:
            return [
                ("Bilateral loaded squat / lunge / leg press", "Axial load on healing tibia"),
                ("Romanian deadlifts, loaded hip thrusts", "Same"),
                ("Single-leg loaded work on injured side", "Same"),
                ("Stairmaster", "Suppressed in Phase I — tibial stress AND locked in Breechay Sculpt Phase 1 spec. Unlocking requires both Phase II clearance AND a Forge program update."),
                ("Running, jumping, plyometrics", "Bone not consolidated"),
                ("Road cycling", "Fall risk on healing leg — balance not yet restored"),
                ("Left-leg single-leg balance", "Phase II+ only with clearance"),
            ]
        case .phaseII:
            return [
                ("Road cycling", "Phase III gate — balance not yet fully confirmed"),
                ("Running of any kind", "Month 5 minimum"),
                ("Stairmaster", "Phase III gate"),
            ]
        case .phaseIII:
            return [
                ("Outdoor running", "Treadmill protocol must complete first"),
            ]
        case .phaseIV:
            return []
        }
    }
}

// MARK: - 2. DAILY PROTOCOLS

extension RecoveryTabView {

    var dailySection: some View {
        VStack(spacing: metrics.blockSpacing) {

            // Context note
            CardView(style: .ambient) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "WHY THESE FOUR PROTOCOLS", color: .inkTeal, size: 9)
                    Text("The fracture is healing. These protocols address what the healing process does not fix on its own: joint stiffness from swelling and disuse, quad inhibition from the nail entry site, glute dropout from altered gait mechanics, and proprioceptive loss that the nail does not restore.")
                        .font(metrics.fontSora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(3)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Arrive at Phase II with these four systems already working and the reintegration is clean. Skip them and you heal the bone but break the movement.")
                        .font(metrics.fontSora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(3)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Stack all protocol cards vertically on all devices.
            // Side-by-side on iPad gives ~240pt per card — too narrow for
            // the detailed rationale text in each protocol card.
            ankleCard.padding(.horizontal, metrics.hPad)
            hipCard.padding(.horizontal, metrics.hPad)
            quadCard.padding(.horizontal, metrics.hPad)
            proprioCard.padding(.horizontal, metrics.hPad)
        }
        .padding(.bottom, 80)
    }

    private var ankleCard: some View {
        protocolCard(
            label: "ANKLE MOBILITY",
            frequency: "Daily · before bed · 8 min",
            icon: "figure.flexibility",
            rationale: "The joint stiffens in response to swelling and disuse — it does not announce this during consolidation. It shows up months later as a gait compensation pattern. If you arrive at Phase II with restricted dorsiflexion, your mechanics are already compromised before you take a full step. Before bed is the right slot — joint offloads immediately after.",
            moves: ankleProtocol
        )
    }

    private var hipCard: some View {
        protocolCard(
            label: "HIP + GLUTE ACTIVATION",
            frequency: "3–4× per week · post-Forge or Hideout stewardship window",
            icon: "figure.strengthtraining.traditional",
            rationale: "The left glute has been underloaded for 5+ weeks. Crutch gait builds compensatory patterns — the right side overworks, the left switches off. That imbalance becomes the next injury when load returns. Hip flexor tightening happens on both sides from altered stride mechanics. Address both now, not at Phase II when you are already trying to reintroduce load.",
            moves: hipProtocol
        )
    }

    private var quadCard: some View {
        protocolCard(
            label: "QUAD RECRUITMENT",
            frequency: "Daily · 5 min · seated — can happen at Hideout between rushes",
            icon: "figure.walk",
            rationale: "The antegrade IM nail enters at the patellar tendon. This is why anterior knee pain and quad inhibition are extremely common after this fixation — the entry site disrupts the VMO signal. Terminal knee extensions with a light band wake the quad back up without loading the tibia. You can do these seated. The goal is restoring the neuromuscular signal, not building strength yet.",
            moves: quadProtocol
        )
    }

    private var proprioCard: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "PROPRIOCEPTION", color: .textMuted, size: 10)
                        Text("Begin Week 6 · right side first")
                            .font(metrics.fontSora(13, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                    Spacer()
                    Image(systemName: "figure.stand")
                        .font(.system(size: metrics.scaledSize(20), weight: .ultraLight))
                        .foregroundColor(.textMuted.opacity(0.3))
                }
                Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                CardView(style: .ambient) {
                    Text("The IM nail stabilizes the fracture but does not restore the proprioceptive pathway — the nervous system's map of where the limb is in space. That map was disrupted by the injury and 5 weeks of disuse. It needs to be rebuilt separately. This affects confidence on a bike, stability at pace, and injury risk on uneven terrain. Start right leg now. Left leg begins at Phase II with clearance.")
                        .font(metrics.fontSora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(3)
                }
                ForEach(proprioProtocol, id: \.0) { move, prescription in
                    moveRow(move: move, prescription: prescription, color: .textMuted)
                }
            }
        }
        .frame(maxWidth: metrics.isIPad ? .infinity : nil)
    }

    @ViewBuilder
    private func protocolCard(label: String, frequency: String, icon: String, rationale: String, moves: [(String, String)]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: label, color: .inkTeal, size: 10)
                        Text(frequency)
                            .font(metrics.fontSora(12, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: metrics.scaledSize(20), weight: .ultraLight))
                        .foregroundColor(.inkTeal.opacity(0.35))
                }
                Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                CardView(style: .ambient) {
                    Text(rationale)
                        .font(metrics.fontSora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                }
                Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                ForEach(moves, id: \.0) { move, prescription in
                    moveRow(move: move, prescription: prescription, color: .inkTeal)
                }
            }
        }
        .frame(maxWidth: metrics.isIPad ? .infinity : nil)
    }

    @ViewBuilder
    private func moveRow(move: String, prescription: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: metrics.scaledSize(12)) {
            Circle().fill(color.opacity(0.5)).frame(width: 5, height: 5).padding(.top, 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(move)
                    .font(metrics.fontSora(13, weight: .regular))
                    .foregroundColor(.textPrimary)
                Text(prescription)
                    .font(metrics.fontMono(10))
                    .foregroundColor(color)
                    .tracking(0.3)
            }
        }
    }

    private var ankleProtocol: [(String, String)] {[
        ("Seated ankle pumps", "Dorsiflexion + plantarflexion · 30 reps each direction"),
        ("Seated ankle circles", "20 reps each direction · slow and controlled"),
        ("Towel-assisted calf stretch", "Seated · 45 sec hold × 2"),
        ("Wall dorsiflexion stretch", "Supported · 45 sec × 2 each side"),
        ("Standing heel raises", "Right leg only · 3 × 15 · controlled eccentric"),
        ("Alphabet trace", "Foot writing A–Z in air · once daily · last thing before bed"),
    ]}

    private var hipProtocol: [(String, String)] {[
        ("Clamshells with resistance band", "3 × 15 each side"),
        ("Side-lying hip abduction", "3 × 15 each side"),
        ("Single-leg glute bridge", "Right/uninjured only · 3 × 12"),
        ("Standing hip abduction, left", "Supported · 3 × 12 · pain-free range only"),
        ("Supine pelvic tilts", "2 × 20 · spine neutral"),
        ("Hip flexor stretch", "Kneeling or seated · 45 sec × 2 each side"),
    ]}

    private var quadProtocol: [(String, String)] {[
        ("Terminal knee extensions (TKE)", "Light band behind knee · straighten from ~30° · 3 × 15 each side"),
        ("Quad sets (isometric)", "Seated, leg straight · push down into surface · 10 sec hold × 10"),
        ("Straight leg raise", "Supine · lock knee · raise 45° · 3 × 12 each side"),
        ("Short arc quads", "Rolled towel under knee · extend from 45° to full · 3 × 15 each side"),
    ]}

    private var proprioProtocol: [(String, String)] {[
        ("Single-leg stand, right leg", "3 × 30 sec eyes open → progress to eyes closed"),
        ("Weight shifts side-to-side", "3 × 20 with crutch support available"),
        ("Single-leg stand, left leg", "Week 8+ with clearance · 3 × 15 sec eyes open"),
        ("Balance disc / wobble board", "Week 12+ with clearance · bilateral first"),
    ]}
}

// MARK: - 3. CARDIO

extension RecoveryTabView {
    var cardioSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "CARDIO INFRASTRUCTURE", color: .inkTeal, size: 10)
                    Text("Near-daily stationary bike — already established. Protect this structure. Do not reduce it to add lower body work later; add lower body work around it.")
                        .font(metrics.fontSora(13, weight: .light))
                        .foregroundColor(.textSecond)
                        .lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // On iPad: horizontal scroll for the three session cards (same fix as Return section)
            if metrics.isIPad {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: metrics.blockSpacing) {
                        ForEach(cardioSessions, id: \.0) { type, freq, duration, rx in
                            cardioSessionCard(type: type, freq: freq, duration: duration, rx: rx)
                                .frame(width: 260)
                        }
                    }
                    .padding(.horizontal, metrics.hPad)
                    .padding(.vertical, 4)
                }
            } else {
                ForEach(cardioSessions, id: \.0) { type, freq, duration, rx in
                    cardioSessionCard(type: type, freq: freq, duration: duration, rx: rx)
                        .padding(.horizontal, metrics.hPad)
                }
            }

            // Notes — full width both devices
            HStack(alignment: .top, spacing: metrics.blockSpacing) {
                CardView(style: .ambient) {
                    VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                        MonoLabel(text: "ZONE 3 + TIBIAL LOAD", color: .textMuted, size: 9)
                        Text("Increased cycling effort means increased quad demand, which increases tibial compressive load through the knee. Still cleared. Watch for tibial ache 24h post-session — especially during Zone 3 efforts and Phase II resistance progression.")
                            .font(metrics.fontSora(12, weight: .light))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                    }
                }

                if metrics.isIPad {
                    CardView(style: .ambient) {
                        VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                            MonoLabel(text: "HIDEOUT STANDING TIME", color: .textMuted, size: 9)
                            Text("Café shift time on feet contributes axial load. End-of-day swelling that resets overnight is normal physiology — your leg is working. Track shift hours in the weekly log to correlate with swelling severity.")
                                .font(metrics.fontSora(12, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            if !metrics.isIPad {
                CardView(style: .ambient) {
                    VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                        MonoLabel(text: "HIDEOUT STANDING TIME", color: .textMuted, size: 9)
                        Text("Café shift time on feet contributes axial load. End-of-day swelling that resets overnight is normal physiology. Track shift hours in the weekly log to correlate with swelling severity.")
                            .font(metrics.fontSora(12, weight: .light))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }
        }
        .padding(.bottom, 80)
    }

    @ViewBuilder
    private func cardioSessionCard(type: String, freq: String, duration: String, rx: String) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: type, color: .inkTeal, size: 10)
                        Text(freq)
                            .font(metrics.fontSora(12, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                    Spacer()
                    MonoLabel(text: duration, color: .textMuted, size: 10)
                }
                Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                Text(rx)
                    .font(metrics.fontSora(13, weight: .light))
                    .foregroundColor(.textSecond)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var cardioSessions: [(String, String, String, String)] {[
        ("Zone 2 Base",
         "4–5× per week",
         "35–45 min",
         "Conversational pace. HR ~130–145. This is the foundation. Don't reduce it."),
        ("Aerobic Development",
         "1× per week",
         "25–30 min",
         "Zone 3 push. HR 150–160. Moderate resistance. Add Zone 3 intervals at Week 12+ in Phase II."),
        ("Active Recovery",
         "1× per week",
         "20 min",
         "Very low resistance. Pure circulation. Counts toward daily load budget."),
    ]}
}

// MARK: - 4. SIGNALS

extension RecoveryTabView {
    var signalsSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView(style: .ambient) {
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "SIGNAL REFERENCE", color: .textMuted, size: 9)
                    Text("What to track. What's noise. What requires action. End-of-day swelling that resets overnight is normal — dependent edema from upright load plus active vascular healing. Not a warning.")
                        .font(metrics.fontSora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // All layouts: stack vertically. Each tier card needs full readable width.
            // On iPad in the master-detail right pane, a 2-col HStack gives ~240pt per card
            // which wraps long signal text. Full width stacked is cleaner and more readable.
            signalTierCard(label: "NORMAL — THIS IS NOISE", color: .inkTeal, signals: normalSignals)
                .padding(.horizontal, metrics.hPad)
            signalTierCard(label: "WATCH — ASSESS", color: .inkAmber, signals: watchSignals)
                .padding(.horizontal, metrics.hPad)
            signalTierCard(label: "HARD STOP — SAME DAY", color: .inkRed, signals: hardStopSignals)
                .padding(.horizontal, metrics.hPad)
        }
        .padding(.bottom, 80)
    }

    @ViewBuilder
    private func signalTierCard(label: String, color: Color, signals: [(String, String)]) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                MonoLabel(text: label, color: color, size: 10)
                ForEach(signals, id: \.0) { signal, meaning in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: metrics.scaledSize(8)) {
                            Circle()
                                .fill(color.opacity(0.7))
                                .frame(width: 5, height: 5)
                                .padding(.top, 5)
                            Text(signal)
                                .font(metrics.fontSora(13, weight: .regular))
                                .foregroundColor(.textPrimary)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Text(meaning)
                            .font(metrics.fontMono(10))
                            .foregroundColor(color.opacity(0.8))
                            .tracking(0.3)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 13)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var normalSignals: [(String, String)] {[
        ("Aching after activity, resolves with rest", "Expected — bone consolidating"),
        ("Mild morning stiffness", "Expected — reduced circulation overnight"),
        ("End-of-day swelling that resets by morning", "Dependent edema — normal physiology"),
        ("Sharp sensation around nail entry site (knee)", "Hardware awareness, not fracture signal"),
    ]}

    private var watchSignals: [(String, String)] {[
        ("Swelling post-bike that doesn't resolve overnight", "Stop activity. Elevate. Reassess next day."),
        ("Tibial ache >24h after Zone 3 effort", "Drop back to Zone 2 only for one week."),
        ("Ankle ROM plateau for 2+ consecutive weeks", "Increase ankle protocol frequency."),
        ("Persistent anterior knee ache", "Increase TKE frequency. Monitor."),
    ]}

    private var hardStopSignals: [(String, String)] {[
        ("Warmth or redness at incision site", "Contact surgeon — possible infection"),
        ("Acute pain increase during weight-bearing", "Stop immediately. No loading until assessed."),
        ("New foot numbness or tingling", "Contact surgeon same day — compartment risk"),
        ("Pain localized at mid-shaft fracture site persisting >hours", "Stop load. Contact surgeon."),
    ]}
}

// MARK: - 5. GATES

extension RecoveryTabView {
    var gatesSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            phase2ClinicalGateCard

            CardView(style: .ambient) {
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "PHASE GATE TIMELINE", color: .textMuted, size: 9)
                    Text("Each gate is condition-based, not calendar-based. Dates are planning targets. Physician clearance governs Phase II and III entry. The date does not grant permission.")
                        .font(metrics.fontSora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView {
                VStack(alignment: .leading, spacing: metrics.scaledSize(metrics.isIPad ? 28 : 20)) {
                    ForEach(Array(recoveryGates.enumerated()), id: \.element.id) { i, gate in
                        HStack(alignment: .top, spacing: metrics.scaledSize(16)) {
                            // Timeline spine
                            VStack(spacing: 0) {
                                gateStatusDot(gate.status)
                                if i < recoveryGates.count - 1 {
                                    Rectangle()
                                        .fill(Color.muted.opacity(0.2))
                                        .frame(width: 1)
                                        .frame(height: metrics.scaledSize(metrics.isIPad ? 36 : 28))
                                }
                            }

                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                HStack {
                                    Image(systemName: gate.icon)
                                        .font(.system(size: metrics.scaledSize(11), weight: .light))
                                        .foregroundColor(gateColor(gate.status))
                                    Text(gate.label)
                                        .font(metrics.fontSora(metrics.isIPad ? 16 : 14, weight: .medium))
                                        .foregroundColor(gateColor(gate.status))
                                    Spacer()
                                    MonoLabel(
                                        text: gate.targetDate.formatted(.dateTime.month(.abbreviated).day()),
                                        color: .textMuted,
                                        size: 9
                                    )
                                }
                                Text(gate.sublabel)
                                    .font(metrics.fontSora(metrics.isIPad ? 13 : 12, weight: .light))
                                    .foregroundColor(.textMuted)
                                    .lineSpacing(1)
                                if gate.status == .passed {
                                    MonoLabel(text: "PASSED", color: .inkTeal, size: 9)
                                } else if gate.status == .approaching {
                                    MonoLabel(text: "APPROACHING — PREPARE PHYSICIAN VISIT", color: .inkAmber, size: 9)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)
            .padding(.bottom, 80)
        }
    }

    private var latestRecoveryLog: TibiaRecoveryLog? { logs.first }

    private enum Phase2GateBadge {
        case hardStop, met, partial, notCleared

        var label: String {
            switch self {
            case .hardStop: return "HARD STOP"
            case .met: return "GATE MET"
            case .partial: return "PARTIAL"
            case .notCleared: return "NOT CLEARED"
            }
        }

        var color: Color {
            switch self {
            case .hardStop: return .inkRed
            case .met: return .inkGreen
            case .partial: return .inkAmber
            case .notCleared: return .textMuted
            }
        }
    }

    private var phase2GateBadge: Phase2GateBadge {
        guard let log = latestRecoveryLog else { return .notCleared }
        if log.hardStopSignalThisWeek { return .hardStop }
        if log.unilateralLoadingPainFree && log.singleLegRDLStable { return .met }
        if log.unilateralLoadingPainFree || log.singleLegRDLStable { return .partial }
        return .notCleared
    }

    private var phase2ClinicalGateCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                HStack {
                    MonoLabel(text: "PHASE 2 CLINICAL GATE", color: .inkTeal, size: 10)
                    Spacer()
                    MonoLabel(text: phase2GateBadge.label, color: phase2GateBadge.color, size: 9)
                }

                if latestRecoveryLog == nil {
                    Button(action: { showLogSheet = true }) {
                        Text("Log this week first to record gate status.")
                            .font(.system(size: metrics.scaledSize(11), design: .monospaced))
                            .foregroundColor(.inkAmber)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                } else {
                    gateCriterionRow(
                        label: "Pain-free unilateral loading confirmed",
                        isOn: latestRecoveryLog?.unilateralLoadingPainFree == true,
                        enabled: latestRecoveryLog?.hardStopSignalThisWeek != true
                    ) {
                        toggleUnilateralGate()
                    }
                    gateCriterionRow(
                        label: "Stable single-leg RDL tolerance confirmed",
                        isOn: latestRecoveryLog?.singleLegRDLStable == true,
                        enabled: latestRecoveryLog?.hardStopSignalThisWeek != true
                    ) {
                        toggleSingleLegRDLGate()
                    }
                }

                gateHardStopRow

                Text("\"Gate met\" requires BOTH criteria confirmed AND no hard stop. Not elapsed time. Not subjective feel. Clinical only.")
                    .font(.system(size: metrics.scaledSize(11), design: .monospaced))
                    .foregroundColor(.textMuted)
                    .lineSpacing(2)
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    private func gateCriterionRow(label: String, isOn: Bool, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: metrics.cardSpacing) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: metrics.scaledSize(14), weight: .light))
                    .foregroundColor(isOn ? .inkGreen : .textMuted)
                Text(label)
                    .font(metrics.fontSora(13, weight: .light))
                    .foregroundColor(isOn ? .inkGreen : .textSecond)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .disabled(!enabled || latestRecoveryLog == nil)
        .opacity(enabled ? 1 : 0.45)
    }

    private var gateHardStopRow: some View {
        let active = latestRecoveryLog?.hardStopSignalThisWeek == true
        return Button(action: toggleHardStopSignal) {
            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                    Image(systemName: active ? "checkmark.square.fill" : "square")
                        .font(.system(size: metrics.scaledSize(14), weight: .light))
                        .foregroundColor(active ? .inkRed : .textMuted)
                    Text("Hard-stop signal this week")
                        .font(metrics.fontSora(13, weight: .medium))
                        .foregroundColor(active ? .inkRed : .textSecond)
                    Spacer()
                }
                if active {
                    Text("Active hard stop — do not probe. Monitor: warmth · acute WB pain · numbness · mid-shaft pain.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced))
                        .foregroundColor(.inkRed)
                        .lineSpacing(2)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(latestRecoveryLog == nil)
    }

    private func toggleUnilateralGate() {
        guard let log = latestRecoveryLog else { return }
        log.unilateralLoadingPainFree.toggle()
        try? modelContext.save()
    }

    private func toggleSingleLegRDLGate() {
        guard let log = latestRecoveryLog else { return }
        log.singleLegRDLStable.toggle()
        try? modelContext.save()
    }

    private func toggleHardStopSignal() {
        guard let log = latestRecoveryLog else { return }
        log.hardStopSignalThisWeek.toggle()
        if log.hardStopSignalThisWeek {
            log.unilateralLoadingPainFree = false
            log.singleLegRDLStable = false
        }
        try? modelContext.save()
    }

    @ViewBuilder
    private func gateStatusDot(_ status: RecoveryGate.GateStatus) -> some View {
        ZStack {
            Circle()
                .fill(gateColor(status).opacity(0.15))
                .frame(width: 18, height: 18)
            Circle()
                .fill(gateColor(status))
                .frame(width: 8, height: 8)
        }
    }

    private func gateColor(_ status: RecoveryGate.GateStatus) -> Color {
        switch status {
        case .passed:     return .inkTeal
        case .approaching: return .inkAmber
        case .upcoming:   return .textMuted
        }
    }
}

// MARK: - 6. RETURN TO ACTIVITY

extension RecoveryTabView {
    var returnSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView(style: .ambient) {
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "SEQUENCED BY TIBIAL IMPACT LOAD", color: .textMuted, size: 9)
                    Text("Lowest to highest. Do not collapse the sequence. Each protocol is a gate for the next. Road cycling is not about tibial stress — it's about fall risk on a healing leg.")
                        .font(metrics.fontSora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            if metrics.isIPad {
                // iPad: horizontal scroll so each card gets enough width to read.
                // 3-column HStack in the master-detail right pane gives ~155pt per card
                // which wraps every word. ScrollView with fixed card width reads cleanly.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: metrics.blockSpacing) {
                        ReturnProtocolCard(
                            title: "Road Cycling",
                            earliest: "~Week 16–18 · August",
                            icon: "figure.outdoor.cycle",
                            color: .inkTeal,
                            rationale: "No impact load. Primary risk is fall on healing leg — waits until balance and weight-bearing are fully restored, not because cycling stresses the tibia.",
                            caution: "Any sharp tibial pain during pedaling, especially on hard efforts or climbs. Aching that doesn't resolve after a session = back off one week.",
                            weeks: cyclingWeeks
                        )
                        .frame(width: 280)

                        ReturnProtocolCard(
                            title: "Treadmill Run",
                            earliest: "~Month 5 · September",
                            icon: "figure.run",
                            color: .inkTeal,
                            rationale: "Controlled surface. Consistent pace. No lateral movement. Easy to stop. Lower psychological pressure to push through discomfort. Treadmill before outdoor for these reasons.",
                            caution: "Any tibial pain during or within 24h after a session = drop back one week. No exceptions. No pace targets in first 4 weeks.",
                            weeks: treadmillWeeks
                        )
                        .frame(width: 280)

                        ReturnProtocolCard(
                            title: "Outdoor Run",
                            earliest: "~Month 6 · October",
                            icon: "figure.run.circle",
                            color: .inkTeal,
                            rationale: "Uneven surface, lateral demands, harder to control pace, harder to stop. Each adds tibial stress above what treadmill tests. Only after treadmill protocol completed without issue.",
                            caution: "Tibial response on outdoor terrain is often different from treadmill. Pay attention to left leg at the 15–20 min mark on first outdoor runs — that's when fatigue shifts load to the bone.",
                            weeks: outdoorWeeks
                        )
                        .frame(width: 280)
                    }
                    .padding(.horizontal, metrics.hPad)
                    .padding(.vertical, 4)
                }
            } else {
                ReturnProtocolCard(
                    title: "Road Cycling",
                    earliest: "~Week 16–18 · August 2026",
                    icon: "figure.outdoor.cycle",
                    color: .inkTeal,
                    rationale: "No impact load. Primary risk is fall on healing leg — waits until balance and weight-bearing are fully restored.",
                    caution: "Any sharp tibial pain during pedaling, especially on hard efforts or climbs. Aching that doesn't resolve after a session = back off one week.",
                    weeks: cyclingWeeks
                )
                ReturnProtocolCard(
                    title: "Treadmill Running",
                    earliest: "~Month 5 · September 2026",
                    icon: "figure.run",
                    color: .inkTeal,
                    rationale: "Controlled surface. Consistent pace. No lateral movement. Easy to stop. Treadmill before outdoor for these reasons.",
                    caution: "Any tibial pain during or within 24h after a session = drop back one week. No exceptions. No pace targets in first 4 weeks.",
                    weeks: treadmillWeeks
                )
                ReturnProtocolCard(
                    title: "Outdoor Running",
                    earliest: "~Month 6 · October 2026",
                    icon: "figure.run.circle",
                    color: .inkTeal,
                    rationale: "Uneven surface, lateral demands, harder to control pace, harder to stop. Only after treadmill protocol completed without issue.",
                    caution: "Left leg at the 15–20 min mark on first outdoor runs — that's when fatigue shifts load to the bone.",
                    weeks: outdoorWeeks
                )
                .padding(.bottom, 80)
            }
        }
        .padding(.bottom, metrics.isIPad ? 80 : 0)
    }

    private var cyclingWeeks: [(String, String, String)] {[
        ("Week 1", "20–30 min flat route, easy pace", "No clipless pedals yet. Flat terrain only."),
        ("Week 2", "30–40 min, same terrain", "Add clipless if confidence is there"),
        ("Week 3", "40–50 min, minor elevation OK", "Monitor left leg fatigue separately"),
        ("Week 4+", "Standard progressive build", "Normal cycling progression from here"),
    ]}

    private var treadmillWeeks: [(String, String, String)] {[
        ("Week 1", "Walk 2 min / Jog 1 min × 8", "27 min · 3 sessions/week"),
        ("Week 2", "Walk 1 min / Jog 2 min × 8", "24 min · 3 sessions/week"),
        ("Week 3", "Walk 1 min / Jog 3 min × 7", "28 min · 3 sessions/week"),
        ("Week 4", "Jog 20 min continuous (if pain-free)", "3 sessions/week · repeat Week 3 if any tibial response"),
        ("Week 5–6", "Build to 30 min continuous", "3–4 sessions/week"),
    ]}

    private var outdoorWeeks: [(String, String, String)] {[
        ("Week 1–2", "Walk/jog intervals matching treadmill Week 3–4", "Flat surface only. Even pavement."),
        ("Week 3–4", "20–25 min continuous, flat", "Still no hills"),
        ("Week 5–6", "Introduce mild terrain variation", "Slight grades OK"),
        ("Week 7+", "Normal outdoor running progression", "Standard load management"),
    ]}
}

// Shared return protocol card — works on both iPhone (full width) and iPad (1/3 column)
private struct ReturnProtocolCard: View {
    @Environment(\.appMetrics) private var metrics
    let title: String
    let earliest: String
    let icon: String
    let color: Color
    let rationale: String
    let caution: String
    let weeks: [(String, String, String)]

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.easeOut(duration: 0.2)) { isExpanded.toggle() } }) {
                CardView {
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: metrics.scaledSize(18), weight: .ultraLight))
                            .foregroundColor(color.opacity(0.7))
                            .frame(width: metrics.scaledSize(28))
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: title.uppercased(), color: color, size: 10)
                            Text(earliest)
                                .font(metrics.fontSora(12, weight: .light))
                                .foregroundColor(.textMuted)
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: metrics.scaledSize(11), weight: .light))
                            .foregroundColor(.textMuted)
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "WHY THIS SEQUENCE", color: .textMuted, size: 9)
                            Text(rationale)
                                .font(metrics.fontSora(13, weight: .light))
                                .foregroundColor(.textSecond)
                                .lineSpacing(2)
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                        VStack(alignment: .leading, spacing: metrics.scaledSize(10)) {
                            MonoLabel(text: "PROTOCOL", color: .textMuted, size: 9)
                            ForEach(weeks, id: \.0) { week, session, note in
                                HStack(alignment: .top, spacing: metrics.scaledSize(10)) {
                                    MonoLabel(text: week, color: color, size: 9)
                                        .frame(width: metrics.scaledSize(60), alignment: .leading)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(session)
                                            .font(metrics.fontSora(12, weight: .regular))
                                            .foregroundColor(.textPrimary)
                                        Text(note)
                                            .font(metrics.fontSora(11, weight: .light))
                                            .foregroundColor(.textMuted)
                                    }
                                }
                            }
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "WATCH FOR", color: .inkAmber, size: 9)
                            Text(caution)
                                .font(metrics.fontSora(12, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, metrics.isIPad ? 0 : metrics.hPad)
    }
}

// MARK: - 7. LOG

extension RecoveryTabView {
    var logSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                HStack {
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "WEEKLY SIGNAL LOG", color: .inkTeal, size: 10)
                        Text("One entry per week. Friday after close.")
                            .font(metrics.fontSora(13, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                    Spacer()
                    Button(action: { showLogSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: metrics.scaledSize(11), weight: .medium))
                            Text("LOG THIS WEEK")
                                .font(metrics.fontMono(10))
                                .tracking(0.5)
                        }
                        .foregroundColor(.bgBase)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.inkTeal)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            if logs.isEmpty {
                CardView(style: .secondary) {
                    VStack(spacing: metrics.cardSpacing) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: metrics.scaledSize(28), weight: .ultraLight))
                            .foregroundColor(.textMuted.opacity(0.4))
                        Text("No entries yet. Log your first week.")
                            .font(metrics.fontSora(13, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, metrics.scaledSize(20))
                }
                .padding(.horizontal, metrics.hPad)
            } else if metrics.isIPad {
                // iPad: 2-up grid of log entries
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: metrics.blockSpacing), GridItem(.flexible())],
                    spacing: metrics.blockSpacing
                ) {
                    ForEach(logs) { log in
                        LogEntryRow(log: log)
                    }
                }
                .padding(.horizontal, metrics.hPad)
            } else {
                ForEach(logs) { log in
                    LogEntryRow(log: log)
                        .padding(.horizontal, metrics.hPad)
                }
            }
        }
        .padding(.bottom, 80)
    }
}

// MARK: - Log entry row (read-only)

private struct LogEntryRow: View {
    @Environment(\.appMetrics) private var metrics
    let log: TibiaRecoveryLog

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                HStack {
                    MonoLabel(text: "WK \(log.weekNumber) POST-OP", color: .inkTeal, size: 10)
                    Spacer()
                    MonoLabel(
                        text: log.weekEndingDate.formatted(.dateTime.month(.abbreviated).day()),
                        color: .textMuted,
                        size: 9
                    )
                }
                Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                HStack(spacing: metrics.scaledSize(16)) {
                    logSignalPill(label: "Ankle ROM", value: log.ankleROM.label, color: log.ankleROM.color)
                    logSignalPill(label: "Tibial Pain", value: log.tibialPain.label, color: log.tibialPain.color)
                    logSignalPill(label: "Bike", value: "\(log.bikeSessionsCompleted)/6", color: .inkTeal)
                }
                if !log.notes.isEmpty {
                    Text(log.notes)
                        .font(metrics.fontSora(12, weight: .light))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                }
            }
        }
    }

    @ViewBuilder
    private func logSignalPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: metrics.rowSpacing) {
            Text(value)
                .font(metrics.fontSora(13, weight: .medium))
                .foregroundColor(color)
            MonoLabel(text: label, color: .textMuted, size: 8)
        }
    }
}

// MARK: - Log entry sheet

struct LogEntrySheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appMetrics) private var metrics

    let existingLogs: [TibiaRecoveryLog]

    @State private var ankleROM: TibiaRecoveryLog.AnkleROMSignal = .improving
    @State private var tibialPain: TibiaRecoveryLog.TibialPainSignal = .none
    @State private var bikeSessionsCompleted: Int = 0
    @State private var notes: String = ""

    private var autoWeekNumber: Int {
        let days = Calendar.current.dateComponents([.day], from: surgeryDate, to: Date()).day ?? 0
        return max(0, days / 7)
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: metrics.blockSpacing) {

                    // Header
                    CardView(style: .ambient) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "WEEK \(autoWeekNumber) SIGNAL LOG", color: .inkTeal, size: 10)
                            Text("Four signals. One entry per week.")
                                .font(metrics.fontSora(13, weight: .light))
                                .foregroundColor(.textMuted)
                        }
                    }
                    .padding(.horizontal, metrics.hPad)

                    // Ankle ROM
                    logFieldCard(label: "ANKLE ROM VS LAST WEEK") {
                        HStack(spacing: 8) {
                            ForEach(TibiaRecoveryLog.AnkleROMSignal.allCases, id: \.self) { val in
                                Button(action: { ankleROM = val }) {
                                    Text(val.label)
                                        .font(metrics.fontMono(10))
                                        .tracking(0.4)
                                        .foregroundColor(ankleROM == val ? .bgBase : .textMuted)
                                        .padding(.horizontal, 10).padding(.vertical, 7)
                                        .background(ankleROM == val ? val.color : Color.surface2)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                }
                            }
                        }
                    }

                    // Tibial pain
                    logFieldCard(label: "TIBIAL PAIN ON WEIGHT-BEARING") {
                        HStack(spacing: 8) {
                            ForEach(TibiaRecoveryLog.TibialPainSignal.allCases, id: \.self) { val in
                                Button(action: { tibialPain = val }) {
                                    Text(val.label)
                                        .font(metrics.fontMono(10))
                                        .tracking(0.4)
                                        .foregroundColor(tibialPain == val ? .bgBase : .textMuted)
                                        .padding(.horizontal, 10).padding(.vertical, 7)
                                        .background(tibialPain == val ? val.color : Color.surface2)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                }
                            }
                        }
                    }

                    // Bike sessions
                    logFieldCard(label: "BIKE SESSIONS COMPLETED (OF 6)") {
                        HStack(spacing: 8) {
                            ForEach([0,1,2,3,4,5,6], id: \.self) { n in
                                Button(action: { bikeSessionsCompleted = n }) {
                                    Text("\(n)")
                                        .font(metrics.fontMono(12))
                                        .foregroundColor(bikeSessionsCompleted == n ? .bgBase : .textMuted)
                                        .frame(width: 34, height: 34)
                                        .background(bikeSessionsCompleted == n ? Color.inkTeal : Color.surface2)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                }
                            }
                        }
                    }

                    // Notes
                    logFieldCard(label: "NOTES (OPTIONAL)") {
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Anything notable this week...")
                                    .font(metrics.fontSora(13, weight: .light))
                                    .foregroundColor(.textMuted.opacity(0.5))
                                    .padding(.top, 1)
                            }
                            TextEditor(text: $notes)
                                .font(metrics.fontSora(13, weight: .light))
                                .foregroundColor(.textPrimary)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 70)
                        }
                    }

                    // Save
                    Button(action: saveEntry) {
                        HStack {
                            Spacer()
                            Text("SAVE ENTRY")
                                .font(metrics.fontMono(11))
                                .tracking(1)
                                .foregroundColor(.bgBase)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(Color.inkTeal)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, metrics.hPad)
                    .padding(.bottom, 40)
                }
                .padding(.top, metrics.scaledSize(20))
            }
            .background(AtmosphericBackground())
            .navigationTitle("Weekly Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(metrics.fontSora(14, weight: .light))
                        .foregroundColor(.textMuted)
                }
            }
        }
        .presentationDetents(metrics.isIPad ? [.fraction(0.85)] : [.large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func logFieldCard<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                MonoLabel(text: label, color: .textMuted, size: 9)
                content()
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    private func saveEntry() {
        let entry = TibiaRecoveryLog()
        entry.weekNumber = autoWeekNumber
        entry.weekEndingDate = Date()
        entry.ankleROMRaw = ankleROM.rawValue
        entry.tibialPainRaw = tibialPain.rawValue
        entry.bikeSessionsCompleted = bikeSessionsCompleted
        entry.phaseWeek = autoWeekNumber
        entry.notes = notes
        context.insert(entry)
        dismiss()
    }
}
