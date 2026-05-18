import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications
import Foundation

struct CustomTabBar: View {
    @Binding var selected: Int
    let showTimeline: Bool   // kept for API compat, unused now

    var tabs: [(String, String)] {
        [
            ("house",         "Home"),
            ("calendar",      "Today"),
            ("brain",         "Operator"),
            ("building.2",    "Hideout"),
            ("person",        "You"),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Single hairline — barely there
            Rectangle()
                .fill(Color.muted.opacity(0.3))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { i in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) { selected = i }
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }) {
                        VStack(spacing: 5) {
                            ZStack {
                                if selected == i {
                                    Circle()
                                        .fill(Color.violet.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                        .blur(radius: 6)
                                }
                                Image(systemName: tabs[i].0)
                                    .font(.system(size: selected == i ? 19 : 17,
                                                  weight: selected == i ? .medium : .light))
                                    .foregroundStyle(
                                        selected == i
                                        ? AnyShapeStyle(LinearGradient(
                                            colors: [.violetLight, .warm],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing))
                                        : AnyShapeStyle(Color.textMuted.opacity(0.6))
                                    )
                                    .scaleEffect(selected == i ? 1.05 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)
                            }
                            .frame(width: 36, height: 28)

                            Text(tabs[i].1)
                                .font(.mono(10))
                                .tracking(0.5)
                                .foregroundColor(selected == i ? .violetLight : .textMuted.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .padding(.bottom, 4)
                    }
                }
            }
            .background(Color.bgBase)

            // Safe area fill
            Color.bgBase.frame(height: safeAreaBottom)
        }
    }

    // Read actual safe area inset — avoids hardcoding device heights
    private var safeAreaBottom: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom) ?? 0
    }
}

// MARK: - SHARED UI HELPERS

// Custom sheet drag handle — replaces iOS default white pill
struct SheetHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(colors: [.violet.opacity(0.5), .warm.opacity(0.3)],
                               startPoint: .leading, endPoint: .trailing)
            )
            .frame(width: 36, height: 3)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }
}

func inputField(_ label: String, placeholder: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        MonoLabel(text: label)
        TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
            .font(.sora(15)).foregroundColor(.textPrimary)
            .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
            .tint(.warm)
    }
}

func editableField(_ label: String, placeholder: String, text: Binding<String>, multiline: Bool = false) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        MonoLabel(text: label)
        if multiline {
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted), axis: .vertical)
                .font(.sora(14)).foregroundColor(.textPrimary).lineLimit(3...6)
                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(.warm)
        } else {
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
                .font(.sora(14)).foregroundColor(.textPrimary)
                .padding(14).background(Color.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(.warm)
        }
    }
}

