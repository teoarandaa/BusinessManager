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
                Task.self,
                QualityMetric.self,
                QualityInsight.self
            ])
            
            container = try ModelContainer(for: schema)
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
