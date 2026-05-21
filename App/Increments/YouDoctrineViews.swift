import SwiftUI
import SwiftData

// MARK: - You → Doctrine (evening read · iPad-first)
// Execution: Signal + Today. Night read: Doctrine + Manual + Ventures (live signal).

struct YouDoctrineTabView: View {
    @Environment(\.appMetrics) private var metrics
    @State private var section = 0

    private let sectionTitles = ["This season", "Plant · log · adjust", "Night read", "Night read"]
    private let sectionKickers = ["OPERATOR", "DISTRIBUTION", "HIDEOUT MIAMI", "FORM"]

    var body: some View {
        VStack(spacing: 0) {
            if !metrics.isIPad {
                VStack(alignment: .leading, spacing: metrics.scaledSize(3)) {
                    MonoLabel(text: sectionKickers[section], color: .textMuted, size: 9)
                    Text(sectionTitles[section])
                        .font(.sora(metrics.headlineSize, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, metrics.hPad)
                .padding(.top, metrics.scaledSize(12))
                .padding(.bottom, metrics.scaledSize(10))
                .animation(.easeOut(duration: 0.2), value: section)
            }

            segmentControl(["Operator", "Distribution", "Hideout", "FORM"], selected: $section)
                .padding(.horizontal, metrics.hPad)
                .padding(.top, metrics.isIPad ? metrics.scaledSize(4) : 0)
                .padding(.bottom, metrics.scaledSize(2))

            LinearGradient(
                colors: [Color.clear, Color.muted.opacity(0.15), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 0.5)
            .padding(.horizontal, metrics.hPad)
            .padding(.bottom, metrics.scaledSize(4))

            ScrollView(showsIndicators: false) {
                Group {
                    switch section {
                    case 0: DoctrineOperatorReading()
                    case 1: DoctrineDistributionReading()
                    case 2: DoctrineHideoutReading()
                    default: DoctrineFORMReading()
                    }
                }
                .id(section)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.25), value: section)
                .adaptiveContentWidth(metrics)
                .padding(.bottom, 80)
            }
        }
    }
}

// MARK: - Reading components (shared with Ventures · Manual · Intel)

struct DoctrineSectionHeader: View {
    let kicker: String
    let title: String
    let accent: Color
    var isFirst: Bool = false
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
            Text(kicker)
                .font(.mono(metrics.monoSmall))
                .foregroundColor(accent.opacity(0.7))
                .tracking(1.5)
            Text(title)
                .font(.sora(metrics.titleSize, weight: .semibold))
                .foregroundColor(.textPrimary)
            Rectangle()
                .fill(accent.opacity(0.25))
                .frame(width: metrics.scaledSize(40), height: 1)
        }
        .padding(.top, isFirst ? metrics.scaledSize(8) : metrics.sectionGap)
        .padding(.bottom, metrics.blockSpacing)
    }
}

