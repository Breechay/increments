import SwiftUI

// MARK: - WANT DOC VIEWS
// You → Want segment — reading surface for direction document.
// Static prose. Not a tracking surface. Not interactive beyond open questions.
// Content source: What I Want v6 · compiled 2026
// Register: same as Doctrine — evening read, arm's-distance iPad, prose not bullets.
// Accent: violetLight (You tab primary) + warm (personal/relational content)
//
// File structure:
//   WantDocTabView          — root scroll, wires all sections
//   WantDocThesisBlock      — governing thesis, human + operator versions
//   WantDocFiveThings       — the five wants
//   WantDocCounterpart      — full counterpart specification
//   WantDocSignalProblem    — signal gap and how to close it
//   WantDocOpenQuestions    — five collapsible open questions
//   WantDocContent          — all prose strings (single source of truth)

// MARK: - Root

struct WantDocTabView: View {
    @Environment(\.appMetrics) private var metrics
    @Environment(\.youIPadReadingFocus) private var youReadingFocus
    @State private var expandedQuestion: UUID? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: metrics.sectionGap) {
                WantDocThesisBlock()
                WantDocFiveThings()
                WantDocCounterpart()
                WantDocSignalProblem()
                WantDocOpenQuestions(expandedQuestion: $expandedQuestion)
            }
            .youReadingContentWidth(metrics, focus: youReadingFocus)
            .padding(.horizontal, metrics.hPad)
            .padding(.top, metrics.scaledSize(8))
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Governing Thesis

struct WantDocThesisBlock: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Kicker
            MonoLabel(text: "DIRECTION · GOVERNING THESIS", color: .violetLight, size: 9)
                .padding(.bottom, metrics.scaledSize(16))

            // Human version — primary
            VStack(alignment: .leading, spacing: metrics.scaledSize(10)) {
                ForEach(WantDocContent.thesisHuman, id: \.self) { line in
                    HStack(alignment: .top, spacing: metrics.scaledSize(14)) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.violetLight.opacity(0.6), Color.warm.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 2)
                            .padding(.top, metrics.scaledSize(4))

                        Text(line)
                            .font(.sora(
                                metrics.isIPad ? metrics.youReadTitleSize * 0.72 : metrics.titleSize * 0.8,
                                weight: .semibold
                            ))
                            .foregroundColor(.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.bottom, metrics.scaledSize(18))

            // Operator version — secondary, muted
            VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                MonoLabel(text: "OPERATOR VERSION", color: .textMuted.opacity(0.6), size: 8)
                Text(WantDocContent.thesisOperator)
                    .font(.sora(metrics.isIPad ? metrics.youReadBodySize * 0.88 : metrics.bodySize * 0.92, weight: .light))
                    .foregroundColor(.textMuted.opacity(0.75))
                    .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(5))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(metrics.scaledSize(12))
            .background(Color.surface2.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: metrics.scaledSize(8)))
            .overlay(
                RoundedRectangle(cornerRadius: metrics.scaledSize(8))
                    .strokeBorder(Color.violetLight.opacity(0.08), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - The Five Things

struct WantDocFiveThings: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            DoctrineSectionHeader(
                kicker: "DIRECTION",
                title: "What I want — the five things",
                accent: .violetLight,
                isFirst: false
            )

            DoctrineSubsection(
                label: "1 · THE BASE",
                accent: .warm,
                paragraphs: WantDocContent.theBase
            )

            DoctrineSubsection(
                label: "2 · SOMEONE WHO CAN SEE YOU",
                accent: .violetLight,
                paragraphs: WantDocContent.theRecognition
            )

            DoctrineSubsection(
                label: "3 · THE BODY OF WORK",
                accent: .inkGreen,
                paragraphs: WantDocContent.theWork
            )

            DoctrineSubsection(
                label: "4 · MOBILITY",
                accent: .inkTeal,
                paragraphs: WantDocContent.theMobility
            )

            DoctrineSubsection(
                label: "5 · INTERESTING ROOMS",
                accent: .violetDim,
                paragraphs: WantDocContent.theRooms
            )
        }
    }
}

// MARK: - Counterpart Specification

