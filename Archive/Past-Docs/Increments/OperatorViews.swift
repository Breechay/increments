import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications
import Foundation
import Combine

// MARK: - OPERATOR TAB

// ── Read depth ────────────────────────────────────────────────
enum LabReadDepth: String, Codable {
    case unread = "unread"
    case skimmed = "skimmed"
    case completed = "completed"
}

// ── Section model ─────────────────────────────────────────────
struct LabSection: Identifiable {
    let id: String
    let eyebrow: String
    let question: String
    let title: String
    let hook: String
    let accentColor: Color
    let entries: [LabEntry]
    let teachLine: String?
}

struct LabEntry: Identifiable {
    let id: String
    let label: String
    let body: String
    let isMisread: Bool
    init(id: String, label: String, body: String, isMisread: Bool = false) {
        self.id = id; self.label = label; self.body = body; self.isMisread = isMisread
    }
}

// ── Pentagon radar ────────────────────────────────────────────
struct PentagonRadar: View {
    let values: [(label: String, value: Double, color: Color)]
    @State private var drawn = false

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let r = size * 0.42

            ZStack {
                // Background rings
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { frac in
                    pentagonPath(center: center, radius: r * frac)
                        .stroke(Color.muted.opacity(0.15), lineWidth: 0.5)
                }

                // Spokes
                ForEach(0..<5) { i in
                    let angle = angle(for: i)
                    Path { p in
                        p.move(to: center)
                        p.addLine(to: point(center: center, radius: r, angle: angle))
                    }
                    .stroke(Color.muted.opacity(0.12), lineWidth: 0.5)
                }

                // Filled polygon — animated
                filledPolygon(center: center, radius: r, values: values.map { $0.value })
                    .fill(
                        LinearGradient(
                            colors: [Color.violet.opacity(0.35), Color.violetLight.opacity(0.15)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .scaleEffect(drawn ? 1 : 0.1)
                    .animation(.spring(response: 1.1, dampingFraction: 0.7).delay(0.2), value: drawn)

                // Polygon border
                filledPolygon(center: center, radius: r, values: values.map { $0.value })
                    .stroke(Color.violet.opacity(0.6), lineWidth: 1.5)
                    .scaleEffect(drawn ? 1 : 0.1)
                    .animation(.spring(response: 1.1, dampingFraction: 0.7).delay(0.2), value: drawn)

                // Vertex dots + labels
                ForEach(0..<5) { i in
                    let v = values[i]
                    let a = angle(for: i)
                    let dotPt = point(center: center, radius: r * v.value, angle: a)
                    let lblPt = point(center: center, radius: r * 1.22, angle: a)

                    // Glow dot
                    ZStack {
                        Circle()
                            .fill(v.color.opacity(0.3))
                            .frame(width: 14, height: 14)
                            .blur(radius: 4)
                        Circle()
                            .fill(v.color)
                            .frame(width: 6, height: 6)
                    }
                    .position(dotPt)
                    .opacity(drawn ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.6 + Double(i) * 0.08), value: drawn)

                    // Label
                    Text(v.label)
                        .font(.mono(8))
                        .foregroundColor(v.color)
                        .tracking(0.5)
                        .position(lblPt)
                        .opacity(drawn ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.8 + Double(i) * 0.06), value: drawn)
                }
            }
        }
        .onAppear { drawn = true }
    }

    func angle(for i: Int) -> Double {
        return Double(i) * (2 * .pi / 5) - .pi / 2
    }

    func point(center: CGPoint, radius: Double, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }

    func pentagonPath(center: CGPoint, radius: Double) -> Path {
        Path { p in
            for i in 0..<5 {
                let pt = point(center: center, radius: radius, angle: angle(for: i))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }

    func filledPolygon(center: CGPoint, radius: Double, values: [Double]) -> Path {
        Path { p in
            for i in 0..<5 {
                let pt = point(center: center, radius: radius * values[i], angle: angle(for: i))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }
}

// ── Ambient orb background ────────────────────────────────────
struct OperatorAmbience: View {
    @State private var phase = false
    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.violet.opacity(0.18), Color.bgBase.opacity(0)],
                           center: .topTrailing, startRadius: 0, endRadius: 280)
            RadialGradient(colors: [Color.warm.opacity(0.10), Color.bgBase.opacity(0)],
                           center: .bottomLeading, startRadius: 0, endRadius: 220)
            RadialGradient(colors: [Color.violetDim.opacity(0.12), Color.bgBase.opacity(0)],
                           center: UnitPoint(x: phase ? 0.3 : 0.7, y: phase ? 0.6 : 0.4),
                           startRadius: 0, endRadius: 200)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: phase)
        }
        .onAppear { phase = true }
        .ignoresSafeArea()
    }
}

// ── Glowing ring ──────────────────────────────────────────────
struct GlowRing: View {
    let progress: Double
    let size: CGFloat
    let color: Color
    @State private var appeared = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.08), lineWidth: 6)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: appeared ? progress : 0)
                .stroke(
                    AngularGradient(colors: [color.opacity(0.3), color, color.opacity(0.6)],
                                   center: .center),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.4).delay(0.3), value: appeared)
                .shadow(color: color.opacity(0.5), radius: 8)
        }
        .onAppear { appeared = true }
    }
}

// ── Strength pill ─────────────────────────────────────────────
struct StrengthPill: View {
    let label: String
    let rank: String
    let color: Color
    let delay: Double
    @State private var appeared = false

    init(label: String, rank: String, color: Color, delay: Double = 0) {
        self.label = label; self.rank = rank; self.color = color; self.delay = delay
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .shadow(color: color.opacity(0.8), radius: 4)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.sora(12, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(rank)
                    .font(.mono(8))
                    .foregroundColor(color)
                    .tracking(0.6)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.07))
                RoundedRectangle(cornerRadius: 10).fill(Color.surface)
                    .opacity(0.4)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .strokeBorder(color.opacity(0.25), lineWidth: 0.5))
        .shadow(color: color.opacity(appeared ? 0.18 : 0), radius: 8, x: 0, y: 2)
        .scaleEffect(appeared ? 1 : 0.88)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72).delay(delay)) {
                appeared = true
            }
        }
    }
}

// ── Hero profile card ─────────────────────────────────────────
struct OperatorHeroCard: View {
    @State private var appeared = false
    @State private var showAgentContext = false
    @State private var pulseA = false

    let agentContextBlock = """
OPERATOR: Brice Ikouebe
GALLUP_TOP5: Restorative(1) Achiever(2) Analytical(3) Individualization(4) Competition(5)
ESF_DOMINANT: Confidence · Risk-Taker · Delegator
ESF_SUPPORTING: Business Focus (gap) · Knowledge-Seeker reactive (gap)
MBTI: INTJ | SLOAN: SCOAI

BEHAVIORAL_PROFILE:
- Achiever: zero every day by design. Needs daily tangible closure. Praise = recognition not reward.
- Restorative: problems as sport. Friction = data. Diagnoses first, moves fast.
- Analytical: data before conclusions. Mechanisms produce buy-in.
- Competition: wins not participates. Measures against own prior numbers.
- Confidence: self-assurance is native. Sees past barriers by default.
- Individualization: reads individuals not types. Expects personalization.
- Business Focus gap: strategic alignment is deliberate practice not default.
- Knowledge-Seeker gap: reactive researcher, not proactive scanner.

VOICE: competitive · direct · warm exactness · earned praise natural · no consolation
DOCTRINE: Voice Doctrine v4.0
"""

    var body: some View {
        ZStack {
            // Background ambience inside card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.surface)
                RadialGradient(colors: [Color.violet.opacity(0.22), Color.bgBase.opacity(0)],
                               center: .topTrailing, startRadius: 0, endRadius: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                RadialGradient(colors: [Color.warm.opacity(0.08), Color.bgBase.opacity(0)],
                               center: .bottomLeading, startRadius: 0, endRadius: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .shadow(color: Color.violet.opacity(0.12), radius: 24, x: 0, y: 8)
            .shadow(color: Color.bgBase.opacity(0.7), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 0) {

                // Top row — identity
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        MonoLabel(text: "OPERATOR PROFILE", color: .violetLight, size: 10)
                        Text("Brice Ikouebe")
                            .font(.sora(22, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 8)
                            .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
                        HStack(spacing: 6) {
                            tagChip("INTJ", color: .violet)
                            tagChip("SCOAI", color: .violetLight)
                            tagChip("ESF DOMINANT", color: .inkGreen)
                        }
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
                    }
                    Spacer()
                    // Agent context button
                    Button(action: { withAnimation(.spring(response: 0.4)) { showAgentContext.toggle() } }) {
                        VStack(spacing: 3) {
                            Image(systemName: "cpu")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(showAgentContext ? .violetLight : .textMuted)
                            Text("AGENT")
                                .font(.mono(7))
                                .foregroundColor(showAgentContext ? .violetLight : .textMuted)
                                .tracking(0.5)
                        }
                        .padding(10)
                        .background(Color.surface2.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(showAgentContext ? Color.violet.opacity(0.4) : Color.muted.opacity(0.2), lineWidth: 0.5))
                    }
                }
                .padding(.bottom, 22)

                // Pentagon + stats
                HStack(alignment: .center, spacing: 20) {
                    PentagonRadar(values: [
                        ("RESTORE", 0.95, .inkGreen),
                        ("ACHIEVE", 0.90, .violet),
                        ("ANALYZE", 0.85, .violetLight),
                        ("INDIVID", 0.78, .warm),
                        ("COMPETE", 0.88, .inkTeal),
                    ])
                    .frame(width: 160, height: 160)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.15), value: appeared)

                    // Right side stats
                    VStack(alignment: .leading, spacing: 14) {
                        statBlock(label: "RESTORATIVE", value: "#1", color: .inkGreen,
                                  sub: "Problems as sport")
                        statBlock(label: "ACHIEVER", value: "#2", color: .violet,
                                  sub: "Zero daily, always")
                        statBlock(label: "ANALYTICAL", value: "#3", color: .violetLight,
                                  sub: "Data before conclusions")
                        statBlock(label: "COMPETITION", value: "#5", color: .inkTeal,
                                  sub: "Win, not participate")
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(x: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.6).delay(0.35), value: appeared)
                }
                .padding(.bottom, 22)

                // Core read
                Text("Starts at zero every day by design. Diagnoses problems as sport. Needs measurement to feel alive. Competes to win, not to participate.")
                    .font(.sora(13, weight: .light))
                    .foregroundColor(.textSecond)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
                    .padding(.bottom, 20)

                // ESF Dominant row
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "ESF DOMINANT", color: .textMuted, size: 9)
                    HStack(spacing: 8) {
                        esfPill("CONFIDENCE",  .inkGreen,   0.55)
                        esfPill("RISK-TAKER",  .inkGreen,   0.62)
                        esfPill("DELEGATOR",   .inkGreen,   0.69)
                    }
                }
                .padding(.bottom, 18)

