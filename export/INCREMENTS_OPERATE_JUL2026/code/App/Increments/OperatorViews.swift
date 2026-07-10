import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications
import Foundation
import Combine

// Brief, Consult, Focus, Settings, Today embed wrappers.
// Removed May 2026 (unreachable): OperatorView, DossierTabView, InsightsView, Cognition Lab.
// Brief + Intel + Manual → You tab only. See INCREMENTS_Master.md § Navigation.

// The intelligence readiness card — tells the app what it's learning to see.
// Honest about thresholds. Not hollow. Not premature.
struct IntelligenceReadinessCard: View {
    @Environment(\.appMetrics) private var metrics
    let patternReadiness: IntelligenceReadiness
    let frictionReadiness: IntelligenceReadiness
    let energyCalibrationReadiness: IntelligenceReadiness
    let cognitionTaggingStatus: String

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.blockSpacing) {
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
                HStack(alignment: .top, spacing: metrics.cardSpacing) {
                    Circle()
                        .fill(cognitionTaggingStatus.contains("All") ? Color.inkGreen : Color.violetLight.opacity(0.5))
                        .frame(width: 6, height: 6)
                        .padding(.top, 4)
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "COGNITION TYPE", size: 11)
                        Text("Creative vs analytical vs administrative — \(cognitionTaggingStatus)")
                            .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                    }
                }
            }
        }
    }

    func readinessRow(label: String, readiness: IntelligenceReadiness, description: String) -> some View {
        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            Circle()
                .fill(readiness.isReady ? Color.inkGreen : Color.muted.opacity(0.4))
                .frame(width: 6, height: 6)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                MonoLabel(text: label, size: 11)
                Text(description)
                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                if !readiness.isReady {
                    Text(readiness.displayText)
                        .font(metrics.fontMono(11)).foregroundColor(.violetLight.opacity(0.7)).tracking(0.3)
                } else {
                    Text(readiness.displayText)
                        .font(metrics.fontMono(11)).foregroundColor(.inkGreen).tracking(0.3)
                }
            }
            Spacer()
        }
    }
}


