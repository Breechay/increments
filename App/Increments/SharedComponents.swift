import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications
import Foundation


// MARK: - GLOBAL APP METRICS (iPad adaptive sizing)
// Single source of truth for all spacing, typography, and layout decisions.
// Injected once at RootView, read everywhere via @Environment(\.appMetrics).
// "arm's distance" iPad mode: bigger type, more breathing room, same information density.

struct AppMetrics {
    let isIPad: Bool
    let isLandscape: Bool

    // ── Typography ──────────────────────────────────────────────────────────
    var displaySize:   CGFloat { isIPad ? 38 : 28 }   // Day counter, hero numbers
    var titleSize:     CGFloat { isIPad ? 26 : 20 }   // Section headers, sheet titles
    var headlineSize:  CGFloat { isIPad ? 18 : 15 }   // Card titles, action names
    var bodySize:      CGFloat { isIPad ? 15 : 12 }   // Body text, descriptions
    var captionSize:   CGFloat { isIPad ? 13 : 11 }   // Supporting detail
    var monoSize:      CGFloat { isIPad ? 12 : 10 }   // Mono labels (standard)
    var monoSmall:     CGFloat { isIPad ? 11 : 9  }   // Mono labels (small)
    var bigNum:        CGFloat { isIPad ? 48 : 36 }   // Revenue numbers, large stats

    // ── Spacing ─────────────────────────────────────────────────────────────
    var hPad:          CGFloat { isIPad ? 36 : 24 }   // Horizontal screen padding
    var cardPad:       CGFloat { isIPad ? 22 : 16 }   // Card internal padding
    var cardRadius:    CGFloat { isIPad ? 18 : 14 }   // Card corner radius
    var cardSpacing:   CGFloat { isIPad ? 16 : 10 }   // Gap between cards
    var sectionGap:    CGFloat { isIPad ? 28 : 16 }   // Gap between sections
    var touchTarget:   CGFloat { isIPad ? 56 : 44 }   // Min tappable height
    var tabBarHeight:  CGFloat { isIPad ? 72 : 50 }   // Bottom tab bar height

    // ── Content width ────────────────────────────────────────────────────────
    // On iPad we cap content width so long lines don't stretch the full screen.
    // Centred in the available space via .frame(maxWidth:).
    var maxContentWidth: CGFloat { isIPad ? 720 : .infinity }

    // No two-column split outside Hideout — all other tabs are
    // single-column reference/execution surfaces that work better wide.
    var useWideColumn: Bool { isIPad }

    // Hideout-specific: two-column only in Hideout tab, iPad landscape only
    var useTwoColumn:  Bool   { isIPad && isLandscape }
    var leftColWidth:  CGFloat { 340 }  // Left panel (dashboard) width in landscape

    // bigNumberSize — maps old HideoutLayoutMetrics name
    var bigNumberSize: CGFloat { bigNum }
    // contentRadius — maps old name, same as cardRadius
    var contentRadius: CGFloat { cardRadius }
}

private struct AppMetricsKey: EnvironmentKey {
    static let defaultValue = AppMetrics(isIPad: false, isLandscape: false)
}

extension EnvironmentValues {
    var appMetrics: AppMetrics {
        get { self[AppMetricsKey.self] }
        set { self[AppMetricsKey.self] = newValue }
    }
}

// Lightweight wrapper — wraps GeometryReader, detects device + orientation, injects metrics.
// Used once at RootView level; all child views just read from environment.
struct AppMetricsProvider<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            let isIPad     = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = geo.size.width > geo.size.height
            let metrics    = AppMetrics(isIPad: isIPad, isLandscape: isLandscape)
            content
                .environment(\.appMetrics, metrics)
        }
    }
}


// MARK: - ADAPTIVE CONTENT WIDTH MODIFIER
// Apply to the top-level ScrollView content VStack in each tab.
// On iPad: centres content and caps width at 720pt for readability.
// On iPhone: no change — full width as before.
extension View {
    func adaptiveContentWidth(_ metrics: AppMetrics) -> some View {
        self
            .frame(maxWidth: metrics.maxContentWidth)
            .frame(maxWidth: .infinity)  // outer frame still fills screen (centers the inner cap)
    }
}

// MARK: - REUSABLE COMPONENTS

// FIX V04 — THREE-TIER CARD HIERARCHY
// Primary: action layer (operative) — surface fill, current treatment
// Secondary: context layer (support) — surface2, +4pt padding
// Ambient: infrastructure layer — no background, left border rule only

enum CardStyle {
    case primary    // Today actions, One Door card, operative items
    case secondary  // Morning evidence, status rows, system summaries
    case ambient    // Metadata, settings, guardrails
}

struct CardView<Content: View>: View {
    let style: CardStyle
    let content: Content
    @Environment(\.appMetrics) private var metrics

