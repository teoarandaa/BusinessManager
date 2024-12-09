import SwiftUI
import SwiftData

@main
struct BusinessManagerApp: App {
    let container: ModelContainer
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        do {
            let schema = Schema([
                Report.self,
                Goal.self,
                Task.self
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
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(container)
    }
}
