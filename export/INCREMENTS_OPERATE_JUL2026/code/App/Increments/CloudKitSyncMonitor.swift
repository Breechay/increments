import Foundation
import CoreData
import CloudKit
import Combine

/// Surfaces SwiftData + CloudKit mirroring health for the You tab (quota, container, offline).
@MainActor
final class CloudKitSyncMonitor: ObservableObject {
    static let shared = CloudKitSyncMonitor()

    enum Health: Equatable {
        case unknown
        case syncing
        case ok
        case paused(String)

        var userLine: String? {
            switch self {
            case .paused(let reason): return reason
            case .syncing: return "iCloud sync in progress."
            default: return nil
            }
        }
    }

    @Published private(set) var health: Health = .unknown
    @Published private(set) var lastUpdated = Date()

    private var observer: NSObjectProtocol?

    func startObserving() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            Task { @MainActor in
                self?.handleEventNotification(note)
            }
        }
    }

    private func handleEventNotification(_ note: Notification) {
        guard
            let event = note.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event
        else { return }

        lastUpdated = Date()

        if event.endDate == nil {
            health = .syncing
            return
        }

        if let error = event.error {
            health = .paused(message(for: error))
            return
        }

        if event.endDate != nil, event.error == nil {
            health = .ok
        }
    }

    private func message(for error: Error) -> String {
        let ck = error as? CKError
        switch ck?.code {
        case .quotaExceeded:
            return "iCloud storage full — sync paused. Free space in Settings → Apple ID → iCloud."
        case .notAuthenticated:
            return "Not signed into iCloud — data stays on this device."
        case .badContainer, .unknownItem:
            return "iCloud container not configured — sync paused until Developer portal is set up."
        case .networkUnavailable, .networkFailure:
            return "Offline — will sync when the network returns."
        default:
            if (error as NSError).localizedDescription.localizedCaseInsensitiveContains("quota") {
                return "iCloud storage full — sync paused."
            }
            return "iCloud sync issue — using this device until it clears."
        }
    }
}