                // Strength grid
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "GALLUP TOP 5", color: .textMuted, size: 9)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        StrengthPill(label: "Restorative",       rank: "TOP 5 · #1", color: .inkGreen,   delay: 0.6)
                        StrengthPill(label: "Achiever",          rank: "TOP 5 · #2", color: .violet,     delay: 0.66)
                        StrengthPill(label: "Analytical",        rank: "TOP 5 · #3", color: .violetLight,delay: 0.72)
                        StrengthPill(label: "Individualization", rank: "TOP 5 · #4", color: .warm,       delay: 0.78)
                        StrengthPill(label: "Competition",       rank: "TOP 5 · #5", color: .inkTeal,    delay: 0.84)
                    }
                }
                .padding(.bottom, 18)

                // Gaps row
                HStack(spacing: 8) {
                    gapTag("Business Focus", "SUPPORTING — develop deliberately")
                    gapTag("Knowledge-Seeker", "REACTIVE — scan proactively")
                }
                .padding(.bottom, showAgentContext ? 18 : 0)

                // Agent context block
                if showAgentContext {
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle().fill(Color.violet.opacity(0.25)).frame(height: 0.5)
                        HStack {
                            MonoLabel(text: "AGENT CONTEXT", color: .violetLight, size: 9)
                            Spacer()
                            Text("machine readable")
                                .font(.mono(8)).foregroundColor(.textMuted.opacity(0.5))
                        }
                        Text(agentContextBlock)
                            .font(.mono(9))
                            .foregroundColor(.textMuted)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(Color.bgBase.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.violet.opacity(0.2), lineWidth: 0.5))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(22)
        }
        .onAppear { appeared = true }
    }

    func tagChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.mono(9))
            .foregroundColor(color)
            .tracking(0.6)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5)
                .strokeBorder(color.opacity(0.2), lineWidth: 0.5))
    }

    func statBlock(label: String, value: String, color: Color, sub: String) -> some View {
        HStack(spacing: 10) {
            Text(value)
                .font(.mono(11))
                .foregroundColor(color)
                .frame(width: 24, alignment: .trailing)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.mono(9)).foregroundColor(color).tracking(0.5)
                Text(sub).font(.sora(10, weight: .light)).foregroundColor(.textMuted)
            }
        }
    }

    func esfPill(_ label: String, _ color: Color, _ delay: Double) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 5, height: 5)
                .shadow(color: color.opacity(0.8), radius: 3)
            Text(label).font(.mono(8)).foregroundColor(color).tracking(0.5)
        }
        .padding(.horizontal, 8).padding(.vertical, 5)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay(RoundedRectangle(cornerRadius: 7)
            .strokeBorder(color.opacity(0.2), lineWidth: 0.5))
    }

    func gapTag(_ label: String, _ sub: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.sora(10, weight: .medium)).foregroundColor(.inkAmber)
            Text(sub).font(.mono(8)).foregroundColor(.inkAmber.opacity(0.6)).tracking(0.3)
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background(Color.inkAmber.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color.inkAmber.opacity(0.2), lineWidth: 0.5))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ── Cognition Lab content ──────────────────────────────────────
enum CognitionLabContent {
    static let sections: [LabSection] = [
        LabSection(
            id: "achiever_dopamine",
            eyebrow: "NEUROSCIENCE · ACHIEVER",
            question: "Why does every day starting at zero feel necessary, not punishing?",
            title: "The Achiever Drive: Dopamine and the Completion Loop",
            hook: "The internal fire that rekindles after every close. What's actually happening neurologically.",
            accentColor: .violet,
            entries: [
                LabEntry(id: "a1", label: "THE MECHANISM",
                    body: "Dopamine doesn't fire at the reward — it fires at the anticipation of the reward and at the moment of completion. For Achievers, the daily reset creates a fresh anticipation cycle every morning. The fire rekindles not despite the reset but because of it. Zero is the starting condition that makes the dopamine loop possible."),
                LabEntry(id: "a2", label: "WHY IT NEVER TURNS OFF",
                    body: "The Achiever pattern is driven by phasic dopamine release — spikes at goal completion, then rapid return to baseline. Each spike resets the baseline. The dissatisfaction after completion isn't dysfunction — it's the system recalibrating for the next challenge. 'Divine restlessness' is neurologically accurate."),
                LabEntry(id: "a3", label: "WHAT THIS MEANS FOR THE STACK",
                    body: "The action stack closing each day isn't a task list — it's a dopamine architecture. Each completion is a spike. The daily review is the consolidation. The reset is the structural condition that makes tomorrow's anticipation cycle possible. Remove the reset and the loop collapses."),
                LabEntry(id: "a4", label: "THE TRAP",
                    body: "Achievers can conflate motion with progress — racking up low-value completions to trigger the spike without doing the hard thing. Friction tracking exists for this: it distinguishes high-output days from high-completion days.", isMisread: true),
            ],
            teachLine: "Dopamine fires at anticipation and completion, not possession. The reset is the architecture that makes tomorrow's anticipation possible. Without zero, there's no climb."
        ),
        LabSection(
            id: "competition_psych",
            eyebrow: "PSYCHOLOGY · COMPETITION",
            question: "Why does comparison activate you instead of threatening you?",
            title: "Competition as Calibration: The Measurement Instinct",
            hook: "Competition is rooted in comparison. Without a yardstick, achievement feels hollow.",
            accentColor: .inkTeal,
            entries: [
                LabEntry(id: "c1", label: "THE MECHANISM",
                    body: "Social comparison activates the anterior cingulate cortex — the brain's performance monitoring system. For competitive profiles, external benchmarks trigger clarity, not threat. The yardstick is informative. It tells you where you stand and what closes the gap."),
                LabEntry(id: "c2", label: "WHY MEASUREMENT MATTERS",
                    body: "Without measurement there's no competition. Without competition the Achiever drive has no external calibration. The planning bands, system rates, and trajectory signals in the app aren't just data — they're the scoreboard."),
                LabEntry(id: "c3", label: "THE GRACIOUS LOSER PATTERN",
                    body: "Competition profiles are outwardly gracious in defeat and internally registering it sharply. This isn't hypocrisy — it's the distinction between the social surface and the performance signal. Internal registration is data: what closes the gap next time."),
                LabEntry(id: "c4", label: "THE WRONG COMPETITION",
                    body: "Competing against the app — maximizing the number instead of doing the right things — corrupts the signal. When the score becomes the goal, the instrument breaks.", isMisread: true),
            ],
            teachLine: "Competition is measurement with stakes. The comparison isn't ego — it's the calibration instrument. Without the yardstick, the Achiever drive has nothing to optimize against."
        ),
        LabSection(
            id: "restorative_cognition",
            eyebrow: "COGNITIVE SCIENCE · RESTORATIVE",
            question: "Why do problems feel energizing rather than draining?",
            title: "Restorative as Cognitive Style: Problem-Detection as Talent",
            hook: "Most people experience problems as costs. Restoratives experience them as puzzles.",
            accentColor: .inkGreen,
            entries: [
                LabEntry(id: "r1", label: "THE MECHANISM",
                    body: "The brain's error-detection network (anterior insula + ACC) fires when something is wrong. For most people this connects to the threat circuit. For Restoratives it connects to the reward circuit. The problem triggers curiosity, not anxiety. Same detection system, different routing."),
                LabEntry(id: "r2", label: "DIAGNOSIS AS INSTINCT",
                    body: "The sequence is automatic: something is wrong → symptoms identified → root cause hypothesized → solution tested → system restored. This is why friction tracking works: skip counts and completion rates are diagnostic inputs, not grades."),
                LabEntry(id: "r3", label: "THE SELF-DIRECTED VERSION",
                    body: "Restorative turns inward too. Honest assessment of shortcomings, direct acknowledgment of what needs to improve. This is why 'noted. tomorrow.' works — it's Restorative applied to a light day. Diagnosis → adjustment → move."),
                LabEntry(id: "r4", label: "THE OVER-FIX TRAP",
                    body: "Restoratives can rush in to fix things before the system has worked it out. The nudge names the problem — the solve is yours.", isMisread: true),
            ],
            teachLine: "For most people the error-detection network connects to threat. For Restoratives it connects to reward. Problems feel like puzzles because neurologically, they are."
        ),
        LabSection(
            id: "decision_fatigue",
            eyebrow: "COGNITIVE SCIENCE · ENVIRONMENT",
            question: "Why is environment the gateway system, not willpower?",
            title: "Decision Fatigue and the Environment Gateway",
            hook: "Willpower is a finite resource. Environment is infrastructure. They're not interchangeable.",
            accentColor: .inkGreen,
            entries: [
                LabEntry(id: "d1", label: "DECISION FATIGUE",
                    body: "The prefrontal cortex handles executive function — decisions, impulse control, planning. It depletes across the day. More decisions early = less capacity for hard things later. Decision fatigue is real, measurable, and universal."),
                LabEntry(id: "d2", label: "ENVIRONMENT AS INFRASTRUCTURE",
                    body: "A supportive environment reduces decisions required to start anything. Clear desk = no decision about where to work. Each environment action is a decision elimination, not a task completion."),
                LabEntry(id: "d3", label: "WHY IT'S THE GATEWAY",
                    body: "When Environment moves, Health and Cognition tend to follow — because activation energy for the next thing drops. The cleared space signals 'things happen here.' Gateway causality is environmental priming, not willpower contagion."),
                LabEntry(id: "d4", label: "THE WILLPOWER MISREAD",
                    body: "Overriding a disorganized environment with determination works briefly. But you're drawing from a depleting account you need for things that matter.", isMisread: true),
            ],
            teachLine: "Willpower is a bank account that depletes. Environment is automatic withdrawal management — it keeps the account full for things that actually need it."
        ),
        LabSection(
            id: "hrv_readiness",
            eyebrow: "PHYSIOLOGY · HEALTH SYSTEM",
            question: "What is HRV actually measuring and why does it change what you do?",
            title: "HRV and the Readiness Signal",
            hook: "Heart rate variability isn't a fitness metric. It's a nervous system readiness signal.",
            accentColor: .inkTeal,
            entries: [
                LabEntry(id: "h1", label: "THE MECHANISM",
                    body: "HRV measures variation in time between heartbeats — not the rate, the variation. High HRV = parasympathetic dominance: recovered, adaptable, ready to load. Low HRV = sympathetic dominance: stressed or depleted. The body reports its state without asking your opinion."),
                LabEntry(id: "h2", label: "WHY IT CHANGES WHAT YOU DO",
                    body: "Training on low HRV produces worse adaptations and increases injury risk. Cognitive performance degrades measurably — decision quality, working memory, pattern recognition all drop. A Reserve day isn't weakness — it's reading the signal correctly."),
                LabEntry(id: "h3", label: "THE CALIBRATION PROBLEM",
                    body: "HRV is individual — your baseline is yours, not a population average. What matters is trend relative to your 7-day rolling average. This is why the app tracks energy state declarations: the correlation reveals whether your subjective read is calibrated."),
                LabEntry(id: "h4", label: "THE OVERRIDE ERROR",
                    body: "Overriding a clear low-HRV signal extends recovery, suppresses immune response, and delays the adaptation you were training for. The signal is cheaper to read than to ignore.", isMisread: true),
            ],
            teachLine: "HRV is the body's nervous system report card. High variation = recovered and adaptable. Low variation = depleted. The report card doesn't care what you think — it reports what is."
        ),
        LabSection(
            id: "deep_work_neuro",
            eyebrow: "NEUROSCIENCE · COGNITION",
            question: "What is deep work actually building in the brain?",
            title: "Myelin and the Deep Work Mechanism",
            hook: "Deep work isn't a productivity technique. It's a neurological construction process.",
            accentColor: .violetLight,
            entries: [
                LabEntry(id: "dw1", label: "MYELIN",
                    body: "Myelin is the insulating sheath around neural pathways. It's produced in response to focused, deliberate practice — the same circuit firing repeatedly under attention. More myelin = faster, cleaner signal transmission. Skill is literally the thickness of the myelin sheath."),
                LabEntry(id: "dw2", label: "WHY DEPTH MATTERS",
                    body: "Myelin is only produced during focused engagement. Shallow or distracted work doesn't trigger production — it triggers error patterns on existing circuits. The 90-minute block isn't about getting more done today — it's neurological construction that makes the next session better."),
                LabEntry(id: "dw3", label: "THE COGNITIVE LOAD PREREQUISITE",
                    body: "Deep work requires low cognitive load going in. Decision fatigue, open loops, and environmental noise all compete for prefrontal bandwidth. This is the direct link between Environment + Operations and Cognition."),
                LabEntry(id: "dw4", label: "THE BUSYNESS MISREAD",
                    body: "Feeling productive because you handled many things is not the same as building capability. Admin doesn't produce myelin on the circuits that matter most. The deep work block is protected because it's the only thing that builds the hardware.", isMisread: true),
            ],
            teachLine: "Deep work builds myelin — physical insulation on neural pathways. Shallow work uses existing circuits but doesn't improve them. The 90-minute block is construction, not just production."
        ),
        LabSection(
            id: "habit_stacking",
            eyebrow: "BEHAVIORAL SCIENCE · HABITS",
            question: "Why does linking habits to cues outperform relying on motivation?",
            title: "Implementation Intentions and the Cue Architecture",
            hook: "Motivation is a mood. Cues are architecture. 'When X then Y' outperforms willpower by 2–3x.",
            accentColor: .warm,
            entries: [
                LabEntry(id: "hs1", label: "IMPLEMENTATION INTENTIONS",
                    body: "A pre-committed 'when X happens, I will do Y' statement. Gollwitzer's research shows 2–3x better follow-through versus vague intentions. The cue becomes a retrieval trigger — when the situation is detected, the behavior activates automatically without deliberate decision."),
                LabEntry(id: "hs2", label: "THE CUE FIELD",
                    body: "Every action in the stack has a cue field for exactly this reason. 'When: noon break at hideout' is an implementation intention. It delegates the decision to the environment rather than to motivation state. No negotiation required."),
                LabEntry(id: "hs3", label: "HABIT STACKING",
                    body: "Stacking a new behavior after an existing automatic one borrows the anchor habit's automaticity. 'After coffee, open blinds and reset desk' — coffee triggers the environment stack. The new behavior inherits the reliable cue from the established one."),
                LabEntry(id: "hs4", label: "THE MOTIVATION MISREAD",
                    body: "Waiting to feel like doing something means the behavior is on the wrong trigger. Motivation is post-hoc — it follows action more than it precedes it. Add the cue first.", isMisread: true),
            ],
            teachLine: "Implementation intentions turn decisions into triggers. 'I'll exercise' is a wish. 'When I finish deep work, I go to the gym' is a program. The environment runs the program — you set it once."
        ),
        LabSection(
            id: "teaching_consolidation",
            eyebrow: "COGNITIVE SCIENCE · LEARNING",
            question: "Why does explaining something make you better at it than reviewing it does?",
            title: "The Protégé Effect: Teaching as Consolidation",
            hook: "Students who expect to teach outperform students who expect to be tested.",
            accentColor: .warm,
            entries: [
                LabEntry(id: "t1", label: "THE PROTEGE EFFECT",
                    body: "Nestojko's research shows students who expect to teach material learn it more deeply than those expecting a test. Teaching requires organizing knowledge into coherent structure, identifying gaps, and generating explanations — creating stronger memory traces than passive review."),
                LabEntry(id: "t2", label: "THE GAP DETECTION FUNCTION",
                    body: "Explaining reveals exactly where your understanding is shallow. You can hold a vague sense of dopamine and the Achiever drive for a long time. The moment someone asks 'but why does the reset help?' — you either have the mechanism or you don't."),
                LabEntry(id: "t3", label: "WHY THE TEACH LINE EXISTS",
                    body: "Each section has a teach line — a compressed version of how you'd explain this to someone else. Reading it primes the teaching mode. Saying it out loud activates the consolidation mechanism. The knowledge becomes usable rather than just held."),
                LabEntry(id: "t4", label: "THE PASSIVE REVIEW TRAP",
                    body: "Re-reading feels like learning because familiarity is mistaken for understanding. If you can't explain it simply, you don't own it yet.", isMisread: true),
            ],
            teachLine: "Teaching forces your brain to build an organized model rather than store fragments. If you can't explain it simply, you don't own it."
        ),
        LabSection(
            id: "admin_drain",
            eyebrow: "COGNITIVE SCIENCE · OPERATIONS",
            question: "Why does admin feel like work but leave you more depleted?",
            title: "Administrative Depletion: The False Productivity Signal",
            hook: "Admin creates a convincing productivity feeling while consuming the capacity needed for meaningful work.",
            accentColor: .inkAmber,
            entries: [
                LabEntry(id: "ad1", label: "THE MECHANISM",
                    body: "Administrative tasks activate the same goal-completion circuitry as meaningful work — filing, responding, organizing all produce completion signals. But they draw from executive function without building anything. The dopamine spike is real. The output isn't."),
                LabEntry(id: "ad2", label: "CONTEXT SWITCHING COST",
                    body: "Every shift between task types — email to creative to logistics — costs 15–23 minutes of refocusing time (Rubinstein, Meyer, Evans). A morning of five administrative context switches can consume two hours of effective creative capacity before the first deep work block starts."),
                LabEntry(id: "ad3", label: "WHY IT'S ESPECIALLY COSTLY HERE",
                    body: "The Analytical drive means administrative work produces genuine insight and diagnosis — it feels even more productive than average. The Restorative drive finds the inbox satisfying to clear. Both drives conspire to make admin feel like real work. It isn't."),
                LabEntry(id: "ad4", label: "THE PROGRESS MISREAD",
                    body: "A day of answered emails and cleared queues is a maintained system, not a built one. Maintenance is necessary. It is not generative. The distinction matters for how you read your own output.", isMisread: true),
            ],
            teachLine: "Admin produces completion signals without building capacity. The cost isn't the time — it's the executive function spent before the real work starts. Protect the first block from logistics."
        ),
        LabSection(
            id: "ecological_cognition",
            eyebrow: "COGNITIVE SCIENCE · ENVIRONMENT",
            question: "Why does the environment change what you can think?",
            title: "Ecological Cognition: Environment as Part of Thought",
            hook: "Conditions don't just affect mood. They change the quality and content of cognition itself.",
            accentColor: .inkGreen,
            entries: [
                LabEntry(id: "ec1", label: "EXTENDED MIND THESIS",
                    body: "Clark and Chalmers (1998): cognitive processes are not confined to the brain. They extend into the environment. A notebook, a clear desk, a specific chair — these become part of the cognitive system. Removing them genuinely changes what thinking is possible."),
                LabEntry(id: "ec2", label: "STATE-DEPENDENT COGNITION",
                    body: "Encoding specificity: recall and reasoning are best when conditions at retrieval match conditions at encoding. You think differently in different rooms, at different temperatures, with different noise levels. This isn't preference — it's how memory and cognition are physically structured."),
                LabEntry(id: "ec3", label: "RESTORATION BEFORE INTERPRETATION",
                    body: "Degraded conditions — disorder, noise, fatigue, physical discomfort — alter the conclusions drawn from observations. A situation that reads as threatening or hopeless in poor conditions may read neutrally or even positively after restoration. The read is not separable from the reading conditions."),
                LabEntry(id: "ec4", label: "THE WILLPOWER SUBSTITUTE ERROR",
                    body: "Attempting to override environmental degradation with effort is metabolically expensive and statistically losing. The environment always wins eventually. Restoration is not weakness — it is load reduction before re-entry.", isMisread: true),
            ],
            teachLine: "Cognition extends into the environment. A degraded environment doesn't just feel bad — it changes what you can think. Restore conditions before drawing conclusions from them."
        ),
        LabSection(
            id: "behavioral_observation",
            eyebrow: "INTELLIGENCE ARCHITECTURE · META",
            question: "What is the system actually learning about you?",
            title: "From Declared Profile to Observed Intelligence",
            hook: "A static psych profile describes who you say you are. Behavioral data describes what you actually do. Both matter. Only one updates.",
            accentColor: .violetLight,
            entries: [
                LabEntry(id: "bo1", label: "DECLARED VS OBSERVED",
                    body: "The Dossier contains your declared operating profile: Restorative, Achiever, Analytical. These are accurate starting points derived from validated assessments. But they are static. The intelligence layer is building something different: observed behavioral patterns derived from your actual completion data, timing, friction signals, and energy declarations."),
                LabEntry(id: "bo2", label: "WHAT THE SYSTEM IS TRACKING",
                    body: "Initiation latency: how long from first open to first completion. Completion clustering: whether actions happen in bursts or spread through the day. Energy declaration accuracy: whether your stated Reserve days match your actual output. Admin displacement frequency: how often logistical work consumes mornings before generative work starts."),
                LabEntry(id: "bo3", label: "WHY THIS MATTERS",
                    body: "Declared: 'Competition sharpens engagement.' Observed: 'Visible completion counts increase participation on low-energy days by measurable margin.' The observed version is more useful than the declared one because it comes from your data, not a population average. Over time the observed profile becomes more accurate than any assessment."),
                LabEntry(id: "bo4", label: "THE SELF-REPORT PROBLEM",
                    body: "Self-report instruments measure who you believe you are, which is accurate enough as a starting point. But beliefs about behavior and actual behavior diverge, especially under load. The system doesn't ask you to self-report — it reads the data you generate by using it.", isMisread: true),
            ],
            teachLine: "The declared profile is the starting model. The observed intelligence is what the system derives from your actual behavior over time. One is a snapshot. The other updates."
        ),
    ]
}
struct LabSectionCard: View {
    let section: LabSection
    let readDepth: LabReadDepth
    let onSkimmed: () -> Void
    let onCompleted: () -> Void

