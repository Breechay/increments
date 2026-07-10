import Foundation
import Combine

/// Mirrors selected `UserDefaults` / `@AppStorage` keys across iPhone and iPad via iCloud Key-Value Store.
/// Core app data syncs through SwiftData + CloudKit in `INCREMENTSApp.container`.
@MainActor
final class CloudSyncPreferences: ObservableObject {
    static let shared = CloudSyncPreferences()

    /// Bump to refresh SwiftUI surfaces that read `@AppStorage` after a remote iCloud KVS update.
    @Published private(set) var revision = UUID()

    private var isApplyingRemote = false
    private var observer: NSObjectProtocol?

    private static let exactKeys: Set<String> = [
        "hasCompletedOnboarding",
        "notificationsEnabled",
        "labReadDepths",
    ]

    private static let prefixes: [String] = [
        "growth_", "friction_", "housing_", "exp_", "wrc_", "decision_", "sprint_",
        "hasCompleted", "notifications", "increments_",
    ]

    func bootstrap() {
        let cloud = NSUbiquitousKeyValueStore.default
        cloud.synchronize()

        if cloud.dictionaryRepresentation.isEmpty {
            pushLocalDefaultsToCloud()
        } else {
            applyRemoteStore(cloud)
        }

        observer = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloud,
            queue: .main
        ) { [weak self] _ in
            self?.applyRemoteStore(cloud)
        }
    }

    func pushLocalDefaultsToCloud() {
        let cloud = NSUbiquitousKeyValueStore.default
        let defaults = UserDefaults.standard

        for key in defaults.dictionaryRepresentation().keys {
            guard shouldMirror(key: key) else { continue }
            cloud.set(defaults.object(forKey: key), forKey: key)
        }
        cloud.synchronize()
    }
}

private extension CloudSyncPreferences {
    func shouldMirror(key: String) -> Bool {
        if Self.exactKeys.contains(key) { return true }
        return Self.prefixes.contains { key.hasPrefix($0) }
    }

    func applyRemoteStore(_ cloud: NSUbiquitousKeyValueStore) {
        isApplyingRemote = true
        defer { isApplyingRemote = false }

        let defaults = UserDefaults.standard
        for key in cloud.dictionaryRepresentation.keys {
            guard shouldMirror(key: key) else { continue }
            if let value = cloud.object(forKey: key) {
                defaults.set(value, forKey: key)
            }
        }
        revision = UUID()
    }
}