struct DoctrineSubsection: View {
    let label: String
    let accent: Color
    let paragraphs: [String]
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.scaledSize(4)) {
            VStack(alignment: .leading, spacing: metrics.scaledSize(6)) {
                Text(label)
                    .font(.mono(metrics.monoSmall))
                    .foregroundColor(accent.opacity(0.7))
                    .tracking(1.2)
                Rectangle()
                    .fill(accent.opacity(0.18))
                    .frame(height: 0.5)
            }
            .padding(.bottom, metrics.scaledSize(4))

            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, text in
                    DoctrineProseBlock(text: text, accent: accent)
                }
            }
        }
        .padding(metrics.cardPad)
        .background(
            ZStack {
                Color.surface2
                LinearGradient(
                    colors: [accent.opacity(0.04), Color.clear],
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
        .padding(.bottom, metrics.sectionGap)
    }
}

struct DoctrineProseBlock: View {
    let text: String
    let accent: Color
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        HStack(alignment: .top, spacing: metrics.scaledSize(14)) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.5), accent.opacity(0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1.5)
                .padding(.top, metrics.scaledSize(5))

            Text(text)
                .font(.sora(metrics.bodySize, weight: .light))
                .foregroundColor(.textPrimary.opacity(0.92))
                .lineSpacing(metrics.scaledSize(6))
                .tracking(0.1)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Bucket 1 + 4 — Operator

struct DoctrineOperatorReading: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            DoctrineSectionHeader(
                kicker: "OPERATOR",
                title: "This season",
                accent: .violetLight,
                isFirst: true
            )

            DoctrineSubsection(
                label: "INJURY · OPERATING CONDITION",
                accent: .violetLight,
                paragraphs: [
                    "You are injured — running suspended. This is not a disruption to the season. It is the season's operating condition. The schedule, the content approach for FORM, the coaching role on Tuesdays and Saturdays — all of these are shaped around the injury, not despite it.",
                    "The injury removes one thing: personal running footage and demos. It opens something more valuable: the intelligence layer of FORM becomes visible in a way it would not be if you were running. What the system does when the athlete is not running is rarer content than any run recap."
                ]
            )

            DoctrineSubsection(
                label: "RESERVE VS COMPRESSED",
                accent: .violetLight,
                paragraphs: [
                    "Reserve is a legitimate operating state. The nervous system needs it. A Reserve day declared honestly produces better decisions and better recovery than a forced full day. Compressed is different — external constraints reduced the window, not the capacity.",
                    "The failure mode is misreading Compressed as Reserve and standing down when forward motion was available. The other failure is misreading Reserve as laziness and pushing through when the system needed to stop.",
                    "The diagnostic question: is the constraint coming from inside — capacity genuinely limited — or outside — schedule reduced the window? They require different responses."
                ]
            )

            DoctrineSubsection(
                label: "TUESDAY",
                accent: .inkGreen,
                paragraphs: [
                    "Tuesday 6AM track is not optional social energy. It is the highest-leverage recurring moment of the week — two athletes on two programs, threshold work, Sony capturing the session, one ledger sentence after.",
                    "It is coaching, content, and distribution in one block. Missing Tuesday is not a scheduling casualty. It is a compounding loss."
                ]
            )

            DoctrineSubsection(
                label: "SCHEDULE SHAPE",
                accent: .warm,
                paragraphs: [
                    "Monday block before Hideout opens — content discipline runs before the operational day begins, so it cannot be displaced. Friday signal log after close — the week's seeds are reviewed when the week is complete, not mid-stream.",
                    "Tuesday and Saturday are athlete sessions. Wednesday through Sunday are Hideout operations. The shape is not arbitrary. Each anchor is placed where it can hold without competing with the other demands of the day."
                ]
            )

            DoctrineSubsection(
                label: "TRUST",
                accent: .violetLight,
                paragraphs: [
                    "Trust increases when observations are accurate, silence is respected when there is nothing to say, interventions are specific, and confidence reflects evidence.",
                    "Trust decreases when obvious things are narrated, generic coaching appears, assistant behavior emerges, or weak observations are surfaced to fill space.",
                    "The register is briefing and diagnostic — not coach, not therapist, not companion. A presence that notices. When something is wrong, it names it. When nothing is wrong, it says nothing."
                ]
            )

            DoctrineSubsection(
                label: "BUY-IN · MECHANISM",
                accent: .violetLight,
                paragraphs: [
                    "You do not need motivation. You need mechanism. Understanding why a protocol is shaped the way it is materially increases compliance — not because you need to be convinced, but because causal structure produces confidence in the action.",
                    "This is why action notes contain mechanism. It is adherence infrastructure, not verbosity.",
                    "The limit: this mechanic does not require monitoring infrastructure, progress displays, or accumulation counters. You already trust the science. Seeing reps accumulate does not increase adherence. It adds cognitive weight without value."
                ]
            )

            DoctrineSectionHeader(
                kicker: "OPERATOR",
                title: "Why distribution is the gap",
                accent: .violetLight
            )

            DoctrineSubsection(
                label: "STRUCTURAL DIAGNOSIS",
                accent: .violetLight,
                paragraphs: [
                    "Distribution is the named gap across the ventures — not because the products are weak, not because discipline is missing, and not because there is psychological resistance to visibility. The products consistently outpace the acquisition systems.",
                    "Distribution is a trained operating discipline that was never part of how these ventures were built. The building instinct is native. The distribution instinct is not. This is a skill gap, not a character gap. It closes through reps, not through motivation."
                ]
            )

            DoctrineSubsection(
                label: "FOUR FRICTIONS",
                accent: .inkAmber,
                paragraphs: [
                    "First: the builder's reward loop. Building produces immediate, legible signal. Distribution produces delayed, noisy signal — a seed planted in week two might produce signal in week eight, or never. Distribution reps feel unrewarding in the short term even when they are working correctly.",
                    "Second: the quality standard. Distribution content that meets your standard takes longer than the block allows. The fix is the fixed format — the 7-shot sequence, assembly doctrine, caption preset — which makes the standard achievable inside the time constraint.",
                    "Third: the product-first default. When in doubt, you return to product work. Product work is generative and familiar. Distribution work is unfamiliar and feels less productive than it is. The Monday block exists to prevent this displacement — distribution runs before the operational day begins.",
                    "Fourth: not knowing what you do not know yet. Distribution methodology was not practiced at scale. The Friday log and the 8-week read answer which seeds work through data rather than pre-existing knowledge."
                ]
            )

            DoctrineSubsection(
                label: "WHY PLANT · LOG · ADJUST",
                accent: .inkGreen,
                paragraphs: [
                    "Plant, log, adjust matches your operating profile. Plant: a fixed protocol removes quality and decision friction. Log: a lightweight signal log removes the need to pre-know which seeds work. Adjust: one change after enough data removes the temptation to change everything when early signal is low.",
                    "The system is not a compromise. It is the correct design for someone who trusts the science, understands that seeds take time, and does not need intermediate feedback to stay with the discipline."
                ]
            )

            DoctrineSubsection(
                label: "BUILDING THE MUSCLE",
                accent: .violetLight,
                paragraphs: [
                    "The distribution muscle develops through reps, not through planning. The first Monday block is a rep. The first Tuesday ledger sentence is a rep. The first Friday log is a rep.",
                    "Eight weeks of these reps is when the data becomes readable. Twelve weeks is when the methodology exists in your body rather than only in a spec.",
                    "Follow the protocol, log the signal, read the data at week eight. The muscle will be there."
                ]
            )
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.top, metrics.scaledSize(8))
    }
}

