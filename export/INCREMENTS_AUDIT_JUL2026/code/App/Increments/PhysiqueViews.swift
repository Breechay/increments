import SwiftUI
import SwiftData
import Foundation

// MARK: - PHYSIQUE TAB — Body Architecture Lab
// Athletic coherence, not muscular accumulation. Economy of mass.
// Canonical agent brief: FORM-iOS/docs/BRICE_OS/BRICE_PHYSIQUE_AGENT_BRIEF.md
// Coherence over development · structure reveal · legacy core routine preserved

struct PhysiqueTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoreCompletionLog.date, order: .reverse) private var coreLogs: [CoreCompletionLog]
    @Query(sort: \AMActivationLog.date, order: .reverse) private var activationLogs: [AMActivationLog]

    @State private var selectedSection = 0
    @State private var expandedDay: String? = nil
    let sections = ["Target", "Cut", "Core", "AM Stack", "Program", "Cardio", "Sculpt", "Skin", "Signals", "Failures", "Adjust"]

    @Environment(\.appMetrics) private var metrics

    var body: some View {
        ZStack {
            AtmosphericBackground()
            VStack(spacing: metrics.cardSpacing) {

                GlanceTabHeader(
                    kicker: "PHYSIQUE LAB",
                    title: metrics.isIPad ? "Body Architecture" : "Physique",
                    kickerColor: .inkGreen
                ) {
                    if metrics.isIPad {
                        VStack(alignment: .trailing, spacing: metrics.scaledSize(4)) {
                            HStack(spacing: metrics.scaledSize(6)) {
                                MonoLabel(text: "~12–13%", color: .textMuted, size: 9)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: metrics.scaledSize(8), weight: .light))
                                    .foregroundColor(.inkGreen)
                                MonoLabel(text: "STRUCTURE", color: .inkGreen, size: 9)
                            }
                            MonoLabel(text: "REVEAL", color: .textMuted, size: 8)
                        }
                    } else {
                        MonoLabel(text: "12–13% → STRUCTURE", color: .inkGreen, size: 9)
                    }
                }

                if metrics.isIPad {
                    // iPad: vertical section rail left, content right — no tapping required
                    IPadMasterDetailLayout(metrics: metrics, leftFraction: 0.28) {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: metrics.scaledSize(2)) {
                                SectionHeader(text: "SECTIONS", color: .textMuted)
                                    .padding(.horizontal, metrics.hPad)
                                    .padding(.top, metrics.scaledSize(12))
                                    .padding(.bottom, metrics.scaledSize(6))
                                ForEach(sections.indices, id: \.self) { i in
                                    Button(action: { withAnimation(.easeOut(duration: 0.18)) { selectedSection = i } }) {
                                        HStack(spacing: metrics.scaledSize(12)) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(selectedSection == i ? Color.inkGreen : Color.inkGreen.opacity(0.15))
                                                .frame(width: metrics.scaledSize(3), height: metrics.scaledSize(28))
                                            Text(sections[i])
                                                .font(metrics.fontMono(11))
                                                .foregroundColor(selectedSection == i ? .textPrimary : .textMuted)
                                                .tracking(0.8)
                                            Spacer()
                                            if selectedSection == i {
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: metrics.scaledSize(10), weight: .medium))
                                                    .foregroundColor(.inkGreen.opacity(0.6))
                                            }
                                        }
                                        .padding(.vertical, metrics.scaledSize(10))
                                        .padding(.horizontal, metrics.hPad)
                                        .background(
                                            selectedSection == i
                                                ? Color.inkGreen.opacity(0.07)
                                                : Color.clear
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius * 0.6))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, metrics.scaledSize(8))
                            .padding(.bottom, 80)
                        }
                    } right: {
                        ScrollView(showsIndicators: false) {
                            Group {
                                switch selectedSection {
                                case 0: targetSection
                                case 1: cutSection
                                case 2: coreSection
                                case 3: amActivationSection
                                case 4: programSection
                                case 5: cardioSection
                                case 6: sculptSection
                                case 7: skinSection
                                case 8: adherenceSection
                                case 9: failuresSection
                                default: adjustSection
                                }
                            }
                            .adaptiveContentWidth(metrics)
                        }
                    }
                } else {
                    // iPhone: single-line section chips — content gets the screen
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: metrics.scaledSize(6)) {
                                ForEach(sections.indices, id: \.self) { i in
                                    physiqueSectionChip(i)
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
                                case 0: targetSection
                                case 1: cutSection
                                case 2: coreSection
                                case 3: amActivationSection
                                case 4: programSection
                                case 5: cardioSection
                                case 6: sculptSection
                                case 7: skinSection
                                case 8: adherenceSection
                                case 9: failuresSection
                                default: adjustSection
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
    }

    // MARK: - 1. TARGET

    var targetSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            // Governing insight
            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 36).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "GOVERNING DOCTRINE", color: .inkGreen, size: 10)
                            Text("Athletic coherence, not muscular accumulation.")
                                .font(metrics.fontSora(15, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                    }
                    Text("Build a body organized by performance — broad shoulders, visible structure, lean waist, functional glutes. Nothing screams for attention.")
                        .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Economy of mass. Enough muscle to improve the read — not maximum muscle. Tissue that doesn't improve the silhouette is not the goal.")
                        .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Target read: athletic first, muscular second. Preferred reaction: \"That guy clearly does something\" — not \"That guy lifts.\"")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkGreen).lineSpacing(2.5)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Coherence over development. The question is not \"What muscle is lagging?\" It is \"What would make the whole thing read correctly?\"")
                        .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Repeatable meals > recipe exploration. System gets more familiar, not more featured.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Priority ranking
            CardView {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    MonoLabel(text: "VISUAL LEVERAGE RANKING", color: .textMuted, size: 10)
                    leverageRow(1, "Shoulder width / 3D cap", 0.98, "Fastest ratio shift. Lateral + rear delt.")
                    leverageRow(2, "Leanness / structure reveal", 0.90, "Jawline, serratus, clavicle shelf, waist — revealed, not built.")
                    leverageRow(3, "Upper chest clavicular fullness", 0.78, "Athletic armor plate. Cut-independent.")
                    leverageRow(4, "Glute shape / glute med shelf", 0.72, "Tennis player glute. Injury-gated now.")
                    leverageRow(5, "Rear delt / back depth", 0.65, "3D silhouette from side. Amplifies shoulders.")
                    leverageRow(6, "Serratus / rib cage detail", 0.55, "BF-gated. Emerges at 8–10% naturally.")
                    leverageRow(7, "TVA / waist vacuum", 0.45, "Highest ROI per effort. Begin immediately.")
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Morphology brief
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        MonoLabel(text: "MORPHOLOGY BRIEF", color: .textMuted, size: 10)
                        Spacer()
                        MonoLabel(text: "UPPER BODY", color: .inkGreen, size: 9)
                    }
                    morphRow("Reference", "Pole vaulter · decathlete · tennis · sprinter — capability visible, coherence over development.")
                    morphRow("Shoulders", "Broad, 3D, capped lateral delts. Rear delt visible from the side. Anterior delt suppressed.")
                    morphRow("Face / jaw", "Revealed by leanness and conditions — not trained directly. Jawline is the result, not the target.")
                    morphRow("Clavicle shelf", "Visible when structure reads lean. Cut milestone, not training milestone.")
                    morphRow("Upper chest", "Clavicular head presence. Incline 15–30°, 35° ceiling — not flat-press dominant.")
                    morphRow("Serratus", "Finger-like striations below lat. Sub-10% + protraction work. Revealed, not built.")
                    morphRow("Midsection", "Legacy core routine + TVA vacuum. Flat read from trunk work and leanness — not more Forge ab volume.")
                    morphRow("Waist", "Narrow. TVA resting tone trainable without adding circumference.")
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        MonoLabel(text: "MORPHOLOGY BRIEF", color: .textMuted, size: 10)
                        Spacer()
                        MonoLabel(text: "LOWER BODY", color: .violetLight, size: 9)
                    }
                    morphRow("Glutes", "Tennis player / sprinter shape. Glute max = fullness. Glute med = the high round shelf. Both required.")
                    morphRow("Posterior chain", "Hamstring and glute visible from behind — the rugby/sprinter read.")
                    morphRow("Thighs", "Powerful, not blocky. Quad suppression is active. Hip-hinge patterns, not knee-dominant.")
                    morphRow("Calves", "Proportional. Athletic, not bodybuilding dominant.")
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Intentional suppression
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "INTENTIONAL SUPPRESSION LIST", color: .inkAmber, size: 10)
                    Text("These are not neglected — they are actively limited.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                    VStack(spacing: metrics.rowSpacing) {
                        suppressRow("Anterior delts", "Already overdeveloped. Grows from incline pressing. Zero direct work.")
                        suppressRow("Upper traps", "Compresses shoulder illusion. Widening traps = shorter neck + smaller-looking delts.")
                        suppressRow("Flat pressing volume", "Feeds anterior delt and mid/lower chest at the expense of upper chest priority.")
                        suppressRow("Direct quad work", "Leg press, hack squat, leg extension. Builds blockiness, not the target silhouette.")
                        suppressRow("Loaded oblique hypertrophy", "Side bends, heavy twists add waist circumference. Anti-rotation only.")
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 2. CUT

    var cutSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "CUT PROTOCOL — STRUCTURE REVEAL", color: .inkGreen, size: 10)
                    }
                    Text("Leanness is pursued to reveal structure (face, clavicles, serratus, waist), not to achieve a body-fat number.")
                        .font(metrics.fontSora(14, weight: .semibold)).foregroundColor(.textPrimary).lineSpacing(3)
                    Text("The jawline is not the target. The conditions are the target. The jawline is the result.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkGreen).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "MACROS — ACTIVE", color: .inkGreen, size: 10)
                    }
                    HStack(spacing: metrics.cardSpacing) {
                        cutCol("CALORIES\nWORKDAYS", "2,200\n–2,350")
                        divider()
                        cutCol("CALORIES\nBASE DAYS", "1,900\n–2,100")
                        divider()
                        cutCol("PROTEIN\nEVERY DAY", "190–210g")
                        divider()
                        cutCol("RATE\nTARGET", "0.5–0.75\nlb/week")
                        Spacer()
                    }
                    Text("~2,650 kcal estimated maintenance. Do not cut below 1,900 kcal. Target: lean enough that anatomy reads correctly — directional ~8–10%, visual outcome over caliper number. Rate above 1 lb/week = muscle loss risk — add 200 kcal. Stall 2+ weeks with adherence = reduce by 150 kcal.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "VISUAL QUALITY SIGNALS", color: .inkGreen, size: 10)
                    Text("Prioritize weekly photos and visual read over body-fat estimates alone. If visual quality improves while scale stalls, the cut has not failed.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        visualSignalRow("Jawline visibility")
                        visualSignalRow("Reduced facial puffiness")
                        visualSignalRow("Cheekbone definition")
                        visualSignalRow("Serratus + clavicle shelf")
                        visualSignalRow("Shoulder-to-waist ratio")
                        visualSignalRow("Waist circumference trend")
                    }
                    Text("Facial changes often lag the waist. Compare photos, not daily mirror checks.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "HYDRATION DOCTRINE", color: .textMuted, size: 10)
                    Text("Hydration is a physique variable. Stable day to day. Avoid large sodium swings, reactive dehydration, and crash-cut water manipulation.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Judge visual quality under normal hydrated conditions — look good living normally, not temporarily leaner through dehydration.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkGreen).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "FACE & MIDSECTION READ", color: .textMuted, size: 10)
                    Text("Governed by: body-fat level · hydration consistency · food volume · sleep quality.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Before cutting calories further, audit: late-night eating · large food-volume meals · hydration · sodium variability · sleep disruption · stress/cortisol.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                    Text("No jawline hacks — mewing, jaw exercisers, facial workouts. ROI is tiny vs continuing the cut path.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkAmber).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    MonoLabel(text: "MEAL TIMING — WORKDAY (WED–SUN)", color: .textMuted, size: 10)
                    mealRailView()
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "CARB TIMING LOGIC", color: .textMuted, size: 10)
                    carbRow2("Fasted cardio 5:00 AM", "Zone 2 fat oxidation peaks when insulin is low. No pre-cardio carbs. Override: half banana if body battery <30 or HRV suppressed. Skip Mon/Fri — Rod at Panorama 6:15.", .good)
                    carbRow2("9:30 AM banana", "First carb of the day. Liver glycogen restoration after fasted cardio without spiking insulin aggressively.", .neutral)
                    carbRow2("1:30 PM — no starch", "Protein + fat only. Keeps insulin low through afternoon, extending fat-burn window.", .neutral)
                    carbRow2("4:45 PM sourdough ←", "Pre-lift glycogen prime. Determines Forge session quality. After a long Hideout shift, glycogen is partially depleted — this is not optional.", .critical)
                    carbRow2("6:30 PM fruit post-lift", "Rapid glycogen replenishment. High-GI post-exercise is appropriate — muscle glucose uptake is elevated.", .good)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "PRE-LIFT CARB — MOST CRITICAL SINGLE ACTION", color: .inkAmber, size: 10)
                    Text("Chronically lifting glycogen-depleted after a long Hideout shift produces strength regression that looks like 'the cut is working.' You're losing muscle, not fat. The sourdough at 4:45 is what separates fat loss from fat-and-muscle loss.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Pack it in the bag every morning. This is not a decision — it is a system.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkAmber).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 3. CORE (LEGACY)

    var coreSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "CORE ROUTINE — LEGACY PRACTICE", color: .inkGreen, size: 10)
                    }
                    Text("Predates Forge. Decades at 4–6×/week — a personal staple like Zone 2, not a random finisher. Whole-system practice; may run independently of Forge.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Long-term operator evidence — preserve unless injury, recovery, or a clearly superior reason says otherwise.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkGreen).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    MonoLabel(text: "ONE ROUND", color: .textMuted, size: 10)
                    coreMoveRow("20", "Accordions")
                    coreMoveRow("60", "Bicycle kicks (30/side)")
                    coreMoveRow("20/side", "Cross-leg reverse crunches")
                    coreMoveRow("20", "Open-leg sit-ups — legs open, push through")
                    coreMoveRow("20", "Windshield wipers — knees at 90°")
                    coreMoveRow("20", "V-ups")
                    coreMoveRow("60", "Flutter kicks (30/side)")
                    coreMoveRow("20", "Leg raises")
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    HStack(spacing: metrics.sectionGap) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "ROUNDS", color: .textMuted, size: 9)
                            Text("2–3").font(.system(size: metrics.scaledSize(13), weight: .semibold, design: .monospaced)).foregroundColor(.textPrimary)
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(width: 0.5, height: 30)
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "PER ROUND", color: .textMuted, size: 9)
                            Text("~5–6 min").font(.system(size: metrics.scaledSize(13), weight: .semibold, design: .monospaced)).foregroundColor(.textPrimary)
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(width: 0.5, height: 30)
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "FREQUENCY", color: .textMuted, size: 9)
                            Text("4–6×/wk").font(.system(size: metrics.scaledSize(13), weight: .semibold, design: .monospaced)).foregroundColor(.inkGreen)
                        }
                        Spacer()
                    }
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    coreCompletionTracker
                    Text("Independent of Forge — not programmed in Sculpt.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2)
                    Text("Placement: first in the 5:00 AM stack — before glute activation, before fasted cardio. Not at bedtime.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkGreen).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "OBSERVED EFFECTS — OPERATOR REPORTED", color: .inkGreen, size: 10)
                    signalRow("Flatter midsection + abdominal definition", "Faster visual response than many traditional hypertrophy-focused ab programs.", .inkGreen)
                    signalRow("Trunk awareness + spinal movement confidence", "Not just hypertrophy — movement reset.", .inkGreen)
                    signalRow("Improved mood + creative energy", "Completion signal beyond physique. Daily reset, not ab day.", .inkGreen)
                    signalRow("Athletic readiness", "Subjective readiness before Forge — preserved unless injury or schedule conflict.", .inkGreen)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                HStack(alignment: .top, spacing: metrics.blockSpacing) {
                    Rectangle().fill(Color.inkAmber.opacity(0.7)).frame(width: 2)
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "BOUNDARY", color: .inkAmber, size: 10)
                        Text("Lives in Physique — not in Forge Sculpt set prescriptions. Do not replace with \"better\" ab programming without explicit operator request.")
                            .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2.5)
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 4. AM STACK

    var amActivationSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkTeal).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "AM GLUTE ACTIVATION", color: .inkTeal, size: 10)
                    }
                    Text("After core, before fasted cardio. Bridges → clamshells → walks → kicks → hinge. Prescribed — not optional.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)

                    activationMoveRow("Glute bridge (BW)", "3×15")
                    activationMoveRow("Clamshell (band)", "3×20/side")
                    activationMoveRow("Lateral band walk", "2×15 steps/direction")
                    activationMoveRow("Donkey kick (BW)", "2×15/side")
                    activationMoveRow("Single-leg hip hinge (BW)", "2×10/side")

                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    activationCompletionTracker
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "STACK ORDER", color: .textMuted, size: 10)
                    Text("Core (2–3 rnd) → Glute activation → Z2 cardio (40 min · 130–145 BPM)")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Total window ~50 min. If time-crunched: 2 core rounds + full activation.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 5. PROGRAM

    var programSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            // Phase status
            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "PROGRAM ARCHITECTURE — PHASE 1 ACTIVE", color: .inkGreen, size: 10)
                    }
                    HStack(spacing: metrics.sectionGap) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "PHASE", color: .textMuted, size: 9)
                            Text("1 of 2").font(.system(size: metrics.scaledSize(13), weight: .semibold, design: .monospaced)).foregroundColor(.inkAmber)
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(width: 0.5, height: 30)
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "CONSTRAINT", color: .textMuted, size: 9)
                            Text("Injury-modified").font(.system(size: metrics.scaledSize(13), weight: .semibold, design: .monospaced)).foregroundColor(.textPrimary)
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(width: 0.5, height: 30)
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "DURATION", color: .textMuted, size: 9)
                            Text("~2–3 wks").font(.system(size: metrics.scaledSize(13), weight: .semibold, design: .monospaced)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Daily structure
            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "DAILY STRUCTURE", color: .inkGreen, size: 10)
                    Text("Morning stack is one window — core, then glute activation, then cardio. PM Forge is the primary hypertrophy signal. Bedtime is tibia protocols only.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    HStack(spacing: metrics.cardSpacing) {
                        slotCol("AM 5:00–5:45", "Core\nGlute activation\nZ2 cardio")
                        slotCol("PM 5:30+", "Primary\nHypertrophy\nHigh signal")
                        slotCol("Bedtime", "Ankle mobility\nTKE · tibia\nNo glute extras")
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Phase 1 context
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack {
                        MonoLabel(text: "PHASE 1 — CURRENT (INJURY-MODIFIED)", color: .inkAmber, size: 10)
                        Spacer()
                        MonoLabel(text: "~3 WEEKS", color: .textMuted, size: 9)
                    }
                    Text("Aggressive upper body. Protected lower body. This is a specialization block — forced prioritization is actually favorable for shoulder and upper chest development. Lower body is preserved, not abandoned.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Forge boundary
            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkAmber).frame(width: 3, height: 52).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            HStack(spacing: metrics.rowSpacing) {
                                MonoLabel(text: "FORGE EXECUTES", color: .inkAmber, size: 9)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.inkAmber.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                MonoLabel(text: "PHYSIQUE GOVERNS", color: .inkGreen, size: 9)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.inkGreen.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            Text("Sets, reps, load, and session history live in Forge. Tap any session below to see the full exercise list. This tab governs intent — why each session exists, what it must accomplish, what it must never do.")
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2.5)
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // MARK: Expandable session cards

            expandableDayCard(
                day: "MONDAY",
                title: "Shoulder A",
                context: "Gym A · with Tim",
                sessionType: nil,
                color: .inkGreen,
                priority: "Lateral + rear delt isolation. The lateral head drives shoulder width — trained fresh, before anything taxes the stabilizers.",
                intent: "Cable lateral opens first. DB lateral second. Rear delt superset closes the isolation block. Press last — 2 sets only, support role. Mechanical dropset finishes.",
                suppressed: "No overhead barbell · No upright row · No front raise · No Arnold press",
                exercises: [
                    ("Cable lateral raise (cross-body)", "4 × 15", "Lead with pinky. Thumbs down. No slack at the bottom."),
                    ("DB lateral raise (strict, seated)", "3 × 12", "No momentum. Pause at top."),
                    ("Reverse pec deck", "3 × 15", "Pinkies flared. Pure posterior arc — not a row."),
                    ("Face pull (high pulley)", "2 × 15", "Pull toward ears. Elbows high at finish."),
                    ("Seated DB press — neutral grip", "2 × 10", "2 sets only. Support, not primary."),
                    ("Lateral raise dropset", "2 × failure", "Finisher. No rest between drops.")
                ]
            )

            expandableDayCard(
                day: "TUESDAY",
                title: "Upper Push",
                context: "Gym A · with Tim",
                sessionType: nil,
                color: .inkGreen,
                priority: "Clavicular head hypertrophy. The specific gap from a training history dominated by flat work. Serratus protraction on every pressing set.",
                intent: "Incline compound always opens. Incline at 15–30° default — 35° ceiling, never 45°. Low-to-high cable fly for clavicular arc. Glute bridge hold closes — shape preservation, not afterthought.",
                suppressed: "No flat barbell bench · No high-to-low fly · No incline above 35° · No dips",
                exercises: [
                    ("Incline DB press (15–30°)", "4 × 8–10", "Elbows slightly in. Press from nipple line upward."),
                    ("Low-to-high cable fly (floor pulley)", "4 × 12", "Arc upward. Finish above shoulder height."),
                    ("Incline DB fly (20–25°)", "3 × 12", "Wide stretch at bottom. Squeeze — don't let arms go vertical."),
                    ("Push-up to serratus protraction", "3 × 12", "Full protraction at top. 2-second hold. This is the point."),
                    ("DB loaded glute bridge hold", "3 × 30s", "DB on hip crease. Max squeeze. Glute max only.")
                ]
            )

            expandableDayCard(
                day: "WEDNESDAY",
                title: "Pull",
                context: "Gym B · solo",
                sessionType: nil,
                color: .textSecond,
                priority: "Rear delt accumulation and serratus direct work. Pull sessions compound rear delt volume with the shoulder days. Upper trap suppressed for the entire phase.",
                intent: "Row with elbows out — rear delt, not lat. Straight-arm pulldown is the primary serratus movement — fully protract at the bottom. No shrugs, no exceptions.",
                suppressed: "No DB shrug · No upright row · No trap-dominant patterns",
                exercises: [
                    ("Chest-supported row (wide, elbows out)", "4 × 12", "Elbows flare wide. Think rear delt, not lat."),
                    ("Lat pulldown (wide grip)", "4 × 10", "Bar to upper chest. Elbows drive down and out."),
                    ("Single-arm cable row (neutral)", "3 × 12/side", "Full stretch at front. Elbow past hip."),
                    ("Face pull (high pulley)", "4 × 15", "Elbows high. External rotation at finish."),
                    ("Straight-arm pulldown", "3 × 12", "Arms straight throughout. Lats and serratus."),
                    ("Serratus cable punch", "3 × 15", "Fully protract at the end — push through the finish.")
                ]
            )

            expandableDayCard(
                day: "THURSDAY",
                title: "Shoulder B",
                context: "Gym A · with Tim",
                sessionType: nil,
                color: .inkGreen,
                priority: "Second lateral stimulus at 72h from Monday. Lateral-dominant today — Thursday is NOT a second rear delt day. Variation, not repetition. Rotator cuff non-negotiable.",
                intent: "Cable lateral opens before DB — different tension curve. Rear fly is superset only (3 sets), intentionally light. Lean-away lateral replaces incline rear work to keep Thursday lateral-dominant.",
                suppressed: "No pronated overhead press · No front raise · No incline rear delt raise (moved out in v2.2)",
                exercises: [
                    ("Single-arm cable lateral (low pulley)", "4 × 15/side", "Constant tension. Opposite hand holds machine."),
                    ("DB lateral raise", "3 × 12", "Superset with rear fly below — no rest between."),
                    ("Rear delt fly (superset)", "3 × 12", "Elbows wide. Drop straight into this from laterals."),
                    ("Lean-away DB lateral raise", "3 × 15/side", "Hold fixed object, lean 20–30°. Longer ROM. No trap."),
                    ("Seated DB press — neutral grip", "2 × 10", "2 sets only. Support role."),
                    ("External rotation (cable or band)", "2 × 15", "Elbow pinned. Slow. Structural — not optional.")
                ]
            )

            expandableDayCard(
                day: "FRIDAY",
                title: "Recovery Pump",
                context: "Gym B · solo",
                sessionType: "RECOVERY BUFFER",
                color: .textMuted,
                priority: "Infrastructure, not stimulus. This session exists to protect Saturday. The arm movements are a vehicle — the actual purpose is arriving at Saturday with a fresh shoulder complex.",
                intent: "35-minute hard cap. No progression tracking. No failure sets. No shoulder work. If you want to add something, you've misread the session. Thursday and Saturday run hard because Friday doesn't.",
                suppressed: "No lateral raises · No face pulls · No pressing · No shoulder isolation of any kind · No extra sets",
                exercises: [
                    ("DB curl (alternating)", "3 × 12", "Moderate weight. Supinate at top. Not a max-effort set."),
                    ("Rope pressdown", "3 × 15", "Controlled. Rope splits at bottom. Elbows pinned."),
                    ("Serratus cable punch", "3 × 15", "Light. Full protraction. Tissue perfusion, not load.")
                ]
            )

            expandableDayCard(
                day: "SATURDAY",
                title: "Full Upper",
                context: "Gym B · solo · recovery-buffered",
                sessionType: nil,
                color: .inkGreen,
                priority: "Highest load ceiling of the week. Friday's buffer is why this can run hard. Gym B gives heavier DBs, cables, and machines Gym A doesn't have.",
                intent: "Incline machine press at converging angle 20–30°. Low-to-high cable fly — floor pulley up, not high-to-low. Machine lateral for full tension arc. Saturday row uses neutral grip (lat emphasis) to differentiate from Wednesday.",
                suppressed: "No high-to-low fly · No flat bench primary · No heavy shrugs",
                exercises: [
                    ("Incline machine press (converging, 20–30°)", "4 × 8", "Let the machine converge. Squeeze at top."),
                    ("Low-to-high cable fly (floor pulley)", "3 × 12", "Upward arc. Finish above shoulder. Upper chest only."),
                    ("Machine lateral raise", "4 × 12", "Full arc. No cheating. Machine holds tension where DB loses it."),
                    ("Chest-supported row — neutral grip", "3 × 12", "Elbows more tucked than Wednesday. Lats, not rear delt."),
                    ("Reverse pec deck", "3 × 15", "Pinkies lead. Rear delt close for the week."),
                    ("DB loaded glute bridge hold", "3 × 30s", "DB on hip crease. Max squeeze. Glute preservation.")
                ]
            )

            // AM Activation
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "AM STACK — 5:00–5:45 AM", color: .textMuted, size: 10)
                    Text("Order: legacy core (Core tab) → glute activation below → 40 min Zone 2 cardio. Prescribed — not optional. If it doesn't feel easy, it's too much.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2.5)
                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                    MonoLabel(text: "GLUTE ACTIVATION — AFTER CORE", color: .inkGreen, size: 10)
                    Text("Glute bridge (BW) · Clamshell (band) · Lateral band walk · Donkey kick · Single-leg hip hinge")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textSecond).lineSpacing(2.5)
                    Text("15–20 min · zero fatigue cost to PM. Donkey kicks here — not at bedtime.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkGreen).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Phase 2 shift
            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack {
                        MonoLabel(text: "PHASE 2 — ARCHITECTURAL SHIFT", color: .inkGreen, size: 10)
                        Spacer()
                        MonoLabel(text: "CLINICAL GATE · NOT CALENDAR", color: .inkAmber, size: 9)
                    }
                    Text("Posterior chain earns a primary session slot. Lower body transitions from activation-only to loaded compound. Shoulder and upper chest priority locks in permanently — those gains do not trade away for glute work.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        archShiftRow("Gate", "Pain-free single-leg loading + stable RDL tolerance. Not elapsed time.")
                        archShiftRow("Lower", "Hip thrust, RDL, B-stance RDL, cable abduction replace bridge-only work.")
                        archShiftRow("Stairmaster", "Unlocks as a glute tool — Wednesday AM or Friday AM only.")
                        archShiftRow("Quad suppression", "Maintained. No leg press, hack squat, or leg extension as primary.")
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Volume — honest framing
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "WEEKLY VOLUME — SPECIALIZATION BLOCK", color: .textMuted, size: 10)
                    Text("This is not balanced hypertrophy volume. These are specialization-level numbers for an advanced operator with a specific morphology target. Recovery signal: Thursday shoulder freshness — not set arithmetic.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    volumeTableRow("Lateral delts", "18–22 sets", "3× weekly · primary morphology driver", .inkGreen)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    volumeTableRow("Rear delts", "18–24 effective", "Distributed Mon/Wed/Thu/Sat · compound overlap included", .inkGreen)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    volumeTableRow("Anterior delts", "0 direct", "Absorbed from incline only · suppressed", .inkAmber)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    volumeTableRow("Upper chest", "10–14 sets", "2× weekly · 15–30° incline only", .textSecond)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    volumeTableRow("Glutes (Phase 1)", "10–14 sets", "AM activation + bridge holds · preservation", .violetLight)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    volumeTableRow("Glutes (Phase 2)", "16–22 sets", "Loaded compounds · primary hypertrophy", .violetLight)
                    Rectangle().fill(Color.muted.opacity(0.1)).frame(height: 0.5)
                    volumeTableRow("Recovery signal", "Thu freshness", "If Thursday isolation degrades → prior days ran hot", .inkAmber)
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - Expandable day card

    func expandableDayCard(
        day: String,
        title: String,
        context: String,
        sessionType: String?,
        color: Color,
        priority: String,
        intent: String,
        suppressed: String,
        exercises: [(String, String, String)]
    ) -> some View {
        let isExpanded = expandedDay == day
        return CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {

                // Tappable header row
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        expandedDay = isExpanded ? nil : day
                    }
                }) {
                    HStack(alignment: .top, spacing: metrics.cardSpacing) {
                        MonoLabel(text: day, color: color, size: 11)
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            HStack(spacing: metrics.rowSpacing) {
                                Text(title).font(metrics.fontSora(14, weight: .semibold)).foregroundColor(.textPrimary)
                                if let st = sessionType {
                                    Text(st)
                                        .font(.system(size: metrics.scaledSize(9), weight: .medium, design: .monospaced))
                                        .foregroundColor(.textMuted)
                                        .padding(.horizontal, 5).padding(.vertical, 2)
                                        .background(Color.muted.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                }
                            }
                            MonoLabel(text: context, color: .textMuted, size: 9)
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: metrics.scaledSize(13), weight: .light))
                            .foregroundColor(.textMuted)
                    }
                }
                .buttonStyle(.plain)

                // Always-visible intent block
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5).padding(.top, 10)
                    HStack(alignment: .top, spacing: metrics.cardSpacing) {
                        MonoLabel(text: "PRIORITY", color: .textMuted, size: 9).frame(width: 60, alignment: .leading)
                        Text(priority).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(alignment: .top, spacing: metrics.cardSpacing) {
                        MonoLabel(text: "INTENT", color: .textMuted, size: 9).frame(width: 60, alignment: .leading)
                        Text(intent).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(alignment: .top, spacing: metrics.cardSpacing) {
                        MonoLabel(text: "SUPPRESS", color: .inkRed, size: 9).frame(width: 60, alignment: .leading)
                        Text(suppressed).font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkRed.opacity(0.8)).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Expandable exercise catalog
                if isExpanded {
                    VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5).padding(.top, 12)
                        HStack(spacing: metrics.rowSpacing) {
                            MonoLabel(text: "EXERCISES", color: .inkGreen, size: 9)
                            Text("tap to collapse")
                                .font(.system(size: metrics.scaledSize(9), design: .monospaced))
                                .foregroundColor(.textMuted)
                        }
                        .padding(.top, 10).padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                            ForEach(Array(exercises.enumerated()), id: \.offset) { idx, ex in
                                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                                    Text("\(idx + 1)")
                                        .font(.system(size: metrics.scaledSize(10), weight: .medium, design: .monospaced))
                                        .foregroundColor(.textMuted)
                                        .frame(width: 14, alignment: .leading)
                                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                        HStack(alignment: .firstTextBaseline, spacing: metrics.cardSpacing) {
                                            Text(ex.0)
                                                .font(metrics.fontSora(13, weight: .medium))
                                                .foregroundColor(.textPrimary)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                            Text(ex.1)
                                                .font(.system(size: metrics.scaledSize(11), weight: .semibold, design: .monospaced))
                                                .foregroundColor(.inkGreen)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        Text(ex.2)
                                            .font(.system(size: metrics.scaledSize(11), design: .monospaced))
                                            .foregroundColor(.textMuted)
                                            .lineSpacing(1.5)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(.vertical, 8)
                                if idx < exercises.count - 1 {
                                    Rectangle().fill(Color.muted.opacity(0.08)).frame(height: 0.5)
                                }
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    // MARK: - 4. CARDIO

    var cardioSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.violetLight).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "CARDIO LAB — SCULPTING TOOLS", color: .inkGreen, size: 10)
                    }
                    Text("Cardio selection determines morphology outcomes, not just caloric expenditure. Each tool has a different sculpting profile. Choose based on what the session needs to accomplish.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                }
            }
            .padding(.horizontal, metrics.hPad)

            cardioTool("STAIRMASTER", "Gym B only · 20–25 min · moderate pace",
                       chips: [("Primary glute tool", Color.violetLight), ("Posterior chain", Color.violetLight), ("Higher fatigue", Color.inkAmber)],
                       strengths: [
                        "Direct glute max + glute med activation through hip extension under load",
                        "Hamstring and calf involvement — full posterior chain stimulus",
                        "Step drive pattern reinforces hip extension (same as hip thrust mechanics)",
                        "Shapes the 'tennis player' glute — round, high, functional",
                       ],
                       weaknesses: [
                        "Higher fatigue cost than bike or elliptical — monitor PM session quality",
                        "Becomes quad-dominant instantly if technique breaks down",
                        "Cannot be used same day as Phase 2 lower body PM session (within 6 hours)",
                       ],
                       technique: "Long stride · Full hip extension at top of each step · Slight forward hinge from hips · Heel drive, not ball of foot · Controlled pace — slow and deliberate. NEVER tiny fast steps — that is quad work with no posterior chain benefit.")

            cardioTool("STATIONARY BIKE", "Gym A · 5:00–5:45 AM · 35–40 min · Zone 2",
                       chips: [("Low fatigue", Color.inkGreen), ("Best Z2 control", Color.inkGreen), ("Safe daily", Color.inkGreen)],
                       strengths: [
                        "Most predictable Zone 2 — resistance dials give precise control",
                        "Minimal leg fatigue — legs fresh for evening Forge session",
                        "Zero injury risk — foot-safe, low-impact",
                        "Zone 2 fat oxidation peaks when fasted and insulin is low",
                       ],
                       weaknesses: [
                        "Low glute stimulus — morphologically neutral on posterior chain",
                        "Caloric tool, not sculpting tool",
                       ],
                       technique: "HR 130–145 · Nasal breathing possible = true Zone 2 · If you cannot nasal breathe, reduce resistance · Fasted default")

            cardioTool("ELLIPTICAL", "Both gyms · moderate pace",
                       chips: [("Low impact", Color.inkAmber), ("Balanced", Color.inkAmber), ("Substitute tool", Color.textMuted)],
                       strengths: [
                        "Slightly more posterior chain than bike (gliding motion with hip extension)",
                        "Very low injury risk — guided, smooth motion",
                        "Useful when bike occupied or for variety",
                       ],
                       weaknesses: [
                        "Less sculpting specificity than stairmaster",
                        "Not a primary sculpting tool — use when other options not available",
                       ],
                       technique: "Good substitute or variety. Not worth a deliberate session slot over stairmaster or bike.")

            cardioTool("ROWING MACHINE", "Gym B · low intensity only",
                       chips: [("Conditional", Color.textMuted), ("Upper back carry", Color.textMuted), ("High systemic fatigue", Color.inkAmber)],
                       strengths: [
                        "Lat/rear delt stimulus from drive phase — can serve as low-intensity pull accessory",
                        "Full-body conditioning when used at low intensity",
                       ],
                       weaknesses: [
                        "High systemic fatigue if intensity rises — worst tool during specialization",
                        "Interference potential with PM pull sessions",
                        "Avoid during heavy shoulder specialization phases",
                       ],
                       technique: "Low intensity only (rate 18–22 spm). Use only as 15-min warm-up or finisher on non-pull days. Not a primary cardio tool during this phase.")

            // Placement rules
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "CARDIO PLACEMENT RULES", color: .textMuted, size: 10)
                    placementRow("Stairmaster", "Wed (no PM lower body) or Fri (PM is low-CNS). Never before Phase 2 posterior chain session.")
                    placementRow("Bike", "Flexible. Default AM tool. 10 min pre-PM as warm-up or 20 min post-PM.")
                    placementRow("Elliptical", "Injury or recovery days. Substitute only.")
                    placementRow("Rowing", "Non-pull days only, low intensity. Not a deliberate slot.")
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Total deliberate cardio: 3–4 sessions/week, 20–35 min. Hideout standing contributes to total energy expenditure — factor it into recovery budget.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 5. SCULPT

    var sculptSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkAmber).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "SCULPT PRIORITIES — SELECTIVE HYPERTROPHY", color: .inkGreen, size: 10)
                    }
                    Text("Forge is the base. These are the specific areas requiring deliberate emphasis and active suppression. 10 years of training = diminishing returns everywhere except targeted weak points.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                }
            }
            .padding(.horizontal, metrics.hPad)

            sculptCard2("01", "Lateral Deltoids",
                       why: "The primary driver of shoulder width. Lateral delt development creates the 3D capped appearance that defines the pole-vaulter shoulder line. Cannot be replaced by front delt or trap development — those work against the target silhouette.",
                       movements: "Cable behind-body raise · DB lateral (thumbs-down, slight lean) · Machine lateral · Leaning DB lateral",
                       frequency: "3× per week minimum. 20–24 sets weekly. High frequency, high volume — this muscle responds to it.",
                       mechanism: "Cable keeps tension in shortened position (where DB raises go slack). Thumbs-down rotation internally rotates humerus, removing anterior delt from the drive. Slight forward lean removes front delt from the top-of-range cheat.",
                       color: .inkGreen)

            sculptCard2("02", "Rear Deltoids",
                       why: "Creates the 3D depth visible from the side and behind. Without rear delt development, shoulders look flat from every angle except straight ahead. Also prevents anterior delt dominance from pulling shoulders into internal rotation.",
                       movements: "Reverse pec deck · Face pull (elbows high) · Chest-supported rear delt raise · Cable cross rear fly · Band pull-apart",
                       frequency: "Every session as a finisher. 16–20 sets weekly. High reps (15–20) — rear delt responds to metabolic stress.",
                       mechanism: "Face pull with elbows high and external rotation hits all three heads of the posterior deltoid plus rotator cuff — corrective and morphological simultaneously.",
                       color: .inkGreen)

            sculptCard2("03", "Glute Max + Glute Med",
                       why: "The tennis player / sprinter shape requires both. Glute max = fullness and power. Glute med = the upper outer shape that creates the high, round appearance visible from rear. Most training programs only develop glute max.",
                       movements: "Glute max: hip thrust, RDL, Bulgarian split (Phase 2). Glute med: cable abductions, banded clamshells, lateral band walk, Stairmaster (correct technique).",
                       frequency: "Current: daily AM activation 15–20 min. Phase 2: 2× per week dedicated, 16–20 sets.",
                       mechanism: "Hip thrust provides the only loading range sufficient for glute max hypertrophy over 12+ weeks. Track load weekly — this is the progressive overload anchor for the glute phase.",
                       color: .violetLight)

            sculptCard2("04", "Hamstrings / Posterior Chain",
                       why: "The rugby/sprinter silhouette from behind. Hamstring development visible from the rear separates 'big legs' from 'athletic legs.' Most hypertrophy programs under-develop hamstrings relative to quads.",
                       movements: "Romanian deadlift (full stretch — the eccentric is the stimulus) · Nordic curl · Lying leg curl · B-stance RDL",
                       frequency: "Phase 2: 2× per week, 10–14 sets. Prioritize the stretch position — shortened hamstring work produces significantly less hypertrophy.",
                       mechanism: "Hamstring hypertrophy is driven primarily by loaded eccentric in the lengthened position (hip flexed + knee extended). RDL stop point: just below kneecap, not floor.",
                       color: .violetLight)

            sculptCard2("05", "Upper Chest (Clavicular Head)",
                       why: "Incline-loaded upper chest creates the clavicular shelf that frames the lean torso. Flat bench develops the sternal head — present, not the priority. The specific gap: clavicular head underdeveloped from a training history dominated by flat work.",
                       movements: "Incline DB press 30–45° · High-to-low cable fly · Incline DB fly · Low-angle machine press",
                       frequency: "2× per week, 14 sets total. Begin each chest session with incline — always. Never warm up with flies (pre-fatigues stabilizers).",
                       mechanism: "30° incline: maximum clavicular head recruitment, minimal anterior delt. 45°: upper boundary. Above 45° = shoulder pressing. The fiber angle cannot be exploited beyond that threshold.",
                       color: .inkAmber)

            sculptCard2("06", "Serratus Anterior",
                       why: "The finger-like striations below the lat sweep. Visible at sub-10% BF. This muscle is currently being undertrained. Two things must happen simultaneously: drop body fat AND add protraction work. Cannot rush it above 10% BF.",
                       movements: "Straight-arm pulldown (full protraction at bottom) · Pushup plus (scapular protraction at top) · Cable punches · Wall slides",
                       frequency: "Add 2–3 sets to end of every chest day and every pull day. Zero fatigue cost — this is protraction work, not a loaded exercise.",
                       mechanism: "Serratus is activated by scapular protraction under load. The full end-range of a pushup — where most people stop short — is the activation position. Add 2 seconds of protraction hold at top.",
                       color: .inkAmber)

            sculptCard2("07", "Calves",
                       why: "Proportional, not dominant. Athletic development without bodybuilding calf focus. Gastrocnemius (visible head) responds to full range, lower rep work.",
                       movements: "Standing calf raise — full range (heels below parallel at bottom, full extension at top). Seated calf for soleus.",
                       frequency: "3× per week, 12–15 sets. Calves need frequency and range — not just load.",
                       mechanism: "Calves rarely grow from compound work alone — direct loading required. Full ROM is mandatory: the stretch at the bottom activates more motor units than partial range pressing.",
                       color: .textMuted)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 7. SKIN — even tone · Miami · daily reference

    var skinSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "EVEN TONE · COMBINATION SKIN", color: .inkGreen, size: 10)
                    }
                    Text("Normal-to-combination. T-zone reads oily in Miami heat; cheeks and jaw more balanced. Goal: even tone and texture — not a product collection. Daily execution lives in Today → Whole Human Reset and Shutdown Preservation.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Visible change: ~6–8 weeks of consistent rotation. Patch test new actives. Post-workout: cleanse face — sweat + SPF residue accelerates uneven tone.")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "MORNING — 5–7 MIN", color: .inkGreen, size: 10)
                    skinStepRow("1", "Cleanse", "Cetaphil · lukewarm · 60–90 sec · pat dry")
                    skinStepRow("2", "Vitamin C", "10–15% L-ascorbic · 3–5 drops · wait 30–60 sec")
                    skinStepRow("3", "Moisturizer", "Light · face + neck · damp skin")
                    skinStepRow("4", "SPF", "Two-finger dose · face, neck, ears, hands · last step")
                    Text("Morning sunlight at Hideout (6:40) happens before SPF — intentional. Apply SPF after that window.")
                        .font(metrics.fontSora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "PM WEEKLY ROTATION", color: .inkGreen, size: 10)
                    Text("One treatment per night. Never stack retinol + exfoliant same night.")
                        .font(metrics.fontSora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                    skinRotationRow("Mon", "Niacinamide", "10% · press into dry skin after cleanse")
                    skinRotationRow("Tue", "Glycolic AHA", "8–10% · thin layer · dry face")
                    skinRotationRow("Wed", "Retinol", "Pea-sized · dry skin 10 min post-cleanse")
                    skinRotationRow("Thu", "Niacinamide", "Same as Monday")
                    skinRotationRow("Fri", "BHA", "Paula's Choice · pores + texture")
                    skinRotationRow("Sat", "Retinol", "Same as Wednesday")
                    skinRotationRow("Sun", "Rest", "Cleanse + moisturizer only")
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "TONE + TEXTURE NOTES", color: .textMuted, size: 10)
                    signalRow("Post-shave bumps", "Single-blade or electric where possible. Azelaic acid 10% on irritated zones — not same night as retinol.", .inkAmber)
                    signalRow("Under-eye dullness", "Caffeine eye cream · ring finger · rice-grain amount · before moisturizer.", .inkGreen)
                    signalRow("Still uneven after 8 weeks", "Optional: alpha arbutin on non-retinol nights — pigmentation-specific, not daily default.", .inkAmber)
                    signalRow("Body lotion timing", "Within 3 min of shower on damp skin — elbows, feet, shins. Same rule as face.", .inkGreen)
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    private func skinStepRow(_ step: String, _ label: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: metrics.rowSpacing) {
            Text(step)
                .font(metrics.fontMono(11))
                .foregroundColor(.inkGreen.opacity(0.7))
                .frame(width: metrics.scaledSize(18))
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(metrics.fontSora(14, weight: .medium))
                    .foregroundColor(.textPrimary)
                Text(detail)
                    .font(metrics.fontSora(12, weight: .light))
                    .foregroundColor(.textMuted)
                    .lineSpacing(2)
            }
        }
    }

    private func skinRotationRow(_ day: String, _ treatment: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            Text(day.uppercased())
                .font(metrics.fontMono(10))
                .foregroundColor(.inkGreen)
                .frame(width: metrics.scaledSize(36), alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(treatment)
                    .font(metrics.fontSora(13, weight: .medium))
                    .foregroundColor(.textPrimary)
                Text(detail)
                    .font(metrics.fontSora(11, weight: .light))
                    .foregroundColor(.textMuted)
            }
            Spacer()
        }
    }

    // MARK: - 8. SIGNALS

    var adherenceSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "ARCHITECTURE SIGNALS — BODY READOUT", color: .inkGreen, size: 10)
                    }
                    Text("Not adherence checkboxes. Sensory and visual signals that tell you whether the architecture is executing correctly. Forge tracks what you did. This reads what it's producing.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Positive signals
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "GREEN SIGNALS — STRUCTURE REVEALING", color: .inkGreen, size: 10)
                    signalRow("Jawline sharper in weekly photos", "Facial structure revealing. Do not chase a caliper number if visual read is improving.", .inkGreen)
                    signalRow("Less facial puffiness at same scale weight", "Hydration, food volume, or sleep correction landing — not necessarily more deficit.", .inkGreen)
                    signalRow("Shoulders look wider in photos than 4 weeks ago", "Lateral delt stimulus is landing. Continue.", .inkGreen)
                    signalRow("Rear of shoulder visible from side view", "Rear delt volume is cumulative. Don't stop.", .inkGreen)
                    signalRow("Waist looks narrower without weight change", "TVA resting tone improving. Vacuum work is registering.", .inkGreen)
                    signalRow("PM sessions feel strong despite the cut", "Pre-lift carb execution is correct. Glycogen is being protected.", .inkGreen)
                    signalRow("Core routine consistent (4–6×/wk)", "Legacy staple working. Before AM glute activation.", .inkGreen)
                    signalRow("AM glute activation consistent (4–5×/wk)", "Prescribed Phase 1 architecture — after core, before cardio.", .inkGreen)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Warning signals
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "AMBER SIGNALS — ARCHITECTURE DRIFT", color: .inkAmber, size: 10)
                    signalRow("Face looks soft at same body fat", "Audit sleep, sodium swings, food volume, stress before cutting calories.", .inkAmber)
                    signalRow("Front of shoulder sore after chest day", "Incline angle has crept above 35°. Press is becoming shoulder press.", .inkAmber)
                    signalRow("Shoulder sessions feel like chest sessions", "Exercise order is wrong. Lateral isolation must come before pressing.", .inkAmber)
                    signalRow("Stairmaster legs feel like quad work", "Technique breakdown. Long stride and heel drive — not rapid tiny steps.", .inkAmber)
                    signalRow("Muscles looking flat despite no weight change", "Glycogen depletion. Pre-lift carb is being missed or cut sessions are too aggressive.", .inkAmber)
                    signalRow("PM sessions feeling weaker week over week", "Recovery ceiling being hit. Check Stairmaster frequency and sleep quality first.", .inkAmber)
                    signalRow("Upper traps feel sore after shoulder day", "Something with upper trap recruitment has crept in. Audit: upright row? Shrugs? High-trap pressing angle?", .inkAmber)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // TVA — kept as zero-cost non-negotiable
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack {
                        MonoLabel(text: "TVA VACUUM — ZERO FATIGUE COST", color: .inkAmber, size: 10)
                        Spacer()
                        MonoLabel(text: "START IMMEDIATELY", color: .inkGreen, size: 9)
                    }
                    Text("TVA resting tone is trainable without adding oblique circumference. Daily practice compresses the waist from inside. Measurable circumference reduction within 4–6 weeks. This is the highest-ROI non-session action in the entire protocol.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Stomach vacuum 3×30–60s · Exhale fully · Navel to spine · Hold · Breathe lightly · Morning fasted window")
                        .font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkAmber).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Forge future note
            CardView(style: .secondary) {
                HStack(alignment: .top, spacing: metrics.blockSpacing) {
                    Rectangle().fill(Color.textMuted.opacity(0.3)).frame(width: 2)
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "FUTURE — FORGE × PHYSIQUE INTEGRATION", color: .textMuted, size: 10)
                        Text("Eventually Forge will send completed training data to Physique. Physique will interpret whether the architecture is being executed — not just whether sessions happened, but whether the right muscles are being prioritized in the right order at the right frequency. When that pipeline exists, this section becomes the interpretation layer.")
                            .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2.5)
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 7. FAILURES

    var failuresSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkAmber).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "FAILURE MODES — ARCHITECTURE COLLAPSE", color: .inkAmber, size: 10)
                    }
                    Text("These are the specific ways this architecture fails. Not generic fitness mistakes — the exact failure signatures of this schedule, this body, this protocol.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                }
            }
            .padding(.horizontal, metrics.hPad)

            failCard2("01", "Doing too much because compliance is high",
                     "High compliance does not imply infinite recovery. At 4 AM wake, active Hideout shift, caloric deficit, and PM lifting — the recovery ceiling is 65–80 true weekly sets. Adding volume because 'it feels manageable' accumulates a debt that shows up 3 weeks later as stalled progress and persistent flatness.",
                     "Volume budget is fixed. When sessions feel easy, add intensity (tempo, less rest) not sets.", true)

            failCard2("02", "Skipped pre-lift carb",
                     "After a 10-hour active Hideout shift, muscle glycogen is partially depleted. Lifting in this state produces strength regression that looks like 'the cut is working.' Chronically, this means losing muscle rather than fat. The sourdough at 4:45 is the single highest-consequence missed action in the entire protocol.",
                     "Pack it in the bag every morning. Not a decision — a system.", true)

            failCard2("03", "Sleep compression",
                     "4 AM wake + 9:30 PM sleep = 6.5 hour ceiling. Any disruption below 6 hours elevates cortisol, suppresses GH release, and directly impairs fat loss regardless of perfect nutrition. The hormonal environment during sleep is a required input for the cut to work.",
                     "9:15 PM hard stop. If shift runs late and home after 8:30 PM, skip next morning's cardio. Sleep takes priority over cardio, always.", true)

            failCard2("04", "Stairmaster fatigue degrading PM session",
                     "Stairmaster is a higher-fatigue tool than bike. Used too frequently or at too high intensity, it degrades evening Forge Breechay quality. In Phase 2: any Stairmaster within 6 hours of a posterior chain PM session will measurably reduce hip thrust performance.",
                     "Monitor: if squat/hip thrust strength drops over 2 consecutive weeks while Stairmaster frequency is high, reduce Stairmaster first.", false)

            failCard2("05", "Anterior delt dominance creeping back",
                     "Any overhead pressing with pronated grip + flat pressing + upright rows continuously feeds the anterior head. If incline angle creeps above 45° 'for more upper chest,' the session has become shoulder pressing. The 3D shoulder appearance requires suppressing what already works in favor of what doesn't yet.",
                     "If front of shoulder is sore after chest day, incline is too steep. If shoulder day feels like pressing, order is wrong.", false)

            failCard2("06", "Flattening instead of sculpting",
                     "Severe caloric deficit depletes muscle glycogen. Muscles look flat, 'deflated,' smaller. This looks like the cut working but is glycogen depletion masking muscle fullness. At 8–10% BF this resolves — but aggressive carb restriction accelerates it and creates false negative feedback.",
                     "Deficit comes from overall calories, not from stripping carbs around training. Pre and post-lift carbs are non-negotiable.", false)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 8. ADJUSTMENTS

    var adjustSection: some View {
        VStack(spacing: metrics.blockSpacing) {

            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    HStack(spacing: metrics.cardSpacing) {
                        Rectangle().fill(Color.inkAmber).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "DECISION TREES — WHEN RESULTS STALL", color: .inkGreen, size: 10)
                    }
                    Text("Answer in order. Do not change the plan until execution is confirmed as the variable. Data-driven correction only.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            adjustCard2("STRUCTURE NOT REVEALING", [
                ("Is visual quality improving in weekly photos?", "If yes while scale stalls — cut is working. Do not chase a BF number.", false),
                ("Is core routine consistent (4–6×/wk · 2–3 rounds)?", "No → restore legacy staple before changing macros.", false),
                ("Is 7-day cardio adherence above 85%?", "No → execution is the variable. Close the adherence gap before changing anything.", false),
                ("Is pre-lift carb being executed 6/7 days?", "No → glycogen depletion masking muscle and slowing metabolism. Fix this first.", false),
                ("Is sleep averaging 6+ hours over 7 days?", "No → hormonal suppression is the primary fat-loss inhibitor. Sleep fix outranks everything.", false),
                ("Audit hydration, sodium, food volume before cutting calories?", "Face and midsection read governed by conditions — not deficit alone.", false),
                ("All confirmed, stall continues 2+ weeks?", "Reduce by 150 kcal. Remove from carbs outside training windows. Protect pre and post-lift carbs.", true),
            ])

            adjustCard2("SHOULDER WIDTH NOT IMPROVING", [
                ("Are lateral raises in every session?", "No → add them. Lateral delts require 3× per week minimum to grow visibly.", false),
                ("Are you using cables or consistent resistance?", "Dumbbells at bottom of lateral raise = zero tension. Cable or band = consistent tension through range.", false),
                ("Is body fat still above 12%?", "Shoulder width = body fat + lateral delt equation. Cut first, then assess.", false),
                ("Technique and adherence confirmed but no response?", "Add leaning lateral raises. Upright rows contraindicated — but Y-raises and cable cross-body behind hip are alternatives.", true),
            ])

            adjustCard2("GLUTE SHAPE NOT IMPROVING", [
                ("Is Stairmaster in weekly rotation with correct technique?", "No → bike and elliptical do not produce posterior chain stimulus for glute shape.", false),
                ("Is Stairmaster technique correct?", "Long stride, hip extension at top, heel drive. If not, same cardio session = quad work, zero glute benefit.", false),
                ("Is glute med being trained specifically (Phase 1)?", "Cable abductions, banded lateral walks, clamshells? Glute max = fullness. Glute med = the high round shape.", false),
                ("Phase 2 technique confirmed, no response?", "Increase hip thrust frequency. Add RDLs. Stairmaster 3× per week. 6-week minimum before assessing.", true),
            ])

            adjustCard2("STRENGTH DROPPING ON CUT", [
                ("Is pre-lift carb being executed?", "This is almost always the cause. Fix the 4:45 PM sourdough before anything else.", false),
                ("Is total protein above 190g/day?", "Below 190g, the body sources amino acids from muscle tissue on a deficit.", false),
                ("Is sleep averaging 6+ hours?", "GH and testosterone suppression from sleep debt directly impairs strength.", false),
                ("All confirmed, still dropping?", "Increase by 150–200 kcal from carbs. Accept slower fat loss to preserve muscle. At sub-12% BF, muscle retention outweighs pace.", true),
            ])

            adjustCard2("GYM A (50 LB) BECOMING THE LIMITING FACTOR", [
                ("Are lateral raises hitting 35–40 lbs?", "Move shoulder sessions to Gym B for heavier DBs and cable access.", false),
                ("Is incline press at 50 lb per hand?", "Gym B dumbbells (70–80 lbs) needed for continued upper chest progression.", false),
                ("Do you need machine rear delt / reverse pec deck?", "Gym B has this. Gym A likely does not. Solo shoulder sessions can migrate.", false),
                ("Tim sessions at Gym A still valuable?", "Yes — social architecture doesn't change. Tim stays at Gym A. Gym B absorbs solo specialization.", true),
            ])

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    func leverageRow(_ num: Int, _ label: String, _ value: Double, _ note: String) -> some View {
        let barH: CGFloat = metrics.isIPad ? 8 : 4
        let labelW: CGFloat = metrics.isIPad ? 200 : 160
        return HStack(spacing: metrics.rowSpacing) {
            Text("\(num)")
                .font(metrics.fontMono(11))
                .foregroundColor(.textMuted)
                .frame(width: metrics.scaledSize(18))
            Text(label)
                .font(metrics.fontSora(14, weight: .medium))
                .foregroundColor(.textPrimary)
                .frame(width: labelW, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(height: barH)
                    RoundedRectangle(cornerRadius: 2).fill(Color.inkGreen)
                        .frame(width: geo.size.width * CGFloat(value), height: barH)
                }
            }
            .frame(height: barH)
            Text(note)
                .font(metrics.fontSora(12, weight: .light))
                .foregroundColor(.textMuted)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, metrics.isIPad ? 6 : 4)
    }

    func morphRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            Text(key)
                .font(.system(size: metrics.scaledSize(11), weight: .semibold, design: .monospaced))
                .foregroundColor(.inkGreen)
                .frame(width: 100, alignment: .leading)
            Rectangle().fill(Color.muted.opacity(0.25)).frame(width: 0.5).padding(.top, 3)
            Text(value).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2.5).fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }

    func visualSignalRow(_ label: String) -> some View {
        HStack(alignment: .top, spacing: metrics.rowSpacing) {
            Text("·").font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkGreen)
            Text(label).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2)
        }
    }

    func coreMoveRow(_ reps: String, _ movement: String) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            Text(reps)
                .font(.system(size: metrics.scaledSize(11), weight: .semibold, design: .monospaced))
                .foregroundColor(.inkGreen)
                .frame(width: 56, alignment: .leading)
            Text(movement)
                .font(metrics.fontSora(13, weight: .light))
                .foregroundColor(.textSecond)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }

    func suppressRow(_ title: String, _ reason: String) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            RoundedRectangle(cornerRadius: 1.5).fill(Color.inkRed.opacity(0.7)).frame(width: 3, height: 32)
            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                Text(title).font(metrics.fontSora(13, weight: .semibold)).foregroundColor(.textPrimary)
                Text(reason).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
            }
        }
        .padding(.vertical, 2)
    }

    func cutCol(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
            Text(label).font(.system(size: metrics.scaledSize(10), design: .monospaced)).foregroundColor(.textMuted).tracking(0.3).lineSpacing(2)
            Text(value).font(.system(size: metrics.scaledSize(13), weight: .semibold, design: .monospaced)).foregroundColor(.textPrimary).lineSpacing(2)
        }
    }

    func divider() -> some View {
        Rectangle().fill(Color.muted.opacity(0.2)).frame(width: 0.5, height: 40).padding(.horizontal, 10)
    }

    func slotCol(_ label: String, _ desc: String) -> some View {
        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
            MonoLabel(text: label, color: .textMuted, size: 9)
            Text(desc).font(metrics.fontSora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(2.5)
        }
        .frame(width: 90, alignment: .leading)
    }

    func mealRailView() -> some View {
        VStack(spacing: metrics.cardSpacing) {
            mealRailRow2("4:05", "Wake + creatine", "Water only. Fasted.", false)
            mealRailRow2("5:15", "Post-cardio", "Protein shake in oat milk.", false)
            mealRailRow2("9:30", "First solid meal", "Chicken · eggs · banana · greens.", false)
            mealRailRow2("1:30", "Midday", "Chicken · arugula · olive oil. No starch.", false)
            mealRailRow2("4:45", "Pre-lift ← CRITICAL", "Sourdough (2 slices) + nut butter.", true)
            mealRailRow2("6:30", "Post-lift", "Shake + banana or watermelon.", false)
            mealRailRow2("7:30", "Final meal", "Chicken · avocado · greens. Kitchen closes 8:30.", false)
        }
    }

    func mealRailRow2(_ time: String, _ name: String, _ detail: String, _ critical: Bool) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            VStack(spacing: metrics.cardSpacing) {
                Circle().fill(critical ? Color.inkAmber : Color.inkGreen.opacity(0.5)).frame(width: 5, height: 5).padding(.top, 5)
                Rectangle().fill(Color.surface2).frame(width: 1).frame(maxHeight: .infinity)
            }.frame(width: 5)
            HStack(alignment: .top) {
                MonoLabel(text: time, color: critical ? .inkAmber : .textMuted, size: 9).frame(width: 32, alignment: .leading)
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    Text(name).font(metrics.fontSora(13, weight: critical ? .semibold : .medium)).foregroundColor(critical ? .inkAmber : .textPrimary)
                    Text(detail).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond)
                }
            }.padding(.bottom, 10)
            Spacer()
        }
    }

    enum CarbSig { case good, neutral, critical }

    func carbRow2(_ label: String, _ text: String, _ sig: CarbSig) -> some View {
        let c: Color = sig == .critical ? .inkAmber : sig == .good ? .inkGreen : .textMuted
        return HStack(alignment: .top, spacing: metrics.cardSpacing) {
            Circle().fill(c.opacity(0.7)).frame(width: 5, height: 5).padding(.top, 5)
            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                Text(label).font(metrics.fontSora(13, weight: .medium)).foregroundColor(.textPrimary)
                Text(text).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    func archShiftRow(_ label: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            MonoLabel(text: label, color: .inkGreen, size: 9).frame(width: 80, alignment: .leading)
            Text(description).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
        }
    }

    func signalRow(_ label: String, _ interpretation: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            RoundedRectangle(cornerRadius: 1.5).fill(color.opacity(0.7)).frame(width: 3, height: 32)
            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                Text(label).font(metrics.fontSora(13, weight: .medium)).foregroundColor(.textPrimary).lineSpacing(1.5).fixedSize(horizontal: false, vertical: true)
                Text(interpretation).font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
    }

    func volumeTableRow(_ muscle: String, _ sets: String, _ note: String, _ color: Color) -> some View {
        HStack(spacing: metrics.cardSpacing) {
            Text(muscle).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).frame(width: 130, alignment: .leading)
            Text(sets).font(.system(size: metrics.scaledSize(12), weight: .semibold, design: .monospaced)).foregroundColor(color).frame(width: 80, alignment: .leading)
            Text(note).font(metrics.fontSora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(1.5).fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(.vertical, 4)
    }

    func cardioTool(_ name: String, _ timing: String, chips: [(String, Color)], strengths: [String], weaknesses: [String], technique: String) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                MonoLabel(text: name, color: .textPrimary, size: 10)
                MonoLabel(text: timing, color: .textMuted, size: 9)
                HStack(spacing: metrics.rowSpacing) {
                    ForEach(chips, id: \.0) { label, color in
                        Text(label).font(.system(size: metrics.scaledSize(10), design: .monospaced)).foregroundColor(color)
                            .padding(.horizontal, 7).padding(.vertical, 3).background(color.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "STRENGTHS", color: .inkGreen, size: 9)
                    ForEach(strengths, id: \.self) { s in
                        HStack(alignment: .top, spacing: metrics.rowSpacing) {
                            Text("+").font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkGreen)
                            Text(s).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "WEAKNESSES / RISKS", color: .inkAmber, size: 9)
                    ForEach(weaknesses, id: \.self) { w in
                        HStack(alignment: .top, spacing: metrics.rowSpacing) {
                            Text("−").font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.inkAmber)
                            Text(w).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                Text(technique).font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    func placementRow(_ tool: String, _ rule: String) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            MonoLabel(text: tool, color: .textMuted, size: 9).frame(width: 70, alignment: .leading)
            Text(rule).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
        }
    }

    func sculptCard2(_ priority: String, _ muscle: String, why: String, movements: String, frequency: String, mechanism: String, color: Color) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                    MonoLabel(text: priority, color: color, size: 11)
                    Text(muscle).font(metrics.fontSora(15, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                }
                Text(why).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "MOVEMENTS", color: .textMuted, size: 9).frame(width: 72, alignment: .leading)
                    Text(movements).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "FREQUENCY", color: .textMuted, size: 9).frame(width: 72, alignment: .leading)
                    Text(frequency).font(metrics.fontSora(13, weight: .light)).foregroundColor(color).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "MECHANISM", color: .textMuted, size: 9).frame(width: 72, alignment: .leading)
                    Text(mechanism).font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    func failCard2(_ num: String, _ title: String, _ mechanism: String, _ correction: String, _ critical: Bool) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                    MonoLabel(text: num, color: critical ? .inkAmber : .textMuted, size: 11)
                    Text(title).font(metrics.fontSora(14, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                    if critical { MonoLabel(text: "HIGH RISK", color: .inkAmber, size: 8) }
                }
                Text(mechanism).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "→", color: .inkGreen, size: 11)
                    Text(correction).font(metrics.fontSora(13, weight: .light)).foregroundColor(.inkGreen).lineSpacing(2.5).fixedSize(horizontal: false, vertical: true)
                }
                .padding(8).background(Color.inkGreen.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    func adjustCard2(_ title: String, _ questions: [(String, String, Bool)] = [], _ questionsNoFlag: [(String, String)] = []) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                MonoLabel(text: title, color: .inkAmber, size: 10)
                ForEach(questions.indices, id: \.self) { i in
                    let (q, a, isConclusion) = questions[i]
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        HStack(alignment: .top, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "\(i+1).", color: isConclusion ? .inkGreen : .textMuted, size: 10)
                            Text(q).font(metrics.fontSora(13, weight: .light)).foregroundColor(.textPrimary).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                        }
                        Text(a).font(.system(size: metrics.scaledSize(11), design: .monospaced)).foregroundColor(isConclusion ? .inkGreen : .textMuted)
                            .lineSpacing(2.5).padding(.leading, 18).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    // Overloaded version without third param
    func adjustCard2(_ title: String, _ questions: [(String, String, Bool)]) -> some View {
        adjustCard2(title, questions, [])
    }

    private func physiqueSectionChip(_ i: Int) -> some View {
        Button(action: { withAnimation(.easeOut(duration: 0.18)) { selectedSection = i } }) {
            Text(sections[i].uppercased())
                .font(metrics.fontMono(9))
                .foregroundColor(selectedSection == i ? .bgBase : .textMuted)
                .tracking(0.5)
                .lineLimit(1)
                .padding(.horizontal, metrics.scaledSize(10))
                .padding(.vertical, metrics.scaledSize(7))
                .background(selectedSection == i ? Color.inkGreen : Color.surface2)
                .clipShape(RoundedRectangle(cornerRadius: metrics.cardRadius * 0.45))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Practice tracking (Core + AM activation)

    private var calendar: Calendar { Calendar.current }

    private func dayStart(_ date: Date = Date()) -> Date {
        calendar.startOfDay(for: date)
    }

    private func trailingSevenDays() -> [Date] {
        let today = dayStart()
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - 6, to: today)
        }
    }

    private func coreLog(on day: Date) -> CoreCompletionLog? {
        let target = dayStart(day)
        return coreLogs.first { dayStart($0.date) == target }
    }

    private func activationLog(on day: Date) -> AMActivationLog? {
        let target = dayStart(day)
        return activationLogs.first { dayStart($0.date) == target }
    }

    private var todayCoreRounds: Int {
        coreLog(on: Date())?.rounds ?? 0
    }

    private var todayActivationComplete: Bool {
        activationLog(on: Date())?.complete ?? false
    }

    private var coreDotGrid: some View {
        HStack(spacing: metrics.scaledSize(8)) {
            ForEach(trailingSevenDays(), id: \.self) { day in
                Circle()
                    .fill((coreLog(on: day)?.rounds ?? 0) >= 1 ? Color.inkGreen : Color.surface2)
                    .frame(width: metrics.scaledSize(8), height: metrics.scaledSize(8))
            }
            Spacer()
        }
    }

    private var activationDotGrid: some View {
        HStack(spacing: metrics.scaledSize(8)) {
            ForEach(trailingSevenDays(), id: \.self) { day in
                Circle()
                    .fill(activationLog(on: day)?.complete == true ? Color.inkTeal : Color.surface2)
                    .frame(width: metrics.scaledSize(8), height: metrics.scaledSize(8))
            }
            Spacer()
        }
    }

    private var coreCompletionTracker: some View {
        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
            MonoLabel(text: "LAST 7 DAYS", color: .textMuted, size: 9)
            coreDotGrid

            if todayCoreRounds >= 1 {
                HStack {
                    Text("Done · \(todayCoreRounds) rounds")
                        .font(.system(size: metrics.scaledSize(11), weight: .semibold, design: .monospaced))
                        .foregroundColor(.inkGreen)
                    Spacer()
                    Text("Change")
                        .font(.system(size: metrics.scaledSize(10), design: .monospaced))
                        .foregroundColor(.textMuted)
                }
                coreRoundPicker(selected: todayCoreRounds)
            } else {
                Text("Core done today?")
                    .font(metrics.fontSora(13, weight: .medium))
                    .foregroundColor(.textPrimary)
                coreRoundPicker(selected: 0)
            }
        }
    }

    private func coreRoundPicker(selected: Int) -> some View {
        HStack(spacing: metrics.scaledSize(8)) {
            ForEach(1...3, id: \.self) { round in
                Button(action: { saveCoreRounds(round) }) {
                    Text("\(round)")
                        .font(.system(size: metrics.scaledSize(12), weight: .medium, design: .monospaced))
                        .foregroundColor(selected == round ? .bgBase : .textMuted)
                        .frame(width: metrics.scaledSize(32), height: metrics.scaledSize(32))
                        .background(selected == round ? Color.inkGreen : Color.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
            if selected >= 1 {
                Button(action: { saveCoreRounds(0) }) {
                    Text("Clear")
                        .font(.system(size: metrics.scaledSize(10), design: .monospaced))
                        .foregroundColor(.textMuted)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    private func saveCoreRounds(_ rounds: Int) {
        let today = dayStart()
        if let existing = coreLog(on: today) {
            if rounds <= 0 {
                modelContext.delete(existing)
            } else {
                existing.rounds = rounds
                existing.createdAt = Date()
            }
        } else if rounds > 0 {
            let log = CoreCompletionLog()
            log.date = today
            log.rounds = rounds
            modelContext.insert(log)
        }
        try? modelContext.save()
    }

    private var activationCompletionTracker: some View {
        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
            MonoLabel(text: "LAST 7 DAYS", color: .textMuted, size: 9)
            activationDotGrid

            Button(action: { saveActivationComplete(!todayActivationComplete) }) {
                HStack {
                    Image(systemName: todayActivationComplete ? "checkmark.square.fill" : "square")
                        .font(.system(size: metrics.scaledSize(14), weight: .light))
                        .foregroundColor(todayActivationComplete ? .inkTeal : .textMuted)
                    Text(todayActivationComplete ? "Activation complete" : "Activation done?")
                        .font(metrics.fontSora(13, weight: .medium))
                        .foregroundColor(todayActivationComplete ? .inkTeal : .textPrimary)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func saveActivationComplete(_ complete: Bool) {
        let today = dayStart()
        if let existing = activationLog(on: today) {
            if complete {
                existing.complete = true
                existing.createdAt = Date()
            } else {
                modelContext.delete(existing)
            }
        } else if complete {
            let log = AMActivationLog()
            log.date = today
            log.complete = true
            modelContext.insert(log)
        }
        try? modelContext.save()
    }

    private func activationMoveRow(_ movement: String, _ dose: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: metrics.cardSpacing) {
            Text(movement)
                .font(metrics.fontSora(13, weight: .light))
                .foregroundColor(.textSecond)
                .lineSpacing(2)
            Spacer(minLength: 8)
            Text(dose)
                .font(.system(size: metrics.scaledSize(11), weight: .semibold, design: .monospaced))
                .foregroundColor(.inkTeal)
        }
    }
}