struct SettingsTabView: View {
    @Environment(\.appMetrics) private var metrics
    @Environment(\.dismiss) private var dismiss
    @Bindable var profile: OperatorProfile
    @Bindable var state: AppState
    // BUG FIX: was @State (resets to false on every tab switch/view re-init).
    // @AppStorage persists the toggle state across app sessions and tab navigation.
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: metrics.blockSpacing) {

            // OPERATOR — name and voice
            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "OPERATOR", color: .textMuted)
                    HStack(spacing: metrics.cardSpacing) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            Text("Name").font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                            Text("Used for direct address. Leave blank to disable.")
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                        }
                        Spacer()
                        TextField("Brice", text: $profile.operatorName)
                            .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .tint(.violet)
                    }

                    Divider().background(Color.muted.opacity(0.3))

                    // Intelligence layer — pattern reading, observations, divergence detection
                    // Runs silently. Does not require voice.
                    Toggle(isOn: $profile.wendyEnabled) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            Text("Intelligence layer").font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                            Text("Pattern reading, observations, divergence detection. Runs silently — no voice required.")
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                        }
                    }
                    .tint(Color.inkGreen)

                    if profile.wendyEnabled {
                        Divider().background(Color.muted.opacity(0.3))

                        VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                            MonoLabel(text: "ANTHROPIC · CLAUDE", color: .inkGreen, size: 11)
                            Text("Powers weekly pattern reads and Operator Consult. Key stays on this device only.")
                                .font(metrics.fontSora(13, weight: .light))
                                .foregroundColor(.textMuted)
                                .lineSpacing(2)
                            apiKeyField("API KEY", placeholder: "sk-ant-...", text: $profile.claudeApiKey)
                            if profile.claudeApiKey.isEmpty {
                                Text("Required for Consult and deeper observations after day 7 in system.")
                                    .font(metrics.fontMono(11))
                                    .foregroundColor(.muted)
                                    .tracking(0.3)
                                    .lineSpacing(2)
                            } else {
                                MonoLabel(text: "KEY SET", color: .inkGreen, size: 9)
                            }
                        }
                    }

                    Divider().background(Color.muted.opacity(0.3))

                    // Voice — spoken output only. Intelligence layer runs regardless.
                    Toggle(isOn: $profile.voicePresenceEnabled) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            Text("Voice").font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                            Text("Speaks observations aloud. Requires intelligence layer. Pause this until voice quality improves.")
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                        }
                    }
                    .tint(Color.violet)
                    .disabled(!profile.wendyEnabled)
                    .onChange(of: profile.voicePresenceEnabled) { _, enabled in
                        VoicePresence.shared.voiceEnabled = enabled
                        if !enabled { VoicePresence.shared.stop() }
                    }

                    // Test button — only relevant when voice is on
                    if profile.voicePresenceEnabled {
                        Divider().background(Color.muted.opacity(0.3))

                        // Voice provider
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "VOICE SOURCE", color: .textMuted)
                            Group {
                                if metrics.isIPad {
                                    HStack(spacing: metrics.rowSpacing) {
                                        voiceProviderChoices
                                    }
                                } else {
                                    VStack(spacing: metrics.rowSpacing) {
                                        voiceProviderChoices
                                    }
                                }
                            }
                        }

                        // Character note — what voice this is reaching for
                        CardView(style: .ambient) {
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                MonoLabel(text: "CHARACTER", color: .textMuted, size: 11)
                                Text("Calm male operator. Grounded. Intelligent. Composed.")
                                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond).lineSpacing(2)
                                Text("Not assistant. Not coach. Not theatrical. A presence that notices.")
                                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                                Text("For ElevenLabs: search calm male, neutral American, grounded, composed.")
                                    .font(metrics.fontMono(11)).foregroundColor(.muted).tracking(0.3).lineSpacing(2)
                            }
                        }

                        // OpenAI TTS — only shows when OpenAI is selected
                        if profile.voiceProvider == .openAI {
                            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                                MonoLabel(text: "OPENAI TTS", color: .inkGreen, size: 11)
                                MonoLabel(text: "Voice: onyx. Get your key at platform.openai.com", color: .muted, size: 10)
                                inputField("API KEY", placeholder: "sk-...", text: $profile.openAIApiKey)
                                    .onChange(of: profile.openAIApiKey) { _, v in
                                        VoicePresence.shared.openAIApiKey = v
                                    }
                                Text("Key stored locally only. ~$0.002/day at normal use.")
                                    .font(metrics.fontMono(11)).foregroundColor(.muted).tracking(0.3)
                            }
                        }

                        // ElevenLabs Phase B — only shows when ElevenLabs is selected
                        if profile.voiceProvider == .elevenLabs {
                            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
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
                                    .font(metrics.fontMono(11)).foregroundColor(.muted).tracking(0.3)
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
                            HStack(spacing: metrics.rowSpacing) {
                                Image(systemName: "waveform")
                                    .font(.system(size: metrics.scaledSize(13), weight: .light))
                                Text("Test voice")
                                    .font(metrics.fontSora(14))
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
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // TRAINING — program start date for dynamic week tracking
            CardView {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "TRAINING", color: .textMuted)
                    HStack {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            Text("Forge Breechay started")
                                .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                            Text("Sets the week counter on Now and Today.")
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                        }
                        Spacer()
                        DatePicker("", selection: $profile.trainingProgramStartDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .tint(.warm)
                            #if os(iOS)
                            .datePickerStyle(.compact)
                            #endif
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // NOTIFICATIONS — master toggle
            CardView {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    MonoLabel(text: "NOTIFICATIONS", color: .textMuted)
                    Toggle(isOn: $notificationsEnabled) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            Text("Daily nudges").font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                            Text("Max 4/day · respects quiet window")
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond)
                        }
                    }
                    .tint(Color.violet)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        #if canImport(UserNotifications)
                        if enabled {
                            #if canImport(UserNotifications)
                            NotificationService.shared.requestPermission()
                            #endif
                            #if canImport(UserNotifications)
                            NotificationService.shared.scheduleAll(profile: profile)
                            #endif
                        } else {
                            #if canImport(UserNotifications)
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            #endif
                        }
                        #endif
                    }

                    Divider().background(Color.muted.opacity(0.3))
                    Toggle(isOn: $profile.quietMode) {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            Text("Quiet Mode").font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                            Text("Suppress all non-critical notifications")
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond)
                        }
                    }
                    .tint(Color.violetDim)
                    .onChange(of: profile.quietMode) { _, _ in
                        #if canImport(UserNotifications)
                        NotificationService.shared.scheduleAll(profile: profile)
                        #endif
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // QUIET WINDOW — Phase 2
            if notificationsEnabled && !profile.quietMode {
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                        MonoLabel(text: "QUIET WINDOW", color: .textMuted)
                        Text("No notifications sent during this window.")
                            .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)

                        HStack(spacing: metrics.blockSpacing) {
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                MonoLabel(text: "FROM", color: .textMuted, size: 11)
                                Picker("", selection: $profile.notifQuietStart) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(hourLabel(h)).tag(h)
                                            .font(metrics.fontSora(14)).foregroundColor(.textPrimary)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 80)
                                .clipped()
                                .colorScheme(.dark)
                            }
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                MonoLabel(text: "UNTIL", color: .textMuted, size: 11)
                                Picker("", selection: $profile.notifQuietEnd) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(hourLabel(h)).tag(h)
                                            .font(metrics.fontSora(14)).foregroundColor(.textPrimary)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 80)
                                .clipped()
                                .colorScheme(.dark)
                            }
                            Spacer()
                            // Preview
                            VStack(alignment: .trailing, spacing: metrics.rowSpacing) {
                                MonoLabel(text: "WINDOW", color: .textMuted, size: 11)
                                Text("\(hourLabel(profile.notifQuietStart)) –")
                                    .font(metrics.fontSora(13)).foregroundColor(.textSecond)
                                Text(hourLabel(profile.notifQuietEnd))
                                    .font(metrics.fontSora(13)).foregroundColor(.textSecond)
                            }
                        }
                        .onChange(of: profile.notifQuietStart) { _, _ in
                            #if canImport(UserNotifications)
                            NotificationService.shared.scheduleAll(profile: profile)
                            #endif
                        }
                        .onChange(of: profile.notifQuietEnd) { _, _ in
                            #if canImport(UserNotifications)
                            NotificationService.shared.scheduleAll(profile: profile)
                            #endif
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)

                // CATEGORY TOGGLES — Phase 2
                CardView(style: .secondary) {
                    VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                        MonoLabel(text: "NOTIFY FOR SYSTEMS", color: .textMuted)

                        categoryToggle("Environment",  isOn: $profile.notifCategoryEnvironment,  color: .inkGreen)
                        categoryToggle("Cognition",    isOn: $profile.notifCategoryCognition,    color: .violetLight)
                        categoryToggle("Health",       isOn: $profile.notifCategoryHealth,       color: .inkTeal)
                        categoryToggle("Operations",   isOn: $profile.notifCategoryOperations,   color: .warm)
                        categoryToggle("Participation",isOn: $profile.notifCategoryParticipation,color: .inkAmber)

                        Divider().background(Color.muted.opacity(0.3))

                        // Hydration — Phase 3 P3
                        HStack(spacing: metrics.cardSpacing) {
                            Circle().fill(Color.inkTeal.opacity(0.6)).frame(width: 7, height: 7)
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                Text("Hydration prompts").font(metrics.fontSora(14)).foregroundColor(.textPrimary)
                                Text("3/day · 10am, 1pm, 4pm · copy: \"Water.\"")
                                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                            }
                            Spacer()
                            Toggle("", isOn: $profile.notifHydrationEnabled).tint(Color.inkTeal).labelsHidden()
                                .onChange(of: profile.notifHydrationEnabled) { _, _ in
                                    #if canImport(UserNotifications)
                                    NotificationService.shared.scheduleAll(profile: profile)
                                    #endif
                                }
                        }

                        // Protein — 2/day
                        HStack(spacing: metrics.cardSpacing) {
                            Circle().fill(Color.inkTeal.opacity(0.6)).frame(width: 7, height: 7)
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                Text("Protein reminders").font(metrics.fontSora(14)).foregroundColor(.textPrimary)
                                Text("2/day · 10am, 3:30pm · copy: \"Protein.\"")
                                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                            }
                            Spacer()
                            Toggle("", isOn: $profile.notifProteinEnabled).tint(Color.inkTeal).labelsHidden()
                                .onChange(of: profile.notifProteinEnabled) { _, _ in
                                    #if canImport(UserNotifications)
                                    NotificationService.shared.scheduleAll(profile: profile)
                                    #endif
                                }
                        }
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }

            // GUARDRAILS
            CardView(style: .ambient) {
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "GUARDRAILS", color: .textMuted)
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        guardrailLine("No streak shaming. No failure language.")
                        guardrailLine("If the app creates pressure, remove items.")
                        guardrailLine("No notifications that generate guilt.")
                        guardrailLine("Gentle decay only — never harsh penalties.")
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            CardView(style: .secondary) {
                VStack(spacing: metrics.rowSpacing) {
                    MonoLabel(text: "INCREMENTS · v\(profile.version)", color: .violet, size: 11)
                    Text("environmental cognition support system")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                    Text("Private build. Your data stays yours.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted.opacity(0.7))
                        .tracking(0.2)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, metrics.hPad)
                }
                .padding(.top, metrics.scaledSize(8))
                .padding(.bottom, 80)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.bgBase)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.violetLight)
                }
            }
        }
        .onAppear { syncNotificationStatus() }
    }

    @ViewBuilder
    private var voiceProviderChoices: some View {
        ForEach(VoiceProvider.allCases, id: \.self) { p in
            Button(action: {
                profile.voiceProvider = p
                VoicePresence.shared.provider = p
            }) {
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    Text(p.label)
                        .font(metrics.fontSora(14))
                        .foregroundColor(profile.voiceProvider == p ? .textPrimary : .textMuted)
                    Text(p.sublabel)
                        .font(metrics.fontSora(12, weight: .light))
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
            .buttonStyle(.plain)
        }
    }

    private func apiKeyField(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            MonoLabel(text: label)
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
                .font(.sora(15))
                .foregroundColor(.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                #if os(iOS)
                .textContentType(.password)
                #endif
                .padding(14)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(.warm)
        }
    }

    func hourLabel(_ h: Int) -> String {
        let suffix = h >= 12 ? "PM" : "AM"
        let h12 = h == 0 ? 12 : h > 12 ? h - 12 : h
        return "\(h12) \(suffix)"
    }

    func categoryToggle(_ label: String, isOn: Binding<Bool>, color: Color) -> some View {
        HStack(spacing: metrics.cardSpacing) {
            Circle().fill(color.opacity(0.6)).frame(width: 7, height: 7)
            Text(label).font(metrics.fontSora(14)).foregroundColor(.textPrimary)
            Spacer()
            Toggle("", isOn: isOn).tint(color).labelsHidden()
                .onChange(of: isOn.wrappedValue) { _, _ in
                    #if canImport(UserNotifications)
                    NotificationService.shared.scheduleAll(profile: profile)
                    #endif
                }
        }
    }

    func guardrailLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: metrics.rowSpacing) {
            Circle().fill(Color.warm.opacity(0.4)).frame(width: 4, height: 4).padding(.top, 5)
            Text(text).font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
        }
    }

    // BUG FIX: syncs notificationsEnabled toggle with real system permission on every appear
    func syncNotificationStatus() {
        #if canImport(UserNotifications)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
        #endif
    }
}