    init(style: CardStyle = .primary, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    // CardView automatically adapts padding and radius from AppMetrics.
    // Every card in the app inherits iPad sizing for free.
    var pad: CGFloat { metrics.cardPad }
    var radius: CGFloat { metrics.cardRadius }

    var body: some View {
        switch style {
        case .primary:
            content
                .padding(pad)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: radius))
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .strokeBorder(Color.white.opacity(0.04), lineWidth: 0.5)
                )
                .shadow(color: Color.bgBase.opacity(0.7), radius: 6, x: 0, y: 3)
                .shadow(color: Color.violet.opacity(0.05), radius: 18, x: 0, y: 8)
        case .secondary:
            content
                .padding(pad)
                .background(Color.surface2)
                .clipShape(RoundedRectangle(cornerRadius: radius))
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .strokeBorder(Color.white.opacity(0.03), lineWidth: 0.5)
                )
                .shadow(color: Color.bgBase.opacity(0.5), radius: 4, x: 0, y: 2)
        case .ambient:
            HStack(spacing: 0) {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.warm.opacity(0.45), Color.violet.opacity(0.18)],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .frame(width: 1)
                content
                    .padding(.leading, metrics.isIPad ? 18 : 14)
                    .padding(.vertical, metrics.isIPad ? 14 : 10)
            }
        }
    }
}

struct MonoLabel: View {
    let text: String
    var color: Color = .textMuted
    var size: CGFloat = 11
    @Environment(\.appMetrics) private var metrics

    var body: some View {
        // Scale up by 2pt on iPad — keeps the same visual weight at arm's distance
        let effectiveSize = size + (metrics.isIPad ? 2 : 0)
        Text(text).font(.mono(effectiveSize)).foregroundColor(color).tracking(2.0).textCase(.uppercase)
    }
}

// Section headers with subtle warm accent dot — more presence than plain MonoLabel
struct SectionHeader: View {
    let text: String
    var color: Color = .textMuted
    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(color.opacity(0.35))
                .frame(width: 16, height: 0.5)
            MonoLabel(text: text, color: color, size: 10)
        }
    }
}