// MARK: - Distribution (existing cadence)

struct DoctrineDistributionReading: View {
    @Environment(\.appMetrics) private var metrics
    @Query(sort: \DecisionLedger.createdAt, order: .reverse) private var ledgerEntries: [DecisionLedger]
    @AppStorage("forge_v1_gate_passed") private var forgeGateCleared = true
    @AppStorage("forge_post_gate_mondays_completed") private var forgePostGateMondaysCompleted = 3

    private var ventureThisWeek: AppContentVenture {
        DistributionCalendar.appContentVenture(
            for: DistributionCalendar.mondayStart(),
            forgeGateCleared: forgeGateCleared,
            forgePostGateMondaysCompleted: forgePostGateMondaysCompleted
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            DoctrineSectionHeader(
                kicker: "DISTRIBUTION",
                title: "Plant · log · adjust",
                accent: .inkGreen,
                isFirst: true
            )

            DoctrineSubsection(
                label: "THREE JOBS",
                accent: .inkGreen,
                paragraphs: [
                    "Monday block plants Hideout and one app-content clip before the café opens — fixed sequence, no decisions at execution time.",
                    "Mid-week you append one sentence to the Decision Ledger when something real happened. Friday after close you log eight to ten minutes of signal.",
                    "After eight weeks of Friday logs, read them once and change one thing if warranted. No progress UI, no dot counters, no motivational copy."
                ]
            )

            DoctrineSubsection(
                label: "CONTENT PRIMITIVE",
                accent: .inkGreen,
                paragraphs: [
                    "One decision, one outcome, one sentence. Outsider-legible — a stranger understands what happened without knowing the product.",
                    "Not a tutorial, not a highlight reel. Your ledger entries become the examples once you have three or more."
                ]
            )

            if ledgerEntries.count >= 3 {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                        MonoLabel(text: "YOUR RECENT LINES", color: .inkGreen, size: 9)
                        ForEach(ledgerEntries.prefix(5)) { entry in
                            DoctrineProseBlock(
                                text: "“\(entry.fragment)” — \(entry.venture.label) · \(entry.dateLabel)",
                                accent: .inkGreen
                            )
                        }
                    }
                }
                .padding(.bottom, metrics.sectionGap)
            }

