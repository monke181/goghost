import SwiftUI
import SwiftData
import FamilyControls

@main
struct NinetyDayRunApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Run.self, DailyEntry.self, FocusSession.self, JournalEntry.self)
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
        SubscriptionManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootRouter()
                .modelContainer(container)
                .preferredColorScheme(.dark)
                .environment(ScreenTimeManager.shared)
                .environment(SubscriptionManager.shared)
        }
    }
}