struct SystemBadge: View {
    let system: SystemTag
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: system.icon).font(.system(size: 10))
            Text(system.label).font(.mono(11)).tracking(1.0)   // FIX V03 — 9pt → 11pt, tracking reduced
        }
        .foregroundColor(system.color)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(system.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct CircularProgress: View {
    let value: Double
    let size: CGFloat
    var color: Color = .violet
    var lineWidth: CGFloat = 3
    var body: some View {
        ZStack {
            Circle().stroke(Color.surface2, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: value)
                .stroke(
                    LinearGradient(colors: [color, color.opacity(0.6)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: value)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - ACTION DETAIL SHEET
// Opened by long-pressing an action row. Shows the full context: note, cue, stats.
// This is the "how do I actually do this" view — not editing, just following.

struct ActionDetailSheet: View {
    let action: Action
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    @Query private var allSessions: [Session]
    @State private var selectedSession: Session? = nil

    var relatedSessions: [Session] {
        let title = action.title.lowercased()
        // Direct keyword match first
        let direct = allSessions.filter { session in
            let st = session.title.lowercased()
            return session.isActive && (
                st.contains(title.prefix(8)) ||
                title.contains("morning") && st.contains("morning") ||
                title.contains("evening") && (st.contains("evening") || st.contains("shutdown")) ||
                title.contains("pm oral") && st.contains("shutdown") ||
                title.contains("grooming") && (st.contains("whole human") || st.contains("morning")) ||
                title.contains("shutdown") && st.contains("shutdown") ||
                title.contains("weekly") && st.contains("weekly") ||
                title.contains("laundry") && st.contains("laundry") ||
                title.contains("warmup") && st.contains("morning") ||
                title.contains("pre-lift") && st.contains("morning") ||
                title.contains("meal") && st.contains("morning") ||
                title.contains("stage tomorrow") && st.contains("shutdown") ||
                title.contains("read before sleep") && st.contains("shutdown")
            )
        }
        if !direct.isEmpty { return direct }
        // Fallback: same system, max 2
        return Array(allSessions.filter { $0.system == action.system && $0.isActive }.prefix(2))
    }

    var completionPct: String {
        String(format: "%.0f%%", action.completionRate * 100)
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)

                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                // System color dot
                                Circle()
                                    .fill(action.system.color)
                                    .frame(width: 6, height: 6)
                                MonoLabel(text: action.system.rawValue.uppercased(), color: action.system.color, size: 9)
                                if let block = action.scheduledBlock {
                                    MonoLabel(text: "· \(formatBlockTime(block))", color: action.system.color.opacity(0.6), size: 9)
                                }
                            }
                            Text(action.title)
                                .font(.sora(20, weight: .semibold))
                                .foregroundColor(.textPrimary)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.textMuted)
                                .frame(width: 28, height: 28)
                                .background(Color.surface2)
                                .clipShape(Circle())
                        }
                    }

                    // The note — execution cue — short and actionable
                    if let note = action.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            MonoLabel(text: "EXECUTE", color: action.system.color, size: 9)
                            Text(note)
                                .font(.sora(14, weight: .light))
                                .foregroundColor(.textPrimary)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(action.system.color.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(action.system.color.opacity(0.12), lineWidth: 0.5)
                        )
                    }

                    // Mechanism note — why this works, expandable
                    if let mechanism = action.mechanismNote, !mechanism.isEmpty {
                        MechanismNoteView(mechanism: mechanism, systemColor: action.system.color)
                    }

                    // Cue
                    if let cue = action.cue, !cue.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "CUE", color: .textMuted, size: 10)
                            Text(cue)
                                .font(.mono(13))
                                .foregroundColor(.textSecond)
                                .tracking(0.3)
                        }
                    }

                    // Stats — only if there's real data
                    if action.daysSinceCreated >= 3 {
                        Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                        HStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "COMPLETION", color: .textMuted, size: 10)
                                Text(completionPct)
                                    .font(.sora(18, weight: .semibold))
                                    .foregroundColor(action.completionRate >= 0.7 ? .inkGreen :
                                                     action.completionRate >= 0.4 ? .inkAmber : .textSecond)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "SKIPPED", color: .textMuted, size: 10)
                                Text("\(action.skipCount)×")
                                    .font(.sora(18, weight: .semibold))
                                    .foregroundColor(action.skipCount >= 4 ? .inkAmber : .textSecond)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                MonoLabel(text: "DAYS", color: .textMuted, size: 10)
                                Text("\(action.daysSinceCreated)")
                                    .font(.sora(18, weight: .semibold))
                                    .foregroundColor(.textSecond)
                            }
                        }
                    }

                    // Complete button — if not already done
                    if !action.isCompleted {
                        Button(action: {
                            onComplete()
                            isPresented = false
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 14, weight: .light))
                                Text("Mark done")
                                    .font(.sora(13, weight: .medium)).tracking(0.3)
                            }
                            .foregroundColor(action.system.color)
                            .frame(maxWidth: .infinity).frame(height: 46)
                            .background(action.system.color.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(action.system.color.opacity(0.25), lineWidth: 1)
                            )
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.inkGreen)
                            Text("Done today")
                                .font(.mono(11))
                                .foregroundColor(.textMuted)
                                .tracking(0.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 6)
                    }

                    // Related protocols — same system, tap to open
                    if !relatedSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Rectangle().fill(Color.muted.opacity(0.2)).frame(height: 0.5)
                            MonoLabel(text: "RELATED PROTOCOLS", color: .textMuted, size: 10)
                            ForEach(relatedSessions) { session in
                                Button(action: { selectedSession = session; isPresented = false }) {
                                    HStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(session.system.color.opacity(0.6))
                                            .frame(width: 2, height: 28)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(session.title)
                                                .font(.sora(13, weight: .medium))
                                                .foregroundColor(.textPrimary)
                                            if !session.cue.isEmpty {
                                                Text(session.cue)
                                                    .font(.mono(10))
                                                    .foregroundColor(.textMuted)
                                                    .tracking(0.3)
                                            }
                                        }
                                        Spacer()
                                        MonoLabel(text: "\(session.steps.count) STEPS", color: .textMuted, size: 10)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10, weight: .light))
                                            .foregroundColor(.textMuted)
                                    }
                                    .padding(12)
                                    .background(Color.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                }
                .padding(28)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.bgBase)
        .sheet(item: $selectedSession) { session in
            SessionExecutionView(session: session) { selectedSession = nil }
        }
    }
}


struct ActionRow: View {
    let action: Action
    var onComplete: () -> Void
    @State private var glowing = false
    @State private var showFrictionNudge = false
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                // Completion circle — tap to complete
                Button(action: {
                    withAnimation(.spring(response: 0.28)) { glowing = true; onComplete() }
                }) {
                    ZStack {
                        Circle()
                            .fill(action.isCompleted ? Color.inkGreen.opacity(0.15) :
                                  action.priorityTier == .anchor ? action.system.color.opacity(0.15) :
                                  action.priorityTier == .amplifier ? action.system.color.opacity(0.03) :
                                  action.system.color.opacity(0.06))
                            .frame(width: 22, height: 22)
                        Circle()
                            .stroke(action.isCompleted ? Color.inkGreen :
                                    action.priorityTier == .anchor ? action.system.color.opacity(0.8) :
                                    action.priorityTier == .amplifier ? action.system.color.opacity(0.2) :
                                    action.system.color.opacity(0.4),
                                    lineWidth: action.priorityTier == .anchor ? 2 : 1.5)
                            .frame(width: 22, height: 22)
                        if action.isCompleted {
                            Image(systemName: "checkmark").font(.system(size: 9, weight: .semibold)).foregroundColor(.inkGreen)
                        }
                    }
                }
                .shadow(color: action.isCompleted ? Color.inkGreen.opacity(glowing ? 0.5 : 0.15) : .clear, radius: 8)