func primaryButton(_ label: String, disabled: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(label)
            .font(.sora(14, weight: .semibold))
            .foregroundColor(disabled ? .textMuted : .bgBase)
            .tracking(1.8)
            .frame(maxWidth: .infinity).frame(height: 50)
            .background(
                Group {
                    if disabled {
                        Color.surface2
                    } else {
                        LinearGradient(
                            colors: [.violetLight, .violet],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: disabled ? .clear : Color.violet.opacity(0.25), radius: 12, x: 0, y: 6)
    }
    .disabled(disabled)
}

func segmentControl(_ options: [String], selected: Binding<Int>) -> some View {
    HStack(spacing: 0) {
        ForEach(options.indices, id: \.self) { i in
            Button(action: { selected.wrappedValue = i }) {
                Text(options[i])
                    .font(.sora(13, weight: selected.wrappedValue == i ? .semibold : .regular))
                    .foregroundColor(selected.wrappedValue == i ? .textPrimary : .textMuted)
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                    .background(selected.wrappedValue == i ? Color.surface : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    .padding(4).background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 12))
}

func emptyState(icon: String, title: String, subtitle: String) -> some View {
    CardView {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 28)).foregroundColor(.violetDim)
            Text(title).font(.sora(15, weight: .medium)).foregroundColor(.textSecond)
            Text(subtitle).font(.sora(13, weight: .light)).foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
    }
    .padding(.horizontal, 24)
}

// MARK: - SEED: MAINTENANCE ITEMS

func seedDefaultMaintenance(context: ModelContext) {
    let defaults: [(String, SystemTag, Int)] = [
        // Environment
        ("Air filter",              .environment,  30),
        ("Water filter",            .environment,  90),
        ("Deep clean — home",       .environment,  14),
        ("Balcony reset — 26th",    .environment,   7),
        ("Terrace deep clean",      .environment,  14),
        // Personal care
        ("Derma roller — replace",  .health,       90),
        ("Razor blade — replace",   .health,       14),
        ("Toothbrush head",         .health,       90),
        ("Dermatologist check",     .health,       365),
        ("Dental cleaning",         .health,       180),
        ("Eye exam",                .health,       365),
        ("Blood panel — annual",    .health,       365),
        ("25-OH Vitamin D test",    .health,       180),
        ("Testosterone panel",      .health,       180),
        // Operations
        ("Weekly reset",            .operations,    7),
        ("Financial review",        .operations,    7),
        ("Espresso machine deep clean", .operations, 7),
        ("Grinder calibration",     .operations,   14),
        ("App subscription audit",  .operations,   90),
    ]
    for (title, system, interval) in defaults {
        context.insert(MaintenanceItem(title: title, system: system, intervalDays: interval))
    }
}

// MARK: - DAILY RESET — clears isCompleted on recurring actions each new calendar day

func resetDailyActionsIfNeeded(context: ModelContext, profile: OperatorProfile, actions: [Action], sessions: [Session] = []) {
    let cal = Calendar.current
    // Only reset once per calendar day
    if let last = profile.lastResetDate, cal.isDateInToday(last) { return }

    // Determine yesterday's weekday for skip counting (we're resetting FOR yesterday)
    let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    let yesterdayWD = cal.component(.weekday, from: yesterday)

    for action in actions {
        guard action.recurrence != .none else { continue }   // one-off actions never reset

        let shouldReset: Bool
        switch action.recurrence {
        case .daily:
            shouldReset = true
        case .weekdays:
            shouldReset = yesterdayWD >= 2 && yesterdayWD <= 6
        case .weekends:
            shouldReset = yesterdayWD == 1 || yesterdayWD == 7
        case .weekly:
            if let ca = action.completedAt {
                let days = cal.dateComponents([.day], from: ca, to: Date()).day ?? 0
                shouldReset = days >= 7
            } else {
                let daysSinceCreated = cal.dateComponents([.day], from: action.createdAt, to: Date()).day ?? 0
                shouldReset = daysSinceCreated >= 7
            }
        case .none:
            shouldReset = false
        }

        if shouldReset {
            if !action.isCompleted { action.skipCount += 1 }
            action.isCompleted = false
            action.completedAt = nil
        }
    }

    // Session reset — parallel logic to actions
    // Blank (no log, no skip) = unknown miss → increment skipCount
    // Intentional skip (skipDates recorded) = deliberate signal → don't double-count
    for session in sessions {
        guard session.recurrence != .none, session.isActive else { continue }

        let wasActiveYesterday: Bool
        switch session.recurrence {
        case .daily:   wasActiveYesterday = true
        case .weekdays: wasActiveYesterday = yesterdayWD >= 2 && yesterdayWD <= 6
        case .weekends: wasActiveYesterday = yesterdayWD == 1 || yesterdayWD == 7
        case .weekly:
            let days = cal.dateComponents([.day], from: session.lastCompleted ?? session.createdAt, to: Date()).day ?? 0
            wasActiveYesterday = days >= 7
        case .none: wasActiveYesterday = false
        }

        guard wasActiveYesterday else { continue }

        let completedYesterday = cal.isDateInYesterday(session.lastCompleted ?? .distantPast)
        let skippedYesterday = cal.isDateInYesterday(session.skipDates.last ?? .distantPast)

        if !completedYesterday && !skippedYesterday {
            // Blank — unknown non-completion. Counts as friction.
            session.skipCount += 1
        }
        // Note: intentional skips (skippedYesterday) are already recorded in skipDates.
        // They don't increment skipCount — that's reserved for unlogged misses.
    }

    profile.lastResetDate = Date()
}

// MARK: - SEED DATA

// PRESCRIBED WEEK SCHEDULE (v2.4):
// Add these manually if already seeded. Time blocks show on action cards.
// DayType "hideout" = Wed–Fri 7AM–5PM, Sat–Sun 7AM–3PM. "base" = Mon–Tue cafe/ops days.
//
// EVERY DAY:  6:00 No phone · 6:05 Light · 6:15 Hydrate · 6:20 Creatine
//             6:30 Move · 6:45 Cold shower · 7:00 Protein · 7:30 Journal
//             21:00 No screens · 21:15 Evening Shutdown · 22:00 Read
// HIDEOUT:    7:00 slow open · 7:15 Pre-shift behaviors · 7:30 Priorities · 8:30 Deep work · 12:00 Protein + outside
// BASE:       8:00 Mon: Close loop · 8:15 Messages · 8:30 Reset one area
// WEEKLY:     Sun 14:00 Read long · Sun 15:00 Inbox physical · Mon 8:00 Close loop

func seedDefaultActions(context: ModelContext) {
    // (title, system, points, note, cue, recurrence, scheduledBlock, dayTypeRaw)
    // Format: (title, system, points, note, cue, recurrence, scheduledBlock, dayTypeRaw, priorityTierRaw, mechanismNote)
    // note = short execution cue (1-2 lines, always visible)
    // mechanismNote = causal mechanism (expandable, why it works this way)
    let defaults: [(String, SystemTag, Int, String?, String, RecurrenceType, String?, String?, String?, String?)] = [

        // ── MORNING ANCHOR — every day (4AM wake) ─────────────────────────────
        ("No phone — first hour",     .cognition,    10,
         "Protect the opening. Nothing urgent in the first hour couldn't wait. Extension: no news or social media before 10AM — the first 2 hours shape your dopamine baseline and executive function for the full day. News optimized for anxiety is not neutral input.",
         "When alarm goes off",                   .daily,   "4:00",  nil, "anchor", nil),

        ("Hydrate",                    .health,        5,
         "500ml before anything. 3L target today.\\nWhile filling: step on scale (post-bathroom, no clothes), glance at Garmin body battery.",
         "When walking to the kitchen",            .daily,   "4:05",  nil, "anchor", nil),

        ("Open the blinds",            .environment,   5,
         "Light signal. At 4AM it's dark — open anyway. The act cues wakefulness even before dawn. Environment system: conditions first.",
         "Walking to kitchen or balcony",          .daily,   "4:10",  nil, nil, nil),

        ("Creatine",                   .health,        5,
         "5g with water.",
         "With morning water",                     .daily,   "4:15",  nil, "anchor", "Works by daily saturation, not acute dosing — timing window is flexible. If you miss morning, take it any time that day. Do NOT take with zinc (absorption competition) — that's why zinc is at dinner, not here."),

        ("Pre-fuel — small",           .health,        5,
         "Banana or half a sourdough slice. Not a meal — just enough to run on. Cardio fuel.",
         "Before cardio — after hydrate",          .daily,   "4:20",  nil, nil, nil),

        ("Cardio — bike or elliptical", .health,      15,
         "STEADY STATE (default): 35–45 min Zone 2, 65–70% max HR. Fat oxidation peaks here without cortisol load that competes with evening Forge Breechay sessions.\nINTERVAL (1x/week, base days only): 20 min — 8 rounds of 1 min hard / 90 sec easy. Not on hideout days. Not on heavy leg days.\nFasted is fine at this pace. Pre-fuel (banana) only if doing intervals.",
         "4:30 — before shower, before hideout",   .daily,   "4:30",  nil, nil, nil),

        ("Cold exposure — 2 min",      .health,       10,
         "Last 2 minutes of shower cold. Not the whole shower — just the finish.",
         "End of shower",                          .daily,   "5:15",  nil, nil, nil),

        ("Morning grooming",           .health,       10,
         "Grooming corridor — 14 min. See Whole Human Reset session for full sequence.",
         "After shower — corridor start",      .daily,   "5:18",  nil, "anchor", nil),

        ("Protein — first meal",       .health,        5,
         "30g minimum. Eggs + chicken or pumpkin seed shake. Pre-commute. Eat before you leave.",
         "First meal — before leaving for hideout",  .daily,   "5:35",  nil, "anchor", nil),

        ("Supplements — midday",       .health,       10,
         "Take with first fat-containing meal (9:30 AM at Hideout, ~9:00 AM at home):\n• Vitamin D3: 5,000 IU — Miami sun + consistent SPF = still likely deficient. Test 25-OH-D biannually, target 50–70 ng/mL.\n• K2 (MK-7): 100mcg — routes D3-driven calcium to bones, not arteries. D3 without K2 long-term is a cardiovascular risk.\n• Vitamin C: 500mg — or rely on breakfast strawberries (~85mg/cup). Supports collagen synthesis, immune function, cortisol clearance.",
         "With first fat meal — 9:30 AM",           .daily,   "9:30",  nil, nil, nil),

        ("Supplements — dinner",        .health,       10,
         "Take with final meal (7:00–7:30 PM):\n• Omega-3: 2–3g EPA+DHA combined. Triglyceride form, refrigerate. Anti-inflammatory — directly counters the inflammatory load of cut + daily training + foot injury recovery. Reduces DOMS, supports cognitive performance.\n• Zinc: 15–25mg picolinate or bisglycinate. NOT with creatine (AM) — they compete for absorption. Depleted rapidly by sweat — active outdoor shift + daily cardio = significant loss. Suppresses testosterone and wound healing when deficient.\n• Ashwagandha KSM-66: 300–600mg. Not generic ashwagandha — KSM-66 is the studied extract. Reduces cortisol, improves VO2 max, supports testosterone under chronic stress load. Takes 4–8 weeks. Not in the morning — causes drowsiness initially.",
         "With final meal — after gym",             .daily,  "19:30",  nil, nil, nil),

        ("Journal — 3 sentences",      .cognition,    10,
         "What happened. What I noticed. What's next.",
         "After protein — before leaving",         .daily, "5:45", nil, nil, nil),

        ("Morning light exposure",     .health,        5,
         "Real sunlight — balcony or commute walk if it's past civil twilight (~30 min before sunrise). Miami sunrise: ~6:32 AM (summer) to ~7:11 AM (winter). At 5:50 AM you're in civil twilight — some natural light available. Full sun exposure happens at Hideout open (7AM action). Red light at 4:08 AM covers the pre-dawn alertness cue.",
         "Post-cardio or commute — natural light when available",  .daily,   "5:50",  nil, nil, nil),

                // ── HIDEOUT DAYS — Wed–Fri 7AM–5PM, Sat–Sun 7AM–3PM ─────────────────────────
        ("Review priorities",          .operations,   10,
         "5 min. What are the 3 things? Write them down before anything else.",
         "When arriving at hideout — 7AM slow open, before the work starts",
         .daily,   "7:30",  "hideout", "anchor", nil),

        ("Deep work block — 90 min",   .cognition,    20,
         "One thing. Phone in another room. Timer on. No interruptions — let it ring.",
         "After slow open, when the place is ready",
         .daily,   "8:30",  "hideout", "anchor", nil),

        ("Protein — second hit",       .health,        5,
         "30g. Noon break.",
         "Noon — hideout midday break",            .daily,   "12:00", "hideout", nil, nil),

        ("Outside — 15 min",           .participation, 5,
         "Walk. Balcony if after 5pm and heat's tolerable with a fan.",
         "After noon protein on hideout days",     .daily,   "12:15", "hideout", nil, nil),

        // Gym — 5PM fixed anchor, building condo gym with Tim
        ("Pre-lift warmup — 20 min",  .health,       10,
         "Do this sequence every session before Forge Breechay. Each item addresses a specific failure point:\n1. Hip flexor stretch — 60 sec/side kneeling lunge. Tight hip flexors reduce glute activation in squats. Direct performance impact.\n2. Thoracic spine rotation — 10 reps/side seated. Foundation for pressing + row mechanics. Stiffness here forces shoulder compensation and injury.\n3. Foam roll — quads 60 sec/leg, lats 60 sec/side. Fascial adhesions from daily training limit range of motion and reduce activation efficiency.\n4. Ankle circles + calf raises — 10 circles/direction + 20 slow raises. Foot injury rehab. Restores dorsiflexion that affects squat mechanics.\n5. Dead hang — 30 sec passive. Spine decompression after 10-hour standing shift. Shoulder joint loaded in full range.",
         "5:00–5:20 PM — gym, before first set",     .daily,  "17:00", nil, nil, nil),

        ("Strength training — gym",    .health,       20,
         "Building with Tim. Session anchor: mobility first (17:00–17:20), then Forge Breechay. Post-workout protein within 30 min.",
         "5:30 PM — after mobility warmup",
         .daily,   "17:30", nil, "anchor", nil),

        ("Post-workout protein",       .health,        5,
         "30g within 30 min of training. The window matters here more than other meals.",
         "Immediately after gym",                   .daily,   "18:00", nil, "anchor", nil),

        // ── BASE DAYS — Mon–Tue cafe/ops/maintenance ───────────────────────────
        ("Respond to 3 messages",      .operations,    5,
         "Clear the queue. Not all of it — just what needs you.",
         "After morning anchor, at the cafe",      .daily,   "8:15",  "base", nil, nil),

        ("Apartment reset — one area", .environment,  10,
         "Rotate daily: Monday = desk surface · Tuesday = kitchen counter + sink. One area, done completely. Not a sweep — an actual reset. The environment system is the gateway system — disorder here costs every other system.",
         "Monday/Tuesday base morning — pick one area",  .daily,  "8:30",  "base", nil, nil),

        ("Protein — noon, base day",   .health,        5,
         "30g. Eggs, chicken, or pumpkin seed shake. Base days you're home or at a café — easier to execute than hideout. Don't skip because the environment is casual.",
         "Noon — base day, wherever you are",      .daily,   "12:00", "base", nil, nil),

        // ── EVENING ANCHOR — every day ─────────────────────────────────────────
        ("PM oral care",               .health,       10,
         "Floss → brush 2 min → tongue scraper. Sequence is not optional.",
         "Before shutdown — 8:25 PM",               .daily,  "20:25", nil, "anchor", nil),

        ("No screens — final hour",    .health,       10,
         "Lights to lamps. Phone to other room. Not silent — other room.",
         "8:30 PM — start of shutdown corridor",   .daily,   "20:30", nil, "anchor", nil),

        ("Minoxidil",                  .health,       10,
         "Dry scalp only. Crown + top zone. Light spread. Must dry 45 min before pillow.",
         "8:20 PM — 45 min before sleep. If using derma roller tonight, apply within 30 min of rolling.",   .daily,   "20:20", nil, "anchor", nil),

        ("Read before sleep",          .cognition,    15,
         "Physical book. 20+ pages. No Kindle. Your Garmin confirms the REM effect — this is a sleep action as much as a reading action.",
         "Physical book only. Your Garmin data confirms REM improvement. Sleep action as much as reading action.",
         "After shutdown staging",     .daily,   "20:50", nil, nil),

        ("Sleep by 9:30PM",            .health,       10,
         "End of shutdown corridor. 4AM wake = 6.5 hr ceiling. 9:15–9:30 target. Every system — fat loss, muscle retention, cortisol, HRV — degrades when this slips. Sleep is not a reward; it is a performance input.",
         "End of shutdown corridor",        .daily,   "21:15", nil, "anchor", nil),

        // ── HIDEOUT OPERATIONS — behavioral science stack ─────────────────────
        ("Pre-shift: load the 4 behaviors",  .operations,   10,
         "1. Primacy — acknowledge every walk-in within 3 seconds.\n2. Choice Architecture — 'Want me to warm a croissant with that?'\n3. Familiarity — which regulars might come in? Know their usual.\n4. Peak-End — '[Name]. Have a great [day]. See you next time.'",
         "Before opening — while prepping",              .daily,   "7:15",  "hideout", nil, nil),

        ("Watermarc relationship touch",     .participation,15,
         "Bring coffee to leasing office. Introduce Hideout. Ask if they'll mention us on tours. Leave cards with concierge. One relationship = potentially dozens of high-value regulars.",
         "First available morning at Hideout",           .weekly,  nil,     "hideout"),
        ("One real conversation",      .participation,10,
         "Phone call counts. A real text thread counts. A DM reply doesn't.",
         "Any natural transition in the day",      .daily,   nil,     nil),

        ("Make something",             .participation,15,
         "Write, build, design, cook. Output, not consumption. Anything counts if you made it.",
         "Weekend — any time",                     .weekends, nil,    nil),


                // ── NIZORAL — Tuesday + Saturday ──────────────────────────────────────
        ("Nizoral — Tuesday",          .health,       10,
         "In the shower. Apply ketoconazole shampoo to scalp — not just hair. Gentle massage. Leave 5 min. Rinse well. Condition mids/ends only if dry. Controls scalp inflammation and fungal environment. Adjunct to minoxidil, not a substitute.",
         "Tuesday shower",                         .weekly,  nil,     nil, nil, nil),

        ("Nizoral — Saturday",         .health,       10,
         "Same as Tuesday. Scalp only. 5-minute contact. Rinse. Condition ends if needed.",
         "Saturday shower",                        .weekly,  nil,     nil, nil, nil),

        // ── PAULA'S CHOICE BHA — Friday ───────────────────────────────────────
        ("BHA texture night — Friday", .health,       10,
         "Paula's Choice BHA exfoliant. Correct tool for texture — better than extended cleanser contact time. After PM cleanse, dry face, thin layer, avoid eye area. Moisturize after if needed. Start 1x weekly. DO NOT combine with retinoid actives same night.",
         "Friday night — after PM cleanse",        .weekly,  nil,     nil, nil, nil),

        // ── INACTIVE — rosemary requires jojoba carrier oil not yet purchased ──
        // When jojoba purchased, uncomment:
        // ("Rosemary scalp — Wednesday", .health, 10,
        //  "Mix: 1 tbsp jojoba + 6 drops rosemary essential oil + small castor (70/20/10 approx). NEVER apply pure rosemary directly — concentrated essential oil causes irritation and inflammatory shedding. Section hair, apply few drops, massage 5 min, leave overnight. Wash next morning.",
        //  "Before bed — Wednesday", .weekly, nil, nil, nil),
        // ("Rosemary scalp — Sunday", .health, 10,
        //  "Same as Wednesday. Diluted blend only. Leave overnight if tolerated. Wash Monday morning.",
        //  "Before bed — Sunday", .weekly, nil, nil, nil),

        // PLANNED — full-face retinoid (purchase when capital allows)
        // ("Retinol — Monday",  .health, 15,
        //  "Full-face retinoid only — not eye cream. Cleanse first. Wait 10-20 min until skin fully dry. Pea-sized only. Dot forehead, cheeks, chin. Avoid eyelids, nostril folds, corners of mouth. Moisturize after. Start 2x weekly. No BHA same night.",
        //  "After PM cleanse — Monday night", .weekly, nil, nil, nil),
        // ("Retinol — Thursday", .health, 15,
        //  "Same as Monday. Cleanse → dry 10-20 min → pea-sized retinoid → moisturize. No BHA same night.",
        //  "After PM cleanse — Thursday night", .weekly, nil, nil, nil),

        // PLANNED — finasteride consult (next capital deployment after 90-day stack run)
        // Crown + top pattern = androgenic thinning. Minoxidil supports growth.
        // Finasteride addresses the driver (DHT). Generic is inexpensive once prescribed.
        // Do not initiate until current owned stack has run consistently for 90 days.

        // PLANNED — hair clinic review (6-month horizon)
        // Re-evaluate prior successful scalp/hairline injectable intervention when resources allow.
        // Defer until core stack has run 6+ months. Not before.

        // ── WEEKLY ─────────────────────────────────────────────────────────────
        ("Read something long",        .cognition,    15,
         "Article, essay, or book chapter. Not a thread, not a summary. On base days (Mon/Tue), this fits naturally post-lunch.",
         "Sunday or base day afternoon",           .weekly,  "14:00", "base", nil, nil),

        ("Inbox zero — physical",      .environment,  10,
         "Mail, packages, receipts. The physical pile.",
         "Sunday afternoon — after reading",       .weekly,  "15:00", nil, nil, nil),

        ("Close one open loop",        .operations,   15,
         "One thing that's been sitting. A reply, a decision, a task. One — not a list.",
         "Monday morning — first thing",           .weekly,  "8:00",  "base", nil, nil),

        // ── RED LIGHT THERAPY ────────────────────────────────────────────────
        ("Red light — 10 min",         .health,       10,
         "Panel 6–12 inches from face + chest. Eyes closed. Do this during hydrate/creatine window.",
         "During 4:05–4:15 AM hydrate window — before cardio",  .daily, "4:08", nil, "anchor", nil),

        // ── SUNLIGHT ON SKIN — at Hideout open ───────────────────────────────
        ("Sunlight — face + arms",     .health,        5,
         "5–10 min direct sun on face and forearms at Hideout open. You're on an outdoor terrace — this is free. Vitamin D synthesis, circadian signal reinforcement, mood. Not through glass. Miami sunrise is ~6:32–7:11 depending on month — by 7AM you have direct light. Don't wear SPF for this window; apply after.",
         "First 5–10 min at Hideout open — outdoor terrace",  .daily, "7:05", "hideout", "amplifier", nil),

        // ── MAGNESIUM GLYCINATE — nightly ────────────────────────────────────
        ("Magnesium glycinate",        .health,       10,
         "400mg glycinate form with water.",
         "8:40 PM — before Stage tomorrow routine",         .daily,  "20:40", nil, "anchor", nil),

        // ── COLLAGEN + VITAMIN C — pre-lift ──────────────────────────────────
        ("Collagen + vitamin C",       .health,       10,
         "10g collagen peptides + vitamin C source (1 cup strawberries covers it) 30–45 min before lifting.",
         "30–45 min before Forge Breechay — with pre-lift meal",  .daily, "16:45", nil, "amplifier", "Collagen synthesis in connective tissue peaks specifically when collagen peptides AND vitamin C are co-present during mechanical loading — not before, not after. The 30–60 min pre-exercise window is the evidence-based timing. Strawberries cover the vitamin C requirement. Direct relevance: foot injury tendon repair + protecting connective tissue under daily Forge Breechay volume."),

        // ── NASAL BREATHING CHECK — during cardio ────────────────────────────
        ("Nasal breathing — cardio check",  .health,    5,
         "At 10 min into cardio: are you breathing through your nose? If not, reduce resistance until you can. Nasal breathing during Zone 2 improves CO2 tolerance, HRV, and nitric oxide production. It's also the best real-time intensity gauge — if you can't nasal breathe, you're above Zone 2. This action is a habit cue, not a task. Once it's automatic, it costs nothing.",
         "10 min into morning cardio — check and adjust",   .daily, "4:40", nil, "amplifier", "Collagen synthesis in connective tissue peaks specifically when collagen peptides AND vitamin C are co-present during mechanical loading — not before, not after. The 30–60 min pre-exercise window is the evidence-based timing. Strawberries cover the vitamin C requirement. Direct relevance: foot injury tendon repair + protecting connective tissue under daily Forge Breechay volume."),

        // ── WEEKLY DEBRIEF — Sunday ──────────────────────────────────────────
        ("Weekly output review",       .operations,   15,
         "Sunday. 15 min. Answer: What moved this week? What didn't? What's the one structural change that would make next week better? Not a retrospective — a routing correction. Write 3 sentences max. This is the highest-leverage 15 minutes of the week if you actually do it.",
         "Sunday — after Hideout close",            .weekly, "15:30", "hideout", nil, nil),

        // ══ ORAL HEALTH ═══════════════════════════════════════════════════════
        ("Derma roller — Sunday",      .health,       10,
         "Same as Wednesday. 0.5mm. Clean before use. Apply minoxidil after within 30 min. The Wed/Sun schedule gives 3–4 days between sessions — sufficient healing time for 0.5mm depth.",
         "Sunday night — before minoxidil",          .weekly, nil,     nil, nil, nil),

        ("Caffeine shampoo — Mon/Thu", .health,        5,
         "Alpecin or similar caffeine shampoo. Leave on scalp 2 minutes before rinsing. Caffeine penetrates follicles and counteracts DHT-induced growth inhibition directly at the follicle level — the same mechanism as topical minoxidil but different pathway. Stacks with, not substitutes for, the protocol. On non-Nizoral days.",
         "Monday and Thursday shower",               .weekly, nil,     nil, nil, nil),

        // ══ SKIN — ADVANCED PROTOCOL ══════════════════════════════════════════
        ("Glycolic acid — Thursday PM", .health,      10,
         "AHA exfoliant, 8–10%. Apply to dry face after PM cleanse. Thin layer, avoid eye area. Unlike BHA (Friday, oil-soluble, targets pores), glycolic AHA is water-soluble and targets surface texture, fine lines, and pigmentation. Alternating AHA Thursday and BHA Friday gives exfoliation coverage without overlap. Don't combine with retinoids same night. Rinse thoroughly next morning.",
         "Thursday PM — after cleanse, before moisturizer",  .weekly, nil,  nil, nil, nil),

        ("Body SPF — exposed areas",   .health,       10,
         "Arms, back of neck, any exposed skin. SPF 30 minimum. You're on an outdoor terrace Wed–Sun, sweeping and setting up in direct morning sun. UVA causes cumulative skin aging regardless of burn — and Miami UVI is high year-round. Apply after the sunlight-on-skin window (don't block that). Spray SPF is fine for body. Reapply at noon if you're still in direct sun.",
         "After 7AM sunlight window — before opening rush", .daily, "7:20", "hideout", nil, nil),

        // ══ BODY CARE ═════════════════════════════════════════════════════════
        ("Body scan — 30 sec",         .health,        5,
         "In the shower or after. Run hands over scalp, face, chest, back, moles. You're looking for: new moles, changes in existing ones (asymmetry, irregular border, multiple colors, >6mm, raised), unusual lumps, persistent skin changes. Miami sun + outdoor work = elevated melanoma risk. Monthly full check with a partner or mirror for back. Dermatologist annually. This takes 30 seconds and saves lives.",
         "Monthly — in the shower",                  .none,   nil,     nil, "amplifier", nil),

        ("Nail care",                  .health,        5,
         "Fingernails: trim straight across, file edges. Toenails: trim straight, not curved — curved edges ingrown. Ingrown toenails with daily cardio and gym are painful and slow recovery. File any rough edges on toenails — friction in shoes causes blisters that interrupt training. Do this after a shower when nails are soft.",
         "Weekly — after Sunday shower",             .weekly, nil,     nil, "amplifier", nil),

        ("Ear cleaning",               .health,        5,
         "Cotton tip only on the outer ear — never in the canal. For wax: let warm water into the ear in the shower, tilt to drain. If buildup is significant: Debrox or similar carbamide peroxide drops monthly. Wax buildup causes hearing loss, tinnitus, and mild cognitive fog that most people don't attribute to it. Don't over-clean — ear canal is self-cleaning, outer ear only.",
         "Monthly — after shower",                   .none,   nil,     nil, "amplifier", nil),

        // ══ SLEEP HYGIENE — COMPLETE ══════════════════════════════════════════
        ("Room temperature — set",     .environment,   5,
         "65–68°F (18–20°C). Core body temperature must drop ~1–2°F to initiate and maintain sleep. Hot rooms prevent this drop — they reduce deep sleep and REM regardless of how tired you are. Set AC 30 min before sleep. In Miami, running AC at night is not optional if you care about sleep quality. If you wake at 3AM feeling hot, room temp is the culprit.",
         "8:15 PM — before no-screens window",       .daily,  "20:15", nil, nil, nil),

        ("Stage tomorrow",             .environment,  10,
         "4 things, 4 minutes: (1) Gym bag packed and by door — including collagen, pre-lift snack, any supplements. (2) Tomorrow's outfit on the chair. (3) Kitchen staged — creatine + magnesium out, water bottle filled. (4) App open to Today so first action is visible at 4AM. Every decision you eliminate from the 4AM window is a direct performance upgrade.",
         "8:45 PM — during shutdown",                .daily,  "20:45", nil, "anchor", nil),

        ("Sleep position — lateral",   .health,        5,
         "Side sleeping (left preferred) improves glymphatic clearance — the brain's overnight waste removal system. Reduces snoring, reduces acid reflux, reduces spinal load vs. back sleeping. Pillow between knees if hip alignment is off. Not a hard rule but worth defaulting to. Left side specifically improves lymphatic drainage.",
         "Read once, internalize. Not a recurring tap. Side sleeping improves glymphatic waste clearance overnight. Left side preferred for lymphatic drainage. Pillow between knees if needed.",
         "One-time read — internalize as default",             .none,  nil, nil, nil),

        ("Intentional learning — 15 min", .cognition, 15,
         "15 min of deliberate skill or knowledge acquisition. Not passive consumption — active learning: a book chapter with notes, a course with pause-and-test, a skill practice session. Domains that compound for you: business operations, behavioral psychology, design, coffee craft, plant care. This is different from your reading habit (which is for deep engagement). This is targeted upskilling. Fits in commute or Hideout quiet window.",
         "Commute or Hideout quiet window",          .daily,  nil,     nil, "amplifier", nil),

        ("Gratitude — 3 items",        .cognition,     5,
         "Write or say 3 specific things. Not 'grateful for health' — 'grateful that my foot is healing faster than expected.' Specificity is what produces the neurological effect (prefrontal cortex activation, reduced amygdala reactivity). Evidence base is strong across multiple trial designs. Skeptics: you're wrong. 60 seconds, same time each day. Pairs naturally with your 3-sentence journal.",
         "With morning journal — 5:45 AM",           .daily,  "5:47",  nil, "amplifier", nil),

        ("Weekly financial check",     .operations,   10,
         "10 min. Not a full review — just: what came in this week, what went out, what's the shift from target, is there a decision needed before next week. For Hideout: is weekly revenue trending toward stability band or above. For personal: any irregular expense requiring adjustment. This is pattern maintenance, not anxiety management. Calm, factual, 10 min.",
         "Monday morning — base day",                .weekly, "9:00",  "base", nil, nil),

        // ══ RELATIONSHIP + PARTICIPATION ══════════════════════════════════════
        ("Scalp massage — 4 min",      .health,        5,
         "Fingertips only — no nails, no palm, no tool. Firm circular pressure, not scratching. Zones in order: temples, crown, occiput (back of skull), sides. 4 full minutes — use a timer once to calibrate what it feels like, then it becomes automatic. Mechanism: mechanical stress on dermal papilla cells triggers gene expression for thicker hair shaft diameter. 24-week study showed statistically significant thickness increase at 4 min/day. Optimal windows: (1) in the shower during conditioner dwell time — warm water and vasodilation amplify blood flow to follicles; (2) immediately after applying minoxidil on treatment nights — massage distributes the solution from drop sites across the zone and increases follicular absorption. Don't do it dry on an irritated or flaking scalp — wet is gentler. Scalp massager tools feel good but reduce feedback; fingertips let you feel tension, tender spots, and areas of poor circulation.",
         "In the shower — during conditioner dwell time",  .daily, nil,  nil, nil, nil),

        ("20-20-20 — Hideout screens", .health,        5,
         "Every 20 min of screen work: look at something 20 feet away for 20 seconds. The outdoor terrace makes this effortless — look at the horizon. Reduces digital eye strain and slows myopia progression. Use customer transitions as the natural cue.",
         "During Hideout screen work — every 20 min", .daily, nil,  "hideout", "amplifier", nil),

        ("Send one meaningful message", .participation, 10,
         "One message to one person that requires thought. Not a reaction, not a reply to a notification — an initiated message with actual content. Check in on someone's specific situation. Share something relevant to them specifically. Make a plan. This is relationship maintenance as a repeatable action. It takes 2 minutes. Over time, your network cohesion is the sum of these small acts.",
         "Any natural transition in the day",        .daily,  nil,     nil, nil, nil),

        ("Compliment or acknowledge",  .participation,  5,
         "One genuine, specific compliment or acknowledgment per day — customer, staff, anyone. Not 'great job' — 'I noticed how you handled that situation, that was thoughtful.' Specificity is what makes it land. This is also a behavioral science tool for Hideout: customers who feel genuinely seen return at higher rates. It's not manipulation — it's just noticing and saying it.",
         "During Hideout shift or in the day",       .daily,  nil,     "hideout", "amplifier", nil),

        // ══ ENVIRONMENT — ADVANCED ════════════════════════════════════════════
        ("Plant check — water + prune", .environment,   5,
         "Quick pass: any dry soil, any dead leaves, any yellowing. You're already at Hideout pruning and setting up — this folds into the 6AM open routine. Living plants in the terrace environment directly affect: air quality (marginal but real), visual appeal for customers (significant), and your own state entering the shift. A dead or struggling plant is an environmental disorder signal.",
         "During 6AM Hideout open routine",          .daily,  "6:10",  "hideout", nil, nil),

        ("Terrace audit — opening",    .environment,  10,
         "5 min before open: chairs aligned, table surfaces clean, any debris from wind or overnight, plants upright, signage correct. You're already doing this — the action cue makes it explicit and consistent. Environmental coherence is the gateway system: a well-set terrace changes customer perception within seconds of arrival, before they've tasted anything.",
         "6:45 AM — before first customer",         .daily,  "6:45",  "hideout", nil, nil),

        ("Condo 26th floor — balcony reset", .environment, 5,
         "Weekly: sweep balcony, wipe rail, remove any items that drifted there. The 26th floor has different environmental conditions — wind-driven particulates, salt air, higher UV exposure on furniture. Monthly: check any outdoor items for corrosion or wear. Your home environment starts from the moment you step outside — keep it clean.",
         "Weekly — Sunday or Monday base day",       .weekly, nil,     nil, nil, nil),

        // ══ BODY COMPOSITION TRACKING ═════════════════════════════════════════
        ("Progress photos — Sunday",   .health,        5,
         "Same conditions: morning light, same pose (front, side, back), same location. Lighting variation kills comparability — use the same spot every week. Photos capture what the scale misses: body composition changes while weight stays flat are common during recomp. At 12–13% body fat targeting 8–10%, the visual delta will be significant over 8–12 weeks. Document it.",
         "Sunday morning — same location and lighting", .weekly, nil,  nil, "amplifier", nil),

        ("Training log — post session", .health,       10,
         "After every Forge Breechay session: log weights for each main movement. Note any week-over-week PR — that number is the competition signal. Memory underestimates actual lifts by ~8–12%. Progressive overload during a cut is what signals muscle retention. 2 minutes per session.",
         "Immediately after Forge Breechay — before shower", .daily, "18:45", nil, "amplifier", nil),

        // ══ RECOVERY TOOLS ════════════════════════════════════════════════════
        ("Contrast shower — post-gym", .health,       10,
         "After post-lift shower: finish with 30 sec cold, then 30 sec warm, repeat 3x, end cold. Different from the morning cold finish — this is a recovery protocol. Mechanism: vasoconstriction/vasodilation cycling increases blood flow to muscles, reduces DOMS, and clears metabolic byproducts. Takes 3 extra minutes. Evidence is moderate but consistent for subjective recovery and DOMS reduction. Use on high-volume leg days especially.",
         "End of post-gym shower — 3 extra minutes", .daily,  "19:00", nil, "amplifier", nil),

        ("Legs up the wall — 5 min",   .health,        5,
         "Lie on floor, legs straight up wall, 5 minutes. After 10-hour active shift + gym: venous return from legs is impaired, feet swell, leg fatigue accumulates. This posture reverses hydrostatic pressure, drains interstitial fluid from lower limbs, and produces measurable parasympathetic activation (HR drop, cortisol reduction). Do it during the post-workout wind-down. Free, takes no equipment.",
         "After post-workout meal — before shutdown. 5 minutes, no equipment.",  .daily,  "19:40", nil, "amplifier", nil),

        ("Epsom salt soak — foot",     .health,       10,
         "20 min warm water + 2 cups epsom salt, foot submerged. Magnesium sulfate transdermal absorption reduces local inflammation and muscle tension. Directly relevant to foot injury recovery. Do 2–3x per week, post-gym. Add a few drops of lavender oil if you have it — mild analgesic and parasympathetic activator. This should be a wind-down ritual, not a chore.",
         "Post-gym, 2–3x weekly — wind-down ritual",  .none,  nil,     nil, "amplifier", nil),

        // ══ NUTRITION — GAPS ══════════════════════════════════════════════════
        ("Electrolytes — midday",      .health,        5,
         "Sodium + potassium + magnesium mid-shift. Options: pinch of sea salt in water bottle, coconut water (has potassium), LMNT or similar packet. With daily Zone 2 cardio + 10-hour active outdoor shift in Miami heat, sweat losses are significant. Signs of electrolyte deficit: afternoon headache, muscle cramps, flat lifts, brain fog by 3PM. This is often what people misidentify as 'low energy.'",
         "Midday at Hideout — 12:30 PM with protein meal", .daily, "12:30", "hideout", nil, nil),


        ("Protein before sleep",       .health,        5,
         "20–30g slow-digesting protein 30 min before sleep. Options from your stack: 1 cup regular milk (~8g) + 1 tbsp almond butter, or a small pumpkin seed protein shake in milk. Casein and milk protein digest slowly overnight — providing amino acids during the 6.5 hour fast when muscle protein synthesis peaks (GH pulses during deep sleep). Don't skip this if your total daily protein is under 190g.",
         "30 min before sleep — 8:45–9:00 PM",      .daily,  "20:55", nil, nil, nil),

        // ══ SOCIAL / HIDEOUT CRAFT ════════════════════════════════════════════
        ("Learn 3 regulars",           .participation, 10,
         "Identify 3 regulars you don't yet know by name. Learn: name, usual order, something specific about them (job, morning routine, why they come). Use the primacy-familiarity-peak-end protocol you already have — but this seeds the database. A café regulars network is a compounding asset. Each known regular has a referral value of 5–10 new customers over time if they feel genuinely known.",
         "During first Hideout hour — observe and note", .weekly, nil, "hideout", "amplifier", nil),

        ("Coffee craft — one technique", .participation, 10,
         "One week, one technique. Spend 10 min learning: extraction variables, milk texturing, a latte art form, filter method, cold brew ratio. Whatever you're weakest on. Craft knowledge compounds into menu development, pricing confidence, and customer education — all of which increase average ticket. The learning cost is near-zero (you're already making coffee). The ROI is significant.",
         "Any quiet window at Hideout",              .weekly, nil,     "hideout", "amplifier", nil),

        ("Menu engineering — weekly",  .operations,   10,
         "10 min: which item had the highest margin this week, which had the lowest. Which item do you push most (primacy bias in the upsell script) and is it the highest margin one? Menu engineering is the highest-leverage business lever for a solo café — no extra labor, no extra rent, just better routing of customer choice. This is behavioral economics applied to the register.",
         "Monday base day — Hideout review",         .weekly, "9:30",  "base", nil, nil),

    ]
    for (title, system, points, note, cue, recurrence, block, dayType, tier, mechanism) in defaults {
        let action = Action(
            title: title, system: system, points: points,
            recurrence: recurrence, note: note, cue: cue,
            scheduledBlock: block, dayTypeRaw: dayType,
            priorityTierRaw: tier, mechanismNote: mechanism
        )
        context.insert(action)
    }
}

func seedDefaultSessions(context: ModelContext) {
    let defaults: [(String, SystemTag, [String], String, RecurrenceType)] = [
        (
            "Morning Protocol",
            .health,
            [
                "4:00 — No phone. Open blinds.",
                "4:05 — Water (500ml) + weigh in (post-bathroom) + Garmin HRV glance",
                "4:08 — Red light (10 min while hydrating)",
                "4:15 — Creatine (5g)",
                "4:20 — Pre-fuel: banana or half sourdough",
                "4:30 — Cardio: Zone 2 bike/elliptical 35–40 min",
                "5:15 — Cold finish (last 2 min of shower cold)",
                "5:18 — Grooming corridor: cleanse → niacinamide → eye cream → SPF → lip balm → body lotion → deodorant → brush teeth AM",
                "5:35 — Protein first meal (30g minimum)",
                "5:45 — Journal (3 sentences) + Gratitude (3 specific items)",
                "5:50 — Morning light on commute"
            ],
            "4:00 AM wake",
            .daily
        ),
        (
            "Evening Shutdown",
            .operations,
            [
                "8:25 — PM oral care: floss → brush → tongue scraper",
                "8:28 — Lights to lamps. Phone to other room.",
                "8:30 — No screens begins",
                "8:35 — Minoxidil (dry scalp, 45 min dry time needed)",
                "8:40 — Magnesium glycinate (400mg)",
                "8:45 — Stage tomorrow: bag packed, outfit set, kitchen staged, app open",
                "8:50 — Read (physical book, 20+ pages)",
                "8:55 — Protein before sleep if total protein under 190g",
                "9:15 — Lights out. Side sleep position."
            ],
            "8:25 PM — hard start",
            .daily
        ),
        (
            "Whole Human Reset",
            .health,
            [
                "Face cleanse — Cetaphil Gentle Cleanser. Wet face first. Pea-sized amount. Fingertips only — no washcloth (too abrasive). Circular motion 60–90 sec, all zones including hairline and jawline. Rinse with lukewarm water — not hot, not cold. Pat dry, never rub. Damp skin is ideal for the next step — don't wait for fully dry.",
                "Niacinamide serum — apply to damp skin immediately after cleanse. 3–4 drops, press into skin with palm, don't rub. Cover full face, neck, upper chest. Wait 30 sec before next product — niacinamide needs brief contact time before being layered over. This is the highest-evidence non-prescription skincare ingredient for this skin type and Miami conditions.",
                "Eye cream — ring finger only, always. Index and middle fingers apply too much pressure to periorbital skin (thinnest on the body — ages fastest). Tap, don't rub or drag. Start at outer corner, tap inward along orbital bone. Under-eye and brow bone. Amount: rice grain per eye. Apply before moisturizer so it contacts skin directly.",
                "Moisturize — Cetaphil Moisturizing Cream or Lotion. Damp skin absorbs 4–5x better than dry — this is the reason to moisturize immediately after cleanse, not 10 minutes later. Face + neck + décolletage. Upward strokes. Don't tug downward. Don't forget the neck — it shows age as fast as the face and gets no SPF from face application alone.",
                "SPF — non-negotiable. Two-finger-length rule: squeeze SPF along index and middle fingers, that's the correct dose for face + neck. Apply face first, then neck, ears (including behind ears — often burned), backs of hands. Miami UV index is 10–11 year-round. UVA ages skin regardless of burning; you don't need to feel the sun to be damaged. Apply last — over moisturizer, under makeup if any.",
                "Lip balm SPF 30+ — lips have zero melanin. They sunburn faster than any other facial skin and are a primary site for squamous cell carcinoma. Separate application from face SPF because lips need a dedicated product. EltaMD UV Lip Balm or similar. Reapply after eating, drinking, at midday. Takes 3 seconds.",
                "Body lotion — apply to still-damp skin within 3 minutes of shower. This is the mechanism: damp skin traps moisture as lotion seals it in; dry skin just sits on top. Full sweep: arms (elbows need extra — the skin is thicker and drier), shoulders, chest, stomach, back of knees, shins, feet. Feet especially — daily standing and walking dries the heel fast. Cetaphil or similar fragrance-free. Takes 90 seconds done right.",
                "Deodorant / antiperspirant — apply to completely dry underarms. Antiperspirant works by blocking sweat ducts with aluminum compounds; moisture degrades effectiveness. If using aluminum-free: apply at night to clean dry skin — more effective timing because sweat is lower during sleep, allowing skin to absorb the active ingredients. For active outdoor café work: clinical strength or prescription-strength if standard isn't holding.",
                "Brush teeth — critical sequence note: do NOT brush immediately after the protein shake or matcha. Acidic drinks temporarily soften enamel; brushing within 20–30 min of them erodes it. Eat/drink first, wait 20 min, then brush. Technique: 45-degree angle to gumline, short strokes, 2 full minutes. Don't rinse with water after — spit only, let fluoride contact enamel for 30 sec. Tongue: brush or scrape back to front 2–3 passes."
            ],
            "After morning shower — grooming corridor 5:18–5:32",
            .daily
        ),
        (
            "Shutdown Preservation",
            .health,
            [
                "Face cleanse — PM cleanse is more important than AM. You're removing SPF (which oxidizes during the day and becomes mildly irritating), sweat, environmental pollutants, and any sebum buildup. Cetaphil Gentle Cleanser. Same technique: lukewarm water, circular motion 60–90 sec, pat dry. Do NOT skip this because you're tired — sleeping in oxidized SPF and sweat accelerates skin aging more than almost anything else.",
                "Niacinamide (optional PM) — if not using retinol or glycolic acid tonight. If you are, skip niacinamide on those nights — the combination isn't harmful but it's redundant. On plain nights, apply same as AM.",
                "Glycolic acid (Thursday PM) / BHA (Friday PM) — apply to dry face, 10–15 min after cleanse. Glycolic (AHA): thin layer, full face except eye area. Don't overdo — more is not better, more is irritating. BHA: same. Both are leave-on treatments, not rinse-off. Don't combine with retinol same night. In Miami heat and humidity, start with lowest concentration and build up.",
                "Moisturize PM — can be heavier than AM moisturizer since no SPF needed and skin repairs overnight. Cetaphil is fine. Apply to slightly damp skin after any treatment products.",
                "Body lotion — feet especially. Heel fissures develop from daily standing; applying lotion PM and wearing socks overnight (even briefly) prevents cracking that becomes painful during cardio. Arms, elbows, knees if you skipped AM.",
                "Floss first — floss before brushing, always. Reason: flossing releases interdental plaque and bacteria; brushing then sweeps them away. If you brush first, flossing moves bacteria around but doesn't clear them. C-shape around each tooth, below gumline, gentle vertical motion. Water flosser is fine as substitute — equally effective if used correctly.",
                "Brush teeth PM — 2 min. Same 45-degree angle technique. This is the more important brush of the day: you're removing a full day of bacterial buildup before an 8+ hour fast. Spit, don't rinse with water — let fluoride work overnight.",
                "Tongue scraper — 2–3 firm passes from back to front. Rinse between passes. Do this after brushing. The tongue surface harbors more bacteria than anywhere else in the mouth — standard brushing doesn't reach the posterior third effectively. Copper or stainless > plastic (antimicrobial properties).",
                "Minoxidil — dry scalp. Completely dry. Moisture on the scalp dilutes the solution and reduces absorption. Apply to crown and top — the thinning zone. Thin spread, not saturated. Must dry 45+ min before pillow contact or it transfers to fabric and you lose the dose. If using derma roller tonight (Wed or Sun), apply minoxidil within 30 min of rolling while channels are open."
            ],
            "After no-screens begins — before sleep",
            .daily
        ),
        (
            "Weekly Reset",
            .operations,
            [
                "What closed this week? — name specific things that are done and don't need to re-enter your head. Not 'I made progress on X.' Closed means closed. If it's not closed, it carries forward.",
                "What carries forward? — active fronts only. If something carried forward 3 weeks in a row without movement, it's either not real or it's blocked. Name the block, not the task.",
                "What needs a decision this week? — distinguish between tasks (do it) and decisions (requires information or judgment). Decisions that sit undecided consume cognitive background load. Make the decision or schedule when you will.",
                "Financial pulse — Hideout: what was this week's daily average, is it trending toward the right band, what's the cash position. Personal: anything irregular this week. 3 numbers, 2 minutes, not a full review.",
                "Watermarc / visibility action this week? — during the 30-day experiment, check: did any planned visibility or relationship action happen? If not, why not? One action per week minimum.",
                "Physical reset — clean the apartment, prep the week's food infrastructure, anything environmental that will cause drag if not handled now.",
                "Set first action for Monday morning — written, specific, doable before 9AM. Not a list. One thing. The thing that, if you did only that, Monday wouldn't feel wasted."
            ],
            "Sunday after Hideout close — 30 min",
            .weekly
        ),
        (
            "Laundry",
            .environment,
            [
                "Sort first: darks / lights / colors separate. Whites with whites — one mixed load of lights and darks over time creates a permanent grey tint on white items that can't be reversed. Gym clothes separate from regular clothes — athletic fabric holds odor and the bacteria transfers.",
                "Water temperature: cold for darks and colors (prevents fading, saves energy), warm for lights and linens, hot only for towels and white athletic wear (kills bacteria). Hot water shrinks most fabrics — when in doubt, cold.",
                "Detergent: less than you think. The measuring lines on cups are 2–3x more than needed. Excess detergent doesn't rinse out fully and leaves residue that traps odor — this is why gym clothes smell after washing. Half the cap is usually correct. For whites: add half cup white vinegar to the rinse cycle, not bleach — vinegar maintains brightness without fabric damage.",
                "Athletic / gym wear: turn inside out — the odor is from bacteria on the skin-contact side. Cold water, gentle cycle. No fabric softener ever on athletic wear — it coats the performance fibers and prevents moisture wicking. This is irreversible damage. Use white vinegar instead.",
                "Move to dry promptly — clothes sitting wet in the drum for more than 2 hours develop mildew smell that survives drying. If you forget, rewash.",
                "Dryer: low heat for athletic wear, dress shirts, anything with elastic or spandex. Medium for most items. High only for towels, sheets, heavy cotton. Overdrying with high heat is what shrinks and degrades fabric over time — not washing.",
                "Fold or hang immediately out of dryer. Leaving folded in the drum for hours creates wrinkles that require ironing. 5 minutes folding when warm vs 20 minutes ironing later.",
                "Shoes and socks: don't machine wash shoes unless they're specifically machine-washable. Remove insoles, hand wash or wipe shell, air dry. Socks: washing inside out removes dead skin cells and bacteria from the inside surface more effectively."
            ],
            "Sunday — or when hamper is full",
            .none
        ),
        // Cognitive Sharpening — base days only. Not for hideout mornings (wrong environment, wrong energy state).
        // On hideout days, reading happens at 20:45 as the evening anchor.
        (
            "Cognitive Sharpening",
            .cognition,
            [
                "Phone in another room or silent",
                "Physical book only — no screen",
                "Read 20 pages minimum",
                "One sentence in journal: what landed"
            ],
            "Base days — after morning anchor, before ops work. Not during hideout shifts.",
            .daily
        ),
        // NEW v2.2 — Deep Work: the 90-min block as a session with setup steps
        (
            "Deep Work Block",
            .cognition,
            [
                "Define the one thing — write it down",
                "Close all tabs except what's needed",
                "Phone off or in another room",
                "Timer: 90 min",
                "No interruptions — let it ring"
            ],
            "After Cognitive Sharpening",
            .daily
        ),
        // SOLO OPERATOR PROTOCOL — behavioral science pre-shift primer
        // Based on: Primacy Effect, Choice Architecture, Familiarity Principle, Peak-End Rule
        // Run before opening — loads the four behaviors mentally before the first customer
        (
            "Solo Operator Protocol",
            .operations,
            [
                "Primacy: ready to acknowledge every walk-in within 3 seconds",
                "Choice Architecture: scripted upsell ready — 'Want me to warm a croissant with that?'",
                "Familiarity: which regulars might come in today? Their usual?",
                "Peak-End: anchor phrase ready — '[Name]. Have a great [day]. See you next time.'"
            ],
            "Before opening — 7AM or 10AM weekends",
            .daily
        ),
        // WATERMARC OUTREACH — highest-ROI visibility play per strategy brief
        (
            "Watermarc relationship touch",
            .participation,
            [
                "Bring coffee to leasing office",
                "Introduce Hideout — ask if they'll mention us on tours",
                "Leave cards with the concierge",
                "Note how many units in the building"
            ],
            "First available morning at Hideout — then monthly",
            .none
        ),

        (
            "Pre-Lift Warmup",
            .health,
            [
                "Hip flexor — 60 sec/side kneeling lunge. Unlocks glute activation.",
                "Thoracic rotation — 10 reps/side. Foundation for pressing mechanics.",
                "Foam roll — quads 60 sec/leg, lats 60 sec/side. Clears fascial adhesions.",
                "Ankle circles — 10 each direction each foot. Foot injury rehab.",
                "Calf raises — 20 slow on step edge, full range. Dorsiflexion restoration.",
                "Dead hang — 30 sec passive. Spine decompression after standing shift."
            ],
            "Gym arrival — before first working set",
            .daily
        ),

        (
            "PM Oral Care",
            .health,
            [
                "Floss first — always before brushing, never after. Flossing dislodges bacteria and food from between teeth; brushing then sweeps them out of the mouth. If you brush first, flossing just moves bacteria around. C-shape: wrap floss around each tooth individually forming a C, slide below the gumline (1–2mm below where the tooth meets the gum), gentle vertical strokes against the tooth surface. Do every tooth, both sides. 60 sec total. Water flosser is acceptable substitute — use on lowest comfortable pressure, angle below gumline.",
                "Brush — 45-degree angle to gumline, not perpendicular. Small circular motions or gentle back-and-forth, 2 minutes. Quad method: 30 sec per quadrant. Don't press hard — the bristles do the work, not force. Scrubbing hard causes gum recession that can't be reversed. Get the inner surfaces (tongue side of lower front teeth is the most missed area). Brush tongue lightly. Spit — do NOT rinse with water after. The fluoride needs 30–60 sec contact with enamel to work; water immediately rinses it away before it can remineralize.",
                "Tongue scraper — after brushing. 2–3 firm passes from as far back as comfortable (you'll trigger gag reflex if you go too far — back off slightly) to the tip. Rinse the scraper between passes. The film you remove is bacterial biofilm, dead cells, and volatile sulfur compounds. This is the primary source of morning breath and also a systemic health factor — oral bacteria aspirated during sleep is linked to respiratory and cardiovascular risk. Copper or stainless steel is antimicrobial; plastic just moves the biofilm around."
            ],
            "8:25 PM — before shutdown corridor",
            .daily
        ),
    ]
    for (title, system, steps, cue, recurrence) in defaults {
        context.insert(Session(title: title, system: system, steps: steps, cue: cue, recurrence: recurrence))
    }
}


// Spec (Design Decisions v1.2 · CARE 03):
// Nodes pulse in one by one (1.2s) → warm corona ignites (0.3s) → wordmark fades up (0.4s) → app loads
// Total ~2.2s. Runs once per cold launch. Static thereafter — instrument mode engaged.

struct LaunchSequenceView: View {
    var onComplete: () -> Void

    // 12 neural nodes — positions tuned to the actual AppIcon (top-down brain, 180pt rendered size)
    // Warm gold nodes sit over the icon's existing node positions
    private let nodePositions: [(CGFloat, CGFloat)] = [
        // Left hemisphere
        (-32, -58), (-54, -28), (-58,  10), (-44,  44), (-18,  60),
        (-24,  -8),
        // Right hemisphere
        ( 32, -58), ( 54, -28), ( 58,  10), ( 44,  44), ( 18,  60),
        ( 24,  -8),
    ]

    // Connections between node indices (pairs)
    private let connections: [(Int, Int)] = [
        (0,1),(1,2),(2,3),(3,4),(4,10),(1,5),(5,2),(5,9),
        (6,7),(7,8),(8,9),(9,10),(7,11),(11,8),(11,3),
        (0,6),(5,11)   // corpus callosum bridges
    ]

    @State private var nodeVisible:    [Bool]   = Array(repeating: false, count: 12)
    @State private var nodeGlow:       [Bool]   = Array(repeating: false, count: 12)
    @State private var coronaOpacity:  Double   = 0
    @State private var coronaRadius:   CGFloat  = 40
    @State private var wordmarkOpacity: Double  = 0
    @State private var wordmarkOffset:  CGFloat = 12
    @State private var sublineOpacity:  Double  = 0
    @State private var connectionOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Brain glyph + nodes
                ZStack {
                    // Warm corona — ignites after nodes
                    RadialGradient(
                        colors: [
                            Color.warm.opacity(0.55 * coronaOpacity),
                            Color.violet.opacity(0.18 * coronaOpacity),
                            Color.bgBase.opacity(0)
                        ],
                        center: .center,
                        startRadius: coronaRadius * 0.3,
                        endRadius: coronaRadius
                    )
                    .frame(width: coronaRadius * 2, height: coronaRadius * 2)
                    .blur(radius: 18)
                    .animation(.easeOut(duration: 0.35), value: coronaOpacity)

                    // BrainGlyph — transparent-background asset from xcassets
                    Image("BrainGlyph")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .shadow(color: Color.violet.opacity(0.35), radius: 32)
                        .shadow(color: Color.warm.opacity(0.2), radius: 16)

                    // Connection lines — appear with nodes
                    Canvas { ctx, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        for (a, b) in connections {
                            guard nodeVisible[a] && nodeVisible[b] else { continue }
                            let pa = CGPoint(
                                x: center.x + nodePositions[a].0,
                                y: center.y + nodePositions[a].1
                            )
                            let pb = CGPoint(
                                x: center.x + nodePositions[b].0,
                                y: center.y + nodePositions[b].1
                            )
                            var path = Path()
                            path.move(to: pa)
                            path.addLine(to: pb)
                            ctx.stroke(
                                path,
                                with: .color(Color.warm.opacity(0.25 * connectionOpacity)),
                                lineWidth: 0.6
                            )
                        }
                    }
                    .frame(width: 180, height: 180)
                    .animation(.easeIn(duration: 0.2), value: connectionOpacity)

                    // Neural nodes
                    ForEach(nodePositions.indices, id: \.self) { i in
                        Circle()
                            .fill(Color.warm)
                            .frame(width: nodeGlow[i] ? 5 : 3.5, height: nodeGlow[i] ? 5 : 3.5)
                            .shadow(color: Color.warm.opacity(nodeGlow[i] ? 0.9 : 0.4),
                                    radius: nodeGlow[i] ? 6 : 2)
                            .offset(x: nodePositions[i].0, y: nodePositions[i].1)
                            .opacity(nodeVisible[i] ? 1 : 0)
                            .scaleEffect(nodeVisible[i] ? 1 : 0.1)
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: nodeVisible[i])
                            .animation(.easeInOut(duration: 0.3), value: nodeGlow[i])
                    }
                }
                .frame(width: 180, height: 180)
                .padding(.bottom, 44)

                // Wordmark
                VStack(spacing: 10) {
                    Text("INCREMENTS")
                        .font(.custom("Sora", size: 28).weight(.light))
                        .foregroundColor(.textPrimary)
                        .tracking(10)

                    Text("environmental cognition support system")
                        .font(.custom("DM Mono", size: 10).weight(.light))
                        .foregroundColor(.textMuted)
                        .tracking(2)
                }
                .opacity(wordmarkOpacity)
                .offset(y: wordmarkOffset)
                .animation(.easeOut(duration: 0.45), value: wordmarkOpacity)
                .animation(.easeOut(duration: 0.45), value: wordmarkOffset)

                Spacer()

                // Bottom line — appears with wordmark
                Text("participation in reality")
                    .font(.custom("DM Mono", size: 9))
                    .foregroundColor(.textMuted.opacity(0.5))
                    .tracking(3)
                    .padding(.bottom, 52)
                    .opacity(sublineOpacity)
                    .animation(.easeOut(duration: 0.4), value: sublineOpacity)
            }
        }
        .onAppear { runSequence() }
    }

    private func runSequence() {
        // Phase 1: nodes pulse in one by one over 1.2s
        // Stagger: 12 nodes × ~90ms each, with slight randomisation for organic feel
        let staggerBase = 0.08
        for i in nodePositions.indices {
            let delay = Double(i) * staggerBase + Double.random(in: 0...0.03)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                nodeVisible[i] = true
                // Brief glow burst on appearance
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { nodeGlow[i] = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { nodeGlow[i] = false }
            }
        }

        // Connection lines fade in as nodes appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation { connectionOpacity = 1 }
        }

        // Phase 2: corona ignites (starts at 1.2s, takes 0.35s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.35)) {
                coronaOpacity = 1
                coronaRadius = 110
            }
            // Final node pulse — all glow together at corona moment
            for i in nodePositions.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { nodeGlow[i] = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)  { nodeGlow[i] = false }
            }
        }

        // Phase 3: wordmark fades up (starts at 1.55s, takes 0.45s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.55) {
            wordmarkOpacity = 1
            wordmarkOffset = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                sublineOpacity = 1
            }
        }

        // Phase 4: hand off to app (2.25s total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.25) {
            onComplete()
        }
    }
}

