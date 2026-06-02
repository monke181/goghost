import FamilyControls
import ManagedSettings
import Combine
import Foundation

@MainActor
@Observable
final class ScreenTimeManager {
    static let shared = ScreenTimeManager()

    var authorizationStatus: AuthorizationStatus = .notDetermined
    var activitySelection: FamilyActivitySelection = FamilyActivitySelection()

    private let store = ManagedSettingsStore()
    // @ObservationIgnored so the macro doesn't wrap AnyCancellable in observation tracking
    @ObservationIgnored private var cancellable: AnyCancellable?

    private init() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        activitySelection = Self.loadSelection()

        // Observe the system publisher — status updates arrive async after the
        // permission dialog is dismissed, so a one-shot sync read misses the change.
        cancellable = AuthorizationCenter.shared.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.authorizationStatus = status
            }
    }

    // ── Authorization ────────────────────────────────────────────────────

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            print("[ScreenTime] authorization failed: \(error)")
        }
        // Status update comes through the Combine publisher above — no sync read needed
    }

    func refreshAuthStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    // ── Selection ────────────────────────────────────────────────────────

    func saveSelection(_ selection: FamilyActivitySelection) {
        activitySelection = selection
        guard let data = try? JSONEncoder().encode(selection) else { return }
        UserDefaults.standard.set(data, forKey: AppStorageKeys.familyActivitySelection)
    }

    var isSelectionEmpty: Bool {
        activitySelection.applicationTokens.isEmpty &&
        activitySelection.categoryTokens.isEmpty &&
        activitySelection.webDomainTokens.isEmpty
    }

    var selectionSummary: String {
        var parts: [String] = []
        let apps = activitySelection.applicationTokens.count
        let cats = activitySelection.categoryTokens.count
        if apps > 0 { parts.append("\(apps) APP\(apps == 1 ? "" : "S")") }
        if cats > 0 { parts.append("\(cats) CATEGOR\(cats == 1 ? "Y" : "IES")") }
        return parts.isEmpty ? "NONE SELECTED" : parts.joined(separator: ", ")
    }

    // ── Shield ───────────────────────────────────────────────────────────

    func activateShield() {
        guard authorizationStatus == .approved, !isSelectionEmpty else { return }
        let sel = activitySelection
        store.shield.applications = sel.applicationTokens.isEmpty ? nil : sel.applicationTokens
        store.shield.applicationCategories = sel.categoryTokens.isEmpty ? nil : .specific(sel.categoryTokens)
        store.shield.webDomains = sel.webDomainTokens.isEmpty ? nil : sel.webDomainTokens
    }

    func deactivateShield() {
        store.clearAllSettings()
    }

    // ── Persistence ──────────────────────────────────────────────────────

    private static func loadSelection() -> FamilyActivitySelection {
        guard
            let data = UserDefaults.standard.data(forKey: AppStorageKeys.familyActivitySelection),
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return FamilyActivitySelection() }
        return selection
    }
}