                // Text area
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        if let block = action.scheduledBlock, !action.isCompleted {
                            Text(formatBlockTime(block))
                                .font(.mono(10))
                                .foregroundColor(action.system.color.opacity(0.8))
                                .tracking(0.5)
                                .fixedSize()
                        }
                        Text(action.title)
                            .font(.sora(14, weight: action.priorityTier == .anchor ? .medium : .regular))
                            .foregroundColor(action.isCompleted ? .textMuted :
                                             action.priorityTier == .amplifier ? .textSecond : .textPrimary)
                            .strikethrough(action.isCompleted, color: .textMuted)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        if let mode = action.cognitionMode, !action.isCompleted {
                            Image(systemName: mode.icon)
                                .font(.system(size: 10, weight: .light))
                                .foregroundColor(mode == .creative ? .warm :
                                                 mode == .analytical ? .violetLight : .textMuted)
                                .fixedSize()
                        }
                    }
                    // Subtitle: first line of note (most useful info — foods, what to do)
                    if !action.isCompleted {
                        let subtitle: String = {
                            if let note = action.note, !note.isEmpty {
                                let firstLine = note.components(separatedBy: "\n").first ?? note
                                return firstLine.count > 60 ? String(firstLine.prefix(60)) + "…" : firstLine
                            } else if let cue = action.cue, !cue.isEmpty {
                                return cue
                            }
                            return ""
                        }()
                        if !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.sora(11, weight: .light))
                                .foregroundColor(.textMuted.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                if action.isHighFriction && !action.isCompleted {
                    Button(action: { withAnimation(.easeOut(duration: 0.2)) { showFrictionNudge.toggle() } }) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.inkAmber.opacity(0.7))
                    }
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .onTapGesture { showDetail = true }

            if showFrictionNudge && !action.isCompleted {
                HStack(spacing: 8) {
                    Rectangle().fill(Color.inkAmber.opacity(0.3)).frame(width: 1)
                        .padding(.leading, 35)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skipped \(action.skipCount)×")
                            .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.3)
                        Text("Topology mismatch — check time, cue, or sequence.")
                            .font(.mono(10)).foregroundColor(.textMuted).tracking(0.2)
                    }
                    Spacer()
                }
                .padding(.top, 6).padding(.bottom, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onChange(of: glowing) { _, new in
            if new { DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { glowing = false } }
        }
        .sheet(isPresented: $showDetail) {
            ActionDetailSheet(action: action, isPresented: $showDetail, onComplete: onComplete)
        }
    }
}


struct AtmosphericBackground: View {
    var enhanced: Bool = false   // Home gets a deeper treatment as the daily entry point
    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            if enhanced {
                // Now — warm bloom from top, violet from far corner, grounded
                RadialGradient(colors: [Color.warm.opacity(0.09), Color.bgBase],
                               center: .init(x: 0.5, y: 0.1), startRadius: 0, endRadius: 380).ignoresSafeArea()
                RadialGradient(colors: [Color.violet.opacity(0.10), Color.bgBase],
                               center: .topTrailing, startRadius: 0, endRadius: 460).ignoresSafeArea()
                RadialGradient(colors: [Color.violetDim.opacity(0.06), Color.bgBase],
                               center: .bottomLeading, startRadius: 0, endRadius: 280).ignoresSafeArea()
            } else {
                // Standard — instrument-mode, nearly flat
                RadialGradient(colors: [Color.violet.opacity(0.10), Color.bgBase],
                               center: .topTrailing, startRadius: 0, endRadius: 400).ignoresSafeArea()
                RadialGradient(colors: [Color.warm.opacity(0.05), Color.bgBase],
                               center: .bottomLeading, startRadius: 0, endRadius: 350).ignoresSafeArea()
            }
        }
    }
}

// MARK: - MECHANISM NOTE (two-layer architecture)
// EXPL-01: "Why this works" — expandable in action detail sheet
// Causal mechanism that turns arbitrary compliance into intelligent buy-in

struct MechanismNoteView: View {
    let mechanism: String
    let systemColor: Color
    @State private var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation(.easeOut(duration: 0.2)) { expanded.toggle() } }) {
                HStack(spacing: 8) {
                    Image(systemName: "atom")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(systemColor.opacity(0.7))
                    MonoLabel(text: "WHY THIS WORKS", color: systemColor.opacity(0.8), size: 10)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.textMuted)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(systemColor.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: expanded ? 12 : 12))
            }
            .buttonStyle(.plain)

            if expanded {
                Text(mechanism)
                    .font(.sora(13, weight: .light))
                    .foregroundColor(.textSecond)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(18)
                    .background(systemColor.opacity(0.05))
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 0, bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12, topTrailingRadius: 0
                    ))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(systemColor.opacity(0.15), lineWidth: 0.5)
        )
    }
}