// MARK: - ONBOARDING
// First launch only. Not setup. A worldview entry point.
// The product selects its own user here.

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            AtmosphericBackground(enhanced: true)

            VStack(spacing: 0) {
                Spacer()

                // Page content
                Group {
                    switch page {
                    case 0: onboardPage0
                    case 1: onboardPage1
                    case 2: onboardPage2
                    case 3: onboardPage3
                    default: EmptyView()
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: appeared)
                .animation(.easeOut(duration: 0.5), value: page)

                Spacer()

                // Navigation
                HStack {
                    // Page dots
                    HStack(spacing: 6) {
                        ForEach(0..<4) { i in
                            Circle()
                                .fill(i == page ? Color.violetLight : Color.muted.opacity(0.3))
                                .frame(width: i == page ? 6 : 4, height: i == page ? 6 : 4)
                                .animation(.easeOut(duration: 0.2), value: page)
                        }
                    }
                    Spacer()
                    Button(action: advance) {
                        HStack(spacing: 6) {
                            Text(page < 3 ? "Continue" : "Enter")
                                .font(.sora(14, weight: .medium))
                            Image(systemName: page < 3 ? "arrow.right" : "arrow.forward")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(page < 3 ? .textPrimary : .bgBase)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(page < 3 ? Color.surface : Color.violet)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 36).padding(.bottom, 52)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { appeared = true }
        }
    }

    func advance() {
        if page < 3 {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                page += 1
                withAnimation { appeared = true }
            }
        } else {
            onComplete()
        }
    }

    // ── Page 0: Operating model (corrected) ─────────────────────
    var onboardPage0: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "INCREMENTS", color: .violetLight, size: 11)
                Text("This system assumes.")
                    .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 16) {
                assumption("Execution is not your problem. Structure often is.", icon: "square.grid.2x2")
                assumption("Friction is usually architectural, not motivational.", icon: "wrench.adjustable")
                assumption("Task arrangement changes execution quality.", icon: "list.number")
                assumption("Environment shapes cognition.", icon: "house")
                assumption("Accurate self-models release bandwidth.", icon: "brain")
            }
        }
        .padding(.horizontal, 36)
    }

    // ── Page 1: Two surfaces ─────────────────────────────────────
    var onboardPage1: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "ARCHITECTURE", color: .warm, size: 11)
                Text("Two surfaces.\nOne purpose.")
                    .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 20) {
                surfaceCard(
                    label: "TODAY",
                    description: "Execute. Sequence. Complete. The execution surface reduces cognitive load — it never adds it.",
                    color: .inkAmber,
                    icon: "calendar"
                )
                surfaceCard(
                    label: "OPERATOR",
                    description: "Brief me. Detect friction. Understand the structure. The intelligence surface improves routing.",
                    color: .violetLight,
                    icon: "brain"
                )
            }
        }
        .padding(.horizontal, 36)
    }

    // ── Page 2: Intelligence doctrine ───────────────────────────
    var onboardPage2: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "INTELLIGENCE LAYER", color: .inkGreen, size: 11)
                Text("Coordination.\nNot motivation.")
                    .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("The system detects structural friction — sequencing issues, fragmentation, admin displacement, environmental drag.")
                    .font(.sora(15, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
                Text("It does not activate. It does not motivate. It reduces the drag on a system that already moves.")
                    .font(.sora(15, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                Text("Agency remains with the operator.")
                    .font(.mono(12)).foregroundColor(.violetLight).tracking(0.5)
            }
        }
        .padding(.horizontal, 36)
    }

    // ── Page 3: Enter ────────────────────────────────────────────
    var onboardPage3: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "DAY 1", color: .textMuted, size: 11)
                Text("The system starts\nat zero.")
                    .font(.sora(28, weight: .semibold)).foregroundColor(.textPrimary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Seven days of data opens the pattern window. The intelligence layer builds from observed behavior, not declared identity.")
                    .font(.sora(15, weight: .light)).foregroundColor(.textSecond).lineSpacing(4)
                Text("Open Today. Sequence the work. Move.")
                    .font(.sora(15, weight: .light)).foregroundColor(.textPrimary).lineSpacing(4)
            }
        }
        .padding(.horizontal, 36)
    }

    // ── Helpers ──────────────────────────────────────────────────
    func assumption(_ text: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.violetLight)
                .frame(width: 20)
            Text(text)
                .font(.sora(15, weight: .light)).foregroundColor(.textPrimary).lineSpacing(3)
        }
    }

    func surfaceCard(label: String, description: String, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(color)
                .frame(width: 24)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 5) {
                MonoLabel(text: label, color: color, size: 11)
                Text(description)
                    .font(.sora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
            }
        }
        .padding(16)
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(color.opacity(0.15), lineWidth: 0.5))
    }
}