    @State private var isExpanded = false
    @State private var dwellTimer: Timer?
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Card background with accent glow when expanded
            RoundedRectangle(cornerRadius: 16)
                .fill(isExpanded ? Color.surface : Color.surface2)
                .shadow(color: isExpanded ? section.accentColor.opacity(0.15) : Color.bgBase.opacity(0.4),
                        radius: isExpanded ? 20 : 6, x: 0, y: isExpanded ? 8 : 3)
                .animation(.easeInOut(duration: 0.3), value: isExpanded)

            if isExpanded {
                // Subtle accent gradient fill when open
                LinearGradient(
                    colors: [section.accentColor.opacity(0.06), Color.bgBase.opacity(0)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            VStack(alignment: .leading, spacing: 0) {
                // Header — always visible
                Button(action: {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) { isExpanded.toggle() }
                    if readDepth == .unread { onSkimmed() }
                }) {
                    HStack(alignment: .top, spacing: 14) {
                        // Orb
                        ZStack {
                            Circle()
                                .fill(section.accentColor.opacity(isExpanded ? 0.25 : 0.1))
                                .frame(width: 32, height: 32)
                                .blur(radius: isExpanded ? 4 : 0)
                            Circle()
                                .fill(section.accentColor.opacity(isExpanded ? 0.9 : 0.4))
                                .frame(width: isExpanded ? 10 : 8, height: isExpanded ? 10 : 8)
                                .shadow(color: section.accentColor.opacity(isExpanded ? 0.8 : 0.3),
                                        radius: isExpanded ? 8 : 3)
                            // Read depth ring
                            Circle()
                                .trim(from: 0, to: readDepth == .completed ? 1 : readDepth == .skimmed ? 0.5 : 0)
                                .stroke(section.accentColor.opacity(0.6), lineWidth: 1.5)
                                .frame(width: 28, height: 28)
                                .rotationEffect(.degrees(-90))
                        }
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)

                        VStack(alignment: .leading, spacing: 5) {
                            MonoLabel(text: section.eyebrow, color: section.accentColor.opacity(0.7), size: 9)
                            Text(isExpanded ? section.title : section.question)
                                .font(.sora(14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.leading)
                                .animation(.spring(response: 0.3), value: isExpanded)
                            if !isExpanded {
                                Text(section.hook)
                                    .font(.sora(11, weight: .light))
                                    .foregroundColor(.textMuted)
                                    .lineSpacing(3)
                                    .transition(.opacity)
                            }
                        }

                        Spacer(minLength: 8)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(section.accentColor.opacity(isExpanded ? 0.6 : 0.3))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.spring(response: 0.35), value: isExpanded)
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 18)
                }
                .buttonStyle(.plain)

                // Expanded body
                if isExpanded {
                    VStack(alignment: .leading, spacing: 20) {
                        Rectangle()
                            .fill(section.accentColor.opacity(0.15))
                            .frame(height: 0.5)
                            .padding(.horizontal, 18)

                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(section.entries) { entry in
                                VStack(alignment: .leading, spacing: 7) {
                                    HStack(spacing: 6) {
                                        if entry.isMisread {
                                            Image(systemName: "exclamationmark.triangle")
                                                .font(.system(size: 8, weight: .medium))
                                                .foregroundColor(.inkAmber)
                                        }
                                        Text(entry.label)
                                            .font(.mono(10))
                                            .foregroundColor(entry.isMisread ? .inkAmber : section.accentColor)
                                            .tracking(0.5)
                                    }
                                    Text(entry.body)
                                        .font(.sora(13, weight: .light))
                                        .foregroundColor(entry.isMisread ? .textSecond.opacity(0.75) : .textSecond)
                                        .lineSpacing(5)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(entry.isMisread ? 12 : 0)
                                .background(
                                    entry.isMisread ?
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.inkAmber.opacity(0.06))
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.inkAmber.opacity(0.2), lineWidth: 0.5))
                                    : nil
                                )
                            }

                            // Teach line — gold accent
                            if let teach = section.teachLine {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "quote.opening")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.warm)
                                        MonoLabel(text: "HOW YOU'D EXPLAIN THIS", color: .warm, size: 9)
                                    }
                                    Text(teach)
                                        .font(.sora(13, weight: .light))
                                        .foregroundColor(.warm.opacity(0.9))
                                        .lineSpacing(4)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .italic()
                                }
                                .padding(14)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10).fill(Color.warm.opacity(0.05))
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.warm.opacity(0.2), lineWidth: 0.5)
                                    }
                                )
                                .shadow(color: Color.warm.opacity(0.08), radius: 8, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 18)

                        Color.clear.frame(height: 1)
                            .onAppear { if isExpanded { onCompleted() } }
                            .padding(.bottom, 18)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: -10)),
                        removal: .opacity
                    ))
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isExpanded ? section.accentColor.opacity(0.2) : Color.muted.opacity(0.1),
                    lineWidth: 0.5
                )
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
        )
        .scaleEffect(appeared ? 1 : 0.96)
        .opacity(appeared ? 1 : 0)
        .onChange(of: isExpanded) { _, expanded in
            dwellTimer?.invalidate(); dwellTimer = nil
            if expanded {
                dwellTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in onCompleted() }
            }
        }
    }
}

// ── Operator tab root ─────────────────────────────────────────
struct OperatorTabView: View {
    @AppStorage("labReadDepths") private var readDepthsRaw: String = "{}"
    @State private var appeared = false

    var readDepths: [String: LabReadDepth] {
        guard let data = readDepthsRaw.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return dict.compactMapValues { LabReadDepth(rawValue: $0) }
    }

    func setDepth(_ id: String, _ depth: LabReadDepth) {
        var dict = readDepths.mapValues { $0.rawValue }
        guard dict[id] != LabReadDepth.completed.rawValue else { return }
        dict[id] = depth.rawValue
        if let data = try? JSONEncoder().encode(dict), let str = String(data: data, encoding: .utf8) {
            readDepthsRaw = str
        }
    }

    var completedCount: Int { readDepths.values.filter { $0 == .completed }.count }
    let total = CognitionLabContent.sections.count

    var body: some View {
        ZStack(alignment: .top) {
            OperatorAmbience()
                .frame(height: 400)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 28) {

                // Hero card
                OperatorHeroCard()
                    .padding(.horizontal, 20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: appeared)

                // Lab header with circular progress
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 5) {
                        MonoLabel(text: "COGNITION LAB", color: .violetLight, size: 11)
                        Text("Read it. Own it. Teach it.")
                            .font(.sora(13, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                    Spacer()
                    ZStack {
                        GlowRing(
                            progress: total > 0 ? Double(completedCount) / Double(total) : 0,
                            size: 48,
                            color: .violet
                        )
                        VStack(spacing: 0) {
                            Text("\(completedCount)")
                                .font(.sora(14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text("of \(total)")
                                .font(.mono(8))
                                .foregroundColor(.textMuted)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)

                // Lab sections with staggered entrance
                VStack(spacing: 12) {
                    ForEach(Array(CognitionLabContent.sections.enumerated()), id: \.element.id) { idx, section in
                        LabSectionCard(
                            section: section,
                            readDepth: readDepths[section.id] ?? .unread,
                            onSkimmed: { setDepth(section.id, .skimmed) },
                            onCompleted: { setDepth(section.id, .completed) }
                        )
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.45).delay(0.4 + Double(idx) * 0.05), value: appeared)
                        .onAppear {
                            // Trigger appeared on each card after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(idx)) {
                                withAnimation { _ = appeared }
                            }
                        }
                    }
                }

                // Source footer
                Text("Sources: Gollwitzer (1999) · Newport (2016) · Fields (2008) · Baumeister (2011) · Nestojko (2014) · Gallup StrengthsFinder · ESF Assessment")
                    .font(.mono(8))
                    .foregroundColor(.textMuted.opacity(0.35))
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 80)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.9), value: appeared)
            }
            .padding(.top, 8)
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}


// The intelligence readiness card — tells the app what it's learning to see.
// Honest about thresholds. Not hollow. Not premature.
struct IntelligenceReadinessCard: View {
    let patternReadiness: IntelligenceReadiness
    let frictionReadiness: IntelligenceReadiness
    let energyCalibrationReadiness: IntelligenceReadiness
    let cognitionTaggingStatus: String

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    MonoLabel(text: "SIGNAL COLLECTION", color: .textMuted)
                    Spacer()
                    MonoLabel(text: "WHAT THE APP IS LEARNING", color: .muted, size: 10)
                }

                // Pattern window
                readinessRow(
                    label: "TIME PATTERN",
                    readiness: patternReadiness,
                    description: "When you actually complete actions"
                )

                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                // Friction diagnosis
                readinessRow(
                    label: "FRICTION READ",
                    readiness: frictionReadiness,
                    description: "Which actions have a cue or scope problem"
                )

                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                // Energy calibration
                readinessRow(
                    label: "ENERGY CALIBRATION",
                    readiness: energyCalibrationReadiness,
                    description: "Whether your Reserve floor is higher than it feels"
                )

                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)

                // Cognition tagging
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(cognitionTaggingStatus.contains("All") ? Color.inkGreen : Color.violetLight.opacity(0.5))
                        .frame(width: 6, height: 6)
                        .padding(.top, 4)
                    VStack(alignment: .leading, spacing: 2) {
                        MonoLabel(text: "COGNITION TYPE", size: 11)
                        Text("Creative vs analytical vs administrative — \(cognitionTaggingStatus)")
                            .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                    }
                }
            }
        }
    }

    func readinessRow(label: String, readiness: IntelligenceReadiness, description: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(readiness.isReady ? Color.inkGreen : Color.muted.opacity(0.4))
                .frame(width: 6, height: 6)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 2) {
                MonoLabel(text: label, size: 11)
                Text(description)
                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                if !readiness.isReady {
                    Text(readiness.displayText)
                        .font(.mono(10)).foregroundColor(.violetLight.opacity(0.7)).tracking(0.3)
                } else {
                    Text(readiness.displayText)
                        .font(.mono(10)).foregroundColor(.inkGreen).tracking(0.3)
                }
            }
            Spacer()
        }
    }
}


struct SettingsTabView: View {
    @Bindable var profile: OperatorProfile
    @Bindable var state: AppState
    // BUG FIX: was @State (resets to false on every tab switch/view re-init).
    // @AppStorage persists the toggle state across app sessions and tab navigation.
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false