            DoctrineSubsection(
                label: "WEEKLY CADENCE",
                accent: .warm,
                paragraphs: [
                    "Monday — Hideout block. Tuesday — FORM threshold seed. Saturday — FORM long run seed. Friday — signal log.",
                    "This week's app-content venture on Monday is \(ventureThisWeek.label). Tim, Tinius, and Cole are Forge athletes — not FORM Tuesday or Saturday capture subjects.",
                    "When signal is working you will have ledger lines before most Mondays and Friday logs that name real attributions."
                ]
            )

            DoctrineSubsection(
                label: "TUESDAY · SATURDAY",
                accent: .inkGreen,
                paragraphs: [
                    "Threshold Tuesdays: 6AM track, Simon on Speed Emergence, Julien on Hyrox Running. Sony carries scene; phone carries one athlete's Today or Ledger — one sentence after.",
                    "Saturday long runs: same athletes, pre-dawn, bike pacing. Capture what Today shows that week. One ledger sentence when the run showed something worth keeping."
                ]
            )
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.top, metrics.scaledSize(8))
    }
}

// MARK: - Bucket 2 — Hideout night read

struct DoctrineHideoutReading: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            DoctrineSectionHeader(
                kicker: "HIDEOUT MIAMI",
                title: "Night read",
                accent: .warm,
                isFirst: true
            )

            DoctrineSubsection(
                label: "FOUR MODES · ONE ASSET",
                accent: .warm,
                paragraphs: [
                    "Hideout operates as four different businesses depending on the day and the season.",
                    "Neighborhood café: the daily anchor, regulars, the outdoor terrace, the reputation that took six years to build.",
                    "Distribution vehicle: every Monday block, every GBP post, every card in a building lobby is Hideout operating as reach.",
                    "Recovery asset: the solo experiment tests the operational floor without staff — what the business is at its minimum.",
                    "Eventually, brand: the name and reputation that make the other ventures legible. Which mode is running today changes what decisions are correct."
                ]
            )

            DoctrineSubsection(
                label: "NERVOUS SYSTEM ECONOMICS",
                accent: .warm,
                paragraphs: [
                    "Every interaction at Hideout costs something from your nervous system — and produces something. High-volume throughput days generate revenue but draw from the same attentional and social pool that coaching, building, and thinking draw from.",
                    "The solo experiment makes this visible: without staff, every transaction is a direct exchange. The question is not only whether you hit the revenue target but what hitting it cost, and whether the cost was worth it.",
                    "Some shifts are worth less than they look. Some are worth more. Nervous system economics is the accounting standard revenue tracking does not do."
                ]
            )

            DoctrineSubsection(
                label: "TWO TRUE LEVERS",
                accent: .warm,
                paragraphs: [
                    "Everything in Hideout distribution traces back to two mechanisms: threshold conversion and first clean recurring pickup.",
                    "Threshold conversion is the gap between people who walk past and people who walk in — column boards, Monday content, GBP presence all operate on this gap.",
                    "First clean recurring pickup is when a first-timer returns without being prompted — marketing becomes retention, which is a better problem. Both levers compound. Neither is fast. Seeds planted now build the memory that produces the second visit in three weeks."
                ]
            )

            DoctrineSubsection(
                label: "THRESHOLD BOARDS",
                accent: .warm,
                paragraphs: [
                    "The column boards are not signage. They are a threshold decision surface. The person at the corridor entrance has already noticed the café. The board resolves hesitation — a reason that costs nothing and risks nothing.",
                    "FIRST TIME? START HERE does not sell the café. It removes the barrier to entering.",
                    "Five states at the threshold: unaware — content and GBP work here. Aware and hesitant — boards work here. Curious but uncertain — menu and first visual do the work. Decided — execution. Returning — the recurring pickup problem.",
                    "Most distribution effort should target states two and three, not state one."
                ]
            )

            DoctrineSubsection(
                label: "PARTNERSHIP SEQUENCE",
                accent: .warm,
                paragraphs: [
                    "Expansive Biscayne is first: professional audience, high caffeine need, one warm introduction rather than cold outreach.",
                    "The salon next door is second: relationship already warm, staff script in place, one free drink per week already running.",
                    "Watermarc is pacing: building relationship warm, cards in progress — a slow seed that compounds over months, not weeks.",
                    "Each partnership has a different time horizon and mechanism. They are not interchangeable."
                ]
            )

            DoctrineSubsection(
                label: "SIGNAL WITHOUT A DASHBOARD",
                accent: .inkGreen,
                paragraphs: [
                    "You will know seeds are working when someone mentions the board without being asked, someone redeems a Watermarc card, someone says they found you on Google, or a first-timer returns the following week.",
                    "These are not metrics to optimize. They are confirmation that a specific seed reached a specific person through a specific mechanism.",
                    "The Friday signal log captures them. The 8-week read tells you which seeds are taking. Live numbers stay in the Hideout tab and Signal log — not here."
                ]
            )
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.top, metrics.scaledSize(8))
    }
}