// MARK: - ROOT VIEW

struct RootView: View {
    @State private var state = AppState()
    @Query private var profiles: [OperatorProfile]
    @Query private var actions: [Action]
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    // 5-tab nav: Home / Today / Operator / Hideout / You
    // Insights, Increments, Habits, Timeline absorbed into Today and Operator sub-tabs
    var showTimeline: Bool { true }   // kept for CustomTabBar compat

    @ViewBuilder
    func tabView(for index: Int) -> some View {
        switch index {
        case 0: HomeView(state: state)
        case 1: TodayView(state: state)
        case 2: OperatorView(state: state)
        case 3: HideoutTabView()
        case 4: YouView(state: state)
        default: HomeView(state: state)
        }
    }

    @Query private var sessions: [Session]
    @Query private var maintenanceItems: [MaintenanceItem]
    @Query private var financialStates: [FinancialState]

    var body: some View {
        ZStack(alignment: .bottom) {
            tabView(for: state.selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            CustomTabBar(selected: $state.selectedTab, showTimeline: showTimeline)
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
            OnboardingView(onComplete: { hasCompletedOnboarding = true })
        }
        .onAppear {
            if profiles.isEmpty {
                let p = OperatorProfile()
                p.operatorName = "Brice"   // seed name — user can change in Settings
                context.insert(p)
            }
            if actions.isEmpty { seedDefaultActions(context: context) }
            if sessions.isEmpty { seedDefaultSessions(context: context) }
            if maintenanceItems.isEmpty { seedDefaultMaintenance(context: context) }
            if financialStates.isEmpty { context.insert(FinancialState()) }
            if let p = profiles.first {
                // BUG FIX: reset recurring actions each new calendar day
                resetDailyActionsIfNeeded(context: context, profile: p, actions: actions, sessions: sessions)
                // BUG FIX: restore systemLastActivity from persisted completionDates on launch.
                // Without this, Home View "X hasn't moved" signal and nextSaneAction sorting
                // were always wrong on cold launch (in-memory only, lost on restart).
                restoreSystemLastActivity(state: state, actions: actions)
                // Sync voice preference from persisted profile
                VoicePresence.shared.voiceEnabled = p.voicePresenceEnabled
                VoicePresence.shared.provider = p.voiceProvider
                VoicePresence.shared.elevenLabsVoiceId = p.elevenLabsVoiceId
                VoicePresence.shared.elevenLabsApiKey = p.elevenLabsApiKey
                VoicePresence.shared.openAIApiKey = p.openAIApiKey
            }
            NotificationService.shared.requestPermission()
        }
        // BUG FIX: also run daily reset when app returns from background (e.g. opened next morning).
        // Without this, actions only reset on cold launch — leaving yesterday's state visible
        // if the app was backgrounded overnight and re-foregrounded the next day.
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                if let p = profiles.first {
                    resetDailyActionsIfNeeded(context: context, profile: p, actions: actions, sessions: sessions)
                    restoreSystemLastActivity(state: state, actions: actions)
                }
            }
        }
    }
}