struct WantDocCounterpart: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            DoctrineSectionHeader(
                kicker: "COUNTERPART",
                title: "The full specification",
                accent: .warm
            )

            DoctrineSubsection(
                label: "THE VEHICLE",
                accent: .warm,
                paragraphs: WantDocContent.vehicle
            )

            // The experience — twelve confirmed dimensions as a visual grid
            wantDimensionsBlock()

            DoctrineSubsection(
                label: "WHAT 'CORRECT' MEANS",
                accent: .warm,
                paragraphs: WantDocContent.whatCorrectMeans
            )

            DoctrineSubsection(
                label: "ON WITNESS — THE ONE THAT'S DIFFERENT",
                accent: .violetLight,
                paragraphs: WantDocContent.onWitness
            )

            DoctrineSubsection(
                label: "THE SEEKING BEHAVIOR",
                accent: .warm,
                paragraphs: WantDocContent.seekingBehavior
            )

            DoctrineSubsection(
                label: "THE SLOW-REVEAL CALIBRATION",
                accent: .inkTeal,
                paragraphs: WantDocContent.slowReveal
            )

            DoctrineSubsection(
                label: "THE OBSERVATIONAL DOMINANCE EDGE CASE",
                accent: .inkAmber,
                paragraphs: WantDocContent.observationalDominance
            )
        }
    }

    @ViewBuilder
    private func wantDimensionsBlock() -> some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(10)) {
            MonoLabel(text: "THE EXPERIENCE — ALL DIMENSIONS CONFIRMED", color: .warm.opacity(0.7), size: 9)
                .padding(.bottom, metrics.scaledSize(4))

            // Two-column grid of the twelve dimensions
            let dims = WantDocContent.confirmedDimensions
            let half = (dims.count + 1) / 2

            HStack(alignment: .top, spacing: metrics.scaledSize(16)) {
                VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
                    ForEach(dims.prefix(half), id: \.self) { dim in
                        dimensionRow(dim)
                    }
                }
                VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
                    ForEach(dims.dropFirst(half), id: \.self) { dim in
                        dimensionRow(dim)
                    }
                }
            }

            Text(WantDocContent.dimensionsNote)
                .font(.sora(metrics.isIPad ? metrics.youReadBodySize * 0.88 : metrics.bodySize * 0.92, weight: .light))
                .foregroundColor(.textSecond)
                .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(5))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, metrics.scaledSize(6))
        }
        .padding(metrics.cardPad)
        .background(
            ZStack {
                Color.surface2
                LinearGradient(
                    colors: [Color.warm.opacity(0.04), Color.clear],
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 0.3)
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: metrics.cardRadius)
                .strokeBorder(Color.white.opacity(0.035), lineWidth: 0.5)
        )
        .shadow(color: Color.bgBase.opacity(0.5), radius: 6, x: 0, y: 3)
    }

    private func dimensionRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: metrics.scaledSize(8)) {
            Circle()
                .fill(Color.warm.opacity(0.5))
                .frame(width: metrics.scaledSize(4), height: metrics.scaledSize(4))
                .padding(.top, metrics.scaledSize(5))
            Text(text)
                .font(.sora(metrics.isIPad ? metrics.youReadBodySize : metrics.bodySize, weight: .light))
                .foregroundColor(.textPrimary.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Signal Problem

struct WantDocSignalProblem: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            DoctrineSectionHeader(
                kicker: "SIGNAL",
                title: "The signal problem — named precisely",
                accent: .violetLight
            )

            DoctrineSubsection(
                label: "THE PRECISE DESCRIPTION",
                accent: .violetLight,
                paragraphs: WantDocContent.signalPreciseDescription
            )

            DoctrineSubsection(
                label: "THE ENTERABLE WORLD PROBLEM",
                accent: .violetLight,
                paragraphs: WantDocContent.enterableWorld
            )

            DoctrineSubsection(
                label: "HOW TO CLOSE THE GAP",
                accent: .inkGreen,
                paragraphs: WantDocContent.closeTheGap
            )
        }
    }
}

// MARK: - Open Questions

struct WantDocOpenQuestions: View {
    @Environment(\.appMetrics) private var metrics
    @Binding var expandedQuestion: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DoctrineSectionHeader(
                kicker: "OPEN",
                title: "What remains open",
                accent: .inkAmber
            )

            // Warning block — this stays
            warningBlock()
                .padding(.bottom, metrics.sectionGap)

