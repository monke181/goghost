import SwiftUI
import SwiftData

@main
struct GoGhostApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Run.self, DailyEntry.self, FocusSession.self)
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootRouter()
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    }
}