// MARK: - WEEKLY REVIEW EXPORT

struct WeeklyExportCard: View {
    @Environment(\.appMetrics) private var metrics
    let actions: [Action]
    let logs: [DailyLog]
    @Query(sort: \HideoutShiftLog.date, order: .reverse) private var shifts: [HideoutShiftLog]
    @State private var showShareSheet = false
    @State private var exportText = ""

    var body: some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: "WEEKLY REVIEW", color: .violetLight, size: 10)
                        Text("Export & share your data.")
                            .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
                    }
                    Spacer()
                    Button(action: {
                        exportText = ExportGenerator.weeklyMarkdown(actions: actions, logs: logs, shifts: Array(shifts.prefix(14)))
                        showShareSheet = true
                    }) {
                        HStack(spacing: metrics.rowSpacing) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: metrics.scaledSize(12)))
                            Text("Export").font(metrics.fontSora(13, weight: .medium))
                        }
                        .foregroundColor(.bgBase)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.violetLight)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                Text("Last 7 days · action rates · Hideout revenue + behavioral techniques · daily notes.\nShare with partner, advisor, or save as weekly record.")
                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            #if canImport(UIKit)
            ShareSheetView(text: exportText)
            #else
            Text("Export not available on this platform")
            #endif
        }
    }
}