            Text("Not problems to solve. Questions the operating system doesn't have a tab for. Hold without forcing.")
                .font(.sora(metrics.isIPad ? metrics.youReadBodySize : metrics.bodySize, weight: .light))
                .foregroundColor(.textMuted)
                .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(5))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, metrics.sectionGap)

            VStack(spacing: 0) {
                ForEach(WantDocContent.openQuestions) { question in
                    openQuestionRow(question)
                }
            }
        }
    }

    @ViewBuilder
    private func warningBlock() -> some View {
        HStack(alignment: .top, spacing: metrics.scaledSize(12)) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: metrics.scaledSize(12), weight: .light))
                .foregroundColor(.inkAmber.opacity(0.7))
                .padding(.top, metrics.scaledSize(2))

            Text("Maps can become substitutes for lived exposure. At some point the next useful move is not refinement — it's exposure.")
                .font(.sora(metrics.isIPad ? metrics.youReadBodySize * 0.92 : metrics.bodySize, weight: .light))
                .foregroundColor(.inkAmber.opacity(0.85))
                .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(5))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(metrics.scaledSize(12))
        .background(Color.inkAmber.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: metrics.scaledSize(8)))
        .overlay(
            RoundedRectangle(cornerRadius: metrics.scaledSize(8))
                .strokeBorder(Color.inkAmber.opacity(0.12), lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private func openQuestionRow(_ question: WantDocOpenQuestion) -> some View {
        let isExpanded = expandedQuestion == question.id

        Button(action: {
            withAnimation(.easeOut(duration: 0.22)) {
                expandedQuestion = isExpanded ? nil : question.id
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: metrics.scaledSize(12)) {
                    Rectangle()
                        .fill(isExpanded ? Color.inkAmber : Color.muted.opacity(0.35))
                        .frame(width: 2)
                        .frame(minHeight: metrics.scaledSize(44))
                        .animation(.easeOut(duration: 0.2), value: isExpanded)

                    VStack(alignment: .leading, spacing: metrics.scaledSize(5)) {
                        Text(question.question)
                            .font(.sora(
                                metrics.isIPad ? metrics.youReadBodySize : metrics.bodySize,
                                weight: isExpanded ? .medium : .light
                            ))
                            .foregroundColor(isExpanded ? .textPrimary : .textSecond.opacity(0.85))
                            .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(4))
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
                            .fill(Color.inkAmber.opacity(0.12))
                            .frame(height: 0.5)
                            .padding(.leading, metrics.scaledSize(14))

                        Text(question.body)
                            .font(.sora(
                                metrics.isIPad ? metrics.youReadBodySize : metrics.bodySize,
                                weight: .light
                            ))
                            .foregroundColor(.textPrimary.opacity(0.88))
                            .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(6))
                            .fixedSize(horizontal: false, vertical: true)
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
}

// MARK: - Open Question model

struct WantDocOpenQuestion: Identifiable {
    let id = UUID()
    let question: String
    let body: String
}

// MARK: - Content strings (single source of truth)
// Update this when What I Want version changes.
// Update WendyPrompts in IntelligenceLayer.swift at the same time.

enum WantDocContent {

    // MARK: Governing thesis

    static let thesisHuman: [String] = [
        "Build what feels true.",
        "Make it easier to enter.",
        "Stay curious longer than certainty.",
        "Move toward expansion, not avoidance.",
        "Seek recognition, not applause."
    ]

    static let thesisOperator: String =
        "Build the authored base. Make the world more permeable. Stay open longer than your first classification. Use movement as multiplication, not escape. Find witness, not merely admiration."

    // MARK: The five things

    static let theBase: [String] = [
        "Hideout — every corner brought to internal standard. Garden, kitchen, bathroom, all of it. Refined. Alive. Intentional. Grown over time, not manufactured instantly. The process is enjoyable because it's lived in — authorship, not perfectionism.",
        "The structure underneath: Rooting → authorship → optional movement. Financially: healthy enough that constant physical presence isn't required. Freedom of movement while the base holds itself.",
        "What this requires: every physical corner brought to standard, sequenced not rushed. Economics crossing the threshold where it runs without daily presence. The distinction between managing it and inhabiting it — the latter is what's wanted."
    ]

    static let theRecognition: [String] = [
        "Not merely a counterpart. Not merely attraction. Not merely partnership. Something closer to: ah. there you are.",
        "The want isn't symmetry of architecture — it's sufficient resolution to perceive yours accurately, and warmth enough to stay in it. Someone perceptive enough to read the whole system, warm enough to remain, alive enough to still surprise you.",
        "Full specification in the section below."
    ]

    static let theWork: [String] = [
        "FORM, Forge, INCREMENTS, RunCards, Hideout — the same operating philosophy in different domains: intelligence layers over physical and cognitive performance. The want: the whole thing becoming legible as a coherent body of work. Authored. Unmistakably yours.",
        "Current bottleneck: distribution. Same gap across everything. Work exists. Signal isn't reaching the right people. That's the unlock — not more building."
    ]

    static let theMobility: [String] = [
        "Not escape. Base first — then movement. Travel, explore other cultures, learn, connect. The nervous system is environment-responsive.",
        "Movement as multiplication, not escape. The cities are multipliers, not the answer. Using them as the answer produces a closed loop: every current room gets mentally disqualified in advance, the environment confirms the prior, nothing changes. Geography increases encounter probability but doesn't fix signal legibility.",
        "Miami pressure-test: the structural diagnosis may be accurate AND confirmation bias may also be operating simultaneously. If the ambient signal gets classified as insufficient too early, scanning stops before the rare signal surfaces."
    ]

    static let theRooms: [String] = [
        "The nutrient set: intellectual novelty, psychological density, cultural seriousness, strange collisions, people who are sharp and curious and don't perform.",
        "Miami feeds: beauty, bodies, energy, physical culture. Miami underfed: intellectual novelty, psychological density, genuine strange collisions. The boredom is structural, not personal.",
        "Environments worth scouting when the base allows: Berlin, Buenos Aires, Lisbon/Porto, Mexico City, Tokyo, London, Paris. These are multipliers — environmental heuristics, not salvation destinations."
    ]

    // MARK: Counterpart

    static let vehicle: [String] = [
        "Intellectually similar. Sharp. Curious. Adventurous. Mischievous. Capable. Fit. Attractive. Charming. Fun.",
        "Not eventually compatible — immediately legible. Not identical. The processing is recognizable on contact. Low-friction cognition from the first real exchange."
    ]

    static let confirmedDimensions: [String] = [
        "Challenge",
        "Expansion",
        "Companionship",
        "Erotic polarity",
        "Co-conspiracy",
        "Witness",
        "Play",
        "Mutual admiration",
        "Adventure partner",
        "Psychological intimacy",
        "Intellectual sparring",
        "Calm home base"
    ]

    static let dimensionsNote: String =
        "Not a single-axis relationship. A fully integrated bond. This raises the bar — but also explains the selectivity. Most people don't carry all of this. The ones who do are rare and immediately recognizable."

    static let whatCorrectMeans: [String] = [
        "Low-friction cognition. Mutual curiosity. Fast mutual recognition. No performance layer. Ease without simplification. Shared appetite for exploration. Attraction without chaos.",
        "Not attractive. Not partner. Not chemistry. Correct. That word is doing the real work."
    ]

    static let onWitness: [String] = [
        "Witness is not in the same category as challenge, erotic polarity, or intellectual sparring. Those are things you bring to each other. Witness is something else.",
        "Part of what witness means: someone seeing the operator cost, not just the output. The cognitive machinery. The restraint. The pressure. The overfunctioning. The fatigue alongside the beauty. And remaining.",
        "But that framing is still operator-centric. Still noble. Still curated.",
        "Real witness also means being seen in the less constructed material: contradiction, softness, uncertainty, irrationality, desire that doesn't have a reason yet, unfinishedness, non-competence. The moments when the system isn't running well and you haven't figured it out yet. Those too. And remaining.",
        "That's different from admiration. Admiration sees the output and responds to it. Witness sees what the output costs and also sees what precedes the output — the mess before the architecture — and stays anyway.",
        "This dimension is probably the least resolved of the counterpart spec. It's worth keeping as an open question rather than a checked box."
    ]

    static let seekingBehavior: [String] = [
        "Solitude until alignment. Not loneliness — genuine preference for solitude over incorrect company.",
        "The festival pattern: this environment contains possible signal; let me move through it until I find resonance. Branching away from the group. Not to escape — to scan."
    ]

    static let slowReveal: [String] = [
        "Fast mutual recognition is the right quality indicator. But some high-quality people are also protective of signal. They're scanning too. They're also calibrated against low-yield interactions.",
        "The distinction: slow reveal accumulates depth with each interaction. Low ceiling produces more contact, same information.",
        "The test: ask a second question. First question is curiosity. Second question is interest — it says: I was inside what you said. If the conversation deepens, slow reveal. If it doesn't, ceiling.",
        "Hold fast mutual recognition as a quality indicator but not necessarily a first-encounter verdict. Two to three encounters before deciding on slow-reveal people."
    ]

    static let observationalDominance: [String] = [
        "Rich models of people accumulate quickly. They feel seen. But they have less material on you. From the other side: being understood by someone who isn't giving anything back — intimate but destabilizing.",
        "The fix: when you state a hypothesis about someone's operating logic, follow it with one sentence of what makes you say so. Brief. Reveals your reasoning without requiring disclosure. Levels the platform."
    ]

    // MARK: Signal problem

    static let signalPreciseDescription: [String] = [
        "Beautiful closed system. The signal reads: finished / authored / high-agency / low need.",
        "This attracts admiration. It doesn't necessarily attract approach — especially from the exact people you want, who are themselves selective and careful readers who won't push on a closed door.",
        "What's legible: authorship, precision, restraint, competence across physical/cognitive/operational domains, high-agency calm, solitude by preference.",
        "What's missing or obscured: the door — the signal reads complete, not visibly seeking. Play — exists in Breechay mode, not consistently surfaced. Curiosity toward people, not systems. Erotic polarity — internal signal strong, externally muted. The warmth inside the restraint.",
        "Even the openness is structured. Even this document is architected openness. Which is elegant — but elegance can suppress permeability."
    ]

    static let enterableWorld: [String] = [
        "The world exists. The work is real. The operating sensibility is coherent. The gap: it doesn't yet read as enterable. Someone encountering the work sees a fully formed operator running sealed systems. Accurate — but accidentally communicates not seeking rather than seeking alignment, not volume."
    ]

    static let closeTheGap: [String] = [
        "Write one thing. Not product content — an actual observation about something you think is true. One piece reveals more than 200 posts. The mechanism: lets the right people find you before meeting you, already calibrated.",
        "Add one unguarded moment to distribution. Not vulnerability — texture. One frame from Hideout before it opens. A problem you haven't solved. If one of the 7-shot film frames includes you — not staged, just present — the signal changes.",
        "Show mechanism, not artifact. In content: what changed and why, not what exists. 'I removed X because Y' is more interesting than 'X now works.' Decision logic, not feature announcements.",
        "The second question in interactions. First question is curiosity. Second question is interest — it says I was inside what you said. Most people stop at one. Don't."
    ]

    // MARK: Open questions

    static let openQuestions: [WantDocOpenQuestion] = [
        WantDocOpenQuestion(
            question: "What does witness actually feel like for you?",
            body: "The hardest item in the counterpart spec to name precisely. Admiration sees the output. Witness sees the operator cost and also sees what precedes the output — the mess before the architecture. The contradiction, the softness, the irrationality, the desire that doesn't have a reason yet. Being seen in that material, not just the constructed version. And someone staying. That's probably the least resolved dimension here and worth keeping open."
        ),
        WantDocOpenQuestion(
            question: "Are you screening for true incompatibility, or sometimes screening out slower-blooming compatibility?",
            body: "The calibration question. Fast mutual recognition is real and right. The question is whether the speed requirement occasionally closes the scan before depth could accumulate. Not a reason to lower standards — a precision question about mechanism. The test is whether depth accumulates over 2-4 interactions, not whether the first contact produces a spark."
        ),
        WantDocOpenQuestion(
            question: "Is Miami structurally insufficient, or are you sometimes confirming that prior by stopping the scan early?",
            body: "Both can be simultaneously true. The structural diagnosis may be accurate and confirmation bias may also be operating. If the ambient signal gets classified too early, you stop transmitting curiosity, and the environment confirms the prior. Worth pressure-testing. The rare person who is there never gets found if the scan has already closed."
        ),
        WantDocOpenQuestion(
            question: "What does Brice want that Breechay doesn't need?",
            body: "Breechay trusts improvisation, doesn't need external confirmation. Brice wants certainty that the system holds. But need and want aren't the same word. The gap between them is probably where the most honest answer to this whole document lives. Infrastructure vs expression — Brice builds the conditions, Breechay inhabits them. But what does Brice want that the infrastructure, once built, still won't provide?"
        ),
        WantDocOpenQuestion(
            question: "How much unpredictability can you welcome in the domains you care most about?",
            body: "The wants are clear: authored base, stable economics, beautiful systems, coherent work, meaningful recognition. Understandable. But love, friendship, creative collision, and discovery require genuine uncertainty — not dysfunction, but actual unpredictability. Things that arrive outside the architecture and change something. The question isn't whether you can tolerate that. It's whether you can welcome it."
        )
    ]
}
