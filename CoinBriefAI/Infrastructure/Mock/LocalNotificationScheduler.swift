import Foundation
import UserNotifications

actor LocalNotificationScheduler: NotificationScheduling {
    private var currentRules = NotificationRule.defaults

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    func rules() async -> [NotificationRule] {
        currentRules
    }

    func update(rule: NotificationRule) async throws {
        guard let index = currentRules.firstIndex(where: { $0.id == rule.id }) else { return }
        currentRules[index] = rule
    }

    func scheduleDigest(rule: NotificationRule) async throws {
        guard rule.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "CoinBrief AI"
        content.body = "\(rule.reason.label): source-backed crypto context is ready."
        content.sound = .default
        content.userInfo = [
            "reason": rule.reason.rawValue,
            "frequencyCapPerDay": rule.frequencyCapPerDay
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: rule.reason.rawValue, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}

