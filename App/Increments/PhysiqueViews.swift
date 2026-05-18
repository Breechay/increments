import SwiftUI
import Foundation

// MARK: - PHYSIQUE TAB — Body Architecture Lab
// Multi-agent synthesis: A+B+D+E hybrid
// Selective hypertrophy + selective omission. Ratio management, not mass accumulation.
// Target: Olympic pole vaulter torso / tennis glutes / rugby posterior chain / sprinter leanness

struct PhysiqueTabView: View {
    @State private var selectedSection = 0
    @State private var expandedDay: String? = nil
    let sections = ["Target", "Cut", "Program", "Cardio", "Sculpt", "Signals", "Failures", "Adjust"]

    @Environment(\.appMetrics) private var metrics

    var body: some View {
        ZStack {
            AtmosphericBackground()
            VStack(spacing: 0) {

                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        MonoLabel(text: "PHYSIQUE LAB", color: .inkGreen, size: 10)
                        Text("Body Architecture")
                            .font(.sora(22, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        HStack(spacing: 6) {
                            Text("FORGE EXECUTES")
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(.inkAmber)
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(Color.inkAmber.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            Text("PHYSIQUE GOVERNS")
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(.inkGreen)
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(Color.inkGreen.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        MonoLabel(text: "~12–13% BF", color: .textMuted, size: 9)
                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.inkGreen)
                        MonoLabel(text: "8–10% GOAL", color: .inkGreen, size: 9)
                    }
                }
                .padding(.horizontal, metrics.hPad).padding(.top, 20).padding(.bottom, 12)

                // Scrollable pill tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(sections.indices, id: \.self) { i in
                            Button(action: { withAnimation(.easeOut(duration: 0.18)) { selectedSection = i } }) {
                                Text(sections[i])
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .tracking(0.5)
                                    .foregroundColor(selectedSection == i ? .bgBase : .textMuted)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(selectedSection == i ? Color.inkGreen : Color.surface2)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.horizontal, metrics.hPad)
                }
                .padding(.bottom, 14)

                ScrollView(showsIndicators: false) {
                    Group {
                        switch selectedSection {
                        case 0: targetSection
                        case 1: cutSection
                        case 2: programSection
                        case 3: cardioSection
                        case 4: sculptSection
                        case 5: adherenceSection
                        case 6: failuresSection
                        default: adjustSection
                        }
                    }
                    .adaptiveContentWidth(metrics)
                }
            }
        }
    }

    // MARK: - 1. TARGET

    var targetSection: some View {
        VStack(spacing: 12) {

            // Governing insight
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 36).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "GOVERNING INSIGHT — MULTI-AGENT SYNTHESIS", color: .inkGreen, size: 10)
                            Text("Ratio management, not mass acquisition.")
                                .font(.sora(15, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                    }
                    Text("The raw material is already there. The task is: suppress what's wrong, accelerate what's right, let leanness unmask what already exists.")
                        .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Fastest visual ROI: drop from 12–13% → 9–10% while building lateral delt cap simultaneously. These two levers change perception faster than any other combination.")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.inkGreen).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Priority ranking
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    MonoLabel(text: "VISUAL LEVERAGE RANKING", color: .textMuted, size: 10)
                    leverageRow(1, "Shoulder width / 3D cap", 0.98, "Fastest ratio shift. Lateral + rear delt.")
                    leverageRow(2, "Leanness (8–10% BF)", 0.90, "Unlocks serratus, abs, sternal line.")
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
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        MonoLabel(text: "MORPHOLOGY BRIEF", color: .textMuted, size: 10)
                        Spacer()
                        MonoLabel(text: "UPPER BODY", color: .inkGreen, size: 9)
                    }
                    morphRow("Reference", "Olympic pole vaulter — extreme torso leanness, 3D shoulder development, visible musculature without mass.")
                    morphRow("Shoulders", "Broad, 3D, capped lateral delts. Rear delt visible from the side. Anterior delt suppressed.")
                    morphRow("Clavicle shelf", "Visible at 8–10% BF. Cut milestone, not training milestone.")
                    morphRow("Upper chest", "Clavicular head presence. Incline-dominant, 30–45°. Not flat-press dominant.")
                    morphRow("Serratus", "Finger-like striations below lat. Appears at sub-10% BF. BF-gated + protraction training.")
                    morphRow("Abs", "Present. Covered. Cut reveals them — not more ab work.")
                    morphRow("Waist", "Narrow. TVA resting tone is trainable without adding circumference.")
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
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
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "INTENTIONAL SUPPRESSION LIST", color: .inkAmber, size: 10)
                    Text("These are not neglected — they are actively limited.")
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted)
                    VStack(spacing: 6) {
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
        VStack(spacing: 12) {

            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "CUT PROTOCOL — ACTIVE", color: .inkGreen, size: 10)
                    }
                    HStack(spacing: 0) {
                        cutCol("CALORIES\nWORKDAYS", "2,200\n–2,350")
                        divider()
                        cutCol("CALORIES\nBASE DAYS", "1,900\n–2,100")
                        divider()
                        cutCol("PROTEIN\nEVERY DAY", "190–210g")
                        divider()
                        cutCol("RATE\nTARGET", "0.5–0.75\nlb/week")
                        Spacer()
                    }
                    Text("~2,650 kcal estimated maintenance. Do not cut below 1,900 kcal. Rate above 1 lb/week = muscle loss risk — add 200 kcal. Rate below 0.5 lb/week after 2 weeks of confirmed adherence = reduce by 150 kcal.")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 14) {
                    MonoLabel(text: "MEAL TIMING — WORKDAY (WED–SUN)", color: .textMuted, size: 10)
                    mealRailView()
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "CARB TIMING LOGIC", color: .textMuted, size: 10)
                    carbRow2("Fasted cardio 4:30 AM", "Zone 2 fat oxidation peaks when insulin is low. No pre-cardio carbs. Override: half banana if body battery <30 or HRV suppressed.", .good)
                    carbRow2("9:30 AM banana", "First carb of the day. Liver glycogen restoration after fasted cardio without spiking insulin aggressively.", .neutral)
                    carbRow2("1:30 PM — no starch", "Protein + fat only. Keeps insulin low through afternoon, extending fat-burn window.", .neutral)
                    carbRow2("4:45 PM sourdough ←", "Pre-lift glycogen prime. Determines Forge session quality. After a 10-hour active shift, glycogen is partially depleted — this is not optional.", .critical)
                    carbRow2("6:30 PM fruit post-lift", "Rapid glycogen replenishment. High-GI post-exercise is appropriate — muscle glucose uptake is elevated.", .good)
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "PRE-LIFT CARB — MOST CRITICAL SINGLE ACTION", color: .inkAmber, size: 10)
                    Text("Chronically lifting glycogen-depleted after an 8-hour active shift produces strength regression that looks like 'the cut is working.' You're losing muscle, not fat. The sourdough at 4:45 is what separates fat loss from fat-and-muscle loss.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Pack it in the bag every morning. This is not a decision — it is a system.")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.inkAmber).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 3. PROGRAM

    var programSection: some View {
        VStack(spacing: 12) {

            // Phase status
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "PROGRAM ARCHITECTURE — PHASE 1 ACTIVE", color: .inkGreen, size: 10)
                    }
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "PHASE", color: .textMuted, size: 9)
                            Text("1 of 2").font(.system(size: 13, weight: .semibold, design: .monospaced)).foregroundColor(.inkAmber)
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(width: 0.5, height: 30)
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "CONSTRAINT", color: .textMuted, size: 9)
                            Text("Injury-modified").font(.system(size: 13, weight: .semibold, design: .monospaced)).foregroundColor(.textPrimary)
                        }
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(width: 0.5, height: 30)
                        VStack(alignment: .leading, spacing: 3) {
                            MonoLabel(text: "DURATION", color: .textMuted, size: 9)
                            Text("~2–3 wks").font(.system(size: 13, weight: .semibold, design: .monospaced)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Daily structure
            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "DAILY STRUCTURE", color: .inkGreen, size: 10)
                    Text("2.5 exposures per day. Not 3 full sessions. The third slot fires only for a specific purpose — serratus, TVA, or targeted micro-pump. Most days: 2 exposures.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    HStack(spacing: 0) {
                        slotCol("AM 4:30–5:10", "Activation\nGlute primer\nLow fatigue")
                        slotCol("PM 5:30+", "Primary\nHypertrophy\nHigh signal")
                        slotCol("Optional 3rd", "Sculpt micro\n10–15 min\nVery low cost")
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Phase 1 context
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        MonoLabel(text: "PHASE 1 — CURRENT (INJURY-MODIFIED)", color: .inkAmber, size: 10)
                        Spacer()
                        MonoLabel(text: "~3 WEEKS", color: .textMuted, size: 9)
                    }
                    Text("Aggressive upper body. Protected lower body. This is a specialization block — forced prioritization is actually favorable for shoulder and upper chest development. Lower body is preserved, not abandoned.")
                        .font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Forge boundary
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Rectangle().fill(Color.inkAmber).frame(width: 3, height: 52).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
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
                                .font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2.5)
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
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "AM SLOT — 4:30–5:10 AM", color: .textMuted, size: 10)
                    Text("Not a workout. A stimulus tier. Fires glute med and preserves posterior chain patterns while PM lower loading is suppressed. Daily or 4–5× per week. 15–20 min max. If it doesn't feel easy, it's too much.")
                        .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2.5)
                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                    Text("Glute bridge (BW) · Clamshell (band) · Lateral band walk · Donkey kick · Single-leg hip hinge")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.textSecond).lineSpacing(2.5)
                    Text("Zero fatigue cost to PM session — that is the design constraint.")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.inkGreen).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Phase 2 shift
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        MonoLabel(text: "PHASE 2 — ARCHITECTURAL SHIFT", color: .inkGreen, size: 10)
                        Spacer()
                        MonoLabel(text: "CLINICAL GATE · NOT CALENDAR", color: .inkAmber, size: 9)
                    }
                    Text("Posterior chain earns a primary session slot. Lower body transitions from activation-only to loaded compound. Shoulder and upper chest priority locks in permanently — those gains do not trade away for glute work.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    VStack(alignment: .leading, spacing: 6) {
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
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "WEEKLY VOLUME — SPECIALIZATION BLOCK", color: .textMuted, size: 10)
                    Text("This is not balanced hypertrophy volume. These are specialization-level numbers for an advanced operator with a specific morphology target. Recovery signal: Thursday shoulder freshness — not set arithmetic.")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
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
            VStack(alignment: .leading, spacing: 0) {

                // Tappable header row
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        expandedDay = isExpanded ? nil : day
                    }
                }) {
                    HStack(alignment: .top, spacing: 8) {
                        MonoLabel(text: day, color: color, size: 11)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(title).font(.sora(13, weight: .semibold)).foregroundColor(.textPrimary)
                                if let st = sessionType {
                                    Text(st)
                                        .font(.system(size: 8, weight: .medium, design: .monospaced))
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
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(.textMuted)
                    }
                }
                .buttonStyle(.plain)

                // Always-visible intent block
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5).padding(.top, 10)
                    HStack(alignment: .top, spacing: 8) {
                        MonoLabel(text: "PRIORITY", color: .textMuted, size: 9).frame(width: 60, alignment: .leading)
                        Text(priority).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(alignment: .top, spacing: 8) {
                        MonoLabel(text: "INTENT", color: .textMuted, size: 9).frame(width: 60, alignment: .leading)
                        Text(intent).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(alignment: .top, spacing: 8) {
                        MonoLabel(text: "SUPPRESS", color: .inkRed, size: 9).frame(width: 60, alignment: .leading)
                        Text(suppressed).font(.system(size: 10, design: .monospaced)).foregroundColor(.inkRed.opacity(0.8)).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Expandable exercise catalog
                if isExpanded {
                    VStack(alignment: .leading, spacing: 0) {
                        Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5).padding(.top, 12)
                        HStack(spacing: 6) {
                            MonoLabel(text: "EXERCISES", color: .inkGreen, size: 9)
                            Text("tap to collapse")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.textMuted)
                        }
                        .padding(.top, 10).padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(exercises.enumerated()), id: \.offset) { idx, ex in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(idx + 1)")
                                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                                        .foregroundColor(.textMuted)
                                        .frame(width: 14, alignment: .leading)
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                                            Text(ex.0)
                                                .font(.sora(12, weight: .medium))
                                                .foregroundColor(.textPrimary)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                            Text(ex.1)
                                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                                .foregroundColor(.inkGreen)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        Text(ex.2)
                                            .font(.system(size: 10, design: .monospaced))
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
        VStack(spacing: 12) {

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Rectangle().fill(Color.violetLight).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "CARDIO LAB — SCULPTING TOOLS", color: .inkGreen, size: 10)
                    }
                    Text("Cardio selection determines morphology outcomes, not just caloric expenditure. Each tool has a different sculpting profile. Choose based on what the session needs to accomplish.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
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

            cardioTool("STATIONARY BIKE", "Gym A · 4:30–5:10 AM · 35–40 min · Zone 2",
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
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "CARDIO PLACEMENT RULES", color: .textMuted, size: 10)
                    placementRow("Stairmaster", "Wed (no PM lower body) or Fri (PM is low-CNS). Never before Phase 2 posterior chain session.")
                    placementRow("Bike", "Flexible. Default AM tool. 10 min pre-PM as warm-up or 20 min post-PM.")
                    placementRow("Elliptical", "Injury or recovery days. Substitute only.")
                    placementRow("Rowing", "Non-pull days only, low intensity. Not a deliberate slot.")
                    Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                    Text("Total deliberate cardio: 3–4 sessions/week, 20–35 min. Hideout standing contributes to total energy expenditure — factor it into recovery budget.")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }

    // MARK: - 5. SCULPT

    var sculptSection: some View {
        VStack(spacing: 12) {

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Rectangle().fill(Color.inkAmber).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "SCULPT PRIORITIES — SELECTIVE HYPERTROPHY", color: .inkGreen, size: 10)
                    }
                    Text("Forge is the base. These are the specific areas requiring deliberate emphasis and active suppression. 10 years of training = diminishing returns everywhere except targeted weak points.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
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

    // MARK: - 6. SIGNALS

    var adherenceSection: some View {
        VStack(spacing: 12) {

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Rectangle().fill(Color.inkGreen).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "ARCHITECTURE SIGNALS — BODY READOUT", color: .inkGreen, size: 10)
                    }
                    Text("Not adherence checkboxes. Sensory and visual signals that tell you whether the architecture is executing correctly. Forge tracks what you did. This reads what it's producing.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Positive signals
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "GREEN SIGNALS — ARCHITECTURE ON TRACK", color: .inkGreen, size: 10)
                    signalRow("Shoulders look wider in photos than 4 weeks ago", "Lateral delt stimulus is landing. Continue.", .inkGreen)
                    signalRow("Rear of shoulder visible from side view", "Rear delt volume is cumulative. Don't stop.", .inkGreen)
                    signalRow("Waist looks narrower without weight change", "TVA resting tone improving. Vacuum work is registering.", .inkGreen)
                    signalRow("PM sessions feel strong despite the cut", "Pre-lift carb execution is correct. Glycogen is being protected.", .inkGreen)
                    signalRow("Stairmaster legs feel like glutes, not quads", "Technique is correct. Posterior chain stimulus landing.", .inkGreen)
                    signalRow("Upper chest feels worked after Tuesday", "Clavicular head is the primary target. If mid-chest is sore instead — incline too low.", .inkGreen)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Warning signals
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel(text: "AMBER SIGNALS — ARCHITECTURE DRIFT", color: .inkAmber, size: 10)
                    signalRow("Front of shoulder sore after chest day", "Incline angle has crept above 45°. Press is becoming shoulder press.", .inkAmber)
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
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        MonoLabel(text: "TVA VACUUM — ZERO FATIGUE COST", color: .inkAmber, size: 10)
                        Spacer()
                        MonoLabel(text: "START IMMEDIATELY", color: .inkGreen, size: 9)
                    }
                    Text("TVA resting tone is trainable without adding oblique circumference. Daily practice compresses the waist from inside. Measurable circumference reduction within 4–6 weeks. This is the highest-ROI non-session action in the entire protocol.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
                    Text("Stomach vacuum 3×30–60s · Exhale fully · Navel to spine · Hold · Breathe lightly · Morning fasted window")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.inkAmber).lineSpacing(2.5)
                }
            }
            .padding(.horizontal, metrics.hPad)

            // Forge future note
            CardView(style: .secondary) {
                HStack(alignment: .top, spacing: 12) {
                    Rectangle().fill(Color.textMuted.opacity(0.3)).frame(width: 2)
                    VStack(alignment: .leading, spacing: 6) {
                        MonoLabel(text: "FUTURE — FORGE × PHYSIQUE INTEGRATION", color: .textMuted, size: 10)
                        Text("Eventually Forge will send completed training data to Physique. Physique will interpret whether the architecture is being executed — not just whether sessions happened, but whether the right muscles are being prioritized in the right order at the right frequency. When that pipeline exists, this section becomes the interpretation layer.")
                            .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2.5)
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
        VStack(spacing: 12) {

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Rectangle().fill(Color.inkAmber).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "FAILURE MODES — ARCHITECTURE COLLAPSE", color: .inkAmber, size: 10)
                    }
                    Text("These are the specific ways this architecture fails. Not generic fitness mistakes — the exact failure signatures of this schedule, this body, this protocol.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
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
        VStack(spacing: 12) {

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Rectangle().fill(Color.inkAmber).frame(width: 3, height: 28).clipShape(RoundedRectangle(cornerRadius: 1.5))
                        MonoLabel(text: "DECISION TREES — WHEN RESULTS STALL", color: .inkGreen, size: 10)
                    }
                    Text("Answer in order. Do not change the plan until execution is confirmed as the variable. Data-driven correction only.")
                        .font(.sora(12, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                }
            }
            .padding(.horizontal, metrics.hPad)

            adjustCard2("ABS NOT IMPROVING", [
                ("Is 7-day cardio adherence above 85%?", "No → execution is the variable. Close the adherence gap before changing anything.", false),
                ("Is pre-lift carb being executed 6/7 days?", "No → glycogen depletion masking muscle and slowing metabolism. Fix this first.", false),
                ("Is sleep averaging 6+ hours over 7 days?", "No → hormonal suppression is the primary fat-loss inhibitor. Sleep fix outranks everything.", false),
                ("All three confirmed, stall continues 2+ weeks?", "Reduce by 150 kcal. Remove from carbs outside training windows. Protect pre and post-lift carbs.", true),
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
        HStack(spacing: 10) {
            Text("\(num)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.textMuted)
                .frame(width: 14)
            Text(label)
                .font(.sora(12, weight: .medium))
                .foregroundColor(.textPrimary)
                .frame(width: 160, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(height: 4)
                    RoundedRectangle(cornerRadius: 2).fill(Color.inkGreen).frame(width: geo.size.width * CGFloat(value), height: 4)
                }
            }
            .frame(height: 4)
            Text(note).font(.sora(10, weight: .light)).foregroundColor(.textMuted).lineSpacing(1.5).fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }

    func morphRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(key)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.inkGreen)
                .frame(width: 100, alignment: .leading)
            Rectangle().fill(Color.muted.opacity(0.25)).frame(width: 0.5).padding(.top, 3)
            Text(value).font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(2.5).fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }

    func suppressRow(_ title: String, _ reason: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 1.5).fill(Color.inkRed.opacity(0.7)).frame(width: 3, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.sora(12, weight: .semibold)).foregroundColor(.textPrimary)
                Text(reason).font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
            }
        }
        .padding(.vertical, 2)
    }

    func cutCol(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 9, design: .monospaced)).foregroundColor(.textMuted).tracking(0.3).lineSpacing(2)
            Text(value).font(.system(size: 13, weight: .semibold, design: .monospaced)).foregroundColor(.textPrimary).lineSpacing(2)
        }
    }

    func divider() -> some View {
        Rectangle().fill(Color.muted.opacity(0.2)).frame(width: 0.5, height: 40).padding(.horizontal, 10)
    }

    func slotCol(_ label: String, _ desc: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            MonoLabel(text: label, color: .textMuted, size: 9)
            Text(desc).font(.sora(10, weight: .light)).foregroundColor(.textSecond).lineSpacing(2.5)
        }
        .frame(width: 90, alignment: .leading)
    }

    func mealRailView() -> some View {
        VStack(spacing: 0) {
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
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 0) {
                Circle().fill(critical ? Color.inkAmber : Color.inkGreen.opacity(0.5)).frame(width: 5, height: 5).padding(.top, 5)
                Rectangle().fill(Color.surface2).frame(width: 1).frame(maxHeight: .infinity)
            }.frame(width: 5)
            HStack(alignment: .top) {
                MonoLabel(text: time, color: critical ? .inkAmber : .textMuted, size: 9).frame(width: 32, alignment: .leading)
                VStack(alignment: .leading, spacing: 1) {
                    Text(name).font(.sora(12, weight: critical ? .semibold : .medium)).foregroundColor(critical ? .inkAmber : .textPrimary)
                    Text(detail).font(.sora(11, weight: .light)).foregroundColor(.textSecond)
                }
            }.padding(.bottom, 10)
            Spacer()
        }
    }

    enum CarbSig { case good, neutral, critical }

    func carbRow2(_ label: String, _ text: String, _ sig: CarbSig) -> some View {
        let c: Color = sig == .critical ? .inkAmber : sig == .good ? .inkGreen : .textMuted
        return HStack(alignment: .top, spacing: 8) {
            Circle().fill(c.opacity(0.7)).frame(width: 5, height: 5).padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.sora(12, weight: .medium)).foregroundColor(.textPrimary)
                Text(text).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    func archShiftRow(_ label: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            MonoLabel(text: label, color: .inkGreen, size: 9).frame(width: 80, alignment: .leading)
            Text(description).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
        }
    }

    func signalRow(_ label: String, _ interpretation: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 1.5).fill(color.opacity(0.7)).frame(width: 3, height: 32)
            VStack(alignment: .leading, spacing: 3) {
                Text(label).font(.sora(12, weight: .medium)).foregroundColor(.textPrimary).lineSpacing(1.5).fixedSize(horizontal: false, vertical: true)
                Text(interpretation).font(.system(size: 10, design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
    }

    func volumeTableRow(_ muscle: String, _ sets: String, _ note: String, _ color: Color) -> some View {
        HStack(spacing: 8) {
            Text(muscle).font(.sora(12, weight: .light)).foregroundColor(.textSecond).frame(width: 130, alignment: .leading)
            Text(sets).font(.system(size: 12, weight: .semibold, design: .monospaced)).foregroundColor(color).frame(width: 80, alignment: .leading)
            Text(note).font(.sora(10, weight: .light)).foregroundColor(.textMuted).lineSpacing(1.5).fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(.vertical, 4)
    }

    func cardioTool(_ name: String, _ timing: String, chips: [(String, Color)], strengths: [String], weaknesses: [String], technique: String) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: name, color: .textPrimary, size: 10)
                MonoLabel(text: timing, color: .textMuted, size: 9)
                HStack(spacing: 6) {
                    ForEach(chips, id: \.0) { label, color in
                        Text(label).font(.system(size: 9, design: .monospaced)).foregroundColor(color)
                            .padding(.horizontal, 7).padding(.vertical, 3).background(color.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    MonoLabel(text: "STRENGTHS", color: .inkGreen, size: 9)
                    ForEach(strengths, id: \.self) { s in
                        HStack(alignment: .top, spacing: 6) {
                            Text("+").font(.system(size: 10, design: .monospaced)).foregroundColor(.inkGreen)
                            Text(s).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    MonoLabel(text: "WEAKNESSES / RISKS", color: .inkAmber, size: 9)
                    ForEach(weaknesses, id: \.self) { w in
                        HStack(alignment: .top, spacing: 6) {
                            Text("−").font(.system(size: 10, design: .monospaced)).foregroundColor(.inkAmber)
                            Text(w).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                Text(technique).font(.system(size: 10, design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5)
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    func placementRow(_ tool: String, _ rule: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            MonoLabel(text: tool, color: .textMuted, size: 9).frame(width: 70, alignment: .leading)
            Text(rule).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
        }
    }

    func sculptCard2(_ priority: String, _ muscle: String, why: String, movements: String, frequency: String, mechanism: String, color: Color) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    MonoLabel(text: priority, color: color, size: 11)
                    Text(muscle).font(.sora(14, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                }
                Text(why).font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5)
                HStack(alignment: .top, spacing: 8) {
                    MonoLabel(text: "MOVEMENTS", color: .textMuted, size: 9).frame(width: 72, alignment: .leading)
                    Text(movements).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 8) {
                    MonoLabel(text: "FREQUENCY", color: .textMuted, size: 9).frame(width: 72, alignment: .leading)
                    Text(frequency).font(.sora(11, weight: .light)).foregroundColor(color).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                }
                HStack(alignment: .top, spacing: 8) {
                    MonoLabel(text: "MECHANISM", color: .textMuted, size: 9).frame(width: 72, alignment: .leading)
                    Text(mechanism).font(.system(size: 10, design: .monospaced)).foregroundColor(.textMuted).lineSpacing(2.5).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    func failCard2(_ num: String, _ title: String, _ mechanism: String, _ correction: String, _ critical: Bool) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    MonoLabel(text: num, color: critical ? .inkAmber : .textMuted, size: 11)
                    Text(title).font(.sora(13, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                    if critical { MonoLabel(text: "HIGH RISK", color: .inkAmber, size: 8) }
                }
                Text(mechanism).font(.sora(11, weight: .light)).foregroundColor(.textSecond).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: 6) {
                    MonoLabel(text: "→", color: .inkGreen, size: 11)
                    Text(correction).font(.sora(11, weight: .light)).foregroundColor(.inkGreen).lineSpacing(2.5).fixedSize(horizontal: false, vertical: true)
                }
                .padding(8).background(Color.inkGreen.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
        .padding(.horizontal, metrics.hPad)
    }

    func adjustCard2(_ title: String, _ questions: [(String, String, Bool)] = [], _ questionsNoFlag: [(String, String)] = []) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: 12) {
                MonoLabel(text: title, color: .inkAmber, size: 10)
                ForEach(questions.indices, id: \.self) { i in
                    let (q, a, isConclusion) = questions[i]
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 6) {
                            MonoLabel(text: "\(i+1).", color: isConclusion ? .inkGreen : .textMuted, size: 10)
                            Text(q).font(.sora(12, weight: .light)).foregroundColor(.textPrimary).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                        }
                        Text(a).font(.system(size: 10, design: .monospaced)).foregroundColor(isConclusion ? .inkGreen : .textMuted)
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
}