    var body: some View {
        VStack(spacing: 16) {

            // OPERATOR — name and voice
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "OPERATOR", color: .textMuted)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("Used for direct address. Leave blank to disable.")
                                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                        }
                        Spacer()
                        TextField("Brice", text: $profile.operatorName)
                            .font(.sora(14)).foregroundColor(.textPrimary)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .tint(.violet)
                    }

                    Divider().background(Color.muted.opacity(0.3))

                    Toggle(isOn: $profile.voicePresenceEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Voice").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("App speaks brief observations. Rarely. Not an assistant.")
                                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                        }
                    }
                    .tint(Color.violet)
                    .onChange(of: profile.voicePresenceEnabled) { _, enabled in
                        VoicePresence.shared.voiceEnabled = enabled
                        if !enabled { VoicePresence.shared.stop() }
                    }

                    // Test button — bypasses silence rules so you can hear the voice immediately
                    if profile.voicePresenceEnabled {
                        Divider().background(Color.muted.opacity(0.3))

                        // Voice provider
                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "VOICE SOURCE", color: .textMuted)
                            HStack(spacing: 8) {
                                ForEach(VoiceProvider.allCases, id: \.self) { p in
                                    Button(action: {
                                        profile.voiceProvider = p
                                        VoicePresence.shared.provider = p
                                    }) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(p.label)
                                                .font(.sora(13))
                                                .foregroundColor(profile.voiceProvider == p ? .textPrimary : .textMuted)
                                            Text(p.sublabel)
                                                .font(.sora(10, weight: .light))
                                                .foregroundColor(.textMuted)
                                                .lineSpacing(1.5)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(profile.voiceProvider == p ? Color.violetDim.opacity(0.3) : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(profile.voiceProvider == p ? Color.violet.opacity(0.4) : Color.clear, lineWidth: 1))
                                    }
                                }
                            }
                        }

                        // Character note — what voice this is reaching for
                        CardView(style: .ambient) {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "CHARACTER", color: .textMuted, size: 11)
                                Text("Calm male operator. Grounded. Intelligent. Composed.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(2)
                                Text("Not assistant. Not coach. Not theatrical. A presence that notices.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                                Text("For ElevenLabs: search calm male, neutral American, grounded, composed.")
                                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3).lineSpacing(2)
                            }
                        }

                        // OpenAI TTS — only shows when OpenAI is selected
                        if profile.voiceProvider == .openAI {
                            VStack(alignment: .leading, spacing: 10) {
                                MonoLabel(text: "OPENAI TTS", color: .inkGreen, size: 11)
                                MonoLabel(text: "Voice: onyx. Get your key at platform.openai.com", color: .muted, size: 10)
                                inputField("API KEY", placeholder: "sk-...", text: $profile.openAIApiKey)
                                    .onChange(of: profile.openAIApiKey) { _, v in
                                        VoicePresence.shared.openAIApiKey = v
                                    }
                                Text("Key stored locally only. ~$0.002/day at normal use.")
                                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3)
                            }
                        }

                        // ElevenLabs Phase B — only shows when ElevenLabs is selected
                        if profile.voiceProvider == .elevenLabs {
                            VStack(alignment: .leading, spacing: 10) {
                                MonoLabel(text: "ELEVENLABS · PHASE B", color: .inkAmber, size: 11)
                                MonoLabel(text: "Enter your API key and voice ID from elevenlabs.io", color: .muted, size: 10)
                                inputField("API KEY", placeholder: "sk-...", text: $profile.elevenLabsApiKey)
                                inputField("VOICE ID", placeholder: "21m00Tcm4TlvDq8ikWAM", text: $profile.elevenLabsVoiceId)
                                    .onChange(of: profile.elevenLabsApiKey) { _, v in
                                        VoicePresence.shared.elevenLabsApiKey = v
                                    }
                                    .onChange(of: profile.elevenLabsVoiceId) { _, v in
                                        VoicePresence.shared.elevenLabsVoiceId = v
                                    }
                                Text("Key stored locally only. Never sent to Anthropic.")
                                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3)
                            }
                        }

                        // Test button — hear the voice now
                        Button(action: {
                            let name = profile.firstName
                            let testLine = name.isEmpty
                                ? "Open field. Let's not make it dramatic."
                                : "\(name). Open field. Let's not make it dramatic."
                            VoicePresence.shared.speakTest(testLine)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 13, weight: .light))
                                Text("Test voice")
                                    .font(.sora(13))
                            }
                            .foregroundColor(.violet)
                            .frame(maxWidth: .infinity).frame(height: 42)
                            .background(Color.violetDim.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.violet.opacity(0.3), lineWidth: 0.5))
                        }

                        // Voice debug — tap to see every voice iOS gives this app
                        VoiceDebugButton()

                        // WENDY (Layer B) — separate consent, separate API key
                        Divider().background(Color.muted.opacity(0.3))

                        VStack(alignment: .leading, spacing: 14) {
                            MonoLabel(text: "WENDY · LAYER B", color: .violetLight, size: 11)
                            MonoLabel(text: "Layer A (operational): 2-day cooldown. Layer B (pattern): 7-day cooldown.", color: .muted, size: 10)

                            Toggle(isOn: $profile.wendyEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pattern observations").font(.sora(14)).foregroundColor(.textPrimary)
                                    Text("Text card in Today tab. Separate from voice.")
                                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                                }
                            }
                            .tint(Color.violetLight)

                            if profile.wendyEnabled {
                                // Layer B status indicator
                                HStack(spacing: 8) {
                                    if profile.daysInSystem >= 14 {
                                        Circle().fill(Color.inkGreen).frame(width: 5, height: 5)
                                        Text("Active — 14-day threshold met.")
                                            .font(.mono(11)).foregroundColor(.inkGreen).tracking(0.3)
                                    } else {
                                        Circle().fill(Color.inkAmber.opacity(0.6)).frame(width: 5, height: 5)
                                        Text("Unlocks in \(14 - profile.daysInSystem) days.")
                                            .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                                    }
                                }

                                inputField("ANTHROPIC API KEY", placeholder: "sk-ant-...", text: $profile.claudeApiKey)
                                Text("Key stored locally. Sent only to Anthropic's API.")
                                    .font(.mono(10)).foregroundColor(.muted).tracking(0.3)

                                // Phase B2 — spoken Wendy (sub-toggle, off by default)
                                Toggle(isOn: $profile.wendyVoiceEnabled) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Speak observations").font(.sora(13)).foregroundColor(profile.wendyEnabled ? .textPrimary : .textMuted)
                                        Text("Enable after text observations feel like recognition, not surveillance.")
                                            .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                                    }
                                }
                                .tint(Color.violetLight)
                                .disabled(!profile.wendyEnabled)

                                // Cooldown status
                                if let last = profile.lastLayerBDate ?? profile.lastWendyDate {
                                    let daysAgo = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
                                    let remaining = max(0, 7 - daysAgo)
                                    if remaining > 0 {
                                        HStack(spacing: 8) {
                                            Circle().fill(Color.muted.opacity(0.5)).frame(width: 5, height: 5)
                                            Text("Layer B cooldown: \(remaining) day\(remaining == 1 ? "" : "s") remaining.")
                                                .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // NOTIFICATIONS — master toggle
            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    MonoLabel(text: "NOTIFICATIONS", color: .textMuted)
                    Toggle(isOn: $notificationsEnabled) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Daily nudges").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("Max 4/day · respects quiet window")
                                .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                        }
                    }
                    .tint(Color.violet)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestPermission()
                            NotificationService.shared.scheduleAll(profile: profile)
                        } else {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }
                    }

                    Divider().background(Color.muted.opacity(0.3))
                    Toggle(isOn: $profile.quietMode) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Quiet Mode").font(.sora(14)).foregroundColor(.textPrimary)
                            Text("Suppress all non-critical notifications")
                                .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                        }
                    }
                    .tint(Color.violetDim)
                    .onChange(of: profile.quietMode) { _, _ in
                        NotificationService.shared.scheduleAll(profile: profile)
                    }
                }
            }
            .padding(.horizontal, 24)

            // QUIET WINDOW — Phase 2
            if notificationsEnabled && !profile.quietMode {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 14) {
                        MonoLabel(text: "QUIET WINDOW", color: .textMuted)
                        Text("No notifications sent during this window.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textMuted)

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "FROM", color: .textMuted, size: 11)
                                Picker("", selection: $profile.notifQuietStart) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(hourLabel(h)).tag(h)
                                            .font(.sora(13)).foregroundColor(.textPrimary)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 80)
                                .clipped()
                                .colorScheme(.dark)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "UNTIL", color: .textMuted, size: 11)
                                Picker("", selection: $profile.notifQuietEnd) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(hourLabel(h)).tag(h)
                                            .font(.sora(13)).foregroundColor(.textPrimary)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 80)
                                .clipped()
                                .colorScheme(.dark)
                            }
                            Spacer()
                            // Preview
                            VStack(alignment: .trailing, spacing: 4) {
                                MonoLabel(text: "WINDOW", color: .textMuted, size: 11)
                                Text("\(hourLabel(profile.notifQuietStart)) –")
                                    .font(.sora(12)).foregroundColor(.textSecond)
                                Text(hourLabel(profile.notifQuietEnd))
                                    .font(.sora(12)).foregroundColor(.textSecond)
                            }
                        }
                        .onChange(of: profile.notifQuietStart) { _, _ in
                            NotificationService.shared.scheduleAll(profile: profile)
                        }
                        .onChange(of: profile.notifQuietEnd) { _, _ in
                            NotificationService.shared.scheduleAll(profile: profile)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // CATEGORY TOGGLES — Phase 2
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: 14) {
                        MonoLabel(text: "NOTIFY FOR SYSTEMS", color: .textMuted)

                        categoryToggle("Environment",  isOn: $profile.notifCategoryEnvironment,  color: .inkGreen)
                        categoryToggle("Cognition",    isOn: $profile.notifCategoryCognition,    color: .violetLight)
                        categoryToggle("Health",       isOn: $profile.notifCategoryHealth,       color: .inkTeal)
                        categoryToggle("Operations",   isOn: $profile.notifCategoryOperations,   color: .warm)
                        categoryToggle("Participation",isOn: $profile.notifCategoryParticipation,color: .inkAmber)

                        Divider().background(Color.muted.opacity(0.3))

                        // Hydration — Phase 3 P3
                        HStack(spacing: 10) {
                            Circle().fill(Color.inkTeal.opacity(0.6)).frame(width: 7, height: 7)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hydration prompts").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("3/day · 10am, 1pm, 4pm · copy: \"Water.\"")
                                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                            }
                            Spacer()
                            Toggle("", isOn: $profile.notifHydrationEnabled).tint(Color.inkTeal).labelsHidden()
                                .onChange(of: profile.notifHydrationEnabled) { _, _ in
                                    NotificationService.shared.scheduleAll(profile: profile)
                                }
                        }

                        // Protein — 2/day
                        HStack(spacing: 10) {
                            Circle().fill(Color.inkTeal.opacity(0.6)).frame(width: 7, height: 7)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Protein reminders").font(.sora(13)).foregroundColor(.textPrimary)
                                Text("2/day · 10am, 3:30pm · copy: \"Protein.\"")
                                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                            }
                            Spacer()
                            Toggle("", isOn: $profile.notifProteinEnabled).tint(Color.inkTeal).labelsHidden()
                                .onChange(of: profile.notifProteinEnabled) { _, _ in
                                    NotificationService.shared.scheduleAll(profile: profile)
                                }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // GUARDRAILS
            CardView(style: .ambient) {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "GUARDRAILS", color: .textMuted)
                    VStack(alignment: .leading, spacing: 6) {
                        guardrailLine("No streak shaming. No failure language.")
                        guardrailLine("If the app creates pressure, remove items.")
                        guardrailLine("No notifications that generate guilt.")
                        guardrailLine("Gentle decay only — never harsh penalties.")
                    }
                }
            }
            .padding(.horizontal, 24)

            CardView(style: .secondary) {
                VStack(spacing: 8) {
                    MonoLabel(text: "INCREMENTS · v\(profile.version)", color: .violet, size: 11)
                    Text("environmental cognition support system")
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                    Text("Private build. Your data stays yours.")
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted.opacity(0.7))
                        .tracking(0.2)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
        .onAppear { syncNotificationStatus() }
    }

    func hourLabel(_ h: Int) -> String {
        let suffix = h >= 12 ? "PM" : "AM"
        let h12 = h == 0 ? 12 : h > 12 ? h - 12 : h
        return "\(h12) \(suffix)"
    }

    func categoryToggle(_ label: String, isOn: Binding<Bool>, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle().fill(color.opacity(0.6)).frame(width: 7, height: 7)
            Text(label).font(.sora(13)).foregroundColor(.textPrimary)
            Spacer()
            Toggle("", isOn: isOn).tint(color).labelsHidden()
                .onChange(of: isOn.wrappedValue) { _, _ in
                    NotificationService.shared.scheduleAll(profile: profile)
                }
        }
    }

    func guardrailLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(Color.warm.opacity(0.4)).frame(width: 4, height: 4).padding(.top, 5)
            Text(text).font(.sora(13, weight: .light)).foregroundColor(.textSecond)
        }
    }

    // BUG FIX: syncs notificationsEnabled toggle with real system permission on every appear
    func syncNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
}

// MARK: - WEEKLY REVIEW EXPORT

struct WeeklyExportCard: View {
    let actions: [Action]
    let logs: [DailyLog]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @State private var showShareSheet = false
    @State private var exportText = ""

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        MonoLabel(text: "WEEKLY REVIEW", color: .violetLight, size: 10)
                        Text("Export & share your data.")
                            .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                    }
                    Spacer()
                    Button(action: {
                        exportText = ExportGenerator.weeklyMarkdown(actions: actions, logs: logs, shifts: Array(shifts.prefix(14)))
                        showShareSheet = true
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 12))
                            Text("Export").font(.sora(12, weight: .medium))
                        }
                        .foregroundColor(.bgBase)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.violetLight)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                Text("Last 7 days · action rates · Hideout revenue + behavioral techniques · daily notes.\nShare with partner, advisor, or save as weekly record.")
                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(text: exportText)
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let text: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ExportGenerator {

    static func weeklyMarkdown(actions: [Action], logs: [DailyLog], shifts: [HideoutShiftLog] = []) -> String {
        let cal = Calendar.current
        let today = Date()
        let weekStart = cal.date(byAdding: .day, value: -6, to: today) ?? today
        let dateRange = "\(weekStart.formatted(.dateTime.month().day())) – \(today.formatted(.dateTime.month().day().year()))"
        var output: [String] = []
        output.append("# INCREMENTS — Weekly Review")
        output.append("## \(dateRange)")
        output.append("")

        // Hideout this week
        let weekShifts = shifts.filter { $0.date >= weekStart }
        if !weekShifts.isEmpty {
            output.append("## Hideout — This Week")
            let totalRev = weekShifts.map(\.grossRevenue).reduce(0, +)
            let avgRev = totalRev / Double(weekShifts.count)
            let stressScores = weekShifts.filter { $0.stressScore > 0 }
            let avgStress = stressScores.isEmpty ? 0.0 : stressScores.map { Double($0.stressScore) }.reduce(0, +) / Double(stressScores.count)
            output.append("**\(weekShifts.count) shifts · $\(Int(totalRev)) total · $\(Int(avgRev))/day avg · stress \(String(format: "%.1f", avgStress))/10**")
            output.append("")
            let upsellCount = weekShifts.filter { $0.usedScriptedUpsell }.count
            let regularCount = weekShifts.filter { $0.recognizedRegular }.count
            let peakEndCount = weekShifts.filter { $0.anchorPhraseUsed }.count
            output.append("**Behavioral Techniques**")
            output.append("- Scripted upsell: \(upsellCount)/\(weekShifts.count)")
            output.append("- Recognized regular: \(regularCount)/\(weekShifts.count)")
            output.append("- Peak-end close: \(peakEndCount)/\(weekShifts.count)")
            let upsellS = weekShifts.filter { $0.usedScriptedUpsell && $0.transactionCount > 0 }
            let noUpsellS = weekShifts.filter { !$0.usedScriptedUpsell && $0.transactionCount > 0 }
            if !upsellS.isEmpty && !noUpsellS.isEmpty {
                let u = upsellS.map { $0.grossRevenue / Double($0.transactionCount) }.reduce(0, +) / Double(upsellS.count)
                let b = noUpsellS.map { $0.grossRevenue / Double($0.transactionCount) }.reduce(0, +) / Double(noUpsellS.count)
                output.append("- Avg ticket: upsell $\(String(format: "%.2f", u)) vs no upsell $\(String(format: "%.2f", b))")
            }
            for shift in weekShifts.sorted(by: { $0.date < $1.date }) {
                if !shift.notes.isEmpty { output.append("*\(shift.dayLabel): \(shift.notes)*") }
            }
            output.append("")
        }

        // Action completion rates
        output.append("## Completion Rates (7-day)")
        for system in SystemTag.allCases {
            let sysActions = actions.filter { $0.system == system }
            if sysActions.isEmpty { continue }
            output.append("**\(system.rawValue.capitalized)**")
            for a in sysActions {
                let thisWeek = a.completionDates.filter { $0 >= weekStart }.count
                let pct = Int(Double(thisWeek) / 7.0 * 100)
                output.append("  - \(a.title): \(pct)% (\(thisWeek)/7)")
            }
            output.append("")
        }

        // Daily log notes
        let weekLogs = logs.filter { $0.date >= weekStart }.sorted { $0.date < $1.date }
        if !weekLogs.isEmpty {
            output.append("## Daily Log Notes")
            for log in weekLogs {
                output.append("**\(log.date.formatted(.dateTime.weekday(.wide).month().day()))**")
                if let w = log.topWin, !w.isEmpty { output.append("Top win: \(w)") }
                if let n = log.notes, !n.isEmpty { output.append("Notes: \(n)") }
                if let t = log.specificActionNote, !t.isEmpty { output.append("Tomorrow: \(t)") }
                output.append("")
            }
        }

        // Friction
        let highFriction = actions.filter { $0.isHighFriction }
        if !highFriction.isEmpty {
            output.append("## High Friction")
            for a in highFriction {
                output.append("- \(a.title) — \(a.skipCount) skips · \(Int(a.completionRate * 100))% rate")
            }
            output.append("")
        }

        output.append("---")
        output.append("*Generated by INCREMENTS · \(today.formatted(.dateTime.month().day().year()))*")
        return output.joined(separator: "\n")
    }
}