// MARK: - Bucket 3 — FORM depth

struct DoctrineFORMReading: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            DoctrineSectionHeader(
                kicker: "FORM",
                title: "Night read",
                accent: .inkGreen,
                isFirst: true
            )

            DoctrineSubsection(
                label: "WHAT FORM IS",
                accent: .inkGreen,
                paragraphs: [
                    "FORM structures athlete training through programs with real periodization. Each athlete runs their own Today on their own phone — different rep structures, different session types, different program logic.",
                    "The intelligence is in the sequencing and the ledger: what you logged shapes what comes next.",
                    "This is not a training log. A training log records what happened. FORM routes what happens next based on what the data said about what happened before. That distinction is the product."
                ]
            )

            DoctrineSubsection(
                label: "GHOST PROTOCOL",
                accent: .inkGreen,
                paragraphs: [
                    "Ghost Protocol is a 6-week run-form curriculum — mechanics, metronome, sessions S01 through S36. It is not a live pace adjuster. It does not automatically reduce target pace when it detects fatigue. It does not monitor you in real time.",
                    "It sequences form work alongside a training program. Early sessions establish metronome discipline. Middle sessions integrate mechanics under load. Late sessions test form retention under fatigue.",
                    "The curriculum exists because form degradation under fatigue is the most common injury mechanism in distance running, and most training programs do not address it directly."
                ]
            )

            DoctrineSubsection(
                label: "OFF-SEASON · INJURED OPERATOR",
                accent: .inkGreen,
                paragraphs: [
                    "The off-season is not a gap in the product. It is when the intelligence layer is most visible — cycles holding structure without active racing, the ledger receiving data without performance pressure, Ghost Protocol running without race-specific fatigue confounds.",
                    "You being injured closes one content surface — personal running demos — and opens a better one: what the system does when the athlete cannot run.",
                    "Most running apps produce nothing useful when the athlete is injured. FORM continues to operate. That is the story."
                ]
            )

            DoctrineSubsection(
                label: "EFFORT GOVERNS · VOICE",
                accent: .inkGreen,
                paragraphs: [
                    "Effort governs is the governing principle — distribution content reflects what the app actually shows, not what feels interesting to describe.",
                    "Site copy can breathe. App copy cannot. Distribution for FORM is always one screen, one decision, one sentence of context.",
                    "The moment distribution copy starts explaining the product rather than showing the product, it has become a tutorial. Tutorials are not distribution."
                ]
            )

            DoctrineSubsection(
                label: "SIMON · JULIEN · TUESDAY",
                accent: .inkGreen,
                paragraphs: [
                    "Simon is on Speed Emergence. Julien is on Hyrox Running. Same session type on the same Tuesday morning — threshold — with different rep structures on two phones.",
                    "Simon's Today shows time-based work: easy plus steady. Julien's shows a structure shaped by Hyrox periodization. One coach, two programs, two phones, one track.",
                    "The content is not here are my athletes training. The content is two different program architectures, same session type, same morning — product truth without claiming a multi-athlete console or live pace adjustment."
                ]
            )

            DoctrineSubsection(
                label: "PER-ATHLETE TRUTH",
                accent: .inkGreen,
                paragraphs: [
                    "There is no coach multi-athlete dashboard. Intelligence is logged and sequenced per device, after the session.",
                    "Tuesday and Saturday capture on Signal handles execution. This section is the stable model — execution checklists stay in Signal, not here."
                ]
            )
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.top, metrics.scaledSize(8))
    }
}