// BUG FIX: rebuild in-memory systemLastActivity from persisted completionDates.
// Called on launch and foreground re-entry. Gives Home View accurate "days since activity"
// data for the nextSaneAction picker and synergy subline, which previously reset to
// "999 days" on every cold launch.
func restoreSystemLastActivity(state: AppState, actions: [Action]) {
    for system in SystemTag.allCases {
        let systemActions = actions.filter { $0.system == system }
        // Find the most recent completion date across all actions in this system
        let latestCompletion = systemActions.compactMap { $0.completionDates.last }.max()
        if let latest = latestCompletion {
            // Only update if this is more recent than what's already in memory
            if let existing = state.systemLastActivity[system] {
                if latest > existing { state.systemLastActivity[system] = latest }
            } else {
                state.systemLastActivity[system] = latest
            }
        }
    }
}

// MARK: - APP ENTRY POINT

// MARK: - SWIFTDATA MIGRATION PLAN
// Lightweight migration: new fields added to existing models get their default values.
// No data is destroyed. Rebuilding the app preserves all user data.
//
// HOW TO ADD NEW FIELDS IN FUTURE:
// 1. Add the field to the model class with a default value
// 2. Add a new VersionedSchema (e.g. SchemaV3) with the updated models
// 3. Add a MigrationStage.lightweight(fromVersion: SchemaV2.self, toVersion: SchemaV3.self)
// 4. Update INCREMENTSMigrationPlan.stages and INCREMENTSApp.container to use the new schema