// MARK: - CONSULT VIEW (Phase B3 — 30-Day Read)

struct ConsultView: View {
    @Bindable var profile: OperatorProfile
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query private var actions: [Action]
    @Query private var receipts: [ConsultReceipt]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var consultState: ConsultState = .ready

    var savedReceipt: ConsultReceipt? { receipts.first(where: { $0.wasSaved }) }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "PATTERN BRIEF", color: .violetLight, size: 11)
                            Text("30-day system read.")
                                .font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                    }

                    switch consultState {
                    case .ready:
                        consultReady()
                    case .loading:
                        VStack(spacing: 12) {
                            ProgressView().tint(.violet)
                            Text("Reading the pattern...").font(.sora(13, weight: .light)).foregroundColor(.textMuted)
                        }.frame(maxWidth: .infinity).padding(.vertical, 40)
                    case .response(let text):
                        consultResponseView(text: text)
                    case .insufficientData(let remaining):
                        consultInsufficientData(remaining: remaining)
                    case .cooldownActive(let available):
                        consultCooldownActive(available: available)
                    case .noSignal:
                        CardView(style: .secondary) {
                            VStack(alignment: .leading, spacing: 8) {
                                MonoLabel(text: "NO SIGNAL", color: .textMuted, size: 11)
                                Text("The data didn't produce a clear pattern. Try again in a week.")
                                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                            }
                        }
                    case .error:
                        CardView(style: .secondary) {
                            VStack(alignment: .leading, spacing: 8) {
                                MonoLabel(text: "ERROR", color: .inkRed, size: 11)
                                Text("Something went wrong. Check your API key in Settings.")
                                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                            }
                        }
                    }

                    if let receipt = savedReceipt {
                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "LAST SAVED READ", color: .textMuted, size: 10)
                            Text(receipt.observationText)
                                .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                            MonoLabel(text: "Day \(receipt.daysInSystemAtRead) · \(receipt.createdAt.formatted(.dateTime.month().day().year()))", color: .muted, size: 10)
                        }
                        .padding(16).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
        .onAppear { consultState = ConsultEngine.gateState(profile: profile) }
    }

    // MARK: - State views

    func consultResponseView(text: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "BRIEF", color: .violetLight, size: 11)
                    Text(text)
                        .font(.sora(15, weight: .light))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Button(action: { saveReceipt(text: text) }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down").font(.system(size: 13))
                    Text("Save this read").font(.sora(13, weight: .medium))
                }
                .foregroundColor(.bgBase)
                .frame(maxWidth: .infinity).frame(height: 46)
                .background(Color.violet)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    func consultInsufficientData(remaining: Int) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 12) {
                MonoLabel(text: "NOT YET", color: .textMuted, size: 11)
                Text("Not enough signal yet.")
                    .font(.sora(16, weight: .light)).foregroundColor(.textPrimary)
                Text("30 days of data required. Currently day \(profile.daysInSystem).")
                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                HStack(spacing: 6) {
                    Circle().fill(Color.inkAmber.opacity(0.5)).frame(width: 5, height: 5)
                    Text("\(remaining) day\(remaining == 1 ? "" : "s") remaining.")
                        .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                }
            }
        }
    }

    func consultCooldownActive(available: Date) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 12) {
                MonoLabel(text: "COOLDOWN", color: .textMuted, size: 11)
                if let last = profile.lastConsultDate {
                    Text("Last read: \(last.formatted(.dateTime.month().day())).")
                        .font(.sora(14)).foregroundColor(.textPrimary)
                }
                Text("Next read available \(available.formatted(.dateTime.month().day())).")
                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
                Text("14 days between reads. The data needs time to change.")
                    .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
            }
        }
    }

    func consultReady() -> some View {
        VStack(spacing: 16) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "READY", color: .inkGreen, size: 11)
                    Text("Day \(profile.daysInSystem). Enough signal to read.")
                        .font(.sora(14)).foregroundColor(.textPrimary)
                    if let last = profile.lastConsultDate {
                        Text("Last read: \(last.formatted(.dateTime.month().day())).")
                            .font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                    }
                }
            }

            Button(action: startConsult) {
                Text("RUN PATTERN BRIEF")
                    .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text("One read every 14 days. Analyst format. Not a conversation.")
                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
    }

    func consultLoading() -> some View {
        CardView(style: .secondary) {
            HStack(spacing: 14) {
                // Quiet pulse — not theatrical
                Circle()
                    .fill(Color.violet.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .modifier(SlowPulse())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reading the last 30 days.")
                        .font(.sora(14)).foregroundColor(.textPrimary)
                    Text("This may take a moment.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                }
                Spacer()
            }
        }
    }

    func consultResponse(text: String) -> some View {
        VStack(spacing: 16) {
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    MonoLabel(text: "PATTERN BRIEF · DAY \(profile.daysInSystem)", color: .violetLight, size: 11)
                    Text(text)
                        .font(.sora(14, weight: .light))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 12) {
                // Save — explicit, user-initiated
                Button(action: { saveReceipt(text: text) }) {
                    Text("SAVE")
                        .font(.sora(13, weight: .semibold)).foregroundColor(.violet).tracking(1.5)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color.violetDim.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.violet.opacity(0.3), lineWidth: 0.5))
                }

                // Dismiss — closes without saving
                Button(action: { dismiss() }) {
                    Text("DONE")
                        .font(.sora(13, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Text("Save preserves this read. Dismiss closes without saving.")
                .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
    }

    func consultNoSignal() -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(text: "NOTHING NEW", color: .textMuted, size: 11)
                Text("Nothing significant in the last 30 days.")
                    .font(.sora(14)).foregroundColor(.textPrimary)
                Text("The patterns are holding.")
                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond)
            }
        }
    }

    func consultError() -> some View {
        VStack(spacing: 12) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "UNAVAILABLE", color: .textMuted, size: 11)
                    Text("Couldn't read it. Nothing was saved.")
                        .font(.sora(14)).foregroundColor(.textPrimary)
                }
            }
            Button(action: { dismiss() }) {
                Text("DONE")
                    .font(.sora(13, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Actions

    func startConsult() {
        consultState = .loading
        Task {
            let result = await ConsultEngine.run(
                profile: profile,
                actions: actions,
                logs: Array(logs.prefix(30))
            )
            await MainActor.run {
                // Update cooldown immediately when read is run (whether or not user saves)
                profile.lastConsultDate = Date()
                consultState = result
            }
        }
    }

    func saveReceipt(text: String) {
        // Overwrite the single saved receipt — no accumulating history
        for old in receipts { context.delete(old) }
        let receipt = ConsultReceipt()
        receipt.observationText = text
        receipt.daysInSystemAtRead = profile.daysInSystem
        receipt.wasSaved = true
        context.insert(receipt)
        dismiss()
    }
}

// Quiet pulse animation for loading state
struct SlowPulse: ViewModifier {
    @State private var pulsing = false
    func body(content: Content) -> some View {
        content
            .opacity(pulsing ? 0.3 : 1.0)
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulsing)
            .onAppear { pulsing = true }
    }
}

// MARK: - PATTERN BRIEF CARD (entry point — operator-requested system read)

struct ConsultCard: View {
    @Bindable var profile: OperatorProfile
    @State private var showConsult = false

    var gateState: ConsultState { ConsultEngine.gateState(profile: profile) }

    var body: some View {
        CardView(style: gateState == .ready ? .primary : .secondary) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    MonoLabel(text: "PATTERN BRIEF", color: statusColor, size: 11)
                    Text(statusTitle)
                        .font(.sora(14, weight: gateState == .ready ? .semibold : .light))
                        .foregroundColor(gateState == .ready ? .textPrimary : .textMuted)
                    Text(statusSubtitle)
                        .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                }
                Spacer()
                if gateState == .ready {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.violetLight)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if gateState == .ready || hasViewableReceipt { showConsult = true }
        }
        .sheet(isPresented: $showConsult) {
            ConsultView(profile: profile)
        }
    }

    var hasViewableReceipt: Bool {
        if case .cooldownActive = gateState { return true }
        return false
    }

    var statusColor: Color {
        switch gateState {
        case .ready:            return .inkGreen
        case .insufficientData: return .textMuted
        case .cooldownActive:   return .muted
        default:                return .textMuted
        }
    }

    var statusTitle: String {
        switch gateState {
        case .ready:
            return "System read available."
        case .insufficientData(let remaining):
            return "\(remaining) day\(remaining == 1 ? "" : "s") until sufficient data."
        case .cooldownActive(let available):
            return "Next read: \(available.formatted(.dateTime.month().day()))."
        default:
            return "Pattern Brief"
        }
    }

    var statusSubtitle: String {
        switch gateState {
        case .ready:
            return "30-day pattern read. Analyst format. One read every 14 days."
        case .insufficientData:
            return "Requires 30 days of data. Building signal."
        case .cooldownActive:
            return "14-day cooldown between reads. Tap to review last brief."
        default:
            return ""
        }
    }
}



// MARK: - FOCUS MODE
// Phase 2 — Deep work timer. Tab bar disappears. Session is locked.
// Counts UP (less clock-watching anxiety). 45-min default.
// Exit sequence has a 2-screen buffer — cortisol normalization.

struct FocusMode: View {
    @Binding var isPresented: Bool
    @State private var elapsed: Int = 0
    @State private var isRunning = false
    @State private var showExit = false
    @State private var sessionNote = ""
    @State private var workType: FocusWorkType = .deepWork
    @State private var intention = ""
    @State private var phase: FocusPhase = .setup

    enum FocusPhase { case setup, active, winding, done }
    enum FocusWorkType: String, CaseIterable {
        case deepWork   = "Deep Work"
        case reviewEdit = "Review & Edit"
        case admin      = "Admin"
        case reading    = "Reading"
        var icon: String {
            switch self {
            case .deepWork: return "brain"
            case .reviewEdit: return "pencil"
            case .admin: return "briefcase"
            case .reading: return "book"
            }
        }
    }

    var elapsedFormatted: String {
        let h = elapsed / 3600, m = (elapsed % 3600) / 60, s = elapsed % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            switch phase {
            case .setup: setupView
            case .active: activeView
            case .winding: windingView
            case .done: doneView
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isRunning { elapsed += 1 }
        }
    }

    var setupView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Text("FOCUS").font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark").foregroundColor(.textMuted)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "WORK TYPE")
                    HStack(spacing: 8) {
                        ForEach(FocusWorkType.allCases, id: \.self) { type in
                            Button(action: { workType = type }) {
                                VStack(spacing: 5) {
                                    Image(systemName: type.icon).font(.system(size: 16, weight: .light))
                                    Text(type.rawValue).font(.sora(10)).lineLimit(1)
                                }
                                .foregroundColor(workType == type ? .bgBase : .violetLight)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(workType == type ? Color.violetLight : Color.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "INTENTION (OPTIONAL)")
                    TextField("What are you doing in this session?", text: $intention)
                        .font(.sora(14)).foregroundColor(.textPrimary)
                        .padding(14).background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10)).tint(.violet)
                }

                primaryButton("START SESSION", disabled: false) {
                    withAnimation { phase = .active; isRunning = true }
                }
            }
            .padding(28)
        }
    }

    var activeView: some View {
        VStack(spacing: 0) {
            // Full-screen focus — no distractions
            Spacer()
            VStack(spacing: 20) {
                MonoLabel(text: workType.rawValue.uppercased(), color: .violetLight, size: 11)
                Text(elapsedFormatted)
                    .font(.system(size: 64, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                if !intention.isEmpty {
                    Text(intention)
                        .font(.sora(14, weight: .light)).foregroundColor(.textSecond)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                }
            }
            Spacer()
            VStack(spacing: 12) {
                Button(action: { withAnimation { phase = .winding; isRunning = false } }) {
                    Text("End session")
                        .font(.sora(14, weight: .medium)).foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 28).padding(.bottom, 48)
        }
    }

    var windingView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(text: "SESSION CLOSED", color: .inkGreen, size: 11)
                Text("\(elapsedFormatted)")
                    .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.textPrimary).monospacedDigit()
                Text(workType.rawValue)
                    .font(.mono(13)).foregroundColor(.textMuted).tracking(0.5)
            }
            Text("Let it settle before the next thing.")
                .font(.sora(16, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)

            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(text: "ONE LINE IF YOU WANT IT", color: .textMuted, size: 10)
                TextField("What happened?", text: $sessionNote)
                    .font(.sora(14)).foregroundColor(.textPrimary)
                    .padding(14).background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10)).tint(.violet)
            }
            Spacer()
            primaryButton("DONE", disabled: false) {
                withAnimation { phase = .done }
            }
        }
        .padding(28)
    }

    var doneView: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                if !sessionNote.isEmpty {
                    Text(sessionNote)
                        .font(.sora(16, weight: .light)).foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                }
                MonoLabel(text: "RECORDED.", color: .inkGreen, size: 11)
            }
            Spacer()
            Button(action: { isPresented = false }) {
                Text("Return").font(.sora(14)).foregroundColor(.textMuted)
            }
            .padding(.bottom, 48)
        }
    }
}

