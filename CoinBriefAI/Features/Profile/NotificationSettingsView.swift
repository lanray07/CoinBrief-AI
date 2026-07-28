import Combine
import SwiftUI

@MainActor
final class NotificationSettingsViewModel: ObservableObject {
    @Published var rules: [NotificationRule] = []
    @Published var authorizationMessage: String?

    private var notificationService: (any NotificationScheduling)?

    func configure(notificationService: any NotificationScheduling) {
        if self.notificationService == nil {
            self.notificationService = notificationService
        }
    }

    func load() async {
        guard let notificationService else { return }
        rules = await notificationService.rules()
    }

    func requestPermission() async {
        guard let notificationService else { return }

        do {
            let granted = try await notificationService.requestAuthorization()
            authorizationMessage = granted ? "Notifications allowed." : "Notifications were not allowed."
        } catch {
            authorizationMessage = "Notification permission failed."
        }
    }

    func setEnabled(_ enabled: Bool, for rule: NotificationRule) async {
        var updated = rule
        updated.isEnabled = enabled
        await update(updated)
    }

    func setFrequency(_ frequency: Int, for rule: NotificationRule) async {
        var updated = rule
        updated.frequencyCapPerDay = frequency
        await update(updated)
    }

    private func update(_ rule: NotificationRule) async {
        guard let notificationService else { return }

        do {
            try await notificationService.update(rule: rule)
            if rule.isEnabled {
                try await notificationService.scheduleDigest(rule: rule)
            }
            await load()
        } catch {
            authorizationMessage = "Could not update notification settings."
        }
    }
}

struct NotificationSettingsView: View {
    @Environment(\.appDependencies) private var dependencies
    @StateObject private var viewModel = NotificationSettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(
                    title: "Notifications",
                    subtitle: "Every notification includes a reason and respects quiet hours.",
                    systemImage: "bell"
                )

                Button {
                    Task { await viewModel.requestPermission() }
                } label: {
                    Label("Allow Notifications", systemImage: "bell.badge")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(CoinBriefTheme.cyan)

                if let authorizationMessage = viewModel.authorizationMessage {
                    Text(authorizationMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.rules) { rule in
                    NotificationRuleRow(
                        rule: rule,
                        onEnabled: { enabled in Task { await viewModel.setEnabled(enabled, for: rule) } },
                        onFrequency: { frequency in Task { await viewModel.setFrequency(frequency, for: rule) } }
                    )
                }
            }
            .padding(16)
        }
        .background(CoinBriefTheme.background)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(notificationService: dependencies.notificationService)
            await viewModel.load()
        }
    }
}

private struct NotificationRuleRow: View {
    let rule: NotificationRule
    let onEnabled: (Bool) -> Void
    let onFrequency: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: Binding(get: { rule.isEnabled }, set: onEnabled)) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(rule.reason.label)
                        .font(.headline)
                    Text("Reason sent: \(rule.reason.label)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Stepper(value: Binding(get: { rule.frequencyCapPerDay }, set: onFrequency), in: 1...8) {
                Text("Daily cap: \(rule.frequencyCapPerDay)")
                    .font(.subheadline)
            }

            Text("Quiet hours: \(rule.quietHoursStart):00 to \(rule.quietHoursEnd):00")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .coinCard()
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environment(\.appDependencies, .preview)
    }
}