// Inline row for Home tab — opens ActionDetailSheet on tap
struct ActionDetailInlineRow: View {
    let action: Action
    @State private var showDetail = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.warm.opacity(0.15)).frame(width: 28, height: 28)
                Circle().fill(Color.warm).frame(width: 8, height: 8)
                    .shadow(color: Color.warm.opacity(0.5), radius: 4)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(action.title)
                    .font(.sora(15, weight: .medium)).foregroundColor(.textPrimary)
                if let cue = action.cue, !cue.isEmpty {
                    Text("When: \(cue)")
                        .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                } else if let note = action.note, !note.isEmpty {
                    Text(note.count > 55 ? String(note.prefix(55)) + "…" : note)
                        .font(.sora(12, weight: .light)).foregroundColor(.textSecond).lineLimit(1)
                }
            }
            Spacer()
            Text("View").font(.sora(11, weight: .light)).foregroundColor(.textMuted)
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.textMuted)
        }
        .contentShape(Rectangle())
        .onTapGesture { showDetail = true }
        .sheet(isPresented: $showDetail) {
            ActionDetailSheet(action: action, isPresented: $showDetail, onComplete: {})
        }
    }
}



struct SessionCard: View {
    let session: Session
    var onTap: () -> Void                      // opens execution view
    var onQuickDone: () -> Void                // marks done without opening steps
    var onSkip: (SessionSkipReason) -> Void    // records intentional skip

    @State private var showSkipOptions = false