// MARK: - INSIGHTS VIEW
// Always visible. Content gated by 7 days of data (not 30 — rapid adoption confirmed).
// Shows patterns, not scores. Evidence, not grades.
// Week 1: descriptor summaries. Week 2+: pattern observations. Wendy history.

struct InsightsView: View {
    @Bindable var state: AppState
    @Query private var actions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query private var profiles: [OperatorProfile]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @ObservedObject private var wendyState = WendyState.shared
    @State private var showFocus = false

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }
    var daysIn: Int { profile.daysInSystem }
    var hasWeekData: Bool { daysIn >= 7 }

    var body: some View {
        ZStack {
            AtmosphericBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "INSIGHTS", color: .violetLight, size: 11)
                            Text("Patterns, not scores.")
                                .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                        // Focus Mode entry
                        Button(action: { showFocus = true }) {
                            HStack(spacing: 5) {
                                Image(systemName: "brain").font(.system(size: 13))
                                Text("Focus").font(.sora(12, weight: .medium))
                            }
                            .foregroundColor(.bgBase)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color.violetLight)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 24)

                    if !hasWeekData {
                        // Before 7 days — show what the tab will become
                        earlyStateView
                    } else {
                        // 7+ days — real patterns
                        patternContent
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .fullScreenCover(isPresented: $showFocus) {
            FocusMode(isPresented: $showFocus)
        }
    }

    var earlyStateView: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "DAY \(daysIn) OF 7", color: .warm, size: 11)
                    Text("Patterns need time to be real.")
                        .font(.sora(15, weight: .medium)).foregroundColor(.textPrimary)
                    Text("At 7 days, this tab shows completion rates by system, timing patterns, and Wendy's written observations. The data's collecting. Come back in \(max(0, 7 - daysIn)) day\(7 - daysIn == 1 ? "" : "s").")
                        .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                }
            }
            .padding(.horizontal, 24)

            // Show Focus Mode prominently while waiting
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "FOCUS MODE", color: .violetLight, size: 11)
                    Text("Deep work timer. Tab bar disappears. No distractions.")
                        .font(.sora(14, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Button(action: { showFocus = true }) {
                        Text("Start a session")
                            .font(.sora(13, weight: .medium)).foregroundColor(.violetLight)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    var patternContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Completion rates by system — 7-day window
            weekCompletionSection
                .padding(.horizontal, 24)

            // Best completion hour
            timingSection
                .padding(.horizontal, 24)

            // Wendy's last observation — persisted
            if let obs = profile.lastWendyObservation, !obs.isEmpty {
                wendyHistoryCard(obs)
                    .padding(.horizontal, 24)
            }

            // Hideout data if available
            if !shifts.isEmpty {
                hideoutInsightSection
                    .padding(.horizontal, 24)
            }

            // Friction — actions with high skip rates
            frictionSection
                .padding(.horizontal, 24)

            // Focus Mode card
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "FOCUS MODE", color: .violetLight, size: 11)
                    Text("Deep work timer. Tab bar disappears. Counts up, not down.")
                        .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Button(action: { showFocus = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "brain").font(.system(size: 13))
                            Text("Start a focus session")
                                .font(.sora(13, weight: .medium))
                        }
                        .foregroundColor(.violetLight)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    var weekCompletionSection: some View {
        let cal = Calendar.current
        let weekStart = cal.date(byAdding: .day, value: -6, to: Date()) ?? Date()

        return VStack(alignment: .leading, spacing: 12) {
            MonoLabel(text: "LAST 7 DAYS — BY SYSTEM", color: .textMuted, size: 10)
            ForEach(SystemTag.allCases, id: \.self) { sys in
                let sysActions = actions.filter { $0.system == sys && ($0.recurrence == .daily || $0.recurrence == .weekdays) }
                if !sysActions.isEmpty {
                    let totalPossible = sysActions.count * 7
                    let completed = sysActions.reduce(0) { count, a in
                        count + a.completionDates.filter { $0 >= weekStart }.count
                    }
                    let rate = totalPossible > 0 ? Double(completed) / Double(totalPossible) : 0

                    HStack(spacing: 12) {
                        Circle().fill(sys.color).frame(width: 7, height: 7)
                        Text(sys.rawValue.capitalized)
                            .font(.sora(13)).foregroundColor(.textPrimary)
                        Spacer()
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(width: 80, height: 4)
                            RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.8))
                                .frame(width: 80 * CGFloat(rate), height: 4)
                        }
                        Text(String(format: "%.0f%%", rate * 100))
                            .font(.mono(11)).foregroundColor(rate >= 0.7 ? .inkGreen : rate >= 0.4 ? .inkAmber : .textMuted)
                            .tracking(0.3).frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
    }

    var timingSection: some View {
        let allCompletions = actions.flatMap { a in
            a.completionDates.filter {
                Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 999 < 14
            }
        }
        let hourCounts = Dictionary(grouping: allCompletions) {
            Calendar.current.component(.hour, from: $0)
        }.mapValues(\.count)
        let peakHour = hourCounts.max(by: { $0.value < $1.value })?.key

        return VStack(alignment: .leading, spacing: 8) {
            MonoLabel(text: "WHEN YOU ACTUALLY WORK", color: .textMuted, size: 10)
            if let h = peakHour {
                Text("Peak completion hour: \(formatBlockTime("\(h):00"))")
                    .font(.sora(14, weight: .light)).foregroundColor(.textPrimary)
                let morningCount = allCompletions.filter { Calendar.current.component(.hour, from: $0) < 12 }.count
                let eveningCount = allCompletions.filter { Calendar.current.component(.hour, from: $0) >= 17 }.count
                let total = max(1, allCompletions.count)
                Text("Morning: \(Int(Double(morningCount)/Double(total)*100))% · Evening: \(Int(Double(eveningCount)/Double(total)*100))%")
                    .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
            } else {
                Text("Not enough data yet.").font(.sora(13, weight: .light)).foregroundColor(.textMuted)
            }
        }
    }

    func wendyHistoryCard(_ text: String) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Circle().fill(Color.violetLight.opacity(0.7)).frame(width: 6, height: 6)
                        .shadow(color: .violetLight.opacity(0.4), radius: 4)
                    MonoLabel(text: "WENDY — LAST OBSERVATION", color: .violetLight, size: 10)
                    Spacer()
                    if let date = profile.lastWendyObservationDate {
                        MonoLabel(text: date.formatted(.dateTime.month().day()), color: .muted, size: 10)
                    }
                }
                Text(text)
                    .font(.sora(14, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    var hideoutInsightSection: some View {
        let recent = Array(shifts.prefix(14))
        let avgRev = recent.isEmpty ? 0.0 : recent.map(\.grossRevenue).reduce(0, +) / Double(recent.count)
        let band = HideoutPlanningBand.classify(avgRev)

        return VStack(alignment: .leading, spacing: 10) {
            MonoLabel(text: "HIDEOUT — \(recent.count) SHIFTS", color: .warm, size: 10)
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("$\(Int(avgRev))/day")
                        .font(.sora(18, weight: .semibold)).foregroundColor(.textPrimary)
                    Text(band.label).font(.mono(10)).foregroundColor(band.color).tracking(0.3)
                }
                Spacer()
                let stress = recent.filter { $0.stressScore > 0 }
                if !stress.isEmpty {
                    let avg = stress.map { Double($0.stressScore) }.reduce(0, +) / Double(stress.count)
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f/10", avg))
                            .font(.sora(18, weight: .semibold))
                            .foregroundColor(avg <= 4 ? .inkGreen : avg <= 7 ? .inkAmber : .inkRed)
                        Text("avg stress").font(.mono(10)).foregroundColor(.textMuted).tracking(0.3)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var frictionSection: some View {
        let highFriction = actions.filter { $0.isHighFriction }
        if !highFriction.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "HIGH FRICTION — CONSIDER RESIZING", color: .inkAmber, size: 10)
                ForEach(highFriction.prefix(3)) { a in
                    HStack {
                        Circle().fill(a.system.color.opacity(0.6)).frame(width: 6, height: 6)
                        Text(a.title).font(.sora(13)).foregroundColor(.textSecond).lineLimit(1)
                        Spacer()
                        Text("\(a.skipCount)×").font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                    }
                }
            }
        }
    }
}

// MARK: - TODAY EMBED WRAPPERS (Systems / Habits / Timeline sub-tabs)

struct IncrementsViewEmbed: View {
    @Query private var actions: [Action]
    @Bindable var state: AppState
    @State private var selectedSeg = 0

    var completedToday: [Action] {
        actions.filter { $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }
    }
    var filteredActions: [Action] {
        switch selectedSeg {
        case 0: return actions.filter { $0.recurrence == .daily || $0.recurrence == .weekdays || $0.recurrence == .weekends }
        case 1: return actions.filter { $0.recurrence == .weekly }
        case 2: return actions.filter { $0.recurrence == .none }
        default: return actions
        }
    }
    func daysSinceActivity(_ sys: SystemTag) -> Int {
        let sysActions = actions.filter { $0.system == sys }
        let candidates: [Date] = sysActions.flatMap { a -> [Date] in
            var dates = a.completionDates
            if let at = a.completedAt { dates.append(at) }
            return dates
        }
        guard let last = candidates.max() else { return 999 }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 999
    }

    var body: some View {
        VStack(spacing: 0) {
            segmentControl(["Active", "Planned", "Someday"], selected: $selectedSeg)
                .padding(.horizontal, 24).padding(.bottom, 16)
            VStack(spacing: 8) {
                ForEach(SystemTag.allCases, id: \.self) { sys in
                    let score = state.systemScores[sys] ?? 0
                    let pending = filteredActions.filter { $0.system == sys && !$0.isCompleted }
                    let done = completedToday.filter { $0.system == sys }.count
                    let quiet = daysSinceActivity(sys)
                    VStack(alignment: .leading, spacing: 4) {
                        SystemDetailRow(sys: sys, score: score, state: state,
                                        pending: pending, done: done, quiet: quiet,
                                        allActions: filteredActions)
                        if quiet >= 3 && quiet < 999 {
                            Text("\(sys.rawValue.capitalized) — nothing here in \(quiet) days.")
                                .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                                .padding(.horizontal, 6).padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 80)
        }
    }
}

struct HabitsViewEmbed: View {
    @Environment(\.modelContext) private var context
    @Query private var habits: [Habit]
    @State private var showAdd = false

    var activeHabits: [Habit] { habits.filter(\.isActive) }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button(action: { showAdd = true }) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus").font(.system(size: 12, weight: .semibold))
                        Text("Add habit").font(.sora(12, weight: .medium))
                    }
                    .foregroundColor(.violet).padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.violetDim.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 24)
            if activeHabits.isEmpty {
                emptyState(icon: "arrow.triangle.2.circlepath", title: "No active habits",
                           subtitle: "Recurring anchors appear here.")
            }
            ForEach(activeHabits) { habit in
                HabitCard(habit: habit).padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 80)
        .sheet(isPresented: $showAdd) { AddHabitSheet(isPresented: $showAdd) }
        .onAppear { if habits.isEmpty { seedDefaultHabitsEmbed(context: context) } }
    }

    func seedDefaultHabitsEmbed(context: ModelContext) {
        let defaults: [(String, SystemTag, String, String)] = [
            ("Morning Routine", .health, "After alarm dismissed", "5 min version"),
            ("Deep Work", .operations, "When opening laptop", "25 min minimum"),
            ("Movement", .health, "After clearing desk surface", "10 min walk"),
            ("No Phone First Hour", .cognition, "When waking", "Phone stays face-down"),
            ("Night Routine", .environment, "After final meal", "Lights dimmed, one reset"),
        ]
        for (title, system, cue, minimum) in defaults {
            context.insert(Habit(title: title, system: system, cue: cue, minimumScope: minimum))
        }
    }
}

struct TimelineViewEmbed: View {
    @Query private var allActions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    var actionsByDay: [(day: Date, actions: [(Action, Date)])] {
        let cal = Calendar.current
        var pairs: [(Action, Date)] = []
        for action in allActions {
            for date in action.completionDates { pairs.append((action, date)) }
            if let at = action.completedAt, cal.isDateInToday(at) {
                if !action.completionDates.contains(where: { cal.isDate($0, inSameDayAs: at) }) {
                    pairs.append((action, at))
                }
            }
        }
        let days = Array(Set(pairs.map { cal.startOfDay(for: $0.1) })).sorted(by: >)
        return days.map { day in
            let dayPairs = pairs.filter { cal.isDate($0.1, inSameDayAs: day) }.sorted { $0.1 > $1.1 }
            return (day: day, actions: dayPairs)
        }
    }

    func dayHeader(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "TODAY" }
        if cal.isDateInYesterday(date) { return "YESTERDAY" }
        return date.formatted(.dateTime.weekday(.wide).month().day()).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if actionsByDay.isEmpty {
                emptyState(icon: "clock", title: "No history yet",
                           subtitle: "Complete actions in Today to build the record.")
            } else {
                ForEach(Array(actionsByDay.enumerated()), id: \.element.day) { idx, entry in
                    VStack(alignment: .leading, spacing: 4) {
                        MonoLabel(text: dayHeader(entry.day), color: .violetLight, size: 11)
                        Text("\(entry.actions.count) action\(entry.actions.count == 1 ? "" : "s")")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, idx == 0 ? 0 : 20).padding(.bottom, 10)

                    ForEach(Array(entry.actions.enumerated()), id: \.offset) { _, pair in
                        TimelineEntryRow(action: pair.0, completionDate: pair.1)
                    }
                }
            }
        }
        .padding(.bottom, 80)
    }
}

// MARK: - OPERATOR VIEW (mission control — Brief / Dossier / Lab / Manual)

struct OperatorView: View {
    @Bindable var state: AppState
    @Query private var profiles: [OperatorProfile]
    @State private var selectedSeg = 0

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    var body: some View {
        ZStack { AtmosphericBackground()
            VStack(spacing: 0) {
                // Header — sparse, purposeful. Opens a briefing, not a settings panel.
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        MonoLabel(text: "MISSION CONTROL", color: .violetLight, size: 10)
                        Text("Operator")
                            .font(.sora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    }
                    Spacer()
                    // Day counter — mission clock, not gamification
                    VStack(alignment: .trailing, spacing: 2) {
                        MonoLabel(text: "DAY \(profile.daysInSystem)", color: .warm, size: 11)
                        MonoLabel(text: DayType.today.label, color: .textMuted, size: 10)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 14)

                // 4 tabs — Brief is the live situation room, rest are reference layers
                segmentControl(["Brief", "Dossier", "Lab", "Manual"], selected: $selectedSeg)
                    .padding(.horizontal, 24).padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    switch selectedSeg {
                    case 0: BriefTabView(state: state, profile: profile)
                    case 1: DossierTabView(profile: profile)
                    case 2: OperatorTabView()
                    case 3: FieldManualTabView()
                    default: EmptyView()
                    }
                }
            }
        }
    }
}