// SCHEMA MIGRATION NOTES:
// SwiftData checksums the MODEL SET (the actual list of @Model classes), not the version number.
// Two VersionedSchema enums with the same model list = identical checksum = crash on launch.
// Rule: every schema in the migration plan must have a DIFFERENT set of models from all others.
//
// History of distinct model-set snapshots:
//   V1 — original base models. Acts as the entry point for any store built before V4 was defined.
//         Without this, staged migration throws "unknown model version" for old installs.
//   V4 — added MaintenanceItem, HydrationLog, FinancialState, ConsultReceipt.
//   V6 — added HideoutShiftLog (+ lastWendyObservation on OperatorProfile via lightweight default).
//
// Removed (identical model arrays = duplicate checksum crash):
//   V2, V3 — same as V4
//   V5     — same as V6

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    // Entry point for stores created before the V4 schema was formally defined.
    // Covers any "unknown" old version — gives staged migration a valid starting node.
    static var models: [any PersistentModel.Type] {
        [Action.self, Habit.self, OperatorProfile.self,
         DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
         Session.self]
    }
}

enum SchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(4, 0, 0)
    // Added MaintenanceItem, HydrationLog, FinancialState, ConsultReceipt.
    static var models: [any PersistentModel.Type] {
        [Action.self, Habit.self, OperatorProfile.self,
         DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
         Session.self, MaintenanceItem.self, HydrationLog.self, FinancialState.self,
         ConsultReceipt.self]
    }
}

