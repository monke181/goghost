import FamilyControls
import ManagedSettings
import Foundation

@Observable
final class ScreenTimeManager {
    static let shared = ScreenTimeManager()

    var authorizationStatus: AuthorizationStatus = .notDetermined
    var activitySelection: FamilyActivitySelection = FamilyActivitySelection()

    private let store = ManagedSettingsStore()

    private init() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        activitySelection = Self.loadSelection()
    }

    // ── Authorization ────────────────────────────────────────────────────

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            // User declined or error — status reflects truth below
        }
        await MainActor.run {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        }
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