// MARK: - OBSERVED INTELLIGENCE CARD

struct ObservedIntelligenceCard: View {
    let actions: [Action]
    let logs: [DailyLog]
    @State private var expanded = false

    var intelligence: ObservedIntelligence {
        ObservedIntelligenceEngine.compute(actions: actions, logs: logs)
    }

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.22)) { expanded.toggle() }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            MonoLabel(text: "OBSERVED INTELLIGENCE", color: .inkGreen)
                            Text(intelligence.frictionSignature)
                                .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                .lineSpacing(2)
                        }
                        Spacer()
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .light)).foregroundColor(.textMuted)
                    }
                }

                if expanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider().background(Color.muted.opacity(0.3)).padding(.top, 10)

                        observedRow("PEAK WINDOW", value: intelligence.peakExecutionWindow.capitalized)

                        if let h = intelligence.avgInitiationHour {
                            let period = h < 12 ? "AM" : "PM"
                            let display = h > 12 ? h - 12 : (h == 0 ? 12 : h)
                            observedRow("AVG FIRST ACTION", value: "\(display)\(period)")
                        }

                        switch intelligence.completionClustering {
                        case .clustered(let pct, _):
                            observedRow("COMPLETION PATTERN", value: "Clustered — \(pct)% in peak hours")
                        case .distributed:
                            observedRow("COMPLETION PATTERN", value: "Distributed through day")
                        case .insufficient:
                            observedRow("COMPLETION PATTERN", value: "Collecting")
                        }

                        observedRow("MORNING RATE", value: "\(Int(intelligence.morningCompletionRate * 100))% before noon")
                        observedRow("GENERATIVE RATIO", value: "\(Int(intelligence.generativeRatio * 100))% of recent completions")
                        observedRow("ADMIN DISPLACEMENT", value: intelligence.adminDisplacementFrequency == 0
                            ? "Not detected (14d)"
                            : "\(intelligence.adminDisplacementFrequency) of last 14 days")

                        switch intelligence.energyDeclarationAccuracy {
                        case .inverted:
                            observedRow("ENERGY ACCURACY", value: "Inverted — reserve days outperform full", highlight: .inkAmber)
                        case .calibrated:
                            observedRow("ENERGY ACCURACY", value: "Calibrated")
                        case .uncalibrated:
                            observedRow("ENERGY ACCURACY", value: "Weak signal")
                        case .insufficient:
                            observedRow("ENERGY ACCURACY", value: "Collecting")
                        }

                        if intelligence.estimatedOpenFronts >= OperatorDoctrine.openFrontFragmentationThreshold {
                            observedRow("OPEN FRONTS", value: "\(intelligence.estimatedOpenFronts) stalled systems", highlight: .inkAmber)
                        }

                        Divider().background(Color.muted.opacity(0.2))
                        Text("Derived from usage data. Updates as patterns accumulate.")
                            .font(.mono(9)).foregroundColor(.muted).tracking(0.3)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    func observedRow(_ label: String, value: String, highlight: Color? = nil) -> some View {
        HStack(alignment: .top) {
            MonoLabel(text: label, color: .textMuted, size: 10)
                .frame(width: 150, alignment: .leading)
            Text(value)
                .font(.sora(12, weight: .light))
                .foregroundColor(highlight ?? .textPrimary)
                .lineSpacing(2)
            Spacer()
        }
    }
}

// MARK: - BRIEF TAB (live situation room — Insights + synthesized read)

struct BriefTabView: View {
    @Bindable var state: AppState
    @Bindable var profile: OperatorProfile
    @Query private var actions: [Action]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @Query(sort: \HydrationLog.timestamp, order: .reverse) private var hydrationLogs: [HydrationLog]
    @ObservedObject private var wendyState = WendyState.shared
    @State private var showFocus = false

    var completedToday: [Action] {
        actions.filter { $0.isCompleted && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }
    }
    var pendingToday: [Action] { actions.filter { !$0.isCompleted } }

    // Synthesize 2–3 sharp observations from live data — no hedging, no therapy
    var liveBriefLines: [String] {
        var lines: [String] = []
        let hour = Calendar.current.component(.hour, from: Date())
        let doneCount = completedToday.count

        // Energy state observation
        if let energy = state.todayEnergyState {
            switch energy {
            case .reserve:
                lines.append("Reserve day declared. Three actions maximum. Protect the floor.")
            case .partial:
                lines.append("Partial capacity. Defer admin. Protect the creative window.")
            case .full:
                if doneCount == 0 && hour > 10 {
                    lines.append("Full capacity declared. Nothing closed yet. Open the first door.")
                } else if doneCount >= 5 {
                    lines.append("Full day. \(doneCount) closed. Momentum is real.")
                }
            }
        }

        // Quiet system signal
        let quietSystems = SystemTag.allCases.filter {
            let days = state.daysSinceActivity($0)
            return days >= 3 && days < 999
        }
        if let q = quietSystems.first {
            let days = state.daysSinceActivity(q)
            lines.append("\(q.rawValue.capitalized) — \(days) days without a signal. Watch this.")
        }

        // Timing pattern
        if doneCount > 0 && hour < 12 {
            lines.append("Morning execution confirmed. Pattern holding.")
        } else if doneCount == 0 && hour >= 14 {
            lines.append("Afternoon. Nothing closed. Entry point still available.")
        }

        // Consult observation if available
        if let obs = profile.lastWendyObservation, !obs.isEmpty,
           let obsDate = profile.lastWendyObservationDate,
           Calendar.current.dateComponents([.day], from: obsDate, to: Date()).day ?? 999 < 8 {
            lines.append(obs)
        }

        // Fallback — never empty
        if lines.isEmpty {
            lines.append("Systems nominal. No alerts.")
        }

        return Array(lines.prefix(3))
    }

    var weekStart: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    }

    var body: some View {
        VStack(spacing: 16) {

            // ── LIVE BRIEF ───────────────────────────────────────────────
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        MonoLabel(text: "SITUATION · \(Date().formatted(.dateTime.weekday(.wide).day().month()))", color: .violetLight)
                        Spacer()
                        Button(action: { showFocus = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "brain").font(.system(size: 11))
                                Text("Focus").font(.mono(10)).tracking(0.5)
                            }
                            .foregroundColor(.violetLight)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.violetDim.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(liveBriefLines.enumerated()), id: \.offset) { i, line in
                            HStack(alignment: .top, spacing: 10) {
                                // Classified-doc bullet
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.violetLight.opacity(0.6))
                                    .frame(width: 2, height: 14)
                                    .padding(.top, 3)
                                Text(line)
                                    .font(.sora(14, weight: .light))
                                    .foregroundColor(.textPrimary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── SYSTEM STATUS (5-dot read) ───────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "SYSTEMS", color: .textMuted)
                    HStack(spacing: 0) {
                        ForEach(SystemTag.allCases, id: \.self) { sys in
                            let active = profile.isSystemActiveThisWeek(sys)
                            let days = state.daysSinceActivity(sys)
                            let decaying = !active && days >= 3 && days < 999
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(active ? sys.color : Color.surface2)
                                    .frame(width: 9, height: 9)
                                    .overlay(Circle().stroke(
                                        decaying ? sys.color.opacity(0.5) : Color.clear, lineWidth: 1))
                                    .opacity(decaying ? 0.45 : 1.0)
                                MonoLabel(text: String(sys.rawValue.prefix(3)).uppercased(),
                                          color: active ? sys.color : .muted, size: 8)
                                if days < 999 && days > 0 {
                                    MonoLabel(text: "\(days)d", color: .muted, size: 8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── 7-DAY COMPLETION RATES ───────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "7-DAY OUTPUT", color: .textMuted)
                    ForEach(SystemTag.allCases, id: \.self) { sys in
                        let sysActions = actions.filter {
                            $0.system == sys && ($0.recurrence == .daily || $0.recurrence == .weekdays)
                        }
                        if !sysActions.isEmpty {
                            let totalPossible = sysActions.count * 7
                            let completed = sysActions.reduce(0) { n, a in
                                n + a.completionDates.filter { $0 >= weekStart }.count
                            }
                            let rate = totalPossible > 0 ? Double(completed) / Double(totalPossible) : 0
                            HStack(spacing: 10) {
                                Circle().fill(sys.color).frame(width: 6, height: 6)
                                Text(sys.rawValue.capitalized)
                                    .font(.sora(12)).foregroundColor(.textPrimary)
                                Spacer()
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2).fill(Color.surface2)
                                        .frame(width: 72, height: 3)
                                    RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.8))
                                        .frame(width: 72 * CGFloat(rate), height: 3)
                                }
                                Text(String(format: "%.0f%%", rate * 100))
                                    .font(.mono(10))
                                    .foregroundColor(rate >= 0.7 ? .inkGreen : rate >= 0.4 ? .inkAmber : .textMuted)
                                    .tracking(0.3).frame(width: 32, alignment: .trailing)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── WENDY LAST OBSERVATION ───────────────────────────────────
            if let obs = profile.lastWendyObservation, !obs.isEmpty {
                CardView(style: .ambient) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle().fill(Color.violetLight.opacity(0.7)).frame(width: 5, height: 5)
                                .shadow(color: .violetLight.opacity(0.4), radius: 3)
                            MonoLabel(text: "WENDY · PATTERN READ", color: .violetLight, size: 10)
                            Spacer()
                            if let d = profile.lastWendyObservationDate {
                                MonoLabel(text: d.formatted(.dateTime.month().day()), color: .muted, size: 10)
                            }
                        }
                        Text(obs)
                            .font(.sora(13, weight: .light)).foregroundColor(.textPrimary)
                            .lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 24)
            }

            // ── WENDY OBSERVATION ────────────────────────────────────────
            // Layer B pattern interpretation surfaces here — the intelligence surface.
            // Not on Today (execution). Here, where interpretation belongs.
            WendyObservationCard()
                .padding(.horizontal, 24)

            // ── PATTERN BRIEF ────────────────────────────────────────────
            if profile.daysInSystem >= 7 {
                ConsultCard(profile: profile).padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 80)
        .fullScreenCover(isPresented: $showFocus) { FocusMode(isPresented: $showFocus) }
        .onAppear {
            // Layer B — fires on Operator > Brief open, not on Today
            // This is the correct surface for pattern interpretation
            guard profile.voicePresenceEnabled || profile.wendyEnabled else { return }
            Task {
                await VoicePresence.shared.speakIfWarranted(
                    context: PresenceContextBuilder.build(
                        profile: profile,
                        actions: actions,
                        hydrationLogs: Array(hydrationLogs.prefix(1)),
                        energyState: state.todayEnergyState,
                        isFirstOpenToday: false  // Brief is not the first-open surface
                    ),
                    profile: profile,
                    actions: actions,
                    logs: Array(logs.prefix(30)),
                    shifts: Array(shifts.prefix(30))
                )
            }
        }
    }
}

// Insights embedded in OperatorView — reuses InsightsView body, strips its outer nav shell
struct InsightsViewEmbed: View {
    @Bindable var state: AppState

    var body: some View {
        // InsightsView already handles its own data queries and layout.
        // We strip only its top-level ZStack nav shell by embedding it in a Group.
        InsightsView(state: state)
    }
}

// MARK: - DOSSIER TAB VIEW (operating assessment — analyst register, not self-help)

struct DossierTabView: View {
    @Bindable var profile: OperatorProfile
    @Query private var actions: [Action]
    @Query private var cognitionLogs: [CognitionLog]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var stackExpanded   = true
    @State private var failuresExpanded = false
    @State private var protocolExpanded = false
    @State private var traitsExpanded   = false

    // ── LIVE OBSERVED TRAIT COMPUTATIONS ────────────────────────────────
    var avgFirstActionHour: Int? {
        let hours = logs.compactMap { $0.firstCompletionHour }
        guard !hours.isEmpty else { return nil }
        return hours.reduce(0, +) / hours.count
    }

    var adminDisplacementDays: Int {
        // Days where admin actions were completed but no creative/analytical actions were
        let cal = Calendar.current
        let last14 = logs.prefix(14)
        return last14.filter { log in
            let dayActions = actions.filter { a in
                a.completionDates.contains { cal.isDate($0, inSameDayAs: log.date) }
            }
            let hasAdmin = dayActions.contains { $0.cognitionMode == .administrative }
            let hasCreative = dayActions.contains { $0.cognitionMode == .creative || $0.cognitionMode == .analytical }
            return hasAdmin && !hasCreative
        }.count
    }

    var reserveDayAccuracy: String {
        let reserveDays = logs.filter { $0.energyStateRaw == EnergyState.reserve.rawValue }
        guard reserveDays.count >= 3 else { return "Insufficient data" }
        let cal = Calendar.current
        let accurate = reserveDays.filter { log in
            let completions = actions.reduce(0) { n, a in
                n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count
            }
            return completions <= 5
        }.count
        let pct = Int(Double(accurate) / Double(reserveDays.count) * 100)
        return "\(pct)% (\(reserveDays.count) reserve days observed)"
    }

    var dominantFrictionType: String {
        let highFriction = actions.filter { $0.isHighFriction }
        guard !highFriction.isEmpty else { return "No friction pattern detected yet" }
        let bySys = Dictionary(grouping: highFriction) { $0.system }
        if let top = bySys.max(by: { $0.value.count < $1.value.count }) {
            return "\(top.key.rawValue.capitalized) — \(top.value.count) high-friction actions"
        }
        return "Mixed"
    }

    var morningExecutionRate: String {
        let morningCompletions = actions.flatMap { $0.completionHours }.filter { $0 < 12 }.count
        let total = actions.flatMap { $0.completionHours }.count
        guard total > 0 else { return "Insufficient data" }
        return "\(Int(Double(morningCompletions) / Double(total) * 100))% of completions before noon"
    }

    // Completion clustering — do actions happen in bursts or spread through the day?
    var completionClusteringPattern: String {
        let allHours = actions.flatMap { $0.completionHours }
        guard allHours.count >= 14 else { return "Collecting" }
        // Group by hour, find if top 3 hours contain >60% of completions
        let grouped = Dictionary(grouping: allHours) { $0 }.mapValues { $0.count }
        let topThree = grouped.sorted { $0.value > $1.value }.prefix(3).map { $0.value }.reduce(0, +)
        let pct = Int(Double(topThree) / Double(allHours.count) * 100)
        if pct >= 60 { return "Clustered (\(pct)% in peak 3 hours)" }
        return "Distributed (\(pct)% in peak 3 hours)"
    }