#if canImport(UIKit)
import UIKit
struct ShareSheetView: UIViewControllerRepresentable {
    let text: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

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
    @Environment(\.appMetrics) private var metrics
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
                VStack(alignment: .leading, spacing: metrics.sectionGap) {
                    SheetHandle().frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "PATTERN BRIEF", color: .violetLight, size: 11)
                            Text("30-day system read.")
                                .font(metrics.fontSora(20, weight: .semibold)).foregroundColor(.textPrimary)
                        }
                        Spacer()
                    }

                    switch consultState {
                    case .ready:
                        consultReady()
                    case .loading:
                        VStack(spacing: metrics.cardSpacing) {
                            ProgressView().tint(.violet)
                            Text("Reading the pattern...").font(metrics.fontSora(14, weight: .light)).foregroundColor(.textMuted)
                        }.frame(maxWidth: .infinity).padding(.vertical, 40)
                    case .response(let text):
                        consultResponseView(text: text)
                    case .insufficientData(let remaining):
                        consultInsufficientData(remaining: remaining)
                    case .cooldownActive(let available):
                        consultCooldownActive(available: available)
                    case .noSignal:
                        CardView(style: .secondary) {
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                MonoLabel(text: "NO SIGNAL", color: .textMuted, size: 11)
                                Text("The data didn't produce a clear pattern. Try again in a week.")
                                    .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
                            }
                        }
                    case .error:
                        CardView(style: .secondary) {
                            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                                MonoLabel(text: "ERROR", color: .inkRed, size: 11)
                                Text("Something went wrong. Check your API key in Settings.")
                                    .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
                            }
                        }
                    }

                    if let receipt = savedReceipt {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "LAST SAVED READ", color: .textMuted, size: 10)
                            Text(receipt.observationText)
                                .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)
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
        VStack(alignment: .leading, spacing: metrics.blockSpacing) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "BRIEF", color: .violetLight, size: 11)
                    Text(text)
                        .font(metrics.fontSora(15, weight: .light))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Button(action: { saveReceipt(text: text) }) {
                HStack(spacing: metrics.rowSpacing) {
                    Image(systemName: "square.and.arrow.down").font(.system(size: metrics.scaledSize(13)))
                    Text("Save this read").font(metrics.fontSora(14, weight: .medium))
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
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                MonoLabel(text: "NOT YET", color: .textMuted, size: 11)
                Text("Not enough signal yet.")
                    .font(metrics.fontSora(16, weight: .light)).foregroundColor(.textPrimary)
                Text("30 days of data required. Currently day \(profile.daysInSystem).")
                    .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
                HStack(spacing: metrics.rowSpacing) {
                    Circle().fill(Color.inkAmber.opacity(0.5)).frame(width: 5, height: 5)
                    Text("\(remaining) day\(remaining == 1 ? "" : "s") remaining.")
                        .font(metrics.fontMono(12)).foregroundColor(.inkAmber).tracking(0.3)
                }
            }
        }
    }

    func consultCooldownActive(available: Date) -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                MonoLabel(text: "COOLDOWN", color: .textMuted, size: 11)
                if let last = profile.lastConsultDate {
                    Text("Last read: \(last.formatted(.dateTime.month().day())).")
                        .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                }
                Text("Next read available \(available.formatted(.dateTime.month().day())).")
                    .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
                Text("14 days between reads. The data needs time to change.")
                    .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
            }
        }
    }

    func consultReady() -> some View {
        VStack(spacing: metrics.blockSpacing) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "READY", color: .inkGreen, size: 11)
                    Text("Day \(profile.daysInSystem). Enough signal to read.")
                        .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                    if let last = profile.lastConsultDate {
                        Text("Last read: \(last.formatted(.dateTime.month().day())).")
                            .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                    }
                }
            }

            Button(action: startConsult) {
                Text("RUN PATTERN BRIEF")
                    .font(metrics.fontSora(15, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text("One read every 14 days. Analyst format. Not a conversation.")
                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
    }

    func consultLoading() -> some View {
        CardView(style: .secondary) {
            HStack(spacing: metrics.blockSpacing) {
                // Quiet pulse — not theatrical
                Circle()
                    .fill(Color.violet.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .modifier(SlowPulse())
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    Text("Reading the last 30 days.")
                        .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                    Text("This may take a moment.")
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                }
                Spacer()
            }
        }
    }

    func consultResponse(text: String) -> some View {
        VStack(spacing: metrics.blockSpacing) {
            CardView {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    MonoLabel(text: "PATTERN BRIEF · DAY \(profile.daysInSystem)", color: .violetLight, size: 11)
                    Text(text)
                        .font(metrics.fontSora(15, weight: .light))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: metrics.cardSpacing) {
                // Save — explicit, user-initiated
                Button(action: { saveReceipt(text: text) }) {
                    Text("SAVE")
                        .font(metrics.fontSora(14, weight: .semibold)).foregroundColor(.violet).tracking(1.5)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color.violetDim.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.violet.opacity(0.3), lineWidth: 0.5))
                }

                // Dismiss — closes without saving
                Button(action: { dismiss() }) {
                    Text("DONE")
                        .font(metrics.fontSora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color.violet).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Text("Save preserves this read. Dismiss closes without saving.")
                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
    }

    func consultNoSignal() -> some View {
        CardView(style: .secondary) {
            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                MonoLabel(text: "NOTHING NEW", color: .textMuted, size: 11)
                Text("Nothing significant in the last 30 days.")
                    .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                Text("The patterns are holding.")
                    .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textSecond)
            }
        }
    }

    func consultError() -> some View {
        VStack(spacing: metrics.cardSpacing) {
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "UNAVAILABLE", color: .textMuted, size: 11)
                    Text("Couldn't read it. Nothing was saved.")
                        .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
                }
            }
            Button(action: { dismiss() }) {
                Text("DONE")
                    .font(metrics.fontSora(14, weight: .semibold)).foregroundColor(.bgBase).tracking(1.5)
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
    @Environment(\.appMetrics) private var metrics
    @Bindable var profile: OperatorProfile
    @State private var showConsult = false

    var gateState: ConsultState { ConsultEngine.gateState(profile: profile) }

    var body: some View {
        CardView(style: gateState == .ready ? .primary : .secondary) {
            HStack(spacing: metrics.blockSpacing) {
                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "PATTERN BRIEF", color: statusColor, size: 11)
                    Text(statusTitle)
                        .font(.sora(14, weight: gateState == .ready ? .semibold : .light))
                        .foregroundColor(gateState == .ready ? .textPrimary : .textMuted)
                    Text(statusSubtitle)
                        .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textMuted).lineSpacing(2)
                }
                Spacer()
                if gateState == .ready {
                    Image(systemName: "chevron.right")
                        .font(.system(size: metrics.scaledSize(12), weight: .medium))
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
    @Environment(\.appMetrics) private var metrics
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
            VStack(alignment: .leading, spacing: metrics.sectionGap) {
                HStack {
                    Text("FOCUS").font(metrics.fontSora(22, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark").foregroundColor(.textMuted)
                    }
                }

                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "WORK TYPE")
                    HStack(spacing: metrics.rowSpacing) {
                        ForEach(FocusWorkType.allCases, id: \.self) { type in
                            Button(action: { workType = type }) {
                                VStack(spacing: metrics.rowSpacing) {
                                    Image(systemName: type.icon).font(.system(size: metrics.scaledSize(16), weight: .light))
                                    Text(type.rawValue).font(metrics.fontSora(12)).lineLimit(1)
                                }
                                .foregroundColor(workType == type ? .bgBase : .violetLight)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(workType == type ? Color.violetLight : Color.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                    MonoLabel(text: "INTENTION (OPTIONAL)")
                    TextField("What are you doing in this session?", text: $intention)
                        .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
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
            VStack(spacing: metrics.sectionGap) {
                MonoLabel(text: workType.rawValue.uppercased(), color: .violetLight, size: 11)
                Text(elapsedFormatted)
                    .font(.system(size: 64, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                if !intention.isEmpty {
                    Text(intention)
                        .font(metrics.fontSora(15, weight: .light)).foregroundColor(.textSecond)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                }
            }
            Spacer()
            VStack(spacing: metrics.cardSpacing) {
                Button(action: { withAnimation { phase = .winding; isRunning = false } }) {
                    Text("End session")
                        .font(metrics.fontSora(15, weight: .medium)).foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 28).padding(.bottom, 48)
        }
    }

    var windingView: some View {
        VStack(alignment: .leading, spacing: metrics.sectionGap) {
            Spacer()
            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                MonoLabel(text: "SESSION CLOSED", color: .inkGreen, size: 11)
                Text("\(elapsedFormatted)")
                    .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.textPrimary).monospacedDigit()
                Text(workType.rawValue)
                    .font(metrics.fontMono(13)).foregroundColor(.textMuted).tracking(0.5)
            }
            Text("Let it settle before the next thing.")
                .font(metrics.fontSora(16, weight: .light)).foregroundColor(.textSecond).lineSpacing(3)

            VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                MonoLabel(text: "ONE LINE IF YOU WANT IT", color: .textMuted, size: 10)
                TextField("What happened?", text: $sessionNote)
                    .font(metrics.fontSora(15)).foregroundColor(.textPrimary)
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
            VStack(spacing: metrics.cardSpacing) {
                if !sessionNote.isEmpty {
                    Text(sessionNote)
                        .font(metrics.fontSora(16, weight: .light)).foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                }
                MonoLabel(text: "RECORDED.", color: .inkGreen, size: 11)
            }
            Spacer()
            Button(action: { isPresented = false }) {
                Text("Return").font(metrics.fontSora(15)).foregroundColor(.textMuted)
            }
            .padding(.bottom, 48)
        }
    }
}


// MARK: - TODAY EMBED WRAPPERS (Systems / Habits / Timeline sub-tabs)

struct IncrementsViewEmbed: View {
    @Environment(\.appMetrics) private var metrics
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
                .padding(.horizontal, metrics.hPad).padding(.bottom, 16)
            VStack(spacing: metrics.rowSpacing) {
                ForEach(SystemTag.allCases, id: \.self) { sys in
                    let score = state.systemScores[sys] ?? 0
                    let pending = filteredActions.filter { $0.system == sys && !$0.isCompleted }
                    let done = completedToday.filter { $0.system == sys }.count
                    let quiet = daysSinceActivity(sys)
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        SystemDetailRow(sys: sys, score: score, state: state,
                                        pending: pending, done: done, quiet: quiet,
                                        allActions: filteredActions)
                        if quiet >= 3 && quiet < 999 {
                            Text("\(sys.rawValue.capitalized) — nothing here in \(quiet) days.")
                                .font(metrics.fontMono(12)).foregroundColor(.textMuted).tracking(0.3)
                                .padding(.horizontal, 6).padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, metrics.hPad)
                }
            }
            .padding(.bottom, 80)
        }
    }
}

struct HabitsViewEmbed: View {
    var body: some View { EmptyView() }
}

struct TimelineViewEmbed: View {
    @Environment(\.appMetrics) private var metrics
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
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                        MonoLabel(text: dayHeader(entry.day), color: .violetLight, size: 11)
                        Text("\(entry.actions.count) action\(entry.actions.count == 1 ? "" : "s")")
                            .font(metrics.fontMono(12)).foregroundColor(.textMuted).tracking(0.3)
                    }
                    .padding(.horizontal, metrics.hPad)
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


// MARK: - OBSERVED INTELLIGENCE CARD

struct ObservedIntelligenceCard: View {
    @Environment(\.appMetrics) private var metrics
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
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
                            MonoLabel(text: "OBSERVED INTELLIGENCE", color: .inkGreen)
                            Text(intelligence.frictionSignature)
                                .font(metrics.fontSora(13, weight: .light)).foregroundColor(.textSecond)
                                .lineSpacing(2)
                        }
                        Spacer()
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: metrics.scaledSize(11), weight: .light)).foregroundColor(.textMuted)
                    }
                }

                if expanded {
                    VStack(alignment: .leading, spacing: metrics.cardSpacing) {
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
                        observedRow("GENERATIVE RATIO", value: "\(Int(intelligence.leverageRatio * 100))% of recent completions")
                        observedRow("ADMIN DISPLACEMENT", value: intelligence.operationalDisplacementFrequency == 0
                            ? "Not detected (14d)"
                            : "\(intelligence.operationalDisplacementFrequency) of last 14 days")

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
                            .font(metrics.fontMono(10)).foregroundColor(.muted).tracking(0.3)
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
                .font(metrics.fontSora(13, weight: .light))
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
    @Environment(\.appMetrics) private var metrics
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
            case .compressed:
                lines.append("Compressed day. Anchors and continuity only. Protect the thread.")
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
        VStack(spacing: metrics.blockSpacing) {

            // ── LIVE BRIEF ───────────────────────────────────────────────
            CardView {
                VStack(alignment: .leading, spacing: metrics.blockSpacing) {
                    HStack {
                        MonoLabel(text: "SITUATION · \(Date().formatted(.dateTime.weekday(.wide).day().month()))", color: .violetLight)
                        Spacer()
                        Button(action: { showFocus = true }) {
                            HStack(spacing: metrics.rowSpacing) {
                                Image(systemName: "brain").font(.system(size: metrics.scaledSize(12)))
                                Text("Focus").font(metrics.fontMono(11)).tracking(0.5)
                            }
                            .foregroundColor(.violetLight)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.violetDim.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                        ForEach(Array(liveBriefLines.enumerated()), id: \.offset) { i, line in
                            HStack(alignment: .top, spacing: metrics.cardSpacing) {
                                // Classified-doc bullet
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.violetLight.opacity(0.6))
                                    .frame(width: 2, height: 14)
                                    .padding(.top, 3)
                                Text(line)
                                    .font(metrics.fontSora(15, weight: .light))
                                    .foregroundColor(.textPrimary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // ── SYSTEM STATUS (5-dot read) ───────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
                    MonoLabel(text: "SYSTEMS", color: .textMuted)
                    HStack(spacing: 0) {
                        ForEach(SystemTag.allCases, id: \.self) { sys in
                            let active = profile.isSystemActiveThisWeek(sys)
                            let days = state.daysSinceActivity(sys)
                            let decaying = !active && days >= 3 && days < 999
                            VStack(spacing: metrics.rowSpacing) {
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
            .padding(.horizontal, metrics.hPad)

            // ── 7-DAY COMPLETION RATES ───────────────────────────────────
            CardView(style: .secondary) {
                VStack(alignment: .leading, spacing: metrics.cardSpacing) {
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
                            HStack(spacing: metrics.cardSpacing) {
                                Circle().fill(sys.color).frame(width: 6, height: 6)
                                Text(sys.rawValue.capitalized)
                                    .font(metrics.fontSora(13)).foregroundColor(.textPrimary)
                                Spacer()
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2).fill(Color.surface2)
                                        .frame(width: 72, height: 3)
                                    RoundedRectangle(cornerRadius: 2).fill(sys.color.opacity(0.8))
                                        .frame(width: 72 * CGFloat(rate), height: 3)
                                }
                                Text(String(format: "%.0f%%", rate * 100))
                                    .font(metrics.fontMono(11))
                                    .foregroundColor(rate >= 0.7 ? .inkGreen : rate >= 0.4 ? .inkAmber : .textMuted)
                                    .tracking(0.3).frame(width: 32, alignment: .trailing)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, metrics.hPad)

            // ── WENDY LAST OBSERVATION ───────────────────────────────────
            if let obs = profile.lastWendyObservation, !obs.isEmpty {
                CardView(style: .ambient) {
                    VStack(alignment: .leading, spacing: metrics.rowSpacing) {
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
                            .font(metrics.fontSora(14, weight: .light)).foregroundColor(.textPrimary)
                            .lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, metrics.hPad)
            }

            // ── WENDY OBSERVATION ────────────────────────────────────────
            // Layer B pattern interpretation surfaces here — the intelligence surface.
            // Not on Today (execution). Here, where interpretation belongs.
            WendyObservationCard()
                .padding(.horizontal, metrics.hPad)

            // ── PATTERN BRIEF ────────────────────────────────────────────
            if profile.daysInSystem >= 7 {
                ConsultCard(profile: profile).padding(.horizontal, metrics.hPad)
            }
        }
        .padding(.bottom, 80)
        .adaptiveContentWidth(metrics)
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