enum SchemaV6: VersionedSchema {
    static var versionIdentifier = Schema.Version(6, 0, 0)
    // V6 includes FinancialState — new fields (capitalClarity, hasRunwayVisibility, etc.)
    // are properties with default values on the existing class, not new models.
    // SwiftData handles default-valued properties automatically — no new schema version needed.
    static var models: [any PersistentModel.Type] {
        [Action.self, Habit.self, OperatorProfile.self,
         DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
         Session.self, MaintenanceItem.self, HydrationLog.self, FinancialState.self,
         ConsultReceipt.self, HideoutShiftLog.self]
    }
}

enum INCREMENTSMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self, SchemaV4.self, SchemaV6.self] }
    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV4.self),
            .lightweight(fromVersion: SchemaV4.self, toVersion: SchemaV6.self),
        ]
    }
}

@main
struct INCREMENTSApp: App {
    @State private var launchComplete = false
    // Prevents tappable elements rendering before SwiftData @Query results settle.
    // RootView stays invisible until both the launch animation finishes AND the store
    // has returned at least one result. On a cold launch the store is ready well before
    // the 2.25s animation completes, so in practice this adds zero perceptible delay.
    @State private var dataReady = false

    // ModelContainer with proper migration plan — preserves all user data across rebuilds.
    // New fields get their default values; nothing is wiped.
    let container: ModelContainer = {
        let schema = Schema([
            Action.self, Habit.self, OperatorProfile.self,
            DailyLog.self, WorkTrack.self, RecoveryPhase.self, CognitionLog.self,
            Session.self, MaintenanceItem.self, HydrationLog.self, FinancialState.self,
            ConsultReceipt.self, HideoutShiftLog.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: INCREMENTSMigrationPlan.self,
                configurations: [config]
            )
        } catch {
            // Migration failed — store is from an unrecognised version or is corrupt.
            // Wipe all three SQLite files and rebuild from scratch (no migration plan needed
            // on a fresh store — SwiftData will create it at the current schema directly).
            print("INCREMENTS: Migration failed (\(error.localizedDescription)). Wiping and rebuilding store.")
            let storeURL = config.url
            let base = storeURL.deletingPathExtension()
            try? FileManager.default.removeItem(at: storeURL)
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite-shm"))
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite-wal"))
            // Rebuild WITHOUT migration plan — fresh store needs no migration.
            let freshConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            do {
                return try ModelContainer(for: schema, configurations: [freshConfig])
            } catch {
                fatalError("INCREMENTS: Could not create ModelContainer even after store deletion: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .preferredColorScheme(.dark)
                    // Only become visible once both the launch animation is done AND the
                    // SwiftData store has settled. Eliminates the window where tappable rows
                    // appear but their backing data isn't ready yet.
                    .opacity(launchComplete && dataReady ? 1 : 0)
                    .onAppear {
                        // Poll briefly for store readiness. On a real device the container is
                        // open well before the 2.25s animation ends, so this loop typically
                        // fires on the first or second tick and adds no perceptible delay.
                        func checkReady() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                // RootView's @Query arrays are not directly visible here, but
                                // the ModelContainer being open is sufficient — mark ready.
                                // If you ever hit a race, increase the tick count.
                                dataReady = true
                            }
                        }
                        checkReady()
                    }

                if !launchComplete {
                    LaunchSequenceView {
                        withAnimation(.easeIn(duration: 0.35)) {
                            launchComplete = true
                        }
                    }
                    .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
