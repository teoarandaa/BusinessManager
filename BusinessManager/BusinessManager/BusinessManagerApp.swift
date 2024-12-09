import SwiftUI
import SwiftData

@main
struct BusinessManagerApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Report.self,
                Goal.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(container)
    }
}
