import SwiftUI
import SwiftData

// MARK: - You → Doctrine (evening read · iPad-first)
// Execution: Signal + Today. Night read: Doctrine + Manual + Ventures (live signal).

struct YouDoctrineTabView: View {
    @Environment(\.appMetrics) private var metrics
    @Environment(\.youIPadReadingFocus) private var youReadingFocus
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
                .youReadingContentWidth(metrics, focus: youReadingFocus)
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
                .font(.sora(metrics.isIPad ? metrics.youReadTitleSize : metrics.titleSize, weight: .semibold))
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
                .font(.sora(metrics.isIPad ? metrics.youReadBodySize : metrics.bodySize, weight: .light))
                .foregroundColor(.textPrimary.opacity(0.92))
                .lineSpacing(metrics.isIPad ? metrics.youReadLineSpacing : metrics.scaledSize(6))
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
                label: "CONDUCT FILTER",
                accent: .inkGreen,
                paragraphs: [
                    "First principles: competence under load, restraint, silence as data, conduct over story. When in doubt: make competence visible and remove explanation.",
                    "Weekly audit — 15 minutes, Monday morning or Sunday evening. Today → Habits → Conduct audit. Maintenance surfaces the same item when the interval is due.",
                    "Pick one product you touched: did you add explanation where conduct should carry? fill a slot without evidence? expand scope before the last layer proved? One line each on business, coaching, relationships. Close by naming one deletion for the next week.",
                    "Before TestFlight or any major ship: delete filter on one surface — if removed, is conduct still clear? Full checklist on Mac: BRICE_OS/CONDUCT_FILTER.md."
                ]
            )

            DoctrineSubsection(
                label: "DIRECTION · WHAT I WANT v7",
                accent: .violetLight,
                paragraphs: [
                    "Seek surprise, not impress — not validate, not admire. Underneath culture, travel, architecture: show me a room I couldn't have built myself.",
                    "Build the authored base. Make the world permeable. Allow the base to become more than you could have authored alone.",
                    "The house itself can become a source of surprise — sometimes a room arrives at the base, not only out there. Stewardship produces discovery, not only deduction.",
                    "Another room audible in life ≠ steward status at Hideout. Exploration stays wide; the house stays selective. Full prose: You → Want."
                ]
            )

            DoctrineSubsection(
                label: "ANOTHER ROOM",
                accent: .warm,
                paragraphs: [
                    "The meal is good. There are other flavors. The anchors worked. Another room. The room worked because it worked.",
                    "Not a habit. A reinterpretation of a recurring feeling. Before: something is missing / I've outgrown this. After: something else exists / this did its job. Concentration is not deprivation. Curiosity is not dissatisfaction. Expansion is not escape.",
                    "When restless, one question only: Am I experiencing deficiency, or am I noticing another room? Follow-up: Is the house failing, or is the house standing? The house is standing — that is why you are looking out the window.",
                    "Rooms are not escapes: another room is not an argument against the current room. The anchor held. The meal nourished. A new room becomes visible because the old room succeeded — not because it failed.",
                    "Audibility, not absence: the problem was not missing a person, city, or philosophy. It was missing context for dormant parts to become audible again.",
                    "Audibility vs acquisition: wrong read — I need more of this. Right read — I can still hear this. Recognition, not obligation. Travel, cinema, camps, architecture — often reminders, not instructions.",
                    "Quiet desires becoming audible is often a sign the system is healthier, not hungrier — the house got quiet enough to hear them, not a need to escape.",
                    "A new room becoming audible is not an argument against the current room. It is evidence the current room worked.",
                    "Survival test: when something lights you up — film, city, person, conversation — do you hear I need to change my life, or Oh, that room is still here? No audit. No checkbox. Mac: BRICE_OS/ANOTHER_ROOM_LENS.md."
                ]
            )

            DoctrineSubsection(
                label: "CONTACT · ALIVENESS",
                accent: .warm,
                paragraphs: [
                    "What is life for? Contact — not survival, success, or legacy as the center. Participation is how contact is lived. Aliveness, not achievement.",
                    "Construction → recognition → permeability. Restraint made you clear enough for life to reach you again — not harder, more reachable.",
                    "Money adds optionality; PRs are moments. The café, a city, music, architecture, conversation — contact with what is alive. Other flavors: more contact, not deficiency.",
                    "Design question: what environments increase contact? Café, Sunday, Tokyo, museum, dinner table, coaching — contact technologies. Light-bearer: help experience become available, not own the dawn.",
                    "Unforced: protect conditions, don't force outcomes. Proximity and practice before role — don't convert a real moment into a growth playbook. Echo: faith-first build now returns human-sized consequences; tend what reality hands back.",
                    "Hope → observable. When reality answers, recognition outranks creation. Touches ledger (concrete echoes): BRICE_OS/REALITY_TOUCHES.md. Orientation: BRICE_OS/PARTICIPATION_ORIENTATION.md."
                ]
            )

            DoctrineSubsection(
                label: "SUNDAY · FREQUENCY",
                accent: .warm,
                paragraphs: [
                    "Not a life problem — a Sunday problem. Mon–Tue and Wed–Sat already feed stewardship, competence, craft, execution. The quiet room becomes audible when operational noise drops.",
                    "Wrong question: who is available? Correct question: what room am I entering? Good people in the wrong room still underfeed. Casa Neos (June 2026) was a diagnostic — availability mistaken for alignment.",
                    "Sunday is not for company. Sunday is for frequency. Never say yes to a person before yes to a room. Room → Person, not Person → Room.",
                    "Tier A signal environments: Wynwood members club, listening room, architecture and design events, independent cinema, museum openings, lectures and salons. Criterion: people taking something seriously without making a spectacle of themselves.",
                    "Stop spending envoy budget on nice and available. One excellent conversation every few weeks may be enough. Pattern manual: BRICE_OS/BRICE_OPERATOR_MANUAL.md."
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

            DoctrineSubsection(
                label: "WHY THE FEEDBACK LOOP BREAKS FOR YOU",
                accent: .violetLight,
                paragraphs: [
                    "Building is native. Distribution is not. This is a skill gap, not a character gap. The building instinct was developed through years of making things work. The distribution instinct has not been developed yet. That is the entire explanation.",
                    "The builder's reward loop runs on immediate feedback. Something compiles or it does not. Something works or it does not. Distribution's feedback loop runs on weeks. The Achiever drive, which fires at daily completion, gets no clean signal from a Monday block. The Analytical drive, which wants data before conclusions, has nothing to read for weeks. Both drives are poorly served by distribution's feedback structure.",
                    "This is why the system is built the way it is. The Monday block is fixed so the rep happens regardless of how distribution feels that morning — before the day's product work has a chance to displace it. The Friday log is lightweight so signal capture does not require enthusiasm. The 8-week read is the single synthesis moment — not weekly optimization, not daily tracking. The system does not ask the operator to feel productive doing distribution. It asks him to run the protocol and read the data when there is enough of it.",
                    "The distribution muscle is not there yet. That is correct and expected. Twelve weeks of Monday blocks, Tuesday ledger sentences, Saturday captures, and Friday logs is when the methodology exists in practice. The reps are the training. The spec is the coach. The signal is the result. You have done harder things with less of a roadmap."
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
                    "Monday block plants Hideout and one app-content clip before open — fixed sequence, no decisions at execution time.",
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
                    "Hideout operates as four modes sharing one asset — not a café with side projects.",
                    "Hospitality: walk-in conditions — food and coffee as daily infrastructure, not the identity of the place.",
                    "Neighborhood infrastructure: the house embedded in Edgewater — residents, concierge, dog walkers, routine capture.",
                    "Recurring partnerships: supplier mode — cold brew accounts, office drops, clean invoices over chaotic walk-ins.",
                    "Operator studio: leverage when economics allow — planning, product work, photography. Which mode is running today changes what decisions are correct."
                ]
            )

            DoctrineSubsection(
                label: "THE HOUSE · STEWARDSHIP",
                accent: .warm,
                paragraphs: [
                    "Hideout is neighborhood infrastructure. The product is conditions — a living room where different worlds coexist peacefully.",
                    "The next evolution is not more authorship. It is stewardship: compatible contributors add rooms; Brice edits whether they belong.",
                    "Test for any addition: does this increase atmosphere or increase inventory? Atmosphere may grow. Inventory must stay constrained.",
                    "Compatible steward: not customer, employee, or contractor — selection framework in COMPATIBLE_STEWARD_FRAMEWORK.md. Contributes before asked, outcome over credit, atmosphere not inventory.",
                    "Old filter: does this match my vision? New filter: does this strengthen the house? Atmosphere law: ATMOSPHERE_GOVERNANCE.md — I love this, but it still has to feel calm.",
                    "Three phases: build the room → make the room work → room becomes audible. Root OS across all projects: ROOT_OPERATING_SYSTEM.md.",
                    "Economic freedom and a gift to the neighborhood are the two purposes. Food is infrastructure serving both."
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
                    "The column boards are not signage. They are a threshold decision surface. The person at the corridor entrance has already noticed Hideout. The board resolves hesitation — a reason that costs nothing and risks nothing.",
                    "FIRST TIME? START HERE does not sell the menu. It removes the barrier to entering.",
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
    @State private var deepReadExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            ZStack(alignment: .topLeading) {
                RadialGradient(
                    colors: [Color.inkGreen.opacity(0.07), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: metrics.scaledSize(220)
                )
                VStack(alignment: .leading, spacing: metrics.scaledSize(8)) {
                    MonoLabel(text: "DISTRIBUTION", color: .inkGreen.opacity(0.8), size: 9)
                    Text("The crash course")
                        .font(.sora(metrics.titleSize, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("Skill level 0. Read completely. Then the reps make sense.")
                        .font(.sora(metrics.captionSize, weight: .light))
                        .foregroundColor(.textMuted)
                    Rectangle()
                        .fill(Color.inkGreen.opacity(0.3))
                        .frame(width: metrics.scaledSize(40), height: 1)
                }
                .padding(metrics.cardPad)
            }
            .padding(.top, metrics.sectionGap)

            coreLabel

            crashSection(
                label: "FARMING, NOT ENGINEERING",
                accent: .inkGreen,
                paragraphs: [
                    "You understand systems, mechanics, operations, product, behavior design. Distribution is not a harder version of those things. It is a different discipline with different physics. Applying builder logic to it produces frustration, not results.",
                    "Engineering mindset: design the machine, the machine works, done. Feedback is immediate. If the button does not fire, you know within minutes.",
                    "Distribution mindset: plant the seed, wait, some die, some sprout, learn which soil works, plant more there. Feedback is delayed by weeks or months. There is no compile error. There is no crash log.",
                    "This is why builders hate it. Not because it is hard — because the feedback loop is broken compared to what they know. The ambiguity feels low-status. It feels like nothing is happening. Usually something is happening. You just cannot see it yet."
                ]
            )

            crashSection(
                label: "WHAT DISTRIBUTION ACTUALLY IS",
                accent: .inkGreen,
                paragraphs: [
                    "The wrong definition: posting content, social media, marketing, making noise, persuasion, audience building. That definition produces the wrong instincts.",
                    "The right definition: distribution is how the right person repeatedly encounters your product in a context that makes action easy.",
                    "Read that again. Three parts: the right person, repeatedly, in a context that makes action easy. All three matter. Most distribution fails because one of the three is wrong.",
                    "A Watermarc card in a luxury building across the street is distribution. A resident picks it up, keeps it, and uses it when they want a reason to try Hideout on a Tuesday morning. Right person — a resident within walking distance. Repeatedly — the card stays in their wallet. Context makes action easy — they already want coffee, they just needed a reason to try somewhere new.",
                    "An Instagram reel is not automatically distribution. It might reach the right person. It might not be repeated. The context might be wrong. It can be distribution. It is not automatically distribution."
                ]
            )

            crashSection(
                label: "THE MENTAL SHIFT",
                accent: .violetLight,
                paragraphs: [
                    "Stop asking: how do I promote this?",
                    "Ask: how does discovery actually happen for this product?",
                    "That question you are excellent at. Because it is systems design. You think about mechanisms, paths, failure modes, user behavior. Distribution is just systems design for discovery.",
                    "For Hideout: the discovery system is local. Proximity, physical presence, search, word of mouth. Build those mechanisms. For FORM: the discovery system is intelligence. Runners who care about the problem find people who understand it. Be visible in the right problem spaces. For Forge: the discovery system is execution proof. Serious lifters recognize when something works correctly. Show it working.",
                    "None of this requires a following. None of it requires performance. None of it requires personality. It requires seeds in the right soil, enough reps, and patience with the feedback loop."
                ]
            )

            crashSection(
                label: "REPS · SIGNAL · ADJUSTMENT",
                accent: .violetLight,
                paragraphs: [
                    "Reps are non-negotiable. One Monday block tells you nothing. Eight Monday blocks start to produce data. Twelve weeks is when the methodology lives in your body rather than in the spec. The rep is the unit of currency, not the result. This is threshold training. You did not understand the physiology before your first threshold session. You ran the reps. The pattern became legible afterward.",
                    "Signal is specific and tied to a mechanism. Signal for Hideout: a board attribution — someone says they saw the sign. GBP attribution — someone says they found you on Google. Watermarc redemption — someone brought the card. Signal for FORM: outside-network engagement — a runner who does not already know you engaging with content. Signal for Forge: execution gate cleared, no workarounds needed in real sessions. Impressions, views, and likes are not signal. They are noise dressed as signal.",
                    "Adjustment is singular and late. You do not adjust in week three. You adjust after eight weeks of logged signal shows a specific surface is not producing. Then you change one variable — not the system, one variable — and run more reps. Changing multiple things at once means you cannot read which change produced the result. One thing. Wait. Read."
                ]
            )

            crashSection(
                label: "WHY THE MONDAY BLOCK EXISTS",
                accent: .inkGreen,
                paragraphs: [
                    "Distribution skill level 0 operators overthink. A fixed block removes the overthinking.",
                    "You did not understand threshold physiology before your first threshold session. You were not required to. You ran the reps. The pattern became legible. After enough sessions, threshold started to feel like something you understood in your body, not just in a plan.",
                    "Monday block is the same mechanism. Do not try to understand distribution fully before the first rep. Run the block. Log the signal. Read the data at week eight. The understanding follows the reps, not the other way around.",
                    "The block is fixed because decisions at execution time are the enemy of consistency. No deciding what to film. No deciding what to write. No deciding which platform. Those decisions were made when the protocol was designed. Monday morning, the only job is to execute the sequence. That is the rep."
                ]
            )

            deepReadToggle

            if deepReadExpanded {
                VStack(alignment: .leading, spacing: metrics.sectionGap) {
                    crashSection(
                        label: "HOW DISCOVERY ACTUALLY HAPPENS · HIDEOUT",
                        accent: .warm,
                        paragraphs: [
                            "Stop asking: how do I make content? Start asking: how does an Edgewater resident become a regular?",
                            "The actual path: walks dog past Hideout, notices the terrace, does not enter. Sees the board again two weeks later. Later searches coffee near me on Google. Sees the profile — 4.7 stars, photos, a recent post. Comes in. Likes it. Returns the following Tuesday.",
                            "That path has multiple contact points: the physical space, the board, the Google profile. Distribution is improving each point on that path. The board is distribution. GBP is distribution. Watermarc cards are distribution. The salon partnership is distribution.",
                            "Instagram? Maybe. But it is weak compared to local mechanisms because the person most likely to become a Hideout regular is not discovering places on TikTok. They are walking past, searching nearby, or hearing from someone who goes.",
                            "The bottleneck is not awareness. It is the gap between noticing and entering. The boards, the GBP, the cards — they all compress that gap. That is the job."
                        ]
                    )

                    crashSection(
                        label: "HOW DISCOVERY ACTUALLY HAPPENS · FORM",
                        accent: .inkGreen,
                        paragraphs: [
                            "Stop asking: how do I get followers? Start asking: how does a runner with a real problem encounter FORM?",
                            "The actual path: a runner thinks — why does my pace feel harder at the same heart rate this week? They search Reddit. Or a training forum. Or they scroll and something stops them. They encounter a real observation from someone who clearly understands the problem. They think: this person gets my exact issue. Then maybe a profile click, an App Store search, an install.",
                            "That encounter mechanism is distribution. The observation dropped into the Reddit thread is a seed. The forum comment is a seed. The Tuesday track session clip showing two different program structures on two phones — that is a seed that lands specifically with runners and coaches who understand what individualized programming actually looks like.",
                            "FORM content works because the intelligence layer is visible. A runner who cares about pacing, fatigue, periodization — they recognize the sophistication immediately. The content does not need to explain the product. It needs to show the product thinking.",
                            "The injury actually helps here. When you cannot post running footage, what remains is the intelligence layer — what the system did, what it decided, how Ghost Protocol sequenced the week. That is rarer content than any run recap. Most apps have nothing interesting to show when the athlete is not running. FORM does."
                        ]
                    )

                    crashSection(
                        label: "HOW DISCOVERY ACTUALLY HAPPENS · FORGE",
                        accent: .violetLight,
                        paragraphs: [
                            "Stop asking: how do I make content? Start asking: how does a serious lifter discover this when their current tools annoy them?",
                            "The actual paths: a training discussion thread where someone complains that their workout app lost a set. A gym friend who mentions the app that actually starts in under five seconds. A coach who recommends it because the plan anchor works correctly. A search for best workout tracker that surfaces a comparison where Forge's execution integrity stands out.",
                            "Forge distribution is about execution truth. Not features. Not design. The specific thing Forge does that other apps do not — session survives a phone call mid-set, draft restores to the right position, rest timer fires correctly with the screen locked — those are the seeds. Show one of those in action and the right person immediately understands the value.",
                            "Tim, Tinius, and Cole have been using Forge for five weeks without workarounds. That is the proof. The gate cleared because real use confirmed it. Distribution starts from that position: a product that works correctly under real gym conditions, with athlete proof already in place."
                        ]
                    )

                    crashSection(
                        label: "WHY IT FEELS LIKE NOTHING IS HAPPENING",
                        accent: .inkAmber,
                        paragraphs: [
                            "Product gives you immediate truth. Button works or it does not. Distribution gives you ambiguous truth. Posted a reel — nothing happened. Did it fail?",
                            "Maybe. Maybe it reached the wrong audience. Maybe it reached the right audience but wrong surface. Maybe it needs twelve repetitions before anyone acts. Maybe the message is wrong. Maybe the channel is impossible. You do not know which.",
                            "That ambiguity feels low-status to operator brains. The Achiever drive wants to complete something today. Distribution does not complete in a day. The Analytical drive wants data before conclusions. Distribution does not produce clean data for weeks.",
                            "This is not a character flaw. It is a mismatch between your natural feedback loops and distribution's feedback loops. The system is designed to bridge that gap: fixed protocol removes the decision overhead, lightweight logging creates the data, 8-week read is when the data is actually readable. You are not supposed to feel the discipline working day-to-day. You are supposed to plant, log, and wait."
                        ]
                    )

                    crashSection(
                        label: "WHY MOST DISTRIBUTION FAILS",
                        accent: .inkAmber,
                        paragraphs: [
                            "Inconsistency. The seed gets planted once and the operator moves on. Distribution depends on exposure frequency. A third-exposure place wins, not a first-exposure one. Most efforts collapse before the third exposure because the first exposure produced no visible signal and the operator concluded the approach was wrong.",
                            "Wrong surface. The seed lands where the mechanism does not connect the right person to the product. TikTok for a neighborhood house: the person who discovers a terrace on TikTok is not the person who becomes a regular. The mechanism is wrong. GBP for the same place: the person searching coffee near me in Edgewater is exactly the target. Same product, different surface, completely different mechanism quality.",
                            "Premature optimization. The approach changes before enough reps have run to produce readable signal. Week three feels like failure because nothing visible has happened. Week eight starts to show pattern. Week twelve confirms it. Changing the approach in week three resets the clock and guarantees you will never read the week-three-through-eight signal."
                        ]
                    )

                    crashSection(
                        label: "SURFACES · LOCAL SEARCH",
                        accent: .warm,
                        paragraphs: [
                            "For Hideout, GBP is the most important single surface. Full stop. It is where people searching for coffee in Edgewater land. Photos, posts, and review responses directly affect whether that search converts to a visit.",
                            "This is not social media. It is local search infrastructure. It compounds invisibly — a well-maintained profile from two years ago is still producing signal today. Every photo added, every review responded to, every post published is a rep that stays in the system indefinitely. Most of Hideout's competition has weak GBP. That is an advantage available right now."
                        ]
                    )

                    crashSection(
                        label: "PHYSICAL SEEDS",
                        accent: .warm,
                        paragraphs: [
                            "Column boards, Watermarc cards, salon partnership, SkyView lobby stand — these are the highest-mechanism surfaces for residential and neighborhood reach. They require placement and maintenance, not ongoing creative effort. The investment is front-loaded. The compounding happens over months.",
                            "A Watermarc card in a 258-unit building is not one potential customer. It is 258 potential customers who live within walking distance and will encounter the card repeatedly in their own lobby. The mechanism is right person, right context, repeated exposure. No algorithm decides who sees it. Every resident sees it."
                        ]
                    )

                    crashSection(
                        label: "SHORT-FORM VIDEO",
                        accent: .textMuted,
                        paragraphs: [
                            "Reels and TikTok are an exhaust pipe, not a primary surface. Post and leave. The algorithm routes to whoever it routes to. For Hideout, weak compared to GBP and physical seeds — the person who becomes a Hideout regular is not discovering it on TikTok. For FORM and Forge, slightly stronger — the problem-space audience does exist on these platforms, and product truth content can reach them if it shows the real system.",
                            "The doctrine: same file posted to three surfaces in the same Monday block. Not optimized per platform. Not managed after posting. The block takes 11 minutes for posting. That is all the time these surfaces get."
                        ]
                    )

                    crashSection(
                        label: "SURFACES · RUNNER COMMUNITIES",
                        accent: .inkGreen,
                        paragraphs: [
                            "For FORM, this is the highest-signal surface available. Reddit running threads, Strava training discussions, niche forums — these are places where runners are already asking exactly the questions FORM is built to answer.",
                            "A runner asks: why does pace feel harder at the same HR this week? That is a FORM question. A real observation dropped into that thread — not a promotion, not a product mention, a genuine response about what the data shows — plants a seed where the audience has already self-selected into caring about the answer.",
                            "This fits the operator profile precisely: observational, non-performative, intelligence-first, no farming. The authority comes from the quality of the observation, not from a following. One observation per week. No links. No pitches. Just the signal the product produces, described accurately."
                        ]
                    )
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.bottom, metrics.sectionGap)
    }

    private var coreLabel: some View {
        HStack(spacing: metrics.scaledSize(8)) {
            Rectangle()
                .fill(Color.inkGreen.opacity(0.4))
                .frame(width: metrics.scaledSize(16), height: 1)
            Text("READ THIS FIRST")
                .font(.mono(metrics.monoSmall))
                .foregroundColor(.inkGreen.opacity(0.6))
                .tracking(1.2)
            Rectangle()
                .fill(Color.inkGreen.opacity(0.15))
                .frame(height: 1)
        }
    }

    private var deepReadToggle: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.25)) {
                deepReadExpanded.toggle()
            }
        }) {
            HStack(spacing: metrics.scaledSize(8)) {
                Rectangle()
                    .fill(Color.textMuted.opacity(0.3))
                    .frame(width: metrics.scaledSize(16), height: 1)
                Text(deepReadExpanded ? "WHEN SIGNAL IS UNCLEAR ↑" : "WHEN SIGNAL IS UNCLEAR ↓")
                    .font(.mono(metrics.monoSmall))
                    .foregroundColor(.textMuted)
                    .tracking(1.2)
                Rectangle()
                    .fill(Color.textMuted.opacity(0.15))
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func crashSection(label: String, accent: Color, paragraphs: [String]) -> some View {
        DoctrineSubsection(label: label, accent: accent, paragraphs: paragraphs)
    }
}