    var body: some View {
        HStack(spacing: 0) {
            // Domain accent strip
            RoundedRectangle(cornerRadius: 2)
                .fill(session.system.color.opacity(0.7))
                .frame(width: 2)
                .padding(.trailing, 14)

            // Main content — tappable to open execution view
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        MonoLabel(text: "PROTOCOL", color: session.system.color, size: 11)
                        MonoLabel(text: "· \(session.steps.count) STEPS", color: .textMuted, size: 11)
                        Spacer()
                    }
                    Text(session.title)
                        .font(.sora(16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    if !session.cue.isEmpty {
                        Text("When: \(session.cue)")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 12)

            // Right side — quick-mark done + skip
            VStack(spacing: 10) {
                // Quick-mark done — single tap, no steps needed
                Button(action: {
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    #endif
                    onQuickDone()
                }) {
                    ZStack {
                        Circle()
                            .fill(session.system.color.opacity(0.08))
                            .frame(width: 36, height: 36)
                        Circle()
                            .stroke(session.system.color.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(session.system.color)
                    }
                }

                // Skip — clear affordance, not tiny
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) { showSkipOptions.toggle() }
                }) {
                    Text("skip")
                        .font(.sora(11, weight: .light))
                        .foregroundColor(.textMuted)
                        .frame(width: 36, height: 20)
                        .contentShape(Rectangle())
                }
            }
        }
        // Skip options — appear inline below card on tap
        if showSkipOptions {
            VStack(alignment: .leading, spacing: 0) {
                Rectangle().fill(Color.muted.opacity(0.15)).frame(height: 0.5).padding(.horizontal, 16)
                HStack(spacing: 8) {
                    skipOption("Rest day", reason: .rest)
                    skipOption("Something came up", reason: .disruption)
                    Button(action: { withAnimation { showSkipOptions = false } }) {
                        Text("cancel").font(.sora(11, weight: .light)).foregroundColor(.textMuted.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    func skipOption(_ label: String, reason: SessionSkipReason) -> some View {
        Button(action: {
            withAnimation { showSkipOptions = false }
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            onSkip(reason)
        }) {
            Text(label)
                .font(.sora(11, weight: .light))
                .foregroundColor(.textSecond)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.muted.opacity(0.3), lineWidth: 0.5))
        }
    }
}

struct SessionExecutionView: View {
    @Environment(\.appMetrics) private var metrics
    @Environment(\.modelContext) private var context
    @Bindable var session: Session
    @Query private var profiles: [OperatorProfile]
    var onClose: () -> Void

    @State private var currentStep: Int = 0
    @State private var closing = false
    @State private var glowComplete = false

    var profile: OperatorProfile { profiles.first ?? OperatorProfile() }

    var body: some View {
        ZStack {
            AtmosphericBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.textMuted)
                            .frame(width: 36, height: 36)
                            .background(Color.surface)
                            .clipShape(Circle())
                    }
                    Spacer()
                    SystemBadge(system: session.system)
                }
                .padding(.horizontal, metrics.hPad).padding(.top, 20).padding(.bottom, 32)

                // Session title
                VStack(alignment: .leading, spacing: 8) {
                    MonoLabel(text: "PROTOCOL · \(session.steps.count) STEPS", color: session.system.color)
                    Text(session.title)
                        .font(.sora(26, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    if !session.cue.isEmpty {
                        Text("When: \(session.cue)")
                            .font(.mono(11)).foregroundColor(.textMuted).tracking(0.3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, metrics.hPad)
                .padding(.bottom, 40)

                // Step list — read-along, not independently checkable
                VStack(spacing: 0) {
                    ForEach(Array(session.steps.enumerated()), id: \.offset) { i, step in
                        HStack(spacing: 16) {
                            // Step index — mono, right-aligned in fixed column
                            Text("\(i + 1)")
                                .font(.mono(13))
                                .foregroundColor(i == currentStep ? session.system.color : .textMuted)
                                .frame(width: 20, alignment: .trailing)

                            // Connector line
                            VStack(spacing: 0) {
                                if i > 0 {
                                    Rectangle()
                                        .fill(i <= currentStep ? session.system.color.opacity(0.3) : Color.muted.opacity(0.2))
                                        .frame(width: 1, height: 12)
                                }
                                Circle()
                                    .fill(i < currentStep ? session.system.color : (i == currentStep ? session.system.color.opacity(0.8) : Color.surface2))
                                    .frame(width: 8, height: 8)
                                    .overlay(Circle().strokeBorder(i == currentStep ? session.system.color : Color.muted.opacity(0.4), lineWidth: 1))
                                if i < session.steps.count - 1 {
                                    Rectangle()
                                        .fill(i < currentStep ? session.system.color.opacity(0.3) : Color.muted.opacity(0.2))
                                        .frame(width: 1, height: 12)
                                }
                            }
                            .frame(width: 8)

                            // Step text
                            Text(step)
                                .font(.sora(i == currentStep ? 16 : 14,
                                            weight: i == currentStep ? .medium : .light))
                                .foregroundColor(i == currentStep ? .textPrimary :
                                                 (i < currentStep ? .textMuted : .textSecond))
                                .strikethrough(i < currentStep, color: .textMuted)
                            Spacer()
                        }
                        .padding(.horizontal, metrics.hPad)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        // Tapping a step advances to it (allows jumping forward, not back)
                        .onTapGesture {
                            if i >= currentStep {
                                withAnimation(.easeOut(duration: 0.2)) { currentStep = i }
                            }
                        }
                    }
                }

                Spacer()

                // CTA — changes based on position in protocol
                VStack(spacing: 12) {
                    if currentStep < session.steps.count - 1 {
                        // Advance step
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) { currentStep += 1 }
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                        }) {
                            Text("Next step")
                                .font(.sora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                                .frame(maxWidth: .infinity).frame(height: 50)
                                .background(session.system.color)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: session.system.color.opacity(0.3), radius: 12, x: 0, y: 6)
                        }

                        // Skip to close — understated, always available
                        Button(action: { closeSession() }) {
                            Text("Protocol closed.")
                                .font(.mono(11)).foregroundColor(.textMuted).tracking(1)
                        }
                    } else {
                        // Final step — primary CTA
                        Button(action: { closeSession() }) {
                            Text("Protocol closed.")
                                .font(.sora(14, weight: .semibold)).tracking(1.8)
                                .foregroundColor(.bgBase)
                                .frame(maxWidth: .infinity).frame(height: 50)
                                .background(
                                    Group {
                                        LinearGradient(
                                            colors: [session.system.color, session.system.color.opacity(0.7)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: session.system.color.opacity(0.35), radius: 14, x: 0, y: 7)
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
                .padding(.bottom, 48)
            }
        }
        .presentationBackground(Color.bgBase)
        .onAppear { VoicePresence.shared.isInSession = true }
        .onDisappear { VoicePresence.shared.isInSession = false }
    }

    private func closeSession() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        session.lastCompleted = Date()
        session.completedAt = Date()
        session.completionDates.append(Date())   // persist to history — survives daily reset
        if session.recurrence == .none { session.isCompleted = true }
        if let p = profiles.first {
            p.addXP(session.points)
            p.markSystemActive(session.system)
        }
        onClose()
    }
}

// MARK: - ADD SESSION SHEET

struct AddSessionSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.appMetrics) private var metrics
    @Environment(\.modelContext) private var context
    @State private var title = ""
    @State private var system: SystemTag = .health
    @State private var cue = ""
    @State private var recurrence: RecurrenceType = .daily
    @State private var steps: [String] = ["", ""]   // start with 2 empty fields

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        steps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count >= 2
    }

    var filledSteps: [String] {
        steps.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Text("New Protocol").font(.sora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        Spacer()
                        Button("Cancel") { isPresented = false }.font(.sora(14)).foregroundColor(.textMuted)
                    }

                    inputField("PROTOCOL NAME", placeholder: "Evening Shutdown", text: $title)

                    // System picker
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "SYSTEM")
                        HStack(spacing: 8) {
                            ForEach(SystemTag.allCases, id: \.self) { tag in
                                Button(action: { system = tag }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: tag.icon).font(.system(size: 14))
                                        Text(tag.rawValue.prefix(3).uppercased()).font(.mono(9)).tracking(1)
                                    }
                                    .foregroundColor(system == tag ? tag.color : .textMuted)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(system == tag ? tag.color.opacity(0.12) : Color.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(system == tag ? tag.color.opacity(0.4) : Color.clear, lineWidth: 1))
                                }
                            }
                        }
                    }

                    inputField("CUE", placeholder: "After shower / Before bed", text: $cue)

                    // Steps — max 6
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            MonoLabel(text: "STEPS")
                            Spacer()
                            MonoLabel(text: "\(filledSteps.count)/6", color: filledSteps.count >= 6 ? .inkAmber : .textMuted, size: 11)
                        }
                        MonoLabel(text: "Steps are navigation — they guide, not score", color: .muted, size: 10)

                        ForEach(steps.indices, id: \.self) { i in
                            HStack(spacing: 10) {
                                Text("\(i + 1)").font(.mono(11)).foregroundColor(.textMuted).frame(width: 16)
                                TextField("", text: $steps[i],
                                          prompt: Text("Step \(i + 1)").foregroundColor(.textMuted))
                                    .font(.sora(14)).foregroundColor(.textPrimary)
                                    .padding(12).background(Color.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .tint(.warm)
                                if steps.count > 2 {
                                    Button(action: { steps.remove(at: i) }) {
                                        Image(systemName: "minus.circle").foregroundColor(.textMuted)
                                    }
                                }
                            }
                        }

                        if steps.count < 6 {
                            Button(action: { steps.append("") }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus").font(.system(size: 12))
                                    Text("Add step").font(.sora(13))
                                }
                                .foregroundColor(.violet)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Color.violetDim.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        } else {
                            // Cap indicator
                            HStack(spacing: 6) {
                                Image(systemName: "equal").font(.system(size: 11)).foregroundColor(.inkAmber)
                                Text("Protocols cap at 6 steps.")
                                    .font(.mono(11)).foregroundColor(.inkAmber).tracking(0.5)
                            }
                            .padding(.top, 4)
                        }
                    }

                    // Recurrence
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(text: "FREQUENCY")
                        HStack(spacing: 6) {
                            ForEach([RecurrenceType.daily, .weekdays, .weekly, .none], id: \.self) { r in
                                Button(action: { recurrence = r }) {
                                    Text(r == .none ? "Once" : r.rawValue.capitalized)
                                        .font(.sora(12)).foregroundColor(recurrence == r ? .violet : .textMuted)
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(recurrence == r ? Color.violetDim.opacity(0.3) : Color.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }

                    primaryButton("Save Protocol", disabled: !canSave) {
                        let session = Session(
                            title: title.trimmingCharacters(in: .whitespaces),
                            system: system,
                            steps: filledSteps,
                            cue: cue.trimmingCharacters(in: .whitespaces),
                            recurrence: recurrence
                        )
                        context.insert(session)
                        isPresented = false
                    }
                    .padding(.bottom, 40)
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgBase)
    }
}