// MARK: - Distribution crash course (Manual tab · read straight through)

struct DistributionCrashCourseReading: View {
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            ZStack(alignment: .topLeading) {
                RadialGradient(
                    colors: [Color.inkGreen.opacity(0.06), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: metrics.scaledSize(200)
                )
                VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
                    MonoLabel(text: "DISTRIBUTION", color: .inkGreen.opacity(0.8), size: 9)
                    Text("The crash course")
                        .font(.sora(metrics.titleSize, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("Read once. Then execute in Signal.")
                        .font(.sora(metrics.captionSize, weight: .light))
                        .foregroundColor(.textMuted)
                    Rectangle()
                        .fill(Color.inkGreen.opacity(0.3))
                        .frame(width: metrics.scaledSize(40), height: 1)
                }
                .padding(metrics.cardPad)
            }
            .padding(.top, metrics.sectionGap)

            crashSection(
                label: "WHY DISTRIBUTION EXISTS",
                accent: .inkGreen,
                paragraphs: [
                    "Every product has two problems. The first is making something worth having. The second is making sure the people who would value it know it exists. Most builders are naturally better at the first than the second.",
                    "Building produces immediate, legible feedback — something works or it does not. Distribution produces delayed, ambiguous feedback — a seed planted today might produce a signal in eight weeks, or never, and you will not know which until you have run enough reps to read the pattern.",
                    "Distribution feels unnatural to product builders because the feedback loops are completely different. When you build, you know within hours whether the thing does what you intended. When you distribute, you plant a seed and wait. The waiting is not a sign that something is wrong. It is how distribution works. Seeds take time."
                ]
            )

            crashSection(
                label: "WHAT DISTRIBUTION IS",
                accent: .inkGreen,
                paragraphs: [
                    "Distribution is not marketing. Marketing is the story you tell about the product. Distribution is the mechanism by which the product reaches the people who would value it. A well-distributed product does not need a marketing strategy — the right seeds in the right places compound into reach over time without requiring active promotion.",
                    "Marketing thinking produces the wrong instincts. Marketing says: more reach, bigger audience, louder message. Distribution thinking says: right seed, right surface, right mechanism, enough reps.",
                    "A Watermarc card placed in a luxury building across the street is not marketing. It is a seed with a specific mechanism — a resident picks it up, keeps it, and uses it when they want a reason to try the café on a Tuesday morning. That mechanism either works or it does not. The signal tells you which."
                ]
            )

            crashSection(
                label: "REPS · SIGNAL · ADJUSTMENT",
                accent: .violetLight,
                paragraphs: [
                    "Reps are non-negotiable. No distribution system produces signal without reps. A single Monday content block tells you nothing. Eight Monday content blocks, consistently executed, start to produce data. Twelve weeks is when the methodology exists in your body rather than just in the protocol. The rep is the unit of currency, not the result.",
                    "Signal is what tells you whether the reps are producing anything. Signal is not followers, views, or impressions. Signal for Hideout is a board attribution — someone saying they saw the sign. Signal for FORM is outside-network engagement — a runner who does not already know you engaging with the content. Signal for Forge is the gate clearing — the product used correctly by real athletes without workarounds. Signal is specific, observable, and tied to a mechanism. Anything that cannot be traced back to a specific seed is noise.",
                    "Adjustment is what happens when signal is consistently absent after enough reps — eight weeks minimum for most surfaces. The adjustment is always singular: change one variable. Not the whole system. One thing. Then run more reps and watch what the signal does."
                ]
            )

            crashSection(
                label: "WHY MOST DISTRIBUTION FAILS",
                accent: .inkAmber,
                paragraphs: [
                    "The first reason is inconsistency. The seed gets planted once and you move on. Distribution requires repetition because the mechanism depends on exposure frequency. A third-exposure café wins, not a first-exposure one. Most efforts fail before the third exposure because the first exposure was expected to produce signal.",
                    "The second reason is wrong surface. The seed is planted where the mechanism does not connect to the target person. TikTok algorithmic discovery for a neighborhood café is a weak surface — the person who discovers a café on TikTok is not the person who becomes a regular. GBP and physical seeds in residential buildings are strong surfaces because the mechanism connects directly to the behavior.",
                    "The third reason is premature optimization. You change the approach before enough reps have run to produce readable signal. Week three feels like failure. Week eight starts to show pattern. Changing in week three resets the clock. One variable, after sufficient reps — that protocol exists to prevent premature optimization."
                ]
            )

            crashSection(
                label: "GOOGLE BUSINESS PROFILE",
                accent: .warm,
                paragraphs: [
                    "GBP is the most important single surface for Hideout. It is where people searching for a café in Edgewater land. Photos, posts, and review responses directly affect whether a search converts to a visit. This is not social media. It is local search infrastructure. It compounds. A well-maintained profile from two years ago is still producing signal today."
                ]
            )

            crashSection(
                label: "PHYSICAL SEEDS",
                accent: .warm,
                paragraphs: [
                    "Boards, cards, and partnerships are the highest-mechanism surfaces for residential and neighborhood reach. They require placement and maintenance, not ongoing creative effort. A Watermarc card in a building lobby is a seed that works passively. The investment is front-loaded. The compounding happens over months."
                ]
            )

            crashSection(
                label: "SHORT-FORM VIDEO",
                accent: .textMuted,
                paragraphs: [
                    "Reels and TikTok are an exhaust pipe, not a primary surface. The algorithm may or may not route to the right person. For Hideout, secondary to GBP and physical seeds. For FORM and Forge, the mechanism by which product truth reaches runners and strength athletes who do not know the product exists. Not optimized. Posted and left."
                ]
            )

            crashSection(
                label: "PROBLEM-SPACE PARTICIPATION",
                accent: .inkGreen,
                paragraphs: [
                    "Forums, community threads, and niche communities are the highest-signal surface for FORM specifically. A runner asking why pace felt harder at the same heart rate is asking exactly the question FORM is built to answer. A real observation dropped into that thread — not a promotion — plants a seed where the audience has already self-selected into caring. No performance, no farming, pure intelligence."
                ]
            )

            crashSection(
                label: "THIS OPERATOR",
                accent: .violetLight,
                paragraphs: [
                    "Building is native. Distribution is not. This is the structural gap — not character, not motivation. The builder's reward loop produces immediate feedback. Distribution produces delayed feedback. The Achiever drive wants to complete something today. Distribution completes in eight weeks when the signal read says a specific seed is working.",
                    "The system is designed around this. The Monday block is fixed so the rep happens regardless of how distribution feels that morning. The Friday log is lightweight so signal capture does not require enthusiasm. The 8-week read is the single review moment — not weekly optimization, not daily tracking. Plant, log, wait, read.",
                    "The distribution muscle develops through reps. It is not there yet. That is correct. After twelve weeks of Monday blocks, Tuesday ledger sentences, Saturday captures, and Friday logs, the methodology will exist in practice rather than in a spec. The reps are the training. The spec is the coach. The signal is the result."
                ]
            )
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.bottom, metrics.sectionGap)
    }

    private func crashSection(label: String, accent: Color, paragraphs: [String]) -> some View {
        DoctrineSubsection(label: label, accent: accent, paragraphs: paragraphs)
    }
}