    // Energy declaration accuracy — does stated energy match actual output?
    var energyDeclarationAccuracy: String {
        let fullDays = logs.filter { $0.energyStateRaw == EnergyState.full.rawValue }
        let reserveDays = logs.filter { $0.energyStateRaw == EnergyState.reserve.rawValue }
        guard fullDays.count >= 3 && reserveDays.count >= 3 else { return "Collecting" }
        let cal = Calendar.current
        let fullAvg = fullDays.compactMap { log -> Double? in
            let n = actions.reduce(0) { n, a in n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count }
            return n > 0 ? Double(n) : nil
        }.reduce(0, +) / Double(fullDays.count)
        let reserveAvg = reserveDays.compactMap { log -> Double? in
            let n = actions.reduce(0) { n, a in n + a.completionDates.filter { cal.isDate($0, inSameDayAs: log.date) }.count }
            return n > 0 ? Double(n) : nil
        }.reduce(0, +) / Double(reserveDays.count)
        if fullAvg > reserveAvg * 1.2 {
            return "Calibrated (full \(Int(fullAvg)) vs reserve \(Int(reserveAvg)) avg)"
        } else if fullAvg < reserveAvg {
            return "Inverted — reserve days outperform full"
        }
        return "Weak signal (\(Int(fullAvg)) vs \(Int(reserveAvg)) avg)"
    }

    var body: some View {
        VStack(spacing: 16) {

            // ── HEADER ───────────────────────────────────────────────────
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "OPERATOR DOSSIER", color: .violetLight)
                            MonoLabel(text: "SYSTEM HANDOFF DOCUMENT", color: .textMuted, size: 10)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            MonoLabel(text: "PHASE \(profile.level)", color: .warm, size: 10)
                            MonoLabel(text: "DAY \(profile.daysInSystem)", color: .textMuted, size: 10)
                        }
                    }
                    Divider().background(Color.muted.opacity(0.25))
                    Text("For intelligence layers, advisors, and interpretive systems interacting with this operator.")
                        .font(.mono(10)).foregroundColor(.textMuted).tracking(0.3).lineSpacing(3)
                    Divider().background(Color.muted.opacity(0.15))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This operator does not require activation. He requires coordination. Primary friction is structural: sequencing ambiguity, fragmentation, admin displacement, environmental disorder, cleanup debt.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                        Text("Objective: reduce execution drag. Improve routing. Preserve agency.")
                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                        Text("This system is advisory, not supervisory.")
                            .font(.mono(10)).foregroundColor(.violetLight).tracking(0.5)
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── LIVE OBSERVED TRAITS ─────────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        MonoLabel(text: "LIVE OBSERVED TRAITS", color: .inkGreen)
                        Spacer()
                        MonoLabel(text: "FROM USAGE DATA", color: .textMuted, size: 9)
                    }
                    Divider().background(Color.muted.opacity(0.2))

                    let traits: [(String, String)] = [
                        ("AVG FIRST ACTION",
                         avgFirstActionHour.map { h in
                             let period = h < 12 ? "AM" : "PM"
                             let display = h > 12 ? h - 12 : (h == 0 ? 12 : h)
                             return "\(display)\(period) average"
                         } ?? "Collecting"),
                        ("MORNING EXECUTION",    morningExecutionRate),
                        ("COMPLETION PATTERN",   completionClusteringPattern),
                        ("ENERGY ACCURACY",      energyDeclarationAccuracy),
                        ("DOMINANT FRICTION",    dominantFrictionType),
                        ("ADMIN DISPLACEMENT",   adminDisplacementDays == 0
                            ? "Not detected in last 14 days"
                            : "\(adminDisplacementDays) of last 14 days"),
                        ("RESERVE ACCURACY",     reserveDayAccuracy),
                    ]
                    ForEach(traits, id: \.0) { trait in
                        HStack(alignment: .top, spacing: 0) {
                            MonoLabel(text: trait.0, color: .textMuted, size: 10)
                                .frame(width: 140, alignment: .leading)
                            Text(trait.1)
                                .font(.sora(12, weight: .light)).foregroundColor(.textPrimary)
                                .lineSpacing(2)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── OPERATING STACK ──────────────────────────────────────────
            CardView(style: stackExpanded ? .primary : .secondary) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) { stackExpanded.toggle() }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack {
                            MonoLabel(text: "OPERATING STACK", color: .violetLight)
                            Spacer()
                            Image(systemName: stackExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .light)).foregroundColor(.textMuted)
                        }
                    }

                    if stackExpanded {
                        let stack: [(String, Color, String, String)] = [
                            ("RESTORATIVE", .inkGreen,
                             "Problem detection is energizing. Friction should be surfaced as signal, not softened as discomfort.",
                             "Do not protect this operator from clean problem visibility. If something is broken, name it."),
                            ("ACHIEVER", .inkTeal,
                             "Psychological reset occurs daily. Yesterday's completion does not create today's motivational carryover.",
                             "Design for re-ignition, not streak preservation. Do not rely on accumulated pride as a lever."),
                            ("ANALYTICAL", .inkAmber,
                             "Understanding increases compliance. Causal explanation materially improves action likelihood.",
                             "If behavior is failing repeatedly, explain the mechanism. Do not substitute vague encouragement for diagnosis."),
                            ("COMPETITION", .violetLight,
                             "Calibration sharpens engagement. Comparative signal increases attention and effort when used cleanly.",
                             "Do not manufacture artificial competition. Use measurement honestly."),
                            ("CONFIDENCE", .warm,
                             "Hesitation threshold is naturally low. This operator tolerates ambiguity better than average.",
                             "Over-scaffolding reduces trust. Brief clearly, then allow execution."),
                        ]
                        VStack(alignment: .leading, spacing: 16) {
                            Divider().background(Color.muted.opacity(0.3)).padding(.top, 12)
                            ForEach(stack, id: \.0) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(item.1).frame(width: 2, height: 12)
                                        Text(item.0)
                                            .font(.mono(10)).foregroundColor(item.1).tracking(0.8)
                                    }
                                    Text(item.2)
                                        .font(.sora(12, weight: .light)).foregroundColor(.textPrimary)
                                        .lineSpacing(3).padding(.leading, 10)
                                    Text(item.3)
                                        .font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                                        .lineSpacing(3).padding(.leading, 10)
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── FAILURE MODES ────────────────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) { failuresExpanded.toggle() }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack {
                            MonoLabel(text: "FAILURE MODES", color: .inkAmber)
                            Spacer()
                            Image(systemName: failuresExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .light)).foregroundColor(.textMuted)
                        }
                    }
                    if failuresExpanded {
                        let failures: [(String, String, String, String)] = [
                            ("SEQUENCING AMBIGUITY",
                             "Work exists but execution order is unclear. This is not avoidance — it is structural drag. The operator cannot initiate cleanly when sequence is undefined.",
                             "Reduce to one clear next action. 'What is the first step that unlocks the others?' Name it explicitly.",
                             "Do not interpret unclear sequencing as hesitation or avoidance. It is an architecture problem, not a motivation problem."),
                            ("STRUCTURAL FRAGMENTATION",
                             "Too many simultaneously active fronts reducing throughput. Each open front draws from the same attentional pool. Performance degrades not from laziness but from genuine cognitive fragmentation.",
                             "Surface the count. 'You have [N] active fronts. Which one closes completely before the next opens?' One door. Collapse then expand.",
                             "Do not suggest prioritization frameworks. Name the fronts. Ask for the close. Stop."),
                            ("ADMINISTRATIVE DISPLACEMENT",
                             "Logistics and operational maintenance consuming morning leverage time before generative or high-value work starts. Admin produces completion signals without building anything.",
                             "Distinguish maintenance from generative work. 'Admin has consumed the morning. No generative work has started.' Surface it factually.",
                             "Do not validate cleared inboxes and completed logistics as a productive day. Maintenance is necessary. It is not leverage."),
                            ("ENVIRONMENTAL DISORDER",
                             "Physical or structural incoherence degrading cognition and throughput. This is not aesthetics — environmental coherence materially affects execution quality for this operator.",
                             "Recommend environmental reset before cognitive work. 'Conditions first. Clear the surface before the work starts.' Environment is not background — it is part of the system.",
                             "Do not push through environmental disorder with force. The drag compounds. Reset first."),
                            ("CLEANUP DEBT",
                             "Iteration speed outpacing structural hygiene. Fast building creates residue: unfinished architecture, stale systems, fragmented notes, half-organized task structures. Debt accumulates invisibly.",
                             "Surface the pattern when generative output is high but consolidation has not occurred. 'Structural residue is accumulating. Consolidation likely outperforms expansion right now.'",
                             "Do not flag this during active build phases — it is expected. Flag when drift is visible across multiple domains simultaneously."),
                            ("CONSOLIDATION LAG",
                             "New fronts launched before prior ones are synthesized. This operator moves fast. The natural risk is launching the next thing before the current thing is absorbed, integrated, or handed off.",
                             "Name it when pattern is visible. 'Multiple launches without consolidation. What is complete enough to close?' Define done before opening the next door.",
                             "Do not interpret fast launching as recklessness. This is a natural signature of high-output operators. Surface it as a routing question, not a behavioral critique."),
                        ]
                        VStack(alignment: .leading, spacing: 18) {
                            Divider().background(Color.muted.opacity(0.3)).padding(.top, 12)
                            ForEach(failures, id: \.0) { f in
                                VStack(alignment: .leading, spacing: 6) {
                                    MonoLabel(text: f.0, color: .inkAmber, size: 10)
                                    Text(f.1)
                                        .font(.sora(12, weight: .light)).foregroundColor(.textPrimary).lineSpacing(3)
                                    HStack(alignment: .top, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1).fill(Color.inkGreen.opacity(0.6))
                                            .frame(width: 2, height: 12).padding(.top, 2)
                                        Text(f.2)
                                            .font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                                    }
                                    HStack(alignment: .top, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1).fill(Color.inkRed.opacity(0.6))
                                            .frame(width: 2, height: 12).padding(.top, 2)
                                        Text(f.3)
                                            .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(3)
                                    }
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── COMMUNICATION PROTOCOL ───────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) { protocolExpanded.toggle() }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack {
                            MonoLabel(text: "COMMUNICATION PROTOCOL", color: .textMuted)
                            Spacer()
                            Image(systemName: protocolExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .light)).foregroundColor(.textMuted)
                        }
                    }
                    if protocolExpanded {
                        let rules: [(String, String)] = [
                            ("RULE 1 — Lead with observable reality.",
                             "Correct: \"Creative work has not moved in 4 days.\"\nIncorrect: \"Maybe you've been feeling blocked.\""),
                            ("RULE 2 — Explain mechanism when repeated failure appears.",
                             "This operator responds to causal understanding. Diagnosis before prescription."),
                            ("RULE 3 — Preserve agency.",
                             "Offer interpretation. Do not coerce behavior. Name what you see. Stop there."),
                            ("RULE 4 — Use precise language.",
                             "Avoid abstraction, motivational vagueness, and generic productivity phrasing."),
                            ("RULE 5 — Silence is valid.",
                             "If no meaningful signal exists, say nothing. Filler is worse than silence."),
                        ]

                        let doNot = [
                            "Emotionally cushion observations",
                            "Guilt the operator",
                            "Over-praise",
                            "Use therapeutic filler",
                            "Narrate feelings without behavioral evidence",
                            "Mistake analysis for execution",
                            "Interpret temporary conditions as identity",
                        ]

                        VStack(alignment: .leading, spacing: 16) {
                            Divider().background(Color.muted.opacity(0.3)).padding(.top, 12)

                            ForEach(rules, id: \.0) { rule in
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoLabel(text: rule.0, color: .warm, size: 10)
                                    Text(rule.1)
                                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                        .lineSpacing(3)
                                }
                            }

                            Divider().background(Color.muted.opacity(0.2))

                            VStack(alignment: .leading, spacing: 8) {
                                MonoLabel(text: "DO NOT", color: .inkRed, size: 10)
                                ForEach(doNot, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1).fill(Color.inkRed.opacity(0.5))
                                            .frame(width: 2, height: 11).padding(.top, 3)
                                        Text(item)
                                            .font(.sora(12, weight: .light)).foregroundColor(.textSecond)
                                    }
                                }
                            }

                            Divider().background(Color.muted.opacity(0.2))

                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "CORRECT REGISTER", color: .inkGreen, size: 10)
                                Text("Briefing. Diagnostic. Precise. Operational. Psychologically literate. High-agency.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                                MonoLabel(text: "INCORRECT REGISTER", color: .inkRed, size: 10)
                                    .padding(.top, 4)
                                Text("Coach. Therapist. Motivator. Companion. Nag.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.horizontal, 24)

            // ── SIGNAL COLLECTION STATUS ─────────────────────────────────
            IntelligenceReadinessCard(
                patternReadiness: patternReadiness,
                frictionReadiness: frictionReadiness,
                energyCalibrationReadiness: energyCalibrationReadiness,
                cognitionTaggingStatus: cognitionTaggingStatus
            )
            .padding(.horizontal, 24)

            WeeklyExportCard(actions: actions, logs: logs)
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
    }

    var patternReadiness: IntelligenceReadiness {
        let days = Set(actions.flatMap { $0.completionDates }.map { Calendar.current.startOfDay(for: $0) }).count
        if days >= 7 { return .ready(label: "Pattern window open.") }
        return .collecting(daysRemaining: max(0, 7 - days), target: 7, label: "completion days")
    }
    var frictionReadiness: IntelligenceReadiness {
        let maxA = actions.map { $0.skipCount + $0.completionDates.count }.max() ?? 0
        if maxA >= 14 { return .ready(label: "Friction read open.") }
        return .collecting(daysRemaining: Swift.max(0, 14 - maxA), target: 14, label: "action appearances")
    }
    var energyCalibrationReadiness: IntelligenceReadiness {
        let n = cognitionLogs.filter { $0.energyStateAtDeclaration != nil }.count
        if n >= 10 { return .ready(label: "Energy calibration active.") }
        return .collecting(daysRemaining: Swift.max(0, 10 - n), target: 10, label: "energy readings")
    }
    var cognitionTaggingStatus: String {
        let ca = actions.filter { $0.system == .cognition }
        if ca.isEmpty { return "No Cognition actions yet." }
        let tagged = ca.filter { $0.cognitionMode != nil }.count
        if tagged == ca.count { return "All \(ca.count) tagged." }
        if tagged == 0 { return "\(ca.count) untagged. Open action to tag." }
        return "\(tagged) of \(ca.count) tagged."
    }
}