// MARK: - SYSTEM STATUS ROW (expandable — science context + pending actions)

struct SystemStatusRow: View {
    @Environment(\.appMetrics) private var metrics
    let sys: SystemTag
    let score: Int
    let state: AppState
    let pendingActions: [Action]
    @Query private var allActions: [Action]
    @State private var expanded = false

    var systemPending: [Action] {
        pendingActions.filter { $0.system == sys }.prefix(3).map { $0 }
    }

    // Training-log trajectory — reads direction not score. Uses completionDates (persistent).
    var trajectorySignal: String? {
        let cal = Calendar.current
        let sysActions = allActions.filter { $0.system == sys }

        // Build set of days with at least one completion in this system (from persistent history)
        let last14dates = (0..<14).compactMap { cal.date(byAdding: .day, value: -$0, to: Date()) }
        let activeDays = last14dates.filter { day in
            sysActions.contains { a in
                a.completionDates.contains { cal.isDate($0, inSameDayAs: day) }
            }
        }.count

        let last7 = last14dates.prefix(7)
        let prior7 = last14dates.dropFirst(7)
        let last7Count = last7.filter { day in
            sysActions.contains { a in a.completionDates.contains { cal.isDate($0, inSameDayAs: day) } }
        }.count
        let prior7Count = prior7.filter { day in
            sysActions.contains { a in a.completionDates.contains { cal.isDate($0, inSameDayAs: day) } }
        }.count

        // No data at all
        if activeDays == 0 { return nil }

        // Building — last 7 days better than prior 7
        if last7Count > prior7Count && last7Count >= 3 {
            return "Pattern building — \(last7Count) of 7 days active. The system is adapting."
        }
        // Fading — last 7 worse than prior 7 with a real gap
        if last7Count < prior7Count && prior7Count >= 3 && last7Count <= 2 {
            return "Less contact than last week. Might be too much friction."
        }
        // Stable and consistent
        if last7Count >= 5 {
            return "Consistent. \(last7Count) of 7 days. Change what you're doing, not how often."
        }
        // Stable at low frequency
        if last7Count >= 3 {
            return "\(last7Count) of 7 days. Something's forming."
        }
        // Very low
        if last7Count >= 1 {
            return "\(last7Count) day\(last7Count == 1 ? "" : "s") this week. One more would anchor it."
        }
        return nil
    }

    var body: some View {
        CardView {
            VStack(spacing: 0) {
                // Collapsed row — always visible
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.28)) { expanded.toggle() }
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    #endif
                }) {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(sys.color.opacity(0.7))
                            .frame(width: 2)
                            .padding(.trailing, 14)
                        HStack(spacing: 10) {
                            Image(systemName: sys.icon).font(.system(size: 14))
                                .foregroundColor(sys.color).frame(width: 20)
                            Text(sys.rawValue.capitalized)
                                .font(.sora(13, weight: .medium)).foregroundColor(.textPrimary)
                                .lineLimit(1)
                            Spacer()
                            Text(state.scoreLabel(score))
                                .font(.mono(10)).foregroundColor(state.scoreColor(score)).tracking(0.5)
                                .lineLimit(1).fixedSize()
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2).fill(Color.surface2).frame(width: 44, height: 3)
                                RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.8))
                                    .frame(width: 44 * CGFloat(score) / 100, height: 3)
                            }
                            // Score number removed — bar + label is sufficient.
                            // Raw integer becomes a Competition-strength tracking target.
                            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .light))
                                .foregroundColor(.textMuted)
                                .padding(.leading, 2)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Expanded content — science note + pending actions
                if expanded {
                    VStack(alignment: .leading, spacing: 14) {
                        Rectangle()
                            .fill(Color.muted.opacity(0.2))
                            .frame(height: 0.5)
                            .padding(.top, 14)

                        // Science context
                        Text(sys.scienceNote)
                            .font(.sora(13, weight: .light))
                            .foregroundColor(.textSecond)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        // What moves it
                        VStack(alignment: .leading, spacing: 6) {
                            MonoLabel(text: "WHAT MOVES IT", color: sys.color, size: 10)
                            Text(sys.whatMovesIt)
                                .font(.sora(12, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(3)
                        }

                        // Trajectory signal — training-log style direction reading
                        // Not a score. Not praise. A pattern observation.
                        if let trajectory = trajectorySignal {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "PATTERN", color: .textMuted, size: 10)
                                Text(trajectory)
                                    .font(.sora(12, weight: .light))
                                    .foregroundColor(.textSecond)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // Friction diagnosis — surfaces high-skip actions for review
                        // Only shows after 14 days of data. Not a grade — a diagnostic.
                        let highFrictionActions = systemPending.filter { $0.isHighFriction }
                        if !highFrictionActions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                MonoLabel(text: "FRICTION DETECTED", color: .inkAmber, size: 10)
                                ForEach(highFrictionActions.prefix(2), id: \.id) { action in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle().fill(Color.inkAmber.opacity(0.5)).frame(width: 5, height: 5).padding(.top, 5)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(action.title)
                                                .font(.sora(12, weight: .medium)).foregroundColor(.textPrimary)
                                            Text("Skipped \(action.skipCount)×.")
                                                .font(.sora(11, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                                        }
                                    }
                                }
                            }
                        }

                        // Pending in this system — single next action, not a list
                        let nextAction = systemPending.first
                        if let action = nextAction {
                            VStack(alignment: .leading, spacing: 6) {
                                MonoLabel(text: "NEXT IN THIS SYSTEM", color: .textMuted, size: 10)
                                HStack(spacing: 10) {
                                    Circle()
                                        .stroke(sys.color.opacity(0.5), lineWidth: 1.5)
                                        .frame(width: 8, height: 8)
                                    Text(action.title)
                                        .font(.sora(13, weight: .medium))
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    if systemPending.count > 1 {
                                        Text("+\(systemPending.count - 1) more")
                                            .font(.mono(10)).foregroundColor(.textMuted)
                                    }
                                }
                            }
                        } else {
                            HStack(spacing: 8) {
                                Circle().fill(sys.color.opacity(0.4)).frame(width: 7, height: 7)
                                Text("No pending actions in this system.")
                                    .font(.sora(12, weight: .light)).foregroundColor(.textMuted)
                            }
                        }
                    }
                    .padding(.top, 2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

